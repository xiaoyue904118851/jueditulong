--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2018/01/11 16:31
-- To change this template use File | Settings | File Templates.
--

local PanelMoneyBag = {}
local var = {}
local ACTIONSET_NAME = "actionset_moneybag"

local DESC_WIDGET_NAME = "buffattr"

local GRAB_STATUS_VALID = 0 --可以抢
local GRAB_STATUS_GETED = 1 --已经抢过
local GRAB_STATUS_TIMEOUT = 2 --过时
local GRAB_STATUS_ZERO = 3 --被抢光

function PanelMoneyBag.initView(params)
    local params = params or {}
    var = {}
    var.loglist = {}
    var.minContribute = 0
    local widget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelMoneyBag/UI_MoneyBag.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_hongbao")
    PanelMoneyBag.initWidget()
    PanelMoneyBag.registeEvent()
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_moneybag_data_ontime"}))
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_baseinfo_ontime"}))
    var.widget:setTouchEnabled(true):addClickEventListener(function(pSender)
        pSender:setTouchEnabled(false)
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_hongbao"})
    end)
    return var.widget
end

function PanelMoneyBag.initWidget()
    var.rankWidget = var.widget:getWidgetByName("Image_rank_bg"):hide()
    var.qiangWidget = var.widget:getWidgetByName("Image_qiang_bg")
    var.openedWidget = var.widget:getWidgetByName("Image_opened_bg"):hide()
    var.tipsWidget = var.widget:getWidgetByName("Panel_detail"):hide()
    var.qiangWidget:getWidgetByName("Label_cd"):hide()
    var.qiangWidget:getWidgetByName("Image_log_bg"):hide()
    var.qiangWidget:getWidgetByName("Text_hongbao_left"):hide()
    var.bgSize = var.widget:getContentSize()
--    var.qiangWidget:setPositionX(var.bgSize.width/2-var.qiangWidget:getContentSize().width/2)
    PanelMoneyBag.showRankWidget()
    var.tipsWidget:setTouchEnabled(true):addClickEventListener(function(pSender)
        pSender:hide()
    end)

--    var.qiangWidget:getWidgetByName("Button_link_rank"):setTouchEnabled(true):addClickEventListener(function(pSender)
--        pSender:setTouchEnabled(false)
--        var.qiangWidget:runAction(cc.Sequence:create(
--            cc.MoveTo:create(0.2, cc.p(var.bgSize.width/2, var.bgSize.height/2)),
--            cc.CallFunc:create(function()
--                PanelMoneyBag.showRankWidget()
--            end)
--        ))
--    end)

    var.qiangWidget:getWidgetByName("Button_tips"):setTouchEnabled(true):addClickEventListener(function(pSender)
        if var.desp then
            UIAnimation.oneTips({
                parent = pSender,
                msg = var.desp,
            })
        end
    end)
    var.qiangWidget:getWidgetByName("Button_open"):setTouchEnabled(false)

    var.openedWidget:getWidgetByName("Button_tips"):setTouchEnabled(true):addClickEventListener(function(pSender)
        if var.desp then
            UIAnimation.oneTips({
                parent = pSender,
                msg = var.desp,
            })
        end
    end)
--    var.openedWidget:getWidgetByName("Button_link_rank"):setTouchEnabled(true):addClickEventListener(function(pSender)
--        pSender:setTouchEnabled(false)
--        var.openedWidget:runAction(cc.Sequence:create(
--            cc.MoveTo:create(0.2, cc.p(var.bgSize.width/2, var.bgSize.height/2)),
--            cc.CallFunc:create(function()
--                PanelMoneyBag.showRankWidget()
--            end)
--        ))
--    end)

    var.rankWidget:getWidgetByName("Button_contribute"):setTouchEnabled(true):addClickEventListener(function(pSender)
        if game.getVipLevel() < var.contributeNeedVip then
            NetClient:alertLocalMsg("VIP等级大于"..var.contributeNeedVip.."级才可以捐献","alert")
            return
        end

        local num = checkint(var.mSendText:getText())
        if num >= var.minContribute then
            var.lastContribute = num
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_moneybag_contribute",params=num}))
        else
            NetClient:alertLocalMsg("捐献金额不得少于"..var.minContribute.."元宝","alert")
        end
    end)

    local inputBg = var.rankWidget:getWidgetByName("Image_num")
    local bgSize = inputBg:getContentSize()
    var.mSendText = util.newEditBox({
        image = "null.png",
        size = bgSize,
        x = 0,
        y = 0,
        placeHolderSize = 24,
        fontSize = 24,
        anchor = cc.p(0,0),
    })
    var.mSendText:setFontColor(Const.COLOR_GREEN_1_C3B)
    var.mSendText:setMaxLength(5):setText(100)
    inputBg:addChild(var.mSendText)
end

function PanelMoneyBag.showRankWidget()
    var.rankWidget:show()
    var.rankWidget:getWidgetByName("Text_rank_value"):hide()
    var.rankWidget:getWidgetByName("Text_yf_value"):hide()
    var.rankWidget:getWidgetByName("Image_list_item"):hide()
    if not var.rankDesp then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_moneybag_contribute_base"}))
    end

end

function PanelMoneyBag.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelMoneyBag.handleHongbaoMsg)
end

function PanelMoneyBag.handleHongbaoMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
        return
    end
    if d.actionid == "resp_moneybag_data_ontime" then
        var.moneyBagInfo = d.param[1].bag[1] --只取一个
        var.nextHongbaoLeftTime = d.param[2] --下波红包发放倒计时
        var.nextHongbaoDesc = d.param[3]
        if var.moneyBagInfo then
            PanelMoneyBag.updateMoneyBag()
        else
            PanelMoneyBag.updateWhenWait()
        end
    elseif d.actionid == "baseinfo_ontime" then
        var.desp = d.param.desp
    elseif d.actionid == "new_moneybag" then
        local info = util.decode(d.param.info)
        if info.type == "new" or info.type == "timeout" then
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_moneybag_data_ontime"}))
        end
    elseif d.actionid == "resp_ontime_moneybag_detail_data" then
        var.loglist = d.param or {}
        PanelMoneyBag.updateGetLog()
    elseif d.actionid == "resp_moneybag_contribute_base" then
        PanelMoneyBag.updateContributeInfo(d.param)
    elseif d.actionid == "resp_moneybag_contribute_rank" then
        PanelMoneyBag.updateContributeRank(d.param)
    end
end

function PanelMoneyBag.updateMoneyBag()
    if var.moneyBagInfo.is_grab == GRAB_STATUS_VALID then
        PanelMoneyBag.updateWhenValid()
    elseif var.moneyBagInfo.is_grab == GRAB_STATUS_GETED then
        PanelMoneyBag.updateWhenGeted()
    elseif var.moneyBagInfo.is_grab == GRAB_STATUS_TIMEOUT or var.moneyBagInfo.is_grab == GRAB_STATUS_ZERO then
        PanelMoneyBag.updateWhenWait()
    end
end

function PanelMoneyBag.sendGotLogMsg()
    if not var.getLog then
        var.loglist = {}
        var.getLog = true
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_moneybag_detail_data",type=6,id=var.moneyBagInfo.id}))
    end
    PanelMoneyBag.updateGetLog()
end

function PanelMoneyBag.updateGetLog()
    if not var.moneyBagInfo then return end
    local listview
    if var.moneyBagInfo.is_grab == GRAB_STATUS_VALID then
        listview =var.qiangWidget:getWidgetByName("ListView_log")
    elseif var.moneyBagInfo.is_grab == GRAB_STATUS_GETED then
        listview =var.openedWidget:getWidgetByName("ListView_log")
    end

    if not listview then return end
    listview:removeAllItems()

    if not var.loglist then return end
    for _, v in ipairs(var.loglist) do
        local width = listview:getContentSize().width - 20
        local richLabel, richWidget = util.newRichLabel(cc.size(width, 0), 3)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel, game.make_str_with_color(Const.COLOR_BLUE_1_STR,v.name).."抢到"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,v.cnt.."元宝"),"", 26, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        listview:pushBackCustomItem(richWidget)
    end
end

function PanelMoneyBag.updateWhenWait()
    var.openedWidget:hide()
    var.qiangWidget:show()
    if var.rankWidget:isVisible() then
        var.qiangWidget:setPosition(cc.p(var.bgSize.width/2, var.bgSize.height/2))
    else
        var.qiangWidget:setPosition(cc.p(var.bgSize.width/2-var.qiangWidget:getContentSize().width/2, var.bgSize.height/2))
    end


    var.qiangWidget:getWidgetByName("Label_cd_get1"):show()

    var.qiangWidget:getWidgetByName("Image_log_bg"):hide()
    var.qiangWidget:getWidgetByName("Text_hongbao_left"):setString(0):show()
    var.qiangWidget:getWidgetByName("Button_open"):setTouchEnabled(false)
    :setBright(false)
    var.qiangWidget:getWidgetByName("Label_cd"):show():stopAllActions()
    var.qiangWidget:getWidgetByName("Label_cd_des"):show():setString(var.nextHongbaoDesc)
    if type(var.nextHongbaoLeftTime) == "number" then
        var.qiangWidget:getWidgetByName("Label_cd"):setString(game.convertSecondsToH(var.nextHongbaoLeftTime))
        if var.nextHongbaoLeftTime > 0 then
            PanelMoneyBag.startCountDown(var.nextHongbaoLeftTime, var.qiangWidget:getWidgetByName("Label_cd"))
        end
    else
        var.qiangWidget:getWidgetByName("Label_cd"):setString(var.nextHongbaoLeftTime)
    end
end

function PanelMoneyBag.startCountDown(time, obj)
    if not obj then return end
    obj:stopAllActions()
    if time <= 0 then time = 0 end
    obj.countdown = time

    if time == 0 then return end
    obj:show()
    PanelMoneyBag.updateCountDownText(obj)
    obj:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(PanelMoneyBag.updateCountDownText))))
end

function PanelMoneyBag.updateCountDownText(pSender)
    if pSender then
        pSender.countdown = pSender.countdown - 1
        pSender:setString(game.convertSecondsToH( pSender.countdown))
        if pSender.countdown <= 0 then
            pSender:stopAllActions()
            return
        end
    end
end

function PanelMoneyBag.updateWhenValid()
    var.openedWidget:hide()
    if var.rankWidget:isVisible() then
        var.qiangWidget:setPosition(cc.p(var.bgSize.width/2, var.bgSize.height/2))
    else
        var.qiangWidget:setPosition(cc.p(var.bgSize.width/2-var.qiangWidget:getContentSize().width/2, var.bgSize.height/2))
    end
    var.qiangWidget:show()
    var.qiangWidget:getWidgetByName("Label_cd_des"):hide()
    var.qiangWidget:getWidgetByName("Label_cd_get1"):hide()
    var.qiangWidget:getWidgetByName("Image_log_bg"):show()
    var.qiangWidget:getWidgetByName("Label_cd"):hide():stopAllActions()
    var.qiangWidget:getWidgetByName ("Text_hongbao_left"):setString(var.moneyBagInfo.money):show()
    var.qiangWidget:getWidgetByName("Button_open"):setBright(true)
    var.qiangWidget:getWidgetByName("Button_open"):setTouchEnabled(true):addClickEventListener(function(pSender)
        if not game.checkBtnClick() then return end
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="req_get_moneybag_ontime",params=var.moneyBagInfo.id}))
    end)
    PanelMoneyBag.sendGotLogMsg()
end

function PanelMoneyBag.updateWhenGeted()
    var.qiangWidget:hide()

    if var.rankWidget:isVisible() then
        var.openedWidget:setPosition(cc.p(var.bgSize.width/2, var.bgSize.height/2))
    else
        var.openedWidget:setPosition(cc.p(var.bgSize.width/2-var.qiangWidget:getContentSize().width/2, var.bgSize.height/2))
    end
    var.openedWidget:show()

    var.openedWidget:getWidgetByName("Label_cd_descr"):show():setString(var.nextHongbaoDesc)
    var.openedWidget:getWidgetByName("AtlasLabel_get_number"):setString(var.moneyBagInfo.grab_num or 0 )
    local numberSize = var.openedWidget:getWidgetByName("AtlasLabel_get_number"):getContentSize()
    var.openedWidget:getWidgetByName("Image_dw"):setPositionX(numberSize.width + 10)
    var.openedWidget:getWidgetByName("Panel_number"):setContentSize(cc.size(numberSize.width + 10 + var.openedWidget:getWidgetByName("Image_dw"):getContentSize().width,numberSize.height))
    var.openedWidget:getWidgetByName("Label_cd"):stopAllActions()
    if type(var.nextHongbaoLeftTime) == "number" then
        var.openedWidget:getWidgetByName("Label_cd"):setString(game.convertSecondsToH(var.nextHongbaoLeftTime))
        if var.nextHongbaoLeftTime > 0 then
            PanelMoneyBag.startCountDown(var.nextHongbaoLeftTime, var.openedWidget:getWidgetByName("Label_cd"))
        end
    else
        var.openedWidget:getWidgetByName("Label_cd"):setString(var.nextHongbaoLeftTime)
    end
    PanelMoneyBag.sendGotLogMsg()
end

function PanelMoneyBag.updateContributeInfo(info)
    if not var.rankDesp then
        var.rankDesp = info.desp
        local despParent = var.rankWidget:getWidgetByName("Image_baseaward")
        local width = despParent:getContentSize().width
        local richLabel, richWidget = util.newRichLabel(cc.size(width, 0), 3)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel, var.rankDesp,"", 26, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
        richWidget:setPosition(cc.p(30, despParent:getContentSize().height/2-richLabel:getRealHeight()/2))
        despParent:addChild(richWidget)

        var.rankWidget:getWidgetByName("Image_baseaward"):setTouchEnabled(true):addClickEventListener(function(pSender)
            PanelMoneyBag.showBaseAwardTips()
        end)
    end
    var.minContribute = info.minc
    var.contributeNeedVip = info.need_vip
    var.baseIconStr = info.minicon
    var.baseBuffId = info.minbuff
    var.rankWidget:getWidgetByName("Text_yf_value"):setString(info.cnumber.."元宝"):show()
    if not var.lastContribute then
        var.mSendText:setText(info.minc)
    end
end

function PanelMoneyBag.updateContributeRank(listdata)
    local listview = var.rankWidget:getWidgetByName("ListView_rank")
    listview:removeAllItems()
    if not listdata then return end
    local copyItem = var.rankWidget:getWidgetByName("Image_list_item")
    local name = ""
    local myrank = 0
    for k, v in ipairs(listdata) do
        local item = copyItem:clone():show()
        name = v.name
        if not name or name == "" then
            name = "虚位以待"
        end
        if k%2 == 0 then
            item:getWidgetByName("Image_list_item"):loadTexture("touming.png",UI_TEX_TYPE_PLIST)
        end
        item:getWidgetByName("Label_username"):setString(name)
        item:getWidgetByName("Label_rank"):setString(k)
        listview:pushBackCustomItem(item)

        if v.name == game.GetMainRole():NetAttr(Const.net_name) then
            myrank = k
        end

        item:setTouchEnabled(true):addClickEventListener(function(pSender)
            PanelMoneyBag.showRankAwardDetail(k, v.cnt, v.buffid, v.title, v.icon)
        end)
    end
    if myrank > 0 then
        var.rankWidget:getWidgetByName("Text_rank_value"):setString(myrank):show()
    else
        var.rankWidget:getWidgetByName("Text_rank_value"):setString("未上榜"):show()
    end
end

function PanelMoneyBag.showRankAwardDetail(rank, minyb,statusid, titlestr, iconstr)
    local itemIcon = var.tipsWidget:getWidgetByName("itembg")
    itemIcon:removeAllChildren()
    itemIcon:ignoreContentAdaptWithSize(true)
    if titlestr then
        itemIcon:loadTexture("nametitle/"..titlestr..".png",UI_TEX_TYPE_LOCAL)
    else
        itemIcon:loadTexture("item_bg.png",UI_TEX_TYPE_PLIST)
        ccui.ImageView:create(iconstr..".png",UI_TEX_TYPE_PLIST)
        :align(display.CENTER,itemIcon:getContentSize().width/2,itemIcon:getContentSize().height/2)
        :addTo(itemIcon)
    end
    var.tipsWidget:getWidgetByName("Text_tips"):setString(string.format("注：第%d名最低需要发放%d元宝",rank,minyb))
    PanelMoneyBag.addBuffDesc(statusid,rank)
    var.tipsWidget:show()
end

function PanelMoneyBag.showBaseAwardTips()
    local itemIcon = var.tipsWidget:getWidgetByName("itembg")
    itemIcon:removeAllChildren()
    itemIcon:ignoreContentAdaptWithSize(true)
    itemIcon:loadTexture("item_bg.png",UI_TEX_TYPE_PLIST)
    ccui.ImageView:create(var.baseIconStr..".png",UI_TEX_TYPE_PLIST)
    :align(display.CENTER,itemIcon:getContentSize().width/2,itemIcon:getContentSize().height/2)
    :addTo(itemIcon)
    var.tipsWidget:getWidgetByName("Text_tips"):setString("注："..var.rankDesp)

    PanelMoneyBag.addBuffDesc(var.baseBuffId,11)
    var.tipsWidget:show()
end

function PanelMoneyBag.addBuffDesc(statusid,rank)
    if var.tipsWidget:getWidgetByName("Image_bg"):getWidgetByName(DESC_WIDGET_NAME) then
        var.tipsWidget:getWidgetByName("Image_bg"):removeChildByName(DESC_WIDGET_NAME)
    end

    local mAttrInfo = NetClient:getStatusDefByID(statusid, 1)
    if not mAttrInfo then
        return
    end

    local attrStr = ""
    if rank <= 5 then
        attrStr = string.format("第%d名获得称号：%s%s<br>",rank,game.make_str_with_color(Const.COLOR_YELLOW_2_STR,mAttrInfo.mName),game.make_str_with_color(Const.COLOR_GREEN_1_STR,"(持续24小时)"))
    elseif rank <=10 then
        attrStr = string.format("第%d名获得BUFF：%s%s<br>",rank, game.make_str_with_color(Const.COLOR_YELLOW_2_STR,mAttrInfo.mName),game.make_str_with_color(Const.COLOR_GREEN_1_STR,"(持续24小时)"))
    else
        attrStr = string.format("保底获得BUFF：%s%s<br>",game.make_str_with_color(Const.COLOR_YELLOW_2_STR,mAttrInfo.mName),game.make_str_with_color(Const.COLOR_GREEN_1_STR,"(持续24小时)"))
    end

    local all_attr_tab = {
        {"物理攻击：",0,0},
        {"魔法攻击：",0,0},
        {"道术攻击：",0,0},
        {"物理防御：",0,0},
        {"魔法防御：",0,0},
    }
    all_attr_tab[1][2] = mAttrInfo.mDC
    all_attr_tab[1][3] = mAttrInfo.mDCmax
    all_attr_tab[2][2] = mAttrInfo.mMC
    all_attr_tab[2][3] = mAttrInfo.mMCmax
    all_attr_tab[3][2] = mAttrInfo.mSC
    all_attr_tab[3][3] = mAttrInfo.mSCmax
    all_attr_tab[4][2] = mAttrInfo.mAC
    all_attr_tab[4][3] = mAttrInfo.mACmax
    all_attr_tab[5][2] = mAttrInfo.mMAC
    all_attr_tab[5][3] = mAttrInfo.mMACmax
    for _, v in ipairs(all_attr_tab) do
        if v[2] > 0 or v[3] > 0 then
            attrStr = attrStr..v[1]..game.make_str_with_color(Const.COLOR_GREEN_1_STR ,v[2].."-"..v[3]).."<br>"
        end
    end
    if mAttrInfo.hpmaxadd > 0 then
        attrStr = attrStr..game.make_str_with_color(Const.COLOR_YELLOW_2_STR ,"生命上限："..mAttrInfo.hpmaxadd)
    end

    if attrStr == "" then return end

    local richLabel, richWidget = util.newRichLabel(cc.size(var.tipsWidget:getContentSize().width-50, 0), 3)
    richWidget.richLabel = richLabel
    util.setRichLabel(richLabel, attrStr,"", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
    richWidget:align(display.LEFT_TOP, 20, 230)
    richWidget:setName(DESC_WIDGET_NAME)
    var.tipsWidget:getWidgetByName("Image_bg"):addChild(richWidget)
end

function PanelMoneyBag.checkPanelClose()
    if var.tipsWidget:isVisible() then
        var.tipsWidget:hide()
        return false
    end
    return true
end

return PanelMoneyBag