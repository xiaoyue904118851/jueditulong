--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/24 16:49
-- To change this template use File | Settings | File Templates.
--
local WidgetHelper = {}

function WidgetHelper:getWidgetByCsb(filename)
    return tolua.cast(cc.CSLoader:createNode(filename),"ccui.Widget")
end

return WidgetHelper