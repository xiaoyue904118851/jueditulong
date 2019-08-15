--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/21 10:27
-- To change this template use File | Settings | File Templates.
-- PanelChallengeBoss
local ACTIONSET_NAME = "rhuodong"
local CHALLENGE_BOSS = {
    WORLDMAP=1,
    MAYASHENDIAN=2,
    BOSSZHIJIA=3,
    YOUMINGSHENGYU=4,
    GERENBOSS=5,
    KUKAFUBOSS=6,
    TEQUANBOSS=7,
}

local CHALLENGE_BOSS_TAG_TO_INDEX = {
    [CHALLENGE_BOSS.WORLDMAP] = Const.ACTIVIY_INDEX_WORLD_BOSS,
    [CHALLENGE_BOSS.MAYASHENDIAN] = Const.ACTIVIY_INDEX_MAYA,
    [CHALLENGE_BOSS.BOSSZHIJIA] = Const.ACTIVIY_INDEX_BOSS_ZHIJIA,
    [CHALLENGE_BOSS.YOUMINGSHENGYU] = Const.ACTIVIY_INDEX_YOUMINGSHENGYU,
    [CHALLENGE_BOSS.GERENBOSS] = Const.ACTIVIY_INDEX_SINGLEBOSS,
    [CHALLENGE_BOSS.KUKAFUBOSS] = Const.ACTIVIY_INDEX_KUAFU,
}

local PanelChallengeBoss = {}
local var = {}

function PanelChallengeBoss.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = CHALLENGE_BOSS.WORLDMAP
    var.lastcnt = 0
    local selectTab
    if params.extend and params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    else
        if UIRedPoint.checkPersonBoss() > 0 then
            var.selectTab = CHALLENGE_BOSS.GERENBOSS
        end
    end

    var.selectedIndex = 0
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelChallengeBoss/UI_Boss_New_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_boss")
    var.bossWidget = var.widget:getWidgetByName("Panel_normal_boss"):hide()
    var.bossWidget:getWidgetByName("Panel_list_item"):hide()
    var.tequanbossWidget = var.widget:getWidgetByName("Panel_tequan_boss"):hide()
    var.bossListView = var.bossWidget:getWidgetByName("ListView_boss"):hide()
    var.rightWidget = var.bossWidget:getWidgetByName("Image_right")
    PanelChallengeBoss.addMenuTabClickEvent()
    PanelChallengeBoss.registeEvent()
    return var.widget
end

function PanelChallengeBoss.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_ACTIVITY_LIST_UPDATE, PanelChallengeBoss.updateListView)
    :addEventListener(Notify.EVENT_ACTIVITY_SELECT_UPDATE, PanelChallengeBoss.handleSelectMsg)
    :addEventListener(Notify.EVENT_ACTIVITY_TIEM_UPDATE, PanelChallengeBoss.resetListTime)
end

function PanelChallengeBoss.addMenuTabClickEvent()
    local cp = cc.p(125,61)
    RadionButtonGroup = UIRadioButtonGroup.new()
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_worldmap"), position=cp, types={UIRedPoint.REDTYPE.BOSS_WORLD}}))
    :addButton(var.widget:getWidgetByName("Button_maya"))
    :addButton(var.widget:getWidgetByName("Button_bosszhijia"))
    :addButton(var.widget:getWidgetByName("Button_ymsy"))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_geren_boss"), position=cp, types={UIRedPoint.REDTYPE.BOSS_PERSON}}))
    :addButton(var.widget:getWidgetByName("Button_kuafu_boss"))
    :addButton(var.widget:getWidgetByName("Button_tequan_boss"))
    :onButtonSelectChanged(function(event)
        PanelChallengeBoss.updatePanelByTag(event.selected)
    end)
    RadionButtonGroup:setButtonSelected(var.selectTab)
    var.widget:getWidgetByName("Button_kuafu_boss"):hide()
    var.widget:getWidgetByName("Button_tequan_boss"):hide()
    var.widget:getWidgetByName("Button_bosszhijia"):hide()
end

function PanelChallengeBoss.updatePanelByTag(tag)
    var.selectTab = tag
    if tag == CHALLENGE_BOSS.TEQUANBOSS then
        var.bossWidget:hide()
        var.tequanbossWidget:show()

    else
        var.tequanbossWidget:hide()
        var.bossWidget:show()
        if NetClient:getActivityList(CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab]) then
            if var.selectTab == CHALLENGE_BOSS.GERENBOSS then
                PanelChallengeBoss.updateListView()
            else
                PanelChallengeBoss.updateListView()
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="page",param={ pid = CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab],flag = false}}))
            end
        else
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="page",param={ pid = CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab] }}))
        end
    end
end

function PanelChallengeBoss.handleActListView(event)
    if CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab] ~= event.pid then return end
    PanelChallengeBoss.updateListView()
end

function PanelChallengeBoss.resetListTime(event)
    if CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab] ~= event.pid then return end
    local list = NetClient:getActivityList(CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab])
    for k, info in ipairs(list) do
        local itemBg = var.bossListView:getItem(k-1)
        if itemBg then
            PanelChallengeBoss.updateNodeFreshTime(itemBg,list[k])
        end
    end
end

function PanelChallengeBoss.updateListView()
    var.zslevel = game.getZsLevel()
    var.viplevel = game.getVipLevel()
    var.rolelevel = game.getRoleLevel()

    local list = NetClient:getActivityList(CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab])
    local total = #list
    for k, info in ipairs(list) do
        local itemBg = var.bossListView:getItem(k-1)
        if not itemBg then
            itemBg = var.bossWidget:getWidgetByName("Panel_list_item"):clone()
            var.bossListView:pushBackCustomItem(itemBg)
        end
        itemBg.tag = k
        itemBg:show()
        PanelChallengeBoss.updateItemInfo(list[k], itemBg)
    end
    for i = 1,var.lastcnt - total do
        var.bossListView:removeLastItem()
    end
    var.lastcnt = total
    var.bossListView:jumpToTop()
    var.bossListView:getItem(0).click(var.bossListView:getItem(0))
    var.bossListView:show()
end

function PanelChallengeBoss.updateRecycleBossListItem(item)
    local bosslistinfo = NetClient:getActivityList(CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab])[item.tag]
    if bosslistinfo then
        PanelChallengeBoss.updateItemInfo(bosslistinfo, item)
    end
end

function PanelChallengeBoss.checkGoBtn(pSender)
    local bosslistinfo = NetClient:getActivityList(CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab])[pSender.index]
    if not bosslistinfo then return end

    local level = checkint(bosslistinfo.lv)
    local viplevel = checkint(bosslistinfo.vip)
    local reinlevel = checkint(bosslistinfo.rein)
    local msg = ""
    local check = true
    if level > 0 then
        msg = msg..level.."级"
        check = var.rolelevel >= level
    elseif viplevel > 0 then
        msg = msg.."VIP"..level
        check = var.viplevel >= viplevel
    elseif reinlevel > 0 then
        msg = msg..reinlevel.."转"
        check = var.zslevel >= reinlevel
    end

    if not check then
        NetClient:alertLocalMsg("您挑战此boss需要"..game.make_str_with_color( Const.COLOR_RED_1_STR,msg).."","alert")
        return
    end

    if var.selectTab == CHALLENGE_BOSS.GERENBOSS then
        if bosslistinfo.itemid and bosslistinfo.itemnum and bosslistinfo.itemnum > 0 then
            local itemdef = NetClient:getItemDefByID(bosslistinfo.itemid)
            if itemdef then
                if NetClient:getBagItemNumberById(bosslistinfo.itemid) < bosslistinfo.itemnum then
                    NetClient:alertLocalMsg("您挑战此boss需"..game.make_str_with_color( Const.COLOR_RED_1_STR,bosslistinfo.itemnum).."个"..itemdef.mName,"alert")
                    if bosslistinfo.itemidx then
                         game.queryQuickBuyInfo(bosslistinfo.itemidx)
                    end
                    return
                end
            end
        end
    end
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="go",param={ pid = CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab],name = bosslistinfo.name}}))
end

function PanelChallengeBoss.updateItemInfo(bosslistinfo, itemBg)
    itemBg:getWidgetByName("Image_high"):setVisible(var.selectedIndex==itemBg.tag)
    itemBg:addClickEventListener(function(pSender)
        PanelChallengeBoss.onItemClicked(pSender)
    end)
    itemBg.click = PanelChallengeBoss.onItemClicked

    if var.selectTab == CHALLENGE_BOSS.GERENBOSS then
        PanelChallengeBoss.updatePersonBossItemInfo(bosslistinfo, itemBg)
    else
        itemBg:getWidgetByName("enter_num"):hide()
        itemBg:getWidgetByName("map_name"):setString(bosslistinfo.map):setTextColor(Const.COLOR_GREEN_1_C3B)
        itemBg:getWidgetByName("boss_name"):setString(bosslistinfo.boss_name)
    end
    itemBg:getWidgetByName("Button_go").index = itemBg.tag
    itemBg:getWidgetByName("Button_go"):addClickEventListener(PanelChallengeBoss.checkGoBtn)
    itemBg:getWidgetByName("Image_act_icon"):ignoreContentAdaptWithSize(true)
    itemBg:getWidgetByName("Image_act_icon"):loadTexture(bosslistinfo.name..".png",UI_TEX_TYPE_PLIST)
    PanelChallengeBoss.updateNodeFreshTime(itemBg,bosslistinfo)
end

function PanelChallengeBoss.updateNodeFreshTime(itemBg,bosslistinfo)
--    print("刷新时间", bosslistinfo.boss_name, bosslistinfo.rest_time)
    if bosslistinfo.rest_time then
        itemBg:getWidgetByName("fresh_time"):show()
        itemBg:getWidgetByName("fresh_time"):stopAllActions()
        if bosslistinfo.rest_time > 0 then
            itemBg:getWidgetByName("fresh_time"):runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function()
                    bosslistinfo.rest_time = bosslistinfo.rest_time - 1
                    if bosslistinfo.rest_time < 1 then
                        itemBg:getWidgetByName("fresh_time"):stopAllActions()
                        itemBg:getWidgetByName("fresh_time"):setString("已刷新")
                    else
                        itemBg:getWidgetByName("fresh_time"):setString(game.convertSecondsToStr( bosslistinfo.rest_time ))
                    end
                end)))
            )

            itemBg:getWidgetByName("fresh_time"):setString(game.convertSecondsToStr( bosslistinfo.rest_time ))
        else
            itemBg:getWidgetByName("fresh_time"):setString("已刷新")
        end
    else
        itemBg:getWidgetByName("fresh_time"):stopAllActions()
        itemBg:getWidgetByName("fresh_time"):hide()
    end

    if bosslistinfo.awardflag and bosslistinfo.awardflag ~= 2 and bosslistinfo.exp then
        local awardbtn = itemBg:getWidgetByName("award_flag_btn")
        if not awardbtn then
            awardbtn = ccui.Button:create()
            awardbtn:setName("award_flag_btn")
            awardbtn:loadTextures("baoxiang_light.png","","baoxiang_gray.png",UI_TEX_TYPE_PLIST)
            awardbtn:setAnchorPoint(display.CENTER)
            awardbtn:setPosition(cc.p(350,55.5))
            awardbtn:addClickEventListener(function(pSender)
                if pSender.flag == 0 or pSender.flag == 2 then
                    NetClient:alertLocalMsg("击杀boss,获得首杀经验奖励"..pSender.exp,"alert")
                    --                    UIAnimation.oneTips({
                    --                        parent = pSender,
                    --                        msg = "击杀boss,获得首杀经验奖励"..pSender.exp,
                    --                    })
                elseif pSender.flag == 1 then
                    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="giveaward",param={ pid = CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab],name = pSender.actname}}))
                end
            end)
            awardbtn:addTo(itemBg)
        end
        --            awardflag	首杀领奖状态 0未达成 1已达成 2已领奖
        awardbtn.actname = bosslistinfo.name
        awardbtn.flag = bosslistinfo.awardflag
        awardbtn.exp = bosslistinfo.exp
        awardbtn:setBright(bosslistinfo.awardflag==1)
    else
        if itemBg:getWidgetByName("award_flag_btn") then
            itemBg:removeChildByName("award_flag_btn")
        end
    end
end

function PanelChallengeBoss.updatePersonBossItemInfo(bosslistinfo, itemBg)
    itemBg:getWidgetByName("boss_name"):setString(bosslistinfo.boss_name)
    itemBg:getWidgetByName("enter_num"):setString(string.format("(%d/%d)",math.max(0,bosslistinfo.allnum-bosslistinfo.enternum),bosslistinfo.allnum)):show()
    itemBg:getWidgetByName("enter_num"):setTextColor(bosslistinfo.enternum<bosslistinfo.allnum and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
    itemBg:getWidgetByName("enter_num"):setPositionX(itemBg:getWidgetByName("boss_name"):getPositionX()+itemBg:getWidgetByName("boss_name"):getContentSize().width)
    local level = checkint(bosslistinfo.lv)
    local viplevel = checkint(bosslistinfo.vip)
    local reinlevel = checkint(bosslistinfo.rein)
    local msg = "需要："
    local check = true
    if level > 0 then
        msg = msg..level.."级"
        check = var.rolelevel >= level
    elseif viplevel > 0 then
        msg = msg.."VIP"..level
        check = var.viplevel >= viplevel
    elseif reinlevel > 0 then
        msg = msg..reinlevel.."转"
        check = var.zslevel >= reinlevel
    end

    if bosslistinfo.itemid and bosslistinfo.itemnum and bosslistinfo.itemnum > 0 then
        local itemdef = NetClient:getItemDefByID(bosslistinfo.itemid)
        if itemdef then
            if msg ~= "" then msg = msg.."，" end
            msg = msg..itemdef.mName.."*"..bosslistinfo.itemnum
            if check then check = NetClient:getBagItemNumberById(bosslistinfo.itemid) >= bosslistinfo.itemnum end
        end
    end

    itemBg:getWidgetByName("map_name"):setString(msg):setTextColor(check == true and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B)
end

function PanelChallengeBoss.onItemClicked(itemBg)
    var.selectedIndex = itemBg.tag
    local bosslistinfo = NetClient:getActivityList(CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab])[var.selectedIndex]

    if not bosslistinfo then
        return
    end

    table.walk(var.bossListView:getItems(),function(v,k)
        v:getWidgetByName("Image_high"):setVisible(v.tag==var.selectedIndex)
    end)

    if not bosslistinfo.detail then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="select",param={ pid = CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab], index = bosslistinfo.index }}))
    else
        PanelChallengeBoss.updateRightInfo(bosslistinfo)
    end
end

function PanelChallengeBoss.handleSelectMsg(event)
    if CHALLENGE_BOSS_TAG_TO_INDEX[var.selectTab] ~= event.pid then return end
    if var.selectedIndex ~= event.index then return end
    PanelChallengeBoss.updateRightInfo(event.info)
end

function PanelChallengeBoss.updateRightInfo(bosslistinfo)
    var.rightWidget:getWidgetByName("Text_boss_name"):setString(bosslistinfo.detail.boss_name..":")
    var.rightWidget:getWidgetByName("Text_boss_level"):setString("Lv."..bosslistinfo.detail.bosslevel)

    if bosslistinfo.detail.relive_gap then
        var.rightWidget:getWidgetByName("Text_boss_name"):setPositionY(43)
        var.rightWidget:getWidgetByName("Text_boss_level"):setPositionY(43)
        var.rightWidget:getWidgetByName("Text_fresh_title"):show()
        var.rightWidget:getWidgetByName("Text_fresh_time"):setString((bosslistinfo.detail.relive_gap/60).."分钟")
    else
        var.rightWidget:getWidgetByName("Text_fresh_title"):hide()
        var.rightWidget:getWidgetByName("Text_boss_name"):setPositionY(19)
        var.rightWidget:getWidgetByName("Text_boss_level"):setPositionY(19)
    end

    for i=1, 8 do
        if var.rightWidget:getWidgetByName("item_"..i):getChildByName("iconNode") then
            var.rightWidget:getWidgetByName("item_"..i):removeChildByName("iconNode")
        end
        if bosslistinfo.detail.down[i] then
            var.rightWidget:getWidgetByName("item_"..i):setTouchEnabled(true)
            UIItem.getSimpleItem({
                parent = var.rightWidget:getWidgetByName("item_"..i),
                typeId = checkint(bosslistinfo.detail.down[i]),
            })
        else
            var.rightWidget:getWidgetByName("item_"..i):setTouchEnabled(false)
            UIItem.cleanSimpleItem(var.rightWidget:getWidgetByName("item_"..i))
        end
    end

    if var.rightWidget:getWidgetByName("Panel_ani_bg"):getChildByName("bossani") then
        var.rightWidget:getWidgetByName("Panel_ani_bg"):removeChildByName("bossani")
    end

    local aniImg = cc.Sprite:create()
    if cc.AnimManager:getInstance():getBinAnimateAsync(aniImg,Const.AVATAR_TYPE.AVATAR_CLOTH,checkint(bosslistinfo.detail.boss_id)*100,4) then
        aniImg:setPosition(cc.p(172, 70))
        aniImg:setName("bossani")
        var.rightWidget:getWidgetByName("Panel_ani_bg"):addChild(aniImg, 0)
    end
end

return PanelChallengeBoss