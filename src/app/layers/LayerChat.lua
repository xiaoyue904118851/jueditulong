--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/17 14:33
-- To change this template use File | Settings | File Templates.
-- LayerChat
local LIST_MAX_NUM = 20

local CHANNEL_INFO = {
    [Const.CHANNEL_TAG.ALL]       = { strChannel = Const.chat_prefix_nomal, contentType = {
        Const.chat_prefix_nomal,
        Const.chat_prefix_world,
        Const.chat_prefix_yell,
        Const.chat_prefix_guild,
        Const.chat_prefix_group,
        Const.chat_prefix_private,
        Const.chat_prefix_system
    }},
    [Const.CHANNEL_TAG.WORLD]     = {strChannel = Const.chat_prefix_world, cooltime = 15, contentType = { Const.chat_prefix_horn,Const.chat_prefix_world,}},
    [Const.CHANNEL_TAG.YELL]      = {strChannel = Const.chat_prefix_yell, contentType = {Const.chat_prefix_yell}},
    [Const.CHANNEL_TAG.GUILD]     = {strChannel = Const.chat_prefix_guild, contentType = {Const.chat_prefix_guild}},
    [Const.CHANNEL_TAG.GROUP]     = {strChannel = Const.chat_prefix_group, contentType = { Const.chat_prefix_group}},
    [Const.CHANNEL_TAG.PRIVATE]   = {strChannel = Const.chat_prefix_private, contentType = {Const.chat_prefix_private}},
    [Const.CHANNEL_TAG.SYSTEM]      = {strChannel = Const.chat_prefix_system, contentType = {Const.chat_prefix_system}},
    [Const.CHANNEL_TAG.HORN]      = {strChannel = Const.chat_prefix_horn, contentType = {Const.chat_prefix_horn}},
}

-- 每个频道上次发言时间
local CHANNEL_LAST_SEND_TIME = {
    [Const.CHANNEL_TAG.ALL]       = 0,
    [Const.CHANNEL_TAG.WORLD]     = 0,
    [Const.CHANNEL_TAG.YELL]      = 0,
    [Const.CHANNEL_TAG.GUILD]     = 0,
    [Const.CHANNEL_TAG.GROUP]     = 0,
    [Const.CHANNEL_TAG.PRIVATE]   = 0,
}

local LayerChat = class("LayerChat", function()
    return display.newLayer()
end)

function LayerChat:ctor()
    self:setContentSize(cc.size(display.width, display.height))
    self:addSprite()
    self:setTouchEnabled(false)
    self:enableNodeEvents()
end

function LayerChat:addSprite()
    self.closeEnabled = true
    self.isMoveing = false
    self.pIsVisible = false
    self.chatIndex = 0
    self.selectTab = Const.CHANNEL_TAG.ALL
    self.m_privateTarget = NetClient.m_strPrivateChatTarget

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelChat/UI_Chat_BG.csb")
    widget:addTo(self)
    widget:align(display.LEFT_BOTTOM, -590*Const.minScale, -5*Const.minScale)
    --    widget:hide()
    widget:setScale(Const.minScale)
    self.rootWidget = widget

    self.widget = widget:getChildByName("Panel_chat")
    self:initWidget()
    self:addMenuTabClickEvent()
    self:addBottomBtnEvent()
    self:initInputContent(params)
end

function LayerChat:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_SHOW_CHAT_LAYER, handler(self,self.handleSwitchLayer))
    :addEventListener(Notify.EVENT_CHAT_MSG, handler(self,self.handleUpdateChat))
    :addEventListener(Notify.EVENT_WHISPER,handler(self,self.handleWhisper))
    :addEventListener(Notify.EVENT_GROUP_LIST_CHANGED, handler(self,self.handleGroupChange))
    :addEventListener(Notify.EVENT_GUILD_TITLE, handler(self,self.handleGuildChange))
end

function LayerChat:handleWhisper()
    self.m_privateTarget = NetClient.m_strPrivateChatTarget
    if not self.pIsVisible then
        self:goShowLayer()
    end
    self.leftButtonGroup:setButtonSelected(Const.CHANNEL_TAG.PRIVATE)
end

function LayerChat:handleSwitchLayer()
    if self.isMoveing then return end
    if self.pIsVisible then
        self:goCloseLayer()
    else
        self:goShowLayer()
    end
end

function LayerChat:goShowLayer()
    self.rootWidget:stopAllActions()
    --    self.rootWidget:show()
    self.isMoveing = true
    self.pIsVisible = true
    self.rootWidget:setOpacity(0)
    self.rootWidget:setPositionX(-160*Const.minScale)
    local btncount = self.leftButtonGroup:getButtonsCount()
    for i = 1, btncount do
        local v = self.leftButtonGroup:getButtonAtIndex(i)
        v:hide()
        v:setPositionX(v:getPositionX()-120)
    end
    self.rootWidget:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveTo:create(0.3, cc.p(-19*Const.minScale, -5*Const.minScale)),
            cc.FadeIn:create(0.3)
        ),
        cc.CallFunc:create(function()
            self.isMoveing = false
            for k = 1, btncount do
                local v = self.leftButtonGroup:getButtonAtIndex(k)
                v:show()
                v:runAction(cc.EaseExponentialOut:create(cc.MoveBy:create(0.1*k, cc.p(120, 0))))
            end
        end)
    ))
end

function LayerChat:goCloseLayer()
    if self.isMoveing or not self.closeEnabled or not self.pIsVisible then return end
    self.rootWidget:stopAllActions()
    self.isMoveing = true
    self.pIsVisible = false
    self.rootWidget:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.MoveTo:create(0.2, cc.p(-100*Const.minScale, -5*Const.minScale)),
            cc.FadeOut:create(0.2)
        ),
        cc.CallFunc:create(function()
            self.rootWidget:setPositionX(-560*Const.minScale)
            self.isMoveing = false
        --                self.rootWidget:hide()
        end)
    ))
end

function LayerChat:initWidget()
    self.panelOp = self.widget:getWidgetByName("Panel_op"):hide()
    self.panelChatInfo = self.widget:getWidgetByName("Panel_chatinfo")
    self.listView = self.panelChatInfo:getWidgetByName("ListView_chatcontent")
    self.warningText = self.panelChatInfo:getWidgetByName("Text_waring"):hide()
    self.btnJoinGuild = self.panelChatInfo:getWidgetByName("Button_joinguild"):hide()
    self.btnJoinGuild:getTitleRenderer():setPositionY(20)
    self.btnJoinGroup = self.panelChatInfo:getWidgetByName("Button_joingroup"):hide()
    self.btnJoinGroup:getTitleRenderer():setPositionY(20)
    self.panelSenfinfo = self.panelChatInfo:getWidgetByName("Panel_sendinfo")
    self.panelMenu = self.panelOp:getWidgetByName("Image_menu")
    self.panelSet = self.panelOp:getWidgetByName("Image_set")
    self.panelBag = self.panelOp:getWidgetByName("Image_bag")
    self.panelEmotion = self.panelOp:getWidgetByName("Image_emotion")

    self.panelOp:addClickEventListener(function(pSender) pSender:hide() end)
    self.widget:getWidgetByName("Button_close"):addClickEventListener(function(pSender)
        self:goCloseLayer()
    end)

    self.btnJoinGroup:addClickEventListener(function(pSender)
        self:goCloseLayer()
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group"})
    end)

    self.btnJoinGuild:addClickEventListener(function(pSender)
        self:goCloseLayer()
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_guild"})
    end)

    self.panelChatInfo:getWidgetByName("Button_menu"):addClickEventListener(function(pSender)
        self.panelOp:show()
        self.panelMenu:show()
        self.panelSet:hide()
        self.panelBag:hide()
        self.panelEmotion:hide()
    end)
    self.panelMenu:getWidgetByName("Button_set"):addClickEventListener(function(pSender)
        self.panelMenu:hide()
        self.panelSet:show()
        self.panelBag:hide()
        self.panelEmotion:hide()
    end)
    self.panelMenu:getWidgetByName("Button_bag"):addClickEventListener(function(pSender)
        self.panelMenu:hide()
        self.panelSet:hide()
        self.panelEmotion:hide()
        self.panelBag:show()
        self:initBagData()
        self.bagButtonGroup:clearSelect()
        self.bagButtonGroup:setButtonSelected(self.mSelectBagTag or 1)
    end)
    self.panelMenu:getWidgetByName("Button_dingwei"):addClickEventListener(function(pSender)
        self.panelOp:hide()
        local msg = "["..NetClient.mNetMap.mName.." "..CCGhostManager:getMainAvatar():PAttr(Const.AVATAR_X)..","..CCGhostManager:getMainAvatar():PAttr(Const.AVATAR_Y).."]"
        local clickstr = "local_goto_"..NetClient.mNetMap.mMapID.."_"..CCGhostManager:getMainAvatar():PAttr(Const.AVATAR_X).."_"..CCGhostManager:getMainAvatar():PAttr(Const.AVATAR_Y)
        self:sendMsg("我的坐标是".."<a href=\"event:"..clickstr.."\" islabel=\"1\">"..msg.."</a>")
    end)
    self.panelMenu:getWidgetByName("Button_emotion"):addClickEventListener(function(pSender)
        self.panelMenu:hide()
        self.panelSet:hide()
        self.panelBag:hide()
        self.panelEmotion:show()
        if not self.mInitEmotion then
            self:initEmotionWidget()
        end
    end)

    self:initSetWidget()
    self:initBagWidget()
end

function  LayerChat:initEmotionWidget()
    self.mInitEmotion = true
    UIGridView.new({
        list = self.panelEmotion:getWidgetByName("ListView_emotion"),
        gridCount = 23,
        cellSize = cc.size(478, 55),
        columns = 8,
        initGridListener = function(gridWidget, index)
            local item = ccui.ImageView:create(string.format("face_%02d.png",index), UI_TEX_TYPE_PLIST)
            item:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
            :addTo(gridWidget)
            item:setTouchEnabled(true)
            item.index = index
            item:addClickEventListener(function(pSender)
                if self:getEmotionCount() < 5 then
                    local msg = self.mSendText:getText()
                    self.mSendText:setString(msg.."#"..string.format("f%02d",pSender.index).."#")
                end
            end)
        end
    })
end

function LayerChat:initSetWidget()
    local uipanel = self.panelSet:getWidgetByName("Panel_ui")
    self.cbShowUI = {}
    local cfg = {
        {tag = Const.CHANNEL_TAG.WORLD, name = "cb_world"},
        {tag = Const.CHANNEL_TAG.GROUP, name = "cb_group"},
        {tag = Const.CHANNEL_TAG.GUILD, name = "cb_guild"},
        {tag = Const.CHANNEL_TAG.PRIVATE, name = "cb_private"},
        {tag = Const.CHANNEL_TAG.YELL, name = "cb_yell"}
    }

    for _, v in ipairs(cfg)  do
        self.cbShowUI[v.tag] =  uipanel:getWidgetByName(v.name)
        self.cbShowUI[v.tag]:setSelected(false)
        self.cbShowUI[v.tag]:addEventListener(function(sender,eventType)
            NativeData.CHAT_SHOW_SETTING = {}
            for k, v in pairs(self.cbShowUI)  do
                if v:isSelected() then
                    table.insert(NativeData.CHAT_SHOW_SETTING, k)
                end
            end
        end)
    end

    for _, v in ipairs(NativeData.CHAT_SHOW_SETTING) do
        if self.cbShowUI[v] then
            self.cbShowUI[v]:setSelected(true)
        end
    end
end

function LayerChat:initBagWidget()
    self.bagPV = self.panelBag:getWidgetByName("PageView_bag")
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    self.bagButtonGroup = UIRadioButtonGroup.new()
    :addButton(self.panelBag:getWidgetByName("btn_right_bag"))
    :addButton(self.panelBag:getWidgetByName("btn_right_self"))
    :onButtonSelectChanged(function(event)
        self:updateBagPVByTag(event.selected)
    end)
    for i = 1, self.bagButtonGroup:getButtonsCount() do
        self.bagButtonGroup:getButtonAtIndex(i):getTitleRenderer():setPositionY(17)
    end
    self.bagPV:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
    self.bagPV:setIndicatorPosition(cc.p(self.bagPV:getContentSize().width/2, 5))
    self.bagPV:setIndicatorSpaceBetweenIndexNodes(10)
end

function LayerChat:initInputContent(params)
    if not params then return end
    if not params.extend then
        return
    end

    local typeid = params.extend.typeid or 0
    local itemDef = NetClient:getItemDefByID(typeid)
    if not itemDef then
        return
    end
    local str = itemDef.mName
    self.mSendText:setString(str)
end

function LayerChat:addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local names = {"Button_chatall", "Button_chatworld", "Button_chatguild", "Button_chartgroup", "Button_chatyell", "Button_chatwhisper", "Button_chatsystem"}
    self.leftButtonGroup = UIRadioButtonGroup.new()
    for _, v in ipairs(names) do
        self.leftButtonGroup:addButton(self.panelChatInfo:getWidgetByName(v))
    end

    self.leftButtonGroup:onButtonSelectChanged(function(event)
        self:updateListViewByTag(event.selected)
    end)
    self.leftButtonGroup:setButtonSelected(self.selectTab)
end

function LayerChat:updateListViewByTag(tag)
    if self.chatIndex == tag then return end
    self.chatIndex = tag
    self:updateBottom()
    self.listView:removeAllItems()

    local mChannelHistory = {}
    local num = 0
    for i = #NetClient.mChatHistroy, 1, -1 do
        local netChat = NetClient.mChatHistroy[i]
        if num < LIST_MAX_NUM then
            if self:shouldShowInList(netChat) then
                table.insert(mChannelHistory, netChat)
                num = num + 1
            end
        end
    end

    local listViewW = self.listView:getContentSize().width
    for i = #mChannelHistory, 1, -1 do
        local strMsg = game.get_net_msg_str(mChannelHistory[i])
        if strMsg ~= "" then
            local richLabel, richWidget = util.newRichLabel(cc.size(listViewW, 0), 3)
            richWidget.richLabel = richLabel
            util.setRichLabel(richLabel, strMsg, "", 24, Const.COLOR_YELLOW_3_OX)
            richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
            self.listView:pushBackCustomItem(richWidget)
        end
    end

    self.listView:forceDoLayout()
    self.listView:jumpToBottom()
end

function LayerChat:handleGuildChange()
    if self.chatIndex == Const.CHANNEL_TAG.GUILD then
        self:updateBottom()
    end
end

function LayerChat:updateBottom()
    self.warningText:setVisible(self.chatIndex == Const.CHANNEL_TAG.SYSTEM)
    if self.chatIndex == Const.CHANNEL_TAG.GUILD then
        local mainRole = CCGhostManager:getMainAvatar()
        local haveguild = game.haveGuild()
        self.btnJoinGuild:setVisible(not haveguild)
        self.panelSenfinfo:setVisible(haveguild)
        self.btnJoinGroup:hide()
    elseif self.chatIndex == Const.CHANNEL_TAG.GROUP then
        local havegroup = #NetClient.mGroupMembers > 0
        self.btnJoinGroup:setVisible(not havegroup)
        self.panelSenfinfo:setVisible(havegroup)
        self.btnJoinGuild:hide()
    else
        self.btnJoinGuild:hide()
        self.btnJoinGroup:hide()
        self.panelSenfinfo:setVisible(self.chatIndex ~= Const.CHANNEL_TAG.SYSTEM)
    end
end

function LayerChat:addBottomBtnEvent()
    local inputBg = self.widget:getWidgetByName("ImageView_inputBg")
    local bgSize = inputBg:getContentSize()

    local function onEdit(event,editBox)
        if event == "began" then
            -- 保持面板不被关闭
            self.closeEnabled = false
            self.panelHold = Scheduler.scheduleGlobal(handler(self,self.handlePanelHold), 0.5)
        elseif event == "changed" then
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
        elseif event == "return" then
            self:handlePanelHold()
        end
    end

    self.mSendText = util.newEditBox({
        image = "null.png",
        size = bgSize,
        listener = onEdit,
        x = 0,
        y = 0,
        placeHolder = Const.chat_placeHolder,
        placeHolderSize = 24,
        fontSize = 24,
        anchor = cc.p(0,0),
        inputMode = Const.EditBox_InputMode.SINGLE_LINE,
        color = Const.COLOR_YELLOW_1_C3B,
    })

    self.mSendText:setMaxLength(40)
    inputBg:addChild(self.mSendText)

    -- 发送按钮
    self.widget:getWidgetByName("Button_send"):addClickEventListener(function(pSender)
        self:gosendMsg()
    end)

    -- 喇叭按钮
    --    self.widget:getWidgetByName("Button_speaker"):addClickEventListener(function(pSender)
    --        self:sendHornMsg()
    --    end)
end

function LayerChat:getEmotionCount()
    local msg = self.mSendText:getText()
    if msg == "" then return 0 end
    local total = 0
    for w in string.gmatch(msg, game.chatFacePatternStr) do
        total = total + 1
    end
    return total
end

function LayerChat:getItemCount()
    local msg = self.mSendText:getText()
    if msg == "" then return 0 end
    local total = 0
    for w in string.gmatch(msg, game.chatItemPatternStr) do
        total = total + 1
    end
    return total
end

function LayerChat:getSendMsg(msg)
    local msg = self.mSendText:getText()
    local mNum = 0
    local shoutMsg = msg
    if msg == "" then
        print("发送内容不可为空")
        return ""
    end

    msg = game.tranItemShow(msg)

    return msg
end

function LayerChat:addVipInfo()
    local lv = game.getVipLevel()
    if lv > 0 then
        return "[VIP"..lv.."]"
    end
    return ""
end

function LayerChat:sendHornMsg()
    local orgMsg = self.mSendText:getText()
    if orgMsg == "" or string.len(orgMsg) <= 0 then
        NetClient:alertLocalMsg("填写内容在发送吧！","alert")
        self.mSendText:setString("")
        return
    end

    local msg = self:getSendMsg(orgMsg)
    if string.len(msg) <= 0 then
        NetClient:alertLocalMsg("内容有错误哟！","alert")
        self.mSendText:setString("")
        return
    end

    NetClient:HornChat(msg)
    self.mSendText:setString("")
end

function LayerChat:gosendMsg()
    local orgMsg = self.mSendText:getText()
    if orgMsg == "" or string.len(orgMsg) <= 0 then
        NetClient:alertLocalMsg("填写内容再发送吧！","alert")
        self.mSendText:setString("")
        return
    end

    -- GM判断
    if self.chatIndex == Const.CHANNEL_TAG.YELL and string.sub(orgMsg,1,1) == "@" then -- 喊话
        NetClient:MapChat(orgMsg) -- GM指令
        self.mSendText:setString("")
        return
    end

    local cooltime = checkint(CHANNEL_INFO[self.chatIndex].cooltime)
    if cooltime > 0 then
        local last = CHANNEL_LAST_SEND_TIME[self.chatIndex]
        if os.time() - last < cooltime then
            NetClient:alertLocalMsg("你说的太快了！","alert")
            return
        end
    end

    local msg = self:getSendMsg(orgMsg)
    if string.len(msg) <= 0 then
        NetClient:alertLocalMsg("内容有错误哟！","alert")
        self.mSendText:setString("")
        return
    end


    self:sendMsg(msg)
end

function LayerChat:sendMsg(msg)
    msg = self:addVipInfo().."："..msg
    CHANNEL_LAST_SEND_TIME[self.chatIndex] = os.time()

    if self.chatIndex == Const.CHANNEL_TAG.ALL then -- 综合
        NetClient:MapChat(msg)
    elseif self.chatIndex == Const.CHANNEL_TAG.WORLD then -- 世界
        NetClient:WorldChat(msg)
    elseif self.chatIndex == Const.CHANNEL_TAG.YELL then -- 喊话
        NetClient:MapChat(msg)
    elseif self.chatIndex == Const.CHANNEL_TAG.GUILD then -- 工会
        if game.haveGuild() then
            NetClient:GuildChat(msg)
        else
            NetClient:alertLocalMsg("你还没有行会！","alert")
        end
    elseif self.chatIndex == Const.CHANNEL_TAG.GROUP then  -- 组队
        if #NetClient.mGroupMembers > 0 then
            NetClient:GroupChat(msg)
        else
            print("no group")
            NetClient:alertLocalMsg("你还没有队伍,请先创建队伍！","alert")
        end
    elseif self.chatIndex == Const.CHANNEL_TAG.PRIVATE then  -- 私聊
        local target = self.m_privateTarget
        if target == "" or target == nil then
            print("no target")
            NetClient:alertLocalMsg("你还没有聊天对象！","alert")
        else
            msg,n=string.gsub(msg,"@[^>]*:","")
            NetClient:PrivateChat(self.m_privateTarget,msg)
        end
    end
    self.mSendText:setString("")
end

function LayerChat:handleUpdateChat(event)
    local netChat = NetClient.mChatHistroy[#NetClient.mChatHistroy]
    if self:shouldShowInList(netChat) then
        self:updateListView(netChat)
    end
end

function LayerChat:shouldShowInList(netChat)
    if netChat.m_strType == CHANNEL_INFO[self.chatIndex].strChannel then
        return true
    end

    local validTypes = CHANNEL_INFO[self.chatIndex].contentType
    for i = 1, #validTypes do
        if validTypes[i] == netChat.m_strType then
            return true
        end
    end
    return false
end

function LayerChat:updateListView(netChat)
    local strMsg = game.get_net_msg_str(netChat)
    if strMsg == "" then
        return
    end

    local mItemsNum = #self.listView:getItems()
    if mItemsNum >= LIST_MAX_NUM then
        self.listView:removeItem(0)
    end

    local width = self.listView:getContentSize().width
    local richLabel, richWidget = util.newRichLabel(cc.size(width - 0, 0), 3)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, strMsg, "", 24, Const.COLOR_YELLOW_3_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    self.listView:pushBackCustomItem(richWidget)
    self.listView:forceDoLayout()
    self.listView:jumpToBottom()
end

function LayerChat:initBagData()
    self.bagList = {{},{}}
    for pos, netItem in pairs(NetClient.mItems) do
        if game.IsPosInBag(pos) then
            local itemCfg = {pos = pos, netItem = netItem }
            table.insert(self.bagList[1], itemCfg)
        elseif game.IsPosInAvatar(pos) then
            local itemCfg = {pos = pos, netItem = netItem }
            table.insert(self.bagList[2], itemCfg)
        end
    end
end

function LayerChat:updateBagPVByTag(tag)
    self.mSelectBagTag = tag
    self.bagPV:removeAllPages()
    local srcItemBg = self.panelBag:getWidgetByName("Image_item_bg"):hide()

    function initItem(gridWidget, index)
        local itemBg = srcItemBg:clone():show()
        itemBg:show()
        itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
        itemBg:addTo(gridWidget)
        itemBg.netItem = self.bagList[tag][index].netItem
        itemBg.itemid = itemBg.netItem.mTypeID
        UIItem.getItem({
            parent = itemBg,
            typeId = itemBg.itemid,
            itemCallBack = function(pSender)
                local msg = self.mSendText:getText()
                local itemdef = NetClient:getItemDefByID(pSender.itemid)
                if itemdef and self:getItemCount() < 3 then
                    self.mSendText:setString(msg.."##"..pSender.netItem.position..","..itemdef.mName.."##")
                end
            end
        })
    end

    UIGridPageView.new({
        pv = self.bagPV,
        count = #self.bagList[tag],
        padding = {left = 0, right = 0, top = 0, bottom = 40},
        row = 3,
        column = 4,
        initGridListener = initItem
    })
end

function LayerChat:handleGroupChange(event)
    if self.chatIndex == Const.CHANNEL_TAG.GROUP then
        self:updateBottom()
    end
end

function LayerChat:handlePanelHold()
    if self.panelHold then
        Scheduler.unscheduleGlobal(self.panelHold)
        self.panelHold = nil
        self.closeEnabled = true
    end
end

function LayerChat:checkPanelClose()
    return self.closeEnabled
end

function LayerChat:onEnter()
    self:registeEvent()
end

return LayerChat