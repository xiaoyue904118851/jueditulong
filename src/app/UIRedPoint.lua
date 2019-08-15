local UIRedPoint={}

UIRedPoint.UIBtnTab = {}
UIRedPoint.ShowRed = {}
UIRedPoint.REDTYPE = {
    SKILL = 1,
    YUANSHEN = 2,
    NEIGONG = 3,
    WING = 4,
    RING = 5,
    JIANJIA = 6,
    BAOSHI = 7,
    DUNPAI = 8,
    ANQI = 9,
    YUXI = 10,
    FIRST_CHARGE = 11,
    ZHANSHEN = 12,
    DAILYACT = 13, -- 日常限时活动 比如元宝狂欢 魔影重重等
    VITALITY = 14, -- 活跃度
    NEWMAIL = 15, -- 新邮件
    ACHIEVE = 16, -- 活跃度
    ACHIEVE1 = 17, -- 活跃度初入江湖
    ACHIEVE2 = 18, -- 活跃度等级修炼
    ACHIEVE3 = 19, -- 活跃度BOSS击杀
    ACHIEVE4 = 20, -- 活跃度强化次数
    ACHIEVE5 = 21, -- 活跃度翅膀提升
    ACHIEVE6 = 22, -- 活跃度元神提升
    -- ACHIEVE7 = 23, -- 活跃度元神提升
    OPEN_BAG_SLOT = 24, -- 背包可以免费开格子
    BOSS_WORLD =25, --世界boss
    BOSS_PERSON = 26, -- 个人boss
    ACHIEVE_MEDAL = 27,--勋章
    ROLEREBORN = 28,--转生
    ACHIEVE_PAGE = 29,--勋章页签
    REFINE_EXP = 30,--经验炼制
    OFFLINE_EXP = 31, --离线经验
    HONGBAO = 32,-- 红包
    ZHANSHEN_ACTIVE1 = 33,--战神激活
    ZHANSHEN_ACTIVE2 = 34,--战神激活
    ZHANSHEN_ACTIVE3 = 35,--战神激活
    AWARDHALL_ONLINE = 36,--奖励大厅在线
    LEVELINVEST = 37,--等级投资
    PRIVILEGECARD = 38, --尊贵特权
    VIP = 39,
    ZHANSHEN_ACTIVE4 = 40,--战神升级
    GUILD_FULI = 41,--行会福利
    GUILD_APPLY = 42,--行会申请
    GUILD_SKILL = 43,--行会技能
    GUILD_LEVEL = 44,--行会升级
    GUILD_UNION = 45,--行会联盟
    AWARDHALL_SIGN = 46,--奖励大厅签到
}

UIRedPoint.FUNC_EFFECT = {
    "Button_tiaozhan",
    "Button_mall",
    "Button_xinqu",
    "Button_tejie",
    "Button_zhengba",
    "Button_awardhall",
    "Button_offlineexp",
    "Button_hongbao",
    "Button_supervalue",
    "Button_invest",
    "Button_refineexp",
    "Button_xunbao",
    "Button_zunguitequan",
    "Button_chong",
}

UIRedPoint.FUNC_CFG = {
    [UIRedPoint.REDTYPE.SKILL] = "checkSkillPoint",
    [UIRedPoint.REDTYPE.YUANSHEN] = "checkYuanshenPoint",
    [UIRedPoint.REDTYPE.NEIGONG] = "checkNeigongPoint",
    [UIRedPoint.REDTYPE.WING] = "checkWingPoint",
    [UIRedPoint.REDTYPE.RING] = "checkRingPoint",
    [UIRedPoint.REDTYPE.JIANJIA] = "checkJianjiaPoint",
    [UIRedPoint.REDTYPE.BAOSHI] = "checkBaoshiPoint",
    [UIRedPoint.REDTYPE.DUNPAI] = "checkDunpaiPoint",
    [UIRedPoint.REDTYPE.ANQI] = "checkAnqiPoint",
    [UIRedPoint.REDTYPE.YUXI] = "checkYuxiPoint",
    [UIRedPoint.REDTYPE.FIRST_CHARGE] = "checkFirstCharagePoint",
    [UIRedPoint.REDTYPE.ZHANSHEN] = "checkZhanshenPoint",
    [UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE1] = "checkZhanshenActivePoint1",
    [UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE2] = "checkZhanshenActivePoint2",
    [UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE3] = "checkZhanshenActivePoint3",
    [UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE4] = "checkZhanshenActivePoint4",
    [UIRedPoint.REDTYPE.DAILYACT] = "checkDailyActPoint",
    [UIRedPoint.REDTYPE.VITALITY] = "checkVitalityPoint",
    [UIRedPoint.REDTYPE.NEWMAIL] = "checkNewMailPoint",
    [UIRedPoint.REDTYPE.ACHIEVE] = "checkAchievePoint",
    [UIRedPoint.REDTYPE.ACHIEVE1] = "checkAchievePoint1",
    [UIRedPoint.REDTYPE.ACHIEVE2] = "checkAchievePoint2",
    [UIRedPoint.REDTYPE.ACHIEVE3] = "checkAchievePoint3",
    [UIRedPoint.REDTYPE.ACHIEVE4] = "checkAchievePoint4",
    [UIRedPoint.REDTYPE.ACHIEVE5] = "checkAchievePoint5",
    [UIRedPoint.REDTYPE.ACHIEVE6] = "checkAchievePoint6",
    -- [UIRedPoint.REDTYPE.ACHIEVE7] = "checkAchievePoint7",
    [UIRedPoint.REDTYPE.OPEN_BAG_SLOT] = "checkOpenBagSlot",
    [UIRedPoint.REDTYPE.BOSS_WORLD] = "checkWorldBoss",
    [UIRedPoint.REDTYPE.BOSS_PERSON] = "checkPersonBoss",
    [UIRedPoint.REDTYPE.ACHIEVE_MEDAL] = "checkXunzhang",
    [UIRedPoint.REDTYPE.ROLEREBORN] = "checkroleReborn",
    [UIRedPoint.REDTYPE.ACHIEVE_PAGE] = "checkAchievePage",
    [UIRedPoint.REDTYPE.REFINE_EXP] = "checkRefineExp",
    [UIRedPoint.REDTYPE.OFFLINE_EXP] = "checkOfflineExp",
    [UIRedPoint.REDTYPE.HONGBAO] = "checkHongbao",
    [UIRedPoint.REDTYPE.AWARDHALL_ONLINE] = "checkawardhall",
    [UIRedPoint.REDTYPE.LEVELINVEST] = "checkLevelInvest",
    [UIRedPoint.REDTYPE.PRIVILEGECARD] = "checkPrivilegeCard",
    [UIRedPoint.REDTYPE.VIP] = "checkVip",
    [UIRedPoint.REDTYPE.GUILD_FULI] = "checkGuildFuli",
    [UIRedPoint.REDTYPE.GUILD_APPLY] = "checkGuildApply",
    [UIRedPoint.REDTYPE.GUILD_SKILL] = "checkGuildSkill",
    [UIRedPoint.REDTYPE.GUILD_LEVEL] = "checkGuildLevel",
    [UIRedPoint.REDTYPE.GUILD_UNION] = "checkGuildUnion",
    [UIRedPoint.REDTYPE.AWARDHALL_SIGN] = "checkAwardHallSign",
}

UIRedPoint.mPointStatus = {}
UIRedPoint.mPointBtn = {}
--
-- parent
-- callback
-- types
function UIRedPoint.addUIPoint(params)
    params = params or {}
    parent = params.parent
    types = params.types or {}
    --print("调用UIRedPoint.addUIPoint", parent:getName(), #types)
    if not parent.point then
        local point = ccui.ImageView:create()
        point:loadTexture("redpoint.png",UI_TEX_TYPE_PLIST)
        point:setAnchorPoint(cc.p(1,1))
        point:setPosition(params.position or cc.p(parent:getContentSize().width,parent:getContentSize().height))
        point:hide()
        parent:addChild(point)
        parent.point = point
    end
    if params.callback then
        parent:addClickEventListener(params.callback)
    end
    if #types > 0 then
        parent.redtypes = types
        for _, type in ipairs(types) do
            if not UIRedPoint.mPointBtn[type] then
                UIRedPoint.mPointBtn[type] = {}
            end
            local add = true
            for _, btn in ipairs(UIRedPoint.mPointBtn[type]) do
                if btn == parent then
                    add = false
                    break
                end
            end
            if add then
                table.insert(UIRedPoint.mPointBtn[type], parent)
--                print(string.format("增加 %s type=%d,此类型共有按钮=%d",parent:getName(), type, #UIRedPoint.mPointBtn[type]))
            end
        end
        parent:enableNodeEvents()
        parent:onNodeEvent("exit", function(psender)
            UIRedPoint.removeUIPoint(psender)
        end)
        if UIRedPoint.checkeffect(parent) then
            UIRedPoint.handleBtnEffect(parent,UIRedPoint.getButtonPointStatus(parent)>0)
        else
            if parent:getName() == "Button_showacti" then
                NetClient:dispatchEvent({name = Notify.EVENT_MAINTOP_RIGHTJIANBTNSHOW, showType = UIRedPoint.getButtonPointStatus(parent)>0})
            else
                parent.point:setVisible(UIRedPoint.getButtonPointStatus(parent)>0) 
            end
        end
        --parent.point:setVisible(UIRedPoint.getButtonPointStatus(parent)>0)
    end
    return parent
end

function UIRedPoint.clearAll()
    UIRedPoint.mPointStatus = {}
    UIRedPoint.mPointBtn = {}
end

function UIRedPoint.removeUIPoint(parent)
--    print("UIRedPoint.removeUIPoint=============", parent:getName())
    for _, type in ipairs(parent.redtypes) do
        for k, btn in ipairs(UIRedPoint.mPointBtn[type]) do
            if btn == parent then
                table.remove(UIRedPoint.mPointBtn[type], k)
--                print(string.format("删除 UIRedPoint.removeUIPoint = %s，此类型还有按钮=%d", btn:getName(),#UIRedPoint.mPointBtn[type]))
                break
            end
        end
    end
end

-- UIRedPoint.REDTYPE, 某个可能会变化的类型
function UIRedPoint.handleChange(types)
    local changebtn = {}

    function checkvvv(btn)
        for _, v in ipairs(changebtn) do
            if v == btn then return false end
        end
        return true
    end

    for _, type in ipairs(types) do
--        print("fun name==", UIRedPoint.FUNC_CFG[type])
        UIRedPoint.mPointStatus[type] = UIRedPoint[UIRedPoint.FUNC_CFG[type]]()
--        print(string.format("检查变化 type=%d, newvalue=%d", type,UIRedPoint.mPointStatus[type]))
        if UIRedPoint.mPointBtn[type] then
            for _, pointbtn in ipairs(UIRedPoint.mPointBtn[type]) do
                if checkvvv(pointbtn) then table.insert(changebtn, pointbtn) end
            end
        end
    end

--    print("开始更改=======",#changebtn)
    for _, pointbtn in ipairs(changebtn) do
--        print("检查按钮==",pointbtn:getName())
        local isvisble = UIRedPoint.getButtonPointStatus(pointbtn)>0
--        print(string.format("更改按钮 %s, visible=%s", pointbtn:getName(), isvisble))
        if pointbtn:getName() == "Button_menu" then
            if not NetClient.RedMenuType then
                pointbtn.point:setVisible(isvisble)
            end
        elseif pointbtn:getName() == "Button_showacti" then
            NetClient:dispatchEvent({name = Notify.EVENT_MAINTOP_RIGHTJIANBTNSHOW, showType = isvisble})
        else
            if UIRedPoint.checkeffect(pointbtn) then
                UIRedPoint.handleBtnEffect(pointbtn,isvisble)
            else
                pointbtn.point:setVisible(isvisble)
            end
        end
    end
end

function UIRedPoint.handleBtnEffect(pointbtn,isvisble)
    if not pointbtn then return end
    if isvisble then
        if not pointbtn:getChildByName("btneff") then

            local btneffect = gameEffect.getPlayEffect(gameEffect.EFFECT_MAINTOPBTN)
            btneffect:setPosition(cc.p(pointbtn:getContentSize().width/2,pointbtn:getContentSize().height/2))
            btneffect:setName("btneff")
            btneffect:addTo(pointbtn)
        else
            if pointbtn:getChildByName("btneff") then
                pointbtn:getChildByName("btneff"):show()
            end
        end
    else
        if pointbtn:getChildByName("btneff") then
            pointbtn:getChildByName("btneff"):removeFromParent()
            --pointbtn:getChildByName("btneff") = nil
        end
    end
end

function UIRedPoint.checkeffect(pointbtn)
    for i= 1,#UIRedPoint.FUNC_EFFECT do
        if UIRedPoint.FUNC_EFFECT[i] == pointbtn:getName() then
            return true
        end
    end
    return false
end

function UIRedPoint.getButtonPointStatus(pointbtn)
    local newstatus = 0
    for _, type in ipairs(pointbtn.redtypes) do
        newstatus = newstatus + (UIRedPoint.mPointStatus[type] or 0)
    end
    return newstatus
end

function UIRedPoint.checkSkillPoint()
    local zslevel = game.getZsLevel()
    local rolelevel = game.getRoleLevel()
    local skills = game.getMySkillList()
    for _, skillid in ipairs(skills) do
        local state =  game.checkUp(skillid, rolelevel, zslevel,NetClient.mCharacter.mGameMoney)
        if state == SkillDef.SKILL_LEARN_STATE.CANUP or state == SkillDef.SKILL_LEARN_STATE.CANLEARN then
            return 1
        end
    end
    return 0
end


function UIRedPoint.checkYuanshenPoint()
    local MAX_JIE = 16
    local MAX_LEVEL = 1600
    local rolelevel = game.getRoleLevel()
    local max = false

    if not NetClient.mYuanshenInfo.curlevel then
        return 0
    end
    if NetClient.mYuanshenInfo.curlevel == MAX_JIE then
        max = true
    end
    if NetClient.mYuanshenInfo.curlevel>=MAX_LEVEL then
        max = true
    end
    local nextNeedInfo

    function getNeedInfo(lv)
        for _, v in ipairs(NetClient.mYuanshenInfo.needitems) do
            if v.js == lv then
                return v
            end
        end
    end

    if not max then
        nextNeedInfo = getNeedInfo(NetClient.mYuanshenInfo.nextlevel)
    end
    if not max and nextNeedInfo then
        if nextNeedInfo.nl <= rolelevel and nextNeedInfo.nn <= NetClient.mYuanshenInfo.yuansheng then
            return 1
        end
    end

    return 0
end

function UIRedPoint.checkNeigongPoint()
    local curexp = NetClient.mCharacter.mCurNgExperience
    local maxexp = NetClient.mCharacter.mCurrentNgLevelMaxExp
    if curexp >= maxexp then
        return 1
    end
    return 0
end

function UIRedPoint.checkXunzhang()
    return NetClient.mMedalCanUp
end

function UIRedPoint.checkWingPoint()
    if not game.isFuncOpen(GuideDef.FUNCID_WING) then return 0 end
    function getSatusDef(jie,lv)
        local status_id
        local baseinfo = NetClient.mWingInfo.baseInfo.base
        if baseinfo then
            status_id =  baseinfo[jie].attrid
        end

        if status_id then
            return NetClient:getStatusDefByID(status_id, lv)
        end

    end

    local JIE_MAX = 13
    local info = NetClient.mWingInfo.info
    local baseinfo = NetClient.mWingInfo.baseInfo
    if not info or not baseinfo then return end

    local rolelevel = game.getRoleLevel()
    local zslevel = game.getZsLevel()
    local max = false
    if info.curlevel >= JIE_MAX then
        max = true
    end

    local nextAttrInfo
    if max then
        curAttrInfo = getSatusDef(info.curlevel,info.curxing)
    else
        nextAttrInfo = getSatusDef(info.nextlevel,info.nextxing)
    end

    if not max and info.nextexp and nextAttrInfo then
        local nextbaseinfo = baseinfo.base[info.nextlevel]
        if nextbaseinfo then
            if nextbaseinfo.needtype and nextbaseinfo.needtype == 0 and rolelevel < nextbaseinfo.need_level then
                return 0
            elseif nextbaseinfo.needtype and nextbaseinfo.needtype == 4 and zslevel < nextbaseinfo.need_level then
                return 0
            elseif info.curexp < info.nextexp then
                return 0
            else
                return 1
            end
        end
    end


    return 0
end

function UIRedPoint.checkRingPoint()
    function getIsActive(ringid)
        for _, v in ipairs(NetClient.mRingInfo.activeInfo) do
            if v.id == ringid then
                return v.act > 0
            end
        end
    end

    function needUp(ringid)
        --print("TZ::::::::::::::::::::::::,",#NetClient.mRingInfo.levelinfo,ringid)
        for _, v in ipairs(NetClient.mRingInfo.levelinfo) do
            if v.id == ringid then
                if v.lv == 0 then
                    --print("TZ:::::::::::----------:needUp1")
                    return -1,0
                elseif v.lv >= v.maxlv then
                    --print("TZ:::::::::::----------:needUp2")
                    return 1,0
                else
                    return 2,v.needvcoin[math.max(1,v.lv)]
                end
            end
        end
        return 0,0
    end
    
    local zslevel = game.getZsLevel()
    local viplevel = game.getVipLevel()
    local rolelevel = game.getRoleLevel()
    --if not NetClient.mRingInfo.list then return 0 end
    for _, v in ipairs(NetClient.mRingInfo.list) do
        local isActive = getIsActive(v.id)
        if not isActive then
            local needzs,needvip,needlv,needvcoin = v.c.zs or 0 ,v.c.vip or 0, v.c.lv or 0, v.c.need_vcoin or 0
            if zslevel >= needzs and viplevel >= needvip and rolelevel >= needlv and NetClient.mCharacter.mVCoin >= needvcoin then
                return 1
            end
        else
            local upret,needvcoin = needUp(v.id)
            if upret == 2 and NetClient.mCharacter.mVCoin >= needvcoin then 
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkShenluPoint(tag)
    if not game.isFuncOpen(GuideDef.FUNCID_SHENLU) then return 0 end
    local rolelevel = game.getRoleLevel()
    local zslevel = game.getZsLevel()
    local info = NetClient.mShenluInfo[tag]
    if not info then return 0 end

    local KIND_MAX = 45
    local max = false
    if info.curkind >= KIND_MAX then
        max = true
    end

    local curItemDef, nextItemDef
    if not max then
        nextItemDef = NetClient:getItemDefByID(info.base + 100*info.curlevel + info.curkind + 1)
    end

    if not max and info.needpoint and nextItemDef then
        if nextItemDef.mNeedType and nextItemDef.mNeedType == 0 and rolelevel < nextItemDef.mNeedParam then
            return 0
        elseif nextItemDef.mNeedType and nextItemDef.mNeedType == 4 and zslevel < nextItemDef.mNeedParam then
            return 0
        elseif info.exppoint < info.needpoint then
            return 0
        else
            return 1
        end
    end

    return 0
end

function UIRedPoint.checkRefineExp()
    if not NetClient:getTopBtnFlag(Const.TOPBTN.btnRefineExp) then return end
    
    if NetClient:getTopBtnFlag(Const.TOPBTN.btnRefineExp)==2 then
        if NetClient.Refineparam then
            if NetClient.Refineparam.renum > 0 then
                if #NetClient.Refineparam.data == 1 then
                    if NetClient.mCharacter.mVCoin >= NetClient.Refineparam.data[1].vcoin_num then
                        return 1
                    else
                        return 0
                    end
                else
                    for i= 1,NetClient.Refineparam.renum do
                        if NetClient.mCharacter.mVCoin >= NetClient.Refineparam.data[4-i].vcoin_num then
                            return 1
                        end
                    end
                end
            end
        end
    else
        return 0
    end
end

function UIRedPoint.checkJianjiaPoint()
    return UIRedPoint.checkShenluPoint(1)
end

function UIRedPoint.checkBaoshiPoint()
    return UIRedPoint.checkShenluPoint(2)
end

function UIRedPoint.checkDunpaiPoint()
    return UIRedPoint.checkShenluPoint(3)
end

function UIRedPoint.checkAnqiPoint()
    return UIRedPoint.checkShenluPoint(4)
end

function UIRedPoint.checkYuxiPoint()
    return UIRedPoint.checkShenluPoint(5)
end

function UIRedPoint.checkZhanshenActivePoint1()
    if NetClient.mFightState then
        if NetClient.mFightState.activecount > 0 then
            local fdata = NetClient.mFightState.fighters[1]
            if fdata and fdata.can_active == 1 and game.getRoleLevel() >= game.getFuncOpenLevel(GuideDef.FUNCID_ZHANSHEN) then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkZhanshenActivePoint2()
    if NetClient.mFightState then
        if NetClient.mFightState.activecount > 0 then
            local fdata = NetClient.mFightState.fighters[2]
            if fdata and fdata.can_active == 1 and game.getRoleLevel() >= game.getFuncOpenLevel(GuideDef.FUNCID_ZHANSHEN)then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkZhanshenActivePoint3()
    if NetClient.mFightState then
        local fdata = NetClient.mFightState.fighters[3]
        if NetClient.mFightState.activecount > 0 then
            if fdata and fdata.can_active == 1 and game.getRoleLevel() >= game.getFuncOpenLevel(GuideDef.FUNCID_ZHANSHEN) then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkZhanshenActivePoint4()
    if NetClient.mFightState then
        local need = NetClient.mFightState.updateGold
        local need_level = NetClient.mFightState.updateNextLevel
        if need and need > 0 and NetClient.mCharacter.mGameMoneyBind >= need then
            if need_level and need_level > 0 and game.getRoleLevel() >= need_level then
                if NetClient.mFightState.jielv then
                    if NetClient.mFightState.jielv.jie < 19 or NetClient.mFightState.jielv.lv < 64 then
                        return 1
                    end
                end
            end
        end
    end
    return 0
end

function UIRedPoint.checkZhanshenPoint()
    if NetClient.mFightState then
        local is_active = false
        for i=1,#NetClient.mFightState.fighters do
            local fdata = NetClient.mFightState.fighters[i]
            if fdata and fdata.active == 1 then
                is_active = true
            end
        end
        if not is_active and game.getRoleLevel() >= game.getFuncOpenLevel(GuideDef.FUNCID_ZHANSHEN) and NetClient.mFightState.activecount > 0 then
            return 1
        end
    end
    if NetClient.zhanshencaninfo then
        if NetClient.zhanshencaninfo > 0 and game.getRoleLevel() >= game.getFuncOpenLevel(GuideDef.FUNCID_ZHANSHEN) then
            return 1
        end
    end 
    return 0
end

function UIRedPoint.checkFirstCharagePoint()
    if NetClient.mFirstchargeInfo.flag == 0 and NetClient.mFirstchargeInfo.chongzi > 0 then
        return 1
    end
    return 0
end

function UIRedPoint.checkVitalityPoint()
    for k, v in ipairs(NetClient.mVitalityInfo.awardInfo) do
        if v == 1 then return 1 end
    end
    return 0
end

function UIRedPoint.checkAchievePage()
    if not game.isFuncOpen(GuideDef.FUNCID_CHENGJIU) then return 0 end

    if NetClient.mAchieveInfo and #NetClient.mAchieveInfo > 0 then
        for i=1,#NetClient.mAchieveInfo do
            local achieve_data = NetClient.mAchieveInfo[i]
            if achieve_data.flag > 0 then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkAchievePoint()
    if not game.isFuncOpen(GuideDef.FUNCID_CHENGJIU) then return 0 end

    if NetClient.mAchieveInfo and #NetClient.mAchieveInfo > 0 then
        for i=1,#NetClient.mAchieveInfo do
            local achieve_data = NetClient.mAchieveInfo[i]
            if achieve_data.flag > 0 then
                return 1
            end
        end
    end
    return UIRedPoint.checkXunzhang()
end

function UIRedPoint.checkAchievePoint1() return UIRedPoint.checkAchievePointByIndex(1) end
function UIRedPoint.checkAchievePoint2() return UIRedPoint.checkAchievePointByIndex(2) end
function UIRedPoint.checkAchievePoint3() return UIRedPoint.checkAchievePointByIndex(3) end
function UIRedPoint.checkAchievePoint4() return UIRedPoint.checkAchievePointByIndex(4) end
function UIRedPoint.checkAchievePoint5() return UIRedPoint.checkAchievePointByIndex(5) end
function UIRedPoint.checkAchievePoint6() return UIRedPoint.checkAchievePointByIndex(6) end
-- function UIRedPoint.checkAchievePoint7() return UIRedPoint.checkAchievePointByIndex(7) end

function UIRedPoint.checkAchievePointByIndex(index)
    for k,v in pairs(NetClient.mAchieveInfo) do
        if v and v.subtype == index then
            if v.flag > 0 then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkDailyActPoint()
    local strarr = string.split(NetClient.mDailyActOpenStr, "_")
    if checkint(strarr[5]) <= game.getRoleLevel() and checkint(strarr[6]) == 1 then
        return 1
    end

    return 0
end

function UIRedPoint.checkNewMailPoint()
    return NetClient.mNewMailNum > 0 and 1 or 0
end

function UIRedPoint.checkOpenBagSlot()
    local price,addnum,addexp = game.getBagSlotPrice()
    return (price == 0 and addnum > 0) and 1 or 0
end

function UIRedPoint.checkWorldBoss()
    if NetClient:getActivityList(Const.ACTIVIY_INDEX_WORLD_BOSS) then
        for _, v in ipairs( NetClient:getActivityList(Const.ACTIVIY_INDEX_WORLD_BOSS)) do
            if v.awardflag == 1 then
                return 1
            end
        end
    end   
    return 0
end

function UIRedPoint.checkroleReborn()
    if not game.GetMainNetGhost() then return 0 end
    local mylevel = game.GetMainNetGhost():NetAttr(Const.net_level)
    local needexp = 0
    if NetClient.mRebornLevel < NetClient.maxRebornLvl then
        needexp =  RebornDefData[tostring(NetClient.mRebornLevel+1)].mXiuWei or 0
    end 
    if mylevel >= 80 and NetClient.mcurExp >= needexp and NetClient.maxRebornLvl > NetClient.mRebornLevel then     
        return 1        
    end
    return 0
end

function UIRedPoint.checkPersonBoss()
    if not game.GetMainNetGhost() then return 0 end
    local zslevel = game.getZsLevel()
    local viplevel = game.getVipLevel()
    local rolelevel = game.getRoleLevel()

    for _, bosslistinfo in ipairs( NetClient:getActivityList(Const.ACTIVIY_INDEX_SINGLEBOSS)) do
        if bosslistinfo.allnum - bosslistinfo.enternum > 0 then
            local level = checkint(bosslistinfo.lv)
            local viplevel = checkint(bosslistinfo.vip)
            local reinlevel = checkint(bosslistinfo.rein)
            local check = true
            if level > 0 then
                check = rolelevel >= level
            elseif viplevel > 0 then
                check = viplevel >= viplevel
            elseif reinlevel > 0 then
                check = zslevel >= reinlevel
            end

            if bosslistinfo.itemid and bosslistinfo.itemnum and bosslistinfo.itemnum > 0 then
                local itemdef = NetClient:getItemDefByID(bosslistinfo.itemid)
                if itemdef then
                    if check then check = NetClient:getBagItemNumberById(bosslistinfo.itemid) >= bosslistinfo.itemnum end
                end
            end
            if check then return 1 end
        end
    end
    return 0
end

function UIRedPoint.checkOfflineExp()
    if NetClient.mOfflineExpInfo and NetClient.mOfflineExpInfo.offlinemin > 0 then
        return 1
    end

    return 0
end

function UIRedPoint.checkHongbao()
    if NetClient.mHongbaoNew then
        return 1
    end

    return 0
end

function UIRedPoint.checkawardhall()
    for i=1,#NetClient.mOnlineInfo.datas do
        if not NetClient.onlineAward or not NetClient.onlineAward[i] or 0 >= NetClient.onlineAward[i] then
            if NetClient.onlinetime >= NetClient.mOnlineInfo.datas[i]*60 then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkAwardHallSign()
    if NetClient:getTopBtnFlag(Const.TOPBTN.btnDaySign)==2 then
        for i=1,#NetClient.mDaySignInfo.giftflags do
            if NetClient.mDaySignInfo.giftflags[i]  == 1 then 
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkLevelInvest()
    if not NetClient.mLevelInvestInfo or not NetClient.mLevelInvestInfo.list or #NetClient.mLevelInvestInfo.list == 0 then
        return 0
    end

    if NetClient.mLevelInvestInfo.flag == 0 then
        return 0
    end

    local ret = 0
    for k,info in ipairs(NetClient.mLevelInvestInfo.list) do
        if info.flag == 0 then
            local canGet = 0
            if info.zslevel > 0 then
                if game.getZsLevel() >= info.zslevel then
                    canGet = 1
                end
            elseif info.level > 0 then
                if game.getRoleLevel() >= info.level then
                    canGet = 1
                end
            end
            info.canGet = canGet
            if canGet then ret = 1 end
        end
    end

    return ret
end

function UIRedPoint.checkPrivilegeCard()
    if not NetClient.mPrivilegeCardInfo then return 0 end
    for k, awardflag in ipairs(NetClient.mPrivilegeCardInfo.award_flag) do
        if awardflag == 0 then return 1 end
    end
    return 0
end

function UIRedPoint.checkVip()
    if not NetClient.mVipLevelGiftInfo then return 0 end
    for k, awardflag in ipairs(NetClient.mVipLevelGiftInfo) do
        if awardflag == 1 then return 1 end
    end
    return 0
end

function UIRedPoint.checkGuildFuli()
    if NetClient.mGuildFuli <= 0 then
        return 1
    end
    return 0
end

function UIRedPoint.IsNeedBright(parent,callback)
	for i=1,#UIRedPoint.ShowRed do
		local show_tab=UIRedPoint.ShowRed[i]
		for j=1,#show_tab do
			if show_tab[j] == parent:getName() then
				UIRedPoint.addUIPoint(parent,callback)
			end
		end
	end
end

function UIRedPoint.RemoveRed(name)
	for i=1,#UIRedPoint.ShowRed do
		local show_tab=UIRedPoint.ShowRed[i]
		if show_tab and name == show_tab[#show_tab] then
			table.remove(UIRedPoint.ShowRed,i)
		end
	end
end

function UIRedPoint.checkGuildApply()
    local mainGuildTitle = game.GetMainRole():NetAttr(Const.net_guild_title)
    local mainGuildName = game.GetMainRole():NetAttr(Const.net_guild_name)
    if (mainGuildName and mainGuildName ~= "") and (mainGuildTitle and mainGuildTitle >= 300) then
        local pGuild = NetClient:getGuildByName(mainGuildName)
        if pGuild and pGuild.mEnteringMembers then
            local count = 0
            for k,v in pairs(pGuild.mEnteringMembers) do
                count = count + 1
            end
            if count > 0 then
                return 1
            end
        end
    end
    return 0
end

function UIRedPoint.checkGuildSkill()
    if NetClient.mGuildSkillData and NetClient.mMyGuildSkillData then
        for i=1,#NetClient.mGuildSkillData do
            local skill_level = NetClient.mMyGuildSkillData[i][1]
            local skill_data = NetClient.mGuildSkillData[i]
            if skill_data then
                local need_type = skill_data.upgrade[tostring(skill_level)].mtype
                local need_level = skill_data.upgrade[tostring(skill_level)].need_glv
                if NetClient.myGuildLV >= need_level and skill_data.upgrade[tostring(skill_level+1)] then
                    if need_type == 4 then
                        if NetClient.mCharacter.mGameMoneyBind >= skill_data.upgrade[tostring(skill_level)].need_money then
                            return 1
                        end
                    else
                        if NetClient.mSelfGuildCT >= skill_data.upgrade[tostring(skill_level)].need_money then
                            return 1
                        end
                    end
                end
            end
        end
    end
    return 0
end

function UIRedPoint.checkGuildLevel()
    local mainGuildTitle = game.GetMainRole():NetAttr(Const.net_guild_title)
    local mainGuildName = game.GetMainRole():NetAttr(Const.net_guild_name)
    if (mainGuildName and mainGuildName ~= "") and (mainGuildTitle and mainGuildTitle >= 300) then
        local level_data = NetClient.mGuildLevelData
        if level_data then
            if level_data.level_list and level_data.guildlv then
                if level_data.guildlv < 15 then
                    local next_level = level_data.guildlv + 1
                    if level_data.level_list[next_level] then
                        if level_data.guild_exp >= level_data.level_list[next_level].exp then
                            return 1
                        end
                    end
                end
            end
        end
    end
    return 0
end

function UIRedPoint.checkGuildUnion()
    local mainGuildTitle = game.GetMainRole():NetAttr(Const.net_guild_title)
    local mainGuildName = game.GetMainRole():NetAttr(Const.net_guild_name)
    if mainGuildName ~= "" and mainGuildTitle > 0 and mainGuildTitle >= 300 then
        if #NetClient.mGuildUnionApply > 0 then
            return 1
        end
    end
    return 0
end

return UIRedPoint