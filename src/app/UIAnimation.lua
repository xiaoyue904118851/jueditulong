--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/14 14:17
-- To change this template use File | Settings | File Templates.
--

local UIAnimation = {}

function UIAnimation.onListMessage(param)
    if param.parent then
        if not param.parent.msgTable then
            param.parent.msgTable = {}
        end
        if not param.parent.msgNodeList then
            param.parent.msgNodeList = {}
        end
        if param.msg and param.msg ~= nil then
            table.insert(param.parent.msgTable,{msg = param.msg, itemid = param.itemid})
        end
        local pSize = param.parent:getContentSize()
        param.parent.maxNode = param.parent.maxNode or 5
        local itemHeight = param.itemheight or 40
        if not param.parent.mLayout then
            param.parent.mLayout = ccui.Layout:create()
            param.parent.mLayout:setContentSize(cc.size(pSize.width,pSize.height))
            param.parent.mLayout:setAnchorPoint(cc.p(0,0))
            param.parent.mLayout:setClippingEnabled(true)
            param.parent.mLayout:setPosition(cc.p(0,2))
            param.parent.mLayout:setTouchEnabled(false)
            param.parent:addChild(param.parent.mLayout)
        end
        if not param.parent.showing and #param.parent.msgTable>0 then
            param.parent:stopAllActions()
            param.parent.showing = true
            local speed = 0.5
            local movespace = itemHeight
            local bgSize = cc.size(512, itemHeight - 4)
            for i = #param.parent.msgNodeList + 1, param.parent.maxNode + 1 do
                if #param.parent.msgTable > 0 then
                    local text = param.parent.msgTable[1].msg
                    local itemid = param.parent.msgTable[1].itemid
                    table.remove(param.parent.msgTable,1)

                    local msgNode = ccui.ImageView:create(param.bgfile or "backgroup_10.png",UI_TEX_TYPE_PLIST)
                    :setScale9Enabled(true)
                    :setContentSize(bgSize)
                    if param.scenter then
                        msgNode:align(display.CENTER_BOTTOM,pSize.width/2,-movespace)
                    else
                        msgNode:align(display.LEFT_BOTTOM,0,-movespace)
                    end

--                    msgNode:setCascadeOpacityEnabled(true)
                    msgNode:setTouchEnabled(false)
                    local richLabel, richWidget = util.newRichLabel(cc.size(bgSize.width, 0), 0)
                    richWidget.richLabel = richLabel
                    richWidget:setTouchEnabled(false)
                    util.setRichLabel(richLabel, text, "", param.fontSize, "0xFFFFFF")
                    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
                    if param.scenter then
                        richWidget:setPosition(cc.p(bgSize.width/2 - richLabel:getRealWidth()/2,0))
--                    elsethen

                    end

--                    richWidget:setCascadeOpacityEnabled(true)
--                    richLabel:setCascadeOpacityEnabled(true)
                    msgNode:addChild(richWidget)

                    if itemid then
                        local itemdef = NetClient:getItemDefByID(itemid)
                        if itemdef then
                            ccui.ImageView:create("icon/"..itemdef.mIconID..".png", UI_TEX_TYPE_LOCAL)
                            :align(display.LEFT_CENTER,50,bgSize.height/2)
                            :addTo(msgNode)
                            :setScale(0.8)
                        end
                    end

                    param.parent.mLayout:addChild(msgNode,1,9999)
                    param.parent.msgNodeList[i] = msgNode
                end
            end

            local postionY = 0
            for i = #param.parent.msgNodeList, 1, -1 do
                local mnode = param.parent.msgNodeList[i]
                local showAction
                mnode:stopAllActions()
                if i == 1 and #param.parent.msgNodeList > param.parent.maxNode then
                    showAction = cc.EaseExponentialOut:create(cc.Spawn:create(cc.FadeOut:create(speed),cc.MoveTo:create(speed,cc.p(mnode:getPositionX(),postionY))))
                else
                    showAction = cc.EaseExponentialOut:create(cc.Spawn:create(cc.MoveTo:create(speed,cc.p(mnode:getPositionX(),postionY))))
                end
                postionY = postionY + movespace
                param.parent.msgNodeList[i]:runAction(
                    cc.Sequence:create(
                        showAction
                    )
                )
            end
            param.parent:runAction(
                cc.Sequence:create(
                    cc.DelayTime:create(speed),
                    cc.CallFunc:create(function()
                        if #param.parent.msgNodeList > param.parent.maxNode then
                            param.parent.msgNodeList[1]:removeFromParent()
                            table.remove(param.parent.msgNodeList,1)
                        end
                        param.parent.showing = false
                        if #param.parent.msgTable>0 then
                            param.msg = nil
                            UIAnimation.onListMessage(param)
                        else
                            param.parent:runAction(
                                cc.Sequence:create(
                                    cc.DelayTime:create(2),
                                    cc.CallFunc:create(function()
                                        for _, v in ipairs(param.parent.msgNodeList) do
                                            v:removeFromParent()
                                        end
                                        param.parent.msgNodeList = {}
                                    end)
                                )
                            )
                        end
                    end)
                )
            )
        end
    end
end

----param{parent,hold,msg,color,pos,fontSize,opacity}
----有消息堆栈
function UIAnimation.onHorizontalMessage(param)
    if param.parent then
        if not param.parent.msgTable then
            param.parent.msgTable = {}
        end
        if param.msg and param.msg ~= nil then
            table.insert(param.parent.msgTable,param.msg)
        end
        local pSize = param.parent:getContentSize()
        local lableHeight = pSize.height-5
        if not param.parent.mLayout then
            param.parent.mLayout = ccui.Layout:create()
            param.parent.mLayout:setContentSize(cc.size(pSize.width,lableHeight))
            param.parent.mLayout:setAnchorPoint(cc.p(0,0))
            param.parent.mLayout:setClippingEnabled(true)
            param.parent.mLayout:setPosition(cc.p(0,2))
            param.parent:addChild(param.parent.mLayout)
        end
        if not param.parent.lastMsg and #param.parent.msgTable>0 then
            local bgSizeWidth = param.parent:getContentSize().width
            local richLabel, richWidget = util.newRichLabel(cc.size(1334, 0), 0)
            richWidget.richLabel = richLabel
            richWidget:setTouchEnabled(false)
            util.setRichLabel(richLabel, param.parent.msgTable[1], "", param.fontSize, param.color or Const.COLOR_WHITE_1_OX)
            richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(bgSizeWidth,0))
            param.parent.mLayout:addChild(richWidget)

            param.parent.lastMsg = richWidget
            local cleanAction = cc.Sequence:create(
                cc.RemoveSelf:create(),
                cc.CallFunc:create(function ()
                    param.parent.lastMsg = nil,
                    param.parent:hide()
                end)
            )
            local speed = 10
            param.parent:show()
            richWidget:runAction(
                cc.Sequence:create(
                    cc.MoveTo:create(speed, cc.p(-richLabel:getRealWidth(), 0)),
                    cleanAction,
                    cc.CallFunc:create(function()
                        table.remove(param.parent.msgTable,1)
                        if #param.parent.msgTable>0 then
                            param.msg = nil
                            UIAnimation.onHorizontalMessage(param)
                        end
                    end)

                )
            )
        end
    end
end

----param{parent,hold,msg,color,pos,fontSize,opacity}
----有消息堆栈
----垂直
function UIAnimation.onMessage(param)
    if param.parent then
        if not param.parent.msgTable then
            param.parent.msgTable = {}
        end
        if param.msg and param.msg ~= nil then
            table.insert(param.parent.msgTable,param.msg)
        end
        local pSize = param.parent:getContentSize()
        local lableHeight = pSize.height-5
        if not param.parent.mLayout then
            param.parent.mLayout = ccui.Layout:create()
            param.parent.mLayout:setContentSize(cc.size(pSize.width,lableHeight))
            param.parent.mLayout:setAnchorPoint(cc.p(0,0))
            param.parent.mLayout:setClippingEnabled(true)
            param.parent.mLayout:setPosition(cc.p(0,2))
            param.parent:addChild(param.parent.mLayout)
        end
        if not param.parent.lastMsg and #param.parent.msgTable>0 then
            local bgSizeWidth = param.parent:getContentSize().width
            local richLabel, richWidget = util.newRichLabel(cc.size(bgSizeWidth, 0), 0)
            richWidget.richLabel = richLabel
            richWidget:setTouchEnabled(false)
            util.setRichLabel(richLabel, param.parent.msgTable[1], "", param.fontSize, param.color or Const.COLOR_WHITE_1_OX)
            richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
            richWidget:setPosition(cc.p(bgSizeWidth/2 - richLabel:getRealWidth()/2,-richLabel:getRealHeight()))
            param.parent.mLayout:addChild(richWidget,1,9999)

            param.parent.lastMsg = richWidget
            local cleanAction
            if not param.hold then
                cleanAction = cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.Spawn:create(cc.FadeOut:create(1),cc.MoveTo:create(1,cc.p(bgSizeWidth/2 - richLabel:getRealWidth()/2,lableHeight)))),
                    cc.RemoveSelf:create(),
                    cc.CallFunc:create(function (dx)
                        param.parent.lastMsg = nil,
                        param.parent:hide()
                    end)
                )
            end
            param.parent:show()
            richWidget:runAction(
                cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.Spawn:create(cc.FadeIn:create(1),cc.MoveTo:create(1,cc.p(bgSizeWidth/2 - richLabel:getRealWidth()/2,lableHeight/2-richLabel:getRealHeight()/2)))),
                    cc.DelayTime:create(3),
                    cleanAction,
                    cc.CallFunc:create(function()
                        table.remove(param.parent.msgTable,1)
                        if #param.parent.msgTable>0 then
                            param.msg = nil
                            UIAnimation.onMessage(param)
                        end
                    end)

                )
            )
        end
    end
end

----param{parent,msg,color,pos,fontSize,opacity, callBack}
----无消息堆栈

function UIAnimation.oneMessage(param)
    if not param.parent then
        print("UIAnimation.oneMessage==>>error")
        return
    end
    param.pos = param.pos or {}
    local parentSize = param.parent:getContentSize()
    local bgX = param.pos.x or parentSize.width/2
    local bgY = param.pos.y or parentSize.height/2

    local msgLabel = util.newUILabel({
        text = param.msg,
        fontSize = param.fontSize or 20,
        anchor = cc.p(0.5,0.5),
        color = param.color or cc.c3b(0,255,0),
        opacity = param.opacity or 250,
    })

    local labelSize = msgLabel:getContentSize()
    local msgBg = ccui.ImageView:create()
    msgBg:setScale9Enabled( true )

    local bgHeight = math.max(labelSize.height + 10, 30)
    local bgWidth =  math.max(labelSize.width + 40, 200)


    local bgFile = param.bgFile or "img_name_bg.png"
    local bgFileType = param.bgFileType or UI_TEX_TYPE_PLIST
    msgBg:loadTexture(bgFile, bgFileType)
    msgBg:setContentSize( cc.size(bgWidth, bgHeight) )
    msgBg:align(display.CENTER, bgX, bgY - 50)
    msgBg:addTo(param.parent)

    msgLabel:align(display.CENTER, bgWidth/2, bgHeight/2)
    msgBg:addChild(msgLabel, 20)

    msgBg:runAction(
        cc.Sequence:create(
            cc.EaseExponentialOut:create(cc.Spawn:create(cc.FadeIn:create(1),cc.MoveTo:create(1,cc.p(bgX, bgY)))),
            cc.DelayTime:create(3),
            cc.CallFunc:create(function()
                msgBg:removeFromParent()
                if param.callBack then param.callBack() end
            end)
        )
    )
end

----param{parent,msg,color,pos,fontSize,opacity, callBack}
----无消息堆栈

function UIAnimation.oneTips(param)
    if not param.parent then
        print("UIAnimation.oneTips==>>error")
        return
    end
    param.parent:setTouchEnabled(false)
    param.pos = param.pos or {}
    local parentSize = param.parent:getContentSize()
    local bgX = param.pos.x or parentSize.width/2
    local bgY = param.pos.y or parentSize.height

    local msgLabel = util.newUILabel({
        text = param.msg,
        fontSize = param.fontSize or 24,
        anchor = cc.p(0.5,0.5),
        color = param.color or Const.COLOR_YELLOW_1_C3B,
        opacity = param.opacity or 250,
    })

    local labelSize = msgLabel:getContentSize()
    local msgBg = ccui.ImageView:create()
    msgBg:setScale9Enabled( true )

    local bgHeight = math.max(labelSize.height + 10, 30)
    local bgWidth =  math.max(labelSize.width + 40, 200)


    local bgFile = param.bgFile or "backgroup_10.png"
    local bgFileType = param.bgFileType or UI_TEX_TYPE_PLIST
    msgBg:loadTexture(bgFile, bgFileType)
    msgBg:setContentSize( cc.size(bgWidth, bgHeight) )
    msgBg:align(display.CENTER_BOTTOM, bgX, bgY + 10)
    msgBg:addTo(param.parent)

    msgLabel:align(display.CENTER, bgWidth/2, bgHeight/2)
    msgBg:addChild(msgLabel, 20)

    msgBg:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(2),
            cc.CallFunc:create(function()
                msgBg:removeFromParent()
                param.parent:setTouchEnabled(true)
                if param.callBack then param.callBack() end
            end)
        )
    )
end

return UIAnimation