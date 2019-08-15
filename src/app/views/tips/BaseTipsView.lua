--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/27 10:
-- To change this template use File | Settings | File Templates.
--

--
-- 不能摧毁的物品列表
CAN_NOT_DESTROY_ITEM = {
    ["旋风流星刀"] = 1,
    ["灭世天雷杖"] = 1,
    ["封魔流星剑"] = 1,
    ["紫金天龙刀"] = 1,
    ["天星龙渊杖"] = 1,
    ["诛仙灭魔剑"] = 1,
    ["玄铁破魔刃"] = 1,
    ["紫金雷鸣杖"] = 1,
    ["无极玄光剑"] = 1,
    ["轩辕剑·至尊"] = 1,
    ["轩辕剑·浑元"] = 1,
    ["轩辕剑·北冥"] = 1,
    ["轩辕神甲·至尊"] = 1,
    ["轩辕神甲·浑元"] = 1,
    ["轩辕神甲·北冥"] = 1,
    ["轩辕神衣·至尊"] = 1,
    ["轩辕神衣·浑元"] = 1,
    ["轩辕神衣·北冥"] = 1,
    ["七煞神衣·至尊"] = 1,
    ["七煞神衣·浑元"] = 1,
    ["七煞神衣·北冥"] = 1,
    ["八方神衣·至尊"] = 1,
    ["八方神衣·浑元"] = 1,
    ["八方神衣·北冥"] = 1,
    ["九五神衣·至尊"] = 1,
    ["九五神衣·浑元"] = 1,
    ["九五神衣·北冥"] = 1,
    ["七煞神甲·至尊"] = 1,
    ["七煞神甲·浑元"] = 1,
    ["七煞神甲·北冥"] = 1,
    ["八方神甲·至尊"] = 1,
    ["八方神甲·浑元"] = 1,
    ["八方神甲·北冥"] = 1,
    ["九五神甲·至尊"] = 1,
    ["九五神甲·浑元"] = 1,
    ["九五神甲·北冥"] = 1,
}


LOCAL_GO_ITEM = {}


LOCAL_GO_ITEM["qibaoItem"] = {
    [10847] = true,
    [10482] = true,
    [10483] = true,
}

LOCAL_GO_ITEM["lingyuItem"] = {
    [10265] = true,
    [10266] = true,
    [10267] = true,
    [10268] = true,
    [10269] = true,
    [10270] = true,
    [10271] = true,
    [10272] = true,
    [10273] = true,
    [10274] = true,
    [10275] = true,
    [10276] = true,
}

LOCAL_GO_ITEM["fabaoItem"] = {
    [10415] = true,
    [10484] = true,
}

LOCAL_GO_ITEM["zhuanshengItem"] = {
    [10298] = true,
}

LOCAL_GO_ITEM["qilingItem"] = {
    [10172] = true,
    [10173] = true,
}

LOCAL_GO_ITEM["huanhundanItem"] = {
    [19002] = true,
}

LOCAL_GO_ITEM["shengzhuangpieceItem"] = {
    [10843] = true,
    [10844] = true,
    [10845] = true,
    [10846] = true,
}

LOCAL_GO_ITEM["labaItem"] = {
    [10083] = true,
    [10084] = true,
}

LOCAL_GO_ITEM["longtenghaoliItem"] = {
    [10182] = true,
}

LOCAL_GO_ITEM["specailPieceItem"] = {
    [10454] = true,
    [10449] = true,
    [10451] = true,
    [10452] = true,
    [10455] = true,
    [10456] = true,
    [10457] = true,
    [10458] = true,
    [10459] = true,
    [10460] = true,
    [10461] = true,
    [10462] = true,
}
LOCAL_NEED_VIP_CONFIG = {
    [18148] = 1
}
-- 一次只能使用一个的道具
LOCAL_USE_ONE = {
    [15015]=true,
    [15587]=true,
}

LOCAL_GO_CFG = {}
LOCAL_GO_CFG["qibaoItem"] = { func = "goPanel", name = "panel_qibaoge"}
LOCAL_GO_CFG["lingyuItem"] = { func = "goPanel", name = "panel_wing"}
LOCAL_GO_CFG["fabaoItem"] = { func = "goPanel", name = "panel_fabao"}
LOCAL_GO_CFG["zhuanshengItem"] = {func = "goZhuansheng", name = "panel_roleInfo", tag = 5 }
LOCAL_GO_CFG["qilingItem"] = {func = "goPanel", name = "panel_roleInfo", tag = 2 }
LOCAL_GO_CFG["huanhundanItem"] = {func = "showMsg", name = "角色无需复活"}
LOCAL_GO_CFG["shengzhuangpieceItem"] = {func = "goPanel", name = "panel_smelter", tag = 7 , btnTag = game.OP_BUTTONS.HECHENG}
LOCAL_GO_CFG["labaItem"] = {func = "goPanel", name = "panel_chat" }
LOCAL_GO_CFG["longtenghaoliItem"] = {func = "goPanel", name = "panel_haoli"}
LOCAL_GO_CFG["specailPieceItem"] = {func = "goPanel", name = "panel_specailRing"}

local BaseTipsView = class("BaseTipsView", function()
    return display.newNode()
end)

-- netItem 对象 可有可无
-- typeID  必须有

function BaseTipsView:ctor(params)
    local params = params or {}
    local itemdef = NetClient:getItemDefByID(params.typeID)
    if itemdef then
        self.netItem = params.netItem
        self.lockHeight = params.lockHeight
        self.showScrollBg = params.showScrollBg
        self.itemDef = itemdef
        self.addbtn = params.addbtn
        self.toDepot = params.toDepot
        self.toGDepot = params.toGDepot
        self:addContent()
    else
        print("typeID is error")
    end
end

function BaseTipsView:addContent()
    self.startBgSize = cc.size(346, 348)
    self.contentHeight = 0
    self:setContentSize(self.startBgSize)
    self.layoutLayer = ccui.Layout:create()
    self.layoutLayer:setContentSize(self.startBgSize)
--        self.layoutLayer:setBackGroundImageScale9Enabled(true)
--        self.layoutLayer:setBackGroundImage("backgroup_10.png",UI_TEX_TYPE_PLIST)
    self.layoutLayer:setLayoutType(ccui.LayoutType.VERTICAL)
    self.layoutLayer:addTo(self)
    self:addTop()
    self:addDesc()
    self:addBtnLayer()
    self:resetBgHeight()
    self:addMoreOpPanel()
end

function BaseTipsView:addTop()
end

function BaseTipsView:getScrollHeight()
    return 157
end

function BaseTipsView:addDesc()
    local linearLayoutParameter = ccui.LinearLayoutParameter:create()
    linearLayoutParameter:setGravity(ccui.LinearGravity.centerHorizontal)
    local scrollheight = self:getScrollHeight()
    local scrollsize = cc.size(self.startBgSize.width,scrollheight)
    local scroll = ccui.ScrollView:create()
    scroll:setClippingEnabled(true)
    scroll:setContentSize(scrollsize)
    scroll:setInnerContainerSize(scrollsize)
    if self.showScrollBg then
        scroll:setBackGroundImageScale9Enabled(true)
        scroll:setBackGroundImage("backgroup_6.png",UI_TEX_TYPE_PLIST)
    end
    local html_str = self:getScrollStr()
    if html_str ~= "" then
        local richw = scrollsize.width-20
        local richLabel,richWidget = util.newRichLabel(cc.size(richw,0))
        util.setRichLabel(richLabel,html_str,"",24,Const.COLOR_YELLOW_1_OX)
        richLabel:setVisible(true)
        local realheight = richLabel:getRealHeight() + 10
        richWidget:setContentSize(cc.p(richw,realheight))
        if realheight > scrollheight then
            scroll:setInnerContainerSize(cc.size(scrollsize.width,realheight))
            if not game.IsEquipment(self.itemDef.mTypeID) and not self.lockHeight then
                -- TODO 可能会需要一个最大值
                scrollheight = realheight
                scroll:setContentSize(cc.size(scrollsize.width,realheight))
            else
                scroll:setBounceEnabled(true)
            end
            richWidget:setPositionY(0)
        else
            richWidget:setPositionY(scrollheight-realheight)
        end
        richWidget:setPositionX(10)
        scroll:addChild(richWidget,10)
    end
    scroll:setLayoutParameter(linearLayoutParameter)
    scroll:addTo(self.layoutLayer)
    self.contentHeight = self.contentHeight + scrollheight
end

function BaseTipsView:getScrollStr()
    return ""
end

function BaseTipsView:addBtnLayer()
    if self.addbtn and self.netItem then
        local widget = ccui.Widget:create()
        widget:setContentSize(cc.size(self.startBgSize.width, 72))
        self:addBtns(widget)
        local linearLayoutParameter = ccui.LinearLayoutParameter:create()
        linearLayoutParameter:setGravity(ccui.LinearGravity.centerHorizontal)
        widget:setLayoutParameter(linearLayoutParameter)
        widget:addTo(self.layoutLayer)
        self.contentHeight = self.contentHeight + widget:getContentSize().height
    end
end

function BaseTipsView:addBtns(widget)
    if game.IsPosInAvatar(self.netItem.position) then
        self:addDressedOpBtn(widget)
    elseif game.IsPosInBag(self.netItem.position) then
        if self.toDepot then
            self:addBagToDepotOpBtn(widget)
        elseif self.toGDepot then
            self:addBagToGDepotOpBtn(widget)
        else
            self:addNormalUseBtn(widget)
        end
    elseif game.IsPosInLottery(self.netItem.position) then
        --        btnConfig = self:getLotteryOpBtnCfg()
    elseif game.IsPosInDepot(self.netItem.position) then
        self:addDepotOpBtn(widget)
    elseif game.IsPosInGuildDepot(self.netItem.position) then
        self:addGDepotOpBtn(widget)
    end
end

function BaseTipsView:addDepotOpBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.DEPOT_OUT
    local btnOp = ccui.Button:create()
    btnOp:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btnOp:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)


    btnCfg = game.OP_BUTTONS.CLOSE
    local btnOp2 = ccui.Button:create()
    btnOp2:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp2:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btnOp2:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btnOp2:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp2:setTitleText(btnCfg.text)
    btnOp2:setTag(btnCfg.tag)
    btnOp2:setAnchorPoint(display.RIGHT_BOTTOM)
    btnOp2:setPosition(cc.p(ox-space,0))
    btnOp2:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp2:addTo(widget)
end

function BaseTipsView:addGDepotOpBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.GDEPOT_OUT
    local btnOp = ccui.Button:create()
    btnOp:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btnOp:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)


    btnCfg = game.OP_BUTTONS.CLOSE
    local btnOp2 = ccui.Button:create()
    btnOp2:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp2:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btnOp2:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btnOp2:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp2:setTitleText(btnCfg.text)
    btnOp2:setTag(btnCfg.tag)
    btnOp2:setAnchorPoint(display.RIGHT_BOTTOM)
    btnOp2:setPosition(cc.p(ox-space,0))
    btnOp2:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp2:addTo(widget)
end

function BaseTipsView:addBagToDepotOpBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.BAG_TO_DEPOT
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)

    local btnCfg = game.OP_BUTTONS.CLOSE
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.RIGHT_BOTTOM)
    btnOp:setPosition(cc.p(ox-space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)
end

function BaseTipsView:addBagToGDepotOpBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.BAG_TO_GDEPOT
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)

    local btnCfg = game.OP_BUTTONS.CLOSE
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.RIGHT_BOTTOM)
    btnOp:setPosition(cc.p(ox-space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)
end

function BaseTipsView:addNormalUseBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.USE
    if game.IsMedicine(self.netItem.mTypeID) then
        btnCfg = game.OP_BUTTONS.EAT
    elseif  game.IsEquipment(self.netItem.mTypeID) then
        btnCfg = game.OP_BUTTONS.DRESS
    end

    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)

    local btnCfg = game.OP_BUTTONS.MORE
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.RIGHT_BOTTOM)
    btnOp:setPosition(cc.p(ox-space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)
    self.haveMoreBtn = true
end

function BaseTipsView:addDressedOpBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.UPGRADE
    local btnOp = ccui.Button:create()
    btnOp:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
    btnOp:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.CENTER_BOTTOM)
    btnOp:setPosition(cc.p(self.startBgSize.width/2,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)

    if not game.isJianjia(self.netItem.mTypeID) and  not game.isBaoshi(self.netItem.mTypeID) and not game.isDunpai(self.netItem.mTypeID)  and not game.isAnqi(self.netItem.mTypeID)  and not game.isYuxi(self.netItem.mTypeID)  then
        btnCfg = game.OP_BUTTONS.UNDRESS
        local btnOp2 = ccui.Button:create()
        btnOp2:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
        btnOp2:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
        btnOp2:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
        btnOp2:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
        btnOp2:setTitleText(btnCfg.text)
        btnOp2:setTag(btnCfg.tag)
        btnOp2:setAnchorPoint(display.LEFT_BOTTOM)
        btnOp2:setPosition(cc.p(ox+space,0))
        btnOp2:addClickEventListener(handler(self, self.onBtnClicked))
        btnOp2:addTo(widget)
        btnOp:setAnchorPoint(display.RIGHT_BOTTOM)
        btnOp:setPositionX(ox-space)
    end
end

function BaseTipsView:onBtnClicked(pSender)
    local btnTag = pSender:getTag()
    print("BaseTipsView:onBtnClicked==", btnTag)

    if pSender.btnCallBack then
        pSender.btnCallBack()
        return
    end

    if btnTag == game.OP_BUTTONS.DRESS.tag or btnTag == game.OP_BUTTONS.EAT.tag or btnTag == game.OP_BUTTONS.ACTIVE.tag  or btnTag == game.OP_BUTTONS.USE.tag or btnTag == game.OP_BUTTONS.HECHENG.tag then
        self:onUseItem(pSender)
    elseif btnTag == game.OP_BUTTONS.SHOW.tag then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_chat", typeid = self.netItem.mTypeID})
    elseif btnTag == game.OP_BUTTONS.SELL.tag then
        self:onSellItem(pSender)
    elseif btnTag == game.OP_BUTTONS.DESTROY.tag then
        self:onDestroyItem(pSender)
    elseif btnTag == game.OP_BUTTONS.UNDRESS.tag then
        self:onUndress(pSender)
    elseif btnTag == game.OP_BUTTONS.RECOVERY.tag then
        self:onRecycle(pSender)
    elseif btnTag == game.OP_BUTTONS.CHAI.tag then
        self:onChaiFen(pSender)
    elseif btnTag == game.OP_BUTTONS.DUI.tag then
        self:onDuidie(pSender)
    elseif btnTag == game.OP_BUTTONS.UPGRADE.tag then
        self:onUpgrade(pSender)
    elseif btnTag == game.OP_BUTTONS.LOTTERY_OUT.tag then
        --        self:moveLotteryToBag(pSender)
    elseif btnTag == game.OP_BUTTONS.DEPOT_OUT.tag then
        self:moveDepotToBag(pSender)
    elseif btnTag == game.OP_BUTTONS.BAG_TO_DEPOT.tag then
        self:moveBagToDepot(pSender)
    elseif btnTag == game.OP_BUTTONS.GDEPOT_OUT.tag then
        self:moveGDepotToBag(pSender)
    elseif btnTag == game.OP_BUTTONS.BAG_TO_GDEPOT.tag then
        self:moveBagToGDepot(pSender)
    elseif btnTag == game.OP_BUTTONS.MORE.tag then
        self.opPanel:show()
    end
    if btnTag ~= game.OP_BUTTONS.MORE.tag then
        if self.opPanel then self.opPanel:hide() end
    end

    NetClient:dispatchEvent(
        {
            name = Notify.EVENT_HANDLE_ITEM_TIPS,
            visible = false,
        })
end

function BaseTipsView:onUseItem(pSender)
    if self.itemDef.SubType == 12 then
        -- 玄晶
        self:onUpgrade(pSender)
        return
    end

    local needVipLevel = LOCAL_NEED_VIP_CONFIG[self.netItem.mTypeID]
    if needVipLevel and needVipLevel > 0  then
        local vipLevel = game.getVipLevel()
        if vipLevel < needVipLevel then
            local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = string.format("王者待遇：成为%s就可以使用红包哦", game.make_str_with_color(Const.COLOR_RED_1_STR,"VIP"..needVipLevel)),
                confirmTitle = "充 值", cancelTitle = "取 消",
                confirmCallBack = function ()
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
                end
            }
            NetClient:dispatchEvent(param)
            return
        end
    end

    local fcfg = self:getUseGoToPanelOrMsgFunc()
    if fcfg ~= nil then
        self[fcfg.func](self, fcfg.name, fcfg.tag)
        return
    end
--    if self.netItem.mOneKeyuse and self.itemDef.mOneKeyuse > 0 then
--        local havenum = NetClient:getBagItemNumberById(self.netItem.mTypeID)
--        if havenum > 1 then
--            local param = {
--                name = Notify.EVENT_PANEL_ON_ALERT, panel = "input", visible = true, lblConfirm = "请输入使用数量",
--                confirmTitle = "是", cancelTitle = "否",
--                maxNum = havenum,
--                num = 1,
--                confirmCallBack = function (num)
--                    NetClient:BagUseItem(self.netItem.position, self.netItem.mTypeID,num)
--                end
--            }
--            NetClient:dispatchEvent(param)
--        else
--            NetClient:BagUseItem(self.netItem.position, self.netItem.mTypeID)
--        end
--        NetClient:BagUseItem(self.netItem.position, self.netItem.mTypeID,havenum)
--    else
--        NetClient:BagUseItem(self.netItem.position, self.netItem.mTypeID,self.netItem.mNumber)
--    end
    local usenum = self.netItem.mNumber
    if LOCAL_USE_ONE[self.netItem.mTypeID] or game.IsMedicine(self.netItem.mTypeID) then usenum = 1 end
    NetClient:BagUseItem(self.netItem.position, self.netItem.mTypeID,usenum)
end

function BaseTipsView:getUseGoToPanelOrMsgFunc()
    for k,v in pairs(LOCAL_GO_CFG) do
        if self:isLocalGoItem(k) then
            return v
        end
    end
end

function BaseTipsView:onDestroyItem(pSender)
    if game.IsWing(self.netItem.mTypeID) or game.IsLightWing(self.netItem.mTypeID) then
        NetClient:alertLocalMsg("羽翼不能被摧毁","alert")
        return
    end

    if self.netItem.mLevel > 0 then
        NetClient:alertLocalMsg("强化过的装备，在锻造进行强化转移后再摧毁可避免损失","alert")
        return
    end

    if CAN_NOT_DESTROY_ITEM[self.itemDef.mName] or  game.IsSpecailRing(self.netItem.mTypeID) then
        NetClient:alertLocalMsg("神器或特戒无法被摧毁","alert")
        return
    end

    local function confirm_destroy()
        NetClient:DestoryItem(self.netItem.position, self.netItem.mTypeID, 1)
    end

    if game.isRareEquip(self.netItem.mTypeID, self.itemDef.mColor) then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = self.itemDef.mName.."是稀有装备，确定摧毁吗？",
            confirmTitle = "是", cancelTitle = "否",
            confirmCallBack = function ()
                confirm_destroy()
            end
        }
        NetClient:dispatchEvent(param)
    else
        confirm_destroy()
    end
end

function BaseTipsView:onSellItem(pSender)
    if self.netItem.mLevel > 0 then
        NetClient:alertLocalMsg("强化过的装备，在锻造进行强化转移后再出售可避免损失","alert")
        return
    end
    local function confirm_sell()
        NetClient:NPCSell(0,self.netItem.position,self.netItem.mTypeID,self.netItem.mNumber,200)
    end

    if game.isRareEquip(self.netItem.mTypeID, self.itemDef.mColor) then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = self.itemDef.mName.."是稀有装备，确定出售吗？",
            confirmTitle = "是", cancelTitle = "否",
            confirmCallBack = function ()
                confirm_sell()
            end
        }
        NetClient:dispatchEvent(param)
    else
        confirm_sell()
    end
end

function BaseTipsView:onUndress(pSender)
    if not game.IsPosInAvatar(self.netItem.position) then
        return
    end

    NetClient:UndressItem(self.netItem.position)
end

function BaseTipsView:onRecycle(pSender)
    if self.netItem.mLevel > 0 then
        NetClient:alertLocalMsg("强化过的装备，在锻造进行强化转移后再回收可避免损失","alert")
        return
    end

    local function confirm_recycle()
        NetClient:PushLuaTable("bag",util.encode({actionid = "do_recycle_item", panelid = "recycle_equip", params = {{pos=self.netItem.position}}}))
    end

    if game.isRareEquip(self.netItem.mTypeID, self.itemDef.mColor) then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = self.itemDef.mName.."是稀有装备，确定回收吗？",
            confirmTitle = "是", cancelTitle = "否",
            confirmCallBack = function ()
                confirm_recycle()
            end
        }
        NetClient:dispatchEvent(param)
    else
        confirm_recycle()
    end
end

function BaseTipsView:onChaiFen(pSender)
    if not game.checkSplit(self.netItem) then
        return
    end

    local function confirm_split(num)
        NetClient:SplitItem(self.netItem.position,self.netItem.mTypeID,num)
    end

    local param = {
        name = Notify.EVENT_PANEL_ON_ALERT, panel = "input", visible = true, lblConfirm = "请输入拆分数量",
        confirmTitle = "是", cancelTitle = "否",
        maxNum = self.netItem.mNumber - 1,
        num = 1,
        confirmCallBack = function (num)
            confirm_split(num)
        end
    }
    NetClient:dispatchEvent(param)
end

function BaseTipsView:onDuidie(pSender)
    local toPos = game.checkDuidie(self.netItem)
    if not toPos then
        NetClient:alertLocalMsg("不能堆叠","alert")
        return
    end
    NetClient:ItemPositionExchange(self.netItem.position, toPos)
end

function BaseTipsView:onUpgrade(pSender)
    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_smelter"})
end

function BaseTipsView:moveLotteryToBag(pSender)
    if NetClient:isBagFull() then
        NetClient:alertLocalMsg("包裹已满","alert")
    else
        NetClient:ItemPositionExchange(self.netItem.position, 0)
    end
end

function BaseTipsView:moveDepotToBag(pSender)
    local topos = NetClient:findEmptyPositionInBag()
    if not topos then
        NetClient:alertLocalMsg("背包已满","alert")
    else
        if not game.checkBtnClick() then return end
        NetClient:ItemPositionExchange(self.netItem.position, topos)
    end
end

function BaseTipsView:moveGDepotToBag(pSender)
    NetClient:PushLuaTable("newgui.guilddepot.onGetJsonData",util.encode({actionid = "guilddepot2bag",from=self.netItem.position,typeid=self.netItem.mTypeID}))
end

function BaseTipsView:moveBagToDepot(pSender)
    local topos = NetClient:findEmptyPositionInDepot()
    if not topos then
        NetClient:alertLocalMsg("仓库已满","alert")
    else
        if not game.checkBtnClick() then return end
        NetClient:ItemPositionExchange(self.netItem.position, topos)
    end
end

function BaseTipsView:moveBagToGDepot(pSender)
    NetClient:PushLuaTable("newgui.guilddepot.onGetJsonData",util.encode({actionid = "bag2guilddepot",from=self.netItem.position}))
end

function BaseTipsView:resetBgHeight()
    self:setContentSize(self.startBgSize.width, self.contentHeight)
    self.layoutLayer:setContentSize(self.startBgSize.width, self.contentHeight)
end

function BaseTipsView:addMoreOpPanel()
    if not self.haveMoreBtn then return end

    self.opPanel = ccui.Widget:create()--ccui.ImageView:create("uilayout/image/maskbg.png",UI_TEX_TYPE_LOCAL)
    --    self.opPanel:setScale9Enabled(true)
    self.opPanel:setContentSize(cc.size(self:getContentSize().width, self:getContentSize().height))
    self.opPanel:setTouchEnabled(true)
    self.opPanel:addClickEventListener(function (pSender)
        self.opPanel:hide()
    end)
    self.opPanel:align(display.LEFT_BOTTOM, 0, 0)
    self.opPanel:addTo(self)
    local linearLayoutParameter = ccui.LinearLayoutParameter:create()
    linearLayoutParameter:setGravity(ccui.LinearGravity.none)
    self.opPanel:setLayoutParameter(linearLayoutParameter)



    local btnConfig = self:getMoreOpBtnCfg(self.netItem)


    local posX = self:getContentSize().width/2-5
    local posY = 98
    for i = 1, #btnConfig do
        local btnCfg = btnConfig[i]
        local btnOp = ccui.Button:create()
        btnOp:setName(btnCfg.name)
        btnOp:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
        btnOp:setTitleFontSize(24)
        btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
        btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
        btnOp:setTitleText(btnCfg.text)
        btnOp:setTag(btnCfg.tag)
        btnOp:setAnchorPoint(display.RIGHT_CENTER)
        btnOp:setPosition(cc.p(posX,posY))
        btnOp:addClickEventListener(handler(self, self.onBtnClicked))
        self.opPanel:addChild(btnOp)
        posY = posY + 72
    end

    self.opPanel:hide()
end

function BaseTipsView:getMoreOpBtnCfg()
    local btnConfig = {}
    if game.IsEquipment(self.netItem.mTypeID) then
        if game.canRecyle(self.itemDef) then
            table.insert(btnConfig, game.OP_BUTTONS.RECOVERY)
        end
        table.insert(btnConfig, game.OP_BUTTONS.SHOW)
    elseif game.IsMedicine(self.netItem.mTypeID) then
    else
        --    道具
        if game.checkActive(self.netItem) then
            table.insert(btnConfig, game.OP_BUTTONS.ACTIVE)
        end
    end

    if game.checkSplit(self.netItem) then
        table.insert(btnConfig, game.OP_BUTTONS.CHAI)
    end

    if game.checkDuidie(self.netItem) then
        table.insert(btnConfig, game.OP_BUTTONS.DUI)
    end

    table.insert(btnConfig, game.OP_BUTTONS.SELL)
    table.insert(btnConfig, game.OP_BUTTONS.DESTROY)
    return btnConfig
end

function BaseTipsView:isLocalGoItem(name)
    if not LOCAL_GO_ITEM[name] then
        return
    end

    return LOCAL_GO_ITEM[name][self.netItem.mTypeID]
end


function BaseTipsView:goPanel(name, tag)
    if name then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = name, pdata = {tag = tag}})
    end
end


function BaseTipsView:goZhuansheng(name, tag)
    if game.getRoleLevel() < LimitConst.ZHUANSHENG_MIN_LEVEL then
        NetClient:alertLocalMsg("转生系统需要"..LimitConst.ZHUANSHENG_MIN_LEVEL.."级","alert")
        return
    end
    self:goPanel(name, tag)
end


function BaseTipsView:showMsg(name)
    NetClient:alertLocalMsg(name,"alert")
end

return BaseTipsView