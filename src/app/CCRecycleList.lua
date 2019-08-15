CCRecycleList = class("CCRecycleList")
--[[
params.list:需要复用的list，类型是listView
params.totalLength:需要显示的item的总数量
params.updateItemfunc:刷新item函数
]]
function CCRecycleList:ctor(params)
	if params.list:getDescription() == "ListView" then
		self._list = params.list
		self._totalLength = params.totalLength or #self._list:getItems()
		self._singlePageNum =  #self._list:getItems() - 1
		self._updateItemFunc = params.updateFunc
		self.index = 1  -- 当前显示页第一项item 序号
		self:init()
	end
end

function CCRecycleList:init()
	local defaultItems = self._list:getItems()

	self._list.designNum = self._list.designNum or #defaultItems

	if self._totalLength < #defaultItems then -- 总数小于当前个数
		for i=1, #defaultItems - self._totalLength do
			self._list:removeLastItem()
		end
	else
		local addNum = self._list.designNum < self._totalLength and self._list.designNum or self._totalLength
		if #defaultItems < addNum then
			for i=1, addNum - #defaultItems do
				self._list:pushBackDefaultItem()
			end
			self._singlePageNum = #self._list:getItems() - 1
		end
	end
	defaultItems = self._list:getItems()
	for i,v in ipairs(defaultItems) do
		v.tag = i
		if self._updateItemFunc then self._updateItemFunc(v) end
	end

	if self._totalLength <= self._list.designNum then
		self._list:addScrollViewEventListener(function ()
		end)
	else
		self._list:addScrollViewEventListener(
			function (list, eventType)
				if eventType == ccui.ScrollviewEventType.scrollToTop and self.index > 1 then
					local itemIndex = #list:getItems() - 1
					local mItem = list:getItem(itemIndex)
					mItem:retain()
					list:removeItem(itemIndex)
					list:insertCustomItem(mItem, 0)
					list:jumpToBottom()
					self.index = self.index - 1
					mItem.tag = self.index
					if self._updateItemFunc then self._updateItemFunc(mItem,eventType) end
					mItem:release()
				elseif eventType == ccui.ScrollviewEventType.scrollToBottom and self.index +self._singlePageNum  < self._totalLength then
					self.index = self.index + 1
					local mItem = list:getItem(0)
					mItem:retain()
					list:removeItem(0)
					list:pushBackCustomItem(mItem)
					list:jumpToTop()
					-- local mItem = list:getItem(#list:getItems() - 1)
					mItem.tag = self.index + self._singlePageNum
					if self._updateItemFunc then self._updateItemFunc(mItem,eventType) end	
					mItem:release()			
				end
			end
		)
	end
end

