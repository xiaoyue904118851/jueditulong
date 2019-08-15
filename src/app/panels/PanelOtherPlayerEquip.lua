--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/15 16:35
-- To change this template use File | Settings | File Templates.
-- PanelOtherPlayerEquip

local PanelOtherPlayerEquip = {}
local var = {}
------ 时装 装备切换
local TAG_VIEW_EQUIP = 1
local TAG_VIEW_FASHION = 2

function PanelOtherPlayerEquip.initView(params)
    local params = params or {}
    var = {}
    var.playerName = params.extend.pdata.playerName
    var.showEquipType = TAG_VIEW_EQUIP
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelOtherPlayerEquip/UI_OtherPlayerEquip_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_otherplayerinfo")
    var.panelEquip = var.widget:getWidgetByName("Panel_zhuangbei")
    var.panelFashion = var.widget:getWidgetByName("Panel_shizhuang"):hide()
    var.widget:getWidgetByName("Label_RoleName"):setString(var.playerName)
    var.widget:getWidgetByName("Panel_equip"):getWidgetByName("Text_gonghui"):hide()
    var.widget:getWidgetByName("Panel_equip"):getWidgetByName("Text_title"):hide()
    PanelOtherPlayerEquip.updateAvatar()
    PanelOtherPlayerEquip.updatePositionItemInfo()
    PanelOtherPlayerEquip.registeEvent()
    return var.widget
end

function PanelOtherPlayerEquip.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PLAYER_INFO, PanelOtherPlayerEquip.handleAvatarInfo)
    :addEventListener(Notify.EVENT_PLAYEREQUIP_INFO, PanelOtherPlayerEquip.handelPositionInfo)
end

function PanelOtherPlayerEquip.handleAvatarInfo(event)
    if NetClient.other_avatar_save ~= "saved" then
        return
    end

    if event.pname ~= var.playerName then return end
    PanelOtherPlayerEquip.updateAvatar()
    PanelOtherPlayerEquip.showRoleInfo()
end

function PanelOtherPlayerEquip.handelPositionInfo()
    if NetClient.other_equip_save ~= "saved" then
        return
    end
    PanelOtherPlayerEquip.updatePositionItemInfo()
end

function PanelOtherPlayerEquip.updatePositionItemInfo()
    var.panelEquip:setVisible(var.showEquipType == TAG_VIEW_EQUIP)
    var.panelFashion:setVisible(var.showEquipType == TAG_VIEW_FASHION)

    if NetClient.other_equip_save ~= "saved" then
        return
    end

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
                local netitem = NetClient.mOthersItems[equipCfg.pos]
                if netitem then
                    UIItem.getSimpleItem({parent = equip_block,
                        typeId = netitem.mTypeID,
                        level = netitem.mLevel,
                        bind = netitem.mItemFlags,
                        itemCallBack = function(pSender)
                        NetClient:dispatchEvent(
                            {
                                name = Notify.EVENT_HANDLE_ITEM_TIPS,
                                pos = equipCfg.pos,
                                otherItem = netitem,
                                typeId = netitem.mTypeID,
                            })
                    end
                    })
                else
                    UIItem.cleanSimpleItem(equip_block)
                    equip_block:setTouchEnabled(false)
                end
            end
        end
    end

end

function PanelOtherPlayerEquip.updateAvatar()
    local playerEquip = NetClient.m_PlayerEquip[var.playerName]
    if not playerEquip then
--        print("PanelOtherPlayerEquip.updateAvatar==>>playerEquip is null,return")
        return
    end
    var.widget:getWidgetByName("Panel_role"):removeAllChildren()

    -- 翅膀
    local wing
    if playerEquip.wing and playerEquip.wing > 0 then
        wing=playerEquip.wing
    end

    -- 衣服
    local cloth
    local netitem = NetClient.mOthersItems[Const.ITEM_CLOTH_POSITION]
    if netitem then
        local itemdef = NetClient:getItemDefByID(netitem.mTypeID)
        if itemdef then
            cloth = itemdef.mIconID
        end
    else
        cloth = Const.DEFAULT_STATEITEM[playerEquip.gender]
    end

    -- 武器
    local weapon
    local netitem = NetClient.mOthersItems[Const.ITEM_WEAPON_POSITION]
    if netitem then
        local itemdef = NetClient:getItemDefByID(netitem.mTypeID)
        if itemdef then
            weapon = itemdef.mIconID
        end
    end

    game.getInsigh({parent = var.widget:getWidgetByName("Panel_role"),wing = wing,cloth = cloth,weapon = weapon})
end

function PanelOtherPlayerEquip.showRoleInfo()
    local playerEquip = NetClient.m_PlayerEquip[var.playerName]
    if not playerEquip then return end

    local roleinfoWidget = var.widget:getWidgetByName("Panel_equip")

    roleinfoWidget:getWidgetByName("Text_title"):setString("")


    roleinfoWidget:getWidgetByName("Label_RoleName"):setString(var.playerName) -- 称号和名字一起
    if playerEquip.guild ~= "" then
        roleinfoWidget:getWidgetByName("Text_gonghui"):show():setString("行会："..playerEquip.guild)
    else
        roleinfoWidget:getWidgetByName("Text_gonghui"):hide()
    end

    roleinfoWidget:getWidgetByName("Label_RoleLevel"):setString(playerEquip.reinlv.."转"..playerEquip.lv.."级")


    local fpanel = roleinfoWidget:getWidgetByName("Panel_new_fp")
    local curText = fpanel:getWidgetByName("Image_zhanli_title")
    local disText = fpanel:getWidgetByName("AtlasLabel_zhanli")
    local fparentSize = fpanel:getParent():getContentSize()
    disText:setString(playerEquip.fightpoint)
    fpanel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, fparentSize.height))--:setPositionX(fparentSize.width/2)

end

return PanelOtherPlayerEquip