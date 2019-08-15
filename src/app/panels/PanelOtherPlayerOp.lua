--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/08 13:12
-- To change this template use File | Settings | File Templates.
--PanelOtherPlayerOp

-- fromfriendpanel
-- fromchat
-- fromtouch
local FROM_TAG_FRIEND = 1 -- 好友面板
local FROM_TAG_CHAT = 2 -- 聊天面板
local FROM_TAG_TOUCH = 3 -- 场景选择

--{text="交 易",name="Button_trade"},
local BTN_CFG = {
    [FROM_TAG_FRIEND] = {
        [1]={{text="查看装备",name="Button_viewother"},{text="发送私聊",name="Button_whisper"},
            {text="删  除",name="Button_delete"},{text="转至仇人",name="Button_toenemy"},
            {text="转黑名单",name="Button_toblank"},},--好友
        [2]={{text="查看装备",name="Button_viewother"},{text="发送私聊",name="Button_whisper"},
            {text="删  除",name="Button_delete"},{text="转至好友",name="Button_tofriend"}, 
            {text="转黑名单",name="Button_toblank"},},--仇人
        [3]={{text="查看装备",name="Button_viewother"},{text="发送私聊",name="Button_whisper"},
            {text="删  除",name="Button_delete"},{text="转至好友",name="Button_tofriend"},
            {text="转至仇人",name="Button_toenemy"},},--黑名单
    },
    [FROM_TAG_CHAT] = {{text="交 易",name="Button_trade"},{text="查看装备",name="Button_viewother"}, {text="邀请组队",name="Button_invitegroup"},
        {text="发送私聊",name="Button_whisper"},{text="加好友",name="Button_friendadd"},
        {text="申请入队",name="Button_applygroup"},  {text="黑名单",name="Button_friendblack"}},
    [FROM_TAG_TOUCH] = {{text="交 易",name="Button_trade"},{text="查看装备",name="Button_viewother"},{text="邀请组队",name="Button_invitegroup"},
     {text="发送私聊",name="Button_whisper"}, {text="加好友",name="Button_friendadd"},{text="交 易",name="Button_trade"}},
}


local PanelOtherPlayerOp = {}

local var = {}

function PanelOtherPlayerOp.initView(params)
    local params = params or {}
    if not params.extend or not params.extend.pdata or not params.extend.pdata.name then print("rrrrr") return end
    var = {}

    var.mTargetName = params.extend.pdata.name
    var.widget = ccui.Widget:create():addTo(params.parent, params.zorder)
    local fromFlag = params.extend.pdata.fromFlag or 1
    local subtype = params.extend.pdata.subtype or 1
    PanelOtherPlayerOp.addSprite(fromFlag,subtype)
    return var.widget
end


function PanelOtherPlayerOp.addSprite(fromFlag,subtype)
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
    local h = top + bottom +  rows * buttonSize.height + (rows -1 )*vspace
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
                btnOp:addClickEventListener(PanelOtherPlayerOp.onBtnClicked) 
            end  
        end
    end

    local textname = ccui.Text:create()
    :align(display.CENTER, w/2, h - top_name)
    :addTo(var.widget)
    textname:setFontName(Const.DEFAULT_FONT_NAME)
    textname:setString(var.mTargetName)
    textname:setFontSize(24)
    textname:setColor(Const.COLOR_WHITE_1_C3B)


    ccui.ImageView:create("img_line01.png",UI_TEX_TYPE_PLIST)
    :align(display.CENTER,w/2,h - top_line)
    :addTo(var.widget)
end

function PanelOtherPlayerOp.onBtnClicked(pSender)
    local btnName = pSender:getName()
    print("btnName=========", btnName)
    if name == "Button_trade" then
        NetClient:TradeInvite(var.mTargetName)
    elseif btnName == "Button_viewother" then
--        NetClient:InfoPlayer(var.mTargetName)
        NetClient:CheckPlayerEquip(var.mTargetName)
    elseif btnName == "Button_whisper" then
        NetClient:privateChatTo(var.mTargetName)
    elseif btnName == "Button_delete" then
        NetClient:FriendChange(var.mTargetName, -1)
    elseif btnName == "Button_tofriend" or btnName == "Button_friendadd" then
        NetClient:FriendChange(var.mTargetName, Const.FRIEND_TITLE.FRIEND)
    elseif btnName == "Button_toenemy" then
        NetClient:FriendChange(var.mTargetName, Const.FRIEND_TITLE.ENEMY)
    elseif btnName == "Button_toblank" or btnName == "Button_friendblack" then
        NetClient:FriendChange(var.mTargetName, Const.FRIEND_TITLE.BLACK)
    elseif name == "Button_invitegroup" then
        if #NetClient.mGroupMembers <= 0 then
            NetClient:alertLocalMsg("你还没有队伍,请先创建队伍！","alert")
        elseif NetClient.mCharacter.mGroupLeader ~= game.GetMainNetGhost():NetAttr(Const.net_name) then
            NetClient:alertLocalMsg("只有队长才能发出邀请哦！","alert")
        elseif NetClient:isPlayerMyInGroup(var.mTargetName) then
            NetClient:alertLocalMsg("对方已在队伍中！","alert")
        elseif #NetClient.mGroupMembers >= Const.GROUP_MAX_MEMBER then
            NetClient:alertLocalMsg("队伍人数已达上限！","alert")
        else
            NetClient:InviteGroup(var.mTargetName)
        end
    elseif name == "Button_applygroup" then
        if #NetClient.mGroupMembers > 0 then
            NetClient:alertLocalMsg("你已经在队伍中了！","alert")
        else
            local group_id = NetClient:getGroupIDByName(var.mTargetName)
            if not group_id then
                NetClient:alertLocalMsg("对方不是队长！","alert")
            elseif NetClient:getNearGroupMemberByID(group_id) >= Const.GROUP_MAX_MEMBER then
                NetClient:alertLocalMsg("队伍人数已达上限！","alert")
            else
                NetClient:JoinGroup(group_id)
            end
        end
    elseif name == "Button_copyname" then

    end
    EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_friend_op"})
end

return PanelOtherPlayerOp