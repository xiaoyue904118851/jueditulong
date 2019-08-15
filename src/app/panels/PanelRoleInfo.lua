--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 15:32
-- To change this template use File | Settings | File Templates.
-- PanelRoleInfo

local PanelRoleInfo = {}
local var = {}

local ROLEINFO_TAG = {
    SHUXING = 1,
    SKILL = 2,
    NEIGONG = 3,
    YUANSHEN = 4,
    ZHUANSHENG = 5
}


local ROLEINFO_TAG_NAME = {
    [ROLEINFO_TAG.SHUXING] = "角色",
    [ROLEINFO_TAG.SKILL] = "技能",
    [ROLEINFO_TAG.NEIGONG] = "内功",
    [ROLEINFO_TAG.YUANSHEN] = "元神",
    [ROLEINFO_TAG.ZHUANSHENG] = "转生",
}

local ROLEINFO_TAG_VIEW = {
    [ROLEINFO_TAG.SHUXING] = "app.views.roleinfo.RoleAttrView",
    [ROLEINFO_TAG.SKILL] = "app.views.roleinfo.RoleSkillView",
    [ROLEINFO_TAG.NEIGONG] = "app.views.roleinfo.RoleNeigongView",
    [ROLEINFO_TAG.YUANSHEN] = "app.views.roleinfo.RoleYuanshenView",
    [ROLEINFO_TAG.ZHUANSHENG] = "app.views.roleinfo.RoleZhuanShengView",
}

function PanelRoleInfo.initView(params)
    local params = params or {}
    var = {}
    var.subView = {}
    var.selectTab = ROLEINFO_TAG.SHUXING
    if params.extend and params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    else
        if UIRedPoint.checkSkillPoint() > 0 then
            var.selectTab = ROLEINFO_TAG.SKILL
        elseif UIRedPoint.checkNeigongPoint() > 0 then
            var.selectTab = ROLEINFO_TAG.NEIGONG
        elseif UIRedPoint.checkYuanshenPoint() > 0 then
            var.selectTab = ROLEINFO_TAG.YUANSHEN
        elseif UIRedPoint.checkroleReborn() > 0 then
            var.selectTab = ROLEINFO_TAG.ZHUANSHENG
        end
    end

    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SKILL) then
        var.selectTab = ROLEINFO_TAG.SKILL
    elseif UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.NEIGONG) then
        var.selectTab = ROLEINFO_TAG.NEIGONG
    elseif UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.YUANSHEN) then
        var.selectTab = ROLEINFO_TAG.YUANSHEN
    end

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_RoleInfo_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_roleinfo")
    var.titleLabel = var.widget:getWidgetByName("Text_title")
    var.viewBg = var.widget:getWidgetByName("Panel_viewbg")

    PanelRoleInfo.addMenuTabClickEvent()
    PanelRoleInfo.registeEvent()
    return var.widget
end

function PanelRoleInfo.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local cp = cc.p(125,61)
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_shuxing"))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_skill"), position=cp, types={UIRedPoint.REDTYPE.SKILL}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_neigong"), position=cp,types={UIRedPoint.REDTYPE.NEIGONG}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_yuanshen"),position=cp, types={UIRedPoint.REDTYPE.YUANSHEN}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_zhuansheng"),position=cp, types={UIRedPoint.REDTYPE.ROLEREBORN}}))
    :onButtonSelectChanged(function(event)
        PanelRoleInfo.updatePanelByTag(event.selected)
    end)
    :onButtonSelectChangedBefor(function(event)
        return PanelRoleInfo.checkButtonClicked(event.selected)
    end)

    UIRadioButtonGroup:setButtonSelected(var.selectTab)
end

function PanelRoleInfo.checkButtonClicked(tag)
    if tag == ROLEINFO_TAG.YUANSHEN and not game.isFuncOpen(GuideDef.FUNCID_YUANSHEN) then
        local finfo = game.getFuncInfo(GuideDef.FUNCID_YUANSHEN)
        if finfo then
            NetClient:alertLocalMsg("元神系统在"..finfo.level.."级开启","alert")
        else
            NetClient:alertLocalMsg("元神系统未开启","alert")
        end
        return false
    elseif tag == ROLEINFO_TAG.ZHUANSHENG and not game.isFuncOpen(GuideDef.FUNCID_ZHUANSHENG) then
        local finfo = game.getFuncInfo(GuideDef.FUNCID_ZHUANSHENG)
        if finfo then
            NetClient:alertLocalMsg("转生系统在"..finfo.level.."级开启","alert")
        else
            NetClient:alertLocalMsg("转生系统未开启","alert")
        end
        return false
    end
    return true
end

function PanelRoleInfo.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_BUTTON_GUILD_SHOW, PanelRoleInfo.handleAddGuide)
end

function PanelRoleInfo.onPanelClose()
    if not var.guidetype then return end
    if var.guidetype == UIButtonGuide.GUILDTYPE.SKILL then
        UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_close"))
    end
end

function PanelRoleInfo.handleAddGuide(event)
    if not event then return end
    if event.GuildType == UIButtonGuide.GUILDTYPE.SKILL then
        var.guidetype = event.GuildType
        UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_close"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.SKILL,2),UIButtonGuide.UI_TYPE_LEFT)
        var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(4), cc.CallFunc:create(function()
            if not NetClient.SkillTouchType then
                EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_roleInfo"})
            end
        end)))  
    end
end

function PanelRoleInfo.hideOtherView(tag)
    for k, v in pairs(var.subView) do
        if k ~= tag then
            v:hide()
        end
    end
end

function PanelRoleInfo.updatePanelByTag(tag)
    if var.subView[tag] then
        var.subView[tag]:setVisible(true)
    else
        var.subView[tag] = require(ROLEINFO_TAG_VIEW[tag]).initView({ parent = var.viewBg})
    end
    PanelRoleInfo.hideOtherView(tag)
    if viewName then
        var.subView = require(viewName).initView({ parent = var.viewBg})
    end

    local title = ROLEINFO_TAG_NAME[tag] or ""
    var.titleLabel:setString(title)

end

return PanelRoleInfo