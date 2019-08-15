--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/10/20 16:53
-- To change this template use File | Settings | File Templates.
-- 

local PanelWing= {}
local var = {}
local ACTIONSET_NAME = "wingtrain"

local JIE_MAX=13

local num_to_str={
    [1]="[一阶]",
    [2]="[二阶]",
    [3]="[三阶]",
    [4]="[四阶]",
    [5]="[五阶]",
    [6]="[六阶]",
    [7]="[七阶]",
    [8]="[八阶]",
    [9]="[九阶]",
    [10]="[十阶]",
    [11]="[十一阶]",
    [12]="[十二阶]",
    [13]="[十三阶]",
}

function PanelWing.initView(params)
    local params = params or {}
    var = {}
    var.autoBuy = false
    var.confirmtag = false
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelWing/UI_Wing_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_wing")

    PanelWing.initWidget()
    PanelWing.resetEffect()
    PanelWing.resetInfo(true)
    PanelWing.registeEvent()
    return var.widget
end

function PanelWing.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelWing.handleWingMsg)
end

function PanelWing.handleWingMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type == ACTIONSET_NAME then
        if d.actionid then
            if d.actionid == "queryinfo" then
                PanelWing.resetInfo()
            end
        end
    end
end

function PanelWing.initWidget()
    var.leftWidget = var.widget:getWidgetByName("Image_left")
    var.rightWidget = var.widget:getWidgetByName("Image_right")
    var.upBtn = var.rightWidget:getWidgetByName("Button_up")
    var.needLevelText = var.rightWidget:getWidgetByName("Text_level_alert")
    var.needPanel = var.rightWidget:getWidgetByName("needPanel")
    var.needExpText = var.needPanel:getWidgetByName("Label_costtitle")
    var.haveExpText = var.needPanel:getWidgetByName("Label_havetitle")
    var.pageView = var.leftWidget:getWidgetByName("PageView_effect")
    var.buqiText = var.rightWidget:getWidgetByName("Text_buqi")
    var.checkBox = var.rightWidget:getWidgetByName("CheckBox_buqi")

    var.starImg = {}
    for i = 1, 5 do
        var.starImg[i] = var.leftWidget:getWidgetByName("Image_star"..i)
    end

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
        if not NetClient.mWingInfo.info or not NetClient.mWingInfo.baseInfo then return end

        if NetClient.mWingInfo.info.nextexp > NetClient.mWingInfo.info.curexp then
            if var.autoBuy then
                if var.confirmtag then
                    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "train", params = 3}))
                else
                    local needyb =math.ceil(((NetClient.mWingInfo.info.nextexp - NetClient.mWingInfo.info.curexp)/NetClient.mWingInfo.baseInfo.expworth)*100);
                    local param = {
                        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否使用"..needyb.."元宝补齐余下的翅膀声望？",
                        confirmTitle = "确 定", cancelTitle = "取 消",
                        confirmCallBack = function ()
                            var.confirmtag = true
                            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "train", params = 3}))
                        end
                    }
                    NetClient:dispatchEvent(param)
                end
                
            else
                NetClient:alertLocalMsg("翅膀声望不足","alert")
            end
        else
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid = "train", params = 1}))
        end
    end)

    var.btnNext = var.leftWidget:getWidgetByName("Button_next")
    var.btnNext:addClickEventListener(function(pSender)
        PanelWing.onChangePage(1)
    end)

    var.btnPre = var.leftWidget:getWidgetByName("Button_pre")
    var.btnPre:addClickEventListener(function(pSender)
        PanelWing.onChangePage(-1)
    end)

    var.tipsBtn = var.rightWidget:getWidgetByName("Button_tips")
    var.tipsBtn:addClickEventListener(function(pSender)
        UIAnimation.oneTips({
            parent = pSender,
            msg = pSender.desp,
        })
    end)
end

function PanelWing.onChangePage(flag)
    local page = var.curPage + flag
    if page > var.totalPage or page < 1 or flag == 0 then
        return
    end
    var.curPage = page
    var.btnPre:setTouchEnabled(var.curPage>1)
    var.btnNext:setTouchEnabled(var.curPage<var.totalPage)
    var.pageView:scrollToPage(var.curPage-1)
end

function PanelWing.gotoPage(page, delay)
    if page > var.totalPage then page = var.totalPage end
    if page < 1 then
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

function PanelWing.resetEffect()
    var.curPage = 1
    var.totalPage = JIE_MAX
    cc.BinManager:getInstance():loadBiz(Const.AVATAR_EFFECT.AVATAR_MODEL_WING,"biz/modelwing.biz")
    var.pageView:removeAllPages()
    for i = 1, var.totalPage do
        var.pageView:addPage(PanelWing.createEffectPage(i))
    end
    var.btnPre:setTouchEnabled(false)
    var.btnNext:setTouchEnabled(true)
end

function PanelWing.createEffectPage(page)
    local pagesize = var.pageView:getContentSize()
    local pageWidget = ccui.Widget:create()
    pageWidget:setContentSize(pagesize)


    local wingImg = cc.Sprite:create()
    if cc.AnimManager:getInstance():getBinAnimateAsync(wingImg,Const.AVATAR_EFFECT.AVATAR_MODEL_WING,1000+page,0) then
        wingImg:align(display.CENTER, pagesize.width/2, pagesize.height/2)
        pageWidget:addChild(wingImg)
    end

    return pageWidget
end

function PanelWing.getSatusDef(jie,lv)
    local status_id
    local baseinfo = NetClient.mWingInfo.baseInfo.base
    if baseinfo then
        status_id =  baseinfo[jie].attrid
    end

    if status_id then
        return NetClient:getStatusDefByID(status_id, lv)
    end

end

function PanelWing.resetInfo(delay)
    if var.upBtn then UIButtonGuide.handleButtonGuideClicked(var.upBtn) end
    local info = NetClient.mWingInfo.info
    local baseinfo = NetClient.mWingInfo.baseInfo
    if not info or not baseinfo then return end

    local rolelevel = game.getRoleLevel()
    local zslevel = game.getZsLevel()
    local max = false
    if info.curlevel >= JIE_MAX then
        max = true
    end

    local curAttrInfo, nextAttrInfo
    if max then
        curAttrInfo = PanelWing.getSatusDef(info.curlevel,info.curxing)
    else
        nextAttrInfo = PanelWing.getSatusDef(info.nextlevel,info.nextxing)
        if info.curlevel > 0 then
            curAttrInfo = PanelWing.getSatusDef(info.curlevel,info.curxing)
        end
    end

    local pageIndex = 1
    local jiestr = ""
    local namestr = "未激活"
    if curAttrInfo then
        jiestr = num_to_str[info.curlevel]
        namestr = string.gsub(curAttrInfo.mName,"%d+阶%d+星","")
        pageIndex = info.curlevel
    end
    PanelWing.gotoPage(pageIndex,delay)
    for i = 1, #var.starImg do
        var.starImg[i]:loadTexture(i<info.curxing and "star1.png" or "star2.png", UI_TEX_TYPE_PLIST)
    end
    local PanelTitle = var.leftWidget:getWidgetByName("Panel_Title")
    local jieText = PanelTitle:getWidgetByName("Label_Jie")
    local nameText = PanelTitle:getWidgetByName("Label_Name")
    local parentSize = PanelTitle:getParent():getContentSize()
    jieText:setString(jiestr):align(display.LEFT_CENTER, 0,parentSize.height/2)
    nameText:setString(namestr):align(display.LEFT_CENTER, jieText:getContentSize().width,parentSize.height/2)
    PanelTitle:setContentSize(cc.size(jieText:getContentSize().width + nameText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)

    local cf = {
        {name = "Panel_PhyAtk", dis = ""},
        {name = "Panel_MagAtk", dis = ""},
        {name = "Panel_DaoAtk", dis = ""},
        {name = "Panel_PhyDef", dis = ""},
        {name = "Panel_MagDef", dis = ""},
    }

    local curValue = {
        { min = curAttrInfo and curAttrInfo.mDC or 0 , max = curAttrInfo and curAttrInfo.mDCmax or 0},
        { min = curAttrInfo and curAttrInfo.mMC or 0 , max = curAttrInfo and curAttrInfo.mMCmax or 0},
        { min = curAttrInfo and curAttrInfo.mSC or 0 , max = curAttrInfo and curAttrInfo.mSCmax or 0},

        { min = curAttrInfo and curAttrInfo.mAC or 0 , max = curAttrInfo and curAttrInfo.mACmax or 0},
        { min = curAttrInfo and curAttrInfo.mMAC or 0 , max = curAttrInfo and curAttrInfo.mMACmax or 0},

        { min = curAttrInfo and curAttrInfo.mFightPoint or 0},
    }

    local nextValue = {
        { min = nextAttrInfo and nextAttrInfo.mDC or 0 , max = nextAttrInfo and nextAttrInfo.mDCmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mMC or 0 , max = nextAttrInfo and nextAttrInfo.mMCmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mSC or 0 , max = nextAttrInfo and nextAttrInfo.mSCmax or 0},

        { min = nextAttrInfo and nextAttrInfo.mAC or 0 , max = nextAttrInfo and nextAttrInfo.mACmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mMAC or 0 , max = nextAttrInfo and nextAttrInfo.mMACmax or 0},

        { min = nextAttrInfo and nextAttrInfo.mFightPoint or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
        local dismin = nextValue[k].min -  curValue[k].min
        local dismax = nextValue[k].max -  curValue[k].max
        if dismin > 0 or dismax > 0 then
            v.dis = "+"..dismin.."-"..dismax
        end
    end

--    local curv = info.curpoint
--    local nextv = info.nextpoint
--    local disvalue = nextv - curv
--    table.insert(cf, {name = "Panel_Fp", value = curv, dis = disvalue > 0 and "+"..disvalue or "" })

    local curv = curAttrInfo and curAttrInfo.luck or 0
    local nextv = nextAttrInfo and nextAttrInfo.luck or 0
    local disvalue = nextv - curv
    table.insert(cf, {name = "Panel_Lucy", value = ((curv/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
    for _, v in ipairs(cf) do
        local panel = var.rightWidget:getWidgetByName(v.name)
        local curText = panel:getWidgetByName("Label_Cur")
        local disText = panel:getWidgetByName("Label_Dis")
        local parentSize = panel:getParent():getContentSize()
        curText:setString(v.value):align(display.LEFT_CENTER, 0,parentSize.height/2)
        disText:setString(v.dis):align(display.LEFT_CENTER, curText:getContentSize().width,parentSize.height/2)
        panel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)
    end

    -- 战力
    local fpanel = var.rightWidget:getWidgetByName("Panel_new_fp")
    local curText = fpanel:getWidgetByName("Image_zhanli_title")
    local disText = fpanel:getWidgetByName("AtlasLabel_zhanli")
    local fparentSize = fpanel:getParent():getContentSize()
    disText:setString(info.curpoint)
    fpanel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, fparentSize.height))--:setPositionX(fparentSize.width/2)
--
--
--    local fpanel = var.rightWidget:getWidgetByName("Panel_new_fp")
--    local curText = fpanel:getWidgetByName("Image_zhanli_title")
--    local disText = fpanel:getWidgetByName("AtlasLabel_zhanli")
--    local fparentSize = fpanel:getParent():getContentSize()
--    curText:align(display.LEFT_CENTER, 0,fparentSize.height/2)
--    disText:setString(info.curpoint):align(display.LEFT_CENTER, curText:getContentSize().width,fparentSize.height/2)
--    fpanel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, fparentSize.height)):align(display.CENTER, fparentSize.width/2, fparentSize.height/2+2)

    if not max and info.nextexp then
        local showeffect = false
        var.needPanel:show()
        var.needExpText:getWidgetByName("Label_costys"):setString(info.nextexp)
        var.haveExpText:getWidgetByName("Label_haveys"):setString(info.curexp)
        var.rightWidget:getWidgetByName("Panel_max"):hide()
        if nextAttrInfo then
            local nextbaseinfo = baseinfo.base[info.nextlevel]
            if nextbaseinfo then
                if nextbaseinfo.needtype and nextbaseinfo.needtype == 0 and rolelevel < nextbaseinfo.need_level then
                    var.upBtn:hide()
                    var.needLevelText:setString("人物等级达到"..nextbaseinfo.need_level.."级可升级"):show()
                elseif nextbaseinfo.needtype and nextbaseinfo.needtype == 4 and zslevel < nextbaseinfo.need_level then
                    var.upBtn:hide()
                    var.needLevelText:setString("转生等级达到"..nextbaseinfo.need_level.."级可升级"):show()
                else
                    var.needLevelText:hide()
                    var.upBtn:setTitleText(info.curlevel > 0 and "升 级" or "激 活"):show()
                    if info.curexp >= info.nextexp then
                        showeffect = true
                    end
                end
            else
                var.upBtn:hide()
                var.needLevelText:hide()
            end
        else
            var.upBtn:hide()
            var.needLevelText:hide()
        end
        var.tipsBtn.desp =  baseinfo.content
        if showeffect then
            if not var.upeffect then
                var.upeffect = gameEffect.getBtnSelectEffect()
                var.upeffect:setPosition(cc.p(var.upBtn:getContentSize().width/2,var.upBtn:getContentSize().height/2))
                var.upeffect:addTo(var.upBtn)
            end

            if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.WING) then
                UIButtonGuide.addGuideTip(var.upBtn,UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.WING),UIButtonGuide.UI_TYPE_LEFT)
            end
        else
            if var.upeffect then
                var.upeffect:removeFromParent()
                var.upeffect = nil
            end
        end
    else
        var.needPanel:hide()
        var.rightWidget:getWidgetByName("Panel_max"):show()
    end
end

return PanelWing