--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/18 09:57
-- To change this template use File | Settings | File Templates.
-- 角色 - 转生

local RoleZhuanShengView = {}
local ACTIONSET_NAME = "reincarnation"
local MAX_REBORN_LEVEL = 15
local var = {}
local ZHUANSHENG_DESC = "转生系统说明：\n\n"
.."1.每次转生成功后都可获得转生属性\n\n"
.."2.转生成功和失败均会消耗转生石，\n转生成功等级会下降5级\n\n"
.."3.转生后可穿戴全新转生装备\n\n"
.."4.转生石可通过BOSS掉落、寻宝获得\n\n"
.."5.70级技能书击杀通天神殿BOSS掉落"

function RoleZhuanShengView.initView(params)
    local params = params or {}
    var = {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelRoleInfo/UI_Reborn.csb"):addTo(params.parent, params.zorder or 1)
    var.widget = widget:getChildByName("Panel_reborn")
    var.rebornxiuwei = var.widget:getWidgetByName("Label_OwnXiuwei")

    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        var.player_name = MainAvatar:NetAttr(Const.net_name)
        var.widget:getWidgetByName("Label_player_name"):setString(var.player_name)
    end
    var.mainRoleInfo = game.GetMainRole()
    var.lefttimes = 0

    RoleZhuanShengView.registeEvent()
    RoleZhuanShengView.updateCloth()
    RoleZhuanShengView.addBtnClickedEvent()
    --NetClient:PushLuaTable("gui.PanelZhuansheng.getInfo")
    NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="queryexchangeinfo"}))

    return var.widget
end

function RoleZhuanShengView.addBtnClickedEvent()
    local function btnCallBack(pSender)
        local pName = pSender:getName()
        if pName == "Button_add" then
            --print("TZ::var.lefttimes:",var.lefttimes)
            EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_quickbuy",pdata = {times = var.lefttimes}})
        elseif pName == "Button_reborn"then
            NetClient:PushLuaTable(ACTIONSET_NAME,util.encode({actionid="upgrade"}))
        end
    end
    var.widget:getWidgetByName("Button_add"):addClickEventListener(btnCallBack)
    var.widget:getWidgetByName("Button_reborn"):addClickEventListener(btnCallBack)
end

function RoleZhuanShengView.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_PUSH_PANEL_DATA, RoleZhuanShengView.handleZhuangShengMsg)
    :addEventListener(Notify.EVENT_AVATAR_CHANGE, RoleZhuanShengView.updateCloth)
end

function RoleZhuanShengView.handleZhuangShengMsg(event) 
    if event.type == nil or event.type ~= "reincarnation" then return end
    local d = util.decode(event.data)
    var.d = d
    --print("TZ:event:1234:",d.actionid)
    if d.actionid == "queryexchangeinfo" then
        var.lefttimes = d.param.extimes or 0
        RoleZhuanShengView.updateView(d)
    elseif d.actionid == "proupgradeinfo" then
        RoleZhuanShengView.updateView(d)
    elseif d.actionid == "updatedata" then
        if d.param then
            if var.rebornxiuwei then  
                var.rebornxiuwei:setString(d.param.curreinexp)
            end           
        end   
    end
end
function RoleZhuanShengView.updateView(d)
    local cf = {
        {name = "Panel_PhyAtk", dis = ""},
        {name = "Panel_MagAtk", dis = ""},
        {name = "Panel_DaoAtk", dis = ""},
        {name = "Panel_PhyDef", dis = ""},
        {name = "Panel_MagDef", dis = ""},
    }
    local rebornlevel = d.param.curlevel or 0
    local curAttrInfo = {} 
    local nextAttrInfo = {} 
    if rebornlevel > 0 then
        curAttrInfo = RoleZhuanShengView.getRebornData(rebornlevel)
    end
    if rebornlevel == MAX_REBORN_LEVEL then
        nextAttrInfo = RoleZhuanShengView.getRebornData(rebornlevel)
    else
        nextAttrInfo = RoleZhuanShengView.getRebornData(rebornlevel+1)
    end 
    local curValue = {
        { min = curAttrInfo and curAttrInfo.mDC or 0 , max = curAttrInfo and curAttrInfo.mDCmax or 0},
        { min = curAttrInfo and curAttrInfo.mMC or 0 , max = curAttrInfo and curAttrInfo.mMCmax or 0},
        { min = curAttrInfo and curAttrInfo.mSC or 0 , max = curAttrInfo and curAttrInfo.mSCmax or 0},

        { min = curAttrInfo and curAttrInfo.mAC or 0 , max = curAttrInfo and curAttrInfo.mACmax or 0},
        { min = curAttrInfo and curAttrInfo.mMAC or 0 , max = curAttrInfo and curAttrInfo.mMACmax or 0},
    }

    local nextValue = {
        { min = nextAttrInfo and nextAttrInfo.mDC or 0 , max = nextAttrInfo and nextAttrInfo.mDCmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mMC or 0 , max = nextAttrInfo and nextAttrInfo.mMCmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mSC or 0 , max = nextAttrInfo and nextAttrInfo.mSCmax or 0},

        { min = nextAttrInfo and nextAttrInfo.mAC or 0 , max = nextAttrInfo and nextAttrInfo.mACmax or 0},
        { min = nextAttrInfo and nextAttrInfo.mMAC or 0 , max = nextAttrInfo and nextAttrInfo.mMACmax or 0},
    }

    for k, v in ipairs(cf) do
        v.value = curValue[k].min.."-"..curValue[k].max
        local dismin = nextValue[k].min -  curValue[k].min
        local dismax = nextValue[k].max -  curValue[k].max
        if dismin > 0 or dismax > 0 then
            v.dis = "+"..dismin.."-"..dismax
        end
    end
    for _, v in ipairs(cf) do
        local panel = var.widget:getWidgetByName(v.name)
        local curText = panel:getWidgetByName("Label_Cur")
        local disText = panel:getWidgetByName("Label_Dis")
        local parentSize = panel:getParent():getContentSize()
        curText:setString(v.value):setPositionX(0)
        disText:setString(v.dis):setPositionX(curText:getRightBoundary())
        panel:setContentSize(cc.size(curText:getContentSize().width + disText:getContentSize().width, parentSize.height)):align(display.CENTER, parentSize.width/2, parentSize.height/2-2)
    end
    var.widget:getWidgetByName("Label_reborn_level"):setString(d.param.curlevel or "0")
    var.widget:getWidgetByName("Label_NeedXiuwei"):setString(nextAttrInfo.mXiuWei or "0")
    var.widget:getWidgetByName("Label_OwnXiuwei"):setString(d.param.curreinexp or "0")
end

function RoleZhuanShengView.getRebornData(level)
    return RebornDefData[tostring(level)]
end
function RoleZhuanShengView.updateCloth()
    if not var.aniBg then
        var.aniBg = var.widget:getWidgetByName("Panel_role"):show()
        var.aniBgSize = var.aniBg:getContentSize()
    end

    var.aniBg:removeAllChildren()
    game.getMyInsigh(var.aniBg)
end

return RoleZhuanShengView