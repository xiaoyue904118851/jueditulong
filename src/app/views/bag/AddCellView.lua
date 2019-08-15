--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/12/20 13:57
-- To change this template use File | Settings | File Templates.
--

local AddCellView = {}
local var = {}

local SLOT_TYPE = {
    WAREHOUSE = 1,
    BAG = 2,
}

function AddCellView.initView(params)
    local params = params or {}
    var = {}
    var.type = params.type or SLOT_TYPE.BAG
    var.list = params.list or {}
    var.num = 1
    var.rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelBag/UI_Bag_AddCell.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = var.rootWidget:getChildByName("Panel_addcell")
    var.costLabel = var.widget:getWidgetByName("Text_cost")
    var.subLabel = var.widget:getWidgetByName("Text_cost_2")

    if var.type == SLOT_TYPE.WAREHOUSE  then
        var.widget:getWidgetByName("Text_msg"):setString("请确定要扩增的仓库格子数量")
        var.widget:getWidgetByName("Text_cost_1_0"):hide()
        var.widget:getWidgetByName("Text_cost_3_0"):hide()
        var.subLabel:hide()
    end

    AddCellView.addBtnClickedEvent()
    AddCellView.registeEvent()
    if #var.list == 0 then
        var.rootWidget:hide()
        NetClient:PushLuaTable("gui.PanelBag.onPanelData",util.encode({actionid = "getInfo"}))
    else
        var.rootWidget:show()
        AddCellView.updateCost()
    end
    return var.rootWidget
end

function AddCellView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, AddCellView.handleBagMsg)
end

function AddCellView.handleBagMsg(event)
    if event.type == nil or event.type ~= "PanelBag" then return end
    local d = util.decode(event.data)
    local type = d.cmd
    if type == "getInfo" then
        if var.type == SLOT_TYPE.BAG then
            var.list = d.list or {}
        elseif var.type == SLOT_TYPE.WAREHOUSE  then
            var.list = d.cklist or {}
        end
        if #var.list == 0 then return end
        var.rootWidget:show()
        AddCellView.updateCost()
    end
end

function AddCellView.addBtnClickedEvent()
    local butnames = {"Button_confirm", "Button_concel", "Button_sub", "Button_add" }
    local variable = 0
    local count = 0

    local input_bg = var.widget:getWidgetByName("Image_inputbg")
    local buyNumLabel = ccui.Text:create(str, Const.DEFAULT_FONT_NAME, 24)
    :align(display.CENTER, input_bg:getContentSize().width/2, input_bg:getContentSize().height/2)
    :setString(var.num)
    :addTo(input_bg)

    local maxAdd = 0
    if var.type == SLOT_TYPE.WAREHOUSE  then
        maxAdd =  NetClient.mDepotMaxSlot - NetClient.mDepotSlotAdd
    elseif var.type == SLOT_TYPE.BAG then
        maxAdd = NetClient.mBagMaxSlot - NetClient.mBagSlotAdd
    end

    local function changeNumber(increment)
        local num = var.num
        if increment then
            if num and num > 0 and num <= maxAdd then
                num = num + increment
                if num == 0 then num = 1 end
                if num > maxAdd then num = maxAdd end
                var.num = num
                buyNumLabel:setString(num)
                AddCellView.updateCost()
            end
        end
    end

    local function update(pSender)
        count = count + 1
        if count > 10 and count < 999 then
            changeNumber(variable)
        elseif count >= 999 then
            pSender:stopAllActions()
        end
    end


    local function btnCallBack(pSender,touchType)

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
            if btnName == "Button_confirm" then
                AddCellView.onConfirm()
            elseif btnName =="Button_concel" then
                var.rootWidget:removeFromParent()
            elseif btnName =="Button_sub" then
                changeNumber(-1)
            elseif btnName == "Button_add" then
                changeNumber(1)
            end
        end
    end


    for i = 1, #butnames do
        var.widget:getWidgetByName(butnames[i]):addTouchEventListener(function ( pSender,eventType )
            btnCallBack(pSender,eventType)
        end)
    end
end

function AddCellView.updateCost()
    if var.type == SLOT_TYPE.WAREHOUSE  then
        local cost = var.num * var.list[1]
        var.costLabel:setString(cost)
    elseif var.type == SLOT_TYPE.BAG  then
        local startIdx = NetClient.mBagSlotAdd + 1
        local endIdx = math.min(NetClient.mBagSlotAdd + var.num, #var.list)

        local cost = 0
        for i = startIdx, endIdx do
            cost = cost + var.list[i]
        end

        local numOfDikoujuan =  NetClient:getBagItemNumberById(10870) * 10
        cost = cost - numOfDikoujuan
        cost = math.max(cost, 0)

        var.subLabel:setString(numOfDikoujuan)
        var.costLabel:setString(cost)
    end
end

function AddCellView.onConfirm()
    local cost = checkint(var.costLabel:getString())
    if cost > NetClient.mCharacter.mVCoin then
        NetClient:alertLocalMsg("您的元宝不足"..cost,"alert")
        return
    end

    local addNum = var.num

    if var.type == SLOT_TYPE.WAREHOUSE  then
        NetClient:PushLuaTable("gui.PanelBag.onPanelData",util.encode({actionid = "addCkSlot", num = addNum}))
    elseif var.type == SLOT_TYPE.BAG then
        NetClient:PushLuaTable("gui.PanelBag.onPanelData",util.encode({actionid = "addSlot", num = addNum}))
    end

    var.rootWidget:removeFromParent()
end

return AddCellView