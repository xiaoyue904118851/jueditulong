--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/20 14:01
-- To change this template use File | Settings | File Templates.
--

local RoleSkillView = {}
local var = {}

function RoleSkillView.initView(params)
    local params = params or {}
    var = {}
    var.firstSelectIdx = nil
    var.selectInfo = nil
    var.skillListData = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_Skill.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_skillup")
    RoleSkillView.initWidget()
    RoleSkillView.addBtnClickedEvent()
    RoleSkillView.resetRightInfo()
    RoleSkillView.addSkillList()
    RoleSkillView.registeEvent()
    return widget
end

function RoleSkillView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_LEVEL_CHANGE, RoleSkillView.handLevelChange)
    :addEventListener(Notify.EVENT_GAME_MONEY_CHANGE, RoleSkillView.handleMoneyChange)
    :addEventListener(Notify.EVENT_ITEM_CHANGE, RoleSkillView.handItemChange)
    :addEventListener(Notify.EVENT_SKILL_CHANGE, RoleSkillView.handleSkillLevelChange)
    :addEventListener(Notify.EVENT_SKILL_LEVEL_CHANGE, RoleSkillView.handleSkillLevelChange)
end

function RoleSkillView.initWidget()
    var.btnClone = var.widget:getWidgetByName("Button_skill_sel"):hide()
    var.listView = var.widget:getWidgetByName("ListView_left")

    var.curDescText = var.widget:getWidgetByName("Text_cur_desc")
    var.nextDescText = var.widget:getWidgetByName("Text_next_desc")

    var.needPanel = var.widget:getWidgetByName("needPanel")
    var.needMaxText = var.widget:getWidgetByName("Text_need_max")
    var.needLvText = var.widget:getWidgetByName("Text_needLv")
    var.needMoneyPanel = var.widget:getWidgetByName("Panel_need_money")
    var.preSkillText = var.widget:getWidgetByName("Text_pre_skill")
    var.needSkillItemText = var.widget:getWidgetByName("Text_skill_item")
end

function RoleSkillView.resetRightInfo()
    var.curDescText:hide()
    var.nextDescText:hide()

    var.needPanel:hide()
    var.needMaxText:hide()
    var.needLvText:hide()
    var.selectInfo = nil
end

function RoleSkillView.addBtnClickedEvent()
    var.widget:getWidgetByName("Button_setting")
    :addClickEventListener(function (pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_skill_setting"})
    end)

    var.upBtn = var.widget:getWidgetByName("Button_up")
    var.upBtn:addClickEventListener(function (pSender)
        if var.selectInfo then
            --UIButtonGuide.handleButtonGuideClicked(var.upBtn)
            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SKILL) then
                NetClient:dispatchEvent({name = Notify.EVENT_BUTTON_GUILD_SHOW, GuildType = UIButtonGuide.GUILDTYPE.SKILL})
                UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.SKILL})
            end 
            if var.selectInfo.state == SkillDef.SKILL_LEARN_STATE.CANUP then
                var.isDoingUp = true
                NetClient:PushLuaTable("skillup",util.encode({actionid = "startupgrade", params = {skillid = var.selectInfo.skillid, skillname = var.selectInfo.skillname}}))
            elseif var.selectInfo.state == SkillDef.SKILL_LEARN_STATE.CANLEARN then

                if not var.selectInfo.skillid or not var.selectInfo.position or not var.selectInfo.typeid then
                    printError("NetClient:learnSkill===", var.selectInfo.skillid, var.selectInfo.position, var.selectInfo.typeid)
                else
                    var.isDoingUp = true
                    NetClient:learnSkill(var.selectInfo.skillid, var.selectInfo.position, var.selectInfo.typeid)
                end
            else
--                print("var.selectInfo.state=====",var.selectInfo.state)
            end
        else
--            print("not var.selectInfo")
        end
    end)

end

function RoleSkillView.handItemChange(event)
    if var.isDoingUp then return end
    if not event then return end
    if not game.IsPosInBag(event.pos) then
        return
    end

    if not event.oldType and not event.newType then return end
    local items = var.gridView:getItems()
    for k,item in pairs(items) do
        local nodeItem = item:getWidgetByName("grid")
        local needinfo = nodeItem.needinfo
        if needinfo and needinfo.needitem and needinfo.neednum > 0 and (needinfo.needitem == event.oldType or needinfo.needitem == event.newType ) then
            RoleSkillView.updateSkillGridItem(item, k)
            if var.selectInfo and var.selectInfo.skillid == nodeItem.skilltype then
                var.selectInfo.state = nodeItem.state
                local haveNum = NetClient:getBagItemNumberById(needinfo.needitem)
                RoleSkillView.updateSelectedNeedItem(haveNum,needinfo.neednum)
                RoleSkillView.updateSelectedUpBtn(nodeItem.state)
            end
            break
        end
    end
end

function RoleSkillView.handleMoneyChange()
    local items = var.gridView:getItems()
    for k,item in pairs(items) do
        local nodeItem = item:getWidgetByName("grid")
        local needinfo = nodeItem.needinfo
        RoleSkillView.updateSkillGridItem(item,k)
        if not var.isDoingUp and var.selectInfo and var.selectInfo.skillid == nodeItem.skilltype and needinfo.bindgold and needinfo.bindgold > 0 then
            var.selectInfo.state = nodeItem.state
            RoleSkillView.updateSelectedNeedGold(needinfo.bindgold)
            RoleSkillView.updateSelectedUpBtn(nodeItem.state)
        end
    end
end

function RoleSkillView.handLevelChange()
    if var.isDoingUp then return end
    var.roleLV = game.getRoleLevel()
    var.roleZsLv = game.getZsLevel()
    local items = var.gridView:getItems()
    for k,item in pairs(items) do
        local nodeItem = item:getWidgetByName("grid")
        local needinfo = nodeItem.needinfo
        RoleSkillView.updateSkillGridItem(item, k)
        if var.selectInfo and var.selectInfo.skillid == nodeItem.skilltype and (needinfo.needlvzs or needinfo.needlv ) then
            var.selectInfo.state = nodeItem.state
            RoleSkillView.updateSelectedNeedLevel(needinfo.needlvzs, needinfo.needlv)
            RoleSkillView.updateSelectedUpBtn(nodeItem.state)
        end
    end
end

function RoleSkillView.handleSkillLevelChange(event)
    var.isDoingUp = false
    if not event or not event.skill_type then return end
    local change_skill = event.skill_type
    local items = var.gridView:getItems()
    for k,item in pairs(items) do
        local nodeItem = item:getWidgetByName("grid")
        if nodeItem.skilltype == change_skill then
            RoleSkillView.updateSkillGridItem(item,k)
            RoleSkillView.updateSkillGridLevel(nodeItem)
            if var.selectInfo and var.selectInfo.skillid == nodeItem.skilltype then
                RoleSkillView.onSelectedSkill(nodeItem)
            end
        else
            local needinfo = nodeItem.needinfo
            if needinfo and needinfo.needskill and  needinfo.needskilllv and needinfo.needskill == change_skill then
                RoleSkillView.updateSkillGridItem(item,k)
            end
        end
    end
end

function RoleSkillView.addSkillList()
    var.roleLV = game.getRoleLevel()
    var.roleZsLv = game.getZsLevel()
    var.listView:removeAllItems()
    var.skillListData = game.getMySkillList()
    var.gridView = UIGridView.new({
        list = var.listView,
        gridCount = #var.skillListData,
        cellSize = cc.size(var.listView:getContentSize().width,var.btnClone:getContentSize().height),
        columns = 3,
        async = false,
        initGridListener = RoleSkillView.addSkillGridItem,
    })
    RoleSkillView.onFinishList()
end

function  RoleSkillView.onFinishList()
    local wd
    if var.firstSelectIdx then
        wd = var.gridView:getItemByIdx(var.firstSelectIdx)
    else
        wd = var.gridView:getItemByIdx(1)
    end
    RoleSkillView.onSelectedSkill(wd:getWidgetByName("grid"))
end

function RoleSkillView.updateSkillGridLevel(nodeItem)
    local skillid = nodeItem.skilltype
    if NetClient.m_netSkill[skillid] then
        nodeItem:getWidgetByName("Image_lock"):hide()
        nodeItem:getWidgetByName("Image_lv_bg"):show():getWidgetByName("lv"):setString(NetClient.m_netSkill[skillid].mLevel)
    else
        nodeItem:getWidgetByName("Image_lock"):show()
        nodeItem:getWidgetByName("Image_lv_bg"):hide()
    end
end

function RoleSkillView.updateSkillGridItem(gridWidget, k)
    local nodeItem = gridWidget:getWidgetByName("grid")
    local skillid = nodeItem.skilltype
    local state,needinfo = game.checkUp(skillid,var.roleLV,var.roleZsLv,NetClient.mCharacter.mGameMoney)
    nodeItem.needinfo = needinfo
    local oldstate = nodeItem.state
    if oldstate == state then
        return
    end
    print("RoleSkillView.updateSkillGridItem",k)
    nodeItem.state = state
    local upImg = nodeItem:getWidgetByName("Image_up")
    if state == SkillDef.SKILL_LEARN_STATE.CANUP or state == SkillDef.SKILL_LEARN_STATE.CANLEARN then
        upImg:show()
        upImg:ignoreContentAdaptWithSize(true)
        if state == SkillDef.SKILL_LEARN_STATE.CANUP and oldstate ~= SkillDef.SKILL_LEARN_STATE.CANUP then
            gameEffect.playEffectByType(gameEffect.EFFECT_JIANTOU)
            :setPosition(cc.p(0,0)):addTo(upImg)
        elseif state == SkillDef.SKILL_LEARN_STATE.CANLEARN and oldstate ~= SkillDef.SKILL_LEARN_STATE.CANLEARN then
            gameEffect.playEffectByType(gameEffect.EFFECT_SHIZI)
            :setPosition(cc.p(0,0)):addTo(upImg)
        end
        if var.firstSelectIdx == nil then var.firstSelectIdx = k end
    else
        upImg:hide()
    end
end

function RoleSkillView.addSkillGridItem(gridWidget, k)
    local skillid = var.skillListData[k]
    local skillDef = NetClient:getSkillDefByID(skillid)
    if not skillDef then
        return
    end

    local nodeItem = var.btnClone:clone():show()
    :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)
    nodeItem:setName("grid")
    nodeItem:getWidgetByName("Image_high"):hide()
    nodeItem.index = k
    nodeItem.skillname = skillDef.mName
    nodeItem.skilltype = skillid

    local state,needinfo = game.checkUp(skillid,var.roleLV,var.roleZsLv,NetClient.mCharacter.mGameMoney)
    nodeItem.state = state
    nodeItem.needinfo = needinfo
    local upImg = nodeItem:getWidgetByName("Image_up")
    if state == SkillDef.SKILL_LEARN_STATE.CANUP or state == SkillDef.SKILL_LEARN_STATE.CANLEARN then
        upImg:show()
        upImg:ignoreContentAdaptWithSize(true)
        if state == SkillDef.SKILL_LEARN_STATE.CANUP then
            gameEffect.playEffectByType(gameEffect.EFFECT_JIANTOU)
            :setPosition(cc.p(0,0)):addTo(upImg)
        elseif state == SkillDef.SKILL_LEARN_STATE.CANLEARN then
            gameEffect.playEffectByType(gameEffect.EFFECT_SHIZI)
            :setPosition(cc.p(0,0)):addTo(upImg)
        end
        if var.firstSelectIdx == nil then var.firstSelectIdx = k end
    else
        upImg:hide()
    end

    nodeItem:getWidgetByName("Text_type"):setString("["..Const.SKILL_TYPE_DESC[skillDef.mSkillType].."]")
    nodeItem:getWidgetByName("name"):setString(skillDef.mName)

    nodeItem:getWidgetByName("shortcut"):ignoreContentAdaptWithSize(true)
    nodeItem:getWidgetByName("shortcut"):loadTexture("skill"..skillid..".png",UI_TEX_TYPE_PLIST)

    RoleSkillView.updateSkillGridLevel(nodeItem)

    nodeItem:addClickEventListener(function (pSender)
        RoleSkillView.onSelectedSkill(pSender)
    end)
end

function RoleSkillView.onSelectedSkill(pSender)
    RoleSkillView.resetRightInfo()

    local items = var.gridView:getItems()
    for _,item in pairs(items) do
        item:getWidgetByName("Image_high"):hide()
    end
    if not pSender then return end
    pSender:getWidgetByName("Image_high"):show()
    local index = pSender.index
    if var.Selectindex then
        if var.Selectindex ~=  index then
            NetClient.SkillTouchType = true
        end
    end

    var.Selectindex = index
    local skillid = pSender.skilltype
    var.selectInfo = {pindex = pSender.index, skillid = skillid, skillname = pSender.skillname, state = pSender.state }


    local curLevel = 0
    if NetClient.m_netSkill[skillid] then
        curLevel = NetClient.m_netSkill[skillid].mLevel
    end

    -- 当前块
    var.curDescText:show()
    if curLevel == 0 then --or var.selectInfo.state == SkillDef.SKILL_LEARN_STATE.UNLEARN  then
        var.curDescText:removeAllChildren()
        var.curDescText:setString("未学习")
    else
        var.curDescText:removeAllChildren()
        var.curDescText:setString("")
        local msg = "策划还没有填写"
        if SkillDef.EFFECT_DESP_LIST[skillid] and SkillDef.EFFECT_DESP_LIST[skillid][curLevel] then
            msg = SkillDef.EFFECT_DESP_LIST[skillid][curLevel][1] or "策划没填写"
        end
        local bgsize = var.curDescText:getContentSize()
        local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
        richWidget.richLabel = richLabel
        richWidget:setTouchEnabled(false)
        util.setRichLabel(richLabel, msg, "", 24, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        richWidget:setAnchorPoint(cc.p(0,1))
        richWidget:setPosition(cc.p(0, var.curDescText:getContentSize().height))
        var.curDescText:addChild(richWidget)

    end

    -- 下一块
    var.nextDescText:show()
    if var.selectInfo.state == SkillDef.SKILL_LEARN_STATE.MAXLEVEL  then
        var.nextDescText:removeAllChildren()
        var.nextDescText:setString("当前已达最高级")
    else
        var.nextDescText:removeAllChildren()
        var.nextDescText:setString("")
        local msg = "策划还没有填写"
        if SkillDef.EFFECT_DESP_LIST[skillid] and SkillDef.EFFECT_DESP_LIST[skillid][curLevel+1] then
            msg = SkillDef.EFFECT_DESP_LIST[skillid][curLevel+1][1] or "策划没填写"
        end
        local bgsize = var.nextDescText:getContentSize()
        local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
        richWidget.richLabel = richLabel
        richWidget:setTouchEnabled(false)
        util.setRichLabel(richLabel, msg, "", 24, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        richWidget:setAnchorPoint(cc.p(0,1))
        richWidget:setPosition(cc.p(0, var.nextDescText:getContentSize().height))
        var.nextDescText:addChild(richWidget)
    end

    RoleSkillView.updateSelectNeedInfo(pSender)
    RoleSkillView.updateSelectedUpBtn(pSender.state)
end

function RoleSkillView.updateSelectNeedInfo(pSender)
    if not pSender then return end
    local skillid = pSender.skilltype
    local needinfo = pSender.needinfo
    local state = pSender.state
    -- 升级需求
    if state == SkillDef.SKILL_LEARN_STATE.UNABLE then
        var.needPanel:hide()
    elseif state == SkillDef.SKILL_LEARN_STATE.MAXLEVEL then
        var.needPanel:hide()
        var.needMaxText:show()
    elseif needinfo then
        var.needPanel:show()
        var.needMaxText:hide()

        if needinfo.needlvzs then
            var.needLvText:setString(needinfo.needlvzs.."转"):show()
        elseif needinfo.needlv then
            var.needLvText:setString("Lv."..needinfo.needlv):show()
        end
        RoleSkillView.updateSelectedNeedLevel(needinfo.needlvzs, needinfo.needlv)

        local py = 212
        if needinfo.bindgold and needinfo.bindgold > 0 then
            var.needMoneyPanel:show()
            var.needMoneyPanel:getWidgetByName("Text_need"):setString("/"..needinfo.bindgold)
            RoleSkillView.updateSelectedNeedGold(needinfo.bindgold)
            py = py - 36
        else
            var.needMoneyPanel:hide()
        end

        -- 道具技能书
        if needinfo.needitem and needinfo.needitemname and  needinfo.neednum then
            var.needSkillItemText:show()
            var.needSkillItemText:setString(needinfo.needitemname)
            local haveNum = NetClient:getBagItemNumberById(needinfo.needitem)
            var.needSkillItemText:getWidgetByName("Text_need"):setString("/"..needinfo.neednum)
            RoleSkillView.updateSelectedNeedItem(haveNum,needinfo.neednum)
            if haveNum >= needinfo.neednum then
                var.selectInfo.typeid = needinfo.needitem
                var.selectInfo.position = NetClient:getItemBagPosById(needinfo.needitem)
            end
            var.needSkillItemText:setPositionY(py)
            py = py - 36
        else
            var.needSkillItemText:hide()
        end

        if needinfo.needskill and  needinfo.needskilllv then
            local skillDef = NetClient:getSkillDefByID(needinfo.needskill)
            if skillDef then
                var.preSkillText:show()
                var.preSkillText:setString(skillDef.mName)
                local nowLevel = 0
                if NetClient.m_netSkill[needinfo.needskill] then
                    nowLevel = NetClient.m_netSkill[needinfo.needskill].mLevel
                end
                var.preSkillText:getWidgetByName("Text_need"):setString("/"..needinfo.needskilllv.."级")
                RoleSkillView.updateSelectedNeedSkill(nowLevel,needinfo.needskilllv)
                var.preSkillText:setPositionY(py)
                py = py - 36
            else
                var.preSkillText:hide()
            end
        else
            var.preSkillText:hide()
        end
    end
end

function RoleSkillView.updateSelectedNeedLevel(zslevel, lv)
    if zslevel then
        var.needLvText:setColor(var.roleZsLv>=zslevel and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
    elseif lv then
        var.needLvText:setColor(var.roleLV>=lv and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
    end

end

function RoleSkillView.updateSelectedNeedGold(needNum)
    local haveNumText = var.needMoneyPanel:getWidgetByName("Text_have")
    haveNumText:setString(NetClient.mCharacter.mGameMoney)
    haveNumText:setTextColor(NetClient.mCharacter.mGameMoney>=needNum and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
    var.needMoneyPanel:getWidgetByName("Text_need"):setPositionX(100+haveNumText:getContentSize().width)
end

function RoleSkillView.updateSelectedNeedSkill(curLevel,needLevel)
    local haveNumText = var.preSkillText:getWidgetByName("Text_have")
    haveNumText:setString(curLevel.."级")
    haveNumText:setTextColor(curLevel>=needLevel and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
    var.preSkillText:getWidgetByName("Text_need"):setPositionX(100+haveNumText:getContentSize().width)
end

function RoleSkillView.updateSelectedNeedItem(haveNum,neednum)
    local haveNumText = var.needSkillItemText:getWidgetByName("Text_have")
    haveNumText:setString(haveNum)
    haveNumText:setTextColor(haveNum>=neednum and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
    var.needSkillItemText:getWidgetByName("Text_need"):setPositionX(100+haveNumText:getContentSize().width)
end

function RoleSkillView.updateSelectedUpBtn(state)
    if var.upBtn.state and var.upBtn.state == state then
        return
    end

    local canup = (state == SkillDef.SKILL_LEARN_STATE.CANUP or state == SkillDef.SKILL_LEARN_STATE.CANLEARN)
    var.upBtn:setTouchEnabled(canup)
    var.upBtn:setBright(canup)

    if state == SkillDef.SKILL_LEARN_STATE.CANLEARN or state == SkillDef.SKILL_LEARN_STATE.UNLEARN then
        var.upBtn:setTitleText("技能学习")
    else
        var.upBtn:setTitleText("技能升级")
    end

    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SKILL) then
        if not canup then
            UIButtonGuide.handleButtonGuideClicked(var.upBtn,{UIButtonGuide.GUILDTYPE.SKILL})
        end
    end

    if canup then
        if not var.upeffect then
            var.upBtn:runAction(cc.Sequence:create(
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    local eff = gameEffect.getBtnSelectEffect()
                    :setPosition(cc.p(var.upBtn:getContentSize().width/2,var.upBtn:getContentSize().height/2))
                    :addTo(var.upBtn)
                    eff:setName("upeffect")
                end))
            )
            var.upeffect = true
        end
        if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SKILL) then
            UIButtonGuide.addGuideTip(var.upBtn,UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.SKILL))
        end
    else
        if var.upeffect then
            var.upeffect = false
            var.upBtn:removeChildByName("upeffect")
        end
    end


    var.upBtn:setTitleColor(canup and Const.COLOR_YELLOW_2_C3B or Const.COLOR_GRAY_1_C3B)
end

return RoleSkillView