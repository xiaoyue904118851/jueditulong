--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/23 16:11
-- To change this template use File | Settings | File Templates.
--

local PanelKingJifen = {}
local var = {}

local ACTIONSET_NAME = "kingdom"
local PANELID = "kingdomInfo"

function PanelKingJifen.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelKing/UI_King_Jifen_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_jifen")
    var.copyNode = var.widget:getWidgetByName("Panel_list_item"):hide()
    PanelKingJifen.updateListView()
    PanelKingJifen.updateJFPoint()
    PanelKingJifen.registeEvent()
    if not NetClient.mKingJFAwardList or #NetClient.mKingJFAwardList == 0 then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="jfaward"}))
    end

    return var.widget
end

function PanelKingJifen.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_KING_UPATE_JF, PanelKingJifen.updateJFPoint)
    :addEventListener(Notify.EVENT_KING_JF_AWARD_LIST, PanelKingJifen.updateListView)
    :addEventListener(Notify.EVENT_KING_JF_AWARD_FLAG, PanelKingJifen.handleUpdateAwardFlag)
end

function PanelKingJifen.updateJFPoint()
    var.widget:getWidgetByName("Text_point"):setString(NetClient.mKingJFPoint)
end

function PanelKingJifen.updateListView()
    local listview = var.widget:getWidgetByName("ListView_jifen")
    listview:removeAllItems()
    for k, v in ipairs(NetClient.mKingJFAwardList) do
        local itemBg = var.copyNode:clone():show()
        itemBg:getWidgetByName("Text_need_point"):setString(v.jf.."积分")
        UIItem.getSimpleItem({
            parent = itemBg:getWidgetByName("item_bg"),
            typeId = v.typeid,
        })

        listview:pushBackCustomItem(itemBg)

        itemBg:getWidgetByName("Button_award").index = k
        itemBg:getWidgetByName("Button_award"):addClickEventListener(function (pSender)
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="getjfaward",param=pSender.index}))
        end)
        PanelKingJifen.updateAwardFlag(itemBg, k)
    end
end

function PanelKingJifen.updateAwardFlag(itemBg, k)
    local awardFlag = NetClient.mKingJFAwardFlagList[k] or 0
    if awardFlag == 2 then
        itemBg:getWidgetByName("Button_award"):hide()
        itemBg:getWidgetByName("Image_flag"):show()
    else
        itemBg:getWidgetByName("Button_award"):setTouchEnabled(awardFlag==1)
        itemBg:getWidgetByName("Button_award"):setBright(awardFlag==1)
        itemBg:getWidgetByName("Image_flag"):hide()
    end
end

function PanelKingJifen.handleUpdateAwardFlag()
    local itemBg
    for k, v in ipairs(NetClient.mKingJFAwardFlagList) do
        itemBg = var.widget:getWidgetByName("ListView_jifen"):getItem(k-1)
        if itemBg then
            PanelKingJifen.updateAwardFlag(itemBg, k)
        end
    end
end

return PanelKingJifen