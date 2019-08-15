--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/25 16:54
-- To change this template use File | Settings | File Templates.
--
local ACTIONSET_NAME = "bag"
local PanelBag = {}

local MAX_RECYCLE_NUM = 80

local var = {}

local PANEL_TYPE = {
    TIPS = 1,
    HUISHOU = 2,
    CANGKU = 3,
    SHOP = 4,
}
--
local CARRY_SHOP_PRICE_TYPE = {
    [0] = {name="img_money.png"},
    [1] = {name="img_vcoin.png"},
    [2] = {name="img_vbind.png"},
    [3] = {name="img_money_bind.png"},
}


local HUISHOU_SETTING = {
    [1] = {
        {text = "100级以下", lv = 100},
        {text = "80级以下", lv = 80},
        {text = "60级以下", lv = 60},
        {text = "50级以下", lv = 50},
        {text = "3转以下", zslv = 3},
    },
    [2] = {
        {text = "通用职业", job = 0},
        {text = "战士", job = Const.JOB_ZS},
        {text = "法师", job = Const.JOB_FS},
        {text = "道士", job = Const.JOB_DS},
    },
    [3] = {
        {text = "白色品质", color = 1},
        {text = "绿色品质", color = 2},
        {text = "蓝色品质", color = 3},
        {text = "紫色品质", color = 4},
        {text = "橙色品质", color = 5},
        {text = "红色品质", color = 6},
    },
    [4] = {
        {text = "通用装备", sex = 0},
        {text = "男性装备", sex = Const.SEX_MALE},
        {text = "女性装备", sex = Const.SEX_FEMALE},
    },
}

local CARRY_SHOP_BUY_MAX = 10
local CARRY_SHOP_PAGE = 1
local LEFT_ROWS = 4
local LEFT_COLUMNS = 6
local LEFT_PAGE_COUNT = 5
local CANGKU_PAGE_COUNT = 6

function PanelBag.initView(params)
    local params = params or {}
    PanelBag.initVar()

    local selectTab
    if params.extend and params.extend.pdata and params.extend.pdata.tag then
        selectTab = params.extend.pdata.tag
    end

    if selectTab == PANEL_TYPE.TIPS or selectTab == PANEL_TYPE.SHOP then
        var.leftselectTab = 1
        if selectTab == PANEL_TYPE.SHOP then
            var.shopType = true
        end
    elseif selectTab == PANEL_TYPE.HUISHOU then
        var.leftselectTab = PANEL_TYPE.HUISHOU
    elseif selectTab == PANEL_TYPE.CANGKU then
        var.leftselectTab = 3
    end
    if not var.leftselectTab then
        var.leftselectTab = 1
    end

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelBag/UI_Bag_New_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_bag")

    PanelBag.initPanel()
    PanelBag.updateGameMoney()
    PanelBag.updateBagSlot()
    var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
        PanelBag.initPageView()
        PanelBag.addBtnClickEvent()
        PanelBag.switchRightPanel(var.leftselectTab)
    end)))
    PanelBag.registeEvent()


    --    NetClient:PushLuaTable("gui.PanelBag.onPanelData",util.encode({actionid = "getInfo"}))

    return var.widget
end

function PanelBag.initVar()
    var = {
        allList = {},
        listViewTag = 0,
        cd = 0,
        selectShopIndex = 1,
        selectTab = PANEL_TYPE.TIPS,
        initFlag = {}
    }
end

function PanelBag.initPanel()
    var.leftPanel = var.widget:getWidgetByName("Image_left")
    var.rightPanel = var.widget:getWidgetByName("Image_right")
    var.sortCDLabel = var.leftPanel:getWidgetByName("Text_CD"):hide()
    var.nodeItemBg = var.leftPanel:getWidgetByName("item_bg"):hide()
    var.pageView = var.leftPanel:getWidgetByName("PageView_bag")
    var.pageView:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
    var.pageView:setIndicatorPosition(cc.p(var.pageView:getContentSize().width/2, 5))
    var.pageView:setIndicatorSpaceBetweenIndexNodes(10)

    var.rightPanels = {}
    var.rightPanels[PANEL_TYPE.TIPS] = var.rightPanel:getWidgetByName("Panel_tips"):hide()
    var.rightPanels[PANEL_TYPE.CANGKU] = var.rightPanel:getWidgetByName("Panel_cangku"):hide()
    var.rightPanels[PANEL_TYPE.HUISHOU] = var.rightPanel:getWidgetByName("Panel_huishou"):hide()
    var.shopPanels = var.widget:getWidgetByName("Panel_shop"):hide()

    var.operatePanel = var.widget:getWidgetByName("Panel_operate"):hide()

    var.huishouTijianPanel = {}
    var.huishouTijianPanel[1] = var.widget:getWidgetByName("Panel_huishou_lv"):hide()
    var.huishouTijianPanel[2] = var.widget:getWidgetByName("Panel_huishou_job"):hide()
    var.huishouTijianPanel[3] = var.widget:getWidgetByName("Panel_huishou_color"):hide()
    var.huishouTijianPanel[4] = var.widget:getWidgetByName("Panel_huishou_sex"):hide()
end

function PanelBag.initTipPanel()
    if var.initFlag[PANEL_TYPE.TIPS] then return end
    var.initFlag[PANEL_TYPE.TIPS] = true
end

function PanelBag.initCkPanel()
    if var.initFlag[PANEL_TYPE.CANGKU] then return end
    var.initFlag[PANEL_TYPE.CANGKU] = true
    local panel = var.rightPanels[PANEL_TYPE.CANGKU]
    var.ckpageView = panel:getWidgetByName("PageView_ck")
    var.ckpageView:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
    var.ckpageView:setIndicatorPosition(cc.p(CANGKU_PAGE_COUNT*25/2, 5))
    var.ckpageView:setIndicatorSpaceBetweenIndexNodes(1)
    panel:getWidgetByName("Button_ck_zhengli"):addClickEventListener(function(pSender)
        PanelBag.onCkSort()
    end)
end

function PanelBag.initHuishouPanel()
    if var.initFlag[PANEL_TYPE.HUISHOU] then return end
    var.initFlag[PANEL_TYPE.HUISHOU] = true
    local panel = var.rightPanels[PANEL_TYPE.HUISHOU]

    panel:getWidgetByName("Button_do_huishou")
    :setZOrder(100)
    :addClickEventListener(function(pSender)
        PanelBag.onBtnCLicked(pSender)
    end)

    var.huishouTijian = {}
    var.huishouTijian[1] = panel:getWidgetByName("Image_lv"):hide()
    var.huishouTijian[2] = panel:getWidgetByName("Image_job"):hide()
    var.huishouTijian[3] = panel:getWidgetByName("Image_color"):hide()
    var.huishouTijian[4] = panel:getWidgetByName("Image_sex"):hide()

    for k, v in ipairs(var.huishouTijianPanel) do
        v.index = k
        local copybtn = v:getWidgetByName("Button_item"):hide()

        local hs = HUISHOU_SETTING[k]
        local py = copybtn:getPositionY()
        for i = 1, #hs do
            local btn = copybtn:clone():show()
            --btn:setTitleText(hs[i].text)
            btn:getWidgetByName("Text_label"):setString(hs[i].text)
            btn.index = i
            btn.typeindex = k
            btn:setPositionY(py)
            btn:addClickEventListener(function (pSender)
                --print("TZ:::sender::",pSender.index)
                NetClient.mHuishouSetting[pSender.typeindex]=pSender.index
                PanelBag.onHuishouSetting()
                pSender:getParent():hide()
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = "recycle_equip", actionid = "save_recycle_setting", params = table.concat(NetClient.mHuishouSetting, ",")}))
            end)
            btn:addTo(v)
            py = py - 32
        end

        v:addClickEventListener(function (pSender)
            pSender:hide()
        --            var.huishouTijian[pSender.index]:getWidgetByName("Text_name"):show()
        end)
    end

    --var.huishouListView = panel:getWidgetByName("ListView_huishou")
    var.huishouAwardText = {}
    var.huishouAwardText[1] = panel:getWidgetByName("Text_huishou_exp"):hide()
    var.huishouAwardText[2] = panel:getWidgetByName("Text_huishou_clip"):hide()
    var.huishouAwardText[3] = panel:getWidgetByName("Text_huishou_gold"):hide()

end

function PanelBag.initShopPanel()
    if var.initFlag[PANEL_TYPE.SHOP] then return end
    var.initFlag[PANEL_TYPE.SHOP] = true
    local panel = var.shopPanels
    var.carryshoplistView = panel:getWidgetByName("ListView_shop")
    var.carryshopNode = panel:getWidgetByName("Button_shop_sel"):hide()
    var.buyNumLabel = panel:getWidgetByName("Label_buynum")
    var.buyNumLabel.count = 0
    var.buyNumLabel.variable = 0

    panel:getWidgetByName("Button_buy"):addClickEventListener(function(pSender)
        UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.CARRYSHOP})
        PanelBag.onShopBuy()
    end)

    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.CARRYSHOP) then
        UIButtonGuide.addGuideTip(panel:getWidgetByName("Button_buy"),"点击购买按钮")
    else
        UIButtonGuide.handleButtonGuideClicked(panel:getWidgetByName("Button_buy"))
    end

    panel:getWidgetByName("Button_jian"):addClickEventListener(function(pSender)
        PanelBag.onShopOpClicked(pSender)
    end)

    panel:getWidgetByName("Button_jia"):addClickEventListener(function(pSender)
        PanelBag.onShopOpClicked(pSender)
    end)

    panel:getWidgetByName("Button_max"):addClickEventListener(function(pSender)
        PanelBag.goMax()
    end)
end

function PanelBag.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_GAME_MONEY_CHANGE, PanelBag.updateGameMoney)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelBag.handleBagMsg)
    :addEventListener(Notify.EVENT_UPDATE_BAG_SLOT,PanelBag.handleUpdateBagSlot)
    :addEventListener(Notify.EVENT_ITEM_CHANGE,PanelBag.onItemChange)
    :addEventListener(Notify.EVENT_ITEM_PANEL_FRESH,PanelBag.onRreshPanel)
    :addEventListener(Notify.EVENT_PUSH_CARRYSHOP_DATA, PanelBag.handleCarryShopMsg)
    :addEventListener(Notify.EVENT_BUTTON_GUILD_SHOW, PanelBag.handleAddGuideTip)
    :addEventListener(Notify.EVENT_VIP_LEVEL_CHANGE, PanelBag.handleVIPChange)
end

function PanelBag.handleAddGuideTip()
    UIButtonGuide.addGuideTip(var.rightPanels[PANEL_TYPE.HUISHOU]:getWidgetByName("Button_do_huishou"),UIButtonGuide.getGuideTips(UIButtonGuide.GUILDTYPE.RE_EQUIP),UIButtonGuide.UI_TYPE_TOP)
    var.rightPanels[PANEL_TYPE.HUISHOU]:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
        PanelBag.doRecovery()
        if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.RE_EQUIP) then
            UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.RE_EQUIP})
            EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_bag"})
        end
    end)))
end

function PanelBag.switchRightPanel(type)
    --if type == nil or var.selectTab == type then
    if type == nil then
        type = PANEL_TYPE.TIPS
    end

    for i = 1, #var.rightPanels do
        var.rightPanels[i]:setVisible( i == type)
    end
    var.rightPanels[type]:setVisible(true)
    var.selectTab = type
    if var.selectTab == PANEL_TYPE.TIPS then
        PanelBag.initTipPanel()
        var.widget:getWidgetByName("panel_left_bag"):show()
        var.widget:getWidgetByName("panel_left_huishou"):hide()
        var.widget:getWidgetByName("panel_left_cangku"):hide()
        local spos = PanelBag.getSelectPos()
        if spos then
            PanelBag.onLeftItemSelected(spos)
        else
            var.rightPanels[PANEL_TYPE.TIPS]:hide()
        end
        if var.shopType then
            var.shopPanels:show()
            PanelBag.initShopPanel()
            var.shopType = false 
            if not var.getShopMsg then
                var.getShopMsg = true
                NetClient:ReqCarryShop(CARRY_SHOP_PAGE)
                return
            end
        end
    elseif var.selectTab == PANEL_TYPE.SHOP then
        PanelBag.initShopPanel()
        if not var.getShopMsg then
            var.getShopMsg = true
            NetClient:ReqCarryShop(CARRY_SHOP_PAGE)
            return
        end
    elseif var.selectTab == PANEL_TYPE.CANGKU then
        PanelBag.initCkPanel()
        PanelBag.hideAllLeftHigh()
        var.widget:getWidgetByName("panel_left_bag"):hide()
        var.widget:getWidgetByName("panel_left_huishou"):hide()
        var.widget:getWidgetByName("panel_left_cangku"):show()
        if not NetClient.mGotCKList then
            NetClient.mGotCKList = true
            NetClient:reqListItem(Const.ITEM_DEPOT_BEGIN, Const.ITEM_DEPOT_BEGIN + Const.ITEM_DEPOT_SIZE + NetClient.mDepotMaxSlot)
        end
        if not var.initCkPageView then
            var.initCkPageView = true
            var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                PanelBag.updateCkPageView()
            end)))

            
        end
    elseif var.selectTab == PANEL_TYPE.HUISHOU then
        var.widget:getWidgetByName("panel_left_bag"):hide()
        var.widget:getWidgetByName("panel_left_huishou"):show()
        var.widget:getWidgetByName("panel_left_cangku"):hide()
        PanelBag.hideAllLeftHigh()
        PanelBag.initHuishouPanel()
        PanelBag.updateHuishouPanel()
    end
end

function PanelBag.initPageView()
    var.pageView:removeAllPages()
    --print("TZ:::::::::initPageView--------------:",os.clock())
    local ostime = os.clock()
    var.gridPageView = UIGridPageView.new({
        pv = var.pageView,
        parent = var.widget,
        count = LEFT_ROWS*LEFT_COLUMNS*LEFT_PAGE_COUNT,
        --count = LEFT_ROWS*LEFT_COLUMNS,
        --count = LEFT_ROWS,
        padding = {left = 0, right = 0, top = 0, bottom = 30},
        row = LEFT_ROWS,
        column = LEFT_COLUMNS,
        initGridListener = PanelBag.showGridItem
    })
    --print("TZ:::::::::initPageView--------------23:",os.clock()-ostime)
    if UIRedPoint.checkOpenBagSlot() == 1 then
        -- 找出最新的一格所在的page
        local pageIndex = math.floor((Const.ITEM_BAG_SIZE+NetClient.mBagSlotAdd+1)/(LEFT_ROWS*LEFT_COLUMNS))
        var.pageView:jumpToItem(pageIndex, cc.p(0, 0), cc.p(0, 0))
    end
end

function PanelBag.updatePageView()
    print("====PanelBag.updatePageView")
    PanelBag.updateBagSlot()

    if var.selectLeftPos and not NetClient:getNetItem(var.selectLeftPos) then
        PanelBag.hideAllLeftHigh()
        if var.selectTab == PANEL_TYPE.TIPS then
            local spos = PanelBag.getSelectPos()
            if spos then
                PanelBag.onLeftItemSelected(spos)
            else
                var.rightPanels[PANEL_TYPE.TIPS]:hide()
            end
        end
    end
end

function PanelBag.onRreshPanel(event)
    var.sortFlag = false
    if event.panelid == Const.SORT_FLAG.BAG then
        PanelBag.updatePageView()
    elseif event.panelid == Const.SORT_FLAG.CANGKU then
        --PanelBag.updateWarehouseSlot()
        PanelBag.updateCkPageView()
    else
        PanelBag.updateBagSlot()
        PanelBag.updateWarehouseSlot()
    end
end

function PanelBag.onItemChange(event)
    local position = event.pos
    if not position then return end

    if not game.IsPosInBag(position) and not game.IsPosInDepot(position) then
        return
    end
    
    local netItem = NetClient:getNetItem(position)
    if netItem and event.oldType and event.oldType == netItem.mTypeID then
        -- 只是数量的变化
        if var.selectTab == PANEL_TYPE.TIPS then
            if var.selectLeftPos == position then
                PanelBag.updateTipPanel(netItem)
            end
        end
        return
    end

    -- 变换道具
    if var.selectTab == PANEL_TYPE.TIPS then
        if var.selectLeftPos == position then
            if netItem then
                PanelBag.updateTipPanel(netItem)
            else
                local spos = PanelBag.getSelectPos()
                if spos then
                    PanelBag.onLeftItemSelected(spos)
                    -- 找出最新的一格所在的page
                    local pageIndex = math.floor((spos+1)/(LEFT_ROWS*LEFT_COLUMNS))
                    var.pageView:jumpToItem(pageIndex, cc.p(0, 0), cc.p(0, 0))
                else
                    var.rightPanels[PANEL_TYPE.TIPS]:hide()
                end
            end
        end
    end
end

function PanelBag.handleBagMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == ACTIONSET_NAME then
        if d.actionid then
            if d.actionid == "load_recycle_setting" then
                PanelBag.onHuishouSetting()
            elseif d.actionid == "recyle_success" then
                var.recycle_tem_tab = {}
                var.recycle_xiyounum = 0
                PanelBag.updateHuishouListView()
            end
        end
    end
end

function PanelBag.addBtnClickEvent()
    --local btnNames = {"Button_show_Recovery", "Button_Shop", "Button_cangku", "Button_zhengli", "Button_onekeyuse"}
    local opened,openLevel = game.checkVipOpened("ck")
    local btnNames = {"Button_Shop","Button_zhengli", "Button_onekeyuse"}
    local leftbtnNames = {"Button_leftbag", "Button_show_Recovery", "Button_cangku"}
    if not opened then
        btnNames = {"Button_Shop","Button_zhengli", "Button_onekeyuse","Button_cangku"}
        leftbtnNames = {"Button_leftbag", "Button_show_Recovery"}
    end  
    for i = 1, #btnNames do
        var.widget:getWidgetByName(btnNames[i])
        :addClickEventListener(function(pSender)
            PanelBag.onBtnCLicked(pSender)
        end)
    end
    
    var.sortBtn = var.widget:getWidgetByName("Button_zhengli")
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    for i= 1,#leftbtnNames do
        UIRadioButtonGroup:addButton(var.widget:getWidgetByName(leftbtnNames[i]))
            :onButtonSelectChanged(function(event)                 
                PanelBag.onBtnCLicked(event.sender)       
                var.leftselectTab = event.selected
            end) 
    end

    var.widget:getWidgetByName("Button_tipsclose")
        :addClickEventListener(function(pSender)
            var.shopPanels:hide()
        end)
    UIRadioButtonGroup:setButtonSelected(var.leftselectTab)
    PanelBag.handleVIPChange()
end

function PanelBag.handleVIPChange()
    local opened,lv = game.checkVipOpened("ck")
    local color = opened and Const.COLOR_YELLOW_2_C3B or Const.COLOR_GRAY_1_C3B
    var.widget:getWidgetByName("Button_cangku"):setTitleColor(color)
end

function PanelBag.showGridItem(gridWidget, index)
    --print("TZ:::::::::showGridItem--------------:",os.clock())
    local itemBg = gridWidget:getChildByName("gridbg")
    if itemBg then
        gridWidget:removeChildByName("gridbg")
    end

    local itemBg = var.nodeItemBg:clone()
    itemBg:setName("gridbg")
    itemBg:addTo(gridWidget)
    itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    itemBg:show()

    local curbagpos = Const.ITEM_BAG_BEGIN + index - 1
    itemBg.mpos = curbagpos
    itemBg.index = index
    gridWidget.pos = curbagpos
    if game.IsPosInBag(curbagpos) then
        itemBg:getWidgetByName("lock_flag"):hide()
        UIItem.getItem({
            parent = itemBg,
            pos = curbagpos,
            showSelectEffect = true,
            itemCallBack = function(pSender)
                PanelBag.onLeftItemSelected(pSender.mpos)
            end
        })
    else
        local freeOpen,minLevel = game.checkBagSlotFreeOpen(index)
        if freeOpen then
            itemBg:getWidgetByName("lock_flag"):ignoreContentAdaptWithSize(true)
            itemBg:getWidgetByName("lock_flag"):loadTexture("dianjikaiqi.png",UI_TEX_TYPE_PLIST)
            itemBg:getWidgetByName("lock_flag"):show()
        else
            itemBg:getWidgetByName("lock_flag"):show()
            if minLevel and minLevel > 0 then
                local lvtips = ccui.Text:create(minLevel.."级开启", Const.DEFAULT_FONT_NAME, 20)
                :align(display.CENTER_BOTTOM,itemBg:getContentSize().width/2, 0)
                :addTo(itemBg)
                lvtips:setColor(Const.COLOR_YELLOW_1_C3B)
--                lvtips:setString(minLevel.."级开启")
            end
        end
        itemBg:setTouchEnabled(true)
        itemBg:addClickEventListener(function(pSender)
            PanelBag.onLeftSlotSelected()
        end)
    end
    --[[
    if index == LEFT_ROWS*LEFT_COLUMNS then
        var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.005), cc.CallFunc:create(function()
            var.gridPageView:initOther()
        end)))
    end
    ]]
end

function PanelBag.getSelectPos()
    if var.selectLeftPos and NetClient:getNetItem(var.selectLeftPos) then
        return var.selectLeftPos
    end

    for pos = game.getBagStartPos(), game.getBagEndPos() do
        if NetClient:getNetItem(pos) then
            return pos
        end
    end
end

function PanelBag.hideAllLeftHigh()
    for k, v in pairs(var.gridPageView:getItems()) do
        NetClient:dispatchEvent(
            {
                name = Notify.EVENT_ITEM_SELECT,
                pos = v.pos,
                visible = false
            })
    end
end

function PanelBag.onLeftSlotSelected()
    local function sendOp()
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = "op_bag",actionid="open_grid_lv_vocin"}))
    end

    local price,addnum,addexp = game.getBagSlotPrice()
    if price > 0 then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true,
            lblConfirm = {
                "是否使用"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,price).."元宝解锁"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,addnum).."个背包格子？",
                "解锁即可获得"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,addexp).."经验",
            },
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function (num)
                sendOp()
            end
        }
        NetClient:dispatchEvent(param)
    else
        sendOp()
    end
end

function PanelBag.onLeftItemSelected(position)
    print("PanelBag.onLeftItemSelected===", position, var.selectTab )
    local netItem = NetClient:getNetItem(position)
    if not netItem then return end
    if var.selectTab == PANEL_TYPE.TIPS then
        var.selectLeftPos = position
        for k, v in pairs(var.gridPageView:getItems()) do
            NetClient:dispatchEvent(
                {
                    name = Notify.EVENT_ITEM_SELECT,
                    pos = v.pos,
                    visible = v.pos == position
            })
        end
        PanelBag.updateTipPanel(netItem)
    elseif var.selectTab == PANEL_TYPE.CANGKU then
        NetClient:dispatchEvent(
            {
                name = Notify.EVENT_HANDLE_ITEM_TIPS,
                pos = position,
                typeId = netItem.mTypeID,
                toDepot = true,
            })
    elseif var.selectTab == PANEL_TYPE.HUISHOU then
        PanelBag.doLeftGoHuishou(position)
    end
end

function PanelBag.updateGameMoney()
    local mainrole = NetClient.mCharacter
    local moneyLabel = {
        {name="Label_GoldIngot",	value =	 mainrole.mVCoin or 0 },
        {name="Label_BindGoldIngot",	value =	mainrole.mVCoinBind or 0 },
        {name="Label_GoldCoin",	value =	mainrole.mGameMoney or 0 },
        {name="Label_BindGoldCoin",	value =	mainrole.mGameMoneyBind or 0 },
    }
    for _,v in ipairs(moneyLabel) do
        var.widget:getWidgetByName(v.name):setString(v.value)
    end
end

function PanelBag.updateBagSlot()
    var.leftPanel:getWidgetByName("Text_Count_Tip"):setString(NetClient:getBagCount().."/"..(Const.ITEM_BAG_SIZE + NetClient.mBagSlotAdd))
end

function PanelBag.handleUpdateBagSlot(event)
    PanelBag.updateBagSlot()
    if event.lastbag then
        for i = event.lastbag + 1, NetClient.mBagSlotAdd do
            local index = Const.ITEM_BAG_SIZE+i
--            print("ii", index)
            local gridWidget = var.gridPageView:getItem(index)
            if gridWidget and index <= var.gridPageView:getItemsCount() then
                PanelBag.showGridItem(gridWidget, index)
            end
        end
    end

    -- 找出最新的一格所在的page
    local pageIndex = math.floor((Const.ITEM_BAG_SIZE+NetClient.mBagSlotAdd)/(LEFT_ROWS*LEFT_COLUMNS))
    var.pageView:scrollToPage(pageIndex)
end

function PanelBag.onBtnCLicked(pSender)
    local btnName = pSender:getName()
    if btnName == "Button_show_Recovery" then
        PanelBag.switchRightPanel(PANEL_TYPE.HUISHOU)
        --var.pageView:scrollToPage(0)
    elseif btnName == "Button_Shop" or btnName == "Button_shop" then
        --PanelBag.switchRightPanel(PANEL_TYPE.SHOP)
        var.shopPanels:show()
        PanelBag.initShopPanel()
        if not var.getShopMsg then
            var.getShopMsg = true
            NetClient:ReqCarryShop(CARRY_SHOP_PAGE)
            return
        end
    elseif btnName == "Button_leftbag" then
        PanelBag.switchRightPanel(PANEL_TYPE.TIPS)
        --var.pageView:scrollToPage(0)
    elseif btnName == "Button_zhengli" then
        var.sortBtn = var.widget:getWidgetByName("Button_zhengli")
        PanelBag.onBtnZhengli()
        --[[
    elseif btnName == "Button_cangkuzhengli" then
        var.sortBtn = var.widget:getWidgetByName("Button_cangkuzhengli")
        PanelBag.onBtnZhengli()
    elseif btnName == "Button_huishouzl" then
        var.sortBtn = var.widget:getWidgetByName("Button_huishouzl")
        PanelBag.onBtnZhengli()
        var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
            PanelBag.onHuishouSetting(false)
        end)))
        ]]
    elseif btnName == "Button_cangku" then
        local opened,openLevel = game.checkVipOpened("ck")
        if opened then
            PanelBag.switchRightPanel(PANEL_TYPE.CANGKU)
            --var.pageView:scrollToPage(0)
        else
            NetClient:alertLocalMsg("需要VIP"..openLevel.."开启随身仓库！","alert")
        end
    elseif btnName == "Button_do_huishou" then
        PanelBag.doRecovery()
        if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.RE_EQUIP) then
            UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.RE_EQUIP})
            EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_bag"})
        end
    elseif btnName == "Button_boss" then
        if PanelBag.isVIP() then
            NetClient:ServerScript("vipjzsd")
        end
    elseif btnName == "Button_chuansong" then
        if PanelBag.isVIP() then
            NetClient:ServerScript("vipgomap")
        end
    elseif btnName == "Button_onekeyuse" then
        PanelBag.doOnekeyuse()
    end
end

function PanelBag.doOnekeyuse()
    local item_tab = {}

    for pos = game.getBagStartPos(), game.getBagEndPos() do
        local item =  NetClient:getNetItem(pos)
        if item then
            local itemdef = NetClient:getItemDefByID(item.mTypeID)
            if item and itemdef and itemdef.mOneKeyuse and  itemdef.mOneKeyuse > 0 then
                table.insert( item_tab,pos)
            end
        end
    end

    if #item_tab == 0 then
        NetClient:alertLocalMsg("没有可一键使用的道具","alert")
        return
    end
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = "bag_onekeyuse", params = item_tab}))
end

function PanelBag.doRecovery()
    if not var.recycle_tem_tab  or #var.recycle_tem_tab == 0 then
        NetClient:alertLocalMsg("没有可回收的装备和道具","alert")
        return
    elseif #var.recycle_tem_tab > MAX_RECYCLE_NUM then
        NetClient:alertLocalMsg("回收装备超过80件","alert")
        return
    end
    if var.recycle_xiyounum > 0 then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "回收列表中含有稀有装备,确定回收吗？",
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function ()
                     NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "do_recycle_item", panelid = "recycle_equip", params = var.recycle_tem_tab}))
                end
            }
        EventDispatcher:dispatchEvent(param)
    else
         NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "do_recycle_item", panelid = "recycle_equip", params = var.recycle_tem_tab}))
    end
    
   
end

function PanelBag.checkCanRecycle( id )
    local itemdef = NetClient:getItemDefByID(id)
    if itemdef then
        if itemdef.mHuishouExp > 0  or itemdef.mHuishouClip > 0 or itemdef.mHuishouGold > 0 then
            return 100
            --            if itemdef.mColor == 0 then
            --                return 100
            --            end
            --            if game.SELECT_RECOVERY[color_tab[itemdef.mColor]] > 0 then
            --                return 100
            --            end
        end
    end
    -- if resmng.xianshizhuangbei[tostring(_id)] then return 102 end
    -- if resmng.jifenwuqi[tostring(_id)] then return 101 end
    return 0
end

function PanelBag.checkRecycleItemPro(netItem)
    if not netItem then return 0 end
    if netItem.mLevel then
        if netItem.mLevel > 0 then
            return 100
        end
    end
    local itemdef = NetClient:getItemDefByID(netItem.mTypeID)
    if itemdef then
        if itemdef.mColor and itemdef.mColor > 0 then
            if game.getItemColor(itemdef.mColor) > 3 then
                return 100
            end 
        end
    end
    return 0
end

function PanelBag.isVIP()
    return true
    --    local vipLevel = game.getVipLevel()
    --    if  vipLevel > 0 then
    --        return true
    --    end
    --    return false
end

function PanelBag.onBtnZhengli()
    if var.cd > 0 then
        NetClient:alertLocalMsg("稍安勿躁","alert")
        return
    end
    if NetClient:getBagCount() <= 0 then
        NetClient:alertLocalMsg("背包为空，不需要整理","alert")
        return
    end

    PanelBag.startSortCD()
    NetClient:SortItem(Const.SORT_FLAG.BAG)
    var.sortFlag = true
end

function PanelBag.startSortCD()
    var.sortBtn:setTouchEnabled(false)
    var.sortBtn:setBright(false)
    var.cd = 6
    var.sortCDLabel:setString(var.cd)
    --var.sortCDLabel:show()

    var.sortCDLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
        var.cd = var.cd - 1
        if var.cd < 1 then
            var.sortCDLabel:hide()
            var.sortCDLabel:stopAllActions()
            var.sortBtn:setTouchEnabled(true)
            var.sortBtn:setBright(true)
            var.sortFlag = false
        else
            var.sortCDLabel:setString(var.cd)
        end
    end))))
end

--------------------------------商店 start
function PanelBag.handleCarryShopMsg(event)
    if CARRY_SHOP_PAGE ~= event.page then
        return
    end
    var.carryshoplistView:removeAllItems()
    local listData = NetClient.mCarryShopList[CARRY_SHOP_PAGE]
    if (not listData or #listData == 0 ) then
        return
    end

    UIGridView.new({
        list = var.carryshoplistView,
        gridCount = #listData,
        cellSize = cc.size(345, 115),
        columns = 1,
        initGridListener = function(gridWidget, index)
            local item = var.carryshopNode:clone():show()
            item:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
            :addTo(gridWidget)

            item:getWidgetByName("Image_high"):hide()
            local iteminfo = NetClient.mCarryShopList[CARRY_SHOP_PAGE][index]
            item:getWidgetByName("Image_price_type"):ignoreContentAdaptWithSize(true)
            item:getWidgetByName("Image_price_type"):loadTexture(CARRY_SHOP_PRICE_TYPE[iteminfo.money_type].name, UI_TEX_TYPE_PLIST)
            item:getWidgetByName("price"):setString(iteminfo.price)

            UIItem.getItem({
                parent = item:getWidgetByName("item_icon_bg"),
                typeId = iteminfo.item_id,
            })
            item:getWidgetByName("item_icon_bg"):setTouchEnabled(false)
            item:addClickEventListener(function (pSender)
                PanelBag.onSelectedShopItem(pSender.index)
            end)
            item.index = index
            local itemDef = NetClient:getItemDefByID(iteminfo.item_id)
            if itemDef then
                item:getWidgetByName("name"):setString(itemDef.mName)
            else
                item:getWidgetByName("name"):setString("")
            end
        end
    })
    PanelBag.onSelectedShopItem(var.selectShopIndex)
end

function PanelBag.onSelectedShopItem(index)
    if not index then return end
    local items = var.carryshoplistView:getItems()
    for i = 1, #items do
        items[i]:getWidgetByName("Image_high"):setVisible(i==index)
    end
    var.selectShopIndex = index
    var.buyNumLabel:setString(NetClient.mCarryShopNum[index] or 1)
end

function PanelBag.changeNumber(increment)
    local maxNum = CARRY_SHOP_BUY_MAX
    local num = checkint(var.buyNumLabel:getString())
    if increment then
        if num and num > 0 and num <= maxNum then
            num= num + increment
            if num <= 0 then
                num = 1
                var.buyNumLabel:stopAllActions()
            end
            if num > maxNum then
                num = maxNum
                var.buyNumLabel:stopAllActions()
            end
            var.buyNumLabel:setString(num)
        end
    end
end

function PanelBag.goMax()
    var.buyNumLabel:stopAllActions()
    var.buyNumLabel:setString(CARRY_SHOP_BUY_MAX)
end

function PanelBag.update()
    var.buyNumLabel.count = var.buyNumLabel.count + 1
    if count >10 and count < CARRY_SHOP_BUY_MAX then
        PanelBag.changeNumber(var.buyNumLabel.variable)
    elseif count > CARRY_SHOP_BUY_MAX then
        var.buyNumLabel:stopAllActions()
    end
end

function PanelBag.onShopOpClicked( pSender, touchType )
    local num = checkint(var.buyNumLabel:getString())
    local btnName = pSender:getName()

    if btnName =="Button_jian" then
        PanelBag.changeNumber(-1)
    elseif btnName == "Button_jia" then
        PanelBag.changeNumber(1)
    end
    -- TODO
    --
    --    if touchType == ccui.TouchEventType.began then
    --        if btnName == "Button_jian" or btnName == "Button_jia" then
    --            if btnName =="Button_jian" then var.buyNumLabel.variable = -1 end
    --            if btnName =="Button_jia" then var.buyNumLabel.variable = 1 end
    --            var.buyNumLabel.count = 0
    --            pSender:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1/60), cc.CallFunc:create(function()
    --                update(pSender)
    --            end))))
    --        end
    --    elseif touchType == ccui.TouchEventType.canceled then
    --        pSender:stopAllActions()
    --    elseif touchType == ccui.TouchEventType.ended then
    --        pSender:stopAllActions()
    --        if btnName =="Button_jian" then
    --            PanelBag.changeNumber(-1,pSender)
    --        elseif btnName == "Button_jia" then
    --            PanelBag.changeNumber(1,pSender)
    --        end
    --    end
end

function PanelBag.onShopBuy()
    local num = math.max(checkint(var.buyNumLabel:getString()), 1)
    local shopinfo = NetClient.mCarryShopList[CARRY_SHOP_PAGE][var.selectShopIndex]
    if shopinfo then
        NetClient.mCarryShopNum[var.selectShopIndex] = num
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "buy", panelid = "carryshop", params = {id = shopinfo.id, page = CARRY_SHOP_PAGE, idx = var.selectShopIndex, num = num,  fugai = 1}}))
    end

end

--------------------------------商店end

--------------------------------tips start
function PanelBag.updateTipPanel(netItem)
    local itemdef = NetClient:getItemDefByID(netItem.mTypeID)
    if not itemdef then return end

    local tipsbg = var.rightPanels[PANEL_TYPE.TIPS]:getWidgetByName("Panel_tipsbg")
    tipsbg:removeAllChildren()

    local bgSize = tipsbg:getContentSize()
    local detailBg = game.getItemTipsView({lockHeight=true,typeID=netItem.mTypeID,netItem=netItem,showScrollBg=true,addbtn=true})
    detailBg:align(display.LEFT_TOP, 0, bgSize.height)
    detailBg:addTo(tipsbg)

    var.rightPanels[PANEL_TYPE.TIPS]:show()
end
---------------------------------tips end

---------------------------------随身仓库 start
function PanelBag.updateWarehouseSlot()
    var.rightPanels[PANEL_TYPE.CANGKU]:getWidgetByName("Text_ck_count"):setString(NetClient:getDepotCount().."/"..(Const.ITEM_DEPOT_SIZE + NetClient.mDepotSlotAdd))
end

function PanelBag.updateCkPageView()
    var.allckList = {}
    for pos, netItem in pairs(NetClient.mItems) do
        if game.IsPosInDepot(pos) then
            local itemCfg = {pos = pos, netItem = netItem }
            var.allckList[pos] = itemCfg
        end
    end
    var.ckpageView:removeAllPages()
    PanelBag.updateWarehouseSlot()

    var.cangkuPageView = UIGridPageView.new({
        pv = var.ckpageView,
        parent = var.rightPanel:getWidgetByName("Panel_cangku"),
        count = 5*4*CANGKU_PAGE_COUNT,
        padding = {left = 0, right = 0, top = 0, bottom = 30},
        row = 5,
        column = 4,
        initGridListener = PanelBag.showCKGridItem
    })
end

function PanelBag.createCkPage(pindex)
    local totalW = 340
    local totallH = 420
    local rows = 5
    local columns = 4
    local rowSize = cc.size(totalW, totallH/rows)

    local pagesize = cc.size(totalW, totallH)
    local pageWidget = ccui.Widget:create()
    pageWidget:setContentSize(pagesize)

    local gridW = rowSize.width/columns
    local gridH = rowSize.height
    for rowIdx = 1, rows do
        local rowWidget = ccui.Widget:create()
        rowWidget:setContentSize(rowSize)
        rowWidget:setAnchorPoint(0, 0)
        rowWidget:setPosition(cc.p(0, totallH/rows * (rows - rowIdx)))
        rowWidget:addTo(pageWidget)

        for columnIdx = 1, columns do
            local currentCnt = (rowIdx - 1) * columns + columnIdx
            local gridWidget = ccui.Widget:create()
            gridWidget:setContentSize(cc.size(gridW, gridH))
            gridWidget:setAnchorPoint(0, 0)
            gridWidget:setPosition((columnIdx - 1) * gridW, 0)
            gridWidget:addTo(rowWidget)

            PanelBag.showCKGridItem(gridWidget, currentCnt + (pindex - 1) * rows * columns)
        end
    end
    return pageWidget
end

function PanelBag.showCKGridItem(gridWidget, index)
    local itemBg = var.nodeItemBg:clone()
    itemBg:show()
    itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    itemBg:addTo(gridWidget)

    itemBg.index = index
    local openindex = Const.ITEM_DEPOT_SIZE + NetClient.mDepotSlotAdd
    local maxindex =  Const.ITEM_DEPOT_SIZE + NetClient.mDepotMaxSlot
    if index <=  openindex then
        itemBg:getWidgetByName("lock_flag"):hide()
        local itemCfg = var.allckList[Const.ITEM_DEPOT_BEGIN + index-1]
        if itemCfg then
            UIItem.getItem({
                parent = itemBg,
                pos = itemCfg.pos,
            })
        else
            --没有东西
        end
    elseif index <= maxindex then
        itemBg:setTouchEnabled(true)
        itemBg:getWidgetByName("lock_flag"):show()
        itemBg:addClickEventListener(function(pSender)
            NetClient:alertLocalMsg("升级VIP可解锁更多的格子哦","alert")
        end)
    else
        itemBg:hide()
    end
end

function PanelBag.onCkSort()
    if table.nums(var.allckList) <= 0 then
        NetClient:alertLocalMsg("仓库为空，不需要整理","alert")
        return
    end
    if not game.checkBtnClick() then return end
    NetClient:SortItem(Const.SORT_FLAG.CANGKU)
    var.sortFlag = true
end
---------------------------------随身仓库 end

--------------------------------- 回收start
function PanelBag.updateHuishouPanel()
    if not var.initFlag[PANEL_TYPE.HUISHOU] then return end
    --var.huishouListView:removeAllItems()
    for k, v in ipairs(var.huishouAwardText) do
        v:hide()
    end


    if not NetClient.mHuishouSetting then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = "recycle_equip", actionid = "load_recycle_setting"}))
    else
        PanelBag.onHuishouSetting()
    end
end

function PanelBag.onHuishouSetting(tag)
    local needinfo = {}
    for k, v in ipairs(var.huishouTijian) do
        local tjconfig = HUISHOU_SETTING[k][checkint(NetClient.mHuishouSetting[k])]
        if tjconfig.lv then
            needinfo.lv = tjconfig.lv
        end

        if tjconfig.zslv then
            needinfo.zslv = tjconfig.zslv
        end

        if tjconfig.job then
            needinfo.job = tjconfig.job
        end

        if tjconfig.color then
            needinfo.color = tjconfig.color
        end

        if tjconfig.sex then
            needinfo.sex = tjconfig.sex
        end

        v:getWidgetByName("Text_name"):setString(tjconfig.text)
        v:setTouchEnabled(true)
        v.index = k
        v:addClickEventListener(function(pSender)
        --            var.huishouTijian[pSender.index]:getWidgetByName("Text_name"):hide()
            var.huishouTijianPanel[pSender.index]:show()
        end)
        v:show()
    end
--    print("读取回收设置", needinfo.lv, needinfo.zslv, needinfo.job, needinfo.color, needinfo.sex)
    var.recycle_tem_tab = {}
    var.recycle_xiyounum = 0
    for k, v in pairs(var.gridPageView:getItems()) do
        local item = NetClient:getNetItem(v.pos)
        if item then
            local recycle_type = PanelBag.checkCanRecycle( item.mTypeID )
            if recycle_type > 0 then
                local itemdef = NetClient:getItemDefByID(item.mTypeID)
                if PanelBag.checkRecycleCfg(netItem, itemdef, needinfo) then
                    table.insert( var.recycle_tem_tab,{pos=v.pos} )
                    NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = v.pos,
                            visible = true
                        })
                end
            end
        end
    end
    if not tag then
        PanelBag.updateHuishouListView()
    end
end

function PanelBag.checkRecycleCfg(netItem, itemdef, needinfo)
    if not needinfo then return true end

    if itemdef.mNeedType == 0 then
        local itemlv = itemdef.mNeedParam
        if needinfo.lv and itemlv  > needinfo.lv then
--            print("   11")
            return false
        end
    elseif itemdef.mNeedType == 4 then
        local itemzslv = itemdef.mNeedParam
        if needinfo.lv then return false end

        if needinfo.zslv and itemzslv > needinfo.zslv then
--            print("   12")
            return false
        end
    end

    if needinfo.sex  and needinfo.sex ~= 0 and itemdef.mSex ~= needinfo.sex then
--        print("   13", itemdef.mSex, needinfo.sex)
        return false
    end
    if needinfo.job  and needinfo.job ~= 0 and itemdef.mJob ~= needinfo.job then
--        print("   14", itemdef.mJob, needinfo.job)
        return false
    end

    if needinfo.color and itemdef.mColor and itemdef.mColor ~= 0 then
        local checkcolor = false
        if Const.Item_Def_color[needinfo.color] then
            for i = needinfo.color, 1, -1 do
                for _, vcolor in ipairs(Const.Item_Def_color[i].colors) do
                    if vcolor == itemdef.mColor then
                        checkcolor = true
                        break
                    end
                end
                if checkcolor then break end
            end
        end
        if not checkcolor then
            --                print("   15", itemdef.mColor, needinfo.color)
            return false
        end
    end

    return true
end

function PanelBag.doLeftGoHuishou(pos)
    local netItem = NetClient:getNetItem(pos)
    if not netItem then return end


    if PanelBag.checkCanRecycle( netItem.mTypeID ) <= 0 then
        NetClient:alertLocalMsg("不可回收","alert")
        return
    end

    --print("TZ::::HUISHOU",#var.recycle_tem_tab)
    if #var.recycle_tem_tab > 0 then
        for i=#var.recycle_tem_tab,1,-1 do
            if var.recycle_tem_tab[i].pos == pos then
                table.remove(var.recycle_tem_tab, i)
                if PanelBag.checkRecycleItemPro(netItem) > 0 then
                    var.recycle_xiyounum = var.recycle_xiyounum - 1
                end
                NetClient:dispatchEvent(
                    {
                        name = Notify.EVENT_ITEM_SELECT,
                        pos = pos,
                        visible = false
                    })
                PanelBag.updateHuishouListView()
                --print("TZ::::HUISHOU22",#var.recycle_tem_tab)
                return 
            end
        end
    end
    --[[
    for _, v in ipairs(var.recycle_tem_tab) do
        if v.pos == pos then
            return
        end
    end
    ]]
    if PanelBag.checkRecycleItemPro(netItem) > 0 then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "这件装备品质为稀有装备,确定回收吗？",
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function ()
                    table.insert(var.recycle_tem_tab, {pos = pos})
                    var.recycle_xiyounum = var.recycle_xiyounum + 1
                    PanelBag.updateHuishouListView()
                end
            }
        EventDispatcher:dispatchEvent(param)
    else
        table.insert(var.recycle_tem_tab, {pos = pos})
        PanelBag.updateHuishouListView()
    end
   
end

function PanelBag.updateHuishouListView()
    if not var.initFlag[PANEL_TYPE.HUISHOU] then return end
    PanelBag.hideAllLeftHigh()
    var.shouyi = {bind_gold = 0, exp = 0, clip = 0}
    for k, v in ipairs(var.huishouAwardText) do
        v:hide()
    end

    --var.huishouListView:removeAllItems()
    if #var.recycle_tem_tab == 0 then
        return
    end
    for j=1,#var.recycle_tem_tab do
        local pos = var.recycle_tem_tab[j].pos
        NetClient:dispatchEvent(
            {
                name = Notify.EVENT_ITEM_SELECT,
                pos = pos,
                visible = true
            })

        local netItem = NetClient:getNetItem(pos)
        if netItem then
            local itemdef = NetClient:getItemDefByID(netItem.mTypeID)
            if itemdef then
                if itemdef.mHuishouExp > 0  then
                    var.shouyi.exp = var.shouyi.exp + itemdef.mHuishouExp*netItem.mNumber
                end
                if itemdef.mHuishouClip > 0  then
                    var.shouyi.clip = var.shouyi.clip + itemdef.mHuishouClip*netItem.mNumber
                end
                if itemdef.mHuishouGold > 0  then
                    var.shouyi.bind_gold = var.shouyi.bind_gold + itemdef.mHuishouGold*netItem.mNumber
                end
            end
        end
    end
    --[[
    UIGridView.new({
        list = var.huishouListView,
        gridCount = #var.recycle_tem_tab,
        cellSize = cc.size(328, 80),
        columns = 4,
        initGridListener = function(gridWidget, index)
            local itemBg = var.nodeItemBg:clone():show()
            itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
            :addTo(gridWidget)
            local pos = var.recycle_tem_tab[index].pos
            itemBg:getWidgetByName("lock_flag"):hide()
            itemBg.index = index
            itemBg.pos = pos
            UIItem.getItem({
                parent = itemBg,
                pos = pos,
                itemCallBack = function(pSender)
                    print("TZZZZZZZZZZZZ::pSender",pSender.index)
                    table.remove(var.recycle_tem_tab, pSender.index)
                    NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = pSender.pos,
                            visible = false
                        })
                    PanelBag.updateHuishouListView()
                end
            })

            NetClient:dispatchEvent(
                {
                    name = Notify.EVENT_ITEM_SELECT,
                    pos = pos,
                    visible = true
                })

            local netItem = NetClient:getNetItem(pos)
            if netItem then
                local itemdef = NetClient:getItemDefByID(netItem.mTypeID)
                if itemdef then
                    if itemdef.mHuishouExp > 0  then
                        var.shouyi.exp = var.shouyi.exp + itemdef.mHuishouExp*netItem.mNumber
                    end
                    if itemdef.mHuishouClip > 0  then
                        var.shouyi.clip = var.shouyi.clip + itemdef.mHuishouClip*netItem.mNumber
                    end
                    if itemdef.mHuishouGold > 0  then
                        var.shouyi.bind_gold = var.shouyi.bind_gold + itemdef.mHuishouGold*netItem.mNumber
                    end
                end
            end
        end
    })
    ]]

    for k, v in ipairs(var.huishouAwardText) do
        v:hide()
    end

    local py = 503.00
    if var.shouyi.exp > 0 then
        var.huishouAwardText[1]:getWidgetByName("Text_value"):setString(var.shouyi.exp)
        var.huishouAwardText[1]:setPositionY(py):show()
        py = py - 25
    end
    if var.shouyi.clip > 0 then
        var.huishouAwardText[2]:getWidgetByName("Text_value"):setString(var.shouyi.clip)
        var.huishouAwardText[2]:setPositionY(py):show()
        py = py - 25
    end
    if var.shouyi.bind_gold > 0 then
        var.huishouAwardText[3]:getWidgetByName("Text_value"):setString(var.shouyi.bind_gold)
        var.huishouAwardText[3]:setPositionY(py):show()
        py = py - 25
    end
end

--------------------------------- 回收end

return PanelBag