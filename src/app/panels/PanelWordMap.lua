--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/04 17:34
-- To change this template use File | Settings | File Templates.
--

local PanelWordMap = {}
local var = {}

function PanelWordMap.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelWordMap/UI_WordMap_BG.csb")
    widget:addTo(params.parent, params.zorder)

    var.widget = widget:getChildByName("Panel_mapboard")
    var.mainRole = CCGhostManager:getMainAvatar()
    PanelWordMap.initWidget()
    PanelWordMap.showMap()
    PanelWordMap.initList()
    PanelWordMap.registeEvent()
    return var.widget
end

function PanelWordMap.initWidget()
    var.leftPanel = var.widget:getChildByName("Image_left")
    var.rightPanel = var.widget:getChildByName("Image_right")

end

function PanelWordMap.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_POS_CHANGE, PanelWordMap.handlePosChange)
end

function PanelWordMap.initList()
    var.srcNpcItem = var.rightPanel:getWidgetByName("Image_listitem"):hide()

    local rb = UIRadioButtonGroup.new()
    :addButton(var.rightPanel:getWidgetByName("btn_right_npc"))
    :addButton(var.rightPanel:getWidgetByName("btn_right_map"))
    :onButtonSelectChanged(function(event)
        PanelWordMap.updateListViewByTag(event.selected)
    end)
    for i = 1, rb:getButtonsCount() do
        rb:getButtonAtIndex(i):getTitleRenderer():setPositionY(17)
    end
    rb:setButtonSelected(1)
end

function PanelWordMap.showMap()
    var.miniMapLayer = require("app.layers.LayerMinMap").new({})
    local origSize = var.miniMapLayer:getContentSize()
    local bgPanel = var.widget:getWidgetByName("Panel_res_bg")
    local bgSize = bgPanel:getContentSize()
    local scalWidth = bgSize.width/origSize.width
    local scaleHeight = bgSize.height/origSize.height
    if scaleHeight >= 1 and scalWidth >= 1 then
        -- 不做任何缩放
    else
        var.miniMapLayer:setScale(math.min(scaleHeight, scalWidth))
    end
    var.miniMapLayer:align(display.CENTER, bgSize.width/2, bgSize.height/2)
    bgPanel:addChild(var.miniMapLayer)
    PanelWordMap.handlePosChange()
end

function PanelWordMap.handlePosChange()
    var.leftPanel:getWidgetByName("Text_pos"):setString(string.format("(x.%d y.%d)",var.mainRole:PAttr(Const.AVATAR_X), var.mainRole:PAttr(Const.AVATAR_Y)))
end

function PanelWordMap.updateListViewByTag(tag)
    local listdata = {}
    if tag == 1 then
        listdata = var.miniMapLayer:getNPCList()
    elseif tag == 2 then
        listdata = var.miniMapLayer:getConnList()
    end
    local listView = var.rightPanel:getWidgetByName("ListView_npclist")
    listView:removeAllItems()

    local function npcBtnClicedEvent(pSender)
        if not game.checkBtnClick() then return end
        local cfg = listdata[pSender.index]
        local btnName = pSender:getName()
        if btnName == "Button_NPC" then
            MainRole.startAutoMoveToMap(tag==1 and cfg.mMapID or cfg.mDesMapID,tag == 1 and cfg.mX or cfg.mDesX,tag == 1 and cfg.mY or cfg.mDesY,tag == 1 and 2 or 0)
        elseif btnName == "Button_Directfly" then
            if tag == 1 then NetClient:DirectFly(cfg.mDirectFlyID) end
        end
        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_wordmap"})
    end


    for k, v in ipairs(listdata) do
        local listItem = var.srcNpcItem:clone()
        listItem:show()
        local btnNpc = listItem:getWidgetByName("Button_NPC")
        btnNpc:setTitleText(tag==1 and v.mNpcName or v.mDesMapName)
        btnNpc.index = k
        btnNpc:addClickEventListener(npcBtnClicedEvent)

        local btnDirectFly = listItem:getWidgetByName("Button_Directfly")
        btnDirectFly:setVisible(tag==1)
        btnDirectFly.index = k
        btnDirectFly:addClickEventListener(npcBtnClicedEvent)

        listView:pushBackCustomItem(listItem)
    end
end
--
--function PanelWordMap.showRightList()
--    -- NPC 怪物
--    local function npcBtnClicedEvent(pSender)
--        if not game.checkBtnClick() then return end
--        local btnName = pSender:getName()
--        local miniMapNpc = pSender.npcCfg
--        if btnName == "Button_NPC" then
--            var.mainRole:startAutoMoveToPos(miniMapNpc.mX,miniMapNpc.mY,2)
--        elseif btnName == "Button_Directfly" then
--            NetClient:DirectFly(miniMapNpc.mDirectFlyID)
--        end
--        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_wordmap"})
--    end
--    local listView = var.widget:getWidgetByName("ListView_npclist")
--    print("var.miniNpcList====", var.miniNpcList)
--    for i = 1, #var.miniNpcList do
--        local nmmn = var.miniNpcList[i]
--        local listItem = var.srcNpcItem:clone()
--        listItem:getWidgetByName("Text_name"):setString(game.clearNumStr(nmmn.mNpcName))
--        listItem:show()
--        listView:pushBackCustomItem(listItem)
--        local btnNpc = listItem:getWidgetByName("Button_NPC")
--        btnNpc.npcCfg = nmmn
--        btnNpc:addClickEventListener(npcBtnClicedEvent)
--        local btnDirectFly = listItem:getWidgetByName("Button_Directfly")
--        btnDirectFly.npcCfg = nmmn
--        btnDirectFly:addClickEventListener(npcBtnClicedEvent)
--
--        if string.find(nmmn.mNpcName,"Lv:") then
--            listItem:getWidgetByName("Text_name"):setColor(cc.c3b(255, 0, 0))
--        end
--    end
--
--    -- 传送门
--    local function conBtnClicedEvent(pSender)
--        if not game.checkBtnClick() then return end
--        local btnName = pSender:getName()
--        local connCfig = pSender.connCfg
--        if btnName == "Button_NPC" then
--            var.mainRole:startAutoMoveToPos(connCfig.mFromX,connCfig.mFromY,0)
--        elseif btnName == "Button_Directfly" then
--            NetClient:DirectFly(connCfig.mDirectFlyID)
--        end
--        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_wordmap"})
--    end
--    for i = 1, #var.miniNpcConnList do
--        local nmc = var.miniNpcConnList[i]
--        local listItem = var.srcNpcItem:clone()
--        listItem:getWidgetByName("Text_name"):setString("传送门："..nmc.mDesMapName)
--        listItem:show()
--        listView:pushBackCustomItem(listItem)
--        local btnNpc = listItem:getWidgetByName("Button_NPC")
--        btnNpc.connCfg = nmc
--        btnNpc:addClickEventListener(conBtnClicedEvent)
--        local btnDirectFly = listItem:getWidgetByName("Button_Directfly"):hide()
--        btnDirectFly.connCfg = nmc
--        btnDirectFly:addClickEventListener(conBtnClicedEvent)
--    end
--end

return PanelWordMap