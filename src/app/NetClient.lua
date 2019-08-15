local NetClient = class("NetClient")

local SocketManager=cc.SocketManager:getInstance()
local NetCC=cc.NetClient:getInstance()

NetCC:setNetMsgListen(NetProtocol.cNotifyMapEnter,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyMapMiniNpc,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyMapConn,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyHPMPChange,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyMapOption,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyInjury,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyMapSafeArea,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyAvatarChange, true)
NetCC:setNetMsgListen(NetProtocol.cNotifyGuildInfo, true)
NetCC:setNetMsgListen(NetProtocol.cNotifyCharacterLoad,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyRelive,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyDie,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyTurn,true)
NetCC:setNetMsgListen(NetProtocol.cNotifySkillDesp,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyGuildUnion,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyGuildUnionList,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyGuildWar,true)
NetCC:setNetMsgListen(NetProtocol.cNotifyGuildWarList,true)

function NetClient:ctor()

    -- cc.GameObject.extend(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    EventDispatcher:bind(self)

    self.mNetChar={}

    self:init()

    self._connected=false

    self.NetFunc={

        [NetProtocol.cResPing] = function(mMsg)
            local year_data = mMsg:readInt()
            local hour_data = mMsg:readInt()
        end,

        [NetProtocol.cResAuthenticate] = function(mMsg)
            local param=mMsg:readInt()
            self:onAuthenticate(param)
        end,

        [NetProtocol.cNotifyYouKeSessionID] = function(mMsg)
            local param = mMsg:readString()
            self:onAuthenticate(param)
        end,
        [NetProtocol.cResUpdateTicket] = function(mMsg)

        end,

        [NetProtocol.cResListCharacter] = function(mMsg)
            local netchar={}
            local mCharListChinaLimit = mMsg:readInt()
            local charlistnumber = mMsg:readInt()
            self.curSelect = mMsg:readInt()
            for i=1,charlistnumber do
                -- if charlistnumber >0 and charlistnumber >= i then
                    local char={}
                    char.mLevel = mMsg:readInt()
                    char.mJob = mMsg:readInt()
                    char.mGender = mMsg:readInt()
                    char.mOnline = mMsg:readInt()
                    char.mName = mMsg:readString()
                    char.mSeedName = mMsg:readString()
                    netchar[i]=char
                -- end
            end
            if self.isReqChar then
                self.mNetChar=netchar
                self:dispatchEvent({name=Notify.EVENT_LOADCHAR_LIST})
                self.isReqChar=false
            end

            if gameLogin._autoEnter then
                print("gameLogin._autoEnter =====", game.mChrName,game.mSeedName)
                NetClient:EnterGame(game.mChrName,game.mSeedName)
            end
        end,

        [NetProtocol.cResDeleteCharacter] = function(mMsg)
            local result = mMsg:readInt()
            if result == 100 then
                self:ListCharacter()
            end
        end,

        [NetProtocol.cResEnterGame] = function(mMsg)
            gameLogin.removeAllLoginPanel()
            gameLogin._autoEnter = false
            gameLogin.isReLogin = false
            local result=mMsg:readInt()

            print("res EnterGame ==>>",result)
            if result==100 then
                -- if self.enter_delay then
                -- 	ccq.scheduler:unscheduleScriptEntry(self.enter_delay)
                --     self.enter_delay = nil
                -- end
                -- PlatformTool.hideWaiting()

                -- game.cleanGame()
            elseif result==103 then
                -- NetClient:EnterGame(game.mChrName,game.mSeedName)
                if not self.enter_delay then
                -- PlatformTool.showWaiting({msg="您的账号已经在线,开始强行挤号"})
                    print("NetProtocol.cResEnterGame==>>您的账号已经在线,倒计时结束后强行挤号")
                    if MAIN_IS_IN_GAME then
                        gameLogin.showLoginEffect()
                    end

                    local function enter_end(dt)
                        if self.enter_delay then
                            Scheduler.unscheduleGlobal(self.enter_delay)
                            self.enter_delay = nil
                        end
                        print("开始强行挤号")
                        NetClient:EnterGame(game.mChrName,game.mSeedName)
                    end
                    self.enter_delay = Scheduler.scheduleGlobal(enter_end,6)
                else
                    print("不启动")
                end
            else
                -- game.ExitToRelogin()
                -- PlatformTool.hideWaiting()
                -- PlatformTool.showMsg("账号登录失败")
                -- device.showAlert("", "账号登录失败", "知道了")
                gameLogin.popErrorDialog({
                    errormsg="账号登录失败"..result,
                    alertTitle="重新登录",
                    onClickConfirm=function()
                        game.ExitToRelogin(true)
                    end
                })
            end
            self:dispatchEvent({name=Notify.EVENT_RES_ENTER_GAME,result=result})
        end,

        [NetProtocol.cNotifyCharacterLoad] = function(mMsg)
            if device.platform == "android" then buglySetUserId(game.mChrName) end
            UISceneGame.regetMainRole()
            UILeftCenter.onReload()
            self:dispatchEvent({name=Notify.EVENT_NOTIFY_CHARACTER_LOAD})
        end,

        [NetProtocol.cResCreateCharacter] = function(mMsg)
            local result=mMsg:readInt()
            local seedname=mMsg:readString()

            local error_msg="角色创建成功"
            if result ~= 100 then
                if result == 101 then
                    error_msg = "角色创建失败,系统错误"
                elseif result == 102 then
                    error_msg = "角色创建失败,不能创建更多的人物了"
                elseif result == 103 then
                    error_msg = "角色创建失败,名称重复"
                elseif result == 104 then
                    error_msg = "角色创建失败, 名称中包含非法字符"
                end
            end
            self:dispatchEvent({name=Notify.EVENT_CREATECHARACTOR,result=result,msg=error_msg,seedname=seedname,error_msg=error_msg})
        end,

        [NetProtocol.cNotifyAvatarChange] = function(mMsg)
            local srcid=mMsg:readUInt()
            local cloth=mMsg:readInt()
            local weapon=mMsg:readInt()
            local mount=mMsg:readInt()
            local wing = mMsg:readInt()
            local lovename=mMsg:readString()
            local shenqi=mMsg:readInt()
            local shenjia=mMsg:readInt()
            local weapon_buding=mMsg:readInt()
            local mount_buding=mMsg:readInt()
            local cloth_buding=mMsg:readInt()

            local netghost = game.GetMainNetGhost()
            if netghost and srcid == netghost:NetAttr(Const.net_id) then
                self:dispatchEvent({name=Notify.EVENT_AVATAR_CHANGE,srcid=srcid})
            end
        end,

        [NetProtocol.cNotifyItemChange] = function(mMsg)
            local newItem = {}
            newItem.position = mMsg:readInt()
            newItem.mTypeID = mMsg:readInt()
            newItem.mDuraMax = mMsg:readInt()
            newItem.mDuration = mMsg:readInt()
            newItem.mItemFlags = mMsg:readInt()

            newItem.mLevel = mMsg:readInt()
            newItem.mNumber = mMsg:readInt()

            newItem.mAddAC = mMsg:readShort()
            newItem.mAddMAC = mMsg:readShort()
            newItem.mAddDC = mMsg:readShort()
            newItem.mAddMC = mMsg:readShort()
            newItem.mAddSC = mMsg:readShort()

            newItem.mUpdAC = mMsg:readShort()
            newItem.mUpdMAC = mMsg:readShort()
            newItem.mUpdDC = mMsg:readShort()
            newItem.mUpdDCMAX = mMsg:readShort()
            newItem.mUpdMC = mMsg:readShort()
            newItem.mUpdMCMAX = mMsg:readShort()
            newItem.mUpdSC = mMsg:readShort()
            newItem.mSCMAX = mMsg:readShort()

            newItem.mLuck = mMsg:readShort()
            local show_flags = mMsg:readInt()
            newItem.mProtect = mMsg:readShort()

            newItem.mAddHp = mMsg:readShort()
            newItem.mAddMp = mMsg:readShort()
            newItem.mCreateTime = mMsg:readInt()
            local add_type = mMsg:readInt()
            local upd_fp = mMsg:readShort()

            local holeinfo = mMsg:readString()
            local stoneinf = mMsg:readString()
            local color_rate = mMsg:readInt()
            local updTimes = mMsg:readInt()
            local basefight = mMsg:readInt()
            local ext1 = mMsg:readInt()
            newItem.mShenzhu = mMsg:readInt()
            local notifyend = mMsg:readInt()

            --            newItem.mUpdMaxCount = tt[18]
            --            newItem.mUpdFailedCount = tt[19]
            --            newItem.mAccuracy = tt[20]
            --            newItem.mBaoji = tt[21]
            --            newItem.mBaoShang = tt[22]
            --            newItem.mBaoShangJM = tt[23]
            --
            --            newItem.mSellPriceType = tt[27]
            --            newItem.mSellPrice = tt[28]

            self:itemChange(newItem, show_flags)

        end,

        [NetProtocol.cNotifyItemDesp] = function(mMsg)
        end,

        [NetProtocol.cNotifyItemPlusDesp] = function(mMsg)
        end,
        ----------------------------------------------------------------------------人物状态相关
        [NetProtocol.cResUseSkill] = function(mMsg)
            local result=mMsg:readShort()
            local skill_type=mMsg:readShort()
            local tag = mMsg:readInt()
            local plugskilltype = mMsg:readShort()
            print("cResUseSkill ret="..result.." tag="..tag.." skillid="..skill_type)
            if MainRole then
                if result == 9 and game.isLiehuoSkill(skill_type) then
                    self:startLiehuoAction(skill_type)
                end
                if result == 0 then
                    -- if skill_type == Const.SKILL_TYPE_CiShaJianShu then
                    --     self.m_bCiShaOn = not self.m_bCiShaOn
                    -- elseif skill_type == Const.SKILL_TYPE_BanYueWanDao then
                    --     self.m_bBanYueOn = not self.m_bBanYueOn
                    -- end
                end
                -- if result == 1 then
                -- 	if self.mStartAutoFight and self.mCharacter.mJob == 100 then
                -- 		MainRole.mMoveToNearAttack = true
                -- 	end
                -- end
                if game.isFsDun(skill_type) then MainRole.mAutoCastSkill = false end
                MainRole.m_isReadyUseSkill = true
                if skill_type == Const.SKILL_TYPE_YinShenShu or skill_type == Const.SKILL_TYPE_JiTiYinShenShu then
                    MainRole.stopAttackOfSoldier()
                    return
                end
            end
        end,

        [NetProtocol.cNotifyInjury] = function(mMsg)
            local srcid = mMsg:readInt()
            local newhp = mMsg:readInt()
            local change = mMsg:readInt()
            local ttdelay = mMsg:readShort()
            local attacker = mMsg:readInt()
            local effect_flags = mMsg:readUByte()
            -- object.tttime = game.getTime() + object.ttdelay
            local skillid = mMsg:readUShort();
            local changeNg = mMsg:readInt();

            if srcid == self.lastSkillParamID then self.lastSkillParamID = -1 end
            if self.mNetGhosts[srcid]~=nil then
                self.mNetGhosts[srcid].mHp=newhp
                self.mNetGhosts[srcid].hp_pro = newhp/self.mNetGhosts[srcid].maxhp
            end

            if srcid==MainRole.mID then
                MainRole.handleAttacked(attacker)
                MainRole.autoGoHomeOrFly()
            else
--                self:dispatchEvent({name=Notify.EVENT_OTHER_HPMP_CHANGE,param={srcid=srcid}})
            end
        end,

        -- [NetProtocol.cNotifyAttackMiss] = function(mMsg)
        -- 	mMsg:readInt()
        -- end,

        [NetProtocol.cNotifyDie] = function(mMsg)
            local srcid = mMsg:readInt()
            local ttdelay = mMsg:readInt()
            local  diemsg = mMsg:readString();
            local  attacker = mMsg:readInt();
            local  flag = mMsg:readInt();-- 1可以原地复活 0不可以
            local  skillid = mMsg:readInt();
            local  relivecount = mMsg:readInt();
            local  effect_flag = mMsg:readUByte();
            local  damage = mMsg:readInt();

            local phost = NetCC:getGhostByID(srcid)
            if phost and phost:NetAttr(Const.net_type) == Const.GHOST_MONSTER then
                --            请求mininpc刷怪时间
                if self.mMapMonster[phost:NetAttr(Const.net_name)] then
                    NetClient:PushLuaTable("player.GetMiniNpcReliveTime",phost:NetAttr(Const.net_name))
                end
            end



        -- if self.mNetGhosts[srcid]~=nil then
        -- 	self.mNetGhosts[srcid].mNextHp=0
        -- 	self.mNetGhosts[srcid].mDead = true

        -- 	if self.mNetGhosts[srcid].mType==Const.GHOST_THIS and not game.UserConfig().Data["no_effect_flag"] then
        -- 		if self.mNetGhosts[srcid].mGender==200 then
        -- 			AudioEngine.playEffect(Const.SOUND.die_male)
        -- 		else
        -- 			AudioEngine.playEffect(Const.SOUND.die_female)
        -- 		end
        -- 	end
        -- end
            if srcid == self.lastSkillParamID then self.lastSkillParamID = -1 end
            self.mBossOwer[srcid] = nil
            if srcid == game.GetMainNetGhost():NetAttr(Const.net_id) then
                if self.mReliveInfo.left > 0 then
                    self:dispatchEvent({name=Notify.EVENT_PANEL_RELIVE, visible = true,
                        msg = diemsg,--"您已死亡，副本免费复活，"..self.mReliveInfo.max.."/"..self.mReliveInfo.left,
                        delay = self.mReliveInfo.time,
                        flag = 101,
                        attacker = attacker,
                        relivecount = self.mReliveInfo.left
                    })
                elseif self.mKingReliveTime > 0 then
                    self:dispatchEvent({name=Notify.EVENT_PANEL_RELIVE, visible = true,
                        msg = diemsg, flag = 100,
                        delay = self.mKingReliveTime,
                        relivecount = 0,
                        attacker = attacker,
                    })
                elseif self.mMapOptions[self.mNetMap.mMapID] and self.mMapOptions[self.mNetMap.mMapID].autoalive < 1 then
                    self:dispatchEvent({name=Notify.EVENT_PANEL_RELIVE, visible = true,
                        msg = diemsg, flag = flag,
                        delay = 15, attacker = attacker,
                        relivecount = relivecount
                    })
                end
            end
        end,

        [NetProtocol.cNotifyRelive] = function(mMsg)
            local srcid = mMsg:readUInt()
            local type = mMsg:readInt()
            if srcid == game.GetMainNetGhost():NetAttr(Const.net_id) then
                self:dispatchEvent({name=Notify.EVENT_PANEL_RELIVE, visible = false})
            end
        end,

        [NetProtocol.cNotifyFindRoadGotoNotify] = function(mMsg)
            local map_name = mMsg:readString()
            local mx = mMsg:readInt()
            local my = mMsg:readInt()
            local target = mMsg:readString()
            local flag = mMsg:readInt()
            if target ~= "" then
                MainRole.mTargetNPCName = target
                MainRole.mTargetX = mx
                MainRole.mTargetY = my
            end
            -- self:dispatchEvent({name=Notify.EVENT_FLYBOOT_SHOW})
            MainRole.startAutoMoveToMap(map_name,mx,my,flag)
        end,

        -- [NetProtocol.cNotifyTeamInfo] = function(mMsg)
        --     local id = mMsg:readInt()
        --     local team_id = mMsg:readInt()
        --     local team_name = mMsg:readString()
        --     local netghost = self.mNetGhosts[id]
        --     if netghost then
        --         netghost.mTeamID = team_id
        --         netghost.mTeamName = team_name
        --         -- netghost.cmdRefreshName = true
        --         -- game.GhostManager():updateSomeOneName(id)
        --     end
        -- end,

        [NetProtocol.cResFriendChange] = function(mMsg)

            local name = mMsg:readString()
            local title = mMsg:readInt()
            local online_state = mMsg:readInt()
            local txinfo = mMsg:readInt()
            local level = mMsg:readInt()
            local gender = mMsg:readInt()
            local job = mMsg:readInt()
			--local playerid = mMsg:readInt()
			--print("TZ:playerid:",playerid)
            -- local power = mMsg:readInt()

            local m_friend = {}
            if self.mFriends[name] then
                if  title < 0 then
                    m_friend=nil
                else
                    m_friend.name = name
                    m_friend.title = title
                    m_friend.online_state = online_state
                    m_friend.gender = gender
                    m_friend.job = job
                    m_friend.level = level
					--m_friend.pid = playerid
                    -- m_friend.power = power
                end
            else
                if title >= 0 then
                    m_friend.name = name
                    m_friend.title = title
                    m_friend.online_state = online_state
                    m_friend.gender = gender
                    m_friend.job = job
                    m_friend.level = level
					--m_friend.pid = playerid
                    -- m_friend.power = power
                end
            end
            self.mFriends[name] = m_friend
        end,

        [NetProtocol.cResFriendFresh] = function(mMsg)
            self:dispatchEvent({name=Notify.EVENT_FRIEND_FRESH, action="fresh"})
        end,

        [NetProtocol.cNotifyBlackBoard] = function(mMsg)
            self.mBlackBoardFlags = mMsg:readInt()
            self.mBlackBoardTitle = mMsg:readString()
            self.mBlackBoardMsg = mMsg:readString()
            self:dispatchEvent({name=Notify.EVENT_LABEL_ZC})
        end,

        [NetProtocol.cNotifyAlert] = function(mMsg)

            local param={}
            param.lv = mMsg:readInt()
            param.flags = mMsg:readInt()
            param.msg = mMsg:readString()

            --special handle
            if param.lv == 100 and param.flags == 0 then
                if param.msg == "获得:绑定金砖(小)*3" then
                    self:alertLocalMsg(param.msg,"post")
                    return
                end
            end

         
            if param.lv == 13 and param.flags == 3 then
                self:dispatchEvent({name = Notify.EVENT_XUNBAO_NOTICE,msg=param.msg})
                --self:alertLocalMsg(param.msg,"mid")
            end

            if param.flags == 2 then

                local ret = util.decode(param.msg)
                -- print("-------------",ret.notice)
                self:dispatchEvent({name = Notify.EVENT_ADD_NOTICE,notice=ret.notice,num=ret.num,boss_type=ret.boss_type})
                param.msg = ret.notice
            end

            if param.flags == 99 then
                ActivityData.parseMsg(param.lv, param.msg)
                return
            end

            local added = false
            if param.lv%10 == 1 then--在中间部位从下方移动到屏幕中间
                if not added then self:alertLocalMsg(param.msg,"alert") added = true end
            end

            if math.floor(param.lv%100 / 10) == 1 then--左下方的【系统】
                local netChat = {}
                netChat.m_channelid = Const.CHANNEL_TAG.SYSTEM
                netChat.m_strType = Const.chat_prefix_system
                netChat.m_uSrcId = 0
                netChat.m_strMsg = param.msg
                self:addToMsgHistory(netChat)
            end

            if math.floor(param.lv%1000 / 100) == 1 then--屏幕中上方
                if not added then self:alertLocalMsg(param.msg,"mid") added = true end
            end

            if math.floor(param.lv%10000 / 1000) == 1 then--banner
                self:alertLocalMsg(param.msg,"banner")
            end

            if math.floor(param.lv%100000 / 10000) == 1 then--屏幕中上的滚动字幕
                self:alertLocalMsg(param.msg,"post")
            end

            if math.floor(param.lv%1000000 / 100000) == 1 then
                self:alertLocalMsg(param.msg,"confirm")
            end
        end,

        [NetProtocol.cNotifyLableInfo] = function(mMsg)
            local param={}
            param.id = mMsg:readInt()
            param.info = mMsg:readString()
        end,

        [NetProtocol.cNotifyFreeDirectFly] = function(mMsg)
            local param = mMsg:readInt()
        end,

        [NetProtocol.cNotifySlaveState] = function(mMsg)
            self.mSlaveState = mMsg:readInt()
        end,

        [NetProtocol.cNotifyTaskChange] = function(mMsg)
            TaskData.taskChange(mMsg)
        end,

        [NetProtocol.cNotifySkillDesp] = function(mMsg)

            local nsd={}
            nsd.skill_id = mMsg:readInt()
            nsd.mName= mMsg:readString()
            nsd.mDesp= mMsg:readString()
            nsd.mIconID = mMsg:readInt()
            nsd.mLevelMax = mMsg:readInt()
            nsd.mShortcut = mMsg:readInt()
            nsd.mEffectType = mMsg:readInt()
            nsd.mEffectResID = mMsg:readInt()
            nsd.mBaseSpell = mMsg:readInt()
            nsd.mSpell = mMsg:readInt()
            nsd.mUseRange =mMsg:readInt()
            nsd.mSoundID = mMsg:readInt()
            nsd.mNeedL1= mMsg:readInt()
            nsd.mL1Train= mMsg:readInt()
            nsd.mNeedL2= mMsg:readInt()
            nsd.mL2Train= mMsg:readInt()
            nsd.mNeedL3= mMsg:readInt()
            nsd.mL3Train= mMsg:readInt()
            nsd.objid = mMsg:readInt()
            nsd.obj_name = mMsg:readString()
            nsd.active = mMsg:readInt()
            nsd.organize = mMsg:readInt()
            nsd.objid_pro = mMsg:readInt()
            nsd.obj_name_pro = mMsg:readString()
            nsd.needgold = mMsg:readInt()
            nsd.NeedL1ZS = mMsg:readInt()
            nsd.preskill = mMsg:readInt()
            nsd.mDesp1 = mMsg:readString()
            self.m_skillsDesp[nsd.skill_id] = nsd
        end,

        [NetProtocol.cNotifySkillChange] = function(mMsg)
        --var skill_type:int = -1
            local skill_temp = {}
            skill_temp.mTypeID = mMsg:readInt()
            skill_temp.mLevel = mMsg:readInt()
            skill_temp.mExp = mMsg:readInt()
            skill_temp.mParam1 = mMsg:readInt()
            local first = mMsg:readInt()
            if skill_temp.mTypeID == Const.SKILL_TYPE_Jump then
                return
            end

            -- if not self.m_netSkill[skill_temp.mTypeID] then
            -- 	if not game.IsPassiveSkill(skill_temp.mTypeID) then
            -- 		table.insert(self.m_skillAddList,skill_temp.mTypeID)
            -- 		-- self:dispatchEvent({name=Notify.EVENT_SKILL_CHANGE})
            -- 	end
            -- end
            if skill_temp.mLevel == 0 then
                if self.m_skillsDesp[skill_temp.mTypeID] then
                    self.m_skillsDesp[skill_temp.mTypeID] = nil
                    local keyindex = table.keyof(self.m_skillAddList,skill_temp.mTypeID)
                    if keyindex then
                        table.remove(self.m_skillAddList,keyindex)
                        self:dispatchEvent({name=Notify.EVENT_SKILL_CHANGE,remove_id = skill_temp.mTypeID})
                        return
                    end
                end
            end
            local learnnew,levelupdate
            if not self.m_netSkill[skill_temp.mTypeID] then
                learnnew = true
            else
                if self.m_netSkill[skill_temp.mTypeID].mLevel ~= skill_temp.mLevel then
                    levelupdate = true
                end
            end
            self.m_netSkill[skill_temp.mTypeID] = skill_temp
            local updateSkillState = false
            if game.isAllCishaSkill(skill_temp.mTypeID) then
                self.m_netSkillOpen[skill_temp.mTypeID] = (skill_temp.mParam1 > 0) and true or false
                updateSkillState = true
            end
            if learnnew then
                self:dispatchEvent({name=Notify.EVENT_SKILL_CHANGE,skill_type = skill_temp.mTypeID})
                if first then
                    local pos = self:updateSkillShortCut(skill_temp.mTypeID)
                    if pos then self:dispatchEvent({name=Notify.EVENT_LEARN_NEW_SKILL, skill_type = skill_temp.mTypeID, pos = pos}) end
                end
            else
                if updateSkillState then
                    self:dispatchEvent({name=Notify.EVENT_SKILL_STATE,id=skill_temp.mTypeID})
                end
            end
            if levelupdate then self:dispatchEvent({name=Notify.EVENT_SKILL_LEVEL_CHANGE,skill_type=skill_temp.mTypeID}) end
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.SKILL})
        end,

        [NetProtocol.cNotifyStatusDef] = function(mMsg)
            local status_id = mMsg:readInt()
            local num = mMsg:readInt()
            for i=1,num do
                local sd={}
                sd.mStatusID = status_id
                sd.mLv = mMsg:readInt()
                sd.mIcon = mMsg:readInt()
                sd.mAC = mMsg:readInt()
                sd.mACmax = mMsg:readInt()
                sd.mMAC = mMsg:readInt()
                sd.mMACmax = mMsg:readInt()
                sd.mDC = mMsg:readInt()
                sd.mDCmax = mMsg:readInt()
                sd.mMC = mMsg:readInt()
                sd.mMCmax = mMsg:readInt()
                sd.mSC = mMsg:readInt()
                sd.mSCmax = mMsg:readInt()
                sd.mHPmax = mMsg:readInt()
                sd.mMPmax = mMsg:readInt()
                sd.mNodef = mMsg:readInt()
                sd.mFightPoint = mMsg:readInt()
                sd.baoji = mMsg:readInt()
                sd.baoprob = mMsg:readInt()
                sd.mName = mMsg:readString()
                sd.damageignore = mMsg:readInt()
                sd.fantanprob = mMsg:readInt()
                sd.fantanpres = mMsg:readInt()
                sd.xiushoupres = mMsg:readInt()
                sd.xiushouprop = mMsg:readInt()
                sd.cloth = mMsg:readInt()
                sd.weapon = mMsg:readInt()
                sd.luck = mMsg:readInt()
                sd.accuracy = mMsg:readInt()
                sd.hpmaxadd = mMsg:readInt()
                sd.baojicounteractpre = mMsg:readInt()
                sd.toughness = mMsg:readInt()
                sd.godatk = mMsg:readInt()
                self.mStatusDesp[sd.mStatusID*100+sd.mLv] = sd
            end
            local endflag = mMsg:readUByte()
        end,

        [NetProtocol.cNotifyPushCocosGui] = function(mMsg)
            local gui_type = mMsg:readInt()
            local gui_name = mMsg:readString()
            local gui_state = mMsg:readInt()
        end,

        [NetProtocol.cNotifyProsperityChange] = function(mMsg)
            local mProsperity = mMsg:readInt()
            local mProsperityNext = mMsg:readInt()
        end,

        [NetProtocol.cNotifyWarInfo] = function(mMsg)
            self.mWarState = mMsg:readInt()
            self.mKingGuild = mMsg:readString()
            self.mKingOfKings = mMsg:readString()

        -- game.GhostManager():updateAllName()
            self:dispatchEvent({name=Notify.EVENT_KING_STATE})
        end,

        [NetProtocol.cNotifyKingdDomInfo] = function(mMsg)
            self.mHasKing = mMsg:readInt()
            if self.mHasKing == 1 then
                self.mKingGuildName = mMsg:readString()
                self.mKingMembers = {}
                local num = mMsg:readInt()
                for i = 1, num do
                    local memberinfo = {}
                    memberinfo.name = mMsg:readString()
                    memberinfo.rank = mMsg:readInt()
                    memberinfo.weapon = mMsg:readInt()
                    memberinfo.cloth = mMsg:readInt()
                    memberinfo.wing = mMsg:readInt()
                    memberinfo.pifeng = mMsg:readInt()
                    memberinfo.shenqi = mMsg:readInt()
                    memberinfo.shenjia = mMsg:readInt()
                    table.insert(self.mKingMembers, memberinfo)
                end
            else
                self.mKingGuildName = ""
                self.mKingMembers = {}
            end
            self:dispatchEvent({name=Notify.EVENT_KING_MEMBER_INFO})
        end,

        [NetProtocol.cNotifyGuildCondition] = function(mMsg)
            local mGuildCondition = mMsg:readString()
        end,

        [NetProtocol.cNotifySlotAdd] = function(mMsg)
            local lastBag = self.mBagSlotAdd
            local lastDepot = self.mDepotSlotAdd
            self.mDepotSlotAdd = mMsg:readInt()
            self.mBagSlotAdd = mMsg:readInt()
            self.mBagMaxSlot = mMsg:readInt()
            self.mDepotMaxSlot = mMsg:readInt()
--            if lastBag < self.mBagSlotAdd then
--                for i=(self.mBagSlotAdd-5),self.mBagSlotAdd-1 do
--                    self:dispatchEvent({name=Notify.EVENT_ITEM_CHANGE,pos=Const.ITEM_BAG_SIZE+i})
--                end
--            end
--            if lastDepot < self.mDepotSlotAdd then
--                for i=(self.mDepotSlotAdd-5),self.mDepotSlotAdd do
--                    self:dispatchEvent({name=Notify.EVENT_ITEM_CHANGE,pos=Const.ITEM_DEPOT_SIZE+1000+i})
--                end
--            end
            if lastBag ~= self.mBagSlotAdd then
                self:dispatchEvent({name=Notify.EVENT_UPDATE_BAG_SLOT,lastbag=lastBag})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.OPEN_BAG_SLOT})
            end
        end,

        [NetProtocol.cNotifyAttributeChange] = function(mMsg)
            local tt=mMsg:getValues("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
            if self.mCharacter.mMaxHp then
                local diff = {
                    [1] = {char = Const.str_mHp,	value = tt[1] - self.mCharacter.mMaxHp  },
                    [2] = {char = Const.str_mAC,	value = tt[10] - self.mCharacter.mAC },
                    [3] = {char = Const.str_mMAC,	value = tt[12] - self.mCharacter.mMAC},
                    [4] = {char = Const.str_mDC,	value = tt[14] - self.mCharacter.mDC},
                    [5] = {char = Const.str_mMC,	value = tt[16] - self.mCharacter.mMC},
                    [6] = {char = Const.str_mSC,	value = tt[18] - self.mCharacter.mSC},

                }
                if not self.msgMid then
                    self.msgMid = {}
                    -- self.msgMidRound = 0
                end

                local firstInQueue = true
                for i,v in ipairs(diff) do
                    if v.value > 0 then
                        table.insert(self.msgMid, "+"..v.char..tostring(v.value))
                        if firstInQueue then
                            firstInQueue = false
                            -- self:dispatchEvent({name = Notify.EVENT_SERVER_MSG, firstInQueue = true})
                        else
                            -- self:dispatchEvent({name = Notify.EVENT_SERVER_MSG, firstInQueue = false})
                        end
                        -- print(11111, firstInQueue)
                        -- self:dispatchEvent({name = Notify.EVENT_SERVER_MSG, firstInQueue = firstInQueue})
                    end
                end

                -- self.msgMidRound = self.msgMidRound + 1
                -- self:dispatchEvent({name=Notify.EVENT_SERVER_MSG})

            end
            self.mCharacter.mMaxHp 			= tt[1]
            self.mCharacter.mMaxMp 			= tt[2]
            self.mCharacter.mMaxBurden 		= tt[3]
            self.mCharacter.mBurden 		= tt[4]
            self.mCharacter.mMaxLoad 		= tt[5]

            self.mCharacter.mLoad 			= tt[6]
            self.mCharacter.mMaxBrawn 		= tt[7]
            self.mCharacter.mBrawn 			= tt[8]
            self.mCharacter.mMaxAC 			= tt[9]
            self.mCharacter.mAC 			= tt[10]

            self.mCharacter.mMaxMAC 		= tt[11]
            self.mCharacter.mMAC 			= tt[12]
            self.mCharacter.mMaxDC 			= tt[13]
            self.mCharacter.mDC 			= tt[14]
            self.mCharacter.mMaxMC 			= tt[15]

            self.mCharacter.mMC 			= tt[16]
            self.mCharacter.mMaxSC 			= tt[17]
            self.mCharacter.mSC 			= tt[18]
            self.mCharacter.mAccuracy 		= tt[19]
            self.mCharacter.mDodge 			= tt[20]
            self.mCharacter.mAntiMagic      = tt[21]
            self.mCharacter.mDropProb 		= tt[22]
            self.mCharacter.mDoubleAttProb 	= tt[23]
            self.mCharacter.mTotalUpdLevel  = tt[24]
            self.mCharacter.mFightPoint		= tt[25]
            self.mCharacter.mLuck			= tt[26] -- 幸运值
            self.mCharacter.mHonor			= tt[27]
            self.mCharacter.mXishou			= tt[28] -- 伤害减免
            self.mCharacter.mBaoji          = tt[29] -- 暴击几率
            self.mCharacter.mFantan_pres    = tt[30] -- 反弹伤害 万分比
            self.mCharacter.mBaojiPres      = tt[31] -- 暴击伤害值
            self.mCharacter.mBaojiCounteractPres    = tt[32] --爆伤抵消值
            self.mCharacter.mToughness              = tt[33] --韧性
            self.mCharacter.mBaojiCounteract        = tt[34] --爆伤减免 万分比
            self.mCharacter.mMaxNg                 = tt[35]
            self.mCharacter.mIgnoredef              = tt[36]
            self.mCharacter.mGodAtk                 = tt[37]
            self.mCharacter.mGodDef = 0
            self:dispatchEvent({name=Notify.EVENT_ATTRIBUTE_CHANGE})
        end,

        -- [NetProtocol.cNotifyNameAdd] = function(mMsg)
        -- 	local srcid = mMsg:readUInt()
        -- 	local namepre = mMsg:readString()
        -- 	local namepro = mMsg:readString()
        -- 	local netghost = self.mNetGhosts[srcid]
        -- 	if netghost then
        -- 		netghost.mNamePre = namepre
        -- 		netghost.mNamePro = namepro
        -- 		-- netghost.cmdRefreshName = true
        -- 		game.GhostManager():updateSomeOneName(srcid)
        -- 	end
        -- end,

        [NetProtocol.cNotifyExpChange] = function(mMsg)
            local curExp = mMsg:readDouble()
            local curMaxExp = mMsg:readDouble()
            local changeExp = mMsg:readInt()
            local src = mMsg:readInt()
            self.mCharacter.mCurExperience = curExp
            self.mCharacter.mCurrentLevelMaxExp = curMaxExp
            self.mCharacter.ExperienceChangeValue = changeExp
            self:dispatchChangeAlertMsg("获得经验","失去经验",changeExp,Const.ITEM_EXP_ID)
            self:dispatchEvent({name=Notify.EVENT_EXP_CHANGE})
        end,

        [NetProtocol.cNotifyNgExpChange] = function(mMsg)
            local curExp = mMsg:readDouble()
            local curMaxExp = mMsg:readDouble()
            local changeExp = mMsg:readInt()
            local src = mMsg:readInt()
            self.mCharacter.mCurNgExperience = curExp
            self.mCharacter.mCurrentNgLevelMaxExp = curMaxExp
            self.mCharacter.NgExperienceChangeValue = changeExp
            self:dispatchChangeAlertMsg("获得内功经验","失去内功经验",changeExp,Const.ITEM_NG_EXP_ID)
            self:dispatchEvent({name=Notify.EVENT_NG_EXP_CHANGE})
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.NEIGONG})
        end,

        [NetProtocol.cNotLoadShortcut] = function(mMsg)
            self.mShortCut = {}
            local num = mMsg:readInt()
            for i=1,num do
                local cutInfo = {}
                cutInfo.cut_id = mMsg:readInt()
                cutInfo.type = mMsg:readInt()
                cutInfo.param = mMsg:readInt()
                cutInfo.itemnum = 1
                self.mShortCut[cutInfo.cut_id] = cutInfo
            end
--            if not self.mInitShortCut then
--                local MainAvatar = CCGhostManager:getMainAvatar()
--                if not MainAvatar then return end
--                local job = MainAvatar:NetAttr(Const.net_job)
--                local save = false
--                for i,v in ipairs(SkillDef.skillPos[job]) do
--                    if self.m_netSkill[v] and not self.mShortCut[i] and not self:haveSetSkillShortCutPos(v) and not game.IsPassiveSkill( v ) then
--                        local cutinfo = {}
--                        cutinfo.cut_id = i
--                        cutinfo.type = 2
--                        cutinfo.param = v
--                        cutinfo.itemnum = 1
--                        self.mShortCut[i] = cutinfo
--                        save = true
--                    end
--                end
--                if save then
--                    self:SaveShortcut()
--                end
--            end
            self.mInitShortCut = true
            self:dispatchEvent({name=Notify.EVENT_SHORTCUT_CHANGE})
        end,

        [NetProtocol.cNotifyFreeReliveLevel] = function(mMsg)
            local mFreeReliveLevel = mMsg:readInt()
        end,

        [NetProtocol.cNotifyLevelChange] = function(mMsg)
            local level = mMsg:readInt()
            local netGhost = game.GetMainNetGhost()
            if netGhost then
                netGhost:setNetValue(Const.net_level, level)
                if self.mCharacter.mLevel~=nil and self.mCharacter.mLevel ~= level then
                    if level > self.mCharacter.mLevel then
                        self:dispatchEvent({name = Notify.EVENT_LEVEL_UP,})
                    end
                    self.m_bLevelChanged = true
                end
                self.mCharacter.mLevel = level
                self:dispatchEvent({name = Notify.EVENT_LEVEL_CHANGE, level = level})
                if self.isEnterGame then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.SKILL,UIRedPoint.REDTYPE.YUANSHEN,UIRedPoint.REDTYPE.WING,UIRedPoint.REDTYPE.RING,
                        UIRedPoint.REDTYPE.JIANJIA,UIRedPoint.REDTYPE.BAOSHI,UIRedPoint.REDTYPE.DUNPAI,UIRedPoint.REDTYPE.ANQI,UIRedPoint.REDTYPE.YUXI,UIRedPoint.REDTYPE.OPEN_BAG_SLOT,
                        UIRedPoint.REDTYPE.BOSS_PERSON,UIRedPoint.REDTYPE.LEVELINVEST})
                    UIButtonGuide.handleLevelChange(level)
                end
            end
        end,

        [NetProtocol.cNotifyNgLevelChange] = function(mMsg)
            local level = mMsg:readInt()
            local netGhost = game.GetMainNetGhost()
            if netGhost then
                netGhost:setNetValue(Const.net_nglevel, level)
                self.mCharacter.mNgLevel = level
                if self.mCharacter.mNgLevel~=nil and self.mCharacter.mNgLevel ~= level then
                    self.m_bNgLevelChanged = true
                end
                self:dispatchEvent({name = Notify.EVENT_NG_LEVEL_CHANGE, level = level})
            end
        end,

        [NetProtocol.cNotifyMapMiniNpc] = function(mMsg)
            local nmmn={}
            nmmn.mMapID = mMsg:readString()
            nmmn.mNpcName = mMsg:readString()
            nmmn.mNpcShortName = mMsg:readString()
            nmmn.mX = mMsg:readInt()
            nmmn.mY = mMsg:readInt()
            nmmn.mDirectFlyID = mMsg:readInt()
            nmmn.mShowNpcFlag = mMsg:readInt()
            nmmn.mReliveTime = mMsg:readInt()
            nmmn.mReliveGap = mMsg:readInt()
            nmmn.mShowNameFlag = mMsg:readInt()

--            dump(nmmn)

            if self.mNetMap.mMapID==nmmn.mMapID then
                if nmmn.mReliveTime == -1 then
                    table.insert(self.mMiniNpc,nmmn)
                else
                    self.mMapMonster[nmmn.mNpcName] = nmmn
                end
            end
        end,

        [NetProtocol.cNotifyURL] = function(mMsg)
            local mRegURL = mMsg:readString()
            local mLoginURL = mMsg:readString()
            local mPayURL = mMsg:readString()
            local mWebhomeURL = mMsg:readString()
            local mBBSURL = mMsg:readString()
            local mDownloadURL = mMsg:readString()
            local mKefuURL = mMsg:readString()
            local mParamURL1 = mMsg:readString()
            local mParamURL2 = mMsg:readString()
            local mParamURL3 = mMsg:readString()
            local mParamURL4 = mMsg:readString()
            local mParamURL5 = mMsg:readString()
        end,

        [NetProtocol.cNotifyCapacityChange] = function(mMsg)
            local mCapacity = mMsg:readInt()
            local capacity = mMsg:readInt()
        end,

        [NetProtocol.cNotifyHPMPChange] = function(mMsg)

            local srcid = mMsg:readUInt()
            local hp = mMsg:readInt()
            local mp = mMsg:readInt()
            local maxhp = mMsg:readInt()
            local maxmp = mMsg:readInt()
            local ng = mMsg:readInt()
            local maxng = mMsg:readInt()
            if hp<=0 then hp=0 end
            if mp<=0 then mp=0 end
            if ng<=0 then ng=0 end

            local param = {}
            param.srcid = srcid
            param.hp = hp
            param.mp = mp
            param.maxhp = maxhp
            param.maxmp = maxmp
            param.ng = ng
            param.maxng= maxng
            param.hp_pro = hp/maxhp
            param.mp_pro = mp/maxmp

            if self.mNetGhosts[srcid]~=nil then
                self.mNetGhosts[srcid].mHp=hp
                self.mNetGhosts[srcid].mMp=mp
                self.mNetGhosts[srcid].mNg=ng
                self.mNetGhosts[srcid].mMaxHp=maxhp
                self.mNetGhosts[srcid].mMaxmp=maxmp
                self.mNetGhosts[srcid].mMaxNg=maxng
            end

            if srcid==MainRole.mID then
                self:dispatchEvent({name=Notify.EVENT_SELF_HPMP_CHANGE,param=param})
            else
--               print("cNotifyHPMPChange===", src, param.hp)
--                self:dispatchEvent({name=Notify.EVENT_OTHER_HPMP_CHANGE,param={srcid=srcid}})
            end
        end,

        [NetProtocol.cNotifyParamData] = function(mMsg)
            local srcid = mMsg:readInt()
            local id = mMsg:readInt()
            local desp = mMsg:readString()

            if not self.mParam[srcid] then
                self.mParam[srcid]={}
            end

            self.mParam[srcid][id]=desp
            self:dispatchEvent({name=Notify.EVENT_PLAYER_PARAM_CHANGE})
        end,

        [NetProtocol.cNotifyOfflineExpInfo] = function(mMsg)
            local mOfflineTime = mMsg:readInt()
            local mOfflineTimeValide = mMsg:readInt()
            local mOfflineTimeValideMax = mMsg:readInt()
            local mOfflineExp = mMsg:readInt()
            local mOfflinePrice1 = mMsg:readInt()
            local mOfflinePrice2 = mMsg:readInt()
            local mOfflinePrice4 = mMsg:readInt()

        end,

        [NetProtocol.cNotifySetModel] = function(mMsg)
            local src_id = mMsg:readUInt()
            local id = mMsg:readInt()
            local vl = mMsg:readInt()
            if src_id == MainRole.mID then
                self.mSelfModel[id] = vl
            else
                self.mOtherModel[id] = vl
            end
            self:dispatchEvent({name=Notify.EVENT_MODEL_SET})
            self.other_panel_save="saved"
        end,


        [NetProtocol.cNotifyVipChange] = function(mMsg)
            local mVcoinAccu = mMsg:readInt()
            local mVipLevel = mMsg:readInt()
            local m_uSrcId = mMsg:readInt()
            local netGhost = game.GetMainNetGhost()
            if netGhost and netGhost:NetAttr(Const.net_id) == m_uSrcId then
                self.mVIPLevel = mVipLevel
                self.mLeijiChongzhiYb = mVcoinAccu --累计充值元宝数
                self:dispatchEvent({name=Notify.EVENT_VIP_LEVEL_CHANGE})
            end
        end,

        [NetProtocol.cNotifyGameMoneyChange] = function(mMsg)
            self.mCharacter.mGameMoney = mMsg:readInt()
            self.mCharacter.mGameMoneyBind = mMsg:readInt()
            self.mCharacter.mVCoin = mMsg:readInt()
            self.mCharacter.mVCoinBind = mMsg:readInt()
            local param = {}
            param.gm_change = mMsg:readInt()
            param.vc_change = mMsg:readInt()
            param.gmb_change = mMsg:readInt()
            param.vcb_change = mMsg:readInt()

            -- if not game.UserConfig().Data["no_effect_flag"] then
            -- 	AudioEngine.playEffect(Const.SOUND.give_gole_coin)
            -- end

            if param.gm_change ~= 0 then
                self:dispatchChangeAlertMsg("获得金币","失去金币",param.gm_change, Const.ITEM_GOLD_ID)
                game.playSoundByID("sound/1113.mp3")
            end
            if param.gmb_change ~= 0 then
                self:dispatchChangeAlertMsg("获得绑定金币","失去绑定金币",param.gmb_change, Const.ITEM_GOLD_BIND_ID)
                game.playSoundByID("sound/1113.mp3")
            end
            if param.vc_change ~= 0 then
                self:dispatchChangeAlertMsg("获得元宝","失去元宝",param.vc_change,Const.ITEM_VCOIN_ID)
            end
            if param.vcb_change ~= 0 then
                self:dispatchChangeAlertMsg("获得绑定元宝","失去绑定元宝",param.vcb_change,Const.ITEM_VCOIN_BIND_ID)
            end
            self:dispatchEvent({name=Notify.EVENT_GAME_MONEY_CHANGE})
            if self.isEnterGame then
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.SKILL, UIRedPoint.REDTYPE_RING})
            end
            if self.mFightState then
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE4})
            end
            if self.mRingInfo.levelinfo then
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.RING})
            end
            if self:getTopBtnFlag(Const.TOPBTN.btnRefineExp)==2 then
                if self.Refineparam then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.REFINE_EXP})
                end
            end
        end,

        [NetProtocol.cNotifyMapEnter] = function(mMsg)
            self.mNetMap={}
            self.mMiniNpc = {}
            self.mMapMonster = {}
            self.mMapConn = {}

            self.mSafeArea = nil
            
            local map_id=mMsg:readString();
            local x=mMsg:readInt();
            local  y=mMsg:readInt();
            local  dir=mMsg:readInt();
            local  minimap=mMsg:readInt();
            local  map_file=mMsg:readString();
            local  map_name=mMsg:readString();
            local  flags=mMsg:readInt();
            local  noInteract=mMsg:readInt();
            local  weather=mMsg:readInt();
            local  maptype=mMsg:readInt();

            self.mNetMap.mMapID=map_id
            self.mNetMap.mMiniMapID=minimap
            self.mNetMap.mMapFile=map_file
            self.mNetMap.mName=map_name
            
            MainRole.updateAttr()

            self:dispatchEvent({name=Notify.EVENT_MAP_ENTER})

            -- local mid=self.mNetMap.mMapID

            -- AudioEngine.stopMusic()

            -- if game.UserConfig().Data["no_music_flag"]==false then
            -- 	if mid=="v001" or mid=="v003" or mid=="v005" then
            -- 		local music=6000+math.random(0,2)
            -- 		AudioEngine.playMusic("sound/"..music..".mp3",true)
            -- 	else
            -- 		local music=7000+math.random(0,1)
            -- 		AudioEngine.playMusic("sound/"..music..".mp3",true)
            -- 	end
            -- end
            -- if mid=="v005" or mid=="kinghome" then
            -- 	game.GameData().mWarHideWing=true
            -- else
            -- 	game.GameData().mWarHideWing=false
            -- end
            -- game.UserConfig():setSystemConfig()
            local mapSound = game.getMapSound(map_file)
            if mapSound then
                game.playSoundByID("sound/"..mapSound..".mp3",true,true)
            end

            if MainRole.m_isAutoKillMonster then MainRole.m_isAutoKillMonster = false end

            -- game.GameData().mRockerRun=false

            if not MAIN_IS_IN_GAME then

                -- 	if PLATFORM_APP then
                -- 		PlatformTool.callPlatformFunc({func="logEvent",event="entergame",userid=game.GameData().mGameUserid,zonename=game.GameData().mCurrentSvr.name,rolename=self.mCharacter.mName,rolelevel=self.mCharacter.mLevel})
                -- 	elseif PLATFORM_UC or PLATFORM_789APP then
                -- 		PlatformTool.callPlatformFunc({func="submitExtendData",roleId=game.GameData().mGameUserid,roleName=self.mCharacter.mName,roleLevel=self.mCharacter.mLevel,zoneId=game.GameData().mCurrentSvr.id,zoneName=game.GameData().mCurrentSvr.name})
                -- 	end

                -- 	print(PlatformCenter.PID,PlatformCenter.VIP)

                -- 	self:PushLuaTable("gui.PlatformCenter.setPlatform",util.encode({pid=PlatformCenter.PID,vip=PlatformCenter.VIP}))

                -- 	if CONFIG_IS_DEBUG == 1 then
                -- 		cc.Director:getInstance():runWithScene(GameScene.new())
                -- 	else
                -- cc.Director:getInstance():replaceScene(cc.SceneGame:create())
                -- 	end
            else
                cc.GhostManager:getInstance():remAllEffect()
                cc.GhostManager:getInstance():remAllSkill()
                cc.CacheManager:getInstance():releaseUnused(true)
            end
        end,

        [NetProtocol.cNotifyMapLeave] = function(mMsg)

            self.mNetMap.mLastMapID = self.mNetMap.mMapID
            self.mNetMap.mMapID = nil
            self.mCharacter.mX = 0
            self.mCharacter.mY = 0
            MainRole.stopAttackOfSoldier()
            self:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = false})
            self:dispatchEvent({name=Notify.EVENT_MAP_LEAVE})
            SimpleAudioEngine:stopAllEffects()
            self:initReliveInfo()
        end,

        [NetProtocol.cNotifyMapOption] = function(mMsg)
            local map_id = mMsg:readString()
            local pkprohibit = mMsg:readByte()
            local pkallow = mMsg:readByte()
            local autoalive = mMsg:readByte()
            local nointeract = mMsg:readByte()
            local lockaction = mMsg:readByte()
            local nozhaohuan = mMsg:readByte()
            local mapflag = mMsg:readInt()
            local nomount = mMsg:readByte()
            -- local wanderdight = mMsg:readByte()

            -- game.mWanderFight=(wanderdight==1) and true or false
            self.mMapOptions[map_id] = {pkprohibit=pkprohibit,pkallow=pkallow,autoalive=autoalive,nointeract=nointeract,lockaction=lockaction,nozhaohuan=nozhaohuan,mapflag=mapflag,nomount=nomount}
            if MainRole then
                MainRole.checkAutoMove()
            end
        end,

        [NetProtocol.cNotifyTotalAttrParam] = function(mMsg)
            local num = mMsg:readInt()

            for i=1,num do
                local id = mMsg:readInt()
                self.mCharacter.mTotalAttrs[id] = {}
                self.mCharacter.mTotalAttrs[id].mJob 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mLevel 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mDC   			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mDCmax 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mMC   			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mMCmax 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mSC   			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mSCmax 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mAC   			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mACmax 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mMAC   			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mMACmax 		= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mHPmax 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mMPmax 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mAccuary 		= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mDodge 			= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mLuck	 		= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mDropProb 		= mMsg:readInt()
                self.mCharacter.mTotalAttrs[id].mDoubleAttProb 	= mMsg:readInt()
            end
        end,

        [NetProtocol.cNotifyMapConn] = function(mMsg)

            local nmc={}
            nmc.mMapID = mMsg:readString()
            nmc.mDesMapID = mMsg:readString()
            nmc.mDesMapName = mMsg:readString()
            nmc.mFromX = mMsg:readInt()
            nmc.mFromY = mMsg:readInt()
            nmc.mDesX = mMsg:readInt()
            nmc.mDesY = mMsg:readInt()
            nmc.mSize = mMsg:readInt()
            nmc.mNameDir = mMsg:readInt()
            nmc.mEffectID = mMsg:readInt()

            if self.mNetMap.mMapID==nmc.mMapID then
                self.mMapConn[nmc.mDesMapID] = nmc
            end
        end,
        [NetProtocol.cNotifyMapSafeArea] = function(mMsg)
            local safeArea = {}
            safeArea.mMapID = mMsg:readString()
            safeArea.mX = mMsg:readInt()
            safeArea.mY = mMsg:readInt()
            safeArea.mSize = mMsg:readInt()

            if self.mNetMap.mMapID ~= safeArea.mMapID then
                return
            end

            self.mSafeArea = safeArea
        end,

        [NetProtocol.cNotifyNpcShowFlags] = function(mMsg)
            local npc_id = mMsg:readUInt()
            local show_flag = mMsg:readInt()
        end,

        [NetProtocol.cResChangeAttackMode] = function(mMsg)
            self.mAttackMode = mMsg:readInt()
            self:dispatchEvent({name=Notify.EVENT_ATTACKMODE_CHANGE})
        -- game.StatusManager().mAllReFreshName = true
        -- game.GhostManager():updateAllName()
        end,

        [NetProtocol.cNotifyTiliChange] = function(mMsg)
            local mTili = mMsg:readInt()
        end,

        [NetProtocol.cNotifyCountDown] = function(mMsg)
            self.m_nCountDownDelay = mMsg:readInt()
            self.m_strCountDownMsg = mMsg:readString()
            self:dispatchEvent({name=Notify.EVENT_COUNT_DOWN})
        end,

        [NetProtocol.cNotifyGroupInfoChange] = function(mMsg)
            self.mCharacter.mGroupID = mMsg:readInt()
            self.mCharacter.mGroupPickMode = mMsg:readInt()
            self.mCharacter.mGroupName = mMsg:readString()
            self.mCharacter.mGroupLeader = mMsg:readString()
            local grouptype = mMsg:readInt()
            local copyid = mMsg:readInt()

            self:resetGroupApplyAndInVite()


            local result = mMsg:readInt()
            local old = clone(self.mGroupMembers)
            self.mGroupMembers = {}
            for i=1,result do
                local gm={}
                local playerid = mMsg:readInt()
                gm.name = mMsg:readString()
                for j=1,#old do
                    if gm.name == old[j].name then
                        gm.name = old[j].name
                        gm.hp = old[j].hp
                        gm.mp = old[j].mp
                        gm.state = old[j].state

                        gm.job = old[j].job
                        gm.level = old[j].level
                        gm.power = old[j].power
                        gm.locateMap = old[j].locateMap
                    end
                end
                self.mGroupMembers[i]=gm
            end

            --print("TZ::cNotifyGroupInfoChange:::::??????????????????????????????123456789")

            self:dispatchEvent({name=Notify.EVENT_GROUP_LIST_CHANGED, type=NetProtocol.cNotifyGroupInfoChange})
        end,

        [NetProtocol.cNotifyGroupState] = function(mMsg)
            self.mCharacter.mGroupID = mMsg:readInt()
            self:resetGroupApplyAndInVite()


            local result = mMsg:readInt()
            for i=1,result do
                if (i-1) < #self.mGroupMembers then
                    self.mGroupMembers[i].state = mMsg:readInt()
                    self.mGroupMembers[i].hp = mMsg:readInt()
                    self.mGroupMembers[i].mp = mMsg:readInt()
                    self.mGroupMembers[i].level = mMsg:readInt()
                    self.mGroupMembers[i].job = mMsg:readInt()
                    local texinfo = mMsg:readInt()
                    local maxhp = mMsg:readInt()
                    local maxmp = mMsg:readInt()
                    local gender = mMsg:readInt()
                    local fight = mMsg:readInt()
                    local status = mMsg:readByte()


                    self.mGroupMembers[i].power = 0 --mMsg:readInt()
                    self.mGroupMembers[i].locateMap = "" --mMsg:readString()
                end
            end
            self:dispatchEvent({name=Notify.EVENT_GROUP_LIST_CHANGED, type=NetProtocol.cNotifyGroupState})
        end,

        [NetProtocol.cNotifyTeamPlayerMiniMapPos] = function(mMsg)
            local TplayerName  = mMsg:readString()
            local TpPosX = mMsg:readInt()
            local TpPosY = mMsg:readInt()
            local TpshowFlag = mMsg:readInt()

            if not TplayerName then return end
            if #self.mGroupMembers > 0 then
                for i= 1,#self.mGroupMembers do
                    if self.mGroupMembers[i].name == TplayerName then
                        self.mGroupMembers[i].PosX = TpPosX
                        self.mGroupMembers[i].PosY = TpPosY
                        self.mGroupMembers[i].showFlag = TpshowFlag
                    end
                end
            end

            self:dispatchEvent({name=Notify.EVENT_NOTIFY_TEAMPLAYERPOS, type=NetProtocol.cNotifyTeamPlayerMiniMapPos})
        end,

        [NetProtocol.cNotifyGroupInfo] = function(mMsg)
            local id =  mMsg:readInt() -- 玩家id
            local group_id =  mMsg:readInt()
            local group_name =  mMsg:readString()
            local group_leader =  mMsg:readString()
            local group_members = mMsg:readInt() -- 成员个数

            if group_id == 0 then
                self.nearByGroupInfo[id] = nil
            else
                self.nearByGroupInfo[id] = {
                    group_id = group_id,
                    group_leader = group_leader,
                    group_name = group_name,
                    group_members = group_members,
                }
            end
            self:dispatchEvent({name=Notify.EVENT_GROUP_LIST_CHANGED, type=NetProtocol.cNotifyGroupInfo})
        end,

        [NetProtocol.cNotifyInviteGroupToMember] = function(mMsg)
            -- 邀请加入组队
            if NativeData.REFUSE_GROUP then
                self:alertLocalMsg("组队被自动拒绝，可在组队面板设置！","alert")
                return
            end

            local teamInvite = {}
            teamInvite.name = mMsg:readString()
            teamInvite.group_id = mMsg:readInt()
            teamInvite.level = mMsg:readInt()
            teamInvite.job = mMsg:readInt()

            if NativeData.AUTO_GROUP then
                NetClient:AgreeInviteGroup(teamInvite.name, teamInvite.group_id)
                return
            end
               
            if(#self.mGroupInvite or 0)> 0 then
                local mInviteType = true
                for i=1,#self.mGroupInvite do
                    if self.mGroupInvite[i].name == teamInvite.name then
                        mInviteType = false  
                    end
                end
                if mInviteType then
                    table.insert(self.mGroupInvite,teamInvite)
                end
            else
                table.insert(self.mGroupInvite,teamInvite)
            end
            --if not self.mGroupInvite[groupID] then
            --    self.mGroupInvite[groupID] = groupLeader
            --end

            self:alertLocalMsg(teamInvite.name..Const.str_group_inviteGroupToMember,"alert")
            self:dispatchEvent({name = Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE,})
        end,
        [NetProtocol.cNotifyJoinGroupToLeader] = function(mMsg)
            -- 加入组队申请
            if NativeData.REFUSE_GROUP then
                self:alertLocalMsg("组队被自动拒绝，可在组队面板设置！","alert")
                return
            end
            local teamApply = {}
            teamApply.name = mMsg:readString()
            teamApply.level = mMsg:readInt()
            teamApply.job = mMsg:readInt()
            if NativeData.AUTO_GROUP then
                self:AgreeJoinGroup(teamApply.name)
                return
            end
            if(#self.mGroupApplyers or 0)> 0 then
                local mApplyType = true
                for i=1,#self.mGroupApplyers do
                    if self.mGroupApplyers[i].name == teamApply.name then
                        mApplyType = false
                    end
                end
                if mApplyType then
                    table.insert(self.mGroupApplyers,teamApply)
                end
            else
                table.insert(self.mGroupApplyers,teamApply)
            end

            --if not self.mGroupApplyers[applyerName] then
              --  self.mGroupApplyers[applyerName] = applyerName
            --end

            self:alertLocalMsg(teamApply.name..Const.str_group_joinToLeader,"alert")
            self:dispatchEvent({name = Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE,})
        end,

        [NetProtocol.cNotifyListGuildBegin] = function(mMsg)
            local kingguild = mMsg:readString()
            local kingname = mMsg:readString()
            local diskingmodel = mMsg:readInt()
            local weapon = mMsg:readInt()
            local cloth = mMsg:readInt()
            local wing = mMsg:readInt()
            local pifeng = mMsg:readInt()
            self.mGuildList = {}
            self.mCharacter.num_enter = 0
        end,

        [NetProtocol.cNotifyListGuildEnd] = function(mMsg)
            self:dispatchEvent({name=Notify.EVENT_GUILD_LIST})
        end,

        [NetProtocol.cNotifyListGuildItem] = function(mMsg)
            local pName = mMsg:readString()
            local pGuild=self:getGuildByName(pName)
            if not pGuild then
                pGuild={}
                pGuild.mName=pName
                table.insert(self.mGuildList,pGuild)
            end
            pGuild.mMemberNumber = mMsg:readInt()
            pGuild.mDesp = mMsg:readString()
            pGuild.mLevelGuild = mMsg:readInt()
            pGuild.entering = mMsg:readInt()
            pGuild.maxnum = mMsg:readInt()
            pGuild.fight = mMsg:readInt()
            pGuild.online_state = mMsg:readInt() -- 会长是否在线
            pGuild.mLeader = mMsg:readString()
        end,

        [NetProtocol.cNotifyInfoItemChange] = function(mMsg)
            local src_id = mMsg:readUInt()
            local newItem = {}
            newItem.position	= mMsg:readInt()
            newItem.mTypeID 	= mMsg:readInt()
            newItem.mDuraMax 	= mMsg:readInt()
            newItem.mDuration  	= mMsg:readInt()
            newItem.mItemFlags  = mMsg:readInt()
            newItem.mLevel  	= mMsg:readInt()
            newItem.mNumber 	= mMsg:readInt()

            newItem.mUpdCount = mMsg:readInt()
            newItem.mAddAC = mMsg:readShort()
            newItem.mAddMAC = mMsg:readShort()
            newItem.mAddDC = mMsg:readShort()
            newItem.mAddMC = mMsg:readShort()
            newItem.mAddSC = mMsg:readShort()

            newItem.mUpdAC = mMsg:readShort()
            newItem.mUpdMAC = mMsg:readShort()
            newItem.mUpdDC = mMsg:readShort()
            newItem.mUpdDCMAX = mMsg:readShort()
            newItem.mUpdMC = mMsg:readShort()
            newItem.mUpdMCMAX = mMsg:readShort()
            newItem.mUpdSC = mMsg:readShort()
            newItem.mUpdSCMAX = mMsg:readShort()
            newItem.mUpdFp = mMsg:readShort()

            newItem.mLuck = mMsg:readShort()
            newItem.mProtect = mMsg:readShort()
            newItem.mAddHp = mMsg:readShort()
            newItem.mAddMp = mMsg:readShort()
            newItem.mCreateTime = mMsg:readInt()

            local holeinfo = mMsg:readString()
            local stoneinf = mMsg:readString()
            local color_rate = mMsg:readInt()
            local ext1 = mMsg:readInt()
            newItem.mShenzhu = mMsg:readInt()

            if self.mOthersItems[newItem.position] then
                self.mOthersItems[newItem.position] =nil
            end
            if newItem.mTypeID > 0 then
                self.mOthersItems[newItem.position] = newItem
                self.other_equip_save = "saved"
            end
            self:dispatchEvent({name=Notify.EVENT_PLAYEREQUIP_INFO})
        end,

        [NetProtocol.cResListGuild] = function(mMsg)
            local guild_num = mMsg:readInt()
            self.mGuildList = {}
            for i=1,guild_num do
                local pGuild = {}
                pGuild.mName = mMsg:readString()
                pGuild.mMemberNumber = mMsg:readInt()
                pGuild.mDesp = mMsg:readString()
                pGuild.mMasterLevel = mMsg:readInt()
                pGuild.mLeader = ""
                table.insert(self.mGuildList,pGuild)
            end
        end,

        [NetProtocol.cNotifySessionClosed] = function(mMsg)
            local s=mMsg:readString()
            self.m_bIsDisConnect = true
            if not gameLogin.isReLogin then
                gameLogin.showDisConnectUI(s)
            end
        end,

        [NetProtocol.cNotifyShowProgressBar] = function(mMsg)
            local time = mMsg:readInt()
            local info = mMsg:readString()
            self:dispatchEvent({name=Notify.EVENT_START_PROGRESS,time = time,info=info})
            local MainAvatar = CCGhostManager:getMainAvatar()
            if MainAvatar then
                MainAvatar:clearAutoMove()
            end
            self.m_bCollecting = true
            self.m_bReqCollect = false
        end,

        [NetProtocol.cNotifyCollectBreak] = function(mMsg)
            self:dispatchEvent({name=Notify.EVENT_STOP_PROGRESS})
            self:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_caiji" , visible = false})
            self.mCollectKuang = false
            self.m_bReqCollect = false
            self.m_bCollecting = false
        end,

        [NetProtocol.cNotifyCollectChange] = function(mMsg)
            local srcid = mMsg:readInt()
            local status = mMsg:readInt()
            if status == game.GetMainRole():NetAttr(Const.net_id) then
                self.m_bCollecting = true
                self.m_bReqCollect = false
            elseif status == 0 then
                self.m_bCollecting = false
                self.m_bReqCollect = false
            end
            -- if self.m_bCollecting then
            --     self.m_bCollecting = false
            --     self.m_bReqCollect = false
            -- end
        end,

        [NetProtocol.cResListGuildMember] = function(mMsg)
            local guild_name = mMsg:readString()
            local list_type = mMsg:readInt()
            local result = mMsg:readInt()
            local member = {}
            for i=1,result do
                local guild_member = {}
                guild_member.nick_name = mMsg:readString()
                guild_member.title = mMsg:readShort()
                guild_member.online = mMsg:readShort()
                guild_member.gender = mMsg:readShort()
                guild_member.job = mMsg:readShort()
                guild_member.level = mMsg:readShort()
                guild_member.fight = mMsg:readInt()
                guild_member.last_out = mMsg:readInt()
                guild_member.guildpt = mMsg:readInt()
                guild_member.reinlv = mMsg:readInt()
                -- guild_member.entertime = mMsg:readInt()
                member[guild_member.nick_name] = guild_member
            end
            local pGuild=self:getGuildByName(guild_name)
            -- for i=1,#self.mGuildList do
            -- if self.mGuildList[i].mName == guild_name then
            if pGuild then
                if list_type == 101 then
                    pGuild.mRealMembers = member
                elseif list_type == 100 then
                    pGuild.mEnteringMembers = member
                    --申请小红点
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_APPLY})
                end
            end
            -- end
            self:dispatchEvent({name = Notify.EVENT_GUILD_MEMBER,data = pGuild })
        end,

        [NetProtocol.cResGetGuildInfo] = function(mMsg)
            local pName = mMsg:readString()
            local pGuild=self:getGuildByName(pName)
            if not pGuild then
                pGuild={}
                pGuild.mName=pName
                table.insert(self.mGuildList,pGuild)
            end
            pGuild.mMemberNumber = mMsg:readInt()
            pGuild.mDesp = mMsg:readString()
            pGuild.mNotice = mMsg:readString()
            -- pGuild.mLeader = mMsg:readString()
            -- pGuild.mLevelGuild = mMsg:readInt()
            -- pGuild.mGuildExp = mMsg:readInt()
            self:dispatchEvent({name = Notify.EVENT_GUILD_INFO})
        end,

        [NetProtocol.cNotifyGuildInfo] = function(mMsg)
            local srcid = mMsg:readUInt()
            local guild_name = mMsg:readString()
            local guild_title = mMsg:readInt()
            if guild_name ~= "" and guild_title > 0 then
                self:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildchangeinfo",}))
                self:PushLuaTable("newgui.guildbuff.onGetJsonData",util.encode({actionid = "query",}))
                self:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildpanelinfo",}))
                if guild_title >= 300 then
                    self:ListGuild(0)
                    self:ListGuildMember(guild_name,100)
                end
            else
                self.mGuildFuli = 1
                self.mSelfGuildCT = 0
                self.myGuildLV = 0
                self.mGuildSkillData = {}
                self.mMyGuildSkillData = {}
                self.mGuildLevelData = {}
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_FULI})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_APPLY})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_SKILL})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_LEVEL})
            end
            self:dispatchEvent({name = Notify.EVENT_GUILD_TITLE})
        end,

        [NetProtocol.cResGetChartInfo] = function(mMsg)
            local chart_type = tostring(mMsg:readInt())
            local page = mMsg:readInt()+1
            local num = mMsg:readInt()
            local total_num = mMsg:readInt()
            local selfseq = mMsg:readInt()
            if not self.mChartData[chart_type] then
                self.mChartData[chart_type] = {}
            end
            self.mChartData[chart_type].totalnum = total_num
            self.mChartData[chart_type].selfseq = selfseq
            self.mChartData[chart_type].list = {}
            for i=1,num do
                local item = {}
                item.name = mMsg:readString()
                item.param = mMsg:readInt()
                item.guild = mMsg:readString()
                item.title = mMsg:readString()
                item.job = mMsg:readInt()
                item.lv = mMsg:readInt()
                item.reinlv = mMsg:readInt()
                if not self.mChartData[chart_type].list[page] then self.mChartData[chart_type].list[page] = {} end
                table.insert(self.mChartData[chart_type].list[page],item)
            end
            self:dispatchEvent({name = Notify.EVENT_REQCHART_LIST,page=page,chart_type=chart_type})
        end,

        [NetProtocol.cResVcoinShopList] = function(mMsg)
            self.mVcoinShopNpcID = mMsg:readInt()
        end,

        [NetProtocol.cResNPCShop] = function(mMsg)
            local srcid = mMsg:readUInt()
            local msg = mMsg:readString()
            local page = mMsg:readInt()
            local num = mMsg:readInt()
            self.mShopNpc.srcid = srcid
            self.mShopNpc.msg = msg
            self.mShopNpc.page = page
            self.mShopNpc.num = num

            local shopItems = {}
            for i = 1, num do
                local mSItemInfo = {}
                mSItemInfo.pos =  mMsg:readInt()
                mSItemInfo.good_id =  mMsg:readInt()
                mSItemInfo.type_id =  mMsg:readInt()
                mSItemInfo.number =  mMsg:readInt()
                mSItemInfo.price_type =  mMsg:readInt()
                mSItemInfo.price =  mMsg:readInt()
                mSItemInfo.oldprice =  mMsg:readInt()
                mSItemInfo.hotsale = mMsg:readInt()
                mSItemInfo.prop = mMsg:readInt()
                mSItemInfo.discount = mMsg:readInt()
                mSItemInfo.page = page
                table.insert(shopItems,mSItemInfo)
            end

            local npcShopInfo = self.mNpcShopInfo[srcid]
            if not npcShopInfo then
                npcShopInfo = {}
            end
            npcShopInfo[page] = shopItems
            self.mNpcShopInfo[srcid] = npcShopInfo
            self:dispatchEvent({name = Notify.EVENT_NET_NPC_SHOP})
        end,

        [NetProtocol.cNotifyItemPanelFresh] = function(mMsg)
            local flag = mMsg:readInt()
            self:dispatchEvent({name = Notify.EVENT_ITEM_PANEL_FRESH, panelid = flag})
        end,

        ----------------------------------------------------------------------------------聊天相关
        [NetProtocol.cResMapChat] = function(mMsg)
            local netChat = {}
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_channelid = Const.CHANNEL_TAG.YELL
            netChat.m_strType = Const.chat_prefix_yell
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cNotifyMapChat] = function(mMsg)
            local netChat = {}
            netChat.m_uSrcId = mMsg:readInt()
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_channelid = Const.CHANNEL_TAG.YELL
            netChat.m_strType = Const.chat_prefix_yell
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cResPrivateChat] = function(mMsg)
            local netChat = {}
            local target = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_strMsg = mMsg:readString()
            netChat.m_channelid = Const.CHANNEL_TAG.PRIVATE
            netChat.m_strType = Const.chat_prefix_private
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cNotifyPrivateChat] = function(mMsg)
            local netChat = {}
            netChat.m_uSrcId = mMsg:readInt()
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_channelid = Const.CHANNEL_TAG.PRIVATE
            netChat.m_strType = Const.chat_prefix_private
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)
            self.m_strPrivateChatTarget = netChat.m_strName
            self:dispatchEvent({name = Notify.EVENT_SHOW_BOTTOM,str="tip_private"})

        end,

        [NetProtocol.cResGuildChat] = function(mMsg)
            local netChat = {}
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_channelid = Const.CHANNEL_TAG.GUILD
            netChat.m_strType = Const.chat_prefix_guild
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cNotifyGuildChat] = function(mMsg)
            local netChat = {}
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_channelid = Const.CHANNEL_TAG.GUILD
            netChat.m_strType = Const.chat_prefix_guild
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cResGroupChat] = function(mMsg)
            local netChat = {}
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_channelid = Const.CHANNEL_TAG.GROUP
            netChat.m_strType = Const.chat_prefix_group
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cNotifyGroupChat] = function(mMsg)
            local netChat = {}
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_channelid = Const.CHANNEL_TAG.GROUP
            netChat.m_strType = Const.chat_prefix_group
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cResNormalChat] = function(mMsg)
            local netChat = {}
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_strType = Const.chat_prefix_nomal
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cNotifyNoramlChat] = function(mMsg)
            local netChat = {}
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_uSrcId = mMsg:readInt()
            netChat.m_strType = Const.chat_prefix_nomal
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)

        end,

        [NetProtocol.cResWorldChat] = function(mMsg)
            local netChat = {}
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_channelid = Const.CHANNEL_TAG.WORLD
            netChat.m_strType = Const.chat_prefix_world
            self:addToMsgHistory(netChat)
        end,

        [NetProtocol.cNotifyWorldChat] = function(mMsg)
            local netChat = {}
            netChat.m_uSrcId = mMsg:readInt()
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_channelid = Const.CHANNEL_TAG.WORLD
            netChat.m_strType = Const.chat_prefix_world
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)

        end,

        [NetProtocol.cResHornChat] = function(mMsg)
            local netChat = {}
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strName = game.mChrName
            netChat.m_strType = Const.chat_prefix_horn
            self:addToMsgHistory(netChat)
            local m_strHornMsg = netChat.m_strType..netChat.m_strMsg
            table.insert(self.mHornChat,m_strHornMsg)
            self:dispatchEvent({name = Notify.EVENT_HORN_CHAT})
        end,

        [NetProtocol.cNotifyHornChat] = function(mMsg)
            local netChat = {}
            netChat.m_uSrcId = mMsg:readInt()
            netChat.m_strName = mMsg:readString()
            netChat.m_strMsg = mMsg:readString()
            netChat.m_strType = Const.chat_prefix_horn
            for i,v in pairs(self.mFriends) do
                if v.title==102 then
                    if netChat.m_strName == v.name then
                        return
                    end
                end
            end
            self:addToMsgHistory(netChat)
            local m_strHornMsg = netChat.m_strType.."["..netChat.m_strName.."]"..netChat.m_strMsg
            table.insert(self.mHornChat,m_strHornMsg)
            self:dispatchEvent({name = Notify.EVENT_HORN_CHAT})

        end,

        [NetProtocol.cNotifyMonsterChat] = function(mMsg)
            local netChat = {}
            netChat.m_uSrcId = mMsg:readInt()
            netChat.m_strMsg = mMsg:readString()
        end,

        [NetProtocol.cResNPCTalk] = function(mMsg)
            local n_id=mMsg:readInt()
            local n_flag=mMsg:readInt()
            local n_param=mMsg:readInt()
            local n_title=mMsg:readString()
            local n_msg=mMsg:readString()
            if n_msg ~= "" then
                self.m_nNpcName = n_title
                self.m_nNpcTalkId = n_id
                self.m_strNpcTalkMsg = n_msg
                self.m_nTalkType = "npc"
                local s,e = string.find(n_msg,"m_tasknpc")
                if s then
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_npcTaskDialog"})
                else
                    self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str="panel_npctalk"})
                end
            end
        end,

        [NetProtocol.cNotifyGotoEndNotify] = function(mMsg)

            local target=mMsg:readString()
            local MainAvatar = CCGhostManager:getMainAvatar()
            MainAvatar:clearAutoMove()
            MainRole.handleAutoKillOn(false)
            if target=="autofightstart" then
                MainRole.mTargetNPCName = ""
                MainRole.handleAutoKillOn(true)
            elseif target~="" then
                local pGhost=NetCC:findGhostByName(target)
                if pGhost then
                    if pGhost:NetAttr(Const.net_type)==Const.GHOST_NPC then
                        self:NpcTalk(pGhost:NetAttr(Const.net_id),"100")
                    elseif pGhost:NetAttr(Const.net_type)==Const.GHOST_MONSTER then
                        MainRole.mTargetNPCName = ""
                        MainRole.handleAutoKillOn(true)
                    end
                end
            end
        end,

        [NetProtocol.cResInfoPlayer] = function(mMsg)
            local playerEquip = {}
            playerEquip.player_id 	= mMsg:readUInt()
            playerEquip.name 		= mMsg:readString()
            playerEquip.loverName 	= mMsg:readString()
            playerEquip.guild 		= mMsg:readString()
            playerEquip.coutry 		= mMsg:readString()
            playerEquip.gender 		= mMsg:readInt()
            playerEquip.fightpoint 	= mMsg:readInt()
            playerEquip.txinfo = mMsg:readInt()
            playerEquip.growthlv = mMsg:readInt()
            playerEquip.growthvalue = mMsg:readInt()
            playerEquip.bigv = mMsg:readInt()
            playerEquip.lv          = mMsg:readInt()
            playerEquip.brawn = mMsg:readInt()
            playerEquip.job = mMsg:readInt()
            playerEquip.vipLevel = mMsg:readInt()
            playerEquip.yuanshenglv = mMsg:readInt()
            playerEquip.wing = mMsg:readInt()
            playerEquip.wingbuffid = mMsg:readInt()
            playerEquip.pifeng = mMsg:readInt()
            playerEquip.pifengbuffid = mMsg:readInt()
            playerEquip.mount = mMsg:readInt()
            playerEquip.mountbuffid = mMsg:readInt()
            playerEquip.petlv = mMsg:readInt()
            playerEquip.suitlist = mMsg:readString()
            playerEquip.reinlv = mMsg:readInt()
            playerEquip.hideshenqi = mMsg:readInt()
            -- playerEquip.cloth       = mMsg:readInt()
            self.m_PlayerEquip[playerEquip.name] = playerEquip
            self.other_avatar_save = "saved"
            self:dispatchEvent({name = Notify.EVENT_PLAYER_INFO,pname=playerEquip.name})
        end,

        ----------------------------------------------------------------------------------熔炉相关


        --------------------------------------------------------------------------------------交易相关
        [NetProtocol.cNotifyTradeInvite] = function(mMsg)
            self.mTradeInviter = mMsg:readString()

            self:alertLocalMsg(self.mTradeInviter.."请求交易","alert")
            self:dispatchEvent({name = Notify.EVENT_TRADE_CHANGE,tradeTarget = self.mTradeInviter})
        end,

        [NetProtocol.cNotifyTradeInfo] = function(mMsg)

            self.mTradeInfo.mTradeGameMoney=mMsg:readInt()
            self.mTradeInfo.mTradeVcoin=mMsg:readInt()
            self.mTradeInfo.mTradeSubmit=mMsg:readInt()
            self.mTradeInfo.mTradeTarget=mMsg:readString()
            self.mTradeInfo.mTradeDesGameMoney=mMsg:readInt()
            self.mTradeInfo.mTradeDesVcoin=mMsg:readInt()
            self.mTradeInfo.mTradeDesSubmit=mMsg:readInt()
            self.mTradeInfo.mTradeDesLevel=mMsg:readInt()
            self.mTradeInfo.mIsTrade=mMsg:readInt()
            -- self.mUiState = bit.bnot(self.mUiState,8)
            self:dispatchEvent({name = Notify.EVENT_TRADE_MONEYCHANGE,str="panel_trade"})
        end,

        [NetProtocol.cNotifyTradeItemChange] = function(mMsg)
            local side = mMsg:readInt()
            local position = mMsg:readInt()
            local item = {}
            item.mTypeID = mMsg:readInt()
            item.mDuraMax = mMsg:readInt()
            item.mDuration = mMsg:readInt()
            item.mItemFlags = mMsg:readInt()
            item.mLevel = mMsg:readInt()
            item.mNumber = mMsg:readInt()
            item.mAddAC = mMsg:readShort()
            item.mAddMAC = mMsg:readShort()
            item.mAddDC = mMsg:readShort()
            item.mAddMC = mMsg:readShort()
            item.mAddSC = mMsg:readShort()
            item.mUpdAC = mMsg:readShort()
            item.mUpdMAC = mMsg:readShort()
            item.mUpdDC = mMsg:readShort()
            item.mUpdMC = mMsg:readShort()
            item.mUpdSC = mMsg:readShort()
            item.mLuck = mMsg:readShort()
            local show_flag = mMsg:readInt()
            item.mProtect = mMsg:readShort()
            item.mAddHp = mMsg:readShort()
            item.mAddMp = mMsg:readShort()
            item.mCreateTime = mMsg:readInt()
            if position < 12 then
                if side == 100 then
                    self.mThisChangeItems[position] = true
                    self.mThisTradeItems[position] = item
                elseif side == 101 then
                    self.mDesChangeItems[position] = true
                    self.mDesTradeItems[position] = item
                end
                self:dispatchEvent({name = Notify.EVENT_TRADE_ITEMCHANGE})
            end
        end,

        --------------------------------------------------------------------------------------
        [NetProtocol.cNotifyItemTalk] = function(mMsg)
            self.m_nItemTalkId = mMsg:readInt()
            self.m_nNpcTalkId = mMsg:readInt()
            local title = mMsg:readString()
            self.m_strNpcTalkMsg = mMsg:readString()
            self.m_strNpcTalkViewId = 0
            self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str="panel_itemtalk"})
        end,

        [NetProtocol.cNotifyPlayerTalk] = function(mMsg)
            self.m_nNpcTalkId = mMsg:readInt()
            self.m_strNpcTalkMsg = mMsg:readString()
            self.m_strNpcTalkViewId = 0
            self.m_nTalkType = "player"
            self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str="panel_npctalk"})
        end,

        [NetProtocol.cNotifyPushLuaTable] = function(mMsg)
            local ttype=mMsg:readString()
            local tdata=mMsg:readString()
            -- print("result == ",tdata,ttype)
            local result=util.decode(tdata)
            
            print("result == ",result)
            if ttype == "npc_talk" then
                self.m_nNpcTalkId = result.id
                self.m_strNpcTalkMsg = result.talk_str
                self.m_strNpcTalkViewId = result.viewid
                EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_npctalk"} )
            elseif ttype == "npc_echo" then
                local PixesGhost = require("app.PixesGhost")
                local pixesGhost = PixesGhost.getPixesGhost(result.id)
                PixesGhost.addTypewritter(pixesGhost,result.talk_str)
            elseif ttype == "item_param" then
                self:dispatchEvent({name = Notify.EVENT_ITEM_TIME, param_id = result.param_id})
                -- elseif ttype == "guide" then
                -- 	self:dispatchEvent({name = Notify.EVENT_SHOW_GUIDE, guideLevel = result.guideLevel}）
            elseif ttype == "alert" then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = result.panel, visible = result.visible,
                    lblConfirm = result.lblConfirm, num = result.num,
                    confirmTitle = result.confirmTitle,
                    cancelTitle = result.cancelTitle,
                    confirmCallBack = function (num)
                        self:PushLuaTable(result.path,util.encode({actionid = result.actionid, param = result.param,args=num}))
                    end
                }
                self:dispatchEvent(param)
            elseif ttype =="open" then
                self:dispatchEvent({name=Notify.EVENT_OPEN_PANEL,str=result.name,mParam = result.extend,mParam2 = result.extend2})
            elseif ttype =="close" then
                self:dispatchEvent({name=Notify.EVENT_CLOSE_PANEL,str=result.name})
            elseif ttype =="game_setting" then
                self:dispatchEvent({name=Notify.EVENT_GAME_SETTING,str=tdata})
            elseif ttype == "fuben" then
                self:dispatchEvent({name=Notify.EVENT_FUBEN_DATA, type=result.type, cmd=result.cmd, data=tdata})
            elseif ttype == "log_qibao" then
                if not self.mLogQibao then self.mLogQibao = {} end
                if #self.mLogQibao > 30 then
                    table.remove(self.mLogQibao, 1)
                end

                table.insert(self.mLogQibao, {typeid = result.info[1], num = result.info[2], time = os.time() })
            elseif ttype == "richang_done" then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "您已完成本次任务！",
                    confirmTitle = "提 交", cancelTitle = "取 消",
                    confirmCallBack = function ()
                        self:PushLuaTable(result.callback,util.encode({actionid = result.str}))
                    end
                }
                EventDispatcher:dispatchEvent(param)
            elseif ttype == "saodang_bagfull" then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "您的背包已满，多余的物品已发送至您的邮箱。",
                    confirmTitle = "确 认", cancelTitle = "取 消"
                }
                EventDispatcher:dispatchEvent(param)
            elseif ttype == "close_autofight" then
                MainRole.stopAttackOfSoldier()
                self:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = false})
            elseif ttype == "achieve_title" then
                self.mAchieveInfo = result
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE_PAGE})
                for i=1,6 do
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE+i})
                end
            elseif ttype == "achieve_reach" then
                if self.mAchieveInfo and #self.mAchieveInfo > 0 then
                    for k,v in pairs(self.mAchieveInfo) do
                        if v.subtype == result.subtype then
                            self.mAchieveInfo[result.subtype] = result
                        end
                    end
                else
                    self.mAchieveInfo[result.subtype] = result
                end
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE_PAGE})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE+result.subtype})
            elseif ttype == "yabiao_state" then
                MainRole.mDartState = result.state
            elseif ttype == "medal_data" then
                self.mMedalCanUp = result.canup
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE})
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE_MEDAL})
                self:notifyPanelData(ttype, tdata)
            elseif ttype == "newfighter_data" then
                if result.name == "fight_state" then
                    self.mFightState = result.s
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE1})
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE2})
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE3})
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN})
                end
                if result.name == "fighterfp" then
                    local fdef = NetClient:getFighterDefByID(result.raw_json_text.defid)
                    if fdef and self.mFightState then
                        self.mFightState.updateGold = fdef.mNeedBindGold
                        self.mFightState.updateNextLevel = fdef.mNeedLv
                        UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE4})
                    end
                end
                self:notifyPanelData(ttype, tdata)
            elseif ttype == "guildpanelchangeinfo" then
                if game.GetMainRole():NetAttr(Const.net_guild_name) ~= "" then
                    self.mGuildFuli = result.giftflag
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_FULI})
                    if self.mGuildLevelData then
                        self.mGuildLevelData.guildlv = result.level
                        self.mGuildLevelData.guild_exp = result.guildexp
                        UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_LEVEL})
                    end
                end
                self:notifyPanelData(ttype, tdata)
            elseif ttype == "skill_base_data" then
                self.mSelfGuildCT = result.guild_con
                self.myGuildLV = result.myglv
                self.mGuildSkillData = result.base_data
                self.mMyGuildSkillData = result.real_ldflag
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_SKILL})
                self:notifyPanelData(ttype, tdata)
            elseif ttype == "skill_upgrade" then
                self.mSelfGuildCT = result.guild_con
                self.mMyGuildSkillData[result.id][1] = result.level
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_SKILL})
                self:notifyPanelData(ttype, tdata)
            elseif ttype == "guildpanelinfo" then
                self.mGuildLevelData = result
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_LEVEL})
                self:notifyPanelData(ttype, tdata)
            else
                self:notifyPanelData(ttype, tdata)
            end
        end,

        [NetProtocol.cNotifyGameParam] = function(mMsg)
            -- TODO 需核对
            local param={}
            param.mSteelEquipCostBase = mMsg:readInt()
            param.mSteelEquipCostMul = mMsg:readInt()
            param.mMaxMagicAnti = mMsg:readInt()
            param.mWalkSpeedWarriorClientParam = mMsg:readInt()
            param.mStandRelivePrice = mMsg:readInt()
            param.mChartOpenLimitLevel = mMsg:readInt()
            param.mAddDepotPrice = mMsg:readInt()
            param.mExchangeUpdProbBase = mMsg:readInt()
            param.mExchangeUpdProbGap = mMsg:readInt()
            param.mExchangeUpdDropMax = mMsg:readInt()
            param.mExchangeUpdCostGM = mMsg:readInt()
            param.mExchangeUpdCostBV = mMsg:readInt()
            param.mStatusQiseshendanAC = mMsg:readInt()
            param.mStatusQiseshendanACMax = mMsg:readInt()
            param.mStatusQiseshendanMAC = mMsg:readInt()
            param.mStatusQiseshendanMACMax = mMsg:readInt()
            param.mStatusQiseshendanDC = mMsg:readInt()
            param.mStatusQiseshendanDCMax = mMsg:readInt()
            param.mStatusQiseshendanMC = mMsg:readInt()
            param.mStatusQiseshendanMCMax = mMsg:readInt()
            param.mStatusQiseshendanSC = mMsg:readInt()
            param.mStatusQiseshendanSCMax = mMsg:readInt()
            param.mStatusQiseshendanHpmaxBase = mMsg:readInt()
            param.mStatusQiseshendanHpmaxGap = mMsg:readInt()
            param.mStatusQiseshendanMpmaxBase = mMsg:readInt()
            param.mStatusQiseshendanMpmaxGap = mMsg:readInt()
            param.mStatusYuanshenhutiAC = mMsg:readInt()
            param.mStatusYuanshenhutiACMax = mMsg:readInt()
            param.mStatusYuanshenhutiMAC = mMsg:readInt()
            param.mStatusYuanshenhutiMACMax = mMsg:readInt()
            param.mStatusYuanshenhutiDC = mMsg:readInt()
            param.mStatusYuanshenhutiDCMax = mMsg:readInt()
            param.mStatusYuanshenhutiMC = mMsg:readInt()
            param.mStatusYuanshenhutiMCMax = mMsg:readInt()
            param.mStatusYuanshenhutiSC = mMsg:readInt()
            param.mStatusYuanshenhutiSCMax = mMsg:readInt()
            param.mStatusTianshenhutiMAXHP = mMsg:readInt()
            param.mStatusTianshenhutiDC = mMsg:readInt()
            param.mStatusTianshenhutiDCMax = mMsg:readInt()
            param.mStatusTianshenhutiMC = mMsg:readInt()
            param.mStatusTianshenhutiMCMax = mMsg:readInt()
            param.mStatusTianshenhutiSC = mMsg:readInt()
            param.mStatusTianshenhutiSCMax = mMsg:readInt()
            param.mStatusTianshenhutiSubDamageProb = mMsg:readInt()
            param.mStatusTianshenhutiSubDamagePres = mMsg:readInt()
            param.mStatusBaqihutiAC = mMsg:readInt()
            param.mStatusBaqihutiACMax = mMsg:readInt()
            param.mStatusBaqihutiMAC = mMsg:readInt()
            param.mStatusBaqihutiMACMax = mMsg:readInt()
            param.mStatusBaqihutiDC = mMsg:readInt()
            param.mStatusBaqihutiDCMax = mMsg:readInt()
            param.mStatusBaqihutiMC = mMsg:readInt()
            param.mStatusBaqihutiMCMax = mMsg:readInt()
            param.mStatusBaqihutiSC = mMsg:readInt()
            param.mStatusBaqihutiSCMax = mMsg:readInt()
            param.mDeleteExchangeUpdFromEquip = mMsg:readInt()
            param.mDieDropBagProb = mMsg:readInt()
            param.mDieDropLoadProb = mMsg:readInt()
            param.mProtectItemPrice = mMsg:readInt()
            param.mProtectItemProbMax = mMsg:readInt()
            param.mProtectItemProb = mMsg:readInt()
            param.mProtectItemAdd = mMsg:readInt()
            param.mPKConfirm = mMsg:readInt()
            param.mStatusFuQiTongXinAC = mMsg:readInt()
            param.mStatusFuQiTongXinACMax = mMsg:readInt()
            param.mStatusFuQiTongXinMAC = mMsg:readInt()
            param.mStatusFuQiTongXinMACMax = mMsg:readInt()
            param.mGuildMemberMax = mMsg:readInt()
            param.mReinResetAttrVcoin = mMsg:readInt()
            param.mReinBuyTimesVcoin = mMsg:readInt()
            param.mReinDCMaxPoint = mMsg:readInt()
            param.mReinMCMaxPoint = mMsg:readInt()
            param.mReinSCMaxPoint = mMsg:readInt()
            param.mReinACMaxPoint = mMsg:readInt()
            param.mReinMACMaxPoint = mMsg:readInt()
            param.mReinHPMaxPoint = mMsg:readInt()
            param.mReinMPMaxPoint = mMsg:readInt()
            param.mReinAccuaryPoint = mMsg:readInt()
            param.mReinDodgePoint = mMsg:readInt()
            param.mReinFreeTimesADay = mMsg:readInt()
            param.mTotalAttrLevelLimit = mMsg:readInt()
            param.mStatusXinFaHPMax = mMsg:readInt()
            param.mStatusXinFaXishou = mMsg:readInt()
            param.mStatusXinFaAC = mMsg:readInt()
            param.mStatusXinFaACMax = mMsg:readInt()
            param.mStatusXinFaMAC = mMsg:readInt()
            param.mStatusXinFaMACMax = mMsg:readInt()
            param.mStatusXinFaDC = mMsg:readInt()
            param.mStatusXinFaDCMax = mMsg:readInt()
            param.mStatusXinFaMC = mMsg:readInt()
            param.mStatusXinFaMCMax = mMsg:readInt()
            param.mStatusXinFaSC = mMsg:readInt()
            param.mStatusXinFaSCMax = mMsg:readInt()
            param.mShowLoginForm = mMsg:readInt()
            param.mStatusZhuanShenMaxHp = mMsg:readInt()
            param.mStatusZhuanShenMaxMp = mMsg:readInt()
            param.mStatusZhuanShenXishou = mMsg:readInt()
            param.mStatusZhuanShenDC = mMsg:readInt()
            param.mStatusZhuanShenDCMax = mMsg:readInt()
            param.mStatusZhuanShenMC = mMsg:readInt()
            param.mStatusZhuanShenMCMax = mMsg:readInt()
            param.mStatusZhuanShenSC = mMsg:readInt()
            param.mStatusZhuanShenSCMax = mMsg:readInt()
            param.mStatusVipDamageMul = mMsg:readInt()
            param.mStatusVipExpMul = mMsg:readInt()
            param.mStatusVipMC = mMsg:readInt()
            param.mStatusVipMCMax = mMsg:readInt()
            param.mStatusVipSC = mMsg:readInt()
            param.mStatusVipSCMax = mMsg:readInt()
            param.mStatusVipAC = mMsg:readInt()
            param.mStatusVipACMax = mMsg:readInt()
            param.mStatusVipMAC = mMsg:readInt()
            param.mStatusVipMACMax = mMsg:readInt()
            param.mWorldChatCostMoney = mMsg:readInt()
            param.mStatusKingdomDC = mMsg:readInt()
            param.mStatusKingdomDCMax = mMsg:readInt()
            param.mStatusKingdomMC = mMsg:readInt()
            param.mStatusKingdomMCMax = mMsg:readInt()
            param.mStatusKingdomSC = mMsg:readInt()
            param.mStatusKingdomSCMax = mMsg:readInt()
            param.mStatusKingdomAC = mMsg:readInt()
            param.mStatusKingdomACMax = mMsg:readInt()
            param.mStatusKingdomMAC = mMsg:readInt()
            param.mStatusKingdomMACMax = mMsg:readInt()
            param.mGuildWarGold = mMsg:readInt()
            self.mGameParam = param
        end,

        [NetProtocol.cResCarryShop] = function(mMsg)
            local page = mMsg:readInt() or 0
            local result = {}
            local listsize = mMsg:readInt()
            for i = 1, listsize do
                local carryShopItem = {}
                carryShopItem.id = mMsg:readInt()
                carryShopItem.item_id = mMsg:readInt()
                carryShopItem.pos = mMsg:readInt()
                carryShopItem.money_type = mMsg:readInt()
                carryShopItem.price = mMsg:readInt()
                carryShopItem.bind = mMsg:readInt()
                table.insert(result, carryShopItem)
            end
            self.mCarryShopList[page] = result
            self:dispatchEvent({name = Notify.EVENT_PUSH_CARRYSHOP_DATA, page = page})
        end,
        [NetProtocol.cNotifyTurn] = function(mMsg)
            local srcid = mMsg:readInt()
            local dir = mMsg:readInt()
            if srcid == MainRole.mID then
                print("NetProtocol.cNotifyTurn", dir)
            end
        end,

        [NetProtocol.GS_Client_List_ChargeDart_Notify] = function(mMsg)
            local num = mMsg:readInt()
            -- print("num", num)
            local result = {}
            for i = 1, num do

                local param = {}
                param.charName = mMsg:readString()
                param.icon = mMsg:readInt()
                param.remainTime = mMsg:readInt()
                param.duration = mMsg:readInt()
                param.fightForce = mMsg:readInt()
                param.stolenTimes = mMsg:readInt()
                param.totalAwards = mMsg:readInt()
                param.remainAward = mMsg:readInt()
                param.state = mMsg:readInt()

                table.insert(result, param)
            end
            -- self:dispatchEvent({name = Notify.EVENT_PUSH_PANEL_DATA, type="listDart", data=result})

            self:dispatchEvent({name = Notify.EVENT_PUSH_DART_DATA, data=result})
        end,
        [NetProtocol.cNotifyChuanSongResult] = function(mMsg)
            local result = mMsg:readInt()
            if result == 1 then
                MainRole.stopAutoMove()
                MainRole.handleAutoKillOn(false)
            end
        end,
        [NetProtocol.cNotifyGameEntered] = function(mMsg)
            self.isEnterGame = true
        end,
        [NetProtocol.cNotifyPlayerLookChange] = function(mMsg)
            local wing = mMsg:readInt()
            local pifeng = mMsg:readInt()
            local mount = mMsg:readInt()
            local wingbuffid = mMsg:readInt()
            local pifengbuffid = mMsg:readInt()
            local mountbuffid = mMsg:readInt()

            self.mCharacter.mLookWing = wing
            self:dispatchEvent({name=Notify.EVENT_AVATAR_CHANGE})
        end,
        [NetProtocol.cNotifyBossOwnerChange] = function(mMsg)
            local bossid = mMsg:readInt()
            local playerName = mMsg:readString()
            self.mBossOwer[bossid]=playerName
            self:dispatchEvent({name=Notify.EVENT_BOSS_OWNER_CHANGE,bossid=bossid,})
        end,
        [NetProtocol.cNotifyIntValue] = function(mMsg)
            local index = mMsg:readInt()
            local value = mMsg:readInt()
            self.mIntValue[index]=value
            self:dispatchEvent({name=Notify.EVENT_PLAYER_INTVALUE_CHANGE,index=index,})
        end,
        [NetProtocol.cNotifyMails] = function(mMsg)
            local mailsize = mMsg:readInt()
            local clearflag = mMsg:readInt() --1表示最后一条
            for i = 1, mailsize do
                local mailinfo = {}
                mailinfo.mailID = mMsg:readString()
                mailinfo.title = mMsg:readString()
                mailinfo.content = mMsg:readString()
                mailinfo.senddate = mMsg:readString()
                mailinfo.leftsecond = mMsg:readString()
                mailinfo.isOpen = mMsg:readInt()
                mailinfo.isReceive = mMsg:readInt()
                local fujiansize = mMsg:readInt()
                mailinfo.fujinItems = {}
                for j = 1, fujiansize do
                    local typeid = mMsg:readInt()
                    local num = mMsg:readInt()
                    table.insert(mailinfo.fujinItems, {typeid=typeid,num=num })
                end
                self.mMailList[mailinfo.mailID] = mailinfo
            end
            if clearflag == 1 then self.mReqMailList = false self:dispatchEvent({name=Notify.EVENT_RECEIVE_MAIL_LIST}) end
        end,
        [NetProtocol.cNotifyMailNum] = function(mMsg)
            self.mNewMailNum = mMsg:readInt()
            self.openMailType = false
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.NEWMAIL})
            self:dispatchEvent({name=Notify.EVENT_RECEIVE_MAIL_LIST})
        end,
        [NetProtocol.cNotifyMailReceiveSuccess] = function(mMsg)
            local mailsize = mMsg:readInt()
            local receiveids = {}
            for i = 1, mailsize do
                local mailID = mMsg:readString()
                if self.mMailList[mailID] then
                    self.mMailList[mailID].isReceive = 1
                    self.mMailList[mailID].isOpen = 1
                    table.insert(receiveids, mailID)
                end
            end
            if #receiveids > 0 then
                self:dispatchEvent({name=Notify.EVENT_RECEIVE_FUJIAN_SUCCESS,receiveids = receiveids})
            end
        end,
        [NetProtocol.cNotifyDelMail] = function(mMsg)
            local mailsize = mMsg:readInt()
            local deleteids = {}
            for i = 1, mailsize do
                local mailID = mMsg:readString()
                if self.mMailList[mailID] then
                    self.mMailList[mailID] = nil
                    table.insert(deleteids, mailID)
                end
            end
            if #deleteids > 0 then
                self:dispatchEvent({name=Notify.EVENT_DELETE_MAIL_SUCCESS,deleteids = deleteids})
            end
        end,
        [NetProtocol.cNotifyChinaLimitLv] = function(mMsg)
            local china_limit_lv = mMsg:readUInt() --防沉迷等级
            local online_time_today = mMsg:readInt() --累计在线时间
            local china_id = mMsg:readInt() --是否验证
            self.mFcmInfo = {china_id = china_id,online_time_today=online_time_today,china_limit_lv=china_limit_lv}
            game.openFangchengmi()
        end,
        [NetProtocol.cNotifyGuildItemChange] = function(mMsg)
            local guildItem = {}
            guildItem.position = mMsg:readInt()
            guildItem.mTypeID = mMsg:readInt()
            guildItem.mDuraMax = mMsg:readInt()
            guildItem.mDuration = mMsg:readInt()
            guildItem.mItemFlags = mMsg:readInt()
            guildItem.mLevel = mMsg:readInt()
            guildItem.mUpdCount = mMsg:readInt()
            guildItem.mAddAC = mMsg:readShort()
            guildItem.mAddMAC = mMsg:readShort()
            guildItem.mAddDC = mMsg:readShort()
            guildItem.mAddMC = mMsg:readShort()
            guildItem.mAddSC = mMsg:readShort()
            guildItem.mUpdAC = mMsg:readShort()
            guildItem.mUpdMAC = mMsg:readShort()
            guildItem.mUpdDC = mMsg:readShort()
            guildItem.mUpdDCMAX = mMsg:readShort()
            guildItem.mUpdMC = mMsg:readShort()
            guildItem.mUpdMCMAX = mMsg:readShort()
            guildItem.mUpdSC = mMsg:readShort()
            guildItem.mUpdSCMAX = mMsg:readShort()
            guildItem.mLuck = mMsg:readShort()
            guildItem.mShowFlags = mMsg:readInt()
            guildItem.mProtect = mMsg:readShort()
            guildItem.mAddHp = mMsg:readInt()
            guildItem.mAddMp = mMsg:readInt()
            guildItem.mCreateTime = mMsg:readInt()
            guildItem.mAddType = mMsg:readInt()
            guildItem.mUpdFp = mMsg:readInt()
            guildItem.mHoleInfo = mMsg:readString()
            guildItem.mStoneInfo = mMsg:readString()
            guildItem.mColorRate = mMsg:readInt()
            guildItem.mUpdTimes = mMsg:readInt()
            guildItem.mBaseFight = mMsg:readInt()
            guildItem.mExt1 = mMsg:readInt()
            guildItem.mShenzhu = mMsg:readInt()
            guildItem.mEnd = mMsg:readInt()
            -- self.mGuildDepotItems[guildItem.position] = guildItem
                if not guildItem then return end
                local oldType
                if self.mGuildDepotItems[guildItem.position] ~= nil then
                    oldType=self.mGuildDepotItems[guildItem.position].mTypeID
                    self.mGuildDepotItems[guildItem.position] = nil
                end
                if guildItem.mTypeID > 0 and guildItem.position >= 3500 then
                    self.mGuildDepotItems[guildItem.position] = guildItem
                    -- if show_flags ~= 0 and show_flags ~= 100 and show_flags ~= 1002 and game.IsPosInBag(guildItem.position) and game.IsEquipment(guildItem.mTypeID) then
                    --     self:check_better_item(guildItem.position)
                    -- end
                else
                    self.mGuildDepotItems[guildItem.position] = nil
                end
            if guildItem.mEnd == -1 then
                self:dispatchEvent({name=Notify.EVENT_GUILD_ITEM_CHANGE,pos=guildItem.position,oldType=oldType})
                -- self:dispatchEvent({name=Notify.EVENT_GUILD_ITEM_CHANGE})
            end
        end,
        [NetProtocol.cNotifyGuildUnion] = function(mMsg)
            local guild_name = mMsg:readString()
            local opcode = mMsg:readInt()
            local pGuild = self:getGuildByName(guild_name)
            if pGuild then
                pGuild.opcode = opcode
                if opcode == 7 or opcode == 8 then
                    self:dispatchEvent({name=Notify.EVENT_GUILD_LIST})
                elseif opcode == 3 then--其他行会请求联盟
                    table.insert(self.mGuildUnionApply,guild_name)
                    self:dispatchEvent({name=Notify.EVENT_GUILD_UNION_LIST,list_type = 1})
                elseif opcode == 6 then--其他行会取消联盟
                    for i=1,#self.mGuildUnionApply do
                        if self.mGuildUnionApply[i] == guild_name then
                            table.remove(self.mGuildUnionApply,i)
                        end
                    end
                    self:dispatchEvent({name=Notify.EVENT_GUILD_UNION_LIST,list_type = 1})
                elseif opcode == 4 then--解散联盟
                    if self.mGuildUnioned[1] == guild_name then
                        self.mGuildUnioned = {}
                        self:dispatchEvent({name=Notify.EVENT_GUILD_UNION_LIST,list_type = 0})
                    end
                elseif opcode == 5 then--同意联盟
                    self.mGuildUnioned = {}
                    self.mGuildUnioned[1] = guild_name
                    self:dispatchEvent({name=Notify.EVENT_GUILD_UNION_LIST,list_type = 0})
                end
            end
        end,
        [NetProtocol.cNotifyGuildUnionList] = function(mMsg)
            local list_type = mMsg:readInt()
            local list_size = mMsg:readInt()
            local guildUnion = {}
            for i=1,list_size do
                local guild_name = mMsg:readString()
                table.insert(guildUnion,guild_name)
            end
            if list_type == 0 then
                self.mGuildUnioned = guildUnion
            elseif list_type == 1 then
                self.mGuildUnionApply = guildUnion
                -- UIRedPoint.handleChange({UIRedPoint.REDTYPE.GUILD_UNION})
            elseif list_type == 2 then
                self.mGuildUnionSelfApply = guildUnion
            end
            self:dispatchEvent({name=Notify.EVENT_GUILD_UNION_LIST,list_type = list_type})
        end,
        [NetProtocol.cNotifyGuildWar] = function(mMsg)
            local guildWar = {}
            guildWar.guild_name = mMsg:readString()
            guildWar.opcode = mMsg:readInt()
            guildWar.lefttime = mMsg:readInt()
            guildWar.level = mMsg:readInt()
            guildWar.memcount = mMsg:readInt()
            guildWar.fight = mMsg:readInt()
            local isInList = false
            for i=1,#self.mGuildWar do
                if self.mGuildWar[i].guild_name == guildWar.guild_name then
                    self.mGuildWar[i].opcode = guildWar.opcode
                    self.mGuildWar[i].lefttime = guildWar.lefttime
                    self.mGuildWar[i].level = guildWar.level
                    self.mGuildWar[i].memcount = guildWar.memcount
                    self.mGuildWar[i].fight = guildWar.fight
                    isInList = true
                end
            end
            if not isInList then
                table.insert(self.mGuildWar,guildWar)
            end
            self:dispatchEvent({name=Notify.EVENT_GUILD_WAR_LIST})
        end,
        [NetProtocol.cNotifyGuildWarList] = function(mMsg)
            local list_size = mMsg:readInt()
            for i=1,list_size do
                local guildWar = {}
                guildWar.guild_name = mMsg:readString()
                guildWar.lefttime = mMsg:readInt()
                guildWar.level = mMsg:readInt()
                guildWar.memcount = mMsg:readInt()
                guildWar.fight = mMsg:readInt()
                table.insert(self.mGuildWar,guildWar)
            end
        end,
    }
end

function NetClient:init()

    --这里存储当前角色所有相关信息

--    self:removeAllEventListeners() 切换角色的时候无法监听到

    self.mLogicMap=nil
    self.mPingDelay=game.getTime()

    self.mCharacter={mID=0,mType=Const.GHOST_THIS,mCloth=-1,mWeapon=-1,mMount=-1,mLiquan=0}
    self.mNetGhosts={}
    self.mItemDesp={}
    self.mFriends={}
    self.mItems = {}
    self.mParam={}
    self.mGuildDepotItems = {}
    self.mIntValue={}

    self.mExtendState={}
    self.mBottomState={}
    self.mSwitchState={}

    self.mSelfModel={}
    self.mOtherModel={}
    self.mGroupMembers={}

    self.mMapConn = {}
    -- self.mSafeData = {}
    self.mMiniNpc = {}
    self.mNetMap={mMapID=nil,mLastMapID=nil}

    self.mGuildList = {}
    self.mChartData = {}

    self.mVcoinShopNpcID = -1
    self.mShopNpc = {}
    self.mNpcShopInfo = {}

    self.mGameParam = {}

    self.mChatHistroy = {}
    self.mHornChat = {}

    self.m_skillsDesp = {}

    self.m_nNpcId = 0
    self.m_nNpcTalkId = 0
    self.m_nItemTalkId = 0
    self.m_strNpcTalkMsg = ""
    self.m_strPrivateChatTarget = ""

    --消息验证
    self.mMoveStep=0
    self.mMoveStepRes=0
    self.mServerDir=0
    self.mServerX=0
    self.mServerY=0
    -- self.mMoveResTime=game.getTime()
    self.mMoveReqX=0
    self.mMoveReqY=0

    self.mSkillSendTag=0
    self.mUseItemSendTag=0

    self.mCastSkillTime=game.getTime()

    self.m_nCountDownDelay=0
    self.m_strCountDownMsg=""
    self.m_bLevelChanged=false
    self.m_bAllowInvite=true
    self.m_bGroupPickMode=true
    self.m_bIsDisConnect = false
    self.m_bCollecting = false
    self.m_bReqCollect = false
    self.m_IsBagSellItem = false

    -- self.mStartAutoFight=false
    self.mAttackMode=101
    self.mBagSlotAdd = 0
    self.mDepotSlotAdd = 0
    self.mBagMaxSlot = 0
    self.mXJ_slot_pos = 0  ---镶嵌位置
    self.mXJ_xq_or_hc = 1 ---1镶嵌 2合成
    self.mXJ_xq_data = {} ---镶嵌表

    self.m_IsBagSellItem = false
    self.m_BestSellerNum = 0
    self.m_netSkill = {}
    self.m_netSkillOpen = {}--技能的开启状态
    self.m_skillAddList = {}
    self.m_skillCD = {}
    self.mShortCut = {}
    self.mNetStatus = {}
    self.mStatusDesp = {}
    self.mChatMemory = {}
    self.mOthersItems ={}
    self.m_PlayerEquip = {}
    self.mMapOptions = {}

    --主角行为相关数据
    self.mLastAimGhost=-1
    self.mCrossAutoMove = false
    self.mCrossAutoMoveFlag = 0
    self.m_bAutoWalk = false
    self:resetLiehuoSkillInfo()
    self.m_targetMap = ""
    self.mTargetMapX = 0
    self.mTargetMapY = 0
    self.mCrossMapPath = {}
    self.mSlaveState = 0
    self.mCreateJob = 0
    self.mGuildFuli = 1
    self.mSelfGuildCT = 0
    self.myGuildLV = 0
    self.mGuildSkillData = {}
    self.mMyGuildSkillData = {}
    self.mGuildLevelData = {}
    self.mCollectKuang = false

    --交易信息
    self.mTradeInviter=""
    self.mUiState = 1
    self.mThisChangeItems = {}
    self.mDesChangeItems = {}
    self.mThisTradeItems = {}
    self.mDesTradeItems = {}
    self.mTradeInfo=
    {
        mTradeGameMoney=0,
        mTradeVcoin=0,
        mTradeSubmit=0,
        mTradeTarget="",
        mTradeDesGameMoney=0,
        mTradeDesVcoin=0,
        mTradeDesSubmit=0,
        mTradeDesLevel=0,
        mIsTrade=0,
    }

    --
    self.mGroupApplyers = {}
    self.mGroupInvite = {}
    self.nearByGroupInfo = {}
    self.mLogQibao = {}
    self.mInitShortCut = false
    self.mCarryShopList = {}
    self.lastSkillParamID = -1
    self.mGotCKList = false
    self.isEnterGame = false
    self.mMedalCanUp = 0
    self.mBossOwer={}
    self.mAchieveInfo = {}
    self.mGuildUnioned = {}
    self.mGuildUnionApply = {}
    self.mGuildUnionSelfApply = {}
    self.mGuildWar = {}
    self.mMapMonster = {}
    self:initReliveInfo()
    self:initKingVar()
    self:initOtherVar()
    self:initVipVar()
    self:initTestVar()
end

function NetClient:initVipVar()
    self.mVIPLevel = 0
    self.mLeijiChongzhiYb = 0 --累计充值元宝数
end

function NetClient:initOtherVar()
--    self.mSkillUpInfo = {}
    self.mOpenFunc = {}
    self.mNeigongBaseInfo = {}
    self.mYuanshenInfo = {}
    self.mShenluInfo = {}
    self.mActivityList = {}
    self.mActivityTitleList = {}
    self.mPromptInfo = {}
    self.mWingInfo = {}
    self.mRingInfo = {}
    self.mFirstchargeInfo = {}
    self.mTopBtn = {}
    self.mVitalityInfo = {}
    self.mDailyActOpenStr = ""
    self.mMailList = {}
    self.mNewMailNum = 0
    self.mReqMailList = false -- 是否需要请求
    self.mAutoTaskDone = true
    self.mFcmDescList = {}
    self.mFcmInfo = {china_id = 0,onlinetime=0}
    self.mCarryShopNum = {}
    self.mOfflineExpInfo = nil
    self.mHongbaoNew = false
    self.mSevenLoginInfo = {state={},loginCnt=0 }
    self.mLevelInvestInfo = nil
    self.mPrivilegeCardInfo = nil
    self.mVipLevelGiftInfo = {}
    self.mXunbaoShopList = {}
    self.mXunbaoShopExchangeLogList = {}
    self.mGetExchangeList = false
    self.mXunbaoJf = 0
    self.mAutoBuyDrugInfo = {} --特权自动买药信息
    self.mItemUseInfo = {}
end

function NetClient:initKingVar()
    self.mWarState = 0
    self.mKingGuild = ""
    self.mKingOfKings = ""
    self.mHasKing = 0
    self.mKingGuildName = ""
    self.mKingMembers = {}
    self.mKingInfo = nil
    self.mKingJFPoint = 0
    self.mKingJFAwardList = {}
    self.mKingJFAwardFlagList = {}
    self.mKingReliveTime = 0
    self.mKingMapInfo = nil
end

function NetClient:initTestVar()
    self.showUpEffect = true
    self.showFp = true
    self.showAlert = true
end

function NetClient:initReliveInfo()
    self.mReliveInfo = {max=0,left=0,time=0}-- {蒙面杀手 龙城宝藏里的送的原地复活次数，复活间隔
end

function NetClient:ParseMsg(mMsg)

    local type=mMsg:readShort()
    if not NetProtocol.log[type] then
        print(string.format("msg type: 0x%04X",type))
    elseif type~=NetProtocol.cResPing then
        if type ~= NetProtocol.cNotifyItemChange and  type ~= NetProtocol.cNotifyMapMiniNpc and type ~= NetProtocol.cNotifyListGuildItem then
        print("recv msg "..NetProtocol.log[type])
        end

    end

    if self.NetFunc[type] then
        self.NetFunc[type](mMsg)
    end

end
-------------------------------------------------------------------请求

local function BuildBA(msgid)

    -- print("send msg "..NetProtocol.log[msgid])

    local msg=SocketManager:getSendByteArray()
    msg:writeShort(msgid)
    return msg
end

function NetClient:Ping()
    local msg=BuildBA(NetProtocol.cReqPing)
    -- msg:writeShort(authid)
    self.mPingDelay = game.getTime()
    NetworkCenter:sendMsg(msg)
end

function NetClient:Authenticate(type,session,seed,authid)
    local msg=BuildBA(NetProtocol.cReqAuthenticate)

    -- print("Authenticate "..session)

    msg:writeInt(type)
    msg:writeString(session)
    msg:writeInt(seed)
    msg:writeInt(authid)
    print("req Authenticate===>>", type,session, seed, authid)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ListCharacter()
    self.isReqChar = true
    local msg=BuildBA(NetProtocol.cReqListCharacter)

    msg:writeInt(0)
    print("req ListCharacter===>>")
    NetworkCenter:sendMsg(msg)
end

function NetClient:DeleteCharacter(charname)
    local msg=BuildBA(NetProtocol.cReqDeleteCharacter)

    msg:writeString(charname)

    NetworkCenter:sendMsg(msg)
end

function NetClient:EnterGame(charname,sessionid)
    local msg=BuildBA(NetProtocol.cReqEnterGame)

    msg:writeString(charname)
    msg:writeString(sessionid)

    print("req EnterGame",charname,sessionid)
    NetworkCenter:sendMsg(msg)
end

function NetClient:CreateCharacter(chrname,job,gender,youke)

    local o=string.find(chrname,"[\"'<>, \n\t]")
    if o and o>0 then
        self:alertLocalMsg("名称中包含非法字符！","alert")
        return
    end

    youke=youke or ""

    local msg=BuildBA(NetProtocol.cReqCreateCharacter)

    msg:writeString(chrname)
    msg:writeInt(job)
    msg:writeInt(gender)
    msg:writeString(youke)

    NetworkCenter:sendMsg(msg)
end

function NetClient:Turn(dir)
    local msg=BuildBA(NetProtocol.cReqTurn)
    msg:writeInt(dir)
    print(string.format("reqTurn==== from:%d to %d",MainRole.mDir,dir))
    -- if MainRole then
    MainRole.mDir = dir
    -- end
    self.mServerDir = dir
    NetworkCenter:sendMsg(msg)
end

function NetClient:UseSkill(skill_type,paramX,paramY,paramID,plus_skill)
    if not plus_skill then plus_skill = 0 end
    -- if not MainRole then return end

    -- if self.mCharacter.mDead then return end
    local todir= game.getLogicDirection(cc.p(MainRole.mX,MainRole.mY),cc.p(paramX,paramY))
    if skill_type==Const.SKILL_TYPE_YiBanGongJi and todir~=MainRole.mDir then
        self:Turn(todir)
    end

    if not MainRole.m_isReadyUseSkill then
        print("not ready use skill!")
        return
    end

    self.mSkillSendTag=self.mSkillSendTag+1

    if not game.isAllCishaSkill(skill_type) then
        MainRole.m_isReadyUseSkill = false
    end

    self.mCastSkillTime = game.getTime()
    MainRole.startSkillCD(skill_type)

    if skill_type==Const.SKILL_TYPE_YiBanGongJi then
        self:resetLiehuoSkillInfo()
    end

    local MainAvatar = CCGhostManager:getMainAvatar()

    if MainAvatar then
        local skill_desp = self:getSkillDefByID(skill_type)
        if MainAvatar:NetAttr(Const.net_job) == Const.JOB_ZS and skill_type ~= Const.SKILL_TYPE_YiBanGongJi then
        else
            if plus_skill and plus_skill > 0 then skill_desp = self:getSkillDefByID(plus_skill) end
            if skill_desp then
                print("handleNotifyUseSkill===============", skill_type,skill_desp.mEffectType,paramX,paramY,paramID,skill_desp.mEffectResID,skill_type)
                MainAvatar:handleNotifyUseSkill(skill_desp.mEffectType,paramX,paramY,paramID,skill_desp.mEffectResID,skill_type)
                if skill_type == Const.SKILL_TYPE_YiBanGongJi then
                    if MainAvatar:NetAttr(Const.net_weapon) > 0 then
                        local itemWeapon = self:getNetItem(Const.ITEM_WEAPON_POSITION)
                        if itemWeapon then
                            local itemdef = self:getItemDefByID(itemWeapon.mTypeID)
                            if itemdef then
                                game.playSoundByID("sound/1000"..itemdef.SubType..".mp3")
                            end
                        end
                    end
                    game.playSoundByID("sound/100050.mp3")
                end
            end
        end
    end
    
    local msg=BuildBA(NetProtocol.cReqUseSkill)
    msg:writeShort(skill_type)
    msg:writeShort(paramX)
    msg:writeShort(paramY)
    msg:writeUInt(paramID)
    msg:writeInt(self.mSkillSendTag)
    msg:writeInt(game.getSkipTime())
    msg:writeShort(plus_skill or 0)--plugskilltype
    NetworkCenter:sendMsg(msg)

    if self.lastSkillParamID == paramID then
        print("可能上个tag技能没有伤害")
    end

    self.lastSkillParamID = paramID
    if game.isFsDun(skill_type) then
        MainRole.mAutoCastSkill = true
    end

    print(os.date("%H:%M:%S").." use skill====tag:"..self.mSkillSendTag..",paramX="..paramX..",paramY="..paramY..",paramID="..paramID..",skillid="..skill_type..",plus_skill="..plus_skill)
end

function NetClient:GetItemDesp(typeid,itemName)
    local msg=BuildBA(NetProtocol.cReqGetItemDesp)
    msg:writeInt(typeid)
    msg:writeString(itemName)
    NetworkCenter:sendMsg(msg)
end

function NetClient:setExtendState(ext_name,state)
    self.mExtendState[ext_name]=state
    self:dispatchEvent({name=Notify.EVENT_GUI_STATE})
end

function NetClient:CountDownFinish()
    local msg=BuildBA(NetProtocol.cCountDownFinish)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ChangeAttackMode(attack_mode)
    local msg=BuildBA(NetProtocol.cReqChangeAttackMode)
    msg:writeInt(attack_mode)
    NetworkCenter:sendMsg(msg)
end

function NetClient:CreateGroup(flags)
    local msg=BuildBA(NetProtocol.cReqCreateGroup)
    msg:writeInt(flags)
    NetworkCenter:sendMsg(msg)
end

function NetClient:LeaveGroup()
    local msg=BuildBA(NetProtocol.cReqLeaveGroup)
    NetworkCenter:sendMsg(msg)
end

function NetClient:updateGroupPickUpMode(mode)
    local msg=BuildBA(NetProtocol.cReqGroupPickMode)
    msg:writeInt(mode)
    NetworkCenter:sendMsg(msg)
end

function NetClient:PickUp(itemid)
    local msg=BuildBA(NetProtocol.cReqPickUp)
    msg:writeUInt(itemid)
    NetworkCenter:sendMsg(msg)
end

function NetClient:FriendChange(name,title)
    local msg=BuildBA(NetProtocol.cReqFriendChange)
    msg:writeString(name)
    msg:writeInt(title)
    NetworkCenter:sendMsg(msg)
end

function NetClient:FriendFresh2()
    local msg=BuildBA(NetProtocol.cReqFriendFresh2)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ListGuild(tag)
    local msg=BuildBA(NetProtocol.cReqListGuild)
    msg:writeInt(tag)
    NetworkCenter:sendMsg(msg)
end

function NetClient:GetGuildInfo(guild_name,flags)
    local msg = BuildBA(NetProtocol.cReqGetGuildInfo)
    msg:writeString(guild_name)
    msg:writeInt(flags)
    NetworkCenter:sendMsg(msg)
end

function NetClient:SetGuildInfo(guild_name,desp,notice)

    local o=string.find(guild_name,"[\"'<>, \n\t]")
    if o and o>0 then
        self:alertLocalMsg("名称中包含非法字符！","alert")
        return
    end

    local o=string.find(desp,"[\"'<>, \n\t]")
    if o and o>0 then
        self:alertLocalMsg("名称中包含非法字符！","alert")
        return
    end

    local o=string.find(notice,"[\"'<>, \n\t]")
    if o and o>0 then
        self:alertLocalMsg("名称中包含非法字符！","alert")
        return
    end

    local msg = BuildBA(NetProtocol.cReqSetGuildInfo)
    msg:writeString(guild_name)
    msg:writeString(desp)
    msg:writeString(notice)
    NetworkCenter:sendMsg(msg)
end

function NetClient:CreateGuild(guild_name,flags)

    local o=string.find(guild_name,"[\"'<>, \n\t]")
    if o and o>0 then
        self:alertLocalMsg("名称中包含非法字符！","alert")
        return
    end

    local msg = BuildBA(NetProtocol.cReqCreateGuild)
    msg:writeString(guild_name)
    msg:writeInt(flags)
    NetworkCenter:sendMsg(msg)
end

function NetClient:JoinGuild(guild_name,flags)
    local msg = BuildBA(NetProtocol.cReqJoinGuild)
    msg:writeString(guild_name)
    msg:writeInt(flags)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ListGuildMember(guild_name,list_type)
    local msg = BuildBA(NetProtocol.cReqListGuildMember)
    msg:writeString(guild_name)
    msg:writeInt(list_type)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ChangeGuildMemberTitle(guild_name,nick_name,dir)
    local msg = BuildBA(NetProtocol.cReqChangeGuildMemberTitle)
    msg:writeString(guild_name)
    msg:writeString(nick_name)
    msg:writeInt(dir)
    NetworkCenter:sendMsg(msg)
end

function NetClient:LeaveGuild(guild_name)
    local msg = BuildBA(NetProtocol.cReqLeaveGuild)
    msg:writeString(guild_name)
    if self.mCharacter.num_enter > 0 then
        self.mCharacter.num_enter = self.mCharacter.num_enter - 1
    end
    NetworkCenter:sendMsg(msg)
end

function NetClient:learnSkill(skillid, position, typeid)
    local msg = BuildBA(NetProtocol.Client_GS_LearnSkill_Req)
    msg:writeInt(skillid)
    msg:writeInt(position)
    msg:writeInt(typeid)
    NetworkCenter:sendMsg(msg)
end

function NetClient:reqListItem(beginpos, endpos)
    local msg = BuildBA(NetProtocol.Client_GS_ListItemData_Req)
    msg:writeInt(beginpos)
    msg:writeInt(endpos)
    NetworkCenter:sendMsg(msg)
end

function NetClient:CheckPlayerEquip( strName )
    print("strName %s",strName)
    self.mOthersItems = {}
    self.other_equip_save = "loaded"
    self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str="panel_otherPlayerEquip", pdata = { playerName = strName } })
    self:InfoPlayer(strName)
end

function NetClient:check_better_item(position)
    local ni = self:getNetItem(position)
    local MainAvatar = CCGhostManager:getMainAvatar()
    if ni then
        if ni and ni.mTypeID then
            local item_define = self:getItemDefByID(ni.mTypeID)
            if item_define then
                if item_define.mNeedParam > game.getRoleLevel() then
                    return
                end
                local better = true

                for i,v in pairs(self.mItems) do
                    if v.position < 0 then
                        if v.mTypeID and math.floor(v.mTypeID/10000) == math.floor(ni.mTypeID /10000) then
                            local id = self:getItemDefByID(v.mTypeID);
                            if id then
                                if id.mNeedType == item_define.mNeedType then
                                    if id.mNeedParam > item_define.mNeedParam then
                                        better = false
                                    end
                                elseif id.mNeedType > item_define.mNeedType then
                                    better = false
                                end
                            end
                        end
                    end
                end

--                dump(better)
                if better then
--                    自动穿翅膀注释掉
--                    if item_define.mTypeID >= 120001 and item_define.mTypeID < 130000 then
--
--                        self:BagUseItem(position,item_define.mTypeID);
--                        return;
--                    end

                    if self.isEnterGame then self:dispatchEvent({name=Notify.EVENT_BETTER_ITEM, typeID = item_define.mTypeID, position = position, }) end
                end
            end
        end
    end
end

function NetClient:ReqBossOwner(bossid)
    local msg = BuildBA(NetProtocol.cReqBossOwner)
    msg:writeInt(bossid)
    NetworkCenter:sendMsg(msg)
end

function NetClient:InfoPlayer( player_name )
    local msg = BuildBA(NetProtocol.cReqInfoPlayer)
    self.m_PlayerEquip = {}
    self.other_avatar_save = "loaded"
    msg:writeString(player_name)
    msg:writeInt(0)--flag
    NetworkCenter:sendMsg(msg)
end

function NetClient:GetChartInfo(chart_type,page)
    local msg = BuildBA(NetProtocol.cReqGetChartInfo)
    msg:writeInt(chart_type)
    msg:writeInt(page-1)
    NetworkCenter:sendMsg(msg)
end

function NetClient:StartCollect(id)
    if not self.m_bCollecting then
        self.m_bReqCollect = true
        local msg = BuildBA(NetProtocol.cReqCollectStart)
        msg:writeInt(id)
        NetworkCenter:sendMsg(msg)
    end
end

function NetClient:ReqCarryShop(page)
    local page = page or 1
    local msg = BuildBA(NetProtocol.cReqCarryShop)
    msg:writeInt(page)
    NetworkCenter:sendMsg(msg)
end

function NetClient:VcoinShopList(shop_id,flags)
    local msg = BuildBA(NetProtocol.cReqVcoinShopList)
    msg:writeInt(shop_id)
    msg:writeInt(flags)
    NetworkCenter:sendMsg(msg)
end

function NetClient:NPCSell(npc_id,pos,type_id,number,flag)
    local msg = BuildBA(NetProtocol.cReqNPCSell)
    msg:writeUInt(npc_id)
    msg:writeInt(pos)
    msg:writeInt(type_id)
    msg:writeInt(number)
    msg:writeInt(flag)
    NetworkCenter:sendMsg(msg)
end

function NetClient:NPCRepair(npc_id,pos,type_id,flag)
    local msg = BuildBA(NetProtocol.cReqNPCRepair)
    msg:writeInt(npc_id)
    msg:writeInt(pos)
    msg:writeInt(type_id)
    msg:writeInt(flag)
    NetworkCenter:sendMsg(msg)
end

function NetClient:UndressItem(position)
    local msg = BuildBA(NetProtocol.cReqUndressItem)
    msg:writeInt(position)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ItemPositionExchange(from,to)
    local msg = BuildBA(NetProtocol.cReqItemPositionExchange)
    msg:writeInt(from)
    msg:writeInt(to)
    msg:writeInt(0)--flag
    NetworkCenter:sendMsg(msg)
end

function NetClient:TradeAddItem(pos,type_id)
    local msg = BuildBA(NetProtocol.cReqTradeAddItem)
    msg:writeInt(pos)
    msg:writeInt(type_id)
    NetworkCenter:sendMsg(msg)
end

function NetClient:BagUseItem(position,type_id,usenum)
    local msg = BuildBA(NetProtocol.cReqBagUseItem)
    msg:writeInt(position)
    msg:writeInt(type_id)
    self.mUseItemSendTag = self.mUseItemSendTag + 1
    msg:writeInt(self.mUseItemSendTag)
    msg:writeInt(usenum or 1)--usenum
    NetworkCenter:sendMsg(msg)
    --喝药音效
end

function NetClient:OneKeyDress(list)
    if not list or #list == 0 then return end

    local msg = BuildBA(NetProtocol.Client_GS_OneKeyDressItem_Req)
    msg:writeInt(#list)
    for k, v in ipairs(list) do
        msg:writeInt(v.position)
        msg:writeInt(v.typeID)
    end
    self.mUseItemSendTag = self.mUseItemSendTag + 1
    msg:writeInt(self.mUseItemSendTag)
    NetworkCenter:sendMsg(msg)
end

function NetClient:AddBagSlot()
    -- local msg = BuildBA(NetProtocol.cReqAddBagSlot)
    -- NetworkCenter:sendMsg(msg)
end

function NetClient:AddDepotSlot()
    local msg = BuildBA(NetProtocol.cReqAddDepotSlot)
    NetworkCenter:sendMsg(msg)
end

function NetClient:DropItem(pos,type_id,number)
    local msg = BuildBA(NetProtocol.cReqDestroyItem)
    msg:writeInt(pos)
    msg:writeInt(type_id)
    msg:writeInt(number)
    NetworkCenter:sendMsg(msg)
end

function NetClient:SortItem(flag)
    local msg = BuildBA(NetProtocol.cReqSortItem)
    msg:writeInt(flag)
    NetworkCenter:sendMsg(msg)
end

function NetClient:PushLuaTable(type,table)
    local msg = BuildBA(NetProtocol.cReqPushLuaTable)
    msg:writeString(type)
    msg:writeString(table)
    NetworkCenter:sendMsg(msg)
end

function NetClient:DirectFly(fly_id)
    local msg = BuildBA(NetProtocol.cReqDirectFly)
    msg:writeInt(fly_id)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ServerScript(param)
    local msg = BuildBA(NetProtocol.cReqServerScript)
    msg:writeString(param)
    NetworkCenter:sendMsg(msg)
end

function NetClient:NpcTalk(npcid,param)
    self.m_nNpcTalkId = 0
    self.m_strNpcTalkMsg = ""

    local msg = BuildBA(NetProtocol.cReqNPCTalk)
    msg:writeUInt(npcid)
    msg:writeString(param)
    NetworkCenter:sendMsg(msg)
end

function NetClient:PlayerTalk(seed,param)
    local msg = BuildBA(NetProtocol.cReqPlayerTalk)
    msg:writeInt(seed)
    msg:writeString(param)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ItemTalk(itemid,seed,param)
    local msg = BuildBA(NetProtocol.cReqItemTalk)
    msg:writeInt(itemid)
    msg:writeInt(seed)
    msg:writeString(param)
    NetworkCenter:sendMsg(msg)
end

function NetClient:NormalChat(msgstr)
    local msg = BuildBA(NetProtocol.cReqNormalChat)
    if string.len(msgstr) > 511 then
        msgstr = string.sub(msgstr,0,511)
    end
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:MapChat(msgstr)
    local msg = BuildBA(NetProtocol.cReqMapChat)
    if string.len(msgstr) > 511 then
        msgstr = string.sub(msgstr,0,511)
    end
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:PrivateChat(target,msgstr)
    local msg = BuildBA(NetProtocol.cReqPrivateChat)
    if string.len(msgstr) > 511 then
        msgstr = string.sub(msgstr,0,511)
    end
    msg:writeString(target)
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:WorldChat(msgstr)
    local msg = BuildBA(NetProtocol.cReqWorldChat)
    if string.len(msgstr) > 511 then
        msgstr = string.sub(msgstr,0,511)
    end
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:HornChat(msgstr)
    local msg = BuildBA(NetProtocol.cReqHornChat)
    if string.len(msgstr) > 256 then
        msgstr = string.sub(msgstr,0,255)
    end
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:GuildChat(msgstr)
    local msg = BuildBA(NetProtocol.cReqGuildChat)
    if string.len(msgstr) > 511 then
        msgstr = string.sub(msgstr,0,511)
    end
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:GroupChat(msgstr)
    local msg = BuildBA(NetProtocol.cReqGroupChat)
    if string.len(msgstr) > 511 then
        msgstr = string.sub(msgstr,0,511)
    end
    msg:writeString(msgstr)
    NetworkCenter:sendMsg(msg)
end

function NetClient:EquipExchangeUpgrade(posFrom,posTo,posAdd,pay_type)
    local msg = BuildBA(NetProtocol.cReqEquipExchangeUpgrade)
    msg:writeInt(posFrom)
    msg:writeInt(posTo)
    msg:writeInt(posAdd)
    msg:writeInt(pay_type)
    NetworkCenter:sendMsg(msg)
end

function NetClient:EquipReRandAdd(posEquip,posAdd)
    local msg = BuildBA(NetProtocol.cReqEquipReRandAdd)
    msg:writeInt(posEquip)
    msg:writeInt(posAdd)
    NetworkCenter:sendMsg(msg)
end

function NetClient:SplitItem(pos,id,num)
    local msg = BuildBA(NetProtocol.cReqSplitItem)
    msg:writeInt(id)
    msg:writeInt(pos)
    msg:writeInt(num)
    NetworkCenter:sendMsg(msg)
end

function NetClient:UpdateTicket()
    local msg = BuildBA(NetProtocol.cReqUpdateTicket)
    NetworkCenter:sendMsg(msg)
end

function NetClient:NpcBuy(npcid,page,pos,good_id,type_id,num)
    local msg = BuildBA(NetProtocol.cReqNPCBuy)
    msg:writeUInt(npcid)
    msg:writeInt(page)
    msg:writeInt(pos)
    msg:writeInt(good_id)
    msg:writeInt(type_id)
    msg:writeInt(num)
    NetworkCenter:sendMsg(msg)
end

function NetClient:VcoinShopBuy(page,pos,good_id,type_id,num)
    local msg = BuildBA(NetProtocol.cReqNPCBuy)
    msg:writeUInt(self.mVcoinShopNpcID)
    msg:writeInt(page)
    msg:writeInt(pos)
    msg:writeInt(good_id)
    msg:writeInt(type_id)
    msg:writeInt(num)
    NetworkCenter:sendMsg(msg)
end

function NetClient:InviteGroup(name)
    if not self.mCharacter.mGroupID then
        self:CreateGroup(0)
    end
    local msg = BuildBA(NetProtocol.cReqInviteGroup)
    msg:writeString(name)
    NetworkCenter:sendMsg(msg)
end

function NetClient:JoinGroup(group_id)
    local msg = BuildBA(NetProtocol.cReqJoinGroup)
    msg:writeInt(group_id)
    --msg:writeByte("")--mode
    msg:writeString("")--password
    NetworkCenter:sendMsg(msg)
end

function NetClient:getGroupIDByName(name)
    for g_id,data in pairs(self.nearByGroupInfo) do
        if data.group_leader == name then
            return data.group_id
        end
    end
    return nil
end

function NetClient:isPlayerMyInGroup(pname)
    for i = 1, #self.mGroupMembers do
        if self.mGroupMembers[i].name == pname then
            return true
        end
    end
end

function NetClient:getNearGroupMemberByID(gid)
    if not self.nearByGroupInfo[gid] then return nil end

    return self.nearByGroupInfo[gid].group_members
end

function NetClient:GroupKickMember(name)
    local msg = BuildBA(NetProtocol.cReqGroupKickMember)
    msg:writeString(name)
    NetworkCenter:sendMsg(msg)
end

function NetClient:GroupSetLeader(name)
    local msg = BuildBA(NetProtocol.cReqGroupSetLeader)
    msg:writeString(name)
    NetworkCenter:sendMsg(msg)
end

function NetClient:TradeInvite(name)
    local msg = BuildBA(NetProtocol.cReqTradeInvite)
    msg:writeString(name)
    NetworkCenter:sendMsg(msg)
end

function NetClient:AgreeTradeInvite(inviter)
    local msg = BuildBA(NetProtocol.cReqAgreeTradeInvite)
    msg:writeString(inviter)
    NetworkCenter:sendMsg(msg)
end

function NetClient:TradeSubmit()
    local msg = BuildBA(NetProtocol.cReqTradeSubmit)
    NetworkCenter:sendMsg(msg)
end

function NetClient:CloseTrade()
    local msg = BuildBA(NetProtocol.cReqCloseTrade)
    NetworkCenter:sendMsg(msg)
end

function NetClient:TradeAddVcoin(num)
    local msg = BuildBA(NetProtocol.cReqTradeAddVcoin)
    msg:writeInt(num)
    NetworkCenter:sendMsg(msg)
end

function NetClient:TradeAddGameMoney(num)
    local msg = BuildBA(NetProtocol.cReqTradeAddGameMoney)
    msg:writeInt(num)
    NetworkCenter:sendMsg(msg)
end

function NetClient:AgreeInviteGroup(name,id)
    local msg = BuildBA(NetProtocol.cReqAgreeInviteGroup)
    msg:writeString(name)
    msg:writeInt(id)
    NetworkCenter:sendMsg(msg)
end

function NetClient:AgreeJoinGroup(name)
    local msg = BuildBA(NetProtocol.cReqAgreeJoinGroup)
    msg:writeString(name)
    NetworkCenter:sendMsg(msg)
end

function NetClient:DestoryItem(pos,id)
    local msg = BuildBA(NetProtocol.cReqDestoryItem)
    msg:writeInt(pos)
    msg:writeInt(id)
    NetworkCenter:sendMsg(msg)
end

function NetClient:NpcShop(npc_id,page)

    local msg = BuildBA(NetProtocol.cReqNPCShop)
    msg:writeUInt(npc_id)
    msg:writeUInt(page)
    NetworkCenter:sendMsg(msg)
end

function NetClient:SaveShortcut()
    local msg = BuildBA(NetProtocol.cReqSaveShortcut)
    local numSkill = 0
    for k, v in pairs(self.mShortCut) do
        if v.type then
            numSkill = numSkill + 1
        end
    end
    msg:writeInt(numSkill)
    for k, v in pairs(self.mShortCut) do
        if v.type then
            msg:writeInt(v.cut_id)
            msg:writeInt(v.type)
            msg:writeInt(v.param)
        end
    end
    NetworkCenter:sendMsg(msg)
end

function NetClient:ChangeMount()
    local msg = BuildBA(NetProtocol.cReqChangeMount)
    msg:writeInt(0)--show
    NetworkCenter:sendMsg(msg)
end
function NetClient:freshHPMP()
    local msg = BuildBA(NetProtocol.cReqFreshHPMP)
    NetworkCenter:sendMsg(msg)
end

function NetClient:Relive(type)
    local msg = BuildBA(NetProtocol.cReqRelive)
    msg:writeInt(type)
    NetworkCenter:sendMsg(msg)
end

function NetClient:refreshGift()
    local msg = BuildBA(NetProtocol.cReqFreshGift)
    NetworkCenter:sendMsg(msg)
end

function NetClient:reqMailList()
    local msg = BuildBA(NetProtocol.cReqMailList)
    NetworkCenter:sendMsg(msg)
end

function NetClient:openMail(mailID)
    local msg = BuildBA(NetProtocol.cReqOpenMail)
    msg:writeString(mailID)
    NetworkCenter:sendMsg(msg)
end

function NetClient:receiveMailItems(mailIDs)
    if #mailIDs == 0 then return end
    local msg = BuildBA(NetProtocol.cReqReceiveMailItems)
    msg:writeInt(#mailIDs)
    for i=1, #mailIDs do
        msg:writeString(mailIDs[i])
    end
    NetworkCenter:sendMsg(msg)
end

function NetClient:deleteMails(flag,mailIDs)
    if #mailIDs == 0 then return end
    local msg = BuildBA(NetProtocol.cReDeleteMail)
    msg:writeInt(flag)
    msg:writeInt(#mailIDs)
    for i=1, #mailIDs do
        msg:writeString(mailIDs[i])
    end
    NetworkCenter:sendMsg(msg)
end

function NetClient:sendFangchengmi(id, name, check_id)
    local msg = BuildBA(NetProtocol.cReqUpdateChinaLimit)
    msg:writeString(id)
    msg:writeString(name)
    msg:writeInt(check_id)
    NetworkCenter:sendMsg(msg)
end

function NetClient:GuildUnion(guild_name,opcode)
    local msg = BuildBA(NetProtocol.cReqGuildUnion)
    msg:writeString(guild_name)
    msg:writeInt(opcode)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ListGuildUnion(listtype)
    local msg = BuildBA(NetProtocol.cReqGuildUnionList)
    msg:writeInt(listtype)
    NetworkCenter:sendMsg(msg)
end

function NetClient:GuildWar(guild_name,opcode)
    local msg = BuildBA(NetProtocol.cReqGuildWar)
    msg:writeString(guild_name)
    msg:writeInt(opcode)
    NetworkCenter:sendMsg(msg)
end

function NetClient:ListGuildWar()
    local msg = BuildBA(NetProtocol.cReqGuildWarList)
    NetworkCenter:sendMsg(msg)
end

----------------------------------工具方法--------------------------------

function NetClient:getStatusDefByID(statusid, lv)
    return StatusDefData[tostring(statusid*10000+lv)]
--    return self.mStatusDesp[statusid*100+lv]
end

function NetClient:getSkillDefByID(skillid)
    if not skillid then return end
--    if self.m_skillsDesp[skillid] then
--        return self.m_skillsDesp[skillid]
--    else
----        self:GetItemDesp(typeid,"")
--    end

    return SkillDescData[skillid]
end

function NetClient:getSkillCDGroup(skillid)
    if not skillid then return 0 end
    if not game.isLiehuoSkill(skillid) and not game.isZsChongZhuangSkill(skillid) then return 0 end

    local def = SkillDescData[skillid]
    if def then
        return def.mCDGroup
    end
    return 0
end

function NetClient:getItemDefByID(typeid)
    if not typeid then return end
    return ItemDefData[tostring(typeid)]
end

function NetClient:getFighterDefByID(mid)
    return FighterDefData[tostring(mid)]
end

function NetClient:getItemDefByName(name)
    for itemid,item in pairs(ItemDefData) do
        if item.mName == name then
            return item
        end
    end
    return nil
end

function NetClient:dispatchChangeAlertMsg(str1,str2,change,itemid)
    if change ~= 0 then
        if change > 0 then
            self:alertLocalMsg(str1.."<font color='"..Const.COLOR_GREEN_1_STR.."'>"..change.."</font>","leftbottom")
        else
            self:alertLocalMsg(str2.."<font color='"..Const.COLOR_GREEN_1_STR.."'>"..(-change).."</font>","leftbottom")
        end
    end
end

function NetClient:alertLocalMsg(msg,type,itemid)
    if not type then type="alert" end
    if type == "confirm" then
        print("--TODO error == 这个参数不再使用", msg)
        return
    end
    self:dispatchEvent({name=Notify.EVENT_ADD_ALERT,msg=msg,type=type,itemid=itemid})
end

function NetClient:getNetItem(pos)
    if self.mItems[pos] then
        return self.mItems[pos]
    else
        return nil
    end
end

function NetClient:getGuildDepotItem(pos)
    if self.mGuildDepotItems[pos] then
        return self.mGuildDepotItems[pos]
    else
        return nil
    end
end

function NetClient:getNetItemNumberById(typeid)
    local num = 0
    for i,v in pairs(self.mItems) do
        if v.mTypeID == typeid then
            num = num + v.mNumber
        end
    end
    return num
end

function NetClient:getBagItemNumberById(typeid)
    local num = 0
    for i,v in pairs(self.mItems) do
        if v.mTypeID == typeid and game.IsPosInBag(i) then
            num = num + v.mNumber
        end
    end
    return num
end

function NetClient:getItemPosById(typeid)
    local posTab = {}
    for i,v in pairs(self.mItems) do
        if v.mTypeID == typeid then
            table.insert(posTab,i)
        end
    end
    return posTab
end

function NetClient:getItemBagPosById(typeid)
    for i,v in pairs(self.mItems) do
        if v.mTypeID == typeid and game.IsPosInBag(i)  then
            return i
        end
    end
    return nil
end

function NetClient:getBagCount()
    local count = 0
    for i,v in pairs(self.mItems) do
        if game.IsPosInBag(i)  then
            count = count + 1
        end
    end
    return count
end

function NetClient:getDepotCount()
    local count = 0
    for i,v in pairs(self.mItems) do
        if game.IsPosInDepot(i)  then
            count = count + 1
        end
    end
    return count
end

function NetClient:getLotteryCount()
    local count = 0
    for i,v in pairs(self.mItems) do
        if game.IsPosInLottery(i)  then
            count = count + 1
        end
    end
    return count
end

function NetClient:getServerParam(index)
    if self.mParam[MainRole.mID][index] then
        return self.mParam[MainRole.mID][index]
    end
    return 0
end

function NetClient:getIntServerParam(index)
    return checkint(self:getServerParam(index))
end

function NetClient:isBagFull()
    return self:getBagCount() >= Const.ITEM_BAG_SIZE + self.mBagSlotAdd
end

function NetClient:isDepotFull()
    return self:getDepotCount() >= Const.ITEM_DEPOT_SIZE + self.mDepotSlotAdd
end

function NetClient:isDepotLotteryFull()
    return self:getLotteryCount() >= Const.ITEM_LOTTERYSIZE
end

function NetClient:getBagBlackNumber()
    local max = Const.ITEM_BAG_SIZE + self.mBagSlotAdd
    local cur =  self:getBagCount()
    return math.max(max-cur, 0)
end

function NetClient:findEmptyPositionInDepot()
    for pos = Const.ITEM_DEPOT_BEGIN, Const.ITEM_DEPOT_BEGIN + Const.ITEM_DEPOT_SIZE + self.mDepotSlotAdd do
        if not self.mItems[pos] or (self.mItems[pos] and (self.mItems[pos].mTypeID <= 0 or self.mItems[pos].mNumber <= 0)) then
            return pos
        end
    end
end

function NetClient:findEmptyPositionInBag()
    for pos = Const.ITEM_BAG_BEGIN, Const.ITEM_BAG_BEGIN + Const.ITEM_BAG_SIZE + self.mBagSlotAdd do
        if not self.mItems[pos] or (self.mItems[pos] and (self.mItems[pos].mTypeID <= 0 or self.mItems[pos].mNumber <= 0)) then
            return pos
        end
    end
end

function NetClient:addToMsgHistory(netChat)
    if not self.showAlert then return end
    netChat.m_strMsg = game.tranFaceShow(netChat.m_strMsg)
    table.insert(self.mChatHistroy,netChat)
    if #self.mChatHistroy > 200 then
        table.remove(self.mChatHistroy,1)
    end
    self:dispatchEvent({name = Notify.EVENT_CHAT_MSG})
end

function NetClient:addToMsgMemory(chatmsg)
    if #self.mChatMemory >= 10 then
        for i=1,10 do
            if not self.mChatMemory[i].locked then
                table.remove(self.mChatMemory,i)
                break
            end
        end
    end
    local tempMem = {}
    tempMem.locked = false
    tempMem.msg = chatmsg
    table.insert(self.mChatMemory,tempMem)
end

function NetClient:privateChatTo(name)
    if name == self.mCharacter.mName then
        return
    end
    self.m_strPrivateChatTarget = name
    self:dispatchEvent({name = Notify.EVENT_WHISPER})
end

function NetClient:getGuildByName(pName)
    for i=1,#self.mGuildList do
        if self.mGuildList[i].mName == pName then
            return self.mGuildList[i]
        end
    end
    return nil
end

function NetClient:resetGroupApplyAndInVite()
    if not self.mCharacter.mGroupID or self.mCharacter.mGroupID == 0 then
        self.mGroupInvite = {}
    else
        self.mGroupApplyers = {}
    end
    self:dispatchEvent({name = Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE,})
end

function NetClient:removeGroupApply(name)
    --self.mGroupApplyers[name] = nil
    if #self.mGroupApplyers > 0 then
        for i = 1,#self.mGroupApplyers do 
            if self.mGroupApplyers[i].name == name then
                table.remove(self.mGroupApplyers,i)
            end
        end
    end
    self:dispatchEvent({name = Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE,})
end

function NetClient:removeGroupInvite(groupid)
    --self.mGroupInvite[groupid] = nil
    if #self.mGroupInvite > 0 then
        for i = 1,#self.mGroupInvite do 
            if self.mGroupInvite[i].group_id == groupid then
                table.remove(self.mGroupInvite,i)
            end
        end
    end
    self:dispatchEvent({name = Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE,})
end

function NetClient:updateSkillShortCut(skill_type)
    if not self.mInitShortCut then return end
    if self:haveSetSkillShortCutPos(skill_type) then return end
    if game.IsPassiveSkill( skill_type ) then return end
    if not game.IsAutoSetSkill( skill_type ) then return end

    for pos = 1, 8 do
        if not self.mShortCut[pos] then
            local cutinfo = {}
            cutinfo.cut_id = pos
            cutinfo.type = Const.ShortCutType.Skill
            cutinfo.param = skill_type
            cutinfo.itemnum = 1
            self.mShortCut[pos] = cutinfo
            self:SaveShortcut()
--            self:dispatchEvent({name=Notify.EVENT_SHORTCUT_CHANGE}) --动画播完再更新
            return pos
        end
    end
end

function NetClient:haveSetSkillShortCutPos(skill_type)
    for cut_id, cutinfo in pairs(self.mShortCut) do
        if cutinfo.type == Const.ShortCutType.Skill and cutinfo.param == skill_type then
            return true
        end
    end
    return false
end

----------------------------------system----------------------------------

----------------------------------net---------------------------------------

function NetClient:onConnect()
    print("onConnected session===>>", game.mSessionID)
--    if Const.test_mode then
    if game.mSessionID and game.mSessionID ~= "" then
        self:Authenticate(101,game.mSessionID,0,0)
    else
        print("session is envalid")
    end
--    end
end

function NetClient:onAuthenticate(result)
    print("onAuthenticate result=", result)
    if result == 100 then
        self:ListCharacter()
    else
        print("账号验证失败==>>",result)
        gameLogin.removeAllLoginPanel()
        if result == 105 then
            NetworkCenter:onConnetTimeOut()
            if MAIN_IS_IN_GAME then
                gameLogin.popErrorDialog({
                    errormsg="登录超时，请重新登录",
                    alertTitle="重新登录",
                    onClickConfirm=function()
                        game.ExitToRelogin(true)
                    end
                })
            else
                gameLogin.popErrorDialog({
                    errormsg="登录超时，请重新登录",
                })
            end
        else
            if MAIN_IS_IN_GAME then
                gameLogin.popErrorDialog({
                    errormsg="账号验证失败:"..result,
                    alertTitle="重新登录",
                    onClickConfirm=function()
                        game.ExitToRelogin(true)
                    end
                })
            else
                gameLogin.popErrorDialog({errormsg="账号验证失败:"..result})
            end
        end
    end
end

--------------------------------------------

function NetClient:itemChange(newItem, show_flags)
    local show_flags = show_flags or 0
    if not newItem then return end
    local oldType
    if self.mItems[newItem.position] ~= nil then
        oldType=self.mItems[newItem.position].mTypeID
        self.mItems[newItem.position] = nil
    end
    if newItem.mTypeID > 0 and newItem.position > -999 then
        self.mItems[newItem.position] = newItem
       -- print("show_flags========",  show_flags)
        if show_flags ~= 0 and show_flags ~= 100 and show_flags ~= 1002 and game.IsPosInBag(newItem.position) and game.IsEquipment(newItem.mTypeID) then
            self:check_better_item(newItem.position)
        end
    else
        self.mItems[newItem.position] = nil
    end
    self:dispatchEvent({name=Notify.EVENT_ITEM_CHANGE,pos=newItem.position,oldType=oldType,newType=newItem.mTypeID})

    if newItem.mTypeID == 0 and oldType and game.IsMedicine(oldType) then
        MainRole.autoBuyDrug()
    end
    --[[
    if newItem.mTypeID == Const.RELIVE_USE_ITEM.id then
        self:dispatchEvent({name=Notify.EVENT_RELIVE_USEITEM,id=newItem.mTypeID})
    end
    ]]
    local itemDef = self:getItemDefByID(newItem.mTypeID)
    if itemDef and newItem.mTypeID > 0 and show_flags ~= 0 and show_flags ~= 100 and show_flags ~= 1002 then
        if game.IsMedicine( newItem.mTypeID ) then
--            self:alertLocalMsg("获得："..itemDef.mName, "right", newItem.mTypeID)
        elseif game.IsPosInBag(newItem.position) then
--            self:alertLocalMsg("获得："..itemDef.mName, "right", newItem.mTypeID)
            self:dispatchEvent({name=Notify.EVENT_SHOW_GET_ITEM_EFFECT, typeid = newItem.mTypeID})
            if itemDef.mOneKeyuse and itemDef.mOneKeyuse > 0 and self:checkItemUseLimit(newItem.mTypeID) then
                self:dispatchEvent({name=Notify.EVENT_PROP_USE_ITEM, typeID = newItem.mTypeID,position=newItem.position})
            end
        end
    end
    if self.isEnterGame then
        UIRedPoint.handleChange({UIRedPoint.REDTYPE.SKILL})
        if (oldType and oldType == 15362) or (newItem and newItem.mTypeID == 15362) then
--            15362 副本卷轴
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.BOSS_PERSON})
        end
    end
end

function NetClient:checkItemUseLimit(itemid)
    for k, v in ipairs(self.mItemUseInfo) do
        if v.itemid == itemid then
            if v.used < v.total then
                return true
            end
            return false
        end
    end

    return true
end

function NetClient:notifyPanelData(ttype, tdata)
    --print("NetClient:notifyPanelData===========",ttype)
    local d = util.decode(tdata)
    if ttype == "player.GetMiniNpcReliveTime" then
        if self.mMapMonster[d.bossname] then
            self.mMapMonster[d.bossname].mReliveTime = d.rt
            self:dispatchEvent({name=Notify.EVENT_BOSS_FRESH, bossname=d.bossname})
        end
        return
    elseif ttype == "taskdone" then
        if d.actionid then
            if d.actionid == "need_bag_slot" then
                self.mAutoTaskDone = false
                local need_slot_num = checkint(d.param)
                self:alertLocalMsg("对不起,您的背包空格不足"..need_slot_num.."格,无法领取任务奖励!", "alert")
            end
        end
        return
    elseif ttype == "skillup" then
        -- 技能升级相关数据
--        self.mSkillUpInfo[tonumber(d.skillid)] = d.info
    elseif ttype == "bag" then
        if d.actionid then
            if d.actionid == "load_recycle_setting" then
                self.mHuishouSetting = string.split(d.rs, ",")
            elseif d.actionid == "recyle_success" then
--                for k, v in ipairs(d.rems) do 如果给了装备精魄，这里会覆盖掉。
--                    local newItem = { position = v.pos, mTypeID = 0, mNumber =0 }
--                    self:itemChange(newItem, 0)
--                end
            elseif d.actionid == "add_bag_result" then
                self:alertLocalMsg("成功开启"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,d.num).."个格子,获得经验*"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,d.exp), "alert")
            elseif d.actionid == "carryshop_num" and d.panelid == "carryshop" then
                self.mCarryShopNum = d.param or {}
                return
            end
        end
    elseif ttype == "guideprompt" then
        -- 新功能开启
        if d.actionid then
            if d.actionid == "openstatus" then
                self.mOpenFunc = d.params
                self:dispatchEvent({name = Notify.EVENT_OPEN_SYSTEM})
            elseif d.actionid == "opennew" then
                local pids = {}
                for _, v in ipairs(d.params) do
                    table.insert(self.mOpenFunc, v.funcId)
                    table.insert(pids, v.funcId)
                end
                if #pids > 0 and self.isEnterGame then
--                    self:dispatchEvent({name = Notify.EVENT_OPEN_NEW, type = Const.OPEN_NEW.FUNC, pids = pids})
                end
                if #pids > 0 then
                    UIButtonGuide.handleOpenNewFunc(pids[#pids])
                    self:dispatchEvent({name = Notify.EVENT_OPEN_SYSTEM})
                end
                return
            elseif d.actionid == "levelprompt" then
                self.mPromptInfo = d.params
            end
            self:dispatchEvent({name = Notify.EVENT_GUIDE_PROMPT, type=ttype, data=tdata})
        end
        return
    elseif ttype == "yuanshenxiuwei" then
        -- 元神
        if d.actionid then
            if d.actionid == "queryyuansheng" then
                self.mYuanshenInfo.curlevel = d.curlevel
                self.mYuanshenInfo.yuansheng = d.yuansheng--元神修为
                self.mYuanshenInfo.nextlevel = d.nextlevel
            elseif d.actionid == "query" then
                self.mYuanshenInfo.curlevel = d.curlevel
                self.mYuanshenInfo.yuansheng = d.yuansheng--元神修为
                self.mYuanshenInfo.fromdesp = d.fromdesp
                self.mYuanshenInfo.needitems = d.needitems
                self.mYuanshenInfo.nextlevel = d.nextlevel
            end
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.YUANSHEN})
            self:dispatchEvent({name = Notify.EVENT_YUANSHEN_CHANGE, type=ttype, data=tdata})
            return
        end
    elseif ttype == "armour" then
        -- 神炉
        if d.actionid then
            if d.actionid == "query_total" then
                self.mShenluInfo = d.list
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.JIANJIA,UIRedPoint.REDTYPE.BAOSHI,UIRedPoint.REDTYPE.DUNPAI,UIRedPoint.REDTYPE.ANQI,UIRedPoint.REDTYPE.YUXI})
            elseif d.actionid == "buqiprice" then
                self.mShenluPrice = d.params
            end
        end
    elseif ttype == "rhuodong" then
        if d.actionid and d.param then
            if d.actionid == "page" and d.param.pid then
                self.mActivityList[d.param.pid] = d.param.list
                self:dispatchEvent({name = Notify.EVENT_ACTIVITY_LIST_UPDATE, pid = d.param.pid })
                if d.param.pid == Const.ACTIVIY_INDEX_WORLD_BOSS then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.BOSS_WORLD})
                elseif d.param.pid == Const.ACTIVIY_INDEX_SINGLEBOSS then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.BOSS_PERSON})
                end
                return
            elseif d.actionid == "pagerestime" and d.param.pid then
                for k, pv in ipairs(d.param.list) do
                    if self.mActivityList[d.param.pid] then
                        for _, v in ipairs(self.mActivityList[d.param.pid]) do
                            if v.index == pv.index then
                                v.rest_time = pv.rest_time
                                v.awardflag = pv.awardflag
                                break
                            end
                        end
                    end
                end
                self:dispatchEvent({name = Notify.EVENT_ACTIVITY_TIEM_UPDATE, pid = d.param.pid })
                if d.param.pid == Const.ACTIVIY_INDEX_WORLD_BOSS then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.BOSS_WORLD})
                end
                return
            elseif d.actioinid == "titlelist" then
                self.mActivityTitleList = d.param
                self:dispatchEvent({name = Notify.EVENT_ACTIVITY_TITLE_LIST})
                return
            elseif d.actionid == "select" and d.param.pid then
                for k, v in ipairs(self.mActivityList[d.param.pid]) do
                    if v.index == d.param.index then
                        v.detail = d.param.info
                        v.detail.down = string.split(v.detail.down, ",")
                        self:dispatchEvent({name = Notify.EVENT_ACTIVITY_SELECT_UPDATE, info = v, pid = d.param.pid, index = checkint(v.index)})
                        return
                    end
                end
            end
        end
    elseif ttype == "wingtrain" then
        if d.actionid and d.param then
            if d.actionid == "querybase" then
                self.mWingInfo.baseInfo = d.param
            elseif d.actionid == "queryinfo" then
                --curexp:当前经验 curmount: 当前阶ID star: 当前星 curlevel:经验等级
                self.mWingInfo.info =  d.param
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.WING})
            end
        end
    elseif ttype == "ring" then
        if d.actionid and d.param then
            if d.actionid == "query_all_info" then
                self:sortRingList(d.param) -- 基本配置表
            elseif d.actionid == "ring_level" then
                self.mRingInfo.levelinfo = d.param -- 升阶表
                if self.mRingInfo.list then
                    UIRedPoint.handleChange({UIRedPoint.REDTYPE.RING})
                end   
            elseif d.actionid == "act_info" then
                self.mRingInfo.activeInfo = d.param -- 激活信息
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.RING})
            end

        end
    elseif ttype == "firstcharge" then
        if d.actionid and d.param then
            if d.actionid == "info" then
                self.mFirstchargeInfo.itemList = d.param.itemList or {}
                self.mFirstchargeInfo.flag = d.param.flag or 0
                self.mFirstchargeInfo.chongzi = d.param.congzi or 0
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.FIRST_CHARGE})
            end
        end
    elseif ttype == "topbtn" then
        if d.actionid and d.param then
            if d.actionid == "dataList" then
                self.mTopBtn = d.param
                self:dispatchEvent({name = Notify.EVENT_BUTTON_STATUS_CHANGE})
            end
        end
        return
    elseif ttype == "vitality" then
        if d.actionid and d.param then
            if d.actionid == "base_info" then
                self.mVitalityInfo.base = d.param
                self:dispatchEvent({name = Notify.EVENT_VITALITY_LIST})
            elseif d.actionid == "award_info" then
                self.mVitalityInfo.awardInfo = d.param
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.VITALITY})
                self:dispatchEvent({name = Notify.EVENT_VITALITY_AWARD_CHANGE})
            elseif d.actionid == "change_info" then
                if self.mVitalityInfo.base then
                    self.mVitalityInfo.base.vitality = d.param.vitality
                    for _, act in ipairs(self.mVitalityInfo.base.data) do
                        if act.idx == d.param.idx then
                            act.num = d.param.num
                            act.have_vita = d.param.have_vita
                            self:dispatchEvent({name = Notify.EVENT_VITALITY_CHANGE, changeindex=act.idx})
                            break
                        end
                    end
                end
            end
        end
        return
    elseif ttype == "actlist" then
        if d.actionid and d.param then
            if d.actionid == "actopen" then
                local opensetr = d.param or ""
                self.mDailyActOpenStr = opensetr
                game.showActOpenView()
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.DAILYACT})
            end
        end
    elseif ttype == "chuansong" then
        if d.actionid and d.param then
            if d.actionid == "yaodu_data" or d.actionid == "leishen_data" or d.actionid == "tongtian_data" or d.actionid == "yuanbao_data" or  d.actionid == "mobai_data"
                    or d.actionid == "moying_data" or d.actionid == "superbox_data" or d.actionid == "smzc_data"  or d.actionid == "shenwei_data" or d.actionid == "shengyu_data"
                    or d.actionid == "vipgj_data" then
                self.m_nNpcName = d.title
                self.m_strNpcTalkMsg = "@"..util.encode(d.param).."@"
                self.m_nTalkType = "player"
                self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str="panel_npctalk"})
                return
            end
        end
    elseif ttype == "smzhanchang" then
        if d.actionid and d.param then
            if d.actionid == "rank" then
                self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_smzc_rank", pdata=d.param.ranklist})
                return
            end
        end
    elseif ttype == "swmy" then
        if d.actionid and d.param then
            if d.actionid == "enter_yb" then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = d.param,
                    confirmTitle = "是", cancelTitle = "否",
                    confirmCallBack = function ()
                        self:PushLuaTable("swmy",util.encode({actionid = "enter_yb"}))
                    end
                }
                self:dispatchEvent(param)
            end
        end
    elseif ttype == "mmss" then
        if d.actionid and d.param then
            if d.actionid == "relive" then
                self.mReliveInfo = {max = d.param.relivenum,left = d.param.canrelivenum,time=d.param.relivetime}
            end
        end

    elseif ttype == "liquan" then
        self.mCharacter.mLiquan = checkint(d)
        self:dispatchEvent({name = Notify.EVENT_GAME_LIQUAN_CHANGE})
        return
    elseif ttype == "relive" then
        self:dispatchEvent({name = Notify.EVENT_LUA_PANEL_RELIVE,type=ttype, data=tdata})
        return
    elseif ttype == "cmessage" then
        if d.actionid and d.param then
--            print("cmessage", tdata)
            if d.actionid == "ybbz" then
                self:dispatchEvent({name = Notify.EVENT_YUANBAO_BUZU,data=d.param})
            end
        end
        return
    elseif ttye == "mail" then
        if d.actionid == "refresh" then
            self.mReqMailList = true
            return
        end
    elseif ttype == "mobai" then
        if d.actionid and d.param then
            if d.actionid == "addexp" then
                local addexp =  d.param.exp
                if d.param.alert then
                    if d.param.king then
                        self:alertLocalMsg("膜拜九五至尊["..game.make_str_with_color(Const.COLOR_GREEN_1_STR,d.param.king).."]获得经验:"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,addexp), "alert")
                    else
                        self:alertLocalMsg("膜拜九五至尊获得经验:"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,addexp),"alert")
                    end
                end
            end
        end
        return
    elseif ttype == "ybquickbuy" then
        if d.actionid and d.param then
            if d.actionid == "queryquickbuyitem" then
                -- 弹出快捷购买
                if #d.param.sellitems == 1 then
                    game.showQuickByPanel(d.param.sellitems[1])
                else
                    print("---TODO 多个道具的快捷购买面板")
                end
            end
        end
        return
    elseif ttype == "kingdom" then
        if d.actionid and d.param then
            if d.actionid == "jfawardflag" then
                self.mKingJFPoint = d.param.jf
                self.mKingJFAwardFlagList = d.param.award_flag
                self:dispatchEvent({name = Notify.EVENT_KING_UPATE_JF})
                self:dispatchEvent({name = Notify.EVENT_KING_JF_AWARD_FLAG})
            elseif d.actionid == "jfaward" then
                self.mKingJFAwardList = d.param
                self:dispatchEvent({name = Notify.EVENT_KING_JF_AWARD_LIST})
            elseif d.actionid == "push_info" then
                self.mKingJFPoint = d.param.jf
                self.mKingMapInfo = d.param
                self:dispatchEvent({name = Notify.EVENT_KING_UPATE_JF})
                self:dispatchEvent({name = Notify.EVENT_KING_UPATE_MAP_RANK_INFO})
            elseif d.actionid == "relivetime" then
                self.mKingReliveTime = d.param.relivetime
            elseif d.actionid == "ranklist" then
                self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_king_rank", pdata=d.param})
            elseif d.actionid == "kingdomInfo" then
                self.mKingInfo = d.param
                self:dispatchEvent({name = Notify.EVENT_KING_INFO_CHANGE})
            elseif d.actionid == "reqwar" then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "alert", visible = true,
                    lblAlert = {"你的请求已经被许可!皇城争霸将会在",
                        game.make_str_with_color(Const.COLOR_GREEN_1_STR,d.param.startt).."开始,"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,d.param.endt).."结束",
                        "剩下的时间不多了,祝你好运!"},
                    alertTitle = "关 闭",
                }
                self:dispatchEvent(param)
            end
        end
        return
    elseif ttype == "zhaohuanling" then
        if d.actionid then
            local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true,
                lblConfirm = d.params,
                confirmTitle = "前 往", cancelTitle = "关 闭",
                confirmCallBack = function ()
                    self:PushLuaTable("zhaohuanling",util.encode({actionid = d.actionid}))
                end
            }
            self:dispatchEvent(param)
        end
        return
    elseif ttype == "fcm" then
        if d.actionid and d.actionid == "desclist" and d.param then
            self.mFcmDescList = d.param
        end
        return
    elseif ttype == "reincarnation" then
        if d.actionid and (d.actionid == "queryexchangeinfo" or d.actionid == "proupgradeinfo"or d.actionid == "updatedata") and d.param then
            self.mRebornLevel = d.param.curlevel
            self.mcurExp = d.param.curreinexp or 0
            if not self.maxRebornLvl then
                self.maxRebornLvl = d.param.maxRebornLevel or 0
            end
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.ROLEREBORN,UIRedPoint.REDTYPE.BOSS_PERSON,UIRedPoint.REDTYPE.LEVELINVEST})
        end
        --return
    elseif ttype == "refineexp" then
        if d.param then
            if d.actionid == "exp_data" then
                self.Refineparam = d.param
                return 
            end
        end
    elseif ttype == "newOfflineExp" then
        if d.actionid and d.param then
            if d.actionid == "expinfo" then
                local first = (self.mOfflineExpInfo == nil)
                self.mOfflineExpInfo = d.param
                if first and self.mOfflineExpInfo.offlinemin > 0 then
                    self:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_offline_exp"})
                end
            elseif d.actionid == "drawresult" then
                self.mOfflineExpInfo.offlinemin = 0
                self:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_offline_exp"})
            end
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.OFFLINE_EXP})
        end
    elseif ttype == "actionset_moneybag" then
        -- 红包界面
        if d.actionid and d.param then
            if d.actionid == "new_moneybag" then
                local info = util.decode(d.param.info)
                if info.type == "new" then
                    self.mHongbaoNew = true
                elseif info.type == "timeout" then
                    self.mHongbaoNew = false
                end
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.HONGBAO})
            elseif d.actionid == "moneybag_snapped" or d.actionid == "get_moneybag_succeed" then
                self.mHongbaoNew = false
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.HONGBAO})
                return
            end
        end
    elseif ttype == "dowakuang" and d.actionid then
        if d.actionid == "start" then
            self.mCollectKuang = true
            self:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_caiji" , visible = true})
        elseif d.actionid == "end" then
            self.mCollectKuang = false
            self:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_caiji" , visible = false})
        end
        return
    elseif ttype == "totalloginpanel" and d.actionid then
        if d.actionid == "getAwards" then
            self.mSevenLoginInfo.state = d.datas
            self.mSevenLoginInfo.loginCnt = d.param1
        elseif d.actionid == "drawCurrentAward" then
            if d.param1 then
                self.mSevenLoginInfo.loginCnt = d.param1
            end

            if d.result == 0 or d.result == 2 then
                self.mSevenLoginInfo.state[d.id].accept = 1
            end
        end
        self:dispatchEvent({name = Notify.EVENT_SEVENLOGIN_MSG, type=ttype, data=tdata})
        return
    elseif ttype == "levelInvest" and d.actionid then
        if d.actionid == "queryinfo" then
            self.mLevelInvestInfo = d.param
        elseif d.actionid == "startInvest" then
            if d.param and d.param == 1 then
                self.mLevelInvestInfo.flag = 1
            end
        elseif d.actionid == "getAward" then
            if d.param then
                for k, v in ipairs(self.mLevelInvestInfo.list) do
                    if v.id == d.param then
                        self.mLevelInvestInfo.list[k].flag = 1
                        break
                    end
                end
            end
        end
        UIRedPoint.handleChange({UIRedPoint.REDTYPE.LEVELINVEST})
    elseif ttype == "privilege" and d.actionid then
        if d.actionid == "change_data" then
            self.mPrivilegeCardInfo = d.param
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.PRIVILEGECARD})
        elseif d.actionid == "use_data" then
            self.mAutoBuyDrugInfo = d.param
            return
        end
    elseif ttype == "vip" and d.actionid then
        if d.actionid == "vipchangeinfo" then
            if d.param then
                self.mVipLevelGiftInfo = d.param.viplvgiftflags or {}
                UIRedPoint.handleChange({UIRedPoint.REDTYPE.VIP})
            end
        end
    elseif ttype == "lottery" and d.actionid then
        if d.actionid == "new_lottery_log" then
            table.insert(self.mXunbaoShopExchangeLogList, d.param)
            if #self.mXunbaoShopExchangeLogList > Const.MAX_LOTTERY_LOG then
                table.remove(self.mXunbaoShopExchangeLogList,1)
            end
            self:dispatchEvent({name = Notify.EVENT_XUNBAO_EXCHANGE_NEW})
            return
        elseif d.actionid == "lottery_log" then
            self.mXunbaoShopExchangeLogList = {}
            self.mXunbaoShopExchangeLogList = d.param
            self:dispatchEvent({name = Notify.EVENT_XUNBAO_EXCHANGE_LIST})
            return
        elseif d.actionid == "querybaseinfo" then
            self.mXunbaoJf = d.param.xbjifen
        elseif d.actionid == "queryupdateinfo" then
            self.mXunbaoJf = d.param.xbjifen
        end
    elseif ttype == "newfighter_data" and d.actionid then
        if d.actionid == "can_upgrade" then
            self.zhanshencaninfo = d.param.next_defid
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.ZHANSHEN})
        end
    elseif ttype == "xntest" then
        self.showAlert = d.alert
        self.showUpEffect = d.up
        self.showFp = d.fp
        return
    elseif ttype == "itemchufa" then
        self.mItemUseInfo = d
        return
    elseif ttype == "onlinetimepanel" then
        if d.actionid == "pushOnlineinfo" then
            self.mOnlineInfo = d
            UILeftTop.countOnlineTime(self.mOnlineInfo.overtime)
            return
        end
    elseif ttype == "daysign" then
        if d.actionid == "updatesigninfo" then
            self.mDaySignInfo = d.param
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.AWARDHALL_SIGN})
        end   
    end

    self:dispatchEvent({name = Notify.EVENT_PUSH_PANEL_DATA, type=ttype, data=tdata})
end

function NetClient:getTopBtnFlag(type)
    return self.mTopBtn[type] or 0
end

function NetClient:sortRingList(list)
    self.mRingInfo.list = {}
    local job = game.GetMainNetGhost():NetAttr(Const.net_job)
    for k, v in pairs(list) do
        if k then
            if v.job == 0 or v.job == job then
                table.insert(self.mRingInfo.list,v)
            end
        end
    end
end

function NetClient:doGetAllMailItems()
    local tMailIDs = {}
    table.walk(self.mMailList,function(v,k)
        if v.isReceive ~= 1 and #v.fujinItems > 0 then
            table.insert(tMailIDs, k)
        end
    end)
    if #tMailIDs > 0 then
        self:receiveMailItems(tMailIDs)
    end
end

function NetClient:doDeleteAllMails()
    local tMailIDs = {}
    table.walk(self.mMailList,function(v,k)
        if v.isOpen == 1 and (#v.fujinItems == 0 or ( #v.fujinItems > 0 and v.isReceive == 1)) then
            table.insert(tMailIDs, k)
        end
    end)
    if #tMailIDs > 0 then
        self:deleteMails(0,tMailIDs)
    end
end

function NetClient:getActivityList(index)
    return self.mActivityList[index]
end

function NetClient:getKingMemberInfoByTitle(title)
    local ret = {}
    for k, v in ipairs(self.mKingMembers) do
        if v.rank == title then
            table.insert(ret,v)
        end
    end
    return ret
end

function NetClient:getKingJfAwardFlag()
    for k, v in ipairs(self.mKingJFAwardFlagList) do
        if v == 1 then return true end
    end
    return false
end

function NetClient:getSkillUpLevelInfo(skillid)
--    return NetClient.mSkillUpInfo[skillid]
    if SkillUpDefData[skillid] then
        return SkillUpDefData[skillid].levelinfo
    end
end

function NetClient:secondsCountdown()
    self:mini_npc_countdown()
    self:privilegeCountdown()
end

function NetClient:mini_npc_countdown()
    if not self.mMapMonster then return end
    for monsername, nmc in pairs(self.mMapMonster) do
        if nmc.mReliveTime > 0 then
            nmc.mReliveTime = nmc.mReliveTime - 1
        end
    end
end

function NetClient:privilegeCountdown()
    if not self.mPrivilegeCardInfo or not self.mPrivilegeCardInfo.left_time then return end
    for k = 1, #self.mPrivilegeCardInfo.left_time do
        local v = self.mPrivilegeCardInfo.left_time[k]
        if v > 0 then
            self.mPrivilegeCardInfo.left_time[k] = v - 1
        end
    end
end

function NetClient:getXunbaoShopList(type)
    if self.mXunbaoShopList[type] then return self.mXunbaoShopList[type] end

    local ret_data = {}
    local item_data = SortXunbaoShopDefData[type];
    if not item_data then  print("11111", type, ret_data) return ret_data end
    local myjob = game.getRoleJob()
    local mysex = game.getRoleGender()
    local needall = XunbaoShopDefData[type].needall

    local job_data = item_data[tostring(myjob)];		--匹配的职业分类
    if job_data then
        local sex_data = job_data["0"];	--性别通用数据
        if sex_data then table.insertto(ret_data,sex_data); end
        if needall then
            sex_data = job_data[tostring(Const.SEX_MALE)];
            if sex_data then table.insertto(ret_data,sex_data); end
            sex_data = job_data[tostring(Const.SEX_FEMALE)];
            if sex_data then table.insertto(ret_data,sex_data); end
        else
            local sex_data = job_data[tostring(mysex)];	--性别数据
            if sex_data then table.insertto(ret_data,sex_data); end
        end
    end

    job_data = item_data["0"];	--通用职业数据
    if job_data then
        local sex_data = job_data["0"];	--性别通用数据
        if sex_data then table.insertto(ret_data,sex_data); end
        if needall then
            sex_data = job_data[tostring(Const.SEX_MALE)];
            if sex_data then table.insertto(ret_data,sex_data); end
            sex_data = job_data[tostring(Const.SEX_FEMALE)];
            if sex_data then table.insertto(ret_data,sex_data); end
        else
            local sex_data = job_data[tostring(mysex)];	--性别数据
            if sex_data then table.insertto(ret_data,sex_data); end
        end
    end

    self.mXunbaoShopList[type] = ret_data
    return ret_data
end

function NetClient:isBanYueOpen()
    return self.m_netSkillOpen[Const.SKILL_TYPE_BanYueWanDao]
end

function NetClient:isCishaOpen()
    return self.m_netSkillOpen[Const.SKILL_TYPE_CiShaJianShu]
end

function NetClient:isLongYingCishaOpen()
    return self.m_netSkillOpen[Const.SKILL_TYPE_LongYingJianQi]
end

function NetClient:isSingleCishaOpen()
    if self.m_netSkillOpen[Const.SKILL_TYPE_CiShaJianShu] then
        return true
    end
    if self.m_netSkillOpen[Const.SKILL_TYPE_LongYingJianQi] then
        return true
    end
end

function NetClient:getOpenedSingleCisha()
    if self.m_netSkillOpen[Const.SKILL_TYPE_LongYingJianQi] then
        return Const.SKILL_TYPE_LongYingJianQi
    end
    if self.m_netSkillOpen[Const.SKILL_TYPE_CiShaJianShu] then
        return Const.SKILL_TYPE_CiShaJianShu
    end
    return 0
end

function NetClient:isSkillOpen(skillid)
    return self.m_netSkillOpen[skillid]
end

function NetClient:resetLiehuoSkillInfo()
    self.m_bLiehuoAction = false
    self.m_bLiehuoSkillId = 0
end

function NetClient:startLiehuoAction(skillid)
    self.m_bLiehuoAction = true
    self.m_bLiehuoSkillId = skillid
end

function NetClient:getHightestLiehuoSkill()
    if self.m_netSkill[113] then
        return 113
    end

    if self.m_netSkill[111] then
        return 111
    end

    if self.m_netSkill[109] then
        return 109
    end

    if self.m_netSkill[106] then
        return 106
    end
end

function NetClient:getFSAutoSkill()
    if self.m_netSkill[421] then
        return 421
    end

    if self.m_netSkill[419] then
        return 419
    end

    if self.m_netSkill[417] then
        return 417
    end

    if self.m_netSkill[414] then
        return 414
    end

    if self.m_netSkill[405] then
        return 405
    end

    if self.m_netSkill[401] then
        return 401
    end
end

function NetClient:getFsTouchedAutoSkill()
    if self.m_netSkill[405] then
        return 405
    end
    if self.m_netSkill[401] then
        return 401
    end
end

function NetClient:getFsDunSkill()
    if self.m_netSkill[418] then
        return 418
    end
    if self.m_netSkill[412] then
        return 412
    end
end

function NetClient:getDSAutoSkill()
    if self.m_netSkill[521] then
        return 521
    end
    if self.m_netSkill[504] then
        return 504
    end
end

function NetClient:getDsZhaohuanSkill()
    if self.m_netSkill[522] then
        return 522
    end
    if self.m_netSkill[518] then
        return 518
    end
    if self.m_netSkill[513] then
        return 513
    end
    if self.m_netSkill[505] then
        return 505
    end
end

function NetClient:onSocketError()
    game.onDisConnect()
    gameLogin.onNetDisConnect()
    self:dispatchEvent({name=Notify.EVENT_SOCKET_ERROR})
end

return NetClient:new()