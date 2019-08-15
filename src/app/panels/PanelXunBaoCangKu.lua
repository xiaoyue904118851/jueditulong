--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelAwardHall

local PanelXunBaoCangKu = {}
local var = {}
local ACTIONSET_NAME = "xbdepot"

local LEFT_ROWS = 5
local LEFT_COLUMNS = 6
local LEFT_PAGE_COUNT = 5
local CANGKU_PAGE_COUNT = 10
 

function PanelXunBaoCangKu.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0
    var.params = nil

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelXunBao/UI_XunBao_BAG_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_bag")
    
    --NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="querybaseinfo",param = ""}))
    --PanelStrengthen.addMenuTabClickEvent()
    var.widget:getWidgetByName("AtlasLabel_zhanli"):setString(NetClient.mCharacter.mFightPoint)
    var.widget:getWidgetByName("Button_openbag")
    :addClickEventListener(function (pSender)
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag"})
        end)
    var.itemnum = 0
    var.cunbtn = var.widget:getWidgetByName("Button_cunbag")
    var.cunbtn:addClickEventListener(function (pSender)
        local topos = NetClient:findEmptyPositionInBag()
        if not topos then
            NetClient:alertLocalMsg("背包已满","alert")
        else
            if not var.selectLeftPos then
                NetClient:alertLocalMsg("未选中物品","alert")
            else
                NetClient:ItemPositionExchange(var.selectLeftPos, topos)
                var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                    PanelXunBaoCangKu.onLeftItemSelected(PanelXunBaoCangKu.getSelectpos()) 
                end)))
            end
        end
    end)
    var.dealbtn = var.widget:getWidgetByName("Button_deal")
    var.dealbtn:addClickEventListener(function (pSender)
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="btnzlck",param = ""}))
        end)
    var.keybtn = var.widget:getWidgetByName("Button_onekey")
    var.keybtn:addClickEventListener(function (pSender)
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="btnallget",param = ""}))
            var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
                PanelXunBaoCangKu.initPageView()
                --PanelXunBaoCangKu.updateBtninfo()
            end)))
        end)

    PanelXunBaoCangKu.updateBaginfo()
    PanelXunBaoCangKu.registeEvent()

    if not NetClient.mGotXBList then
        NetClient.mGotXBList = true
        NetClient:reqListItem(Const.ITEM_LOTTERYDEPOT_BEGIN, Const.ITEM_LOTTERYDEPOT_BEGIN + Const.ITEM_LOTTERYSIZE)
        var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
            PanelXunBaoCangKu.initPageView()
            --PanelXunBaoCangKu.updateBtninfo()
        end)))
    else
        --PanelXunBaoCangKu.updateBtninfo()
        PanelXunBaoCangKu.initPageView()
    end 
    return var.widget
end

function PanelXunBaoCangKu.getSelectpos()
    local pos = Const.ITEM_LOTTERYDEPOT_BEGIN
    for i = Const.ITEM_LOTTERYDEPOT_BEGIN,Const.ITEM_LOTTERYDEPOT_BEGIN+Const.ITEM_LOTTERYSIZE do
        if NetClient:getNetItem(i) then
            return i
        end
    end
end

function PanelXunBaoCangKu.updateBaginfo()
    var.nodeItemBg = var.widget:getWidgetByName("item_bg"):hide()
    var.pageView = var.widget:getWidgetByName("PageView_bag")
    var.pageView:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
    var.pageView:setIndicatorPosition(cc.p(var.pageView:getContentSize().width/2, 5))
    var.pageView:setIndicatorSpaceBetweenIndexNodes(10)
end

function PanelXunBaoCangKu.showGridItem(gridWidget, index)
    local itemBg = gridWidget:getChildByName("gridbg")
    if itemBg then
        gridWidget:removeChildByName("gridbg")
    end

    if NetClient:getNetItem(Const.ITEM_LOTTERYDEPOT_BEGIN+index-1) then
        var.itemnum = var.itemnum + 1
    end
    local itemBg = var.nodeItemBg:clone()
    itemBg:setName("gridbg")
    itemBg:addTo(gridWidget)
    itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    itemBg:show()

    local curbagpos = Const.ITEM_LOTTERYDEPOT_BEGIN + index - 1
    itemBg.mpos = curbagpos
    itemBg.index = index
    gridWidget.pos = curbagpos
    if game.IsPosInLottery(curbagpos) then
        itemBg:getWidgetByName("lock_flag"):hide()
        UIItem.getItem({
            parent = itemBg,
            pos = curbagpos,
            showSelectEffect = true,
            itemCallBack = function(pSender)
                local netItem = NetClient:getNetItem(pSender.mpos)
                if not netItem then return end
                PanelXunBaoCangKu.onLeftItemSelected(pSender.mpos)
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
            --PanelBag.onLeftSlotSelected()
        end)
    end
end

function PanelXunBaoCangKu.initPageView()
    var.pageView:removeAllPages()
    var.itemnum = 0
    var.gridPageView = UIGridPageView.new({
        pv = var.pageView,
        parent = var.widget,
        --count = LEFT_ROWS*LEFT_COLUMNS*LEFT_PAGE_COUNT,
        count =Const.ITEM_LOTTERYSIZE,
        padding = {left = 0, right = 0, top = 0, bottom = 30},
        row = LEFT_ROWS,
        column = LEFT_COLUMNS,
        initGridListener = PanelXunBaoCangKu.showGridItem
    })


    PanelXunBaoCangKu.onLeftItemSelected(Const.ITEM_LOTTERYDEPOT_BEGIN)
end


function PanelXunBaoCangKu.onLeftItemSelected(position)
    print("PanelBag.onLeftItemSelected===", position, var.selectTab )
    local netItem = NetClient:getNetItem(position)
    PanelXunBaoCangKu.updateTipPanel(netItem)
    if not netItem then return end
    var.selectLeftPos = position
    for k, v in pairs(var.gridPageView:getItems()) do
        NetClient:dispatchEvent(
            {
                name = Notify.EVENT_ITEM_SELECT,
                pos = v.pos,
                visible = v.pos == position
        })
    end
end

function PanelXunBaoCangKu.updateTipPanel(netItem)
    if not var.tipsbg then
        var.tipsbg = var.widget:getWidgetByName("Panel_tipsbg")
    end
    var.tipsbg:removeAllChildren()
    if not netItem then return end 
    local itemdef = NetClient:getItemDefByID(netItem.mTypeID)
    if not itemdef then return end

    local bgSize = var.tipsbg:getContentSize()
    local detailBg = game.getItemTipsView({lockHeight=true,typeID=netItem.mTypeID,netItem=netItem,showScrollBg=true,addbtn=false})
    detailBg:align(display.LEFT_TOP, 0, bgSize.height)
    detailBg:addTo(var.tipsbg)
end

function PanelXunBaoCangKu.updateBtninfo()
    if var.itemnum == 0 then
        var.cunbtn:setTouchEnabled(false)
        :setBright(false)
        var.dealbtn:setTouchEnabled(false)
        :setBright(false)
        var.keybtn:setTouchEnabled(false)
        :setBright(false)
    end
end

function PanelXunBaoCangKu.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_ITEM_PANEL_FRESH, PanelXunBaoCangKu.handleDataMsg) 
end

function PanelXunBaoCangKu.handleDataMsg(event)
     PanelXunBaoCangKu.initPageView()
     PanelXunBaoCangKu.updateBtninfo()
end
return PanelXunBaoCangKu