local ScrollFight={}
local var = {}
local textWidth = 17
function ScrollFight.initWidget(callBack)
	local m_pMainWidget = nil
	var = {
		mHandle = nil,
		mBehindSp = {},
		mMoveSp = {},
		mShowSp = {},
		mFightAdd = nil,
		mFightAll = nil,
		mAdd = {},
		mAll = {},
		mTotal = {},
		mScrollIndex = 1,
		mNumIndex = 0,
		mIsRunning=0,
		mRunningTime=0.05,
		mRunVec={},
		mCallFunc=nil,
	}
	m_pMainWidget = ccui.Widget:create()
	mCallFunc = callBack

	local hide_layer = ccui.Layout:create()
	hide_layer:setAnchorPoint(cc.p(0,1))
	hide_layer:setContentSize(cc.size(300,30))
	hide_layer:setClippingEnabled(true)
	hide_layer:setName("hide_layer")
	m_pMainWidget:addChild(hide_layer)

	for i = 1, 10 do
		local fight_sprite = display.newSprite("#img_power_0.png")
		local behind_sprite = display.newSprite("#img_power_9.png")
		-- behind_sprite:setScale(1.5)
		-- fight_sprite:setScale(1.5)
		fight_sprite:setAnchorPoint(cc.p(0,0))
		behind_sprite:setAnchorPoint(cc.p(0,0))
		fight_sprite:setPosition(cc.p(textWidth *i, 0))
		behind_sprite:setPosition(cc.p(fight_sprite:getPositionX(),fight_sprite:getPositionY() - 35))
		hide_layer:addChild(fight_sprite)
		hide_layer:addChild(behind_sprite)
		var.mBehindSp[i] = behind_sprite
		var.mShowSp[i] = fight_sprite
	end
	return m_pMainWidget
end

function ScrollFight.AddNewFight(scrollWidget,add,all)
	if var.mIsRunning == 1 then
		ScrollFight.clearData()
	end
	var.mFightAdd = add
	var.mFightAll = all
	var.mAdd = ScrollFight.IntToStringTab(var.mFightAdd)
	var.mAll = ScrollFight.IntToStringTab(var.mFightAll)
	var.mTotal = ScrollFight.IntToStringTab(var.mFightAdd+var.mFightAll)
	if #var.mTotal > #var.mAll then
		for i=1,(#var.mTotal-#var.mAll) do
			table.insert(var.mAll,i,0)
		end
	end
	var.mNumIndex = #var.mAll
	local hide_layer = scrollWidget:getWidgetByName("hide_layer")
	local fight_bg = hide_layer:getWidgetByName("fight_bg")
	for i=1,10 do
		if var.mShowSp[i] then
			if i <= #var.mAll then
				var.mShowSp[i]:setVisible(true)
				var.mShowSp[i]:setSpriteFrame("img_power_"..var.mAll[i]..".png")
			else
				var.mShowSp[i]:setVisible(false)
			end
		end
	end
	ScrollFight.runScrollF()
end

function ScrollFight.runScrollF()
	var.mIsRunning = 1
	local tab_scroll = ScrollFight.getScrollTab()
	if not tab_scroll then
		ScrollFight.runNextNum()
	end
	if var.mNumIndex <= 0 then
		ScrollFight.endScroll()
		return
	end
	local bd_sp = var.mBehindSp[var.mNumIndex]
	if bd_sp and tab_scroll then
		if tab_scroll[var.mScrollIndex] then
			bd_sp:setSpriteFrame("img_power_"..tab_scroll[var.mScrollIndex]..".png")
		end
		bd_sp:runAction(cc.Sequence:create(
				cc.EaseSineOut:create(cc.MoveTo:create(var.mRunningTime, cc.p(bd_sp:getPositionX(),bd_sp:getPositionY()+35)))))
	end
	
	if var.mShowSp[var.mNumIndex] then
		var.mShowSp[var.mNumIndex]:runAction(cc.Sequence:create(
				cc.EaseSineOut:create(cc.MoveTo:create(var.mRunningTime,cc.p(var.mShowSp[var.mNumIndex]:getPositionX(),var.mShowSp[var.mNumIndex]:getPositionY()+35))),
				cc.CallFunc:create(ScrollFight.runNextNum)))
	end
end

function ScrollFight.runNextNum()
	local tab_scroll = ScrollFight.getScrollTab()
	if var.mShowSp[var.mNumIndex] then
		var.mShowSp[var.mNumIndex]:setPosition(cc.p(var.mShowSp[var.mNumIndex]:getPositionX(),var.mShowSp[var.mNumIndex]:getPositionY()-35))
		if tab_scroll[var.mScrollIndex] then
			var.mShowSp[var.mNumIndex]:setSpriteFrame("img_power_"..tab_scroll[var.mScrollIndex]..".png")
		end
	end
	var.mScrollIndex = var.mScrollIndex + 1
	if var.mBehindSp[var.mNumIndex] then
		var.mBehindSp[var.mNumIndex]:setPosition(cc.p(var.mBehindSp[var.mNumIndex]:getPositionX(),
			var.mBehindSp[var.mNumIndex]:getPositionY()-35))
	end
	if var.mScrollIndex > #tab_scroll then 
		var.mNumIndex = var.mNumIndex - 1
		var.mScrollIndex = 1
	end
	ScrollFight.runScrollF()
end

function ScrollFight.endScroll()
	var.mIsRunning = 0
	if mCallFunc then
		mCallFunc(var.mFightAdd+var.mFightAll)
	end
	local function runNextAct()
		if var.mHandle then
			Scheduler.unscheduleGlobal(var.mHandle)
			var.mHandle = nil
		end
		if var.mRunVec and #var.mRunVec > 0 then
			ScrollFight.AddNewFight(var.mRunVec[1][1],var.mRunVec[1][2])
			table.remove(var.mRunVec,1)
		end
	end
	if var.mRunVec and #var.mRunVec > 0 then
		print(var.mRunVec[1][1],var.mRunVec[1][2])
		var.mHandle = Scheduler.scheduleGlobal(runNextAct,0.01)
		
	end
end

function ScrollFight.getScrollTab()
	
	local tab_scroll = ScrollFight.ScrollAToB(var.mAll[var.mNumIndex],var.mTotal[var.mNumIndex])
	while not tab_scroll do
		var.mNumIndex = var.mNumIndex - 1
		if var.mNumIndex <= 0 then
			ScrollFight.endScroll()
			break
		end
		var.mScrollIndex = 1
		tab_scroll = ScrollFight.ScrollAToB(var.mAll[var.mNumIndex],var.mTotal[var.mNumIndex])
		if tab_scroll then
			break
		end
	end
	return tab_scroll
end

function ScrollFight.ScrollAToB(numA,numB)
	local scroll_tab = {}
	if numA and numB then
		if numA > numB then
			for i=numA+1,9 do
				table.insert(scroll_tab,i)
			end
			for i=0,numB do
				table.insert(scroll_tab,i)
			end
		elseif numA == numB then
			scroll_tab = nil
		else
			for i=numA+1,numB do
				table.insert(scroll_tab,i)
			end
		end
	end
	return scroll_tab
end

function ScrollFight.clearData()
	
	var.mFightAdd = nil
	var.mFightAll = nil
	var.mAdd = {}
	var.mAll = {}
	var.mTotal = {}
	var.mScrollIndex = 1
	var.mNumIndex = 0
	var.mIsRunning=0
	var.mRunningTime=0.05
	for i=1,10 do
		var.mShowSp[i]:stopAllActions()
		var.mBehindSp[i]:stopAllActions()
		var.mShowSp[i]:setPosition(cc.p(17*i,0))
		var.mBehindSp[i]:setPosition(cc.p(var.mShowSp[i]:getPositionX(),var.mShowSp[i]:getPositionY()-35))
	end
end

function ScrollFight.IntToStringTab(num)
	local num_tab = {}
	local index = 1
	num = math.abs(num)
	if num >= 10 then
		while num >= 10 do
			num_tab[index] = num%10
			num = math.floor(num/10)
			index = index + 1
			if num < 10 then
				num_tab[index] = num
				break
			end
		end
	else
		num_tab[index] = num
	end
	local change_tab = {}
	for i=1,#num_tab do
		change_tab[#num_tab-i+1] = num_tab[i]
	end
	return change_tab
end

return ScrollFight