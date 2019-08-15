--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/16 16:19
-- To change this template use File | Settings | File Templates.
-- RoleAttrView

local RoleAttrView = {}
local var = {}

function RoleAttrView.initView(params)
    local params = params or {}
    var = {}
    var.equipVisible = true
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_RoleAttr.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_bg")
    var.mainRoleInfo = game.GetMainRole()
    RoleAttrView.addEquipInfo()
    RoleAttrView.addBtnClickedEvent()
    RoleAttrView.updateRightAttr()
    RoleAttrView.updatePoints()
    RoleAttrView.registeEvent()
    return widget
end

function RoleAttrView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_ATTRIBUTE_CHANGE, RoleAttrView.updateAllAttr)
end

function RoleAttrView.addBtnClickedEvent()
end

function RoleAttrView.getPerValue(value)
    if not value then value = 0 end
    return string.format("%0.2f%%",value/100)
end

function RoleAttrView.updateRightAttr()
    local netChar = NetClient.mCharacter
    local zslevel = game.getZsLevel()
    local cf = {
        {name = "Label_Level", value = game.getRoleLevel() },
        {name = "Text_zs_level", value = string.format("[%d转]", zslevel) },

        {name = "Label_Hp", value = var.mainRoleInfo:NetAttr(Const.net_hp).."/"..var.mainRoleInfo:NetAttr(Const.net_maxhp)},
        {name = "Label_MagValue", value = var.mainRoleInfo:NetAttr(Const.net_mp).."/"..var.mainRoleInfo:NetAttr(Const.net_maxmp)},
        {name = "Label_Ng", value = var.mainRoleInfo:NetAttr(Const.net_ng).."/"..var.mainRoleInfo:NetAttr(Const.net_maxng)},

        {name = "Label_PhyAtk", value = tostring(netChar.mDC).."-"..tostring(netChar.mMaxDC)},
        {name = "Label_MagAtk", value = tostring(netChar.mMC).."-"..tostring(netChar.mMaxMC)},
        {name = "Label_DaoAtk", value = tostring(netChar.mSC).."-"..tostring(netChar.mMaxSC)},

        {name = "Label_PhyDef", value = tostring(netChar.mAC).."-"..tostring(netChar.mMaxAC)},
        {name = "Label_MagDef", value = tostring(netChar.mMAC).."-"..tostring(netChar.mMaxMAC)},


        {name = "Label_Xingyun", value = RoleAttrView.getPerValue(netChar.mLuck)},
        {name = "Label_BaojiProb", value = RoleAttrView.getPerValue(netChar.mBaoji)}, -- 暴击几率
        {name = "Label_BaojiHurt", value = netChar.mBaojiPres},
        {name = "Label_BaoShangMian", value = RoleAttrView.getPerValue(netChar.mBaojiCounteract)},
        {name = "Label_BaoShangDi", value = netChar.mBaojiCounteractPres},

        {name = "Label_Pk", value = var.mainRoleInfo:NetAttr(Const.net_pkvalue)},
        {name = "Label_Shanbi", value = netChar.mDodge},
        {name = "Label_Zhunque", value = netChar.mAccuracy},
        {name = "Label_Renxing", value = RoleAttrView.getPerValue(netChar.mToughness)},
        {name = "Label_MagShan", value = netChar.mAntiMagic},
        {name = "Label_Shanmian", value = RoleAttrView.getPerValue(netChar.mXishou)},
        {name = "Label_Fantan", value = RoleAttrView.getPerValue(netChar.mFantan_pres)},
        {name = "Label_hsfy", value = RoleAttrView.getPerValue(netChar.mIgnoredef)},
        {name = "Label_GodAtk", value = netChar.mGodAtk},
        {name = "Label_GodDef", value = netChar.mGodDef},
    }
    local rightWidget = var.widget:getWidgetByName("Image_right")
    if zslevel < 1 then
        rightWidget:getWidgetByName("Text_zs_level"):hide()
        rightWidget:getWidgetByName("Label_Level"):setPositionX(111-rightWidget:getWidgetByName("Label_Level"):getContentSize().width/2)
    else
        rightWidget:getWidgetByName("Text_zs_level"):show()
        rightWidget:getWidgetByName("Label_Level"):setPositionX(111)
    end

    for _, v in ipairs(cf) do
        if type(v.value) == "boolean" then v.value = 0 end
        if rightWidget:getWidgetByName(v.name) then
            rightWidget:getWidgetByName(v.name):setString(v.value)
        end
    end

    var.widget:getWidgetByName("LoadingBar_hp"):setPercent(var.mainRoleInfo:NetAttr(Const.net_hp)/var.mainRoleInfo:NetAttr(Const.net_maxhp)*100)
    var.widget:getWidgetByName("LoadingBar_mp"):setPercent(var.mainRoleInfo:NetAttr(Const.net_mp)/var.mainRoleInfo:NetAttr(Const.net_maxmp)*100)
    var.widget:getWidgetByName("LoadingBar_ng"):setPercent(var.mainRoleInfo:NetAttr(Const.net_ng)/var.mainRoleInfo:NetAttr(Const.net_maxng)*100)
end

function RoleAttrView.updateAllAttr()
    RoleAttrView.updateRightAttr()
    RoleAttrView.updatePoints()
end

function RoleAttrView.updatePoints()
    local fpanel = var.widget:getWidgetByName("Image_right"):getWidgetByName("Image_zhanlibg"):getWidgetByName("Panel_new_fp")
    local curText = fpanel:getWidgetByName("Image_zhanli_title")
    local disText = fpanel:getWidgetByName("AtlasLabel_zhanli")
    local fparentSize = fpanel:getParent():getContentSize()
    disText:setString(NetClient.mCharacter.mFightPoint)
    fpanel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, fparentSize.height))--:setPositionX(fparentSize.width/2)

end

function RoleAttrView.addEquipInfo()
    require("app.views.EquipView").initView({
        parent = var.widget:getWidgetByName("Image_equipBg"),
        delay = 0.05,
        itemInitistener = function(event)
            UIItem.getItem({parent = event.parent, pos = event.pos,})
        end,
    })
end

return RoleAttrView