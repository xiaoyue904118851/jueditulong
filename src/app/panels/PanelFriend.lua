--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/15 11:23
-- To change this template use File | Settings | File Templates.
--

local PanelFriend = {}
local FRIEND_TAG = {
    FRIEND = 1,
    ENEMY = 2,
    BLACK = 3,
}
local FRIEND_LIST_CONFIG = {
    { tag = FRIEND_TAG.FRIEND, title = Const.FRIEND_TITLE.FRIEND,label="添加好友",btn="我的好友"},-- 好友
    { tag = FRIEND_TAG.ENEMY, title = Const.FRIEND_TITLE.ENEMY,label="添加仇人",btn="我的仇人"},-- 仇人
    { tag = FRIEND_TAG.BLACK, title = Const.FRIEND_TITLE.BLACK,label="添加黑名单",btn="黑名单"},--黑名单
}

local var = {}

function PanelFriend.initView(params)
    local params = params or {}
    var = {}
    var.listViewTag = 0

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelFriend/UI_Friend_BG.csb")
    widget:addTo(params.parent, params.zorder)

    var.widget = widget:getChildByName("Panel_friend")
    var.inputName = var.widget:getWidgetByName("TextField_searchname")

    var.srcListItem = var.widget:getWidgetByName("Image_listbg"):hide()
    var.listView = var.widget:getWidgetByName("ListView_playerlist")

    PanelFriend.addMenuTabClickEvent()
    PanelFriend.addBtnClicedEvent()
    PanelFriend.registeEvent()

    NetClient:FriendFresh2()
    return var.widget
end

function PanelFriend.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_FRIEND_FRESH, PanelFriend.handleUpdateListView)
end

function PanelFriend.addMenuTabClickEvent()
    local btn_firendlist = var.widget:getWidgetByName("Button_firendlist")
    local btn_enemylist = var.widget:getWidgetByName("Button_enemylist")
    local btn_blacklist = var.widget:getWidgetByName("Button_blacklist")

    var.topGroupButton = UIRadioButtonGroup.new()
    :addButton(btn_firendlist)
    :addButton(btn_enemylist)
    :addButton(btn_blacklist)
    :onButtonSelectChanged(function(event)
        PanelFriend.onTabClicked(event.selected)
    end)

    var.topGroupButton:setButtonSelected(FRIEND_TAG.FRIEND)
end

function PanelFriend.onTabClicked(tag)
    var.listViewTag = tag
    var.listView:hide()
    local startY = 553.00
    for i = 1, var.topGroupButton:getButtonsCount() do
        var.topGroupButton:getButtonAtIndex(i):setPositionY(startY)
        if i == tag then
            var.listView:setPositionY(var.topGroupButton:getButtonAtIndex(i):getPositionY()-9)
            startY = startY - var.listView:getContentSize().height-63
            var.topGroupButton:getButtonAtIndex(i):getWidgetByName("Image_jiantou"):setRotation(90)
        else
            var.topGroupButton:getButtonAtIndex(i):getWidgetByName("Image_jiantou"):setRotation(0)
            startY = startY - 66
        end
    end
    PanelFriend.updateListView(tag)
end

function PanelFriend.getListData(tag,needsort)
    local listData = {}
    local onlinenum = 0

    local curTitle = FRIEND_LIST_CONFIG[tag].title
    if curTitle then
        for _,v in pairs(NetClient.mFriends) do
            if v.title == curTitle then
                if v.online_state ~= 0 then onlinenum = onlinenum + 1 end
                table.insert(listData, v)
            end
        end
    end

    local sortF = function(fa, fb)
        return fa.online_state > fb.online_state
    end
    if #listData > 1 and needsort then
        table.sort( listData, sortF )
    end

    return listData,onlinenum
end

function PanelFriend.updateListView(tag)
    var.listViewTag = tag
    var.listView:removeAllItems()
    var.listView:show()
    var.widget:getWidgetByName("Button_find"):setTitleText(FRIEND_LIST_CONFIG[var.listViewTag].label)
    for i = 1, var.topGroupButton:getButtonsCount() do
        local btn = var.topGroupButton:getButtonAtIndex(i)
        local listData,onlinenum = PanelFriend.getListData(i, i == var.listViewTag)
        btn:setTitleText(FRIEND_LIST_CONFIG[i].btn.."["..onlinenum.."/"..#listData.."]")
        btn:getTitleRenderer():align(display.LEFT_CENTER, 44, 25)
        if i == var.listViewTag then
            for k, friendInfo in ipairs(listData) do
                local listItem = var.srcListItem:clone()
                listItem:setTouchEnabled(true)
                listItem:show()
                var.listView:pushBackCustomItem(listItem)
                listItem:getWidgetByName("Text_online"):setString(Const.ONLINE[friendInfo.online_state]):setTextColor(friendInfo.online_state == 0 and Const.COLOR_GRAY_1_C3B or Const.COLOR_GREEN_1_C3B)
                listItem:getWidgetByName("Text_name"):setString(friendInfo.name):setTextColor(friendInfo.online_state == 0 and Const.COLOR_GRAY_1_C3B or Const.COLOR_YELLOW_1_C3B)
                listItem:getWidgetByName("Text_lv"):setString("Lv."..friendInfo.level):setTextColor(friendInfo.online_state == 0 and Const.COLOR_GRAY_1_C3B or Const.COLOR_GREEN_1_C3B)
                listItem:getWidgetByName("Image_heigh"):hide()
                -- 头像
                listItem:getWidgetByName("Image_ava"):loadTexture(Const.JOB_AND_GENDER[friendInfo.job][friendInfo.gender],UI_TEX_TYPE_PLIST)
                listItem.fname = friendInfo.name
                listItem.index = k
                listItem:setTouchEnabled(true)
                :addClickEventListener(function (pSender)
                    PanelFriend.onSelectItem(pSender.index)
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_friend_op", pdata={fromFlag=1,subtype=var.listViewTag,name=pSender.fname}})
                end)
            end
        end
    end

end

function PanelFriend.onSelectItem(index)
    local items = var.listView:getItems()
    for i = 1, #items do
        items[i]:getWidgetByName("Image_heigh"):setVisible(i==index)
    end
end

function PanelFriend.addBtnClicedEvent()
    local function btnCallBack(pSender)
        local btnName =  pSender:getName()
        if btnName == "Button_find" then
            local addName = var.inputName:getString()
            if  addName ~= "" then
                if var.listViewTag == 1 then
                    NetClient:FriendChange(addName, Const.FRIEND_TITLE.FRIEND)
                elseif var.listViewTag == 2 then
                    NetClient:FriendChange(addName, Const.FRIEND_TITLE.ENEMY)
                elseif var.listViewTag == 3 then
                    NetClient:FriendChange(addName, Const.FRIEND_TITLE.BLACK)
                end
            else
                NetClient:alertLocalMsg("您还未输入玩家信息！","alert")
            end
        end
    end
    var.widget:getWidgetByName("Button_find"):addClickEventListener(btnCallBack)
end

function PanelFriend.handleUpdateListView(event)
    if event and event.action == "fresh" then
        PanelFriend.updateListView(var.listViewTag)
    end
end

return PanelFriend