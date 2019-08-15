--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/24 17:45
-- To change this template use File | Settings | File Templates.
-- LayerGamePanel

-- closeSelf 打开的时候不关闭之前的panel, 关闭的时候只关闭自己
local PANEL_CONFIG = {
    ["panel_chat"] 		            = 	{name = "PanelChat",		},
    ["panel_setting"] 		        = 	{name = "PanelSetting",		},
    ["panel_bag"] 		            = 	{name = "PanelBag",closeSelf = 1},
    ["panel_mall"] 		            = 	{name = "PanelMall",closeSelf = 1},
    ["panel_vip"] 		            = 	{name = "PanelVIP"},
    ["panel_firstcharge"] 	        = 	{name = "PanelFirstCharge",	},
    ["panel_challenge_boss"] 	    = 	{name = "PanelChallengeBoss", res = 1},
    ["panel_sevenlogin"] 		    = 	{name = "PanelSevenLogin",		res = 1},
    ["panel_npcTaskDialog"] 	    = 	{name = "PanelNpcTaskDialog",closeSelf = 1, opacity = 0	},
    ["panel_npctalk"] 	            = 	{name = "PanelNpcTalk",	res=1, opacity = 0	},
    ["panel_wordmap"] 	            = 	{name = "PanelWordMap",	},
    ["panel_friend"] 	            = 	{name = "PanelFriend",closeSelf = 1},
    ["panel_friend_op"]             = 	{name = "PanelOtherPlayerOp",closeSelf = 1,opacity = 0	},
    ["panel_otherPlayerEquip"] 	    = 	{name = "PanelOtherPlayerEquip", closeSelf = 1},
    ["panel_roleInfo"] 	            = 	{name = "PanelRoleInfo", res = 1},
    ["panel_chart"] 	            = 	{name = "PanelChart", closeSelf = 1},
    ["panel_group"] 	            = 	{name = "PanelGroup", closeSelf = 1},
    ["panel_smelter"]               =   {name = "PanelSmelter", res = 1},
	["panel_guild"]                 =   {name = "PanelGuild", closeSelf = 1},
    ["panel_trade"]                 =   {name = "PanelTrade", closeSelf = 1},
    ["panel_wing"]                  =   {name = "PanelWing", closeSelf = 1},

    ["panel_activity_hall"]         =   {name = "PanelActivityHall",res=1,closeani=false},

    ["panel_skill_setting"]         =   {name = "PanelSkillSetting"},
    ["panel_specailring"]           =   {name = "PanelSpecailRing",		res = 1},
    ["panel_yabiao"]                 =   {name = "PanelYaBiao", res = 1,closeSelf = 1},
    ["panel_fuben"]                 =   {name = "PanelFuben", res = 1,closeSelf = 1},
    ["panel_shenlu"]                 =   {name = "PanelShenlu", },
    ["panel_preopen"]               =   {name = "PanelPreOpen", closeani = false},
    ["panel_zhanshen"]               =   {name = "PanelZhanShen", closeSelf = 1,res=1},
    ["panel_shenqi"]               =   {name = "PanelShenQi", closeSelf = 1},
    ["panel_mail"]               =   {name = "PanelMail",},
    ["panel_achieve"]               =   {name = "PanelAchieve", closeSelf = 1},
    ["panel_quickbuy"]               =   {name = "PanelRoleQuickBuy", closeSelf = 1},

    -- 神魔战场排名
    ["panel_smzc_rank"]             = {name = "PanelSMZCRank",		path = "activity"},
    ["panel_king"]                  = {name = "PanelKing", path = "activity"},
    ["panel_king_jf"]               = {name = "PanelKingJifen", path = "activity"},
    ["panel_king_rank"]             = {name = "PanelKingRank", path = "activity"},
    ["panel_refine_exp"]            = {name = "PanelRefineExp", path = "activity"},
    ["panel_offline_exp"]           = {name = "PanelOfflineExp", path = "activity"},
    ["panel_hongbao"]              = {name = "PanelMoneyBag", path = "activity",res = 1},
    ["panel_fcm"]             = {name = "PanelFangchenmi", closeSelf = 1},
    ["panel_award_hall"]             = {name = "PanelAwardHall",res = 1},
    ["panel_level_invest"]             = {name = "PanelLevelInvest"},
    ["panel_strengthen"]             = {name = "PanelStrengthen",res=1},
    ["panel_super_value"]             = {name = "PanelSuperValue"},
    ["panel_xunbao"]             = {name = "PanelXunBao"},
    ["panel_privilege_card"]             = {name = "PanelPrivilegeCard",		res = 1},
    ["panel_xunbao_shop"]             = {name = "PanelXunBaoShop"},
    ["panel_xunbao_cangku"]             = {name = "PanelXunBaoCangKu"},
    ["panel_group_op"]             = {name = "PanelMyGroupOp",closeSelf = 1,opacity = 0},
}

local LayerGamePanel = class("LayerGamePanel", function()
    return display.newNode()
end)

function LayerGamePanel:ctor()
    self.m_lastPanelName = nil
    self.m_bgMskPanels = {} -- maskwidget
    self.m_panelFiles = {} -- logic
    self:enableNodeEvents()
end

function LayerGamePanel:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_OPEN_PANEL, handler(self,self.handleOpenEvent))
    :addEventListener(Notify.EVENT_CLOSE_PANEL, handler(self,self.handleCloseEvent))
    :addEventListener(Notify.EVENT_CLOSE_ALL_PANEL, handler(self,self.DiscloseAllPanels))
end

function LayerGamePanel:handleOpenEvent(event)
    local pName = event.str

    if pName == "panel_chat" then
        NetClient:dispatchEvent({name=Notify.EVENT_SHOW_CHAT_LAYER})
        return
    end

    if pName == "panel_charge" then
        event.str = "panel_mall"
        event.pdata = {tag=3 }
        pName = event.str
    end

    local panelConfig = PANEL_CONFIG[pName]
    if pName and panelConfig then
        if not PANEL_CONFIG[pName].closeSelf then
            self:closeAllPanels()
        end

        self.m_lastPanelName = pName
        if self.m_bgMskPanels[pName] then
            self.m_bgMskPanels[pName]:setVisible(true)
            if pName == "panel_mall" then
                NetClient:dispatchEvent({name=Notify.EVENT_MALL_CHANGE_INFO,tag = 3})
            end
            print("panel already exist !!!", pName)
            return
        end
        self:openPanel(pName, event)
    else
        print("error！！！========》》》》》》》》》》")
        print("error, panel is invalid ==>", pName)
    end
end

function LayerGamePanel:DiscloseAllPanels(event)
    self:closeAllPanels("btn_close")
end

function LayerGamePanel:closeAllPanels(from)
    for k,v in pairs(self.m_bgMskPanels) do
        self:closePanel(k,from)
    end
end

function LayerGamePanel:getResFileName(panelConfig)
    local pt = ""
    if panelConfig.path then
        pt = "/"..panelConfig.path
    end

    return "uilayout"..pt.."/"..panelConfig.name.."/"..panelConfig.name
end

function LayerGamePanel:getPanelFileName(panelConfig)
    local pt = ""
    if panelConfig.path then
        pt = panelConfig.path.."."
    end
    return "app.panels."..pt..panelConfig.name
end

function LayerGamePanel:closePanel(pName,from)
    local panel = self.m_bgMskPanels[pName]
    if panel then
        if self.m_panelFiles[pName].checkPanelClose and not self.m_panelFiles[pName].checkPanelClose() then
            return
        end
        local panelConfig = PANEL_CONFIG[pName]
        panel:getChildByName("_imgbg"):setOpacity(0)
        game.playSoundByID("sound/1116.mp3")
        if panelConfig.closeani == nil or panelConfig.closeani == true then
            local t = 0.15
            panel:runAction(cc.Spawn:create(
                    cc.FadeOut:create(t),
                    cc.Sequence:create(
                        cc.EaseSineOut:create(cc.MoveBy:create(t,cc.p(0, -10))),
                        cc.CallFunc:create(handler(self,self.realClosePanel),{pName=pName,from=from})
                    )
            ))
        else
            self:realClosePanel(panel,{pName=pName,from=from})
        end
    end
end

function LayerGamePanel:realClosePanel(pSender,args)
--    print(psender:getName())
    local pName = args.pName
    local from = args.from
    local panel = self.m_bgMskPanels[pName]
    if not panel then return end
    self:removeChild(panel)
    self.m_bgMskPanels[pName] = nil
    if self.m_panelFiles[pName] then
        local panelConfig = PANEL_CONFIG[pName]
        if panelConfig.res then
            local fn = self:getResFileName(panelConfig)
            remove_frames(fn,Const.TEXTURE_TYPE.PNG)
        end
        if self.m_panelFiles[pName].onPanelClose then
            self.m_panelFiles[pName].onPanelClose(from)
        end
        self.m_panelFiles[pName] = nil
        if PANEL_CONFIG[pName].mLastPanel then
            NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_smelter"})
            PANEL_CONFIG[pName].mLastPanel = nil
        end
    end


    saveTextureCache()
end

function LayerGamePanel:openPanel(pName, extend)
    local panelConfig = PANEL_CONFIG[pName]
    if panelConfig then
        local pn = self:getPanelFileName(panelConfig)
        self.m_panelFiles[pName] = require(pn)
        if self.m_panelFiles[pName] then
            self.m_bgMskPanels[pName] = self:createMaskPanel(pName)
            if panelConfig.res then
                local fn = self:getResFileName(PANEL_CONFIG[pName])
                asyncload_frames(fn,Const.TEXTURE_TYPE.PNG,function ()
                    self:initPanelView(extend)
                end)
            else
                self:initPanelView(extend)
--                print("TZ:initPanelView:1",pName)
            end
            game.playSoundByID("sound/1114.mp3")
        else
            printError("invalid file ", pn)
        end
    end
end

function LayerGamePanel:createMaskPanel(pName)
    local maskpanel = ccui.Widget:create()
    maskpanel:setContentSize(display.width, display.height)
    maskpanel:setTouchEnabled(true)
    maskpanel:addClickEventListener(function (pSender)
        if PANEL_CONFIG[pName].closeSelf then
            print("LayerGamePanel==>>clicked maskbg, closeSelfPanels")
            self:closePanel(pName)
        else
            print("LayerGamePanel==>>clicked maskbg, closeAllPanels")
            self:closeAllPanels()
        end
    end)
    maskpanel.defaultPos = cc.p(display.cx, display.cy)
    maskpanel:align(display.CENTER, maskpanel.defaultPos.x, maskpanel.defaultPos.y)
    maskpanel:addTo(self)
    maskpanel:setName(pName)

    local imgpanel = ccui.ImageView:create()
    imgpanel:setScale9Enabled(true)
    imgpanel:loadTexture("uilayout/image/maskbg.png",UI_TEX_TYPE_LOCAL)
    imgpanel:setOpacity(PANEL_CONFIG[pName].opacity or 200)
    imgpanel:setScale9Enabled(true)
    imgpanel:setContentSize(display.width, display.height)
    imgpanel:setName("_imgbg")
    imgpanel:align(display.CENTER, maskpanel.defaultPos.x, maskpanel.defaultPos.y)
    imgpanel:setTouchEnabled(false)
    imgpanel:addTo(maskpanel)

    return maskpanel
end


function LayerGamePanel:initPanelView(extend)
    local pName = extend.str
    PANEL_CONFIG[pName].mLastPanel = extend.last_panel
    if not self.m_panelFiles[pName] then
		print("LayerGamePanel:initPanelView==>>Error",pName)
        local panel = self.m_bgMskPanels[pName]
        if panel then
            panel:removeFromParent()
            self.m_bgMskPanels[pName] = nil
        end

        printError("LayerGamePanel:initPanelView==>>", pName)
        return
    end

    if self.m_panelFiles[pName].initView then
        local maskLayer = self.m_bgMskPanels[pName]
--        if maskLayer then
--            print("TZ:initPanelView:2",pName)
--        end
--        print("TZ:initPanelView:21")
        local wigdetPanel =  self.m_panelFiles[pName].initView({extend = extend, parent = maskLayer, zorder = 3})
        if wigdetPanel then
            wigdetPanel:setTouchEnabled(true)
--            print("TZ:initPanelView:3")
            wigdetPanel:align(display.CENTER, maskLayer.defaultPos.x, maskLayer.defaultPos.y)
            wigdetPanel:setScale(Const.minScale)

            local btnClose = wigdetPanel:getWidgetByName("Button_close")
            if btnClose then
                btnClose:addClickEventListener(function (pSender)
                    print("TZ:::::pSender------------CLOSE")
                    if PANEL_CONFIG[pName].closeSelf then
                        self:closePanel(pName,"btn_close")
                    else
                        self:closeAllPanels("btn_close")
                    end
                end)
            end

            local panelClose = wigdetPanel:getWidgetByName("Panel_close")
            if panelClose then
                panelClose:addClickEventListener(function (pSender)
                    if PANEL_CONFIG[pName].closeSelf then
                        self:closePanel(pName,"btn_close")
                    else
                        self:closeAllPanels("btn_close")
                    end
                end)
            end
        end
    end
end

function LayerGamePanel:handleCloseEvent(event)
    local pName = event.str
    if pName ~= "" then
        self:closePanel(pName)
    end
end

function LayerGamePanel:onEnter()
    self:registeEvent()
end

return LayerGamePanel