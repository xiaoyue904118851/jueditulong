--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/17 15:03
-- To change this template use File | Settings | File Templates.
--
local EquipView = {}
local var = {}


------ 时装 装备切换
local TAG_VIEW_EQUIP = 1
local TAG_VIEW_FASHION = 2

function EquipView.initView(params)
    local params = params or {}
    var = {}
    var.mainRoleInfo = game.GetMainNetGhost()
    var.itemInitListener = params.itemInitistener

    var.rootidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Equip.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = var.rootidget:getChildByName("Panel_equip")
    var.widget:getWidgetByName("Label_RoleName"):hide()
    var.panelEquip = var.widget:getWidgetByName("Panel_zhuangbei")
    var.panelFashion = var.widget:getWidgetByName("Panel_shizhuang"):hide()

    EquipView.showRoleInfo()
    EquipView.addBtnClickedEvent()
    var.showEquipType = TAG_VIEW_EQUIP
    EquipView.registeEvent()

    local function showfun()
        EquipView.updateCloth()
        EquipView.updatePositionItemInfo()
    end

    if params.delay and params.delay > 0 then
        var.widget:runAction(cc.Sequence:create(
                cc.DelayTime:create(params.delay),
                cc.CallFunc:create(function()
                    showfun()
                end)
        ))
    else
        showfun()
    end
end

function EquipView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_AVATAR_CHANGE, EquipView.updateCloth)
end

function EquipView.updateGongui()
    if game.haveGuild() then
        var.widget:getWidgetByName("Text_gonghui"):setString("行会："..NetCC:getMainGhost():NetAttr(Const.net_guild_name))
    else
        var.widget:getWidgetByName("Text_gonghui"):setString("")
    end
end

function EquipView.updateTitle()
    var.widget:getWidgetByName("Text_title"):setString("")
end

function EquipView.updateLv()
    var.widget:getWidgetByName("Label_RoleLevel"):setString("Lv:"..game.getRoleLevel()):hide()
end

function EquipView.updateName()
    var.widget:getWidgetByName("Label_RoleName"):show():setString(var.mainRoleInfo:NetAttr(Const.net_name))
end

function EquipView.updatePoints()
    var.widget:getWidgetByName("AtlasLabel_point"):setString(NetClient.mCharacter.mFightPoint):hide()
end

function EquipView.showRoleInfo()
    EquipView.updateGongui()
    EquipView.updateTitle()
    EquipView.updateLv()
    EquipView.updateName()
    EquipView.updatePoints()
end

function EquipView.addBtnClickedEvent()
    local function btnClicked(pSender)
        local btnName = pSender:getName()
        if btnName == "Button_goequip" then
            var.showEquipType = TAG_VIEW_EQUIP
            EquipView.updatePositionItemInfo()
        elseif btnName == "Button_gofashion" then
--            var.showEquipType = TAG_VIEW_FASHION
--            EquipView.updatePositionItemInfo()
        end
    end

    var.widget:getWidgetByName("Button_goequip")
    :addClickEventListener(function (pSender)
        btnClicked(pSender)
    end)

    var.widget:getWidgetByName("Button_gofashion")
    :addClickEventListener(function (pSender)
        btnClicked(pSender)
    end)
end

function EquipView.updatePositionItemInfo()
    var.panelEquip:setVisible(var.showEquipType == TAG_VIEW_EQUIP)
    var.panelFashion:setVisible(var.showEquipType == TAG_VIEW_FASHION)

    local positionCfg
    local panelWidget
    if var.showEquipType == TAG_VIEW_EQUIP then
        positionCfg = Const.EQUIP_INFO
        panelWidget = var.panelEquip:getChildByName("Panel_icon_bg")
    else
        positionCfg = Const.FASHION_INFO
        panelWidget = var.panelFashion
    end

    for designPos = 1, #positionCfg do
        local equipCfg = positionCfg[designPos]
        if equipCfg.pos then
            local equip_block = panelWidget:getChildByName("icon_"..designPos)
            if equip_block then
                if var.itemInitListener then var.itemInitListener({pos = equipCfg.pos, parent = equip_block}) end
            end
        end
    end

end

function EquipView.updateCloth()
    if not var.aniBg then
        var.aniBg = var.widget:getWidgetByName("Panel_role"):show()
    end

    var.aniBg:removeAllChildren()
    game.getMyInsigh(var.aniBg)
end

return EquipView