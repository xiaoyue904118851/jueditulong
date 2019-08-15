--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/10/26 17:53
-- To change this template use File | Settings | File Templates.
--
local BaseTipsView = import("app.views.tips.BaseTipsView")

local PropTipsView = class("PropTipsView", BaseTipsView)

function PropTipsView:ctor(params)
    PropTipsView.super.ctor(self, params)
end

function PropTipsView:addTop()
    local linearLayoutParameter = ccui.LinearLayoutParameter:create()
    linearLayoutParameter:setGravity(ccui.LinearGravity.centerHorizontal)
    local topwidget = WidgetHelper:getWidgetByCsb("uilayout/PanelCommon/UI_Tip_Item.csb")
    local panelWidget = topwidget:getChildByName("Panel_top"):clone()
    if not self.lockHeight then
        panelWidget:setContentSize(cc.size(panelWidget:getContentSize().width,92))
        panelWidget:getWidgetByName("Text_tip"):hide()
        panelWidget:getWidgetByName("Image_topline"):hide()
    end

    -- 名字
    panelWidget:getWidgetByName("itemname"):setString(self.itemDef.mName):setTextColor(game.getColor(self.itemDef.mColor))
    -- 等级
    if self.itemDef.mNeedParam and self.itemDef.mNeedParam > 0 then
        local color = game.getRoleLevel() >= self.itemDef.mNeedParam and Const.COLOR_GREEN_1_C3B or Const.COLOR_RED_1_C3B
        panelWidget:getWidgetByName("Text_lv"):setString(self.itemDef.mNeedParam.."级"):setTextColor(color)
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
    panelWidget:setLayoutParameter(linearLayoutParameter)
    panelWidget:addTo(self.layoutLayer)
    self.contentHeight = self.contentHeight + panelWidget:getContentSize().height
end

function PropTipsView:getScrollHeight()
    return self.lockHeight and 320 or 157
end

function PropTipsView:getScrollStr()
    local html_str = ""

    if string.len(self.itemDef.mDesp) > 0 then
        html_str  = html_str..game.make_str_with_color(Const.COLOR_YELLOW_1_STR,self.itemDef.mDesp)
    end


    if self.netItem and self.netItem.mDuration > 1 and self.itemDef.SubType ~= 12  then
        if string.len(html_str) > 0 then html_str  = html_str.."<br>" end
        html_str = html_str..game.make_str_with_color(Const.COLOR_WHITE_1_STR,"还可以使用：")..game.make_str_with_color(Const.COLOR_GREEN_1_STR,self.netItem.mDuration.."次")
    end
    return html_str
end

function PropTipsView:addNormalUseBtn(widget)
    local ox = self.startBgSize.width/2
    local space = 5
    local btnCfg = game.OP_BUTTONS.USE
    if game.IsMedicine(self.netItem.mTypeID) then
        btnCfg = game.OP_BUTTONS.EAT
    end

    local btnOp = ccui.Button:create()
    btnOp:setName(btnCfg.name)
    btnOp:loadTextures("new_com_btn_green.png","","new_com_btn_gray.png",UI_TEX_TYPE_PLIST)
    btnOp:setTitleFontSize(24)
    btnOp:setTitleFontName(Const.DEFAULT_BTN_FONT_NAME)
    btnOp:setTitleText(btnCfg.text)
    btnOp:setTag(btnCfg.tag)
    btnOp:setAnchorPoint(display.LEFT_BOTTOM)
    btnOp:setPosition(cc.p(ox+space,0))

    btnOp:addTo(widget)

    if self.itemDef.SubType == 0 then
        btnOp:setTitleColor(Const.COLOR_GRAY_1_C3B)
        btnOp:setTouchEnabled(false):setBright(false)
    else
        btnOp:setTitleColor(Const.COLOR_YELLOW_2_C3B)
        btnOp:addClickEventListener(handler(self, self.onBtnClicked))
    end

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

function PropTipsView:getMoreOpBtnCfg()
    local btnConfig = {}
    if game.checkActive(self.netItem) then
        table.insert(btnConfig, game.OP_BUTTONS.ACTIVE)
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

return PropTipsView