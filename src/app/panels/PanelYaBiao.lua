local PanelYaBiao = {}
local var = {}
function PanelYaBiao.initView(params)
    local params = params or {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelYaBiao/PanelYaBiao.csb")
    widget:addTo(params.parent, params.zorder)
    var.selectTab = 1
    var.mYabiaoData = {}
    var.widget = widget:getChildByName("Panel_yabiao")
    var.buyitemType = false
    PanelYaBiao.registeEvent()
    NetClient:PushLuaTable("npc.biaoshi.onGetJsonData",util.encode({actionid = "openPanel"}))

    return var.widget
end


function PanelYaBiao.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
        :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelYaBiao.handlePanelData)
        :addEventListener(Notify.EVENT_ITEM_CHANGE, PanelYaBiao.freshYBL)
        :addEventListener(Notify.EVENT_MAP_LEAVE, PanelYaBiao.handleMapLeave)
end

function PanelYaBiao.handleMapLeave()
    EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_yabiao"})
end

function PanelYaBiao.freshYBL(event)
    if event and event.pos then
        local tempItem = NetClient:getNetItem(event.pos)
        if tempItem then
            if tempItem.mTypeID == var.mYabiaoData.lpid and var.mYabiaoData then
                local have_num = NetClient:getBagItemNumberById(var.mYabiaoData.lpid)
                for i=1,4 do
                    local biaoche_data = var.mYabiaoData.bc_data[i]
                    local biaocheWidget = var.widget:getWidgetByName("biaoche_bg_"..i)
                    biaocheWidget:getWidgetByName("text_need_lingpai"):setString(have_num.."/"..biaoche_data.need_num)
                end
                PanelYaBiao.updateYbLing()
            end
        end
        if var.buyitemType then
            NetClient:PushLuaTable("npc.biaoshi.onGetJsonData",util.encode({actionid = var.yabiaocmok..var.selectTab}))
            var.buyitemType = false
        end
    end
end

function PanelYaBiao.updateYbLing()
    if var.mYabiaoData and var.mYabiaoData.lpid then
        var.widget:getWidgetByName("text_left_ybitem"):setString(NetClient:getBagItemNumberById(var.mYabiaoData.lpid))
    end
end

function PanelYaBiao.handlePanelData(event)
    if event and event.type == "yabiao_data" then
        local yabiao_data = json.decode(event.data)
        var.yabiaocmok = yabiao_data.cmok
        if not yabiao_data then return end
        var.mYabiaoData = yabiao_data
        PanelYaBiao.updateYbLing()
        for i=1,4 do
            local biaocheWidget = var.widget:getWidgetByName("biaoche_bg_"..i)
            biaocheWidget:addClickEventListener(function (pSender)
                PanelYaBiao.hideAllHigh()
                pSender:getWidgetByName("Image_high"):show()
                var.selectTab = tonumber(string.sub(pSender:getName(),12))
            end)
            local biaoche_data = yabiao_data.bc_data[i]
            biaocheWidget:getWidgetByName("biaoche_name"):setString(biaoche_data.name)
            local have_num = NetClient:getBagItemNumberById(biaoche_data.needitemid)
            biaocheWidget:getWidgetByName("text_need_lingpai"):setString(have_num.."/"..biaoche_data.need_num)
            biaocheWidget:getWidgetByName("Image_high"):hide()
            if biaoche_data.cur_quality == i then
                var.selectTab = i
                biaocheWidget:getWidgetByName("Image_high"):show()
            end
            for j=1,#biaoche_data.reward do
                if j <= #biaoche_data.reward then
                    UIItem.getSimpleItem({
                        parent = biaocheWidget:getWidgetByName("item_bg_"..j),
                        name = biaoche_data.reward[j].name,
                        num = biaoche_data.reward[j].num,
                        itemCallBack = function () end,
                    })
                else
                    biaocheWidget:getWidgetByName("item_bg_"..j):hide()
                end
            end
        end
        var.widget:getWidgetByName("text_left_count"):setString(yabiao_data.dqyabiao.."/"..yabiao_data.maxnum):setTextColor(yabiao_data.dqyabiao>0 and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
        var.widget:getWidgetByName("Button_go"):addClickEventListener(function (pSender)
            PanelYaBiao.startYB()
        end)
        var.widget:getWidgetByName("Button_buy_lp"):addClickEventListener(function (pSender)
            PanelYaBiao.startBuy()
        end)
    end
end

function PanelYaBiao.hideAllHigh( ... )
    for i=1,4 do
        local biaocheWidget = var.widget:getWidgetByName("biaoche_bg_"..i)
        biaocheWidget:getWidgetByName("Image_high"):hide()
    end
end

function PanelYaBiao.startYB()
--    运镖次数判断
    if var.mYabiaoData.dqyabiao == 0 then
        local myVipLevel = game.getVipLevel()
        local opened,lv = game.checkVipOpened("dart")
        if not opened then
            local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "成为VIP"..lv.."可增加押镖次数",
                confirmTitle = "充 值", cancelTitle = "取 消",
                confirmCallBack = function ()
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
                end
            }
            NetClient:dispatchEvent(param)
            return
        elseif myVipLevel < lv then
            local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "提升VIP可增加押镖次数",
                confirmTitle = "充 值", cancelTitle = "取 消",
                confirmCallBack = function ()
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
                end
            }
            NetClient:dispatchEvent(param)
            return
        end
        NetClient:alertLocalMsg("今日押镖次数已用完","alert")
        return
    end

    local needlpnum = tonumber(var.mYabiaoData.bc_data[var.selectTab].need_num)
    local lpnum = NetClient:getBagItemNumberById(var.mYabiaoData.lpid)
    if lpnum >= needlpnum then
        NetClient:PushLuaTable("npc.biaoshi.onGetJsonData",util.encode({actionid = var.mYabiaoData.cmok..var.selectTab}))
        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_yabiao"})
    else
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否使用"..var.mYabiaoData.lpprice.."*"..(needlpnum-lpnum).."绑定元宝购买押镖令",
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function ()
                var.buyitemType = true
                NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({
                    actionid = "quickbuy",
                    typeid=var.mYabiaoData.lpid,
                    subtype=var.mYabiaoData.lpsubtype,
                    num=needlpnum-lpnum,
                    buytype=var.mYabiaoData.lpbuyflag
                }))
                --NetClient:PushLuaTable("npc.biaoshi.onGetJsonData",util.encode({actionid = var.mYabiaoData.cmok..var.selectTab}))
                EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_yabiao"})
            end
        }
        NetClient:dispatchEvent(param)
    end
end

function PanelYaBiao.startBuy()
    local param = {
        name = Notify.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
        itemid = var.mYabiaoData.lpid,itemprice = var.mYabiaoData.lpprice,itemnum = 1,
        itembuyflag = var.mYabiaoData.lpbuyflag,itembindflag = var.mYabiaoData.lpbindflag,
        confirmTitle = "购 买", cancelTitle = "取 消",
        confirmCallBack = function (num)
        -- 购买令牌
            NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({
                actionid = "quickbuy",
                typeid=var.mYabiaoData.lpid,
                subtype=var.mYabiaoData.lpsubtype,
                num=num,
                buytype=var.mYabiaoData.lpbuyflag
            }))
        end
    }
    NetClient:dispatchEvent(param)
end

function PanelYaBiao.onPanelClose( ... )
    if var.curWidget then
        var.curWidget = nil
    end
end

return PanelYaBiao