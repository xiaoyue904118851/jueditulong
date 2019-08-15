--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/25 12:40
-- To change this template use File | Settings | File Templates.
--NearOpView

local NearOpView = {}
local var = {}
local NEAR_PLAYER_TAG = {
    LEADER = 1,
    PLAYER = 2,
}

function NearOpView.initView(params)
    var = {}
    var.nearType = params.type
    var.uname = params.uname
    var.groupid = params.groupid
    var.isfull = params.isfull
    var.myname = game.GetMainRole():NetAttr(Const.net_name)
    var.rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelGroup/UI_Group_Near_OP.csb"):addTo(params.parent, params.zorder or 10)
    var.widget = var.rootWidget:getChildByName("Panel_group_otherinfo")
    var.widget:getWidgetByName("Label_username"):setString(var.uname)

    NearOpView.addBtnClickedEvent()
end

function NearOpView.addBtnClickedEvent()
    local btnNames =  {"Button_close", "Button_viewother", "Button_whisper", "Button_friendadd", "Button_trade", "Button_groupinvite" , "Button_applygroup" }
    for i = 1, #btnNames do
        var.widget:getWidgetByName(btnNames[i]):hide()
    end

    if var.nearType == NEAR_PLAYER_TAG.PLAYER then
        btnNames = {"Button_close", "Button_viewother", "Button_whisper", "Button_friendadd", "Button_trade", "Button_groupinvite" }
    else
        btnNames = {"Button_close", "Button_viewother", "Button_whisper", "Button_friendadd", "Button_trade", "Button_applygroup" }
    end

    local function btnCallBack(pSender)
        local btnName = pSender:getName()
        var.rootWidget:removeFromParent()
        if btnName == "Button_viewother" then

            NetClient:CheckPlayerEquip(var.uname)
        elseif btnName == "Button_whisper" then
            NetClient:privateChatTo(var.uname)
        elseif btnName == "Button_friendadd" then
            NetClient:FriendChange(var.uname, Const.FRIEND_TITLE.FRIEND)
        elseif btnName == "Button_groupinvite" then
            if #NetClient.mGroupMembers <= 0 then
                NetClient:alertLocalMsg("你还没有队伍,请先创建队伍！","alert")
            elseif NetClient.mCharacter.mGroupLeader ~= var.myname then
                NetClient:alertLocalMsg("只有队长才能发出邀请哦！","alert")
            elseif #NetClient.mGroupMembers >= Const.GROUP_MAX_MEMBER then
                NetClient:alertLocalMsg("队伍人数已达上限！","alert")
            else
                NetClient:InviteGroup(var.uname)
            end
        elseif btnName == "Button_applygroup" then
            if #NetClient.mGroupMembers > 0 then
                NetClient:alertLocalMsg("你已经在队伍中了！","alert")
            elseif var.isfull then
                NetClient:alertLocalMsg("队伍人数已达上限！","alert")
            else
                NetClient:JoinGroup(var.groupid)
            end
        elseif btnName == "Button_trade" then
            NetClient:TradeInvite(var.uname)
        end
    end

    local posy = 45
    for i = 1, #btnNames do
        local btn = var.widget:getWidgetByName(btnNames[i]):show()
        btn:addClickEventListener(btnCallBack)
        if i > 4 then
            btn:setPositionY(posy)
            posy = posy + 70
        end
    end


end

return NearOpView