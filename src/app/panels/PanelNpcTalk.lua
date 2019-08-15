--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/26 17:04
-- To change this template use File | Settings | File Templates.
--

local PanelNpcTalk = {}
local var = {}

local BTN_NAME_TO_GROUP_ID = {
    ["Panel_city"]=1,
    ["Panel_dangerous"]=2,
    ["Panel_others"]=3,
}

function PanelNpcTalk.initView(params)
    var = {}
    local params = params or {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelNpcTalk/PanelNpcTalk.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_npctalk")
    var.widget:addClickEventListener(function (pSender)
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_npctalk"})
    end)

    var.panelExtend = params.extend.mParam or ""
    var.panelNpcName = params.extend.mParam2 or ""
    var.talkPanel = var.widget:getWidgetByName("npc_talk_bg")
    var.widget:getWidgetByName("movenpc_bg"):hide()
    var.widget:getWidgetByName("list_talk_bg"):hide()
    var.moveListView = var.widget:getWidgetByName("movenpc_bg"):getWidgetByName("ListView_move")
    var.widget:getWidgetByName("Image_bg"):getWidgetByName("Button_close"):addClickEventListener(function (pSender)
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_npctalk"})
    end)
    var.LuaMiddle = ""
    var.widget:getWidgetByName("panel_daily_acc"):hide()
    var.widget:getWidgetByName("panel_daily_done"):hide()
    var.widget:getWidgetByName("panel_award_rc"):hide()
    var.widget:getWidgetByName("panel_xm_bg"):hide()
    if var.panelExtend == "richang" then
        var.talkPanel:hide()
        var.widget:getWidgetByName("daily_talk_bg"):show()
        var.widget:getWidgetByName("npc_ph_bg"):hide()
        var.widget:getWidgetByName("Label_t"):setString("日常任务")
        var.LuaMiddle = "richang"
        NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "openPanel"}))
    elseif var.panelExtend == "richangjy" then
      
        var.talkPanel:hide()
        var.widget:getWidgetByName("daily_talk_bg"):show()
        var.widget:getWidgetByName("npc_ph_bg"):hide()
        var.widget:getWidgetByName("Label_t"):setString("剿灭精英")
        var.LuaMiddle = "jingyingRC"
        NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "openPanel"}))
    elseif var.panelExtend == "richangxm" then
        var.talkPanel:hide()
        var.widget:getWidgetByName("daily_talk_bg"):show()
        var.widget:getWidgetByName("npc_ph_bg"):hide()
        var.widget:getWidgetByName("Label_t"):setString("降魔任务")
        var.LuaMiddle = "xiangmodian"
        NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "openPanel"}))
    elseif var.panelExtend == "caikuang" then
        var.talkPanel:hide()
        var.widget:getWidgetByName("daily_talk_bg"):show()
        var.widget:getWidgetByName("npc_ph_bg"):hide()
        var.widget:getWidgetByName("Label_t"):setString("采矿")
        var.LuaMiddle = "richang3"
        NetClient:PushLuaTable("npc.richang3.onGetJsonData",util.encode({actionid = "openPanel"}))
    elseif var.panelExtend == "paohuan" then
        var.talkPanel:hide()
        var.widget:getWidgetByName("Label_t"):setString("跑环")
        var.widget:getWidgetByName("daily_talk_bg"):hide()
        var.widget:getWidgetByName("npc_ph_bg"):show()
        var.widget:getWidgetByName("panel_ph_start"):show()
        var.widget:getWidgetByName("panel_ph_done"):hide()
        var.LuaMiddle = "biqi.paohuan"
        NetClient:PushLuaTable("npc.biqi.paohuan.onGetJsonData",util.encode({actionid = "openPanel",npc_name = var.panelNpcName}))
    else
        var.talkPanel:show()
        var.widget:getWidgetByName("daily_talk_bg"):hide()
        var.widget:getWidgetByName("npc_ph_bg"):hide()
        PanelNpcTalk.showContent()
    end
    PanelNpcTalk.registeEvent()
    return var.widget
end

function PanelNpcTalk.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
        :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelNpcTalk.handlePanelData)
end

--160.00  245

function PanelNpcTalk.handlePanelData(event)
    if event and (event.type == "richang_data" or event.type == "richangjy_data" or event.type == "caikuang_data") then
        local fumo_data = json.decode(event.data)
        var.awardinfo = fumo_data.award
        if not fumo_data then return end
        var.widget:getWidgetByName("panel_xm_bg"):hide()
        var.widget:getWidgetByName("panel_award_rc"):show()
        var.widget:getWidgetByName("img_bottom_line"):setPositionY(160)
        for i=1,2 do
            var.widget:getWidgetByName("item_icon_"..i):removeAllChildren()
            if i <= #fumo_data.award then
                UIItem.getSimpleItem({
                    parent = var.widget:getWidgetByName("item_icon_"..i),
                    typeId = fumo_data.award[i].id,
                    name = fumo_data.award[i].name,
                    itemCallBack = function () end,
                })
                --local namewidget = var.widget:getWidgetByName("label_award_info_"..i)
                local numwidget = var.widget:getWidgetByName("label_num_"..i)
                if fumo_data.starinfo then
                    numwidget:setString(game.getShorNum(fumo_data.award[i].num*fumo_data.starinfo.bs))
                else
                    numwidget:setString(game.getShorNum(fumo_data.award[i].num))
                end
                
                --[[
                local itemdef = NetClient:getItemDefByID(fumo_data.award[i].id)
                if not itemdef then
                    itemdef = NetClient:getItemDefByName(fumo_data.award[i].name)
                end
                if itemdef then
                    namewidget:setString(itemdef.mName.."：")
                end
                numwidget:setPositionX(namewidget:getContentSize().width+5)
                ]]
            end
        end
         
        if event.type == "richangjy_data" then
            var.widget:getWidgetByName("panel_award_jinyin_rc"):show()
            var.showtipType = false
            var.jydata = fumo_data.starinfo
            if var.jydata.star  == var.jydata.max or fumo_data.type == 3 then
                if var.jydata.star  == var.jydata.max then
                    var.widget:getWidgetByName("Image_manji"):show()
                end
                var.widget:getWidgetByName("Button_shuaxing"):hide()
                var.widget:getWidgetByName("Button_shuaxing"):setTouchEnabled(false)
                var.widget:getWidgetByName("Button_shixing"):hide()
                var.widget:getWidgetByName("Button_shixing"):setTouchEnabled(false)
            else
                var.widget:getWidgetByName("Image_manji"):hide()
                var.widget:getWidgetByName("Button_shuaxing"):show()
                var.widget:getWidgetByName("Button_shuaxing"):setTouchEnabled(true)
                var.widget:getWidgetByName("Button_shixing"):show()
                var.widget:getWidgetByName("Button_shixing"):setTouchEnabled(true)
                var.widget:getWidgetByName("Button_shixing"):addClickEventListener(function (pSender)
                    if not NetClient.showshitipType then
                        NetClient.showshitipType = false
                        local param = {
                        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否花费"..var.jydata.freshall[var.jydata.star].."绑元提升至10星",
                        confirmTitle = "确定", cancelTitle = "取消",showtype = true,showValue = NetClient.showshitipType,showpanel = "shixing",
                        confirmCallBack = function ()
                            
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_total_star"}))
                        end
                        }
                        EventDispatcher:dispatchEvent(param)
                    else
                        NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_total_star"}))
                    end
                end)
                var.widget:getWidgetByName("Button_shuaxing"):addClickEventListener(function (pSender)
                    if not NetClient.showtipType then
                        NetClient.showtipType = false
                        local param = {
                        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "    是否花费"..var.jydata.fresh.."绑元提升任务星级                  (刷星有一定几率失败)",
                        confirmTitle = "确定", cancelTitle = "取消",showtype = true,showValue = NetClient.showtipType,showpanel = "shuaxing",
                        confirmCallBack = function ()
                            --var.showtipType = true
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_star"}))
                        end
                        }
                        EventDispatcher:dispatchEvent(param)
                    else
                        NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_star"}))
                    end
                end)
            end 
            for i = 1, var.jydata.max do 
                if i > var.jydata.star then
                    var.widget:getWidgetByName("Button_star"..i):setBright(false)
                else
                    var.widget:getWidgetByName("Button_star"..i):setBright(true)
                    var.refreshstar = i
                end
            end
        end
        
        if event.type ~= "caikuang_data" then
            if fumo_data.can_use_count > 0 then
                var.widget:getWidgetByName("label_left_info"):setString("今日剩余次数：")
                var.widget:getWidgetByName("label_left_time"):setString(fumo_data.can_use_count)
                if var.showCloseGuild then
                    UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_close"),"点击关闭按钮",UIButtonGuide.UI_TYPE_RIGHT)
                end

            elseif fumo_data.can_buy_count > 0 then
                var.widget:getWidgetByName("label_left_info"):setString("剩余购买次数：")
                var.widget:getWidgetByName("label_left_time"):setString(fumo_data.can_buy_count)
            else
                var.widget:getWidgetByName("label_left_info"):setString("今日剩余次数：")
                var.widget:getWidgetByName("label_left_time"):setString("0")
                var.widget:getWidgetByName("panel_award_jinyin_rc"):hide()
                var.widget:getWidgetByName("btn_done"):setBright(false)
            end
            var.widget:getWidgetByName("label_task_info"):setString(fumo_data.name)
        else
            var.widget:getWidgetByName("label_task_info"):setString(fumo_data.desc)
            var.widget:getWidgetByName("label_left_info"):setString("今日剩余次数：")
            var.widget:getWidgetByName("label_left_time"):setString(fumo_data.left_count)
            if fumo_data.left_count == 0 then
                var.widget:getWidgetByName("panel_award_jinyin_rc"):hide()
                var.widget:getWidgetByName("btn_done"):setBright(false)
            end
        end
        var.widget:getWidgetByName("Text_richang_vip_tips"):hide()

        if fumo_data.type == 2 or fumo_data.type == 1 then
            var.widget:getWidgetByName("panel_daily_acc"):show()
            var.widget:getWidgetByName("panel_daily_done"):hide()
            local finishRichang = false
            if event.type == "richang_data" and fumo_data.can_use_count > 0  then
                local opened,openLevel = game.checkVipOpened("rconekey")
                if not opened then
                    var.widget:getWidgetByName("Text_richang_vip_tips"):show():setString(string.format("VIP%d",openLevel))
                else
                    finishRichang = true
                end
            end
            var.widget:getWidgetByName("btn_done"):setTitleText(finishRichang and "一键完成" or "接受任务")
            var.widget:getWidgetByName("btn_done"):addClickEventListener(function (pSender)
                if finishRichang then
                    NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_onekey_finish"}))
                else
                    if event.type ~= "caikuang_data" then
                        if fumo_data.can_use_count > 0 then
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_accept"}))
                            EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_npctalk"})
                        elseif fumo_data.can_buy_count > 0 then
                            local param = {
                                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "购买额外任务次数需要花费"..fumo_data.buy_count_yuanbao.."元宝",
                                confirmTitle = "购 买", cancelTitle = "取 消",
                                confirmCallBack = function ()
                                    -- 购买斩妖令
                                    NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "buy_once"}))
                                    NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "openPanel"}))
                                end
                            }
                            NetClient:dispatchEvent(param)
                        end
                    else
                        NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_accept"}))
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_npctalk"})
                    end
                end
            end)
            
        elseif fumo_data.type == 3 then
            var.widget:getWidgetByName("panel_daily_acc"):show()
            var.widget:getWidgetByName("panel_daily_done"):hide()
            var.widget:getWidgetByName("btn_done"):setTitleText("立即前往"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_go"}))
                EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_npctalk"})
            end)
        elseif fumo_data.type == 4 then
            if var.panelExtend == "richang" then
                var.widget:getWidgetByName("panel_daily_acc"):hide()
                var.widget:getWidgetByName("panel_daily_done"):show()
                for i=1,3 do
                    var.widget:getWidgetByName("Button_done_"..i):addClickEventListener(function (pSender)
                        if UIButtonGuide.isShowRichangTaskGuide() then
                            UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.RICHANGTASK})
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_done"..i}))
                            EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_npctalk"})
                            --NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "openPanel"}))
                        else
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_done"..i}))
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "openPanel"}))
                        end
                    end)
                end
                if UIButtonGuide.isShowRichangTaskGuide() then
                    var.showCloseGuild = true
                    var.guildtype = UIButtonGuide.GUILDTYPE.RICHANGTASK
                    UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_done_3"),"点击此处领取经验")
                else
                    UIButtonGuide.clearGuideTip(var.widget:getWidgetByName("Button_done_3"))
                end
                var.showCloseGuild = false
            elseif var.panelExtend == "richangjy" or var.panelExtend == "caikuang" then
                var.widget:getWidgetByName("panel_daily_acc"):show()
                var.widget:getWidgetByName("panel_daily_done"):hide()
                var.widget:getWidgetByName("Button_shuaxing"):hide()
                var.widget:getWidgetByName("Button_shuaxing"):setTouchEnabled(false)
                var.widget:getWidgetByName("Button_shixing"):hide()
                var.widget:getWidgetByName("Button_shixing"):setTouchEnabled(false)
                var.widget:getWidgetByName("btn_done"):setTitleText("完成任务"):addClickEventListener(function (pSender)
                    NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_done"}))
                    NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "openPanel"}))
                end)
            end
        end
    elseif event and event.type == "richangjy_star" then
            local freshdata = json.decode(event.data)
            var.jydata.star = freshdata.star
            for i = 1,#var.awardinfo do 
                var.widget:getWidgetByName("label_num_"..i):setString(game.getShorNum(var.awardinfo[i].num*freshdata.bs))
            end
            
            if freshdata.star == var.jydata.max then
                var.widget:getWidgetByName("Image_manji"):show()
                var.widget:getWidgetByName("Button_shuaxing"):hide()
                var.widget:getWidgetByName("Button_shuaxing"):setTouchEnabled(false)
                var.widget:getWidgetByName("Button_shixing"):hide()
                var.widget:getWidgetByName("Button_shixing"):setTouchEnabled(false)
            else
                var.widget:getWidgetByName("Image_manji"):hide()
                var.widget:getWidgetByName("Button_shuaxing"):show()
                var.widget:getWidgetByName("Button_shuaxing"):setTouchEnabled(true)
                var.widget:getWidgetByName("Button_shixing"):show()
                var.widget:getWidgetByName("Button_shixing"):setTouchEnabled(true)
                var.widget:getWidgetByName("Button_shixing"):addClickEventListener(function (pSender)
                    if not NetClient.showshitipType then
                        NetClient.showshitipType = false
                        local param = {
                        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否花费"..var.jydata.freshall[var.jydata.star].."绑元提升至10星",
                        confirmTitle = "确定", cancelTitle = "取消",showtype = true,showValue = NetClient.showshitipType,showpanel = "shixing",
                        confirmCallBack = function ()    
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_total_star"}))
                        end
                        }
                        EventDispatcher:dispatchEvent(param)
                    else
                        NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_total_star"}))
                    end 
                end)
                var.widget:getWidgetByName("Button_shuaxing"):addClickEventListener(function (pSender)
                    if not NetClient.showtipType then
                        NetClient.showtipType = false
                        local param = {
                        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "    是否花费"..var.jydata.fresh.."绑元提升任务星级                  (刷星有一定几率失败)",
                        confirmTitle = "确定", cancelTitle = "取消",showtype = true,showValue = NetClient.showtipType,showpanel = "shuaxing",
                        confirmCallBack = function ()
                            --NetClient.showtipType = true
                            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_star"}))
                        end
                        }
                        EventDispatcher:dispatchEvent(param)
                    else
                        NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "fresh_star"}))
                    end  
                end)
            end 
            for i = 1, var.jydata.max do 
                if i > freshdata.star then
                    var.widget:getWidgetByName("Button_star"..i):setBright(false)
                else   
                    if i > var.refreshstar then
                        gameEffect.playEffectByType(gameEffect.EFFECT_REFRESHSTAR)
                        :setPosition(cc.p(var.widget:getWidgetByName("Button_star"..i):getContentSize().width/2,var.widget:getWidgetByName("Button_star"..i):getContentSize().height/2)):addTo(var.widget:getWidgetByName("Button_star"..i))
                    end
                    var.widget:getWidgetByName("Button_star"..i):setBright(true)
                end
            end
            var.refreshstar = freshdata.star
    elseif event and event.type == "richangxm_data" then
        local fumo_data = json.decode(event.data)
        if not fumo_data then return end
        var.widget:getWidgetByName("panel_xm_bg"):show()
        var.widget:getWidgetByName("panel_award_rc"):hide()
        var.widget:getWidgetByName("panel_daily_acc"):hide()
        var.widget:getWidgetByName("panel_daily_done"):hide()
        var.widget:getWidgetByName("img_bottom_line"):setPositionY(245)
        for i=1,4 do
            var.widget:getWidgetByName("xm_icon_"..i):removeAllChildren()
            if i <= #fumo_data.award then
                UIItem.getSimpleItem({
                    parent = var.widget:getWidgetByName("xm_icon_"..i),
                    name = fumo_data.award[i].name,
                    num = fumo_data.award[i].num,
                    itemCallBack = function () end,
                })
            end
        end
        for i=1,3 do
            local need_num = fumo_data.need_tab[i]
            if not need_num then need_num = 0 end
            var.widget:getWidgetByName("Button_xmdone_"..i):setTitleText("上交降魔符X"..need_num):addClickEventListener(function (pSender)
                NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_done"..(i+1)}))
                NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "openPanel"}))
            end)
        end

        var.widget:getWidgetByName("label_xm_desp_2"):setString("任务完成次数："..(5 - fumo_data.can_use_count).."/5")
        var.widget:getWidgetByName("label_task_info"):setString("      "..fumo_data.intro)
        var.widget:getWidgetByName("Button_xmdone"):addClickEventListener(function (pSender)
            NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = "task_go"}))
            EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_npctalk"})
        end)
        var.widget:getWidgetByName("label_have_num"):setString(fumo_data.have_num)
    elseif event and event.type == "paohuan_data" then
        local fumo_data = json.decode(event.data)
        if not fumo_data then return end
        print(event.data)
        local curShowPanel = var.widget:getWidgetByName("npc_ph_bg")
        if fumo_data.type == 2 then
            curShowPanel:getWidgetByName("panel_ph_start"):show()
            curShowPanel:getWidgetByName("panel_ph_done"):hide()
            curShowPanel:getWidgetByName("label_ph_info"):setString(fumo_data.title)
            for i=1,#fumo_data.con do
                curShowPanel:getWidgetByName("label_ph_con_"..i):setString(fumo_data.con[i])
            end
            for i=1,#fumo_data.phtype do
                curShowPanel:getWidgetByName("label_ph_type_"..i):setString(fumo_data.phtype[i])
            end
            curShowPanel:getWidgetByName("btn_ph_done"):addClickEventListener(function (pSender)
                NetClient:PushLuaTable("npc."..var.LuaMiddle..".onGetJsonData",util.encode({actionid = fumo_data.callback,npc_name = var.panelNpcName}))
            end)
        elseif fumo_data.type == 3 or fumo_data.type == 4 then
            curShowPanel:getWidgetByName("label_rich_dot"):removeAllChildren()
            curShowPanel:getWidgetByName("panel_ph_start"):hide()
            curShowPanel:getWidgetByName("panel_ph_done"):show()
            local richLabel, richWidget = util.newRichLabel(cc.size(370, 0), 0)
            var.mPHRichWidget = richWidget
            util.setRichLabel(richLabel, fumo_data.desp, "panel_npctalk", 24)
            richLabel:setPosition(cc.p(-190,richLabel:getRealHeight()/2))
            curShowPanel:getWidgetByName("label_rich_dot"):show():addChild(richWidget)
            curShowPanel:getWidgetByName("label_ph_num"):setString(fumo_data.done_time.."/50")
            if fumo_data.type == 3 then
                curShowPanel:getWidgetByName("btn_ph_done2"):hide()
                curShowPanel:getWidgetByName("label_ph_state"):setString("(已接)")
            elseif fumo_data.type == 4 then
                curShowPanel:getWidgetByName("btn_ph_done2"):show()
                curShowPanel:getWidgetByName("label_ph_state"):setString("(完成)")
            end
            curShowPanel:getWidgetByName("icon_award_1"):removeAllChildren()
            UIItem.getSimpleItem({
                parent = curShowPanel:getWidgetByName("icon_award_1"),
                name = "经验",
                itemCallBack = function () end,
            })
            curShowPanel:getWidgetByName("award_num_1"):setString(game.getShorNum(fumo_data.exp_num))

            for i=1,#fumo_data.award do
                curShowPanel:getWidgetByName("icon_50_award_"..i):removeAllChildren()
                UIItem.getSimpleItem({
                    parent = curShowPanel:getWidgetByName("icon_50_award_"..i),
                    name = fumo_data.award[i][1],
                    itemCallBack = function () end,
                })
                curShowPanel:getWidgetByName("award_50_num_"..i):setString(game.getShorNum(fumo_data.award[i][2]))
            end
            if fumo_data.callback then
                if fumo_data.callback == "T1001END" then
                    curShowPanel:getWidgetByName("btn_ph_done2"):show()
                end
                curShowPanel:getWidgetByName("btn_ph_done2"):addClickEventListener(function (pSender)
                    NetClient:PushLuaTable("npc.biqi.paohuan.onGetJsonData",util.encode({actionid = fumo_data.callback,npc_name = var.panelNpcName}))
                end)
            end
        end
    end
end

function PanelNpcTalk.onPanelClose()
    NetClient.m_strNpcTalkViewId = 0
end

function PanelNpcTalk.onGroupTitleClicked(pSender)
    local btnname = pSender:getName()
    local groupid = BTN_NAME_TO_GROUP_ID[btnname]
    if not groupid then return end

    local remove = false
    if pSender.showflag == 1 then
        -- 展开状态，收起操作
        pSender.showflag = 0
        remove = true
        pSender:getWidgetByName("Image_change"):loadTexture("button_plus.png", UI_TEX_TYPE_PLIST)
    else
        -- 收起状态，展开操作
        pSender.showflag = 1
        remove = false
        pSender:getWidgetByName("Image_change"):loadTexture("button_minus.png", UI_TEX_TYPE_PLIST)
    end
    local senderindex = var.moveListView:getIndex(pSender)
    local groupmanplen = #(MoveNpcDefData[groupid].list)
    if remove then
        local subItem = var.moveListView:getItem(senderindex+1)
        if subItem and subItem:getName() == btnname.."_sub" then
            var.moveListView:removeItem(senderindex+1)
        end
    else
        local subItem = ccui.Layout:create()
        subItem:setContentSize(cc.size(pSender:getContentSize().width, groupmanplen*pSender:getContentSize().height))
        subItem:setLayoutType(ccui.LayoutType.VERTICAL)
        subItem:setName(btnname.."_sub")

        for k, mapinfo in ipairs(MoveNpcDefData[groupid].list) do
            local btnOp = ccui.Button:create()
            btnOp:loadTextures("mapmove/"..mapinfo.bgres..".png","mapmove/"..mapinfo.bgres..".png","",UI_TEX_TYPE_LOCAL)
            btnOp.groupid = groupid
            btnOp.index = k
            btnOp:addClickEventListener(PanelNpcTalk.onMapItemClicked)
            local linearLayoutParameter = ccui.LinearLayoutParameter:create()
            linearLayoutParameter:setGravity(ccui.LinearGravity.centerHorizontal)
            btnOp:setLayoutParameter(linearLayoutParameter)
            btnOp:addTo(subItem)
        end

        var.moveListView:insertCustomItem(subItem, senderindex+1)
    end
end

function PanelNpcTalk.onMapItemClicked(pSender)
    local mapinfo = MoveNpcDefData[pSender.groupid].list[pSender.index]
    if not mapinfo then return end

    if mapinfo.minLevel and mapinfo.minLevel > game.getRoleLevel() then
        NetClient:alertLocalMsg("想去"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,mapinfo.mapname).."??还是"..game.make_str_with_color(Const.COLOR_RED_1_STR,mapinfo.minLevel).."级以后再去吧!","alert")
        return
    end

    if mapinfo.minVIPLevel and mapinfo.minVIPLevel > game.getVipLevel() then
        NetClient:alertLocalMsg("由于您的VIP等级不足,无法进入"..game.make_str_with_color(Const.COLOR_RED_1_STR,mapinfo.mapname),"alert")
        return
    end

    if mapinfo.minZhuanshengLevel and mapinfo.minZhuanshengLevel > game.getZsLevel() then
        NetClient:alertLocalMsg("想去"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,mapinfo.mapname).."??还是"..game.make_str_with_color(Const.COLOR_RED_1_STR,mapinfo.minZhuanshengLevel).."转以后再去吧!","alert")
        return
    end
    NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_npctalk"})
    if NetClient.m_nTalkType == "npc" then
        NetClient:NpcTalk(NetClient.m_nNpcTalkId,mapinfo.talkstr)
    elseif NetClient.m_nTalkType == "player" then
        NetClient:PlayerTalk(NetClient.m_nNpcTalkId,mapinfo.talkstr)
    end
end

function PanelNpcTalk.showMoveNpcTalk()
    var.talkPanel:hide()
    var.widget:getWidgetByName("Label_t"):setString("对话传送")
    var.widget:getWidgetByName("movenpc_bg"):show()
    local item1 = var.moveListView:getItem(0)
    local item2 = var.moveListView:getItem(1)
    local item3 = var.moveListView:getItem(2)
    item1:addClickEventListener(PanelNpcTalk.onGroupTitleClicked)
    item2:addClickEventListener(PanelNpcTalk.onGroupTitleClicked)
    item3:addClickEventListener(PanelNpcTalk.onGroupTitleClicked)

--    默认展开第一组
    item1.showflag = 0
    PanelNpcTalk.onGroupTitleClicked(item1)
    item2.showflag = 0
--    PanelNpcTalk.onGroupTitleClicked(item2)
    item3.showflag = 0
--    PanelNpcTalk.onGroupTitleClicked(item3)
end

function PanelNpcTalk.showTalk()
    var.widget:getWidgetByName("Label_t"):setString("对话")
    var.talkPanel:getWidgetByName("Text_npc_name"):setString(NetClient.m_nNpcName)
    var.talkPanel:getWidgetByName("Panel_item"):hide()
    var.talkPanel:getWidgetByName("Text_cost_vcoin"):hide()
    var.talkPanel:getWidgetByName("Button_award"):hide()
    var.talkPanel:getWidgetByName("Button_go"):hide()
    var.talkPanel:getWidgetByName("detail_scroll"):hide()
    var.talkPanel:getWidgetByName("Text_intro"):hide()
    local scrollview = var.talkPanel:getWidgetByName("npcTalk_scroll")
    scrollview:show():setTouchEnabled(true)
    local innerSize = scrollview:getInnerContainerSize()
    local contentSize = scrollview:getContentSize()

    local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
    util.setRichLabel(richLabel,NetClient.m_strNpcTalkMsg,"panel_npctalk",24,Const.COLOR_YELLOW_1_OX)
    richLabel:setVisible(true)
    richWidget:setContentSize(cc.p(contentSize.width,richLabel:getRealHeight()))
    scrollview:addChild(richWidget,10)
    scrollview:jumpToPercentVertical(0)

    if richLabel:getRealHeight() > contentSize.height then
        scrollview:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0,0))
    else
        local change_size = contentSize.height-richLabel:getRealHeight()
        scrollview:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0,change_size))
        scrollview:setBounceEnabled(false)
    end
    var.talkPanel:getWidgetByName("Button_buy"):hide()
end

function PanelNpcTalk.showEnterListTalk()
    var.talkPanel:hide()
    local talk_str = string.sub(NetClient.m_strNpcTalkMsg, 2, string.len(NetClient.m_strNpcTalkMsg)-1)
    local talkobj = util.decode(talk_str)
    var.widget:getWidgetByName("Label_t"):setString(NetClient.m_nNpcName)
    local thiswidget = var.widget:getWidgetByName("list_talk_bg")

    local scrollview = thiswidget:getWidgetByName("detail_scroll")
    scrollview:show():setTouchEnabled(true)
    local innerSize = scrollview:getInnerContainerSize()
    local contentSize = scrollview:getContentSize()

    local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
    util.setRichLabel(richLabel,talkobj.detail,"panel_npctalk",24,Const.COLOR_YELLOW_1_OX)
    richLabel:setVisible(true)
    richWidget:setContentSize(cc.p(contentSize.width,richLabel:getRealHeight()))
    scrollview:addChild(richWidget,10)
    scrollview:jumpToPercentVertical(0)

    if richLabel:getRealHeight() > contentSize.height then
        scrollview:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0,0))
    else
        local change_size = contentSize.height-richLabel:getRealHeight()
        scrollview:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0,change_size))
        scrollview:setBounceEnabled(false)
    end

    local listview = thiswidget:getWidgetByName("ListView_list")
    listview:removeAllItems()
    local listwidth = listview:getContentSize().width
    local cellHeight = 56
    for _, info in ipairs(talkobj.enterlist) do
        local rowWidget = ccui.Layout:create()
        rowWidget:setContentSize(listwidth,cellHeight)
        rowWidget:setTouchEnabled(true):addClickEventListener(function(pSender)
            if info.minVlv and game.getVipLevel() < info.minVlv then
                NetClient:alertLocalMsg("您的VIP等级不足","alert")
                return
            end
            if info.maxVlv and game.getVipLevel() > info.maxVlv then
                NetClient:alertLocalMsg("VIP等级不满足","alert")
                return
            end
            NetClient:PushLuaTable("chuansong",util.encode({actionid = info.linkstr}))
            NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_npctalk"})
        end)
        local richLabel,richWidget = util.newRichLabel(cc.size(listwidth,0))
        util.setRichLabel(richLabel,info.text,"",24,Const.COLOR_GREEN_1_OX)
        richLabel:setVisible(true)
        richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
        richWidget:align(display.LEFT_CENTER, 0, cellHeight/2)
        rowWidget:addChild(richWidget)
        listview:pushBackCustomItem(rowWidget)
    end
    thiswidget:show()
end

function PanelNpcTalk.showActNpcTalk()
    local talk_str = string.sub(NetClient.m_strNpcTalkMsg, 2, string.len(NetClient.m_strNpcTalkMsg)-1)
    local talkobj = util.decode(talk_str)

    if talkobj.enterlist then
        PanelNpcTalk.showEnterListTalk()
        return
    end

    var.widget:getWidgetByName("Label_t"):setString("活动")
    var.talkPanel:getWidgetByName("npcTalk_scroll"):hide()
    var.talkPanel:getWidgetByName("Text_npc_name"):setString(NetClient.m_nNpcName)
    var.talkPanel:getWidgetByName("Text_intro"):setString("    "..talkobj.intro)

    local scrollview = var.talkPanel:getWidgetByName("detail_scroll")
    scrollview:show():setTouchEnabled(true)
    local innerSize = scrollview:getInnerContainerSize()
    local contentSize = scrollview:getContentSize()

    local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
    util.setRichLabel(richLabel,talkobj.detail,"panel_npctalk",24,Const.COLOR_YELLOW_2_OX)
    richLabel:setVisible(true)
    richWidget:setContentSize(cc.p(contentSize.width,richLabel:getRealHeight()))
    scrollview:addChild(richWidget,10)
    scrollview:jumpToPercentVertical(0)

    if richLabel:getRealHeight() > contentSize.height then
        scrollview:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0,0))
    else
        local change_size = contentSize.height-richLabel:getRealHeight()
        scrollview:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(0,change_size))
        scrollview:setBounceEnabled(false)
    end

    local buybtn = var.talkPanel:getWidgetByName("Button_buy"):hide()
    local gobtn = var.talkPanel:getWidgetByName("Button_go"):hide()
    local awardbtn = var.talkPanel:getWidgetByName("Button_award"):hide()
    local cx = var.talkPanel:getContentSize().width/2
    if talkobj.draw_cmd then
        buybtn:hide()
        gobtn:show()
        awardbtn:show()
        awardbtn:align(display.RIGHT_CENTER, cx-20,awardbtn:getPositionY())
        gobtn:align(display.LEFT_CENTER, cx+20,gobtn:getPositionY())
        awardbtn:addClickEventListener(function (pSender)
            if NetClient.m_nTalkType == "npc" then
                NetClient:NpcTalk(NetClient.m_nNpcTalkId,string.split(talkobj.draw_cmd,"_")[2])
            elseif NetClient.m_nTalkType == "player" then
                NetClient:PushLuaTable("chuansong",util.encode({actionid = "playertalk", cmd=string.split(talkobj.draw_cmd,"_")[2]}))
            end
        end)
    elseif talkobj.buyitem then
        awardbtn:hide()
        gobtn:show()
        buybtn:show()
        buybtn:align(display.RIGHT_CENTER, cx-20,awardbtn:getPositionY())
        gobtn:align(display.LEFT_CENTER, cx+20,gobtn:getPositionY())
        buybtn:setTitleText(talkobj.buyitem.text)
        buybtn.quickbuytype=talkobj.buyitem.buyindex
        buybtn:addClickEventListener(function (pSender)
            if pSender.quickbuytype then
                game.queryQuickBuyInfo(pSender.quickbuytype)
            end
        end)
    else
        buybtn:hide()
        awardbtn:hide()
        gobtn:show()
        gobtn:align(display.CENTER, cx,gobtn:getPositionY())
    end

    if talkobj.requesttxt then
        gobtn:setTitleText(talkobj.requesttxt)
    end

    local enter_flag = true
    if talkobj.enter_flag then
        enter_flag = (talkobj.enter_flag == 1)
    end
    gobtn:setVisible(enter_flag)
    gobtn:addClickEventListener(function (pSender)
        if NetClient.m_nTalkType == "npc" then
            NetClient:NpcTalk(NetClient.m_nNpcTalkId,string.split(talkobj.requestcmd,"_")[2])
        elseif NetClient.m_nTalkType == "player" then
            NetClient:PushLuaTable("chuansong",util.encode({actionid = talkobj.requestcmd}))
        end

        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_npctalk"})
    end)

    if talkobj.item or talkobj.itemtip  then
        var.talkPanel:getWidgetByName("Panel_item"):show()
        if talkobj.item then
            UIItem.getSimpleItem({
                parent = var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("award_1"),
                typeId = talkobj.item.typeid,
            })
            local itemdef = NetClient:getItemDefByID(talkobj.item.typeid)
            if itemdef then
                local parent = var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("Text_costname"):show()
                coststr = "消耗"..game.make_str_with_color( Const.COLOR_GREEN_1_STR,itemdef.mName )..":"
                local havenum = NetClient:getBagItemNumberById(talkobj.item.typeid)
                if havenum >= talkobj.item.num then
                    coststr=coststr..game.make_str_with_color( Const.COLOR_GREEN_1_STR,havenum )
                else
                    coststr=coststr..game.make_str_with_color( Const.COLOR_RED_1_STR,havenum )
                end
                coststr=coststr..game.make_str_with_color( Const.COLOR_GREEN_1_STR,"/"..talkobj.item.num )
                local contentSize = parent:getContentSize()
                local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
                util.setRichLabel(richLabel,coststr,"",24,Const.COLOR_YELLOW_1_OX)
                richLabel:setVisible(true)
                richWidget:setContentSize(cc.size(richLabel:getRealWidth(),richLabel:getRealHeight()))
                richWidget:setPositionX(contentSize.width/2-richLabel:getRealWidth()/2)
                richWidget:addTo(parent)
            else
                var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("Text_costname"):hide()
            end
        else
            var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("award_1"):hide()
            var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("Text_costname"):hide()
        end
        if talkobj.itemtip then
            var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("Text_tips"):setString(talkobj.itemtip):show()
        else
            var.talkPanel:getWidgetByName("Panel_item"):getWidgetByName("Text_tips"):hide()
        end
    else
        var.talkPanel:getWidgetByName("Panel_item"):hide()
    end

    --
    if talkobj.kingtro then
        var.talkPanel:getWidgetByName("Text_kingintro"):show()
        scrollview:setPositionY(30)
        local parent = var.talkPanel:getWidgetByName("Text_kingintro")
        local contentSize = parent:getContentSize()
        local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
        util.setRichLabel(richLabel,talkobj.kingtro,"",24,Const.COLOR_YELLOW_1_OX)
        richLabel:setVisible(true)
        richWidget:setContentSize(cc.size(contentSize.width,richLabel:getRealHeight()))
        richWidget:addTo(parent)
        gobtn:setTitleText("开始膜拜")
    else
        var.talkPanel:getWidgetByName("Text_kingintro"):hide()
    end

    if talkobj.needvcoin then
        var.talkPanel:getWidgetByName("Text_cost_vcoin"):show()
        var.talkPanel:getWidgetByName("Text_cost_vcoin"):getWidgetByName("Text_value"):setString(talkobj.needvcoin)
    else
        var.talkPanel:getWidgetByName("Text_cost_vcoin"):hide()
    end
end

function PanelNpcTalk.showContent()
    local len = string.len(NetClient.m_strNpcTalkMsg)
    if string.sub(NetClient.m_strNpcTalkMsg, 1, 1) == "@" and string.sub(NetClient.m_strNpcTalkMsg,len) == "@" then
        PanelNpcTalk.showActNpcTalk()
    elseif string.find(NetClient.m_strNpcTalkMsg,"m_movenpc") then
        PanelNpcTalk.showMoveNpcTalk()
    else
        PanelNpcTalk.showTalk()
    end

end

function PanelNpcTalk.onPanelClose()
    UIButtonGuide.setGuideEnd(var.guildtype)
end

return PanelNpcTalk