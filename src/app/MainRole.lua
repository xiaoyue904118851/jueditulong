local MainRole = {}

local m_tile_step = {{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1}}

autoQG=true
autoFightBack=false

function MainRole.initVar()

	MainRole.m_isDead = false
	MainRole.mAimGhostID = 0
	MainRole.mLastAimID = 0
	MainRole.mLastAimLeftTime = 0

	MainRole.m_isReadyUseSkill=true
	MainRole.mMoveToNearAttack=false
	MainRole.m_isAutoKillMonster=false
	MainRole.mAiKeepAttack=false
    MainRole.mShowBagFullOnce = false
    MainRole.mShowBagFullTime = 0

	MainRole.mAiStartPos = nil
	MainRole.m_isAutoMoving = false
	MainRole.mTargetNPCName = ""
	MainRole.mTargetX = 0
	MainRole.mTargetY = 0
	MainRole.mMoveEndAutoPick = false
	MainRole.mMoveEndAutoTalk = false
	MainRole.mMoveEndAutoCaiji = false
	MainRole.mPlusSkill = 0
	MainRole.mMoveSpace = 2
	MainRole.mLastClickSkill = MainRole.getAiSkill()
	MainRole.mLastClickAttack = game.getTime()
	MainRole.lastClearMFDTime = game.getTime()
	MainRole.lastClearZJTime = game.getTime()
	MainRole.lastClearYLDTime = game.getTime()
	MainRole.mLastClickFindTime = game.getTime()
	MainRole.mLastCollectTime = game.getTime()
	MainRole.mMovingAndPickItem = 0

	MainRole.m_nAutoFightTime = 0

	MainRole.m_nAutoDrinkTime = 0

	MainRole.mMoveAndFinding=false
	MainRole.mFindingDir=0
	MainRole.mLastFindingDir=0
	MainRole.mRandMoveCount = 0
	MainRole.mPickingItem=0
	MainRole.mAutoCastSkill = false -- 请求服务器释放魔法盾
    MainRole.mHaveStatusMoFaDun = false -- 实际有无魔法盾buff
    MainRole.mHaveStatusZHANJIA = false -- 实际有无道士物防buff
    MainRole.mHaveStatusYOULINDUN = false -- 实际有无道士魔防buff
    MainRole.mCurSkillCircleID = 0
    MainRole.mCurSkillUsed = true
    MainRole.mCurSkillTag = 0
    MainRole.mUseSkillOnce = false
	MainRole.mLiehuoCdTime = 0
	MainRole.mTaskTarget = ""
	MainRole.mDartState = "off"
	MainRole.resetTargetRoad()

end

function MainRole.resetTargetRoad()
    MainRole.mTargetRoad = {map="",x=0,y=0}
end

function MainRole.setTargetRoad(mapname,x,y)
    MainRole.mTargetRoad = {map=mapname,x=x,y=y}
end

function MainRole.haveTargetRoad()
    if MainRole.mTargetRoad.map ~= "" and MainRole.mTargetRoad.x > 0 and MainRole.mTargetRoad.y > 0 then
        return true
    end
    return false
end

function MainRole.getAiSkill()
	local MainAvatar = CCGhostManager:getMainAvatar()
	local skill_type = Const.SKILL_TYPE_YiBanGongJi
	if not MainAvatar then return skill_type end

	if MainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
		
	elseif MainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
        local as = NetClient:getDSAutoSkill()
		if as then
			skill_type = as
		end
		-- if MainRole.mUseSkillOnce then
		-- 	if NetClient.m_netSkill[Const.SKILL_TYPE_TianZunQunDu] then
		-- 		skill_type = Const.SKILL_TYPE_TianZunQunDu
		-- 	elseif NetClient.m_netSkill[Const.SKILL_TYPE_ShiDuShu] then
		-- 		skill_type = Const.SKILL_TYPE_ShiDuShu
		-- 	end
		-- 	MainRole.mUseSkillOnce = false
		-- end
	elseif MainAvatar:NetAttr(Const.net_job) == Const.JOB_FS then
        local as = NetClient:getFSAutoSkill()
        if as then
            skill_type = as
        end
	end

	return skill_type
end

local function checkMpEnough(skill_type)
	if skill_type == Const.SKILL_TYPE_YiBanGongJi then return true end
	local MainGhost = game.GetMainNetGhost()
    if not MainGhost then return end
    local skillDef = NetClient:getSkillDefByID(skill_type)
    if skillDef and NetClient.m_netSkill[skill_type] then
    	-- return true
    	-- print("checkMpEnough" ,skill_type, MainGhost:NetAttr(Const.net_mp), skillDef.mBaseSpell, skillDef.mSpell, NetClient.m_netSkill[skill_type].mLevel)
        if MainGhost:NetAttr(Const.net_mp) >=skillDef.mBaseSpell + math.floor( skillDef.mSpell * (NetClient.m_netSkill[skill_type].mLevel + 1) * 0.25) then
            return true
        end
    end
end

function MainRole.updateEnabledSkill(skill_type)
	MainRole.updateAttr()
	local aiSkill = skill_type
	if MainRole.mJob == Const.JOB_FS then
		if skill_type == Const.SKILL_TYPE_BingPaoXiao and not checkMpEnough(skill_type) then
			aiSkill = MainRole.updateEnabledSkill(Const.SKILL_TYPE_LeiDianShu)
		end
		if skill_type == Const.SKILL_TYPE_LeiDianShu and not checkMpEnough(skill_type) then
			aiSkill = Const.SKILL_TYPE_YiBanGongJi
		end
	elseif MainRole.mJob == Const.JOB_DS then
		if skill_type == Const.SKILL_TYPE_LingHunHuoFu and not checkMpEnough(skill_type) then
			aiSkill = Const.SKILL_TYPE_YiBanGongJi
		end
	end

	return aiSkill
end

function MainRole.startCastSkill(skill_type,skill_x,skill_y)
    MainRole.updateAttr()
	skill_type = MainRole.updateEnabledSkill(skill_type)
	local MainAvatar = CCGhostManager:getMainAvatar()
	-- local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
	local mAimGhost = CCGhostManager:getPixesAvatarByID(MainRole.mAimGhostID)
    if mAimGhost then
        if mAimGhost:NetAttr(Const.net_hp) <= 0 or mAimGhost:NetAttr(Const.net_dead) then
            return
        end
    end

	if MainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
        return MainRole.startCastZsSkill(skill_type,skill_x,skill_y,MainAvatar,mAimGhost)
	else
		return MainRole.startCastFsAndDsSkill(skill_type,skill_x,skill_y,MainAvatar,mAimGhost)
	end
end

function MainRole.startCastZsSkill(skill_type,skill_x,skill_y,MainAvatar,mAimGhost)
    if game.isAllCishaSkill(skill_type) or game.isLiehuoSkill(skill_type) then
        NetClient:UseSkill(skill_type,MainRole.mX,MainRole.mY,0)
        return
    end

    if mAimGhost then
        if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_MONSTER and mAimGhost:NetAttr(Const.net_collecttime) > 0 then
            if mAimGhost:NetAttr(Const.net_hp) > 0 and not mAimGhost:NetAttr(Const.net_dead) and not NetClient.m_bReqCollect
                and not NetClient.m_bCollecting and not MainRole.mMoveEndAutoCaiji then--进度条结束后m_bCollecting应该设为false
                if MainAvatar then
                    if mAimGhost:NetAttr(Const.net_level) == 0 and NetClient.mCollectKuang then
                        return true
                    end
                    local dis = math.floor(cc.pGetDistance(cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y)),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y))))
                    if dis <= 2 then
                        MainRole.mMoveEndAutoCaiji = true
                        MainRole.mWarriorAttackCD = false
                        auto_move_end(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),6)
                    else
                        MainAvatar:startAutoMoveToPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),999)
                        MainRole.mMoveEndAutoCaiji = true
                        MainRole.mWarriorAttackCD = false
                    end
                end
            end
            return true
        end
    end
    if game.getTime() - NetClient.mCastSkillTime < 600 then
        MainRole.mWarriorAttackCD = true
        return
    end
    if game.isZsChongZhuangSkill(skill_type) then
        local plus_skill = MainRole.getZsPlusSkill()
        NetClient:UseSkill(skill_type,MainRole.mX+m_tile_step[MainRole.mDir+1][1],MainRole.mY+m_tile_step[MainRole.mDir+1][2],0,plus_skill)
        return
    end
    if mAimGhost then
        if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_SLAVE and string.find(mAimGhost:NetAttr(Const.net_name),MainAvatar:NetAttr(Const.net_name)) and game.isDamageSkill(skill_type) then return end
        local dir = game.getLogicDirection(cc.p(MainRole.mX,MainRole.mY),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y)))
        if dir ~= MainRole.mDir then
            --修正服务器方向
            NetClient:Turn(dir)
        end
        --有目标普通攻击
        local dis = math.floor(cc.pGetDistance(cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y)),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y))))

        if dis==0 or dis>MainRole.mMoveSpace or not (dis==2 and (MainRole.mX+m_tile_step[dir+1][1]*2)==mAimGhost:NetAttr(Const.net_x) and (MainRole.mY+m_tile_step[dir+1][2]*2)==mAimGhost:NetAttr(Const.net_y) ) then
            MainRole.mMoveToNearAttack = true
            if MainAvatar and (MainAvatar:PAttr(Const.avatar_state)==Const.STATE_IDLE or MainAvatar:PAttr(Const.avatar_state)==Const.STATE_PREPARE) then
                mainrole_action_start(MainAvatar)
            end
        else
            local newPlusSkill = MainRole.getPlusSkillTypeByPos(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y))
            NetClient:UseSkill(skill_type,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),newPlusSkill)
        end
    else
        local plus_skill = MainRole.getZsPlusSkill()
        NetClient:UseSkill(skill_type,MainRole.mX+m_tile_step[MainRole.mDir+1][1],MainRole.mY+m_tile_step[MainRole.mDir+1][2],0,plus_skill)
    end
end

function MainRole.startCastFsAndDsSkill(skill_type,skill_x,skill_y,MainAvatar,mAimGhost)
    if not MainRole.m_isReadyUseSkill then
        return false
    end

    if mAimGhost then
        --有目标的情况
        if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_MONSTER and mAimGhost:NetAttr(Const.net_collecttime) > 0 then
            if mAimGhost:NetAttr(Const.net_hp) > 0 and not mAimGhost:NetAttr(Const.net_dead) and not NetClient.m_bReqCollect
                and not NetClient.m_bCollecting and not MainRole.mMoveEndAutoCaiji then
                if MainAvatar then
                    if mAimGhost:NetAttr(Const.net_level) == 0 and NetClient.mCollectKuang then
                        return true
                    end
                    local dis = math.floor(cc.pGetDistance(cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y)),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y))))
                    if dis <= 2 then
                        MainRole.mMoveEndAutoCaiji = true
                        MainRole.mWarriorAttackCD = false
                        auto_move_end(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),6)
                    else
                        MainAvatar:startAutoMoveToPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),999)
                        MainRole.mMoveEndAutoCaiji = true
                        MainRole.mMageAttackCD = false
                    end
                end
            end
            return true
        end
    end
    local skill_cd = 800
    local myjob = MainAvatar:NetAttr(Const.net_job)
    if myjob == Const.JOB_DS then skill_cd = 1000 end
    if game.getTime() - NetClient.mCastSkillTime < skill_cd then
        MainRole.mLastClickSkill = skill_type
        MainRole.mMageAttackCD = true
        return false
    end
    if mAimGhost then
        --有目标的情况
        if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_SLAVE and string.find(mAimGhost:NetAttr(Const.net_name),MainAvatar:NetAttr(Const.net_name)) and game.isDamageSkill(skill_type) then return end
        local dir = game.getLogicDirection(cc.p(MainRole.mX,MainRole.mY),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y)))
        if dir ~= MainRole.mDir then
            --修正服务器方向
            NetClient:Turn(dir)
        end
        local dis = math.floor(cc.pGetDistance(cc.p(MainRole.mX,MainRole.mY),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y))))
        if skill_type == Const.SKILL_TYPE_YiBanGongJi then
            if dis > 1 then
                MainRole.mMoveToNearAttack = true
                if MainAvatar and (MainAvatar:PAttr(Const.avatar_state)==Const.STATE_IDLE or MainAvatar:PAttr(Const.avatar_state)==Const.STATE_PREPARE) then
                    mainrole_action_start(MainAvatar)
                end
            else
                NetClient:UseSkill(skill_type,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
            end
            MainRole.mAiKeepAttack = true
            -- MainRole.m_isReadyUseSkill = false
            return true
        else
            if skill_type == Const.SKILL_TYPE_JiTiYinShenShu or skill_type == Const.SKILL_TYPE_QunTiZhiLiao or skill_type == Const.SKILL_TYPE_YouLingDun or skill_type == Const.SKILL_TYPE_ShenShengZhanJiaShu then
                if mAimGhost.mType == Const.GHOST_PLAYER or mAimGhost.mType == Const.GHOST_SLAVE then
                    --辅助类技能针对玩家目标施放
                    NetClient:UseSkill(skill_type,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
                else
                    --目标为怪物则辅助技能针对空地施放
                    NetClient:UseSkill(skill_type,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),0,0)
                end
            elseif MainRole.mUseSkillOnce and myjob == Const.JOB_DS then
                if NetClient.m_netSkill[Const.SKILL_TYPE_TianZunQunDu] then
                    NetClient:UseSkill(Const.SKILL_TYPE_TianZunQunDu,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
                elseif NetClient.m_netSkill[Const.SKILL_TYPE_ShiDuShu] then
                    NetClient:UseSkill(Const.SKILL_TYPE_ShiDuShu,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
                end
                MainRole.mUseSkillOnce = false
            elseif MainRole.mUseSkillOnce and myjob == Const.JOB_FS then
                if NetClient.m_netSkill[Const.SKILL_TYPE_HuoQiang] then
                    NetClient:UseSkill(Const.SKILL_TYPE_HuoQiang,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
                end
                MainRole.mUseSkillOnce = false
            else
                local aims = #NetCC:getGhostsAroundPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),Const.GHOST_MONSTER)
                if aims > 1 and autoQG then
                    if skill_type == Const.SKILL_TYPE_LeiDianShu and NetClient.m_netSkill[Const.SKILL_TYPE_BingPaoXiao] then
                        --针对群体,雷电术自动转冰咆哮
                        skill_type = Const.SKILL_TYPE_BingPaoXiao
                    elseif skill_type == Const.SKILL_TYPE_DuoHunJianYU and NetClient.m_netSkill[Const.SKILL_TYPE_JuFengPo] then
                        --针对群体,夺魂剑雨自动转飓风破
                        skill_type = Const.SKILL_TYPE_JuFengPo
                    end
                end

--                print(skill_type,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id))
                NetClient:UseSkill(skill_type,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
            end
        end
    else
        --无目标 释放到方向3格
        local check = false
        if myjob == Const.JOB_FS then
            if skill_type == Const.SKILL_TYPE_HuoQiuShu or skill_type == Const.SKILL_TYPE_LeiDianShu or skill_type == Const.SKILL_TYPE_BingPaoXiao
            or skill_type == Const.SKILL_TYPE_HuoLongQiYan
            or skill_type == Const.SKILL_TYPE_LiuXingHuoYu or skill_type == Const.SKILL_TYPE_LieHuoLiaoYuan or skill_type == Const.SKILL_TYPE_FenTianLieYan
            or skill_type == Const.SKILL_TYPE_HuoQiang or skill_type == Const.SKILL_TYPE_HanBingZhang then
                check = true
            end
        else
            if skill_type == Const.SKILL_TYPE_LingHunHuoFu or skill_type == Const.SKILL_TYPE_ShiDuShu
            or skill_type == Const.SKILL_TYPE_DuoHunJianYU or skill_type == Const.SKILL_TYPE_JuFengPo
            or skill_type == Const.SKILL_TYPE_ZuZhouShu then
                check = true
            end
        end

        if check then
            local dx,dy = game.getDirectionPoint(MainRole.mDir,3,MainRole.mX,MainRole.mY)
            local mNearby = NetCC:getNearestGhost(Const.GHOST_MONSTER,true)
            if mNearby and mNearby:NetAttr(Const.net_collecttime) <= 0 then
                mAimGhost=mNearby
                --优先寻找附近的怪物施放
                dx = mNearby:NetAttr(Const.net_x)
                dy = mNearby:NetAttr(Const.net_y)
                CCGhostManager:selectSomeOne(mNearby:NetAttr(Const.net_id))
                NetClient:UseSkill(skill_type,dx,dy,mNearby:NetAttr(Const.net_id),0)
            else
                --默认施放在前方5格位置
                if not MainRole.m_isAutoKillMonster then
                    NetClient:UseSkill(skill_type,dx,dy,0,0)
                else
                    MainRole.mAiKeepAttack = true
                    return true
                end
            end
        else
            --默认在自己身上
            NetClient:UseSkill(skill_type,MainRole.mX,MainRole.mY,0,0)
        end
    end
    MainRole.mAiKeepAttack = true
    MainRole.m_isReadyUseSkill = false
    return true
end

function MainRole.getZsPlusSkill()
    local plus_skill = 0
    if NetClient:isSingleCishaOpen() then
        plus_skill = NetClient:getOpenedSingleCisha()
    elseif NetClient:isBanYueOpen() then
        plus_skill = Const.SKILL_TYPE_BanYueWanDao
    end
    return plus_skill
end

function MainRole.getPlusSkillTypeByPos(dx,dy)
    local plus_skill = 0
    if NetClient.m_bLiehuoAction then
--        战圣烈焰相关
        plus_skill = NetClient.m_bLiehuoSkillId
        return plus_skill
    end

	local nearGhosts = #NetCC:getGhostsAroundPos(dx,dy,Const.GHOST_MONSTER)
    if nearGhosts > 1 then
--      群攻
        if NetClient:isBanYueOpen() then
            plus_skill = Const.SKILL_TYPE_BanYueWanDao
        elseif NetClient:isSingleCishaOpen() then
            plus_skill = NetClient:getOpenedSingleCisha()
        end
    else
--     单攻
        if NetClient:isSingleCishaOpen() then
            plus_skill = NetClient:getOpenedSingleCisha()
        elseif NetClient:isBanYueOpen() then
            plus_skill = Const.SKILL_TYPE_BanYueWanDao
        end
    end
    return plus_skill
--[[
    local plus_skill = 0
    local nearGhosts
    -- if NetClient.mAttackMode ~= 101 then
    --        nearGhosts = #NetCC:getGhostsAroundPos(dx,dy,Const.GHOST_PLAYER)
    --    else
    -- 	nearGhosts = #NetCC:getGhostsAroundPos(dx,dy,Const.GHOST_MONSTER)
    --    end
    nearGhosts = #NetCC:getGhostsAroundPos(dx,dy,0)
    if NetClient:isBanYueOpen() and NetClient:isCishaOpen() then
        plus_skill = Const.SKILL_TYPE_CiShaJianShu
        if nearGhosts > 1 then
            plus_skill = Const.SKILL_TYPE_BanYueWanDao
        end
    elseif not NetClient:isBanYueOpen() and NetClient:isCishaOpen() then
        plus_skill = Const.SKILL_TYPE_CiShaJianShu
    elseif NetClient:isBanYueOpen() and not NetClient:isCishaOpen() then
        if nearGhosts > 1 then
            plus_skill = Const.SKILL_TYPE_BanYueWanDao
        end
    end
    if NetClient.m_bLiehuoAction then
        plus_skill = Const.SKILL_TYPE_LieHuoJianFa
    end
    return plus_skill
    ]]--
end

function MainRole.getPlusSkillType(mAimGhost)
	local plus_skill = 0
	local space = 1
	if NetClient:isBanYueOpen() and NetClient:isSingleCishaOpen() then
		space = 1
		plus_skill = NetClient:getOpenedSingleCisha()
	elseif not NetClient:isBanYueOpen() and NetClient:isSingleCishaOpen() then
		space = 2
		plus_skill = NetClient:getOpenedSingleCisha()
	elseif NetClient:isBanYueOpen() and not NetClient:isSingleCishaOpen() then
		space = 1
		plus_skill = Const.SKILL_TYPE_BanYueWanDao
	end
	-- if #NetCC:getGhostsAroundPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_type)) > 1 and NetClient.m_netSkill[Const.SKILL_TYPE_BanYueWanDao] then
	-- 	plus_skill = Const.SKILL_TYPE_BanYueWanDao
	-- 	space = 1
	-- 	if not NetClient:isBanYueOpen() then
 --            if mAimGhost and (mAimGhost:NetAttr(Const.net_hp) > 0 and  mAimGhost:NetAttr(Const.net_dead) == false) then
 --                NetClient:UseSkill(plus_skill,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
 --            end
	-- 	end
	-- end
	-- if #NetCC:getGhostsAroundPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_type)) == 1 and NetClient.m_netSkill[Const.SKILL_TYPE_CiShaJianShu] then
	-- 	plus_skill = Const.SKILL_TYPE_CiShaJianShu
	-- 	space = 2
	-- 	if not NetClient:isCishaOpen() then
 --            if mAimGhost and (mAimGhost:NetAttr(Const.net_hp) > 0 and  mAimGhost:NetAttr(Const.net_dead) == false) then
 --                NetClient:UseSkill(plus_skill,mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),mAimGhost:NetAttr(Const.net_id),0)
 --            end
	-- 	end
	-- end
	if NetClient.m_bLiehuoAction then
		plus_skill = NetClient.m_bLiehuoSkillId
		space = 1
	end
	return plus_skill,space
end

function MainRole.attackNearGhost()
	local mAimGhost = CCGhostManager:getPixesGhostByID(MainRole.mAimGhostID)
	if not mAimGhost then
		local mNearby = NetCC:getNearestGhost(Const.GHOST_MONSTER,true)
		if mNearby then
			mAimGhost=mNearby
			CCGhostManager:selectSomeOne(mAimGhost:NetAttr(Const.net_id))
		end
	else
		if game.getTime() - MainRole.mLastClickAttack < 600 then
			return
		end
	end
	if mAimGhost then
		if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_MONSTER and mAimGhost:NetAttr(Const.net_collecttime) > 0 then
			if mAimGhost:NetAttr(Const.net_hp) > 0 and not mAimGhost:NetAttr(Const.net_dead) and not NetClient.m_bReqCollect
                and not NetClient.m_bCollecting and not MainRole.mMoveEndAutoCaiji then--进度条结束后m_bCollecting应该设为false
				local MainAvatar = CCGhostManager:getMainAvatar()
				if MainAvatar then
                    if mAimGhost:NetAttr(Const.net_level) == 0 and NetClient.mCollectKuang then
                        return true
                    end
                    local dis = math.floor(cc.pGetDistance(cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y)),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y))))
                    if dis <= 2 then
                        MainRole.mMoveEndAutoCaiji = true
                        auto_move_end(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),6)
                    else
    					MainAvatar:startAutoMoveToPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),999)
    					MainRole.mMoveEndAutoCaiji = true
                    end
				end
			end
			return
		end
	end
	MainRole.mLastClickAttack = game.getTime()
	if not mAimGhost then return end
	MainRole.startCastSkill(MainRole.getAiSkill())
end

function MainRole.getAimGhost(ghostID)
	local mAimGhost = CCGhostManager:getPixesGhostByID(MainRole.mAimGhostID)

	if mAimGhost then
		mAimGhost.mX = mAimGhost:NetAttr(Const.net_x)
		mAimGhost.mY = mAimGhost:NetAttr(Const.net_y)
		mAimGhost.mType = mAimGhost:NetAttr(Const.net_type)
		mAimGhost.mID = mAimGhost:NetAttr(Const.net_id)
		mAimGhost.mCollectTime = mAimGhost:NetAttr(Const.net_collecttime)
		mAimGhost.mHp = mAimGhost:NetAttr(Const.net_hp)
		return mAimGhost
	end
end

function MainRole.updateAttr()
	local MainAvatar = CCGhostManager:getMainAvatar()
	if MainAvatar then
		MainRole.mID = MainAvatar:NetAttr(Const.net_id)
		MainRole.mX = MainAvatar:NetAttr(Const.net_x)
		MainRole.mY = MainAvatar:NetAttr(Const.net_y)
		MainRole.mDir = MainAvatar:NetAttr(Const.net_dir)
		MainRole.mJob = MainAvatar:NetAttr(Const.net_job)

		return MainAvatar
	end
end

function MainRole.handleAutoKillOn(isAuto)
	-- print()
	MainRole.m_isAutoKillMonster = isAuto
	if MainRole.m_isAutoKillMonster then
		local MainAvatar = CCGhostManager:getMainAvatar()
		MainRole.mAiStartPos = cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y))
		local aimGhost=NetCC:getGhostByID(MainRole.mAimGhostID)
		if not aimGhost then
			MainRole.selectNearestMonster()
		end
		MainRole.m_nAutoFightTime = game.getTime()
		MainAvatar:clearAutoMove()
		MainRole.autoKillMonster()
        MainRole.m_isAutoMoving = false
        MainRole.mMoveAndFinding=false
        MainRole.mShowBagFullOnce = false
        MainRole.mShowBagFullTime = game.getTime()
--		MainRole.autoSkillCheckAndCast()
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = true})
	else
		MainRole.mAiStartPos = nil
		MainRole.m_isAutoMoving = false
		MainRole.mMoveAndFinding=false
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = false})
	end
end

function MainRole.doNearAttack()
	local MainAvatar = CCGhostManager:getMainAvatar()
	-- local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
	local mAimGhost = CCGhostManager:getPixesAvatarByID(MainRole.mAimGhostID)
	if mAimGhost then
		MainRole.updateAttr()
        if mAimGhost:NetAttr(Const.net_hp) <= 0 or mAimGhost:NetAttr(Const.net_dead) == true then
            return
        end

		local dx = mAimGhost:NetAttr(Const.net_x)
		local dy = mAimGhost:NetAttr(Const.net_y)
		if MainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
			-- local plus_skill,space = getPlusSkillType(mAimGhost)

			if game.getTime() - NetClient.mCastSkillTime < 600 then
				MainRole.mWarriorAttackCD = true
				return
			end
			-- MainAvatar:clearAutoMove()
			if not MainAvatar:autoMoveOneStep(MainAvatar:findAttackPosition(mAimGhost:NetAttr(Const.net_id),MainRole.mMoveSpace)) then
				local newPlusSkill = MainRole.getPlusSkillTypeByPos(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y))
				NetClient:UseSkill(Const.SKILL_TYPE_YiBanGongJi,dx,dy,mAimGhost:NetAttr(Const.net_id),newPlusSkill)
			end
        else
			NetClient:UseSkill(Const.SKILL_TYPE_YiBanGongJi,dx,dy,mAimGhost:NetAttr(Const.net_id),0)
		end
	end
end

function MainRole.update()

	local MainAvatar = CCGhostManager:getMainAvatar()
	if MainAvatar:NetAttr(Const.net_dead) then
		if not MainRole.m_isDead then
			MainRole.m_isDead = true
		end
	else

		if MainRole.m_isDead then MainRole.initVar() end

		local curTime = game.getTime()
		if curTime - MainRole.m_nAutoFightTime > 300 and not NetClient.m_bCollecting then
			MainRole.m_nAutoFightTime=curTime
			MainRole.autoKillMonster()
			-- MainRole.autoSkillCheckAndCast()
		end
		if MainRole.mWarriorAttackCD then
			if game.getTime() - NetClient.mCastSkillTime >= 600 and not NetClient.m_bCollecting then
				MainRole.mWarriorAttackCD = false
				MainRole.mMoveToNearAttack = true
				mainrole_action_start(MainAvatar)
				return
			end
		end
		if MainRole.mMageAttackCD then
			local skill_cd = 800
			if MainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then skill_cd = 1000 end
			if game.getTime() - NetClient.mCastSkillTime >= skill_cd and not NetClient.m_bCollecting then
				MainRole.mMageAttackCD = false
				local aimGhost=NetCC:getGhostByID(MainRole.mAimGhostID)
				if (MainRole.mAiKeepAttack and aimGhost) then
					MainRole.startCastSkill(MainRole.mLastClickSkill)
				end
				return
			end
		end

		if MainRole.m_nAutoDrinkTime then
			if game.getTime() - MainRole.m_nAutoDrinkTime >= 1000 then
				MainRole.m_nAutoDrinkTime = game.getTime()
                MainRole.autoDrinkDrug()
			end
		end

        if MainRole.mShowBagFullOnce then
            if game.getTime() - MainRole.mShowBagFullTime >= 3000 then
                MainRole.mShowBagFullOnce = false
            end
        end
		-- if MainAvatar then
		-- 	if string.len(MainRole.mTargetNPCName)<50 and MainRole.mTargetX > 0 and MainRole.mTargetY > 0 then
		-- 		local dis = math.floor(cc.pGetDistance(cc.p(MainRole.mTargetX,MainRole.mTargetY),cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y))))-- > 15*15
		-- 		if dis <= 6 then
		-- 			local pGhost = NetCC:findGhostByName(MainRole.mTargetNPCName)
		-- 			if pGhost and pGhost:NetAttr(Const.net_type)==Const.GHOST_MONSTER then
		-- 				MainAvatar:clearAutoMove()
		-- 				MainRole.handleAutoKillOn(true)
		-- 				MainRole.mTargetNPCName = ""
		-- 			end
		-- 		end
		-- 	end
		-- end
	end
end

function MainRole.autoSkillCheckAndCast()
	local MainAvatar = CCGhostManager:getMainAvatar()
	if MainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
		if MainRole.m_isAutoKillMonster then
			if not MainRole.mHaveStatusZHANJIA and checkMpEnough(Const.SKILL_TYPE_ShenShengZhanJiaShu) then
				if game.getTime() - NetClient.mCastSkillTime >= 1000 then
					NetClient:UseSkill(Const.SKILL_TYPE_ShenShengZhanJiaShu,game.GetMainRole():NetAttr(Const.net_x),game.GetMainRole():NetAttr(Const.net_y),0,0)
				end
			end
			if not MainRole.mHaveStatusYOULINDUN and checkMpEnough(Const.SKILL_TYPE_YouLingDun) then
				if game.getTime() - NetClient.mCastSkillTime >= 1000 then
					NetClient:UseSkill(Const.SKILL_TYPE_YouLingDun,game.GetMainRole():NetAttr(Const.net_x),game.GetMainRole():NetAttr(Const.net_y),0,0)
				end
			end
		end
	end
	if game.SETTING_TABLE["check_auto_skill"] and game.SETTING_TABLE["protect_control"] then
		if MainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
			if game.getTime() - MainRole.mLiehuoCdTime > SkillDef.ZS_LIEHUO_CD * 1000 and not NetClient.m_bLiehuoAction then
                local liehuoSkill = NetClient:getHightestLiehuoSkill()
			    if liehuoSkill then
					MainRole.startCastSkill(liehuoSkill)
				end
			end
		elseif MainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
			if NetClient.mSlaveState == 0 then
                local zhskill = NetClient:getDsZhaohuanSkill()
                if zhskill then
                    MainRole.startCastSkill(zhskill)
                end
            end
		elseif MainAvatar:NetAttr(Const.net_job) == Const.JOB_FS then--自动放盾
			if not MainRole.mAutoCastSkill and not MainRole.mHaveStatusMoFaDun then
                if game.getTime() - MainRole.lastClearMFDTime > 800 then
                    if NetClient.m_netSkill[Const.SKILL_TYPE_XuanGuangDun] and  checkMpEnough(Const.SKILL_TYPE_XuanGuangDun) then
                        MainRole.startCastSkill(Const.SKILL_TYPE_XuanGuangDun)
                    elseif NetClient.m_netSkill[Const.SKILL_TYPE_MoFaDun] and  checkMpEnough(Const.SKILL_TYPE_MoFaDun) then
                        MainRole.startCastSkill(Const.SKILL_TYPE_MoFaDun)
                    end
				end
			end
		end
	end
end

function MainRole.autoGoHomeOrFly()
	if game.SETTING_TABLE["protect_control"] then
		if game.SETTING_TABLE["check_hp_fly"] then
			local MainAvatar = CCGhostManager:getMainAvatar()
			if MainAvatar then
				local mPer = MainAvatar:NetAttr(Const.net_hp)/MainAvatar:NetAttr(Const.net_maxhp)*100
				if mPer <= game.SETTING_TABLE["label_fly_percent"] then
					local Drug_tab = {10001,10004,15002}
					for i=1,#Drug_tab do
						local item_num = NetClient:getBagItemNumberById(Drug_tab[i])
						if item_num > 0 then
							local item_pos = NetClient:getItemBagPosById(Drug_tab[i])
							if item_pos then
								NetClient:BagUseItem(item_pos,Drug_tab[i])
								return
							end
						end
					end
				end
			end
		end
		if game.SETTING_TABLE["check_gohome"] then
			local MainAvatar = CCGhostManager:getMainAvatar()
			if MainAvatar then
				local mPer = MainAvatar:NetAttr(Const.net_hp)/MainAvatar:NetAttr(Const.net_maxhp)*100
				if mPer <= game.SETTING_TABLE["label_home_percent"] then
					local Drug_tab = {10002,10005}
					for i=1,#Drug_tab do
						local item_num = NetClient:getBagItemNumberById(Drug_tab[i])
						if item_num > 0 then
							local item_pos = NetClient:getItemBagPosById(Drug_tab[i])
							if item_pos then
								NetClient:BagUseItem(item_pos,Drug_tab[i])
								return
							end
						end
					end
				end
			end
		end
	end
end

function MainRole.autoBuyDrug()
    local Drug_tab = {10309,10310,10307,10308,10299,10304,10296,10301}
    for i=1,#Drug_tab do
        local item_num = NetClient:getBagItemNumberById(Drug_tab[i])
        if item_num > 0 then
            return
        end
    end
--                    背包里没有 如果是特权1 则购买
    if NetClient.mPrivilegeCardInfo.left_time[1] > 0 and NetClient.mAutoBuyDrugInfo then
        local idx = NetClient.mAutoBuyDrugInfo.idx
        local price = NetClient.mAutoBuyDrugInfo.price
        local use_level = NetClient.mAutoBuyDrugInfo.use_level
        if game.getRoleLevel() >= use_level and NetClient.mCharacter.mGameMoneyBind >= price then
            NetClient:PushLuaTable("bag",util.encode({actionid = "buy", panelid = "carryshop", params = {id = idx, page = 1, idx = idx, num = 1}}))
        end
    end
end

function MainRole.autoDrinkDrug()
	if game.SETTING_TABLE["protect_control"] then
		if game.SETTING_TABLE["check_hp"] then
			local MainAvatar = CCGhostManager:getMainAvatar()
			if MainAvatar then
				local mPer = MainAvatar:NetAttr(Const.net_hp)/MainAvatar:NetAttr(Const.net_maxhp)*100
				if mPer <= game.SETTING_TABLE["label_hp_percent"] then
					--喝血药
					local Drug_tab = {10309,10310,10307,10308,10299,10304,10296,10301,15012,15013}--万年寒霜双加血和蓝
					for i=1,#Drug_tab do
						local item_num = NetClient:getBagItemNumberById(Drug_tab[i])
						if item_num > 0 then
							local item_pos = NetClient:getItemBagPosById(Drug_tab[i])
							if item_pos then
								NetClient:BagUseItem(item_pos,Drug_tab[i])
								return
							end
						end
                    end
				end
			end
		end
		if game.SETTING_TABLE["check_mp"] then
			local MainAvatar = CCGhostManager:getMainAvatar()
			if MainAvatar then
				local mPer = MainAvatar:NetAttr(Const.net_mp)/MainAvatar:NetAttr(Const.net_maxmp)*100
				if mPer <= game.SETTING_TABLE["label_mp_percent"] then
					--喝魔药
					local Drug_tab = {15012,15013}
					for i=1,#Drug_tab do
						local item_num = NetClient:getBagItemNumberById(Drug_tab[i])
						if item_num > 0 then
							local item_pos = NetClient:getItemBagPosById(Drug_tab[i])
							if item_pos then
								NetClient:BagUseItem(item_pos,Drug_tab[i])
								return
							end
						end
					end
				end
			end
		end
	end
end

function MainRole.getAutoKillSkill()
	local MainAvatar = CCGhostManager:getMainAvatar()
	local skill_type = Const.SKILL_TYPE_YiBanGongJi

	if MainAvatar:NetAttr(Const.net_mp) >= 18 then
		if MainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
			
		elseif MainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
            local as = NetClient:getDSAutoSkill()
            if as then
                skill_type = as
            end
		elseif MainAvatar:NetAttr(Const.net_job) == Const.JOB_FS then
            local as = NetClient:getFSAutoSkill()
            if as then
                skill_type = as
            end
		end
	end

	return skill_type
end

function MainRole.handleAttacked(attacker)
	if not MainRole.m_isAutoKillMonster and not MainRole.m_isAutoMoving and autoFightBack then
		local aimGhost=NetCC:getGhostByID(MainRole.mAimGhostID)
		if not aimGhost then
			local acker=NetCC:getGhostByID(attacker)
			if acker and (acker:NetAttr(Const.net_type)==Const.GHOST_MONSTER or acker:NetAttr(Const.net_type)==Const.GHOST_PLAYER) then
				CCGhostManager:selectSomeOne(attacker)
				if acker:NetAttr(Const.net_type)==Const.GHOST_PLAYER then
					NetClient:ChangeAttackMode(100)
				end
				MainRole.attackNearGhost()
			end
		else
			MainRole.attackNearGhost()
		end
	end
end

function MainRole.autoKillMonster()
	MainRole.autoSkillCheckAndCast()
	if MainRole.m_isAutoKillMonster then
		local mainAvatar = CCGhostManager:getMainAvatar()
		MainRole.updateAttr()
		-- MainRole.autoSkillCheckAndCast()
		--不会打断寻路
		if not MainRole.m_isAutoMoving and not MainRole.mMoveAndFinding then
			local aimGhost=NetCC:getGhostByID(MainRole.mAimGhostID)
			if not aimGhost or (aimGhost:NetAttr(Const.net_type)~=Const.GHOST_MONSTER and aimGhost:NetAttr(Const.net_type)~=Const.GHOST_PLAYER) then
				if false then--cc.pDistanceSQ(MainRole.mAiStartPos,cc.p(MainRole.mX,MainRole.mY)) > 15*15 then --距离挂机起始点超过一定距离返回
					if mainAvatar then
						mainAvatar:startAutoMoveToPos(MainRole.mAiStartPos.x,MainRole.mAiStartPos.y)
						MainRole.m_isAutoMoving = true
					end
				else
					local items=NetCC:getNearGhost(Const.GHOST_ITEM)
					--这里写捡物品的优先逻辑
					if game.SETTING_TABLE["pick_control"] and #items>0 then
						if not NetClient:isBagFull() then
							if MainRole.mMoveEndAutoPick then--正在捡物品
								return
							end
							if not MainRole.mMoveEndAutoPick then
								
								local item = MainRole.getNearestItemByCon()
								if item and item:NetAttr(Const.net_id)~=MainRole.mPickingItem then
								-- for _,v in ipairs(items) do
								-- 	local item=NetCC:getGhostByID(v)
								-- 	if item and v~=MainRole.mPickingItem then
										if MainRole.checkPickItem(item) then
											local onwer = item:NetAttr(Const.net_item_onwer)
											local ittype = item:NetAttr(Const.net_itemtype)
											if onwer <=0 or onwer == MainRole.mID then
												if mainAvatar then
													if item:NetAttr(Const.net_x) == mainAvatar:NetAttr(Const.net_x) and item:NetAttr(Const.net_y) == mainAvatar:NetAttr(Const.net_y) then
														NetClient:PickUp(item:NetAttr(Const.net_id))
														MainRole.mPickingItem=item:NetAttr(Const.net_id)
														return
													else
														if item:NetAttr(Const.net_id) ~= MainRole.mMovingAndPickItem then
															mainAvatar:startAutoMoveToPos(item:NetAttr(Const.net_x),item:NetAttr(Const.net_y))
															MainRole.mMoveEndAutoPick=true
															MainRole.m_isAutoMoving = true
															MainRole.mMovingAndPickItem = item:NetAttr(Const.net_id)
															return
														else
															-- print("AAAAAAAAAAAAAAAAAA",item:NetAttr(Const.net_x),mainAvatar:NetAttr(Const.net_x),item:NetAttr(Const.net_y),mainAvatar:NetAttr(Const.net_y))
														end
													end
												end
											end
										end
								-- 	end
								elseif item and item:NetAttr(Const.net_id)==MainRole.mPickingItem and MainRole.checkPickItem(item) then
									return
								end
							end
						else
                            if not MainRole.mShowBagFullOnce then
                                NetClient:alertLocalMsg("包裹已满","alert")
                                MainRole.mShowBagFullOnce = true
                                MainRole.mShowBagFullTime = game.getTime()
                            end
						end
					end
					local mMonster
					if MainRole.mTaskTarget ~= "" then
						mMonster = NetCC:getNearestGhostByName(MainRole.mTaskTarget,true)
					end
					if not mMonster then
						if NetClient.mAttackMode ~= 101 then
							MainRole.selectNearPlayer(true)
							-- return
						else
							mMonster = NetCC:getNearestGhost(Const.GHOST_MONSTER)
						end
					--只会找到活的怪物
					end
					if mMonster then
						CCGhostManager:selectSomeOne(mMonster:NetAttr(Const.net_id))
					else
						-- if not game.mWanderFight then
						-- 	if mainAvatar then
						-- 		mainAvatar:startAutoMoveToPos(MainRole.mAiStartPos.x,MainRole.mAiStartPos.y)
						-- 		MainRole.m_isAutoMoving = true
						-- 	end
						-- else
							MainRole.mMoveAndFinding=true
						-- end
					end
				end
			else
				local mAimGhost = NetCC:getGhostByID(MainRole.mAimGhostID)
				if mAimGhost then
					-- if mAimGhost:NetAttr(Const.net_collecttime) > 0 then
					-- 	if mAimGhost:NetAttr(Const.net_hp) > 0 and (not NetClient.m_bReqCollect and not NetClient.m_bCollecting) then--进度条结束后m_bCollecting应该设为false
					-- 		local MainAvatar = CCGhostManager:getMainAvatar()
					-- 		if MainAvatar then
					-- 			-- local dis = math.floor(cc.pGetDistance(cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y)),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y))))
					-- 			MainAvatar:startAutoMoveToPos(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y),999)
					-- 			MainRole.mMoveEndAutoCaiji = true
					-- 			-- if dis <= 2 then return end
					-- 		end
					-- 	end
     --                else
     					if MainRole.mMoveEndAutoPick then return end
                    	if mAimGhost:NetAttr(Const.net_ortype) == 511 and mAimGhost:NetAttr(Const.net_rn_zy) <= 2 then return end
						-- if mAimGhost:NetAttr(Const.net_jingying) >= 1 and mainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then

						-- end
						MainRole.startCastSkill(MainRole.getAiSkill())
					-- end
				end
			end
		end
	end
end

function MainRole.clearAimGhost()
    local mAimGhost = NetCC:getGhostByID(MainRole.mAimGhostID)
    if mAimGhost then
        MainRole.mAimGhostID=0
        MainRole.mAiKeepAttack = false
    end
end

function MainRole.startAutoMoveToMap(mapname,tx,ty,flag,flystr)
--    print("findroad=== 1", mapname,tx,ty,flag)
	local MainAvatar = CCGhostManager:getMainAvatar()
	MainAvatar:clearAutoMove()
	MainRole.handleAutoKillOn(false)
	NetClient.m_targetMap = mapname
    MainRole.setTargetRoad(mapname,tx,ty)
    MainRole.stopAttackOfSoldier()
	if NetClient.mNetMap.mMapID == mapname then
		MainAvatar:startAutoMoveToPos(tx,ty,flag)
		-- MainRole.m_isAutoMoving = true
    else
        -- NetClient:PushLuaTable("player.DirectFly",util.encode({map=mapname,x=tx,y=ty}))

		NetClient.mTargetMapX = tx
		NetClient.mTargetMapY = ty
		if MainRole.searchCrossMapPath() then
			NetClient.mCrossAutoMove = true
			NetClient.mCrossAutoMoveFlag = flag
			local mapConn = NetClient.mMapConn[NetClient.mCrossMapPath[#NetClient.mCrossMapPath]]
        	if flag == 3 then flag = 1 elseif flag == 2 then flag = 0 end
			MainAvatar:startAutoMoveToPos(mapConn.mFromX,mapConn.mFromY,flag)
			-- self.mMoveToCross=true
			table.remove(NetClient.mCrossMapPath)
--            print("findroad=== 2", mapConn.mFromX,mapConn.mFromY,flag)
		else
			if flystr and flystr ~= "" then
				local param=string.split(flystr,"_")
				if param[2] == "zhouhuan" then
					NetClient:PushLuaTable("npc.biqi.paohuan.onGetJsonData",util.encode({actionid = "fly",target_id = param[3]}))
				-- elseif param[1]=="fly" then
				-- 	NetClient:DirectFly(param[2])
				else
	            	NetClient:PushLuaTable("player.DirectFly",util.encode({map=mapname,x=tx-1,y=ty}))
                    print("此场景无法寻路到目标场景，直飞", mapname,tx,ty,flag,flystr)
--	            	NetClient:alertLocalMsg("此场景无法寻路到目标场景，直飞", "mid")
				end
			else
			    print("Failed to search a road!!!")
	            -- NetClient:PushLuaTable("player.DirectFly",util.encode({map=mapname,x=tx-1,y=ty}))
                print("此场景无法寻路到目标场景", mapname,tx,ty,flag,flystr)
	            NetClient:alertLocalMsg("此场景无法寻路到目标场景", "mid")
	        end
       end
	end
end

function MainRole.searchCrossMapPath()
	while #NetClient.mCrossMapPath > 0 do
		table.remove(NetClient.mCrossMapPath)
	end
	local q ={}
	local closeList = {}
	local visitSet = {}
	local curNode = {name="",parent=-1}
	curNode.name = NetClient.mNetMap.mMapID
	curNode.parent = -1
	table.insert(q,curNode)
	while #q > 0 do
		curNode = q[#q]
		table.remove(q)
		table.insert(closeList,curNode)
		if curNode.name == NetClient.m_targetMap then
			while curNode.parent ~= -1 do
				table.insert(NetClient.mCrossMapPath,curNode.name)
				curNode = closeList[curNode.parent]
			end
			return true
		end
		local p = #closeList
		local node = MapConnDefData[curNode.name]
		local size = 0
		if node then
			size = #node
		end
		for i=1,size do
			if visitSet[node[i]] == nil then
				visitSet[node[i]] = node[i]
				local cur={name="",parent=-1}
				cur.name = node[i]
				cur.parent = p
				table.insert(q,cur)
			end
		end
	end
	return false
end

function MainRole.checkAutoMove()
	local MainAvatar = CCGhostManager:getMainAvatar()
	if NetClient.mCrossAutoMove then
		if NetClient.m_targetMap ~= NetClient.mNetMap.mMapID then
			if #NetClient.mCrossMapPath > 0 then
				local mapConn = NetClient.mMapConn[NetClient.mCrossMapPath[#NetClient.mCrossMapPath]]
                if mapConn then
                	print("TZ:checkAutoMove:X",mapConn.mFromX)
                	print("TZ:checkAutoMove:X",mapConn.mFromY)
				    MainAvatar:startAutoMoveToPos(mapConn.mFromX,mapConn.mFromY,NetClient.mCrossAutoMoveFlag == 3 and 1 or 0)
                else
                    print("The cross mapConn is null !")
                    NetClient.mCrossAutoMove = false
                    NetClient.mCrossAutoMoveFlag = 0
                end
				-- self.mMoveToCross=true
				table.remove(NetClient.mCrossMapPath)
			else
				----print("The cross path list is already empty!")
				NetClient.mCrossAutoMove = false
				NetClient.mCrossAutoMoveFlag = 0
			end
		else
			NetClient.mCrossAutoMove = false
			MainAvatar:startAutoMoveToPos(NetClient.mTargetMapX,NetClient.mTargetMapY,NetClient.mCrossAutoMoveFlag)
			NetClient.mCrossAutoMoveFlag = 0
		end
	end
end

function MainRole.stopAttackOfSoldier()
	local mainAvatar = game.GetMainNetGhost()
	-- if mainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
		if MainRole.m_isAutoKillMonster then MainRole.m_isAutoKillMonster = false end
		if MainRole.mAiKeepAttack then MainRole.mAiKeepAttack = false end
        MainRole.mShowBagFullOnce = false
		NetClient.m_bReqCollect = false
		MainRole.mMoveEndAutoCaiji = false
		MainRole.mMoveEndAutoPick = false
		MainRole.mMoveEndAutoTalk = false
		MainRole.mMoveAndFinding=false
        MainRole.mPickingItem = 0
        MainRole.mMovingAndPickItem = 0
        MainRole.clearAimGhost()
	-- end
end

function MainRole.selectNearPlayer(killMon,showAlert)
	local MainAvatar = CCGhostManager:getMainAvatar()
	if NetClient.mAttackMode == 101 then
		NetClient:alertLocalMsg("和平模式无法攻击玩家！","alert")
		return
	else
		local mNearby = NetCC:getNearGhost(Const.GHOST_PLAYER)
		if NetClient.mAttackMode == 102 then--team
			if NetClient.mCharacter.mGroupID and NetClient.mCharacter.mGroupID > 0 then
				for i,v in ipairs(mNearby) do
					local tempGhost = NetCC:getGhostByID(v)
					if tempGhost and tempGhost:NetAttr(Const.net_teamid) > 0 and tempGhost:NetAttr(Const.net_teamid) ~= NetClient.mCharacter.mGroupID then
						CCGhostManager:selectSomeOne(v)
						return
					end
				end
				if showAlert then
					NetClient:alertLocalMsg("附近没有其他队伍玩家！","alert")
				end
			else
				if showAlert then
					NetClient:alertLocalMsg("你没有队伍！","alert")
				end
			end
			if killMon then
				MainRole.selectNearMonster()
			end
			return
		end
		if NetClient.mAttackMode == 103 then--guild
			if MainAvatar:NetAttr(Const.net_guild_title) and MainAvatar:NetAttr(Const.net_guild_title) > 101 then
				for i,v in ipairs(mNearby) do
					local tempGhost = NetCC:getGhostByID(v)
					if tempGhost and tempGhost:NetAttr(Const.net_guild_name) ~= MainAvatar:NetAttr(Const.net_guild_name) then
						CCGhostManager:selectSomeOne(v)
						return
					end
				end
				if showAlert then
					NetClient:alertLocalMsg("附近没有其他行会玩家！","alert")
				end
			else
				if showAlert then
					NetClient:alertLocalMsg("你没有行会！","alert")
				end
			end
			if killMon then
				MainRole.selectNearMonster()
			end
			return
		end
		-- if NetClient.mAttackMode == 104 then--善恶和阵营尚未完成
		-- 	for i,v in ipairs(mNearby) do
		-- 		local tempGhost = NetCC:getGhostByID(v)
		-- 		print(tostring(tempGhost:NetAttr(Const.net_pkvalue)))
		-- 		if tempGhost and tempGhost:NetAttr(Const.net_pkvalue) and tempGhost:NetAttr(Const.net_pkvalue) > 0 then
		-- 			CCGhostManager:selectSomeOne(v)
		-- 			return
		-- 		end
		-- 	end
		-- 	NetClient:alertLocalMsg("附近没有红名玩家！","alert")
		-- 	return
		-- end
		if NetClient.mAttackMode == 105 then--神魔战场
			for i,v in ipairs(mNearby) do
				local tempGhost = NetCC:getGhostByID(v)
				if tempGhost and tempGhost:NetAttr(Const.net_teamid) and tempGhost:NetAttr(Const.net_teamid) ~= MainAvatar:NetAttr(Const.net_teamid) then
					CCGhostManager:selectSomeOne(v)
					return
				end
			end
			if killMon then
				MainRole.selectNearMonster()
			end
			return
		end
		if #mNearby > 0 then
			local randomGhost = NetCC:getGhostByID(mNearby[math.random(1,#mNearby)])
			if randomGhost then
				CCGhostManager:selectSomeOne(randomGhost:NetAttr(Const.net_id))
			end
		else
			if killMon then
				if not MainRole.m_isAutoKillMonster then
					MainRole.selectNearMonster()
				else
					MainRole.attackNearGhost()
				end
			else
				if showAlert then
					NetClient:alertLocalMsg("附近没有玩家！","alert")
				end
			end
		end
	end
end

function MainRole.selectNearMonster()
	local mNearby = NetCC:getNearGhost(Const.GHOST_MONSTER)
	if #mNearby > 0 then
		local randomGhost = NetCC:getGhostByID(mNearby[math.random(1,#mNearby)])
		if randomGhost then
			CCGhostManager:selectSomeOne(randomGhost:NetAttr(Const.net_id))
		end
	else
		NetClient:alertLocalMsg("附近没有怪物！","alert")
	end
end

function MainRole.selectNearestMonster()
	local mMonster
	if MainRole.mTaskTarget ~= "" then
		mMonster = NetCC:getNearestGhostByName(MainRole.mTaskTarget,true)
	end
	if not mMonster then
		mMonster = NetCC:getNearestGhost(Const.GHOST_MONSTER)
	--只会找到活的怪物
	end
	if mMonster then
		CCGhostManager:selectSomeOne(mMonster:NetAttr(Const.net_id))
	end
end

function MainRole.selectNpcAndTalkByPos(targetX,targetY)
	local result = NetCC:getGhostsAroundPos(targetX,targetY,Const.GHOST_NPC)
    if result and result[1] then
        local targetGhost = NetCC:getGhostByID(result[1])
        if targetGhost then
            if targetGhost:NetAttr(Const.net_type) == Const.GHOST_NPC then
            	if MainRole.mAimGhostID > 0 and targetGhost:NetAttr(Const.net_id) ~= MainRole.mAimGhostID then
                	MainRole.mAimGhostID = targetGhost:NetAttr(Const.net_id)
                end
            	CCGhostManager:selectSomeOne(targetGhost:NetAttr(Const.net_id))
                NetClient:NpcTalk(targetGhost:NetAttr(Const.net_id),"100")
            elseif targetGhost:NetAttr(Const.net_type) == Const.GHOST_ITEM then

            end
        end
    end
end

function auto_move_start(targetX,targetY,flag)
	-- local MainAvatar = CCGhostManager:getMainAvatar()
	-- if cc.pDistanceSQ(cc.p(targetX, targetY), cc.p(MainAvatar:PAttr(Const.AVATAR_X), MainAvatar:PAttr(Const.AVATAR_Y))) >= 30*30 then--超过一定距离才显示骑马
	if not MainRole.m_isAutoKillMonster then
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_move" , visible = true})
		MainRole.m_isAutoMoving = true
	end
	-- end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_AUTOMOVE_START,"auto_move_start")

function auto_move_end(targetX,targetY,flag)
	
	MainRole.m_isAutoMoving = false
	print("auto_move_end==========",targetX,targetY,flag)
    MainRole.updateAttr()
	local MainAvatar = CCGhostManager:getMainAvatar()
--	if MainAvatar then
--		MainAvatar:clearAutoMove()
--        local dir = game.getLogicDirection(cc.p(MainAvatar:PAttr(Const.AVATAR_X),MainAvatar:PAttr(Const.AVATAR_Y)),cc.p(targetX,targetY))
--        if dir ~= MainAvatar:NetAttr(Const.net_dir) then
--            --修正服务器方向
--            print("auto_move_end go turn")
--            NetClient:Turn(dir)
--        end
--
--    end
    if not MainRole.mMoveEndAutoTalk then
        MainRole.selectNpcAndTalkByPos(targetX,targetY)
    end
	if MainRole.mTargetNPCName~="" then
		if MainRole.mTargetNPCName=="autofightstart" then
			MainRole.mTargetNPCName = ""
			MainRole.handleAutoKillOn(true)
		elseif string.len(MainRole.mTargetNPCName)<50 then
			local pGhost = NetCC:findGhostByName(MainRole.mTargetNPCName)
			if pGhost and pGhost:NetAttr(Const.net_type)==Const.GHOST_MONSTER then
				MainRole.handleAutoKillOn(true)
				MainRole.mTargetNPCName = ""
			end
		end
	end
	NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_move" , visible = false})
	-----------------寻路终止自动显示挂机-------- ---------
	-- if (#(NetCC:getNearGhost(Const.GHOST_MONSTER)) > 0 or #(NetCC:getNearGhost(Const.GHOST_ITEM)) > 0) then
	-- 	NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = true})
	-- end

	-----------------寻路终止自动捡物品-----------------
	if MainRole.mMoveEndAutoPick then
		local netGhost = NetCC:getGhostAtPos(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y),Const.GHOST_ITEM)
		if #netGhost>0 then
			NetClient:PickUp(netGhost[1])
			MainRole.mPickingItem=netGhost[1]
		end
		MainRole.mMoveEndAutoPick=false
	end

	if MainRole.mMoveEndAutoTalk then
		if MainRole.mAimGhostID > 0 then
			local mAimGhost = CCGhostManager:getPixesAvatarByID(MainRole.mAimGhostID)
			if mAimGhost then
				if MainRole.mTargetNPCName == "" or MainRole.mTargetNPCName == mAimGhost:NetAttr(Const.net_name) then
					local pid = mAimGhost:NetAttr(Const.net_id)
					NetClient:NpcTalk(pid,"100")
				else
					MainRole.selectNpcAndTalkByPos(targetX,targetY)
				end
			end
		end
		MainRole.mMoveEndAutoTalk=false
	end

	if MainRole.mMoveEndAutoCaiji then
		if MainRole.mAimGhostID > 0 then
			local mAimGhost = CCGhostManager:getPixesAvatarByID(MainRole.mAimGhostID)
			if mAimGhost then
				if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_MONSTER and mAimGhost:NetAttr(Const.net_collecttime) > 0 then
					if mAimGhost:NetAttr(Const.net_hp) > 0 and not NetClient.m_bCollecting then--进度条结束后m_bCollecting应该设为false
						-- local dir = game.getLogicDirection(cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y)),cc.p(mAimGhost:NetAttr(Const.net_x),mAimGhost:NetAttr(Const.net_y)))
						-- NetClient:Turn(dir)
						NetClient:StartCollect(mAimGhost:NetAttr(Const.net_id))
						MainRole.mLastCollectTime = game.getTime()
					end
				end
			end
		end
		MainRole.mMoveEndAutoCaiji=false
	end

	if MainRole.m_isAutoKillMonster then
		MainRole.autoKillMonster()
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_AUTOMOVE_END,"auto_move_end")

function mainrole_action_start(PixesMainAvatar)
	if PixesMainAvatar then
		local  mAimGhost = nil
		if MainRole.mAimGhostID > 0 then
			mAimGhost = CCGhostManager:getPixesAvatarByID(MainRole.mAimGhostID)
		end
		if mAimGhost and mAimGhost:NetAttr(Const.net_type) ~= Const.GHOST_NPC then
			if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_MONSTER and mAimGhost:NetAttr(Const.net_collecttime) > 0 then
				return
			end
			if mAimGhost:NetAttr(Const.net_type) == Const.GHOST_SLAVE and string.find(mAimGhost:NetAttr(Const.net_name),PixesMainAvatar:NetAttr(Const.net_name)) then return end
			if MainRole.mMoveToNearAttack then
				if(mAimGhost and not mAimGhost:NetAttr(Const.net_dead)) then
					-- local plus_skill,space = getPlusSkillType(mAimGhost)
					if (game.isLiehuoSkill(MainRole.mPlusSkill) and not NetClient.m_bLiehuoAction)
					or (not game.isLiehuoSkill(MainRole.mPlusSkill) and NetClient.m_bLiehuoAction) then
						MainRole.mPlusSkill,MainRole.mMoveSpace = MainRole.getPlusSkillType(mAimGhost)
					end
					if PixesMainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS then
						if game.getTime() - MainRole.mLastClickFindTime >= 480 then
							MainRole.mWarriorAttackCD = false
							MainRole.mLastClickFindTime = game.getTime()
						end
					end
					if not PixesMainAvatar:autoMoveOneStep(PixesMainAvatar:findAttackPosition(mAimGhost:NetAttr(Const.net_id),MainRole.mMoveSpace)) then
						MainRole.doNearAttack()
					end
				else
					MainRole.mMoveToNearAttack=false
				end
				return 1
			elseif PixesMainAvatar:NetAttr(Const.net_job) == Const.JOB_FS or PixesMainAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
				if MainRole.mAiKeepAttack then
					if(mAimGhost and not mAimGhost:NetAttr(Const.net_dead))  then
						MainRole.startCastSkill(MainRole.getAiSkill())
					else
						MainRole.mAiKeepAttack = false
					end
				end
			end
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAINROLE_ACTIONSTART,"mainrole_action_start")

function MainRole.randMove()
	local mainAvatar = CCGhostManager:getMainAvatar()
	if mainAvatar then
		if MainRole.nextDirPosIsNotBlock(MainRole.mFindingDir) and mainAvatar:actionRun(MainRole.mFindingDir) then
			-- print("mainAvatar:actionRun")
			MainRole.mRandMoveCount = 0
			MainRole.mLastFindingDir=MainRole.mFindingDir
			return
		else
			local dirb=(MainRole.mFindingDir+4)%8
			local dir2=MainRole.mFindingDir
			for i=1,100 do
				dir2=math.floor(math.random(0,100))%8
				if dir2~=MainRole.mLastFindingDir and dir2~=dirb then
					MainRole.mFindingDir=dir2
					if MainRole.mRandMoveCount > 10 then
						MainRole.stopAttackOfSoldier()
            			NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = false})
						NetClient:alertLocalMsg("此位置无法寻路！","alert")
						return
					end
					MainRole.randMove()
					MainRole.mRandMoveCount = MainRole.mRandMoveCount + 1
					-- print("mainAvatar:randMove")
					return
				end
			end
		end
	end
end

function MainRole.nextDirPosIsNotBlock(dir)
	local mainAvatar = CCGhostManager:getMainAvatar()
	if mainAvatar then
		local next_x,next_y = game.getDirectionPoint(dir,1,mainAvatar:NetAttr(Const.net_x),mainAvatar:NetAttr(Const.net_y))
		if not NetCC:getMap():getLogicBlock(next_x,next_y) then
			return true
		end
	end
	return false
end

function MainRole.checkPickItem( item )
	if item then
		local item_name = item:NetAttr(Const.net_name)
		local itemdef = NetClient:getItemDefByName(item_name)
		if itemdef then
			if game.IsDissipative(itemdef.mTypeID) then--材料
				local isGold = false
				local isDrug = false
				if itemdef.mTypeID == 19000 or itemdef.mTypeID == 19007 then
					isGold = true
					if game.SETTING_TABLE["check_gold"] then--捡金币
						return true
					end
				end
				if itemdef.mTypeID == 10296 or itemdef.mTypeID == 10299 or itemdef.mTypeID == 10301 
					or itemdef.mTypeID == 10304 or itemdef.mTypeID == 10307 or itemdef.mTypeID == 10308 
					or itemdef.mTypeID == 10309 or itemdef.mTypeID == 10310 or itemdef.mTypeID == 15013 then
					isDrug = true
					if game.SETTING_TABLE["check_drug"] then--捡药水
						return true
					end
				end
				if game.SETTING_TABLE["check_other"] and not isGold and not isDrug then--捡其他
					return true
				end
				return false
			else
				if itemdef.mNeedType == 0 then--普通装备
					if game.SETTING_TABLE["check_pick_level"] and itemdef.mNeedParam >= game.SETTING_TABLE["num_pick_level"] then--需求等级
						return true
					elseif not game.SETTING_TABLE["check_pick_level"] then
						return true
					end
				elseif itemdef.mNeedType == 4 then--转生装备
					if game.SETTING_TABLE["check_zs_item"] then
						return true
					end
				end
				return false
			end
			return false
		end
		return false
	end
	return false
end

function MainRole.getNearestItemByCon()
	local result
	local items=NetCC:getNearGhost(Const.GHOST_ITEM)
	if #items>0 then
		for _,v in ipairs(items) do
			local item=NetCC:getGhostByID(v)
			if item then
				if MainRole.checkPickItem( item ) then
					if not result or MainRole.isGhostNearToMainRole(item,result) then
						result = item
					end
				end
			end
		end
	end
	return result
end

function MainRole.isGhostNearToMainRole(ghostA,ghostB)
	local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar and ghostA and ghostB then
    	local disA = math.floor(cc.pGetDistance(cc.p(ghostA:NetAttr(Const.net_x),ghostA:NetAttr(Const.net_y)),cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y))))
    	local disB = math.floor(cc.pGetDistance(cc.p(ghostB:NetAttr(Const.net_x),ghostB:NetAttr(Const.net_y)),cc.p(MainAvatar:NetAttr(Const.net_x),MainAvatar:NetAttr(Const.net_y))))
    	return disA < disB
    end
    return false
end

function MainRole.stopAutoMove()
	local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        MainAvatar:clearAutoMove()
        NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_move" , visible = false})
    end
end

function mainrole_action_end(PixesMainAvatar)
	if MainRole.mMoveAndFinding then
		local mItem = NetCC:getNearestItem(0)
		if mItem then
			local onwer = mItem:NetAttr(Const.net_item_onwer)
			local ittype = mItem:NetAttr(Const.net_itemtype)
			if onwer > 0 and onwer ~= PixesMainAvatar:NetAttr(Const.net_id) then
				mItem=nil
			end
		end
		local mMonster = NetCC:getNearestGhost(Const.GHOST_MONSTER)
		if (not mItem or (mItem and (not MainRole.checkPickItem(mItem))) or NetClient:isBagFull()) and not mMonster then
			MainRole.mFindingDir=MainRole.mDir
			MainRole.randMove()
		else
			MainRole.mMoveAndFinding=false
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAINROLE_ACTIONEND,"mainrole_action_end")

function status_change(status_str)
--    print("status_change:", status_str)
	local change=false
	local temp = string.split(status_str,",")
	local sta = {}
	local id = 0
	if temp[1] then id = tonumber(temp[1]) end
	if temp[2] then sta.id = tonumber(temp[2]) end
	if temp[3] then sta.dura = tonumber(temp[3]) end
	if temp[4] then sta.param = tonumber(temp[4]) end
	if not NetClient.mNetStatus[id] then
		NetClient.mNetStatus[id]={}
	end
	if not NetClient.mNetStatus[id][sta.id] then
		change=true
	else
		if sta.param ~= NetClient.mNetStatus[id][sta.id].param then
			change=true
		end
	end
	if sta.dura > 0 then
		NetClient.mNetStatus[id][sta.id] = sta

		--this is gm
		if id~=NetClient.mCharacter.mID and sta.id == Const.STATUS_TYPE_ALL_YINGSHEN then
			print("this is a gm")
--			CCGhostManager:remGhost(id)
			NetClient.mNetGhosts[id]=nil
			-- NetClient:dispatchEvent({name=Notify.EVENT_NEAR_LIST})
		end
	else
		NetClient.mNetStatus[id][sta.id] = nil
		change=true
	end
	local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        if id == MainAvatar:NetAttr(Const.net_id) and change then
            NetClient:dispatchEvent({name=Notify.EVENT_STATUS_CHANGE})
            if sta.id == Const.STATUS_TYPE_MOFADUN or sta.id == Const.STATUS_TYPE_MOFADUN_ADV then
                local pixesAvatar = CCGhostManager:getPixesAvatarByID(id)
                if pixesAvatar then
                    if sta.dura > 0 and sta.param > 0 then
                        MainRole.mHaveStatusMoFaDun = true
                    else
                        MainRole.mHaveStatusMoFaDun = false
                        MainRole.lastClearMFDTime = game.getTime()
                    end
                end
            elseif sta.id == Const.STATUS_TYPE_SHENSHENGZHANJIASHU then
            	local pixesAvatar = CCGhostManager:getPixesAvatarByID(id)
                if pixesAvatar and pixesAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
                    if sta.dura > 0 and sta.param > 0 then
                        MainRole.mHaveStatusZHANJIA = true
                    else
                        MainRole.mHaveStatusZHANJIA = false
                        MainRole.lastClearZJTime = game.getTime()
                    end
                end
            elseif sta.id == Const.STATUS_TYPE_YOULINGDUN then
            	local pixesAvatar = CCGhostManager:getPixesAvatarByID(id)
                if pixesAvatar and pixesAvatar:NetAttr(Const.net_job) == Const.JOB_DS then
                    if sta.dura > 0 and sta.param > 0 then
                        MainRole.mHaveStatusYOULINDUN = true
                    else
                        MainRole.mHaveStatusYOULINDUN = false
                        MainRole.lastClearYLDTime = game.getTime()
                    end
                end
            end
        end
    end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_STATUS_CHANGE,"status_change")

function MainRole.status_countdown()
    local mainrole = game.GetMainNetGhost()
    if not mainrole then return end
    local id = mainrole:NetAttr(Const.net_id)
    local statusMap = NetClient.mNetStatus[id]
    if not statusMap or table.nums(statusMap) == 0 then
        return
    end

    for _,v in pairs(statusMap) do
        local descinfo = game.getStatusDescDefByID(v.id, v.param)
        if descinfo then
            if v.dura > 0 then
                v.dura = v.dura - 1
            end
        end
    end
end


function MainRole.startSkillCD(skill_type)
    if skill_type == Const.SKILL_TYPE_YiBanGongJi then return end
    local cdtime = 0.6
    local myjob = game.getRoleJob()
    if myjob == Const.JOB_FS then
        cdtime = 0.78
    elseif myjob == Const.JOB_DS then
        cdtime = 0.98
    end
    if game.isZsChongZhuangSkill(skill_type) then
        cdtime = 5
    elseif game.isLiehuoSkill(skill_type) then
        cdtime = 10
        MainRole.mLiehuoCdTime = game.getTime()
    end
    local cdg = NetClient:getSkillCDGroup(skill_type)
    NetClient:dispatchEvent({name=Notify.EVENT_SKILL_COOLDOWN,type=skill_type,cd=cdtime,group=cdg})
end

return MainRole