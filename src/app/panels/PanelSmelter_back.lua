--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/28 17:44
-- To change this template use File | Settings | File Templates.
--
local SELF_POS = {
    -2 * 2, --装备里面的武器
    -3 * 2, --装备里面的战衣
    -4 * 2,--装备里面的头盔
    -5 * 2, --装备里面的戒指左
    -5* 2 - 1, --装备里面的戒指右
    -6 * 2, --装备里面的护腕左
    -6* 2 - 1, --装备里面的护腕右
    -7 * 2, --装备里面的项链
    -8 * 2, --装备里面的勋章
    -9 * 2, --装备里面的腰带
    -10 * 2, --装备里面的战靴
    -11 * 2,  -- 装备里面的魂器
    -12 * 2, -- 装备里面的翅膀
    -13 * 2, -- 时装里面的光翼
    -14 * 2,  --时装武器
    -15 * 2, --时装衣服
    -16 * 2,  --时装特戒
    -16 * 2 - 1, --时装婚戒
    -18 * 2,  --时装头饰
    -19 * 2,-- 挂饰没有
    -20 * 2,   --  时装披风
    -21 * 2, --时装护肩1
    -21 * 2 - 1, --时装护肩2
}

WUFANG      = 1 --物防
MOFANG      = 2 --魔防
WUGONG      = 3 --物攻
MOGONG      = 4 --魔攻
DAOGONG     = 5 --道攻
SHENGMING   = 6 --生命
ZHUNQUE     = 7 --准确
BAOJI       = 8 --暴击
BAOSHANG    = 9 --暴伤
BAOSHANGJM  = 10 --爆伤减免

local LOCKTAB = {
    [WUFANG] = 0,
    [MOFANG] = 0,
    [WUGONG] = 0,
    [MOGONG] = 0,
    [DAOGONG] = 0,
    [SHENGMING] = 0,
    [ZHUNQUE] = 0,
    [BAOJI] = 0,
    [BAOSHANG] = 0,
    [BAOSHANGJM] = 0
}

local PropStars = {
    [WUFANG] = {
        [1]=7,[2]=8,[3]=9,[4]=11,[5]=20,[6]=31,[7]=44,[8]=66,[9]=92,[10]=120
    },
    [MOFANG] = {
        [1]=4,[2]=5,[3]=6,[4]=7,[5]=14,[6]=22,[7]=31,[8]=46,[9]=64,[10]=84
    },
    [WUGONG] = {
        [1]=15,[2]=17,[3]=20,[4]=24,[5]=44,[6]=68,[7]=96,[8]=144,[9]=198,[10]=258
    },
    [MOGONG] = {
        [1]=15,[2]=17,[3]=20,[4]=24,[5]=44,[6]=68,[7]=96,[8]=144,[9]=198,[10]=258
    },
    [DAOGONG] = {
        [1]=15,[2]=17,[3]=20,[4]=24,[5]=44,[6]=68,[7]=96,[8]=144,[9]=198,[10]=258
    },
    [SHENGMING] = {
        [1]=40,[2]=80,[3]=120,[4]=160,[5]=220,[6]=280,[7]=340,[8]=420,[9]=500,[10]=600
    },
    [ZHUNQUE] = {
        [1]=1,[2]=2,[3]=3,[4]=4,[5]=5,[6]=6,[7]=7,[8]=8,[9]=9,[10]=10
    },
    [BAOJI] = {
        [1]=20,[2]=30,[3]=40,[4]=50,[5]=65,[6]=80,[7]=100,[8]=125,[9]=175,[10]=250
    },
    [BAOSHANG] = {
        [1]=40,[2]=60,[3]=80,[4]=100,[5]=130,[6]=160,[7]=200,[8]=250,[9]=350,[10]=500
    },
    [BAOSHANGJM] = {
        [1]=40,[2]=60,[3]=80,[4]=100,[5]=130,[6]=160,[7]=200,[8]=250,[9]=350,[10]=500
    },
}
local PanelSmelter = {}
local var = {}

local tab_right = {
    {csb = "PanelUpgrade",panel = "panel_upgrade"},
    {csb = "PanelPray",panel = "panel_pray"},
    {csb = "PanelInherit",panel = "panel_inherit"},
    {csb = "PanelRecovery",panel = "panel_recovery"},
    {csb = "PanelCompose",panel = "panel_compose"},
    {csb = "PanelSplit",panel = "panel_split"},
    {csb = "PanelUpstar",panel = "panel_upstar"},
}

local ql_info_label = {"Label_SuperAbility","Label_Ability1","Label_Ability2","Label_Ability3","Label_Ability4"}

local leftBtn = {"btn_bag_baodian","btn_bag_xuanjin","btn_bag_jiu"}

local xj_tab = {
    {id = 10142,nextid = 10143,name="一品玄晶",needVcoin = 8,needMoney=10000,needNum=3},
    {id = 10143,nextid = 10144,name="二品玄晶",needVcoin = 24,needMoney=20000,needNum=3},
    {id = 10144,nextid = 10145,name="三品玄晶",needVcoin = 73,needMoney=40000,needNum=3},
    {id = 10145,nextid = 10146,name="四品玄晶",needVcoin = 220,needMoney=80000,needNum=3},
    {id = 10146,nextid = 10147,name="五品玄晶",needVcoin = 700,needMoney=160000,needNum=3},
    {id = 10147,nextid = 10148,name="六品玄晶",needVcoin = 2400,needMoney=320000,needNum=3},
    {id = 10148,nextid = 10149,name="七品玄晶",needVcoin = 7920,needMoney=640000,needNum=3},
    {id = 10149,nextid = 10150,name="八品玄晶",needVcoin = 26136,needMoney=960000,needNum=3},
    {id = 10150,nextid = 10151,name="九品玄晶",needVcoin = 0,needMoney=1280000,needNum=3},
    {id = 10151,nextid = 10225,name="十品玄晶",needVcoin = 0,needMoney=1920000,needNum=3},
    {id = 10225,nextid = 10226,name="十一品玄晶",needVcoin = 0,needMoney=2560000,needNum=3},
    {id = 10226,nextid = nil,name="十二品玄晶",needVcoin = 0,needMoney=10000,needNum=3},
}

local baodian_tab = {
    {id = 10069,nextid = 10070,needMoney=20000,needNum=3},
    {id = 10089,nextid = 10090,needMoney=20000,needNum=3},
    {id = 10129,nextid = 10130,needMoney=20000,needNum=3},
    {id = 10070,nextid = 10071,needMoney=20000,needNum=3},
    {id = 10090,nextid = 10287,needMoney=20000,needNum=3},
    {id = 10130,nextid = 10288,needMoney=20000,needNum=3},
}

local jiu_tab = {
    {id = 10139,nextid = 10284,needMoney = 20000,needNum = 5},
    {id = 10284,nextid = 10285,needMoney = 20000,needNum = 5},
    {id = 10285,nextid = 10286,needMoney = 20000,needNum = 5},
}

function PanelSmelter.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = 1
    var.bagSelectTab = 1
    var.hcSelectTab = 1
    var.curWidget = nil
    dump(params.extend.pdata )
    if params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    end

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSmelter/PanelRonglu.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("panel_ronglu")

    var.widget:getWidgetByName("Panel_shenfu"):hide():setTouchEnabled(false):setLocalZOrder(100):addClickEventListener(function ( pSender )
        pSender:hide():setTouchEnabled(false)
    end)
    var.widget:getWidgetByName("Panel_ronghe"):hide():setTouchEnabled(false):setLocalZOrder(100):addClickEventListener(function ( pSender )
        pSender:hide():setTouchEnabled(false)
    end)

    var.widget:getWidgetByName("Button_Close_fu"):addClickEventListener(function ( pSender )
        var.widget:getWidgetByName("Panel_shenfu"):hide():setTouchEnabled(false)
    end)

    var.item_list = var.widget:getWidgetByName("item_list")

    var.fu_list = var.widget:getWidgetByName("ListView_TradeItemList")

    PanelSmelter.addMenuTabClickEvent()

    PanelSmelter.registeEvent()

    return var.widget
end

function PanelSmelter.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
        :addEventListener(Notify.EVENT_NOTIFY_GETITEMDESP, PanelSmelter.updateAllItems)
        :addEventListener(Notify.EVENT_ITEM_CHANGE, PanelSmelter.updateLeftItems)
end

function PanelSmelter.updateAllItems( event )
    if var.PageVar.pos then
        PanelSmelter.updateRightPanel(var.selectTab,var.PageVar.pos )
    end
end

function PanelSmelter.updateLeftItems( event )
    if var.selectTab ~= 5 then
        PanelSmelter.updateLeftPanel(var.bagSelectTab)
        if var.PageVar.pos then
            PanelSmelter.updateRightPanel( var.selectTab,var.PageVar.pos )
        end
        if var.PageVar.fromPos and var.PageVar.toPos then
            if var.PageVar.fromPos == event.pos then
                var.PageVar.item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                var.PageVar.target_name:setString("已强化装备"):setColor(cc.c3b(0,255,255))
                var.PageVar.fromPos = -999
                var.PageVar.cost_gold:setString(0)
            end
            if var.PageVar.toPos == event.pos then
                var.PageVar.inherit_item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                var.PageVar.inherit_name:setString("未强化装备"):setColor(cc.c3b(0,255,255))
                var.PageVar.toPos = -999
            end
        end
        if var.PageVar.recycleTab and #var.PageVar.recycleTab > 0 then
            for i=1,#var.PageVar.recycleTab do
                local item_bg = var.curWidget:getWidgetByName("right_item_bg_"..i)
                if item_bg then
                    item_bg:removeAllChildren()
                end
            end
            var.PageVar.mSoulNum = 0
            var.PageVar.mExpNum = 0
            var.PageVar.mSoulLabel:setString(var.PageVar.mSoulNum)
            var.PageVar.mExpLabel:setString(var.PageVar.mExpNum)
            var.PageVar.recycleTab = {}
        end
    else
        if var.PageVar.pos then
            PanelSmelter.updateRightPanel( var.selectTab,var.PageVar.pos )
        end
        PanelSmelter.updateLeftHCPanel(var.hcSelectTab)
    end
end

function PanelSmelter.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local RadionButtonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_EquipStrengthen"))
    :addButton(var.widget:getWidgetByName("Button_EquipPray") )
    :addButton(var.widget:getWidgetByName("Button_EquipMix") )
    :addButton(var.widget:getWidgetByName("Button_EquipRecycle"))
    :addButton(var.widget:getWidgetByName("Button_MysStoneStren"))
    :addButton(var.widget:getWidgetByName("Button_MysStoneSep"))
    :addButton(var.widget:getWidgetByName("Button_Upstar"))
    :onButtonSelectChanged(function(event)
        PanelSmelter.updatePanelByTag(event.selected)
    end)
    RadionButtonGroup:setButtonSelected(var.selectTab)

    var.leftButtonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("btn_self_equip"))
    :addButton(var.widget:getWidgetByName("btn_bag_equip") )
    :onButtonSelectChanged(function(event)
        PanelSmelter.updateLeftPanel(event.selected)
    end)
    var.leftButtonGroup:setButtonSelected(var.bagSelectTab)

    var.leftHCButtonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("btn_bag_baodian"))
    :addButton(var.widget:getWidgetByName("btn_bag_xuanjin") )
    :addButton(var.widget:getWidgetByName("btn_bag_jiu") )
    :onButtonSelectChanged(function(event)
        PanelSmelter.updateLeftHCPanel(event.selected)
    end)
end

function PanelSmelter.updatePanelByTag(tag)
    var.widget:getWidgetByName("btn_self_equip"):show():setPositionY(285)
    var.widget:getWidgetByName("btn_bag_equip"):show():setPositionY(170)
    for i=1,#leftBtn do
        var.widget:getWidgetByName(leftBtn[i]):hide()
    end
    var.selectTab = tag
    if var.curWidget then
        var.curWidget:removeFromParent()
    end
    if tab_right[tag] then
        local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSmelter/"..tab_right[tag].csb..".csb"):addTo(var.widget)
        var.curWidget = widget:getChildByName(tab_right[tag].panel)
    end
    var.PageVar = {}
    if var.selectTab == 1 then
        PanelSmelter.updateLeftPanel(var.bagSelectTab)
        var.PageVar.item_bg = var.curWidget:getWidgetByName("right_item_bg")
        var.PageVar.xj_bg = var.curWidget:getWidgetByName("right_xj_bg")
        var.PageVar.fu_bg = var.curWidget:getWidgetByName("right_fu_bg")
        var.PageVar.target_name = var.curWidget:getWidgetByName("right_target_name"):setColor(cc.c3b(255,102,255))
        var.PageVar.xj_name = var.curWidget:getWidgetByName("right_xj_name"):setColor(cc.c3b(0,255,255))
        var.PageVar.fu_name = var.curWidget:getWidgetByName("right_fu_name"):setColor(cc.c3b(0,255,255))
        var.PageVar.cost_gold = var.curWidget:getWidgetByName("Label_CostGoldCoin"):setString(0)
        var.PageVar.upd_per = var.curWidget:getWidgetByName("Label_EquipSuccessRate"):setString("0%")
        var.PageVar.check_xj =  var.curWidget:getWidgetByName("CheckBox_buy_xj"):hide():setSelected(((game.AUTOBUYUPDXJ == 1) and true) or false)
        var.PageVar.check_xj:addClickEventListener(function ( pSender )
                game.AUTOBUYUPDXJ = game.AUTOBUYUPDXJ > 0 and 0 or 1
                pSender:setSelected(((game.AUTOBUYUPDXJ == 1) and true) or false)
                PanelSmelter.updateUpdPercent()
                
            end)
        var.PageVar.check_fu = var.curWidget:getWidgetByName("CheckBox_buy_fu"):hide():setSelected(((game.AUTOBUYUPDFU == 1) and true) or false)
        var.PageVar.check_fu:addClickEventListener(function ( pSender )
                game.AUTOBUYUPDFU = game.AUTOBUYUPDFU > 0 and 0 or 1
                pSender:setSelected(((game.AUTOBUYUPDFU == 1) and true) or false)
                PanelSmelter.updateUpdPercent()
            end)
        var.curWidget:getWidgetByName("Button_sel"):addClickEventListener(function ( pSender )
                var.widget:getWidgetByName("Panel_shenfu"):show():setTouchEnabled(true)
                local pos_tab = PanelSmelter.getBagFuAllID()
                local function updateFuList( item,eventType )
                    local net_item = NetClient:getNetItem(pos_tab[item.tag])
                    if net_item then
                        local itemdef = NetClient:getItemDefByID(net_item.mTypeID)
                        if itemdef then
                            item:getWidgetByName("label_fu"):setString(itemdef.mName)
                            item:getWidgetByName("label_fu"):setColor(util.Quality2color(itemdef.mColor))
                        end
                        item:addClickEventListener(function ( pSender )
                            var.PageVar.needFuPos = net_item.position
                            PanelSmelter.updateUpdPercent()
                            var.widget:getWidgetByName("Panel_shenfu"):hide():setTouchEnabled(false)
                        end)
                        
                        UIItem.getItem({
                            parent = item:getWidgetByName("fu_item_bg"),
                            typeId = net_item.mTypeID,
                            itemCallBack = function () end
                        })
                        item:getWidgetByName("fu_item_bg"):setTouchEnabled(false)
                    end
                end
                local params = {
                    list            = var.fu_list,
                    totalLength     = math.ceil(#pos_tab),
                    updateFunc  = updateFuList,
                }
                CCRecycleList.new(params)
            end)
        var.PageVar.upd_loadbar = var.curWidget:getWidgetByName("LoadingBar_EquipSuccessRate"):setPercent(0)
        var.curWidget:getWidgetByName("Button_EquipStrenOpera"):addClickEventListener(function ( ... )
            if var.PageVar.pos then
                local need_xj_num = NetClient:getBagItemNumberById(var.PageVar.needXJ)
                if need_xj_num > 0 or game.AUTOBUYUPDXJ == 1 then
                    local fu_pos = -999
                    local xj_pos = -999
                    local pos_xj_tab = NetClient:getItemPosById(var.PageVar.needXJ)
                    if pos_xj_tab and #pos_xj_tab > 0 then xj_pos = pos_xj_tab[1] end
                    if var.PageVar.needFuPos and var.PageVar.needFuPos > 0 then
                        fu_pos = var.PageVar.needFuPos
                    end
                    PanelSmelter.runProgressBar(var.PageVar.upd_loadbar,function ( ... )
                        NetClient:PushLuaTable("gui.PanelUpgrade.onPanelData",util.encode(
                            {
                                actionid="upgrade",
                                item_pos = var.PageVar.pos,
                                xj_pos = xj_pos,
                                fu_pos = fu_pos,
                                buy_xj=game.AUTOBUYUPDXJ,
                                buy_fu=game.AUTOBUYUPDFU
                            }))
                    end)
                else
                    NetClient:alertLocalMsg("材料不足！","alert")
                end
            else
                NetClient:alertLocalMsg("请放入装备！","alert")
            end
        end)
    end
    if var.selectTab == 2 then
        PanelSmelter.updateLeftPanel(var.bagSelectTab)
        var.PageVar.item_bg = var.curWidget:getWidgetByName("right_item_bg")
        var.PageVar.xj_bg = var.curWidget:getWidgetByName("right_xj_bg")
        var.PageVar.target_name = var.curWidget:getWidgetByName("right_target_name"):setColor(cc.c3b(255,153,255))
        var.PageVar.xj_name = var.curWidget:getWidgetByName("right_xj_name"):setColor(cc.c3b(0,255,255))
        var.PageVar.check_qly =  var.curWidget:getWidgetByName("CheckBox_buy_qly"):setSelected(((game.AUTOBUYUPDQLY == 1) and true) or false)
        var.PageVar.check_qly:addClickEventListener(function ( pSender )
                game.AUTOBUYUPDQLY = game.AUTOBUYUPDQLY > 0 and 0 or 1
                pSender:setSelected(((game.AUTOBUYUPDQLY == 1) and true) or false)
                
            end)
        var.PageVar.check_fys = var.curWidget:getWidgetByName("CheckBox_buy_fys"):setSelected(((game.AUTOBUYUPDFYS == 1) and true) or false)
        var.PageVar.check_fys:addClickEventListener(function ( pSender )
                game.AUTOBUYUPDFYS = game.AUTOBUYUPDFYS > 0 and 0 or 1
                pSender:setSelected(((game.AUTOBUYUPDFYS == 1) and true) or false)
            end)
        for i=1,#ql_info_label do
            var.curWidget:getWidgetByName(ql_info_label[i]):hide()
        end
        for i=1,4 do
            var.curWidget:getWidgetByName("btn_lock_pray_"..i):hide():addClickEventListener(function ( pSender )
                if pSender.attr then
                    LOCKTAB[pSender.attr] = LOCKTAB[pSender.attr] > 0 and 0 or 1
                    pSender:setBrightStyle(LOCKTAB[pSender.attr])
                end
            end)
        end
        var.curWidget:getWidgetByName("Button_EquipPrayOpera"):addClickEventListener(function ( ... )
            if var.PageVar.pos then
                local need_qly_num = NetClient:getBagItemNumberById(var.PageVar.needQLY)
                if need_qly_num > 0 or game.AUTOBUYUPDQLY == 1 then
                    local qly_pos = -999
                    local pos_qly_tab = NetClient:getItemPosById(var.PageVar.needQLY)
                    if pos_qly_tab and #pos_qly_tab > 0 then qly_pos = pos_qly_tab[1] end
                    NetClient:PushLuaTable("gui.PanelUpgrade.onPanelData",util.encode(
                        {
                            actionid="pray",
                            item_pos = var.PageVar.pos,
                            qly_pos = qly_pos,
                            buy_qly=game.AUTOBUYUPDQLY,
                            buy_fys=game.AUTOBUYUPDFYS,
                            lock_tab = LOCKTAB
                        }))
                else
                    NetClient:alertLocalMsg("材料不足！","alert")
                end
            else
                NetClient:alertLocalMsg("请放入装备！","alert")
            end
        end)
    end
    if var.selectTab == 3 then
        PanelSmelter.updateLeftPanel(var.bagSelectTab)
        var.PageVar.item_bg = var.curWidget:getWidgetByName("right_item_bg")
        var.PageVar.inherit_item_bg = var.curWidget:getWidgetByName("inherit_item_bg")
        var.PageVar.target_name = var.curWidget:getWidgetByName("right_target_name"):setColor(cc.c3b(0,255,255))
        var.PageVar.inherit_name = var.curWidget:getWidgetByName("inherit_name"):setColor(cc.c3b(255,153,255))
        var.PageVar.cost_gold = var.curWidget:getWidgetByName("Label_MixCostGold"):setString(0)
        var.curWidget:getWidgetByName("CheckBox_showPanel"):addClickEventListener(function ( pSender )
            
        end)
        var.PageVar.upd_loadbar = var.curWidget:getWidgetByName("LoadingBar_MixFalldownRate"):setPercent(0)
        var.curWidget:getWidgetByName("Button_EquipMixOpera"):addClickEventListener(function ( pSender )
            if var.PageVar.fromPos and NetClient:getNetItem(var.PageVar.fromPos) then
                if var.PageVar.toPos and NetClient:getNetItem(var.PageVar.toPos) then
                    PanelSmelter.runProgressBar(var.PageVar.upd_loadbar,function ( ... )
                        NetClient:PushLuaTable("gui.PanelUpgrade.onPanelData",util.encode(
                            {
                                actionid="ronghe",
                                from_pos = var.PageVar.fromPos,
                                to_pos = var.PageVar.toPos,
                                isuse = 1
                            }))
                    end)
                else
                    NetClient:alertLocalMsg("请放入要继承的装备！","alert")
                end
            else
                NetClient:alertLocalMsg("请放入已强化装备！","alert")
            end
        end)
    end
    if var.selectTab == 4 then
        var.widget:getWidgetByName("btn_self_equip"):hide()
        var.widget:getWidgetByName("btn_bag_equip"):setPositionY(285)
        var.bagSelectTab = 2
        var.leftButtonGroup:setButtonSelected(var.bagSelectTab)
        var.PageVar.recycleTab = {}
        var.PageVar.mSoulLabel = var.curWidget:getWidgetByName("Label_SoulStoneNum")
        var.PageVar.mExpLabel = var.curWidget:getWidgetByName("Label_ExpNum")
        var.PageVar.mSoulNum = 0
        var.PageVar.mExpNum = 0
        
        var.curWidget:getWidgetByName("Button_AddAll"):addClickEventListener(function ( pSender )
            local index = 1
            var.PageVar.recycleTab = {}
            var.PageVar.mSoulNum = 0
            var.PageVar.mExpNum = 0
            for i=0,72 do
                local item = NetClient:getNetItem(i)
                if item then
                    if game.IsEquipment(item.mTypeID) then
                        local result,hunshi,exp = PanelSmelter.checkCanRecycle( item.mTypeID )
                        if result > 0 then
                            table.insert( var.PageVar.recycleTab,i )
                            local item_bg = var.curWidget:getWidgetByName("right_item_bg_"..index)
                            UIItem.getItem({
                                parent = item_bg,
                                typeId = item.mTypeID,
                                pos = i,
                                itemCallBack = function () end
                            })
                            var.PageVar.mSoulNum = var.PageVar.mSoulNum + hunshi
                            var.PageVar.mExpNum = var.PageVar.mExpNum + exp
                            item_bg.index = index
                            item_bg:addClickEventListener(function ( pSender )
                                pSender:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                                local pos = var.PageVar.recycleTab[pSender.index]
                                local tempitem = NetClient:getNetItem(pos)
                                if tempitem then
                                    local tempresult,temphunshi,tempexp = PanelSmelter.checkCanRecycle( tempitem.mTypeID )
                                    var.PageVar.mSoulNum = var.PageVar.mSoulNum - temphunshi
                                    var.PageVar.mExpNum = var.PageVar.mExpNum - tempexp
                                    table.remove(var.PageVar.recycleTab,pSender.index)
                                    var.PageVar.mSoulLabel:setString(var.PageVar.mSoulNum)
                                    var.PageVar.mExpLabel:setString(var.PageVar.mExpNum)
                                end
                            end)
                            index = index + 1
                        end
                    end
                end
            end
            var.PageVar.mSoulLabel:setString(var.PageVar.mSoulNum)
            var.PageVar.mExpLabel:setString(var.PageVar.mExpNum)
        end)
        var.curWidget:getWidgetByName("Button_EquiRecycleOpera"):addClickEventListener(function ( pSender )
            if #var.PageVar.recycleTab > 0 then NetClient:PushLuaTable("gui.PanelUpgrade.onPanelData",util.encode({actionid="huishou",param=var.PageVar.recycleTab})) end
        end)
    end
    if var.selectTab == 5 then
        var.widget:getWidgetByName("btn_self_equip"):hide()
        var.widget:getWidgetByName("btn_bag_equip"):hide()
        for i=1,#leftBtn do
            var.widget:getWidgetByName(leftBtn[i]):show()
        end
        var.leftHCButtonGroup:setButtonSelected(var.hcSelectTab)
        PanelSmelter.updateLeftHCPanel(var.hcSelectTab)
        var.PageVar.item_bg = var.curWidget:getWidgetByName("right_item_bg")
        var.PageVar.next_item_bg = var.curWidget:getWidgetByName("next_item_bg")
        var.PageVar.target_name = var.curWidget:getWidgetByName("right_target_name"):setColor(cc.c3b(0,255,255))
        var.PageVar.next_name = var.curWidget:getWidgetByName("next_name"):setColor(cc.c3b(255,153,255))
        var.PageVar.cost_gold = var.curWidget:getWidgetByName("Label_CostBindGoldCoin"):setString(0)
        var.PageVar.upd_loadbar = var.curWidget:getWidgetByName("LoadingBar_ProgressBar"):setPercent(0)
        var.curWidget:getWidgetByName("Button_Compose"):addClickEventListener(function ( pSender )
            PanelSmelter.runProgressBar(var.PageVar.upd_loadbar,function ( ... )
                NetClient:PushLuaTable("gui.PanelUpgrade.onPanelData",util.encode({actionid="hecheng",pos=var.PageVar.pos}))
            end)
        end)
    end
    if var.selectTab == 6 then
        PanelSmelter.updateLeftPanel(var.bagSelectTab)
        var.PageVar.item_bg = var.curWidget:getWidgetByName("right_item_bg")
        var.PageVar.target_name = var.curWidget:getWidgetByName("right_target_name"):setColor(cc.c3b(255,153,255))
        var.PageVar.cost_gold = var.curWidget:getWidgetByName("Label_SepCostGold"):setString(0)
        var.PageVar.upd_loadbar = var.curWidget:getWidgetByName("LoadingBar_StoneSepSuccessRate"):setPercent(0)
        var.curWidget:getWidgetByName("Button_StoneSepOpera"):addClickEventListener(function ( pSender )
            PanelSmelter.runProgressBar(var.PageVar.upd_loadbar,function ( ... )
                NetClient:PushLuaTable("gui.PanelUpgrade.onPanelData",util.encode({actionid="chaifen",pos=var.PageVar.pos}))
            end)
        end)
    end
end

function PanelSmelter.updateLeftPanel( tag )
    var.bagSelectTab = tag

    local pos_self = {}
    if var.bagSelectTab == 1 then
        for i=1,#SELF_POS do
            local item = NetClient:getNetItem(SELF_POS[i])
            if item then
                if var.selectTab == 6 then
                    if item.mLevel > 0 then
                        table.insert(pos_self,SELF_POS[i])
                    end
                else
                    table.insert(pos_self,SELF_POS[i])
                end
            end
        end
    elseif var.bagSelectTab == 2 then
        for i=0,72 do
            local item = NetClient:getNetItem(i)
            if item then
                if game.IsEquipment(item.mTypeID) then
                    if var.selectTab == 6 then
                        if item.mLevel > 0 then
                            table.insert(pos_self,i)
                        end
                    else
                        table.insert(pos_self,i)
                    end
                end
            end
        end
    end
    local function updateLeftList( item,eventType )
        local net_item = NetClient:getNetItem(pos_self[item.tag])
        if net_item then
            local itemdef = NetClient:getItemDefByID(net_item.mTypeID)
            if itemdef then
                item:getWidgetByName("Label_ItemName"):setString(itemdef.mName)
                item:getWidgetByName("Label_InfoLevel"):show()
                item:getWidgetByName("Label_StrenLevel"):show():setString(net_item.mLevel)
                item:getWidgetByName("Label_ItemName"):setColor(util.Quality2color(itemdef.mColor))
            end
            UIItem.getItem({
                parent = item:getWidgetByName("item_bg"),
                typeId = net_item.mTypeID,
                pos = pos_self[item.tag],
                itemCallBack = function () end
            })
            item:getWidgetByName("item_bg"):setTouchEnabled(false)
            item:addClickEventListener(function ( pSender )
                PanelSmelter.updateRightPanel(var.selectTab,net_item.position)
            end)
        end
    end
    var.item_list:setItemModel(var.item_list:getItem(0))
    local params = {
        list            = var.item_list,
        totalLength     = math.ceil(#pos_self),
        updateFunc  = updateLeftList,
    }
    CCRecycleList.new(params)
end

function PanelSmelter.updateUpdPercent()
    if not var.PageVar.needXJ then return end
    local need_xj_num = NetClient:getBagItemNumberById(var.PageVar.needXJ)
    var.PageVar.all_per = 0
    local xj_def = NetClient:getItemDefByID(var.PageVar.needXJ)
    if xj_def then
        var.PageVar.xj_name:setString(xj_def.mName):setColor(util.Quality2color(xj_def.mColor))
        var.PageVar.cost_gold:setString(xj_def.mMACMax)
        local item = NetClient:getNetItem(var.PageVar.pos)
        if item.mLevel >= 8 then
            var.PageVar.check_xj:hide()
            game.AUTOBUYUPDXJ = 0
            var.PageVar.check_xj:setSelected(false)
        else
            var.curWidget:getWidgetByName("Label_StrenStoneAutoBuy"):setString("自动购买【"..xj_tab[item.mLevel+1].name.."】")
        end
        if need_xj_num > 0 or game.AUTOBUYUPDXJ == 1 then
            if game.AUTOBUYUPDXJ == 1 then
                var.PageVar.check_xj:show()
            elseif need_xj_num > 0 then 
                var.PageVar.check_xj:hide()
                game.AUTOBUYUPDXJ = 0
                var.PageVar.check_xj:setSelected(false)
            end
            var.PageVar.all_per = var.PageVar.all_per + xj_def.mMAC
        else
            var.PageVar.cost_gold:setString(0)
            var.PageVar.upd_per:setString("0%")
            if item.mLevel >= 8 then
                var.PageVar.check_xj:hide()
                game.AUTOBUYUPDXJ = 0
                var.PageVar.check_xj:setSelected(false)
            else
                var.PageVar.check_xj:show()
            end
        end

        if (var.PageVar.needFuPos and var.PageVar.needFuPos > 0) or game.AUTOBUYUPDFU == 1 then
            if game.AUTOBUYUPDFU == 1 then
                var.PageVar.check_fu:show()
                if item.mLevel > 4 then
                    var.PageVar.all_per = var.PageVar.all_per + 100
                else
                    var.PageVar.all_per = var.PageVar.all_per + 50
                end
            elseif (var.PageVar.needFuPos and var.PageVar.needFuPos > 0) then
                var.PageVar.check_fu:hide()
                game.AUTOBUYUPDFU = 0
                var.PageVar.check_fu:setSelected(false)
                local fuitem = NetClient:getNetItem(var.PageVar.needFuPos)
                if fuitem then
                    local itemicon = var.PageVar.fu_bg:getWidgetByName("itemIcon")
                    if itemicon then
                        UIItem.updateItemIconByTypeId(itemicon,fuitem.mTypeID)
                    else
                        UIItem.getItem({
                            parent = var.PageVar.fu_bg,
                            typeId = fuitem.mTypeID,
                            itemCallBack = function () end
                        })
                        var.PageVar.fu_bg:addClickEventListener(function ( pSender )
                            var.PageVar.fu_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                            var.PageVar.fu_name:setString("天工神符"):setColor(cc.c3b(0,255,255))
                            var.PageVar.needFuPos = -999
                            PanelSmelter.updateUpdPercent()
                        end)
                    end
                    local fu_def = NetClient:getItemDefByID(fuitem.mTypeID)
                    if fu_def then
                        var.PageVar.all_per = var.PageVar.all_per + fu_def.mAC
                        var.PageVar.fu_name:setString(fu_def.mName):setColor(util.Quality2color(fu_def.mColor))
                    end
                end
            end
        else
            var.PageVar.check_fu:show()
        end
        if item.mLevel <= 4 then
            var.curWidget:getWidgetByName("Label_StrenProtectAutoBuy"):setString("自动购买保护符（50%）")
        else
            var.curWidget:getWidgetByName("Label_StrenProtectAutoBuy"):setString("自动购买保护符（100%）")
        end
        var.PageVar.upd_per:setString((var.PageVar.all_per > 100 and 100 or var.PageVar.all_per).."%")
    end
end

function PanelSmelter.updateRightPanel( page,pos )
    if page == 1 then
        var.PageVar.pos = pos
        local item = NetClient:getNetItem(pos)
        if not item then return end
        PanelSmelter.clearUpdRight()
        local itemIcon = var.PageVar.item_bg:getWidgetByName("itemIcon")
        if not itemIcon then
            UIItem.getItem({
                parent = var.PageVar.item_bg,
                typeId = item.mTypeID,
                pos = pos,
                itemCallBack = function () end
            })
            var.PageVar.item_bg:addClickEventListener(function ( pSender )
                PanelSmelter.clearUpdRight()
            end)
        else
            UIItem.updateItemIconByPos(itemIcon,pos)
        end
        if item.mLevel < 12 then
            var.PageVar.needXJ = xj_tab[item.mLevel+1].id
            local need_xj_num = NetClient:getBagItemNumberById(var.PageVar.needXJ)
            local itemIcon = var.PageVar.xj_bg:getWidgetByName("itemIcon")
            if not itemIcon then
                UIItem.getItem({
                    parent = var.PageVar.xj_bg,
                    typeId = xj_tab[item.mLevel+1].id,
                    num = need_xj_num,
                    itemCallBack = function () end
                })
            else
                UIItem.updateItemIconByTypeId(itemIcon,xj_tab[item.mLevel+1].id,need_xj_num)
            end
            local itemdef = NetClient:getItemDefByID(item.mTypeID)
            if itemdef then
                var.PageVar.target_name:setString(itemdef.mName)
                var.PageVar.target_name:setColor(util.Quality2color(itemdef.mColor))
            end
            local fu_id,posTab = PanelSmelter.getBagFuMaxID()
            if fu_id > 0 and posTab then
                local itemIcon = var.PageVar.fu_bg:getWidgetByName("itemIcon")
                if not itemIcon then
                    UIItem.getItem({
                        parent = var.PageVar.fu_bg,
                        typeId = fu_id,
                        num = #posTab,
                        itemCallBack = function () end
                    })
                    var.PageVar.fu_bg:addClickEventListener(function ( pSender )
                        var.PageVar.fu_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                        var.PageVar.fu_name:setString("天工神符"):setColor(cc.c3b(0,255,255))
                        var.PageVar.needFuPos = -999
                        PanelSmelter.updateUpdPercent()
                    end)
                else
                    UIItem.updateItemIconByTypeId(itemIcon,fu_id,#posTab)
                end
                var.PageVar.needFuPos = posTab[1]
            else
                var.PageVar.check_fu:show()
            end
            PanelSmelter.updateUpdPercent()
        end
    end
    if page == 2 then
        if var.PageVar.pos and pos ~= var.PageVar.pos then
            LOCKTAB = {
                [WUFANG] = 0,
                [MOFANG] = 0,
                [WUGONG] = 0,
                [MOGONG] = 0,
                [DAOGONG] = 0,
                [SHENGMING] = 0,
                [ZHUNQUE] = 0,
                [BAOJI] = 0,
                [BAOSHANG] = 0,
                [BAOSHANGJM] = 0
            }
        end
        var.PageVar.pos = pos
        local item = NetClient:getNetItem(pos)
        if not item then return end
        PanelSmelter.clearUpdRight()
        local itemIcon = var.PageVar.item_bg:getWidgetByName("itemIcon")
        if not itemIcon then
            UIItem.getItem({
                parent = var.PageVar.item_bg,
                typeId = item.mTypeID,
                pos = pos,
                itemCallBack = function () end
            })
            var.PageVar.item_bg:addClickEventListener(function ( pSender )
                PanelSmelter.clearUpdRight()
            end)
        else
            UIItem.updateItemIconByPos(itemIcon,pos)
        end
        var.PageVar.needQLY = 10172
        local need_qly_num = NetClient:getBagItemNumberById(var.PageVar.needQLY)
        local itemIcon2 = var.PageVar.xj_bg:getWidgetByName("itemIcon")
        if not itemIcon2 then
            UIItem.getItem({
                parent = var.PageVar.xj_bg,
                typeId = var.PageVar.needQLY,
                num = need_qly_num,
                itemCallBack = function () end
            })
        else
            UIItem.updateItemIconByTypeId(itemIcon2,var.PageVar.needQLY,need_qly_num)
        end
        local itemdef = NetClient:getItemDefByID(item.mTypeID)
        if itemdef then
            var.PageVar.target_name:setString(itemdef.mName)
            var.PageVar.target_name:setColor(util.Quality2color(itemdef.mColor))
        end
        local ATTR_TAB = {
            [WUFANG]  = {name = "最大物理防御+",value = item.mAddAC},--物防
            [MOFANG]  = {name = "最大魔法防御+",value = item.mAddMAC},--魔防
            [WUGONG]  = {name = "最大物理攻击+",value = item.mAddDC},--物攻
            [MOGONG]  = {name = "最大魔法攻击+",value = item.mAddMC},--魔攻
            [DAOGONG]  = {name = "最大道术攻击+",value = item.mAddSC},--道攻
            [SHENGMING]  = {name = "最大生命上限+",value = item.mAddHp},--生命
            [ZHUNQUE]  = {name = "准确+",value = item.mAccuracy},--准确
            [BAOJI]  = {name = "暴击+",value = item.mBaoji},--暴击
            [BAOSHANG]  = {name = "暴伤加成+",value = item.mBaoShang},--暴伤
            [BAOSHANGJM]  = {name = "爆伤减免+",value = item.mBaoShangJM},--爆伤减免
        }
        local index = 1
        local tab_str = {}
        for i=1,#ATTR_TAB do
            if ATTR_TAB[i].value > 0 then
                var.curWidget:getWidgetByName("Label_SuperAbility"):show()
                local star_attr = PropStars[i]
                for j=1,#star_attr do
                    if star_attr[j] == ATTR_TAB[i].value then
                        local tempValue = ATTR_TAB[i].value
                        if i == BAOJI then tempValue = string.format("%0.1f",tempValue/100) end
                        tab_str[index] = {}
                        tab_str[index].attr = i
                        tab_str[index].str = ATTR_TAB[i].name..tempValue.."("..j.."星)"
                        index = index + 1
                    end
                end
            end
        end
        for i=1,#tab_str do
            var.curWidget:getWidgetByName("Label_Ability"..i):show():setString(tab_str[i].str)
            local btn_lock = var.curWidget:getWidgetByName("btn_lock_pray_"..i):show():setBrightStyle(0)
            btn_lock.attr = tab_str[i].attr
            if LOCKTAB[tab_str[i].attr] == 1 then
                btn_lock:setBrightStyle(1)
            end
        end
    end
    if page == 3 then
        local item = NetClient:getNetItem(pos)
        if not item then return end
        PanelSmelter.clearUpdRight()
        local itemdef = NetClient:getItemDefByID(item.mTypeID)
        if item.mLevel > 0 then
            var.PageVar.fromPos = pos
            local itemIcon = var.PageVar.item_bg:getWidgetByName("itemIcon")
            if not itemIcon then
                UIItem.getItem({
                    parent = var.PageVar.item_bg,
                    typeId = item.mTypeID,
                    pos = pos,
                    itemCallBack = function () end
                })
                var.PageVar.item_bg:addClickEventListener(function ( pSender )
                    var.PageVar.item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                    var.PageVar.target_name:setString("已强化装备"):setColor(cc.c3b(0,255,255))
                    var.PageVar.fromPos = -999
                    var.PageVar.cost_gold:setString(0)
                end)
            else
                UIItem.updateItemIconByPos(itemIcon,var.PageVar.fromPos)
            end
            if itemdef then
                var.PageVar.target_name:setString(itemdef.mName)
                var.PageVar.target_name:setColor(util.Quality2color(itemdef.mColor))
            end
            local need_money = 6250
            if item.mLevel <= 4 then
                for i=2,item.mLevel do
                    need_money = need_money * 2
                end
            else
                need_money = need_money*8
                for i=5,item.mLevel do
                    need_money = need_money * 2
                end
            end
            var.PageVar.cost_gold:setString(need_money)
        else
            var.PageVar.toPos = pos
            local itemIcon = var.PageVar.inherit_item_bg:getWidgetByName("itemIcon")
            if not itemIcon then
                UIItem.getItem({
                    parent = var.PageVar.inherit_item_bg,
                    typeId = item.mTypeID,
                    pos = pos,
                    itemCallBack = function () end
                })
                var.PageVar.inherit_item_bg:addClickEventListener(function ( pSender )
                    var.PageVar.inherit_item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                    var.PageVar.inherit_name:setString("未强化装备"):setColor(cc.c3b(0,255,255))
                    var.PageVar.toPos = -999
                end)
            else
                UIItem.updateItemIconByPos(itemIcon,var.PageVar.toPos)
            end
            if itemdef then
                var.PageVar.inherit_name:setString(itemdef.mName)
                var.PageVar.inherit_name:setColor(util.Quality2color(itemdef.mColor))
            end
        end
    end
    if page == 4 then
        local item = NetClient:getNetItem(pos)
        if not item then return end
        local result,hunshi,exp = PanelSmelter.checkCanRecycle(item.mTypeID)
        if result > 0 then
            if #var.PageVar.recycleTab > 0 then
                for i=1,#var.PageVar.recycleTab do
                    if var.PageVar.recycleTab[i] == pos then
                        return
                    end
                end
            end
            table.insert( var.PageVar.recycleTab,pos )
            for i=1,10 do
                local item_bg = var.curWidget:getWidgetByName("right_item_bg_"..i)
                if item_bg then
                    local itemicon = item_bg:getWidgetByName("iconNode")
                    if not itemicon then
                        UIItem.getItem({
                            parent = item_bg,
                            typeId = item.mTypeID,
                            pos = pos,
                            itemCallBack = function () end
                        })
                        var.PageVar.mSoulNum = var.PageVar.mSoulNum +hunshi
                        var.PageVar.mExpNum = var.PageVar.mExpNum + exp
                        var.PageVar.mSoulLabel:setString(var.PageVar.mSoulNum)
                        var.PageVar.mExpLabel:setString(var.PageVar.mExpNum)
                        item_bg:addClickEventListener(function ( pSender )
                            pSender:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
                            local pos = var.PageVar.recycleTab[i]
                            local tempitem = NetClient:getNetItem(pos)
                            if tempitem then
                                local tempresult,temphunshi,tempexp = PanelSmelter.checkCanRecycle( tempitem.mTypeID )
                                var.PageVar.mSoulNum = var.PageVar.mSoulNum - temphunshi
                                var.PageVar.mExpNum = var.PageVar.mExpNum - tempexp
                                table.remove(var.PageVar.recycleTab,i)
                                var.PageVar.mSoulLabel:setString(var.PageVar.mSoulNum)
                                var.PageVar.mExpLabel:setString(var.PageVar.mExpNum)
                            end
                        end)
                        return
                    end
                end
            end
        else
            NetClient:alertLocalMsg("该装备无法回收！","alert")
        end
    end
    if page == 5 then
        PanelSmelter.clearUpdRight()
        local item = NetClient:getNetItem(pos)
        if not item then return end
        local itemdef = NetClient:getItemDefByID(item.mTypeID)
        var.PageVar.pos = pos
        if itemdef then
            var.PageVar.target_name:setString(itemdef.mName)
            var.PageVar.target_name:setColor(util.Quality2color(itemdef.mColor))
            local nextid,needmoney,neednum = PanelSmelter.getNextItemInfo( item.mTypeID )
            if nextid > 0 then
                local itemIcon = var.PageVar.item_bg:getWidgetByName("iconNode")
                if not itemIcon then
                    UIItem.getItem({
                        parent = var.PageVar.item_bg,
                        typeId = item.mTypeID,
                        pos = pos,
                        itemCallBack = function () end
                    })
                    var.PageVar.item_bg:addClickEventListener(function ( pSender )
                        PanelSmelter.clearUpdRight()
                        var.PageVar.pos = -999
                    end)
                    UIItem.updateItemNum(var.PageVar.item_bg:getWidgetByName("iconNode"), item.mNumber.."/"..neednum,math.floor(item.mNumber/neednum) >= 1 and cc.c3b(0,255,0) or cc.c3b(255,0,0))
                else
                    UIItem.updateItemIconByPos(itemIcon,var.PageVar.pos)
                    UIItem.updateItemNum(itemIcon, item.mNumber.."/"..neednum,math.floor(item.mNumber/neednum) >= 1 and cc.c3b(0,255,0) or cc.c3b(255,0,0))
                end
                var.PageVar.cost_gold:setString(needmoney)
                local itemdef2 = NetClient:getItemDefByID(nextid)
                if itemdef2 then
                    var.PageVar.next_name:setString(itemdef2.mName)
                    var.PageVar.next_name:setColor(util.Quality2color(itemdef2.mColor))
                end
                local itemIcon = var.PageVar.next_item_bg:getWidgetByName("iconNode")
                if not itemIcon then
                    UIItem.getItem({
                        parent = var.PageVar.next_item_bg,
                        typeId = nextid,
                        num = math.ceil(item.mNumber/neednum),
                        itemCallBack = function () end
                    })
                else
                    UIItem.updateItemIconByTypeId(itemIcon,nextid,math.ceil(item.mNumber/neednum))
                end
            end
        end
    end
    if page == 6 then
        PanelSmelter.clearUpdRight()
        local item = NetClient:getNetItem(pos)
        if not item then return end
        if item.mLevel > 0 then
            local itemdef = NetClient:getItemDefByID(item.mTypeID)
            var.PageVar.pos = pos
            if itemdef then
                var.PageVar.target_name:setString(itemdef.mName)
                var.PageVar.target_name:setColor(util.Quality2color(itemdef.mColor))
                local itemIcon = var.PageVar.item_bg:getWidgetByName("iconNode")
                if not itemIcon then
                    UIItem.getItem({
                        parent = var.PageVar.item_bg,
                        typeId = item.mTypeID,
                        pos = pos,
                        itemCallBack = function () end
                    })
                    var.PageVar.item_bg:addClickEventListener(function ( pSender )
                        PanelSmelter.clearUpdRight()
                        var.PageVar.pos = -999
                    end)
                else
                    UIItem.updateItemIconByPos(itemIcon,var.PageVar.pos)
                end
                local gold = 1000
                for i=2,item.mLevel do
                    gold = gold*2
                end
                var.PageVar.cost_gold:setString(gold)
            end
        end
    end
end

function PanelSmelter.clearUpdRight()
    if var.selectTab == 1 then
        var.PageVar.item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.target_name:setString("目标装备"):setColor(cc.c3b(255,102,255))
        var.PageVar.xj_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.xj_name:setString("玄晶"):setColor(cc.c3b(0,255,255))
        var.PageVar.fu_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.fu_name:setString("天工神符"):setColor(cc.c3b(0,255,255))
        var.PageVar.cost_gold:setString(0)
        var.PageVar.upd_per:setString("0%")
        var.PageVar.check_xj:hide()
        var.PageVar.check_fu:hide()
    elseif var.selectTab == 2 then
        var.PageVar.item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.target_name:setString("目标装备"):setColor(cc.c3b(255,153,255))
        var.PageVar.xj_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.xj_name:setString("高级祈灵玉"):setColor(cc.c3b(0,255,255))
        for i=1,#ql_info_label do
            var.curWidget:getWidgetByName(ql_info_label[i]):hide()
        end
        for i=1,4 do
            var.curWidget:getWidgetByName("btn_lock_pray_"..i):hide()
        end
    elseif var.selectTab == 5 then
        var.PageVar.item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.next_item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.target_name:setString("低级物品"):setColor(cc.c3b(0,255,255))
        var.PageVar.next_name:setString("高级物品"):setColor(cc.c3b(255,153,255))
        var.PageVar.cost_gold:setString(0)
    elseif var.selectTab == 6 then
        var.PageVar.item_bg:loadTexture(game.getItemBgName(1),UI_TEX_TYPE_PLIST):removeAllChildren()
        var.PageVar.target_name:setString("目标装备"):setColor(cc.c3b(255,153,255))
        var.PageVar.cost_gold:setString(0)
    end
end

function PanelSmelter.updateLeftHCPanel( tag )
    if var.hcSelectTab ~= tag then PanelSmelter.clearUpdRight() end
    var.hcSelectTab = tag
    local pos_self = {}
    for i=0,72 do
        local item = NetClient:getNetItem(i)
        if item then
            if var.hcSelectTab == 1 then--宝典
                for j=1,#baodian_tab do
                    if baodian_tab[j].id == item.mTypeID and baodian_tab[j].nextid then
                        table.insert(pos_self,i)
                    end
                end
            elseif var.hcSelectTab == 2 then--玄晶
                for j=1,#xj_tab do
                    if xj_tab[j].id == item.mTypeID and xj_tab[j].nextid then
                        table.insert(pos_self,i)
                    end
                end
            elseif var.hcSelectTab == 3 then--杜康酒
                for j=1,#jiu_tab do
                    if jiu_tab[j].id == item.mTypeID and jiu_tab[j].nextid then
                        table.insert(pos_self,i)
                    end
                end
            end
        end
    end
    local function updateLeftList( item,eventType )
        local net_item = NetClient:getNetItem(pos_self[item.tag])
        if net_item then
            local itemdef = NetClient:getItemDefByID(net_item.mTypeID)
            if itemdef then
                item:getWidgetByName("Label_ItemName"):setString(itemdef.mName)
                item:getWidgetByName("Label_InfoLevel"):hide()
                item:getWidgetByName("Label_StrenLevel"):hide()
                item:getWidgetByName("Label_ItemName"):setColor(util.Quality2color(itemdef.mColor))
            end
            UIItem.getItem({
                parent = item:getWidgetByName("item_bg"),
                typeId = net_item.mTypeID,
                pos = pos_self[item.tag],
                itemCallBack = function () end
            })
            item:getWidgetByName("item_bg"):setTouchEnabled(false)
            item:addClickEventListener(function ( pSender )
                PanelSmelter.updateRightPanel(var.selectTab,net_item.position)
            end)
        end
    end
    var.item_list:setItemModel(var.item_list:getItem(0))
    local params = {
        list            = var.item_list,
        totalLength     = math.ceil(#pos_self),
        updateFunc  = updateLeftList,
    }
    CCRecycleList.new(params)
end

function PanelSmelter.getBagFuMaxID()
    local fu_tab = {10161,10160,10159,10158,10157,10156,10155,10154,10153,10152,}
    for i=1,#fu_tab do
        local num = NetClient:getBagItemNumberById(fu_tab[i])
        if num > 0 then
            local pos_tab = NetClient:getItemPosById(fu_tab[i])
            if #pos_tab > 0 then
                return fu_tab[i],pos_tab
            end
        end
    end
    return 0,nil
end

function PanelSmelter.getBagFuAllID()
    local fu_tab = {10161,10160,10159,10158,10157,10156,10155,10154,10153,10152,}
    local pos_tab = {}
    for i=1,#fu_tab do
        local temp = NetClient:getItemPosById(fu_tab[i])
        for j=1,#temp do
            table.insert(pos_tab,temp[j])
        end
    end
    return pos_tab
end

function PanelSmelter.checkCanRecycle( id )
    local itemdef = NetClient:getItemDefByID(id)
    if itemdef then
        if itemdef.mHuishouExp > 0 or itemdef.mHunshi > 0 then
            return 1,itemdef.mHuishouExp,itemdef.mHunshi
        end
    end
    return 0,0,0
end

function PanelSmelter.getNextItemInfo( id )
    for i=1,#xj_tab do
        if xj_tab[i].id == id then
            return xj_tab[i].nextid,xj_tab[i].needMoney,xj_tab[i].needNum
        end
    end
    for i=1,#baodian_tab do
        if baodian_tab[i].id == id then
            return baodian_tab[i].nextid,baodian_tab[i].needMoney,baodian_tab[i].needNum
        end
    end
    for i=1,#jiu_tab do
        if jiu_tab[i].id == id then
            return jiu_tab[i].nextid,jiu_tab[i].needMoney,jiu_tab[i].needNum
        end
    end
    return 0,0,0
end

function PanelSmelter.runProgressBar(progressbar,func)
    local percent = 0
    local function runLoading( dt )
        if percent<100 then
            percent=percent+2
            if progressbar then
                progressbar:setPercent(percent)
            end
        else
            if progressbar then
                progressbar:setPercent(0)
            end
            if var.freshHandle then
                Scheduler.unscheduleGlobal(var.freshHandle)
                var.freshHandle = nil
                func()
            end
        end
    end
    var.freshHandle = Scheduler.scheduleGlobal(runLoading, 1/60)
end

function PanelSmelter.onPanelClose(  )
    LOCKTAB = {
        [WUFANG] = 0,
        [MOFANG] = 0,
        [WUGONG] = 0,
        [MOGONG] = 0,
        [DAOGONG] = 0,
        [SHENGMING] = 0,
        [ZHUNQUE] = 0,
        [BAOJI] = 0,
        [BAOSHANG] = 0,
        [BAOSHANGJM] = 0
    }
end

return PanelSmelter