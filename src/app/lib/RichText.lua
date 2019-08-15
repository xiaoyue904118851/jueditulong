--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/08 12:14
-- To change this template use File | Settings | File Templates.
--

local RichText = class("", function()
    return ccui.Layout:create()
end)

-- content table 格式的内容
-- width  显示宽度
-- defaultFontSize 默认字号
-- defaultFontName 默认字体名称
-- defaultFontColor 默认字体颜色
-- verticalSpace  每行间距

function RichText:ctor(params)
    params = checktable(params)

    self.mContent = params.content or ""

    if type(self.mContent) ~= "table" then
        print("RichText:ctor==>> error, content must be table")
        return
    end

    self.mSeedID = NetClient.m_nNpcTalkId
    self.mParentName = params.parentName or ""
    self.mWidth = params.width or display.width
    self.mDefaultFontSize = params.defaultFontSize or 24
    self.mDefaultFontName = params.defaultFontName or Const.DEFAULT_FONT_NAME
    self.mDefaultFontColor = params.defaultFontColor or cc.c3b(255, 255, 255)
    self.mVerticalSpace = params.verticalSpace or 10

    self:showContent()
    self:formatLayout()

    self:setContentSize(cc.size(self.mWidth, self.mTotalHeight))
end

--player:push_lua_table("npc_talk",util.encode({id = npc:get_id(), talk_str = {
--    { t = "label", c = "简单的传送功能", fs = 25, fc = "255, 255, 0"},
--    { t = "br"},
--    { t = "label", c = "普通区域", fs = 25, fc = "255, 0, 0"},
--    { t = "br"},
--    { t = "button", c = "新手村", event = "", fs = 25, fc = "255, 0, 0"},
--}}));

function RichText:showContent()
    self.mTotalHeight = 0
    self.mRowItems = {}
    local currentRow = { items = {}, maxHight = 0}
    for i = 1, #self.mContent do
        local content = self.mContent[i]
        local type = content.t
        local str = content.c
        local fn = content.fn or self.mDefaultFontName
        local fs = content.fs or self.mDefaultFontSize
        local strColor = content.fc or "255, 255, 255"
        local color = string.split(strColor, ",")
        local strBtnSize = content.bs

        if type == "br" then
            table.insert(self.mRowItems, currentRow)

            -- 插入一个空行
            currentRow = { items = {}, maxHight = self.mVerticalSpace }
            table.insert(self.mRowItems, currentRow)

            currentRow = { items = {}, maxHight = 0 }
        elseif type == "label" then
            local label = ccui.Text:create(str, fn, fs)
            label:setColor(cc.c3b(checkint(color[1]), checkint(color[2]), checkint(color[3])))
            table.insert(currentRow.items, label)
            currentRow.maxHight = math.max(currentRow.maxHight, label:getContentSize().height)
        elseif type == "button" then
            local label = ccui.Text:create(str, fn, fs)
            label:setColor(cc.c3b(checkint(color[1]), checkint(color[2]), checkint(color[3])))

            local label_size = label:getContentSize()
            local btn_size = cc.size(label_size.width+25, label_size.height+20)
            if strBtnSize then
                local bs = string.split(strBtnSize, ",")
                btn_size = cc.size(bs[1], bs[2])
            end

            local button = ccui.Button:create()
            button:loadTextures("button_40_3.png","button_40_3_sel.png","",UI_TEX_TYPE_PLIST)
            label:setPosition(btn_size.width/2,btn_size.height/2)
            button:addChild(label)
            button:setScale9Enabled(true)
            button:setTouchEnabled(true)
            button:setContentSize(btn_size)
            button:addClickEventListener(function(psender)
                self:onButtonClick(psender, content.event)
            end)
            local buttonBg = ccui.Layout:create()
            local buttonBgSize = cc.size(btn_size.width + 20, btn_size.height)
            buttonBg:setContentSize(buttonBgSize)
            button:setAnchorPoint(cc.p(0.5, 0.5))
            button:setPosition(buttonBgSize.width/2,buttonBgSize.height/2)
            buttonBg:addChild(button)

            table.insert(currentRow.items, buttonBg)
            currentRow.maxHight = math.max(currentRow.maxHight, buttonBgSize.height)
        end

        if i == #self.mContent and type ~= "br" then
            table.insert(self.mRowItems, currentRow)
        end
    end
end

function RichText:formatLayout()
    self.mTotalHeight = 0
    for i = 1, #self.mRowItems do
        local rowElements = self.mRowItems[i]
        self.mTotalHeight = self.mTotalHeight + rowElements.maxHight + self.mVerticalSpace
    end

    local pastHeight = 0
    for i = 1, #self.mRowItems do
        local rowElements = self.mRowItems[i]
        if #rowElements.items ~= 0 then
            local y = self.mTotalHeight - pastHeight - rowElements.maxHight/2
            local currentRowWidth = 0
            for j = 1, #rowElements.items do
                local node = rowElements.items[j]
                node:setAnchorPoint(cc.p(0, 0.5))
                node:setPosition(cc.p(currentRowWidth, y))
                self:addChild(node)

                currentRowWidth = currentRowWidth + node:getContentSize().width
            end
        end

        pastHeight = pastHeight + rowElements.maxHight + self.mVerticalSpace
    end

end

function RichText:onButtonClick(pSender, eventStr)
    print("RichText:onButtonClick==>>", eventStr)
    if not string.find(eventStr,"event:") then
        return
    end

    local paramlist = string.sub(eventStr,7)
    local param = string.split(paramlist, "_")
    if #param <= 0 then
        return
    end

    if param[1] == "talk" then
        local funName = param[2]
        if funName then
            if self.mParentName == "panel_npctalk" then
                NetClient:NpcTalk(self.mSeedID, funName)
            end
        end
    end

    NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = self.mParentName})
end

return RichText