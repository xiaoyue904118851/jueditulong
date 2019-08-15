--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/01/03 12:35
-- To change this template use File | Settings | File Templates.
--

local VipTequanView = {}
local var = {}


function VipTequanView.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelVIP/UI_VIP_Tequan.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_vip_tequan")

    var.listView = var.widget:getWidgetByName("ListView_tq")
    var.srcListItem = var.widget:getWidgetByName("Image_item"):hide()

    VipTequanView.showList()

    return widget
end

function VipTequanView.showList()
    var.listView:removeAllItems()
    for k, v in ipairs(VipDefData.tequanname) do
        local item = var.srcListItem:clone():show()
        item:getWidgetByName("Text_tq_name"):setString(v.text)
        if k%2 == 0 then
            item:loadTexture("touming.png",UI_TEX_TYPE_PLIST)
        end

        for level, info in ipairs(VipDefData.list) do
            local textnode = item:getWidgetByName("Text_tq_level_"..level)
            if textnode then
                local value = info.tequanlist[v.key]
                if v.type == 0 then
                    textnode:setString(value)
                elseif v.type == 1 then
                    textnode:hide()
                    ccui.ImageView:create(value == 0 and "cha.png" or "img_checkbox_flag.png", UI_TEX_TYPE_PLIST)
                    :align(display.CENTER,textnode:getPositionX(),textnode:getPositionY())
                    :addTo(item)
                elseif v.type == 2 then
                    textnode:setString(string.format("%d%%", value))
                elseif v.type == 3 then
                    textnode:setString(value/10)
                end


            end
        end
        var.listView:pushBackCustomItem(item)
    end
end

return VipTequanView