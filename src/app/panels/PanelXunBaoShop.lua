--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelAwardHall

local PanelXunBaoShop = {}
local var = {}
local ACTIONSET_NAME = "lottery"
 

function PanelXunBaoShop.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = 1
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelXunBao/UI_JiFenExchange_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_shenlu")
    var.rlistView = var.widget:getWidgetByName("ListView_rightlist")
    var.rlistItem = var.widget:getWidgetByName("Image_frame"):hide()
    var.duiListView = var.widget:getWidgetByName("ListView_rightren")
    --PanelXunBaoShop.updateXunbaoJf()
    var.widget:getWidgetByName("Label_jifennum"):setString(NetClient.mXunbaoJf)
    var.logNumber = 0
    PanelXunBaoShop.addMenuTabClickEvent()
    PanelXunBaoShop.registeEvent()
    if not NetClient.mGetExchangeList then
        NetClient.mGetExchangeList = true
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="lottery_log"}))
    else
        PanelXunBaoShop.updateDuihuaninfo()
    end
    return var.widget
end

function PanelXunBaoShop.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_XUNBAO_EXCHANGE_LIST, PanelXunBaoShop.updateDuihuaninfo)
    :addEventListener(Notify.EVENT_XUNBAO_EXCHANGE_NEW, PanelXunBaoShop.handleNewDuihuanLog)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelXunBaoShop.updateXunbaoJf)
end

function PanelXunBaoShop.addMenuTabClickEvent()
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    local px = -11
    local py = 551.00
    for k, v in ipairs(XunbaoShopDefData) do
        local btnOp = ccui.Button:create()
        btnOp:loadTextures("button_table2.png","button_table2_sel.png","",UI_TEX_TYPE_PLIST)
        btnOp:setTitleFontSize(24)
        btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
        btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
        btnOp:setTitleText(v.mName)
        btnOp:setTag(k)
        btnOp:align(display.CENTER, px, py)
        btnOp:addTo(var.widget)
        py = py - 84
        btnOp:getTitleRenderer():setPositionX(62)
        UIRadioButtonGroup:addButton(btnOp)
    end
    UIRadioButtonGroup:onButtonSelectChanged(function(event)
        var.selectTab = event.selected
        PanelXunBaoShop.updateLeftInfo()
    end)

    UIRadioButtonGroup:setButtonSelected(var.selectTab)
end

function PanelXunBaoShop.updateXunbaoJf(event)
    if event.type == nil then return end
    if event.type ~= ACTIONSET_NAME then return end
    local d = util.decode(event.data)
    if d.actionid == "queryupdateinfo" then
        var.widget:getWidgetByName("Label_jifennum"):setString(NetClient.mXunbaoJf)
    end 
end

function PanelXunBaoShop.updateLeftInfo()
    var.rlistView:removeAllItems()
    local infodata = NetClient:getXunbaoShopList(var.selectTab)
    for i = 1,#infodata do
        local data = infodata[i]
        local listItem = var.rlistItem:clone():show()
         UIItem.getSimpleItem({
            parent = listItem:getWidgetByName("Image_item"),
            typeId = data.itemid,
        })
        listItem:getWidgetByName("Label_iname"):setString(data.name)
        local costmsg = ""
        if data.n_item and data.n_item ~= "" then
            costmsg = costmsg..data.n_item
        end
        if data.need and data.need > 0 then
            if costmsg ~= "" then costmsg = costmsg.."+" end
            costmsg = costmsg..game.make_str_with_color(Const.COLOR_GREEN_1_STR,data.need.."积分")
        end

        if costmsg ~= "" then
            costmsg = game.make_str_with_color(Const.COLOR_WHITE_1_STR,"消耗:")..costmsg
            local richLabel, richWidget = util.newRichLabel(cc.size(500, 0), 3)
            richWidget.richLabel = richLabel
            util.setRichLabel(richLabel, costmsg, "", 24, Const.COLOR_YELLOW_1_OX)
            richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(112.5,20))
            listItem:addChild(richWidget)
        end

        listItem:getWidgetByName("Button_go")
        :setTag(data.idx)
        :addClickEventListener(function(pSender)
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="buy",param = {page = var.selectTab,idx =pSender:getTag()}}))
        end)

        var.rlistView:pushBackCustomItem(listItem)
    end
end

function PanelXunBaoShop.handleNewDuihuanLog()
    PanelXunBaoShop.insertDuihuaninfo(#NetClient.mXunbaoShopExchangeLogList)
end

function PanelXunBaoShop.insertDuihuaninfo(idx)
    local data = NetClient.mXunbaoShopExchangeLogList[idx]
    if not data then return end
    local listViewW = var.duiListView:getContentSize().width
    if not data.p_vip then return end
    local strMsg = game.make_str_with_color(Const.COLOR_BLUE_1_STR,data.p_name)..game.make_str_with_color(Const.COLOR_YELLOW_3_STR,"[VIP"..data.p_vip.."]").."获得了"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,data.item or "")--..DateHelper.toDateStr(data.creattime)
    local richLabel, richWidget = util.newRichLabel(cc.size(listViewW - 20, 0), 1)
    richWidget.richLabel = richLabel
    util.setRichLabel(richLabel, strMsg, "", 24, Const.COLOR_GRAY_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    var.duiListView:insertCustomItem(richWidget,0)
    var.logNumber = var.logNumber + 1
    if var.logNumber > Const.MAX_LOTTERY_LOG then
        var.duiListView:removeItem(var.logNumber-1)
        var.logNumber = var.logNumber - 1
    end
end

function PanelXunBaoShop.updateDuihuaninfo()
    var.duiListView:removeAllItems()
    var.logNumber = 0
    if not NetClient.mXunbaoShopExchangeLogList or #NetClient.mXunbaoShopExchangeLogList == 0 then return end

    for idx, data in ipairs(NetClient.mXunbaoShopExchangeLogList) do
        PanelXunBaoShop.insertDuihuaninfo(idx)
    end
end

return PanelXunBaoShop