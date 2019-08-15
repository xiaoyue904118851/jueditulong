--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/25 18:04
-- To change this template use File | Settings | File Templates.
--

local PanelVIP = {}
local var = {}
local VIP_PANEL_TAG = {
    FULI = 1,
    TEQUAN = 2
}
local DESC_WIDGET_NAME = "disText"
function PanelVIP.initView(params)
    local params = params or {}
    var = {}
    var.subView = {}
    var.selectTab = VIP_PANEL_TAG.FULI
    if params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    end
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelVIP/Panel_VIP_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_vip")
    var.viewBg = var.widget:getWidgetByName("Panel_viewbg")
    var.widget:getWidgetByName("Button_go_charge"):addClickEventListener(function(pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
    end)
    PanelVIP.addMenuTabClickEvent()
    PanelVIP.registeEvent()
    asyncload_frames("uilayout/UI_VIP",".png",function ()
        PanelVIP.updateVIPInfo()
    end)
    return var.widget
end

function PanelVIP.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_VIP_LEVEL_CHANGE, PanelVIP.updateVIPInfo)
end

function PanelVIP.updateVIPInfo()
    local levelImg = var.widget:getWidgetByName("Image_top"):getWidgetByName("Image_vip_level")
    levelImg:ignoreContentAdaptWithSize(true)
    local myVipLevel = game.getVipLevel()
    if myVipLevel > 0 then
        levelImg:loadTexture("VIP"..myVipLevel..".png",UI_TEX_TYPE_PLIST)
    else
        levelImg:loadTexture("zanweikaiqi.png",UI_TEX_TYPE_PLIST)
    end

    local parent = var.widget:getWidgetByName("Text_chongzhi_tips")
    if parent:getChildByName(DESC_WIDGET_NAME) then
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

    var.widget:getWidgetByName("Image_top"):getWidgetByName("Label_charge"):setString(NetClient.mLeijiChongzhiYb.."/"..nexttotal)
    var.widget:getWidgetByName("Image_top"):getWidgetByName("LoadingBar_vip"):setPercent((NetClient.mLeijiChongzhiYb/nexttotal)*100)
end

function PanelVIP.addMenuTabClickEvent()
    local buttonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_fuli"))
    :addButton(var.widget:getWidgetByName("Button_tequan") )
    :onButtonSelectChanged(function(event)
        PanelVIP.updatePanelByTag(event.selected)
    end)
    buttonGroup:setButtonSelected(var.selectTab)

    for i = 1, buttonGroup:getButtonsCount() do
        buttonGroup:getButtonAtIndex(i):getTitleRenderer():setPositionY(17)
    end
end

function PanelVIP.updatePanelByTag(tag)
    if tag == VIP_PANEL_TAG.FULI then
        if var.subView[VIP_PANEL_TAG.TEQUAN]  then
            var.subView[VIP_PANEL_TAG.TEQUAN]:hide()
        end
        if var.subView[tag] then
            var.subView[tag]:setVisible(true)
        else
            var.subView[tag] = require("app.views.vip.VipFuliView").initView({ parent = var.viewBg, tag = tag})
        end
    elseif tag == VIP_PANEL_TAG.TEQUAN then
        if var.subView[VIP_PANEL_TAG.FULI]  then
            var.subView[VIP_PANEL_TAG.FULI]:hide()
        end
        if var.subView[tag] then
            var.subView[tag]:setVisible(true)
        else
            var.subView[tag] = require("app.views.vip.VipTequanView").initView({ parent = var.viewBg, tag = tag})
        end
    end
end

function PanelVIP.onPanelClose()
    var.subView = {}
    remove_frames("uilayout/UI_VIP",Const.TEXTURE_TYPE.PNG)
end

return PanelVIP