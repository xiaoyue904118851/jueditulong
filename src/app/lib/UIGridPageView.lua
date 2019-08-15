--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/18 09:59
-- To change this template use File | Settings | File Templates.
--

UIGridPageView = class("UIGridPageView")

function UIGridPageView:ctor(params)
    self._items = {}
    self._pv = params.pv
    self._totalCount = params.count
    self._column = params.column or 1
    self._row = params.row or 1
    self._padding = params.padding or {left = 0, right = 0, top = 0, bottom = 0 }
    self._viewRect = self._pv:getContentSize()
    self._gridRect = cc.size(self._viewRect.width - self._padding.left - self._padding.right, self._viewRect.height - self._padding.top - self._padding.bottom)
    self._itemW = self._gridRect.width/self._column
    self._itemH = self._gridRect.height/self._row
    self._initGridListener = params.initGridListener
    if params.async or params.parent then
        self:createAllPage()
        self._parent = params.parent
        self._finishListener = params.finishListener
        self._initGridIndex = 0
        self._parent:scheduleUpdateWithPriorityLua(function()
            self:onframeUpdate()
        end, 0)
    else
        --print("TZ::::::OPIUY------------------------------------------>23")
        self:initAll()
    end
end

function UIGridPageView:createAllPage()
    local pageCount = self:getPageCount()
    for i = 1, pageCount do
        local pageWidget = ccui.Layout:create()
        pageWidget:setLayoutType(ccui.LayoutType.VERTICAL)
        self._pv:addPage(pageWidget)
    end
end

function UIGridPageView:onframeUpdate()
    if self._initGridIndex >= self._totalCount then
        self._parent:unscheduleUpdate()
        return
    end

    local pageIndex = math.floor(self._initGridIndex/(self._row*self._column))
    local pageWidget = self._pv:getItem(pageIndex)
    if not pageWidget then
        return
    end

    local rowIndex = math.floor((self._initGridIndex - pageIndex*(self._row*self._column)) /self._column)
    local rowWidget = pageWidget:getChildByName("row_"..rowIndex)
    if not rowWidget then
        local linearLayoutParameter = ccui.LinearLayoutParameter:create()
        linearLayoutParameter:setGravity(ccui.LinearGravity.centerHorizontal)
        rowWidget = ccui.Layout:create()
        rowWidget:setContentSize(cc.size(self._gridRect.width,self._itemH))
        rowWidget:setLayoutType(ccui.LayoutType.HORIZONTAL)
        rowWidget:setLayoutParameter(linearLayoutParameter)
        rowWidget:setName("row_"..rowIndex)
        rowWidget:addTo(pageWidget)
    end
    local gridWidget = self:newItem():addTo(rowWidget)
    self._items[#self._items+1]=gridWidget

    self._initGridIndex = self._initGridIndex + 1
    if self._initGridListener then self._initGridListener(gridWidget, self._initGridIndex) end

    if self._initGridIndex == self._totalCount then
        self._parent:unscheduleUpdate()
        if self._finishListener then self._finishListener() end
        return
    end
end

function UIGridPageView:getItemsCount()
    return self._totalCount
end

function UIGridPageView:newItem()
    local item = ccui.Widget:create()
    item:setTouchEnabled(false)
    local linearLayoutParameter = ccui.LinearLayoutParameter:create()
    linearLayoutParameter:setGravity(ccui.LinearGravity.centerVertical)
    item:setLayoutParameter(linearLayoutParameter)
    item:setContentSize(self._itemW, self._itemH)
    return item
end

function UIGridPageView:getItems()
    return self._items
end

function UIGridPageView:getItem(index)
    if index < 1 or index > self:getItemsCount() then return end
    return self._items[index]
end

function UIGridPageView:addItem(item)
    table.insert(self._items, item)
    return self
end

function UIGridPageView:createPage_(pageNo)
    local page = ccui.Widget:create()
    local beginIdx = self._row*self._column*(pageNo-1) + 1
    local itemW = self._itemW
    local itemH = self._itemH
    local item

    local bBreak = false
    for row = 1, self._row do
        for column = 1, self._column do
            item = self._items[beginIdx]
            beginIdx = beginIdx + 1
            if not item then
                bBreak = true
                break
            end
            page:addChild(item)
            item:setAnchorPoint(0.5, 0.5)
            item:setPosition(
                column*itemW - itemW/2,
                self._viewRect.height - row*itemH + itemH/2
            )
        end
        if bBreak then
            break
        end
    end

    return page
end

function UIGridPageView:getPageCount()
    return math.ceil(self._totalCount/(self._column*self._row))
end
function UIGridPageView:initOther()
    local pageCount = self:getPageCount()
    for i = self._column*self._row+1, self._totalCount do
        local item = self:newItem()
        if self._initGridListener then self._initGridListener(item, i) end
        self:addItem(item)
    end
     for i = 2, pageCount do
        self._pv:addPage(self:createPage_(i))
    end
end

 

function UIGridPageView:initAll()
    local pageCount = self:getPageCount()
    for i = 1, self._totalCount/pageCount do
        local item = self:newItem()
        if self._initGridListener then self._initGridListener(item, i) end
        self:addItem(item)
    end

    self._pv:addPage(self:createPage_(1))
end

return UIGridPageView