util = {} 
local NODE_TYPE={
	NODE_START_TAG= 1,   --开始标签,如 <a href="liigo.com"> 或 <br/>
	NODE_END_TAG=	2,   --结束标签,如 </a>
	NODE_CONTENT=	3,   --内容: 介于开始标签和/或结束标签之间的普通文本
	NODE_REMARKS=	4,   --注释: <!-- -->
	NODE_UNKNOWN=	5,   --未知的节点类型
}

local TAG_TYPE={
	TAG_A=			11,
	TAG_BR=			28,
	TAG_FONT=		51,
	TAG_HTML=		66,
	TAG_P=			91,
	TAG_ITEM=		151,
	TAG_F=			152,
	TAG_PIC=		153,
	TAG_TASKPIC=	154,
	TAG_TASKNPC=	155,
	TAG_TASKTARGET= 156,
	TAG_LINE=		157,
}

local QualityColor = {
    [1] = cc.c3b(255,255,255),
    [2] = cc.c3b(0,255,0),
    [3] = cc.c3b(0,255,255),
    [4] = cc.c3b(51,0,255),
    [5] = cc.c3b(255,0,255),
    [6] = cc.c3b(255,138,0),
}

local OxQualityColor = {
    [1] = "#FFFFFF",
    [2] = "#00FF00",
    [3] = "#00FFFF",
    [4] = "#3300FF",
    [5] = "#FF00FF",
    [6] = "#FF8A00",
}

function util.Quality2color( quality)
    if not quality then return end
    game.getColor(quality)
end

--function util.Quality2color( quality, ox )
--    if not quality then return end
--    local color = QualityColor[quality]
--    if ox then color = OxQualityColor[quality] end
--    if not color then
--        color = quality --兼容老版本
--    end
--    return color
--end

function util.getDistance(x0, y0, x1, y1)
	local result = math.sqrt((x0 - x1) * (x0 - x1) + (y0 - y1) * (y0 - y1))
	return result
end

function util.moveAnime(clone, primitive, x0, y0, x1, y1, callback)
	local lastingTime = util.getDistance(x0, y0, x1, y1) / 800
	primitive.isRunningAction = true
	clone:stopAllActions()
	clone:runAction(
		cc.Sequence:create(
			cc.EaseExponentialOut:create(cc.MoveTo:create(lastingTime,cc.p(x1, y1))),
			cc.CallFunc:create(
			function ()
				if callback then
					callback()
				end
				primitive:setVisible(true)
				primitive.isRunningAction = false
				clone:removeFromParent()
			end)))
end

function util.addSlideMove(panel, slideOutCallBack)
	local posbegan,posmove,posend,timeBegan,timeMove
	local panelPosX = panel:getPositionX()
	local panelPosY = panel:getPositionY()
	local panelSize = panel:getContentSize()
	local lastingTime

	local function onSlideBack(direction)
		lastingTime = math.abs(panelPosX - panel:getPositionX()) / 800
		panel:stopAllActions()
		panel:runAction(
			cc.EaseSineOut:create(
				cc.MoveTo:create(lastingTime, panel.defaultPos)
			)
		)
	end

	local function onSlideOut(moveVector)
		local function callback(dx)
			-- print("callback")
			if slideOutCallBack then
				slideOutCallBack()
			end
		end
		local moveDistance
		local missPosX
		local panelPosX = panel:getPositionX()
		if moveVector < 0 then--往右边移动
			moveDistance = display.width - panelPosX + panel:getAnchorPoint().x * panelSize.width
			missPosX = display.width + panel:getAnchorPoint().x * panelSize.width + 50
		else
			moveDistance = panelPosX + (1 - panel:getAnchorPoint().x) * panelSize.width
			missPosX = (panel:getAnchorPoint().x - 1) * panelSize.width - 50
		end

		if moveDistance < 0 then
			if slideOutCallBack then
				slideOutCallBack()
			end
			return
		end

		lastingTime = moveDistance / 1600
		panel:stopAllActions()
		panel:runAction(
			cc.Sequence:create(
				cc.EaseSineOut:create(
					cc.MoveTo:create(
						lastingTime, cc.p(missPosX, panel:getPositionY())
					)
				),
				cc.CallFunc:create(callback)
			)
		)

	end

    local function slidelayer(sender, touch_type)
    	print("touch_type",touch_type)
    	if not sender.touchState then sender.touchState = touch_type end

    	if sender.touchState > touch_type then return end

    	sender.touchState = touch_type

		if touch_type == ccui.TouchEventType.began then
			posbegan = sender:getTouchBeganPosition()
			timeBegan = game.getTime()
		elseif touch_type == ccui.TouchEventType.moved then
			local ignoreLength = 100
			posmove = sender:getTouchMovePosition()
			if not posbegan then posbegan = posmove end
			if math.abs(posbegan.x-posmove.x) > ignoreLength then
				panel:setPositionX(posmove.x-posbegan.x+panelPosX+ignoreLength*(posbegan.x-posmove.x)/math.abs(posbegan.x-posmove.x))
			end
		elseif (touch_type == ccui.TouchEventType.ended) or (touch_type == ccui.TouchEventType.canceled) then
			if posmove then
				if math.abs(posbegan.x-posmove.x) > 200 then
					onSlideOut(posbegan.x-posmove.x)
				elseif math.abs(posbegan.x-posmove.x) > 150 then
					local speed  = math.abs(posbegan.x-posmove.x) / (game.getTime()-timeBegan)
					if speed >1500 then
						onSlideOut(posbegan.x-posmove.x)
					else
						posend = sender:getTouchEndPosition()
						onSlideBack(posbegan.x-posend.x)
					end
				else
					posend = sender:getTouchEndPosition()
					onSlideBack(posbegan.x-posend.x)
				end
				posbegan,posmove,posend,timeBegan=nil
			end
			sender.touchState = nil
		end
	end

	local dragArea = ccui.Widget:create()
	dragArea:setName("dragArea")
	dragArea:setContentSize(panelSize)
	dragArea:setAnchorPoint(cc.p(0, 0))
	panel:addChild(dragArea,10)
	dragArea:setTouchEnabled(true)
	dragArea:setSwallowTouches(false)
	dragArea:addTouchEventListener(slidelayer)
end

function util.setPanelMoveEnabled(panel, movable)
	local dragArea = panel:getWidgetByName("dragArea")
	if dragArea then
		if movable then
			dragArea:setTouchEnabled(true)
			dragArea:setSwallowTouches(false)
		else
			dragArea:setTouchEnabled(false)
		end
	end
end

function util.newRichLabel(size,space)
	if not space then
		space = 0
	end
	local richlabel=ccui.RichText:create()
	richlabel:ignoreContentAdaptWithSize(false)
	richlabel:setContentSize(size)
	richlabel:setAnchorPoint(cc.p(0,0))
	richlabel:setVerticalSpace(space)
	local richWidget = ccui.Widget:create()
	richWidget:setAnchorPoint(cc.p(0,0))
	richWidget:addChild(richlabel)
	return richlabel,richWidget
end
function util.setRichLabel(richlabel,htmltext,parent,tsize,decolor)
--    C++没有这个方法 暂时屏蔽
--	richlabel:removeAllElement()

	if not parent then
		parent = ""
	end

	htmltext,n=string.gsub(htmltext,"\t"," ")
	htmltext,n=string.gsub(htmltext,"\r","")
	-- htmltext,n=string.gsub(htmltext,"%c","<br>")

	local parser=cc.HtmlParser:new()
	tolua.takeownership(parser)

	parser:parseHtml(htmltext)

	local msize=20
	if tsize then
		msize=tsize
    end
    local mcolor="0xffffff"
    if decolor then
        mcolor=decolor
    end

	local brCount = 0
	local tag_a=false
	local index=0
	local Dcolor=mcolor
	local Dsize=msize
	local Tcolor = {[1]=mcolor}
	local Tsize = {[1]=msize}
	print(htmltext)
	for i=0,parser:getHtmlNodeCount()-1 do
		local pNode=parser:getHtmlNode(i)
		print("pNode:getType() == ",pNode:getType())
		if pNode:getType()==NODE_TYPE.NODE_START_TAG then
			print("pNode:getTagType() == ",pNode:getTagType())
			if pNode:getTagType()~=TAG_TYPE.TAG_BR then
				brCount=0
			end

			if pNode:getTagType()==TAG_TYPE.TAG_FONT then

				local tempcolor=cc.HtmlParser:getAttributeStringValue(pNode,"color","ffffff")
				table.insert(Tcolor,"0x"..string.sub(tempcolor,2))

				local tempsize=cc.HtmlParser:getAttributeIntValue(pNode,"size",msize)
				table.insert(Tsize,tempsize)

			elseif pNode:getTagType()==TAG_TYPE.TAG_BR then

				brCount = brCount + 1
				local height = 0
				if brCount >1 and parent ~= "panel_npctalk" then
--					height = 10
				end
				local ccnode=cc.Node:create()
				ccnode:setContentSize(cc.size(richlabel:getCustomSize().width,height))
				local element=ccui.RichElementCustomNode:create(index,display.COLOR_WHITE,255,ccnode)
				richlabel:pushBackElement(element)
				index=index+1
			elseif pNode:getTagType()==TAG_TYPE.TAG_PIC then
				local picfile = cc.HtmlParser:getAttributeStringValue(pNode,"src")
				if picfile and tostring(picfile)~="" then
					local sprite=cc.Sprite:create()
					sprite:setSpriteFrame(tostring(picfile))
					if sprite then
						local element=ccui.RichElementCustomNode:create(index,cc.c3b(255,255,255),0,sprite)
						richlabel:pushBackElement(element)
						index=index+1
					end
				end
			elseif pNode:getTagType()==TAG_TYPE.TAG_P then

				brCount = brCount + 1
				local height = 0
				if brCount >1 then
					height = 20
				end
				tag_a=true
				local ccnode = parser:getHtmlNode(i+1)
				if ccnode:getType() == NODE_TYPE.NODE_CONTENT then
					local function linktouch(pSender)
						util.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
					end
					local tempStr=ccnode:getText()
                    local labelStr = tempStr
                    local attr = string.split(tempStr, ",")
                    if attr and attr[2] then
                        local itemdef = NetClient:getItemDefByID(checkint(attr[2]))
                        if itemdef then
                            labelStr = "["..itemdef.mName.."]"
                        end
                    end

					local label = util.newUILabel({
						text = labelStr,
						fontSize = Tsize[#Tsize]+2,
						anchor = cc.p(1,0.5),
						color = cc.c3b(0,255,0),
						position = cc.p(320,110),
					})
					label:setLocalZOrder(10)
					label:setTouchEnabled(true)
--					label.user_data="event:local_itemname_"..tempStr
                    label.user_data="event:itemshow_"..tempStr
					label:addClickEventListener(linktouch)
					local element=ccui.RichElementCustomNode:create(index,Const.COLOR_GREEN_1_C3B,255,label)
					richlabel:pushBackElement(element)
					index=index+1
				end
			elseif pNode:getTagType()==TAG_TYPE.TAG_A then
				local link = ""
                local islabel = false
                local ttcolor = cc.c3b(255,172,8)
				if parser:getHtmlNodeCount() > 0 then
					link = cc.HtmlParser:getAttributeStringValue(pNode,"href")
                    islabel = (checkint(cc.HtmlParser:getAttributeStringValue(pNode,"islabel")) == 1)
                    local ttempcolor = cc.HtmlParser:getAttributeStringValue(pNode,"color")
                    if ttempcolor then
                        ttcolor = game.getColor(ttempcolor)
                    else
                        ttcolor = Const.COLOR_GREEN_1_C3B
                    end
				end
				tag_a=true
				local ccnode = parser:getHtmlNode(i+1)
				if ccnode:getType() == NODE_TYPE.NODE_CONTENT then
					local tempStr=ccnode:getText()
                    tempStr=game.clearHtmlText(tempStr)
--                    if islabel then
                        local label = util.newUILabel({
                            text = tempStr,
                            font = Const.DEFAULT_FONT_NAME,
                            fontSize = Tsize[#Tsize],
                            color = ttcolor,
                        })
                        label:setTouchEnabled(true)
                        label.user_data=link
                        label:addClickEventListener(function (pSender)
                            util.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
                        end)
                        local element=ccui.RichElementCustomNode:create(index,ttcolor,255,label)
                        richlabel:pushBackElement(element)
					index=index+1
				end
			end

		elseif pNode:getType()==NODE_TYPE.NODE_CONTENT then
			if tag_a then 
				tag_a=false
			else
				local text=pNode:getText()
				if text then
					local tempStr=game.clearHtmlText(text)
					local tcolor=Dcolor
					if tonumber(Tcolor[#Tcolor]) then tcolor=tonumber(Tcolor[#Tcolor]) end
					local element=ccui.RichElementText:create(index,game.getColor(tcolor),255,tempStr,Const.DEFAULT_FONT_NAME,Tsize[#Tsize])
					richlabel:pushBackElement(element)
					index=index+1
				end
			end
		elseif pNode:getType()==NODE_TYPE.NODE_END_TAG then
			if pNode:getTagName()=="font" then
				table.remove(Tcolor,#Tcolor)
				table.remove(Tsize,#Tsize)
			end
		end

	end
	richlabel:formatText()
	richlabel:setPosition(cc.p(0,richlabel:getRealHeight()))
    parser:cleanHtmlNodes()
end
function util.setRichLabel11(richlabel,htmltext,parent,tsize,decolor)
--    C++没有这个方法 暂时屏蔽
--	richlabel:removeAllElement()

	if not parent then
		parent = ""
	end

	-- htmltext,n=string.gsub(htmltext,"\t"," ")
	-- htmltext,n=string.gsub(htmltext,"\r","")
	-- htmltext,n=string.gsub(htmltext,"%c","<br>")

	-- local parser=cc.HtmlParser:new()
	-- tolua.takeownership(parser)

	-- parser:parseHtml(htmltext)

	local msize=20
	if tsize then
		msize=tsize
    end
    local mcolor="0xffffff"
    if decolor then
        mcolor=decolor
    end

	local brCount = 0
	local tag_a=false
	local index=0
	local Dcolor=mcolor
	local Dsize=msize
	local Tcolor = {[1]=mcolor}
	local Tsize = {[1]=msize}
	local html_ = htmlParse.parsestr(htmltext)
	print("htmltext == ",htmltext)

	-- local  htmlIndex = 1
	-- local count = #html_
	-- if #html_ > 1 then
	-- 	print("count == ",count)
	-- 		for i=1, count do
	-- 			local curIndex = htmlIndex
	-- 			local nextIndex = htmlIndex+1
	-- 			local pNode = html_[curIndex]
	-- 			print("文本 == ",curIndex)
	-- 			dump(pNode)
	-- 			if nextIndex>count then

	-- 			else
	-- 				  print("type == ",type(pNode))
	-- 				  if type(pNode)=="table"  then

	-- 				  else
	-- 						local function linktouch(pSender)
	-- 							util.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
	-- 						end
	-- 						local tempStr=pNode
	-- 	                    local labelStr = tempStr
	-- 	                    local attr = string.split(tempStr, ",")
	-- 	                    if attr and attr[2] then
	-- 	                        local itemdef = NetClient:getItemDefByID(checkint(attr[2]))
	-- 	                        if itemdef then
	-- 	                            labelStr = "["..itemdef.mName.."]"
	-- 	                        end
	-- 	                    end

	-- 						local label = util.newUILabel({
	-- 							text = labelStr,
	-- 							fontSize = Tsize[#Tsize]+2,
	-- 							anchor = cc.p(1,0.5),
	-- 							color = cc.c3b(0,255,0),
	-- 							position = cc.p(320,110),
	-- 						})
	-- 						label:setLocalZOrder(10)
	-- 						-- label:setTouchEnabled(true)
	-- 	--					label.user_data="event:local_itemname_"..tempStr
	-- 	                    label.user_data="event:itemshow_"..tempStr
	-- 						-- label:addClickEventListener(linktouch)
	-- 						local element=ccui.RichElementCustomNode:create(index,Const.COLOR_GREEN_1_C3B,255,label)
	-- 						richlabel:pushBackElement(element)
	-- 						index=index+1
	-- 				  end

	-- 				local pNodeArr = html_[nextIndex]
	-- 				htmlIndex = nextIndex+1
	-- 				print("属性 = =")
	-- 				dump(pNodeArr)
	-- 			end
	
	-- 		end
	-- else
	-- 						local function linktouch(pSender)
	-- 							util.touchlink(pSender,ccui.TouchEventType.ended,parent,richlabel)
	-- 						end
	-- 						local tempStr=htmltext
	-- 	                    local labelStr = tempStr
	-- 	                    local attr = string.split(tempStr, ",")
	-- 	                    if attr and attr[2] then
	-- 	                        local itemdef = NetClient:getItemDefByID(checkint(attr[2]))
	-- 	                        if itemdef then
	-- 	                            labelStr = "["..itemdef.mName.."]"
	-- 	                        end
	-- 	                    end

	-- 						local label = util.newUILabel({
	-- 							text = labelStr,
	-- 							fontSize = Tsize[#Tsize]+2,
	-- 							anchor = cc.p(1,0.5),
	-- 							color = cc.c3b(0,255,0),
	-- 							position = cc.p(320,110),
	-- 						})
	-- 						label:setLocalZOrder(10)
	-- 						label:setTouchEnabled(true)
	-- 	--					label.user_data="event:local_itemname_"..tempStr
	-- 	                    label.user_data="event:itemshow_"..tempStr
	-- 						label:addClickEventListener(linktouch)
	-- 						local element=ccui.RichElementCustomNode:create(index,Const.COLOR_GREEN_1_C3B,255,label)
	-- 						richlabel:pushBackElement(element)
	-- 				-- index=index+1
			
	-- end
	dump(html_)
		-- if ccnode:getType() == NODE_TYPE.NODE_CONTENT then
		

	richlabel:formatText()
	richlabel:setPosition(cc.p(0,richlabel:getRealHeight()))
    -- parser:cleanHtmlNodes()
end

function util.touchlink(pSender,touch_type,parent,richlabel)
	-- if touch_type == ccui.TouchEventType.ended then
		local pWidget = pSender
		-- local _touchEndPos = cc.p(pWidget:getTouchEndPosition().x,pWidget:getTouchEndPosition().y)
		local paramlist = pWidget.user_data
        -- print("util.touchlink====", paramlist,parent)
		if pWidget then
			local m_nSeed = NetClient.m_nNpcTalkId
			if paramlist and paramlist ~= "" then
				if string.find(paramlist,"ui_accept_task") then

				elseif string.find(paramlist,"ui_done_task") then

				end
				if not string.find(paramlist,"event:") then
					return
				else
					paramlist = string.sub(paramlist,7)
				end
				local param = string.split(paramlist, "_")
				if #param <= 0 then
					return
				end
				if param[1] == "talk" then
					if #param > 1 then
						if parent == "panel_npctalk" then
							if NetClient.m_nTalkType then
								if NetClient.m_nTalkType == "npc" then
									NetClient:NpcTalk(m_nSeed,param[2])
								elseif NetClient.m_nTalkType == "player" then
									NetClient:PlayerTalk(m_nSeed,param[2])
                                    -- NetClient:ServerScript(param[2])
								end
							end
						elseif parent == "panel_playertalk" then
							NetClient:PlayerTalk(m_nSeed,param[2])
						elseif parent == "panel_itemtalk" then
							NetClient:ItemTalk(NetClient.m_nItemTalkId,m_nSeed,param[2])
						end
					end
				elseif param[1] == "local" then
					if param[2] and param[3] and param[2] == "chat" then
						NetClient:privateChatTo(param[3])
					elseif param[2] == "goto" then
						local walktag = 2
						if #param==4 then
							local xx=tonumber(param[3])
							local yy=tonumber(param[4])
							MainRole.setTargetRoad(NetClient.mNetMap.mMapID,xx,yy)
                            local mainRole = CCGhostManager:getMainAvatar()
							mainRole:startAutoMoveToPos(xx,yy,walktag)
						end
						if #param==5 or #param==6 then
							local map_name=param[3]
							local xx=tonumber(param[4])
							local yy=tonumber(param[5])
							if #param==6 then MainRole.mTargetNPCName=param[6] end
							MainRole.startAutoMoveToMap(map_name,xx,yy,walktag)
                        end
                    elseif param[2] == "superring" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_specailring"})
					elseif param[2] == "zhouhuan" then
						NetClient:PushLuaTable("npc.biqi.paohuan.onGetJsonData",util.encode({actionid = "fly",target_id = param[3]}))
					elseif param[2] == "HelpQiandao" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_award_hall",  pdata = {tag = 2}})
                    elseif param[2] == "HelpHuiShou" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag",  pdata = {tag = 2}})
                    elseif param[2] == "personalBoss" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_challenge_boss",  pdata = {tag = 5}})
                    elseif param[2] == "HelpChongzhi" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
                    elseif param[2] == "HelpRefineexp" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_refine_exp"})
                    elseif param[2] == "HelpBoss" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_challenge_boss",  pdata = {tag = 1}})
                    elseif param[2] == "HelpGuildHuodong" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_guild",  pdata = {tag = 4}})
                    elseif param[2] == "HelpGuildDepot" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_guild",  pdata = {tag = 2}})
                    elseif param[2] == "wsxunbao" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_xunbao"})
                    elseif param[2] == "showvip" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_vip"})
                    elseif param[2] == "openshop" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_mall",  pdata = {tag = 1}})
                    elseif param[2] == "wsqianghua" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_smelter",  pdata = {tag = 1}})
                    elseif param[2] == "baoshi" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_shenlu",  pdata = {tag = 2}})
                    elseif param[2] == "dunpai" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_shenlu",  pdata = {tag = 3}})
                    elseif param[2] == "jianjia" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_shenlu",  pdata = {tag = 1}})
                    elseif param[2] == "xunzhang" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_achieve",  pdata = {tag = 2}})
                    elseif param[2] == "yuanshen" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_roleInfo",  pdata = {tag = 4}})
                    elseif param[2] == "zuoqi" then
                        --EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_guild",  pdata = {tag = 4}})
                    elseif param[2] == "chibang" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_wing"})
                    elseif param[2] == "privilegecard" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_privilege_card"})
                    elseif param[2] == "firstCharge" then
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_firstcharge"})
                    else
                        NetClient:alertLocalMsg(paramlist.."开发中，稍安勿躁！","alert")
                    end
				elseif param[1]=="fly" then
					NetClient:DirectFly(param[2])
				elseif param[1] == "speeker" then
                    if param[2] and param[2] ~= game.GetMainNetGhost():NetAttr(Const.net_name) then
                        UILeftTop.showOtherOpPanelFromChat(param[2])
                    end
                elseif param[1] == "itemshow" then
                    if param[2] then
                        local netitem = game.parseChatItemTip(param[2])
                        NetClient:dispatchEvent(
                            {
                                name = Notify.EVENT_HANDLE_ITEM_TIPS,
                                pos = netitem.position,
                                otherItem = netitem,
                                typeId = netitem.mTypeID,
                            })
                    end
                end
				NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = parent})
			end
		end
	-- end
end

function util.litenerTaskLink(paramstr,flystr)
	local param=string.split(paramstr,"_")
	local mainRole = CCGhostManager:getMainAvatar()
	if param then
		if param[1]=="local" then
			local walktag=2
			if param[2]=="goto" or param[2]=="walkto" then
				if param[2]=="walkto" then walktag=3 end
				if #param==4 then
					local xx=tonumber(param[3])
					local yy=tonumber(param[4])
                    MainRole.setTargetRoad(NetClient.mNetMap.mMapID,xx,yy)
					mainRole:startAutoMoveToPos(xx,yy,walktag)
				end
				if #param==5 or #param==6 then
					local map_name=param[3]
					local xx=tonumber(param[4])
					local yy=tonumber(param[5])
					if #param==6 then MainRole.mTargetNPCName=param[6] end
					MainRole.startAutoMoveToMap(map_name,xx,yy,walktag,flystr)
				end
				-- NetClient:PushLuaTable("gui.PanelMount.onPanelData",util.encode({ actionid= "mounting",}))
				-- NetClient:ChangeMount()
			elseif param[2] == "zhouhuan" then
				NetClient:PushLuaTable("npc.biqi.paohuan.onGetJsonData",util.encode({actionid = "fly",target_id = param[3]}))
			elseif param[2] == "ymsy" then
                NetClient:PushLuaTable("chuansong",util.encode({actionid = "get_shengyu_data"}))
            elseif param[2] == "BuyGiftBag" then
                NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_super_value" })
            elseif param[2] == "personalBoss" then
                NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_challenge_boss", pdata = { tag = 5 }})
            elseif param[2] == "wssjboss" then
                NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_challenge_boss" })
            end
		elseif param[1]=="fly" then
			NetClient:DirectFly(param[2])
		elseif param[1]=="click" then
			NetClient:ServerScript(param[2])
		elseif param[1]=="open" then
			if #param==3 then
				NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = param[2].."_"..param[3]})
			end
		end
		-- game.NetClient():dispatchEvent({name=Notify.EVENT_GUIDE_SWITCH})
	end
end

function util.decode(text)
	return json.decode(text)
end

function util.encode(text)
	return json.encode(text)
end

function util.changeHandPos(panel, skipChildrenName)
	local children = panel:getChildren()
	local size = panel:getContentSize()
	local need2Skip
	for i,v in ipairs(children) do
		local childName = v:getName()
		need2Skip = false
		if skipChildrenName then
			for i,v in ipairs(skipChildrenName) do
				if childName == v then
					need2Skip = true
					break
				end
			end
		end
		if not need2Skip then
			v:setPositionX((size.width - v:getPositionX()))
		end
	end
end

function util.httpRequest(url,listener)
    -- local request = network.createHTTPRequest(listener,url,"GET")
    -- request:addPOSTValue("KEY", "VALUE")
    -- request:setTimeout(8)
    -- request:start()
    -- return request
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("GET",url)
    xhr:registerScriptHandler(listener)
    xhr:send()
    return xhr
end

--[[--

创建一个文字输入框,并返回 CCEditBox 对象。

可用参数：

-   image: 输入框的图像,可以是图像名或者是 cc.Sprite9Scale 显示对象。用 display.newScale9Sprite() 创建 cc.Sprite9Scale 显示对象。
-   imagePressed: 输入状态时输入框显示的图像（可选）
-   imageDisabled: 禁止状态时输入框显示的图像（可选）
-   listener: 回调函数
-   size: 输入框的尺寸,用 CCSize(宽度, 高度) 创建
-   x, y: 坐标（可选）

~~~ lua

local function onEdit(event, editbox)
	if event == "began" then
		-- 开始输入
	elseif event == "changed" then
		-- 输入框内容发生变化
	elseif event == "ended" then
		-- 输入结束
	elseif event == "return" then
		-- 从输入框返回
	end
end

local editbox = util.newEditBox({
	image = "EditBox.png",
	listener = onEdit,
	size = CCSize(200, 40)
})

~~~

注意: 使用setInputFlag(0) 可设为密码输入框。

注意：构造输入框时,请使用setPlaceHolder来设定初始文本显示。setString为出现输入法后的默认文本。

注意：事件触发机制,player模拟器上与真机不同,请使用真机实测(不同ios版本貌似也略有不同)。

注意：changed事件中,需要条件性使用setString（如trim或转化大小写等）,否则在某些ios版本中会造成死循环。

~~~ lua

--错误,会造成死循环

editbox:setString(string.trim(editbox:getText()))

~~~

~~~ lua

--正确,不会造成死循环
local _text = editbox:getText()
local _trimed = string.trim(_text)
if _trimed ~= _text then
	editbox:setString(_trimed)
end

~~~

@param table params 参数表格对象

@return CCEditBox 文字输入框

]]
function util.newEditBox(params)
	local imageNormal = params.image
	local imagePressed = params.imagePressed
	local imageDisabled = params.imageDisabled

	if type(imageNormal) == "string" then
		if string.byte(imageNormal) == 35 then
			imageNormal = ccui.Scale9Sprite:create()
			imageNormal:initWithSpriteFrame(display.newSpriteFrame(string.sub(params.image, 2)))
		else
			imageNormal = ccui.Scale9Sprite:create(imageNormal)
		end
	end
	if type(imagePressed) == "string" then
		if string.byte(imagePressed) == 35 then
			imagePressed = ccui.Scale9Sprite:create()
			imagePressed:initWithSpriteFrame(display.newSpriteFrame(string.sub(params.imagePressed, 2)))
		else
			imagePressed = ccui.Scale9Sprite:create(imagePressed)
		end
	end
	if type(imageDisabled) == "string" then
		if string.byte(imageDisabled) == 35 then
			imageDisabled = ccui.Scale9Sprite:create()
			imageDisabled:initWithSpriteFrame(display.newSpriteFrame(string.sub(params.imageDisabled, 2)))
		else
			imageDisabled = ccui.Scale9Sprite:create(imageDisabled)
		end
	end

	local editbox = ccui.EditBox:create(params.size, imageNormal, imagePressed, imageDisabled)
	editbox:setFontName(Const.DEFAULT_FONT_NAME)
	editbox:setPlaceholderFontName(Const.DEFAULT_FONT_NAME)

	if editbox then
		if params.color then
			editbox:setFontColor(params.color)
		end

		if params.listener then
			editbox:registerScriptEditBoxHandler(params.listener)
		end
		
		if params.x and params.y then
			editbox:setPosition(params.x, params.y)
		end

		if params.placeHolder then
			editbox:setPlaceHolder(params.placeHolder)
			if params.placeHolderColor then
				editbox:setPlaceholderFontColor(params.placeHolderColor)
			end
			if params.placeHolderSize then
				editbox:setPlaceholderFontSize(params.placeHolderSize)
			end
		end

		if params.inputMode then
			editbox:setInputMode(params.inputMode)
		else
            editbox:setInputMode(Const.EditBox_InputMode.SINGLE_LINE)
        end

		if params.anchor then
			editbox:setAnchorPoint(params.anchor)
		else
			editbox:setAnchorPoint(cc.p(0.5, 0.5))
		end

		if params.fontSize then
			editbox:setFontSize(params.fontSize)
		end	
	end
	editbox:setInputFlag(1)
	editbox.setString = editbox.setText
	return editbox
end

function util.newTextField(param)
	local textfield=ccui.TextField:create()

	if param.size then
		textfield:setContentSize(param.size)
		textfield:setTouchSize(param.size)
		textfield:setTouchAreaEnabled(true)
	end
	if checkint(param.x) and checkint(param.y) then
		textfield:setPosition(cc.p(param.x,param.y))
	end
	if type(param.place)=="string" then
		textfield:setPlaceHolder(param.place)
	else
		textfield:setPlaceHolder("")
	end
	if checkint(param.fontsize) then
		textfield:setFontSize(param.fontsize)
	else
		textfield:setFontSize(22)
	end
	if checkint(param.maxlen) then
		textfield:setMaxLengthEnabled(true)
		textfield:setMaxLength(param.maxlen)
	end
	if param.anchor then
		textfield:setAnchorPoint(param.anchor)
	end
	if type(listener)=="function" then
		textfield:addEventListener(listener)
	end

	textfield.getText=textfield.getString
	textfield.setString=textfield.setText

	return textfield
end

function util.initNavBar(param)

	local function pushMenuButton(pSender)
		-- if touch_type == ccui.TouchEventType.ended then
			NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = param.from}) --关闭当前面板
			NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = pSender.pName}) --打开相应面板
		-- end
	end

	local navBar = ccui.Widget:create()
	navBar:setContentSize(cc.size(100,640))
	local btnBack = ccui.Button:create("item_icon.png")
	btnBack:setTitleText(param.back.text)
	btnBack.pName = param.back.pName
	btnBack:addClickEventListener(pushMenuButton)
	btnBack:align(2,2,630)
	btnBack:setTitleFontSize(28)
	navBar:addChild(btnBack)

	local listBar = ccui.ListView:create()
	listBar:setClippingEnabled(true)
	listBar:setContentSize(cc.size(80,480))
	listBar:setInnerContainerSize(cc.size(220,#param.bar*100))
	listBar:align(7,10,30)
	listBar:setDirection(1)
	listBar:setItemsMargin(20)
	listBar:setTouchEnabled(true)
	listBar:setBounceEnabled(true)

	navBar:addChild(listBar)

	for i,v in ipairs(param.bar) do
		local btnMenu = ccui.Button:create()
		btnMenu:loadTextures("btn_color_6.png","btn_color_6_sel.png")
		btnMenu:setScale9Enabled(true)
		btnMenu:setContentSize(cc.size(80,80))
		btnMenu:setTitleText(v.text)
		btnMenu.pName = v.pName
		btnMenu:addTouchEventListener(pushMenuButton)
		listBar:pushBackCustomItem(btnMenu)
	end
	return navBar
end

function util.tabValueCopy(ori_tab)--table的浅拷贝
    if (type(ori_tab) ~= "table") then
        return nil;
    end
    local new_tab = {};
    for i,v in pairs(ori_tab) do
        local vtyp = type(v);
        if (vtyp == "table") then
            new_tab[i] = tabValueCopy(v);
        elseif (vtyp == "thread") then
            -- TODO: dup or just point to?
            new_tab[i] = v;
        elseif (vtyp == "userdata") then
            -- TODO: dup or just point to?
            new_tab[i] = v;
        else
            new_tab[i] = v;
        end
    end
    return new_tab;
end

--处理同一个控件短时间内多次触摸
function util.handleMultiTouchTimes(widget, exeFuncByTimes)
	local function  runOnce(dx)
		print("finish", widget.touchTimes)
		exeFuncByTimes(widget)
		widget.touchTimes = 0
		if widget.simulateHandle then
			Scheduler.unscheduleGlobal(widget.simulateHandle)
			widget.simulateHandle = nil
		end
	end

	local function touchCB(sender, touchType)
		if touchType == ccui.TouchEventType.began then
			if widget.simulateHandle then
				Scheduler.unscheduleGlobal(widget.simulateHandle)
				widget.simulateHandle = nil
			end
		
		elseif touchType == ccui.TouchEventType.ended then
			if not widget.simulateHandle then
				widget.simulateHandle = Scheduler.scheduleGlobal(runOnce, 0.2)
			end
			if not widget.touchTimes then
				widget.touchTimes = 0
			end
			widget.touchTimes = widget.touchTimes + 1
		end
	end
	widget:addTouchEventListener(touchCB)
end

function util.newUILabel(table)
	if table then
		if not table.text then table.text = "" end
		if not table.font then table.font = Const.DEFAULT_FONT_NAME end
		if not table.fontSize then table.fontSize = 24 end
		if not table.color then table.color = display.COLOR_WHITE end
	end
	local uiLabel = ccui.Text:create(table.text,table.font,table.fontSize)
	uiLabel:setColor(table.color)
	if table.contentSize then
		uiLabel:setContentSize(table.contentSize.width,table.contentSize.height)
	end
	if table.anchor then
		uiLabel:setAnchorPoint(table.anchor)
	end
	if table.position then
		uiLabel:setPosition(table.position)
	end
	if table.mName then
		uiLabel:setName(table.mName)
	end
	if table.opacity then
		uiLabel:setOpacity(table.opacity)
	end
	return uiLabel
end

function util.pEqual(pt1, pt2)
	if not pt1 or not pt2 then return false end
    if pt1.x == pt2.x and pt1.y == pt2.y then
        return true
    end
    return false
end

function util.setBuffNum(imgBuff, params)--创建的时候params是table类型，修改的时候是数字或者string
	local lblBuffNum = imgBuff:getWidgetByName("lblBuffNum")
	if not lblBuffNum then
		display.newTTFLabel(params)
			:addTo(imgBuff)
			:setName("lblBuffNum")
		return
	end
	if type(params) == "number" or type(params) == "string" then
		params = checkint(params)
		if params == 0 then params = "" end
		lblBuffNum:setString(params)
	end
end

function util.getWidgetCenterPos(widget)
	if widget then
		local anchor = widget:getAnchorPoint()
		local pos = widget:getAnchorPointInPoints()

		local m_pos = widget:convertToWorldSpace(cc.p((0.5-anchor.x)*widget:getContentSize().width+pos.x,(0.5-anchor.y)*widget:getContentSize().height+pos.y))
		
		return m_pos
	end
end

--功能：统计字符串中字符的个数
--返回：总字符个数、英文字符数、中文字符数
function util.stringcount(str)
    local tmpStr=str
    local _,sum=string.gsub(str,"[^\128-\193]","")
    local _,countEn=string.gsub(tmpStr,"[%z\1-\127]","")
    return sum,countEn,sum-countEn
end