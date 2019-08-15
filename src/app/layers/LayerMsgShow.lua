--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/14 16:09
-- To change this template use File | Settings | File Templates.
--
local ACTION_ITEM_EFFECT = 10001
local LayerMsgShow = class("LayerMsgShow", function()
    return ccui.Layout:create()
end)

function LayerMsgShow:ctor()
    self.mGuildList = {}
    self.mMsgNodeList = {}
    self.mMsgMaxNode = 3
    self.new_item_icon_list = {}
    self.last_new_item = 0
    self:setContentSize(cc.size(display.width, display.height))
    self:addSprite()
    self:setTouchEnabled(true)
    self:setSwallowTouches(false)
    self:addClickEventListener(function ( pSender )
        local endpos = self:convertToNodeSpace(pSender:getTouchEndPosition())
        gameEffect.getCacheEffect(gameEffect.EFFECT_POINT, {removeSelf=true})
        :setPosition(endpos):addTo(self)
    end)

    self:enableNodeEvents()
end

function LayerMsgShow:addSprite()
    self.mMidNode = ccui.Widget:create()
    :setContentSize(cc.size(Const.WIN_WIDTH, Const.WIN_HEIGHT))
    :addTo(self)
    :align(display.CENTER_BOTTOM, display.cx, display.cy + 130*Const.minScale)
    :setTouchEnabled(false)
    :setScale(Const.minScale)

    self.mLeftBottomNode = ccui.Widget:create()
    :setContentSize(cc.size(300, 200))
    :addTo(self)
    :align(display.LEFT_BOTTOM, Const.minScale * 20, Const.minScale * 5)
    :setTouchEnabled(false)
    :setScale(Const.minScale)
    self.mLeftBottomNode.maxNode = 3

    -- 新技能 新功能开启
    self.mNewBg = self:createMaskBg()
    self.mNewBg:setName("mNewBg")
    self.mNewBg:addTo(self)
    self.mNewBg:hide()

    -- TODO 可优化成batchnode
    -- 顶部背景
    self.topBg = ccui.ImageView:create()
    self.topBg:setScale9Enabled(true)
    self.topBg:loadTexture("backgroup_10.png", UI_TEX_TYPE_PLIST)
    self.topBg:setContentSize( cc.size(display.width*0.8, 40*Const.minScale) )
    self.topBg:align(display.CENTER_TOP, display.cx, display.top)
    self.topBg:addTo(self)
    self.topBg:setScale(Const.minScale)
    self.topBg:hide()

    self:addScrollFight()
    self:updateFightPoint()
end

function LayerMsgShow:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_ADD_ALERT, handler(self,self.updateAlertMsg))
--    :addEventListener(Notify.EVENT_SHOW_GET_ITEM_EFFECT, handler(self,self.handleItemEffectMsg))
    :addEventListener(Notify.EVENT_OPEN_NEW,handler(self, self.handleNew))
    :addEventListener(Notify.EVENT_LEARN_NEW_SKILL,handler(self, self.handleLearnNewSkill))
    :addEventListener(Notify.EVENT_ATTRIBUTE_CHANGE, handler(self, self.updateFightPoint))
    :addEventListener(Notify.EVENT_SELF_HPMP_CHANGE, handler(self, self.runHpWarning))
--    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, handler(self, self.handleLuaMsg))
    :addEventListener(Notify.EVENT_LEVEL_UP, handler(self, self.handleLevelup))
    :addEventListener(Notify.EVENT_SOCKET_ERROR, handler(self, self.handleSocketError))
end

function LayerMsgShow:handleSocketError()
    self.lastAttr = nil
end

function LayerMsgShow:addHpWarning()
    if self.hpWarningBg then
        self.hpWarningBg:stopAllActions()
        self.hpWarningBg:removeFromParent()
        self.hpWarningBg = nil
    end
    self.hpWarningBg = ccui.ImageView:create()
    self.hpWarningBg:loadTexture("uilayout/image/huxiok.png", UI_TEX_TYPE_LOCAL)
    self.hpWarningBg:setScaleX(display.width/Const.WIN_WIDTH)
    self.hpWarningBg:setScaleY(display.height/Const.WIN_HEIGHT)
    self.hpWarningBg:align(display.CENTER, display.cx, display.cy)
    self.hpWarningBg:addTo(self,55)
end

function LayerMsgShow:updateAlertMsg(event)
    if not NetClient.showAlert then return end
    local mtype = event.type
    if mtype == "post" then
        self:updateTopMsg(event)
    elseif mtype == "mid" or mtype=="alert" then
        if self.showNoticeType then
            self.mMidNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
                self:updateMidMsg(event)
                self.showNoticeType = false
            end)))
        else
            self:updateMidMsg(event)
            self.showNoticeType = true
        end
    elseif mtype == "leftbottom" then
        if self.showNoticeType then
            self.mLeftBottomNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.15), cc.CallFunc:create(function()
                self:updateLeftBottomMsg(event)
                self.showNoticeType = false
            end)))
        else
            self:updateLeftBottomMsg(event)
            self.showNoticeType = true
        end
    end
end

function LayerMsgShow:updateTopMsg(event)
    local msg =  event.msg or ""
    if msg == "" then return end

    local param={
        parent = self.topBg,
        fontSize = 26,
        msg = msg,
    }
    UIAnimation.onMessage(param)
end

function LayerMsgShow:updateMidMsg(event)
    local msg =  event.msg or ""
    if msg == "" then return end

    local param={
        parent = self.mMidNode,
        scenter = true,
        fontSize = 26,
        msg = msg,
        itemid = event.itemid,
        hold = true,
    }
    UIAnimation.onListMessage(param)
end

function LayerMsgShow:updateLeftBottomMsg(event)
    local msg =  event.msg or ""
    if msg == "" then return end

    local param={
        parent = self.mLeftBottomNode,
        fontSize = 22,
        msg = msg,
        hold = true,
        itemheight = 20,
        bgfile = "touming.png"
    }
    UIAnimation.onListMessage(param)
end
--[[
function LayerMsgShow:handleItemEffectMsg(event)
    local typeid = event.typeid
    if not typeid then
        return
    end

    local bagBtn = UIRightTop.getBagBtn()
    if not bagBtn then
        return
    end

    if self.last_new_item == typeid then
        return
    end

    local itemDef = NetClient:getItemDefByID(typeid)
    if not itemDef then
        return
    end

    self.last_new_item = typeid
    local icon = ccui.ImageView:create()
    icon:align(display.CENTER, display.cx, display.cy -70)
    icon:loadTexture("icon/"..itemDef.mIconID..".png")
    icon:setVisible(false)
    self:addChild( icon )
    table.insert( self.new_item_icon_list, icon )

    if self:getActionByTag(ACTION_ITEM_EFFECT) then return end

    local function show_effect()
        if not self.new_item_icon_list or not self.new_item_icon_list[1] then
            self:stopActionByTag(ACTION_ITEM_EFFECT)
            return
        end

        local icon = self.new_item_icon_list[1]
        table.remove( self.new_item_icon_list,1)
        icon:setVisible(true)

        local function check_callback()
            self:removeChild( icon )
        end

        local x = bagBtn:convertToWorldSpace(bagBtn:getAnchorPointInPoints()).x
        local y = bagBtn:convertToWorldSpace(bagBtn:getAnchorPointInPoints()).y
        local move_a = {}
        move_a[ #move_a + 1 ] = cc.MoveTo:create( 0.1, cc.p(display.cx, display.cy) )
        move_a[ #move_a + 1 ] = cc.DelayTime:create(0.5)
        -- cc.EaseIn:create( action,rate )
        move_a[ #move_a + 1 ] = cc.EaseIn:create( cc.MoveTo:create( 1, cc.p(x,y) ),0.6 )

        move_a[ #move_a + 1 ] = cc.DelayTime:create(0.5)

        move_a[ #move_a + 1 ] = cc.ScaleTo:create(0.1,0.1)

        move_a[ #move_a + 1 ] = cc.CallFunc:create( check_callback )
        icon:runAction(cc.Sequence:create(move_a))
    end

    local actions = {}
    actions[#actions+1] = cc.CallFunc:create( show_effect )
    actions[#actions+1] = cc.DelayTime:create(0.3)
    local s_actions = cc.RepeatForever:create( cc.Sequence:create(actions) )
    s_actions:setTag(ACTION_ITEM_EFFECT)
    self:runAction(s_actions)
end
--]]

function LayerMsgShow:handleLearnNewSkill(event)
    if not event then return end
    local skill_type = event.skill_type
    local shortpos = event.pos
    if not skill_type then return end
    if not shortpos then return end

    local skillDef = NetClient:getSkillDefByID(skill_type)
    if not skillDef then return end

    local icon = ccui.ImageView:create()
    icon:align(display.CENTER, display.cx, 150)
    icon:loadTexture("skill"..skill_type..".png",UI_TEX_TYPE_PLIST)

    local targetBtn = UIRightBottom.getSkillTargetBtn(shortpos)
    if targetBtn then
        self:addChild( icon )
        local cp = targetBtn:convertToWorldSpace(targetBtn:getAnchorPointInPoints())
        icon:runAction(cc.Sequence:create(
            cc.MoveTo:create( 1, cc.p(cp.x,cp.y)),
            cc.ScaleTo:create(0.1,0.1),
            cc.CallFunc:create(function()
                icon:removeFromParent()
                NetClient:dispatchEvent({name=Notify.EVENT_SHORTCUT_CHANGE})
            end)
        ))
    end
end
--[[
function LayerMsgShow:handleNew(event)
    local type = event.type
    local pids = event.pids or {}
    local shortpos = event.shortpos or {}

    if #pids == 0 then return end
    self.mGuildWidget = {}
    self.mNewBg:stopAllActions()
    self.mNewBg:removeAllChildren()
    table.insert(self.mGuildList, { type = type, pids = pids, shortpos = shortpos})

    local widget = ccui.Widget:create()
    local width, height = 0,0
    for _, pv in ipairs(self.mGuildList) do
        for k, v in ipairs(pv.pids) do
            local namestr = ""
            local titlestr,iconstr
            local imgType
            if pv.type == Const.OPEN_NEW.SKILL then
                local skillDef = NetClient:getSkillDefByID(v)
                if skillDef then
                    titlestr = "newskill.png"
                    iconstr = "skill"..v..".png"
                    namestr = skillDef.mName
                    imgType = UI_TEX_TYPE_PLIST
                end
            elseif pv.type == Const.OPEN_NEW.FUNC then
                local finfo = game.getFuncInfo(v)
                if finfo then
                    titlestr = "newfunction.png"
                    iconstr = finfo.icon
                    namestr = finfo.name
                    imgType = UI_TEX_TYPE_PLIST
                end
            end
            if titlestr and iconstr and imgType then
                local newWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelNew.csb"):addTo(widget)
                local panelWidget = newWidget:getChildByName("Panel_new")
                table.insert(self.mGuildWidget, panelWidget)
                panelWidget:getWidgetByName("shortcut"):loadTexture(iconstr,imgType)
                panelWidget:getWidgetByName("shortcut"):ignoreContentAdaptWithSize(true)
                panelWidget:getWidgetByName("Image_title"):loadTexture(titlestr,UI_TEX_TYPE_PLIST)
                panelWidget:getWidgetByName("name"):setString(namestr)
                panelWidget:setTouchEnabled(false)

                gameEffect.playEffectByType(gameEffect.EFFECT_OPEN)
                :setPosition(cc.p(107,109)):addTo(panelWidget:getWidgetByName("Panel_effect"))

                panelWidget.iconstr = iconstr
                panelWidget.imgType = imgType
                panelWidget.type = pv.type
                panelWidget.pid = v -- 技能id 或者 功能开启id
                panelWidget.shortpos = pv.shortpos[k]
                height = panelWidget:getContentSize().height
                display.align(newWidget, display.LEFT_CENTER, width, height/2)
                width = width + panelWidget:getContentSize().width
                if k < #pv.pids then width = width + 20 end
            end
        end
    end
    if #self.mGuildWidget == 0 then return end
    widget:setContentSize(cc.size(width, height))
    widget:align(display.CENTER, display.cx, display.cy)
    widget:setScale(Const.minScale)
    widget:addTo(self.mNewBg)

    local function cleanAction()
        self.mNewBg:stopAllActions()
        for k, v in pairs(self.mGuildWidget) do
            local starcpp = v:convertToWorldSpace(v:getAnchorPointInPoints())
            local icon = ccui.ImageView:create()
            icon:align(display.CENTER, starcpp.x, starcpp.y)
            icon:loadTexture(v.iconstr, v.imgType)
            local targetBtn
            if v.type == Const.OPEN_NEW.FUNC then
                if v.pid == GuideDef.FUNCID_YUANSHEN then
                    targetBtn = UILeftTop.getRoleBtn()
                elseif v.pid ==  GuideDef.FUNCID_SHENLU or v.pid == GuideDef.FUNCID_ZHANSHEN or v.pid == GuideDef.FUNCID_WING or v.pid == GuideDef.FUNCID_SHENQI or v.pid == GuideDef.FUNCID_CHENGJIU then
                    targetBtn = UIRightBottom.getMenuButtonByFuncId(v.pid)
                end
            elseif v.type == Const.OPEN_NEW.SKILL then
                targetBtn = UIRightBottom.getSkillTargetBtn(v.shortpos)
            end
            if targetBtn then
                self:addChild( icon )
                icon.type = v.type
                icon.shortpos = v.shortpos
                local cp = targetBtn:convertToWorldSpace(targetBtn:getAnchorPointInPoints())
                icon:runAction(cc.Sequence:create(
                    cc.MoveTo:create( 1, cc.p(cp.x,cp.y)),
                    cc.ScaleTo:create(0.1,0.1),
                    cc.CallFunc:create(function()
                        icon:removeFromParent()
                        if icon.type == Const.OPEN_NEW.SKILL and icon.shortpos then
                            NetClient:dispatchEvent({name=Notify.EVENT_SHORTCUT_CHANGE})
                        end
                    end)
                ))
            end
        end
        self.mGuildWidget = {}
        self.mNewBg:removeAllChildren()
        self.mGuildList ={}
        self.mNewBg:hide()

    end

    self.mNewBg:setTouchEnabled(true)
    self.mNewBg:addClickEventListener(function(pSender)
        cleanAction()
    end)

    self.mNewBg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(function()
        cleanAction()
    end))))

    self.mNewBg:show()
end
--]]
function LayerMsgShow:createMaskBg()
    local mask = ccui.ImageView:create("uilayout/image/maskbg.png",UI_TEX_TYPE_LOCAL)
    mask:setOpacity(200)
    mask:setScale9Enabled(true)
    mask:setContentSize(cc.size(Const.VISIBLE_WIDTH, Const.VISIBLE_HEIGHT))
    mask:setTouchEnabled(true)
    mask:align(display.CENTER, display.cx, display.cy)
    return mask
end

function LayerMsgShow:addScrollFight()
--    self.mAttrNode = ccui.Widget:create()
--    :addTo(self)
--    :align(display.CENTER_BOTTOM, display.width/4, 230*Const.minScale)
--    :setTouchEnabled(false)

    self.mScrollWidget = ScrollFight.initWidget(handler(self, self.fightCall))
    self.mScrollWidget:align(display.LEFT_CENTER, display.width/4, 200*Const.minScale):hide()
    self.mScrollWidget:setScale(Const.maxScale)
    self:addChild(self.mScrollWidget)

    self.mAddNumAtlas = ccui.TextAtlas:create("", "uilayout/image/zhanlishuzi_lv.png", 17, 26, 0)
    :align(display.LEFT_CENTER, 0,0)
    :hide()
    :addTo(self.mScrollWidget)
    local addflag = ccui.ImageView:create("better_equip.png",UI_TEX_TYPE_PLIST)
    :align(display.LEFT_CENTER,0, 13)
    :addTo(self.mAddNumAtlas)
    addflag:setName("img_flag")

    self.mRemNumAtlas = ccui.TextAtlas:create("", "uilayout/image/zhanlishuzi_red.png", 17, 26, 0)
    :align(display.LEFT_CENTER, 0,0)
    :hide()
    :addTo(self.mScrollWidget)
    local remflag = ccui.ImageView:create("worse_equip.png",UI_TEX_TYPE_PLIST)
    :align(display.LEFT_CENTER,0, 13)
    :addTo(self.mRemNumAtlas)
    remflag:setName("img_flag")
end

function LayerMsgShow:updateFightPoint()
    if not NetClient.showFp then return end
    if not self.lastAttr or not self.lastAttr.mFightPoint then
        self.lastAttr = clone(NetClient.mCharacter)
        return
    end

    if not NetClient.isEnterGame then return end
    if NetClient.mCharacter.mFightPoint and self.lastAttr.mFightPoint then
        local add = NetClient.mCharacter.mFightPoint - self.lastAttr.mFightPoint
        if add ~= 0 then
            self:fightChange(add, self.lastAttr.mFightPoint)
--            if add > 0 then
--                self:attrAdd()
--            end
            self.lastAttr = clone(NetClient.mCharacter)
        end
    end
end

function LayerMsgShow:fightChange(add, all)
    local hander
    if add <= 0 and all <= 0 then return end
    if self.mScrollWidget then
        self.mScrollWidget:show()

        if self.mScrollWidget:getChildByName("addfight") then
            self.mScrollWidget:removeChildByName("addfight")
        end

        gameEffect.getCacheEffect(gameEffect.EFFECT_ZHANDOULI, {removeSelf=true})
        :setPosition(cc.p(55,-17)):setName("addfight"):addTo(self.mScrollWidget, -2)

        local len = string.len(NetClient.mCharacter.mFightPoint.."") + 1
        local starty, endy = -42, -17
        if add ~= 0 then
            if add > 0 then
                self.mRemNumAtlas:hide()
                self.mAddNumAtlas:setString(";"..add)
                self.mAddNumAtlas:getChildByName("img_flag"):setPositionX(self.mAddNumAtlas:getContentSize().width)
                self.mAddNumAtlas:setPosition(cc.p(len*17, starty)):show()
                self.mAddNumAtlas:runAction(cc.Sequence:create(
                    cc.EaseSineOut:create(
                        cc.MoveTo:create(1.0, cc.p(len*17,endy)))
                ))
            elseif add < 0 then
                self.mAddNumAtlas:hide()
                self.mRemNumAtlas:setString(":"..(-add))
                self.mRemNumAtlas:getChildByName("img_flag"):setPositionX(self.mRemNumAtlas:getContentSize().width)
                self.mRemNumAtlas:setPosition(cc.p(len*17, starty)):show()
                self.mRemNumAtlas:runAction(cc.Sequence:create(
                    cc.EaseSineOut:create(
                        cc.MoveTo:create(1.0, cc.p(len*17,endy)))
                ))
            end

        end
        ScrollFight.AddNewFight(self.mScrollWidget, add, all)
    end
end

function LayerMsgShow:fightCall(number)
    self.mScrollWidget:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function ()
            if self.mScrollWidget:getChildByName("addfight") then
                self.mScrollWidget:removeChildByName("addfight")
            end
            self.mAddNumAtlas:hide()
            self.mRemNumAtlas:hide()
            self.mScrollWidget:hide()
        end)))
end

function LayerMsgShow:runHpWarning(event)
    if not event.param then return end
    local pro = event.param.hp_pro or 0
    if pro > 0.5 then
        self.isShowHpWaring = false
        if self.hpWarningBg then
            self.hpWarningBg:stopAllActions()
            self.hpWarningBg:removeFromParent()
            self.hpWarningBg = nil
        end
        return
    end

    if self.isShowHpWaring then return end

    self.isShowHpWaring = true
    self:addHpWarning()
    self.hpWarningBg:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.FadeOut:create(1),
        cc.FadeIn:create(1)
    )))
end

function LayerMsgShow:handleLevelup()
    if not NetClient.showUpEffect then return end
--    local sprite = cc.Sprite:create()
--    asyncload_frames("scenebg/shengjiok",Const.TEXTURE_TYPE.PVR,function()
--        if sprite then
--            local frames = display.newFrames("shengji_%02d.png", 1, 9)
--            local animation = display.newAnimation(frames, 0.05)
--            sprite:playAnimationOnce(animation,{removeSelf=true})
--        end
--    end)
--    sprite:onNodeEvent("exit", function()
--        remove_frames("scenebg/shengjiok",Const.TEXTURE_TYPE.PVR)
--    end)
--    sprite:setScale(Const.maxScale)
--    sprite:setPosition(cc.p(display.cx,display.cy-80)):addTo(self)
    --game.playSoundByID("sound/1110.mp3")
    local MainAvatar = CCGhostManager:getMainAvatar()
    self:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            gameEffect.getCacheEffect(gameEffect.EFFECT_LEVELUP, {removeSelf=true})
--            :setPosition(cc.p(display.cx,display.cy-80)):
            :addTo(MainAvatar:getSprite(),10)
        end)
    ))
end

--[[
function LayerMsgShow:handleLuaMsg(event)
    if not event then return end
    if event.type == "playeffect" then
        local effectidx = checkint(event.data)
        if effectidx == gameEffect.EFFECT_TASK_DONE then
            gameEffect.getCacheEffect(effectidx, {removeSelf=true})
            :setScale(Const.maxScale)
            :setPosition(cc.p(display.cx,display.height*0.75)):addTo(self)
        end

    end
end
--]]
--[[
function LayerMsgShow:attrAdd()
    local dis = {
        -- 物理攻击 魔法攻击 道术攻击
        {name = "wuligongji.png", min = NetClient.mCharacter.mDC - self.lastAttr.mDC, max = NetClient.mCharacter.mMaxDC - self.lastAttr.mMaxDC},
        {name = "mofagongji.png", min = NetClient.mCharacter.mMC - self.lastAttr.mMC, max = NetClient.mCharacter.mMaxMC - self.lastAttr.mMaxMC},
        {name = "daoshugongji.png", min = NetClient.mCharacter.mSC - self.lastAttr.mSC, max = NetClient.mCharacter.mMaxSC - self.lastAttr.mMaxSC},

        -- 物理防御
        {name = "wulifangyu.png", min = NetClient.mCharacter.mAC - self.lastAttr.mAC, max = NetClient.mCharacter.mMaxAC - self.lastAttr.mMaxAC},
        -- 魔法防御
        {name = "mofafangyu.png", min = NetClient.mCharacter.mMAC - self.lastAttr.mMAC, max = NetClient.mCharacter.mMaxMAC - self.lastAttr.mMaxMAC},
        -- 生命上限
        {name = "shengmingshangxian.png", value = NetClient.mCharacter.mMaxHp - self.lastAttr.mMaxHp},
--        -- 魔法上限
        {name = "mofashangxian.png", value = NetClient.mCharacter.mMaxMp - self.lastAttr.mMaxMp},
        -- 内功上限
        {name = "neigongshangxian.png", value = NetClient.mCharacter.mMaxNg - self.lastAttr.mMaxNg},
        -- 幸运
        {name = "xingyun.png", value = NetClient.mCharacter.mLuck - self.lastAttr.mLuck, per = true},
        -- 意志 TODO
        -- 暴击几率
        {name = "baojijilv.png", value = NetClient.mCharacter.mBaoji - self.lastAttr.mBaoji, per = true},
        -- 暴击伤害
        {name = "baojishanghai.png", value = NetClient.mCharacter.mBaojiPres - self.lastAttr.mBaojiPres},
        -- 爆伤减免
        {name = "baoshangjianmian.png", value = NetClient.mCharacter.mBaojiCounteract - self.lastAttr.mBaojiCounteract, per = true},
        -- 爆伤抵消
        {name = "baoshangdixiao.png", value = NetClient.mCharacter.mBaojiCounteractPres - self.lastAttr.mBaojiCounteractPres},
        -- 闪避
        {name = "shanbi.png", value = NetClient.mCharacter.mDodge - self.lastAttr.mDodge },
        -- 准确
        {name = "zhunque.png", value = NetClient.mCharacter.mAccuracy - self.lastAttr.mAccuracy },
        -- 韧性
        {name = "renxing.png", value = NetClient.mCharacter.mToughness - self.lastAttr.mToughness, per = true},
        -- 魔法闪避
        {name = "mofashanbi.png", value = NetClient.mCharacter.mAntiMagic - self.lastAttr.mAntiMagic },
        -- 伤害减免
        {name = "shanghaijianmian.png", value = NetClient.mCharacter.mXishou - self.lastAttr.mXishou, per = true},
        -- 反弹伤害
        {name = "fantanshanghai.png", value =  NetClient.mCharacter.mFantan_pres - self.lastAttr.mFantan_pres, per = true},
        -- 忽视防御
        {name = "hushifangyu.png", value = NetClient.mCharacter.mIgnoredef - self.lastAttr.mIgnoredef, per = true},
        -- 神圣攻击
        {name = "shenshenggongji.png", value = NetClient.mCharacter.mGodAtk - self.lastAttr.mGodAtk},
        -- 神圣防御
        {name = "shenshengfangyu.png", value = NetClient.mCharacter.mGodDef - self.lastAttr.mGodDef},
    }

    local nodeitem = {}
    for _, v in ipairs(dis) do
        local valuestr
        if v.max and v.min and (v.max > 0 or v.min > 0 ) then
            valuestr = v.min..":"..v.max
        elseif v.value and v.value > 0 then
            if v.per then
                valuestr = string.format("%0.2f",(v.value/10000)*100).."/"
            else
                valuestr = v.value
            end
        end
        if valuestr then
            table.insert(nodeitem, self:createAttrItem(v.name, valuestr))
        end
    end

    if #nodeitem == 0 then return end

    self.mAttrNode:stopAllActions()
    self.mAttrNode:removeAllChildren()

    local space = 30*Const.minScale
    for k, v in ipairs(nodeitem) do
        v:align(display.LEFT_BOTTOM, 0, -k*space)
        :setScale(Const.maxScale)
        :addTo(self.mAttrNode)
        v:runAction(cc.Sequence:create(
            cc.DelayTime:create(1+k*0.3),
            cc.Spawn:create(
                cc.MoveBy:create(0.2, cc.p(-50,0)),
                cc.FadeOut:create(0.2)
            ),
            cc.RemoveSelf:create()
        ))
    end

    self.mAttrNode:setPositionY(200*Const.minScale + #nodeitem * space)
end

function LayerMsgShow:createAttrItem(name, value)
    local img_bg = ccui.ImageView:create("shuzhidi.png",UI_TEX_TYPE_PLIST)
    local bgsize = img_bg:getContentSize()

    ccui.ImageView:create(name,UI_TEX_TYPE_PLIST)
    :align(display.LEFT_CENTER, 5, bgsize.height/2)
    :addTo(img_bg)

    ccui.ImageView:create("maohao.png",UI_TEX_TYPE_PLIST)
    :align(display.LEFT_CENTER, 85, bgsize.height/2)
    :addTo(img_bg)

    local alta = ccui.TextAtlas:create(value, "uilayout/image/shuzhi.png", 14, 20, ".")
    :align(display.LEFT_CENTER, 95,bgsize.height/2)
    :addTo(img_bg)

    return img_bg
end
--]]
function LayerMsgShow:onEnter()
    self:registeEvent()
end

return LayerMsgShow