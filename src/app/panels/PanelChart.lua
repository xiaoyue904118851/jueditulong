--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/23 10:49
-- To change this template use File | Settings | File Templates.
--

local PanelChart = {}

local TOP_TAG = {
    FIGHT = 1,
    LEVEL = 2,
    RICH = 3,
    ACHIEVE = 4,
}

local TAG_CHART={
    TAG_CHART_ALL =100,
    TAG_CHART_WARRIOR =101,
    TAG_CHART_MAGE =102,
    TAG_CHART_TAOIST =103,
    TAG_CHART_RICH =104,
    TAG_CHART_FIGHT_W =106,
    TAG_CHART_FIGHT_M =107,
    TAG_CHART_FIGHT_T =108,
    TAG_CHART_FIGHT_ALL =109,
    TAG_CHART_ACHIEVE =105,
}
local SERVER_CHART_TYPE = {
    [TOP_TAG.FIGHT] = {TAG_CHART.TAG_CHART_FIGHT_ALL,TAG_CHART.TAG_CHART_FIGHT_W,TAG_CHART.TAG_CHART_FIGHT_M,TAG_CHART.TAG_CHART_FIGHT_T},
    [TOP_TAG.LEVEL] = {TAG_CHART.TAG_CHART_ALL,TAG_CHART.TAG_CHART_WARRIOR,TAG_CHART.TAG_CHART_MAGE,TAG_CHART.TAG_CHART_TAOIST},
    [TOP_TAG.RICH] = {TAG_CHART.TAG_CHART_RICH},
    [TOP_TAG.ACHIEVE] = {TAG_CHART.TAG_CHART_ACHIEVE}
}

local PARAM_CHART_TYPE = {
    [TOP_TAG.FIGHT] = "战力",
    [TOP_TAG.LEVEL] = "等级",
    [TOP_TAG.RICH] = "财富",
}

local var = {}

function PanelChart.initView(params)
    var = {}
    var.curpage = 1
    var.totalpage = 1
    local params = params or {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelChart/UI_Chart_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_chartboard")
    var.srcListItem1 = var.widget:getWidgetByName("Panel_chartListItem_0"):hide()
    var.srcListItem2 = var.widget:getWidgetByName("Panel_chartListItem_1"):hide()
    var.listView = var.widget:getWidgetByName("ListView_chartlist")
    var.myPos = var.widget:getWidgetByName("AtlasLabel_rank")
    var.totalPageText = var.widget:getWidgetByName("Label_pagecount")
    var.btnNext = var.widget:getWidgetByName("Button_next")
    var.btnNext:addClickEventListener(function(pSender)
        PanelChart.onChangePage(1)
    end)

    var.btnPre = var.widget:getWidgetByName("Button_pre")
    var.btnPre:addClickEventListener(function(pSender)
        PanelChart.onChangePage(-1)
    end)

    PanelChart.addTopMenuTabClickEvent()
    PanelChart.addLeftMenuTabClickEvent()
    var.topGroupButton:setButtonSelected(TOP_TAG.FIGHT)

    local  tipsBtn = var.widget:getWidgetByName("Button_tips")
    tipsBtn:addClickEventListener(function(pSender)
        UIAnimation.oneTips({
            parent = pSender,
            msg = pSender.desp,
        })
    end)
    tipsBtn.desp = "攻击高于自身战力的玩家，对方有5%的伤害减免"
    PanelChart.registeEvent()
    return var.widget
end

function PanelChart.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_REQCHART_LIST, PanelChart.handleChartList)
end

function PanelChart.addTopMenuTabClickEvent()
    var.topGroupButton = UIRadioButtonGroup.new()
    :addButton(var.widget:getWidgetByName("Button_GearScore"))
    :addButton(var.widget:getWidgetByName("Button_Level") )
    :addButton(var.widget:getWidgetByName("Button_Rich"))
    :onButtonSelectChanged(function(event)
        PanelChart.onTopButtonClicked(event.selected)
    end)
end

function PanelChart.addLeftMenuTabClickEvent()
    var.subPanel = var.widget:getWidgetByName("Panel_sub")
    var.leftGroupButton = UIRadioButtonGroup.new()
    :addButton(var.subPanel:getWidgetByName("Button_All"))
    :addButton(var.subPanel:getWidgetByName("Button_Warrior") )
    :addButton(var.subPanel:getWidgetByName("Button_Mage"))
    :addButton(var.subPanel:getWidgetByName("Button_DaoShi"))
    :onButtonSelectChanged(function(event)
        for i = 1, var.leftGroupButton:getButtonsCount() do
            var.leftGroupButton:getButtonAtIndex(i):getWidgetByName("Image_heigh"):setVisible(i==event.selected)
        end
        var.curpage = 1
        var.totalpage = 1
        PanelChart.updateListViewByTag(event.selected)
    end)
end

function PanelChart.onTopButtonClicked(tag)
    var.topTag = tag
    local leftMenuCounts = #SERVER_CHART_TYPE[var.topTag]
    for i = 1, 4 do
        local leftBtn = var.leftGroupButton:getButtonAtIndex(i)
        if i <= leftMenuCounts then
            leftBtn:show()
        else
            leftBtn:hide()
        end
    end
    local startY = 445.00
    for i = 1, var.topGroupButton:getButtonsCount() do
        var.topGroupButton:getButtonAtIndex(i):setPositionY(startY)
        if i == tag then
            var.subPanel:setPositionY(var.topGroupButton:getButtonAtIndex(i):getPositionY())
            startY = startY - var.subPanel:getContentSize().height-54
        else
            startY = startY - 66
        end
    end

    var.leftGroupButton:clearSelect()
    var.leftGroupButton:setButtonSelected(1)

    var.widget:getWidgetByName("Text_desc_3"):setString(PARAM_CHART_TYPE[var.topTag])
    var.widget:getWidgetByName("Text_desc_2"):setVisible(var.topTag~=TOP_TAG.LEVEL)
    var.widget:getWidgetByName("Image_line_2"):setVisible(var.topTag~=TOP_TAG.LEVEL)
end

function PanelChart.updateListViewByTag(tag)
    var.leftTag = tag
    var.charType = SERVER_CHART_TYPE[var.topTag][var.leftTag]
    if not NetClient.mChartData[var.charType] or not NetClient.mChartData[var.charType].list or not NetClient.mChartData[var.charType].list[var.curpage] then
        NetClient:GetChartInfo(var.charType,var.curpage)
    else
        PanelChart.updateListView()
    end
end

function PanelChart.handleChartList(event)
    if checkint(event.chart_type) ~= var.charType or event.page ~= var.curpage then return end
    PanelChart.updateListView()
end

function PanelChart:updateListView()
    var.listView:removeAllItems()
    local chartData = NetClient.mChartData[tostring(var.charType)]
    var.myPos:setString(chartData.selfseq)
    var.perNum = 9
    var.totalpage = math.ceil(chartData.totalnum/var.perNum)
    var.totalPageText:setString(var.curpage.."/"..var.totalpage)
    if chartData.list[var.curpage] then
        for k, chartMsg in ipairs(chartData.list[var.curpage])  do
            local rankreal = (var.curpage - 1)*var.perNum + k
            local listItem
            if k%2 == 0 then
                listItem = var.srcListItem2:clone():show()
            else
                listItem = var.srcListItem1:clone():show()
            end
            if rankreal <= 3 then
                local img = "img_power_"..k..".png"
                local ranknum = ccui.ImageView:create(img,UI_TEX_TYPE_PLIST)
                ranknum:setPosition(listItem:getWidgetByName("Label_rank"):getPosition())
                ranknum:addTo(listItem)
                listItem:getWidgetByName("Label_rank"):hide()
            else
                listItem:getWidgetByName("Label_rank"):setString(k)
            end
            listItem:getWidgetByName("Label_rank"):setString(rankreal)
            listItem:getWidgetByName("Label_username"):setString(chartMsg.name)
            listItem:getWidgetByName("Label_job"):setString(game.getJobStr(chartMsg.job))
            listItem:getWidgetByName("Label_lv"):setString(chartMsg.lv):setVisible(var.topTag~=TOP_TAG.LEVEL)
            listItem:getWidgetByName("Label_Num"):setString(chartMsg.param)

            var.listView:pushBackCustomItem(listItem)
        end
    end
end

function PanelChart.onChangePage(flag)
    local page = var.curpage + flag
    if page > var.totalpage or page < 1 or flag == 0 then
        return
    end
    var.curpage = page
    var.btnPre:setTouchEnabled(var.curpage>1)
    var.btnNext:setTouchEnabled(var.curpage<var.totalpage)
    if not NetClient.mChartData[var.charType] or not NetClient.mChartData[var.charType].list or not NetClient.mChartData[var.charType].list[var.curpage] then
        NetClient:GetChartInfo(var.charType,var.curpage)
    else
        PanelChart.updateListView()
    end
end

return PanelChart