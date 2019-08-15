local UIButtonGuide={}

UIButtonGuide.UI_TYPE_TOP = 1
UIButtonGuide.UI_TYPE_BOTTOM = 2
UIButtonGuide.UI_TYPE_LEFT = 3
UIButtonGuide.UI_TYPE_RIGHT = 4

UIButtonGuide.GUILDTYPE = {
    SKILL = 1001,
    ZHANSHEN = 1002,
    NEIGONG = 1003,
    SHENLU = 1004,
    CHENGJIU = 1005,
    YUANSHEN = 1006, -- 元神
    RING = 1007, --特戒
    WING = 1008, --翅膀
    QIANGHUA = 1009, -- 强化
    SHENQI = 1010,--神器
    RE_EQUIP = 1011,--装备回收
    RICHANGTASK = 1501, --日常任务
    EXPFUBENTASK = 1502, -- 副本使者 经验副本
    CARRYSHOP = 1503, -- 随身商店
}

-- 新功能开启对一个的GUILDTYPE
--NEW_SYSTEM_TO_GUILD = {
--    [GuideDef.FUNCID_ZHANSHEN] = UIButtonGuide.GUILDTYPE.ZHANSHEN,
--    [GuideDef.FUNCID_SHENLU] = UIButtonGuide.GUILDTYPE.SHENLU,
--    [GuideDef.FUNCID_CHENGJIU] = UIButtonGuide.GUILDTYPE.CHENGJIU,
--    [GuideDef.FUNCID_YUANSHEN] = UIButtonGuide.GUILDTYPE.YUANSHEN,
--    [GuideDef.FUNCID_RING] = UIButtonGuide.GUILDTYPE.RING,
--    [GuideDef.FUNCID_WING] = UIButtonGuide.GUILDTYPE.WING,
--}

UIButtonGuide.mGuildStatus = {}


function UIButtonGuide.handleLevelChange(level)
    local guildType
    for k, v in pairs(ButtonGuildData) do
        if v.mLevel == level then
            guildType = k
            break
        end
    end
    if not guildType then return end
    UIButtonGuide.mGuildStatus[guildType] = 1

    if guildType == UIButtonGuide.GUILDTYPE.RE_EQUIP then
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_bag",pdata = {tag = 2}})
    end

--    分发事件
    NetClient:dispatchEvent({name = Notify.EVENT_BUTTON_GUILD_SHOW, guildType = guildType})
end

-- 有新功能开启
function UIButtonGuide.handleOpenNewFunc(fid)
--    print("====>>>有新功能开启",fid)
--    local gtype = NEW_SYSTEM_TO_GUILD[fid]
--    if not gtype then return end
--    UIButtonGuide.mGuildStatus[gtype] = 1
--    UIButtonGuide.handleButtonGuildChange(gtype)
end

function UIButtonGuide.handleButtonGuideClicked(pSender,guildtypes)
    UIButtonGuide.clearGuideTip(pSender)
    if guildtypes and #guildtypes > 0 then
        for _, v in ipairs(guildtypes) do
            if UIButtonGuide.mGuildStatus[v] and UIButtonGuide.mGuildStatus[v] == 1 then
                UIButtonGuide.setGuideEnd(v)
                break
            end
        end
    end
end

function UIButtonGuide.clearAll()
    UIButtonGuide.mGuildStatus = {}
end

function UIButtonGuide.isShowRichangTaskGuide()
    if game.getRoleLevel() == 52 then
        UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.RICHANGTASK] = 1
    else
        UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.RICHANGTASK] = 0
    end

    return UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.RICHANGTASK)
end

function UIButtonGuide.setFubenGuide()
    if not UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.EXPFUBENTASK] or UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.EXPFUBENTASK] == 0 then
        UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.EXPFUBENTASK] = 1
    end
end

function UIButtonGuide.setCarryShopGuide()
    if not UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.CARRYSHOP] or UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.CARRYSHOP] == 0 then
        UIButtonGuide.mGuildStatus[UIButtonGuide.GUILDTYPE.CARRYSHOP] = 1
    end
end

function UIButtonGuide.isShowGuide(type)
    local status = UIButtonGuide.mGuildStatus[type] or 0
    return status == 1
end

-- 面板关闭时调用
function UIButtonGuide.setGuideEnd(type)
    if not type then return end
    if UIButtonGuide.mGuildStatus[type] then
        UIButtonGuide.mGuildStatus[type] = 99
    end
end

function UIButtonGuide.addGuideTip(psender,tipstr,uitype)
    if not psender then return end
    if psender:getChildByName("buttonguild") then
        return
    end
    local uitype = uitype or UIButtonGuide.UI_TYPE_TOP
    local rootWidget
    local moveBy
    local parentSize = psender:getContentSize()
    if uitype==UIButtonGuide.UI_TYPE_LEFT then
        rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Guide_Left.csb")
        rootWidget:align(display.RIGHT_CENTER, 0, parentSize.height/2)
        moveBy = cc.MoveBy:create(1,cc.p(-10, 0))
    elseif uitype==UIButtonGuide.UI_TYPE_RIGHT then
        rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Guide_Right.csb")
        rootWidget:align(display.LEFT_CENTER, parentSize.width, parentSize.height/2)
        moveBy = cc.MoveBy:create(1,cc.p(10, 0))
    elseif uitype==UIButtonGuide.UI_TYPE_BOTTOM then
        rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Guide_Bottom.csb")
        rootWidget:align(display.CENTER_TOP, parentSize.width/2, 0)
        moveBy = cc.MoveBy:create(1,cc.p(0, -10))
    else
        rootWidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Guide_Top.csb")
        rootWidget:align(display.CENTER_BOTTOM, parentSize.width/2, parentSize.height)
        moveBy = cc.MoveBy:create(1,cc.p(0, 10))
    end
    rootWidget:getChildByName("Panel_guild"):setTouchEnabled(true)
    rootWidget:setName("buttonguild")
    rootWidget:getChildByName("Panel_guild"):getWidgetByName("Label_tips"):setString(tipstr or "点击此处")
    rootWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(moveBy,cc.DelayTime:create(0.5),moveBy:reverse())))
    psender:addChild(rootWidget)
end

function UIButtonGuide.clearGuideTip(psender)
    if not psender then return end
    if not psender:getChildByName("buttonguild") then
        return
    end
    psender:removeChildByName("buttonguild")
end

function UIButtonGuide.getGuideTips(type)
    local desc = ButtonGuildData[type]
    if not desc then return "点击此按钮" end
    return desc.mTips
end

function UIButtonGuide.getGuideStepTips(type, step)
    local desc = ButtonGuildData[type]
    if not desc then return "点击此按钮" end
    if not step then step = 1 end
    if not desc.mStepTips[step] then return "点击此按钮" end
    return desc.mStepTips[step]
end

return UIButtonGuide