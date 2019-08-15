--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/12/03 18:01
-- To change this template use File | Settings | File Templates.
--

local LayerTest = class("LayerTest", function()
    return display.newLayer()
end)

function LayerTest:ctor()
    self:setContentSize(cc.size(display.width, display.height))
    self:addSprite()
    self:registeEvent()
    self:hide()
end

function LayerTest:addSprite()
    self.btn = util.newUILabel({
        text = "",
        fontSize = 24,
        anchor = cc.p(0.5,0.5),
        color = cc.c3b(0,255,0),
        position = cc.p(display.cx, display.cy),
    })
    self.btn:addTo(self)
end

function LayerTest:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_OPEN_TASK_PANEL, handler(self, self.updateTask))
end

function LayerTest:updateTask()
    self:show()
    self.talkmsg = util.decode(NetClient.m_strNpcTalkMsg)
    if self.talkmsg.is_done then
        self.btn:setString("5秒后自动完成任务")
    else
        self.btn:setString("5秒后自动接受任务")
    end
    self.btn:stopAllActions()
    self.btn:runAction(cc.Sequence:create(
        cc.DelayTime:create(4),
        cc.CallFunc:create(handler(self, self.onDialogTouched))
    ))
end

function LayerTest:onDialogTouched(pSender)
    pSender:setTouchEnabled(false)
    pSender:stopAllActions()
    if self.talkmsg.event then
        NetClient:NpcTalk(NetClient.m_nNpcTalkId,self.talkmsg.event)
    end
    self:hide()
    saveTextureCache()
end

return LayerTest