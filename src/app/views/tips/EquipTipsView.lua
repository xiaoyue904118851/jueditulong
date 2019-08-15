--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/26 20:25
-- To change this template use File | Settings | File Templates.
--

local BaseTipsView = import("app.views.tips.BaseTipsView")

local EquipTipsView = class("EquipTipsView", BaseTipsView)

function EquipTipsView:ctor(params)
    params.lockHeight = true
    EquipTipsView.super.ctor(self, params)
end

function EquipTipsView:addTop()
    local linearLayoutParameter = ccui.LinearLayoutParameter:create()
    linearLayoutParameter:setGravity(ccui.LinearGravity.centerHorizontal)
    local topwidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Tip_Equip.csb")
    local panelWidget = topwidget:getChildByName("Panel_top"):clone()
    -- 名字
    panelWidget:getWidgetByName("itemname"):setString(self.itemDef.mName):setTextColor(game.getColor(self.itemDef.mColor))
    -- 等级
    if self.itemDef.mNeedParam and self.itemDef.mNeedParam > 0 then
        if self.itemDef.mNeedType == 0 then
            local color = game.getRoleLevel() >= self.itemDef.mNeedParam and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B
            panelWidget:getWidgetByName("Text_lv"):setString(self.itemDef.mNeedParam.."级"):setTextColor(color)
        elseif self.itemDef.mNeedType == 4 then
            local color = game.getZsLevel() >= self.itemDef.mNeedParam and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B
            panelWidget:getWidgetByName("Text_lv"):setString(self.itemDef.mNeedParam.."转"):setTextColor(color)
        else
            panelWidget:getWidgetByName("Text_lv"):hide()
            panelWidget:getWidgetByName("lv_name"):hide()
        end
    else
        panelWidget:getWidgetByName("Text_lv"):hide()
        panelWidget:getWidgetByName("lv_name"):hide()
    end
    -- 绑定
    if self.netItem then
        panelWidget:getWidgetByName("Text_bind"):setString(self.netItem.mItemFlags % 2 == 1 and "已绑定" or "未绑定")
    else
        panelWidget:getWidgetByName("Text_bind"):hide()
    end
    UIItem.getSimpleItem({
        parent = panelWidget:getWidgetByName("itembg"),
        typeId = self.itemDef.mTypeID,
        itemCallBack = function () end
    })

    -- 职业
    local color = Const.COLOR_GREEN_1_C3B
    if self.itemDef.mJob ~= 0 and game.getRoleJob() ~= self.itemDef.mJob then
        color = Const.COLOR_RED_1_C3B
    end
    panelWidget:getWidgetByName("Text_job"):setString(Const.JOB[self.itemDef.mJob]):setTextColor(color)

    -- 战力
    local fpanel = panelWidget:getWidgetByName("Panel_new_fp")
    local curText = fpanel:getWidgetByName("Image_zhanli_title")
    local disText = fpanel:getWidgetByName("AtlasLabel_zhanli")
    local fparentSize = fpanel:getParent():getContentSize()
    disText:setString(self.itemDef.mAddFight)
    fpanel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, fparentSize.height))--:setPositionX(fparentSize.width/2)


--    local fpanel = panelWidget:getWidgetByName("Image_zhanli_title")
--    fpanel:getWidgetByName("AtlasLabel_zhanli"):setString(self.itemDef.mAddFight)
--    fpanel:setPositionX(fpanel:getParent():getContentSize().width/2)

    panelWidget:setLayoutParameter(linearLayoutParameter)
    panelWidget:addTo(self.layoutLayer)
    self.contentHeight = self.contentHeight + panelWidget:getContentSize().height
end

function EquipTipsView:getScrollHeight()
    return 320
end

function EquipTipsView:getScrollStr()
    local html_str = ""
    html_str = html_str..self:make_base_attr()
    if string.len(self.itemDef.mDesp) > 0 then
        html_str = html_str.."<br><pic src='img_line01.png'/><br><br>"
        html_str = html_str..game.make_str_with_color(Const.COLOR_YELLOW_1_STR,self.itemDef.mDesp)
    end
    return html_str
end

function EquipTipsView:make_base_attr()
    --    local ret = "<pic src='img_point01.png'/>"..game.make_str_with_color(Const.COLOR_YELLOW_2_STR,"[基础属性]").."<br>"
    local ret = game.make_str_with_color(Const.COLOR_YELLOW_2_STR,"[基础属性]").."<br>"
    local base_attr = {
        {min = self.itemDef.mAC,max = self.itemDef.mACMax,
            add = (self.netItem  and self.netItem .mAddAC or 0)+(self.netItem  and self.netItem .mUpdAC or 0),
            maxadd = (self.netItem  and self.netItem .mAddAC or 0)+(self.netItem  and self.netItem .mUpdAC or 0),
            name="物理防御:"},
        {min = self.itemDef.mMAC,max = self.itemDef.mMACMax,
            add = (self.netItem  and self.netItem .mAddMAC or 0)+(self.netItem  and self.netItem .mUpdMAC or 0),
            maxadd = (self.netItem  and self.netItem .mAddMAC or 0)+(self.netItem  and self.netItem .mUpdMAC or 0),
            name="魔法防御:"},
        {min = self.itemDef.mDC,max = self.itemDef.mDCMax,
            add = (self.netItem  and self.netItem .mAddDC or 0)+(self.netItem  and self.netItem .mUpdDC or 0),
            maxadd = (self.netItem  and self.netItem .mAddDC or 0)+(self.netItem  and self.netItem .mUpdDCMAX or 0),
            name="物理攻击:"},
        {min = self.itemDef.mMC,max = self.itemDef.mMCMax,
            add = (self.netItem  and self.netItem .mAddMC or 0)+(self.netItem  and self.netItem .mUpdMC or 0),
            maxadd = (self.netItem  and self.netItem .mAddMC or 0)+(self.netItem  and self.netItem .mUpdMCMAX or 0),
            name="魔法攻击:"},
        {min = self.itemDef.mSC,max = self.itemDef.mSCMax,
            add = (self.netItem  and self.netItem .mAddSC or 0)+(self.netItem  and self.netItem .mUpdSC or 0),
            maxadd = (self.netItem  and self.netItem .mAddSC or 0)+(self.netItem  and self.netItem .mSCMAX or 0),
            name="道术攻击:"},
    }
    local base_adv_attr = {
        {val = self.itemDef.mAccuracy,add = 0,unit = "",name="闪避:"},
        {val = self.itemDef.mDodge,add = 0,unit = "",name="精确:"},
        {val = 100*self.itemDef.mAntiMagic/NetClient.mGameParam.mMaxMagicAnti,add = 0,unit = "%",name="魔法闪避:",color=Const.COLOR_YELLOW_3_STR},
        {val = self.itemDef.mAntiPoison*10,add = 0,unit = "%",name="中毒闪避:"},
        {val = self.itemDef.mHpRecover*10,add = 0,unit = "%",name="生命恢复:"},
        {val = self.itemDef.mMpRecover*10,add = 0,unit = "%",name="魔法恢复:"},
        {val = self.itemDef.mPoisonRecover*10,add = 0,unit = "%",name="中毒恢复:"},
        {val = self.itemDef.mMaxHp,add = (self.netItem  and self.netItem.mAddHp or 0),unit = "",name="生命上限:"},
        {val = self.itemDef.mMaxMp,add = (self.netItem  and self.netItem.mAddHp or 0),unit = "",name="魔法上限:"},
    }
    if self.itemDef.mMaxHpPres and self.itemDef.mMaxHpPres > 0 then
        table.insert(base_adv_attr, {val = self.itemDef.mMaxHpPres/100,add = 0,unit = "%",name="生命上限:"})
    end
    if self.itemDef.mMaxMpPres and self.itemDef.mMaxHpPres > 0 then
        table.insert(base_adv_attr, {val = self.itemDef.mMaxMpPres/100,add = 0,unit = "%",name="魔法上限:"})
    end

    for i=1,#base_attr do
        local add = base_attr[i].add
        local maxadd = base_attr[i].maxadd
        if (base_attr[i].min + add > 0) or (base_attr[i].max + maxadd) > 0 then
            ret = ret..game.make_str_with_color(Const.COLOR_YELLOW_1_STR,base_attr[i].name)
                    ..game.make_str_with_color(Const.COLOR_GREEN_1_STR,(base_attr[i].min+add+(self.itemDef.mColorRangeL or 0))..
                    "-"..(base_attr[i].max + maxadd+(self.itemDef.mColorRange or 0)).."<br>")
        end
    end
    local luck = self.itemDef.mLuck + (self.netItem  and self.netItem .mLuck or 0) - self.itemDef.mCurse
    if luck > 0 then
        ret = ret..game.make_str_with_color("#00FF00","幸运:")..game.make_str_with_color("#FFFFFF","+"..luck).."<br>"
    elseif luck < 0 then
        ret = ret..game.make_str_with_color("#00FF00","诅咒:")..game.make_str_with_color("#FFFFFF","+"..(-luck)).."<br>"
    end
    for i=1,#base_adv_attr do
        if (base_adv_attr[i].val + base_adv_attr[i].add) > 0 then
            local color = base_adv_attr[i].color or Const.COLOR_RED_1_STR
            ret = ret..game.make_str_with_color( color,base_adv_attr[i].name)..game.make_str_with_color(color ,"+"..(base_adv_attr[i].val + base_adv_attr[i].add)..base_adv_attr[i].unit).."<br>"
        end
    end
    if self.itemDef.mXishouProb > 0 and self.itemDef.mXishouPres > 0 then
        ret = ret..game.make_str_with_colorr(Const.COLOR_RED_1_STR,"吸收物理伤害"..self.itemDef.mXiShouPres).."<br>"
        ret = ret..game.make_str_with_color(Const.COLOR_RED_1_STR,"吸收魔法伤害"..self.itemDef.mXiShouPres).."<br>"
    end
    return ret
end

function EquipTipsView:addNormalUseBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.DRESS
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn_green.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)

    local btnCfg = game.OP_BUTTONS.MORE
    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn.png","","",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.RIGHT_BOTTOM)
    btnOp:setPosition(cc.p(ox-space,0))
    btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    btnOp:addTo(widget)
    self.haveMoreBtn = true
end

function EquipTipsView:getMoreOpBtnCfg()
    local btnConfig = {}
    if game.canRecyle(self.itemDef) then
        table.insert(btnConfig, game.OP_BUTTONS.RECOVERY)
    end
    if game.checkSplit(self.netItem) then
        table.insert(btnConfig, game.OP_BUTTONS.CHAI)
    end

    if game.checkDuidie(self.netItem) then
        table.insert(btnConfig, game.OP_BUTTONS.DUI)
    end

    table.insert(btnConfig, game.OP_BUTTONS.SELL)
    table.insert(btnConfig, game.OP_BUTTONS.DESTROY)
    return btnConfig
end

return EquipTipsView