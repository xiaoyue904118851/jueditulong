local UILeftBottom={}

local var = {}
function UILeftBottom.init_ui(leftBottom)
    var = {}
    var.widget = leftBottom:getChildByName("Panel_leftbottom")
    var.widget:align(display.LEFT_BOTTOM, 0, 0):setScale(Const.maxScale)

    UILeftBottom.addBtnClicedEvent()
    UILeftBottom.registeEvent()
end

function UILeftBottom.registeEvent()
end

function UILeftBottom.addBtnClicedEvent()
end

return UILeftBottom