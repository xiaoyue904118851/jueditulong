--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelAwardHall

local PanelAwardHall = {}
local var = {}

local ROLEINFO_TAG = {
    ONLINE = 1,
    SIGNUP = 2
}

function PanelAwardHall.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0
    var.params = nil
    var.selectTab = ROLEINFO_TAG.ONLINE
    if params.extend and params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    end
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAwardHall/UI_AwardHall_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_awardhall")
    var.viewBg = var.widget:getWidgetByName("Panel_viewbg")

    var.widget:getWidgetByName("Button_sign"):setVisible(NetClient:getTopBtnFlag(Const.TOPBTN.btnDaySign)==2)
    var.widget:getWidgetByName("Button_sign"):setTouchEnabled(NetClient:getTopBtnFlag(Const.TOPBTN.btnDaySign)==2)

    PanelAwardHall.addMenuTabClickEvent()
    return var.widget
end

function PanelAwardHall.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_onlineaward"), types={UIRedPoint.REDTYPE.AWARDHALL_ONLINE}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_sign"), types={UIRedPoint.REDTYPE.AWARDHALL_SIGN}}))
    --:addButton(var.widget:getWidgetByName("Button_onlineaward"))
    --:addButton(var.widget:getWidgetByName("Button_sign"))
    
    :onButtonSelectChanged(function(event)
        PanelAwardHall.updatePanelByTag(event.selected)
    end)

    UIRadioButtonGroup:setButtonSelected(var.selectTab)
end


function PanelAwardHall.updatePanelByTag(tag)
    if var.subView then var.subView:removeFromParent() var.subView = nil end
    local viewName

    if tag == ROLEINFO_TAG.ONLINE then
        viewName = "app.views.awardhall.OnlineAward"
    elseif tag == ROLEINFO_TAG.SIGNUP then
        viewName = "app.views.awardhall.EveryDaySignup"
    end

    if viewName then
        var.subView = require(viewName).initView({ parent = var.viewBg})
    end

end


function PanelAwardHall.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelAwardHall.handleUpdateinfo)
end

  

return PanelAwardHall