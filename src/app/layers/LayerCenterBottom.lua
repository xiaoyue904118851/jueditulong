--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/07 21:35
-- To change this template use File | Settings | File Templates.
--

local LayerCenterBottom = class("LayerCenterBottom", function()
    return ccui.Layout:create()
end)

function LayerCenterBottom:ctor()
    self:enableNodeEvents()
    self:addWidget()
    self:handleUpdateChat()
end

function LayerCenterBottom:onEnter()
    self:registeEvent()
end

function LayerCenterBottom:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_HANDLE_FLOATING, handler(self, self.handleUpdateAutoMove))
    :addEventListener(Notify.EVENT_CHAT_MSG, handler(self, self.handleUpdateChat))
end

function LayerCenterBottom:addWidget()
    local widget = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_CenterBottom.csb")
    widget:addTo(self, 2)
    self.widget = widget:getChildByName("Panel_centerbottom")
    self.widget:align(display.CENTER_BOTTOM, display.cx, 0)
    self.center_panel = self.widget:getWidgetByName("Panel_center"):setScale(Const.minScale)

    self.flyshoe = self.widget:getWidgetByName("Button_fly"):hide()


    local function btnCallBack(pSender)
        local btnName =  pSender:getName()
        if btnName == "ListView_msglist" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_chat"})
        elseif btnName == "Button_bag" then
                EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag"})
        elseif btnName == "Button_fly" then
            if MainRole.haveTargetRoad() then
                if not game.checkBtnClick() then return end
                NetClient:PushLuaTable("player.DirectFly",util.encode(MainRole.mTargetRoad))
            end
        end
    end
    self.widget:getWidgetByName("ListView_msglist"):addClickEventListener(btnCallBack)
    self.flyshoe:addClickEventListener(btnCallBack)
    UIRedPoint.addUIPoint({parent=self.widget:getWidgetByName("Button_bag"), position=cc.p(70,70), types={UIRedPoint.REDTYPE.OPEN_BAG_SLOT},callback = btnCallBack})
    UIRedPoint.handleChange({UIRedPoint.REDTYPE.OPEN_BAG_SLOT})
    self.chatMsgBG = self.widget:getWidgetByName("ImageView_msgbg")

end

function LayerCenterBottom:checkMainShow(netChat)
    if not netChat then return end
    for _, v in ipairs(NativeData.CHAT_SHOW_SETTING)  do
        if v == netChat.m_channelid then
            return true
        end
    end
end

function LayerCenterBottom:handleUpdateChat()
    if #NetClient.mChatHistroy <= 0 then return end
    local netChat = NetClient.mChatHistroy[#NetClient.mChatHistroy]
    if not netChat or not self:checkMainShow(netChat) then return end

    if self.chatListView == nil then
        self.chatListView = self.widget:getWidgetByName("ListView_msglist")
        self.chatListView:setBounceEnabled(true)
        self.chatListView:setTouchEnabled(true)
    end

    self.chatMsgBG:stopAllActions()
    strMsg = game.get_net_msg_str(netChat)

    local mItemsNum = #self.chatListView:getItems()
    if mItemsNum >= 2 then
        self.chatListView:removeItem(0)
    end

    local width = self.chatListView:getContentSize().width
    local richLabel, richWidget = util.newRichLabel(cc.size(width, 0), 3)
    richWidget.richLabel = richLabel
    util.setRichLabel(richLabel, strMsg, "", 26, Const.COLOR_YELLOW_3_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    self.chatListView:pushBackCustomItem(richWidget)
    self.chatListView:forceDoLayout()
    self.chatListView:jumpToBottom()

    self.chatMsgBG:show()

    -- self.chatMsgBG:runAction(cc.Sequence:create(
    --     cc.DelayTime:create(8),
    --     cc.FadeOut:create( 0.6 ),
    --     cc.CallFunc:create(function()
    --         self.chatMsgBG:hide()
    --     end)
    -- ))
end

function LayerCenterBottom:handleUpdateAutoMove( event )
    if event and event.btn then
        if event.btn == "main_auto_move" then
            self:updateAutoMove(event.visible)
        elseif event.btn == "main_auto_fight" then
            self:updateAutoFight(event.visible)
        elseif event.btn == "main_auto_caiji" then
            self:updateAutoCaiji(event.visible)
        end
    end
end

-- 自动寻路
function LayerCenterBottom:updateAutoMove(visible)

    local mainrole=CCGhostManager:getMainAvatar()
    if not mainrole then return end
    if not visible then
        if self.center_panel:getChildByName("automove") then
            self.center_panel:removeChildByName("automove")
        end
        if self.flyshoe then
            self.flyshoe:hide()
        end
        return
    end
    self.isCaikuanging = false
    if self.center_panel:getChildByName("autofight") then
        self.center_panel:removeChildByName("autofight")
    end
    if self.center_panel:getChildByName("autocaiji") then
        self.center_panel:removeChildByName("autocaiji")
    end

    if not self.center_panel:getChildByName("automove") then
        gameEffect.getCacheEffect(gameEffect.EFFECT_XUNLU)
        :setPosition(cc.p(667,215)):setName("automove"):addTo(self.center_panel)
    end


--    local autoMove = cc.Sprite:create()
--    autoMove:setName("automove"):setPosition(cc.p(667,200))
--    if cc.AnimManager:getInstance():getBinAnimateAsync(autoMove,4,"930006",0) then
--        if self.center_panel:getChildByName("automove") then
--            self.center_panel:removeChildByName("automove")
--        end
--        self.center_panel:addChild(autoMove)
--    end

    if MainRole.haveTargetRoad() and MainRole.mDartState == "off" then
        self.flyshoe:show()
        self.flyshoe:setPosition(cc.p(667+160,215))
    end

    -- if NetClient.mCharacter.mMount <= 0 then
    --     NetClient:PushLuaTable("gui.PanelMount.onPanelData",util.encode({actionid = "mounting",flag="autofind"}))
    -- end
end

function LayerCenterBottom:updateAutoCaiji(visible)
    local mainrole=CCGhostManager:getMainAvatar()
    if not mainrole then return end
    if not visible then
        if self.center_panel:getChildByName("autocaiji") then
            self.center_panel:removeChildByName("autocaiji")
        end
        self.isCaikuanging = false
        return
    end
    self.isCaikuanging = true
    if self.center_panel:getChildByName("automove") then
        self.center_panel:removeChildByName("automove")
    end

    if self.center_panel:getChildByName("autofight") then
        self.center_panel:removeChildByName("autofight")
    end

    if self.center_panel:getChildByName("autocaiji") then
        return
    end

    if not self.center_panel:getChildByName("autocaiji") then
        gameEffect.playEffectByType(gameEffect.EFFECT_CAIJIZHONG)
        :setPosition(cc.p(667,215)):setName("autocaiji"):addTo(self.center_panel)
    end
end

-- 自动战斗
function LayerCenterBottom:updateAutoFight(visible)
    local mainrole=CCGhostManager:getMainAvatar()
    if not mainrole then return end
    if not visible then
        if self.center_panel:getChildByName("autofight") then
            self.center_panel:removeChildByName("autofight")
        end
        return
    end

    if self.center_panel:getChildByName("automove") then
        self.center_panel:removeChildByName("automove")
    end
    if self.isCaikuanging then return end
    if not self.center_panel:getChildByName("autofight") then
        gameEffect.getCacheEffect(gameEffect.EFFECT_AUTOFIGHT)
        :setPosition(cc.p(667,215)):setName("autofight"):addTo(self.center_panel)
    end

--    local autoFight = cc.Sprite:create()
--    autoFight:setName("autofight"):setPosition(cc.p(667,200))
--    if cc.AnimManager:getInstance():getBinAnimateAsync(autoFight,4,"930005",0) then
--        if self.center_panel:getChildByName("autofight") then
--            self.center_panel:removeChildByName("autofight")
--        end
--        self.center_panel:addChild(autoFight)
--    end

    if self.flyshoe then
        self.flyshoe:hide()
    end
end

return LayerCenterBottom