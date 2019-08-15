--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/01/19 16:09
-- To change this template use File | Settings | File Templates.
--

local PanelSpecailRing = {}
local var = {}
local ACTIONSET_NAME = "ring"

local  RING_EFFECT = {
    [10010]={plist = "10010", pattern = "10010_000%02d.png", begin = 0, length = 10},
    [10020]={plist = "10020", pattern = "10020_000%02d.png", begin = 0, length = 10},
    [10030]={plist = "10030", pattern = "10030_000%02d.png", begin = 0, length = 10},
    [10040]={plist = "10040", pattern = "10040_000%02d.png", begin = 0, length = 10},
    [10050]={plist = "10050", pattern = "10050_000%02d.png", begin = 0, length = 10},
    [10060]={plist = "10060", pattern = "10060_000%02d.png", begin = 0, length = 10},
    [10070]={plist = "10070", pattern = "10070_000%02d.png", begin = 0, length = 9},
    [10080]={plist = "10080", pattern = "10080_000%02d.png", begin = 0, length = 10},
}

function PanelSpecailRing.initView(params)
    local params = params or {}
    var = {}
    var.selectIdx = 1
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSpecailRing/UI_SpecailRing_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_ring")
    PanelSpecailRing.initWidget()
    PanelSpecailRing.updateListView()
    PanelSpecailRing.registeEvent()
    return var.widget
end

function PanelSpecailRing.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelSpecailRing.handleRingMsg)
end

function PanelSpecailRing.handleRingMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == ACTIONSET_NAME then
        if d.actionid then
            if d.actionid == "query_all_info" then
                PanelSpecailRing.updateListView()
            elseif d.actionid == "act_info" or d.actionid == "ring_level" then
                PanelSpecailRing.updateListView()
            end
        end
    end
end

function PanelSpecailRing.initWidget()
    var.tipPanel = var.widget:getWidgetByName("Panel_skill_tips"):hide()
    var.tipPanel:addClickEventListener(function(pSender)
        var.tipPanel:hide()
    end)
    var.listview = var.widget:getWidgetByName("ListView_tejie")
    var.copyNode =  var.widget:getWidgetByName("Panel_listitem"):hide()
    var.rightPanel = var.widget:getWidgetByName("Image_rightbg"):hide()

    var.nameImg = var.rightPanel:getWidgetByName("Image_tejie_name")
    var.fightImg = var.rightPanel:getWidgetByName("Image_fight_name"):getWidgetByName("atlas_fight")
    var.skillBox = var.rightPanel:getWidgetByName("skillBox")
    var.skillBox:getWidgetByName("skillImg"):addClickEventListener(function(pSender)
        PanelSpecailRing.showSkillTip(pSender.ringdef, pSender.isactive)
    end)
    var.upBtn = var.rightPanel:getWidgetByName("Button_get_item"):hide()
    var.upBtn:addClickEventListener(function(pSender)
        local actionid = pSender.actionid
        local ringid = pSender.ringid
        if actionid and actionid ~= "" and ringid and ringid  ~= "" then
            UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.RING})
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = actionid,param={id=ringid}}))
        end

    end)
    var.maxLable = var.rightPanel:getWidgetByName("Text_max"):hide()
    var.effectBg = var.widget:getWidgetByName("img_tejie_show")
end

function PanelSpecailRing.updateListView()
    var.listview:removeAllItems()
    if not NetClient.mRingInfo or not NetClient.mRingInfo.list then return end
    local zslevel = game.getZsLevel()
    local viplevel = game.getVipLevel()
    local rolelevel = game.getRoleLevel()
    for k, v in ipairs(NetClient.mRingInfo.list) do
        local item = var.copyNode:clone():show()
        item:getWidgetByName("label_name"):setString(v.name)
        local tipstr = ""
        local tipcolor = Const.COLOR_YELLOW_1_C3B
        if v.c.zs and v.c.zs > 0 then
            tipstr = "角色转生"..v.c.zs.."级可激活"
        elseif v.c.lv and v.c.lv > 0 then
            tipstr = "角色"..v.c.lv.."级可激活"
        elseif v.c.vip and v.c.vip > 0 then
            tipstr = "VIP"..v.c.vip.."级可激活"
        elseif v.c.need_vcoin and v.c.need_vcoin > 0 then
            tipstr = "花费"..v.c.need_vcoin.."元宝可激活"
            tipcolor = Const.COLOR_GREEN_1_C3B
        end
        item:getWidgetByName("img_icon"):loadTexture(v.id..".png",UI_TEX_TYPE_PLIST)
        item.index = k
        item.isActive = PanelSpecailRing.isActive(v.id)
        if not item.isActive then
            local needzs,needvip,needlv,needvcoin = v.c.zs or 0 ,v.c.vip or 0, v.c.lv or 0, v.c.need_vcoin or 0
            if zslevel >= needzs and viplevel >= needvip and rolelevel >= needlv and NetClient.mCharacter.mVCoin >= needvcoin then
                item.canActive = true
            end
        else
            local upret,needvcoin,curentlv  = PanelSpecailRing.needUp(v.id)
            item.upret = upret
            item.needvcoin = needvcoin
            if upret == 2 then
                tipstr = "花费"..v.c.need_vcoin.."元宝可进阶"
                tipcolor = Const.COLOR_GREEN_1_C3B
            else
                tipstr = "已激活"
                tipcolor = Const.COLOR_YELLOW_1_C3B
            end
            if upret == 2 or upret == 1 then
                item:getWidgetByName("label_name"):setString(v.name..curentlv.."阶")
            end
        end

        item:getWidgetByName("Text_tips"):setString(tipstr)
        item:getWidgetByName("Text_tips"):setTextColor(tipcolor)
        if (not item.isActive and item.canActive ) or (item.isActive and item.upret == 2 and NetClient.mCharacter.mVCoin >= item.needvcoin ) then
            item:getWidgetByName("Image_red"):show()
        else
            item:getWidgetByName("Image_red"):hide()
        end

--        print("", v.name, item.isActive, item.canActive, item.upret, item.needvcoin)
        var.listview:pushBackCustomItem(item)

        item:addClickEventListener(function (pSender)
            PanelSpecailRing.onSlectedItem(pSender)
        end)
    end

    if var.selectIdx then
        local sender = var.listview:getItem(var.selectIdx-1)
        if sender then  PanelSpecailRing.onSlectedItem(sender) end
    end
end

function PanelSpecailRing.isActive(ringid)
    for _, v in ipairs(NetClient.mRingInfo.activeInfo) do
        if v.id == ringid then
            if v.act == 1 then
                return true
            else
                break
            end
        end
    end

    for _, v in ipairs(NetClient.mRingInfo.levelinfo) do
        if v.id == ringid then
            return v.lv > 0
        end
    end
end

-- 0 不需要 1 最高级 2可升级
function PanelSpecailRing.needUp(ringid)
    for _, v in ipairs(NetClient.mRingInfo.levelinfo) do
        if v.id == ringid then
            if v.lv == 0 then
                return -1
            elseif v.lv >= v.maxlv then
                return 1,nil,v.lv
            else
                return 2,v.needvcoin[math.max(1,v.lv)],v.lv
            end
        end
    end

    return 0
end

function PanelSpecailRing.getRingLv(ringid)
    for _, v in ipairs(NetClient.mRingInfo.levelinfo) do
        if v.id == ringid then
            return v.lv
        end
    end
    return 0
end

function PanelSpecailRing.getRingDef(ringid)
    local rlv = PanelSpecailRing.getRingLv(ringid)
    if rlv > 1 then
        ringid = ringid + rlv
    end
    return RingDefData[tostring(ringid)]
end

function PanelSpecailRing.onSlectedItem(pSender)
    if var.upBtn then UIButtonGuide.handleButtonGuideClicked(var.upBtn) end
    var.selectIdx = pSender.index
    for k, v in ipairs(var.listview:getItems()) do
        v:getWidgetByName("img_light"):setVisible(k==pSender.index)
    end
    var.effectBg:removeAllChildren()

    local info = NetClient.mRingInfo.list[pSender.index]
    if not info then
        var.rightPanel:hide()
        return
    end

    var.effectBg:runAction(cc.Sequence:create(
        cc.DelayTime:create(1/60),
        cc.CallFunc:create(function()
            local cfg = RING_EFFECT[info.id]
            local sps = gameEffect.getFrameEffect( "scenebg/ring/"..cfg.plist, cfg.pattern, cfg.begin, cfg.length, 0.1)
            :addTo(var.effectBg)
            sps:setPosition(cc.p(-180,180))
        end)
     ))

    var.nameImg:loadTexture("tj_"..info.id..".jpg",UI_TEX_TYPE_PLIST)

    var.fightImg:setString(info["fp"..game.getRoleJob()])

    local ringid = info.id
    local isActive = pSender.isActive
    local ringdef = PanelSpecailRing.getRingDef(ringid)
    if ringdef then
        local cf = {
            {name = "label_wuli", value = ringdef.mDC.."-"..ringdef.mDCMax},
            {name = "label_mofa", value = ringdef.mMC.."-"..ringdef.mMCMax},
            {name = "label_dsgj", value = ringdef.mSC.."-"..ringdef.mSCMax},

            {name = "label_wufang", value = ringdef.mAC.."-"..ringdef.mACMax},
            {name = "label_mofang", value = ringdef.mMAC.."-"..ringdef.mMACMax},
            {name = "label_hp", value = ringdef.mMaxHp},
        }
        for _, v in ipairs(cf) do
            var.rightPanel:getWidgetByName(v.name):setString(v.value)
        end

        var.skillBox:getWidgetByName("shortcut"):loadTexture("sk_"..ringdef.mSkillIconId..".png",UI_TEX_TYPE_PLIST)
        var.skillBox:getWidgetByName("name"):setString(ringdef.mSkillName)
        var.skillBox:getWidgetByName("skillImg").ringdef = ringdef
        var.skillBox:getWidgetByName("skillImg").isactive = isActive

        -------------按钮的显示
        var.upBtn:show()
        var.upBtn.ringid = ringid
        var.upBtn.actionid = ""
        var.maxLable:hide()
        var.upBtn:setTouchEnabled(true)
        var.upBtn:setBright(true)
        local showeffect = false
        if not isActive then
            var.upBtn:setTitleText("激活")
            var.upBtn.actionid = "active"
            if pSender.canActive then
                showeffect = true
            end
        else
            local upret = pSender.upret
            local needvcoin = pSender.needvcoin
            if  upret == 0 then
                var.upBtn:setTitleText("已激活")
                var.upBtn:setBright(false)
                var.upBtn:setTouchEnabled(false)
            elseif upret == 1 then
                var.upBtn:hide()
                var.maxLable:show()
            elseif upret == 2 then
                var.upBtn:setTitleText("进阶")
                var.upBtn.actionid = "level"
                showeffect = NetClient.mCharacter.mVCoin >= needvcoin
            end
        end
        if showeffect then
            if not var.upeffect then
                var.upeffect = gameEffect.getNormalBtnSelectEffect()
                var.upeffect:setPosition(cc.p(var.upBtn:getContentSize().width/2,var.upBtn:getContentSize().height/2))
                var.upeffect:addTo(var.upBtn)
            end

            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.RING) then
                UIButtonGuide.addGuideTip(var.upBtn,UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.RING),UIButtonGuide.UI_TYPE_LEFT)
            end
        else
            if var.upeffect then
                var.upeffect:removeFromParent()
                var.upeffect = nil
            end
        end
        var.rightPanel:show()
    end
end

function PanelSpecailRing.showSkillTip(ringdef, isActive)
    if not ringdef then return end
    var.tipPanel:getWidgetByName("shortcut"):ignoreContentAdaptWithSize(true)
    var.tipPanel:getWidgetByName("shortcut"):loadTexture("sk_"..ringdef.mSkillIconId..".png",UI_TEX_TYPE_PLIST)
    var.tipPanel:getWidgetByName("name"):setString(ringdef.mSkillName)
    if ringdef.mCD > 0 then
        var.tipPanel:getWidgetByName("Text_cool_value"):setString(string.format("%d分", ringdef.mCD/60))
    else
        var.tipPanel:getWidgetByName("Text_cool_value"):setString("无")
    end

    local statusstr = isActive and "已激活" or "未激活"
    local statuscolor = isActive and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B
    local statuslabel = var.tipPanel:getWidgetByName("Text_status")
    statuslabel:setString(statusstr)
    statuslabel:setTextColor(statuscolor)
    var.tipPanel:getWidgetByName("Text_desc"):setString(ringdef.mDesp)


    var.tipPanel:show()
end

function PanelSpecailRing.onPanelClose()
    UIButtonGuide.setGuideEnd(UIButtonGuide.GUILDTYPE.RING)
end

return PanelSpecailRing