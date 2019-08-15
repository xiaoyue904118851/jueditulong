--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/12/11 16:23
-- To change this template use File | Settings | File Templates.
--BuffListView

local BuffListView = {}
local var = {}

function BuffListView.initView(params)
    local params = params or {}
    var = {}

    var.rootidget = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_BuffList.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = var.rootidget:getChildByName("Panel_bufflist")

    var.buffListViewItem = var.widget:getWidgetByName("Panel_listitem"):hide()

    BuffListView.updateBuffList()
    return  var.rootidget
end

function BuffListView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_STATUS_CHANGE, BuffListView.updateBuffList)
end

function BuffListView.updateBuffList()
    local buffListView = var.widget:getWidgetByName("ListView_buff")
    buffListView:removeAllItems():hide()

    local statusMap
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        local id = MainAvatar:NetAttr(Const.net_id)
        statusMap = NetClient.mNetStatus[id]
    end

    if not statusMap then
        return end

    local num = 0
    for _,v in pairs(statusMap) do
        local descinfo = game.getStatusDescDefByID(v.id, v.param)
        if descinfo then
            local buffItem = var.buffListViewItem:clone()
            buffItem:show()
            buffItem:getWidgetByName("ImageView_icon"):loadTexture(string.format("buff/status_%02d.png", descinfo.mIconID),UI_TEX_TYPE_LOCAL)
            if descinfo.mTimeType == 1 then
                buffItem:getWidgetByName("Label_time"):stopAllActions()
                buffItem:getWidgetByName("Label_time"):setString("永久")
            else
                buffItem:getWidgetByName("Label_time"):setString( DateHelper.convertSecondsToStr(v.dura, true))
                buffItem:getWidgetByName("Label_time"):stopAllActions()
                buffItem:getWidgetByName("Label_time"):runAction(cc.RepeatForever:create(cc.Sequence:create(
                    cc.DelayTime:create(1),
                    cc.CallFunc:create(function(pSender)
                        pSender:setString( DateHelper.convertSecondsToStr(v.dura, true))
                    end)
                )))
            end
            buffItem:getWidgetByName("Label_name"):setString(descinfo.mName)
            buffItem:getWidgetByName("Label_desc"):setString(descinfo.mDesc)
            buffListView:pushBackCustomItem(buffItem)
            num = num + 1
        end
    end

    local listviewsize = cc.size(438,  math.min(560, var.buffListViewItem:getContentSize().height*num))
    buffListView:setContentSize(listviewsize)

    var.widget:getWidgetByName("Panel_listview_bg"):setContentSize(cc.size(listviewsize.width+10, listviewsize.height+30))
    var.rootidget:setContentSize(var.widget:getWidgetByName("Panel_listview_bg"):getContentSize())
    buffListView:show()
end

return BuffListView