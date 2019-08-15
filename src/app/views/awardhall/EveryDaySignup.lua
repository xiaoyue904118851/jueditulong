--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/28 14:22
-- To change this template use File | Settings | File Templates.
--

local EveryDaySignup = {}
local var = {}
local ACTIONSET_NAME = "daysign"
local MAXDATE = 42
local STATUS_NOT_DRAW=0;        --不可领取
local STATUS_CAN_DRAW=1;        --可领取
local STATUS_ALREADY_DRAWGIFT=2;    --已领奖

function EveryDaySignup.initView(params)
    local params = params or {}
    var = {}
    var.selectInfo = nil
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelAwardHall/UI_SignUp.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_signup")
    EveryDaySignup.registeEvent()

    var.curmonths = 0
    var.signtype = false
    var.reSignarry = {}
    var.hasSignarry = {}

    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="querybaseinfo"}))
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="updatesigninfo"}))

    return widget
end

function EveryDaySignup.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, EveryDaySignup.handleInfoMsg)
end

function EveryDaySignup.initWidget()
    var.signlistView = var.widget:getWidgetByName("ListView_signlist")
    var.signlistItem = var.widget:getWidgetByName("Button_award"):hide()
    var.datelistView = var.widget:getWidgetByName("ListView_datelist")
    var.datelistItem = var.widget:getWidgetByName("list_item"):hide()
    var.awardlistView = var.widget:getWidgetByName("ListView_awardlist")
    var.awardlistItem = var.widget:getWidgetByName("Image_item"):hide()
    EveryDaySignup.updateSignListInfo()
    var.getbtn = var.widget:getWidgetByName("Button_get")
    var.getbtnLabel = var.widget:getWidgetByName("Label_get")
    var.getbtn:addClickEventListener(function (pSender)
             NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="drawgift",param = {idx = var.select}}))
        end)
    var.signbtn = var.widget:getWidgetByName("Button_sign")
    var.signbtn:addClickEventListener(function (pSender)
             NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="freesign",param = ""}))
        end)
    --EveryDaySignup.updateDateListInfo()
end

function EveryDaySignup.updateSignListInfo()
    var.signlistView:removeAllItems()
    local btnlist = {} 
    for i= 1,#var.infodata.awardlist do
        local listItem = var.signlistItem:clone():show()
        local Info =  var.infodata.awardlist[i]
        listItem:getWidgetByName("TextField_label"):setString("签到"..Info.needday.."次")
        local signbtn = listItem:getWidgetByName("Button_award")
        btnlist[i] = signbtn
        var.signlistView:pushBackCustomItem(listItem)
    end

    var.signListButton = UIRadioButtonGroup.new()
    for i= 1,#btnlist do
        var.signListButton:addButton(btnlist[i])
            :onButtonSelectChanged(function(event)
                EveryDaySignup.updateAwardInfo(event.selected)
                EveryDaySignup.handleupdatebtn(event.selected)
                var.select = event.selected
            end) 
    end
end

function EveryDaySignup.updateAwardInfo(tag)
    var.awardlistView:removeAllItems()
    for i=1,#var.infodata.awardlist[tag].award do
        local listItem = var.awardlistItem:clone():show()
        local itemInfo =  var.infodata.awardlist[tag].award[i]
        UIItem.getSimpleItem({
            parent = listItem:getWidgetByName("Image_item"),
            typeId = itemInfo.typeid,
        })
        local itemimage = listItem:getWidgetByName("Image_item")
        local numtips = ccui.Text:create(itemInfo.num, Const.DEFAULT_FONT_NAME, 20)
                :align(display.CENTER_BOTTOM,itemimage:getContentSize().width/1.3, 0)
                :addTo(itemimage)
                numtips:setColor(Const.COLOR_GREEN_1_C3B)
        var.awardlistView:pushBackCustomItem(listItem)
    end
end

function EveryDaySignup.updateDateListInfo()
    var.datelistView:removeAllItems()
     UIGridView.new({
        parent = var.widget,
        --async = true,
        list = var.datelistView,
        gridCount = 42,
        cellSize = cc.size(var.datelistView:getContentSize().width,var.datelistItem:getContentSize().height),
        columns = 7,
        initGridListener = EveryDaySignup.addGridItem
    })
end

function EveryDaySignup.addGridItem(gridWidget, index)
    local widget = var.datelistItem:clone():show()
    :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    :addTo(gridWidget)
    --local itemimage = widget:getWidgetByName("Image_item")
    local Tdays = var.datelistinfo[index].day
    local days = 0
    if  Tdays < 10 then
        days = "0"..var.datelistinfo[index].day
    else
        days = var.datelistinfo[index].day
    end
    local numtips = ccui.Text:create(days, Const.DEFAULT_FONT_NAME, 20)
                :align(display.CENTER_BOTTOM,widget:getContentSize().width/3, 0)
                :addTo(widget)
    if var.datelistinfo[index].month > 0 then
        numtips:setColor(cc.c3b(0, 0, 0))
    else
        numtips:setColor(Const.COLOR_GRAY_1_C3B)
    end
    local flag = var.signinfo.signflag
    if var.datelistinfo[index].month > 0 then
        local signbtn = widget:getWidgetByName("Button_resign")
        var.reSignarry[Tdays] = signbtn
        var.hasSignarry[Tdays]= widget:getWidgetByName("Image_hassign")
        if var.curday > Tdays then
            if bit._and(flag,2^Tdays) ~=0 then
                widget:getWidgetByName("Image_hassign"):show()
            else  
                signbtn:show()
                :setTouchEnabled(true)
                :addClickEventListener(function (pSender)
                    --if NetClient.mCharacter.mVCoin >= var.infodata.needyb then
                        local param = {
                            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true,
                            lblConfirm ="补签花费"..var.infodata.needyb.."元宝",
                            confirmTitle = "确 定", cancelTitle = "取 消",
                            confirmCallBack = function ()
                                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="ybsign",param={day=Tdays}}))
                                var.signDay = Tdays
                            end
                            }
                        NetClient:dispatchEvent(param)
                    --else
                        --NetClient:alertLocalMsg("元宝不足","alert")
                    --end
                end)
            end
        end
    end
end

function EveryDaySignup.handleInfoMsg(event)
    if event.type == nil then return end
    local d = util.decode(event.data)
    if event.type ~= ACTIONSET_NAME then return end
    if not d.actionid then
       return
    end
    if d.actionid == "querybaseinfo" then
        var.infodata = d.param
        EveryDaySignup.initWidget()
    elseif d.actionid == "updatesigninfo" then
        var.signinfo = nil
        var.signinfo = d.param
        if var.curmonths ~= var.signinfo.curmonth then
            var.widget:getWidgetByName("AtlasLabel_get_number"):setString(var.signinfo.curmonth)
            var.curmonths = var.signinfo.curmonth
        end
        var.widget:getWidgetByName("Label_signnum"):setString(var.signinfo.signcount)
        if not var.datelistinfo then
            var.signListButton:setButtonSelected(1)
            EveryDaySignup.handledateinfo()
        end

        if bit._and(var.signinfo.signflag,2^var.signinfo.curday) ~=0 then
            if not var.signtype then
                var.signbtn:setTouchEnabled(false)
                :setBright(false)
                var.signbtn:setTitleText("已签到")
                var.signbtn:setTitleColor(Const.COLOR_GRAY_1_C3B)
                var.signtype = true    
                var.hasSignarry[var.signinfo.curday]:show() 
            end
        end
        EveryDaySignup.handleupdatebtn(var.select)
        if var.signDay then
            if bit._and(var.signinfo.signflag,2^var.signDay) ~=0 then
                var.reSignarry[var.signDay]:hide()
                var.reSignarry[var.signDay]:setTouchEnabled(false)
                var.hasSignarry[var.signDay]:show() 
            end
        end
        
    end
end

function EveryDaySignup.handleupdatebtn(tag)
    local flag = var.signinfo.giftflags[tag]
    if flag == STATUS_NOT_DRAW then
        var.getbtn:setTouchEnabled(false)
        :setBright(false)
        var.getbtnLabel:setString("领   取")
        var.getbtnLabel:setColor(Const.COLOR_GRAY_1_C3B)
    elseif flag == STATUS_CAN_DRAW then
        var.getbtn:setTouchEnabled(true)
        :setBright(true)
        var.getbtnLabel:setString("领   取")
        var.getbtnLabel:setColor(Const.COLOR_YELLOW_1_C3B)
    elseif flag == STATUS_ALREADY_DRAWGIFT then
        var.getbtn:setTouchEnabled(false)
        :setBright(false)
        var.getbtnLabel:setString("已领取")
        var.getbtnLabel:setColor(Const.COLOR_GRAY_1_C3B)
    end 
end

function EveryDaySignup.handledateinfo()
    local month = var.signinfo.curmonth
    var.curday = var.signinfo.curday
    local weekday = var.signinfo.weekday
    local oneweek = weekday-(var.curday%7)+1
    if oneweek < 0 then
        oneweek = oneweek + 7
    end
    local curmonthdays = EveryDaySignup.getMonthdays(month)
    local lastmonthdays =0
    if month == 1 then
        lastmonthdays = EveryDaySignup.getMonthdays(12)
    else
        lastmonthdays = EveryDaySignup.getMonthdays(month-1)
    end
    var.datelistinfo = {}
    for i= 1,MAXDATE do
        var.datelistinfo[i] = {}
        if  oneweek == 7  then
            if curmonthdays >= i then
                var.datelistinfo[i].day =  i
                var.datelistinfo[i].month = 1
            else
                var.datelistinfo[i].day =  i-curmonthdays
                var.datelistinfo[i].month = 0
            end
        else
            if i < 8 then
                if i < oneweek+1 then
                    var.datelistinfo[i].day =  lastmonthdays-oneweek+i
                    var.datelistinfo[i].month = 0
                else
                    var.datelistinfo[i].day = i-oneweek
                    var.datelistinfo[i].month = 1
                end
            else
                if curmonthdays  >= i - oneweek then
                    var.datelistinfo[i].day = i-oneweek
                    var.datelistinfo[i].month = 1
                else
                    var.datelistinfo[i].day = i-oneweek-curmonthdays
                    var.datelistinfo[i].month = 0
                end
            end
        end
    end
    EveryDaySignup.updateDateListInfo()
end

function EveryDaySignup.getMonthdays(tag)
    if tag == 2 then
        return 28
    elseif (tag%2 == 1 and tag < 8) or (tag%2 == 0 and tag > 7) then
        return 31
    else
        return 30
    end
end

return EveryDaySignup