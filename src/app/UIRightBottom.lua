
local UIRightBottom={}

local var = {}
local kuang_tab = {{15389,2000},{15388,4000},{15392,6000},{15393,10000}}
local MENU_CONFIG = {
    -- row1
    { btn = "Button_role", panel = "panel_roleInfo", cp = cc.p(80, 216),
        redtypes={UIRedPoint.REDTYPE.SKILL,UIRedPoint.REDTYPE.YUANSHEN,UIRedPoint.REDTYPE.NEIGONG,UIRedPoint.REDTYPE.ROLEREBORN},
        guildtypes={UIButtonGuide.GUILDTYPE.SKILL,}},
    { btn = "Button_friend", panel = "panel_friend", cp = cc.p(161, 216)},
    { funcid = GuideDef.FUNCID_ZHANSHEN, btn = "Button_zhanshen", panel = "panel_zhanshen", cp = cc.p(244, 216),
        redtypes={UIRedPoint.REDTYPE.ZHANSHEN,UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE1,UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE2,UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE3,UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE4},
        guildtypes={UIButtonGuide.GUILDTYPE.ZHANSHEN},uitype=UIButtonGuide.UI_TYPE_LEFT},
    -- row2
    {funcid = GuideDef.FUNCID_QIANGHUA, btn = "Button_smelter", panel = "panel_smelter", cp = cc.p(80, 134),guildtypes={UIButtonGuide.GUILDTYPE.QIANGHUA}},
    { funcid = GuideDef.FUNCID_SHENLU, btn = "Button_shenlu", panel = "panel_shenlu", cp = cc.p(161, 134),
        redtypes={UIRedPoint.REDTYPE.JIANJIA,UIRedPoint.REDTYPE.BAOSHI,UIRedPoint.REDTYPE.DUNPAI,UIRedPoint.REDTYPE.ANQI,UIRedPoint.REDTYPE.YUXI},
        guildtypes={UIButtonGuide.GUILDTYPE.SHENLU},uitype=UIButtonGuide.UI_TYPE_LEFT},
    { funcid = GuideDef.FUNCID_CHENGJIU, btn = "Button_chengjiu", panel = "panel_achieve", cp = cc.p(244, 134),
        redtypes={UIRedPoint.REDTYPE.ACHIEVE,UIRedPoint.REDTYPE.ACHIEVE1,UIRedPoint.REDTYPE.ACHIEVE2,UIRedPoint.REDTYPE.ACHIEVE3,UIRedPoint.REDTYPE.ACHIEVE4,UIRedPoint.REDTYPE.ACHIEVE5,UIRedPoint.REDTYPE.ACHIEVE6},guildtypes={UIButtonGuide.GUILDTYPE.CHENGJIU,}},
    -- row3
    { funcid = GuideDef.FUNCID_GUILD,btn = "Button_guild", panel = "panel_guild", cp = cc.p(80, 56),redtypes={UIRedPoint.REDTYPE.GUILD_FULI,UIRedPoint.REDTYPE.GUILD_APPLY,UIRedPoint.REDTYPE.GUILD_SKILL,UIRedPoint.REDTYPE.GUILD_LEVEL,UIRedPoint.REDTYPE.GUILD_UNION,}},
    { funcid = GuideDef.FUNCID_WING, btn = "Button_wing", panel = "panel_wing", cp = cc.p(161, 56),redtypes={UIRedPoint.REDTYPE.WING},guildtypes={UIButtonGuide.GUILDTYPE.WING,}},
    { funcid = GuideDef.FUNCID_SHENQI, btn = "Button_shenqi", panel = "panel_shenqi", cp = cc.p(244, 56),guildtypes={UIButtonGuide.GUILDTYPE.SHENQI,}},
--
--
--    { btn = "Button_mail", panel = "panel_mail", cp = cc.p(80, 56),redtypes={UIRedPoint.REDTYPE.NEWMAIL}},
--    { btn = "Button_chart", panel = "panel_chart", cp = cc.p(161, 56)},
--    { btn = "Button_seting", panel = "panel_setting", cp = cc.p(244, 56)},

}

function UIRightBottom.init_ui(rightBottom)
	var = {
		sIcon = {},
        menuBtn = {},
        totalPage = 2,
        curPage = 1,
        curMenuPage = 1,
        showSkill = true
    }
	var.widget = rightBottom:getChildByName("Panel_rightbottom")
    var.widget:align(display.RIGHT_BOTTOM, Const.VISIBLE_WIDTH, 0):setScale(Const.minScale)

    var.widget:getWidgetByName("Image_autofight"):setLocalZOrder(100)
    var.widget:getWidgetByName("btn_autofight"):setLocalZOrder(90)
    var.widget:getWidgetByName("btn_autofight"):addClickEventListener(function ( pSender )
        MainRole.handleAutoKillOn(not MainRole.m_isAutoKillMonster)
    end)

    var.btnMenu = UIRedPoint.addUIPoint({
        parent=var.widget:getWidgetByName("Button_menu"),
        types={UIRedPoint.REDTYPE.SKILL,UIRedPoint.REDTYPE.YUANSHEN,UIRedPoint.REDTYPE.WING ,UIRedPoint.REDTYPE.NEIGONG,UIRedPoint.REDTYPE.ZHANSHEN,
            UIRedPoint.REDTYPE.JIANJIA,UIRedPoint.REDTYPE.BAOSHI,UIRedPoint.REDTYPE.DUNPAI,UIRedPoint.REDTYPE.ANQI,UIRedPoint.REDTYPE.YUXI,
            UIRedPoint.REDTYPE.NEWMAIL,UIRedPoint.REDTYPE.ACHIEVE,UIRedPoint.REDTYPE.ROLEREBORN}
    })
    var.btnMenu:addClickEventListener(function ( pSender )
        UIRightBottom.onSwitchMenuAndSkill()
    end)

    var.widget:getWidgetByName("Button_sell"):addClickEventListener(function (pSender)
        local recycle_tem_tab = {}
        for i=1,4 do
            local pos_tab = NetClient:getItemPosById(kuang_tab[i][1])
            for j=1,#pos_tab do
                table.insert(recycle_tem_tab,{pos=pos_tab[j]})
            end
        end
        NetClient:PushLuaTable("bag",util.encode({actionid = "do_recycle_item", panelid = "recycle_equip", params = recycle_tem_tab}))
    end)

    UIRightBottom.init_ui_menu_new()
    UIRightBottom.init_ui_attack()
    UIRightBottom.init_ui_kuang()
    UIRightBottom.updateItemUseBtn()
    UIRightBottom.handleUpdateExp()
    UIRightBottom.registeEvent()
end

function UIRightBottom.handleUpdateExp( event )
    if NetClient.mCharacter.mCurExperience and NetClient.mCharacter.mCurrentLevelMaxExp then
        local pp = NetClient.mCharacter.mCurExperience/NetClient.mCharacter.mCurrentLevelMaxExp*100
        var.widget:getWidgetByName("ImageView_expbar_bg"):getWidgetByName("LoadingBar_expbar"):setPercent(pp)
        var.widget:getWidgetByName("Text_exp_bar"):setString(NetClient.mCharacter.mCurExperience.."/"..NetClient.mCharacter.mCurrentLevelMaxExp.."("..string.format("%0.2f", pp).."%)")
    end
end

function UIRightBottom.init_ui_kuang()

    if NetClient.mNetMap and NetClient.mNetMap.mMapID == "kuangdong" then
        var.widget:getWidgetByName("Panel_kuang"):show()
        local all_price = 0
        for i=1,4 do
            local item_num = NetClient:getNetItemNumberById(kuang_tab[i][1])
            var.widget:getWidgetByName("num_kuang_"..i):setString(item_num)
            all_price = all_price + item_num*kuang_tab[i][2]
        end
        var.widget:getWidgetByName("label_all_price"):setString(all_price)

    else
        var.widget:getWidgetByName("Panel_kuang"):hide()
    end
end

function UIRightBottom.init_ui_attack()
    var.skillLayer = var.widget:getWidgetByName("Panel_attack")
    var.skillLayer:setTouchEnabled(true)
    var.skillLayer:addTouchEventListener(function(sender,touchType)
        if touch_type == ccui.TouchEventType.began then
        elseif touchType == ccui.TouchEventType.moved then
        elseif touchType == ccui.TouchEventType.canceled or touchType == ccui.TouchEventType.ended then
            if sender:getTouchBeganPosition().x < sender:getTouchEndPosition().x then
                if sender:getTouchEndPosition().x - sender:getTouchBeganPosition().x > 10 then
                    UIRightBottom.onChangePage(-1)
                end
            elseif sender:getTouchBeganPosition().x > sender:getTouchEndPosition().x then
                if sender:getTouchBeganPosition().x - sender:getTouchEndPosition().x > 10 then
                    UIRightBottom.onChangePage(1)
                end
            end
        end
    end)

    var.btnLayer = var.skillLayer:getWidgetByName("Panel_rotate")
    for i=1,8 do

        local btnLayer = var.btnLayer
        var.sIcon[i] = btnLayer:getWidgetByName("skillBox_"..i)
        var.sIcon[i]:getWidgetByName("Text_debug"):hide()
        var.sIcon[i].bg = var.sIcon[i]:getWidgetByName("skillImg")
        var.sIcon[i].bg.tag = i
        var.sIcon[i].bg.firstTouched = true

        var.sIcon[i].icon = var.sIcon[i]:getWidgetByName("shortcut")

        var.sIcon[i].lock = var.sIcon[i]:getWidgetByName("shortlock")
        var.sIcon[i].lock:hide()

        var.sIcon[i].mark = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("skill_mark_circle.png")))
        :align(display.LEFT_BOTTOM, 0, 0)
        :addTo(var.sIcon[i].icon, 100)
        var.sIcon[i].mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
        var.sIcon[i].mark:setReverseDirection(true)
        var.sIcon[i].mark.tag = i

        var.sIcon[i].isCD = false
        var.sIcon[i].icon:ignoreContentAdaptWithSize(true)
        var.sIcon[i].bg:addTouchEventListener(UIRightBottom.pushMainSkill)
        var.sIcon[i].bg:setSwallowTouches(false)
    end

    var.skillLayer:getWidgetByName("Button_attack"):addTouchEventListener(function ( pSender,event_type )
    -- MainRole.startCastSkill(MainRole.getAiSkill())
        local touchMoved = false
        local movedDis = 0
        if event_type == ccui.TouchEventType.ended or event_type == ccui.TouchEventType.canceled then
            local posbeganY = pSender:getTouchBeganPosition().y
            local posendY = pSender:getTouchEndPosition().y
            if math.abs(posendY - posbeganY) > 10 then
                touchMoved = true
                movedDis = posendY - posbeganY
                if movedDis > 0 then--上划找玩家
                    MainRole.selectNearPlayer(false,true)
                else--下划找怪物
                    MainRole.selectNearMonster()
                end
            end
            if not touchMoved then
                MainRole.stopAutoMove()
                local mAimGhost = CCGhostManager:getPixesGhostByID(MainRole.mAimGhostID)
                if NetClient.mAttackMode ~= 101 and (not mAimGhost) then
                    MainRole.selectNearPlayer(true,false)
                end
                MainRole.attackNearGhost()
            end
        end
    end)




    var.btnNext = var.widget:getWidgetByName("Button_next")
    var.btnNext:setTouchEnabled(false)
--    var.btnNext:addClickEventListener(function(pSender)
--        UIRightBottom.onChangePage(1)
--    end)

    var.btnPre = var.skillLayer:getWidgetByName("Button_pre")
    var.btnPre:setTouchEnabled(false)
--    var.btnPre:addClickEventListener(function(pSender)
--        pSender:setTitleText(var.curPage == 1 and 2 or 1)
--        UIRightBottom.onChangePage(-1)
--    end)

    UIRightBottom.updateArrow()
    UIRightBottom.handleShortcutChange()
end

--function UIRightBottom.onMenuBtnClicked(pSender)
--    local btnName =  pSender:getName()
--    if btnName == "menulImg_1" then
--        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_skill"})
--    elseif btnName == "menulImg_2" then
--        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_friend"})
--    elseif btnName == "menulImg_3" then
--        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_guild"})
--    elseif btnName == "menulImg_4" then
--        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group"})
--    end
--end

--function UIRightBottom.init_ui_menu()
--    var.menuLayer = var.widget:getWidgetByName("Panel_menu"):hide()
--    for i=1,8 do
--        var.menuBtn[i] = var.menuLayer:getWidgetByName("menuBox_"..i)
--        var.menuBtn[i]:getWidgetByName("menulImg_"..i):addClickEventListener(UIRightBottom.onMenuBtnClicked)
--    end
--    UIRightBottom.changeMenu()
--    var.menuLayer:getWidgetByName("Button_fresh")
--   :addClickEventListener(function(pSender)
--        var.curMenuPage = (var.curMenuPage == 1 and 2 or 1)
--        UIRightBottom.changeMenu()
--    end)
--end

function UIRightBottom.init_ui_menu_new()
    var.menuLayer = var.widget:getWidgetByName("Panel_menu_new"):hide()
    var.menuLayer:setLocalZOrder(100)
    for _, v in ipairs(MENU_CONFIG) do
        local callback = function(pSender)
            UIButtonGuide.handleButtonGuideClicked(pSender)
            var.showGuildFlag = false
            if (v.funcid and not game.isFuncOpen(v.funcid)) or  game.getFuncOpenLevel(v.funcid) > game.getRoleLevel() then
                NetClient:alertLocalMsg(game.getFuncOpenLevel(v.funcid).."级开启","alert")
                return
            end

            if v.panel ~= "" then
                EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = v.panel})
            else
                print("TODO 增加配置")
            end

        end
        local btn = UIRedPoint.addUIPoint({parent=var.menuLayer:getWidgetByName(v.btn), position=cc.p(70,70), types=v.redtypes,callback = callback})
        if (v.funcid and not game.isFuncOpen(v.funcid)) or  game.getFuncOpenLevel(v.funcid) > game.getRoleLevel() then
            btn:setBright(false)
        else
            btn:setBright(true)
        end
    end
end

function UIRightBottom.handleFuncChange(event )
    for _, v in ipairs(MENU_CONFIG) do
        local btn = var.menuLayer:getWidgetByName(v.btn)
        if (v.funcid and not game.isFuncOpen(v.funcid)) or  game.getFuncOpenLevel(v.funcid) > game.getRoleLevel() then
            btn:setBright(false)
            btn:hide()
        else
            btn:show()
            btn:setBright(true)
        end
    end
end

--function UIRightBottom.changeMenu()
--    for k, v in ipairs(var.menuBtn) do
--        if k < 5 then
--            v:setVisible(var.curMenuPage == 1)
--        else
--            v:setVisible(var.curMenuPage == 2)
--        end
--    end
--end

function UIRightBottom.handleMapEnter()
    UIRightBottom.init_ui_kuang()
end

function UIRightBottom.handleItemChange(event)
    if event and event.pos then
        local item = NetClient:getNetItem(event.pos)
        if item then
            if item.mTypeID == kuang_tab[1][1] or item.mTypeID == kuang_tab[2][1]
                or item.mTypeID == kuang_tab[3][1] or item.mTypeID == kuang_tab[4][1] then
                UIRightBottom.init_ui_kuang()
            end
        end
    end

    if event then
        UIRightBottom.updateItemUseBtn()
    end
end

function UIRightBottom.updateItemUseBtn(idx)
    if not var.itemUseBtn then
        function onUseItem(pSender)
            if pSender.num and pSender.num > 0 then
                NetClient:BagUseItem(pSender.position, pSender.mTypeID)
            else
                if pSender.tag == 1 then
                    local data ={}
                    for k, v in ipairs(Const.MAIN_UI_ITEM) do
                        if v.id == pSender.mTypeID then
                            data.typeid = v.id
                            data.sellyb = v.sellyb
                            data.priceflag = v.priceflag
                            data.bindflag = v.bindflag or 0
                        end
                    end
                    game.showQuickByPanel(data)
                    NetClient:alertLocalMsg("没有"..pSender.name..",请前往商城购买")
                else
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag",  pdata = {tag = 4}})
                    NetClient:alertLocalMsg("没有"..pSender.name..",请前往随身商店购买")
                end
            end
        end
        var.itemUseBtn = {}
        var.itemUseBtn[1] = var.widget:getWidgetByName("Button_gohome")
        var.itemUseBtn[2] = var.widget:getWidgetByName("Button_addhp")
        var.itemUseBtn[1]:addClickEventListener(onUseItem)
        var.itemUseBtn[2]:addClickEventListener(onUseItem)
        for k, v in ipairs(Const.MAIN_UI_ITEM) do
            local itemdef = NetClient:getItemDefByID(v.id)
            if itemdef then
                if var.itemUseBtn[k] then
                    var.itemUseBtn[k]:getWidgetByName("Image_icon"):ignoreContentAdaptWithSize(true)
                    var.itemUseBtn[k]:getWidgetByName("Image_icon"):loadTexture("icon/"..itemdef.mIconID..".png")--:setScale(1.5)
                    var.itemUseBtn[k].mTypeID = v.id
                    var.itemUseBtn[k].name = v.name
                    var.itemUseBtn[k].tag = k
                end
            end
        end
    end

    if idx then
        local btn = var.itemUseBtn[idx]
        if btn then
            btn.position = NetClient:getItemBagPosById(btn.mTypeID)
            btn.num = NetClient:getBagItemNumberById(btn.mTypeID)
            btn:getWidgetByName("Text_num"):setString(btn.num):setVisible(btn.num>1)
            btn:setBright(btn.num>0)
            btn:getWidgetByName("Image_icon"):getVirtualRenderer():setState(btn.num>0 and 0 or 1)
        end
    else
        for k, btn in ipairs(var.itemUseBtn) do
            btn.position = NetClient:getItemBagPosById(btn.mTypeID)
            btn.num = NetClient:getBagItemNumberById(btn.mTypeID)
            btn:getWidgetByName("Text_num"):setString(btn.num):setVisible(btn.num>1)
            btn:setBright(btn.num>0)
            btn:getWidgetByName("Image_icon"):getVirtualRenderer():setState(btn.num>0 and 0 or 1)
        end
    end
end

function UIRightBottom.handleRecyleMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == "bag" then
        if d.actionid then
            if d.actionid == "recyle_success" then
                UIRightBottom.init_ui_kuang()
            end
        end
    end
end

function UIRightBottom.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_SKILL_COOLDOWN,UIRightBottom.handleSkillCD)
    :addEventListener(Notify.EVENT_SKILL_STATE,UIRightBottom.freshCisha)
    :addEventListener(Notify.EVENT_SHORTCUT_CHANGE,UIRightBottom.handleShortcutChange)
    :addEventListener(Notify.EVENT_EXP_CHANGE, UIRightBottom.handleUpdateExp)
    :addEventListener(Notify.EVENT_OPEN_SYSTEM, UIRightBottom.handleFuncChange)
    :addEventListener(Notify.EVENT_MAP_ENTER, UIRightBottom.handleMapEnter)
    :addEventListener(Notify.EVENT_ITEM_CHANGE, UIRightBottom.handleItemChange)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, UIRightBottom.handleRecyleMsg)
    :addEventListener(Notify.EVENT_BUTTON_GUILD_SHOW, UIRightBottom.handleButtonGuildShow)
    :addEventListener(Notify.EVENT_SKILL_USED, UIRightBottom.handleSkillUsed)
    :addEventListener(Notify.EVENT_HANDLE_FLOATING, UIRightBottom.handleAutofightEffect)
end

function UIRightBottom.getIconStr(cutinfo)
    if cutinfo.type == Const.ShortCutType.Skill then
        return "skill"..cutinfo.param..".png",UI_TEX_TYPE_PLIST
    elseif cutinfo.type == Const.ShortCutType.Item then
        local itemdef = NetClient:getItemDefByID(cutinfo.param)
        if itemdef then
            return "icon/"..itemdef.mIconID..".png",UI_TEX_TYPE_LOCAL
        end
    end
    print("快捷键错误", cutinfo.type, cutinfo.param)
    return ""
end

function UIRightBottom.handleAutofightEffect(event)
    if event and event.btn then
        if event.btn == "main_auto_fight" then
            if event.visible then
                if not var.autoBtnEffect then
                    var.autoBtnEffect = gameEffect.getPlayEffect(gameEffect.EFFECT_MAINACTIVEBTN)
                    var.autoBtnEffect:setPosition(cc.p(var.widget:getWidgetByName("btn_autofight"):getContentSize().width/2-1,var.widget:getWidgetByName("btn_autofight"):getContentSize().height/2+4))
                    var.autoBtnEffect:addTo(var.widget:getWidgetByName("btn_autofight"))
                else
                    var.autoBtnEffect:show()
                end
            else
                if var.autoBtnEffect then
                    var.autoBtnEffect:removeFromParent()
                    var.autoBtnEffect = nil
                end
            end
        end
    end
end

function UIRightBottom.handleShortcutChange()
    for i = 1, 8 do
        var.sIcon[i].cdgroup = 0
        var.sIcon[i].icon:hide()
        if var.sIcon[i].lock:getChildByName("openeffect") then
            var.sIcon[i].lock:removeChildByName("openeffect")
        end
    end

    for cut_id, cutinfo in pairs(NetClient.mShortCut) do
        local sicon = var.sIcon[cut_id]
        if cutinfo.type == Const.ShortCutType.Skill then
            sicon.cdgroup = NetClient:getSkillCDGroup(cutinfo.param)
            sicon.icon:loadTexture(UIRightBottom.getIconStr(cutinfo))
        else
            sicon.icon:loadTexture(UIRightBottom.getIconStr(cutinfo))
        end
        sicon.icon:show()
        if cutinfo.type == Const.ShortCutType.Skill then
            local visible = NetClient:isSkillOpen(cutinfo.param)
            sicon.lock:setVisible(visible)
            if visible then UIRightBottom.addOpenEffect(sicon.lock) end
        elseif cutinfo.type == Const.ShortCutType.Item then
            local num = NetClient:getBagItemNumberById(cutinfo.param)
            if num < 1 then
                sicon.icon:setColor(cc.c3b(127, 127, 127))
            end
        end

    end
end

function UIRightBottom.freshCisha(event)
    for i = 1, 8 do
        for cut_id, cutinfo in pairs(NetClient.mShortCut) do
            if cut_id == i and cutinfo.type == Const.ShortCutType.Skill then
                if var.sIcon[i].icon:isVisible() then
                    local visible = NetClient:isSkillOpen(cutinfo.param)
                    var.sIcon[i].lock:setVisible(visible)
                    UIRightBottom.addOpenEffect(var.sIcon[i].lock)
                end
            end
        end
    end
end

function UIRightBottom.addOpenEffect(parent)
    if not parent:isVisible()  then
        if parent:getChildByName("openeffect") then
            parent:removeChildByName("openeffect")
        end
        return
    end

    local openSprite = cc.Sprite:create()
    openSprite:setName("openeffect"):setPosition(cc.p(22,40))
    if cc.AnimManager:getInstance():getBinAnimateAsync(openSprite,4,"930007",0) then
        if parent:getChildByName("openeffect") then
            parent:removeChildByName("openeffect")
        end
        parent:addChild(openSprite)
    end
end

function UIRightBottom.pushMainSkill(pSender,touch_type)

	if not var.skillDrag then
		if var.sIcon[pSender.tag].isCD then print("skill is cding ") return end
		if touch_type == ccui.TouchEventType.began then
			pSender:runAction(cc.ScaleTo:create(0.3,0.95))

--			UIRightBottom.handleSkillName(pSender,true)
			
		elseif touch_type == ccui.TouchEventType.canceled then
--			UIRightBottom.handleSkillName(pSender)

			pSender:stopAllActions()
			pSender:runAction(
				cc.Sequence:create(
					cc.ScaleTo:create(0.2,1.05),
					cc.ScaleTo:create(0.2,1.0)
				)
			)
            if pSender:getTouchBeganPosition().x < pSender:getTouchEndPosition().x then
                if pSender:getTouchEndPosition().x - pSender:getTouchBeganPosition().x > 10 then
                    UIRightBottom.onChangePage(-1)
                end
            elseif pSender:getTouchBeganPosition().x > pSender:getTouchEndPosition().x then
                if pSender:getTouchBeganPosition().x - pSender:getTouchEndPosition().x > 10 then
                    UIRightBottom.onChangePage(1)
                end
            end
		elseif touch_type == ccui.TouchEventType.ended then
			pSender:stopAllActions()
			pSender:runAction(
				cc.Sequence:create(
					cc.ScaleTo:create(0.2,1.05),
					cc.ScaleTo:create(0.2,1.0)
				)
			)
			var.sIcon[pSender.tag].icon:stopAllActions()
			pSender.firstTouched = false

            if pSender:getTouchBeganPosition().x < pSender:getTouchEndPosition().x then
                if pSender:getTouchEndPosition().x - pSender:getTouchBeganPosition().x > 10 then
                    UIRightBottom.onChangePage(-1)
                end
            elseif pSender:getTouchBeganPosition().x > pSender:getTouchEndPosition().x then
                if pSender:getTouchBeganPosition().x - pSender:getTouchEndPosition().x > 10 then
                    UIRightBottom.onChangePage(1)
                end
            end

			UIRightBottom.startUseSkill(pSender.tag)
--			UIRightBottom.handleSkillName(pSender)
		end
	else
--		UIRightBottom.sortSkillButton(pSender,touch_type)
	end
end

--function UIRightBottom.handleSkillCD(event)
--	local function skillCoolDownCallBack(data)
--		var.sIcon[data.tag].mark:setVisible(false)
--		var.sIcon[data.tag].bg:setTouchEnabled(true)
--		var.sIcon[data.tag].isCD = false
--    end
--
--    if not event then return end
--    if event.type == Const.SKILL_TYPE_YiBanGongJi then return end
--
--
--	if event then
--		if event.type ~= Const.SKILL_TYPE_YiBanGongJi then
--            local yibancd = true
--			local cdtime = 0.6
--            local myjob = game.getRoleJob()
--			if myjob == Const.JOB_FS then
--                cdtime = 0.78
--            elseif myjob == Const.JOB_DS then
--                cdtime = 0.98
--			end
--			if game.isZsChongZhuangSkill(event.type) then
--				cdtime = 5
--                yibancd = false
--			elseif game.isLiehuoSkill(event.type) then
--				cdtime = 10
--                yibancd = false
--				MainRole.mLiehuoCdTime = game.getTime()
--			end
--
--			if yibancd then
--				for i=1,8 do
--					if NetClient.mShortCut[i] and NetClient.mShortCut[i].type == Const.ShortCutType.Skill then
--						var.sIcon[i].isCD = true
--						var.sIcon[i].bg:setTouchEnabled(false)
--                        if NetClient.mShortCut[i].param == event.type then
--                            var.sIcon[i].mark:setVisible(true)
--                            var.sIcon[i].mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
--                            var.sIcon[i].mark:runAction(cc.Sequence:create(cc.ProgressFromTo:create(cdtime,100,0),cc.CallFunc:create(skillCoolDownCallBack)))
--                        else
--                            var.sIcon[i].mark:runAction(cc.Sequence:create(cc.DelayTime:create(cdtime),cc.CallFunc:create(skillCoolDownCallBack)))
--                        end
--					end
--				end
--            else
--				for i=1,8 do
--					if NetClient.mShortCut[i] and NetClient.mShortCut[i].type == Const.ShortCutType.Skill and NetClient.mShortCut[i].param == event.type then
--						var.sIcon[i].isCD = true
--						--var.sIcon[i].mark:setVisible(true)
--						var.sIcon[i].bg:setTouchEnabled(false)
--                        if NetClient.mShortCut[i].param == event.type then
--                            var.sIcon[i].mark:setVisible(true)
--                            var.sIcon[i].mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
--                            var.sIcon[i].mark:runAction(cc.Sequence:create(cc.ProgressFromTo:create(cdtime,100,0),cc.CallFunc:create(skillCoolDownCallBack)))
--                        else
--                            var.sIcon[i].mark:runAction(cc.Sequence:create(cc.DelayTime:create(cdtime),cc.CallFunc:create(skillCoolDownCallBack)))
--                        end
--						--var.sIcon[i].mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
--						--var.sIcon[i].mark:runAction(cc.Sequence:create(cc.ProgressFromTo:create(cdtime,100,0),cc.CallFunc:create(skillCoolDownCallBack)))
--					end
--				end
--			end
--		end
--	end
--end

function UIRightBottom.handleSkillCD(event)
    local function skillCoolDownCallBack(data)
        var.sIcon[data.tag].mark:setVisible(false)
        var.sIcon[data.tag].bg:setTouchEnabled(true)
        var.sIcon[data.tag].isCD = false
    end

    if not event then return end
    if event.type == Const.SKILL_TYPE_YiBanGongJi then return end
    local cdtime = event.cd or 10

    for i=1,8 do
        if NetClient.mShortCut[i] and NetClient.mShortCut[i].type == Const.ShortCutType.Skill then
            if NetClient.mShortCut[i].param == event.type or (event.group > 0 and var.sIcon[i].cdgroup == event.group) then
                var.sIcon[i].isCD = true
                var.sIcon[i].bg:setTouchEnabled(false)
                var.sIcon[i].mark:setVisible(true)
                var.sIcon[i].mark:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
                var.sIcon[i].mark:runAction(cc.Sequence:create(cc.ProgressFromTo:create(cdtime,100,0),cc.CallFunc:create(skillCoolDownCallBack)))
            end
        end
    end
end

function UIRightBottom.handleSkillName(pSender,visible)
	if var.skillShortInfo then
		var.skillShortInfo:removeFromParent()
		var.skillShortInfo = nil
	end

	if visible then
		local skillName = ""
        if NetClient.mShortCut[pSender.tag] then
            local skillId = NetClient.mShortCut[pSender.tag].param
            local skillDef = NetClient:getSkillDefByID(skillId)
            if skillId and skillDef then
                skillName = skillDef.mName
            end
        end

		local addPosX = -50
		if not var.normalSide then 
			addPosX = 50
		end
		var.skillShortInfo = util.newUILabel({
			text = skillName,
			color = cc.c3b(255,0,0),
			fontSize = 30,
			position = cc.p(pSender:getPositionX()+addPosX,pSender:getPositionY()+50),
			opacity = 0,
		})
		var.widget:addChild(var.skillShortInfo)
	end
	
end

function UIRightBottom.startUseSkill(tag)
    local cutinfo = NetClient.mShortCut[tag]
    if not  cutinfo or not cutinfo.param then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_skill_setting"})
        return
    end

    if cutinfo.type == Const.ShortCutType.Skill then
        MainRole.stopAutoMove()
        if UIRightBottom.isSkill2Pos(cutinfo.param) then
            UIRightBottom.showSkillCircle(cutinfo.param,tag)
        else
            MainRole.startCastSkill(cutinfo.param)
        end
    elseif cutinfo.type == Const.ShortCutType.Item then
        UIRightBottom.startUseItem(cutinfo.param)
    end
end

function UIRightBottom.startUseItem(typeid)
    local num = NetClient:getBagItemNumberById(typeid)
    local pos = NetClient:getItemBagPosById(typeid)
    if num < 1 or not pos then
        NetClient:alertLocalMsg("背包无此物品", "alert")
    else
        NetClient:BagUseItem(pos, typeid)
    end
end

function UIRightBottom.updateArrow()
    var.btnPre:setVisible(var.curPage==1)
    var.btnNext:setVisible(var.curPage==2)
end

function UIRightBottom.onChangePage(flag)
    local page = var.curPage + flag
    if page > var.totalPage or page < 1 or flag == 0 then
        return
    end

    var.btnLayer:runAction( cc.Sequence:create( cc.RotateTo:create(0.2, (page- 1) * -90 ),cc.CallFunc:create(function()
        var.curPage = page
        UIRightBottom.updateArrow()
    end)) )
end

function UIRightBottom.onSwitchMenuAndSkill()
    if var.isRunAni then return end
    var.isRunAni = true
    if var.showSkill == nil  then var.showSkill = true end
    local t = 0.2
    if var.showSkill then
        var.btnMenu:getWidgetByName("Image_menu"):runAction(cc.RotateTo:create(t, 45 ))
        var.skillLayer:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.MoveTo:create(t, cc.p(300,0))),
            cc.CallFunc:create(function()
                var.skillLayer:hide()
                if var.btnMenu.point then
                    var.btnMenu.point:hide()
                end
                NetClient.RedMenuType = true
                UIRightBottom.showMenuBtnAni()
            end)
        ))
    else
        var.btnMenu:getWidgetByName("Image_menu"):runAction(cc.RotateTo:create(t, 0 ))
        var.menuLayer:runAction(cc.Sequence:create(
            cc.EaseSineOut:create(cc.MoveTo:create(t, cc.p(300,0))),
            cc.CallFunc:create(function()
                var.menuLayer:hide()
                NetClient.RedMenuType = false
                if var.btnMenu.point then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.SKILL,UIRedPoint.REDTYPE.YUANSHEN,UIRedPoint.REDTYPE.WING ,UIRedPoint.REDTYPE.NEIGONG,UIRedPoint.REDTYPE.ZHANSHEN,
                    UIRedPoint.REDTYPE.JIANJIA,UIRedPoint.REDTYPE.BAOSHI,UIRedPoint.REDTYPE.DUNPAI,UIRedPoint.REDTYPE.ANQI,UIRedPoint.REDTYPE.YUXI,
                    UIRedPoint.REDTYPE.NEWMAIL,UIRedPoint.REDTYPE.ACHIEVE,UIRedPoint.REDTYPE.ROLEREBORN})
                end
                var.skillLayer:setPositionX(300)
                var.skillLayer:show()
--                var.skillLayer:runAction(cc.EaseBackOut:create(cc.MoveTo:create(t, cc.p(0,0))))
                var.skillLayer:runAction(cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.MoveTo:create(t, cc.p(0,0))),
                    cc.CallFunc:create(function()
                        var.isRunAni = false
                    end)
                ))
            end)
        ))
    end

    var.showSkill = not var.showSkill
    UIButtonGuide.handleButtonGuideClicked(pSender)
    UIRightBottom.updateMenuTips()
end

function UIRightBottom.showMenuBtnAni()
--    -- 直接显示特效
--    var.menuLayer:show()
--    var.menuLayer:runAction(cc.Sequence:create(
--        cc.EaseExponentialOut:create(cc.MoveTo:create(0.2, cc.p(0,0))),
--        cc.CallFunc:create(function()
--            var.isRunAni = false
--        end)
--    ))

    -- 一列显示特效
    var.menuLayer:setPositionX(0)
    for _, v in ipairs(MENU_CONFIG) do
        local btn = var.menuLayer:getWidgetByName(v.btn)
        if btn then
            btn:setPositionX(400)
        end
    end
    var.menuLayer:show()
    for k, v in ipairs(MENU_CONFIG) do
        local btn = var.menuLayer:getWidgetByName(v.btn)
        if btn then
            local t = (k-1)%3 * 0.2 + 0.2
            btn:runAction(cc.Sequence:create(
                cc.EaseExponentialOut:create(cc.MoveTo:create(t, v.cp)),
                --                cc.EaseBackOut:create(cc.MoveTo:create(t, v.cp)),
                cc.CallFunc:create(function()
                    if btn.ismax then var.isRunAni = false end
                end)
            ))
            btn.ismax = (k == #MENU_CONFIG)
        end
    end

    UIRightBottom.handleFuncChange()

    -- 挨个显示特效
--    var.menuLayer:setPositionX(0)
--    for _, v in ipairs(MENU_CONFIG) do
--        local btn = var.menuLayer:getWidgetByName(v.btn)
--        if btn then
--            btn:setPositionX(400)
--        end
--    end
--    var.menuLayer:show()
--    local delay = 0
--    local t = 0.2
--    for k, v in ipairs(MENU_CONFIG) do
--        local btn = var.menuLayer:getWidgetByName(v.btn)
--        if btn then
--            btn:runAction(cc.Sequence:create(
--                cc.DelayTime:create(delay),
--                cc.EaseExponentialOut:create(cc.MoveTo:create(t, v.cp)),
----                cc.EaseBackOut:create(cc.MoveTo:create(t, v.cp)),
--                cc.CallFunc:create(function()
--                    if btn.ismax then var.isRunAni = false end
--                end)
--            ))
--            btn.ismax = (k == #MENU_CONFIG)
--            delay = delay + t
--        end
--    end

end

function UIRightBottom.getMenuButtonByFuncId(fid)
    if var.showSkill then
        return var.btnMenu
    end
    for _, v in pairs(MENU_CONFIG) do
        if v.funcid and v.funcid == fid then
            return var.menuLayer:getWidgetByName(v.btn)
        end
    end
end

function UIRightBottom.getSkillTargetBtn(shortpos)
    if not var.showSkill then
        return var.btnMenu
    end

    if not shortpos or (shortpos < 5 and var.curPage == 2) or (shortpos > 4 and var.curPage == 1) then
        return var.skillLayer:getWidgetByName("Button_attack")
    end

    return var.sIcon[shortpos]
end

function UIRightBottom.handleButtonGuildShow(event)
    if not event or not event.guildType then return end
    local finded = false
    for _, v in ipairs(MENU_CONFIG) do
        if v.guildtypes and #v.guildtypes > 0 then
            local showTips = false
            for k, v in ipairs(v.guildtypes) do
                if v == event.guildType then
                    showTips = true
                    finded = true
                    break
                end
            end

            if showTips then
                var.menuLayer:getWidgetByName(v.btn):setLocalZOrder(100)
                UIButtonGuide.addGuideTip(var.menuLayer:getWidgetByName(v.btn),UIButtonGuide.getGuideTips(event.guildType),v.uitype)
            else
                UIButtonGuide.clearGuideTip(var.menuLayer:getWidgetByName(v.btn))
            end
        end
    end
    if finded then
        var.showGuildFlag = true
        UIRightBottom.updateMenuTips()
    end
end

function UIRightBottom.updateMenuTips()
    if var.showSkill and var.showGuildFlag then
        UIButtonGuide.addGuideTip(var.btnMenu,"点击菜单按钮",UIButtonGuide.UI_TYPE_LEFT)
    else
        UIButtonGuide.clearGuideTip(var.btnMenu)
    end
end

function UIRightBottom.isSkill2Pos(skillId)
    if skillId == Const.SKILL_TYPE_HuoQiang or skillId == Const.SKILL_TYPE_ShenShengZhanJiaShu or skillId == Const.SKILL_TYPE_JiTiYinShenShu
        or skillId == Const.SKILL_TYPE_QunTiZhiLiao or skillId == Const.SKILL_TYPE_TianZunQunDu or skillId == Const.SKILL_TYPE_YouLingDun then
        return true
    end
    return false
end

function UIRightBottom.showSkillCircle(skillId,tag)
    local cutinfo = NetClient.mShortCut[tag]
    if MainRole.mCurSkillTag > 0 and MainRole.mCurSkillTag ~= tag then
        if var.sIcon[MainRole.mCurSkillTag].icon:isVisible() then
            var.sIcon[MainRole.mCurSkillTag].lock:hide()
            UIRightBottom.addOpenEffect(var.sIcon[MainRole.mCurSkillTag].lock)
        end
    end
    if cutinfo and cutinfo.param then
        if cutinfo.param == skillId then
            if var.sIcon[tag].icon:isVisible() then
                var.sIcon[tag].lock:show()
                if MainRole.mCurSkillCircleID > 0 and MainRole.mCurSkillCircleID == skillId then
                    MainRole.mCurSkillCircleID = 0
                    MainRole.mCurSkillUsed = false
                    MainRole.mCurSkillTag = 0
                    var.sIcon[tag].lock:hide()
                else
                    MainRole.mCurSkillCircleID = skillId
                    MainRole.mCurSkillTag = tag
                    MainRole.mCurSkillUsed = false
                end
                UIRightBottom.addOpenEffect(var.sIcon[tag].lock)
            end
        end
    end
end

function UIRightBottom.handleSkillUsed(event)
    if MainRole.mCurSkillCircleID > 0 and MainRole.mCurSkillUsed then
        UIRightBottom.showSkillCircle(MainRole.mCurSkillCircleID,MainRole.mCurSkillTag)
    end
end
return UIRightBottom