local UIRightTop={}

local MENU_TOP_BTN = {
    { btn = "Button_tiaozhan", panel = "panel_challenge_boss",redtypes={UIRedPoint.REDTYPE.BOSS_WORLD,UIRedPoint.REDTYPE.BOSS_PERSON},toptype=Const.TOPBTN.btnWorldBoss},
    { btn = "Button_mall", panel = "panel_mall"},
    { btn = "Button_xinqu", panel = "panel_activity_hall", redtypes={UIRedPoint.REDTYPE.DAILYACT,UIRedPoint.REDTYPE.VITALITY}, toptype=Const.TOPBTN.btnVitality},
    { funcid = GuideDef.FUNCID_WING, btn = "Button_tejie", panel = "panel_specailring", redtypes={UIRedPoint.REDTYPE.RING}, guildtypes={UIButtonGuide.GUILDTYPE.RING},toptype=Const.TOPBTN.btnRing},
    { btn = "Button_zhengba", panel = "panel_king",toptype=Const.TOPBTN.btnwar},
    { btn = "Button_awardhall", panel = "panel_award_hall", redtypes={UIRedPoint.REDTYPE.AWARDHALL_ONLINE,UIRedPoint.REDTYPE.AWARDHALL_SIGN}},
    { btn = "Button_offlineexp", panel = "panel_offline_exp", redtypes={UIRedPoint.REDTYPE.OFFLINE_EXP},toptype=Const.TOPBTN.btnOfflineExp},
    { btn = "Button_hongbao", panel = "panel_hongbao", redtypes={UIRedPoint.REDTYPE.HONGBAO},toptype=Const.TOPBTN.btnHongbao},
    { btn = "Button_supervalue", panel = "panel_super_value",toptype=Const.TOPBTN.btnShopFavorable},
    { btn = "Button_invest", panel = "panel_level_invest", redtypes={UIRedPoint.REDTYPE.LEVELINVEST},toptype=Const.TOPBTN.btnLevelInvest},
    { btn = "Button_refineexp", panel = "panel_refine_exp", redtypes={UIRedPoint.REDTYPE.REFINE_EXP},toptype=Const.TOPBTN.btnRefineExp},
    { btn = "Button_xunbao", panel = "panel_xunbao",toptype=Const.TOPBTN.btnXunBao},
    { btn = "Button_zunguitequan", panel = "panel_privilege_card", redtypes={UIRedPoint.REDTYPE.PRIVILEGECARD}},
    { btn = "Button_chong", panel = "panel_firstcharge", redtypes={UIRedPoint.REDTYPE.FIRST_CHARGE},toptype=Const.TOPBTN.btnFirstCharge},
}

local MENU_CONFIG = {
    ["Button_minimap"] = { btn = "Button_minimap", panel = "panel_wordmap"},
    ["Button_preopen"] =  { btn = "Button_preopen", panel = "panel_preopen"},
    ["Button_showacti"] = { btn = "Button_showacti", panel = "",redtypes={UIRedPoint.REDTYPE.BOSS_WORLD,
    UIRedPoint.REDTYPE.BOSS_PERSON,UIRedPoint.REDTYPE.DAILYACT,UIRedPoint.REDTYPE.VITALITY,UIRedPoint.REDTYPE.RING,
    UIRedPoint.REDTYPE.AWARDHALL_ONLINE,UIRedPoint.REDTYPE.AWARDHALL_SIGN,UIRedPoint.REDTYPE.OFFLINE_EXP,UIRedPoint.REDTYPE.HONGBAO,UIRedPoint.REDTYPE.LEVELINVEST,
    UIRedPoint.REDTYPE.REFINE_EXP,UIRedPoint.REDTYPE.PRIVILEGECARD,UIRedPoint.REDTYPE.FIRST_CHARGE}},
    ["Button_fangchenmi"] = { btn = "Button_fangchenmi", panel = "panel_fcm"},

    ["Button_mail"] = { btn = "Button_mail", panel = "panel_mail", redtypes={UIRedPoint.REDTYPE.NEWMAIL}},
    ["Button_chart"] = { btn = "Button_chart", panel = "panel_chart", },
    ["Button_seting"] = { btn = "Button_seting", panel = "panel_setting",},
}

local SYSBUTTON_RIGHT_X = 336
local var = {}
function UIRightTop.init_ui(righttop)
    var = {}
	var.widget = righttop:getChildByName("Panel_righttop")
    var.widget:align(display.RIGHT_TOP, Const.VISIBLE_WIDTH, Const.VISIBLE_HEIGHT):setScale(Const.minScale)
    var.panel_acti = var.widget:getWidgetByName("Panel_sysbutton1")
    var.panel_preopen = var.widget:getWidgetByName("Panel_preopen"):hide()
    var.mIsShow = true
    var.mIsShowBtn = var.widget:getWidgetByName("Button_showacti")
    UIRightTop.updateBtnStatus()
    UIRightTop.addBtnClicedEvent()
    UIRightTop.updatFangchenmiBtn()
    UIRightTop.updateMapName()
    UIRightTop.updatePrePanel()
    UIRightTop.handlePosChange()
    UIRightTop.registeEvent()
end

function UIRightTop.handleFubenMsg(event)
    local cmd = event.cmd
    if cmd == "enter" then
        var.panel_acti:hide()
    elseif cmd == "exit" then
        var.panel_acti:show()
    end
end

function UIRightTop.addBtnClicedEvent()
    local function btnCallBack(pSender)
        UIButtonGuide.handleButtonGuideClicked(pSender)
        local btnName =  pSender:getName()
        if btnName == "Button_showacti" then
            UIRightTop.showAllActivity()
            var.widget:getWidgetByName("Button_showacti"):setFlippedX(not var.mIsShow)
        else
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = pSender.panel})
            if var.preBtnEffect then
                var.preBtnEffect:removeFromParent()
                var.preBtnEffect = nil
            end
        end
    end
    for k, v in pairs(MENU_CONFIG) do
        local btn = var.widget:getWidgetByName(k)
        btn.panel = v.panel
        UIRedPoint.addUIPoint({parent=btn,callback=btnCallBack,types=v.redtypes})
    end
    for _, v in pairs(MENU_TOP_BTN) do
        local btn = var.widget:getWidgetByName(v.btn)
        btn.panel = v.panel
        UIRedPoint.addUIPoint({parent=btn,callback=btnCallBack,types=v.redtypes})
    end
end

function UIRightTop.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_MAP_ENTER, handler(UIRightTop, UIRightTop.updateMapName))
    :addEventListener(Notify.EVENT_FUBEN_DATA, UIRightTop.handleFubenMsg)
    :addEventListener(Notify.EVENT_LEVEL_CHANGE, UIRightTop.updatePrePanel)
    :addEventListener(Notify.EVENT_GUIDE_PROMPT, UIRightTop.handleGuideMsg)
    :addEventListener(Notify.EVENT_SHOW_TOP_BTN, UIRightTop.updatTopBtn)
    :addEventListener(Notify.EVENT_FANGCHENMI_CHANGE, UIRightTop.updatFangchenmiBtn)
    :addEventListener(Notify.EVENT_BUTTON_GUILD_SHOW, UIRightTop.handleButtonGuildShow)
    :addEventListener(Notify.EVENT_POS_CHANGE, UIRightTop.handlePosChange)
    :addEventListener(Notify.EVENT_BUTTON_STATUS_CHANGE,UIRightTop.updateBtnStatus)
    :addEventListener(Notify.EVENT_MAINTOP_RIGHTJIANBTNSHOW,UIRightTop.updateTopBtnEffect)
end

function UIRightTop.updateMapName()
    var.widget:getWidgetByName("Label_mapname"):setString(NetClient.mNetMap.mName)
end

function UIRightTop.handlePosChange()
    local mainAvatar = game.GetMainRole()
    if mainAvatar then
        var.widget:getWidgetByName("Label_pos"):setString(mainAvatar:PAttr(Const.AVATAR_X)..","..mainAvatar:PAttr(Const.AVATAR_Y))
    end
end

function UIRightTop.updatTopBtn(event)
    if var.FristShow  then return end
    if event.visible then return end
    var.panel_acti:stopAllActions()
    var.mIsShow = event.visible
    if var.mIsShow then
        var.panel_acti:setPosition(cc.p(SYSBUTTON_RIGHT_X, 190))
    else
        var.panel_acti:setPosition(cc.p(920, 190))
    end
    var.panel_acti:setVisible(var.mIsShow)
    var.mIsShowBtn:setFlippedX(not var.mIsShow)
    UIRightTop.addTopBtnEffect()
    
    var.FristShow = true
     
end

function UIRightTop.addTopBtnEffect()
    if var.TopbtnShowType then
        if not var.mIsShow then
            if var.TopbtnShowType == 1 then
                if not var.mIsShowBtn:getChildByName("btneffect") then
                    local effect = gameEffect.getPlayEffect(gameEffect.EFFECT_MAINJIANBTN)
                    effect:setPosition(cc.p(var.mIsShowBtn:getContentSize().width/2,var.mIsShowBtn:getContentSize().height/2))
                    effect:setName("btneffect")
                    effect:addTo(var.mIsShowBtn)
                else
                    if var.mIsShowBtn:getChildByName("btneffect") then
                        var.mIsShowBtn:getChildByName("btneffect"):show()
                    end
                end
            else
                if var.mIsShowBtn:getChildByName("btneffect") then
                    var.mIsShowBtn:getChildByName("btneffect"):removeFromParent()
                end
            end
        else
            if var.mIsShowBtn:getChildByName("btneffect") then
                var.mIsShowBtn:getChildByName("btneffect"):removeFromParent()
            end
        end 
    end
end

function UIRightTop.updateTopBtnEffect(event)
    if not event then return end
    if event.showType then
        var.TopbtnShowType = 1
    else
        var.TopbtnShowType = 2
    end
end

function UIRightTop.updatFangchenmiBtn()
--    var.widget:getWidgetByName("Button_fangchenmi"):setVisible(NetClient.mFcmInfo.china_id ~= Const.FCM_TYPE.PASS)
end

function UIRightTop.showAllActivity( ... )
    var.mIsShow = not var.mIsShow
    if var.mIsShow then
        -- 显示
        var.panel_acti:show()
        var.panel_acti:stopAllActions()
        var.panel_acti:runAction(
            cc.Sequence:create(
                cc.EaseExponentialOut:create(cc.MoveTo:create(0.2,cc.p(SYSBUTTON_RIGHT_X, 190))),
                cc.CallFunc:create(
                    function ()
--                        var.widget:getWidgetByName("Button_showacti"):setFlippedX(false)
                    end)
                )
            )
    else
        -- 隐藏
        var.panel_acti:stopAllActions()
        var.panel_acti:runAction(
            cc.Sequence:create(
                cc.EaseExponentialOut:create(cc.MoveTo:create(0.2,cc.p(920, 190))),
                cc.CallFunc:create(
                    function ()
                        var.panel_acti:hide()
--                        var.widget:getWidgetByName("Button_showacti"):setFlippedX(true)
                    end)
                )
            )
    end
    UIRightTop.addTopBtnEffect()
end

function UIRightTop.getBagBtn()
    if var and var.widget:getWidgetByName("Button_bag") then
        return var.widget:getWidgetByName("Button_bag")
    end
end

function UIRightTop.updatePrePanel()
    local rolelevel = game.getRoleLevel()
    local finfo = game.getPreFuncInfo(rolelevel)
    if finfo then
        var.panel_preopen:getWidgetByName("Button_preopen"):loadTextureNormal(finfo.icon, UI_TEX_TYPE_PLIST)
        var.panel_preopen:getWidgetByName("Label_levelinfo"):setString(finfo.level.."级开启")
        var.panel_preopen:show()
        if not var.preBtnEffect then
            if var.openlevel then if var.openlevel == finfo.level then return end end
            var.preBtnEffect = gameEffect.getPlayEffect(gameEffect.EFFECT_MAINTOPBTN)
            var.preBtnEffect:setPosition(cc.p(var.panel_preopen:getWidgetByName("Button_preopen"):getContentSize().width/2,var.panel_preopen:getWidgetByName("Button_preopen"):getContentSize().height/2))
            var.preBtnEffect:addTo(var.panel_preopen:getWidgetByName("Button_preopen"))
            var.openlevel  = finfo.level
        else
            if var.preBtnEffect then
                var.preBtnEffect:show()
            end 
        end 
    else
        var.panel_preopen:hide()
        if var.preBtnEffect then
            var.preBtnEffect:removeFromParent()
            var.preBtnEffect = nil
        end
    end
end

function UIRightTop.handleGuideMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == "guideprompt" then
        if d.actionid then
            if d.actionid == "levelprompt" then
                UIRightTop.updatePrePanel()
            end
        end
    end
end

function UIRightTop.updateBtnStatus()
    local stary = 112
    local starx = 320
    local spacex = 84
    local spacey = 80
    local posx = starx
    local posy = stary
    local cnt = 1
    for _, v in ipairs(MENU_TOP_BTN) do
        local visible = true
        if v.toptype then
            visible = (NetClient:getTopBtnFlag(v.toptype)==2)
        end
        local btn = var.widget:getWidgetByName(v.btn)
        btn:setVisible(visible)
        if visible then
            btn:setPosition(cc.p(posx,posy))
            if cnt == 7 then
                posx = starx
                posy = stary - spacey
            else
                posx = posx - spacex
            end
            cnt = cnt + 1
        end
    end


    if NetClient:getTopBtnFlag(Const.TOPBTN.btnRefineExp)==2 then
        UIRedPoint.handleChange({UIRedPoint.REDTYPE.REFINE_EXP})
    end
end

function UIRightTop.handleButtonGuildShow(event)
    if not event or not event.guildType then return end
    for _, v in pairs(MENU_TOP_BTN) do
        if v.guildtypes and #v.guildtypes > 0 then
            local showTips = false
            for _, t in ipairs(v.guildtypes) do
                if t == event.guildType then
                    showTips = true
                    break
                end
            end

            if showTips then
                UIButtonGuide.addGuideTip(var.widget:getWidgetByName(v.btn),UIButtonGuide.getGuideTips(event.guildType),UIButtonGuide.UI_TYPE_BOTTOM)
            else
                UIButtonGuide.clearGuideTip(var.widget:getWidgetByName(v.btn))
            end
        end
    end
end

function update_ping( ping )
    if var and var.widget then
        -- var.widget:getWidgetByName("Label_ping"):setString("延迟："..ping.."ms")
    end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_PING_UPDATE,"update_ping")

function UIRightTop.clear( ... )
    var = {}
end

return UIRightTop