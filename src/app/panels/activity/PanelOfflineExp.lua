--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2018/01/08 13:35
-- To change this template use File | Settings | File Templates.
--

local PanelOfflineExp = {}
local var = {}
local ACTIONSET_NAME = "newOfflineExp"

function PanelOfflineExp.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelOfflineExp.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_offlineexp")
    PanelOfflineExp.addBtnClicedEvent()
    PanelOfflineExp.registeEvent()
    if not NetClient.mOfflineExpInfo then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="getCurrentOfflineExp"}))
    else
        PanelOfflineExp.updateInfo()
    end
    return var.widget
end

function PanelOfflineExp.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelOfflineExp.handleOfflineExpMsg)
end

function PanelOfflineExp.handleOfflineExpMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
        return
    end
    PanelOfflineExp.updateInfo()
end

function PanelOfflineExp.updateInfo()
    if not NetClient.mOfflineExpInfo then return end
    var.widget:getWidgetByName("Text_off_time_t"):getWidgetByName("Text_value"):setString(DateHelper.convertSecondsToStr(NetClient.mOfflineExpInfo.offlinemin*60))
    var.widget:getWidgetByName("Text_off_exp_t"):getWidgetByName("Text_value"):setString(NetClient.mOfflineExpInfo.a1.exp)
    var.widget:getWidgetByName("Text_off_vip_t"):getWidgetByName("Text_value"):setString(NetClient.mOfflineExpInfo.a1.exp - NetClient.mOfflineExpInfo.a0.exp)

    var.widget:getWidgetByName("Text_cost_vcoin"):getWidgetByName("Text_value"):setString(NetClient.mOfflineExpInfo.a2.money)

    local bgsize = var.widget:getWidgetByName("Text_vip_tips"):getContentSize()
    local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, NetClient.mOfflineExpInfo.desc, "", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    richWidget:setAnchorPoint(cc.p(0,0))
    richWidget:setPosition(cc.p(334, 80))
    var.widget:getWidgetByName("Panel_offlineexp"):addChild(richWidget)
end

function PanelOfflineExp.addBtnClicedEvent()
    var.widget:getWidgetByName("Button_free"):addClickEventListener(function (pSender)
        if NetClient.mOfflineExpInfo then
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="drawCurrentOfflineExp",params=1}))
        end
    end)
    var.widget:getWidgetByName("Button_double"):addClickEventListener(function (pSender)
        if NetClient.mOfflineExpInfo then
            local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm =  "花费"..NetClient.mOfflineExpInfo.a2.money.."元宝领取双倍奖励？",
                confirmTitle = "领 取", cancelTitle = "算 了",
                confirmCallBack = function ()
                    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="drawCurrentOfflineExp",params=2}))
                end
            }
            NetClient:dispatchEvent(param)
        end
    end)
end

return PanelOfflineExp