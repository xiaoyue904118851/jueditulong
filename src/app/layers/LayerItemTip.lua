--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/18 16:21
-- To change this template use File | Settings | File Templates.
--

local LayerItemTip = class("LayerItemTip", function()
    return display.newNode()
end)

function LayerItemTip:ctor()
    local colorBg = ccui.ImageView:create("backgroup_10.png",UI_TEX_TYPE_PLIST)
    colorBg:setOpacity(200)
    colorBg:setScale9Enabled(true)
    colorBg:setContentSize(cc.size(display.width, display.height))
    colorBg:setTouchEnabled(true)
    colorBg:addClickEventListener(function (pSender)
        self:closeSelf()
    end)
    colorBg:align(display.CENTER, display.cx, display.cy)
    colorBg:addTo(self)

    self:enableNodeEvents()
    self:hide()
end

function LayerItemTip:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_HANDLE_ITEM_TIPS, handler(self,self.showTips))
end

function LayerItemTip:showTips(event)
    if event.visible ~= nil and event.visible == false then
        self:closeSelf()
        return
    end

    local typeId = event.typeId

    if not typeId then
        print("LayerItemTip:showTips==>self.typeId is null")
        return
    end

    local itemdef = NetClient:getItemDefByID(typeId)
    if itemdef == nil then
        print("LayerItemTip:showTips==>itemdef is null")
        return
    end

    self.itemdef = itemdef
    self.pos = event.pos
    self.typeId = typeId
    self.toDepot = event.toDepot
    self.toGDepot = event.toGDepot
    local otherItem = event.otherItem

    if event.level and not otherItem then
        otherItem = game.genNetItemByLevel(typeId,event.level)
    end

    self.item = otherItem or NetClient:getNetItem(self.pos)

    if self.pos and self.pos >= Const.ITEM_GUILDDEPOT_BEGIN then self.item = NetClient:getGuildDepotItem(self.pos) end

    self:cleanInfoLayer()
    self.infoLayer = display.newNode():addTo(self)

    self.curDetailBg = self:showDetail(self.pos,self.typeId,self.itemdef,self.item, not otherItem)

    local leftPos = game.getAvatarPos(self.typeId)

    local checkok = true
    if not otherItem then
        checkok = not game.IsPosInAvatar(self.pos)
    end

    if self.pos and not  game.IsPosInDepot(self.pos) and not self.toDepot and not game.IsPosInGuildDepot(self.pos) and not self.toGDepot and leftPos and checkok then
        local item = NetClient:getNetItem(leftPos)
        if item and NetClient:getItemDefByID(item.mTypeID) then
            local itemdef = NetClient:getItemDefByID(item.mTypeID)
            local leftDetailBg = self:showDetail(leftPos,item.mTypeID,itemdef,item)
            leftDetailBg:setPositionX(display.cx - leftDetailBg:getContentSize().width/2*Const.minScale)
            self.curDetailBg:setPositionX(display.cx + leftDetailBg:getContentSize().width/2*Const.minScale)-- + self.curDetailBg:getContentSize().width
        else
            self.curDetailBg:setPositionX(display.cx)
        end
    else
        self.curDetailBg:setPositionX(display.cx)
    end

    self:show()
end

function LayerItemTip:showDetail(pos, typeId, itemdef,item, ismy)
    local detailBg,tipview,bgsize
    if game.IsEquipment(typeId) then
        tipview = require("app.views.tips.EquipTipsView").new({typeID = typeId,netItem=item,showScrollBg=true,addbtn=ismy,toDepot=self.toDepot,toGDepot=self.toGDepot})
        detailBg = ccui.ImageView:create("uilayout/image/zhuangbeixinxi_bg.png")
        detailBg:setTouchEnabled(true)
    else
        tipview = require("app.views.tips.PropTipsView").new({typeID = typeId,netItem=item,addbtn=ismy,toDepot=self.toDepot,toGDepot=self.toGDepot})
        detailBg = ccui.ImageView:create("backgroup_5.png",UI_TEX_TYPE_PLIST)
        detailBg:setScale9Enabled(true)
        detailBg:setContentSize(cc.size(tipview:getContentSize().width+40, tipview:getContentSize().height+50))
    end
    tipview:align(display.CENTER_TOP, detailBg:getContentSize().width/2, detailBg:getContentSize().height-20)
    tipview:addTo(detailBg)
    detailBg:setTouchEnabled(true)
    detailBg:align(display.CENTER, display.cx, display.cy):setScale(Const.minScale)
    detailBg:addTo(self.infoLayer)
    return detailBg
end

function LayerItemTip:cleanInfoLayer()
    if self.infoLayer then
        self.infoLayer:removeFromParent()
        self.infoLayer = nil
    end
end


function LayerItemTip:closeSelf()
    self:hide()
    self:cleanInfoLayer()
end

function LayerItemTip:onEnter()
    self:registeEvent()
end

return LayerItemTip