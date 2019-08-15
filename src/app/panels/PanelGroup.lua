--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/23 16:20
-- To change this template use File | Settings | File Templates.
--

local PanelGroup = {}
local var = {}
local LIST_PER_NUM = 5 -- 每页显示5条
local NEAR_TAG = {
    LEADER = 1,
    PLAYER = 2,
}
local Base_TAG = {
    SETUPTEAM = 1,
    DISSMISSTEAM = 2,
    LEAVETEAM = 3,
    MYTEAMREFLIST = 4,
    NEARREFLIST = 5,
    INVITEALL = 6,
    APPLYREFLIST = 7,
    CLEANUPALL = 8,
    FRIENDREFLIST = 9,
    FRIENDINVITEALL = 10,
    GUILDREFLIST = 11,
    GUILDINVITEALL = 12,
}
local TOP_TAG = {
    MYTEAM = 1,
    NEARPLAYER = 2,
    TEAMINVITE = 3,
    MYFRIEND = 4,
    GUILDMEMBER = 5,
}

local TAG_GROUP={
    TAG_GROUP_APPLY =100,
    TAG_GROUP_INVITE =101,
}

local SERVER_GROUP_TYPE = {
    [TOP_TAG.MYTEAM] = {},
    [TOP_TAG.NEARPLAYER] = {},
    --[TOP_TAG.TEAMINVITE] = {TAG_GROUP.TAG_GROUP_APPLY,TAG_GROUP.TAG_GROUP_INVITE},
    [TOP_TAG.TEAMINVITE] = {},
    [TOP_TAG.MYFRIEND] = {},
    [TOP_TAG.GUILDMEMBER] = {}
}

function PanelGroup.initView(params)
    local params = params or {}
    var = {}

    var.nearTag = 0
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGroup/UI_Group_BG_new.csb"):addTo(params.parent, params.zorder)
    --local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGroup/UI_Group_BG.csb"):addTo(params.parent, params.zorder)

    var.widget = widget:getChildByName("Panel_groupboard")
    var.toptag = 0
    ----[[
    if params.extend.pdata then
        if params.extend.pdata.type then
            var.type = 3
        elseif params.extend.pdata.tag then
            var.type = params.extend.pdata.tag
        end 
    else
        var.type =  0
    end

    --NetClient.OPviewType = false
    
    var.teamListItem = var.widget:getWidgetByName("Panel_list_item_zd"):hide()
    var.duiListItem = var.widget:getWidgetByName("Panel_groupListItem"):hide()
    var.teamListItem1 = var.widget:getWidgetByName("Panel_list_item_zd_1"):hide()
    var.listView = var.widget:getWidgetByName("ListView_grouplist")
    var.preBaseBtn =  var.widget:getWidgetByName("Button_fre"):hide()
    var.midBaseBtn =  var.widget:getWidgetByName("Button_mid"):hide()
    var.lastBaseBtn =  var.widget:getWidgetByName("Button_last"):hide()
    var.preBaseLabel = var.widget:getWidgetByName("Label_frebutton") 
    var.midBaseLabel = var.widget:getWidgetByName("Label_midbutton") 
    var.lastBaseLabel = var.widget:getWidgetByName("Label_lastbutton")
    var.teamred =  var.widget:getWidgetByName("Image_teamred"):hide()

    var.myname = game.GetMainNetGhost():NetAttr(Const.net_name)

    PanelGroup.addTopMenuTabClickEvent()
    PanelGroup.addLeftMenuTabClickEvent()
    PanelGroup.addBaseBtnClickedEvent()
    if var.type > 0 then
        var.topGroupButton:setButtonSelected(var.type)
        var.toptag = var.type
    else
        var.topGroupButton:setButtonSelected(TOP_TAG.MYTEAM)
        var.toptag = TOP_TAG.MYTEAM
    end 
    --PanelGroup.getnewNearData()

    var.listapplydata = {}
    var.listinvitedata = {}
    --PanelGroup.updatenewMyGroupInfo()
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        var.guild_name = MainAvatar:NetAttr(Const.net_guild_name)
        --var.player_name = MainAvatar:NetAttr(Const.net_name) 
        NetClient:ListGuild(0)
        NetClient:ListGuildMember(var.guild_name,101)
        var.FristGuildReq = true
    end
    PanelGroup.registeEvent()
    --NetClient:ListGuild(0)
    return var.widget
end

function PanelGroup.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_GROUP_LIST_CHANGED, PanelGroup.handleGroupListChange)
    :addEventListener(Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE, PanelGroup.handleGroupListChange)
    :addEventListener(Notify.EVENT_GUILD_MEMBER, PanelGroup.getguildListData)
end
 

function PanelGroup.addTopMenuTabClickEvent()
    var.topGroupButton = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_grouplist"))
    :addButton(var.widget:getWidgetByName("Button_nearplayer") )
    :addButton(var.widget:getWidgetByName("Button_apply"))
    :addButton(var.widget:getWidgetByName("Button_friend"))
    :addButton(var.widget:getWidgetByName("Button_guild"))
    :onButtonSelectChanged(function(event)
        PanelGroup.onTopButtonClicked(event.selected)
        var.toptag = event.selected
    end)
end

function PanelGroup.onTopButtonClicked(tag)
    var.topTag = tag
    local leftMenuCounts = #SERVER_GROUP_TYPE[var.topTag] or 0
    for i = 1, 2 do
        local leftBtn = var.leftGroupButton:getButtonAtIndex(i)
        if i <= leftMenuCounts then
            leftBtn:show()
        else
            leftBtn:hide()
        end
    end
    local startY = 516.00
    for i = 1, var.topGroupButton:getButtonsCount() do
        var.topGroupButton:getButtonAtIndex(i):setPositionY(startY)
        if i == tag and leftMenuCounts > 0 then
            var.subPanel:setPositionY(var.topGroupButton:getButtonAtIndex(i):getPositionY()-10)
            startY = startY - var.subPanel:getContentSize().height-63
        else
            if i == 1 then
                startY = startY - 94
            else
                startY = startY - 63
            end            
        end
    end

    var.leftGroupButton:clearSelect()
    var.leftGroupButton:setButtonSelected(1)

    if leftMenuCounts == 0 then
        PanelGroup.updateListViewByTag(var.topTag)
    end

    --var.widget:getWidgetByName("Text_desc_3"):setString(PARAM_CHART_TYPE[var.topTag])
    --var.widget:getWidgetByName("Text_desc_2"):setVisible(var.topTag~=TOP_TAG.LEVEL)
    --var.widget:getWidgetByName("Image_line_2"):setVisible(var.topTag~=TOP_TAG.LEVEL)
end

function PanelGroup.addLeftMenuTabClickEvent()
    var.subPanel = var.widget:getWidgetByName("Panel_sub")
    var.leftGroupButton = UIRadioButtonGroup.new()
    :addButton(var.subPanel:getWidgetByName("Button_apply"))
    :addButton(var.subPanel:getWidgetByName("Button_invite") )
    --:addButton(var.subPanel:getWidgetByName("Button_Mage"))
    --:addButton(var.subPanel:getWidgetByName("Button_DaoShi"))
    :onButtonSelectChanged(function(event)
        for i = 1, var.leftGroupButton:getButtonsCount() do
            var.leftGroupButton:getButtonAtIndex(i):getWidgetByName("Image_heigh"):setVisible(i==event.selected)
        end
        var.curpage = 1
        var.totalpage = 1
        PanelGroup.updateListViewByTag(event.selected)
    end)
end

function PanelGroup.updatebaseBtnByTag(tag)
    if tag == TOP_TAG.MYTEAM then
        if var.grouplistData then
            if (#var.grouplistData or 0) > 0 then
                if var.iamLeader then
                    var.preBaseBtn:hide()
                    var.midBaseBtn:show()
                    var.lastBaseBtn:hide()
                    var.midBaseBtn:setTag(Base_TAG.LEAVETEAM)
                    var.midBaseLabel:setString("离开队伍")
                else
                    var.preBaseBtn:hide()
                    var.midBaseBtn:show()
                    var.lastBaseBtn:hide()
                    var.midBaseBtn:setTag(Base_TAG.LEAVETEAM)
                    var.midBaseLabel:setString("离开队伍")
                end
            end
        else
            var.preBaseBtn:hide()
            var.midBaseBtn:show()
            var.lastBaseBtn:hide()
            var.midBaseBtn:setTag(Base_TAG.SETUPTEAM)
            var.midBaseLabel:setString("创建队伍")
        end
    elseif tag == TOP_TAG.NEARPLAYER then
        var.preBaseBtn:hide()
        var.midBaseBtn:show()
        var.lastBaseBtn:hide()
        var.midBaseBtn:setTag(Base_TAG.NEARREFLIST)
        var.midBaseLabel:setString("刷新列表")
    elseif tag == TOP_TAG.TEAMINVITE then
        var.preBaseBtn:show()
        var.midBaseBtn:hide()
        var.lastBaseBtn:show()
        var.preBaseBtn:setTag(Base_TAG.APPLYREFLIST)
        var.lastBaseBtn:setTag(Base_TAG.CLEANUPALL)
        var.preBaseLabel:setString("刷新列表")
        var.lastBaseLabel:setString("清空列表")
        if #NetClient.mGroupInvite == 0 or #NetClient.mGroupApplyers == 0 then
            var.lastBaseBtn:setBright(false)
        else
            var.lastBaseBtn:setBright(true)
        end
    elseif tag == TOP_TAG.MYFRIEND then
        var.preBaseBtn:hide()
        var.midBaseBtn:show()
        var.lastBaseBtn:hide()
        var.midBaseBtn:setTag(Base_TAG.FRIENDREFLIST)
        var.midBaseLabel:setString("刷新列表")

    elseif tag == TOP_TAG.GUILDMEMBER then
        var.preBaseBtn:hide()
        var.midBaseBtn:show()
        var.lastBaseBtn:hide()
        var.midBaseBtn:setTag(Base_TAG.GUILDREFLIST)
        var.midBaseLabel:setString("刷新列表")
    end
    
    if (#PanelGroup.handleGetnewteamlistdata(1)+#PanelGroup.handleGetnewteamlistdata(0)) > 0 then
        var.teamred:show()
        var.teamred:setLocalZOrder(100)
    else
        var.teamred:hide()
    end
end
function PanelGroup.addBaseBtnClickedEvent()
    local function btnCallBack(pSender)
        local btntag =  pSender:getTag()
        if btntag == Base_TAG.SETUPTEAM then
            NetClient:CreateGroup(0)
        elseif btntag == Base_TAG.LEAVETEAM then
            NetClient.mGroupApplyers = {}
            NetClient:LeaveGroup()
        elseif btntag == Base_TAG.DISSMISSTEAM then
            NetClient:LeaveGroup()
        elseif btntag == Base_TAG.MYTEAMREFLIST then
            PanelGroup.updateListViewByTag(TOP_TAG.MYTEAM)
        elseif btntag == Base_TAG.NEARREFLIST then
            PanelGroup.updateListViewByTag(TOP_TAG.NEARPLAYER) 
        elseif btntag == Base_TAG.APPLYREFLIST then
            PanelGroup.updateListViewByTag(TOP_TAG.TEAMINVITE)
        elseif btntag == Base_TAG.CLEANUPALL then
            NetClient:resetGroupApplyAndInVite()     
        elseif btntag == Base_TAG.FRIENDREFLIST then
            PanelGroup.updateListViewByTag(TOP_TAG.MYFRIEND)     
        elseif btntag == Base_TAG.GUILDREFLIST then
            if var.FristGuildReq then
                NetClient:ListGuild(0)
                NetClient:ListGuildMember(var.guild_name,101)
                var.FristGuildReq = false
            end
            --PanelGroup.updateListViewByTag(TOP_TAG.GUILDMEMBER)           
        end
    end
    var.preBaseBtn:addClickEventListener(btnCallBack)
    var.midBaseBtn:addClickEventListener(btnCallBack)
    var.lastBaseBtn:addClickEventListener(btnCallBack)

    var.checkBox = var.widget:getWidgetByName("CheckBox_refuse")
    var.checkBox:addEventListener(function(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            NativeData.REFUSE_GROUP = true
            NativeData.HAND_GROUP = false
            NativeData.AUTO_GROUP = false
        elseif eventType == ccui.CheckBoxEventType.unselected then
            --NativeData.REFUSE_GROUP = false
            --NativeData.AUTO_GROUP = true
        end
        PanelGroup.updatecheckBox()
    end)
    var.handcheckBox = var.widget:getWidgetByName("CheckBox_hand")
    var.handcheckBox:addEventListener(function(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            NativeData.REFUSE_GROUP = false
            NativeData.HAND_GROUP = true
            NativeData.AUTO_GROUP = false   
        elseif eventType == ccui.CheckBoxEventType.unselected then
            --NativeData.HAND_GROUP = false
            --NativeData.AUTO_GROUP = true
        end
        PanelGroup.updatecheckBox()
    end)
    var.autocheckBox = var.widget:getWidgetByName("CheckBox_auto")
    var.autocheckBox:addEventListener(function(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
                NativeData.REFUSE_GROUP = false
                NativeData.HAND_GROUP = false
                NativeData.AUTO_GROUP = true 
        elseif eventType == ccui.CheckBoxEventType.unselected then
            --NativeData.AUTO_GROUP = false
            --NativeData.HAND_GROUP = true
        end
        PanelGroup.updatecheckBox()
    end)
    PanelGroup.updatecheckBox()
end
function PanelGroup.updatecheckBox()
    var.checkBox:setSelected(NativeData.REFUSE_GROUP)
    var.handcheckBox:setSelected(NativeData.HAND_GROUP)
    var.autocheckBox:setSelected(NativeData.AUTO_GROUP)
end
function PanelGroup.updateListViewByTag(tag)
    if tag == TOP_TAG.MYTEAM then
        PanelGroup.updatenewMyGroupInfo()
    else 
        PanelGroup.updateinfolist(tag)
    end
    PanelGroup.updatebaseBtnByTag(tag)
end
function PanelGroup.updateinfolist(tag)
    
    local GroupType = 0
    if (#NetClient.mGroupMembers or 0) > 0 then
        GroupType = 1
    end
    local selectArray = {}
    local infolistdata 
    if tag == TOP_TAG.NEARPLAYER then
        infolistdata = PanelGroup.getnewNearData()
    elseif tag == TOP_TAG.TEAMINVITE then
        infolistdata = PanelGroup.handleGetnewteamlistdata(GroupType)
    elseif tag == TOP_TAG.MYFRIEND then
        infolistdata = PanelGroup.getfriendListData(true)
    elseif tag == TOP_TAG.GUILDMEMBER then
        infolistdata = var.MemberData
    end
    if not infolistdata then
        return 
    else
        for i=1,#infolistdata do
            if (not infolistdata[i].job) or (not infolistdata[i].level) then
                return
            end
        end
    end
    var.listView:removeAllItems()
    --print("TZ:infolistdata:",(#infolistdata or 0))
    local function btnClicked(pSender)
        local btnName = pSender:getName()
        local btnIdx = pSender.idx
        local name = infolistdata[btnIdx].name
        local gruopid = infolistdata[btnIdx].group_id
        local myname = var.myname
        if btnName == "Button_agree" then
            if GroupType > 0 then
                NetClient:AgreeJoinGroup(name)
                NetClient:removeGroupApply(name)
            else
                NetClient:AgreeInviteGroup(name, gruopid)
                NetClient:removeGroupInvite(gruopid)
            end
        elseif btnName == "Button_reject" then
            if GroupType > 0 then
                NetClient:removeGroupApply(name)
            else
                NetClient:removeGroupInvite(gruopid)
            end
        elseif btnName == "Button_item" then
            local itype = pSender.type
            if GroupType > 0 then
                if NetClient.mCharacter.mGroupLeader ~= myname then
                    NetClient:alertLocalMsg("只有队长才能发出邀请哦！","alert")
                elseif #NetClient.mGroupMembers >= Const.GROUP_MAX_MEMBER then
                    NetClient:alertLocalMsg("队伍人数已达上限！","alert")
                else
                    NetClient:InviteGroup(name)
                end
            else
                if itype == 1 then
                    NetClient:alertLocalMsg("你还没有队伍,请先创建队伍！","alert")
                --elseif itype == 2 and #NetClient:getNearGroupMemberByID(gruopid) == Const.GROUP_MAX_MEMBER then
                    --NetClient:alertLocalMsg("队伍人数已达上限！","alert")
                else
                    NetClient:JoinGroup(gruopid)
                end
            end
        elseif btnName == "listItem" then
            --if NetClient.OPviewType then return end
            for i= 1,#infolistdata do 
                if i == btnIdx then
                    selectArray[i]:setVisible(true)
                else
                    selectArray[i]:setVisible(false)
                end    
            end
         
            if myname ~= name then
                --require("app.views.group.MyGroupOpView").initView({ parent = var.widget, uname = name})
                EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group_op", pdata={uname=name}})
            end
        end
    end

    if infolistdata then
        local offLineColor = cc.c3b(176, 176, 176)
        local onLineColor = cc.c3b(18, 207, 42)
        if tag == TOP_TAG.TEAMINVITE then
            for i = 1, #infolistdata do  
                local groupPlayer = infolistdata[i]
                local listItem = var.teamListItem1:clone():show()                       
                listItem:getWidgetByName("item_name"):setString(groupPlayer.name)
                if groupPlayer.job > 0 then
                    listItem:getWidgetByName("item_job"):setString(game.getJobStr(groupPlayer.job))
                else
                    listItem:getWidgetByName("item_job"):setString("")
                end
                if groupPlayer.level > 0 then
                    listItem:getWidgetByName("item_level"):setString(groupPlayer.level)
                else
                    listItem:getWidgetByName("item_level"):setString("")
                end                     
                if GroupType > 0 then
                    listItem:getWidgetByName("item_state"):setString("申请入队")
                else
                    listItem:getWidgetByName("item_state"):setString("邀请入队")
                end
                local confirmBtn = listItem:getWidgetByName("Button_agree")
                confirmBtn:addClickEventListener(btnClicked)
                confirmBtn.idx = i

                listItem:setTouchEnabled(true):addClickEventListener(btnClicked)
                listItem:setName("listItem")
                listItem.idx = i
                selectArray[i] = listItem:getWidgetByName("Image_high")

                local cancelBtn = listItem:getWidgetByName("Button_reject")
                cancelBtn:addClickEventListener(btnClicked)
                cancelBtn.idx = i
                var.listView:pushBackCustomItem(listItem)
            end
        else
            for i = 1, #infolistdata do
                --print("TZ:infolistdata:",#infolistdata)
                local groupPlayer = infolistdata[i]
                local listItem = var.teamListItem:clone():show()      
                --print("TZ:groupPlayer:",groupPlayer.name)
                listItem:getWidgetByName("item_name"):setString(groupPlayer.name)
                if groupPlayer.job > 0 then
                    listItem:getWidgetByName("item_job"):setString(game.getJobStr(groupPlayer.job))
                else
                    listItem:getWidgetByName("item_job"):setString("")
                end
                if groupPlayer.level > 0 then
                    listItem:getWidgetByName("item_level"):setString(groupPlayer.level)
                else
                    listItem:getWidgetByName("item_level"):setString("")
                end   
                local itemBtn = listItem:getWidgetByName("Button_item")
                itemBtn:addClickEventListener(btnClicked)
                itemBtn.idx = i
                if tag == TOP_TAG.NEARPLAYER then
                    listItem:getWidgetByName("item_state"):setString(groupPlayer.stateStr)
                    if GroupType > 0 then
                        if groupPlayer.stateStr == "未组队" then
                            listItem:getWidgetByName("Label_itembtn"):setString("邀请入队")
                            itemBtn.type = 1 
                        else
                            listItem:getWidgetByName("Button_item"):hide()
                        end
                    else
                        if groupPlayer.stateStr == "未组队" then
                            listItem:getWidgetByName("Label_itembtn"):setString("邀请入队")
                            itemBtn.type = 1  
                        else
                            listItem:getWidgetByName("Label_itembtn"):setString("申请入队")
                            if groupPlayer.group_leader then
                                if groupPlayer.group_leader == groupPlayer.name then
                                    listItem:getWidgetByName("ImageView_captain"):show()
                                else
                                    listItem:getWidgetByName("ImageView_captain"):hide()
                                end
                            end
                            if groupPlayer.group_members then
                                local msg = game.make_str_with_color(Const.COLOR_GREEN_1_STR,"(")..groupPlayer.group_members ..game.make_str_with_color(Const.COLOR_GREEN_1_STR, "/"..Const.GROUP_MAX_MEMBER..")")
                                local richLabel, richWidget = util.newRichLabel(cc.size(listItem:getWidgetByName("Label_groupnum"):getContentSize().width, 0), 0)
                                richWidget.richLabel = richLabel
                                richWidget:setTouchEnabled(false)
                                util.setRichLabel(richLabel, msg, "", 24, Const.COLOR_WHITE_1_OX)
                                richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
                                listItem:getWidgetByName("Label_groupnum"):addChild(richWidget)
                                listItem:getWidgetByName("Label_groupnum"):show()
                                listItem:getWidgetByName("item_state"):setPositionY(listItem:getWidgetByName("item_state"):getPositionY()+10)
                            end
                            if groupPlayer.isfull then
                                itemBtn.type = 2 
                            else
                                itemBtn.type = 0 
                            end                        
                        end 
                    end       
                else
                    if groupPlayer.online_state > 0 then
                        listItem:getWidgetByName("item_state"):setTextColor(onLineColor)
                        listItem:getWidgetByName("item_state"):setString("在线")
                    else
                        listItem:getWidgetByName("item_state"):setTextColor(offLineColor)
                        listItem:getWidgetByName("item_state"):setString("离线")                     
                    end
                    listItem:getWidgetByName("Label_itembtn"):setString("邀请入队")
                    itemBtn.type = 1
                    listItem:getWidgetByName("ImageView_captain"):hide()
                end
                
                listItem:setTouchEnabled(true):addClickEventListener(btnClicked)
                listItem:setName("listItem")
                listItem.idx = i
                selectArray[i] = listItem:getWidgetByName("Image_high")
                --listItem:getWidgetByName("Button_itemsel"):hide()                          
                var.listView:pushBackCustomItem(listItem)
            end
        end    
    end
    --print("TZ:infolist:",(#infolistdata or 0))
end
function PanelGroup.updatenewMyGroupInfo() 
    if #NetClient.mGroupMembers ==  0 then
        var.grouplistData = nil 
        var.listView:removeAllItems()
        return 
    end
    local listData = clone(NetClient.mGroupMembers)
    if not listData then
        return
    else
        for i = 1, #listData do
            if (not listData[i].job) or  (not listData[i].level) then
                return
            end
        end
    end
    var.listView:removeAllItems()
    local groupLeader = NetClient.mCharacter.mGroupLeader
    local myname = var.myname
    var.iamLeader = (groupLeader == myname)
    local function sortF(fa, fb)
        if fa.name == myname then--队长的名字排在前面
            return true
        elseif fa.name == groupLeader and fb.name ~= myname then
            return true
        elseif fb.name == myname then
            return false
        elseif fb.name == groupLeader then
            return false
        end
        return checkint(fa.state)> checkint(fb.state)
    end
    table.sort(listData, sortF )
    local selectArray = {}

    var.grouplistData = listData
    local function itemClicked(pSender)
        --if NetClient.OPviewType then return end
        local idx = pSender.idx
        for i= 1,#listData do 
            if i == idx then
                selectArray[i]:setVisible(true)
            else
                selectArray[i]:setVisible(false)
            end    
        end
        --print("TZ:listDataname:",listData[idx].name)
        if myname ~= listData[idx].name then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group_op", pdata={uname=listData[idx].name}})
            --require("app.views.group.MyGroupOpView").initView({ parent = var.widget, uname = listData[idx].name})
        end
    end

    local offLineColor = cc.c3b(176, 176, 176)
    local onLineColor = cc.c3b(18, 207, 42)
    for i = 1, #listData do
        local groupPlayer = listData[i]
        local listItem = var.duiListItem:clone():show()
        local uname = groupPlayer.name

        listItem:getWidgetByName("Label_name"):setString(uname)
        if groupPlayer.job > 0 then
            listItem:getWidgetByName("Label_job"):setString(game.getJobStr(groupPlayer.job))
        else
            listItem:getWidgetByName("Label_job"):setString("")
        end
        
        if groupPlayer.level > 0 then
            listItem:getWidgetByName("Label_level"):setString(groupPlayer.level)
        else
            listItem:getWidgetByName("Label_level"):setString("")
        end
        
        listItem:getWidgetByName("ImageView_captain"):setVisible(uname == groupLeader)
        if uname == groupLeader then
            listItem:getWidgetByName("Label_zhiwei"):setString("("..#listData.."/"..Const.GROUP_MAX_MEMBER..")")
            listItem:getWidgetByName("Label_zhiwei"):setTextColor(onLineColor)
        end        
        if groupPlayer.state == 100 then
            -- 离线
            listItem:getWidgetByName("Label_state"):setTextColor(offLineColor)
            listItem:getWidgetByName("Label_state"):setString("离线")
        else
            listItem:getWidgetByName("Label_state"):setTextColor(onLineColor)
            listItem:getWidgetByName("Label_state"):setString("在线")  
        end
        listItem:getWidgetByName("Image_ying"):setVisible(i%2 == 1) 
        listItem:setTouchEnabled(true):addClickEventListener(itemClicked)
        listItem.idx = i
        selectArray[i] = listItem:getWidgetByName("Image_high")
        --[[
        :addClickEventListener(function (pSender)
            listItem:getWidgetByName("Image_high"):setVisible(true)
            require("app.views.group.MyGroupOpView").initView({ parent = var.widget, uname = uname})
                    end)
                    ]]
        var.listView:pushBackCustomItem(listItem)
    end
end

function PanelGroup.handleGetteamlistdata()
    
    for _,v in pairs(NetClient.mGroupApplyers) do
        var.listapplydata[#var.listapplydata + 1] = {name = v,}
    end
    --print("TZ:Applyers:",#var.listapplydata)
    for k,v in pairs(NetClient.mGroupInvite) do
        var.listinvitedata[#var.listinvitedata + 1] = {groupid = k, name = v,}
    end
    --print("TZ:Invite:",#var.listinvitedata)
end

function PanelGroup.handleGetnewteamlistdata(tag)
    var.listapplydata = {}
    var.listinvitedata = {}
    if (#NetClient.mGroupApplyers or 0) > 0 then
        for i = 1,#NetClient.mGroupApplyers do 
            var.listapplydata[#var.listapplydata + 1] = NetClient.mGroupApplyers[i]
        end
    end
    --print("TZ:newApplyers:",#var.listapplydata)
    if (#NetClient.mGroupInvite or 0) > 0 then
        for i = 1,#NetClient.mGroupInvite do 
            var.listinvitedata[#var.listinvitedata + 1] = NetClient.mGroupInvite[i]
        end
    end
    if tag > 0 then
        return var.listapplydata
    else
        return var.listinvitedata
    end
    --print("TZ:newInvite:",#var.listinvitedata)
end

function PanelGroup.getnewNearData(tag)
    local allPlayers = {}
    local netNearGroupInfo = NetClient.nearByGroupInfo or {}
    for i,v in ipairs(NetCC:getNearGhost(Const.GHOST_PLAYER)) do
        local player = CCGhostManager:getPixesGhostByID(v)
        if player then
            local temp = {
                name = player:NetAttr(Const.net_name),
                pid = player:NetAttr(Const.net_id),
                job = player:NetAttr(Const.net_job),
                level = player:NetAttr(Const.net_level),
                power = player:NetAttr(Const.net_fight_point),
                locateMap = player:NetAttr(Const.net_cur_map),
                state = player:NetAttr(Const.net_state),
            }
            table.insert(allPlayers, temp)
        end
    end
    --[[
    local curList = {}
    if tag == nil or tag == NEAR_TAG.LEADER then
        local curTag = NEAR_TAG.LEADER
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            local nearByGroupInfo = netNearGroupInfo[player.pid]
            if nearByGroupInfo and nearByGroupInfo.group_leader == player.name and nearByGroupInfo.group_leader ~= NetClient.mCharacter.mGroupLeader then
                player.group_id = nearByGroupInfo.group_id
                player.stateStr = nearByGroupInfo.group_members.."/"..Const.GROUP_MAX_MEMBER
                player.isfull = (nearByGroupInfo.group_members == Const.GROUP_MAX_MEMBER)
                table.insert(curList, player)
            end
        end     
    end
    ]]
    var.nearListData = {}
    if tag == nil or tag == NEAR_TAG.PLAYER then
        local curTag = NEAR_TAG.PLAYER
        local curList = {}
        for i = 1, #allPlayers do
            local player = allPlayers[i]
            --print("TZ:PLAYER:",player.pid)
            local nearByGroupInfo = netNearGroupInfo[player.pid]
            if not nearByGroupInfo then
                player.stateStr = "未组队"
                table.insert(curList, player)
            else            
                player.group_id = nearByGroupInfo.group_id
                player.stateStr = "已组队"
                player.group_leader = nearByGroupInfo.group_leader
                player.group_members = nearByGroupInfo.group_members
                --player.stateStr = "已组队".."("..nearByGroupInfo.group_members.."/"..Const.GROUP_MAX_MEMBER..")"
                if nearByGroupInfo.group_leader == player.name and nearByGroupInfo.group_leader ~= NetClient.mCharacter.mGroupLeader then
                    player.isfull = (nearByGroupInfo.group_members == Const.GROUP_MAX_MEMBER)
                end
                table.insert(curList, player)                    
            end
        end
        var.nearListData = curList
    end
    --print("TZ:curList:",#var.nearListData)
    return var.nearListData
    --print("TZ:curList:",#var.nearListData)   
end

function PanelGroup.getfriendListData(needsort)
    local listData = {}
    local onlinenum = 0
    local netNearGroupInfo = NetClient.nearByGroupInfo or {}
    for _,v in pairs(NetClient.mFriends) do
        --print("TZ:mFriends:",v.title)
        if v.title == 100 then
            if not NetClient:isPlayerMyInGroup(v.name) then
                if v.online_state ~= 0 then 
                    onlinenum = onlinenum + 1 
                end
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
    return listData
end

function PanelGroup.getguildListData(event)
    --print("TZ:guild:","getguildListData")
    var.MemberData = {}
    if event and event.data then
        --print("TZ:guildevent:",event.data)
        local guild = event.data
        if guild then
            local compFunction = function(member1,member2)
                if member1.title == member2.title then
                    return member1.level > member2.level
                end
                return member1.title > member2.title
            end
            if guild.mRealMembers then
                for k,v in pairs(guild.mRealMembers) do
                    local member = {}
                    if var.myname ~= v.nick_name then
                        if not NetClient:isPlayerMyInGroup(v.nick_name) then
                            member.name    = v.nick_name
                            --print("TZ:member:",member.name)
                            member.title        = v.title
                            member.online_state       = v.online
                            --member.gender       = v.gender
                            member.job          = v.job
                            member.level        = v.level
                            member.fight        = v.fight
                            member.guildpt      = v.guildpt
                            member.entertime    = v.entertime
                            table.insert(var.MemberData,member)
                        end
                    end
                end
                table.sort(var.MemberData, compFunction)
            end
        end
    end
    if not var.FristGuildReq then
        PanelGroup.updateListViewByTag(TOP_TAG.GUILDMEMBER) 
        var.FristGuildReq = true
    end
                     
    --return var.MemberData
end

function PanelGroup.handleGroupListChange()
    PanelGroup.updateListViewByTag(var.toptag)
end

function PanelGroup.OnPanelClose()
   -- NetClient.OPviewType = false
end

return PanelGroup