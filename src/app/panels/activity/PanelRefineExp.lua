--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/15 11:23
-- To change this template use File | Settings | File Templates.
--

local PanelRefineExp = {}

local ACTIONSET_NAME = "refineexp"
local MAX_NUM = 3

local var = {}

function PanelRefineExp.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0
    var.params = nil

    local widget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelRefineExp.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_refineexp")

    var.maxtips = var.widget:getWidgetByName("Label_max_tips"):hide()
     
    PanelRefineExp.addMenuTabClickEvent()
    --PanelRefineExp.addBtnClicedEvent()
    PanelRefineExp.registeEvent()
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="can_level"}))
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="sur_time"}))
    return var.widget
end

function PanelRefineExp.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelRefineExp.handleUpdateinfo)
end

function PanelRefineExp.addMenuTabClickEvent()
    local function btnCallBack(pSender)
        local btnName =  pSender:getName()
        if btnName == "Button_refine" then
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="start"}))
        end
    end
    var.widget:getWidgetByName("Button_refine"):addClickEventListener(btnCallBack) 
end

function PanelRefineExp.handleUpdateinfo(event)
    if event.type == nil or event.type ~= "refineexp" then return end
    local d = util.decode(event.data)
    if not d then return end
    local curnum = 0
    --print("TZ::::::::curnum::",d.actionid)
    if not var.params then
        var.params = NetClient.Refineparam.data
    end
    if d.actionid == "sur_time" then
        PanelRefineExp.CountTimeDownn(d.param.time)
        var.widget:getWidgetByName("label_leftnum"):setString("/"..#var.params)
    elseif d.actionid == "can_level"then
        var.widget:getWidgetByName("Label_role_level"):setString(d.param.level)
        curnum = d.param.num
        NetClient.Refineparam.renum = curnum
        local refinetype = #var.params-curnum+1
        --print("TZ:::refinetype::",refinetype)
        if var.params[refinetype] then
            var.widget:getWidgetByName("Label_exp_num"):setString(var.params[refinetype].exp_num)
            var.widget:getWidgetByName("label_gold"):setString(var.params[refinetype].vcoin_num)
            if curnum > 0 then
                var.widget:getWidgetByName("label_havenum"):setColor(cc.c3b(18, 207, 40))
                var.widget:getWidgetByName("label_havenum"):setString(curnum)
            end
        else
            var.widget:getWidgetByName("label_havenum"):setColor(cc.c3b(255, 255, 255))
            var.widget:getWidgetByName("label_havenum"):setString(curnum)
            var.widget:getWidgetByName("Text_money"):hide()
            var.widget:getWidgetByName("Image_levelandexp"):hide()
            var.maxtips:show()
        end
    end
    
    
end

function PanelRefineExp.CountTimeDownn(times)
    local time = times
    local function runLoading( dt )
        time = time-1
        if time > 0 and var.widget then
            var.widget:getWidgetByName("label_lefttimes"):setString(game.convertSecondsToH(time))
        else
            if var.freshHandle or not var.freshHandle then
                Scheduler.unscheduleGlobal(var.freshHandle)
                var.freshHandle = nil
            end
        end
    end
    if time > 0 and var.widget then
        var.widget:getWidgetByName("label_lefttimes"):setString(game.convertSecondsToH(time))
    end
    var.freshHandle = Scheduler.scheduleGlobal(runLoading, 1)   
end


function PanelRefineExp.onPanelClose()
    if var.freshHandle then
        Scheduler.unscheduleGlobal(var.freshHandle)
        var.freshHandle = nil
    end
end
function PanelRefineExp.handleUpdateListView(event)
    if event and event.action == "fresh" then    
    end
end

return PanelRefineExp