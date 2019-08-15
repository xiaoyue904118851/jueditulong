--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/11 12:03
-- To change this template use File | Settings | File Templates.
--

local PanelPreOpen= {}
local var = {}

function PanelPreOpen.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelPreOpen/UI_PreOpen_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_preopen")
    PanelPreOpen.initWidget()
    PanelPreOpen.updateWidget()
    PanelPreOpen.registeEvent()
    return var.widget
end

function PanelPreOpen.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_LEVEL_CHANGE, PanelPreOpen.updateLvInfo)
end

function PanelPreOpen.initWidget()
    var.infoPanel = var.widget:getWidgetByName("Panel_info"):setOpacity(0)
    var.titleText = var.infoPanel:getWidgetByName("Text_title")
    var.imgIcon = var.infoPanel:getWidgetByName("Image_icon")
    var.despText = var.infoPanel:getWidgetByName("Text_desp")
    var.mlvText = var.infoPanel:getWidgetByName("Text_mlv")
    var.openlvText = var.infoPanel:getWidgetByName("Text_olv")

    gameEffect.playEffectByType(gameEffect.EFFECT_JUANZHOU,{})
    :setPosition(cc.p(260, 216)):addTo(var.widget,-1)

    var.infoPanel:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.FadeIn:create(0.1)
    ))


   var.infoPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
        var.widget:getWidgetByName("Panel_close"):show()
    end)))

--    local sp = cc.Sprite:create("uilayout/image/zhankai_bg.png")
--    sp:addChild(var.infoPanel:clone():show())
--
--    local bar = cc.ProgressTimer:create(sp)
--    :align(display.CENTER, 260, 208.50)
--    :addTo(var.widget)
--    bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
--    bar:setMidpoint(cc.p(0.5, 0.5))
--    bar:setBarChangeRate(cc.p(1,0))
--
--    bar:runAction(cc.ProgressFromTo:create(1,0,100))
end

function PanelPreOpen.updateWidget()
    local rolelevel = game.getRoleLevel()
    var.finfo = game.getPreFuncInfo(rolelevel)
    if var.finfo then
        var.imgIcon:loadTexture(var.finfo.icon, UI_TEX_TYPE_PLIST)
        var.titleText:setString(var.finfo.name)
        var.despText:setString(var.finfo.desp)
        var.openlvText:setString("/"..var.finfo.level.."级")
        var.mlvText:setString(rolelevel)
    end
end

function PanelPreOpen.updateLvInfo()
    local rolelevel = game.getRoleLevel()
    var.mlvText:setString(rolelevel)
    if var.finfo then
        var.mlvText:setTextColor(var.finfo.level>rolelevel and Const.COLOR_RED_1_C3B or Const.COLOR_GREEN_1_C3B)
    end
end

return PanelPreOpen