--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/29 18:39
-- To change this template use File | Settings | File Templates.
--
local RoleYuanshenView = {}
local var = {}
local ACTIONSET_NAME = "yuanshenxiuwei"
local MAX_JIE = 16; --最大阶数
local MAX_LEVEL = 1600;

function RoleYuanshenView.initView(params)
    local params = params or {}
    var = {}
    var.autoBuy = false
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_Yuanshen.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_yuanshen")
    RoleYuanshenView.initWidget()
    RoleYuanshenView.resetRightInfo()
    RoleYuanshenView.registeEvent()

    return widget
end

function RoleYuanshenView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_YUANSHEN_CHANGE, RoleYuanshenView.handleYuanshenMsg)
    :addEventListener(Notify.EVENT_LEVEL_CHANGE, RoleYuanshenView.resetNeedInfo)
end

function RoleYuanshenView.initWidget()
    var.leftWidget = var.widget:getWidgetByName("Image_left")
    var.rightWidget = var.widget:getWidgetByName("Image_right")
    var.nameText = var.leftWidget:getWidgetByName("Text_title")
    var.upBtn = var.rightWidget:getWidgetByName("Button_up")
    var.needLevelText = var.rightWidget:getWidgetByName("Text_level_alert")
    var.needPanel = var.rightWidget:getWidgetByName("needPanel")
    local checkBox = var.rightWidget:getWidgetByName("CheckBox_buqi")
    checkBox:addEventListener(function(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            var.autoBuy = true
        elseif eventType == ccui.CheckBoxEventType.unselected then
            var.autoBuy = false
        end
    end)
    checkBox:setSelected(var.autoBuy)
    var.upBtn:addClickEventListener(function (pSender)
        if var.needXiuwei then
            if var.needYb and var.needYb > 0 and var.autoBuy then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否使用"..var.needYb.."元宝补齐余下的修为？",
                    confirmTitle = "确 定", cancelTitle = "取 消",
                    confirmCallBack = function ()
                        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade", params = 3}))
                    end
                }
                NetClient:dispatchEvent(param)
            else
                NetClient:alertLocalMsg("元神修为不足","alert")
            end
        else
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade", params = 1}))
        end
    end)

    var.lightBg = {}
    for i = 1, 5 do
        var.lightBg[i] = var.leftWidget:getWidgetByName("Image_jie_"..i)
        var.lightBg[i]:getWidgetByName("Image_ll"):hide()
    end
    var.tipsBtn = var.rightWidget:getWidgetByName("Button_tips")
    var.tipsBtn:addClickEventListener(function(pSender)
        UIAnimation.oneTips({
            parent = pSender,
            msg = pSender.desp,
        })
    end)

    var.leftWidget:runAction(cc.Sequence:create(
        cc.DelayTime:create(1/60),
        cc.CallFunc:create(function()
            gameEffect.playEffectByType(gameEffect.EFFECT_YUANSHEN_BG)
            :setPosition(cc.p(300,261)):addTo(var.leftWidget)
        end)
    ))
end

function RoleYuanshenView.handleYuanshenMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then return end
    if d.actionid == "paynum" then
        var.needYb = checkint(d.params)
    elseif d.actionid == "query" or d.actionid == "queryyuansheng" then
        RoleYuanshenView.resetRightInfo()
    end
end

function RoleYuanshenView.getNeedInfo(lv)
    for k, v in ipairs(NetClient.mYuanshenInfo.needitems) do
        if v.js == lv then
           return v
        end
    end
end

function RoleYuanshenView.resetRightInfo()
    if var.upBtn then UIButtonGuide.handleButtonGuideClicked(var.upBtn) end
    local rolelevel = game.getRoleLevel()
    local max = false
    if NetClient.mYuanshenInfo.curlevel == MAX_JIE then
        max = true
    end
    if NetClient.mYuanshenInfo.curlevel>=MAX_LEVEL then
        max = true
    end
    local nextNeedInfo
    local curAttrInfo, nextAttrInfo

    if max then
        curAttrInfo = NetClient:getStatusDefByID(Const.STATUS_TYPE_YUANSHENG, NetClient.mYuanshenInfo.curlevel)
    else
        nextAttrInfo = NetClient:getStatusDefByID(Const.STATUS_TYPE_YUANSHENG, NetClient.mYuanshenInfo.nextlevel)
        if NetClient.mYuanshenInfo.curlevel > 0 then
            curAttrInfo = NetClient:getStatusDefByID(Const.STATUS_TYPE_YUANSHENG, NetClient.mYuanshenInfo.curlevel)
        end
    end

    for k, v in ipairs(var.lightBg) do
        if NetClient.mYuanshenInfo.curlevel > 100 and NetClient.mYuanshenInfo.curlevel%100 >= k then
            v:getWidgetByName("Image_ll"):show()
            if not v:getChildByName("lighteffect") then
                gameEffect.playEffectByType(gameEffect.EFFECT_YUANSHEN_LIGHT):setName("lighteffect")
                :setPosition(cc.p(0,0)):addTo(v)
            end
        else
            v:getWidgetByName("Image_ll"):hide()
            if v:getChildByName("lighteffect") then
                v:removeChildByName("lighteffect")
            end
        end
    end

    if curAttrInfo then
        var.nameText:setString(curAttrInfo.mName)
    else
        var.nameText:setString("未激活")
    end

    local cf = {
        {name = "Panel_PhyAtk", dis = ""},
        {name = "Panel_MagAtk", dis = ""},
        {name = "Panel_DaoAtk", dis = ""},
        {name = "Panel_PhyDef", dis = ""},
        {name = "Panel_MagDef", dis = ""},
    }

    local curValue = {
        { min = curAttrInfo and curAttrInfo.mDC or 0 , max = curAttrInfo and curAttrInfo.mDCmax or 0},
        { min = curAttrInfo and curAttrInfo.mMC or 0 , max = curAttrInfo and curAttrInfo.mMCmax or 0},
        { min = curAttrInfo and curAttrInfo.mSC or 0 , max = curAttrInfo and curAttrInfo.mSCmax or 0},

        { min = curAttrInfo and curAttrInfo.mAC or 0 , max = curAttrInfo and curAttrInfo.mACmax or 0},
        { min = curAttrInfo and curAttrInfo.mMAC or 0 , max = curAttrInfo and curAttrInfo.mMACmax or 0},
    }

    local nextValue = {
        { min = nextAttrInfo and nextAttrInfo.mDC or 0 , max = nextAttrInfo and nextAttrInfo.mDCmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mMC or 0 , max = nextAttrInfo and nextAttrInfo.mMCmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mSC or 0 , max = nextAttrInfo and nextAttrInfo.mSCmax or 0},

        { min = nextAttrInfo and nextAttrInfo.mAC or 0 , max = nextAttrInfo and nextAttrInfo.mACmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mMAC or 0 , max = nextAttrInfo and nextAttrInfo.mMACmax or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
        local dismin = nextValue[k].min -  curValue[k].min
        local dismax = nextValue[k].max -  curValue[k].max
        if dismin > 0 or dismax > 0 then
            v.dis = "+"..dismin.."-"..dismax
        end
    end

    local curHpMax = curAttrInfo and curAttrInfo.mHPmax or 0
    local nextHpMax = nextAttrInfo and nextAttrInfo.mHPmax or 0
    local disvalue = nextHpMax - curHpMax
    table.insert(cf, {name = "Panel_HpMax", value = ((curHpMax/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
    for _, v in ipairs(cf) do
        local panel = var.rightWidget:getWidgetByName(v.name)
        local curText = panel:getWidgetByName("Label_Cur")
        local disText = panel:getWidgetByName("Label_Dis")
        local parentSize = panel:getParent():getContentSize()
        curText:setString(v.value):setPositionX(0)
        disText:setString(v.dis):setPositionX(curText:getRightBoundary())
        panel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)

    end
    var.tipsBtn.desp = NetClient.mYuanshenInfo.fromdesp
    RoleYuanshenView.resetNeedInfo()
end

function RoleYuanshenView.resetNeedInfo()
    local rolelevel = game.getRoleLevel()
    local max = false
    if NetClient.mYuanshenInfo.curlevel == MAX_JIE then
        max = true
    end
    if NetClient.mYuanshenInfo.curlevel>=MAX_LEVEL then
        max = true
    end
    local nextNeedInfo

    if not max then
        nextNeedInfo = RoleYuanshenView.getNeedInfo(NetClient.mYuanshenInfo.nextlevel)
    end
    if not max and nextNeedInfo then
        var.needPanel:show()
        cf = {
            {name= "Label_costys", value = nextNeedInfo.nn},
            {name= "Label_haveys", value = NetClient.mYuanshenInfo.yuansheng} ,
        }
        for _, v in ipairs(cf) do
            var.rightWidget:getWidgetByName(v.name):setString(v.value)
        end

        var.needXiuwei = NetClient.mYuanshenInfo.yuansheng <  nextNeedInfo.nn
        local showeffect = false
        if nextNeedInfo.nl > rolelevel then
            if  var.upeffect  then
                var.upeffect:removeFromParent()
                var.upeffect = nil
            end
            var.upBtn:hide()
            var.needLevelText:show()
            local str = "等级达到"..nextNeedInfo.nl.."级可"
            str = str..(NetClient.mYuanshenInfo.curlevel > 0 and "升级" or "激活")
            var.needLevelText:setString(str)
        else
            if var.needXiuwei then
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade", params = 2}))
            end
            var.upBtn:show()
            var.needLevelText:hide()
            var.upBtn:setTitleText(NetClient.mYuanshenInfo.curlevel > 0 and "升 级" or "激 活")
            if NetClient.mYuanshenInfo.yuansheng >= nextNeedInfo.nn then
                showeffect = true
            else
                var.upBtn:setTouchEnabled(true)
                var.upBtn:setBright(true)
            end
        end
        var.rightWidget:getWidgetByName("Panel_max"):hide()

        if showeffect then
            if not var.upeffect then
                var.upeffect = gameEffect.getBtnSelectEffect()
                var.upeffect:setPosition(cc.p(var.upBtn:getContentSize().width/2,var.upBtn:getContentSize().height/2))
                var.upeffect:addTo(var.upBtn)
            end
            var.upBtn:setTouchEnabled(true)
            var.upBtn:setBright(true)
            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.YUANSHEN) then
                UIButtonGuide.addGuideTip(var.upBtn,UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.YUANSHEN),UIButtonGuide.UI_TYPE_LEFT)
            end
        else
            if var.upeffect then
                var.upeffect:removeFromParent()
                var.upeffect = nil
            end
        end
    else
        var.needPanel:hide()
        var.rightWidget:getWidgetByName("Panel_max"):show()
    end
end

return RoleYuanshenView
