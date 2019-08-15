--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/31 12:30
-- To change this template use File | Settings | File Templates.
--

UIGridView = class("UIGridView")

-- list 父节点listView类型的
-- gridCount 共显示的小格子数
-- cellSize listview本身的一行的大小
-- columns  每行显示多少个

function UIGridView:ctor(params)
    self._list = params.list
    self._totalCount = params.gridCount
    self._cellSize = params.cellSize
    self._columns = params.columns or 1
    self._items = {}
    self._initGridListener = params.initGridListener
    if params.async and params.parent then
        self._parent = params.parent
        self._finishListener = params.finishListener
        self._initGridIndex = 0
        self._parent:scheduleUpdateWithPriorityLua(function()
            self:onframeUpdate()
        end, 0)
    else
        self:initAll()
    end
end

function UIGridView:getItems()
    return self._items
end

function UIGridView:getItemByIdx(idx)
    return self._items[idx]
end

function UIGridView:createRowWidget()
    local rowWidget = ccui.Layout:create()
    rowWidget:setLayoutType(ccui.LayoutType.HORIZONTAL)
    rowWidget:setContentSize(self._cellSize)
    return rowWidget
end

function UIGridView:onframeUpdate()
    if self._initGridIndex >= self._totalCount then
        self._parent:unscheduleUpdate()
        return
    end

    local rowIndex = math.floor(self._initGridIndex/self._columns)
    local rowWidget = self._list:getItem(rowIndex)

    if not rowWidget then
        rowWidget = self:createRowWidget()
        self._list:pushBackCustomItem(rowWidget)
    end

    local linearLayoutParameter = ccui.LinearLayoutParameter:create()
    linearLayoutParameter:setGravity(ccui.LinearGravity.centerVertical)
    local columnW = self._cellSize.width/self._columns
    local columnH = self._cellSize.height
    local gridWidget = ccui.Widget:create()
    gridWidget:setContentSize(cc.size(columnW, columnH))
    gridWidget:setLayoutParameter(linearLayoutParameter)
    gridWidget:addTo(rowWidget)

    self._items[#self._items+1]=gridWidget

    self._initGridIndex = self._initGridIndex + 1
    if self._initGridListener then self._initGridListener(gridWidget, self._initGridIndex) end

    if self._initGridIndex == self._totalCount then
        self._parent:unscheduleUpdate()
        if self._finishListener then self._finishListener() end
        return
    end
end

function UIGridView:initAll()
    local rows = math.ceil(self._totalCount/self._columns)
    local columnW = self._cellSize.width/self._columns
    local columnH = self._cellSize.height
    for rowIdx = 1, rows do
        local rowWidget = self:createRowWidget()
        self._list:pushBackCustomItem(rowWidget)

        for columnIdx = 1, self._columns do
            local currentCnt = (rowIdx - 1) * self._columns + columnIdx
            if currentCnt > self._totalCount then
                return
            end

            local gridWidget = ccui.Widget:create()
            gridWidget:setContentSize(cc.size(columnW, columnH))
            gridWidget:setAnchorPoint(0, 0)
            gridWidget:setPosition((columnIdx - 1) * columnW, 0)
            gridWidget:addTo(rowWidget)
            self._items[#self._items+1]=gridWidget
            if self._initGridListener then self._initGridListener(gridWidget, currentCnt) end
        end
    end
end

return UIGridView

