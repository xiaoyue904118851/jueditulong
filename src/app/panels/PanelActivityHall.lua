--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/01 12:53
-- To change this template use File | Settings | File Templates.
--PanelActivityHall
local ACTIONSET_NAME = "rhuodong"
local VITALITY_ACTIONSET_NAME = "vitality"
local PanelActivityHall = {}

local TAG_LIVENESS = 1
local TAG_DAILY = 2

local ACTIVITY_TYPE = {
    UNDO = 1,
    DOING = 2,
    PAST = 3,
}

local VITALITY_ICON = {
    ["1"] = "meiriqiandao.png", -- 每日任务
    ["2"] = "richangrenwu.png", -- 日常任务
    ["3"] = "ziyuanfuben.png", -- 资源副本
    ["4"] = "yabiao.png", -- 押镖
    ["5"] = "zhuangbeihuishou.png", -- 装备回收
    ["6"] = "caijikuangshi.png", -- 采集矿石
    ["7"] = "gerenboss.png", -- 个人boss
    ["8"] = "xunbao.png", -- 寻宝
    ["9"] = "jisha3kguaiwu.png", --击杀300只怪物
    ["10"] = "ziyuanfuben.png", --每日充值
	["11"] = "jingyanlianzhi.png", --击杀300只怪物
    ["12"] = "jishashijieboss.png", -- 击杀世界BOSS
    ["13"] = "jiaomiejingying.png", --剿灭精英
    ["17"] = "xiangmorenwu.png", --降魔任务
    ["18"] = "hanghuifuli.png",--行会福利
    ["19"] = "hanghuimijing.png",--行会密境
    ["20"] = "hanghuijuanxian.png",--行会捐献装备
}

local TIME_ACT_ICON = {
    ["yaodu"] = "yaodumijing.png",--妖都秘境 10:30-11:00
    ["shenweimoyu1"]="shenweimoyu.png",--神威魔域 11:00-12:00
    ["mobaizhizun1"]="mobaizhizun.png",--膜拜至尊 12:00-13:00
    ["moyingchongchong"]="moyingchongchong.png",--魔影重重 13:00-14:00
    ["shenweimoyu2"]="longchengbaozang.png", --龙城宝藏 14:00-14:15
    ["shuangbeijingyan"]="shuangbeijingyan.png",--双倍经验 14:30-15:30
    ["wangzuo"]="leishenmijing.png",--雷神秘境 15:30-16:00
    ["shenmozhanchang"]="shenmozhanchang.png",--神魔战场 16:00-17:00
    ["yuanbaokuanghuan"]="yuanbaokuanghuan.png",-- 元宝狂欢
    ["tutengzhanchang"]="tutengzhanchang.png",--图腾战场 17:30-18:00
    ["mobaizhizun"]="mobaizhizun.png",-- 膜拜至尊 18:00-19:00
    ["wangchengzhengba"]="huangchengzhengba.png",-- 皇城争霸 20:00-21:00
    ["shenweimoyu3"] = "shenweimoyu.png", -- 神威魔域 21:00-22:00
    ["tongtian"] = "tongtianmijing.png", -- 通天秘境 22:30-23:00
}

function PanelActivityHall.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = 1
    var.listdata = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelActivityHall/UI_Act_Hall.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_act_hall")
    var.rightPanel = var.widget:getWidgetByName("Panel_tips"):hide()
    var.rightPanel:addClickEventListener(function(pSender)
        pSender:hide()
    end)
    var.bottomPanel = var.widget:getWidgetByName("Image_bottom"):hide()
    var.listActi = var.widget:getWidgetByName("ListView_act"):hide()
    var.listVitality = var.widget:getWidgetByName("ListView_vitality"):hide()
    var.listItemLiveness = var.widget:getWidgetByName("Panel_list_item_liveness"):hide()
    PanelActivityHall.initBottomAward()
    PanelActivityHall.updateBottomAward()
    PanelActivityHall.registeEvent()
    PanelActivityHall.addMenuTabClickEvent()

    return var.widget
end

function PanelActivityHall.addMenuTabClickEvent()
    local cp = cc.p(125,61)
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_liveness"))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_daily"), position=cp,types={UIRedPoint.REDTYPE.DAILYACT}}))
    :onButtonSelectChanged(function(event)
        PanelActivityHall.updateListViewByTag(event.selected)
    end)
    UIRadioButtonGroup:getButtonAtIndex(var.selectTab):setBrightStyle(BRIGHT_HIGHLIGHT)
    UIRadioButtonGroup:setButtonSelected(var.selectTab)
end

function PanelActivityHall.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_ACTIVITY_LIST_UPDATE, PanelActivityHall.handleActListView)
    :addEventListener(Notify.EVENT_ACTIVITY_SELECT_UPDATE, PanelActivityHall.handleSelectMsg)
    :addEventListener(Notify.EVENT_VITALITY_CHANGE, PanelActivityHall.handleVitalityChange)
    :addEventListener(Notify.EVENT_VITALITY_AWARD_CHANGE, PanelActivityHall.updateBottomAward)
    :addEventListener(Notify.EVENT_VITALITY_LIST, PanelActivityHall.handleVitalityList)
end

function PanelActivityHall.handleVitalityChange(event)
    var.textVitalityValue:setString(NetClient.mVitalityInfo.base.vitality)
    local items = var.vitalgridView:getItems()
    for k,item in pairs(items) do
        if item:getWidgetByName("livebg").vatalityindex == event.changeindex then
            item:removeAllChildren()
            PanelActivityHall.addLivenesGridItem(item, k)
            break
        end
    end
end

function PanelActivityHall.handleSelectMsg(event)
    if var.selectTab ~= TAG_DAILY then return end
    if not var.act or not var.act.info then return end
    if var.act.info.name ~= event.info.name then return end
    var.act.info.detail = event.info.detail
    PanelActivityHall.setRightData()
end

function PanelActivityHall.updateListViewByTag(tag)
    var.selectTab = tag
    if var.selectTab == TAG_LIVENESS then
        var.listVitality:show()
        var.listActi:hide()
    elseif var.selectTab == TAG_DAILY then
        var.listVitality:hide()
        var.listActi:show()
    end
--    var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
        if var.selectTab == TAG_LIVENESS then
            if NetClient.mVitalityInfo.base then
                PanelActivityHall.updateListView()
            else
                NetClient:PushLuaTable(VITALITY_ACTIONSET_NAME,util.encode({actionid="base_info"}))
            end
        elseif var.selectTab == TAG_DAILY then
            if NetClient:getActivityList(Const.ACTIVIY_INDEX_DAILY) then
                PanelActivityHall.updateListView()
            else
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="page",param={ pid = Const.ACTIVIY_INDEX_DAILY }}))
            end
        end
--    end)))
end

function PanelActivityHall.handleVitalityList()
--    print("更新活跃度面板", var.selectTab ~= TAG_LIVENESS)
--    if var.selectTab ~= TAG_LIVENESS then return end
    var.listActi:removeAllChildren()
    var.listVitality:removeAllChildren()
    var.vitalgridView = nil
    var.listdata = {}
    var.vitalityData = {}
    PanelActivityHall.updateListView()
    PanelActivityHall.initBottomAward()
end

function PanelActivityHall.handleActListView()
    if var.selectTab ~= TAG_DAILY then return end
    PanelActivityHall.updateListView()
end

function PanelActivityHall.updateListView()
    if var.selectTab == TAG_DAILY then
        if #var.listdata == 0 then
            local list = NetClient:getActivityList(Const.ACTIVIY_INDEX_DAILY)
            local unlist = {}
            local pastlist = {}
            local donginglist = {}
            local cur_time = os.date( "*t",os.time() )
            local curmin = cur_time.hour * 60 + cur_time.min
            local openstatus
            for _,info in ipairs(list) do
                local timelist = {}
                for w in string.gmatch(info.begintime, "%d+") do
                    table.insert(timelist, checkint(w))
                end
                openstatus = PanelActivityHall.checkActOpen(info.begintime, curmin)
                if openstatus ==  ACTIVITY_TYPE.UNDO then
                    table.insert(unlist, {type = ACTIVITY_TYPE.UNDO, info = info})
                elseif openstatus ==  ACTIVITY_TYPE.PAST then
                    table.insert(pastlist,  {type = ACTIVITY_TYPE.PAST, info = info})
                else
                    table.insert(donginglist,  {type = ACTIVITY_TYPE.DOING, info = info})
                end
            end
            var.listdata = {}
            table.insertto(var.listdata, donginglist)
            table.insertto(var.listdata, unlist)
            table.insertto(var.listdata, pastlist)
            var.gridView = UIGridView.new({
                parent = var.widget,
                list = var.listActi,
                gridCount = #var.listdata,
                cellSize = cc.size(var.listActi:getContentSize().width,var.listItemLiveness:getContentSize().height),
                columns = 2,
                async = true,
                initGridListener = PanelActivityHall.addDailyGridItem
            })
        end
    elseif var.selectTab == TAG_LIVENESS then
        if var.vitalgridView == nil then
            var.vitalityData = {}
            for k, v in ipairs(NetClient.mVitalityInfo.base.data) do
                if v.isshow and v.isshow == 1 then
                    table.insert(var.vitalityData, v)
                end
            end

            var.vitalgridView  = UIGridView.new({
                parent = var.widget,
                async = true,
                list = var.listVitality,
                gridCount = #var.vitalityData,
                cellSize = cc.size(var.listActi:getContentSize().width,var.listItemLiveness:getContentSize().height),
                columns = 2,
                initGridListener = PanelActivityHall.addLivenesGridItem
            })
        end
    end
end

function PanelActivityHall.addDailyGridItem(gridWidget, k)
    local act = var.listdata[k]
    local info = act.info
    local widget = var.listItemLiveness:clone():show()
    :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)
    widget:getWidgetByName("name"):setString(info.activitiesname)--:setTextColor(act.type == ACTIVITY_TYPE.PAST and Const.COLOR_GRAY_1_C3B or Const.COLOR_YELLOW_1_C3B)

    if game.getRoleLevel() < checkint(info.level) then
        widget:getWidgetByName("lv_alert"):setString(info.level.."级开启")
        widget:getWidgetByName("open_time_title"):hide()
    else
        widget:getWidgetByName("lv_alert"):hide()
        if act.type ~= ACTIVITY_TYPE.DOING then
            widget:getWidgetByName("open_time"):setString(info.begintime)--:setTextColor(act.type == ACTIVITY_TYPE.PAST and Const.COLOR_GRAY_1_C3B or Const.COLOR_YELLOW_1_C3B)
        else
            widget:getWidgetByName("open_time_title"):removeFromParent()
        end
    end

    -- 有活跃度
    local vitalinfo = NetClient.mVitalityInfo.base.data[info.vitalityid]
    if vitalinfo then
        widget:getWidgetByName("Text_num_left"):setString(checkint(vitalinfo.num))
        widget:getWidgetByName("Text_num_total"):setString("/"..vitalinfo.max_num)
        widget:getWidgetByName("Text_num_total"):setPositionX(widget:getWidgetByName("Text_num_left"):getPositionX()+widget:getWidgetByName("Text_num_left"):getContentSize().width)
        widget:getWidgetByName("Text_value_left"):setString(vitalinfo.have_vita)
        widget:getWidgetByName("Text_value_total"):setString("/"..vitalinfo.all_vitality)
        widget:getWidgetByName("Text_value_total"):setPositionX(widget:getWidgetByName("Text_value_left"):getPositionX()+widget:getWidgetByName("Text_value_left"):getContentSize().width)
    else
        widget:getWidgetByName("Text_num_left"):setString("无限")
        widget:getWidgetByName("Text_num_total"):setString("")
        :setPositionX(widget:getWidgetByName("Text_num_left"):getPositionX()+widget:getWidgetByName("Text_num_left"):getContentSize().width)
        widget:getWidgetByName("Text_value_left"):setString("无")
        widget:getWidgetByName("Text_value_total"):setString("")
        :setPositionX(widget:getWidgetByName("Text_value_left"):getPositionX()+widget:getWidgetByName("Text_value_left"):getContentSize().width)
    end


    widget:getWidgetByName("Image_high"):hide()
    local gobtn =  widget:getWidgetByName("Button_go")
    if act.type == ACTIVITY_TYPE.DOING then
        if game.getRoleLevel() >= checkint(info.level) then
            if info.actid == 6 then
                gobtn:setTitleText("开启中")
            else
                gobtn:setTitleText("前  往")
            end

            gobtn.index = k
            gobtn:show()
            gobtn:addClickEventListener(function(pSender)
                PanelActivityHall.goDaily(var.listdata[pSender.index])
            end)
            gameEffect.getNormalBtnSelectEffect()
            :setPosition(cc.p(gobtn:getContentSize().width/2,gobtn:getContentSize().height/2))
            :addTo(gobtn)
        else
            gobtn:hide()
            gobtn:setBright(false)
            gobtn:setTouchEnabled(false)
        end

    else
        gobtn:hide()
    end

    if TIME_ACT_ICON[info.name] and TIME_ACT_ICON[info.name] ~= "" then
        widget:getWidgetByName("Image_act_icon"):loadTexture(TIME_ACT_ICON[info.name],UI_TEX_TYPE_PLIST)
    else
        widget:getWidgetByName("Image_act_icon"):hide()
    end
--    if act.type == ACTIVITY_TYPE.PAST then
--        local gray_name = {"name", "open_time_title","open_time" }
--        for _, v in ipairs(gray_name) do
--            widget:getWidgetByName(v):setTextColor(Const.COLOR_GRAY_1_C3B)
--        end
--    end

    local function on_clear()
        local items = var.gridView:getItems()
        for _,item in pairs(items) do
            item:getWidgetByName("Image_high"):hide()
        end
    end
    local function on_select( pSender )
        on_clear()
        pSender:getWidgetByName("Image_high"):show()
        var.act = act
        if not info.detail then
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="select",param={ pid = Const.ACTIVIY_INDEX_DAILY, index = info.index }}))
        else
            PanelActivityHall.setRightData()
        end
    end
    widget:addClickEventListener(on_select)
    widget.click = on_select
end

function PanelActivityHall.setRightData()
    if not var.act then return  end
    local info = var.act.info
    if not info then return  end
    var.rightPanel:show()
    var.rightPanel:getWidgetByName("Label_Title"):setString(info.activitiesname)
    var.rightPanel:getWidgetByName("Label_time_r"):setString(info.begintime)
    var.rightPanel:getWidgetByName("Label_explain"):setString(info.detail.introduction)
    var.rightPanel:getWidgetByName("Label_lv"):setString(info.level):setTextColor(game.getRoleLevel()>= checkint(info.level) and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)

    local gobtn = var.rightPanel:getWidgetByName("Button_go")
    if var.act.type == ACTIVITY_TYPE.DOING and game.getRoleLevel() >= checkint(info.level) then
        gobtn:setTouchEnabled(true)
        gobtn:setBright(true)
        gobtn:addClickEventListener(function(pSender)
            PanelActivityHall.goDaily()
        end)
        if not gobtn.upeffect then
            gobtn.upeffect = gameEffect.getNormalBtnSelectEffect()
            gobtn.upeffect:setPosition(cc.p(gobtn:getContentSize().width/2,gobtn:getContentSize().height/2))
            gobtn.upeffect:addTo(gobtn)
        end
        if info.actid == 6 then
            gobtn:setTitleText("开启中")
        else
            gobtn:setTitleText("前  往")
        end
    else
        gobtn:setTitleText("前  往")
        gobtn:setTouchEnabled(false)
        gobtn:setBright(false)
        if gobtn.upeffect then
            gobtn.upeffect:removeFromParent()
            gobtn.upeffect = nil
        end
    end
    local srcitem = var.rightPanel:getWidgetByName("acti_item_1"):hide()
    local listview = var.rightPanel:getWidgetByName("ListView_award")
    listview:removeAllItems()
    for _, itemid in ipairs(info.detail.down) do
        local itembg = srcitem:clone():show()
        UIItem.getSimpleItem({
            parent = itembg,
            typeId = checkint(itemid),
        })
        listview:pushBackCustomItem(itembg)
    end
end

function PanelActivityHall.goDaily(act)
    if not act then act = var.act end
    if not act then return  end
    local info = act.info
    if not info then return  end
    local openstatus = PanelActivityHall.checkActOpen(info.begintime)
    if openstatus == ACTIVITY_TYPE.DOING then
        NetClient:PushLuaTable("actlist",util.encode({actionid="goact",param=info.actid}))
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_activity_hall"})
    else
        NetClient:alertLocalMsg("活动未开始哦！","alert")
    end
end

function PanelActivityHall.addLivenesGridItem(gridWidget, k)
    local info = var.vitalityData[k]
    local widget = var.listItemLiveness:clone():show()
    :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)
    widget:setName("livebg")
    widget:getWidgetByName("open_time_title"):hide()
    widget:getWidgetByName("name"):setString(info.name)
    widget:getWidgetByName("Text_num_left"):setString(info.num)
    widget:getWidgetByName("Text_num_total"):setString("/"..info.max_num)
    :setPositionX(widget:getWidgetByName("Text_num_left"):getPositionX()+widget:getWidgetByName("Text_num_left"):getContentSize().width)
    widget:getWidgetByName("Text_value_left"):setString(info.have_vita)
    widget:getWidgetByName("Text_value_total"):setString("/"..info.all_vitality)
    :setPositionX(widget:getWidgetByName("Text_value_left"):getPositionX()+widget:getWidgetByName("Text_value_left"):getContentSize().width)


    widget:getWidgetByName("Image_high"):hide()

    if VITALITY_ICON[tostring(info.idx)] and VITALITY_ICON[tostring(info.idx)] ~= "" then
        widget:getWidgetByName("Image_act_icon"):loadTexture(VITALITY_ICON[tostring(info.idx)],UI_TEX_TYPE_PLIST)
    else
        widget:getWidgetByName("Image_act_icon"):hide()
    end
    local eventarr = string.split(info.event,":")
    local btnEventStr = "event:"..eventarr[1]
    local gobtn = widget:getWidgetByName("Button_go")
    local rolelevel = game.getRoleLevel()
    if rolelevel < info.needlv then
        gobtn:hide()
        widget:getWidgetByName("lv_alert"):setString(info.needlv.."级开启")
    else
        widget:getWidgetByName("lv_alert"):hide()
        if info.num < info.max_num then
            gobtn:show()
            gobtn.user_data = btnEventStr
            gobtn:addClickEventListener(function(pSender)
                PanelActivityHall.goLiveness(pSender)
            end)
            local function on_clear()
                local items = var.vitalgridView:getItems()
                for _,item in pairs(items) do
                    item:getWidgetByName("Image_high"):hide()
                end
            end
            local function on_select( pSender )
                on_clear()
                pSender:getWidgetByName("Image_high"):show()
                --            PanelActivityHall.goLiveness(pSender)
            end
            widget:addClickEventListener(on_select)
        else
            gobtn:hide()
        end
    end

    widget.vatalityindex = info.idx
    widget.user_data = btnEventStr
end

function PanelActivityHall.goLiveness(pSender)
    util.touchlink(pSender,ccui.TouchEventType.ended,"","")
    NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_activity_hall"})
end

function PanelActivityHall.checkActOpen(begintime, curmin)
    if not curmin then
        local cur_time = os.date( "*t",os.time() )
        curmin = cur_time.hour * 60 + cur_time.min
    end

    local timelist = {}
    for w in string.gmatch(begintime, "%d+") do
        table.insert(timelist, checkint(w))
    end
    local startmin = timelist[1] * 60 + timelist[2]
    local endmin = timelist[3] * 60 + timelist[4]
    if curmin < startmin then
        return ACTIVITY_TYPE.UNDO
    elseif curmin >= endmin then
        return ACTIVITY_TYPE.PAST
    else
        return ACTIVITY_TYPE.DOING
    end
end

function PanelActivityHall.initBottomAward()
    if not NetClient.mVitalityInfo.base then return end
    var.bottomPanel:show()
    for i = 1, 4 do
        local info = NetClient.mVitalityInfo.base.award[i]
        local awardPanel = var.bottomPanel:getWidgetByName("Button_liveness_"..i)
        awardPanel.typeId = info.award[1].typeid
        awardPanel.index = i
        awardPanel:setTouchEnabled(true)
        awardPanel:addClickEventListener(function(pSender)
            if not NetClient.mVitalityInfo.awardInfo[pSender.index] or NetClient.mVitalityInfo.awardInfo[pSender.index] == 0 then
                NetClient:dispatchEvent(
                    {
                        name = Notify.EVENT_HANDLE_ITEM_TIPS,
                        typeId = pSender.typeId,
                        visible = true,
                    })
            elseif NetClient.mVitalityInfo.awardInfo[pSender.index] == 1 then
                NetClient:PushLuaTable(VITALITY_ACTIONSET_NAME,util.encode({actionid="give_award",param={ idx = pSender.index}}))
            elseif NetClient.mVitalityInfo.awardInfo[pSender.index] == 2 then
                NetClient:alertLocalMsg("已领取", "alert")
            end
        end)
    end

    var.textVitalityValue = var.bottomPanel:getWidgetByName("Text_huoyuevalue")
    var.textVitalityValue:setString(NetClient.mVitalityInfo.base.vitality)
    PanelActivityHall.updateBar()
end

function PanelActivityHall.updateBar()
--    local bar = var.bottomPanel:getWidgetByName("Image_bar")
--    local h = bar:getContentSize().height
--    local w = (NetClient.mVitalityInfo.base.vitality/NetClient.mVitalityInfo.base.allvitality)*526
--    bar:setContentSize(cc.size(w,h))

    if not NetClient.mVitalityInfo.base or not NetClient.mVitalityInfo.base.award then return end
    local barw = 68
    local barh = 6
    local minvalue = 0
    local vitality = NetClient.mVitalityInfo.base.vitality
    for i = 1, 4 do
        local info = NetClient.mVitalityInfo.base.award[i]
        local bar = var.bottomPanel:getWidgetByName("Image_bar_"..i)
        if vitality > info.need_num then
            bar:setContentSize(cc.size(barw,barh))
        elseif vitality > minvalue and  vitality <= info.need_num then
            local w = ((vitality - minvalue)/(info.need_num-minvalue))*barw
            bar:setContentSize(cc.size(w,barh))
        else
            bar:hide()
        end
        minvalue = info.need_num
    end
end

function PanelActivityHall.updateBottomAward()
    local awardPanel
    for k, v in ipairs(NetClient.mVitalityInfo.awardInfo or {}) do
        awardPanel = var.bottomPanel:getWidgetByName("Button_liveness_"..k)
        if awardPanel then
            if v == 0 then -- 0 不能领 1 可领 2 已领
                if awardPanel:getChildByName("awardEffect") then awardPanel:removeChildByName("awardEffect") end
            elseif v == 1 then
                if not awardPanel:getChildByName("awardEffect") then
                    gameEffect.playEffectByType(gameEffect.EFFECT_VITALITY_AWARD)
                    :setPosition(cc.p(70,40)):setName("awardEffect"):addTo(awardPanel,-1)
                end
            elseif v == 2 then
                awardPanel:setBright(false)
                awardPanel:setTouchEnabled(false)
                if awardPanel:getChildByName("awardEffect") then awardPanel:removeChildByName("awardEffect") end
            end
        end
    end
end

return PanelActivityHall