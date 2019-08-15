--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/28 14:08
-- To change this template use File | Settings | File Templates.
-- PanelFangchenmi

local PanelFangchenmi = {}
local var = {}
function PanelFangchenmi.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelFcm/UI_Fangchenmi_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_fcm")
    PanelFangchenmi.addDesc()
    PanelFangchenmi.updateWidget()
    PanelFangchenmi.registeEvent()
    return var.widget
end

function PanelFangchenmi.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_FANGCHENMI_CHANGE, PanelFangchenmi.updateWidget)
end

function PanelFangchenmi.addDesc()
    local scroll = var.widget:getWidgetByName("ScrollView_desc")
    local innerSize = scroll:getInnerContainerSize()
    local contentSize = scroll:getContentSize()
    local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width-10,0))
    util.setRichLabel(richLabel,NetClient.mFcmDescList[1] or "","",24, Const.COLOR_YELLOW_1_OX)
    scroll:setClippingEnabled(true)
    richLabel:setVisible(true)
    richWidget:setContentSize(cc.p(contentSize.width-10,richLabel:getRealHeight()))

    if richLabel:getRealHeight() < contentSize.height then
        richWidget:setPosition(cc.p(0,contentSize.height-richLabel:getRealHeight()))
        scroll:setBounceEnabled(false)
    else
        richWidget:setPosition(cc.p(0,0))
        scroll:setBounceEnabled(true)
    end

    scroll:addChild(richWidget,10)
    scroll:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
    scroll:jumpToPercentVertical(0)
end

function PanelFangchenmi.updateWidget()
    if NetClient.mFcmInfo.china_id == Const.FCM_TYPE.UNVALID then
        var.widget:getWidgetByName("ImageView_name_bg"):show()
        var.widget:getWidgetByName("ImageView_iden_bg"):show()
        var.widget:getWidgetByName("Text_name_value"):hide()
        var.widget:getWidgetByName("Text_iden_value"):hide()
        var.widget:getWidgetByName("btn_done"):setTouchEnabled(true)
        var.widget:getWidgetByName("btn_done"):setBright(true)
        var.widget:getWidgetByName("btn_done"):addClickEventListener(function (pSender)
            PanelFangchenmi.checkSubmit()
        end)
    else
        var.widget:getWidgetByName("ImageView_name_bg"):hide()
        var.widget:getWidgetByName("ImageView_iden_bg"):hide()
        var.widget:getWidgetByName("Text_name_value"):hide()
        var.widget:getWidgetByName("Text_iden_value"):hide()
        var.widget:getWidgetByName("Text_name"):hide()
        var.widget:getWidgetByName("Text_iden"):hide()

        var.widget:getWidgetByName("btn_done"):setTouchEnabled(false)
        var.widget:getWidgetByName("btn_done"):setBright(false)
    end
end

function PanelFangchenmi.checkSubmit()
    local name = var.widget:getWidgetByName("TextField_name"):getString()
    local id = var.widget:getWidgetByName("TextField_iden"):getString()
    local check_id = 0

    if name == "" then
        NetClient:alertLocalMsg("请输入姓名！","alert")
        return
    end

    if id == "" then
        NetClient:alertLocalMsg("请输入身份证号！","alert")
        return
    end
   
    if string.len(name) > 12 then
        NetClient:alertLocalMsg("请输入合法的姓名！","alert")
        return
    end
     
    if string.len(id) ~= 18 or checkint(string.sub(id, 1, 17)) == 0 then
        NetClient:alertLocalMsg("请输入合法的身份证！","alert")
        return
    end

    local curData = os.date("*t")
    local startday = string.sub(id, 7, 10)*365 + string.sub(id, 11, 12)*31 + string.sub(id, 13, 14)
    local curday = curData.year*365 + curData.month*31 + curData.day

    if curday - startday <= 0 then
        NetClient:alertLocalMsg("请输入合法的身份证！","alert")
        return
    end

    if curday - startday <= 18*365 then
        check_id = Const.FCM_TYPE.TEENAGE
    else
        check_id = Const.FCM_TYPE.PASS
    end

    NetClient.mFcmInfo.china_id = check_id
    PanelFangchenmi.updateWidget()
    NetClient:sendFangchengmi(id, name, check_id)
end

return PanelFangchenmi