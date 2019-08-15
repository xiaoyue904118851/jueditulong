--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/11/12 18:51
-- To change this template use File | Settings | File Templates.
-- PanelSMZCRank

local PanelSMZCRank = {}
local var = {}

function PanelSMZCRank.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelSMZCRank.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_list")
    var.widget:getWidgetByName("Panel_chartListItem"):hide()
    var.listdata = {}
    if params.extend and params.extend.pdata and params.extend.pdata then
        var.listdata = params.extend.pdata
    end
    var.widget:runAction(
        cc.Sequence:create(cc.DelayTime:create(0.1),
            cc.CallFunc:create(function()
                PanelSMZCRank.updateListView()
            end))
    )
    return var.widget
end

function PanelSMZCRank.updateListView()
    local listview = var.widget:getWidgetByName("ListView_zc")
    local copyNode = var.widget:getWidgetByName("Panel_chartListItem"):hide()
    for k, v in ipairs(var.listdata) do
        local itembg = copyNode:clone():show()
        if k%2 == 0 then itembg:getWidgetByName("Image_mask"):hide() end
        local color = Const.COLOR_YELLOW_1_C3B
        if k <= 3 then
            local img = "img_power_"..k..".png"
            if k == 1 then
                color = Const.COLOR_YELLOW_2_C3B
            elseif k == 2 then
                color = Const.COLOR_BLUE_1_C3B
            elseif k == 3 then
                color = Const.COLOR_GREEN_1_C3B
            end
            local ranknum = ccui.ImageView:create(img,UI_TEX_TYPE_PLIST)
            ranknum:setPosition(itembg:getWidgetByName("Label_rank"):getPosition())
            ranknum:addTo(itembg)
            itembg:getWidgetByName("Label_rank"):hide()
        else
            itembg:getWidgetByName("Label_rank"):setString(k):setTextColor(color)
        end
        itembg:getWidgetByName("Label_username"):setString(v.name):setTextColor(color)
        itembg:getWidgetByName("Label_Num"):setString(v.jifen):setTextColor(color)
        itembg:getWidgetByName("Label_zhenying"):setString(v.team==1 and "神族" or "魔族"):setTextColor(color)
        itembg:getWidgetByName("Label_kill"):setString(v.killnum.."/"..v.bekillnum):setTextColor(color)
        itembg:getWidgetByName("Label_lv"):setString(v.level):setTextColor(color)
        itembg:getWidgetByName("Label_guild"):setString(v.guild):setTextColor(color)
        itembg:getWidgetByName("Label_job"):setString(Const.JOB[v.job]):setTextColor(color)
        listview:pushBackCustomItem(itembg)
    end
end


return PanelSMZCRank