--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/18 09:57
-- To change this template use File | Settings | File Templates.
-- 角色 - 转生购买物品

local PanelRoleQuickBuy = {}
local ACTIONSET_NAME = "reincarnation"
local EX_NEED_LEVEL = 80

function PanelRoleQuickBuy.initView(params)
    local params = params or {}
    var = {}
    var.times = 0
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_Rebron_QuickBuy.csb"):addTo(params.parent, params.zorder or 1)
    if params then
        if params.extend.pdata then
            var.times = params.extend.pdata.times
        end 
    end
    var.widget = widget:getChildByName("Panel_buy")
    var.widget:show():setTouchEnabled(true)
    
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        var.plevel = MainAvatar:NetAttr(Const.net_level)
    end
    
    PanelRoleQuickBuy.registeEvent()
    PanelRoleQuickBuy.addBtnClickedEvent()

    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="queryexchangebuyinfo"}))
    --PanelRoleQuickBuy.upDateTimesLabel(var.times)
   
    return var.widget
end

function PanelRoleQuickBuy.upDateTimesLabel(num)
    local times = ""
    if var.plevel > EX_NEED_LEVEL then
        if num >= 3 then
            times = "兑换次数已用完"         
        else
            times = "剩余"..(3-num).."次" 
        end
    else
        times = ""
    end
    var.widget:getWidgetByName("Label_price_1"):setString(times)
end 

function PanelRoleQuickBuy.upDateiconinfo(info)
    if info then
        UIItem.getSimpleItem({
            parent = var.widget:getWidgetByName("item_bg1"),
            typeId = info.exptypeid,
        })
        UIItem.getSimpleItem({
            parent = var.widget:getWidgetByName("item_bg2"),
            typeId = info.buydata.typeid,
        })
    end
    
end 

function PanelRoleQuickBuy.addBtnClickedEvent()
    local function btnCallBack(pSender)
        local pName = pSender:getName()
        if pName == "Button_convert" then
            if var.plevel > EX_NEED_LEVEL then
                local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否降低你的等级来兑换修为",
                confirmTitle = "确  定", cancelTitle = "取  消",
                autoclose = true,
                confirmCallBack = function ()
                NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="exchangeexp"}))
                end
                }
                NetClient:dispatchEvent(param)  
            else
                local param = {
                name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "你等级不够！请将等级提升至"..game.make_str_with_color( Const.COLOR_GREEN_1_STR,"Lv81" ).."再来吧！",
                confirmTitle = "确  定", cancelTitle = "取  消",
                autoclose = true,
                confirmCallBack = function ()             
                end
                }
                NetClient:dispatchEvent(param)  
            end               
        elseif pName == "Button_buy"then
            local data = {}
            if var.buydata then
                data.typeid = var.buydata.typeid
                data.sellyb = var.buydata.sellyb
                data.priceflag = var.buydata.priceflag
                data.bindflag = var.buydata.bindflag or 0
                game.showQuickByPanel(data)
            end
            
            --NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({actionid="new_quickbuy"}))
        end
    end
    var.widget:getWidgetByName("Button_convert"):addClickEventListener(btnCallBack)
    var.widget:getWidgetByName("Button_buy"):addClickEventListener(btnCallBack)
end
function PanelRoleQuickBuy.handleZhuangShengMsg(event)
    if event.type == nil or event.type ~= "reincarnation" then return end
    local d = util.decode(event.data)
    if d.actionid == "updatedata" then
         PanelRoleQuickBuy.upDateTimesLabel(d.param.lefttimes or 0 )
    elseif d.actionid == "queryexchangebuyinfo" then
        PanelRoleQuickBuy.upDateTimesLabel(d.param.extimes or 0 )
        PanelRoleQuickBuy.upDateiconinfo(d.param or 0 )
        var.buydata = d.param.buydata
    end
end
function PanelRoleQuickBuy.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelRoleQuickBuy.handleZhuangShengMsg)
end

return PanelRoleQuickBuy