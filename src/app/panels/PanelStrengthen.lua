--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelAwardHall

local PanelStrengthen = {}
local var = {}
local MAXNUM = 5

local ROLEINFO_TAG = {
    ONLINE = 1,
    SIGNUP = 2
}

function PanelStrengthen.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0
    var.params = nil

    var.selectTab = ROLEINFO_TAG.ONLINE
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelStrengthen/UI_Strengthen_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_strengthen")
    

    var.listView = var.widget:getWidgetByName("ListView_rightlist")
    var.listItem = var.widget:getWidgetByName("Image_frame"):hide()

    --PanelStrengthen.addMenuTabClickEvent()
    NetClient:dispatchEvent({name = Notify.EVENT_STRENGTNEN_BUTTON_SHOW,hideType = true})
    var.selectTab = 1
    PanelStrengthen:sortData()
    return var.widget
end

function PanelStrengthen.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    for i= 1,MAXNUM do
        UIRadioButtonGroup:addButton(var.widget:getWidgetByName("Button_left"..i))
            :onButtonSelectChanged(function(event)
                PanelStrengthen.updateTaskInfo(event.selected)
                var.selectTab = event.selected
            end) 
    end
    UIRadioButtonGroup:setButtonSelected(var.selectTab)
end
function PanelStrengthen.sortData()
    var.infodata = {}
    for j = 1,MAXNUM do
        var.infodata[j] = {}
        local id = 1
        for k,v in pairs(StrengthenDef) do 
            if v.mType == j then
                var.infodata[j][id] = v
                id = id+1
            end
        end
    end
    PanelStrengthen.addMenuTabClickEvent()
end

function PanelStrengthen.updateTaskInfo(tag)
    var.listView:removeAllItems()
    
    for i = 1,#var.infodata[tag] do
        local data = var.infodata[tag][i]
        local listItem = var.listItem:clone():show()
        listItem:getWidgetByName("Label_task"):setString(data.mDengLu)
        listItem:getWidgetByName("Label_taskdesc"):setString(data.mTask)
        listItem:getWidgetByName("Label_btnname"):setString(data.mLinkText)
        listItem:getWidgetByName("Image_act_icon"):ignoreContentAdaptWithSize(true)
        listItem:getWidgetByName("Image_act_icon"):loadTexture(data.mIcon..".png",UI_TEX_TYPE_PLIST)
         
        for j = 1,data.mStar do
             listItem:getWidgetByName("Image_star"..j):show()
        end
        local gobtn = listItem:getWidgetByName("Button_go")
        gobtn.user_data = data.mLinkEvent
        gobtn:addClickEventListener(function (pSender)
                util.touchlink(pSender,ccui.TouchEventType.ended,"panel_strengthen","")
            end)
        var.listView:pushBackCustomItem(listItem)
    end
end

return PanelStrengthen