--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/25 18:53
-- To change this template use File | Settings | File Templates.
-- LayerNotice

local LayerNotice = class("LayerNotice", function()
    return ccui.Layout:create()
end)

function LayerNotice:ctor()
    self:enableNodeEvents()
    self.listdata = {}
    self:addWidget()
end

function LayerNotice:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE, handler(self, self.handleUpdateGroupApplyChange))
    :addEventListener(Notify.EVENT_TRADE_CHANGE, handler(self, self.handleUpdateTrade))
    :addEventListener(Notify.EVENT_SELF_HPMP_CHANGE,  handler(self, self.handleHpMpChange))
    :addEventListener(Notify.EVENT_RECEIVE_MAIL_LIST,  handler(self, self.handleMailChange))
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA,  handler(self, self.handleYaBiaoChange))
    :addEventListener(Notify.EVENT_PANEL_RELIVE, handler(self, self.handleStrButtonShow))
    :addEventListener(Notify.EVENT_STRENGTNEN_BUTTON_SHOW, handler(self, self.handleStrButtonShow))
end

function LayerNotice:addWidget()
    local widget = WidgetHelper:getWidgetByCsb("uilayout/LayerNotice/LayerNotice.csb")
    widget:addTo(self, 2)
    self.widget = widget:getChildByName("Panel_notice")
    self.widget:align(display.CENTER_BOTTOM, display.cx, 0)
    self.widget:setScale(Const.minScale)
    self.srcNoticeListItem = self.widget:getWidgetByName("Button_group"):hide()
    self.noticeListView = self.widget:getWidgetByName("ListView_notice"):hide()
    
    --[[
    self.hpBtn = self.widget:getWidgetByName("Button_hptip"):hide()
    self.hpBtn:addClickEventListener(function ( pSender )
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag",  pdata = {tag = 4}})
    end)
    self.ybBtn = self.widget:getWidgetByName("Button_ybtip"):hide()
    self.strBtn = self.widget:getWidgetByName("Button_strentip"):hide()
    self.ybBtn:addClickEventListener(function ( pSender )
        NetClient:PushLuaTable("npc.biaoshi.onGetJsonData",util.encode({actionid="find_biaoche"}))
    end)
    
    self.strBtn:addClickEventListener(function ( pSender )
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_strengthen"})
    end)
    ]]
end

function LayerNotice:handleStrButtonShow(event)
    if not event then return end
    if event.hideType then 
        --self.strBtn:hide()
        --self.strBtn:setTouchEnabled(not event.hideType)
        if #self.listdata > 0 then
            for j= 1,#self.listdata do
                if self.listdata[j] == Const.NOTICE_TYPE.STRENGTH then
                    table.remove(self.listdata,j)
                    self:updateNoticeListView()
                end
            end
        end
    else
        local insertType = false
        if #self.listdata > 0 then
            for j= 1,#self.listdata do
                if self.listdata[j] == Const.NOTICE_TYPE.STRENGTH then
                    insertType = true
                end
            end
        end
        if not insertType then
            self.listdata[#self.listdata + 1] = Const.NOTICE_TYPE.STRENGTH
            self:updateNoticeListView()
        end
        --self.strBtn:show()
        --self.strBtn:setTouchEnabled(true)
    end
end

function LayerNotice:CheckMedicineNUM()
    local num = 0
    for i = 5, #Const.Skill_Setting_Item do
       num = num + NetClient:getBagItemNumberById(Const.Skill_Setting_Item[i].id)
    end
    return num
end

function LayerNotice:handleUpdateGroupApplyChange()
    local addType
    local removeTypes = {}

    -- 申请入队
    local appCount = 0
    for k,v in pairs(NetClient.mGroupApplyers) do
        appCount = appCount + 1
    end
    if appCount > 0 then
        addType = Const.NOTICE_TYPE.GROUP_APPLY
        table.insert(removeTypes, Const.NOTICE_TYPE.GROUP_INVITE)
    else
        table.insert(removeTypes, Const.NOTICE_TYPE.GROUP_APPLY)
    end

    if appCount == 0 then
        -- 邀请入队
        local inviteCount = 0
        for k,v in pairs(NetClient.mGroupInvite) do
            inviteCount = inviteCount + 1
        end
        if inviteCount > 0 then
            addType = Const.NOTICE_TYPE.GROUP_INVITE
        else
            table.insert(removeTypes, Const.NOTICE_TYPE.GROUP_INVITE)
        end
    end

    -- 删除
    for i = 1, #removeTypes do
        local clearType = removeTypes[i]
        for j = 1, #self.listdata do
            if self.listdata[j] == clearType then
                table.remove(self.listdata,j)
                break
            end
        end
    end

    if addType ~= nil then
        local insertNew = true
        for i = 1, #self.listdata do
            if self.listdata[i] == addType then
                insertNew = false
                break
            end
        end
        if insertNew then
            self.listdata[#self.listdata + 1] = addType
        end
    end

    self:updateNoticeListView()
end

function LayerNotice:handleUpdateTrade(event)
    if event and event.tradeTarget then
        self.listdata[#self.listdata + 1] = Const.NOTICE_TYPE.TRADE
        self:updateNoticeListView()
    end
end

function LayerNotice:handleMailChange(event)
    --[[
    local unReadNum = 0
    table.walk(NetClient.mMailList,function(v,k)
        table.insert(var.sortlist, k)
        if v.isOpen ~= 1 then unReadNum = unReadNum + 1 end
    end)
    ]]
    
    if NetClient.mNewMailNum > 0 then
        local MailType = true
        if self.listdata then
            if #self.listdata > 0 then
                for i= 1,#self.listdata do
                    if self.listdata[i] == Const.NOTICE_TYPE.MAIL then
                        MailType = false
                    end
                end
            end
        end
        if MailType then
            self.listdata[#self.listdata + 1] = Const.NOTICE_TYPE.MAIL
            self:updateNoticeListView()
        end

        if NetClient.openMailType then
            if #self.listdata > 0 then
                for j= 1,#self.listdata do
                    if self.listdata[j] == Const.NOTICE_TYPE.MAIL then
                        table.remove(self.listdata,j)
                        self:updateNoticeListView()
                    end
                end
            end
        end
    else
        if self.listdata then
            if #self.listdata > 0 then
                for j= 1,#self.listdata do
                    if self.listdata[j] == Const.NOTICE_TYPE.MAIL then
                        table.remove(self.listdata,j)
                        self:updateNoticeListView()
                    end
                end
            end
        end     
    end
end

function LayerNotice:onNoticeItemClicked(pSender)
    local ctype = pSender.ctype
    if ctype == Const.NOTICE_TYPE.GROUP_APPLY or ctype == Const.NOTICE_TYPE.GROUP_INVITE  then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group", pdata = { type = ctype }})
    elseif ctype == Const.NOTICE_TYPE.TRADE then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = NetClient.mTradeInviter.."请求交易，是否同意？",
            confirmTitle = "是", cancelTitle = "否",
            confirmCallBack = function ()
                NetClient:AgreeTradeInvite(NetClient.mTradeInviter)
            end
        }
        EventDispatcher:dispatchEvent(param)
    elseif ctype == Const.NOTICE_TYPE.MAIL then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_mail", pdata = { type = ctype }})
    elseif ctype == Const.NOTICE_TYPE.HPMP then
        self.showHpType = false
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag",  pdata = {tag = 4}})
    elseif ctype == Const.NOTICE_TYPE.YABIAO then
        NetClient:PushLuaTable("npc.biaoshi.onGetJsonData",util.encode({actionid="find_biaoche"}))
    elseif ctype == Const.NOTICE_TYPE.STRENGTH then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_strengthen"})
    end
    table.remove(self.listdata,pSender.index)
    self:updateNoticeListView()
end

function LayerNotice:updateNoticeListView()
    self.noticeListView:removeAllItems()
    for i = 1, #self.listdata do
        local ctype = self.listdata[i]
        local listItem = self.srcNoticeListItem:clone():show()
        if ctype == Const.NOTICE_TYPE.GROUP_APPLY or ctype == Const.NOTICE_TYPE.GROUP_INVITE then
            listItem:getWidgetByName("Button_group"):loadTextures("zudui.png","","",UI_TEX_TYPE_PLIST)
        elseif ctype == Const.NOTICE_TYPE.TRADE then
            --listItem:getWidgetByName("Label_iconname"):setString(Const.str_notice_trade)
        elseif ctype == Const.NOTICE_TYPE.MAIL then
            listItem:getWidgetByName("Button_group"):loadTextures("youjiantixing.png","","",UI_TEX_TYPE_PLIST)
        elseif ctype == Const.NOTICE_TYPE.HPMP then
            self.showHpType = true
            listItem:getWidgetByName("Button_group"):loadTextures("yaoshuibuzu.png","","",UI_TEX_TYPE_PLIST)
        elseif ctype == Const.NOTICE_TYPE.YABIAO then
            listItem:getWidgetByName("Button_group"):loadTextures("biaoche.png","","",UI_TEX_TYPE_PLIST)
        elseif ctype == Const.NOTICE_TYPE.STRENGTH then
            listItem:getWidgetByName("Button_group"):loadTextures("woyaobianqiang.png","","",UI_TEX_TYPE_PLIST)
        end
        local btn = listItem:getWidgetByName("Button_group")
        btn:addClickEventListener(function(pSender)  self:onNoticeItemClicked(pSender) end)
        btn.ctype = ctype
        btn.index = i
        self.noticeListView:pushBackCustomItem(listItem)
    end
    self.noticeListView:setVisible(#self.listdata > 0)
end

function LayerNotice:handleUpdateNotice(event)
    local uitype = event.uitype
    self.noticeListView:show()
    for i = 1, #self.listdata do
        if self.listdata[i] == uitype then
            return
        end
    end

    self.listdata[#self.listdata + 1] = uitype
    self:updateNoticeListView()
end

function LayerNotice:handleHpMpChange(event)
    if not event.param then return end
    local pro = event.param.hp_pro or 0
    --[[
    self.hpBtn:setVisible(pro < 0.5)
    if pro < 0.5 then
        UIButtonGuide.setCarryShopGuide()
    end
    ]]
    if pro < 0.5 and self:CheckMedicineNUM() == 0 then
        if self.showHpType then return end
        local insertType = false
        if #self.listdata > 0 then
            for j= 1,#self.listdata do
                if self.listdata[j] == Const.NOTICE_TYPE.HPMP then
                    insertType = true
                end
            end
        end
        if not insertType then
            self.listdata[#self.listdata + 1] = Const.NOTICE_TYPE.HPMP
            self:updateNoticeListView()
            UIButtonGuide.setCarryShopGuide()
        end
    else
        if not self.showHpType then return end
        if #self.listdata > 0 then
            for j= 1,#self.listdata do
                if self.listdata[j] == Const.NOTICE_TYPE.HPMP then
                    table.remove(self.listdata,j)
                    self.showHpType = false
                    self:updateNoticeListView()
                end
            end
        end
    end
end

function LayerNotice:handleYaBiaoChange(event)
    if event and event.type == "dart_away" then
        --self.ybBtn:show()
        local insertType = false
        if #self.listdata > 0 then
            for j= 1,#self.listdata do
                if self.listdata[j] == Const.NOTICE_TYPE.YABIAO then
                    insertType = true
                end
            end
        end
        if not insertType then
            self.listdata[#self.listdata + 1] = Const.NOTICE_TYPE.YABIAO
            self:updateNoticeListView()
        end
    elseif event and event.type == "dart_near" then
        if #self.listdata > 0 then
            for j= 1,#self.listdata do
                if self.listdata[j] == Const.NOTICE_TYPE.YABIAO then
                    table.remove(self.listdata,j)
                    self:updateNoticeListView()
                end
            end
        end
        --self.ybBtn:hide()
    end
end

function LayerNotice:onEnter()
    self:registeEvent()
end

return LayerNotice