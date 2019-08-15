--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/08/18 18:14
-- To change this template use File | Settings | File Templates.
--
local ACTIONSET_NAME = "relive"
local LayerRelive = class("LayerRelive", function()
    return ccui.Layout:create()
end)

function LayerRelive:ctor()
    self:enableNodeEvents()

    self.colorBg = ccui.ImageView:create("uilayout/image/maskbg.png",UI_TEX_TYPE_LOCAL)
    self.colorBg:setOpacity(200)
    self.colorBg:setScale9Enabled(true)
    self.colorBg:setCascadeOpacityEnabled(false)
    self.colorBg:setContentSize(cc.size(Const.VISIBLE_WIDTH, Const.VISIBLE_HEIGHT))
    self.colorBg:setTouchEnabled(true)
    self.colorBg:align(display.CENTER, display.cx, display.cy)
    self.colorBg:addTo(self)

    self.colorBg:hide()
end

function LayerRelive:onEnter()
    self:registeEvent()
end

function LayerRelive:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_PANEL_RELIVE, handler(self, self.handlePanelRelive))
    :addEventListener(Notify.EVENT_LUA_PANEL_RELIVE, handler(self, self.handleLuaPanelRelive))
    --:addEventListener(Notify.EVENT_RELIVE_USEITEM, handler(self, self.handleUseItemRelive))
end
--[[
function LayerRelive:handleUseItemRelive(event)
    if not event then return end
    if self.standLive and event.id == Const.RELIVE_USE_ITEM.id then
        if NetClient:getBagItemNumberById(event.id) >= self.Rneednum then
            self:closeRelivePanel()
            NetClient:Relive(101)
        end
    end
end
]]

function LayerRelive:handleLuaPanelRelive(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == ACTIONSET_NAME then
        if d.actionid then
            if d.actionid == "relive_data" and d.param then
                self:updateRelveItemInfo(d.param.have_num or 0,d.param.need_num or 0)
            end
        end
    end
end

function LayerRelive:updateRelveItemInfo(havanum,neednum)
    if not self.widget or not self.standLive then return end
    local msg = havanum..game.make_str_with_color(Const.COLOR_GREEN_1_STR, "/"..neednum)
    --self.parent = nil
    if not self.parent then
        self.needlabel = self.widget:getWidgetByName("Text_item_need_num")
        self.havelabel = self.widget:getWidgetByName("Text_item_have_num")
    end
    self.havelabel:setString(havanum)
    self.needlabel:setPositionX(self.havelabel:getPositionX()+self.havelabel:getContentSize().width)
    self.needlabel:setString("/"..neednum)
    --[[
    local richLabel, richWidget = util.newRichLabel(cc.size(self.parent:getContentSize().width, 0), 0)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, msg, "", 24, Const.COLOR_WHITE_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    self.parent:addChild(richWidget)
    ]]
    self.widget:getWidgetByName("Button_relive").haveitem=havanum
    self.widget:getWidgetByName("Button_relive").needitem=neednum
    self.Rneednum = neednum
end

function LayerRelive:closeRelivePanel()
    self.standLive = false
    self.colorBg:removeAllChildren()
    self.colorBg:hide()
    self.widget = nil
end

function LayerRelive:handlePanelRelive(event)
    if not event then return end

    self:closeRelivePanel()

    if not event.visible then
        return
    end

    self.delay = event.delay
    if self.delay < 0 then self.delay = 0 end

    local reliveWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelRelive.csb"):addTo(self.colorBg)
    reliveWidget:setScale(Const.minScale)
    display.align(reliveWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = reliveWidget:getChildByName("Panel_relive")
    panelWidget:setTouchEnabled(true)
    self.widget = panelWidget
    self.standLive = false

    local function homeBtnClicedEvent(pSender)
        self:closeRelivePanel()
        NetClient:Relive(100)
    end

    local function aliveBtnClicedEvent(pSender)
        if pSender.relivecount <= 0 and pSender.haveitem < pSender.needitem then
            --[[
            local data ={}
            data.typeid = Const.RELIVE_USE_ITEM.id
            data.sellyb = Const.RELIVE_USE_ITEM.sellyb
            data.priceflag = Const.RELIVE_USE_ITEM.priceflag
            data.bindflag = Const.RELIVE_USE_ITEM.bindflag or 0
            game.showQuickByPanel(data)
            ]]
            NetClient:dispatchEvent( {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
                itemid = Const.RELIVE_USE_ITEM.id,itemprice = Const.RELIVE_USE_ITEM.sellyb,itemnum = pSender.needitem,
                itembuyflag = Const.RELIVE_USE_ITEM.priceflag-1,itembindflag = Const.RELIVE_USE_ITEM.bindflag,countTime = self.delay,
                confirmTitle = "购 买", cancelTitle = "取 消",
                confirmCallBack = function (num,typeid)
                    NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({actionid="new_quickbuy", param={itemid=typeid,num=num}}))
                end
            })
            NetClient:alertLocalMsg("没有原地复活次数,请前往商城购买九转还魂丹","alert")
        else
            if pSender.haveitem >= pSender.needitem then
                self:closeRelivePanel()
                NetClient:Relive(101)
            end
        end
    end
    panelWidget:getWidgetByName("Text_time"):setString(DateHelper.getCurTime())

    local parent = panelWidget:getWidgetByName("Text_msg")
    local richLabel, richWidget = util.newRichLabel(cc.size(parent:getContentSize().width, 0), 0)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, event.msg or "您已死亡,请选择复活方式", "", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    richWidget:setPosition(cc.p(parent:getContentSize().width/2-richLabel:getRealWidth()/2, parent:getContentSize().height-richLabel:getRealHeight()))
    parent:addChild(richWidget)

    local relivecount = event.relivecount or 0
    local btnHome= panelWidget:getWidgetByName("Button_gohome")
    btnHome:addClickEventListener(homeBtnClicedEvent)

    local btnAlive = panelWidget:getWidgetByName("Button_relive")
--    if event.autoalive then
----        自动原地复活 只显示一个回城复活按钮 不显示九转
--        btnAlive:setVisible(false)
--        btnHome:setPositionY(209)
--        panelWidget:getWidgetByName("Text_time_tip"):setString("秒后自动原地复活")
--        panelWidget:getWidgetByName("Text_item_1"):hide()
--        panelWidget:getWidgetByName("Text_item_2"):hide()
--    elseif event.flag == 1 then
----        回城复活 原地复活两种
----        btnAlive:setTitleText("原地复活("..relivecount.."次)")
--        self.standLive = true
--        btnAlive.relivecount=relivecount
--        btnAlive:addClickEventListener(aliveBtnClicedEvent)
--        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="relive_data"}))
--    else
----    只有 回城复活，没有原地复活
--        panelWidget:getWidgetByName("Text_item_1"):hide()
--        panelWidget:getWidgetByName("Text_item_2"):hide()
--        btnAlive:setVisible(false)
--        btnHome:setPositionY(209)
--    end

    if event.flag == 100 then
--        两个按钮都不显示
        panelWidget:getWidgetByName("Text_item_1"):hide()
        panelWidget:getWidgetByName("Text_item_2"):hide()
        btnHome:setTouchEnabled(false)
        btnHome:setBright(false)
        panelWidget:getWidgetByName("Text_time_tip"):setString("秒后自动原地复活")
    elseif event.flag == 101 then
--        免费自动原地复活 只显示一个回城复活按钮 不显示九转还魂丹
        btnAlive:setVisible(false)
        btnHome:setPositionY(209)
        panelWidget:getWidgetByName("Text_time_tip"):setString("秒后自动原地复活")
        panelWidget:getWidgetByName("Text_item_1"):hide()
        panelWidget:getWidgetByName("Text_item_2"):hide()
    elseif event.flag == 1 then
--        回城复活 原地复活两种
        self.standLive = true
        btnAlive.relivecount=relivecount
        btnAlive:addClickEventListener(aliveBtnClicedEvent)
        panelWidget:getWidgetByName("Text_time_tip"):setString("秒后自动回城复活")
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="relive_data"}))
    else
        --    只有 回城复活，没有原地复活
        btnAlive:setVisible(false)
        btnHome:setPositionY(209)
        panelWidget:getWidgetByName("Text_item_1"):hide()
        panelWidget:getWidgetByName("Text_item_2"):hide()
    end


    local countdownLabel = panelWidget:getWidgetByName("Text_countdown")
    countdownLabel:setString(self.delay)
    if self.delay > 0 then
        countdownLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function(pSender)
                self.delay = self.delay - 1
                if self.delay < 0 then
                    pSender:stopAllActions()
                    if not event.autoalive then homeBtnClicedEvent() end
                else
                    pSender:setString(self.delay)
                end
            end)
        )))
    else
        countdownLabel:hide()
        panelWidget:getWidgetByName("Text_time_tip"):hide()
    end

    self.colorBg:setVisible(true)
end

return LayerRelive