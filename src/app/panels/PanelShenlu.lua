--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/09/30 16:53
-- To change this template use File | Settings | File Templates.
-- PanelRoleInfo

local PanelShenlu= {}
local var = {}
local ACTIONSET_NAME = "armour"
local SHENLU_TAG = {
    JIANJIA = 1,
    BAOSHI = 2,
    DUNPAI = 3,
    ANQI = 4,
    YUXI = 5
}
local KIND_MAX=45;   --45类
local SHENLU_TAG_NAME = {
    [SHENLU_TAG.JIANJIA] = "肩甲",
    [SHENLU_TAG.BAOSHI] = "宝石",
    [SHENLU_TAG.DUNPAI] = "盾牌",
    [SHENLU_TAG.ANQI] = "暗器",
    [SHENLU_TAG.YUXI] = "玉玺",
}

local SHENLU_EFFECT = {
    [SHENLU_TAG.JIANJIA] = {
        {plist = "jianjia0", pattern = "jianjia0_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia1", pattern = "jianjia1_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia2", pattern = "jianjia2_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia3", pattern = "jianjia3_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia4", pattern = "jianjia4_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia5", pattern = "jianjia5_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia6", pattern = "jianjia6_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "jianjia7", pattern = "jianjia7_%02d.png", begin = 1, length = 10, time = 0.2},
    },
    [SHENLU_TAG.BAOSHI] = {
        {plist = "baoshi0", pattern = "baoshi0_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi1", pattern = "baoshi1_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi2", pattern = "baoshi2_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi3", pattern = "baoshi3_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi4", pattern = "baoshi4_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi5", pattern = "baoshi5_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi6", pattern = "baoshi6_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "baoshi7", pattern = "baoshi7_%02d.png", begin = 1, length = 10, time = 0.2},
    },
    [SHENLU_TAG.DUNPAI] = {
        {plist = "dun0", pattern = "dun0_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun1", pattern = "dun1_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun2", pattern = "dun2_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun3", pattern = "dun3_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun4", pattern = "dun4_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun5", pattern = "dun5_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun6", pattern = "dun6_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "dun7", pattern = "dun7_%02d.png", begin = 1, length = 10, time = 0.2},
    },
    [SHENLU_TAG.ANQI] = {
        {plist = "anqi0", pattern = "anqi0_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi1", pattern = "anqi1_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi2", pattern = "anqi2_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi3", pattern = "anqi3_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi4", pattern = "anqi4_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi5", pattern = "anqi5_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi6", pattern = "anqi6_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "anqi7", pattern = "anqi7_%02d.png", begin = 1, length = 10, time = 0.2},
    },
    [SHENLU_TAG.YUXI] = {
        {plist = "yuxi0", pattern = "yuxi0_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi1", pattern = "yuxi1_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi2", pattern = "yuxi2_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi3", pattern = "yuxi3_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi4", pattern = "yuxi4_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi5", pattern = "yuxi5_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi6", pattern = "yuxi6_%02d.png", begin = 1, length = 10, time = 0.2},
        {plist = "yuxi7", pattern = "yuxi7_%02d.png", begin = 1, length = 10, time = 0.2},
    },
}

--[[
local SHENLU_EFFECT = {
    [SHENLU_TAG.JIANJIA] = {
        {image = "jianjia0_01"},
        {image = "jianjia1_01"},
        {image = "jianjia2_01"},
        {image = "jianjia3_01"},
        {image = "jianjia4_01"},
        {image = "jianjia5_01"},
        {image = "jianjia6_01"},
        {image = "jianjia7_01"},
    },
    [SHENLU_TAG.BAOSHI] = {
        {image = "baoshi0_01"},
        {image = "baoshi1_01"},
        {image = "baoshi2_01"},
        {image = "baoshi3_01"},
        {image = "baoshi4_01"},
        {image = "baoshi5_01"},
        {image = "baoshi6_01"},
        {image = "baoshi7_01"},
    },
    [SHENLU_TAG.DUNPAI] = {
        {image = "dun0_01"},
        {image = "dun1_01"},
        {image = "dun2_01"},
        {image = "dun3_01"},
        {image = "dun4_01"},
        {image = "dun5_01"},
        {image = "dun6_01"},
        {image = "dun7_01"},
    },
    [SHENLU_TAG.ANQI] = {
        {image = "anqi0_01"},
        {image = "anqi1_01"},
        {image = "anqi2_01"},
        {image = "anqi3_01"},
        {image = "anqi4_01"},
        {image = "anqi5_01"},
        {image = "anqi6_01"},
        {image = "anqi7_01"},
    },
    [SHENLU_TAG.YUXI] = {
        {image = "yuxi0_01"},
        {image = "yuxi1_01"},
        {image = "yuxi2_01"},
        {image = "yuxi3_01"},
        {image = "yuxi4_01"},
        {image = "yuxi5_01"},
        {image = "yuxi6_01"},
        {image = "yuxi7_01"},
    },
}
]]
local num_to_str={
    [1]="[一阶]",[2]="[一阶]",[3]="[一阶]",
    [4]="[二阶]",[5]="[二阶]",[6]="[二阶]",
    [7]="[三阶]",[8]="[三阶]",[9]="[三阶]",
    [10]="[四阶]",[11]="[四阶]",[12]="[四阶]",
    [13]="[五阶]",[14]="[五阶]",[15]="[五阶]",
    [16]="[六阶]",[17]="[六阶]",[18]="[六阶]",
    [19]="[七阶]",[20]="[七阶]",[21]="[七阶]",
    [22]="[八阶]",[23]="[八阶]",[24]="[八阶]",
    [25]="[九阶]",[26]="[九阶]",[27]="[九阶]",
    [28]="[十阶]",[29]="[十阶]",[30]="[十阶]",
    [31]="[十一阶]",[32]="[十一阶]",[33]="[十一阶]",
    [34]="[十二阶]",[35]="[十二阶]",[36]="[十二阶]",
    [37]="[十三阶]",[38]="[十三阶]",[39]="[十三阶]",
    [40]="[十四阶]",[41]="[十四阶]",[42]="[十四阶]",
    [43]="[十五阶]",[44]="[十五阶]",[45]="[十五阶]",
}
local num_to_pageid={
    [1]=1,[2]=1,[3]=1,
    [4]=1,[5]=1,[6]=1,
    [7]=2,[8]=2,[9]=2,
    [10]=2,[11]=2,[12]=2,
    [13]=3,[14]=3,[15]=3,
    [16]=3,[17]=3,[18]=3,
    [19]=4,[20]=4,[21]=4,
    [22]=4,[23]=4,[24]=4,
    [25]=5,[26]=5,[27]=5,
    [28]=5,[29]=5,[30]=5,
    [31]=6,[32]=6,[33]=6,
    [34]=6,[35]=6,[36]=6,
    [37]=7,[38]=7,[39]=7,
    [40]=7,[41]=7,[42]=7,
    [43]=8,[44]=8,[45]=8,
}

function PanelShenlu.initView(params)
    local params = params or {}
    var = {}
    var.selectTab = SHENLU_TAG.JIANJIA
    if params.extend and params.extend.pdata and params.extend.pdata.tag then
        var.selectTab = params.extend.pdata.tag
    else
        if UIRedPoint.checkJianjiaPoint() > 0 then
            var.selectTab = SHENLU_TAG.JIANJIA
        elseif UIRedPoint.checkBaoshiPoint() > 0 then
            var.selectTab = SHENLU_TAG.BAOSHI
        elseif UIRedPoint.checkDunpaiPoint() > 0 then
            var.selectTab = SHENLU_TAG.DUNPAI
        elseif UIRedPoint.checkAnqiPoint() > 0 then
            var.selectTab = SHENLU_TAG.ANQI
        elseif UIRedPoint.checkYuxiPoint() > 0 then
            var.selectTab = SHENLU_TAG.YUXI
        end
    end
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelShenlu/UI_Shenlu_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_shenlu")

    PanelShenlu.initWidget()
    PanelShenlu.addMenuTabClickEvent()
    PanelShenlu.registeEvent()
    return var.widget
end

function PanelShenlu.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelShenlu.handleShenluMsg)
end

function PanelShenlu.handleShenluMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == ACTIONSET_NAME then
        if d.actionid then
            if d.actionid == "query_total" then
                PanelShenlu.resetInfo(var.selectTab)
            end
        end
    end
end

function PanelShenlu.initWidget()
    var.leftWidget = var.widget:getWidgetByName("Image_left")
    var.rightWidget = var.widget:getWidgetByName("Image_right")
    var.upBtn = var.rightWidget:getWidgetByName("Button_up")
    var.needLevelText = var.rightWidget:getWidgetByName("Text_level_alert")
    var.needPanel = var.rightWidget:getWidgetByName("needPanel")
    var.needExpText = var.needPanel:getWidgetByName("Label_costtitle")
    var.haveExpText = var.needPanel:getWidgetByName("Label_havetitle")
    var.effectbg = var.leftWidget:getWidgetByName("Image_effectbg")
    var.pageView = var.leftWidget:getWidgetByName("PageView_effect")
    var.buqiText = var.rightWidget:getWidgetByName("Text_buqi")
    var.checkBox = var.rightWidget:getWidgetByName("CheckBox_buqi")

    var.starImg = {}
    var.confirmtag = false
    for i = 1, 3 do
        var.starImg[i] = var.leftWidget:getWidgetByName("Image_star"..i)
    end
    var.autoBuy = false
    local checkBox = var.rightWidget:getWidgetByName("CheckBox_buqi")
    checkBox:addEventListener(function(sender,eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            var.autoBuy = true
        elseif eventType == ccui.CheckBoxEventType.unselected then
            var.autoBuy = false
        end
    end)
    var.checkBox:setSelected(var.autoBuy)

    var.upBtn:addClickEventListener(function (pSender)
        UIButtonGuide.handleButtonGuideClicked(pSender)
        if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SHENLU) then
            UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_close"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.SHENLU,2),UIButtonGuide.UI_TYPE_LEFT)
        end
        var.widget:runAction(cc.Sequence:create(cc.DelayTime:create(3), cc.CallFunc:create(function()
            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SHENLU) then
                EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_shenlu"})
            end
        end))) 
        local info = NetClient.mShenluInfo[var.selectTab]
        if not info then return end

        if info.needpoint > info.exppoint then
            if var.selectTab == SHENLU_TAG.YUXI then
                if var.autoBuy then
                    if var.confirmtag then
                        NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade", params = {category = var.selectTab, useyb = 1}}))
                    else
                        local needyb = math.floor((info.needpoint - info.exppoint)/NetClient.mShenluPrice.yuxi)
                        local param = {
                            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否使用"..needyb.."元宝补齐余下的"..SHENLU_TAG_NAME[var.selectTab].."积分？",
                            confirmTitle = "确 定", cancelTitle = "取 消",
                            confirmCallBack = function ()
                                var.confirmtag = true
                                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade", params = {category = var.selectTab, useyb = 1}}))
                            end
                        }
                        NetClient:dispatchEvent(param)
                    end
                else
                    NetClient:alertLocalMsg(SHENLU_TAG_NAME[var.selectTab].."积分不足","alert")
                end
            else
                NetClient:alertLocalMsg(SHENLU_TAG_NAME[var.selectTab].."积分不足","alert")
            end
        else
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "upgrade", params = {category = var.selectTab}}))
        end
    end)

    var.btnNext = var.leftWidget:getWidgetByName("Button_next")
    var.btnNext:addClickEventListener(function(pSender)
        PanelShenlu.onChangePage(1)
    end)

    var.btnPre = var.leftWidget:getWidgetByName("Button_pre")
    var.btnPre:addClickEventListener(function(pSender)
        PanelShenlu.onChangePage(-1)
    end)

    var.tipsBtn = var.rightWidget:getWidgetByName("Button_tips")
    var.tipsBtn:addClickEventListener(function(pSender)
        UIAnimation.oneTips({
            parent = pSender,
            msg = pSender.desp,
        })
    end)
end

function PanelShenlu.onPanelClose() 
    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SHENLU) then
        UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_close"),{UIButtonGuide.GUILDTYPE.SHENLU})
    end
end

function PanelShenlu.addMenuTabClickEvent()
--    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local cp = cc.p(125,70)
    local RadionButtonGroup = UIRadioButtonGroup.new()
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_jianjia"),position=cp,types={UIRedPoint.REDTYPE.JIANJIA}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_baoshi"),position=cp,types={UIRedPoint.REDTYPE.BAOSHI}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_dunpai"),position=cp,types={UIRedPoint.REDTYPE.DUNPAI}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_anqi"),position=cp,types={UIRedPoint.REDTYPE.ANQI}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_yuxi"),position=cp,types={UIRedPoint.REDTYPE.YUXI}}))
    :onButtonSelectChanged(function(event)
        PanelShenlu.updatePanelByTag(event.selected)
    end)
    :onButtonSelectChangedBefor(function(event)
        return PanelShenlu.checkButtonClicked(event.selected)
    end)

    RadionButtonGroup:setButtonSelected(var.selectTab)
end

function PanelShenlu.newgotoPage(page)
    if page > var.totalPage or page < 1 then
        return
    end
    var.curPage = page
    var.effectbg:removeAllChildren()
    local pagesize = var.effectbg:getContentSize()

    local cfg = SHENLU_EFFECT[var.selectTab][page]
    --ccui.ImageView:create("uilayout/image/shenlu/"..cfg.image..".png")
    gameEffect.getFrameEffect( "scenebg/shenlu/"..cfg.plist, cfg.pattern, cfg.begin, cfg.length, cfg.time)
    :addTo(var.effectbg)
    :setPosition(cc.p(pagesize.width/2,pagesize.height/2))
end
--[[
function PanelShenlu.gotoPage(page, delay)
    if page > var.totalPage or page < 1 then
        return
    end

    var.curPage = page
    var.btnPre:setTouchEnabled(var.curPage>1)
    var.btnNext:setTouchEnabled(var.curPage<var.totalPage)
    if delay then
        var.buqiText:stopAllActions()
        var.buqiText:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.01),
            cc.CallFunc:create(function()
                var.pageView:jumpToItem(var.curPage-1, cc.p(0, 0), cc.p(0, 0))
            end)
        ))
    else
        var.pageView:scrollToPage(var.curPage-1)
    end
end
]]
function PanelShenlu.onChangePage(flag)
    local page = var.curPage + flag
    if page > var.totalPage or page < 1 or flag == 0 then
        return
    end
    var.curPage = page
    --var.btnPre:setTouchEnabled(var.curPage>1)
    --var.btnNext:setTouchEnabled(var.curPage<var.totalPage)
    PanelShenlu.newgotoPage(var.curPage)
    --var.pageView:scrollToPage(var.curPage-1)
end
--[[
function PanelShenlu.resetEffect()
    var.pageView:hide()
    var.curPage = 1
    var.totalPage = #SHENLU_EFFECT[var.selectTab]

    var.pageView:removeAllPages()
    for i = 1, var.totalPage do
        var.pageView:addPage(PanelShenlu.createEffectPage(i))
    end
    var.pageView:show()
    var.btnPre:setTouchEnabled(false)
    var.btnNext:setTouchEnabled(true)
end

function PanelShenlu.createEffectPage(page)
    local pagesize = var.effectbg:getContentSize()
    local pageWidget = ccui.Widget:create()
    pageWidget:setContentSize(pagesize)

    local cfg = SHENLU_EFFECT[var.selectTab][page]
    ccui.ImageView:create("uilayout/image/shenlu/"..cfg.image..".png")
    --gameEffect.getFrameEffect( "scenebg/shenlu/"..cfg.plist, cfg.pattern, cfg.begin, cfg.length, cfg.time)
    :addTo(pageWidget)
    :setPosition(cc.p(pagesize.width/2,pagesize.height/2))
   
    return pageWidget
end
]]
function PanelShenlu.checkButtonClicked(tag)
    return true
end

function PanelShenlu.updatePanelByTag(tag)
    var.selectTab = tag
    --PanelShenlu.resetEffect()
    PanelShenlu.resetInfo(tag, true)
end

function PanelShenlu.resetInfo(tag,delay)
    if var.upBtn then UIButtonGuide.handleButtonGuideClicked(var.upBtn) end
    local info = NetClient.mShenluInfo[tag]
    if not info then return end

    var.totalPage = #SHENLU_EFFECT[var.selectTab]

    var.buqiText:setVisible(tag==SHENLU_TAG.YUXI)
    var.checkBox:setVisible(tag==SHENLU_TAG.YUXI)

    local rolelevel = game.getRoleLevel()
    local zslevel = game.getZsLevel()
    local max = false
    if info.curkind >= KIND_MAX then
        max = true
    end

    local curItemDef, nextItemDef
    if max then
        curItemDef = NetClient:getItemDefByID(info.base + 100*info.curlevel + info.curkind)
    else
        nextItemDef = NetClient:getItemDefByID(info.base + 100*info.curlevel + info.curkind + 1)
        if info.curkind > 0 then
            curItemDef = NetClient:getItemDefByID(info.base + 100*info.curlevel + info.curkind)
        end
    end

    local jiestr = ""
    local namestr = "未激活"
    local star = 0
    local pageIndex = 1
    if curItemDef then
        jiestr = num_to_str[info.curkind]
        pageIndex = num_to_pageid[info.curkind] or 1
        namestr = string.gsub(curItemDef.mName,"%[%d星%]","")
        star = checkint(string.match(curItemDef.mName, "%d+"))
    end
    --PanelShenlu.gotoPage(pageIndex,delay)
    PanelShenlu.newgotoPage(pageIndex)
    for i = 1, #var.starImg do
        var.starImg[i]:loadTexture(i<=star and "star1.png" or "star2.png", UI_TEX_TYPE_PLIST)
    end
    local PanelTitle = var.leftWidget:getWidgetByName("Panel_Title")
    local jieText = PanelTitle:getWidgetByName("Label_Jie")
    local nameText = PanelTitle:getWidgetByName("Label_Name")
    local parentSize = PanelTitle:getParent():getContentSize()
    jieText:setString(jiestr):align(display.LEFT_CENTER, 0,parentSize.height/2)
    nameText:setString(namestr):align(display.LEFT_CENTER, jieText:getContentSize().width,parentSize.height/2)
    PanelTitle:setContentSize(cc.size(jieText:getContentSize().width + nameText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)

    local cf = {
        {name = "Label_PhyAtkTitle", dis = ""},
        {name = "Label_MagAtkTitle", dis = ""},
        {name = "Label_DaoAtkTitle", dis = ""},
        {name = "Label_PhyDefTitle", dis = ""},
        {name = "Label_MagDefTitle", dis = ""},
    }

    local curValue = {
        { min = curItemDef and curItemDef.mDC or 0 , max = curItemDef and curItemDef.mDCMax or 0},
        { min = curItemDef and curItemDef.mMC or 0 , max = curItemDef and curItemDef.mMCMax or 0},
        { min = curItemDef and curItemDef.mSC or 0 , max = curItemDef and curItemDef.mSCMax or 0},
        { min = curItemDef and curItemDef.mAC or 0 , max = curItemDef and curItemDef.mACMax or 0},
        { min = curItemDef and curItemDef.mMAC or 0 , max = curItemDef and curItemDef.mMACMax or 0},
    }

    local nextValue = {
        { min = nextItemDef and nextItemDef.mDC or 0 , max = nextItemDef and nextItemDef.mDCMax or 0},
        { min = nextItemDef and nextItemDef.mMC or 0 , max = nextItemDef and nextItemDef.mMCMax or 0},
        { min = nextItemDef and nextItemDef.mSC or 0 , max = nextItemDef and nextItemDef.mSCMax or 0},
        { min = nextItemDef and nextItemDef.mAC or 0 , max = nextItemDef and nextItemDef.mACMax or 0},
        { min = nextItemDef and nextItemDef.mMAC or 0 , max = nextItemDef and nextItemDef.mMACMax or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
        local dismin = nextValue[k].min -  curValue[k].min
        local dismax = nextValue[k].max -  curValue[k].max
        if dismin > 0 or dismax > 0 then
            v.dis = "+"..dismin.."-"..dismax
        end
        if v.value == "0-0" and v.dis == "" then v.value = nil end
    end
    -- 生命上限
    local curatt = curItemDef and curItemDef.mMaxHpPres or 0
    local nextatt = nextItemDef and nextItemDef.mMaxHpPres or 0
    local disvalue = nextatt - curatt
    if curatt > 0 or disvalue > 0 then
        table.insert(cf, {name = "Label_HpMaxTitle", value = ((curatt/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
    else
        table.insert(cf, {name = "Label_HpMaxTitle"})
    end
    -- 反弹伤害
    curatt = curItemDef and curItemDef.mFantanPres or 0
    nextatt = nextItemDef and nextItemDef.mFantanPres or 0
    disvalue = nextatt - curatt
    if curatt > 0 or disvalue > 0 then
        table.insert(cf, {name = "Label_FantanTitle", value = ((curatt/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
    else
        table.insert(cf, {name = "Label_FantanTitle"})
    end

    -- 伤害减免
    curatt =  curItemDef and curItemDef.mDamageIgnore2 or 0
    nextatt = nextItemDef and nextItemDef.mDamageIgnore2 or 0
    disvalue = nextatt - curatt
    if curatt > 0 or disvalue > 0 then
        table.insert(cf, {name = "Label_ShanmianTitle", value = ((curatt/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
    else
        table.insert(cf, {name = "Label_ShanmianTitle"})
    end
    -- 暴击伤害
    curatt =  curItemDef and curItemDef.mBaoji_pres or 0
    nextatt = nextItemDef and nextItemDef.mBaoji_pres or 0
    disvalue = nextatt - curatt
    if curatt > 0 or disvalue > 0 then
        table.insert(cf, {name = "Label_BaojiHurtTitle", value = curatt, dis = disvalue > 0 and "+"..disvalue or "" })
    else
        table.insert(cf, {name = "Label_BaojiHurtTitle"})
    end

    local postionY = 479 --479.45 -- 26.62
    local space  = 30
    for _, v in ipairs(cf) do
        local attrlabel = var.rightWidget:getWidgetByName(v.name)
        if v.value then
            local panel = attrlabel:getWidgetByName("Panel_arr")
            local curText = panel:getWidgetByName("Label_Cur")
            local disText = panel:getWidgetByName("Label_Dis")
            local parentSize = panel:getParent():getContentSize()
            curText:setString(v.value):align(display.LEFT_CENTER, 0,parentSize.height/2)
            if v.dis == "" then
                disText:setString("")
            else
                disText:setString(v.dis):align(display.LEFT_CENTER, curText:getContentSize().width,parentSize.height/2)
            end

            panel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)
            attrlabel:setPositionY(postionY)
            postionY = postionY - space
            attrlabel:show()
        else
            attrlabel:hide()
        end
    end

    if not max and info.needpoint then
        var.needPanel:show()
        var.rightWidget:getWidgetByName("Panel_max"):hide()
        var.needExpText:setString("消耗"..SHENLU_TAG_NAME[tag].."积分")
        var.needExpText:getWidgetByName("Label_costys"):setString(info.needpoint)
        var.haveExpText:setString("拥有"..SHENLU_TAG_NAME[tag].."积分")
        var.haveExpText:getWidgetByName("Label_haveys"):setString(info.exppoint)
        var.rightWidget:getWidgetByName("Panel_max"):hide()
        local showeffect = false
        if nextItemDef then
            if nextItemDef.mNeedType and nextItemDef.mNeedType == 0 and rolelevel < nextItemDef.mNeedParam then
                var.upBtn:hide()
                var.needLevelText:setString("人物等级达到"..nextItemDef.mNeedParam.."级可升级"):show()
            elseif nextItemDef.mNeedType and nextItemDef.mNeedType == 4 and zslevel < nextItemDef.mNeedParam then
                var.upBtn:hide()
                var.needLevelText:setString("转生等级达到"..nextItemDef.mNeedParam.."级可升级"):show()
            else
                var.needLevelText:hide()
                var.upBtn:setTitleText(info.curkind > 0 and "升 级" or "激 活"):show()
                if info.exppoint >= info.needpoint then showeffect = true end
            end
            if showeffect then
                if not var.upeffect then
                    var.upeffect = gameEffect.getBtnSelectEffect()
                    var.upeffect:setPosition(cc.p(var.upBtn:getContentSize().width/2,var.upBtn:getContentSize().height/2))
                    var.upeffect:addTo(var.upBtn)
                end
                if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SHENLU) then
                    UIButtonGuide.addGuideTip(var.upBtn,UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.SHENLU),UIButtonGuide.UI_TYPE_LEFT)
                end
            else
                if var.upeffect then
                    var.upeffect:removeFromParent()
                    var.upeffect = nil
                end
            end
        else
            var.upBtn:hide()
            var.needLevelText:hide()
        end
        var.tipsBtn.desp = info.fromdesp
    else
        var.needPanel:hide()
        var.rightWidget:getWidgetByName("Panel_max"):show()
    end
end

function PanelShenlu.getAttrCfg()


    local cf = {
        {name = "Panel_PhyAtk", dis = ""},
        {name = "Panel_MagAtk", dis = ""},
        {name = "Panel_DaoAtk", dis = ""},
        {name = "Panel_PhyDef", dis = ""},
        {name = "Panel_MagDef", dis = ""},
    }

    local curValue = {
        { min = curItemDef and curItemDef.mDC or 0 , max = curItemDef and curItemDef.mDCMax or 0},
        { min = curItemDef and curItemDef.mMC or 0 , max = curItemDef and curItemDef.mMCMax or 0},
        { min = curItemDef and curItemDef.mSC or 0 , max = curItemDef and curItemDef.mSCMax or 0},
        { min = curItemDef and curItemDef.mAC or 0 , max = curItemDef and curItemDef.mACMax or 0},
        { min = curItemDef and curItemDef.mMAC or 0 , max = curItemDef and curItemDef.mMACMax or 0},
    }

    local nextValue = {
        { min = nextItemDef and nextItemDef.mDC or 0 , max = nextItemDef and nextItemDef.mDCMax or 0},
        { min = nextItemDef and nextItemDef.mMC or 0 , max = nextItemDef and nextItemDef.mMCMax or 0},
        { min = nextItemDef and nextItemDef.mSC or 0 , max = nextItemDef and nextItemDef.mSCMax or 0},
        { min = nextItemDef and nextItemDef.mAC or 0 , max = nextItemDef and nextItemDef.mACMax or 0},
        { min = nextItemDef and nextItemDef.mMAC or 0 , max = nextItemDef and nextItemDef.mMACMax or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
        local dismin = nextValue[k].min -  curValue[k].min
        local dismax = nextValue[k].max -  curValue[k].max
        if dismin > 0 or dismax > 0 then
            v.dis = "+"..dismin.."-"..dismax
        end
    end

    local curHpMax = curItemDef and curItemDef.mMaxHp or 0
    local nextHpMax = nextItemDef and nextItemDef.mMaxMp or 0
    local disvalue = nextHpMax - curHpMax
    table.insert(cf, {name = "Panel_HpMax", value = ((curHpMax/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
end

return PanelShenlu