--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelAwardHall

local PanelXunBao = {}
local var = {}
local ACTIONSET_NAME = "lottery"
local MAXLISTNUM = 10
 

function PanelXunBao.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0
    var.params = nil

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelXunBao/UI_XunBao_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_xunbao")
    

    var.miListView = var.widget:getWidgetByName("ListView_rightmi")
    var.renListView = var.widget:getWidgetByName("ListView_rightren")
     
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="querybaseinfo",param = ""}))

    --PanelStrengthen.addMenuTabClickEvent()
    var.selectTab = 1
    var.showType = false
    --PanelSuperValue:sortData()
    var.widget:getWidgetByName("Button_gocharge")
    :addClickEventListener(function (pSender)
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_mall",  pdata = {tag = 3}})
        end)
    var.widget:getWidgetByName("Button_bag")
    :addClickEventListener(function (pSender)
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_xunbao_cangku"})
        end)

    var.widget:getWidgetByName("Button_dui")
    :addClickEventListener(function (pSender)
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_xunbao_shop"})
        end)
    var.btntable = {}
    for i= 1,3 do
        var.btntable[i] = var.widget:getWidgetByName("Button_xun"..i)
        var.widget:getWidgetByName("Button_xun"..i)
        :setName("btnxb"..i)
        :setTag(i)
        :addClickEventListener(function (pSender)
            local xnum = var.infodata.btninfo[pSender:getTag()].times
            if var.freetime < xnum then
                local param = {
                        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "您的寻宝卷不足，是否花费"..(xnum-var.freetime)*var.infodata.btninfo[1].vcoin.."元宝寻宝",
                        confirmTitle = "确 定", cancelTitle = "取 消",
                        confirmCallBack = function ()
                            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid=pSender:getName(),param = ""}))
                            gameEffect.playEffectByType(gameEffect.EFFECT_XUNBAO, {removeSelf=true})                            
                            :setPosition(cc.p(display.cx-300,display.cy-35)):addTo(var.widget)
                            for j= 1,3 do
                                var.btntable[i]:setTouchEnabled(false)
                            end
                            var.btntable[pSender:getTag()]:runAction(cc.Sequence:create(
                            cc.DelayTime:create(2),
                            cc.CallFunc:create(PanelXunBao.dealxunbaobtnInfo)
                            ))
                        end
                    }
                    EventDispatcher:dispatchEvent(param)
            else
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid=pSender:getName(),param = ""}))
                gameEffect.playEffectByType(gameEffect.EFFECT_XUNBAO, {removeSelf=true})                
                :setPosition(cc.p(display.cx-300,display.cy-35)):addTo(var.widget)
            end
        end)
    end
    PanelXunBao.registeEvent()
    PanelXunBao.handleAddQuanfuMsg()
    var.renlogNum = 0
    var.quanlogNum = 0
    --NetClient.renMsg = {}
    --PanelXunBao.handleAddXunBaoMsg()
    return var.widget
end

function PanelXunBao.dealxunbaobtnInfo()
    for i = 1,#var.btntable do
        var.btntable[i]:setTouchEnabled(true)
    end
end

function PanelXunBao.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelXunBao.handleDataMsg)
    :addEventListener(Notify.EVENT_XUNBAO_NOTICE, PanelXunBao.handleXunBaoMsg)  
end

function PanelXunBao.handleXunBaoMsg(event)
    if not event.msg then return end
    
    if not NetClient.renMsg then
        NetClient.renMsg ={}
        NetClient.renMsg[#NetClient.renMsg+1] = event.msg
        PanelXunBao.handleAddXunBaoMsg()
    else
        NetClient.renMsg[#NetClient.renMsg+1] = event.msg
        PanelXunBao.insertRenListMsg(#NetClient.renMsg)
    end
end
function PanelXunBao.handleAddXunBaoMsg()
    if not NetClient.renMsg then return end
    var.renlogNum = 0 
    var.renListView:removeAllItems()
    PanelXunBao.addcountMimsg()
end

function PanelXunBao.handleAddQuanfuMsg()
    if not NetClient.quanfuinfo then return end
    var.quanlogNum = 0
    var.miListView:removeAllItems()
    PanelXunBao.addcountQunmsg()
    --[[
    for i=1,#NetClient.quanfuinfo do
        PanelXunBao.insertQuanfuListMsg(i)
    end
    ]]
end

function PanelXunBao.insertQuanfuListMsg(idx)
    local listViewW = var.miListView:getContentSize().width
    local strMsg = NetClient.quanfuinfo[idx]
    if strMsg ~= "" and strMsg ~= "," then
        
        local richLabel, richWidget = util.newRichLabel(cc.size(listViewW - 20, 0), 3)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel, strMsg, "", 24, Const.COLOR_YELLOW_3_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        var.miListView:insertCustomItem(richWidget,0)
    end
    var.quanlogNum = var.quanlogNum + 1
    if var.quanlogNum > MAXLISTNUM then
        var.miListView:removeItem(var.quanlogNum-1)
        var.quanlogNum = var.quanlogNum - 1
    end
    var.miListView:forceDoLayout()
    var.miListView:jumpToBottom()
end

function PanelXunBao.insertRenListMsg(idx)
    local listViewW = var.renListView:getContentSize().width
    local strMsg = NetClient.renMsg[idx]
    if strMsg ~= "" then
        local richLabel, richWidget = util.newRichLabel(cc.size(listViewW - 20, 0), 3)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel, strMsg, "", 24, Const.COLOR_YELLOW_3_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        var.renListView:insertCustomItem(richWidget,0)
    end
    var.renlogNum = var.renlogNum + 1
    if var.renlogNum > MAXLISTNUM then
        var.renListView:removeItem(var.renlogNum-1)
        var.renlogNum = var.renlogNum - 1
    end
    var.renListView:forceDoLayout()
    var.renListView:jumpToBottom()
end

function PanelXunBao.addcountMimsg()
    local time = 1
    local function runLoading( dt )
        if time > #NetClient.renMsg then
            if var.freshmi  then
                Scheduler.unscheduleGlobal(var.freshmi)
                var.freshmi = nil
            end
        else
            PanelXunBao.insertRenListMsg(time)
            time = time+1
        end
    end
    var.freshmi = Scheduler.scheduleGlobal(runLoading, 0.1)   
end

function PanelXunBao.addcountQunmsg()
    local time = 1
    local function runLoading( dt )
        if time > #NetClient.quanfuinfo then
            if var.freshqun then
                Scheduler.unscheduleGlobal(var.freshqun)
                var.freshqun = nil
            end
        else
            PanelXunBao.insertQuanfuListMsg(time)
            time = time+1
        end
    end
    var.freshqun = Scheduler.scheduleGlobal(runLoading, 0.15)   
end

function PanelXunBao.handleDataMsg(event)
    if event.type == nil then return end
    if event.type ~= ACTIONSET_NAME then return end
    local d = util.decode(event.data)
    if not d.actionid then return end
    if d.actionid == "querybaseinfo" then
        var.infodata = d.param
        var.freetime = d.param.freetimes 
        var.jifen = d.param.xbjifen
        PanelXunBao.updatexunbaoinfo()    
    elseif d.actionid == "qunfuxinxi" then
        local data = d.param
        if data then 
            NetClient.quanfuinfo ={}
            for k,v in pairs(data) do       
                if v and v ~= ","then
                    NetClient.quanfuinfo[#NetClient.quanfuinfo+1] = v
                end
            end
            if var.quanlogNum > 0 then
                PanelXunBao.addcountQunmsg()
            else
                PanelXunBao.handleAddQuanfuMsg()
            end
        end 
    elseif d.actionid == "queryupdateinfo" then
        var.freetime = d.param.freetimes
        var.jifen = d.param.xbjifen
        var.widget:getWidgetByName("Label_jifennum"):setString(var.jifen)
        var.widget:getWidgetByName("Label_juannum"):setString(var.freetime)
    elseif d.actionid == "xunbaoawardinfo" then
        if not NetClient.renMsg then
            NetClient.renMsg ={}
            for i =1,#d.param do
                NetClient.renMsg[#NetClient.renMsg+1] = "寻宝获得了"..game.make_str_with_color( Const.COLOR_GREEN_1_STR,d.param[i])
            end
            PanelXunBao.handleAddXunBaoMsg()
        else
            NetClient.renMsg ={}
            for i =1,#d.param do
                NetClient.renMsg[#NetClient.renMsg+1] = "寻宝获得了"..game.make_str_with_color( Const.COLOR_GREEN_1_STR,d.param[i])
            end 
            PanelXunBao.addcountMimsg()
        end
    end
end

function PanelXunBao.updatexunbaoinfo()
    if not var.infodata then return end
    for i= 1,#var.infodata.itemlist do
        UIItem.getSimpleItem({
            parent = var.widget:getWidgetByName("Image_item"..i),
            typeId = var.infodata.itemlist[i],
        })
    end
    var.widget:getWidgetByName("Label_jifennum"):setString(var.jifen)
    var.widget:getWidgetByName("Label_juannum"):setString(var.freetime)
    for j = 1,#var.infodata.btninfo do 
        var.widget:getWidgetByName("Label_vocin"..j):setString(var.infodata.btninfo[j].vcoin)
    end
end
function PanelXunBao.onPanelClose()
    if var.freshqun then
        Scheduler.unscheduleGlobal(var.freshqun)
        var.freshqun = nil
    end
    if var.freshmi then
        Scheduler.unscheduleGlobal(var.freshmi)
        var.freshmi = nil
    end
end


return PanelXunBao