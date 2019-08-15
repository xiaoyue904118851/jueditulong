local UILeftTop={}

local var = {}

local list_pkbtn = {
    ["Button_listall"] = {100,"state_all.png"},
    ["Button_listpeace"] = {101,"state_peace.png"},
    ["Button_listteam"] = {102,"state_group.png"},
    ["Button_listguild"] = {103,"state_guild.png"},
    ["Button_listgoodevil"] = {104,"state_evil.png"},
}
local pkbtn_info = {
    [100] = "全 体", --"state_all.png",
    [101] = "和 平", --"state_peace.png",
    [102] = "组 队", --"state_group.png",
    [103] = "行 会", --"state_guild.png",
    [104] = "善 恶", --"state_evil.png",
    [105] = "阵 营", --"state_evil.png",
}

function UILeftTop.init_ui(lefttop)
    var = {}
    var.showUIID = nil
	var.hasBufflist = false
	var.widget = lefttop:getChildByName("Panel_lefttop")
    var.widget:align(display.LEFT_TOP, 0, Const.VISIBLE_HEIGHT):setScale(Const.minScale)
    -- var.widget:setScaleX(Const.SCALE_X)
    -- var.widget:setScaleY(Const.SCALE_Y)
	var.widget:getWidgetByName("panel_changepk"):hide():setTouchEnabled(false)
    var.widget:getWidgetByName("panel_bufflist"):hide():setTouchEnabled(false)
    var.bossHpPanel = var.widget:getWidgetByName("Panel_bosshp"):hide()
    var.otherPlayerPanel = var.widget:getWidgetByName("Panel_otherplayer"):hide()
    var.otherPlayerOpPanel = var.widget:getWidgetByName("panel_otheropr"):hide():setTouchEnabled(false)
	-- var.widget:getWidgetByName("opr_otherinfobg"):hide():setTouchEnabled(false)
    var.selfPanel = var.widget:getWidgetByName("Panel_selfinfo")
    var.widget:getWidgetByName("panel_changepk"):addClickEventListener(function ( pSender )
        pSender:hide():setTouchEnabled(false)
    end)
    var.widget:getWidgetByName("panel_bufflist"):addClickEventListener(function ( pSender )
        pSender:hide():setTouchEnabled(false)
        pSender:removeAllChildren()
    end)

    var.otherPlayerOpPanel:addClickEventListener(function ( pSender )
        pSender:hide():setTouchEnabled(false)
    end)

    var.widget:getWidgetByName("Button_attmode"):addClickEventListener(function ( pSender )
        var.widget:getWidgetByName("panel_changepk"):show():setTouchEnabled(true)
    end)

    var.widget:getWidgetByName("Button_bufflist"):addClickEventListener(function ( pSender )
        UILeftTop.onBtnBuffClicked()
    end)

    var.otherPlayerPanel:setTouchEnabled(true):addClickEventListener(function()  UILeftTop.showOtherOpPanel() end)
    UILeftTop.addOtherOpBtn()

    for btnname,btninfo in pairs(list_pkbtn) do
        var.widget:getWidgetByName(btnname):addClickEventListener(function ( pSender )
            NetClient:ChangeAttackMode(btninfo[1])
            var.widget:getWidgetByName("panel_changepk"):hide():setTouchEnabled(false)
        end)
    end
    --[[
    var.strengthBtn = var.widget:getWidgetByName("Button_strengthen")
    var.strengthBtn:addClickEventListener(function ( pSender )
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_strengthen"})
    end)
    ]]
    var.tagIndex=1000

    UILeftTop.initRoleInfo()
    UILeftTop.updateLV()
    UILeftTop.updateFightPoint()
    UILeftTop.addBtnClicedEvent()
    UILeftTop.handleAttackModeChange()
    UILeftTop.updateBuffNum()
    UILeftTop.onButtonStatusChange()
    UILeftTop.handleVipLevelChange()
    UILeftTop.registeEvent()
end

function UILeftTop.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_LEVEL_CHANGE, UILeftTop.handleLevelChange)
    :addEventListener(Notify.EVENT_ATTRIBUTE_CHANGE, UILeftTop.updateFightPoint)
    :addEventListener(Notify.EVENT_SELF_HPMP_CHANGE, UILeftTop.handleHpMpChange)
    :addEventListener(Notify.EVENT_ATTACKMODE_CHANGE, UILeftTop.handleAttackModeChange)
    :addEventListener(Notify.EVENT_STATUS_CHANGE, UILeftTop.updateBuffNum)
    :addEventListener(Notify.EVENT_TARGET_UI_CHANGE, UILeftTop.handleTargetUIChange)
    :addEventListener(Notify.EVENT_OTHER_HPMP_CHANGE,UILeftTop.handleOtherHpMpChange)
    :addEventListener(Notify.EVENT_BOSS_OWNER_CHANGE,UILeftTop.updateBossOwner)
    :addEventListener(Notify.EVENT_BUTTON_STATUS_CHANGE,UILeftTop.onButtonStatusChange)
    :addEventListener(Notify.EVENT_SEVENLOGIN_MSG, UILeftTop.handleSevenLoginMsg)
    :addEventListener(Notify.EVENT_VIP_LEVEL_CHANGE, UILeftTop.handleVipLevelChange)
end

--[[
function UILeftTop.handleButtonShow(event)
    if not event then return end
    if event.hideType then 
        var.strengthBtn:hide()
        var.strengthBtn:setTouchEnabled(not event.hideType)
        if var.BtnEffect then
            var.BtnEffect:removeFromParent()
            var.BtnEffect = nil
        end
    else
        var.strengthBtn:show()
        var.strengthBtn:setTouchEnabled(true)
        if not var.BtnEffect then
            var.BtnEffect = gameEffect.getPlayEffect(gameEffect.EFFECT_MAINTOPBTN)
            var.BtnEffect:setPosition(cc.p(var.strengthBtn:getContentSize().width/2,var.strengthBtn:getContentSize().height/2))
            var.BtnEffect:addTo(var.strengthBtn)
        else
            var.BtnEffect:show()
        end
    end
    
end
]]

function UILeftTop.showOtherOpPanel()
    UILeftTop.resetOtherOpBtn()
--     print("TZ::resetOtherOpBtn:1234")
    var.otherPlayerOpPanel:show():setTouchEnabled(true)
    local avatar = CCGhostManager:getPixesGhostByID(MainRole.mAimGhostID)
    if avatar then
        var.mTargetName = avatar:NetAttr(Const.net_name)
        var.otherPlayerOpPanel:getWidgetByName("Text_name"):setString(var.mTargetName)
    end
end

function UILeftTop.showOtherOpPanelFromChat(strname)
    UILeftTop.resetOtherOpBtn(true)
--    print("TZ::strname:1234")
    var.mTargetName = strname
    var.otherPlayerOpPanel:show():setTouchEnabled(true)
    var.otherPlayerOpPanel:getWidgetByName("Text_name"):setString(var.mTargetName)
end

function UILeftTop.onOtherOpBtnClicked(pSender)
    local name = pSender:getName()
    if name == "Button_trade" then
        NetClient:TradeInvite(var.mTargetName)
    elseif name == "Button_viewother" then
        NetClient:CheckPlayerEquip(var.mTargetName)
    elseif name == "Button_invitegroup" then
        if #NetClient.mGroupMembers <= 0 then
            NetClient:alertLocalMsg("你还没有队伍,请先创建队伍！","alert")
        elseif NetClient.mCharacter.mGroupLeader ~= game.GetMainRole():NetAttr(Const.net_name) then
            NetClient:alertLocalMsg("只有队长才能发出邀请哦！","alert")
        elseif NetClient:isPlayerMyInGroup(var.mTargetName) then
            NetClient:alertLocalMsg("对方已在队伍中！","alert")
        elseif #NetClient.mGroupMembers >= Const.GROUP_MAX_MEMBER then
            NetClient:alertLocalMsg("队伍人数已达上限！","alert")
        else
            NetClient:InviteGroup(var.mTargetName)
        end
    elseif name == "Button_whisper" then
        NetClient:privateChatTo(var.mTargetName)
    elseif name == "Button_friendadd" then
        NetClient:FriendChange(var.mTargetName, Const.FRIEND_TITLE.FRIEND)
    elseif name == "Button_applygroup" then
        if #NetClient.mGroupMembers > 0 then
            NetClient:alertLocalMsg("你已经在队伍中了！","alert")
        else
            local group_id = NetClient:getGroupIDByName(var.mTargetName)
            if not group_id then
                NetClient:alertLocalMsg("对方不是队长！","alert")
            elseif NetClient:getNearGroupMemberByID(group_id) >= Const.GROUP_MAX_MEMBER then
                NetClient:alertLocalMsg("队伍人数已达上限！","alert")
            else
                NetClient:JoinGroup(group_id)
            end
        end
    elseif name == "Button_copyname" then

    elseif name == "Button_friendblack" then
        NetClient:FriendChange(var.mTargetName, Const.FRIEND_TITLE.BLACK)
    end
    var.otherPlayerOpPanel:hide():setTouchEnabled(false)
end

function UILeftTop.addOtherOpBtn()
    --"Button_trade","Button_copyname",
    local btnnames = {"Button_viewother", "Button_trade", "Button_invitegroup", "Button_whisper", "Button_friendadd", "Button_applygroup", "Button_friendblack" }
    var.allOpBtns = {}
    for k, name in ipairs(btnnames) do
        var.allOpBtns[k] = var.otherPlayerOpPanel:getWidgetByName(name)
        var.allOpBtns[k]:addClickEventListener(function ( pSender )
            UILeftTop.onOtherOpBtnClicked(pSender)
        end)
    end
end

function UILeftTop.resetOtherOpBtn(fromChat)
    local btns = {}
    if fromChat then
        btns = {"Button_trade", "Button_copyname"}
    else
        btns = {"Button_friendblack", "Button_applygroup", "Button_copyname","Button_trade"}
    end

    for _, btn in ipairs(var.allOpBtns) do
        btn:show()
    end

    -- for _, name in ipairs(btns) do
    --     var.otherPlayerOpPanel:getWidgetByName(name):hide()
    -- end
end

function UILeftTop.addBtnClicedEvent()
    local function btnCallBack(pSender)
        local btnName =  pSender:getName()
        if btnName == "Button_recharge" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
        elseif btnName == "Button_vip" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_vip"})
        elseif btnName == "Button_callsys" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_roleInfo"})
        elseif btnName == "Button_sevenlogin" then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_sevenlogin"})
        end
    end

    --    充值
    UIRedPoint.addUIPoint({parent=var.selfPanel:getWidgetByName("Button_recharge"),callback=btnCallBack})
    --    VIP
    UIRedPoint.addUIPoint({parent=var.selfPanel:getWidgetByName("Button_vip"),callback=btnCallBack,types={UIRedPoint.REDTYPE.VIP}})
    --    个人头像
    UIRedPoint.addUIPoint({parent=var.selfPanel:getWidgetByName("Button_callsys"),callback=btnCallBack})

    var.selfPanel:getWidgetByName("Button_sevenlogin"):addClickEventListener(btnCallBack)
end

function UILeftTop.initRoleInfo()
    local mainRole = game.GetMainNetGhost()
    if mainRole then
        var.selfPanel:getWidgetByName("Label_hp"):setString(mainRole:NetAttr(Const.net_hp))
        var.selfPanel:getWidgetByName("Label_maxhp"):setString(mainRole:NetAttr(Const.net_maxhp))
        var.selfPanel:getWidgetByName("Label_mp"):setString(mainRole:NetAttr(Const.net_mp))
        var.selfPanel:getWidgetByName("Label_maxmp"):setString(mainRole:NetAttr(Const.net_maxmp))
        var.selfPanel:getWidgetByName("LoadingBar_hpbar"):setPercent(mainRole:NetAttr(Const.net_hp)/mainRole:NetAttr(Const.net_maxhp)*100)
        var.selfPanel:getWidgetByName("LoadingBar_mpbar"):setPercent(mainRole:NetAttr(Const.net_mp)/mainRole:NetAttr(Const.net_maxmp)*100)
        var.selfPanel:getWidgetByName("Button_callsys"):loadTextures(Const.JOB_AND_GENDER[mainRole:NetAttr(Const.net_job)][mainRole:NetAttr(Const.net_gender)],"","",UI_TEX_TYPE_PLIST)
    end
end

function UILeftTop.getRoleBtn()
    return var.widget:getWidgetByName("Button_callsys")
end

function UILeftTop.updateLV()
    var.widget:getWidgetByName("Label_lvinfo"):setString(game.getRoleLevel())
end

function UILeftTop.updateFightPoint()
    -- local add = NetClient.mCharacter.mFightPoint - var.lastFight
    -- if add > 0 then
    --     UILeftTop.fightChange(add, var.lastFight)
    -- else
        var.widget:getWidgetByName("AtlasLabel_fight"):setString(NetClient.mCharacter.mFightPoint)
    -- end
end

function UILeftTop.handleLevelChange(event)
    var.widget:getWidgetByName("Label_lvinfo"):setString(event.level)
end

function UILeftTop.handleHpMpChange(event)
    if event.param then
        var.selfPanel:getWidgetByName("Label_hp"):setString(event.param.hp)
        var.selfPanel:getWidgetByName("Label_maxhp"):setString(event.param.maxhp)
        var.selfPanel:getWidgetByName("Label_mp"):setString(event.param.mp)
        var.selfPanel:getWidgetByName("Label_maxmp"):setString(event.param.maxmp)
        var.selfPanel:getWidgetByName("LoadingBar_hpbar"):setPercent(event.param.hp_pro*100)
        var.selfPanel:getWidgetByName("LoadingBar_mpbar"):setPercent(event.param.mp_pro*100)
    end
end

function UILeftTop.handleAttackModeChange( event )
    var.widget:getWidgetByName("Button_attmode"):setTitleText(pkbtn_info[NetClient.mAttackMode])
end

function UILeftTop.handleTargetUIChange(event)
    event = event or {}
    if not event.visible then
        NetClient:dispatchEvent({
            name=Notify.EVENT_SHOW_TOP_BTN,visible=true
        })
        var.showUIID = nil
        var.showUIType = nil
        var.otherPlayerPanel:hide()
        var.bossHpPanel:hide()
        return
    else
        NetClient:dispatchEvent({
            name=Notify.EVENT_SHOW_TOP_BTN,visible=false
        })
        var.showUIID = event.params.srcID
        var.showUIType = event.uitype
        if event.uitype == Const.GHOST_PLAYER then
            var.bossHpPanel:hide()
            UILeftTop.showPlayerUI(event.params)
        elseif event.uitype == Const.GHOST_MONSTER then
            var.otherPlayerPanel:hide()
            UILeftTop.showBossUI(event.params)
        end
    end
end

function UILeftTop.showPlayerUI(params)
    if not var.otherLv then
        var.otherLv = var.otherPlayerPanel:getWidgetByName("Text_lv")
    end
    if not var.otherName then
        var.otherName = var.otherPlayerPanel:getWidgetByName("Label_name")
    end
    var.otherLv:setString("Lv."..params.lv)
    var.otherName:setString(params.name)
    var.otherName:setPositionX(var.otherLv:getPositionX()+var.otherLv:getContentSize().width+10)
    var.otherPlayerPanel:getWidgetByName("ImageView_otherhead"):loadTexture(Const.JOB_AND_GENDER[params.job][params.gender],UI_TEX_TYPE_PLIST)
    UILeftTop.updateUIHp()
    var.otherPlayerPanel:show()
end

function UILeftTop.showBossUI(params)
    var.bossHpPanel:getWidgetByName("Text_lv"):setString(params.lv)

    if not var.bossName then
        var.bossName = var.bossHpPanel:getWidgetByName("Text_name")
    end
    if not var.bossOwner then
        var.bossOwner = var.bossHpPanel:getWidgetByName("Text_owner"):hide()
    end
    var.bossName:setString(game.clearNumStr(params.name))
    var.bossOwner:setPositionX(var.bossName:getPositionX()+var.bossName:getContentSize().width+10)
    var.lastPro = nil
    UILeftTop.updateBossOwner({bossid==var.showUIID})
    UILeftTop.updateUIHp()
    var.bossHpPanel:show()
end

function UILeftTop.updateBossOwner(event)
    if not event.bossid then return end
    if event.bossid ~= var.showUIID then return end
    if not NetClient.mBossOwer[event.bossid] then
        NetClient:ReqBossOwner(event.bossid)
    else
        local playername = NetClient.mBossOwer[event.bossid] or "无"
        var.bossOwner:setString("归属("..playername..")")
        var.bossOwner:setPositionX(var.bossName:getPositionX()+var.bossName:getContentSize().width+10)
        var.bossOwner:show()
    end
end

function UILeftTop.handleOtherHpMpChange(event)
    if not event.param then return end
    if not var.showUIType or not var.showUIID then return end
    if event.param.srcid ~= var.showUIID then return end
    UILeftTop.updateUIHp()
end

function UILeftTop.updateUIHp()
    local avatar = CCGhostManager:getPixesGhostByID(var.showUIID)
    if avatar then
        local hp = avatar:NetAttr(Const.net_hp)
        local maxhp = avatar:NetAttr(Const.net_maxhp)
        local pro = string.format("%0.2f", hp/maxhp) * 100

        if var.showUIType == Const.GHOST_PLAYER then
            var.bossHpPanel:hide()
            var.otherPlayerPanel:getWidgetByName("Text_hp"):setString(hp.."/"..maxhp)
            var.otherPlayerPanel:getWidgetByName("LoadingBar_hpbar"):setPercent(pro)
        elseif var.showUIType == Const.GHOST_MONSTER then
            var.otherPlayerPanel:hide()
            var.bossHpPanel:getWidgetByName("Text_hp"):setString(hp.."/"..maxhp)--,test("..var.showUIID..","..pro.."%)")
--            if not var.lastPro or (var.lastPro and pro < var.lastPro ) then
                var.bossHpPanel:getWidgetByName("LoadingBar_hpbar"):setPercent(pro)
--            end
            var.lastPro = pro
--            if var.lastPro and pro > var.lastPro then
--                printError(string.format("var.lastPro=%s,pro=%s", var.lastPro, pro))
--            end
        end
    end
end


function UILeftTop.onBtnBuffClicked()
    var.widget:getWidgetByName("panel_bufflist"):removeAllChildren()
    if not var.hasBufflist then
        var.widget:getWidgetByName("panel_bufflist"):hide():setTouchEnabled(false)
        return
    end
    var.widget:getWidgetByName("panel_bufflist"):show():setTouchEnabled(true)
    local widget = require("app.views.BuffListView").initView({
        parent = var.widget:getWidgetByName("panel_bufflist"),
    })
    widget:align(display.LEFT_TOP, 250,611)
end

function UILeftTop.updateBuffNum()
    local num = 0
    local statusMap
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        local id = MainAvatar:NetAttr(Const.net_id)
        statusMap = NetClient.mNetStatus[id]
        if statusMap then
            for k,v in pairs(statusMap) do
                if game.getStatusDescDefByID(v.id, v.param) then
                    num = num + 1
                end
            end
        end
    end

    var.hasBufflist = num>0
    var.widget:getWidgetByName("Button_bufflist"):setTitleText("状态*"..num)
end

function UILeftTop.onButtonStatusChange()
    local btn = var.selfPanel:getWidgetByName("Button_sevenlogin")
    local effectname = "higheffect"
    function removeEffect()
        if btn:getChildByName(effectname) then
            btn:removeChildByName(effectname)
        end

    end
    local visible = NetClient:getTopBtnFlag(Const.TOPBTN.btnTotalLoginReward)==2
    btn:setVisible(visible)
    if visible then
        local firstValidId,firstNextId = game.getSevenLoginSelectedId()
        if firstValidId then
            btn:getWidgetByName("Image_mt"):hide()
            btn:loadTextures(firstValidId.."DAY.png",firstValidId.."DAY.png","",UI_TEX_TYPE_PLIST)
            if not btn:getChildByName(effectname) then
                gameEffect.playEffectByType(gameEffect.EFFECT_SEVENLOGIN)
                :setPosition(cc.p(54,77)):setName(effectname):addTo(btn)
            end
        elseif firstNextId then
            btn:loadTextures(firstNextId.."DAY.png",firstNextId.."DAY.png","",UI_TEX_TYPE_PLIST)
            removeEffect()
            local tips
            if firstNextId==(NetClient.mSevenLoginInfo.loginCnt+1) then
                tips = "明日可领"
            else
                local sevenLoginDef = game.getSevenLoginDef(firstNextId)
                if not sevenLoginDef then
                    tips = ""
                else
                    local needLevel = sevenLoginDef.limit.lv
                    local needZsLevel = sevenLoginDef.limit.zhuansheng
                    tips = needZsLevel > 0 and needZsLevel.."转可领" or needLevel.."级可领"
                end
            end

            if tips ~= "" then
                btn:getWidgetByName("Image_mt"):getWidgetByName("Label_levelinfo"):setString(tips)
                btn:getWidgetByName("Image_mt"):show()
            else
                btn:getWidgetByName("Image_mt"):hide()
            end
        else
            btn:setVisible(false)
        end
    else
        removeEffect()
    end
end

function UILeftTop.handleSevenLoginMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)

    if not d.actionid then
        return
    end

    if d.actionid == "getAwards" then
        UILeftTop.onButtonStatusChange()
    elseif d.actionid == "drawCurrentAward" then
        if d.result == 0 then
            UILeftTop.onButtonStatusChange()
        end
    end
end

function UILeftTop.handleVipLevelChange()
    var.selfPanel:getWidgetByName("Button_vip"):getWidgetByName("ImageView_vplevel"):loadTexture("m_VIP".. game.getVipLevel()..".png",UI_TEX_TYPE_PLIST)
end

function UILeftTop.countOnlineTime(times)
    if UILeftTop.freshHandle then
        Scheduler.unscheduleGlobal(UILeftTop.freshHandle)
        UILeftTop.freshHandle = nil
    end
    local index = 1
    --NetClient.onlinetime = 590
    NetClient.onlinetime = times
    local function runLoading(dt)
        NetClient.onlinetime = NetClient.onlinetime+1
        if NetClient.onlinetime == NetClient.mOnlineInfo.datas[index]*60 then
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.AWARDHALL_ONLINE})
            if index == #NetClient.mOnlineInfo.datas then
                if UILeftTop.freshHandle then
                    Scheduler.unscheduleGlobal(UILeftTop.freshHandle)
                    UILeftTop.freshHandle = nil
                end
            end
            index = index + 1
        end
    end
    UILeftTop.freshHandle = Scheduler.scheduleGlobal(runLoading, 1)
end

return UILeftTop