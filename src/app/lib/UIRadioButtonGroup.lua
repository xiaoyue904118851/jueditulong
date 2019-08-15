--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/18 17:58
-- To change this template use File | Settings | File Templates.
--

local UIRadioButtonGroup = class("UIRadioButtonGroup")

function UIRadioButtonGroup:ctor()
    self:clearAll()
end

function UIRadioButtonGroup:addButton(button)
    local buttonIndex = #self.buttons_ + 1
    self.buttons_[buttonIndex] = button
    button:addClickEventListener(function (pSender)
        self:updateButtonState_(pSender, buttonIndex)
    end)
    return self
end

function UIRadioButtonGroup:getButtonAtIndex(index)
    return self.buttons_[index]
end

function UIRadioButtonGroup:getButtonsCount()
    return #self.buttons_
end

function UIRadioButtonGroup:onButtonSelectChanged(callback)
    self.buttonSelectedChangedFuncListener_= callback
    return self
end

function UIRadioButtonGroup:onButtonSelectChangedBefor(callback)
    self.buttonSelectedChangedBeforeFuncListener_ = callback
    return self
end

function UIRadioButtonGroup:updateButtonState_(clickedButton, currentSelectedIndex)
    if self.buttonSelectedChangedBeforeFuncListener_ then
        local ret = self.buttonSelectedChangedBeforeFuncListener_({sender = clickedButton, selected = currentSelectedIndex})
        if not ret then
            return
        end
    end

    for index, button in ipairs(self.buttons_) do
        if index == currentSelectedIndex then
            button:setBrightStyle(BRIGHT_HIGHLIGHT)
            button:setTitleColor(Const.COLOR_YELLOW_3_C3B)
        else
            button:setBrightStyle(BRIGHT_NORMAL)
            button:setTitleColor(Const.COLOR_YELLOW_2_C3B)
        end
    end
    if self.currentSelectedIndex_ ~= currentSelectedIndex then
        local last = self.currentSelectedIndex_
        self.currentSelectedIndex_ = currentSelectedIndex
        if self.buttonSelectedChangedFuncListener_ then
            self.buttonSelectedChangedFuncListener_({sender = clickedButton, selected = currentSelectedIndex, last = last})
        end
    end
end

function UIRadioButtonGroup:clearSelect()
    self.currentSelectedIndex_ = 0
    for _, button in ipairs(self.buttons_) do
        button:setTitleColor(Const.COLOR_YELLOW_2_C3B)
        button:setBrightStyle(BRIGHT_NORMAL)
    end
end

function UIRadioButtonGroup:clearItems()
    self.buttons_ = {}
    self.currentSelectedIndex_ = 0
end

function UIRadioButtonGroup:clearAll()
    self.buttons_ = {}
    self.currentSelectedIndex_ = 0
    self.buttonSelectedChangedFuncListener_ = nil
    self.buttonSelectedChangedBeforeFuncListener_ = nil
end

function UIRadioButtonGroup:setButtonSelected(index)
    local sender = self.buttons_[index]
    if not sender then
        return self
    end

    self:updateButtonState_(sender, index)
    return self
end

return UIRadioButtonGroup