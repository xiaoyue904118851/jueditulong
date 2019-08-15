--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/26 17:03
-- To change this template use File | Settings | File Templates.
--

local PanelNpcTaskDialog = {}
local var = {}

function PanelNpcTaskDialog.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelNpcTaskDialog/UI_NpcTaskDialog_BG.csb")
    widget:addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_npcdialog")
    var.talkmsg = util.decode(NetClient.m_strNpcTalkMsg)

    PanelNpcTaskDialog.showTopContent()
    PanelNpcTaskDialog.showBottomButton()
    PanelNpcTaskDialog.showAwardItem()

    return var.widget
end

function PanelNpcTaskDialog.showTopContent()
    local talkmsg = var.talkmsg

    var.widget:getWidgetByName("Text_npc_name"):setString(talkmsg.npc)
    var.widget:getWidgetByName("Text_task_name"):setString("["..talkmsg.task_type.."]"..talkmsg.task_name)

    var.widget:getWidgetByName("Text_desc"):setString(talkmsg.desc)
end
--[[
function PanelNpcTaskDialog.showTopContent()
    local talkmsg = var.talkmsg

    var.widget:getWidgetByName("Text_npc_name"):setString(talkmsg.npc)
    var.widget:getWidgetByName("Text_task_name"):setString("["..talkmsg.task_type.."]"..talkmsg.task_name)

    local desc = talkmsg.desc

    local scroll = var.widget:getWidgetByName("ScrollView_NpcContent")
    local innerSize = scroll:getInnerContainerSize()
    local contentSize = scroll:getContentSize()
    local richLabel,richWidget = util.newRichLabel(cc.size(contentSize.width,0))
    util.setRichLabel(richLabel,desc,"panel_npcTaskDialog",24, Const.COLOR_YELLOW_1_OX)
    scroll:setClippingEnabled(true)
    richLabel:setColor(cc.c3b(187,166,121))
    richLabel:setVisible(true)
    richWidget:setContentSize(cc.p(contentSize.width,richLabel:getRealHeight()))

    if richLabel:getRealHeight() < contentSize.height then
        richWidget:setPosition(cc.p(0,contentSize.height-richLabel:getRealHeight()))
        scroll:setBounceEnabled(false)
    else
        richWidget:setPosition(cc.p(0,0))
        scroll:setBounceEnabled(true)
    end

    scroll:addChild(richWidget,10)
    scroll:setInnerContainerSize(cc.size(innerSize.width,richLabel:getRealHeight()))
    scroll:jumpToPercentVertical(0)
end
--]]
function PanelNpcTaskDialog.showBottomButton()
    local talkmsg = var.talkmsg
    local rightAccepteBtn = var.widget:getWidgetByName("Button_do")
    if talkmsg.is_done then
        rightAccepteBtn:setTitleText("完成任务")
    else
        rightAccepteBtn:setTitleText("接受任务")
    end
    rightAccepteBtn:addClickEventListener(PanelNpcTaskDialog.onDialogTouched)

    if NetClient.mAutoTaskDone then
        rightAccepteBtn:runAction(cc.Sequence:create(
            cc.DelayTime:create(4),
            cc.CallFunc:create(PanelNpcTaskDialog.onDialogTouched)
        ))
    end
    var.widget:addClickEventListener(PanelNpcTaskDialog.onDialogTouched)
end

function PanelNpcTaskDialog.onDialogTouched(pSender)
    pSender:setTouchEnabled(false)
    var.widget:getWidgetByName("Button_do"):stopAllActions()
    if not var.sendClose then
        var.sendClose = true
        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_npcTaskDialog"})
    end
end

function PanelNpcTaskDialog.taskDone()
    var.widget:getWidgetByName("Button_do"):stopAllActions()
    local msgevent = var.talkmsg.event
    if msgevent then
        NetClient:NpcTalk(NetClient.m_nNpcTalkId,msgevent)
    end
end

function PanelNpcTaskDialog.showAwardItem()
    local awardItems = var.talkmsg.award
    for i = 1, 4 do
        if awardItems[i] then
            local itemBg = var.widget:getWidgetByName("item_icon_"..i)
            itemBg:show()
            UIItem.getSimpleItem({parent = itemBg, name = awardItems[i].name, typeId = awardItems[i].itemId, num = awardItems[i].num})
        else
            var.widget:getWidgetByName("item_icon_"..i):hide()
        end
    end

end

function PanelNpcTaskDialog.onPanelClose(from)
    if from and from == "btn_close" then return end
    PanelNpcTaskDialog.taskDone()
end

return PanelNpcTaskDialog