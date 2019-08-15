--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/23 16:11
-- To change this template use File | Settings | File Templates.
--
local PanelKing = {}
local var = {}
local ACTIONSET_NAME = "kingdom"
local PANELID = "kingdomInfo"
function PanelKing.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/activity/PanelKing/UI_King_BG.csb"):addTo(params.parent, params.zorder)
    var.mClosePanel = true
    var.widget = widget:getChildByName("Panel_king")
    var.widget:getWidgetByName("Panel_server_notice"):hide()
    var.widget:getWidgetByName("Panel_title"):hide()
    PanelKing.handleKingState()
    PanelKing.handlelKingInfoChange()
    PanelKing.handleKingMemberInfo()
    PanelKing.addButtonClickEvent()
    PanelKing.registeEvent()
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="info"}))
    return var.widget
end

function PanelKing.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_KING_STATE, PanelKing.handleKingState)
    :addEventListener(Notify.EVENT_KING_INFO_CHANGE, PanelKing.handlelKingInfoChange)
    :addEventListener(Notify.EVENT_KING_MEMBER_INFO, PanelKing.handleKingMemberInfo)
end

function PanelKing.addButtonClickEvent()
    local btncfg = {
        ["Button_notice"]={},
        ["Button_title"]={},
        ["Button_go"]={},
        ["Button_apply"]={},
        ["Button_award"]={},
    }
    local function btnCallBack(pSender)
        local btnName =  pSender:getName()
        if btnName == "Button_notice" then
            PanelKing.onClickNoticeBtn()
        elseif btnName == "Button_title" then
            PanelKing.onClickTitleBtn()
        elseif btnName == "Button_go" then
            if game.getRoleLevel() < NetClient.mKingInfo.goto_level then
                NetClient:alertLocalMsg(game.make_str_with_color(Const.COLOR_GREEN_1_STR,NetClient.mKingInfo.goto_level.."级").."以后可以传送至皇城攻城区域！","alert")
                return
            end
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="gotomap"}))
            EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_king"})
        elseif btnName == "Button_apply" then
            PanelKing.onClickApply()
        elseif btnName == "Button_award" then
            if not game.isKingLeader() then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "alert", visible = true,
                    lblAlert = {"每日占城奖励: "..game.make_str_with_color(Const.COLOR_GREEN_1_STR,NetClient.mKingInfo.prize_num.."元宝"),"对不起,你不是皇城城主,无法领取！"},
                    alertTitle = "关 闭",
                }
                NetClient:dispatchEvent(param)
                return
            end
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="getprize"}))
        end
    end
    for k, v in pairs(btncfg) do
        UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName(k),callback=btnCallBack,types=v})
    end
end

function PanelKing.onClickApply()
    local param = {
    	name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm =  {"申请抢夺皇城需缴纳"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,NetClient.mKingInfo.war_cost.."金币"),"确定申请？"},
    	confirmTitle = "申 请", cancelTitle = "算 了",
    	confirmCallBack = function ()
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="reqwar"}))
    	end
    }
    NetClient:dispatchEvent(param)
end

function PanelKing.onClickNoticeBtn()
    if not game.isKingLeader() then
        NetClient:alertLocalMsg("您不是皇城城主，无法发送广播！","alert")
        return
    end

    if not NetClient.mKingInfo.sendmsg_num or NetClient.mKingInfo.sendmsg_num == 0 then
        NetClient:alertLocalMsg("对不起,今日皇城特权广播次数已经用完！","alert")
        return
    end

    local noticePanel = var.widget:getWidgetByName("Panel_server_notice"):show()
    noticePanel:setTouchEnabled(true)

    local inputBg = noticePanel:getWidgetByName("ImageView_inputBg")
    local bgSize = inputBg:getContentSize()
    local mSendText = util.newEditBox({
        image = "null.png",
        size = bgSize,
        x = 0,
        y = 0,
--        placeHolder = "输入要广播的消息",
        placeHolderSize = 28,
        fontSize = 24,
        anchor = cc.p(0,0),
    })

    mSendText:setMaxLength(40)
    inputBg:addChild(mSendText)

    var.mClosePanel = false
    local function pushAlertButton(pSender)
        local btnName = pSender:getName()
        if btnName == "Button_confirm" then
            local msgstr = mSendText:getText()
            if msgstr == "" then
                NetClient:alertLocalMsg("请输入广播内容！","alert")
                return
            end
            mSendText:setText("")
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="noticeServer", msg=msgstr}))
        end
        noticePanel:hide()
        var.mClosePanel = true
    end
    noticePanel:getWidgetByName("Button_confirm"):addClickEventListener(pushAlertButton)
    noticePanel:getWidgetByName("Button_cancel"):addClickEventListener(pushAlertButton)

    noticePanel:getWidgetByName("Text_num"):setString(NetClient.mKingInfo.sendmsg_num or 0)
end

function PanelKing.onClickTitleBtn()
    local noticePanel = var.widget:getWidgetByName("Panel_title"):show()
    noticePanel:setTouchEnabled(true)
    var.mClosePanel = false

    local statusdef = NetClient:getStatusDefByID(Const.STATUS_BUFF_KING_LEADER,1)
    if statusdef and not var.statusInit then
        noticePanel:getWidgetByName("Text_status_wlgj_value"):setString(statusdef.mDC.."-"..statusdef.mDCmax)
        noticePanel:getWidgetByName("Text_status_mfgj_value"):setString(statusdef.mMC.."-"..statusdef.mMCmax)
        noticePanel:getWidgetByName("Text_status_dsgj_value"):setString(statusdef.mSC.."-"..statusdef.mSCmax)
        var.statusInit = true
    end

    local function pushAlertButton(pSender)
        local btnName = pSender:getName()
        if btnName == "Button_confirm" then
            if not game.isKingLeader() then
                NetClient:alertLocalMsg("您不是皇城城主，无法领取称号！", "alert")
                return
            end
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({panelid = PANELID, actionid="godpower"}))
        end
        noticePanel:hide()
        var.mClosePanel = true
    end
    noticePanel:getWidgetByName("Button_confirm"):addClickEventListener(pushAlertButton)
    noticePanel:getWidgetByName("Button_cancel"):addClickEventListener(pushAlertButton)

    local msgstr ="您不是皇城城主，无法领取称号！"
    if game.isKingLeader() then
        msgstr ="城主专属称号，使用称号增加城主基础属性！"
    end

    noticePanel:getWidgetByName("Text_msg"):setString(msgstr)
end

function PanelKing.handleKingState()
    var.widget:getWidgetByName("Text_king_guild"):setString(NetClient.mKingGuild ~= "" and NetClient.mKingGuild or "无")
end

function PanelKing.handlelKingInfoChange()
    if not NetClient.mKingInfo then
        var.widget:getWidgetByName("Text_days"):setString("0天")
        var.widget:getWidgetByName("Text_open_time"):setString("暂无攻城申请")
    else
        var.widget:getWidgetByName("Text_days"):setString(NetClient.mKingInfo.kingTime.."天")
        var.widget:getWidgetByName("Text_open_time"):setString(NetClient.mKingInfo.warTime)
    end
end

function PanelKing.handleKingMemberInfo()
    local curPanel = var.widget:getWidgetByName("Image_show_bg")
    curPanel:getWidgetByName("Panel_insight"):removeAllChildren()
    if NetClient.mHasKing == 1 then
        local memberinfos = NetClient:getKingMemberInfoByTitle(Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADMIN)
        local position
        if memberinfos[1] then
            curPanel:getWidgetByName("Text_chengzhu"):setString(memberinfos[1].name)
            position = cc.p(curPanel:getWidgetByName("Text_chengzhu"):getPositionX(),curPanel:getWidgetByName("Text_chengzhu"):getPositionY()+20)
            PanelKing.updateInSight(position, memberinfos[1].wing,memberinfos[1].cloth,memberinfos[1].weapon)
        else
            curPanel:getWidgetByName("Text_chengzhu"):setString("虚位以待")
        end

        --
        memberinfos =  NetClient:getKingMemberInfoByTitle(Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV)
        if memberinfos[1] then
            curPanel:getWidgetByName("Text_fuchengzhu"):setString(memberinfos[1].name)
            position = cc.p(curPanel:getWidgetByName("Text_fuchengzhu"):getPositionX(),curPanel:getWidgetByName("Text_fuchengzhu"):getPositionY()+50)
            PanelKing.updateInSight(position, memberinfos[1].wing,memberinfos[1].cloth,memberinfos[1].weapon)
        else
            curPanel:getWidgetByName("Text_fuchengzhu"):setString("虚位以待")
        end

        --
        memberinfos =  NetClient:getKingMemberInfoByTitle(Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER)
        for i = 1, 3 do
            local minfo = memberinfos[i]
            if minfo then
                curPanel:getWidgetByName("Text_zhanglao_"..i):setString(minfo.name)
                position = cc.p(curPanel:getWidgetByName("Text_zhanglao_"..i):getPositionX(),curPanel:getWidgetByName("Text_zhanglao_"..i):getPositionY())
                if i == 1 then
                    position.y = position.y+50
                else
                    position.y = position.y+0
                end

                PanelKing.updateInSight(position, minfo.wing,minfo.cloth,minfo.weapon)
            else
                curPanel:getWidgetByName("Text_zhanglao_"..i):setString("虚位以待")
            end
        end
    else
        curPanel:getWidgetByName("Text_chengzhu"):setString("虚位以待")
        curPanel:getWidgetByName("Text_fuchengzhu"):setString("虚位以待")
        curPanel:getWidgetByName("Text_zhanglao_1"):setString("虚位以待")
        curPanel:getWidgetByName("Text_zhanglao_2"):setString("虚位以待")
        curPanel:getWidgetByName("Text_zhanglao_3"):setString("虚位以待")
    end
end

function PanelKing.updateInSight(position, wing, cloth, weapon)
    if wing then
        ccui.ImageView:create("stateitem/"..wing..".png",UI_TEX_TYPE_LOCAL)
        :align(display.CENTER, position.x-10, position.y/2)
        :addTo(var.widget:getWidgetByName("Image_show_bg"):getWidgetByName("Panel_insight"))
    end

    local itemdef = NetClient:getItemDefByID(cloth)
    if itemdef then
        cloth = itemdef.mIconID
    end
    ccui.ImageView:create("stateitem/"..cloth..".png",UI_TEX_TYPE_LOCAL)
    :align(display.CENTER, position.x, position.y/2)
    :addTo(var.widget:getWidgetByName("Image_show_bg"):getWidgetByName("Panel_insight"))

    local itemdef = NetClient:getItemDefByID(weapon)
    if itemdef then
        ccui.ImageView:create("stateitem/"..weapon..".png",UI_TEX_TYPE_LOCAL)
        :align(display.CENTER, position.x, position.y/2)
        :addTo(var.widget:getWidgetByName("Image_show_bg"):getWidgetByName("Panel_insight"))
    end
end

function PanelKing.checkPanelClose()
    return var.mClosePanel
end

return PanelKing