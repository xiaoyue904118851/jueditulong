LayerRocker = {}

local var = {}

function LayerRocker.init()
	var = {
		layerRocker,
		rockerWidget,
		rockerTouch,
		rockerBlock,
		rockerBg,
		rocker,
		freeRocker=true,
		rockerCenter = cc.p(150,150),
		defaultPos = cc.p(150,150),
	}

	var.layerRocker = cc.Layer:create()

	-- ccui.Widget:setWidgetRect(true)

	var.rockerWidget = WidgetHelper:getWidgetByCsb("uilayout/MainUI/LayerRocker.csb")
	var.rockerWidget:setPosition(Const.leftBottom())
    var.rockerWidget:setScale(Const.minScale)

	var.layerRocker:addChild(var.rockerWidget)

	if var.rockerWidget then
		var.rockerTouch = var.rockerWidget:getChildByName("rocker_touch") -- 技能区域，屏蔽摇杆触摸
		var.rockerBlock = var.rockerWidget:getChildByName("block_area")
		var.rockerBg = var.rockerWidget:getChildByName("main_rocker_bg") -- 摇杆背景圈

		var.rocker = var.rockerWidget:getChildByName("main_rocker") -- 摇杆本身
		var.rocker:setTouchEnabled(false)
 		LayerRocker.changeRockerMode()

 		-- cc.EventProxy.new(NetClient,var.rockerWidget)
			-- :addEventListener(Notify.EVENT_CHANGE_ROCKER,LayerRocker.changeRockerMode)
			-- :addEventListener(Notify.EVENT_HAND_MODEL,LayerRocker.changeRockerSide)
 	end

	LayerRocker.registerLayerTouch()

	return var.layerRocker
end

function LayerRocker.registerLayerTouch()
	local touchID, TBPos, active, showRocker

	local function onTouchBegan(touch,event)
 		
 		local touchPos = touch:getLocation()

		if touchPos.y < Const.VISIBLE_Y + 70 then return false end --屏蔽聊天栏

		if MainRole.mCurSkillCircleID > 0 and not MainRole.mCurSkillUsed and not var.rockerTouch:hitTest(touchPos,cc.Camera:getVisitingCamera(),cc.Vertex3F(0.0, 0.0, 0.0)) then
			local skill_cd = 800
			if game.GetMainRole():NetAttr(Const.net_job) == Const.JOB_DS then skill_cd = 1000 end
			if game.getTime() - NetClient.mCastSkillTime >= skill_cd then
			    local screenPoint = cc.NetClient:getInstance():getMap():ScreenPoint()
			    local convertPos = UISceneGame.convertPos(touchPos)
			    local dis2RoleX = math.floor((convertPos.x-screenPoint.x-Const.VISIBLE_WIDTH/2)/64)
			    local dis2RoleY = math.floor((Const.VISIBLE_HEIGHT/2 - (convertPos.y-screenPoint.y))/32)
			    -- print(dis2RoleX,dis2RoleY)
			    MainRole.stopAutoMove()
				NetClient:UseSkill(MainRole.mCurSkillCircleID,game.GetMainRole():NetAttr(Const.net_x)+dis2RoleX,game.GetMainRole():NetAttr(Const.net_y)+dis2RoleY,0,0)
				if MainRole.mCurSkillCircleID ~= Const.SKILL_TYPE_HuoQiang then
					MainRole.mCurSkillUsed = true
					NetClient:dispatchEvent({name = Notify.EVENT_SKILL_USED})
				end
				MainRole.mAiKeepAttack = false
				-- MainRole.startCastSkill(MainRole.mCurSkillCircleID,game.GetMainRole():NetAttr(Const.net_x)+dis2RoleX,game.GetMainRole():NetAttr(Const.net_y)+dis2RoleY)
			end
			return
		end
		if not var.rockerTouch:hitTest(touchPos,cc.Camera:getVisitingCamera(),cc.Vertex3F(0.0, 0.0, 0.0)) then
			if UISceneGame.handleGhostsTouched(touchPos) then --or var.rockerBlock:hitTest(touchPos,cc.Camera:getVisitingCamera(),nil) 
				return false 
			end
		end 
		
		if not touchID then
			touchID = touch:getId() 
			
			if var.freeRocker then
				showRocker = false
				TBPos = var.rockerWidget:convertToNodeSpace(touchPos)
			else
				if var.rockerTouch:hitTest(touchPos,cc.Camera:getVisitingCamera(),cc.Vertex3F(0.0, 0.0, 0.0)) then
					var.rocker:setHighlighted(true)
					active = true
					local lbPos = var.rockerWidget:convertToNodeSpace(touchPos)
					LayerRocker.setRockerPosition(lbPos)
					-- LayerRocker.onRockerMoved(lbPos)
                else
--                    NetClient:dispatchEvent({name = Notify.EVENT_MAP_TOUCHED , pos = touchPos})
                    UISceneGame.findingTouchMove(touchPos, 1)
				end
			end
			return true
		end
	end
	local function onTouchMoved(touch,event)
		if touch:getId() ~= touchID then return end
		if var.freeRocker then
			local lbPos = var.rockerWidget:convertToNodeSpace(touch:getLocation())
			if showRocker then
				LayerRocker.onRockerMoved(lbPos,true)
			elseif cc.pDistanceSQ(TBPos,lbPos) > 10*10 then
				showRocker = true
				LayerRocker.setRockerPosition(lbPos)
				var.rocker:setVisible(true)
				-- LayerRocker.setRockerVisible(true)
				var.rocker:setHighlighted(true)
			end
		else
			local touchPos = touch:getLocation()
			if active then
				local lbPos = var.rockerWidget:convertToNodeSpace(touchPos)
				LayerRocker.onRockerMoved(lbPos,true)
			else
				UISceneGame.findingTouchMove(touchPos)
			end
		end
	end
	local function onTouchEnded(touch,event)
		if touch:getId() ~= touchID then return end
		touchID = nil
		showRocker = false
		local touchPos = touch:getLocation()
		if var.freeRocker then
			if cc.pDistanceSQ(TBPos,var.rockerWidget:convertToNodeSpace(touchPos)) < 3*3 then
				NetClient:dispatchEvent({name = Notify.EVENT_MAP_TOUCHED , pos = touchPos})
			else
				LayerRocker.onRockerReleased()
			end
			TBPos = nil
		else
			if active then
				LayerRocker.onRockerReleased(true)
				active = false
			else
				UISceneGame.findingTouchEnd(Const.center())
				NetClient:dispatchEvent({name = Notify.EVENT_MAP_TOUCHED , pos = touchPos})
				if MainRole.mAimGhostID > 0 then
					local mAimGhost = MainRole.getAimGhost(MainRole.mAimGhostID)
					if mAimGhost and mAimGhost:NetAttr(Const.net_type) == Const.GHOST_NPC then
						mAimGhost:getSprite():removeChildByName("selected")
						MainRole.mAimGhostID = 0
					end
				end
			end
		end
	end

	local _touchListener = cc.EventListenerTouchOneByOne:create()
	_touchListener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	_touchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
	_touchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
	_touchListener:setSwallowTouches(false)
	local eventDispatcher = var.layerRocker:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(_touchListener, var.layerRocker)
end


function LayerRocker.changeRockerMode(event)
	var.freeRocker = not var.freeRocker
	LayerRocker.setRockerfreeRocker(var.freeRocker)
end

function LayerRocker.setRockerfreeRocker(full)
	var.rocker:setVisible(not full)
	-- LayerRocker.setRockerVisible(not full)
	if not full then
		LayerRocker.setRockerPosition(var.defaultPos)
	else

	end
end

-- function LayerRocker.setRockerVisible(visible)
-- 	-- var.rockerBg:setVisible(visible)
-- 	-- var.rockerBg:setVisible(false)
-- 	var.rocker:setVisible(visible)
-- end

function LayerRocker.onRockerMoved(pos,moved)
	if cc.pDistanceSQ(var.rockerCenter,pos) > 60*60 then
		pos=cc.pAdd(var.rockerCenter,cc.pMul(cc.pNormalize(cc.pSub(pos,var.rockerCenter)),60))
	end
	var.rocker:setPosition(pos)
	-- print("LayerRocker.onRockerMoved",moved,LayerRocker.getScreenPosition(var.rockerCenter,pos).x,LayerRocker.getScreenPosition(var.rockerCenter,pos).y)
	if moved then
		UISceneGame.findingTouchMove(LayerRocker.getScreenPosition(var.rockerCenter,pos))
	end
end

function LayerRocker.getScreenPosition(cpoint,npoint)
	local rcpoint = UISceneGame.get_mainrole_pixespos()
	if not rcpoint then rcpoint=Const.center() end
	local scalex=math.min(Const.VISIBLE_WIDTH/60,Const.VISIBLE_HEIGHT/60)
	local resultpoint=cc.pSub(npoint,cpoint)
	local mappos=cc.pAdd(rcpoint,cc.p(resultpoint.x*scalex,resultpoint.y*scalex))
	return cc.p(mappos.x,mappos.y)
end

function LayerRocker.onRockerReleased(visible) --visible 摇杆是否可见
	if not visible then visible = false end
	
	var.rocker:setHighlighted(false)
	if visible then LayerRocker.setRockerPosition(var.defaultPos) end
	var.rocker:setVisible(visible)
	if visible then
		-- var.rocker:runAction(cca.seq({cca.scaleTo(0.1,0.7),cca.scaleTo(0.1,0.8)}))
	end
	-- LayerRocker.setRockerVisible(visible)
	UISceneGame.findingTouchEnd(Const.center())
end

function LayerRocker.setRockerPosition(pos)
	if not pos then 
		pos = var.rockerCenter 
	else
		var.rockerCenter = pos
	end
	var.rocker:setPosition(pos)
	var.rockerBg:setPosition(pos)
end

function LayerRocker.changeRockerSide(event)
	local rockerParam = {
		["normal"] = {defaultPos = cc.p(150,150), anchor = cc.p(0,0), pos = Const.leftBottom()},
		["reverse"]= {defaultPos = cc.p(-150,150), anchor = cc.p(1,0), pos = Const.rightBottom()}
	}
	
	local param = rockerParam[event.hand]
	if param then
		var.defaultPos = param.defaultPos
		var.rockerBlock:setAnchorPoint(param.anchor)
		var.rockerTouch:setAnchorPoint(param.anchor)
		var.rockerWidget:setAnchorPoint(param.anchor)
		var.rockerWidget:setPosition(param.pos)
	end
	LayerRocker.setRockerPosition(var.defaultPos)
end

function LayerRocker.hitTest(pos) -- 判断触摸
	if var.freeRocker then

	else
		if var.rockerTouch and var.rockerTouch:hitTest(pos,cc.Camera:getVisitingCamera(),cc.Vertex3F(0.0, 0.0, 0.0)) then
			return true
		end
	end
	return false
end