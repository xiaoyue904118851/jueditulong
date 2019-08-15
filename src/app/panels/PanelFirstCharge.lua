--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/25 19:03
-- To change this template use File | Settings | File Templates.
--

local PanelFirstCharge = {}
local var = {}
local ACTIONSET_NAME = "firstcharge"

local  WEAPON_EFFECT = {
    [Const.JOB_ZS]={plist = "firstChargeWeapon0", pattern = "firstChargeWeapon0_0000%d.png", begin = 0, length = 8, pos = cc.p(-100,140)},
    [Const.JOB_FS]={plist = "firstChargeWeapon1", pattern = "firstChargeWeapon1_0000%d.png", begin = 0, length = 8, pos = cc.p(-150,240)},
    [Const.JOB_DS]={plist = "firstChargeWeapon2", pattern = "firstChargeWeapon2_0000%d.png", begin = 0, length = 8, pos = cc.p(-100,170)},
}

function PanelFirstCharge.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelFirstCharge/UI_FirstCharge_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_firstcharge")
    var.weaponWidget = var.widget:getWidgetByName("Panel_weapon")
    var.btn = var.widget:getWidgetByName("Button_ChargeNow")
    var.btn:addClickEventListener(function(pSender)
        PanelFirstCharge.onClickBtn()
    end)
    PanelFirstCharge.onGetInfo()
	PanelFirstCharge.registeEvent()
    return var.widget
end

function PanelFirstCharge.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelFirstCharge.handleFirstChargeMsg)
end

function PanelFirstCharge.handleFirstChargeMsg(event)
	if event.type == nil or event.type ~= ACTIONSET_NAME then return end
    local d = util.decode(event.data)
    local type = d.cmd
    if type == "info" then
        PanelFirstCharge.onGetInfo(d)
    elseif type == "getGift" then
--    	var.status = NetClient.mFirstchargeInfo.flag
--    	PanelFirstCharge.updatBtn()
    end
end

function  PanelFirstCharge.onGetInfo()
    if NetClient.mFirstchargeInfo.flag == 1 then
        var.status = 2
    else
        if NetClient.mFirstchargeInfo.chongzi > 0 then
            var.status = 1
        else
            var.status = 0
        end
    end

    PanelFirstCharge.updateItemList()
	PanelFirstCharge.updatBtn()
end

function PanelFirstCharge.updateItemList()
    local list = NetClient.mFirstchargeInfo.itemList or {}
    local index = 1
    for _, v in ipairs(list) do
        local bg = var.widget:getWidgetByName("Panel_award_" .. index)
        if bg then
            UIItem.getSimpleItem({
                parent = bg,
                typeId = v.typeid,
                num = v.num,
                bind = v.bind,
                level = v.upgradelv,
            })
            index = index + 1
        end
    end

    var.weaponWidget:removeAllChildren()
    var.weaponWidget:runAction(cc.Sequence:create(
        cc.DelayTime:create(1/60),
        cc.CallFunc:create(function()
            local cfg = WEAPON_EFFECT[MainRole.mJob]
            gameEffect.getFrameEffect( "scenebg/firstcharge/"..cfg.plist, cfg.pattern, cfg.begin, cfg.length, 0.15)
            :addTo(var.weaponWidget)
            :setPosition(cfg.pos)
        end),
        cc.DelayTime:create(1/60),
        cc.CallFunc:create(function()
        -- 头衔特效
            local paneltitle = var.widget:getWidgetByName("Panel_title")
            gameEffect.getFrameEffect( "scenebg/firstcharge/titleEff", "titleEff_0000%d.png", 0, 8, 0.15)
            :addTo(paneltitle)
            :setPosition(cc.p(-30,170))
        end)
    ))
end

function PanelFirstCharge.updatBtn()
	-- 0 没冲过值不能领 1 可以领取 2 已经领取过了
	local tipStr 
	if var.status == 0 then
		tipStr = "充点小钱"
		var.btn:setTouchEnabled(true)
	elseif var.status == 1 then
		tipStr = "领取奖励"
		var.btn:setTouchEnabled(true)
	elseif var.status == 2 then
		tipStr = "已领取"
		var.btn:setTouchEnabled(false)
	end
	if tipStr then
		var.btn:show()
		var.btn:setTitleText(tipStr)
	else
		var.btn:hide()
	end 	
end

function PanelFirstCharge.onClickBtn()
	if var.status == 1 then
		NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "getReward"}))
	else
		EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL,str = "panel_charge"})
	end
end


return PanelFirstCharge