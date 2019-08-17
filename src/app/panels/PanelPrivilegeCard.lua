--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2018/01/25 18:49
-- To change this template use File | Settings | File Templates.
--
local ACTIONSET_NAME = "privilege"
local CARD_CFG = {
    {"白银特权","白银","baiyin_ico.png","消耗8888元宝购买7天白银特权？", "白银特权续费7天，需要8888元宝"},
    {"黄金特权","黄金","huangjin_ico.png","消耗18888元宝购买7天黄金特权？", "黄金特权续费7天，需要18888元宝"},
    {"钻石特权","钻石","zuanshi_ico.png","消耗3088元宝购买7天钻石特权？", "钻石特权续费7天，需要88888元宝"},
}
local TUANGOU_ALERT_MSG = {"团购后3种特权各增加7天","需要花费%s元宝"}

local DESC_WIDGET_NAME = "tequandesc"
local PanelPrivilegeCard = {}
local var = {}

function PanelPrivilegeCard.initView(params)
    local params = params or {}
    var = {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelPrivilegeCard/UI_PrivilegeCard_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_card")
    var.widget:getWidgetByName("Panel_content"):hide()
    var.tipsWidget = var.widget:getWidgetByName("Panel_detail")
    var.tipsWidget:hide():setTouchEnabled(true):addClickEventListener(function(pSender)
        pSender:hide()
    end)
    PanelPrivilegeCard.registeEvent()
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="base_data"}))
    return var.widget
end

function PanelPrivilegeCard.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelPrivilegeCard.handleprivilegeCardInfo)
end

function PanelPrivilegeCard.handleprivilegeCardInfo(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
        return
    end

    if d.actionid == "base_data" then
        var.privilegeCardDef = {}
        var.privilegeCardDef.pricelist = {d.param.vcoin[1],d.param.vcoin[2],d.param.vcoin[3]}
        var.privilegeCardDef.oldPrice = d.param.vcoin[5]
        var.privilegeCardDef.newPrice = d.param.vcoin[4]
        var.privilegeCardDef.buffdescList = d.param.attri
        var.privilegeCardDef.awardList = d.param.award
        var.privilegeCardDef.descList = d.param.desc
        PanelPrivilegeCard.updateAllPanel()
    elseif d.actionid == "change_data" then
        PanelPrivilegeCard.updateChangeData()
    end
end

function PanelPrivilegeCard.updateAllPanel()
    var.widget:getWidgetByName("Panel_content"):show()
    PanelPrivilegeCard.updateTuangouInfo()
    PanelPrivilegeCard.updateCardContent()
end

function PanelPrivilegeCard.updateCardContent()
    for k = 1, 3 do
        local node = var.widget:getWidgetByName("Image_tequan"..k)
        if node then
            PanelPrivilegeCard.updateOnePanel(k, node)
        end
    end
end

function PanelPrivilegeCard.updateChangeData()
    for k = 1, 3 do
        local node = var.widget:getWidgetByName("Image_tequan"..k)
        if node then
            PanelPrivilegeCard.updateBuyState(k, node)
        end
    end
end

function PanelPrivilegeCard.updateTuangouInfo()
    local parent = var.widget:getWidgetByName("Image_tuangou")
    parent:getWidgetByName("label_yuanjia"):setString(var.privilegeCardDef.oldPrice)
    parent:getWidgetByName("label_xianjia"):setString(var.privilegeCardDef.newPrice)
    local zhekou = string.format("%0.2f",var.privilegeCardDef.newPrice/var.privilegeCardDef.oldPrice)
    parent:getWidgetByName("Button_tuangou"):getWidgetByName("Text_zhekou"):setString(string.format("%0.1f",zhekou*10))
    parent:getWidgetByName("Button_tuangou"):show():addClickEventListener(function (pSender)
        game.checkBtnClick()
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true,
            lblConfirm = {TUANGOU_ALERT_MSG[1], string.format(TUANGOU_ALERT_MSG[2], game.make_str_with_color(Const.COLOR_GREEN_1_STR,var.privilegeCardDef.newPrice))},
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function ()
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="renew",params=4}))
            end
        }
        NetClient:dispatchEvent(param)
    end)
end

function PanelPrivilegeCard.updateOnePanel(k, node)
    local buffnodename = "buffnode"
    if node:getChildByName(buffnodename) then
        node:removeChildByName(buffnodename)
    end

--    buff描述
    local buffmsg = var.privilegeCardDef.buffdescList[k]
    if buffmsg then
        local richLabel, richWidget = util.newRichLabel(cc.size(300, 0), 0)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel,  buffmsg,"", 26, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
        richWidget:align(display.LEFT_TOP,25,360)
        richWidget:setName(buffnodename)
        richWidget:addTo(node)
    end

--    道具奖励
    local awardList = var.privilegeCardDef.awardList[k]
    for i = 1, 4 do
        local itemnode = node:getWidgetByName("item_icon_"..i)
        if awardList[i] then
            itemnode:show()
            UIItem.cleanSimpleItem(itemnode)
            itemnode:setTouchEnabled(true)
            UIItem.getSimpleItem({
                parent = itemnode,
                typeId = awardList[i].typeid,
                num = awardList[i].num,
                bind = awardList[i].bindflag,
            })
        else
            itemnode:hide()
        end
    end

    node:getWidgetByName("Button_tips"):addClickEventListener(function (pSender)
        PanelPrivilegeCard.showDetail(k)
    end)

    PanelPrivilegeCard.updateBuyState(k, node)
end

function PanelPrivilegeCard.onClickedBuy(k,msg)
    local param = {
        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = msg,
        confirmTitle = "确 定", cancelTitle = "取 消",
        confirmCallBack = function ()
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="renew",params=k}))
        end
    }
    NetClient:dispatchEvent(param)
end

function PanelPrivilegeCard.getLeftDay(sec)
    local day = math.floor(sec / 86400)
    if day < 1 then return 1 end
    if sec - day*86400 > 0 then
        day = day + 1
    end
    return day
end

--    剩余时间
function PanelPrivilegeCard.updateBuyState(k, node)
    local awardflag = NetClient.mPrivilegeCardInfo.award_flag[k]
    if not NetClient.mPrivilegeCardInfo or awardflag == -1 or (NetClient.mPrivilegeCardInfo and NetClient.mPrivilegeCardInfo.left_time[k] <= 0 ) then
        --     没有购买
        node:getWidgetByName("Image_day_un"):hide()
        node:getWidgetByName("Image_unopen"):show()
        node:getWidgetByName("AtlasLabel_leftday"):hide()
        node:getWidgetByName("Button_get_award"):hide()
        node:getWidgetByName("Image_btn_got_flag"):hide()
        node:getWidgetByName("Button_buy"):setTitleText("购  买"):setPositionX(node:getContentSize().width/2)
        node:getWidgetByName("Button_buy"):addClickEventListener(function (pSender)
            game.checkBtnClick()
            PanelPrivilegeCard.onClickedBuy(k,CARD_CFG[k][4])
        end)
        node:getWidgetByName("Button_tips_time"):addClickEventListener(function (pSender)
            UIAnimation.oneTips({
                parent = pSender,
                msg = "未开启",
            })
        end)
    else
        --    购买了
        node:getWidgetByName("Image_day_un"):show()
        node:getWidgetByName("Image_unopen"):hide()
        local timeLabel = node:getWidgetByName("AtlasLabel_leftday"):show()
        timeLabel:setString(PanelPrivilegeCard.getLeftDay( NetClient.mPrivilegeCardInfo.left_time[k]))
        node:getWidgetByName("Image_day_un"):setPositionX(timeLabel:getPositionX() + timeLabel:getContentSize().width + 3)
        node:getWidgetByName("Button_buy"):setTitleText("续  费"):setPositionX(86)
        node:getWidgetByName("Button_buy"):addClickEventListener(function (pSender)
            game.checkBtnClick()
            PanelPrivilegeCard.onClickedBuy(k,CARD_CFG[k][5])
        end)
        local gotbtn = node:getWidgetByName("Button_get_award")
        if awardflag == 0 then
        --    未领取
            node:getWidgetByName("Image_btn_got_flag"):hide()

            gotbtn:show():addClickEventListener(function (pSender)
                game.checkBtnClick()
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="give_award",params=k}))
            end)
            if not gotbtn:getChildByName("effect") then
                gameEffect.getNormalBtnSelectEffect()
                :setPosition(cc.p(gotbtn:getContentSize().width/2,gotbtn:getContentSize().height/2))
                :addTo(gotbtn)
                :setName("effect")
            end
        else
            gotbtn:hide()
            if gotbtn:getChildByName("effect") then
                gotbtn:removeChildByName("effect")
            end
            node:getWidgetByName("Image_btn_got_flag"):show()
        end
        node:getWidgetByName("Button_tips_time"):addClickEventListener(function (pSender)
            UIAnimation.oneTips({
                parent = pSender,
                msg = "剩余时间："..DateHelper.convertSecondsToStr(NetClient.mPrivilegeCardInfo.left_time[k]),
            })
        end)
    end
    node:getWidgetByName("Button_buy"):getWidgetByName("Text_price"):setString(var.privilegeCardDef.pricelist[k])
end

function PanelPrivilegeCard.showDetail(k)
    if k < 1 or k > 3 then return end
    var.tipsWidget:getWidgetByName("Text_tequan_name"):setString(CARD_CFG[k][1])
    var.tipsWidget:getWidgetByName("Text_level_value"):setString(CARD_CFG[k][2])
    var.tipsWidget:getWidgetByName("Image_icon"):loadTexture(CARD_CFG[k][3], UI_TEX_TYPE_PLIST)

    if var.tipsWidget:getWidgetByName("Image_bg"):getWidgetByName(DESC_WIDGET_NAME) then
        var.tipsWidget:getWidgetByName("Image_bg"):removeChildByName(DESC_WIDGET_NAME)
    end

    if var.privilegeCardDef.descList[k] then
        local msg = table.concat(var.privilegeCardDef.descList[k],"<br>")
        local richLabel, richWidget = util.newRichLabel(cc.size(var.tipsWidget:getContentSize().width-50, 0), 1)
        richWidget.richLabel = richLabel
        util.setRichLabel(richLabel, msg,"", 24, Const.COLOR_YELLOW_1_OX)
        richWidget:setContentSize(cc.size(richLabel:getRealWidth(), richLabel:getRealHeight()))
        richWidget:align(display.LEFT_TOP, 20, 230)
        richWidget:setName(DESC_WIDGET_NAME)
        var.tipsWidget:getWidgetByName("Image_bg"):addChild(richWidget)
    end

    var.tipsWidget:show()
end

function PanelPrivilegeCard.checkPanelClose()
    if var.tipsWidget:isVisible() then
        var.tipsWidget:hide()
        return false
    end
    return true
end

return PanelPrivilegeCard