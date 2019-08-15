--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/25 12:44
-- To change this template use File | Settings | File Templates.
--
local PanelMyGroupOp = {}
--local MyGroupOpView = {}
local var = {}
local TEAM_LEADER = 1 -- 队长
local TEAM_MEBER = 2 -- 成员
local groupLeader = nil
local myname = nil

local BTN_CFG = {
    [TEAM_LEADER] = {{text="查看装备",name="Button_viewother"}, {text="发送私聊",name="Button_whisper"},
        {text="加为好友",name="Button_friend"},{text="黑名单",name="Button_backlist"},
        {text="踢出队伍",name="Button_leavegroup"},  {text="移交队长",name="Button_leader"}},
    [TEAM_MEBER] = {{text="查看装备",name="Button_viewother"}, {text="发送私聊",name="Button_whisper"},
        {text="加为好友",name="Button_friend"},{text="黑名单",name="Button_backlist"}},
}

function PanelMyGroupOp.initView(params)
    if not params.extend or not params.extend.pdata or not params.extend.pdata.uname then print("rrrrr") return end
    var = {}

    var.uname = params.extend.pdata.uname
    var.tag = params.extend.pdata.tag or 0
    --var.rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelGroup/UI_Group_MyGroup_OP.csb"):addTo(params.parent, params.zorder or 10)
    var.widget = ccui.Widget:create():addTo(params.parent, params.zorder)
    if var.tag then
        if var.tag > 0 then
            var.widget:setPosition(200,-200)
        end
    end
    groupLeader = NetClient.mCharacter.mGroupLeader
    myname = game.GetMainNetGhost():NetAttr(Const.net_name)
    if var.tag > 0 or groupLeader ~= myname then
        PanelMyGroupOp.addSprite(TEAM_MEBER,1)
    else
        PanelMyGroupOp.addSprite(TEAM_LEADER,1)      
    end
    return var.widget
    --[[]]
    
    
    --var.widget = var.rootWidget:getChildByName("Panel_groupoperate")
    --var.widget:getWidgetByName("Label_username"):setString(var.uname)

    --PanelMyGroupOp.addBtnClickedEvent()
end

function PanelMyGroupOp.addSprite(fromFlag,subtype)
    local top_line = 53
    local top_name = 35
    local top = 65
    local bottom = 28
    local buttonSize = cc.size(126,50)
    local btns = BTN_CFG[fromFlag]
    if fromFlag == FROM_TAG_FRIEND then
        btns = btns[subtype]
    end
    -- print("TZ::btns:",#btns)
    local columns = 2
    local vspace = 10
    local rows = math.ceil(#btns/columns)
    local h = top + bottom +  4 * buttonSize.height + (rows -1 )*vspace
    local w = 314

    var.widget:setContentSize(cc.size(w,h))
    local bg = ccui.ImageView:create("backgroup_9.png",UI_TEX_TYPE_PLIST)
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(w,h))
    bg:setTouchEnabled(true)
    bg:align(display.CENTER,w/2,h/2)
    bg:addTo(var.widget)

    for row=1, rows do
        for column=1 , columns do
            local posx = 0
            local posy = h - top - (row -1 )*vspace-buttonSize.height*(row - 0.5 )
            local currentCnt = (row - 1) * columns + column
            if #btns >= currentCnt then 
                local btnOp = ccui.Button:create()
                btnOp:loadTextures("red_btn.png","","",UI_TEX_TYPE_PLIST)
                btnOp:setTitleFontSize(Const.DEFAULT_BTN_FONT_SIZE)
                btnOp:setTitleColor(Const.DEFAULT_BTN_FONT_COLOR)
                btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
                btnOp:setTitleText(btns[currentCnt].text)
                btnOp:setName(btns[currentCnt].name)
                btnOp:addTo(var.widget)
                if column == 1 then
                    posx = w/2-6
                    btnOp:setAnchorPoint(display.RIGHT_CENTER)
                else
                    posx = w/2+6
                    btnOp:setAnchorPoint(display.LEFT_CENTER)
                end
                btnOp:setPosition(cc.p(posx,posy))
                btnOp:addClickEventListener(PanelMyGroupOp.onBtnClicked) 
            end  
        end
    end

    local textname = ccui.Text:create()
    :align(display.CENTER, w/2, h - top_name)
    :addTo(var.widget)
    textname:setFontName(Const.DEFAULT_FONT_NAME)
    textname:setString(var.uname)
    textname:setFontSize(24)
    textname:setColor(Const.COLOR_WHITE_1_C3B)


    ccui.ImageView:create("img_line01.png",UI_TEX_TYPE_PLIST)
    :align(display.CENTER,w/2,h - top_line)
    :addTo(var.widget)
end


function PanelMyGroupOp.onBtnClicked(pSender)
    local btnName = pSender:getName()
    print("btnName=========", btnName)
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
    --NetClient.OPviewType = false
    EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_group_op"})
end

function PanelMyGroupOp.addBtnClickedEvent()
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
        --NetClient.OPviewType = false
        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_group_op"})
    end

    for i = 1, #btnNames do
        var.widget:getWidgetByName(btnNames[i]):addClickEventListener(btnCallBack)
    end
end


return PanelMyGroupOp