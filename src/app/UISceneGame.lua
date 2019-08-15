local UISceneGame={}

local scene=nil

local var = {}

local sys_check = {"check_trade","check_guild","check_group","check_weapon","check_cloth",
    "check_wing","check_title","check_skill","check_monster","check_guild_player","check_alien_player"
}

--传进来的pos应该是大地图上某个点的坐标(如果是摇杆则需要映射换算)
function UISceneGame.initVar()
	var = {
		scene,
		mainrole,
		destlayer,
		alivelayer,
		mainScheduler,
		pingScheduler,
		mainrolePos,
		standStillTime = 0, --静止不动计时
		---------UI相关变量---------
		uiPlayer,
		uiListPlayers,

		hpBar,
		hpLbl,
		ghostType,

		showTargetID=0,
		selectTab={},

		nearbyGhosts = {},
		lastPos = nil,
		setLowFPSOnce = false,
	}
end

UISceneGame.initVar();

function UISceneGame.findingTouchStart(pos)
	if var.mainrole and var.destlayer then
		var.mainrole:findingTouchStart(var.destlayer:convertToNodeSpace(pos))
	end
end

function UISceneGame.convertPos(pos)
	return var.destlayer:convertToNodeSpace(pos)
end

function UISceneGame.findingTouchMove(pos, isClickMap)
    if isClickMap == nil then isClickMap = 0 end
	if not var.mainrole then var.mainrole = CCGhostManager:getMainAvatar() end
	if var.mainrole and var.destlayer then
        local logicPos = cc.p(var.mainrole:NetAttr(Const.net_x),var.mainrole:NetAttr(Const.net_y))
        local from = NetCC:logicPosToPixesPos(logicPos.x,logicPos.y)
        local to = var.destlayer:convertToNodeSpace(pos)
        local dir = game.getPixesDirection(from,to)
        local dis = cc.pGetDistance(from, to);
        local flag = 2 -- 跑步
        --if dis <= 75 and isClickMap == 1 then
        if dis <= 75 then
            flag = 1 -- 走路
        end
		MainRole.stopAttackOfSoldier()
		MainRole.handleAutoKillOn(false) --取消自动挂机
		local mainAvatar = game.GetMainRole()
	    if mainAvatar then
			mainAvatar:clearAutoMove()
		end
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_move" , visible = false})
		var.mainrole:findingTouchMove(cc.p(dir,flag))
		if not var.welcometype and game.getRoleLevel() < 30 then
			UILeftCenter.showMainlineTip()
		end
	end
end
function UISceneGame.findingTouchEnd(pos)
	if var.mainrole and var.destlayer then
		MainRole.mMoveToNearAttack = false
		MainRole.handleAutoKillOn(false) --取消自动挂机
		MainRole.stopAttackOfSoldier()
		local mainAvatar = game.GetMainRole()
	    if mainAvatar then
			mainAvatar:clearAutoMove()
		end
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_move" , visible = false})
		var.mainrole:findingTouchEnd(var.destlayer:convertToNodeSpace(pos))
        MainRole.resetTargetRoad()
	end
end

function UISceneGame.setMainUIVisible(visible)

	local uiTable = {"m_ltPartUI","m_lcPartUI","m_lbPartUI","m_rtPartUI","m_rcPartUI","m_rbPartUI","m_layerRocker"}
	for _,v in ipairs(uiTable) do
		UISceneGame[v]:setVisible(visible)
	end
end

function UISceneGame.handleShowPlot(event)
	if event then
		UISceneGame.setMainUIVisible(not event.show)
	end
end

function UISceneGame.handleMainUIVisible(event)
	if event then
		UISceneGame.setMainUIVisible(event.visible)
	end
end

local function freshHP()
--	local ava = CCGhostManager:getPixesGhostByID(var.showTargetID)
--	if ava then
--		if ava:NetAttr(Const.net_dead) then
--			var.showTargetID = 0--死的时候手动清空指向ghost的id
--			var.uiPlayer:hide()
--			UIRightTop.showAllActivity()
--			return
--		end
--
--		local hp = ava:NetAttr(Const.net_hp)
--		local maxHp = ava:NetAttr(Const.net_maxhp)
--		var.hpLbl:setString(hp.."/"..maxHp)
--		var.hpBar:setPercentage(math.ceil(hp*100/maxHp))
--	end
end

function UISceneGame.showUIPlayer(avaID)
	local avatar = CCGhostManager:getPixesGhostByID(avaID)
	if avatar then
        if var.showTargetID and var.showTargetID ~= avaID then
            NetClient:dispatchEvent({
                name=Notify.EVENT_TARGET_UI_CHANGE,
                visible=false,
            })
        end

		var.showTargetID=avaID
		var.nearbyGhosts = NetCC:getNearGhost(var.ghostType)
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_change" , visible = false})
		if var.ghostType == Const.GHOST_PLAYER then

            NetClient:dispatchEvent({
                name=Notify.EVENT_TARGET_UI_CHANGE,
                visible=true,
                uitype=Const.GHOST_PLAYER,
                params={
                    srcID = var.showTargetID,
                    lv=avatar:NetAttr(Const.net_level),
                    name=avatar:NetAttr(Const.net_name),
                    job=avatar:NetAttr(Const.net_job),
                    gender=avatar:NetAttr(Const.net_gender),
                }
            })
			-- local imgPlayerBg = var.uiPlayer:getWidgetByName("imgPlayerBg")
			-- imgPlayerBg:getWidgetByName("lblPlayerLevel"):setString(tostring(avatar:NetAttr(Const.net_level)))
			-- imgPlayerBg:getWidgetByName("lblPlayerName"):setString(avatar:NetAttr(Const.net_name))
			
			-- freshHP()
			-- if var.ghostType == Const.GHOST_PLAYER then
			-- 	local job = avatar:NetAttr(Const.net_job)
			-- 	local gender = avatar:NetAttr(Const.net_gender)
			-- 	-- print(job)
			-- 	local id = (job - 100) * 2 + gender - 199
			-- 	-- var.uiPlayer:getWidgetByName("imgPlayerHead"):loadTexture("scene/"..head_key[id].."_big.png", ccui.TextureResType.localType)
			-- end

			-- imgPlayerBg:setVisible(true)
			-- var.uiListPlayers:getWidgetByName("listPlayersBg"):setVisible(false)

			-- table.removebyvalue(var.nearbyGhosts, avaID)--去掉当前的

			if table.nums(var.nearbyGhosts) > 0 and not MainRole.m_isAutoKillMonster then
				NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_change" , visible = true})
			end
        elseif var.ghostType == Const.GHOST_MONSTER then
            if avatar:NetAttr(Const.net_level) >= 100 then
                NetClient:dispatchEvent({
                    name=Notify.EVENT_TARGET_UI_CHANGE,
                    visible=true,
                    uitype=Const.GHOST_MONSTER,
                    params={
                        srcID = var.showTargetID,
                        lv=avatar:NetAttr(Const.net_level),
                        name=avatar:NetAttr(Const.net_name),
                    }
                })
            end
        end


	end
end

function UISceneGame.handleGhostsTouched(point)
	MainRole.stopAutoMove()
	-- local function pushBtnAvatar(sender, touchType)
	-- 	if touchType == ccui.TouchEventType.ended then
	-- 		-- var.uiListPlayers:getWidgetByName("listPlayersBg"):setVisible(false)
	-- 		CCGhostManager:selectSomeOne(sender.avaID)
	-- 	end
	-- end
	local monsterID = CCGhostManager:isTouchGhost(point,Const.GHOST_MONSTER)
    if monsterID == 0 then
        monsterID = CCGhostManager:isTouchGhost(point,Const.GHOST_NEUTRAL)
    end
	if monsterID > 0 then
		if game.SETTING_TABLE["check_monster"] then
			return
		end
        if UILeftCenter.checkIsMyTotem(monsterID) then
            return
        end

		if MainRole.mAimGhostID ~= monsterID then
			if MainRole.mAimGhostID > 0 then
				local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
				if mAimGhost then
					mAimGhost:getSprite():removeChildByName("selected")
				end
			end
			CCGhostManager:selectSomeOne(monsterID)
		end
		if MainRole.mAimGhostID == monsterID then
			if var.mainrole then
				local job = var.mainrole:NetAttr(Const.net_job)
				local default_skill = Const.SKILL_TYPE_YiBanGongJi
				if job == Const.JOB_FS then
                    local as = NetClient:getFsTouchedAutoSkill() if as then default_skill = as end
				elseif job == Const.JOB_DS then
                    local as = NetClient:getDSAutoSkill() if as then default_skill = as end
				end
				local mAimGhost=NetCC:getGhostByID(MainRole.mAimGhostID)
				if mAimGhost then
					if mAimGhost:NetAttr(Const.net_collecttime) > 0 then
						if mAimGhost:NetAttr(Const.net_hp) > 0 and not NetClient.m_bCollecting then--进度条结束后m_bCollecting应该设为false
							-- MainRole.doNearAttack()
							UISceneGame.startAutoMoveToPos(point, 999)
							MainRole.mMoveEndAutoCaiji = true
						end
					else
						if mAimGhost:NetAttr(Const.net_ortype) == 511 and mAimGhost:NetAttr(Const.net_rn_zy) <= 2 then return end
						MainRole.startCastSkill(default_skill)
					end
				end
			end
		end
		return true
	end

	if #CCGhostManager:isTouchGhosts(point,Const.GHOST_ITEM)>0 then
		UISceneGame.startAutoMoveToPos(point)
		MainRole.mMoveEndAutoPick = true
		return true 
	end
	local avatarID = CCGhostManager:isTouchGhost(point,Const.GHOST_PLAYER)
	if avatarID > 0 then
		if MainRole.mAimGhostID ~= avatarID then
			if MainRole.mAimGhostID > 0 then
				local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
				if mAimGhost then
					mAimGhost:getSprite():removeChildByName("selected")
				end
			end
			CCGhostManager:selectSomeOne(avatarID)
		else
			if var.mainrole then
				local job = var.mainrole:NetAttr(Const.net_job)
				local default_skill = Const.SKILL_TYPE_YiBanGongJi
                if job == Const.JOB_FS then
                    local as = NetClient:getFsTouchedAutoSkill() if as then default_skill = as end
                elseif job == Const.JOB_DS then
                    local as = NetClient:getDSAutoSkill() if as then default_skill = as end
                end
				local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
				if mAimGhost then
					MainRole.startCastSkill(default_skill)
				end
			end
		end
		return true
	end
	local ghostID = CCGhostManager:isTouchGhosts(point)
	if #ghostID == 1 then
        if MainRole.mAimGhostID > 0 and MainRole.mAimGhostID ~= avatarID then
            local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
            if mAimGhost then
                mAimGhost:getSprite():removeChildByName("selected")
            end
        end
        local ghost_id = ghostID[1]
        local newpoint = point
        local tempGhost = NetCC:getGhostByID(ghost_id)
        if tempGhost and var.mainrole then
            if tempGhost:NetAttr(Const.net_type) == Const.GHOST_SLAVE then
                return false
            end
            newpoint = cc.p(tempGhost:NetAttr(Const.net_x),tempGhost:NetAttr(Const.net_y))
            CCGhostManager:selectSomeOne(ghost_id)
            MainRole.mTargetNPCName = ""
            MainRole.setTargetRoad(NetClient.mNetMap.mMapID,newpoint.x,newpoint.y)
            var.mainrole:startAutoMoveToPos(newpoint.x,newpoint.y,2)
            MainRole.mMoveEndAutoTalk = true
            return true
        end
        return false
	elseif #ghostID > 1 then
		local tempGhostTab = {}
		for i=1,#ghostID do
			local tempGhost = NetCC:getGhostByID(ghostID[i])
			if tempGhost and tempGhost:NetAttr(Const.net_type) ~= Const.GHOST_SLAVE then
				table.insert(tempGhostTab,ghostID[i])
			end
		end
		CCGhostManager:selectSomeOne(tempGhostTab[1])
		MainRole.mTargetNPCName = ""
		UISceneGame.startAutoMoveToPos(point,2)
		MainRole.mMoveEndAutoTalk = true
		return true
	end
	return false
end

function UISceneGame.startAutoMoveToPos(point,flag)
	local pos = var.destlayer:convertToNodeSpace(point)
	local logicPos = NetCC:pixesPosToLogicPos(pos.x,pos.y)
	if var.mainrole then
		MainRole.mMoveToNearAttack = false
		MainRole.handleAutoKillOn(false) --取消自动挂机
		MainRole.mWarriorAttackCD = false
		MainRole.mMageAttackCD = false
		-- NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = false})
		if flag ~= 999 then
			MainRole.stopAttackOfSoldier()
		end
		var.mainrole:startAutoMoveToPos(logicPos.x,logicPos.y,flag or 0)
	end
end

function UISceneGame.handleMapTouched(event)
	if event and event.pos then
		UISceneGame.startAutoMoveToPos(event.pos)
--		local pos = var.destlayer:convertToNodeSpace(event.pos)
--		local blink = ccui.ImageView:create("acc_audio_btn_0_sel",UI_TEX_TYPE_PLIST)
--		blink:setPosition(pos)
--		blink:runAction(
--			cc.Sequence:create(
--				cc.Blink:create(0.3,2),
--				cc.RemoveSelf:create()
--			)
--		)
--		var.destlayer:addChild(blink)
	end
end

function UISceneGame.handleAutoChangeAim(event)

	if table.nums(var.nearbyGhosts) < 1 then var.nearbyGhosts = NetCC:getNearGhost(var.ghostType) end
	if table.nums(var.nearbyGhosts) > 0 then
		local aimID = var.nearbyGhosts[math.random(1,#var.nearbyGhosts)]
		CCGhostManager:selectSomeOne(aimID)
	end
end

function UISceneGame.handlePanelData(event)
	if event.type == "PanelOne" then
		local serverData = util.decode(event.data)
		if serverData and serverData.panelName then
			NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = serverData.panelName})
		end
	end
end

function UISceneGame.onKeyboard(event)
	if event.key=="back" then
		device.showAlert("提示","要重新登录吗？",{"确定","取消"},function (event)
			if event.buttonIndex == 1 then
				game.ExitToRelogin()
		    end
		end)
	end
end

function UISceneGame.get_mainrole_pixespos()
	if var.destlayer then
		local mainrole=CCGhostManager:getMainAvatar()
		if mainrole then
			return mainrole:getSprite():convertToWorldSpace(cc.p(0,0))
		end
	end
end

local function update(dx)
    if gameLogin._isAutoLogining or gameLogin.isReLogin then return end
	------------------------------------挂机判断--------------------------------
	-- local curPos = cc.p(var.mainrole:NetAttr(Const.net_x),var.mainrole:NetAttr(Const.net_y))
	-- if util.pEqual(curPos, var.mainrolePos) then
	-- 	var.standStillTime = var.standStillTime + 1
	-- 	if var.standStillTime >= 10 and (#(NetCC:getNearGhost(Const.GHOST_MONSTER)) > 0 or #(NetCC:getNearGhost(Const.GHOST_ITEM)) > 0) then
	-- 		var.standStillTime = 0
	-- 		-- NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = true})
	-- 	end
	-- else
	-- 	var.mainrolePos = curPos
	-- 	var.standStillTime = 0
	-- 	-- NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_auto_fight" , visible = false})
	-- end
	-------------------------------------刷新选中角色状态----------------------------------
	if var.showTargetID > 0 then
--		freshHP()
	end

	if var.showTargetID == 0 and MainRole.mLastAimID > 0 then
		MainRole.mLastAimLeftTime = MainRole.mLastAimLeftTime + 1
	end

	if NetClient.mTradeInfo.mIsTrade == 1 then
		if not game.openTrade then
			NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_trade"})
		end
	else
		if game.openTrade then
			NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_trade"})
		end
	end

	MainRole.update()

    local mainAvatar = game.GetMainRole()
    if mainAvatar then
        local curPos = cc.p(mainAvatar:PAttr(Const.AVATAR_X),mainAvatar:PAttr(Const.AVATAR_Y))
        if not var.lastPos then
            NetClient:dispatchEvent({name=Notify.EVENT_POS_CHANGE})
            var.lastPos = curPos
        elseif var.lastPos and (var.lastPos.x ~= curPos.x or var.lastPos.y ~= curPos.y) then
            NetClient:dispatchEvent({name=Notify.EVENT_POS_CHANGE})
            var.lastPos = curPos
        end
      --   local mainFPS = cc.Director:getInstance():getFrameRate()
      --   if mainFPS < 20 and not var.setLowFPSOnce then
		    -- var.setLowFPSOnce = true
		    -- local param = {
		    --     name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "当前游戏帧数过低，导致运行不流畅，是否屏蔽显示？",
		    --     confirmTitle = "确  定", cancelTitle = "关  闭",
		    --     autoclose = true,
		    --     confirmCallBack = function ()
		    --         game.SETTING_TABLE["showall_control"] = true
		    --         for i=1,#sys_check do
		    --         	game.SETTING_TABLE[sys_check[i]] = true
		    --         end
		    --     	NetClient:PushLuaTable("player.setGameData",util.encode(game.SETTING_TABLE))
				  --   NativeData.saveSettingInfo(game.GetMainRole():NetAttr(Const.net_name))
				  --   game.GetMainRole():setPAttr(Const.AVATAR_SET_CHANGE,1)
				  --   NetClient:alertLocalMsg("屏蔽显示成功，若要修改请前往设置界面！","alert")
		    --     end,
		    --     cancelCallBack = function ()
				  --   NetClient:alertLocalMsg("当前帧数过低，若要修改请前往设置界面！","alert")
		    --     end
		    -- }
		    -- NetClient:dispatchEvent(param)
      --   end
    end
end

local function pingServer(dt)
	-- NetClient:Ping()
    MainRole.status_countdown()
    NetClient:secondsCountdown()
end

function UISceneGame.onSocketError(event)
	game.ExitToRelogin()
end

function UISceneGame.regetMainRole()
    var.mainrole = CCGhostManager:getMainAvatar()
end

function scene_game_enter(_scene)
    -- if true  then
    --     return
    -- end
	print("scene_game_enter==================>>start")
	UISceneGame.initVar()
	print("scene_game_enter==================>>start1")
	var.mainScheduler = Scheduler.scheduleGlobal(update,0.2)

	var.pingScheduler = Scheduler.scheduleGlobal(pingServer,1)

	MAIN_IS_IN_GAME=true

	var.scene = _scene
	var.scene:setGameScale(Const.minScale)
	var.mainrole = CCGhostManager:getMainAvatar()
	var.destlayer=var.scene:getChildByName("map_dest")
	if var.destlayer then
		var.alivelayer=var.scene:getChildByName("map_alive")
    end

    local rokerZOrder = 6
    local bottomZOrder = 10
    local pannelZOrder = 11
    local chatZOrder = 12
    local alertZOrder  = 50 -- 最高操作层
    local itemTipZOrder = 55
    local msgShowZOrder = 60 -- 层最高，只是显示，不接收事件
	print("scene_game_enter==================>>start2")
    var.m_lcPartUI = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_LeftCenter.csb")
	if var.m_lcPartUI then
		var.scene:addChild(var.m_lcPartUI,bottomZOrder)
		UILeftCenter.init_ui(var.m_lcPartUI)
	end
	
    var.m_ltPartUI = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_LeftTop.csb")
	if var.m_ltPartUI then
		var.scene:addChild(var.m_ltPartUI,bottomZOrder)
		UILeftTop.init_ui(var.m_ltPartUI)
	end

	var.m_rtPartUI = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_RightTop.csb")
	if var.m_rtPartUI then
		var.scene:addChild(var.m_rtPartUI,bottomZOrder)
		UIRightTop.init_ui(var.m_rtPartUI)
	end

	var.m_rbPartUI = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_RightBottom.csb")
	if var.m_rbPartUI then
		var.scene:addChild(var.m_rbPartUI,bottomZOrder)
		UIRightBottom.init_ui(var.m_rbPartUI)
    end

    var.m_lbPartUI = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_LeftBottom.csb")
    if var.m_lbPartUI then
        var.scene:addChild(var.m_lbPartUI,bottomZOrder)
        UILeftBottom.init_ui(var.m_lbPartUI)
    end
 --运行崩溃 暂时屏蔽 后续处理 2019/8/8-xy
    var.m_cbPartUI = require("app.layers.LayerCenterBottom").new()
    if var.m_cbPartUI then
        var.scene:addChild(var.m_cbPartUI,bottomZOrder)
    end

	var.m_layerRocker = LayerRocker.init()
	if var.m_layerRocker then
		var.scene:addChild(var.m_layerRocker,rokerZOrder)
	end

    var.m_gamePanel = require("app.layers.LayerGamePanel").new()
    if var.m_gamePanel then
        var.scene:addChild(var.m_gamePanel,pannelZOrder)
    end
	--运行崩溃 暂时屏蔽 
    var.m_LayerChat = require("app.layers.LayerChat").new()
    if var.m_LayerChat then
        var.scene:addChild(var.m_LayerChat,chatZOrder)
    end

    var.m_LayerItemTip = require("app.layers.LayerItemTip").new()
    if var.m_LayerItemTip then
        var.scene:addChild(var.m_LayerItemTip,itemTipZOrder)
    end

    var.m_layerAlert = require("app.layers.LayerAlert").new()
    if var.m_layerAlert then
        var.scene:addChild(var.m_layerAlert,alertZOrder)
    end

    var.m_layerNotice = require("app.layers.LayerNotice").new()
    if var.m_layerNotice then
        var.scene:addChild(var.m_layerNotice,bottomZOrder)
    end

    var.m_LayerRelive = require("app.layers.LayerRelive").new()
    if var.m_LayerRelive then
        var.scene:addChild(var.m_LayerRelive,chatZOrder)
    end

    var.m_LayerMsgShow = require("app.layers.LayerMsgShow").new()
    if var.m_LayerMsgShow then
        var.scene:addChild(var.m_LayerMsgShow,msgShowZOrder)
    end

    print("scene_game_enter==================>>start3")
    dw.EventProxy.new(NetClient,scene)
----	:addEventListener(Notify.EVENT_SHOW_PLOT, UISceneGame.handleShowPlot)  --TODO
----	:addEventListener(Notify.EVENT_MAINUI_VISIBLE, UISceneGame.handleMainUIVisible)  --TODO
----	:addEventListener(Notify.EVENT_ATTACKMODE_CHANGE, UISceneGame.updatePKState)  --TODO
--	:addEventListener(Notify.EVENT_MAP_TOUCHED, UISceneGame.handleMapTouched)
----	:addEventListener(Notify.EVENT_HANDLE_CHG_AVA, UISceneGame.handleAutoChangeAim)  --TODO
----	:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, UISceneGame.handlePanelData)
----	:addEventListener(Notify.EVENT_KEYBOARD_PASSED, UISceneGame.onKeyboard)
   		:addEventListener(Notify.EVENT_START_PROGRESS, UISceneGame.onShowMountProgressbar)  --TODO
   		:addEventListener(Notify.EVENT_STOP_PROGRESS, UISceneGame.onStopProgressbar)  --TODO
--
--    print("注册成功")
    ----------------------新手欢迎界面 start----------------------
    if not var.mainrole then return end
    if var.mainrole:NetAttr(Const.net_level) == 1 and TaskData.list[Const.TASK_MAIN_ID] and TaskData.list[Const.TASK_MAIN_ID].mState == 12 then
        print("UISceneGame:scene_game_enter==>>show welcomePanel")
        var.welcometype = true
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "welcome", visible = true,
            startCallBack = function ()
                NetClient:PushLuaTable("player.onMainTaskBegin", util.encode({actionid = "start"}))
                var.welcometype = false
            end
        }
        NetClient:dispatchEvent(param)
    end
    ----------------------新手欢迎界面 end----------------------
    print("scene_game_enter==================>>start4")
    if var.mainrole:NetAttr(Const.net_level) >= 60 then
        -- 离线经验
        NetClient:PushLuaTable("newOfflineExp",util.encode({actionid="getCurrentOfflineExp"}))
    end

    print("scene_game_enter==>>end")
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SCENE_GAME_ENTER,"scene_game_enter")

function scene_game_exit(_scene)
	if var.mainScheduler then
		Scheduler.unscheduleGlobal(var.mainScheduler)
		var.mainScheduler = nil
	end
	if var.pingScheduler then
		Scheduler.unscheduleGlobal(var.pingScheduler)
		var.pingScheduler = nil
	end

	MAIN_IS_IN_GAME=false

	var.scene = nil
	UIRightTop.clear()
	var = {}

	--clear game
	cc.GhostManager:getInstance():remAllSkill()
	cc.GhostManager:getInstance():remAllEffect()
	cc.NetClient:getInstance():remAllNetGhost()
	cc.CacheManager:getInstance():releaseUnused(false)
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SCENE_GAME_EXIT,"scene_game_exit")


local stateImg = {
	[100] = "all",
	[101] = "peace",
	[102] = "team",
	[103] = "guild",
	[104] = "shane",
}
function UISceneGame:updatePKState(event)
	local curState = NetClient.mAttackMode -- 99
	var.mode_btn:loadTextures("btn_"..stateImg[curState], "btn_"..stateImg[curState].."_sel", "", UI_TEX_TYPE_PLIST)
	-- UISceneGame.mode_manage:getWidgetByName("mode_btn"):setCapInsets(cc.rect())
end

function ghost_map_meet(srcid)
	if not MainRole then return end

	local mon = CCGhostManager:getPixesGhostByID(srcid)

    if not mon  then
        return
    end

    if  mon:NetAttr(Const.net_type) == Const.GHOST_MONSTER then
        UILeftCenter.checkIsKilledTutom(srcid)
    end

    if not mon:NetAttr(Const.net_rn_zy) or mon:NetAttr(Const.net_rn_zy) <=2 then return end

    if  mon:NetAttr(Const.net_type) == Const.GHOST_MONSTER then
		print(tostring(MainRole.m_isAutoKillMonster))
		return
	end
	if var.nearbyGhosts and table.indexof(var.nearbyGhosts, srcid) == false then--新的ghost则塞到table中
		table.insert(var.nearbyGhosts, srcid)
	end
	if srcid == MainRole.mLastAimID then--刚才选中的ghost
		if MainRole.mLastAimLeftTime <= 150 then
			CCGhostManager:selectSomeOne(srcid)
			MainRole.mLastAimLeftTime = 0
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAP_MEET,"ghost_map_meet")

function ghost_map_bye(srcid)--对象死亡也会触发
    if var.nearbyGhosts then
	    table.removebyvalue(var.nearbyGhosts, srcid)
    end
	if not MainRole then return end

	if srcid == var.showTargetID then
		var.showTargetID=0
        NetClient:dispatchEvent({
            name=Notify.EVENT_TARGET_UI_CHANGE,
            visible=false,
        })
        if srcid == MainRole.mLastAimID then
        	MainRole.mLastAimLeftTime = 0
        end
		MainRole.mAimGhostID = 0
		NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_change" , visible = false})
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_MAP_BYE,"ghost_map_bye")

function handle_ghost_injury(srcid)
    if srcid == var.showTargetID then
--        print("handle_ghost_injury===",srcid)
        NetClient:dispatchEvent({name=Notify.EVENT_OTHER_HPMP_CHANGE,param={srcid=srcid}})
    end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_GHOST_INJURY,"handle_ghost_injury")

function handle_ghost_die(srcid)
    if srcid == MainRole.mAimGhostID then
        MainRole.mAimGhostID=0
        MainRole.mAiKeepAttack = false
        -- MainRole.autoKillMonster()
    end
    if srcid == var.showTargetID then
        var.showTargetID=0
        NetClient:dispatchEvent({
            name=Notify.EVENT_TARGET_UI_CHANGE,
            visible=false,
        })
        MainRole.mAimGhostID = 0
        NetClient:dispatchEvent({name = Notify.EVENT_HANDLE_FLOATING , btn = "main_change" , visible = false})
    end
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        if srcid == MainAvatar:NetAttr(Const.net_id) then
            MainAvatar:clearAutoMove()
            MainRole.handleAutoKillOn(false)
            NetClient:dispatchEvent({name=Notify.EVENT_CLOSE_ALL_PANEL})
        end
    end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_GHOST_DIE,"handle_ghost_die")

function select_some_one(selected,pixesGhost)
	local pid = pixesGhost:NetAttr(Const.net_id)
	local pixesAvatar = CCGhostManager:getPixesAvatarByID(pid)
	local ptype = pixesGhost:NetAttr(Const.net_type)
	if pixesAvatar then
		if selected == 0 then

		elseif selected == 1 then

			MainRole.mMoveToNearAttack = false
			
			MainRole.mPlusSkill,MainRole.mMoveSpace = MainRole.getPlusSkillType(pixesGhost)
			if ptype == Const.GHOST_NPC then
				MainRole.mAimGhostID = pid
			elseif ptype == Const.GHOST_ITEM then-- 捡物品
				UISceneGame.startAutoMoveToPos(point)
				MainRole.mMoveEndAutoPick=true
			else 
				var.ghostType=ptype

				if ptype==Const.GHOST_PLAYER then
					MainRole.mLastAimID=pid
				end
				if MainRole.mAimGhostID == 0 or MainRole.mAimGhostID ~= pid then
					if pixesGhost:NetAttr(Const.net_level) >= 100 and pixesGhost:NetAttr(Const.net_type) == Const.GHOST_MONSTER then
					-- if pixesGhost:NetAttr(Const.net_jingying) == 2 then
						MainRole.mUseSkillOnce = true
					end
				end
				MainRole.mAimGhostID = pid--当前指向的角色id
				UISceneGame.showUIPlayer(pid)
			end

			if ptype==Const.GHOST_NPC and var.selectTab.npc then
				local savatar=CCGhostManager:getPixesAvatarByID(var.selectTab.npc)
				if savatar then
--					savatar:remEffect("selected")
					savatar:getSprite():removeChildByName("selected")
				end
				var.selectTab.npc=nil
			elseif ptype~=Const.GHOST_NPC and var.selectTab.oth then
				local savatar=CCGhostManager:getPixesAvatarByID(var.selectTab.oth)
				if savatar then
--					savatar:remEffect("selected")
					savatar:getSprite():removeChildByName("selected")
				end
				var.selectTab.oth=nil
			end

			if ptype~=Const.GHOST_ITEM then
                local effectidx = gameEffect.EFFECT_SELECTED_RED
				if ptype == Const.GHOST_NPC or ptype == Const.GHOST_PLAYER then
                    effectidx = gameEffect.EFFECT_SELECTED_GREEN
				end
				if pixesAvatar then
					-- table.insert(var.selectTab,pid)
					if ptype==Const.GHOST_NPC then
						var.selectTab.npc=pid
					else
						var.selectTab.oth=pid
					end
                    gameEffect.playEffectByType(effectidx)
						:setPosition(cc.p(0,-16)):setName("selected"):addTo(pixesAvatar:getSprite())
				end
			end
		end
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SELECT_SOME_ONE,"select_some_one")

function update_npc_flag(flag_str)
    local npc_id = 0
    local show_flag = 0
    local centerx, centery = 0, 0
    local temp = string.split(flag_str,",")
    if temp[1] then npc_id = tonumber(temp[1]) end
    if temp[2] then show_flag = tonumber(temp[2]) end
    if temp[3] then centerx = tonumber(temp[3]) end
    if temp[4] then centery = tonumber(temp[4]) end

    local pixesAvatar = CCGhostManager:getPixesAvatarByID(npc_id)
    if not pixesAvatar and pixesAvatar:NetAttr(Const.net_type) ~= Const.GHOST_NPC then return end

    if pixesAvatar:getSprite():getChildByName("npc_task") then
        if pixesAvatar:getSprite():getChildByName("npc_task") then pixesAvatar:getSprite():removeChildByName("npc_task") end
    end
    if show_flag / 10 % 10 == 1 then
        gameEffect.playEffectByType(gameEffect.EFFECT_WENHAO)
        :setPosition(cc.p(0,centery)):setName("npc_task"):addTo(pixesAvatar:getSprite(), 10)
    elseif show_flag % 10 == 1 then
        gameEffect.playEffectByType(gameEffect.EFFECT_TANHAO)
        :setPosition(cc.p(0,centery)):setName("npc_task"):addTo(pixesAvatar:getSprite(), 10)
    else
--        pixesAvatar:getSprite():removeChildByName("npc_task")
        -- 删除
    end
end

cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_UPDATE_NPC_FLAG,"update_npc_flag")

function UISceneGame.onShowMountProgressbar(event)
	if event then
		if not var.progress_bg then
			var.progress_bg = ccui.ImageView:create("uilayout/image/collect_bg2.png",UI_TEX_TYPE_LOCAL)
		    	:align(display.CENTER, Const.VISIBLE_WIDTH/2, Const.VISIBLE_HEIGHT/2-170)
		    	:setScale9Enabled(true):hide()
		    	:setScale(Const.minScale)
		        :addTo(var.scene,10)

			local mountUpBar = display.newProgressTimer("uilayout/image/collect_bar2.png", display.PROGRESS_TIMER_BAR)
			mountUpBar:setAnchorPoint(0.5,0.5)
			mountUpBar:setMidpoint(cc.p(0, 0.5))--设置进度条的起点，cc.p(0, 0.5)表示从最左边的中间为起点；
			mountUpBar:setBarChangeRate(cc.p(1.0, 0))--设置进度条变化速度，cc.p(1.0, 0)表示只在x轴上变化；
			mountUpBar:align(display.CENTER, var.progress_bg:getContentSize().width/2,var.progress_bg:getContentSize().height/2)
				:addTo(var.progress_bg)
				:setName("progress_bar")
				:setPercentage(0)
			local label_test = util.newUILabel({
				text = event.info,
				font = Const.DEFAULT_FONT_NAME,
				fontSize = 20,
			})
			:align(display.CENTER, var.progress_bg:getContentSize().width/2,var.progress_bg:getContentSize().height/2-30)
			:addTo(var.progress_bg)
		end
		var.progress_bg:show()
		local progress_bar = var.progress_bg:getChildByName("progress_bar")
		progress_bar:runAction(
			cca.seq({
				cc.ProgressFromTo:create(event.time/1000,0,100),
				cca.cb(
					function()
						var.progress_bg:hide()
						progress_bar:setPercentage(0)
						NetClient.m_bCollecting = false
					end
				)
			})
		)
	end
end

function UISceneGame.onStopProgressbar( event )
	if var.progress_bg then
		var.progress_bg:getChildByName("progress_bar"):stopAllActions()
		var.progress_bg:hide()
	end
end


function UISceneGame.printNodeTree()
    local file = io.open("NodeTree.txt","w")
    file:write("\n");
    local curData = os.date("*t")
    local fp = io.open(writeLogFileName, "a+")
    local content = string.format("%d-%d-%d, %02d:%02d:%02d\t print nodetree info ===>>>\n", curData.year, curData.month, curData.day, curData.hour, curData.min, curData.sec)
    UISceneGame.searchNodeTree(var.scene, 1,file)
end

function UISceneGame.searchNodeTree(node, level,file)
    local children = node:getChildren()
    for k,v in ipairs(children) do
        if v:getChildrenCount() > 0 then
            UISceneGame.writeNode(level, v:getName(), file, true)
            UISceneGame.searchNodeTree(v, level+1,file)
        else
            UISceneGame.writeNode(level, v:getName(), file, false)
        end
    end

end

function UISceneGame.writeNode(level, nodeName, file, hasChild)
    local str = ""
    for i = 1, level do
        str = "    "..str
    end

    if true == hasChild then
        str = str.."+"
    else
        str = str.."-"
    end
    str = table.concat({str, "[",level,"]",nodeName,"\n"})
    file:write(str)
end

return UISceneGame