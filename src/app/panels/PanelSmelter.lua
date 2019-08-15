-- 身上装备位置 顺序不可随意改变 etype 暂时没用到
local SELF_POS = {
    Const.ITEM_WEAPON_POSITION, 
    Const.ITEM_NICKLACE_POSITION,
    Const.ITEM_GLOVE1_POSITION, 
    Const.ITEM_RING1_POSITION,  
    Const.ITEM_YUPEI_POSITION,  

    Const.ITEM_HUFU2_POSITION,  
    Const.ITEM_SHENQI_POSTITION,

    Const.ITEM_JIANJIA_POSITION,
    Const.ITEM_BAOSHI_POSITION, 
    Const.ITEM_DUNPAI_POSITION, 
    Const.ITEM_ANQI_POSITION,   
    Const.ITEM_YUXI_POSITION,   
    Const.ITEM_MEDAL_POSITION,  

    Const.ITEM_CLOTH_POSITION,  
    Const.ITEM_HAT_POSITION,
    Const.ITEM_BELT_POSITION,   
    Const.ITEM_BOOT_POSITION,   
    Const.ITEM_HUFU_POSITION,   

    Const.ITEM_LONGHUN_POSTITION,   
    Const.ITEM_SHENJIA_POSTITION,   
}

local jjs_path = 
{
    [15372] = {"jinjieshi_lv.png","精良进阶石"},
    [15373] = {"jinjieshi_lan.png","优秀进阶石"},
    [15364] = {"jinjieshi_zi.png","卓越进阶石"},
    [15365] = {"jinjieshi_cheng.png","完美进阶石"},
    [15366] = {"jinjieshi_hong.png","传说进阶石"},
}

local PanelSmelter = {}
local var = {}

function PanelSmelter.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSmelter/PanelSmelter.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_smelter")
    
    var.selectTab = 1
    var.bagSelectTab = 1
    var.rightSelectTab = 1
    var.mEffectSprite = nil
    var.widget:getWidgetByName("label_gold"):setString(NetClient.mCharacter.mGameMoney)
    var.widget:getWidgetByName("label_gold_bind"):setString(NetClient.mCharacter.mGameMoneyBind)
    var.widget:getWidgetByName("label_vcion"):setString(NetClient.mCharacter.mVCoin)
    var.widget:getWidgetByName("label_vcoin_bind"):setString(NetClient.mCharacter.mVCoinBind)
    var.item_list = var.widget:getWidgetByName("item_list")
    var.widget:getWidgetByName("btn_shop"):addClickEventListener(function (pSender)
        NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_mall",last_panel = "panel_smelter"})
    end)
    var.panelExtend = params.extend.mParam or ""
    if var.panelExtend == "zbsj" then
	    
	end
    --banshu
    var.widget:getWidgetByName("Button_ql"):hide():setTouchEnabled(false)
    var.widget:getWidgetByName("Button_zl"):hide():setTouchEnabled(false)
    var.widget:getWidgetByName("Button_xl"):hide():setTouchEnabled(false)
    var.widget:getWidgetByName("Button_sz"):hide():setTouchEnabled(false)
    var.widget:getWidgetByName("Button_fm"):hide():setTouchEnabled(false)

    PanelSmelter.addMenuTabClickEvent()
    PanelSmelter.registeEvent()

    return var.widget
end

function PanelSmelter.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    	:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelSmelter.handlePanelData)
        :addEventListener(Notify.EVENT_GAME_MONEY_CHANGE, PanelSmelter.handleMoneyChange)
end

function PanelSmelter.handlePanelData(event)
    if event and event.type == "item_data" then
        var.item_data = json.decode(event.data)
        if not var.item_data then return end
        if var.selectTab == 1 then
            if var.rightSelectTab == 1 then--强化面板（强化页签）
                if #var.pos_self > 0 then
                    NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = var.pos_self[1],
                            visible = true
                        })
                    PanelSmelter.updateRightPanelByItem(var.pos_self[1])
                end
                var.curPanel:getWidgetByName("panel_qh_bg"):getWidgetByName("btn_qa_qh").desp = var.item_data.tips
            elseif var.rightSelectTab == 2 then--强化面板（转移页签）
                var.curPanel:getWidgetByName("panel_zy_bg"):getWidgetByName("btn_qa_qh").desp = var.item_data.tips
            elseif var.rightSelectTab == 3 then--强化面板（合成页签）
                var.curPanel:getWidgetByName("panel_hc_bg"):getWidgetByName("btn_qa_qh").desp = var.item_data.tips
            end
        end
         if var.selectTab == 2 then
            if var.rightSelectTab == 1 then--升阶面板（升阶页签）
                if #var.pos_self > 0 then
                    NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = var.pos_self[1],
                            visible = true
                        })
                    PanelSmelter.updateRightPanelByItem(var.pos_self[1])
                end
                var.curPanel:getWidgetByName("panel_sj_bg"):getWidgetByName("btn_qa_qh").desp = var.item_data.intro
            elseif var.rightSelectTab == 2 then--升阶面板（转移页签）
                var.curPanel:getWidgetByName("panel_zy_bg"):getWidgetByName("btn_qa_qh").desp = var.item_data.advancetransferinfo.intro
            end
        end
    elseif event and event.type == "item_upgrade_result" then
        local result = json.decode(event.data)
        if var.selectTab == 1 then
            if var.rightSelectTab == 1 then--强化面板（强化页签）
                if result and result.errcode == 0 then
                    PanelSmelter.showSucessEffect(var.curPanel:getWidgetByName("panel_qh_bg"),cc.p(296,440),"qianghuachenggong.png")
                end
                if var.curSelectItem then
                    PanelSmelter.updateRightPanelByItem(var.curSelectItem)
                end
            end
        end
    elseif event and event.type == "transfersuccess" then
        if var.selectTab == 1 then
            if var.rightSelectTab == 2 then--强化面板（转移页签）
                PanelSmelter.showSucessEffect(var.curPanel:getWidgetByName("panel_zy_bg"),cc.p(296,335),"zhuanyichenggong.png")
                var.curPanel:getWidgetByName("item_zy_bg_1"):removeAllChildren()
                var.curPanel:getWidgetByName("item_zy_bg_2"):removeAllChildren()
                var.curPanel:getWidgetByName("img_item_info_1"):show()
                var.curPanel:getWidgetByName("img_item_info_2"):show()
                var.curPanel:getWidgetByName("label_need_gold_transfer"):setString(0)
                if var.mTransferIcon[1] then
                    NetClient:dispatchEvent(
                    {
                        name = Notify.EVENT_ITEM_SELECT,
                        pos = var.mTransferIcon[1],
                        visible = false
                    })
                end
                if var.mTransferIcon[2] then
                    NetClient:dispatchEvent(
                    {
                        name = Notify.EVENT_ITEM_SELECT,
                        pos = var.mTransferIcon[2],
                        visible = false
                    })
                end
                var.mTransferIcon = {}
            end
        end
    elseif event and event.type == "mergematerial" then
        local result = json.decode(event.data)
        if var.selectTab == 1 then
            if var.rightSelectTab == 3 then--强化面板（合成页签）
                if result and result.result == 0 then
                    if var.curSelectItem then
                        PanelSmelter.showSucessEffect(var.curPanel:getWidgetByName("panel_hc_bg"),cc.p(296,335),"hehcengchenggong.png")
                        local tempItem = NetClient:getNetItem(var.curSelectItem)
                        if tempItem and var.curSelectItemType and tempItem.mTypeID == var.curSelectItemType then
                            var.curPanel:getWidgetByName("label_hc_num"):setString(tempItem.mNumber.."/2")
                        else
                            var.curPanel:getWidgetByName("item_hc_bg_1"):removeAllChildren()
                            var.curPanel:getWidgetByName("img_item_info_3"):show()
                            var.curPanel:getWidgetByName("item_hc_bg_2"):removeAllChildren()
                            var.curPanel:getWidgetByName("img_item_info_4"):show()
                            var.curPanel:getWidgetByName("hc_success_bg"):hide()
                            var.curPanel:getWidgetByName("succ_box_hc"):setSelected(false)
                            var.curPanel:getWidgetByName("label_need_gold_compose"):setString(0)
                            var.curPanel:getWidgetByName("label_hc_num"):setString("0/2")
                        end
                    end
                    PanelSmelter.updateRightPanel(1)
                end
            end
        end
    elseif event and event.type == "advance_result" then
        local result = json.decode(event.data)
        if var.selectTab == 2 then
            if var.rightSelectTab == 1 then--升阶面板（升阶页签）
                if var.curSelectItem and var.curSelectItem == result.position then
                    PanelSmelter.showSucessEffect(var.curPanel:getWidgetByName("panel_sj_bg"),cc.p(296,440),"shengjiechenggong.png")
                    PanelSmelter.updateRightPanelByItem(result.position)
                end
                PanelSmelter.updateRightPanel(1)
            end
        end
    elseif event and event.type == "advtransfer_result" then
        local result = json.decode(event.data)
        if var.selectTab == 2 then
            if var.rightSelectTab == 2 then--升阶面板（转移页签）
                PanelSmelter.showSucessEffect(var.curPanel:getWidgetByName("panel_zy_bg"),cc.p(296,335),"zhuanyichenggong.png")
                var.curPanel:getWidgetByName("item_zy_bg_1"):removeAllChildren()
                var.curPanel:getWidgetByName("item_zy_bg_2"):removeAllChildren()
                var.curPanel:getWidgetByName("img_item_info_1"):show()
                var.curPanel:getWidgetByName("img_item_info_2"):show()
                var.curPanel:getWidgetByName("label_need_gold_transfer"):setString(0)
                var.mTransferIcon = {}
            end
        end
    end
end

function PanelSmelter.handleMoneyChange(event)
    var.widget:getWidgetByName("label_gold"):setString(NetClient.mCharacter.mGameMoney)
    var.widget:getWidgetByName("label_gold_bind"):setString(NetClient.mCharacter.mGameMoneyBind)
    var.widget:getWidgetByName("label_vcion"):setString(NetClient.mCharacter.mVCoin)
    var.widget:getWidgetByName("label_vcoin_bind"):setString(NetClient.mCharacter.mVCoinBind)
end

function PanelSmelter.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local RadionButtonGroup = UIRadioButtonGroup.new()
        :addButton(var.widget:getWidgetByName("Button_qh"))
        :addButton(var.widget:getWidgetByName("Button_sj"))
        :addButton(var.widget:getWidgetByName("Button_ql"))
        :addButton(var.widget:getWidgetByName("Button_zl"))
        :addButton(var.widget:getWidgetByName("Button_xl"))
        :addButton(var.widget:getWidgetByName("Button_sz"))
        :addButton(var.widget:getWidgetByName("Button_fm"))
        :onButtonSelectChanged(function(event)
            PanelSmelter.updatePanelByTag(event.selected)
        end)
    RadionButtonGroup:setButtonSelected(var.selectTab)

    var.RightButtonGroup = UIRadioButtonGroup.new()
        :addButton(var.widget:getWidgetByName("btn_right_self"))
        :addButton(var.widget:getWidgetByName("btn_right_bag"))
        :onButtonSelectChanged(function(event)
            PanelSmelter.updateRightPanel(event.selected)
            var.widget:getWidgetByName("btn_right_self"):getTitleRenderer():setPositionY(17)
            var.widget:getWidgetByName("btn_right_bag"):getTitleRenderer():setPositionY(17)
            if event.sender then
                event.sender:getTitleRenderer():setPositionY(23)
            end
        end)
    var.RightButtonGroup:setButtonSelected(var.bagSelectTab)
end

function PanelSmelter.cleanQHPanel()
    if var.qhRichWidget then
        var.qhRichWidget:removeFromParent()
        var.qhRichWidget = nil
    end
    for i=1,12 do
        var.curPanel:getWidgetByName("qh_star_"..i):setBright(false)
    end
    var.curPanel:getWidgetByName("panel_qh_bg"):hide()
    var.curPanel:getWidgetByName("panel_zy_bg"):hide()
    var.curPanel:getWidgetByName("panel_hc_bg"):hide()
    var.curPanel:getWidgetByName("item_qh_bg"):removeAllChildren()
    var.curPanel:getWidgetByName("item_zy_bg_1"):removeAllChildren()
    var.curPanel:getWidgetByName("item_zy_bg_2"):removeAllChildren()
    var.curPanel:getWidgetByName("img_item_info"):show()
    var.curPanel:getWidgetByName("img_item_info_1"):show()
    var.curPanel:getWidgetByName("img_item_info_2"):show()
    var.curPanel:getWidgetByName("item_hc_bg_1"):removeAllChildren()
    var.curPanel:getWidgetByName("img_item_info_3"):show()
    var.curPanel:getWidgetByName("item_hc_bg_2"):removeAllChildren()
    var.curPanel:getWidgetByName("img_item_info_4"):show()
    var.curPanel:getWidgetByName("hc_success_bg"):hide()
    var.curPanel:getWidgetByName("succ_box_hc"):setSelected(false)
    var.curPanel:getWidgetByName("label_need_gold_compose"):setString(0)
    var.curPanel:getWidgetByName("label_hc_num"):setString("0/2")
end

function PanelSmelter.cleanSJPanel()
    if var.qhRichWidget then
        var.qhRichWidget:removeFromParent()
        var.qhRichWidget = nil
    end
    var.curPanel:getWidgetByName("item_sj_bg"):removeAllChildren()
    var.curPanel:getWidgetByName("img_item_info"):show()
    var.curPanel:getWidgetByName("label_need_stone_1"):setString("/1")
    var.curPanel:getWidgetByName("label_have_stone_1"):setString("0")
    var.curPanel:getWidgetByName("label_need_stone_2"):setString("/1")
    var.curPanel:getWidgetByName("label_have_stone_2"):setString("0")
    var.curPanel:getWidgetByName("auto_buy_box"):setSelected(false)
    var.curPanel:getWidgetByName("label_auto_buy"):hide()
    if var.curSelectItem then
        NetClient:dispatchEvent(
        {
            name = Notify.EVENT_ITEM_SELECT,
            pos = var.curSelectItem,
            visible = false
        })
    end
    var.curSelectItem = nil
    var.curSelectItemType = nil
    var.curPanel:getWidgetByName("text_need_gold"):setString("消耗精良进阶石：")
    var.curPanel:getWidgetByName("img_jjs_lv"):loadTexture("jinjieshi_lv.png",UI_TEX_TYPE_PLIST)
    var.curPanel:getWidgetByName("item_zy_bg_1"):removeAllChildren()
    var.curPanel:getWidgetByName("img_item_info_1"):show()
    var.curPanel:getWidgetByName("item_zy_bg_2"):removeAllChildren()
    var.curPanel:getWidgetByName("img_item_info_2"):show()
    var.curPanel:getWidgetByName("label_need_gold_transfer"):setString("0")
end

function PanelSmelter.cleanCurPanel(tag,notclean)
    if var.curPanel then
        if tag == 1 then
            PanelSmelter.cleanQHPanel()
        elseif tag == 2 then
            var.curPanel:getWidgetByName("panel_sj_bg"):hide()
            var.curPanel:getWidgetByName("panel_zy_bg"):hide()
            PanelSmelter.cleanSJPanel()
        end

        -- if var.leftButtonGroup then
        --     var.leftButtonGroup:clearAll()
        --     var.leftButtonGroup = nil
        -- end
        var.mTransferIcon = {}
        var.curSelectItem = nil
        var.curSelectItemType = nil
        var.item_data = {}
        if not notclean then
            var.curPanel:removeFromParent()
            var.curPanel = nil
            if var.widget:getChildByName("csb_panel") then
                var.widget:removeChildByName("csb_panel")
            end
        end
    end
    var.widget:getWidgetByName("btn_right_self"):getTitleRenderer():setString("身上装备")
    var.widget:getWidgetByName("btn_right_bag"):show()
end

function PanelSmelter.updatePanelByTag(tag)
    if var.selectTab ~= tag then
        PanelSmelter.cleanCurPanel(var.selectTab)
    end
    var.selectTab = tag
    var.rightSelectTab = 1
    if var.RightButtonGroup then
        if var.bagSelectTab == 1 then
            PanelSmelter.updateRightPanel(1)
        end
        var.RightButtonGroup:setButtonSelected(1)
    end
    if var.selectTab == 1 then
        local curWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelSmelter/PanelUpgrade.csb")
            :align(display.CENTER, 475, 340)
            :setName("csb_panel")
            :addTo(var.widget,100)
        var.curPanel = curWidget:getChildByName("panel_upgrade")

        local panel_tab = {"panel_qh_bg","panel_zy_bg","panel_hc_bg"}
        for i=1,#panel_tab do
            var.curPanel:getWidgetByName(panel_tab[i]):getWidgetByName("btn_qa_qh"):addClickEventListener(function (pSender)
                UIAnimation.oneTips({
                    parent = pSender,
                    msg = pSender.desp,
                })
            end)
        end

        var.leftButtonGroup = UIRadioButtonGroup.new()
            :addButton(var.curPanel:getWidgetByName("btn_left_qh"))
            :addButton(var.curPanel:getWidgetByName("btn_left_zy"))
            :addButton(var.curPanel:getWidgetByName("btn_left_hc"))
            :onButtonSelectChanged(function(event)
                PanelSmelter.updateRightPage(event.selected)
                var.curPanel:getWidgetByName("btn_left_qh"):getTitleRenderer():setPositionY(17)
                var.curPanel:getWidgetByName("btn_left_zy"):getTitleRenderer():setPositionY(17)
                var.curPanel:getWidgetByName("btn_left_hc"):getTitleRenderer():setPositionY(17)
                if event.sender then
                    event.sender:getTitleRenderer():setPositionY(23)
                end
            end)
        var.leftButtonGroup:setButtonSelected(var.rightSelectTab)
    elseif var.selectTab == 2 then
        local curWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelSmelter/PanelAdvance.csb")
            :align(display.CENTER, 475, 340)
            :setName("csb_panel")
            :addTo(var.widget,100)
        var.curPanel = curWidget:getChildByName("panel_advance")

        local panel_tab = {"panel_sj_bg","panel_zy_bg"}
        for i=1,#panel_tab do
            var.curPanel:getWidgetByName(panel_tab[i]):getWidgetByName("btn_qa_qh"):addClickEventListener(function (pSender)
                UIAnimation.oneTips({
                    parent = pSender,
                    msg = pSender.desp,
                })
            end)
        end
        var.leftButtonGroup = UIRadioButtonGroup.new()
            :addButton(var.curPanel:getWidgetByName("btn_left_sj"))
            :addButton(var.curPanel:getWidgetByName("btn_left_zy"))
            :onButtonSelectChanged(function(event)
                PanelSmelter.updateRightPage(event.selected)
                var.curPanel:getWidgetByName("btn_left_sj"):getTitleRenderer():setPositionY(17)
                var.curPanel:getWidgetByName("btn_left_zy"):getTitleRenderer():setPositionY(17)
                if event.sender then
                    event.sender:getTitleRenderer():setPositionY(23)
                end
            end)
        var.leftButtonGroup:setButtonSelected(var.rightSelectTab)
    end
end

function PanelSmelter.updateRightPage(tag)
    PanelSmelter.cleanCurPanel(var.selectTab,true)

    var.rightSelectTab = tag
    if var.selectTab == 1 then
        if var.RightButtonGroup then
            if var.bagSelectTab == 1 then
                PanelSmelter.updateRightPanel(1)
            end
            var.RightButtonGroup:setButtonSelected(1)
        end
        if var.rightSelectTab == 1 then
            var.curPanel:getWidgetByName("panel_qh_bg"):show()
            var.curPanel:getWidgetByName("qh_success_bg"):hide()
            var.curPanel:getWidgetByName("label_wg"):hide()
            var.curPanel:getWidgetByName("label_auto_buy"):hide()
            var.curPanel:getWidgetByName("text_need_xj"):hide()
            var.curPanel:getWidgetByName("text_need_gold"):hide()
            NetClient:PushLuaTable("newgui.equipup.OnEquipLua",util.encode({actionid = "querymergeinfo"}))
        elseif var.rightSelectTab == 2 then
            var.curPanel:getWidgetByName("panel_zy_bg"):show()
            NetClient:PushLuaTable("newgui.equipup.OnEquipLua",util.encode({actionid = "querytransferinfo"}))
        elseif var.rightSelectTab == 3 then
            var.curPanel:getWidgetByName("panel_hc_bg"):show()
            var.curPanel:getWidgetByName("hc_success_bg"):hide()
            NetClient:PushLuaTable("newgui.materialMerge.OnMergeLua",util.encode({actionid = "mergematerialinfo"}))
        end
    elseif var.selectTab == 2 then
        if var.rightSelectTab == 1 then
            PanelSmelter.updateRightPanel(var.bagSelectTab)
            var.curPanel:getWidgetByName("panel_sj_bg"):show()
            NetClient:PushLuaTable("newgui.equipadvance.OnAdvanceLua",util.encode({actionid = "getEquipAdvanceInfo"}))
        elseif var.rightSelectTab == 2 then
            PanelSmelter.updateRightPanel(var.bagSelectTab)
            var.curPanel:getWidgetByName("panel_zy_bg"):show()
            NetClient:PushLuaTable("newgui.equipadvtransfer.OnAdvTranLua",util.encode({actionid = "queryadvancetransferinfo"}))
        end
    end
end

function PanelSmelter.updateRightPanel(tag)
    var.bagSelectTab = tag
    var.pos_self = {}
    if var.bagSelectTab == 1 then
        if var.selectTab == 1 and var.rightSelectTab == 3 then
            var.widget:getWidgetByName("btn_right_self"):getTitleRenderer():setString("材料")
            var.widget:getWidgetByName("btn_right_bag"):hide()
            for i=0,119 do
                local item = NetClient:getNetItem(i)
                if item then
                    if game.IsMaterial(item.mTypeID) then
                        table.insert(var.pos_self,i)
                    end
                end
            end
        else
            for i=1,#SELF_POS do
                local item = NetClient:getNetItem(SELF_POS[i])
                if item then
                    local isMaxLevel = false
                    if var.selectTab == 1 and var.rightSelectTab == 1 then--强化面板（强化页签）
                        if item.mLevel >= 24 then isMaxLevel = true end
                    end
                    if var.selectTab == 2 and var.rightSelectTab == 1 then--升阶面板（升阶页签）
                        local nextID = game.calc_advance_item_type(item.mTypeID)
                        local nextItemdef = NetClient:getItemDefByID(nextID)
                        if not nextItemdef then
                            isMaxLevel = true
                        end
                    end
                    if not PanelSmelter.canUpgradeEquip(item.mTypeID) then
                        isMaxLevel = true
                    end
                    if not isMaxLevel then
                        table.insert(var.pos_self,SELF_POS[i])
                    end
                end
            end
        end
    elseif var.bagSelectTab == 2 then
        for i=0,119 do
            local item = NetClient:getNetItem(i)
            if item then
                if game.IsEquipment(item.mTypeID) then
                    local isMaxLevel = false
                    if var.selectTab == 1 and var.rightSelectTab == 1 then--强化面板（强化页签）
                        if item.mLevel >= 24 then isMaxLevel = true end
                    end
                    if var.selectTab == 2 and var.rightSelectTab == 1 then--升阶面板（升阶页签）
                        local nextID = game.calc_advance_item_type(item.mTypeID)
                        local nextItemdef = NetClient:getItemDefByID(nextID)
                        if not nextItemdef then
                            isMaxLevel = true
                        end
                    end
                    if not PanelSmelter.canUpgradeEquip(item.mTypeID) then
                        isMaxLevel = true
                    end
                    if not isMaxLevel then
                        table.insert(var.pos_self,i)
                    end
                end
            end
        end
    end
    var.item_list:removeAllChildren()
    local all_height = math.ceil(#var.pos_self/4)*80
    if all_height <= var.item_list:getContentSize().height then all_height = var.item_list:getContentSize().height end
    for i=1,#var.pos_self do
        local item_temp = var.widget:getWidgetByName("item_icon"):clone()
        item_temp:setPosition(cc.p(52+math.floor((i-1)%4)*80,all_height-50-math.floor((i-1)/4)*80))
        UIItem.getItem({
            parent = item_temp,
            pos = var.pos_self[i],
            showSelectEffect = true,
            itemCallBack = function (pSender)
                if pSender and pSender.itemIcon then
                    if var.curSelectItem then
                        NetClient:dispatchEvent(
                            {
                                name = Notify.EVENT_ITEM_SELECT,
                                pos = var.curSelectItem,
                                visible = false
                            })
                    end
                    NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = pSender.itemIcon.itemPos,
                            visible = true
                        })
                    PanelSmelter.updateRightPanelByItem(pSender.itemIcon.itemPos,pSender.itemIcon.typeId)
                end
            end
        })

        if var.curSelectItem and var.pos_self[i] == var.curSelectItem then
            NetClient:dispatchEvent(
                {
                    name = Notify.EVENT_ITEM_SELECT,
                    pos = var.curSelectItem,
                    visible = true
                })
        end
        var.item_list:addChild(item_temp)
    end
    var.item_list:setInnerContainerSize(cc.size(346,all_height))
end

function PanelSmelter.updateRightPanelByItem(pos,typeId)
    local ni = NetClient:getNetItem(pos)
    if ni then
        if var.selectTab == 1 then--强化面板
            if var.rightSelectTab == 1 then--强化面板（强化页签）
                if var.item_data and var.curPanel then
                    local cur_data = var.item_data.levelInfo[ni.mLevel]
                    local qh_data = var.item_data.levelInfo[ni.mLevel+1]
                    if ni.mLevel > 0 and not cur_data then return end
                    if qh_data then
                        var.curSelectItem = pos
                        if var.qhRichWidget then
                            var.qhRichWidget:removeFromParent()
                            var.qhRichWidget = nil
                        end
                        var.curPanel:getWidgetByName("item_qh_bg"):removeAllChildren()
                        var.curPanel:getWidgetByName("img_item_info"):hide()
                        UIItem.getItem({
                            parent = var.curPanel:getWidgetByName("item_qh_bg"),
                            pos = pos,
                        })
                        for i=1,12 do
                            if ni.mLevel%12 >= i then
                                --设亮
                                var.curPanel:getWidgetByName("qh_star_"..i):setBright(true)
                            else
                                var.curPanel:getWidgetByName("qh_star_"..i):setBright(false)
                            end
                        end
                        var.curPanel:getWidgetByName("qh_success_bg"):show()
                        var.curPanel:getWidgetByName("atlas_suc"):setString(qh_data.baseprop/100)
                        if qh_data.baseprop >= 10000 or ni.mLevel >= 12 then
                            var.curPanel:getWidgetByName("label_succ_info"):hide()
                        else
                            var.curPanel:getWidgetByName("label_succ_info"):show()
                            var.curPanel:getWidgetByName("label_succ_vcoin"):setString(qh_data.needyb.."元宝")
                        end
                        var.curPanel:getWidgetByName("text_need_xj"):show()
                        var.curPanel:getWidgetByName("label_xj_name"):setString(((ni.mLevel+1)%12).."级")
                        local needitem_num = NetClient:getBagItemNumberById(qh_data.needitems[1].type_id)
                        if needitem_num <= 0 then
                            var.curPanel:getWidgetByName("label_auto_buy"):show()
                        end
                        if needitem_num < qh_data.needitems[1].num then
                            var.curPanel:getWidgetByName("label_have_xj"):setColor(cc.c3b(231, 3, 1))
                            var.curPanel:getWidgetByName("label_need_xj"):setColor(cc.c3b(231, 3, 1))
                        else
                            var.curPanel:getWidgetByName("label_have_xj"):setColor(cc.c3b(255, 255, 255))
                            var.curPanel:getWidgetByName("label_need_xj"):setColor(cc.c3b(18, 207, 40))
                        end
                        var.curPanel:getWidgetByName("label_have_xj"):setString(needitem_num)
                        var.curPanel:getWidgetByName("label_need_xj"):setString("/"..qh_data.needitems[1].num)
                        var.curPanel:getWidgetByName("text_need_gold"):show()
                        if ni.mLevel < 12 then
                            var.curPanel:getWidgetByName("text_need_gold"):setString("消耗绑金：")
                            var.curPanel:getWidgetByName("img_money"):loadTexture("img_money_bind.png",UI_TEX_TYPE_PLIST):setContentSize(cc.size(38,34))
                        else
                            var.curPanel:getWidgetByName("text_need_gold"):setString("消耗金币：")
                            var.curPanel:getWidgetByName("img_money"):loadTexture("img_money.png",UI_TEX_TYPE_PLIST):setContentSize(cc.size(32,34))
                        end
                        if (tonumber(qh_data.gold) >= NetClient.mCharacter.mGameMoneyBind and ni.mLevel < 12) 
                            or (tonumber(qh_data.gold) >= NetClient.mCharacter.mGameMoney and ni.mLevel >= 12) then
                            var.curPanel:getWidgetByName("label_need_gold"):setColor(cc.c3b(231, 3, 1))
                        else
                            var.curPanel:getWidgetByName("label_need_gold"):setColor(cc.c3b(18, 207, 40))
                        end
                        var.curPanel:getWidgetByName("label_need_gold"):setString(qh_data.gold)

                        local itemdef = NetClient:getItemDefByID(ni.mTypeID)
                        if itemdef then
                            local richLabelStr = ""
                            if not cur_data then
                                cur_data = {adddc = 0,addmdc = 0,addmc = 0,addmmc = 0,addsc = 0,addmsc = 0}
                            end
                            if itemdef.mDC > 0 and itemdef.mDCMax > 0 and (qh_data.adddc > 0 or qh_data.addmdc) then--加物攻
                                richLabelStr = richLabelStr.."<font color='#D4C08B'>物理攻击：</font>"..(itemdef.mDC+cur_data.adddc+itemdef.mColorRangeL).."-"..(itemdef.mDCMax+cur_data.addmdc+itemdef.mColorRange)
                                .."<font color='#12CF28'> → "
                                ..(itemdef.mDC+qh_data.adddc+itemdef.mColorRangeL).."-"..(itemdef.mDCMax+qh_data.addmdc+itemdef.mColorRange).."</font><br>"
                            end
                            if itemdef.mMC > 0 and itemdef.mMCMax > 0 and (qh_data.addmc > 0 or qh_data.addmmc) then--加魔攻
                                richLabelStr = richLabelStr.."<font color='#D4C08B'>魔法攻击：</font>"..(itemdef.mMC+cur_data.addmc+itemdef.mColorRangeL).."-"..(itemdef.mMCMax+cur_data.addmmc+itemdef.mColorRange)
                                .."<font color='#12CF28'> → "
                                ..(itemdef.mMC+qh_data.addmc+itemdef.mColorRangeL).."-"..(itemdef.mMCMax+qh_data.addmmc+itemdef.mColorRange).."</font><br>"
                            end
                            if itemdef.mSC > 0 and itemdef.mSCMax > 0 and (qh_data.addsc > 0 or qh_data.addmsc) then--加道攻
                                richLabelStr = richLabelStr.."<font color='#D4C08B'>道术攻击：</font>"..(itemdef.mSC+cur_data.addsc+itemdef.mColorRangeL).."-"..(itemdef.mSCMax+cur_data.addmsc+itemdef.mColorRange)
                                .."<font color='#12CF28'> → "
                                ..(itemdef.mSC+qh_data.addsc+itemdef.mColorRangeL).."-"..(itemdef.mSCMax+qh_data.addmsc+itemdef.mColorRange).."</font><br>"
                            end
                            local richLabel, richWidget = util.newRichLabel(cc.size(400, 0), 0)
                            var.qhRichWidget = richWidget
                            util.setRichLabel(richLabel, richLabelStr, "panel_smelter", 28)
                            richLabel:setPosition(cc.p(-200,richLabel:getRealHeight()/2))
                            var.curPanel:getWidgetByName("label_wg"):show():addChild(var.qhRichWidget)
                            local function updatePercent(pSender)
                                if pSender:isSelected() and ni.mLevel < 12 then
                                    var.curPanel:getWidgetByName("atlas_suc"):setString(100)
                                else
                                    var.curPanel:getWidgetByName("atlas_suc"):setString(qh_data.baseprop/100)
                                end
                            end
                            updatePercent(var.curPanel:getWidgetByName("succ_box"))
                            var.curPanel:getWidgetByName("succ_box"):addClickEventListener(function ( pSender )
                                
                                gameEffect.playEffectByType(gameEffect.EFFECT_UPGRADE_PER, {removeSelf=true,onComplete=function ()
                                    updatePercent(var.curPanel:getWidgetByName("succ_box"))
                                end})
                                    :setPosition(cc.p(281,23)):addTo(var.curPanel:getWidgetByName("qh_success_bg"))
                            end)
                            var.curPanel:getWidgetByName("Button_upgrade"):addClickEventListener(function (pSender)
                                --UIButtonGuide.handleButtonGuideClicked(pSender)
                                if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.QIANGHUA) then
                                    UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_close"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.QIANGHUA,2),UIButtonGuide.UI_TYPE_LEFT)
                                end 
                                var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                                    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.QIANGHUA) then
                                        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_smelter"})
                                    end
                                end)))
                                UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.QIANGHUA})
                                --paytype是否元宝补足几率 useyb 没用 useyb2元宝补足玄晶
                                if var.curSelectItem then
                                    local need_num = qh_data.needitems[1].num
                                    local have_num = NetClient:getBagItemNumberById(qh_data.needitems[1].type_id)
                                    local needSuc = (var.curPanel:getWidgetByName("succ_box"):isSelected() and 1 or 0)
                                    local needXj = (var.curPanel:getWidgetByName("auto_buy_box"):isSelected() and 1 or 0)
                                    if have_num < need_num and needXj == 0 then
                                        NetClient:alertLocalMsg("玄晶不足","alert")
                                        return
                                    end
                                    NetClient:PushLuaTable("newgui.equipup.OnEquipLua",util.encode({actionid = "equipupgrade",position=pos,paytype=needSuc,useyb2=needXj}))
                                else
                                    NetClient:alertLocalMsg("请放入装备","alert")
                                    return
                                end
                            end)
                            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.QIANGHUA) then
                                UIButtonGuide.addGuideTip(var.curPanel:getWidgetByName("Button_upgrade"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.QIANGHUA),UIButtonGuide.UI_TYPE_RIGHT)
                            else
                                UIButtonGuide.clearGuideTip(var.curPanel:getWidgetByName("Button_upgrade"))
                            end
                        end
                    else
                        if ni.mLevel >= 24 then
                            PanelSmelter.updateRightPanelByItem(-999)
                            PanelSmelter.updateRightPanel(1)
                            NetClient:alertLocalMsg("已经强化到最顶级","alert")
                        end
                    end
                end
            elseif var.rightSelectTab == 2 then--强化面板（转移页签）
                if var.item_data and var.curPanel then
                    
                    var.curPanel:getWidgetByName("Button_transfer"):addClickEventListener(function (pSender)
                        if var.mTransferIcon[1] and var.mTransferIcon[2] then
                            NetClient:PushLuaTable("newgui.equipup.OnEquipLua",util.encode({actionid = "equiptransfer",position=var.mTransferIcon[1],paytype=0,transferpositon=var.mTransferIcon[2]}))
                        else
                            NetClient:alertLocalMsg("请放入不同强化等级的装备","alert")
                        end
                    end)
                    if not var.mTransferIcon[1] then
                        var.curPanel:getWidgetByName("item_zy_bg_1"):removeAllChildren()
                        var.curPanel:getWidgetByName("img_item_info_1"):hide()
                        UIItem.getItem({
                            parent = var.curPanel:getWidgetByName("item_zy_bg_1"),
                            pos = pos,
                            itemCallBack = function (pSender)
                                if pSender and pSender.itemIcon then
                                    NetClient:dispatchEvent(
                                    {
                                        name = Notify.EVENT_ITEM_SELECT,
                                        pos = pSender.itemIcon.itemPos,
                                        visible = false
                                    })
                                    pSender:removeAllChildren()
                                    var.mTransferIcon[1] = nil
                                    var.curPanel:getWidgetByName("label_need_gold_transfer"):setString("0")
                                    var.curPanel:getWidgetByName("img_item_info_1"):show()
                                end
                            end
                        })
                        var.mTransferIcon[1] = pos
                        return
                    end
                    if not var.mTransferIcon[2] then
                        if var.mTransferIcon[1] then
                            local item1 = NetClient:getNetItem(var.mTransferIcon[1])
                            if item1 then
                                --"请放入不同强化等级的装备"
                                if item1.mLevel ~= ni.mLevel then
                                    var.curPanel:getWidgetByName("item_zy_bg_2"):removeAllChildren()
                                    var.curPanel:getWidgetByName("img_item_info_2"):hide()
                                    UIItem.getItem({
                                        parent = var.curPanel:getWidgetByName("item_zy_bg_2"),
                                        pos = pos,
                                        itemCallBack = function (pSender)
                                            if pSender and pSender.itemIcon then
                                                NetClient:dispatchEvent(
                                                {
                                                    name = Notify.EVENT_ITEM_SELECT,
                                                    pos = pSender.itemIcon.itemPos,
                                                    visible = false
                                                })
                                                pSender:removeAllChildren()
                                                var.mTransferIcon[2] = nil
                                                var.curPanel:getWidgetByName("label_need_gold_transfer"):setString("0")
                                                var.curPanel:getWidgetByName("img_item_info_2"):show()
                                            end
                                        end
                                    })
                                    var.mTransferIcon[2] = pos
                                    local transferInfo = var.item_data.transferinfo
                                    local maxLevel = math.max(item1.mLevel,ni.mLevel)
                                    local temp = transferInfo[maxLevel]
                                    if temp then
                                        if tonumber(temp.cost) >= NetClient.mCharacter.mGameMoneyBind then
                                            var.curPanel:getWidgetByName("label_need_gold_transfer"):setColor(cc.c3b(231, 3, 1))
                                        else
                                            var.curPanel:getWidgetByName("label_need_gold_transfer"):setColor(cc.c3b(18, 207, 40))
                                        end
                                        var.curPanel:getWidgetByName("label_need_gold_transfer"):setString(temp.cost)
                                    end
                                else
                                    NetClient:dispatchEvent(
                                    {
                                        name = Notify.EVENT_ITEM_SELECT,
                                        pos = pos,
                                        visible = false
                                    })
                                    NetClient:alertLocalMsg("请放入不同强化等级的装备","alert")
                                    return
                                end
                            end
                        end
                    else
                        NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = pos,
                            visible = false
                        })
                    end
                end
            elseif var.rightSelectTab == 3 then --强化面板（合成页签）
                if var.item_data and var.curPanel then
                    var.curPanel:getWidgetByName("img_item_info_3"):hide()
                    local all_xj_data = var.item_data.materialInfo[1]
                    var.curPanel:getWidgetByName("label_hc_num"):setString(ni.mNumber.."/"..all_xj_data.num_once)
                    var.curSelectItem = pos
                    var.curSelectItemType = ni.mTypeID
                    UIItem.getItem({
                        parent = var.curPanel:getWidgetByName("item_hc_bg_1"),
                        pos = pos,
                        itemCallBack = function (pSender)
                            if pSender and pSender.itemIcon then
                                NetClient:dispatchEvent(
                                {
                                    name = Notify.EVENT_ITEM_SELECT,
                                    pos = pSender.itemIcon.itemPos,
                                    visible = false
                                })
                                pSender:removeAllChildren()
                                var.curPanel:getWidgetByName("img_item_info_3"):show()
                                var.curPanel:getWidgetByName("item_hc_bg_2"):removeAllChildren()
                                var.curPanel:getWidgetByName("img_item_info_4"):show()
                                var.curPanel:getWidgetByName("hc_success_bg"):hide()
                                var.curPanel:getWidgetByName("succ_box_hc"):setSelected(false)
                                var.curPanel:getWidgetByName("label_need_gold_compose"):setString(0)
                                var.curPanel:getWidgetByName("label_hc_num"):setString("0/2")
                                var.curSelectItem = nil
                                var.curSelectItemType = nil
                            end
                        end
                    })
                    local cur_xj_data
                    for i=1,#all_xj_data.merge_data do
                        if all_xj_data.merge_data[i].material_id == ni.mTypeID then
                            cur_xj_data = all_xj_data.merge_data[i]
                        end
                    end
                    if cur_xj_data then
                        var.curPanel:getWidgetByName("hc_success_bg"):show()
                        var.curPanel:getWidgetByName("img_item_info_4"):hide()
                        UIItem.getItem({
                            parent = var.curPanel:getWidgetByName("item_hc_bg_2"),
                            typeId = cur_xj_data.merge_id,
                        })
                        if all_xj_data.need_money_type[1] == 4 then--1=元宝 2=绑定元宝 3=金币 4=绑定金币
                            var.curPanel:getWidgetByName("text_need_gold_hc"):setString("消耗绑金：")
                        end
                        if tonumber(cur_xj_data.need_gold) >= NetClient.mCharacter.mGameMoneyBind then
                            var.curPanel:getWidgetByName("label_need_gold_compose"):setColor(cc.c3b(231, 3, 1))
                        else
                            var.curPanel:getWidgetByName("label_need_gold_compose"):setColor(cc.c3b(18, 207, 40))
                        end
                        var.curPanel:getWidgetByName("label_need_gold_compose"):setString(cur_xj_data.need_gold)
                        if cur_xj_data.suc_rate >= 10000 then
                            var.curPanel:getWidgetByName("label_succ_info_hc"):hide()
                        else
                            var.curPanel:getWidgetByName("label_succ_info_hc"):show()
                            var.curPanel:getWidgetByName("label_succ_vcoin_hc"):setString(cur_xj_data.needyb.."元宝")
                        end
                        var.curPanel:getWidgetByName("atlas_suc_hc"):setString(cur_xj_data.suc_rate/100)
                        local function updatePercent(pSender)
                            if pSender:isSelected() then
                                var.curPanel:getWidgetByName("atlas_suc_hc"):setString(100)
                            else
                                var.curPanel:getWidgetByName("atlas_suc_hc"):setString(cur_xj_data.suc_rate/100)
                            end
                        end
                        updatePercent(var.curPanel:getWidgetByName("succ_box_hc"))
                        var.curPanel:getWidgetByName("succ_box_hc"):addClickEventListener(function ( pSender )
                            updatePercent(pSender)
                        end)
                        local needSuc = (var.curPanel:getWidgetByName("succ_box_hc"):isSelected() and 1 or 0)
                        var.curPanel:getWidgetByName("Button_compose"):addClickEventListener(function ( pSender )
                            if var.curSelectItem then
                                NetClient:PushLuaTable("newgui.materialMerge.OnMergeLua",util.encode({actionid = "mergematerial",pos=pos,luckmaterialpos=-1,useyb=needSuc}))
                            else
                                NetClient:alertLocalMsg("请放入玄晶","alert")
                                return
                            end
                        end)
                        var.curPanel:getWidgetByName("Button_compose_all"):addClickEventListener(function ( pSender )
                            if var.curSelectItem then
                                NetClient:PushLuaTable("newgui.materialMerge.OnMergeLua",util.encode({actionid = "mergematerialall",pos=pos,luckmaterialpos=-1,useyb=needSuc}))
                            else
                                NetClient:alertLocalMsg("请放入玄晶","alert")
                                return
                            end
                        end)
                    end
                end
            end
        elseif var.selectTab == 2 then--升阶面板
            if var.rightSelectTab == 1 then--升阶面板（升阶页签）
                if var.item_data and var.curPanel then
                    local itemdef = NetClient:getItemDefByID(ni.mTypeID)
                    if itemdef then
                        if itemdef.mAdvNeed1 > 0 and itemdef.mAdvNeedNum1 > 0 and itemdef.mAdvNeed2 > 0 and itemdef.mAdvNeedNum2 > 0 then 
                            var.curSelectItem = pos
                            if var.qhRichWidget then
                                var.qhRichWidget:removeFromParent()
                                var.qhRichWidget = nil
                            end
                            var.curPanel:getWidgetByName("item_sj_bg"):removeAllChildren()
                            var.curPanel:getWidgetByName("img_item_info"):hide()
                            var.curPanel:getWidgetByName("label_auto_buy"):hide()
                            UIItem.getItem({
                                parent = var.curPanel:getWidgetByName("item_sj_bg"),
                                pos = pos,
                                itemCallBack = function (pSender)
                                    if pSender and pSender.itemIcon then
                                        NetClient:dispatchEvent(
                                        {
                                            name = Notify.EVENT_ITEM_SELECT,
                                            pos = pSender.itemIcon.itemPos,
                                            visible = false
                                        })
                                        PanelSmelter.cleanSJPanel()
                                    end
                                end
                            })
                            if jjs_path[itemdef.mAdvNeed2] then
                                var.curPanel:getWidgetByName("text_need_gold"):setString("消耗"..jjs_path[itemdef.mAdvNeed2][2].."：")
                                var.curPanel:getWidgetByName("img_jjs_lv"):loadTexture(jjs_path[itemdef.mAdvNeed2][1],UI_TEX_TYPE_PLIST)
                            end
                            local needitem_num1 = NetClient:getBagItemNumberById(itemdef.mAdvNeed1)
                            local needitem_num2 = NetClient:getBagItemNumberById(itemdef.mAdvNeed2)
                            if needitem_num1 < itemdef.mAdvNeedNum1 or needitem_num2 < itemdef.mAdvNeedNum2 then
                                var.curPanel:getWidgetByName("label_auto_buy"):show()
                            end
                            if needitem_num1 < itemdef.mAdvNeedNum1 then
                                var.curPanel:getWidgetByName("label_have_stone_1"):setColor(cc.c3b(231, 3, 1))
                                var.curPanel:getWidgetByName("label_need_stone_1"):setColor(cc.c3b(231, 3, 1))
                            else
                                var.curPanel:getWidgetByName("label_have_stone_1"):setColor(cc.c3b(255, 255, 255))
                                var.curPanel:getWidgetByName("label_need_stone_1"):setColor(cc.c3b(18, 207, 40))
                            end
                            if needitem_num2 < itemdef.mAdvNeedNum2 then
                                var.curPanel:getWidgetByName("label_have_stone_2"):setColor(cc.c3b(231, 3, 1))
                                var.curPanel:getWidgetByName("label_need_stone_2"):setColor(cc.c3b(231, 3, 1))
                            else
                                var.curPanel:getWidgetByName("label_have_stone_2"):setColor(cc.c3b(255, 255, 255))
                                var.curPanel:getWidgetByName("label_need_stone_2"):setColor(cc.c3b(18, 207, 40))
                            end
                            var.curPanel:getWidgetByName("label_need_stone_1"):setString("/"..itemdef.mAdvNeedNum1)
                            var.curPanel:getWidgetByName("label_have_stone_1"):setString(needitem_num1)
                            var.curPanel:getWidgetByName("label_need_stone_2"):setString("/"..itemdef.mAdvNeedNum2)
                            var.curPanel:getWidgetByName("label_have_stone_2"):setString(needitem_num2)
                            local nextID = game.calc_advance_item_type(ni.mTypeID)
                            local nextItemdef = NetClient:getItemDefByID(nextID)
                            if nextItemdef then
                                local richLabelStr = ""
                                if nextItemdef.mColorRangeL > 0 and nextItemdef.mColorRange > 0 then
                                    if itemdef.mDC > 0 and itemdef.mDCMax > 0 then--加物攻
                                        richLabelStr = richLabelStr.."<font color='#D4C08B'>物理攻击：</font>"
                                        ..itemdef.mDC+itemdef.mColorRangeL.."-"..itemdef.mDCMax+itemdef.mColorRange
                                        .."<font color='#12CF28'> → "
                                        ..itemdef.mDC+nextItemdef.mColorRangeL.."-"..itemdef.mDCMax+nextItemdef.mColorRange.."</font><br>"
                                    end
                                    if itemdef.mMC > 0 and itemdef.mMCMax > 0 then--加魔攻
                                        richLabelStr = richLabelStr.."<font color='#D4C08B'>魔法攻击：</font>"
                                        ..itemdef.mMC+itemdef.mColorRangeL.."-"..itemdef.mMCMax+itemdef.mColorRange
                                        .."<font color='#12CF28'> → "
                                        ..itemdef.mMC+nextItemdef.mColorRangeL.."-"..itemdef.mMCMax+nextItemdef.mColorRange.."</font><br>"
                                    end
                                    if itemdef.mSC > 0 and itemdef.mSCMax > 0 then--加道攻
                                        richLabelStr = richLabelStr.."<font color='#D4C08B'>道术攻击：</font>"
                                        ..itemdef.mSC+itemdef.mColorRangeL.."-"..itemdef.mSCMax+itemdef.mColorRange
                                        .."<font color='#12CF28'> → "
                                        ..itemdef.mSC+nextItemdef.mColorRangeL.."-"..itemdef.mSCMax+nextItemdef.mColorRange.."</font><br>"
                                    end
                                    local richLabel, richWidget = util.newRichLabel(cc.size(400, 0), 0)
                                    var.qhRichWidget = richWidget
                                    util.setRichLabel(richLabel, richLabelStr, "panel_smelter", 28)
                                    richLabel:setPosition(cc.p(-200,richLabel:getRealHeight()/2))
                                    var.curPanel:getWidgetByName("label_wg"):show():addChild(var.qhRichWidget)
                                else
                                    NetClient:dispatchEvent(
                                    {
                                        name = Notify.EVENT_ITEM_SELECT,
                                        pos = pos,
                                        visible = false
                                    })
                                    NetClient:alertLocalMsg("该装备已满阶！","alert")
                                    PanelSmelter.cleanSJPanel()
                                    return
                                end
                            elseif not nextItemdef then
                                NetClient:alertLocalMsg("该装备不能进阶！","alert")
                                PanelSmelter.cleanSJPanel()
                                return
                            end
                            var.curPanel:getWidgetByName("Button_advance"):addClickEventListener(function (pSender)
                                if var.curSelectItem then
                                    local needSuc = (var.curPanel:getWidgetByName("auto_buy_box"):isSelected() and 1 or 0)
                                    NetClient:PushLuaTable("newgui.equipadvance.OnAdvanceLua",util.encode({actionid = "beginAdvance",position=pos,needYB=needSuc}))
                                else
                                    NetClient:alertLocalMsg("请放入装备","alert")
                                end
                            end)
                        else
                            local initItemQuality = game.calc_item_quality(ni.mTypeID)
                            if initItemQuality >= 6 then
                                NetClient:alertLocalMsg("装备已满阶","alert")
                            else
                                NetClient:alertLocalMsg("该装备不能进阶！","alert")
                            end
                            PanelSmelter.cleanSJPanel()
                        end
                    end
                end
            elseif var.rightSelectTab == 2 then--升阶面板（转移页签）
                if var.item_data and var.curPanel then
                    
                    var.curPanel:getWidgetByName("Button_transfer"):addClickEventListener(function (pSender)
                        if var.mTransferIcon[1] and var.mTransferIcon[2] then
                            NetClient:PushLuaTable("newgui.equipadvtransfer.OnAdvTranLua",util.encode({actionid = "beginadvancetransfer",position1=var.mTransferIcon[1],position2=var.mTransferIcon[2]}))
                        else
                            NetClient:alertLocalMsg("请放入不同品质的装备","alert")
                        end
                    end)
                    if not var.mTransferIcon[1] then
                        var.curPanel:getWidgetByName("item_zy_bg_1"):removeAllChildren()
                        var.curPanel:getWidgetByName("img_item_info_1"):hide()
                        UIItem.getItem({
                            parent = var.curPanel:getWidgetByName("item_zy_bg_1"),
                            pos = pos,
                            itemCallBack = function (pSender)
                                if pSender and pSender.itemIcon then
                                    NetClient:dispatchEvent(
                                    {
                                        name = Notify.EVENT_ITEM_SELECT,
                                        pos = pSender.itemIcon.itemPos,
                                        visible = false
                                    })
                                    pSender:removeAllChildren()
                                    var.mTransferIcon[1] = nil
                                    var.curPanel:getWidgetByName("label_need_gold_transfer"):setString("0")
                                    var.curPanel:getWidgetByName("img_item_info_1"):show()
                                end
                            end
                        })
                        var.mTransferIcon[1] = pos
                        return
                    end
                    if not var.mTransferIcon[2] then
                        if var.mTransferIcon[1] then
                            local item1 = NetClient:getNetItem(var.mTransferIcon[1])
                            if item1 then
                                local item_quality_1 = game.calc_item_quality(item1.mTypeID)
                                local item_quality_2 = game.calc_item_quality(ni.mTypeID)
                                --"请放入不同强化等级的装备"
                                if item_quality_1 ~= item_quality_2 then
                                    var.curPanel:getWidgetByName("item_zy_bg_2"):removeAllChildren()
                                    var.curPanel:getWidgetByName("img_item_info_2"):hide()
                                    UIItem.getItem({
                                        parent = var.curPanel:getWidgetByName("item_zy_bg_2"),
                                        pos = pos,
                                        itemCallBack = function (pSender)
                                            if pSender and pSender.itemIcon then
                                                NetClient:dispatchEvent(
                                                {
                                                    name = Notify.EVENT_ITEM_SELECT,
                                                    pos = pSender.itemIcon.itemPos,
                                                    visible = false
                                                })
                                                pSender:removeAllChildren()
                                                var.mTransferIcon[2] = nil
                                                var.curPanel:getWidgetByName("label_need_gold_transfer"):setString("0")
                                                var.curPanel:getWidgetByName("img_item_info_2"):show()
                                            end
                                        end
                                    })
                                    var.mTransferIcon[2] = pos
                                    local transferInfo = var.item_data.advancetransferinfo
                                    local maxLevel = math.max(item_quality_1,item_quality_2)
                                    local temp = transferInfo.cost[maxLevel]
                                    if temp then
                                        if tonumber(temp) >= NetClient.mCharacter.mGameMoneyBind then
                                            var.curPanel:getWidgetByName("label_need_gold_transfer"):setColor(cc.c3b(231, 3, 1))
                                        else
                                            var.curPanel:getWidgetByName("label_need_gold_transfer"):setColor(cc.c3b(18, 207, 40))
                                        end
                                        var.curPanel:getWidgetByName("label_need_gold_transfer"):setString(temp)
                                    end
                                else
                                    NetClient:dispatchEvent(
                                    {
                                        name = Notify.EVENT_ITEM_SELECT,
                                        pos = pos,
                                        visible = false
                                    })
                                    NetClient:alertLocalMsg("请放入不同品质的装备","alert")
                                    return
                                end
                            end
                        end
                    else
                        NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = pos,
                            visible = false
                        })
                    end
                end
            end
        end
    else
        if var.selectTab == 1 then--强化面板
            if var.rightSelectTab == 1 then--强化面板（强化页签）
                if var.qhRichWidget then
                    var.qhRichWidget:removeFromParent()
                    var.qhRichWidget = nil
                end
                for i=1,12 do
                    var.curPanel:getWidgetByName("qh_star_"..i):setBright(false)
                end
                var.curPanel:getWidgetByName("qh_success_bg"):hide()
                var.curPanel:getWidgetByName("text_need_xj"):hide()
                var.curPanel:getWidgetByName("text_need_gold"):hide()
                var.curPanel:getWidgetByName("label_auto_buy"):hide()
                var.curPanel:getWidgetByName("item_qh_bg"):removeAllChildren()
                var.curPanel:getWidgetByName("img_item_info"):show()
            end
        end
    end
end

function PanelSmelter.onPanelClose()
    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.QIANGHUA) then
        UIButtonGuide.setGuideEnd(UIButtonGuide.GUILDTYPE.QIANGHUA)
    end
end

function PanelSmelter.canUpgradeEquip(typeId)
    if typeId == 30101 or typeId == 35101 or typeId == 20201 or typeId == 20202 or typeId == 20203 then
        return false
    end
    return true
end

function PanelSmelter.showSucessEffect(parent,pos,img_path)
    var.mEffectSprite = gameEffect.playEffectByType(gameEffect.EFFECT_UPGRADE_SUCC, {removeSelf=true,
        onShowAlert=function ()
            if var.mEffectSprite then
                local img_result = ccui.ImageView:create()
                img_result:loadTexture(img_path,UI_TEX_TYPE_PLIST)
                img_result:setPosition(cc.p(var.mEffectSprite:getContentSize().width/2,var.mEffectSprite:getContentSize().height/2))
                img_result:setName("result")
                var.mEffectSprite:addChild(img_result)
            end
        end,
        onComplete=function ()
            var.mEffectSprite=nil
        end
    })
    var.mEffectSprite:setPosition(pos):addTo(parent)--var.curPanel:getWidgetByName("panel_qh_bg") cc.p(296,440) "qianghuachenggong.png"
end

return PanelSmelter