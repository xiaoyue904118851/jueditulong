--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/14 11:07
-- To change this template use File | Settings | File Templates.
--

local PanelMall = {}
local var = {}

local MALL_TAG = {
    MALLLIST = 1,
    JISHOU = 2,
    CHARGE = 3,
}


local MALL_TAG_NAME = {
    [MALL_TAG.MALLLIST] = "商城",
    [MALL_TAG.JISHOU] = "寄售",
    [MALL_TAG.CHARGE] = "充值",
}

function PanelMall.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = MALL_TAG.MALLLIST
    if params.extend and params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    end
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelMall/UI_Mall_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_mall")
    var.titleLabel = var.widget:getWidgetByName("Label_Title")
    var.viewBg = var.widget:getWidgetByName("ImageView_mallboard")

    PanelMall.handleMoneyChange()
    PanelMall.handleLiquanChange()
    PanelMall.addMenuTabClickEvent()
    PanelMall.registeEvent()
    return var.widget
end

function PanelMall.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_GAME_MONEY_CHANGE, PanelMall.handleMoneyChange)
    :addEventListener(Notify.EVENT_GAME_LIQUAN_CHANGE, PanelMall.handleLiquanChange)
    :addEventListener(Notify.EVENT_MALL_CHANGE_INFO, PanelMall.handlePanelChangge)
end

function PanelMall.addMenuTabClickEvent()
    var.UIRadioButtonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_mall"))
    :addButton(var.widget:getWidgetByName("Button_jishou"))
    :addButton(var.widget:getWidgetByName("Button_charge"))
    :onButtonSelectChanged(function(event)
        PanelMall.updatePanelByTag(event.selected)
    end)
    :onButtonSelectChangedBefor(function(event)
        return PanelMall.checkButtonClicked(event.selected)
    end)

    var.UIRadioButtonGroup:setButtonSelected(var.selectTab)

    var.widget:getWidgetByName("Button_jishou"):hide()
    var.widget:getWidgetByName("Button_charge"):setPosition(var.widget:getWidgetByName("Button_jishou"):getPosition())
end

function PanelMall.handlePanelChangge(event)
    if not event or not event.tag then return end
    var.selectTab = MALL_TAG.CHARGE
    var.UIRadioButtonGroup:setButtonSelected(var.selectTab)
end

function PanelMall.checkButtonClicked(tag)
    return true
end

function PanelMall.updatePanelByTag(tag)
    if var.subView then var.subView:removeFromParent() var.subView = nil end
    local viewName

    if tag == MALL_TAG.MALLLIST then
        viewName = "app.views.mall.MallListView"
    elseif tag == MALL_TAG.JISHOU then
--        viewName = "app.views.mall.JiShouView"
    elseif tag == MALL_TAG.CHARGE then
        viewName = "app.views.mall.ChargeView"
    end

    if viewName then
        var.subView = require(viewName).initView({ parent = var.viewBg})
    end

    local title = MALL_TAG_NAME[tag] or ""
    var.titleLabel:setString(title)
end

function PanelMall.handleMoneyChange()
    var.widget:getWidgetByName("img_head_bg"):getWidgetByName("label_gold"):setString(NetClient.mCharacter.mGameMoney)
    var.widget:getWidgetByName("img_head_bg"):getWidgetByName("label_gold_bind"):setString(NetClient.mCharacter.mGameMoneyBind)
    var.widget:getWidgetByName("img_head_bg"):getWidgetByName("label_vcion"):setString(NetClient.mCharacter.mVCoin)
    var.widget:getWidgetByName("img_head_bg"):getWidgetByName("label_vcoin_bind"):setString(NetClient.mCharacter.mVCoinBind)
end

function PanelMall.handleLiquanChange()
    var.widget:getWidgetByName("img_head_bg"):getWidgetByName("label_lq"):setString(NetClient.mCharacter.mLiquan)
end

return PanelMall