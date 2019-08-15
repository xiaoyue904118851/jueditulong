local PanelTrade = {}
local var = {}

function PanelTrade.initView(params)
    local params = params or {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelTrade/PanelTrade.csb")
    widget:addTo(params.parent, params.zorder)

    var.widget = widget:getChildByName("Panel_trade")
    
    var.widget:getWidgetByName("panel_tradeopr"):hide():setTouchEnabled(false)

    game.openTrade = true

    var.widget:getWidgetByName("Label_TradeTargetName"):setString(NetClient.mTradeInfo.mTradeTarget)
    var.widget:getWidgetByName("Label_TalkTradePartnerName"):setString(NetClient.mTradeInfo.mTradeTarget)
    var.targetGold = var.widget:getWidgetByName("Label_TradePartnerGold"):setString(NetClient.mTradeInfo.mTradeDesGameMoney)
    var.targetVcion = var.widget:getWidgetByName("Label_TradePartnerGoldIngot"):setString(NetClient.mTradeInfo.mTradeDesVcoin)
    var.targetSubmitL = var.widget:getWidgetByName("Label_TradePartnerStatus")
    var.mySubmitL = var.widget:getWidgetByName("Label_CofirmFlag")
    var.listView = var.widget:getWidgetByName("ListView_TalkContent")
    -- var.mSendText = var.widget:getWidgetByName("TextField_TalkMessage")
    var.widget:getWidgetByName("Button_CloseTrade"):addClickEventListener(function ( ... )
        EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_trade"})
    end)

    var.widget:getWidgetByName("Button_MessageSent"):addClickEventListener(function ( ... )
        local orgMsg = var.mSendText:getText()
        if orgMsg == "" or string.len(orgMsg) <= 0 then
            NetClient:alertLocalMsg("填写内容再发送吧！","alert")
            var.mSendText:setString("")
            return
        end
        local msg,n=string.gsub(orgMsg,"@[^>]*:","")
        NetClient:PrivateChat(NetClient.mTradeInfo.mTradeTarget,msg)
        var.mSendText:setString("")
    end)

    if NetClient.mTradeInfo.mTradeDesSubmit == 0 then
        var.targetSubmitL:setString("【未确认】")
        var.widget:getWidgetByName("ImageView_Confirm"):hide()
        var.widget:getWidgetByName("ImageView_NonConfirm"):show()
    end
    if NetClient.mTradeInfo.mTradeSubmit == 0 then
        var.mySubmitL:hide()
        var.widget:getWidgetByName("ImageView_ConfirmFlag"):hide()
    end

    local chatBg = var.widget:getWidgetByName("chat_bg")
    var.mSendText = util.newEditBox({
        image = "null.png",
        size = chatBg:getContentSize(),
        -- listener = onEdit,
        x = 0,
        y = 0,
        placeHolder = Const.chat_placeHolder,
        placeHolderSize = 28,
        fontSize = 28,
        anchor = cc.p(0,0),
    })

    var.mSendText:setMaxLength(40)
    chatBg:addChild(var.mSendText)

    local function onEditGold(event,editBox)
        if event == "return" then
            local mstart,mend = string.find(editBox:getText(),"^[+-]?%d+$")
            if mstart and mend then
                local gold = tonumber(string.gsub(editBox:getText(),mstart,mend))
                if gold and gold > 0 then
                    if NetClient.mTradeInfo.mTradeGameMoney >= gold then
                        NetClient:alertLocalMsg("无法减少数量！","alert")
                        editBox:setText(NetClient.mTradeInfo.mTradeGameMoney)
                    else
                        NetClient:TradeAddVcoin(gold-NetClient.mTradeInfo.mTradeGameMoney)
                    end
                end
            else
                NetClient:alertLocalMsg("请输入数字！","alert")
            end
        end
    end
    local goldBg = var.widget:getWidgetByName("gold_bg")
    var.mGoldText = util.newEditBox({
        image = "null.png",
        size = goldBg:getContentSize(),
        listener = onEditGold,
        x = 0,
        y = 0,
        placeHolder = Const.str_tradegold,
        placeHolderColor = cc.c3b(255,241,0),
        color = cc.c3b(255,241,0),
        placeHolderSize = 20,
        fontSize = 20,
        anchor = cc.p(0,0),
    })

    var.mGoldText:setMaxLength(10)
    goldBg:addChild(var.mGoldText)

    local function onEditVcoin(event,editBox)
        if event == "ended" then
            local mstart,mend = string.find(editBox:getText(),"^[+-]?%d+$")
            if mstart and mend then
                local vcoin = tonumber(string.sub(editBox:getText(),mstart,mend))
                if vcoin and vcoin > 0 then
                    if NetClient.mTradeInfo.mTradeVcoin >= vcoin then
                        NetClient:alertLocalMsg("无法减少数量！","alert")
                        editBox:setText(NetClient.mTradeInfo.mTradeVcoin)
                    else
                        NetClient:TradeAddVcoin(vcoin-NetClient.mTradeInfo.mTradeVcoin)
                    end
                end
            else
                NetClient:alertLocalMsg("请输入数字！","alert")
            end
        end
    end
    local vcoinBg = var.widget:getWidgetByName("vcoin_bg")
    var.mVcoinText = util.newEditBox({
        image = "null.png",
        size = vcoinBg:getContentSize(),
        listener = onEditVcoin,
        x = 0,
        y = 0,
        placeHolder = Const.str_tradevcoin,
        placeHolderColor = cc.c3b(255,241,0),
        placeHolderSize = 20,
        fontSize = 20,
        anchor = cc.p(0,0),
    })

    
    var.mVcoinText:setMaxLength(10)
    vcoinBg:addChild(var.mVcoinText)

    var.widget:getWidgetByName("Button_TradeConfirm"):addClickEventListener(function ( pSender )
        NetClient:TradeSubmit()
    end)
    -- ImageView_Confirm

    -- ImageView_NonConfirm

    -- Label_TradePartnerStatus

    -- ImageView_ConfirmFlag

    -- Label_CofirmFlag

    -- TextField_TalkMessage

    -- TextField_TradeGold

    -- TextField_TradeGoldIngot
    PanelTrade.registeEvent()
    return var.widget
end

function PanelTrade.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_CHAT_MSG, PanelTrade.handleUpdateChat)
    :addEventListener(Notify.EVENT_TRADE_MONEYCHANGE, PanelTrade.handleUpdateTrade)
end

function PanelTrade.handleUpdateChat(event)
    local netChat = NetClient.mChatHistroy[#NetClient.mChatHistroy]
    if netChat.m_strType == Const.chat_prefix_private then
        PanelTrade.updateListView(netChat)
    end
end

function PanelTrade.handleUpdateTrade(event)
    var.targetGold:setString(NetClient.mTradeInfo.mTradeDesGameMoney)
    var.targetVcion:setString(NetClient.mTradeInfo.mTradeDesVcoin)
    -- var.targetSubmitL
    if NetClient.mTradeInfo.mTradeSubmit == 1 then
        var.widget:getWidgetByName("Button_TradeConfirm"):hide():setTouchEnabled(false)
        var.widget:getWidgetByName("ImageView_ConfirmFlag"):show()
        var.widget:getWidgetByName("Label_CofirmFlag"):show()
    end
    if NetClient.mTradeInfo.mTradeDesSubmit == 1 then
        var.targetSubmitL:setString("【已确认】")
        var.widget:getWidgetByName("ImageView_Confirm"):show()
        var.widget:getWidgetByName("ImageView_NonConfirm"):hide()
    end
end

function PanelTrade.updateListView( netChat )

    local strMsg = ""
    if netChat.m_strName == game.mChrName then
        strMsg = strMsg.."你说:"
    else
        strMsg = strMsg..netChat.m_strName.."</a>对你说:"
    end
    strMsg = "<font color=\"#0099FF\" >"..strMsg.."</font>"..netChat.m_strMsg

    local width = var.listView:getContentSize().width
    local richLabel, richWidget = util.newRichLabel(cc.size(width - 30, 0), 3)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, strMsg, "panel_chat", 22)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    var.listView:pushBackCustomItem(richWidget)
    var.listView:forceDoLayout()
    var.listView:jumpToBottom()
end

function PanelTrade.onPanelClose(  )
    if NetClient.mTradeInfo.mIsTrade == 1 then
        NetClient:CloseTrade()
    end
    game.openTrade = false
end

return PanelTrade