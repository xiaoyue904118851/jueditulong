local PanelZhanShen = {}
local var = {}
local zs_head_tab = {"zszs.png","fszs.png","dszs.png","hszs.png"}
local ZS_TIPS = "出战次数：\n战神每日免费出战次数为5次，激活幻兽可额外增加5次\n获得次数：\n出战次数为0时，可购买次数或等待10分钟后自动恢复1次次数\n切换出战：\n切换战神出战时，需要消耗出战次数"

function PanelZhanShen.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelZhanShen/PanelZhanShen.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_zhanshen")
    var.selectTab = 1
    var.curFighterIndex = 1

    for i=1,4 do
        local sprite = ccui.Scale9Sprite:create()
        sprite:initWithSpriteFrame(display.newSpriteFrame(zs_head_tab[i]))
        local parent
        if i == 4 then
            parent = var.widget:getWidgetByName("img_huanshou")
        else
            parent = var.widget:getWidgetByName("img_zs_bg_"..i)
            parent:getWidgetByName("img_condition"):setZOrder(10)
        end
        sprite:setState(1)
        sprite:setName("img_head")
        sprite:setPosition(cc.p(77.5,75))
        parent:addChild(sprite)
    end

    var.widget:getWidgetByName("panel_hs_tips"):hide():addClickEventListener(function (pSender)
        pSender:hide()
    end)
    var.widget:getWidgetByName("panel_skill_bg"):hide():addClickEventListener(function (pSender)
        pSender:hide()
    end)
    var.widget:getWidgetByName("Button_close_zs"):addClickEventListener(function (pSender)
        var.widget:getWidgetByName("skill_icon_2"):getVirtualRenderer():setState(0)
        var.widget:getWidgetByName("skill_icon_3"):getVirtualRenderer():setState(0)
        for i=1,3 do
            var.widget:getWidgetByName("img_zs_bg_"..i):getChildByName("img_head"):setState(0)
        end
        var.widget:getWidgetByName("img_huanshou"):getChildByName("img_head"):setState(0)
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_zhanshen"})
    end)
    var.widget:getWidgetByName("btn_huanshou"):addClickEventListener(function (pSender)
        var.widget:getWidgetByName("panel_hs_tips"):show()
        if var.mFightState then
            local hs_state = var.mFightState.magic.yes
            if hs_state == 1 then
                var.widget:getWidgetByName("label_already_buy"):show()
                var.widget:getWidgetByName("level_hs_need"):hide()
                var.widget:getWidgetByName("Button_buy_hs"):hide()
            else
                var.widget:getWidgetByName("label_already_buy"):hide()
                var.widget:getWidgetByName("level_hs_need"):show()
                var.widget:getWidgetByName("Button_buy_hs"):show()
            end
        end
    end)
    for i=1,3 do
        var.widget:getWidgetByName("img_zs_skill_"..i):addClickEventListener(function (pSender)
            var.widget:getWidgetByName("panel_skill_bg"):show()
            if var.mFightBaseData then
                local skill_data = var.mFightBaseData[var.selectTab].skills
                if skill_data[i] then
                    local skill_desp = NetClient:getSkillDefByID(skill_data[i].skillid)
                    if skill_desp then
                        var.widget:getWidgetByName("skill_icon"):loadTexture("skill"..skill_data[i].skillid..".png",UI_TEX_TYPE_PLIST)
                        var.widget:getWidgetByName("tlsp_skill_level"):setString(skill_data[i].level.."级")
                        var.widget:getWidgetByName("tips_skill_condition"):hide()
                        var.widget:getWidgetByName("tips_skill_name"):setString(skill_desp.mName)
                        var.widget:getWidgetByName("tips_skill_desp"):setString(skill_desp.mDesp1)
                        if skill_data[i].openjie > 1 then
                            var.widget:getWidgetByName("tips_skill_condition"):show():setString("战神"..skill_data[i].openjie.."阶获得。")
                        end
                    end
                end
            end
        end)
    end
    var.widget:getWidgetByName("Button_buy_hs"):addClickEventListener(function (pSender)
        NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "active_magic"}))
    end)
    var.widget:getWidgetByName("check_show_hs"):addClickEventListener(function ( pSender )
        if pSender:isSelected() then
            NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "show_magic"}))
        else
            NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "hide_magic"}))
        end
    end)
    var.widget:getWidgetByName("Button_tips"):addClickEventListener(function(pSender)
        UIAnimation.oneTips({
            parent = pSender,
            msg = ZS_TIPS,
        })
    end)
    PanelZhanShen.registeEvent()
    PanelZhanShen.addMenuTabClickEvent()
    NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "queryfighterinfo"}))

    return var.widget
end

function PanelZhanShen.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    	:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelZhanShen.handlePanelData)
end

function PanelZhanShen.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local RadionButtonGroup = UIRadioButtonGroup.new()
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("btn_zs_1"), types={UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE1}}))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("btn_zs_2"), types={UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE2}}))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("btn_zs_3"), types={UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE3}}))
        -- :addButton(var.widget:getWidgetByName("btn_zs_2"))
        -- :addButton(var.widget:getWidgetByName("btn_zs_3"))
        :onButtonSelectChanged(function(event)
            PanelZhanShen.updatePanelByTag(event.selected)
        end)
    RadionButtonGroup:setButtonSelected(var.selectTab)
end

function PanelZhanShen.updatePanelByTag(tag)
    var.selectTab = tag
    if var.mFightBaseData then
        var.widget:getWidgetByName("img_zhanshen_bg"):loadTexture("uilayout/image/zhanshen/model_"..tag..".png",UI_TEX_TYPE_LOCAL)
        local skill_data = var.mFightBaseData[tag].skills
        for i=1,3 do
            print("skill"..skill_data[i].skillid..".png")
            var.widget:getWidgetByName("skill_icon_"..i):loadTexture("skill"..skill_data[i].skillid..".png",UI_TEX_TYPE_PLIST)
            var.widget:getWidgetByName("level_skill_"..i):setString(skill_data[i].level.."级")
        end
        var.widget:getWidgetByName("Button_levelup"):addClickEventListener(function ( pSender )
            NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "upgrade"}))
        end)
        UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_onekey"),types={UIRedPoint.REDTYPE.ZHANSHEN_ACTIVE4}})
        
        var.widget:getWidgetByName("Button_onekey"):addClickEventListener(function ( pSender )
            NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "upgrade_onekey"}))
        end)
        var.widget:getWidgetByName("Button_call"):addClickEventListener(function ( pSender )
            NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "callfighter",fid=var.selectTab}))
        end)
    end
    if var.selecteffect then
        var.selecteffect:removeFromParent()
        var.selecteffect = nil
    end
    var.selecteffect = gameEffect.getPlayEffect(gameEffect.EFFECT_ZHANSHENSELECT)
    var.selecteffect:setPosition(cc.p(var.widget:getWidgetByName("btn_zs_"..tag):getContentSize().width/2,var.widget:getWidgetByName("btn_zs_"..tag):getContentSize().height/2))
    var.selecteffect:addTo(var.widget:getWidgetByName("btn_zs_"..tag))
    PanelZhanShen.setButtonCallBack()
end

function PanelZhanShen.onPanelClose()  
    UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_close"),{UIButtonGuide.GUILDTYPE.ZHANSHEN})
end

function PanelZhanShen.setButtonCallBack()
    --UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_onekey"))
    UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_call"))
    local btn_call = var.widget:getWidgetByName("Button_call")
    if var.mFightState then
        local fdata = var.mFightState.fighters[var.selectTab]
        --UIRedPoint.removeUIPoint(btn_call)
        if fdata.active == 1 then
            if var.activeeffect then
                var.activeeffect:hide()
            end
            btn_call:loadTextures("zhaohui.png","zhaohui.png","",UI_TEX_TYPE_PLIST)
            btn_call:setBright(true)
            btn_call:setTouchEnabled(true)
            if var.mFightState.activecount > 0 then
                UIRedPoint.addUIPoint({parent=btn_call, callback=function ( pSender )
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否召回当前战神(重新召唤\n消耗一次召唤次数)？",
                    confirmTitle = "是", cancelTitle = "否",
                    confirmCallBack = function ()
                        NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "killfighter"}))
                    end
                }
                EventDispatcher:dispatchEvent(param)
                end})
            else
                btn_call:addClickEventListener(function(pSender)
                    local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否召回当前战神(重新召唤\n消耗一次召唤次数)？",
                    confirmTitle = "是", cancelTitle = "否",
                    confirmCallBack = function ()
                        NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "killfighter"}))
                    end
                    }
                    EventDispatcher:dispatchEvent(param)
                end)
            end
            if btn_call.point then
                btn_call.point:hide()
            end
            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.ZHANSHEN) and not var.showclosetips then
                var.showclosetips = true
                UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_close_zs"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.ZHANSHEN,3),UIButtonGuide.UI_TYPE_LEFT)
                var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
                    EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_zhanshen"})
                end)))
                UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_call"))
            end
            
            --[[
            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.ZHANSHEN) then
                UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_onekey"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.ZHANSHEN,2))
            end
            ]]
        else
            if fdata.enable == 1 then
                if var.activeeffect then
                    var.activeeffect:hide()
                end
                btn_call:loadTextures("chuzhan.png","chuzhan.png","",UI_TEX_TYPE_PLIST)
                btn_call:setBright(true)
                btn_call:setTouchEnabled(true)
                if var.mFightState.activecount > 0 then
                    UIRedPoint.addUIPoint({parent=btn_call, callback=function ( pSender )
                        if var.selectTab ~= var.curFighterIndex and var.curFighterIndex > 0 then
                            local param = {
                                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "当前已有战神出战，是否替换当前战\n神(消耗一次召唤次数)？",
                                confirmTitle = "是", cancelTitle = "否",
                                confirmCallBack = function ()
                                    NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "callfighter",fid=var.selectTab}))
                                end
                            }
                            EventDispatcher:dispatchEvent(param)
                        else
                            if var.mFightState.activecount > 0 then
                                NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "callfighter",fid=var.selectTab}))
                            else
                                if not var.mFightState then return end
                                local param = {
                                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否花费"..var.mFightState.needbindgold.."绑定金币购买一次？",
                                    confirmTitle = "是", cancelTitle = "否",
                                    confirmCallBack = function ()
                                        NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "buy_active_count"}))
                                    end
                                }
                                EventDispatcher:dispatchEvent(param)
                            end
                        end
                    end})
                else
                    btn_call:addClickEventListener(function ( pSender )
                        if var.selectTab ~= var.curFighterIndex and var.curFighterIndex > 0 then
                            local param = {
                                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "当前已有战神出战，是否替换当前战\n神(消耗一次召唤次数)？",
                                confirmTitle = "是", cancelTitle = "否",
                                confirmCallBack = function ()
                                    NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "callfighter",fid=var.selectTab}))
                                end
                            }
                            EventDispatcher:dispatchEvent(param)
                        else
                            if var.mFightState.activecount > 0 then
                                NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "callfighter",fid=var.selectTab}))
                            else
                                if not var.mFightState then return end
                                local param = {
                                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否花费"..var.mFightState.needbindgold.."绑定金币购买一次？",
                                    confirmTitle = "是", cancelTitle = "否",
                                    confirmCallBack = function ()
                                        NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "buy_active_count"}))
                                    end
                                }
                                EventDispatcher:dispatchEvent(param)
                            end
                        end
                    end)
                end
                if var.curFighterIndex == 0 then
                    if var.mFightState.activecount > 0 then
                        btn_call.point:show()
                    else
                        if btn_call.point then
                            btn_call.point:hide()
                        end
                    end
                else
                    btn_call.point:hide()
                end
                if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.ZHANSHEN) then
                    UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_call"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.ZHANSHEN,1))
                end
            else
                btn_call:loadTextures("jihuo.png","jihuo.png","jihuo_gray.png",UI_TEX_TYPE_PLIST)
                if fdata.can_active == 1 and game.getRoleLevel() >= game.getFuncOpenLevel(GuideDef.FUNCID_ZHANSHEN)  then
                    if not var.activeeffect then
                        var.activeeffect = gameEffect.getPlayEffect(gameEffect.EFFECT_ZHANSHENACTIVE)
                        var.activeeffect:setPosition(cc.p(var.widget:getWidgetByName("Button_call"):getContentSize().width/2,var.widget:getWidgetByName("Button_call"):getContentSize().height/2))
                        var.activeeffect:addTo(var.widget:getWidgetByName("Button_call"))
                    else
                        var.activeeffect:show()
                    end
                else
                    if var.activeeffect then var.activeeffect:hide() end
                    btn_call:setBright(false)
                    btn_call:setTouchEnabled(false)
                end

                UIRedPoint.addUIPoint({parent=btn_call, callback=function ( pSender )
                    NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "active_fighter",fid=var.selectTab}))
                end})
                btn_call.point:hide()
            end
        end
    end
end

function PanelZhanShen.handlePanelData(event)
    if event and event.type == "newfighter_data" then
        local fight_data = json.decode(event.data)
        -- print(event.data)
        if not fight_data then return end
        if fight_data.name == "fight_state" then
            var.mFightState = fight_data.s
            var.curFighterIndex = 0
            for i=1,#var.mFightState.fighters do
                local fdata = var.mFightState.fighters[i]
                local zs_panel = var.widget:getWidgetByName("img_zs_bg_"..i)
                if fdata.enable == 1 then
                    zs_panel:getChildByName("img_head"):setState(0)
                    zs_panel:getWidgetByName("img_condition"):hide()
                    zs_panel:getWidgetByName("label_zs_name"):setString(var.mFightBaseData[i].name)
                else
                    zs_panel:getChildByName("img_head"):setState(1)
                    zs_panel:getWidgetByName("img_condition"):show()
                    zs_panel:getWidgetByName("label_condition"):setString("V"..var.mFightBaseData[i].cond.needvip.."马上激活")
                    zs_panel:getWidgetByName("label_zs_name"):setString("第"..var.mFightBaseData[i].cond.loginday.."天可激活")
                end
                if fdata.active == 1 then
                    var.curFighterIndex = i
                    zs_panel:getWidgetByName("img_fight"):show()
                else
                    zs_panel:getWidgetByName("img_fight"):hide()
                end
                PanelZhanShen.setButtonCallBack()
            end
            local hs_state = var.mFightState.magic.yes
            local hs_show = var.mFightState.magic.show
            if hs_state == 0 then
                var.widget:getWidgetByName("img_huanshou"):getChildByName("img_head"):setState(1)
                var.widget:getWidgetByName("img_show_hs"):hide()
            else
                var.widget:getWidgetByName("check_show_hs"):setSelected(hs_show == 1 and true or false)
                var.widget:getWidgetByName("img_huanshou"):getChildByName("img_head"):setState(0)
                var.widget:getWidgetByName("img_show_hs"):show()
            end
            if var.mFightState.activecount > 0 then
                var.widget:getWidgetByName("label_left_time"):show():setPositionX(713.5):setString(var.mFightState.activecount)
                var.widget:getWidgetByName("label_time_info"):show():setPositionX(703.5):setString("今日剩余出战次数：")
            else
                var.widget:getWidgetByName("label_left_time"):hide()
                var.widget:getWidgetByName("label_time_info"):hide()
                NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "active_count_cdtime"}))
            end
        elseif fight_data.name == "queryfighterinfo" then
            var.mFightBaseData = fight_data.raw_json_text
            PanelZhanShen.updatePanelByTag(var.selectTab)
        elseif fight_data.name == "fighterfp" then
            var.widget:getWidgetByName("label_damage"):setString(fight_data.raw_json_text.damage)
            var.widget:getWidgetByName("atlas_fight"):setString(fight_data.raw_json_text.fp)
            local fdef = NetClient:getFighterDefByID(fight_data.raw_json_text.defid)
            if fdef then
                var.widget:getWidgetByName("label_zs_level"):setString(fdef.mName)
                if fdef.mJie >=3 and fdef.mJie < 6 then
                    var.widget:getWidgetByName("skill_icon_2"):getVirtualRenderer():setState(0)
                    var.widget:getWidgetByName("skill_icon_3"):getVirtualRenderer():setState(1)
                elseif fdef.mJie >= 6 then
                    var.widget:getWidgetByName("skill_icon_2"):getVirtualRenderer():setState(0)
                    var.widget:getWidgetByName("skill_icon_3"):getVirtualRenderer():setState(0)
                else
                    var.widget:getWidgetByName("skill_icon_2"):getVirtualRenderer():setState(1)
                    var.widget:getWidgetByName("skill_icon_3"):getVirtualRenderer():setState(1)
                end
                if MainRole.mJob == Const.JOB_ZS then
                    var.widget:getWidgetByName("wuli_info"):setString("物理攻击：")
                    var.widget:getWidgetByName("label_wuli"):setString(fdef.mDC.."-"..fdef.mDCMax)
                    var.widget:getWidgetByName("label_hp"):setString(fdef.mWarriorAddHp)
                elseif MainRole.mJob == Const.JOB_FS then
                    var.widget:getWidgetByName("wuli_info"):setString("魔法攻击：")
                    var.widget:getWidgetByName("label_wuli"):setString(fdef.mMC.."-"..fdef.mMCMax)
                    var.widget:getWidgetByName("label_hp"):setString(fdef.mWizardAddHp)
                else
                    var.widget:getWidgetByName("wuli_info"):setString("道术攻击：")
                    var.widget:getWidgetByName("label_wuli"):setString(fdef.mSC.."-"..fdef.mSCMax)
                    var.widget:getWidgetByName("label_hp"):setString(fdef.mTaoistAddHp)
                end
                var.widget:getWidgetByName("label_wufang"):setString(fdef.mAC.."-"..fdef.mACMax)
                var.widget:getWidgetByName("label_mofang"):setString(fdef.mMAC.."-"..fdef.mMACMax)
                var.widget:getWidgetByName("label_mp"):setString(fdef.mMaxMp)
                var.widget:getWidgetByName("label_renxing"):setString(string.format("%0.2f",fdef.mToughness/100).."%")
                var.widget:getWidgetByName("label_baoshang"):setString(fdef.mBaojiPres)
                var.widget:getWidgetByName("label_baoji"):setString(string.format("%0.2f",fdef.mBaojiProb/100).."%")
                var.widget:getWidgetByName("label_cost"):setString(fdef.mNeedBindGold)
                if var.mFightState then
                    var.widget:getWidgetByName("label_jie_per"):setString(var.mFightState.jielv.lv.."/"..fdef.mMaxLevel)
                    var.widget:getWidgetByName("load_level"):setPercent(var.mFightState.jielv.lv/fdef.mMaxLevel*100)
                end
                local MainAvatar = CCGhostManager:getMainAvatar()
                if MainAvatar then
                    local selfLevel = game.getRoleLevel()
                    if selfLevel < fdef.mNeedLv or fight_data.raw_json_text.defid >= 1148 then
                        var.widget:getWidgetByName("Button_levelup"):hide()
                        var.widget:getWidgetByName("Button_onekey"):hide()
                        if fight_data.raw_json_text.defid >= 1148 then
                            var.widget:getWidgetByName("level_need_info"):hide()
                            var.widget:getWidgetByName("label_need_level"):show():setString("已满级")
                        else
                            var.widget:getWidgetByName("label_need_level"):show():setString("等级达到"..fdef.mNeedLv.."级可升级")
                        end
                    else
                        var.widget:getWidgetByName("Button_levelup"):show()
                        var.widget:getWidgetByName("Button_onekey"):show()
                        var.widget:getWidgetByName("label_need_level"):hide()
                    end
                end
            end
        elseif fight_data.name == "active_count_cdtime" then
            var.leftCountTime = fight_data.raw_json_text.cd
            local function refreshTime( ... )
                var.leftCountTime = var.leftCountTime - 1
                if var.leftCountTime <= 0 then
                    if var.coutDown then
                        Scheduler.unscheduleGlobal(var.coutDown)
                        var.coutDown = nil
                    end
                    NetClient:PushLuaTable("newgui.newfighter.OnFighterLua",util.encode({actionid = "queryfighterinfo"}))
                    return
                end
                var.widget:getWidgetByName("label_left_time"):setString(game.convertSecondsToStr( var.leftCountTime ))
            end
            if not var.coutDown then
                var.coutDown = Scheduler.scheduleGlobal(refreshTime, 1)
            end
            var.widget:getWidgetByName("label_left_time"):show():setPositionX(660):setString(game.convertSecondsToStr( var.leftCountTime ))
            var.widget:getWidgetByName("label_time_info"):show():setPositionX(650):setString("增加一次：")
        elseif fight_data.name == "active_magic" then
            var.widget:getWidgetByName("panel_hs_tips"):hide()
        end
    end
end

function PanelZhanShen.onPanelClose()
    UIButtonGuide.setGuideEnd(UIButtonGuide.GUILDTYPE.ZHANSHEN)
    if var.coutDown then
        Scheduler.unscheduleGlobal(var.coutDown)
        var.coutDown = nil
    end
end

return PanelZhanShen