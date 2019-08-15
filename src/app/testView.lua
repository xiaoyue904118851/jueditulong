--
-- Created by testview.
-- @author: xy
-- @date: 2019/8/8 
--

local testView = {}
function testView.initView(params)
    local widget = WidgetHelper:getWidgetByCsb("uilayout/TestView/TestView.csb")
    return widget
end

return testView