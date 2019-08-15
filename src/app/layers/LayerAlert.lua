--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/10 15:53
-- To change this template use File | Settings | File Templates.
--

local LayerAlert = class("LayerAlert", function()
    return ccui.Layout:create()
end)

function LayerAlert:ctor()
    self:enableNodeEvents()
    self.mColorBgCnt = 0

    self.lastFight = NetClient.mCharacter.mFightPoint
    --self.colorBg = self:createMaskBg()
    --self.colorBg:setName("colorBg")
    --self.colorBg:addTo(self)
    --self.colorBg:hide()

    self.mBetterItemBg = self:createMaskBg()
    self.mBetterItemBg:setName("betterItemBg")
    self.mBetterItemBg:setOpacity(0)
    self.mBetterItemBg:addTo(self)
    self.mBetterItemBg:hide()

    self.mPropItemBg = self:createMaskBg()
    self.mPropItemBg:setName("propItemBg")
    self.mPropItemBg:setOpacity(0)
    self.mPropItemBg:addTo(self)
    self.mPropItemBg:hide()

    self.mBetterItemList = {}
    self.mPropItemList = {} -- 可同时使用的道具
end

function LayerAlert:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_PANEL_ON_ALERT, handler(self, self.handlePanelOnAlert))
    :addEventListener(Notify.EVENT_SERVER_MSG, handler(self, self.handleMsgBottom)) -- TODO
    :addEventListener(Notify.EVENT_BETTER_ITEM, handler(self, self.handleBetterItem))
    :addEventListener(Notify.EVENT_PROP_USE_ITEM, handler(self,self.handlePropUse))
    :addEventListener(Notify.EVENT_MAP_LEAVE, handler(self, self.handleCloseFubenPanel))
    :addEventListener(Notify.EVENT_SUPERBOX_RANK, handler(self, self.handlesBoxRankPanel))
    :addEventListener(Notify.EVENT_YUANBAO_BUZU, handler(self, self.handleYbbzPanel))
end

function LayerAlert:handlePanelOnAlert(event)
    if not event then return end

    local panelName = event.panel
    if  panelName == "confirm" then
        self:handlePanelConfirm(event)
    elseif panelName == "alert" then
        self:handlePanelAlert(event)
    elseif panelName == "input" then
        self:handlePanelInput(event)
    elseif panelName == "welcome" then
        self:handleWelcome(event)
    elseif panelName == "equipExchange" then
        self:handleEquipExchange(event)
    elseif panelName == "fubendone" then
        self:handleFubenDone(event)
    elseif panelName == "fubenfailed" then
        self:handleFubenFailed(event)
    elseif panelName == "buy" then
        self:handlePanelBuy(event)
    end
end

function LayerAlert:handleYbbzPanel(event)
    if not event then return end
    local data = event.data
    if not data or not data.id then return end
    if self.showYbbz then return end
    local pMask = self:getChildByName("ybbz")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("ybbz")
    pMask:setVisible(true)
    self.showYbbz = true
    local touchNode = ccui.Widget:create():setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(pMask)
    touchNode:setTouchEnabled(true)

    local function closepanel()
        self.showYbbz = false
        --self:hideColorBg()
        pMask:hide()
        touchNode:removeFromParent()
        touchNode = nil
        pMask  = nil
    end

    touchNode:addClickEventListener(function (pSender)
        closepanel()
    end)


    local rootidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelYbbz.csb"):addTo(touchNode)
    rootidget:setScale(Const.maxScale)
    display.align(rootidget, display.CENTER, display.cx, display.cy)

    local panelWidget = rootidget:getChildByName("Panel_ybbz")
    panelWidget:setTouchEnabled(true)

    local function onBtnClicked(pSender)
        local btnName = pSender:getName()
        if btnName == "Button_charge" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_charge"})
        elseif btnName == "Button_act" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_firstcharge"})
        end
        closepanel()
    end

    panelWidget:getWidgetByName("Button_close"):addClickEventListener(onBtnClicked)

    panelWidget:getWidgetByName("Button_charge"):addClickEventListener(onBtnClicked)
    if data.id ~= 1 then
        panelWidget:getWidgetByName("Button_act"):hide()
        panelWidget:getWidgetByName("Button_charge"):setPositionX(panelWidget:getContentSize().width/2)
    else
        panelWidget:getWidgetByName("Button_act"):addClickEventListener(onBtnClicked)
    end

    if data.txt then
        local parent = panelWidget:getWidgetByName("Text_desc")
        local richLabel, richWidget = util.newRichLabel(cc.size(parent:getContentSize().width, 0), 0)
        richWidget.richLabel = richLabel
        richWidget:setTouchEnabled(false)
        util.setRichLabel(richLabel, data.txt, "", 24, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        richWidget:setPositionY(parent:getContentSize().height-richLabel:getRealHeight())
        parent:addChild(richWidget)
    end
end

function LayerAlert:handleCloseFubenPanel(event)
    
    local pMask = self:getChildByName("fuben")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    --[[
    self:hideColorBg()
    if self.fubenWidget then
        self.fubenWidget:removeFromParent()
        self.fubenWidget = nil
    end
    ]]
end
-----------------确认面板-------------
-- local param = {
-- 	name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "看到你是XX，说明成功了",
-- 	confirmTitle = "是", cancelTitle = "否",
-- 	confirmCallBack = function ()
-- 		print("你这个傻逼")
-- end
-- 	cancelCallBack = function ()
-- 		print("")
-- 	end
-- }
-- NetClient:dispatchEvent(param)
-- 提示消息，确定，取消按钮
function LayerAlert:handlePanelConfirm(event)
    local onClickConfirm = event.confirmCallBack
    local onClickCanCel = event.cancelCallBack
    local pMask = self:getChildByName("canfirm")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("canfirm")
    local confirmWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelConfirm.csb"):addTo(pMask)
    confirmWidget:setScale(Const.maxScale)
    display.align(confirmWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = confirmWidget:getChildByName("Panel_confirm")
    panelWidget:setTouchEnabled(true)

    local function pushConfirmButtons( pSender )
        --self:hideColorBg()
        pMask:hide()
        local btnName = pSender:getName()
        if btnName == "Button_confirm" then
            if onClickConfirm then onClickConfirm() end
        elseif btnName == "Button_cancel" then
            if onClickCanCel then onClickCanCel() end
            if event.showpanel == "shuaxing" then
                NetClient.showtipType = false
            elseif event.showpanel == "shixing" then
                NetClient.showshitipType = false
            end
        end
        confirmWidget:removeFromParent()
        pMask = nil
    end

    local btnConfirm = panelWidget:getWidgetByName("Button_confirm")
    btnConfirm:setTitleText(event.confirmTitle or Const.str_titletext_confirm)
    btnConfirm:addClickEventListener(pushConfirmButtons)

    local btnCancel = panelWidget:getWidgetByName("Button_cancel")
    btnCancel:setTitleText(event.cancelTitle or Const.str_titletext_cancel)
    btnCancel:addClickEventListener(pushConfirmButtons)

    local visible = event.visible
    --self:setColorBgVisible(visible)
    pMask:setVisible(visible)
    confirmWidget:setVisible(visible)

    if event.countTime then
        confirmWidget:runAction(cc.Sequence:create(cc.DelayTime:create(event.countTime), cc.CallFunc:create(function()
            if confirmWidget then
                confirmWidget:removeFromParent()
                pMask = nil
            end
        end)))
    end

    if event.showtype then
        panelWidget:getWidgetByName("panel_show"):setVisible(event.showtype)
        panelWidget:getWidgetByName("CheckBox_confrim"):addEventListener(function(sender,eventType)
            if eventType == ccui.CheckBoxEventType.selected then
                if event.showpanel == "shuaxing" then
                    NetClient.showtipType = true
                elseif event.showpanel == "shixing" then
                     NetClient.showshitipType = true
                end
            elseif eventType == ccui.CheckBoxEventType.unselected then
                if event.showpanel == "shuaxing" then
                    NetClient.showtipType = false
                elseif event.showpanel == "shixing" then
                     NetClient.showshitipType = false
                end
            end
        end)
        if event.showpanel == "shuaxing" then
            panelWidget:getWidgetByName("CheckBox_confrim"):setSelected(NetClient.showtipType)
        elseif event.showpanel == "shixing" then
            panelWidget:getWidgetByName("CheckBox_confrim"):setSelected(NetClient.showshitipType)
        end
        
    end

    if visible then
        if type(event.lblConfirm) ~= "table" then
            local textParent = panelWidget:getWidgetByName("Text_msg_1")
            local bgsize = textParent:getContentSize()
            local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
            richWidget.richLabel = richLabel
            richWidget:setTouchEnabled(false)
            util.setRichLabel(richLabel, event.lblConfirm, "", 28, Const.COLOR_YELLOW_1_OX)
            richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(bgsize.width/2-richLabel:getRealWidth()/2, bgsize.height-richLabel:getRealHeight()))
            textParent:addChild(richWidget)
            textParent:show()
        else
            for k, ctext in ipairs(event.lblConfirm) do
                local textParent = panelWidget:getWidgetByName("Text_msg_"..k)
                if textParent then
                    local bgsize = textParent:getContentSize()
                    local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
                    richWidget.richLabel = richLabel
                    richWidget:setTouchEnabled(false)
                    util.setRichLabel(richLabel, ctext, "", 28, Const.COLOR_YELLOW_1_OX)
                    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
                    richWidget:setPosition(cc.p(bgsize.width/2-richLabel:getRealWidth()/2, bgsize.height-richLabel:getRealHeight()))
                    textParent:addChild(richWidget)
                    textParent:show()
                end
            end
        end
    end

    if event.autoclose then
        local cd = 5
        panelWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            cd = cd - 1
            if cd <= 0 then
                confirmWidget:removeFromParent()
                --self:hideColorBg()
                pMask:hide()
                pMask = nil
            end
        end))))
    end
end

-----------------提示面板-------------
-- local param = {
-- 	name = Notify.EVENT_PANEL_ON_ALERT, panel = "alert", visible = true, lblAlert "你就是一个臭煞笔，不服来战！",
-- 	alertTitle = "朕知道了",
-- 	alertCallBack = function ()
-- 		print("你这个丑傻逼")
-- 	end
-- }
-- NetClient:dispatchEvent(param)
function LayerAlert:handlePanelAlert(event)
    local onClickAlert = event.alertCallBack
    local pMask = self:getChildByName("palert")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("palert")
    local alertWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelAlert.csb"):addTo(pMask)
    alertWidget:setScale(Const.maxScale)
    display.align(alertWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = alertWidget:getChildByName("Panel_alert")
    panelWidget:setTouchEnabled(true)

    local function pushAlertButton(pSender)
        --self:hideColorBg()
        pMask:hide()
        local btnName = pSender:getName()
        if btnName == "Button_alert" then
            if onClickAlert then onClickAlert() end
        end
        alertWidget:removeFromParent()
        pMask = nil
    end

    local btnAlert = panelWidget:getWidgetByName("Button_alert")
    btnAlert:setTitleText(event.alertTitle or Const.str_titletext_alert)
    btnAlert:addClickEventListener(pushAlertButton)

    local visible = event.visible
    --self:setColorBgVisible(visible)
    pMask:setVisible(visible)
    alertWidget:setVisible(visible)

    if visible then
        if type(event.lblAlert) ~= "table" then
            local textParent = panelWidget:getWidgetByName("Text_msg_1")
            local bgsize = textParent:getContentSize()
            local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
            richWidget.richLabel = richLabel
            richWidget:setTouchEnabled(false)
            util.setRichLabel(richLabel, event.lblAlert, "", 28, Const.COLOR_YELLOW_1_OX)
            richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
            richWidget:align(display.CENTER_TOP, bgsize.width/2, bgsize.height)
--            richWidget:setPosition(cc.p(bgsize.width/2-richLabel:getRealWidth()/2, bgsize.height))
            textParent:addChild(richWidget)
            textParent:show()
        else
            for k, ctext in ipairs(event.lblAlert) do
                local textParent = panelWidget:getWidgetByName("Text_msg_"..k)
                if textParent then
                    local bgsize = textParent:getContentSize()
                    local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width - 30, 0), 0)
                    richWidget.richLabel = richLabel
                    richWidget:setTouchEnabled(false)
                    util.setRichLabel(richLabel, ctext, "", 28, Const.COLOR_YELLOW_1_OX)
                    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
                    richWidget:setPosition(cc.p(bgsize.width/2-richLabel:getRealWidth()/2, 0))
                    textParent:addChild(richWidget)
                    textParent:show()
                end
            end
        end
    end
end

-----------------输入框面板-------------
-- local param = {
-- 	name = Notify.EVENT_PANEL_ON_ALERT, panel = "input", visible = true, lblConfirm = "请输入购买坐骑丹数量！", num = 1
-- confirmTitle = "确定"
-- 	confirmCallBack = function ()
-- 		print("你不是傻逼？？？")
-- 	end
-- }
-- NetClient:dispatchEvent(param)
function LayerAlert:handlePanelInput(event)
    local onClickCommit = event.confirmCallBack
    local maxNum = event.maxNum or 1000
    local pMask = self:getChildByName("pinput")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("pinput")
    local inputWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelInput.csb"):addTo(pMask)
    inputWidget:setScale(Const.maxScale)
    display.align(inputWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = inputWidget:getChildByName("Panel_input")
    panelWidget:setTouchEnabled(true)

    local input_bg = panelWidget:getWidgetByName("Image_inputbg")
    local buyNumLabel = ccui.Text:create(str, Const.DEFAULT_FONT_NAME, 24)
    :align(display.CENTER, input_bg:getContentSize().width/2, input_bg:getContentSize().height/2)
    :setString(checkint(event.num))
    :addTo(input_bg)

    local variable = 0
    local count = 0

    local function changeNumber(increment,pSender)
        local num = checkint(buyNumLabel:getString())
        if increment then
            if num and num > 0 and num <= maxNum then
                num= num + increment
                if num <= 0 then
                    num = 1
                    pSender:stopAllActions()
                end
                if num > maxNum then
                    num = maxNum
                    pSender:stopAllActions()
                end
                buyNumLabel:setString(num)
            end
        end
    end

    local function update(pSender)
        count = count + 1
        if count >10 and count < 999 then
            changeNumber(variable,pSender)
        elseif count > 999 then
            pSender:stopAllActions()
        end
    end

    local function pushCommitButtons( pSender, touchType )
        local num = checkint(buyNumLabel:getString())
        local btnName = pSender:getName()
        if touchType == ccui.TouchEventType.began then
            if btnName == "Button_sub" or btnName == "Button_add" then
                if btnName =="Button_sub" then variable = -1 end
                if btnName =="Button_add" then variable = 1 end
                count = 0
                pSender:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1/60), cc.CallFunc:create(function()
                    update(pSender)
                end))))
        end
        elseif touchType == ccui.TouchEventType.canceled then
            pSender:stopAllActions()
        elseif touchType == ccui.TouchEventType.ended then
            pSender:stopAllActions()
            if btnName == "Button_commit" then
                if onClickCommit then
                    onClickCommit(num)
                    --self:hideColorBg()
                    pMask:hide()
                    inputWidget:removeFromParent()
                    pMask = nil
                end
            elseif btnName =="Button_sub" then
                changeNumber(-1,pSender)
            elseif btnName == "Button_add" then
                changeNumber(1,pSender)
            elseif btnName == "Button_cancel" then
                --self:hideColorBg()
                pMask:hide()
                inputWidget:removeFromParent()
                pMask = nil
            end
        end
    end

    local btns = {
        {name = "Button_sub",},
        {name = "Button_add",},
        {name = "Button_commit", text = Const.str_sure,},
        {name = "Button_cancel", text = Const.str_cancel,},
    }
    for k,v in pairs(btns) do
        panelWidget:getWidgetByName(v.name):addTouchEventListener(pushCommitButtons)
        if v.text then
            panelWidget:getWidgetByName(v.name):setTitleText(v.text)
        end
    end

    local visible = event.visible
    --self:setColorBgVisible(visible)
    pMask:setVisible(visible)
    inputWidget:setVisible(visible)

    if visible then
        panelWidget:getWidgetByName("Text_msg"):setString(event.lblConfirm)
    end
end

------------------购买面板---------------
-- local param = {
--     name = Notify.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
--     itemid = 1,itemprice = 1,itempriceflag = 1,itembindflag = 1,
--     confirmTitle = "购 买", cancelTitle = "取 消",
--     confirmCallBack = function (num)
        
--     end
-- }
-- NetClient:dispatchEvent(param)
function LayerAlert:handlePanelBuy(event)
    local money_bg = {
        [0] = "img_vcoin.png",--元宝
        [1] = "img_vbind.png",--绑定元宝
        [3] = "img_money.png",--金币
        [4] = "img_money_bind.png",--绑定金币
        [11] = "img_liquan.png",--礼券
    }
    local pMask = self:getChildByName("qkbuy")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("qkbuy")
    local touchNode = ccui.Widget:create():setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(pMask)
    touchNode:setTouchEnabled(true)
    local function closePanel()
        pMask:hide()
        touchNode:removeFromParent()
        touchNode = nil
        pMask = nil
    end
    touchNode:addClickEventListener(closePanel)


    local onClickCommit = event.confirmCallBack
    local buyWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelQuickBuy.csb"):addTo(touchNode)
    buyWidget:setScale(Const.maxScale)
    display.align(buyWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = buyWidget:getChildByName("Panel_buy")
    panelWidget:setTouchEnabled(true)
    if event.countTime then
        buyWidget:runAction(cc.Sequence:create(cc.DelayTime:create(event.countTime), cc.CallFunc:create(function()
            if touchNode then
                closePanel()
            end
        end)))
    end

    local function onEdit(mevent,editBox)
        if mevent == "return" then
            panelWidget:getWidgetByName("label_item_cost"):setString(event.itemprice*tonumber(editBox:getText()))
        end
    end

    local input_bg = panelWidget:getWidgetByName("Image_inputbg")
    local mBuyText = util.newEditBox({
        image = "null.png",
        size = input_bg:getContentSize(),
        listener = onEdit,
        x = 0,
        y = 0,
        placeHolder = "1",
        placeHolderSize = 24,
        placeHolderColor = cc.c3b(18,207,40),
        fontSize = 24,
        anchor = cc.p(0,0),
        inputMode = Const.EditBox_InputMode.NUMERIC,
        color = cc.c3b(18,207,40),
    })

    mBuyText:setMaxLength(10)
    mBuyText:setText(event.itemnum)
    input_bg:addChild(mBuyText)

    local itemdef = NetClient:getItemDefByID(event.itemid)
    if itemdef then
        panelWidget:getWidgetByName("label_item_name"):setString(itemdef.mName)
    end
    UIItem.getSimpleItem({
        parent = panelWidget:getWidgetByName("item_bg"),
        typeId = event.itemid,
        bind = event.itembindflag,
        itemCallBack = function () end
    })
    panelWidget:getWidgetByName("label_item_price"):setString(event.itemprice)
    panelWidget:getWidgetByName("vcoin_bg"):loadTexture(money_bg[event.itembuyflag],UI_TEX_TYPE_PLIST)
    panelWidget:getWidgetByName("cost_bg"):loadTexture(money_bg[event.itembuyflag],UI_TEX_TYPE_PLIST)
    panelWidget:getWidgetByName("label_item_cost"):setString(event.itemprice*tonumber(mBuyText:getText()))

    local variable = 0
    local count = 0

    local function changeNumber(increment,pSender)
        local num = checkint(mBuyText:getText())
        if increment then
            if num and num > 0 and num <= 1000 then
                num= num + increment
                if num <= 0 then
                    num = 1
                    pSender:stopAllActions()
                end
                if num > 1000 then
                    num = 1000
                    pSender:stopAllActions()
                end
                mBuyText:setText(num)
                panelWidget:getWidgetByName("label_item_cost"):setString(event.itemprice*tonumber(mBuyText:getText()))
            end
        end
    end

    local function update(pSender)
        count = count + 1
        if count >10 and count < 999 then
            changeNumber(variable,pSender)
        elseif count > 999 then
            pSender:stopAllActions()
        end
    end

    local function pushCommitButtons( pSender, touchType )
        local num = checkint(mBuyText:getText())
        local btnName = pSender:getName()
        if touchType == ccui.TouchEventType.began then
            if btnName == "Button_sub" or btnName == "Button_add" then
                if btnName =="Button_sub" then variable = -1 end
                if btnName =="Button_add" then variable = 1 end
                count = 0
                pSender:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1/60), cc.CallFunc:create(function()
                    update(pSender)
                end))))
        end
        elseif touchType == ccui.TouchEventType.canceled then
            pSender:stopAllActions()
        elseif touchType == ccui.TouchEventType.ended then
            pSender:stopAllActions()
            if btnName == "Button_commit" then
                if onClickCommit then
                    onClickCommit(num,event.itemid)
                    closePanel()
                end
            elseif btnName =="Button_sub" then
                changeNumber(-1,pSender)
            elseif btnName == "Button_add" then
                changeNumber(1,pSender)
            elseif btnName == "Button_cancel" then
                closePanel()
            end
        end
    end

    local btns = {
        {name = "Button_sub",},
        {name = "Button_add",},
        {name = "Button_commit", text = Const.str_sure,},
        {name = "Button_cancel", text = Const.str_cancel,},
    }
    for k,v in pairs(btns) do
        panelWidget:getWidgetByName(v.name):addTouchEventListener(pushCommitButtons)
        if v.text then
            panelWidget:getWidgetByName(v.name):setTitleText(v.text)
        end
    end

    local visible = event.visible
    pMask:setVisible(visible)
    buyWidget:setVisible(visible)
end

function LayerAlert:handleWelcome(event)
    local onClickStart = event.startCallBack
    local pMask = self:getChildByName("pwelcome")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("pwelcome")
    local welcomeWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelWelcome.csb"):addTo(pMask)
    welcomeWidget:setScale(Const.maxScale)
    display.align(welcomeWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = welcomeWidget:getChildByName("Panel_welcome")
    panelWidget:setTouchEnabled(true)

    local function pushStartButton(pSender)
        local btnName = pSender:getName()
        if btnName == "Button_start" then
            if onClickStart then onClickStart() end
        end
        pMask:hide()
        welcomeWidget:removeFromParent()
    end

    local btnStart = panelWidget:getWidgetByName("Button_start")
    btnStart:addClickEventListener(pushStartButton)

    local visible = event.visible
    pMask:setVisible(visible)
    welcomeWidget:setVisible(visible)
end

function LayerAlert:handleFubenDone(event)
    local visible = event.visible
    self:setColorBgVisible(visible)
    if not visible then
        return
    end
    local pMask = self:getChildByName("fuben")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("fuben")
    local onClickConfirm = event.confirmCallBack
    local pfuben = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/Panel_FubenDone.csb"):addTo(pMask)
    pfuben:setScale(Const.maxScale)
    display.align(pfuben, display.CENTER, display.cx, display.cy)
    local allWidget = pfuben:getChildByName("Panel_fubendone")
    allWidget:getWidgetByName("Panel_fbfailed"):hide()
    local panelWidget = allWidget:getWidgetByName("Panel_fbsucess"):show()
    panelWidget:setTouchEnabled(true)
    panelWidget:getWidgetByName("label_show_tips"):hide()

    if not event.notaward then
        if #event.award > 0 then
            for i=1,4 do
                if event.award[i] then
                    UIItem.getSimpleItem({
                        parent = panelWidget:getWidgetByName("item_icon_"..i),
                        name = event.award[i].name,
                        num = event.award[i].num,
                    })
                end
            end
        end
    else
        for i=1,4 do
            panelWidget:getWidgetByName("item_icon_"..i):hide()
        end
        panelWidget:getWidgetByName("label_show_tips"):show():setString(event.tips)
        panelWidget:getWidgetByName("label_fuben_title"):setString("通关成功")
        panelWidget:getWidgetByName("Button_get"):setTitleText("离    开")
    end
    panelWidget:getWidgetByName("Button_get"):addClickEventListener(function (pSender)
        if onClickConfirm then onClickConfirm() end
        self:hideColorBg()
        pMask:hide()
        if pfuben then
            pfuben:removeFromParent()
            pfuben = nil
        end
        pMask = nil
    end)
end

function LayerAlert:handleFubenFailed(event)
    local visible = event.visible
    self:setColorBgVisible(visible)
    if not visible then
        return
    end
    local pMask = self:getChildByName("fuben")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("fuben")
    local onClickConfirm = event.confirmCallBack
    pfuben  = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/Panel_FubenDone.csb"):addTo(pMask)
    pfuben:setScale(Const.maxScale)
    display.align(pfuben, display.CENTER, display.cx, display.cy)
    local allWidget = pfuben:getChildByName("Panel_fubendone")
    allWidget:getWidgetByName("Panel_fbsucess"):hide()
    local panelWidget = allWidget:getWidgetByName("Panel_fbfailed"):show()
    panelWidget:setTouchEnabled(true)

    panelWidget:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
        if onClickConfirm then onClickConfirm() end
        --self:hideColorBg()
        pMask:hide()
        if pfuben then
            pfuben:removeFromParent()
            pfuben = nil
        end
        pMask = nil
    end)
end

function LayerAlert:handleEquipExchange(event)
    local visible = event.visible
    --self:setColorBgVisible(visible)

    if not visible then
        return
    end

    local pMask = self:getChildByName("equip")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end
    pMask = self:createMaskBg()
    pMask:addTo(self)
    pMask:setName("equip")
    local onClickConfirm = event.confirmCallBack
    local confirmWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelEquipExchange.csb"):addTo(pMask)
    confirmWidget:setScale(Const.maxScale)
    display.align(confirmWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = confirmWidget:getChildByName("Panel_equipExchange")
    panelWidget:setTouchEnabled(true)

    local function pushConfirmButtons( pSender )
        pMask:hide()
        local btnName = pSender:getName()
        if btnName == "Button_confirm" then
            if onClickConfirm then onClickConfirm() end
        end
        confirmWidget:removeFromParent()
        pMask = nil
    end

    local btnConfirm = panelWidget:getWidgetByName("Button_confirm")
    btnConfirm:setTitleText(event.confirmTitle or Const.str_titletext_confirm)
    btnConfirm:addClickEventListener(pushConfirmButtons)

    local btnCancel = panelWidget:getWidgetByName("Button_cancel")
    btnCancel:setTitleText(event.cancelTitle or Const.str_titletext_cancel)
    btnConfirm:addClickEventListener(pushConfirmButtons)

    local visible = event.visible
    pMask:setVisible(visible)
    confirmWidget:setVisible(visible)

    UIItem.getItem({
        parent = panelWidget:getWidgetByName("ImageView_ItemBg1"),
        typeId = event.typeid1,
    })

    UIItem.getItem({
        parent = panelWidget:getWidgetByName("ImageView_ItemBg2"),
        typeId = event.typeid2,
    })

    panelWidget:getWidgetByName("Label_Cost"):setString(event.lblCost)

    panelWidget:getWidgetByName("Label_ItemName1"):setString(event.name1)
    panelWidget:getWidgetByName("Label_ItemName2"):setString(event.name2)
end

function LayerAlert:handlesBoxRankPanel(event)
    if not event or not event.list or not event.award then return end
    --self:setColorBgVisible(true)

    local pMask = self:getChildByName("boxrank")
    if pMask then
        pMask:removeFromParent()
        pMask = nil
    end

    local touchNode = ccui.Widget:create():setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(self)
    touchNode:setTouchEnabled(true)
    touchNode:addClickEventListener(function (pSender)
        pSender:removeFromParent()
        pSender = nil
    end)
    touchNode:setName("boxrank")

    local rootidget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelSuperBoxRank.csb"):addTo(touchNode)
    rootidget:setScale(Const.maxScale)
    display.align(rootidget, display.CENTER, display.cx, display.cy)

    local panelWidget = rootidget:getChildByName("Panel_list")
    panelWidget:setTouchEnabled(true)
    local listview = panelWidget:getWidgetByName("ListView_rank")
    local copyNode = panelWidget:getWidgetByName("Panel_rank_item"):hide()
    local awardstr = ""
    for k, v in ipairs(event.award) do
        local itemdef = NetClient:getItemDefByID(v.typeid)
        if itemdef then
            if awardstr ~= "" then awardstr = awardstr.."<br>" end
            awardstr = awardstr..itemdef.mName--.."*"..game.make_str_with_color( Const.COLOR_GREEN_1_STR,v.num )
        end
    end

--    local newlist = {}
--    for k, v in ipairs(event.list) do
--        local find = false
--        for _, info in ipairs(newlist) do
--            print("", _, v.seedit, info.seedit)
--            if info.seedit == v.seedit then
--                info.cnt = info.cnt + 1
--                find = true
--                break
--            end
--        end
--        print("aaa", k, #newlist,find)
--        if not find then
--            table.insert(newlist, {cnt=1,guild=v.guild,job=v.job,name=v.name,seedit=v.seedit})
--        end
--    end
--    local sortF = function(fa, fb)
--        return fa.cnt > fb.cnt
--    end
--    if #newlist > 1 then
--        table.sort( newlist, sortF )
--    end

    for k, v in pairs(event.list) do
        local itembg = copyNode:clone():show()
        itembg:getWidgetByName("Text_name"):setString(v.name)
        itembg:getWidgetByName("Text_job"):setString(Const.JOB[v.job] or "")
        itembg:getWidgetByName("Text_guild"):setString(v.guild)
        local richLabel, richWidget = util.newRichLabel(cc.size(itembg:getWidgetByName("Text_award"):getContentSize().width, 0), 0)
        richWidget.richLabel = richLabel
        richWidget:setTouchEnabled(false)
        util.setRichLabel(richLabel, awardstr, "", 24, Const.COLOR_GREEN_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0, itembg:getWidgetByName("Text_award"):getContentSize().height-richLabel:getRealHeight()))
        richWidget:addTo(itembg:getWidgetByName("Text_award"))

        listview:pushBackCustomItem(itembg)
    end
end

function LayerAlert:handleMsgBottom()
    NetClient:alertLocalMsg(NetClient.msgMid[#NetClient.msgMid],"alert")
end

function LayerAlert:onEnter()
    self:registeEvent()
end

function LayerAlert:handlePropUse(event)
    if not event then return end
    local typeID = event.typeID
    local position = event.position
    if not typeID or not position then return end

    for k, v in ipairs(self.mPropItemList) do
        if v.position == position and v.typeID == typeID then
            return
        end
    end
    table.insert(self.mPropItemList, {typeID = typeID, position = position})
    self.mPropItemBg:stopAllActions()
    self.mPropItemBg:removeAllChildren()

    local widget = ccui.Widget:create()
    local bgWidget =  ccui.ImageView:create("backgroup_5.png",UI_TEX_TYPE_PLIST)
    bgWidget:align(display.LEFT_BOTTOM, 0,0)
    bgWidget:addTo(widget)

    local width, height = 0,0
    local newWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelBetterItem.csb"):addTo(widget)
    local copyNode = newWidget:getChildByName("Panel_betteritem"):hide()

    local showList = #self.mPropItemList > 1
    for k, v in ipairs(self.mPropItemList) do
        local itemDef = NetClient:getItemDefByID(v.typeID)
        if itemDef then
            local better_bg = copyNode:clone():show()

            better_bg:getWidgetByName("Text_addfight_value"):setString(itemDef.mAddFight):setVisible(false)
            better_bg:getWidgetByName("Text_addfight"):setVisible(false)
            local ccc = game.getColor(itemDef.mColor)
            better_bg:getWidgetByName("Text_itemname"):setString(itemDef.mName):setTextColor(game.getColor(itemDef.mColor)):setVisible(not showList)

            UIItem.getSimpleItem({
                parent = better_bg:getWidgetByName("icon_bg"),
                typeId = v.typeID,
            })

            better_bg:setTouchEnabled(false)
            height = better_bg:getContentSize().height
            display.align(better_bg, display.LEFT_CENTER, width, height/2)
            if showList then
                width = width + 98
                if k == #self.mPropItemList then width = width + 22 end
            else
                width = width + better_bg:getContentSize().width
            end
            better_bg:addTo(widget)

        end
    end

    bgWidget:setScale9Enabled(true)
    bgWidget:setContentSize(cc.size(width, height))
    widget:setContentSize(cc.size(width, height))
    widget:align(display.RIGHT_BOTTOM, display.width - Const.minScale * 300, 0)
    widget:setScale(Const.minScale)
    widget:addTo(self.mPropItemBg)

    ccui.ImageView:create("img_line01.png",UI_TEX_TYPE_PLIST)
    :setScale9Enabled(true)
    :setContentSize(cc.size(width-20, 2))
    :align(display.CENTER,width/2, 85)
    :addTo(widget)

    local btn_equip = ccui.Button:create()
    btn_equip:loadTextures("red_btn.png","","",UI_TEX_TYPE_PLIST)
    btn_equip:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btn_equip:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btn_equip:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btn_equip:setTitleText("使用")
    btn_equip:align(display.CENTER, width/2, 50)
    btn_equip:addTo(widget)



    local function onClose()
        self.mPropItemBg:stopAllActions()
        self.mPropItemList ={}
        self.mPropItemBg:hide()
    end

    local function newItemUse()
        local item_tab = {}
        for k, v in ipairs(self.mPropItemList) do
            local itemdef = NetClient:getItemDefByID(v.typeID)
            if itemdef and itemdef.mOneKeyuse and  itemdef.mOneKeyuse > 0 then
                table.insert( item_tab,v.position)
            end
        end
        onClose()
        NetClient:PushLuaTable("bag",util.encode({panelid = "bag_onekeyuse", params = item_tab}))
    end

    btn_equip:addClickEventListener(function (pSender)
        newItemUse()
    end)

    --    btn_close:addClickEventListener(function (pSender)
    --        onClose()
    --    end)

    self.mPropItemBg:setTouchEnabled(false)
    local cd = 5
    btn_equip:setTitleText("使用("..cd..")")
    self.mPropItemBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        cd = cd - 1
        if cd < 1 then
            newItemUse()
        else
            btn_equip:setTitleText("使用("..cd..")")
        end
    end))))

    self.mPropItemBg:show()
end

function LayerAlert:handleBetterItem(event)
    if not event then return end
    local typeID = event.typeID
    local position = event.position


    if not typeID or not position then return end

    if  game.isJianjia(typeID) or  game.isBaoshi(typeID) or  game.isDunpai(typeID)  or game.isAnqi(typeID)  or game.isYuxi(typeID)  or game.IsMedal(typeID) then return end

    local betterInAvatar, avaPos = game.isBetterInAvatar(position)
    if betterInAvatar ~= Const.ITEM_BETTER_SELF then return end

    self.mBetterItemBg:stopAllActions()
    self.mBetterItemBg:removeAllChildren()


    --self.mBetterItemBg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
    local removeIndex = {}
    for k, v in ipairs(self.mBetterItemList) do
        if v.avaPos == avaPos then
            table.insert(removeIndex, k)
        end
    end

    for i = 1, #removeIndex do
        table.remove(self.mBetterItemList, i)
    end

    table.insert(self.mBetterItemList, {typeID = typeID, position = position, avaPos = avaPos})
    local widget = ccui.Widget:create()
    local bgWidget =  ccui.ImageView:create("backgroup_5.png",UI_TEX_TYPE_PLIST)
    bgWidget:align(display.LEFT_BOTTOM, 0,0)
    bgWidget:addTo(widget)

    local width, height = 0,0
    local newWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelBetterItem.csb"):addTo(widget)
    local copyNode = newWidget:getChildByName("Panel_betteritem"):hide()

    local showList = #self.mBetterItemList > 1
    for k, v in ipairs(self.mBetterItemList) do
        local itemDef = NetClient:getItemDefByID(v.typeID)
        if itemDef then
            local better_bg = copyNode:clone():show()

            better_bg:getWidgetByName("Text_addfight_value"):setString(itemDef.mAddFight):setVisible(not showList)
            better_bg:getWidgetByName("Text_addfight"):setVisible(not showList)
            local ccc = game.getColor(itemDef.mColor)
            better_bg:getWidgetByName("Text_itemname"):setString(itemDef.mName):setTextColor(game.getColor(itemDef.mColor)):setVisible(not showList)

            UIItem.getSimpleItem({
                parent = better_bg:getWidgetByName("icon_bg"),
                typeId = v.typeID,
            })

            better_bg:setTouchEnabled(false)
            height = better_bg:getContentSize().height
            display.align(better_bg, display.LEFT_CENTER, width, height/2)
            if showList then
                width = width + 98
                if k == #self.mBetterItemList then width = width + 22 end
            else
                width = width + better_bg:getContentSize().width
            end
            better_bg:addTo(widget)

        end
    end

    bgWidget:setScale9Enabled(true)
    bgWidget:setContentSize(cc.size(width, height))
    widget:setContentSize(cc.size(width, height))
    widget:align(display.RIGHT_BOTTOM, display.width - Const.minScale * 300, 0)
    widget:setScale(Const.minScale)
    widget:addTo(self.mBetterItemBg)
--    local btn_close = ccui.Button:create()
--    btn_close:loadTextures("button_close1.png","","",UI_TEX_TYPE_PLIST)
--    btn_close:align(display.RIGHT_BOTTOM, width, height-20)
--    btn_close:addTo(widget)
    ccui.ImageView:create("img_line01.png",UI_TEX_TYPE_PLIST)
    :setScale9Enabled(true)
    :setContentSize(cc.size(width-20, 2))
    :align(display.CENTER,width/2, 85)
    :addTo(widget)

    local btn_equip = ccui.Button:create()
    btn_equip:loadTextures("red_btn.png","","",UI_TEX_TYPE_PLIST)
    btn_equip:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btn_equip:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btn_equip:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btn_equip:setTitleText("装备")
    btn_equip:align(display.CENTER, width/2, 50)
    btn_equip:addTo(widget)
    local function onClose()
        self.mBetterItemBg:stopAllActions()
        self.mBetterItemList ={}
        self.mBetterItemBg:hide()
    end
    local function newItemUse()
        local list = self.mBetterItemList
        onClose()

        if #list == 1 then
            NetClient:BagUseItem(list[1].position, list[1].typeID)
        else
            NetClient:OneKeyDress(list)
        end
    end
    btn_equip:addClickEventListener(function (pSender)
        newItemUse()
    end)
--    btn_close:addClickEventListener(function (pSender)
--        onClose()
--    end)
    self.mBetterItemBg:setTouchEnabled(false)
--    self.mBetterItemBg:addClickEventListener(function(pSender)
--        newItemUse()
--    end)
    local cd = 5
    btn_equip:setTitleText("装备("..cd..")")
    self.mBetterItemBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        cd = cd - 1
        if cd < 1 then
            newItemUse()
        else
            btn_equip:setTitleText("装备("..cd..")")
        end
    end))))
    self.mBetterItemBg:show()
    --end)))
end

function LayerAlert:createMaskBg()
    local mask = ccui.ImageView:create("uilayout/image/maskbg.png",UI_TEX_TYPE_LOCAL)
    mask:setOpacity(200)
    mask:setScale9Enabled(true)
    mask:setCascadeOpacityEnabled(false)
    mask:setContentSize(cc.size(Const.VISIBLE_WIDTH, Const.VISIBLE_HEIGHT))
    mask:setTouchEnabled(true)
    mask:align(display.CENTER, display.cx, display.cy)
    return mask
end

function LayerAlert:setColorBgVisible(visible)
    --[[
    if visible then
        self:showColorBg()
    else
        self:hideColorBg()
    end
    ]]
end

function LayerAlert:showColorBg()
--[[
    self.mColorBgCnt = self.mColorBgCnt + 1
    
	self.colorBg:show()
    ]]
end

function LayerAlert:hideColorBg()
--[[
    if self.mColorBgCnt > 0 then
        self.mColorBgCnt = self.mColorBgCnt - 1
    end

    print("self.mColorBgCnt=",self.mColorBgCnt)
    if self.mColorBgCnt < 1 then self.colorBg:hide() end
	self.colorBg:hide()
    ]]
end

return LayerAlert