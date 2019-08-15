local PanelAchieve = {}
local var = {}
local ZHANG_EFFECT = {
    {plist = "huizhang0", pattern = "huizhang0_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang1", pattern = "huizhang1_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang2", pattern = "huizhang2_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang3", pattern = "huizhang3_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang4", pattern = "huizhang4_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang5", pattern = "huizhang5_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang6", pattern = "huizhang6_%02d.png", begin = 1, length = 10, time = 0.2},
    {plist = "huizhang7", pattern = "huizhang7_%02d.png", begin = 1, length = 10, time = 0.2},
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

function PanelAchieve.initView(params)
    local params = params or {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAchieve/PanelAchieve.csb")
    widget:addTo(params.parent, params.zorder)
    var.selectTab = 1
    if UIRedPoint.checkXunzhang() > 0 then
        var.selectTab = 2
    end

    var.widget = widget:getChildByName("Panel_achieve")

    PanelAchieve.registeEvent()
    PanelAchieve.addMenuTabClickEvent()
    return var.widget
end

function PanelAchieve.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
        :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelAchieve.handlePanelData)
end

function PanelAchieve.handlePanelData(event)
    if event and event.type == "achieve_page_data" then
        local achieve_data = json.decode(event.data)
        if not achieve_data then return end
        if var.selectTab == 1 then
            if achieve_data.subtype == var.curPanelselectTab then
                if achieve_data.achievelist and #achieve_data.achievelist > 0 then
                    var.mAchieveData = achieve_data.achievelist
                    var.curPanel:getWidgetByName("num_cur_point"):setString(achieve_data.point)
                    PanelAchieve.updateAchievePage(var.curPanelselectTab)
                end
            end
        end
    elseif event and event.type == "medal_data" then
        local medal_data = json.decode(event.data)
        if not medal_data then return end
        if var.selectTab == 2 then
            var.curPanel:getWidgetByName("Label_costpoint"):setString(medal_data.needpoint)
            var.curPanel:getWidgetByName("Label_havepoint"):setString(medal_data.exppoint)
            var.curPanel:getWidgetByName("Button_tips").desp = medal_data.fromdesp
            PanelAchieve.updateMedalByKJ(medal_data.curkind,medal_data.curlevel,medal_data.start_typeid)

            if medal_data.canup == 1 then
                local btn_up = var.curPanel:getWidgetByName("Button_up")
                if not var.upeffect then
                    var.upeffect = gameEffect.getBtnSelectEffect()
                    var.upeffect:setPosition(cc.p(btn_up:getContentSize().width/2,btn_up:getContentSize().height/2))
                    var.upeffect:addTo(btn_up)
                end
            else
                if var.upeffect then
                    var.upeffect:removeFromParent()
                    var.upeffect = nil
                end
            end
        end
    elseif event and event.type == "title_data" then
        local title_data = json.decode(event.data)
        if not title_data then return end
        if var.selectTab == 3 then
            var.mTitleData = title_data
            PanelAchieve.updateTitle()
        end
    elseif event and event.type == "cur_title" then
        local title_data = json.decode(event.data)
        if not title_data then return end
        if var.mSortData and #var.mSortData > 0 then
            if var.mCurTitle > 0 and var.mCurTitle ~= title_data.curtitle then
                for i=1,#var.mSortData do
                    if var.mSortData[i].idx == var.mCurTitle then
                        local item = var.curPanel:getWidgetByName("list_title"):getItem(i-1)
                        if item then
                            item:getWidgetByName("title_show"):hide()
                        end
                    end
                    if var.mSortData[i].idx == title_data.curtitle then
                        local item = var.curPanel:getWidgetByName("list_title"):getItem(i-1)
                        if item then
                            item:getWidgetByName("title_show"):show()
                        end
                    end
                end
            end
            local select_data = var.mSortData[var.mLastSelectItem]
            if select_data.idx == title_data.curtitle then
                local item = var.curPanel:getWidgetByName("list_title"):getItem(var.mLastSelectItem-1)
                if item then
                    item:getWidgetByName("title_show"):show()
                end
                var.curPanel:getWidgetByName("Button_equip"):setTitleText("卸下")
            else
                local item = var.curPanel:getWidgetByName("list_title"):getItem(var.mLastSelectItem-1)
                if item then
                    item:getWidgetByName("title_show"):hide()
                end
                var.curPanel:getWidgetByName("Button_equip"):setTitleText("显示")
            end
        end
        var.mCurTitle = title_data.curtitle
    end
end

function PanelAchieve.updateAchievePage(page)
    if var.mAchieveData and #var.mAchieveData > 0 then
        var.curPanel:getWidgetByName("list_achieve"):removeAllItems()
        local function sortFunction(fa, fb)
            
            if fa.flag == fb.flag then
                return fa.index < fb.index
            end
            local temp_flagA = (fa.flag == 1 and 3 or fa.flag)
            local temp_flagB = (fb.flag == 1 and 3 or fb.flag)
            return temp_flagA > temp_flagB
        end
        table.sort(var.mAchieveData, sortFunction )
        for i=1,#var.mAchieveData do
            local temp_data = var.mAchieveData[i]
            local item_model = var.curPanel:getWidgetByName("model_achieve"):clone()
            item_model:getWidgetByName("name"):setString(temp_data.name)
            item_model:getWidgetByName("Image_high"):hide()
            item_model:getWidgetByName("img_al_done"):hide()
            item_model:getWidgetByName("Button_get"):hide()
            item_model:getWidgetByName("label_done"):hide()
            item_model:getWidgetByName("label_all"):hide()
            for j=1,#temp_data.award do
                if temp_data.award[j].typeid == 19032 then
                    item_model:getWidgetByName("point"):setString(temp_data.award[j].num)
                elseif temp_data.award[j].typeid == 19001 then
                    item_model:getWidgetByName("exp"):setString(temp_data.award[j].num)
                end
            end
            if temp_data.flag == 0 then
                item_model:getWidgetByName("label_done"):show():setString(temp_data.curvalue)
                item_model:getWidgetByName("label_all"):show():setString("/"..temp_data.maxvalue)
            elseif temp_data.flag == 1 then
                local btn_get = item_model:getWidgetByName("Button_get")
                btn_get:show()
                UIRedPoint.addUIPoint({parent=btn_get, callback=function (pSender)
                    NetClient:PushLuaTable("newgui.achieve1.onGetJsonData",util.encode({actionid = "drawachievegift",subtype=var.curPanelselectTab,idx=temp_data.index}))
                end})
                btn_get.point:show()
            else
                item_model:getWidgetByName("img_al_done"):show()
            end
            var.curPanel:getWidgetByName("list_achieve"):pushBackCustomItem(item_model)
        end
    end
end

function PanelAchieve.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local cp = cc.p(125,61)
    local RadionButtonGroup = UIRadioButtonGroup.new()
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_achieve"), position=cp, types={UIRedPoint.REDTYPE.ACHIEVE_PAGE,UIRedPoint.REDTYPE.ACHIEVE1,UIRedPoint.REDTYPE.ACHIEVE2,UIRedPoint.REDTYPE.ACHIEVE3,UIRedPoint.REDTYPE.ACHIEVE4,UIRedPoint.REDTYPE.ACHIEVE5,UIRedPoint.REDTYPE.ACHIEVE6}}))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_zhang"), position=cp, types={UIRedPoint.REDTYPE.ACHIEVE_MEDAL}}))
        -- :addButton(var.widget:getWidgetByName("Button_achieve"))
        -- :addButton(var.widget:getWidgetByName("Button_zhang"))
        :addButton(var.widget:getWidgetByName("Button_title"))
        :onButtonSelectChanged(function(event)
            PanelAchieve.updatePanelByTag(event.selected)
        end)
    RadionButtonGroup:setButtonSelected(var.selectTab)
end

function PanelAchieve.updatePanelByTag(tag)
    if var.widget:getChildByName("child_widget") then
	   var.widget:removeChildByName("child_widget")
    end
    var.selectTab = tag
	if tag == 1 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAchieve/PanelAchieveMain.csb")
		widget:setPosition(cc.p(56,25))
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_achieve_main")
        var.curPanelselectTab = 1
        var.curPanel:getWidgetByName("Button_onekey"):addClickEventListener(function (pSender)
            UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.CHENGJIU})
            NetClient:PushLuaTable("newgui.achieve1.onGetJsonData",util.encode({actionid = "drawallachievegift",page=var.curPanelselectTab}))
        end)
        PanelAchieve.initAchieveListBtn()

        if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.CHENGJIU) then
            UIButtonGuide.addGuideTip(var.curPanel:getWidgetByName("Button_onekey"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.CHENGJIU),UIButtonGuide.UI_TYPE_LEFT)
        else
            UIButtonGuide.clearGuideTip(var.curPanel:getWidgetByName("Button_onekey"))
        end
    elseif tag == 2 then
        local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAchieve/PanelMedal.csb")
        widget:setPosition(cc.p(56,25))
        widget:setName("child_widget")
        widget:addTo(var.widget)
        var.curPanel = widget:getChildByName("Panel_medal_main")
        -- PanelAchieve.initAchieveListBtn()
        var.mAutoBuqi = false
        var.curPanel:getWidgetByName("Panel_max"):hide()
        var.curPanel:getWidgetByName("CheckBox_buqi"):setSelected(false):addClickEventListener(function (pSender)
            var.mAutoBuqi = not var.mAutoBuqi
        end)
        var.curPanel:getWidgetByName("Button_up"):addClickEventListener(function (pSender)
            NetClient:PushLuaTable("newgui.medal.onGetJsonData",util.encode({actionid = "upgrade",buy=(var.mAutoBuqi and 3 or 1)}))--2提示补齐 3直接补齐
        end)

        var.btnNext = var.curPanel:getWidgetByName("Button_next")
        var.btnNext:addClickEventListener(function(pSender)
            PanelAchieve.onChangePage(1)
        end)

        var.btnPre = var.curPanel:getWidgetByName("Button_pre")
        var.btnPre:addClickEventListener(function(pSender)
            PanelAchieve.onChangePage(-1)
        end)

        var.pageView = var.curPanel:getWidgetByName("PageView_effect"):hide()
        var.effectbg = var.curPanel:getWidgetByName("Image_effectbg")
        var.curPage = 1
        var.totalPage = 8

        --[[
        var.pageView:removeAllPages()
        for i = 1, var.totalPage do
            var.pageView:addPage(PanelAchieve.createEffectPage(i))
        end
        var.pageView:show()
        ]]
        var.btnPre:setTouchEnabled(true)
        var.btnNext:setTouchEnabled(true)

        var.curPanel:getWidgetByName("Button_tips"):addClickEventListener(function(pSender)
            UIAnimation.oneTips({
                parent = pSender,
                msg = pSender.desp,
            })
        end)

        NetClient:PushLuaTable("newgui.medal.onGetJsonData",util.encode({actionid = "getMedalData"}))
    elseif tag == 3 then
        local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAchieve/PanelTitle.csb")
        widget:setPosition(cc.p(56,25))
        widget:setName("child_widget")
        widget:addTo(var.widget)
        var.curPanel = widget:getChildByName("Panel_title")
        var.mTitleData = {}
        var.mSortData = {}
        var.mCurTitle = 0
        var.curPanel:getWidgetByName("Button_equip"):addClickEventListener(function (pSender)
            local temp_data = var.mSortData[var.mLastSelectItem]
            if temp_data then
                local curtitle = 0
                if var.mCurTitle ~= temp_data.idx then curtitle = temp_data.idx end
                NetClient:PushLuaTable("newgui.title.onGetJsonData",util.encode({actionid = "cur_title",curtitle=curtitle}))
            end
        end)
        NetClient:PushLuaTable("newgui.title.onGetJsonData",util.encode({actionid = "getTitleData"}))
	end
end

function PanelAchieve.initAchieveListBtn()
    local UIRadioButtonGroup = UIRadioButtonGroup.new()
    :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_1"), types={UIRedPoint.REDTYPE.ACHIEVE1}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_2"), types={UIRedPoint.REDTYPE.ACHIEVE2}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_3"), types={UIRedPoint.REDTYPE.ACHIEVE3}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_4"), types={UIRedPoint.REDTYPE.ACHIEVE4}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_5"), types={UIRedPoint.REDTYPE.ACHIEVE5}}))
    :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_6"), types={UIRedPoint.REDTYPE.ACHIEVE6}}))
    -- :addButton(UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("btn_left_7"), types={UIRedPoint.REDTYPE.ACHIEVE7}}))
    :onButtonSelectChanged(function(event)
        PanelAchieve.updateListViewByTag(event.selected)
    end)
    UIRadioButtonGroup:setButtonSelected(var.curPanelselectTab)
    for i=1,6 do
        UIRedPoint.handleChange({UIRedPoint.REDTYPE.ACHIEVE+i})
    end
end

function PanelAchieve.updateListViewByTag(tag)
    var.curPanelselectTab = tag
    var.mAchieveData = {}
    NetClient:PushLuaTable("newgui.achieve1.onGetJsonData",util.encode({actionid = "getSinglePageData",page=var.curPanelselectTab}))
end

function PanelAchieve.updateMedalByKJ(curkind,curlevel,starttypeid)
    for i=1,3 do
        var.curPanel:getWidgetByName("Image_star"..i):loadTexture(i <= (curkind - math.floor((curkind-1)/3)*3) and "star1.png" or "star2.png", UI_TEX_TYPE_PLIST)
    end
    local pageIndex = 1
    local namestr = "未激活"
    local jiestr = ""
    local item
    local nextItem
    if curkind > 0 then
        item = NetClient:getItemDefByID(starttypeid+(curlevel-1)*100+curkind-1)
        if item then
            namestr=item.mName
            nextItem = NetClient:getItemDefByID(starttypeid+(curlevel-1)*100+curkind)
        end
    else
        nextItem = NetClient:getItemDefByID(starttypeid)
    end
    pageIndex = num_to_pageid[curkind] or 1
    --PanelAchieve.newgotoPage(pageIndex,delay)
    PanelAchieve.newgotoPage(pageIndex)
    local PanelTitle = var.curPanel:getWidgetByName("Panel_Title")
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
        { min = item and item.mDC or 0 , max = item and item.mDCMax or 0},
        { min = item and item.mMC or 0 , max = item and item.mMCMax or 0},
        { min = item and item.mSC or 0 , max = item and item.mSCMax or 0},

        { min = item and item.mAC or 0 , max = item and item.mACMax or 0},
        { min = item and item.mMAC or 0 , max = item and item.mMACMax or 0},

        { min = item and item.mFightPoint or 0},
    }

    local nextValue = {
        { min = nextItem and nextItem.mDC or 0 , max = nextItem and nextItem.mDCMax or 0},
        { min = nextItem and nextItem.mMC or 0 , max = nextItem and nextItem.mMCMax or 0},
        { min = nextItem and nextItem.mSC or 0 , max = nextItem and nextItem.mSCMax or 0},

        { min = nextItem and nextItem.mAC or 0 , max = nextItem and nextItem.mACMax or 0},
        { min = nextItem and nextItem.mMAC or 0 , max = nextItem and nextItem.mMACMax or 0},

        { min = nextItem and nextItem.mFightPoint or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
        local dismin = nextValue[k].min -  curValue[k].min
        local dismax = nextValue[k].max -  curValue[k].max
        if dismin > 0 or dismax > 0 then
            v.dis = "+"..dismin.."-"..dismax
        end
    end

    local curv = item and item.mIgnoreDef or 0
    local nextv = nextItem and nextItem.mIgnoreDef or 0
    local disvalue = nextv - curv
    table.insert(cf, {name = "Panel_Lucy", value = ((curv/10000)*100).."%", dis = disvalue > 0 and "+"..((disvalue/10000)*100).."%" or "" })
    for _, v in ipairs(cf) do
        local panel = var.curPanel:getWidgetByName(v.name)
        local curText = panel:getWidgetByName("Label_Cur")
        local disText = panel:getWidgetByName("Label_Dis")
        local parentSize = panel:getParent():getContentSize()
        curText:setString(v.value):align(display.LEFT_CENTER, 0,parentSize.height/2)
        disText:setString(v.dis):align(display.LEFT_CENTER, curText:getContentSize().width,parentSize.height/2)
        panel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)
    end

    if nextItem then
        if nextItem.mNeedParam > game.GetMainRole():NetAttr(Const.net_level) then
            var.curPanel:getWidgetByName("needPanel"):hide()
            var.curPanel:getWidgetByName("Panel_max"):show()
            var.curPanel:getWidgetByName("label_max_level"):setString("下一阶需要等级:"..nextItem.mNeedParam)
            
        end
    else
        var.curPanel:getWidgetByName("needPanel"):hide()
        var.curPanel:getWidgetByName("Panel_max"):show()
            var.curPanel:getWidgetByName("label_max_level"):setString("已达最高级")
    end
end

function PanelAchieve.updateTitle()
    local list_title = var.curPanel:getWidgetByName("list_title")
    list_title:removeAllItems()
    var.mSortData = {}
    for k,v in pairs(var.mTitleData) do
        if v.hide == 0 then
            table.insert(var.mSortData,v)
        end
    end
    local function sortFunction(fa, fb)
        if fa.flag == fb.flag then
            return fa.idx < fb.idx
        end
        return fa.flag < fb.flag
    end
    table.sort(var.mSortData, sortFunction )
    for i=1,#var.mSortData do
        local temp_data = var.mSortData[i]
        local item_model = var.curPanel:getWidgetByName("model_achieve"):clone()
        item_model:getWidgetByName("Image_high"):hide()
        item_model:getWidgetByName("title_show"):hide()
        item_model:getWidgetByName("item_bg"):loadTexture("nametitle/"..temp_data.name..".png",UI_TEX_TYPE_LOCAL)
        if temp_data.flag >= 1 then
            item_model:getWidgetByName("item_bg"):getVirtualRenderer():setState(1)
        end
        if temp_data.idx == var.mCurTitle then
            item_model:getWidgetByName("title_show"):show()
        end
        item_model:addClickEventListener(function (pSender)
            local item = var.curPanel:getWidgetByName("list_title"):getItem(var.mLastSelectItem-1)
            item:getWidgetByName("Image_high"):hide()
            var.mLastSelectItem = i
            pSender:getWidgetByName("Image_high"):show()
            PanelAchieve.updateTitleByIdx(i)
        end)
        list_title:pushBackCustomItem(item_model)

        if i == 1 then
            var.mLastSelectItem = 1
            item_model:getWidgetByName("Image_high"):show()
            PanelAchieve.updateTitleByIdx(var.mLastSelectItem)
        end
    end
    PanelAchieve.updateTitleAllAttr()
end

function PanelAchieve.updateTitleAllAttr()
    for i=1,6 do
        var.curPanel:getWidgetByName("all_attr_"..i):hide()
    end
    local all_attr_tab = {
        {"物理攻击：",0,0},
        {"魔法攻击：",0,0},
        {"道术攻击：",0,0},
        {"物理防御：",0,0},
        {"魔法防御：",0,0},
        {"生命上限：",0,0},
    }
    for i=1,#var.mSortData do
        local temp_data = var.mSortData[i]
        if temp_data.flag == 0 then
            local mAttrInfo = NetClient:getStatusDefByID(temp_data.buffid,temp_data.guildlv)
            if mAttrInfo then
                all_attr_tab[1][2] = all_attr_tab[1][2] + mAttrInfo.mDC
                all_attr_tab[1][3] = all_attr_tab[1][3] + mAttrInfo.mDCmax
                all_attr_tab[2][2] = all_attr_tab[2][2] + mAttrInfo.mMC
                all_attr_tab[2][3] = all_attr_tab[2][3] + mAttrInfo.mMCmax
                all_attr_tab[3][2] = all_attr_tab[3][2] + mAttrInfo.mSC
                all_attr_tab[3][3] = all_attr_tab[3][3] + mAttrInfo.mSCmax
                all_attr_tab[4][2] = all_attr_tab[4][2] + mAttrInfo.mAC
                all_attr_tab[4][3] = all_attr_tab[4][3] + mAttrInfo.mACmax
                all_attr_tab[5][2] = all_attr_tab[5][2] + mAttrInfo.mMAC
                all_attr_tab[5][3] = all_attr_tab[5][3] + mAttrInfo.mMACmax
                all_attr_tab[6][2] = all_attr_tab[6][2] + mAttrInfo.hpmaxadd
            end
        end
    end
    local index = 1
    for i=1,#all_attr_tab do
        if all_attr_tab[i][2] > 0 or all_attr_tab[i][3] > 0 then
            var.curPanel:getWidgetByName("all_attr_"..index):show():setString(all_attr_tab[i][1])
            local attr_str = all_attr_tab[i][2].."-"..all_attr_tab[i][3]
            if i == 6 then
                attr_str = all_attr_tab[i][2]
            end
            var.curPanel:getWidgetByName("all_attr_"..index):getWidgetByName("Label_attr"):setString(attr_str)
            index = index + 1
        end
    end
end

function PanelAchieve.updateTitleByIdx(idx)
    local temp_data = var.mSortData[idx]
    if temp_data then
        var.curPanel:getWidgetByName("img_cur_title"):loadTexture("nametitle/"..temp_data.name..".png",UI_TEX_TYPE_LOCAL)
        var.curPanel:getWidgetByName("label_title_condition"):setString(temp_data.desp)
        local mAttrInfo = NetClient:getStatusDefByID(temp_data.buffid,temp_data.guildlv)
        if mAttrInfo then
            PanelAchieve.updateTitleAttr(mAttrInfo,temp_data.buffid)
            var.curPanel:getWidgetByName("Button_equip"):setTitleText("显示"):setBright(true)
            var.curPanel:getWidgetByName("left_time"):show()
            var.curPanel:getWidgetByName("label_left_time"):show():setString("永久")
            if temp_data.flag >= 1 then
                var.curPanel:getWidgetByName("Button_equip"):setTitleText("显示"):setBright(false)
                if temp_data.lefttime == -1 then
                    var.curPanel:getWidgetByName("left_time"):hide()
                    var.curPanel:getWidgetByName("label_left_time"):hide()
                end
            elseif temp_data.flag == 0 then
                if temp_data.idx == var.mCurTitle then
                    var.curPanel:getWidgetByName("Button_equip"):setTitleText("卸下"):setBright(true)
                end
                if temp_data.lefttime > 0 then
                    var.curPanel:getWidgetByName("left_time"):show()
                    local day = math.floor(temp_data.lefttime/(60*60*24))
                    local left = temp_data.lefttime%(60*60*24)
                    local hour = math.floor(left/(60*60))
                    left = left%(60*60)
                    local min = math.floor(left/60)
                    local str = "永久"
                    if day > 0 then
                        str = day.."天"
                    elseif hour > 0 then
                        str = hour.."小时"
                    else
                        str = min.."分钟"
                    end
                    var.curPanel:getWidgetByName("label_left_time"):show():setString(str)
                end
            end
        end
    end
end

function PanelAchieve.updateTitleAttr(attr_info,buffid)
    if buffid == 158 then
        var.curPanel:getWidgetByName("cur_attr_1"):setString("物理防御：")
        var.curPanel:getWidgetByName("cur_attr_1"):getWidgetByName("Label_attr"):setString(attr_info.mAC.."-"..attr_info.mACmax)
        var.curPanel:getWidgetByName("cur_attr_2"):setString("魔法防御：")
        var.curPanel:getWidgetByName("cur_attr_2"):getWidgetByName("Label_attr"):setString(attr_info.mMAC.."-"..attr_info.mMACmax)
        var.curPanel:getWidgetByName("cur_attr_3"):setString("生命上限：")
        var.curPanel:getWidgetByName("cur_attr_3"):getWidgetByName("Label_attr"):setString(attr_info.hpmaxadd)
        var.curPanel:getWidgetByName("cur_attr_4"):hide()
    else
        var.curPanel:getWidgetByName("cur_attr_1"):setString("物理攻击：")
        var.curPanel:getWidgetByName("cur_attr_1"):getWidgetByName("Label_attr"):setString(attr_info.mDC.."-"..attr_info.mDCmax)
        var.curPanel:getWidgetByName("cur_attr_2"):setString("魔法攻击：")
        var.curPanel:getWidgetByName("cur_attr_2"):getWidgetByName("Label_attr"):setString(attr_info.mMC.."-"..attr_info.mMCmax)
        var.curPanel:getWidgetByName("cur_attr_3"):setString("道术攻击：")
        var.curPanel:getWidgetByName("cur_attr_3"):getWidgetByName("Label_attr"):setString(attr_info.mSC.."-"..attr_info.mSCmax)
        if attr_info.hpmaxadd > 0 then
            var.curPanel:getWidgetByName("cur_attr_4"):show()
            var.curPanel:getWidgetByName("cur_attr_4"):getWidgetByName("Label_attr"):setString(attr_info.hpmaxadd)
        else
            var.curPanel:getWidgetByName("cur_attr_4"):hide()
        end
    end
end

function PanelAchieve.onChangePage(flag)
    local page = var.curPage + flag
    if page > var.totalPage or page < 1 or flag == 0 then
        return
    end
    var.curPage = page
    --var.btnPre:setTouchEnabled(var.curPage>1)
    --var.btnNext:setTouchEnabled(var.curPage<var.totalPage)
    --var.pageView:scrollToPage(var.curPage-1)
     PanelAchieve.newgotoPage(var.curPage)
end

function PanelAchieve.newgotoPage(page)
    if page > var.totalPage or page < 1 then
        return
    end
    var.curPage = page
    var.effectbg:removeAllChildren()
    local pagesize = var.effectbg:getContentSize()

    local cfg = ZHANG_EFFECT[page]
    --ccui.ImageView:create("uilayout/image/shenlu/"..cfg.image..".png")
    gameEffect.getFrameEffect( "scenebg/xunzhang/"..cfg.plist, cfg.pattern, cfg.begin, cfg.length, cfg.time)
    :addTo(var.effectbg)
    :setPosition(cc.p(pagesize.width/2,pagesize.height/2))
end
--[[
function PanelAchieve.createEffectPage(page)
    local pagesize = var.effectbg:getContentSize()
    local pageWidget = ccui.Widget:create()
    pageWidget:setContentSize(pagesize)

    local cfg = ZHANG_EFFECT[page]
    gameEffect.getFrameEffect( "scenebg/xunzhang/"..cfg.plist, cfg.pattern, cfg.begin, cfg.length, cfg.time)
    :addTo(pageWidget)
    :setPosition(cc.p(pagesize.width/2,pagesize.height/2))

    return pageWidget
end

function PanelAchieve.gotoPage(page, delay)
    if page > var.totalPage or page < 1 then
        return
    end

    var.curPage = page
    var.btnPre:setTouchEnabled(var.curPage>1)
    var.btnNext:setTouchEnabled(var.curPage<var.totalPage)
    var.pageView:scrollToPage(var.curPage-1)
end
]]

function PanelAchieve.onPanelClose()
    UIButtonGuide.setGuideEnd(UIButtonGuide.GUILDTYPE.CHENGJIU)
end

return PanelAchieve