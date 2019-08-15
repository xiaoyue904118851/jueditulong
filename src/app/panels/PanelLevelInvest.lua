--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.

local PanelLevelInvest = {}
local var = {}
local ACTIONSET_NAME = "levelInvest"

function PanelLevelInvest.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelLevelInvest/PanelLevelInvest.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_levelinvest")

    var.listView = var.widget:getWidgetByName("ListView_itemlist")
    var.listitem = var.widget:getWidgetByName("Image_frame"):hide()

    var.investBtn = var.widget:getWidgetByName("Button_invest")

    if not NetClient.mLevelInvestInfo then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="queryinfo"}))
    else
        PanelLevelInvest.updateAllListView()
        PanelLevelInvest.updateBaseInfo()
    end

    PanelLevelInvest.registeEvent()
    return var.widget
end

function PanelLevelInvest.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelLevelInvest.handleLevelInvestInfo)
end

function PanelLevelInvest.handleLevelInvestInfo(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
        return
    end

    if d.actionid == "queryinfo" or d.actionid == "startInvest" then
        PanelLevelInvest.updateAllListView()
        PanelLevelInvest.updateBaseInfo()
    elseif d.actionid == "getAward" then
        PanelLevelInvest.updateAllListView()
    end
end

function PanelLevelInvest.updateBaseInfo()
    if not var.showDesc and NetClient.mLevelInvestInfo.desc then
        var.showDesc = true
        local richLabel, richWidget = util.newRichLabel(cc.size(750, 0), 3)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel, NetClient.mLevelInvestInfo.desc,"", 26, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
        richWidget:align(display.LEFT_BOTTOM,30,300)
        richWidget:addTo(var.widget)
    end

    if NetClient.mLevelInvestInfo.flag == 0 then
        var.investBtn:show()
        var.investBtn:addClickEventListener(function (pSender)
            if not game.checkBtnClick() then return end
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="startInvest"}))
        end)
    else
        var.investBtn:hide()
    end
end

function PanelLevelInvest.updateAllListView()
    var.listView:removeAllItems()
    if not NetClient.mLevelInvestInfo.list or #NetClient.mLevelInvestInfo.list == 0 then return end

--    已经投资了才需要排序
--    print("#NetClient.mLevelInvestInfo.list================",#NetClient.mLevelInvestInfo.list )
    if NetClient.mLevelInvestInfo.flag ~= 0 and #NetClient.mLevelInvestInfo.list > 0 then
        local function sortV( a, b )
--            print("sss", a.flag, a.canGet,a.zslevel, a.level)
            if a.flag < b.flag then
                return true
            end

            if a.flag > b.flag then
                return false
            end

            if a.flag == 0 then
                if a.canGet > b.canGet then
                    return true
                end

                if a.canGet < b.canGet then
                    return false
                end
            end

            if a.zslevel > b.zslevel then
                return false
            end

            if a.zslevel < b.zslevel then
                return true
            end

            return a.level < b.level
        end
        table.sort( NetClient.mLevelInvestInfo.list, sortV )
    end


    for idx = 1, #NetClient.mLevelInvestInfo.list do
        local item = PanelLevelInvest.updateListItem(idx)
        var.listView:pushBackCustomItem(item)
    end
end

function PanelLevelInvest.updateListItem(idx)
    local cell = var.listitem:clone():show()

    local info = NetClient.mLevelInvestInfo.list[idx]
    local awardlist = info.award
    for i = 1, 2 do
        if awardlist[i] then
            local itemNode = cell:getWidgetByName("Image_item"..i):show()
            UIItem.cleanSimpleItem(itemNode)
            itemNode:setTouchEnabled(true)
            UIItem.getSimpleItem({
                parent = itemNode,
                typeId = awardlist[i].typeid,
                num = awardlist[i].num,
            })
        else
            cell:getWidgetByName("Image_item"..i):hide()
        end
    end
    local msg = "等级达到"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,info.level).."级"
    if info.zslevel > 0 then
        msg = "转生达到"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,info.zslevel).."级"
    end
    local width = cell:getContentSize().width - 60
    local richLabel, richWidget = util.newRichLabel(cc.size(width, 0), 3)
    richWidget.richLabel = richLabel
    util.setRichLabel(richLabel, msg,"", 26, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
    richWidget:align(display.LEFT_CENTER,28,cell:getContentSize().height/2)
    richWidget:addTo(cell)

    local getbtn = cell:getWidgetByName("Button_get")
    if NetClient.mLevelInvestInfo.flag == 0 then
        getbtn:setTouchEnabled(false)
        getbtn:setBright(false)
        getbtn:removeAllChildren()
        cell:getWidgetByName("Image_btn_got_flag"):hide()
    else
        if info.flag == 1 then
            getbtn:hide()
            cell:getWidgetByName("Image_btn_got_flag"):show()
        else
            cell:getWidgetByName("Image_btn_got_flag"):hide()
            local canGet = false
            if info.zslevel > 0 then
                if game.getZsLevel() >= info.zslevel then
                    canGet = true
                end
            elseif info.level > 0 then
                if game.getRoleLevel() >= info.level then
                    canGet = true
                end
            end

            getbtn:setTouchEnabled(canGet)
            getbtn:setBright(canGet)

            if canGet then
                gameEffect.getNormalBtnSelectEffect()
                :setPosition(cc.p(getbtn:getContentSize().width/2,getbtn:getContentSize().height/2))
                :addTo(getbtn)
                getbtn:addClickEventListener(function (pSender)
                    if not game.checkBtnClick() then return end
--                    print("info.id===========", info.id)
                    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="getAward",params=info.id}))
                end)
            end
        end
    end

    return cell
end

return PanelLevelInvest