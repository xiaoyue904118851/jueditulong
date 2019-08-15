--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/14 11:33
-- To change this template use File | Settings | File Templates.
--

local MallListView = {}
local var = {}

local MALL_TOP_TAG = {
    COIN_HOT = 1,
    COIN_EXP = 2,
    COIN_STRENGTHEN = 3,
    COIN_OTHERS = 4,
    BIND_COINT = 5,
    LIQUAN = 6,
}

-- fenye = 0 取所有的是热卖的 其它的则取对应的分页值即可
local SHOP_CFG = {
    [MALL_TOP_TAG.COIN_HOT] = {btnname="Button_coin_hot",pageid = 0, fenye = 0},
    [MALL_TOP_TAG.COIN_EXP] = {btnname="Button_coin_exp",pageid = 0, fenye = 1,},
    [MALL_TOP_TAG.COIN_STRENGTHEN] = {btnname="Button_coin_Strengthen",pageid = 0, fenye = 2,},
    [MALL_TOP_TAG.COIN_OTHERS] = {btnname="Button_coin_Others",pageid = 0, fenye = 3,},
    [MALL_TOP_TAG.BIND_COINT] = {btnname="Button_bind_coin",pageid = 1, fenye = 0},
    [MALL_TOP_TAG.LIQUAN] = {btnname="Button_liquan",pageid = 2, fenye = 0},
}
--（0金币1元宝2绑定元宝3绑定金币4通用元宝5通用金币9礼券10跨服积分）
local SHOP_PRICE_ICON = {
    [0] = "img_money.png",
    [1] = "img_vcoin.png",
    [2] = "img_vbind.png",
    [3] = "img_money_bind.png",
    [9] = "img_liquan.png",
}


local MALL_PRICE_TYPE_TO_BUY_PANEL = {
    [0] = 3,
    [1] = 0,
    [2] = 1,
    [3] = 4,
    [9] = 11,
}

function MallListView.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = MALL_TOP_TAG.COIN_HOT
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelMall/UI_Mall_List.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_malllist")
    var.listView = {}
    var.listData = {}
    for i = 1, MALL_TOP_TAG.LIQUAN do
        var.listView[i] = var.widget:getWidgetByName("ListView_malllist_"..i):hide()
        var.listData[i] = {}
    end

    var.srcListItem = var.widget:getWidgetByName("Panel_list_item"):hide()
    MallListView.addTopMenuTabClickEvent()
    MallListView.registeEvent()
    return widget
end

function MallListView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_NET_NPC_SHOP, MallListView.handleNpcShopMsg)
end

function MallListView.addTopMenuTabClickEvent()
    var.topMenuBtn = UIRadioButtonGroup.new()
    for _, cfg in ipairs(SHOP_CFG) do
        var.topMenuBtn:addButton(var.widget:getWidgetByName(cfg.btnname))
    end
    var.topMenuBtn:onButtonSelectChanged(function(event)
        MallListView.onTopMenuClicked(event.selected)
    end)
    var.topMenuBtn:setButtonSelected(var.selectTab)
end

function MallListView.onTopMenuClicked(topTag)
    var.topTag = topTag
    for i = 1, var.topMenuBtn:getButtonsCount() do
        var.topMenuBtn:getButtonAtIndex(i):getTitleRenderer():setPositionY(i==topTag and 20 or 17)
        var.listView[i]:hide()
    end

    var.curPage = SHOP_CFG[var.topTag].pageid
    if #var.listView[var.topTag]:getItems() == 0 then
        if not NetClient.mVcoinShopNpcID or NetClient.mVcoinShopNpcID == -1 then
            var.listView[var.topTag]:removeAllItems()
            NetClient:VcoinShopList(var.curPage,0)
            return
        end

        if not NetClient.mNpcShopInfo[NetClient.mVcoinShopNpcID] or not NetClient.mNpcShopInfo[NetClient.mVcoinShopNpcID][var.curPage] then
            var.listView[var.topTag]:removeAllItems()
            NetClient:VcoinShopList(var.curPage,0)
            return
        end
        MallListView.updateListView()
    else
        var.listView[var.topTag]:show()
    end
end

function MallListView.handleNpcShopMsg()
    if not NetClient.mVcoinShopNpcID or NetClient.mVcoinShopNpcID == -1 then
        return
    end
    if NetClient.mShopNpc.srcid ~= NetClient.mVcoinShopNpcID then
        return
    end
    if NetClient.mShopNpc.page ~= var.curPage then
        return
    end
    MallListView.updateListView()
end

function MallListView.updateListView()
    var.listView[var.topTag]:removeAllItems()
    var.listView[var.topTag]:show()
    var.listView[var.topTag]:setTouchEnabled(false)
    local srcList = NetClient.mNpcShopInfo[NetClient.mVcoinShopNpcID][var.curPage]
    if not srcList then return end

    var.listData[var.topTag] = {}
    local fenye = SHOP_CFG[var.topTag].fenye
    for _, v in ipairs(srcList) do
        if fenye == 0 then
            if v.hotsale == 1 then
                table.insert(var.listData[var.topTag],v)
            end
        elseif fenye == v.prop then
            table.insert(var.listData[var.topTag],v)
        end
    end

    UIGridView.new({
        parent = var.widget,
        async = true,
        list = var.listView[var.topTag],
        gridCount = #var.listData[var.topTag],
        cellSize = cc.size(var.listView[var.topTag]:getContentSize().width,var.srcListItem:getContentSize().height),
        columns = 3,
        initGridListener = MallListView.addMallGridItem
    })

    var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.CallFunc:create(function()
        var.listView[var.topTag]:setTouchEnabled(true)
    end)))
    
end

function MallListView.addMallGridItem(gridWidget, index)
    local sellinfo = var.listData[var.topTag][index]
    if not sellinfo then return end
    local itemDef = NetClient:getItemDefByID(sellinfo.type_id)
    if not itemDef then return end

    local widget = var.srcListItem:clone():show()
    :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)

    widget:getWidgetByName("name"):setString(itemDef.mName)
    UIItem.getSimpleItem({
        parent = widget:getWidgetByName("item_bg"),
        typeId = sellinfo.type_id,
    })
    widget:getWidgetByName("Button_buy").index = index
    widget:getWidgetByName("Button_buy"):addClickEventListener(function(pSender)
        local psellinfo = var.listData[var.topTag][pSender.index]
        if not psellinfo then return end
        var.buyinfo = psellinfo
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
            itemid = var.buyinfo.type_id,itemprice = var.buyinfo.oldprice,itemnum = 1,
            itembuyflag = MALL_PRICE_TYPE_TO_BUY_PANEL[var.buyinfo.price_type],itembindflag = 0,
            confirmTitle = "购 买", cancelTitle = "取 消",
            confirmCallBack = function (num)
                MallListView.onBuyBtnClicked(num)
            end
        }
        NetClient:dispatchEvent(param)
    end)
    widget:getWidgetByName("Text_price"):setString(sellinfo.price)
    widget:getWidgetByName("Image_money_type"):ignoreContentAdaptWithSize(true)
    widget:getWidgetByName("Image_money_type"):loadTexture(SHOP_PRICE_ICON[sellinfo.price_type],UI_TEX_TYPE_PLIST)
end

function MallListView.onBuyBtnClicked(buy_num)
    if not var.buyinfo then return end

    if buy_num >= 1000 then
        NetClient:alertLocalMsg("背包格子可能不够啦！","alert")
        return
    end

    local price = var.buyinfo.price
    if var.buyinfo.oldprice > 0 then
        price = var.buyinfo.oldprice
    end

    local cost = buy_num * price
    local checkOk = false


    if var.buyinfo.price_type == 2 then -- 绑定元宝
        if NetClient.mCharacter.mVCoinBind < cost then
            NetClient:alertLocalMsg("绑定元宝不足"..cost.."！","alert")
            return
        end
        checkOk = true
    end

    if var.buyinfo.price_type == 9 then -- 礼券
        if NetClient.mCharacter.mLiquan < cost then
            NetClient:alertLocalMsg("礼券不足"..cost.."！","alert")
            return
        end
    end

--    if not checkOk then
--        return
--    end
    print("cost == ",cost)
    NetClient:VcoinShopBuy(var.buyinfo.page, var.buyinfo.pos, var.buyinfo.good_id, var.buyinfo.type_id, buy_num)
end

return MallListView