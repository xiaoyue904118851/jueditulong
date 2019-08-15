--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/28 14:22
-- To change this template use File | Settings | File Templates.
--

local RoleNeigongView = {}
local var = {}
local ACTIONSET_NAME = "neigong"

function RoleNeigongView.initView(params)
    local params = params or {}
    var = {}
    var.selectInfo = nil
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_Neigong.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_neigong")
    RoleNeigongView.initWidget()
    RoleNeigongView.registeEvent()

    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "queryfp"}))
    if not NetClient.mNeigongBaseInfo.desc then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "baseinfo"}))
    else
        RoleNeigongView.updateNgDesc()
    end

    return widget
end

function RoleNeigongView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, RoleNeigongView.handleNeigongMsg)
    :addEventListener(Notify.EVENT_NG_LEVEL_CHANGE, RoleNeigongView.handleNgLvMsg)
    :addEventListener(Notify.EVENT_NG_EXP_CHANGE, RoleNeigongView.handleNgExpChange)
end

function RoleNeigongView.initWidget()
    var.leftWidget = var.widget:getWidgetByName("Image_left")
    var.rightWidget = var.widget:getWidgetByName("Image_right")
    var.zhanliText = var.rightWidget:getWidgetByName("AtlasLabel_zhanli")
    var.roleBg = var.leftWidget:getWidgetByName("Image_role_bg")
    RoleNeigongView.addBtnClickedEvent()

    var.expBar = cc.ProgressTimer:create(cc.Sprite:create("uilayout/image/neigongjindutiao.png"))
    :align(display.CENTER, 298.30, 309.75)
    :addTo(var.leftWidget:getWidgetByName("Panel_timerbg"))
    var.expBar:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    var.expBar:setReverseDirection(true)
    var.expBar:getSprite():setFlippedY(true)
    var.nglvText = var.leftWidget:getWidgetByName("AtlasLabel_lv")
    RoleNeigongView.handleNgLvMsg()

    RoleNeigongView.handleNgExpChange()
    RoleNeigongView.resetRightInfo()

    local zlbg = var.rightWidget:getWidgetByName("Image_zhanli_bg")
    zlbg:runAction(cc.Sequence:create(
        cc.DelayTime:create(1/60),
        cc.CallFunc:create(function()
            gameEffect.playEffectByType(gameEffect.EFFECT_NEIGONG_ZHANLI)
            :setPosition(cc.p(175,25)):addTo(var.rightWidget:getWidgetByName("Image_zhanli_bg"))
        end)
    ))

    local sprite = cc.Sprite:create()
    asyncload_frames("scenebg/neigong/neigong03",Const.TEXTURE_TYPE.PVR,function()
        if sprite then
            local frames = display.newFrames("neogong03_%02d.png", 1, 8)
            local animation = display.newAnimation(frames, 0.15)
            sprite:playAnimationForever(animation,{removeSelf=true})
        end
    end)
    sprite:onNodeEvent("exit", function()
        remove_frames("scenebg/neigong/neigong03",Const.TEXTURE_TYPE.PVR)
    end)
    sprite:setPosition(cc.p(280,195)):addTo(var.roleBg)
end

function RoleNeigongView.handleNgExpChange()
    local curexp = NetClient.mCharacter.mCurNgExperience
    local maxexp = NetClient.mCharacter.mCurrentNgLevelMaxExp
    if  curexp and maxexp then
        local pp = curexp/maxexp*100
        if pp < 6 then pp = 6 end
        if pp > 93 then pp = (pp - 93)/7 + 93 end
        var.expBar:setPercentage(pp)
        var.leftWidget:getWidgetByName("Text_jindu_cur"):setString(curexp):setTextColor(curexp>=maxexp and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
        var.leftWidget:getWidgetByName("Text_jindu_max"):setString("/"..maxexp)

        if var.roleBg:getChildByName("neigongfull") then
            var.roleBg:removeChildByName("neigongfull")
        end

        if curexp >= maxexp then
            if not var.roleBg:getChildByName("neigongfull") then
                var.roleBg:runAction(cc.Sequence:create(cc.DelayTime:create(1/60), cc.CallFunc:create(function()
                    gameEffect.playEffectByType(gameEffect.EFFECT_NEIGONG_FULL):setName("neigongfull")
                    :setPosition(cc.p(280,195)):addTo(var.roleBg)
                end)))
            end
            if not var.upeffect then
                var.upeffect = gameEffect.getBtnSelectEffect()
                var.upeffect:setPosition(cc.p(var.upBtn:getContentSize().width/2,var.upBtn:getContentSize().height/2))
                var.upeffect:addTo(var.upBtn)
                var.upBtn:setTouchEnabled(true)
                var.upBtn:setBright(true)
            end
            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.NEIGONG) then
                UIButtonGuide.addGuideTip(var.upBtn,UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.NEIGONG),UIButtonGuide.UI_TYPE_TOP)
            end
        else
            if var.upeffect then
                var.upeffect:removeFromParent()
                var.upeffect = nil
            end
            if var.roleBg:getChildByName("neigongfull") then
                var.roleBg:removeChildByName("neigongfull")
            end
            var.upBtn:setTouchEnabled(false)
            var.upBtn:setBright(false)
        end
    end
end

function RoleNeigongView.handleNeigongMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
       return
    end

    if d.actionid == "queryfp" then
        RoleNeigongView.updateNgFight(d.fp)
    elseif d.actionid == "baseinfo" then
        NetClient.mNeigongBaseInfo.desc = d.info.desc
        RoleNeigongView.updateNgDesc()
    end
end

function RoleNeigongView.handleNgLvMsg()
    var.nglvText:setString(NetClient.mCharacter.mNgLevel or 0)
end

function RoleNeigongView.updateNgFight(p)
    var.zhanliText:setString(p or 0)
end

function RoleNeigongView.updateNgDesc()
    local msg = NetClient.mNeigongBaseInfo.desc or ""
    local descText = var.rightWidget:getWidgetByName("Text_baseinfo")
    local bgsize = descText:getContentSize()
    local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width - 30, 0), 0)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, msg, "", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    richWidget:setAnchorPoint(cc.p(0,1))
    richWidget:setPosition(cc.p(0, descText:getContentSize().height))
    descText:addChild(richWidget)
end

function RoleNeigongView.resetRightInfo()
    local nginfo = NeigongDefData[tostring(NetClient.mCharacter.mNgLevel or 0)]
    if not nginfo then return end

    local mainRoleInfo = game.GetMainNetGhost()
    local job = game.getRoleJob()

    local hf = 0
    if job == Const.JOB_ZS then
        hf = nginfo.mZSRecover
    elseif job == Const.JOB_FS then
        hf = nginfo.mFSRecover
    elseif job == Const.JOB_DS then
        hf = nginfo.mDSRecover
    end

    local cf = {
        {name = "Label_NeigongMax", value = mainRoleInfo:NetAttr(Const.net_maxng) },
        {name = "Label_Huifu", value = hf },
        {name = "Label_jianshang", value = string.format("%0.2f",nginfo.mDamagePer/10000).."%" },
        {name = "Label_PhyAtk", value = nginfo.mDC.."-"..nginfo.mDCMax},
        {name = "Label_MagAtk", value = nginfo.mMC.."-"..nginfo.mMCMax},
        {name = "Label_DaoAtk", value = nginfo.mSC.."-"..nginfo.mSCMax},
    }
    for _, v in ipairs(cf) do
        var.rightWidget:getWidgetByName(v.name):setString(v.value)
    end
end

function RoleNeigongView.addBtnClickedEvent()
    var.upBtn = var.leftWidget:getWidgetByName("Button_up")
    var.upBtn:addClickEventListener(function (pSender)
        UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.NEIGONG})
        gameEffect.playEffectByType(gameEffect.EFFECT_NEIGONG_UP):setName("neigongup")
        :setPosition(cc.p(280,195)):addTo(var.roleBg)
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade_onekey"}))
        if var.upeffect then
            var.upeffect:removeFromParent()
            var.upeffect = nil
        end
    end)
end


return RoleNeigongView