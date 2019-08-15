--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/25 12:44
-- To change this template use File | Settings | File Templates.
--

local MyGroupOpView = {}
local var = {}

function MyGroupOpView.initView(params)
    var = {}
    var.uname = params.uname
    var.tag = params.tag or 0
    --var.rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelGroup/UI_Group_MyGroup_OP.csb"):addTo(params.parent, params.zorder or 10)
    var.rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelGroup/UI_Group_MyGroup_new.csb"):addTo(params.parent, params.zorder or 10)
    if params.tag then
        if var.tag > 0 then
            var.rootWidget:setPosition(0,-200)
        end
    end
    NetClient.OPviewType = true
    var.widget = var.rootWidget:getChildByName("Panel_groupoperate")
    var.widget:getWidgetByName("Label_username"):setString(var.uname)

    MyGroupOpView.addBtnClickedEvent()
end

function MyGroupOpView.addBtnClickedEvent()
    local btnNames =  {"Button_close", "Button_viewother", "Button_whisper", "Button_copyname", "Button_friend", "Button_leavegroup","Button_leader","Button_backlist"}

    local groupLeader = NetClient.mCharacter.mGroupLeader
    local myname = game.GetMainNetGhost():NetAttr(Const.net_name)
    var.widget:getWidgetByName("Button_copyname"):hide():setTouchEnabled(false)
    var.widget:getWidgetByName("Button_backlist"):setPosition(var.widget:getWidgetByName("Button_copyname"):getPosition())
    if var.tag > 0 or groupLeader ~= myname then
        var.widget:getWidgetByName("Button_leavegroup"):hide():setTouchEnabled(false)
        var.widget:getWidgetByName("Button_leader"):hide():setTouchEnabled(false)       
    end

    local function btnCallBack(pSender)
        local btnName = pSender:getName()
        var.rootWidget:removeFromParent()
        if btnName == "Button_viewother" then
            NetClient:CheckPlayerEquip(var.uname)
        elseif btnName == "Button_leader" then
            if groupLeader == myname then
                NetClient:GroupSetLeader(var.uname)
            else
                NetClient:alertLocalMsg("需要队长权限!","alert")
            end
        elseif btnName == "Button_whisper" then
            NetClient:privateChatTo(var.uname)
        elseif btnName == "Button_friend" then
            NetClient:FriendChange(var.uname, Const.FRIEND_TITLE.FRIEND)
        elseif btnName == "Button_leavegroup" then
            if groupLeader == myname then
                NetClient:GroupKickMember(var.uname)
            else
                NetClient:alertLocalMsg("需要队长权限!","alert")
            end
        elseif btnName == "Button_backlist" then
            NetClient:FriendChange(var.uname, Const.FRIEND_TITLE.BLACK)
        elseif btnName == "Button_copyname" then
        elseif btnName == "Button_close" then
        end
        NetClient.OPviewType = false
    end

    for i = 1, #btnNames do
        var.widget:getWidgetByName(btnNames[i]):addClickEventListener(btnCallBack)
    end
end


return MyGroupOpView