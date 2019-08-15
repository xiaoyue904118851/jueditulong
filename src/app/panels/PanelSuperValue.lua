--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelAwardHall

local PanelSuperValue = {}
local var = {}
local ACTIONSET_NAME = "favorablebuy"
local RESTABEL = {
    [1] = "chaozhizhuangbeilibao.jpg",
    [2] = "kuaisuchengzhanglibao.jpg",
    [3] = "aoshiqunxionglibao.jpg",
    [4] = "zhizunwangzhelibao.jpg",
    [5] = "junlintianxialibao.jpg",
    [6] = "weiwoduzunlibao.jpg",
}

local STATUS_NOT_DRAW=0;        --不可领取
local STATUS_CAN_DRAW=1;        --可领取
local STATUS_ALREADY_DRAWGIFT=2;    --已领奖

 

function PanelSuperValue.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0
    var.params = nil

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSuperValue/UI_Supervalue_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_supervalue")
    

    var.listView = var.widget:getWidgetByName("ListView_leftlist")
    var.listItem = var.widget:getWidgetByName("Button_left"):hide()
    var.awardList = var.widget:getWidgetByName("ListView_awardlist")
    var.awardItem = var.widget:getWidgetByName("Image_item"):hide()
    var.image = var.widget:getWidgetByName("Image_list")

    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="querybaseinfo",param = ""}))

    --PanelStrengthen.addMenuTabClickEvent()
    var.selectTab = 1
    var.showType = false
    PanelSuperValue:sortData()
    var.widget:getWidgetByName("Button_gocharge")
    :addClickEventListener(function (pSender)
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_mall",  pdata = {tag = 3}})
        end)
    var.getBtn = var.widget:getWidgetByName("Button_get")
    var.getBtn:addClickEventListener(function (pSender)
            print("")
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="drawgift",param = {idx = var.selectTab}}))
        end)

    var.btnLabel = var.widget:getWidgetByName("Label_getname")

    PanelSuperValue.registeEvent()
    return var.widget
end

function PanelSuperValue.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelSuperValue.handleDataMsg) 
end

function PanelSuperValue.handleDataMsg(event)
    if event.type == nil then return end
    if event.type ~= ACTIONSET_NAME then return end
    local d = util.decode(event.data)
    if not d.actionid then return end
    if d.actionid == "querybaseinfo" then
        --var.infodata = d.param
        
    elseif d.actionid == "querygiftflag" then
        var.awardinfo = {}
        var.awardinfo = d.param
        
        PanelSuperValue.updateBottombtn(var.selectTab)
    end
end

function PanelSuperValue.updateLeftbtn()
    var.listView:removeAllItems()
    local Btnarry = {}
    for i = 1,#var.infodata do
        local data = var.infodata[i]
        local listItem = var.listItem:clone():show()
        Btnarry[i] = listItem:getWidgetByName("Button_left")
        listItem:getWidgetByName("Label_btnname"):setString(data.name)
        var.listView:pushBackCustomItem(listItem)
    end

    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    for i= 1,#Btnarry do
        UIRadioButtonGroup:addButton(Btnarry[i])
            :onButtonSelectChanged(function(event)
                PanelSuperValue.updateLeftInfo(event.selected)
                var.selectTab = event.selected
            end) 
    end
    UIRadioButtonGroup:setButtonSelected(var.selectTab)
end

function PanelSuperValue.updateBottombtn(index)
    if not var.awardinfo then return end
    local data = var.awardinfo.flag[index]
    if data.btnflag == STATUS_CAN_DRAW then
        var.getBtn:setTouchEnabled(true)
        :setBright(true)
        var.btnLabel:setString("立即领取")
        var.btnLabel:setColor(cc.c3b(225, 172, 8))
    elseif data.btnflag == STATUS_ALREADY_DRAWGIFT then
        var.getBtn:setTouchEnabled(false)
        :setBright(false)
        var.btnLabel:setString("已领奖")
        var.btnLabel:setColor(Const.COLOR_GRAY_1_C3B)
    end
end

function PanelSuperValue.updateLeftInfo(tag)
    var.awardList:removeAllItems()
    
    for i = 1,#var.infodata[tag].award do
        local data = var.infodata[tag].award[i]
        local listItem = var.awardItem:clone():show()
         UIItem.getSimpleItem({
            parent = listItem:getWidgetByName("Image_item"),
            typeId = data.typeid,
            level =  data.upgradelv,
        })
        local itemimage = listItem:getWidgetByName("Image_item")
        if data.num > 1 then
            local numtips = ccui.Text:create(data.num, Const.DEFAULT_FONT_NAME, 20)
                :align(display.CENTER_BOTTOM,itemimage:getContentSize().width/2, 0)
                :addTo(itemimage)
                numtips:setColor(Const.COLOR_GREEN_1_C3B)
        end
        var.awardList:pushBackCustomItem(listItem)
    end
   var.image:loadTexture("uilayout/image/supervalue/"..RESTABEL[tag],UI_TEX_TYPE_LOCAL)
   PanelSuperValue.updateBottombtn(tag)
end

function PanelSuperValue.sortData()
    local job = game.getRoleJob()
    if not game.GetMainNetGhost() then return end
    local gender = game.GetMainNetGhost():NetAttr(Const.net_gender)
    var.infodata = {}
    for i= 1,#ChaozhiDefData do
        var.infodata[i] = {}
        var.infodata[i].name = ChaozhiDefData[i].name
        var.infodata[i].price = ChaozhiDefData[i].price
        var.infodata[i].award = ChaozhiDefData[i].down[tostring(gender)][tostring(job)]
    end
    PanelSuperValue.updateLeftbtn()
end

return PanelSuperValue