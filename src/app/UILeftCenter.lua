local UILeftCenter = {}
local var = {}
local xmf_btn_name = {"单倍","双倍","四倍"}

PAGE_TASK = 0
PAGE_FUBEN = 1
PAGE_XM = 2
PAGE_TEAM = 3
PAGE_ACT = 4 -- 活动面板

SUB_PAGE_ACT = {
    MYCC = 1, --魔影重重
    LCBZ = 2,--龙城宝藏
    SMZC =3, --神魔战场
    MMSS = 4, -- 蒙面杀手
    TTZC = 5, -- 图腾战场
    SWMY = 6, -- 神威魔域
    HCZB = 7, -- 皇城争霸
    HHMJ = 8, -- 行会秘境
}

function UILeftCenter.init_ui(leftCenter)
    var = {}
    var.actAward = {}
	var.widget = leftCenter:getChildByName("Panel_leftcenter")
    var.widget:align(display.LEFT_CENTER, 0, Const.VISIBLE_Y+Const.VISIBLE_HEIGHT/2):setScale(Const.minScale)

    var.showPanel = var.widget:getWidgetByName("Panel_show"):show()
    var.hidePanel = var.widget:getWidgetByName("Panel_hide"):hide()
    var.taskPanel = var.widget:getWidgetByName("Panel_task")
    var.teamPanel = var.widget:getWidgetByName("Panel_team"):hide()
    var.xmPanel = var.widget:getWidgetByName("Panel_xmd"):hide()
    var.xmPanelHide = var.widget:getWidgetByName("Panel_xmd_hide"):hide()

    var.taskListView = var.showPanel:getWidgetByName("ListView_task")
    var.taskItemNode = var.showPanel:getWidgetByName("Button_taskboard")
    var.taskItemNode:hide()

    var.guideMainTask = var.widget:getWidgetByName("Image_maintask"):hide()
    var.gMainTaskPosX = var.guideMainTask:getPositionX()
    var.gMainTaskPosY = var.guideMainTask:getPositionY()
    var.guideGetTask = var.widget:getWidgetByName("Image_gettask"):hide()
    var.gGetTaskPosX = var.guideGetTask:getPositionX()
    var.gGetTaskPosY = var.guideGetTask:getPositionY()

    var.showAutoGuide = false

    var.nteam = var.widget:getWidgetByName("Image_nteam")
    var.frilabel = var.widget:getWidgetByName("Label_friteam")
    var.selabel = var.widget:getWidgetByName("Label_seteam")
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        var.pjob = MainAvatar:NetAttr(Const.net_job)
        var.myName = MainAvatar:NetAttr(Const.net_name)
    end

    var.btn_show = var.hidePanel:getWidgetByName("Button_show")
    var.btn_show:addClickEventListener(function ( pSender )
        UILeftCenter.showTaskBoard()
    end)
    var.btn_hide = var.showPanel:getWidgetByName("Button_hide")
    var.btn_hide:addClickEventListener(function ( pSender )
            UILeftCenter.hideTaskBoard()
        end)
    var.btn_husong = var.showPanel:getWidgetByName("Button_HuSong"):hide()
    var.btn_husong:addClickEventListener(function ( pSender )
            NetClient:PushLuaTable("gui.PanelDaily.onYaBiaoInfo",util.encode({actionid = "husongbc"}))
        end)
    var.btn_chuansong = var.showPanel:getWidgetByName("Button_ChuanSong"):hide()
    var.btn_chuansong:addClickEventListener(function ( pSender )
            NetClient:PushLuaTable("gui.PanelDaily.onYaBiaoInfo",util.encode({actionid = "chuansongbc"}))
        end)

     
    var.teamPanel:getWidgetByName("Button_searchteam"):addClickEventListener(function(pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group"})
    end)

    var.xm_btn_show = var.xmPanelHide:getWidgetByName("Button_show")
    var.xm_btn_show:addClickEventListener(function ( pSender )
        UILeftCenter.showXMDBoard()
    end)
    var.xm_btn_hide = var.xmPanel:getWidgetByName("Button_hide_xmd")
    var.xm_btn_hide:addClickEventListener(function ( pSender )
        UILeftCenter.hideXMDBoard()
    end)
    var.teamPanel:getWidgetByName("Button_createteam"):addClickEventListener(function(pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group"})
    end)
    var.teamlistView = var.teamPanel:getWidgetByName("ListView_team") 
    var.teamListItem = var.teamPanel:getWidgetByName("Panel_listitem"):hide()

    local buttonGroup = UIRadioButtonGroup.new()
    :addButton(var.showPanel:getWidgetByName("Button_taskarrow"))
    :addButton(var.showPanel:getWidgetByName("Button_team"))
    :onButtonSelectChanged(function(event)
        if event.selected == 1 then
            var.mCurShowPage = PAGE_TASK
            UILeftCenter.showPage(PAGE_TASK)
        elseif event.selected == 2 then
            var.mCurShowPage = PAGE_TEAM
            UILeftCenter.showPage(PAGE_TEAM)
        end
    end)
    for i = 1,buttonGroup:getButtonsCount() do
        buttonGroup:getButtonAtIndex(i):getTitleRenderer():setPositionY(22)
    end
    buttonGroup:setButtonSelected(1)
    UILeftCenter.initTaskList()
    UILeftCenter.handleKingMapList()
    UILeftCenter.registeEvent()

end

function UILeftCenter.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_TASK_CHANGE, UILeftCenter.onTaskChange)
    :addEventListener(Notify.EVENT_FUBEN_DATA, UILeftCenter.handleFubenMsg)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, UILeftCenter.handlePanelData)
    :addEventListener(Notify.EVENT_ITEM_CHANGE, UILeftCenter.freshXMF)
    :addEventListener(Notify.EVENT_PLAYER_INTVALUE_CHANGE,UILeftCenter.handleIntvalueChange)
    :addEventListener(Notify.EVENT_KING_UPATE_JF, UILeftCenter.handleUpdateKingJFPoint)
    :addEventListener(Notify.EVENT_KING_JF_AWARD_FLAG, UILeftCenter.handleUpdateKingAwardFlag)
    :addEventListener(Notify.EVENT_KING_UPATE_MAP_RANK_INFO,UILeftCenter.handleKingMapList)
    :addEventListener(Notify.EVENT_GROUP_LIST_CHANGED, UILeftCenter.handleGroupListChange)
    --:addEventListener(Notify.EVENT_APPLY_OR_INVITE_LIST_CHANGE, UILeftCenter.handleGroupListChange)
end

function UILeftCenter.handleIntvalueChange(event)
    if not event or not event.index then return end
    if event.index ~= Const.INT_UPDATE_ENTERCOPY_FLAG then return end

    if NetClient.mIntValue[Const.INT_UPDATE_ENTERCOPY_FLAG] == 1 then

    else
        UILeftCenter.removeAutoLeaveHandle()
        var.mCurShowPage = PAGE_TASK
        UILeftCenter.showPage(PAGE_TASK)
    end
end

function UILeftCenter.getvarWidget()
    return var.widget
end

function UILeftCenter.removeAutoLeaveHandle()
--    if var.autoLeaveHandle then
--        Scheduler.unscheduleGlobal(var.autoLeaveHandle)
--        var.autoLeaveHandle = nil
--    end
end

function UILeftCenter.cleanGame()
    var = {}
    UILeftCenter.removeAutoLeaveHandle()
end

function UILeftCenter.handleFubenMsg(event)
    local cmd = event.cmd
    if cmd == "enter" then
        var.widget:hide()
    elseif cmd == "exit" then
        var.widget:show()
    end
end
--[[
function UILeftCenter.countDownByCommand(dt)
    var.countDown = var.countDown - 1
    if var.countDown <= 0 then
        UILeftCenter.removeAutoLeaveHandle()
        return
    end
    var.countDownText:setString(game.convertSecondsToStr( var.countDown ))
end

function UILeftCenter.startCountDown(time, obj)
    UILeftCenter.removeAutoLeaveHandle()
    if time < 0 then return end
    var.countDown = time
    var.countDownText = obj
    var.countDownText:setString(game.convertSecondsToStr( var.countDown )):show()
    var.autoLeaveHandle = Scheduler.scheduleGlobal(UILeftCenter.countDownByCommand, 1)
end
--]]
function UILeftCenter.startCountDown(time, obj)
    if not obj then return end
    obj:stopAllActions()
    if time <= 0 then time = 0 end
    obj.countdown = time

    if time == 0 then return end
    obj:show()
    UILeftCenter.updateCountDownText(obj)
    obj:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(UILeftCenter.updateCountDownText))))
end

function UILeftCenter.updateCountDownText(pSender)
    if pSender then
        if gameLogin._isAutoLogining then pSender:stopAllActions() return end
        pSender.countdown = pSender.countdown - 1
        pSender:setString(game.convertSecondsToStr( pSender.countdown))
        if pSender.countdown <= 0 then
            pSender:stopAllActions()
            return
        end
    end
end

function UILeftCenter.onTaskChange(event)
    if event and (event.tid ~= Const.TASK_ID_FUBEN_MAINTASK and event.tid ~= Const.TASK_ID_FUBEN_SEXP) then
        UILeftCenter.updateTaskList(event.tid,event.statechange)
    elseif event.tid == Const.TASK_ID_FUBEN_MAINTASK or event.tid == Const.TASK_ID_FUBEN_SEXP then
        UILeftCenter.updateFubenInfo(event.tid)
    end
end

function UILeftCenter.updateFubenInfo(tid)
    if var.mCurShowPage ~= PAGE_FUBEN then return end
    local fuben_data = TaskData.list[tid]
    if not fuben_data then return end
    local curpanel = var.fubenPanel:getWidgetByName("Panel_fuben"):show()
    local state = math.fmod(fuben_data.mState,10)
    if state == 4 then --完成
        if var.panel_data then
            UIButtonGuide.addGuideTip(curpanel:getWidgetByName("Button_leave"),"点击领取奖励",UIButtonGuide.UI_TYPE_RIGHT)
            curpanel:getWidgetByName("Button_leave"):setTitleText("领取奖励"):addClickEventListener(function (pSender)
                if var.panel_data then
                    UIButtonGuide.handleButtonGuideClicked(curpanel:getWidgetByName("Button_leave"))
                    NetClient:PushLuaTable(var.panel_data.donecommand,util.encode({actionid = "done",multi = 1}))
                end
            end)
            -- local param = {
            --     name = Notify.EVENT_PANEL_ON_ALERT,
            --     panel = "fubendone",
            --     visible = true,
            --     award = var.panel_data.copy_award,
            --     confirmCallBack = function ()
            --         if var.panel_data then
            --             NetClient:PushLuaTable(var.panel_data.donecommand,util.encode({actionid = "done",multi = 1}))
            --             var.panel_data = nil
            --         end
            --     end
            -- }
            -- NetClient:dispatchEvent(param)
            UILeftCenter.startCountDown(var.panel_data.leavetime/1000, var.fubenPanel:getWidgetByName("AtlasLabel_time"))
        end
    elseif fuben_data.mState == 0 then
        UIButtonGuide.handleButtonGuideClicked(curpanel:getWidgetByName("Button_leave"))
        UILeftCenter.removeAutoLeaveHandle()
        var.fubenPanel:getWidgetByName("AtlasLabel_time"):stopAllActions()
        return
    end
    curpanel:getWidgetByName("Text_monster_value"):setString(fuben_data.mParam_1.."只")
end

function UILeftCenter.handlePanelData(event)
    if not event then return end
    if event.type == "fuben_data" then
        -- local fuben_data = TaskData.list[Const.TASK_ID_FUBEN_MAINTASK]
        var.panel_data = util.decode(event.data)
        if not var.panel_data then return end
        UILeftCenter.showPage(PAGE_FUBEN)
        var.mCurShowPage = PAGE_FUBEN
        local curpanel = var.fubenPanel:getWidgetByName("Panel_fuben"):show()
        --var.fubenPanel:getWidgetByName("Button_hide"):setTitleText("【副本】"..var.panel_data.name)
        var.fubenPanel:getWidgetByName("Text_hide"):setString("[副本]"..var.panel_data.name)
        for i=1,4 do
            local award_bg = var.fubenPanel:getWidgetByName("award_"..i)
            local award_item = var.panel_data.copy_award[i]
            if award_bg then
                if not award_item then
                    award_bg:hide()
                else
                    UIItem.getSimpleItem({
                        parent = award_bg,
                        name = award_item.name,
                        num = award_item.num,
                    })
                end
            end
        end
        UILeftCenter.startCountDown(var.panel_data.leavetime/1000*10, var.fubenPanel:getWidgetByName("AtlasLabel_time"))
        curpanel:getWidgetByName("Button_leave"):setTitleText("离开副本"):addClickEventListener(function (pSender)
            local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm ="是否立即退出当前副本？",
                confirmTitle = "确定", cancelTitle = "取消",countTime = var.panel_data.leavetime/1000*10,
                confirmCallBack = function ()
                    NetClient:PushLuaTable(var.panel_data.donecommand,util.encode({actionid = "leave"}))
                end
            }
            EventDispatcher:dispatchEvent(param)
        end)
    elseif event.type == "leftxm_data" then
        var.mCurShowPage = PAGE_XM
        var.panel_data = util.decode(event.data)
        if not var.panel_data then return end
        UILeftCenter.showPage(PAGE_XM)
        --[[
        for i=1,4 do
            local award_bg = var.xmPanel:getWidgetByName("xm_award_"..i)
            local award_item = var.panel_data.award[i]
            if award_bg then
                if not award_item then
                    award_bg:hide()
                else
                    UIItem.getSimpleItem({
                        parent = award_bg,
                        name = award_item.name,
                        num = award_item.num,
                    })
                end
            end
        end
        ]]
        var.xmPanel:getWidgetByName("label_left_xmf"):setString(var.panel_data.have_num)
        var.xmPanel:getWidgetByName("text_left_xmcount"):setString(var.panel_data.done_count.."/"..var.panel_data.max_count)
        var.xmPanel:getWidgetByName("Button_xm_done"):addClickEventListener(function (pSender)
            NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "fly_npc"}))
            UILeftCenter.showPage(PAGE_TASK)
        end)
        for i=1,3 do
            local need_num = var.panel_data.need_tab[i]
            if not need_num then need_num = 0 end
            var.xmPanel:getWidgetByName("label_xm_done_num_"..i):setString(need_num.."个")
            var.xmPanel:getWidgetByName("label_xm_done_last_"..i):setPositionX(var.xmPanel:getWidgetByName("label_xm_done_num_"..i):getPositionX()+var.xmPanel:getWidgetByName("label_xm_done_num_"..i):getContentSize().width)
            var.xmPanel:getWidgetByName("Button_labelxm_"..i):addClickEventListener(function (pSender)
                NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "task_done"..(i+1)}))
            end)
        end
    elseif event.type == "richangxm_fresh" then
        if var.mCurShowPage == PAGE_XM then
            var.panel_data = util.decode(event.data)
            if not var.panel_data then return end
            var.xmPanel:getWidgetByName("label_left_xmf"):setString(var.panel_data.have_num)
            var.xmPanel:getWidgetByName("text_left_xmcount"):setString(var.panel_data.done_count.."/"..var.panel_data.max_count)
            for i=1,3 do
                var.xmPanel:getWidgetByName("label_xm_done_num_"..i):setString(var.panel_data.need_tab[i].."个")
                var.xmPanel:getWidgetByName("label_xm_done_last_"..i):setPositionX(var.xmPanel:getWidgetByName("label_xm_done_num_"..i):getPositionX()+var.xmPanel:getWidgetByName("label_xm_done_num_"..i):getContentSize().width)
                --var.xmPanel:getWidgetByName("label_need_xmf_"..i):setString("上交"..var.panel_data.need_tab[i].."个降魔符")
            end
        end
    elseif event.type == "mycc" or event.type == "superbox" or event.type == "mmss" or event.type == "smzc" or event.type == "guildtotem" or event.type == "swmy" or event.type == "guildcopy" then
        UILeftCenter.handleActPanelData(event)
    end
end

function UILeftCenter.checkIsMyTotem(monsterid)
    if not var.totemMonsterInfo then return false end
    if not game.haveGuild() then return false end
    for k, v in ipairs(var.totemMonsterInfo) do
        if v.id and v.id == monsterid then
            if v.guild then
                return v.guild == NetCC:getMainGhost():NetAttr(Const.net_guild_name)
            end
            return false
        end
    end
    return false
end

function UILeftCenter.checkIsKilledTutom(monsterid)
    if not var.totemMonsterInfo then return end
    for k, v in ipairs(var.totemMonsterInfo) do
        if v.id and v.id == monsterid then
            local PixesGhost = require("app.PixesGhost")
            PixesGhost.updateTutomName(v.id,v.guild)
        end
    end
end

function UILeftCenter.handleActPanelData(event)
    local d = util.decode(event.data)
    if not d then return end
--    print(d.actionid,d.param)
    if not d.actionid or not  d.param then return end

    if event.type == "mycc" then
        local luatype = "mycc"
        if d.actionid == "jifen" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
            end
            var.mCurActShowPage =  SUB_PAGE_ACT.MYCC
            --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】魔影重重")
            var.actPanel:getWidgetByName("Text_hide"):setString("[活动]魔影重重")
            local curpanel = var.actPanel:getWidgetByName("Panel_mycc"):show()
            curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable(luatype,util.encode({actionid = "leave"}))
            end)
            curpanel:getWidgetByName("Text_myjf_value"):setString(d.param.jf)
            curpanel:getWidgetByName("Text_ljjy_value"):setString(d.param.exp)
            curpanel:getWidgetByName("Text_limit_value"):setString(d.param.limit)
            UILeftCenter.startCountDown(d.param.lefttime, var.actPanel:getWidgetByName("AtlasLabel_time"))
            if not var.actAward[SUB_PAGE_ACT.MYCC] then
                NetClient:PushLuaTable(luatype,util.encode({actionid = "query"}))
            else
                UILeftCenter.updateActAward(SUB_PAGE_ACT.MYCC)
                --var.actPanel:getWidgetByName("Text_tips"):setString(var.actAward[SUB_PAGE_ACT.MYCC][1].desp):show()
            end
        elseif d.actionid == "drawgift" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.MYCC then return end
            local curpanel = var.actPanel:getWidgetByName("Panel_mycc")
            curpanel:getWidgetByName("Button_done"):addClickEventListener(function (pSender)
                if checkint(curpanel:getWidgetByName("Text_myjf_value")) >= checkint(curpanel:getWidgetByName("Text_limit_value")) then
                    NetClient:PushLuaTable(luatype,util.encode({actionid = "drawgift"}))
                else
                    NetClient:alertLocalMsg("积分不足","alert")
                end
            end)
            curpanel:getWidgetByName("Button_done"):setTouchEnabled(d.param.drawok~=1)
            curpanel:getWidgetByName("Button_done"):setBright(d.param.drawok~=1)

        elseif d.actionid == "query" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.MYCC then return end
            local curpanel = var.actPanel:getWidgetByName("Panel_mycc")
            var.actAward[SUB_PAGE_ACT.MYCC] = d.param
            UILeftCenter.updateActAward(SUB_PAGE_ACT.MYCC)
            --var.actPanel:getWidgetByName("Text_tips"):setString(var.actAward[SUB_PAGE_ACT.MYCC][1].desp):show()
        end
    elseif event.type == "superbox" then
        local luatype = "superbox"
        if d.actionid == "baseinfo" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
            end
            var.mCurActShowPage =  SUB_PAGE_ACT.LCBZ
            --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】龙城宝藏")
            var.actPanel:getWidgetByName("Text_hide"):setString("[活动]龙城宝藏")
            local curpanel = var.actPanel:getWidgetByName("Panel_lcbz"):show()
            curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable(luatype,util.encode({actionid = "superbox_leave"}))
            end)
            --var.actPanel:getWidgetByName("Text_tips"):hide()
            var.actAward[SUB_PAGE_ACT.LCBZ] = d.param.showaward
            UILeftCenter.updateActAward(SUB_PAGE_ACT.LCBZ)
            var.maxmonlist = d.param.maxmonlist
            curpanel:getWidgetByName("Text_monster_value"):setString(var.maxmonlist.."/"..var.maxmonlist.."波")
            UILeftCenter.startCountDown(d.param.lefttime, var.actPanel:getWidgetByName("AtlasLabel_time"))
        elseif d.actionid == "updateinfo" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.LCBZ then return end
            local curpanel = var.actPanel:getWidgetByName("Panel_lcbz")
            curpanel:getWidgetByName("Text_monster_value"):setString(d.param.basedata.mongened.."/"..var.maxmonlist.."波")
            curpanel:getWidgetByName("Text_fresh_value"):setString(d.param.next_mongen_time.."秒")
            curpanel:getWidgetByName("Text_left_value"):setString(d.param.nummon)
            local owners="无"
            if #d.param.basedata.boxholder > 0 then
                owners = d.param.basedata.boxholder[1].name
            end
            curpanel:getWidgetByName("Text_owner_value"):setString(owners)
        elseif d.actionid == "endinfo" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.LCBZ then return end
            local curpanel = var.actPanel:getWidgetByName("Panel_lcbz")
            curpanel:getWidgetByName("Text_monster_value"):setString(d.param.basedata.mongened.."/"..var.maxmonlist.."波")
            curpanel:getWidgetByName("Text_fresh_value"):setString(d.param.next_mongen_time.."秒")
            curpanel:getWidgetByName("Text_left_value"):setString(d.param.nummon)
            local owners="无"
            if #d.param.basedata.boxholder > 0 then
                owners = d.param.basedata.boxholder[1].name
            end
            curpanel:getWidgetByName("Text_owner_value"):setString(owners)
            var.actAward[SUB_PAGE_ACT.LCBZ] = d.param.endaward
            UILeftCenter.updateActAward(SUB_PAGE_ACT.LCBZ)
            var.actPanel:getWidgetByName("AtlasLabel_time"):stopAllActions()
            NetClient:dispatchEvent({name=Notify.EVENT_SUPERBOX_RANK,list=d.param.basedata.bxmap,award=d.param.endaward})
        end
    elseif event.type == "mmss" then
        local luatype = "mmss"
        if d.actionid == "mmss_info" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
            end
            var.mCurActShowPage =  SUB_PAGE_ACT.MMSS
            --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】蒙面杀手")
            var.actPanel:getWidgetByName("Text_hide"):setString("[活动]蒙面杀手")
            local curpanel = var.actPanel:getWidgetByName("Panel_mmss"):show()
            local contentSize = curpanel:getWidgetByName("Text_intro"):getContentSize()
            local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
            util.setRichLabel(richLabel,d.param.str,"",24,Const.COLOR_YELLOW_1_OX)
            richLabel:setVisible(true)
            richWidget:setContentSize(cc.p(contentSize.width,richLabel:getRealHeight()))
            richWidget:addTo(curpanel:getWidgetByName("Text_intro"))
            richWidget:setPositionY(curpanel:getWidgetByName("Text_intro"):getContentSize().height-richLabel:getRealHeight())
            var.actAward[SUB_PAGE_ACT.MMSS] = d.param.award
            UILeftCenter.updateActAward(SUB_PAGE_ACT.MMSS)
            UILeftCenter.startCountDown(d.param.lefttime, var.actPanel:getWidgetByName("AtlasLabel_time"))
            curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable(luatype,util.encode({actionid = "leave_map"}))
            end)
        end
    elseif event.type == "smzc" then
        local luatype = "smzc"
        if d.actionid == "querybaseinfo" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
            end
            local curpanel = var.actPanel:getWidgetByName("Panel_smzc")
            var.mCurActShowPage =  SUB_PAGE_ACT.SMZC
            --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】神魔战场")
            var.actPanel:getWidgetByName("Text_hide"):setString("[活动]神魔战场")
            curpanel:show()
            curpanel:getWidgetByName("Text_szjf_value"):setString(d.param.shenzu_jifen)
            curpanel:getWidgetByName("Text_mzjf_value"):setString(d.param.mozu_jifen)
            curpanel:getWidgetByName("Text_myjf_value"):setString(d.param.jifen)
            curpanel:getWidgetByName("Text_limit_value"):setString(d.param.jifen_item_limit)
            if d.param.zhenying then
            end
            curpanel:getWidgetByName("Text_szjf"):setTextColor(d.param.zhenying==1 and Const.COLOR_GREEN_1_C3B or Const.COLOR_YELLOW_1_C3B)
            curpanel:getWidgetByName("Text_mzjf"):setTextColor(d.param.zhenying==2 and Const.COLOR_GREEN_1_C3B or Const.COLOR_YELLOW_1_C3B)

            --var.actPanel:getWidgetByName("Text_tips"):setString(d.param.desc2):show()
            var.actAward[SUB_PAGE_ACT.SMZC] = d.param.jifen_item
            UILeftCenter.updateActAward(SUB_PAGE_ACT.SMZC)
            UILeftCenter.startCountDown(d.param.time, var.actPanel:getWidgetByName("AtlasLabel_time"))
            curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable(luatype,util.encode({actionid = "smzc_leave"}))
            end)
            curpanel:getWidgetByName("Button_done"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable(luatype,util.encode({actionid = "smzc_drawgift_jifen"}))
            end)
            local sjifen = tonumber(d.param.jifen) or 0
            curpanel:getWidgetByName("Button_done"):setBright(sjifen>=500)
            curpanel:getWidgetByName("Button_done"):setTouchEnabled(sjifen>=500)
            curpanel:getWidgetByName("Button_done"):setVisible(d.param.jifen_item_flag<=0)
            if d.param.jifen_item_flag <= 0 then
                curpanel:getWidgetByName("Button_leave"):setPositionX(255)
            else
                curpanel:getWidgetByName("Button_leave"):setPositionX(169)
            end
        elseif d.actionid == "changeinfo" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.SMZC then return end
            local curpanel = var.actPanel:getWidgetByName("Panel_smzc")
            curpanel:getWidgetByName("Text_szjf_value"):setString(d.param.shenzu_jifen)
            curpanel:getWidgetByName("Text_mzjf_value"):setString(d.param.mozu_jifen)
            curpanel:getWidgetByName("Text_myjf_value"):setString(d.param.jifen)
            curpanel:getWidgetByName("Button_done"):setVisible(d.param.jifen_item_flag<=0)
            if d.param.jifen_item_flag <= 0 then
                curpanel:getWidgetByName("Button_leave"):setPositionX(255)
            else
                curpanel:getWidgetByName("Button_leave"):setPositionX(169)
            end
        end
    elseif event.type == "guildtotem" then
        local luatype = "guildtotem"
        if d.actionid == "totem_info" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
                --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】图腾战场")
                var.actPanel:getWidgetByName("Text_hide"):setString("[活动]图腾战场")
            end
            local curpanel = var.actPanel:getWidgetByName("Panel_tuteng")
            var.mCurActShowPage =  SUB_PAGE_ACT.TTZC
            var.actAward[SUB_PAGE_ACT.TTZC] = {}
            UILeftCenter.updateActAward(SUB_PAGE_ACT.TTZC)
            curpanel:show()
            UILeftCenter.startCountDown(d.param.lefttime, var.actPanel:getWidgetByName("AtlasLabel_time"))
            -- 说明
            curpanel:getWidgetByName("Text_info_left"):removeAllChildren()
            local infostr = ""
            for k, v in ipairs(d.param.info) do
                if k == 1 or k == 2 or k == 4 then
                    local guild = v.guild
                    if not guild or guild == "" then
                        guild = "无行会占有"
                    end
                    infostr=infostr..game.clearNumStr(v.name)..":".."("..guild..")".."<br>".." ".."<br>"
                end
            end
            local contentSize = curpanel:getWidgetByName("Text_info_left"):getContentSize()
            local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
            util.setRichLabel(richLabel,infostr,"",20,Const.COLOR_YELLOW_1_OX)
            richLabel:setVisible(true)
            richWidget:setContentSize(cc.size(contentSize.width,richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(0,contentSize.height-richLabel:getRealHeight()-10))
            richWidget:addTo(curpanel:getWidgetByName("Text_info_left"))
            -- 收益
            curpanel:getWidgetByName("Text_info_right"):removeAllChildren()
            local perstr = ""
            for k, v in ipairs(d.param.info) do
                if k == 1 or k == 2 or k == 4 then
                    perstr=perstr.."收益+"..v.per.."<br>".." ".."<br>"
                end  
            end
            local contentSize = curpanel:getWidgetByName("Text_info_right"):getContentSize()
            local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
            util.setRichLabel(richLabel,perstr,"",20,Const.COLOR_GREEN_1_OX)
            richLabel:setVisible(true)
            richWidget:setContentSize(cc.size(contentSize.width,richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(0,contentSize.height-richLabel:getRealHeight()-33))
            richWidget:addTo(curpanel:getWidgetByName("Text_info_right"))

            -- 奖励
            curpanel:getWidgetByName("Text_exp_value"):setString(d.param.award.exp.."/5秒")
            curpanel:getWidgetByName("Text_ngexp_value"):setString(d.param.award.ngexp.."/5秒")

            curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable(luatype,util.encode({actionid = "leave_map"}))
            end)
        elseif d.actionid == "show_info" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.TTZC then return end
            var.totemMonsterInfo = d.param or {}
            for k, v in ipairs(var.totemMonsterInfo) do
                if v.id then
                    local PixesGhost = require("app.PixesGhost")
                    PixesGhost.updateTutomName(v.id,v.guild)
                end
            end
        end
    elseif event.type == "swmy" then
        local luatype = "swmy"
        if d.actionid == "shenwei_info" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
                --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】神威魔域")
                var.actPanel:getWidgetByName("Text_hide"):setString("[活动]神威魔域")
            end
            local curpanel = var.actPanel:getWidgetByName("Panel_swmy")
            curpanel:show()
            var.mCurActShowPage =  SUB_PAGE_ACT.SWMY
            curpanel:getWidgetByName("Text_mapname"):setString(d.param.map_name)
            var.actAward[SUB_PAGE_ACT.SWMY] = d.param.award
            UILeftCenter.updateActAward(SUB_PAGE_ACT.SWMY)
            --介绍
            curpanel:getWidgetByName("Text_str"):removeAllChildren()
            local contentSize = curpanel:getWidgetByName("Text_str"):getContentSize()
            local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
            util.setRichLabel(richLabel,d.param.str,"",22,Const.COLOR_YELLOW_1_OX)
            richLabel:setVisible(true)
            richWidget:setContentSize(cc.size(contentSize.width,richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(0,contentSize.height-richLabel:getRealHeight()))
            richWidget:addTo(curpanel:getWidgetByName("Text_str"))

            if d.param.npc and d.param.npc ~= "" then
                curpanel:getWidgetByName("Button_leave"):hide()
                curpanel:getWidgetByName("Button_npc"):show()
                curpanel:getWidgetByName("Button_npc").user_data="event:"..d.param.npc
                curpanel:getWidgetByName("Button_npc"):addClickEventListener(function (pSender)
                    util.touchlink(pSender,ccui.TouchEventType.ended,"")
                end)
            else
                curpanel:getWidgetByName("Button_leave"):show()
                curpanel:getWidgetByName("Button_npc"):hide()
                curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                    NetClient:PushLuaTable(luatype,util.encode({actionid = "shenwei_exit"}))
                end)
            end
            --var.actPanel:getWidgetByName("Text_tips"):setString("激情PK,死亡不掉落装备"):hide()
        elseif d.actionid == "shenwei_cd" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.SWMY then return end
            UILeftCenter.startCountDown(d.param, var.actPanel:getWidgetByName("AtlasLabel_time"))
        end
    elseif event.type == "guildcopy" then
        local luatype = "newgui.guildcopy.onGetJsonData"
        if d.actionid == "copy_info" then
            if var.mCurShowPage ~= PAGE_ACT then
                var.mCurShowPage = PAGE_ACT
                UILeftCenter.showPage(PAGE_ACT)
            end
            var.mCurActShowPage =  SUB_PAGE_ACT.HHMJ
            --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【副本】行会秘境")
            var.actPanel:getWidgetByName("Text_hide"):setString("[副本]行会秘境")
            local curpanel = var.actPanel:getWidgetByName("Panel_guildcopy"):show()
            curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm ="是否立即退出当前副本？",
                    confirmTitle = "确定", cancelTitle = "取消",countTime = d.param.lefttimes,
                    confirmCallBack = function ()
                        NetClient:PushLuaTable(luatype,util.encode({actionid = "leave_copy"}))
                    end
                }
                EventDispatcher:dispatchEvent(param) 
            end)
            --var.actPanel:getWidgetByName("Text_tips"):hide()
            var.actAward[SUB_PAGE_ACT.HHMJ] = d.param.award
            UILeftCenter.updateActAward(SUB_PAGE_ACT.HHMJ)
            -- var.maxmonlist = d.param.mon_num
            curpanel:getWidgetByName("Text_count_value"):setString(d.param.bosscount)
            curpanel:getWidgetByName("Text_left_value"):setString(d.param.mon_num)
            curpanel:getWidgetByName("Text_fresh_value"):setString("行会"..d.param.next_level.."级")
            UILeftCenter.startCountDown(d.param.lefttimes, var.actPanel:getWidgetByName("AtlasLabel_time"))
        elseif d.actionid == "update_info" then
            if var.mCurShowPage ~= PAGE_ACT or var.mCurActShowPage ~= SUB_PAGE_ACT.HHMJ then return end
            local curpanel = var.actPanel:getWidgetByName("Panel_guildcopy"):show()
            local cur_count = tonumber(curpanel:getWidgetByName("Text_count_value"):getString()) or 0
            if d.param.bosscount > cur_count then
                UILeftCenter.startCountDown(d.param.lefttimes, var.actPanel:getWidgetByName("AtlasLabel_time"))
            end
            curpanel:getWidgetByName("Text_count_value"):setString(d.param.bosscount)
            curpanel:getWidgetByName("Text_left_value"):setString(d.param.mon_num)
            curpanel:getWidgetByName("Text_fresh_value"):setString("行会"..d.param.next_level.."级")
            var.actAward[SUB_PAGE_ACT.HHMJ] = d.param.award
            UILeftCenter.updateActAward(SUB_PAGE_ACT.HHMJ)
        elseif d.actionid == "guildcount" then
            UILeftCenter.startCountDown(d.param, var.actPanel:getWidgetByName("AtlasLabel_time"))
        elseif d.actionid == "guildend" then
            UILeftCenter.startCountDown(d.param.lefttime, var.actPanel:getWidgetByName("AtlasLabel_time"))
            if d.param.flag == 0 then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "fubenfailed", visible = true,
                    confirmCallBack = function (num)
                        NetClient:PushLuaTable(luatype,util.encode({actionid = "leave_copy"}))
                    end
                }
                NetClient:dispatchEvent(param)
            elseif d.param.flag == 1 then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "fubendone", visible = true,
                    notaward = true,
                    tips = "提升行会等级，开放更多关卡",
                    confirmCallBack = function (num)
                        NetClient:PushLuaTable(luatype,util.encode({actionid = "leave_copy"}))
                    end
                }
                NetClient:dispatchEvent(param)
            elseif d.param.flag == 2 then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "fubendone", visible = true,
                    notaward = true,
                    tips = "行会已经通过所有关卡",
                    confirmCallBack = function (num)
                        NetClient:PushLuaTable(luatype,util.encode({actionid = "leave_copy"}))
                    end
                }
                NetClient:dispatchEvent(param)
            end
        end
    end
end

function UILeftCenter.handleKingMapList()
    if NetClient.mKingMapInfo == nil then return end
    local luatype = "kingdom"
    if var.mCurShowPage ~= PAGE_ACT then
        var.mCurShowPage = PAGE_ACT
        UILeftCenter.showPage(PAGE_ACT)
        --var.actPanel:getWidgetByName("Button_hide"):setTitleText("【活动】皇城争霸")
        var.actPanel:getWidgetByName("Text_hide"):setString("[活动]皇城争霸")
    end
    local curpanel = var.actPanel:getWidgetByName("Panel_zhengba")
    curpanel:show()
    var.mCurActShowPage =  SUB_PAGE_ACT.HCZB
    var.actAward[SUB_PAGE_ACT.HCZB] = {}
    UILeftCenter.updateActAward(SUB_PAGE_ACT.HCZB)
    UILeftCenter.startCountDown(NetClient.mKingMapInfo.lefttime, var.actPanel:getWidgetByName("AtlasLabel_time"))
    curpanel:getWidgetByName("Button_done"):addClickEventListener(function (pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_king_jf"})
    end)
    curpanel:getWidgetByName("Button_leave"):addClickEventListener(function (pSender)
        NetClient:PushLuaTable(luatype,util.encode({actionid = "leave",panelid = "kingdomInfo"}))
    end)
    -- 积分更新
    UILeftCenter.handleUpdateKingJFPoint()
    -- 排名更新
    for i = 1,3 do
        local rankpanel = curpanel:getWidgetByName("Panel_rank"..i)
        if NetClient.mKingMapInfo.list[i] then
            rankpanel:show()
            rankpanel:getWidgetByName("Text_pname"):setString(NetClient.mKingMapInfo.list[i].name)
            rankpanel:getWidgetByName("Text_pname_point"):setString(NetClient.mKingMapInfo.list[i].jf)
        else
            rankpanel:hide()
        end
    end
end

function UILeftCenter.handleUpdateKingJFPoint()
    if var.mCurShowPage == PAGE_ACT and var.mCurActShowPage ==  SUB_PAGE_ACT.HCZB and var.actPanel then
        var.actPanel:getWidgetByName("Panel_zhengba"):getWidgetByName("Text_szjf_value"):setString(NetClient.mKingJFPoint)
    end
end

function UILeftCenter.handleUpdateKingAwardFlag()
    if var.mCurShowPage == PAGE_ACT and var.mCurActShowPage ==  SUB_PAGE_ACT.HCZB and var.actPanel then
        local can_get = NetClient:getKingJfAwardFlag()
        local awardbtn = var.actPanel:getWidgetByName("Panel_zhengba"):getWidgetByName("Button_done")
        if can_get then
            if not awardbtn:getChildByName("awardeffect") then
                local effecSprite = gameEffect.getBtnSelectEffect()
                effecSprite:setPosition(cc.p(awardbtn:getContentSize().width/2,awardbtn:getContentSize().height/2))
                effecSprite:setName("awardeffect")
                effecSprite:addTo(awardbtn)
            end
        else
            if awardbtn:getChildByName("awardeffect") then
                awardbtn:removeChildByName("awardeffect")
            end
        end
    end
end

function UILeftCenter.updateActAward(subtype)
    local aNUM = 0
    for i=1,4 do
        if var.actAward[subtype][i] then
            var.actPanel:getWidgetByName("award_"..i):show()
            UIItem.getSimpleItem({
                parent = var.actPanel:getWidgetByName("award_"..i),
--                num = var.actAward[subtype][i].num,
                typeId = var.actAward[subtype][i].typeid,
                name = var.actAward[subtype][i].name,
                bind = var.actAward[subtype][i].bindflag
            })
            aNUM = aNUM+1
        else
            var.actPanel:getWidgetByName("award_"..i):hide()
        end
    end
    if aNUM == 1 then
       var.actPanel:getWidgetByName("award_1"):setPositionX(180) 
    end
end

function UILeftCenter.freshXMF(event)
    if var.mCurShowPage == PAGE_XM then
        if event and event.pos then
            local tempItem = NetClient:getNetItem(event.pos)
            if tempItem then
                if tempItem.mTypeID == 15500 then
                    var.xmPanel:getWidgetByName("label_left_xmf"):setString(NetClient:getNetItemNumberById(tempItem.mTypeID))
                end
            end
        end
    end
end

function UILeftCenter.removeActPanel()
    if var.actPanel then var.actPanel:removeFromParent() var.actPanel = nil end
end

function UILeftCenter.removeFubenPanel()
    if var.fubenPanel then var.fubenPanel:removeFromParent() var.fubenPanel = nil var.panel_data = nil end
end

function UILeftCenter.showMainlineTip()
    if game.getRoleLevel() < 30 and not var.hideTaskType and not var.showrunType then
        var.showAutoGuide = true 
        if var.mCurShowPage == PAGE_TEAM then
            var.curGuide = var.guideMainTask
            var.curGuide:setPosition(cc.p(var.gMainTaskPosX,var.gMainTaskPosY))
            if not var.moveBy then
                var.moveBy = cc.MoveBy:create(1,cc.p(0, 10))
            end
        else
            var.curGuide = var.guideGetTask
            var.curGuide:setPosition(cc.p(var.gGetTaskPosX,var.gGetTaskPosY))
            if not var.moveBy then
                var.moveBy = cc.MoveBy:create(1,cc.p(-10, 0))
            end
        end
        var.curGuide:show()
        if var.curGuide  then
            var.showrunType = true
            var.curGuide:runAction(cc.Repeat:create(cc.Sequence:create(var.moveBy,cc.DelayTime:create(0.5),var.moveBy:reverse()),10))
            var.curGuide:runAction(cc.Sequence:create(
                cc.DelayTime:create(5),
                cc.CallFunc:create(UILeftCenter.dealMainlineTip)
            ))
        end
        
    end
    
end

function UILeftCenter.dealMainlineTip()
    if not var.sortlist then return end

    var.talkmsg = util.decode(NetClient.m_strNpcTalkMsg)
    if var.curGuide then
        var.curGuide:hide()
        var.curGuide:stopAllActions()
        var.moveBy = nil
        var.showAutoGuide = false
        var.showrunType = false
    end
    local tid = var.sortlist[1]
    local taskinfo = TaskData.list[tid]
    local state = math.fmod(taskinfo.mState,10)
    local linkstr = taskinfo.mInfo.task_target 

    if tid == Const.TASK_MAIN_ID and state == 3 and taskinfo.mInfo.target_type == "equip" then
            linkstr = "open_panel_smelter" 
    elseif state == 1 and taskinfo.mInfo.need_level then
            linkstr = "open_panel_dailyactivity"  
    end
    util.litenerTaskLink(linkstr,taskinfo.mInfo.target_fly)
end


function UILeftCenter.showPage(page)
    if not var.widget then return end
    var.totemMonsterInfo = {}
    if page == PAGE_TASK then
        UILeftCenter.removeActPanel()
        UILeftCenter.removeFubenPanel()
        var.showPanel:show()
        var.taskPanel:show()
        var.teamPanel:hide()
        var.xmPanel:hide()
        var.xmPanelHide:hide()
        if var.showAutoGuide then
            var.guideMainTask:hide()
            var.moveBy = nil
            UILeftCenter.showMainlineTip()
        end
    elseif page == PAGE_FUBEN then
        UILeftCenter.removeActPanel()
        var.showPanel:hide()
        var.taskPanel:hide()
        var.teamPanel:hide()
        var.xmPanel:hide()
        var.xmPanelHide:hide()
        if not var.fubenPanel then
            local widget = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_LeftCenter_Fuben.csb")
            var.fubenPanel = widget:getChildByName("Panel_leftact")
            UILeftCenter.hideAllActPanel(var.fubenPanel)
            widget:align(display.LEFT_CENTER, 0, var.widget:getContentSize().height/2+40)
            widget:addTo(var.widget)
        else
            var.fubenPanel:hide()
        end
    elseif page == PAGE_XM then
        UILeftCenter.removeActPanel()
        UILeftCenter.removeFubenPanel()
        var.taskPanel:hide()
        var.teamPanel:hide()
        var.showPanel:hide()
        var.xmPanel:show()
        var.xmPanelHide:hide()
        if var.hideXMDType then
            UILeftCenter.showXMDBoard()
        end
    elseif page == PAGE_TEAM then
        UILeftCenter.removeActPanel()
        UILeftCenter.removeFubenPanel()
        var.showPanel:show()
        var.taskPanel:hide()
        var.teamPanel:show()
        var.xmPanel:hide()
        var.xmPanelHide:hide()

        
        UILeftCenter.refreashMyGroupList()
        ----[[
        --]]
    elseif page == PAGE_ACT then
        UILeftCenter.removeFubenPanel()
        var.taskPanel:hide()
        var.teamPanel:hide()
        var.showPanel:hide()
        var.xmPanel:hide()
        var.xmPanelHide:hide()
        if not var.actPanel then
            local widget = WidgetHelper:getWidgetByCsb("uilayout/MainUI/UI_LeftCenter_Act.csb")
            var.actPanel = widget:getChildByName("Panel_leftact")
            UILeftCenter.hideAllActPanel(var.actPanel)
            widget:align(display.LEFT_CENTER, 0, var.widget:getContentSize().height/2+40)
            widget:addTo(var.widget)
        else
            var.actPanel:hide()
        end
    end
end

function UILeftCenter.refreashMyGroupList()
    var.mGroupNum = #NetClient.mGroupMembers or 0
    if var.mGroupNum > 0 then
        var.teamPanel:getWidgetByName("Button_searchteam"):hide():setTouchEnabled(false)
        var.teamPanel:getWidgetByName("Button_createteam"):hide():setTouchEnabled(false)
        var.teamPanel:getWidgetByName("ListView_team"):show():setTouchEnabled(true)   
    else
        var.teamPanel:getWidgetByName("ListView_team"):hide():setTouchEnabled(false)
        var.teamPanel:getWidgetByName("Button_searchteam"):show():setTouchEnabled(true)
        var.teamPanel:getWidgetByName("Button_createteam"):show():setTouchEnabled(true)
        var.frilabel:setString("寻找队伍")
        var.selabel:setString("创建队伍")
    end
    var.teamlistView:removeAllItems() 
    local infodata = UILeftCenter.updateMygroupInfo()
    
    if (not infodata) then
        return
    else
        for j=1,#infodata do
            if (not infodata[j].job) or (not infodata[j].level) then
                return
            end
        end 
    end
    local groupLeader = NetClient.mCharacter.mGroupLeader
    local myname = game.GetMainRole():NetAttr(Const.net_name)
    local function itemClicked(pSender)
        local idx = pSender.idx
        if idx == 1 then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group", pdata = {tag = 1}})
        elseif idx > #infodata then
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group", pdata = {tag = 2}})
        else
            --if NetClient.OPviewType then return end
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_group_op", pdata={uname = infodata[idx].name,tag = 1}})
            --require("app.views.group.MyGroupOpView").initView({ parent = var.widget, uname = infodata[idx].name,tag = 1})
        end
    end

    for i=1, #infodata +1 do
        local listItem = var.teamListItem:clone():show()
        if i > #infodata then
            for i=1,4 do
                if i == 4 then
                    listItem:getWidgetByName("Image_hteam"..i):show()
                else
                    listItem:getWidgetByName("Image_hteam"..i):hide()
                end 
            end
            listItem:getWidgetByName("Label_friteam"):setString("添加队员")
            listItem:getWidgetByName("ImageView_captain"):hide()
        else
            local groupdata = infodata[i]
            if groupdata then
                for i=1,4 do
                if i ==  ((groupdata.job or 0) -99) then
                    listItem:getWidgetByName("Image_hteam"..i):show()
                else
                    listItem:getWidgetByName("Image_hteam"..i):hide()
                end 
            end
            if groupdata.job  == 0 then
                listItem:getWidgetByName("Label_friteam"):setString(groupdata.name.."(离线)")
            else
                listItem:getWidgetByName("Label_friteam"):setString(groupdata.name)
            end
            
            if groupLeader == groupdata.name then
                listItem:getWidgetByName("ImageView_captain"):show()
            else
                listItem:getWidgetByName("ImageView_captain"):hide()
            end
            end
            
        end
        listItem:setTouchEnabled(true):addClickEventListener(itemClicked)
        listItem.idx = i
        var.teamlistView:pushBackCustomItem(listItem)
    end
end

function UILeftCenter.updateMygroupInfo()
    local listData = clone(NetClient.mGroupMembers)
    local grouplistData = {}
    local groupLeader = NetClient.mCharacter.mGroupLeader
    local myname = game.GetMainRole():NetAttr(Const.net_name)
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
    table.sort(listData, sortF)
    grouplistData = listData
    return grouplistData
end

function UILeftCenter.hideAllActPanel(widget)
    widget:getWidgetByName("Panel_show"):show()
    widget:getWidgetByName("Button_show"):hide()
    widget:getWidgetByName("Button_show"):addClickEventListener(function ( pSender )
        UILeftCenter.showActBoard(widget)
    end)
    widget:getWidgetByName("Button_hide"):addClickEventListener(function ( pSender )
        UILeftCenter.hideActBoard(widget)
    end)

    local allpanels = {"Panel_mycc", "Panel_lcbz", "Panel_smzc", "Panel_mmss", "Panel_tuteng", "Panel_swmy", "AtlasLabel_time", "Panel_zhengba","Panel_guildcopy"}
    for k, v in ipairs(allpanels) do
        if widget:getWidgetByName(v) then
            widget:getWidgetByName(v):hide()
        end
    end
end

function UILeftCenter.createTaskItem(index, tid)
    local taskBtnItem = var.taskListView:getItem(index-1)
    if not taskBtnItem then
        taskBtnItem = var.taskItemNode:clone()
        var.taskListView:insertCustomItem(taskBtnItem, index-1)
    end
    local taskinfo = TaskData.list[tid]
    if not taskinfo then return end
    local taskType = taskBtnItem:getChildByName("Label_type")
    local taskTitle	= taskBtnItem:getChildByName("Label_task")
    local taskmsg	= taskBtnItem:getChildByName("Text_desc")
    taskTitle:setString(taskinfo.mName)

    local state = math.fmod(taskinfo.mState,10)
    if state == 4 then --完成
        taskBtnItem:getChildByName("Text_status"):show():setPositionX(43+taskTitle:getContentSize().width)
        taskmsg:setColor(Const.COLOR_GREEN_1_C3B)
    else
        taskBtnItem:getChildByName("Text_status"):hide()
        taskmsg:setColor(Const.COLOR_WHITE_1_C3B)
    end

    if tid == Const.TASK_MAIN_ID then
        if taskinfo.mInfo.target_type == "mon" then
            MainRole.mTaskTarget = taskinfo.mInfo.target_name
        else
            MainRole.mTaskTarget = ""
        end
        taskType:setString("[主]")
    else
        taskType:setString("[支]")
        if tid == 7000 then
            if state == 4 then
                var.btn_chuansong:show()
                var.btn_husong:show()
            else
                var.btn_chuansong:hide()
                var.btn_husong:hide()
            end
        end
    end

    local descstr = ""
    if taskinfo.mInfo.target_num and tonumber(taskinfo.mInfo.target_num) > tonumber(taskinfo.mParam_1) then
        if taskinfo.mInfo.target_name then
            descstr = taskinfo.mInfo.target_name.."("..taskinfo.mParam_1.."/"..taskinfo.mInfo.target_num..")"
        else
            descstr = taskinfo.mInfo.task_name.."("..taskinfo.mParam_1.."/"..taskinfo.mInfo.target_num..")"
        end

    else
        if state ~= 1 then
            descstr = "回复： "
        end
        descstr = descstr..taskinfo.mInfo.task_name
    end
    taskmsg:setString(descstr)

    taskBtnItem:addClickEventListener(function (pSender)
        UILeftCenter.removeEquipTaskGuild()
        if taskinfo.mInfo.target_type == "mon" then
            MainRole.mTaskTarget = taskinfo.mInfo.target_name
        end
        if tid == Const.TASK_MAIN_ID and state == 3 and taskinfo.mInfo.target_type == "equip" then
            UILeftCenter.addEquipTaskGuild(taskinfo.mInfo.equip_info)-- 穿装备的任务
        else
            local linkstr = taskinfo.mInfo.task_target
            if state == 1 and taskinfo.mInfo.need_level then
                linkstr = "open_panel_dailyactivity" -- 等级不足
            end
            util.litenerTaskLink(linkstr,taskinfo.mInfo.target_fly)
        end
    end)

    taskBtnItem:show():setTouchEnabled(true)
end

function UILeftCenter.removeEquipTaskGuild()
    if var.taskPanel:getChildByName("equipGuide") then
        var.taskPanel:removeChildByName("equipGuide")
    end
end

function UILeftCenter.addEquipTaskGuild(equip_info)
    local bgW = 202
    local widget = ccui.Layout:create()
    widget:setName("equipGuide")
    widget:setTouchEnabled(true)
    if equip_info.equipexp then
        local expText = ccui.Text:create()
        :align(display.CENTER, bgW/2, 30)
        :addTo(widget)
        expText:setFontSize(26)
        expText:setFontName(Const.DEFAULT_FONT_NAME)
        expText:setColor(Const.COLOR_GREEN_1_C3B)
        expText:setString(equip_info.equipexp)

        ccui.ImageView:create("img_line01.png",UI_TEX_TYPE_PLIST)
        :align(display.CENTER,bgW/2, 50)
        :setScale9Enabled(true)
        :setContentSize(cc.size(bgW-20, 2))
        :addTo(widget)
    end

    local positionY = 85
    if equip_info.getequip and #equip_info.getequip > 0 then
        for k, v in ipairs(equip_info.getequip) do
            local btnOp = ccui.Button:create()
            btnOp:loadTextures("red_btn.png","","",UI_TEX_TYPE_PLIST)
            btnOp:setTitleFontSize(24)
            btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
            btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
            btnOp:setTitleText(v.t)
            btnOp:align(display.CENTER,bgW/2, positionY)
            btnOp:setTouchEnabled(true)
            btnOp:addClickEventListener(function (pSender)
                util.litenerTaskLink(v.link)
                UILeftCenter.removeEquipTaskGuild()
            end)
            btnOp:addTo(widget)
            if k < #equip_info.getequip then
                positionY = positionY + 70
            else
                positionY = positionY + 50
            end
        end
    end
    widget:setBackGroundImageScale9Enabled(true)
    widget:setBackGroundImage("backgroup_9.png",UI_TEX_TYPE_PLIST)
    widget:setContentSize(cc.size(bgW, positionY))
    widget:addTo(var.taskPanel)
    widget:align(display.LEFT_TOP, var.taskPanel:getContentSize().width+10, var.taskPanel:getContentSize().height+50)

    ccui.ImageView:create("renwuzhixiang_arrow.png",UI_TEX_TYPE_PLIST)
    :align(display.CENTER,0, positionY-80)
    :addTo(widget)
end

function UILeftCenter.initTaskList()
--    print("===========================UILeftCenter.initTaskList,新建listview")
    var.sortlist = {}
    for tid, taskinfo in pairs(TaskData.list) do
        if taskinfo.mInfo and tid ~= Const.TASK_ID_FUBEN_MAINTASK and tid ~= Const.TASK_ID_FUBEN_SEXP and taskinfo.mState > 0 and taskinfo.mFlags >= 0 then
            print("initTaskList=>>", tid,taskinfo.mState)
            if tid == Const.TASK_ID_YABIAO and math.fmod(taskinfo.mState,10) == 1 then

            else
                table.insert(var.sortlist, tid)
            end
        end
    end

    local sortF = function(fa, fb)
        local r
        if TaskData.list[fa].mTaskID == Const.TASK_MAIN_ID then
            return true
        elseif TaskData.list[fb].mTaskID == Const.TASK_MAIN_ID then
            return false
        end
        if math.fmod(TaskData.list[fa].mState,10) == math.fmod(TaskData.list[fb].mState,10) then
            r = TaskData.list[fa].mSort < TaskData.list[fb].mSort
        else
            r = math.fmod(TaskData.list[fa].mState,10) > math.fmod(TaskData.list[fb].mState,10)
        end
        return r
    end
    if #var.sortlist > 1 then
        table.sort( var.sortlist, sortF )
    end
    var.taskListView:removeAllItems():hide()
    for idx, tid in ipairs(var.sortlist) do
        UILeftCenter.createTaskItem(idx, tid)
    end
    var.taskListView:show()
end

function UILeftCenter.updateTaskList(changetid,statechange)
--    print("changetid==", changetid,statechange)
    if not changetid then return end

    local viewidx
    if changetid == Const.TASK_MAIN_ID then
        viewidx = 1
        if not TaskData.list[changetid].mInfo then
            if var.sortlist[viewidx] == Const.TASK_MAIN_ID then
                var.taskListView:removeItem(viewidx-1)
            end
            return
        else
            if var.sortlist[viewidx] ~= Const.TASK_MAIN_ID then
                table.insert(var.sortlist,viewidx,changetid)
            end
        end
    else
        if not TaskData.list[changetid].mInfo then
            -- 任务删除
            viewidx = nil
        else
            if not statechange and var.sortlist and #var.sortlist > 0 then
                for idx, tid in ipairs(var.sortlist) do
                    if tid == changetid then
                        viewidx = idx
    --                    print("找到了", viewidx)
                        break
                    end
                end
            end
        end
    end
--    print("viewidx==", viewidx)
    -- sort
    if not viewidx then
        UILeftCenter.initTaskList()
    else
        UILeftCenter.createTaskItem(viewidx, changetid)
    end
end

function UILeftCenter.onReload()
    var.mCurShowPage = PAGE_TASK
    UILeftCenter.showPage(PAGE_TASK)
end

function UILeftCenter.hideTaskBoard()
    var.hidePanel:show()
    var.showPanel:stopAllActions()
    var.hideTaskType = true
    var.showPanel:runAction(
        cc.Sequence:create(
            cc.EaseExponentialOut:create(cc.MoveBy:create(0.5,cc.p(-400, 0))),
            cc.CallFunc:create(
                function ()
                    var.showPanel:hide()
                end)
        )
    )
end

function UILeftCenter.hideActBoard(widget)
    if not widget then return end
    widget:getWidgetByName("Button_show"):stopAllActions()
    widget:getWidgetByName("Panel_show"):stopAllActions()
    widget:getWidgetByName("Panel_show"):runAction(
        cc.Sequence:create(
            cc.EaseExponentialOut:create(cc.MoveTo:create(0.5,cc.p(-360, 0))),
            cc.CallFunc:create(
                function ()
                    widget:getWidgetByName("Panel_show"):hide()
                    widget:getWidgetByName("Button_show"):show()
                end)
        )
    )
end

function UILeftCenter.showActBoard(widget)
    if not widget then return end
    widget:getWidgetByName("Button_show"):hide()
    widget:getWidgetByName("Button_show"):stopAllActions()
    widget:getWidgetByName("Panel_show"):stopAllActions()
    widget:getWidgetByName("Panel_show"):show()
    widget:getWidgetByName("Panel_show"):runAction(cc.EaseExponentialOut:create(cc.MoveTo:create(0.5,cc.p(0, 0))))
end

function UILeftCenter.handleGroupListChange()
--    UILeftCenter.showPage(var.mCurShowPage)
    if var.mCurShowPage == PAGE_TEAM then
        UILeftCenter.refreashMyGroupList()
    end
end

function UILeftCenter.showTaskBoard()
    var.showPanel:show()
    var.hidePanel:hide()
    var.hideTaskType = false
    var.showPanel:stopAllActions()
    var.showPanel:runAction(cc.EaseExponentialOut:create(cc.MoveBy:create(0.5,cc.p(400, 0))))
end

function UILeftCenter.showXMDBoard()
    var.xmPanel:show()
    var.xmPanelHide:hide()
    var.hideXMDType = false
    var.xmPanel:stopAllActions()
    var.xmPanel:runAction(cc.EaseExponentialOut:create(cc.MoveBy:create(0.5,cc.p(400, 0))))
end


function UILeftCenter.hideXMDBoard()
    var.xmPanelHide:show()
    var.xmPanel:stopAllActions()
    var.hideXMDType = true
    var.xmPanel:runAction(
        cc.Sequence:create(
            cc.EaseExponentialOut:create(cc.MoveBy:create(0.5,cc.p(-400, 0))),
            cc.CallFunc:create(
                function ()
                    var.xmPanel:hide()
                end)
        )
    )
end

return UILeftCenter