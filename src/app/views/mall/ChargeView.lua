--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2018/01/22 19:04
-- To change this template use File | Settings | File Templates.
--

local ChargeView = {}
local var = {}
local DESC_WIDGET_NAME = "disText"
function ChargeView.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelMall/UI_Charge.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_charge")

    var.listView = var.widget:getWidgetByName("ListView_charge")
    var.srcListItem = var.widget:getWidgetByName("Image_list_item"):hide()

    var.widget:getWidgetByName("Button_go_vip"):addClickEventListener(function(pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_vip"})
    end)

    asyncload_frames("uilayout/UI_VIP",".png",function ()
        ChargeView.updateVIPInfo()
    end)

    widget:onNodeEvent("exit", function()
        remove_frames("uilayout/UI_VIP",".png")
    end)

    ChargeView.updateListView()
    ChargeView.registeEvent()
    return widget
end

function ChargeView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_VIP_LEVEL_CHANGE, ChargeView.updateVIPInfo)
end

function ChargeView.updateVIPInfo()
    var.widget:getWidgetByName("Image_myvip"):ignoreContentAdaptWithSize(true)
    local myVipLevel = game.getVipLevel()
    if myVipLevel > 0 then
        var.widget:getWidgetByName("Image_myvip"):loadTexture("VIP"..myVipLevel..".png",UI_TEX_TYPE_PLIST)
    else
        var.widget:getWidgetByName("Image_myvip"):loadTexture("zanweikaiqi.png",UI_TEX_TYPE_PLIST)
    end

    local parent = var.widget:getWidgetByName("Text_chongzhi_tips")
    if parent:getWidgetByName(DESC_WIDGET_NAME) then
        parent:removeChildByName(DESC_WIDGET_NAME)
    end
    local dis, nexttotal = game.getNextVipLevelNeedTotal()

    local dismsg = ""
    if dis == -1 then
        dismsg = "已达满级"
    else
        dismsg = "再充值"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,dis).."元宝，即可升级到"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,"VIP "..(myVipLevel+1))
    end
    local richLabel, richWidget = util.newRichLabel(cc.size(parent:getContentSize().width, 0), 3)
    richWidget.richLabel = richLabel
    util.setRichLabel(richLabel, dismsg,"", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
    richWidget:align(display.CENTER_BOTTOM, parent:getContentSize().width/2, 0)
    richWidget:setName(DESC_WIDGET_NAME)
    parent:addChild(richWidget)

    var.widget:getWidgetByName("Label_bar_charge"):setString(NetClient.mLeijiChongzhiYb.."/"..nexttotal)
    var.widget:getWidgetByName("LoadingBar_vip"):setPercent((NetClient.mLeijiChongzhiYb/nexttotal)*100)
end

function ChargeView.updateListView()
    var.listView:removeAllItems()
    var.listData = CHARGE_CFG

    UIGridView.new({
        list = var.listView,
        gridCount = #var.listData,
        cellSize = cc.size(980, 233),
        columns = 4,
        initGridListener = ChargeView.initGridFunc
    })
end

function ChargeView.initGridFunc(gridWidget, index)
    local listItem = var.srcListItem:clone():show()
    listItem:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)

    local cfgInfo = var.listData[index]
    listItem:getWidgetByName("Image_vcoin"):loadTexture("uilayout/image/charge/"..cfgInfo.rmb.."yuan.jpg",UI_TEX_TYPE_LOCAL)
    listItem:getWidgetByName("Image_vcoin"):ignoreContentAdaptWithSize(true)

    listItem:getWidgetByName("Label_paytitle"):setString(cfgInfo.num.."元宝")
    listItem:getWidgetByName("AtlasLabel_pay"):setString(cfgInfo.rmb)

    listItem:setTouchEnabled(true):addClickEventListener(function()
        print("pay info ", cfgInfo.num, cfgInfo.rmb)
        PlatformTool.pay(cfgInfo)
    -- TODO
    end)
end

return ChargeView