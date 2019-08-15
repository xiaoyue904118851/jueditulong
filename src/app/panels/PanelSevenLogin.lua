--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2018/01/16 18:53
-- To change this template use File | Settings | File Templates.
--

local PanelSevenLogin = {}
local var = {}
local ACTIONSET_NAME = "totalloginpanel"

local SEVENLOGIN_STATE_VALID = 1 --可领
local SEVENLOGIN_STATE_PASS = 2 --已领
local SEVENLOGIN_STATE_INVALID = 3 --不可领

function PanelSevenLogin.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = 1
    local mainRole = game.GetMainNetGhost()
    var.gender = mainRole:NetAttr(Const.net_gender)
    var.job = mainRole:NetAttr(Const.net_job)
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSevenLogin/UI_SevenLogin_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_7day")
    var.maxDay = #SevenLoginDefData
    PanelSevenLogin.addMenuTabClickEvent()
    var.widget:getWidgetByName("Button_getaward"):addClickEventListener(function(pSender)
        pSender:setTouchEnabled(false)
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "drawCurrentAward",params=var.selectTab}))
    end)
    PanelSevenLogin.freshAllPanel()
    PanelSevenLogin.registeEvent()
    return var.widget
end

function PanelSevenLogin.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_SEVENLOGIN_MSG, PanelSevenLogin.handleSevenLoginMsg)
end

function PanelSevenLogin.addMenuTabClickEvent()
    var.buttonList = {}
    for i = 1, var.maxDay do
        var.buttonList[i] = var.widget:getWidgetByName("Button_day"..i)
        var.buttonList[i].tag = i
        var.buttonList[i]:addClickEventListener(function(pSender)
            PanelSevenLogin.updatePanelByTag(pSender, pSender.tag)
        end)
    end
end

function PanelSevenLogin.updatePanelByTag(pSenfer,tag)
    var.selectTab = tag
    for i = 1, var.maxDay do
        var.buttonList[i]:getWidgetByName("Image_high"):setVisible(i==tag)
    end

    var.widget:getWidgetByName("AtlasLabel_dl_num"):setString(tag)

    local sevenLoginDef = game.getSevenLoginDef(tag)
    if not sevenLoginDef then
        return
    end

    local needLevel = sevenLoginDef.limit.lv
    local needZsLevel = sevenLoginDef.limit.zhuansheng
    var.widget:getWidgetByName("AtlasLabel_need_level"):setString(needZsLevel > 0 and needZsLevel or needLevel)
    var.widget:getWidgetByName("Image_plevel_dw"):loadTexture((needZsLevel > 0 and "zhuan.png" or "ji.png"),UI_TEX_TYPE_PLIST)

    local awardlist = sevenLoginDef["award"][""..var.gender][""..var.job]
    local xMove = 0
    if #awardlist == 3 then xMove = 43 end
    local statrX = 266
    for i = 1, 4 do
        local itemNode = var.widget:getWidgetByName("item_icon_"..i)
        if awardlist[i] then
            if xMove > 0 then itemNode:setPositionX(statrX+xMove) end
            itemNode:setTouchEnabled(true)
            UIItem.getSimpleItem({
                parent = itemNode,
                typeId = awardlist[i].typeid,
                num = awardlist[i].num,
            })
        else
            itemNode:hide()
            itemNode:setTouchEnabled(false)
            UIItem.cleanSimpleItem(itemNode)
        end
        statrX = statrX + 87
    end

    local btn = var.widget:getWidgetByName("Button_getaward")
    local getFlag = var.widget:getWidgetByName("Image_btn_got_flag")

    if pSenfer.s_state == SEVENLOGIN_STATE_PASS then
        getFlag:show()
        btn:hide()
    elseif pSenfer.s_state == SEVENLOGIN_STATE_VALID then
        btn:show()
        getFlag:hide()
        btn:setTouchEnabled(true)
        btn:setBright(true)
    else
        btn:show()
        getFlag:hide()
        btn:setTouchEnabled(false)
        btn:setBright(false)
    end
end

function PanelSevenLogin.handleSevenLoginMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
        return
    end

    if d.actionid == "getAwards" then
        PanelSevenLogin.freshAllPanel()
    elseif d.actionid == "drawCurrentAward" then
        if d.result == 0 then
            PanelSevenLogin.onGetSucess(d.id)
        else
            var.widget:getWidgetByName("Button_getaward"):setTouchEnabled(true)
        end
    end
end

function PanelSevenLogin.freshAllPanel()
    PanelSevenLogin.updateAllAward()
    PanelSevenLogin.updateLoginCnt()
end

function PanelSevenLogin.updateLoginCnt()
    var.widget:getWidgetByName("Text_denglu_tip"):setString(tag)
    local msg = "当前累计登陆"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,NetClient.mSevenLoginInfo.loginCnt).."天"
    local width = var.widget:getContentSize().width/2
    local richLabel, richWidget = util.newRichLabel(cc.size(width, 0), 3)
    richWidget.richLabel = richLabel
    util.setRichLabel(richLabel, msg,"", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    richWidget:setPosition(cc.p(28,20))
    richWidget:addTo(var.widget)
end

function PanelSevenLogin.updateAllAward()
    local firstValidId
    local firstNextId
    for i = 1, var.maxDay do
        local btn = var.buttonList[i]
        local getInfo = NetClient.mSevenLoginInfo.state[i]
        btn:getWidgetByName("Image_redpoint"):hide()
        if getInfo then
            btn:show()
            if getInfo.accept == 1 then
                btn.s_state = SEVENLOGIN_STATE_PASS
                btn:setBright(false)
                btn:setTouchEnabled(false)
            else
                if getInfo.allow == 1 then
                    btn:getWidgetByName("Image_redpoint"):show()
                    btn.s_state = SEVENLOGIN_STATE_VALID
                    if not firstValidId then firstValidId = i end
                else
                    btn.s_state = SEVENLOGIN_STATE_INVALID
                    if not firstNextId then firstNextId = i end
                end
                btn:setBright(true)
                btn:setTouchEnabled(true)
            end
        else
            btn:hide()
        end
    end
    PanelSevenLogin.setSelectTab(firstValidId,firstNextId)
end

function PanelSevenLogin.onGetSucess(id)
    if id > var.maxDay then return end
    local btn = var.buttonList[id]
    if btn then
        btn.s_state = SEVENLOGIN_STATE_PASS
        btn:setBright(false)
        btn:setTouchEnabled(false)
        btn:getWidgetByName("Image_redpoint"):hide()
    end

    local firstValidId,firstNextId = game.getSevenLoginSelectedId()
    PanelSevenLogin.setSelectTab(firstValidId,firstNextId)
end

function PanelSevenLogin.setSelectTab(firstValidId,firstNextId)
    var.selectTab = firstValidId
    if not var.selectTab then
        var.selectTab = firstNextId
    end
    if not var.selectTab then
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_sevenlogin"})
        return
    end

    PanelSevenLogin.updatePanelByTag(var.buttonList[var.selectTab],var.selectTab)
end

return PanelSevenLogin