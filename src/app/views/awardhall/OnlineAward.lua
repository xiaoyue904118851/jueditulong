--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/28 14:22
-- To change this template use File | Settings | File Templates.
--

local OnlineAward = {}
local var = {}
local ACTIONSET_NAME = "onlinetimepanel"

function OnlineAward.initView(params)
    local params = params or {}
    var = {}
    var.selectInfo = nil
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAwardHall/UI_OnlineAward.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_onlineaward")
    var.listView = var.widget:getWidgetByName("ListView_awardlist")
    var.listItem = var.widget:getWidgetByName("Image_item1"):hide()
    var.infotype = false
    var.infoCanGet = {}
    var.infoGet = {}
    var.hasnum = 0
    OnlineAward.registeEvent()
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="getCurrentAwards"}))

    var.getBtn = var.widget:getWidgetByName("Button_get")
    var.getBtn:setTouchEnabled(false)
        :setBright(false)
        :addClickEventListener(function (pSender)
             NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="drawCurrentAward",param = ""}))
        end)

    return widget
end

function OnlineAward.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, OnlineAward.handleAwardDataMsg) 
end


function OnlineAward.handleAwardDataMsg(event)
    if event.type == nil then return end
    if event.type ~= ACTIONSET_NAME then return end
    local d = util.decode(event.data)
    if not d.actionid then return end
    if d.actionid == "getCurrentAwards" then
        var.info = nil
        var.info = d
        if not var.infotype then
            OnlineAward.updateListInfo()
        end
        NetClient.onlineAward = {}
        NetClient.onlineAward = var.info.hasawardId
        UIRedPoint.handleChange({UIRedPoint.REDTYPE.AWARDHALL_ONLINE})
        var.infotype = true
    elseif d.actionid == "drawCurrentAward" then
        OnlineAward.updateListState()
    end
end

function OnlineAward.updateListInfo()
    var.listView:removeAllItems()
     UIGridView.new({
        parent = var.widget,
        async = true,
        list = var.listView,
        gridCount = #var.info.datas,
        cellSize = cc.size(var.listView:getContentSize().width,var.listItem:getContentSize().height),
        columns = 3,
        initGridListener = OnlineAward.addGridItem
    })
end

function OnlineAward.addGridItem(gridWidget, index)
    local sellinfo = var.info.datas[index]
    if not sellinfo then return end
   
    local widget = var.listItem:clone():show()
    :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)
    widget:getWidgetByName("AtlasLabel_get_number"):setString(sellinfo.awards[1].num)

    if var.info.overtime < sellinfo.time*60 then
        OnlineAward.startCountDown((sellinfo.time*60-var.info.overtime), widget:getWidgetByName("label_lefttimes"))
    end
    --var.infoLabel[index] = widget:getWidgetByName("label_lefttimes")
    if var.info.overtime >= sellinfo.time*60 then
        if var.info.hasawardId[index] then
            if var.info.hasawardId[index] > 0 then
                --var.infoCanGet[index] = widget:getWidgetByName("Image_select")
                var.infoCanGet[index] = widget:getWidgetByName("Image_item1")
                var.infoGet[index] = widget:getWidgetByName("Image_hasget"):show()
            else
                --var.infoCanGet[index] = widget:getWidgetByName("Image_select"):show()
                var.infoCanGet[index] = widget:getWidgetByName("Image_item1")
                gameEffect.playEffectByType(gameEffect.EFFECT_ONLINEAWARD)
                :setName("showeffect")
                :setPosition(cc.p( var.infoCanGet[index]:getContentSize().width/2, var.infoCanGet[index]:getContentSize().height/2+2)):addTo( var.infoCanGet[index])
                var.infoGet[index] = widget:getWidgetByName("Image_hasget")
                var.hasnum = var.hasnum + 1
            end
        else
            var.infoCanGet[index] = widget:getWidgetByName("Image_item1")
            gameEffect.playEffectByType(gameEffect.EFFECT_ONLINEAWARD)
            :setName("showeffect")
            :setPosition(cc.p( var.infoCanGet[index]:getContentSize().width/2, var.infoCanGet[index]:getContentSize().height/2+2)):addTo( var.infoCanGet[index])
            var.infoGet[index] = widget:getWidgetByName("Image_hasget")
            var.hasnum =var.hasnum +1
        end
    else
        var.infoCanGet[index] = widget:getWidgetByName("Image_item1")
        var.infoGet[index] = widget:getWidgetByName("Image_hasget")
    end
    if var.hasnum > 0 and index == #var.info.datas then
        var.getBtn:setTouchEnabled(true)
        :setBright(true)
    end  
end



function OnlineAward.startCountDown(time, obj)
    if not obj then return end
    obj:stopAllActions()
    if time <= 0 then time = 0 end
    obj.countdown = time

    if time == 0 then return end
    obj:show()
    OnlineAward.updateCountDownText(obj)
    obj:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(OnlineAward.updateCountDownText))))
end

function OnlineAward.updateCountDownText(pSender)
    if pSender then
        pSender.countdown = pSender.countdown - 1
        pSender:setString(game.convertSecondsToH( pSender.countdown))
        if pSender.countdown <= 0 then
            pSender:setString("")
            var.getBtn:setTouchEnabled(true)
            :setBright(true)
            pSender:stopAllActions()
            return
        end
    end
end

function OnlineAward.updateListState()
    var.hasnum = 0 
    for i = 1, #var.info.datas do
        local infos = var.info.datas[i]
        if var.info.overtime >= infos.time*60 then
            if var.info.hasawardId[i] then
                if var.info.hasawardId[i] > 0 then
                    var.infoGet[i]:show()
                    if var.infoCanGet[i]:getChildByName("showeffect") then
                       var.infoCanGet[i]:getChildByName("showeffect"):removeFromParent()
                    end
                    --var.infoCanGet[i]:hide()
                else
                    var.infoGet[i]:hide()
                    if var.infoCanGet[i]:getChildByName("showeffect") then
                        var.infoCanGet[i]:getChildByName("showeffect"):show()
                    else
                        gameEffect.playEffectByType(gameEffect.EFFECT_ONLINEAWARD)
                        :setName("showeffect")
                        :setPosition(cc.p(var.infoCanGet[index]:getContentSize().width/2, var.infoCanGet[index]:getContentSize().height/2+2)):addTo(var.infoCanGet[index])
                    end
                    var.hasnum =var.hasnum +1
                end
            else
                var.infoGet[i]:hide()
                if var.infoCanGet[i]:getChildByName("showeffect") then
                    var.infoCanGet[i]:getChildByName("showeffect"):show()
                else
                    gameEffect.playEffectByType(gameEffect.EFFECT_ONLINEAWARD)
                    :setName("showeffect")
                    :setPosition(cc.p( var.infoCanGet[index]:getContentSize().width/2, var.infoCanGet[index]:getContentSize().height/2+2)):addTo( var.infoCanGet[index])
                end
                var.hasnum =var.hasnum +1
            end
        else
            var.infoGet[i]:hide()
            if var.infoCanGet[i]:getChildByName("showeffect") then
                var.infoCanGet[i]:getChildByName("showeffect"):removeFromParent()
            end
        end
    end
    if var.hasnum > 0 then
        var.getBtn:setTouchEnabled(true)
        :setBright(true)
    end  
end

return OnlineAward