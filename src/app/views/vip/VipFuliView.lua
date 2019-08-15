--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/01/03 12:35
-- To change this template use File | Settings | File Templates.
--

local VipFuliView = {}
local var = {}
local ACTIONSET_NAME = "vip"

local FUNC_PVR = "uilayout/PanelVIP/PanelVIPfuli"

function VipFuliView.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = VipFuliView.getValidTab()
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelVIP/UI_VIP_Fuli.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_vip_fuli")
    var.widget:getWidgetByName("Button_show_item"):hide()
    var.srcFuliWidget = var.widget:getWidgetByName("Panel_fuliInfo")
    VipFuliView.addBtnEvent()
    VipFuliView.updateFuliInfo(var.srcFuliWidget, var.selectTab)
    VipFuliView.registeEvent()
    var.srcFuliWidget:onNodeEvent("exit", function()
        remove_frames(FUNC_PVR,Const.TEXTURE_TYPE.PVR)
    end)
    return widget
end

function VipFuliView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
        :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, VipFuliView.handleVipData)
end

function VipFuliView.getValidTab()
    if not NetClient.mVipLevelGiftInfo then
        if game.getVipLevel() > 0 then
            return game.getVipLevel()
        end
        return 1
    end
    for k, awardflag in ipairs(NetClient.mVipLevelGiftInfo) do
        if awardflag == 1 then
            return k
        end
    end
    if game.getVipLevel() > 0 then
        return game.getVipLevel()
    end
    return 1
end

function VipFuliView.getNextValid()
    if not NetClient.mVipLevelGiftInfo then
        return var.selectTab
    end
    for k, awardflag in ipairs(NetClient.mVipLevelGiftInfo) do
        if awardflag == 1 then
            return k
        end
    end
    return var.selectTab
end

function VipFuliView.handleVipData(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end

    if not d.actionid then
        return
    end

    if d.actionid == "vipchangeinfo" then
        var.selectTab = VipFuliView.getNextValid()
        VipFuliView.updateFuliInfo(var.srcFuliWidget, var.selectTab)
        if var.selectTab == 1 then
            var.widget:getWidgetByName("Button_pre"):hide()
        end
        if var.selectTab == #VipDefData.list then
            var.widget:getWidgetByName("Button_next"):hide()
        end
    end
end

function VipFuliView.addBtnEvent()
    local moveBy = cc.MoveBy:create(1,cc.p(-10, 0))
    var.widget:getWidgetByName("Button_pre"):runAction(cc.RepeatForever:create(cc.Sequence:create(moveBy,cc.DelayTime:create(0.5),moveBy:reverse())))
    var.widget:getWidgetByName("Button_pre"):addClickEventListener(function(pSender)
        if var.selectTab > 1 then
            var.selectTab = var.selectTab - 1
            VipFuliView.updateFuliInfo(var.srcFuliWidget, var.selectTab)
            var.widget:getWidgetByName("Button_next"):show()
            if var.selectTab == 1 then
                pSender:hide()
            end
        end
    end)
    if var.selectTab == 1 then
        var.widget:getWidgetByName("Button_pre"):hide()
    end

    local moveBy = cc.MoveBy:create(1,cc.p(10, 0))
    var.widget:getWidgetByName("Button_next"):runAction(cc.RepeatForever:create(cc.Sequence:create(moveBy,cc.DelayTime:create(0.5),moveBy:reverse())))
    var.widget:getWidgetByName("Button_next"):addClickEventListener(function(pSender)
        if var.selectTab < #VipDefData.list then
            var.selectTab = var.selectTab + 1
            VipFuliView.updateFuliInfo(var.srcFuliWidget, var.selectTab)
            var.widget:getWidgetByName("Button_pre"):show()
            if var.selectTab == #VipDefData.list then
                pSender:hide()
            end
        end
    end)
    var.widget:getWidgetByName("Button_award"):addClickEventListener(function(pSender)
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "get_lv_gift",idx = var.selectTab}))
    end)
    if var.selectTab == #VipDefData.list then
        var.widget:getWidgetByName("Button_next"):hide()
    end
end

function VipFuliView.updateFuliInfo(widget, level)
    var.widget:getWidgetByName("Image_level_title"):loadTexture("m_VIP"..level..".png",UI_TEX_TYPE_PLIST)
    VipFuliView.updateBuffAttr(widget,level)
    VipFuliView.updateAward(widget,level)
    if var.loadpvr then
        VipFuliView.updateFunction(widget,level)
    else
        var.loadpvr = true
        asyncload_frames(FUNC_PVR,Const.TEXTURE_TYPE.PVR,function ()
            VipFuliView.updateFunction(widget,level)
        end)
    end
end

function VipFuliView.updateBuffAttr(widget, level)
    local mAttrInfo = NetClient:getStatusDefByID(Const.STATUS_TYPE_VIP, level)
    if not mAttrInfo then
        return
    end

    local cf = {
        {name = "Label_PhyAtkTitle", dis = ""},
        {name = "Label_MagAtkTitle", dis = ""},
        {name = "Label_DaoAtkTitle", dis = ""},
        {name = "Label_PhyDefTitle", dis = ""},
        {name = "Label_MagDefTitle", dis = ""},
    }

    local curValue = {
        { min = mAttrInfo and mAttrInfo.mDC or 0 , max = mAttrInfo and mAttrInfo.mDCmax or 0},
        { min = mAttrInfo and mAttrInfo.mMC or 0 , max = mAttrInfo and mAttrInfo.mMCmax or 0},
        { min = mAttrInfo and mAttrInfo.mSC or 0 , max = mAttrInfo and mAttrInfo.mSCmax or 0},

        { min = mAttrInfo and mAttrInfo.mAC or 0 , max = mAttrInfo and mAttrInfo.mACmax or 0},
        { min = mAttrInfo and mAttrInfo.mMAC or 0 , max = mAttrInfo and mAttrInfo.mMACmax or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
    end
    table.insert(cf, {name = "Label_HpMaxTitle", value = ((mAttrInfo.mHPmax/10000)*100).."%"})
    for _, v in ipairs(cf) do
        local panel = widget:getWidgetByName(v.name)
        panel:getWidgetByName("Label_Cur"):setString(v.value)
    end
end

function VipFuliView.updateAward(widget,level)
    local vipList = VipDefData.list
    if vipList and vipList[level] then
        local award = vipList[level].awardlist
        if award and #award > 0 then
            for i=1,6 do
                widget:getWidgetByName("Image_item_"..i):removeAllChildren()
                if award[i] then
                    UIItem.getItem({
                        parent = widget:getWidgetByName("Image_item_"..i),
                        typeId = award[i].typeid,
                        num = award[i].num,
                    })
                    widget:getWidgetByName("Image_item_"..i):show()
                else
                    widget:getWidgetByName("Image_item_"..i):hide()
                end
            end
        end
    end
    if NetClient.mVipLevelGiftInfo and #NetClient.mVipLevelGiftInfo > 0 then
        if NetClient.mVipLevelGiftInfo[level] then
            local btn = widget:getWidgetByName("Button_award")
            if tonumber(NetClient.mVipLevelGiftInfo[level]) == 0 then--不可领
                btn:setTitleText("不可领")
                btn:setBright(false)
                btn:setTouchEnabled(false)
                if btn:getChildByName("effect") then
                    btn:removeChildByName("effect")
                end
            elseif tonumber(NetClient.mVipLevelGiftInfo[level]) == 1 then--可领取
                btn:setTitleText("领取")
                btn:setBright(true)
                btn:setTouchEnabled(true)
                if not btn:getChildByName("effect") then
                    local effectnode = gameEffect.getNormalBtnSelectEffect()
                    effectnode:setPosition(cc.p(btn:getContentSize().width/2,btn:getContentSize().height/2))
                    effectnode:addTo(btn)
                    effectnode:setName("effect")
                end
            elseif tonumber(NetClient.mVipLevelGiftInfo[level]) == 2 then--已领取
                btn:setTitleText("已领取")
                btn:setBright(false)
                btn:setTouchEnabled(false)
                if btn:getChildByName("effect") then
                    btn:removeChildByName("effect")
                end
            end
        end
    end
end

function VipFuliView.updateFunction(widget,level)
    local scrollView = widget:getWidgetByName("ListView_showicon")
    scrollView:removeAllItems()
    local vipList = VipDefData.list
    if vipList and vipList[level] then
        local bigIconList = vipList[level].bigiconlist
        local picname = ""
        if bigIconList and #bigIconList > 0 then
            for _,tab_img in ipairs(bigIconList) do
                local item = widget:getWidgetByName("Button_show_item"):clone():show()
                if string.find(tab_img.pic,".jpg") then
                    item:loadTextures(tab_img.pic,tab_img.pic,"",UI_TEX_TYPE_PLIST)
                    picname = string.sub(tab_img.pic,1,-5)
                    if picname == "cangkuwei" then
                        item:getWidgetByName("img_extra"):hide()
                        item:getWidgetByName("atlas_num"):show():setString(vipList[level].tequanlist["slot"])
                    elseif picname == "bangdingjinzhuan" then
                        item:getWidgetByName("img_extra"):hide()
                        item:getWidgetByName("atlas_num"):show():setString(vipList[level].tequanlist["bindjz"])
                    elseif tab_img.img_extra and tab_img.img_extra ~= "" then
                        item:getWidgetByName("atlas_num"):hide()
                        item:getWidgetByName("img_extra"):show():loadTexture(tab_img.img_extra,UI_TEX_TYPE_PLIST)
                    else
                        item:getWidgetByName("img_extra"):hide()
                        item:getWidgetByName("atlas_num"):hide()
                    end
                    item.pic = picname
                    item.viplevel = level
                    item.alertstr = tab_img.alertstr
                    item:addClickEventListener(function(pSender)
                        VipFuliView.onBigShowIconCliked(pSender)
                    end)
                    scrollView:pushBackCustomItem(item)
                end
            end
        end
    end

end

function VipFuliView.onBigShowIconCliked(pSender)
    game.checkBtnClick()
    if pSender.pic == "vipguaji" or pSender.pic == "zhuanshuboss" then
        if game.getVipLevel() < pSender.viplevel then
            NetClient:alertLocalMsg("您的VIP等级不足","alert")
            return
        end
    end
    if pSender.pic == "vipguaji" then
        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "processEnterVipMJ"}))
    elseif pSender.pic == "zhuanshuboss" then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "即将传送至VIP专属Boss地图,是否立即前往？",
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function ()
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "processEnterVipMap"}))
            end
        }
        NetClient:dispatchEvent(param)
    elseif pSender.alertstr and pSender.alertstr ~= "" then
        UIAnimation.oneTips({
            parent = pSender,
            msg = pSender.alertstr,
            pos = cc.p(77,174),
        })
    end
end

return VipFuliView