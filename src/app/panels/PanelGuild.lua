local PanelGuild = {}
local var = {}

local left_btn_tab = {
"行会信息     ",
"行会仓库     ",
"行会技能     ",
"行会活动     ",
"行会联盟     ",
"行会日志     ",
"行会列表     ",
"行会战       ",
"行会升级     ",
"审核成员     ",
}

local EXCHANGE_DEGREE_LIST={   --1为金币 2为元宝
	[1] = {100000,200000,500000,1000000},
	[2] = {1000,2000,5000,10000},
}

local MIN_DONATE_GOLD = 1000 --金币捐献的最小值
local MIN_DONATE_VCOIN = 100 --元宝捐献最小值
local EXCHANGE_DEGREE_GLOD = 1 --1000金币对应的行会贡献度
local EXCHANGE_DEGREE_VCOIN = 2000 --100元宝对应的行会贡献度
local EXCHANGE_GUILDEXP_GLOD = 50 --1000金币对应的行会经验
local EXCHANGE_GUILDEXP_VCOIN = 5000 --100元宝对应的行会经验

local GUILD_SKILL_PATH = {
	"guild_hpmax.png",
	"guild_wf.png",
	"guild_mf.png",
	"guild_attack.png",
}

local HUISHOU_SETTING = {
    [1] = {
        {text = "100级以下", lv = 100},
        {text = "80级以下", lv = 80},
        {text = "3转以下", zslv = 3},
    },
    [2] = {
        {text = "通用职业", job = 0},
        {text = "战士", job = Const.JOB_ZS},
        {text = "法师", job = Const.JOB_FS},
        {text = "道士", job = Const.JOB_DS},
    },
    [3] = {
        {text = "白色品质", color = 1},
        {text = "绿色品质", color = 2},
        {text = "蓝色品质", color = 3},
        {text = "紫色品质", color = 4},
        {text = "橙色品质", color = 5},
        {text = "红色品质", color = 6},
    },
    [4] = {
        {text = "通用装备", sex = 0},
        {text = "男性装备", sex = Const.SEX_MALE},
        {text = "女性装备", sex = Const.SEX_FEMALE},
    },
}

local guild_rl_set = {
	"guild_ronglian_lv",
    "guild_ronglian_job",
    "guild_ronglian_color",
    "guild_ronglian_sex",
}

local GUILD_WAR_OPCODE = {
	START_GUILD_WAR=1,			--宣战
	END_GUILD_WAR=2,			--终止宣战
	GUILD_UNION_REQ=3,			--请求联盟
	GUILD_UNION_DISMISS=4,		--解散联盟
	GUILD_UNION_AGREE=5,		--同意联盟
	GUILD_UNION_REFUSE=6,		--拒绝联盟
	GUILD_UNION_REQ_CANCEL=7,	--联盟请求取消
	GUILD_UNION_REQ_ADD=8,		--联盟请求添加
}

local LEFT_ROWS = 4
local LEFT_COLUMNS = 6
local LEFT_PAGE_COUNT = 5

local RIGHT_ROWS = 4
local RIGHT_COLUMNS = 4
local RIGHT_PAGE_COUNT = 10

function PanelGuild.initView(params)
    local params = params or {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuild.csb")
    widget:addTo(params.parent, params.zorder)
    var.selectTab = 1
    var.curLeftArrow = 0
    var.mAutoRecycle = 1
    var.widget = widget:getChildByName("Panel_guild")
    var.mEventProxy = nil
    var.mBagItemTab = {}
    var.mStoreItemTab = {}

    var.mExtends = params.extend

    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
    	var.guild_name = MainAvatar:NetAttr(Const.net_guild_name)
    	var.guild_title = MainAvatar:NetAttr(Const.net_guild_title)
    	var.self_name = MainAvatar:NetAttr(Const.net_name)
    end
    print(var.guild_name,var.guild_title)
    if not var.guild_name or var.guild_name == "" or not var.guild_title or var.guild_title == 0 then
    	PanelGuild.InitPanelsByTag(0)
    else
    	if var.mExtends and var.mExtends.pdata and var.mExtends.pdata.tag then
    		var.selectTab = var.mExtends.pdata.tag
    	end
    	PanelGuild.InitPanelsByTag(1)
    end

    var.mPanelDonate = var.widget:getWidgetByName("Panel_donate")
    var.mPanelDonateGold = var.widget:getWidgetByName("Panel_gold_sel")

    var.mPanelDonate:hide():setLocalZOrder(100)
    var.mPanelDonateGold:hide():setLocalZOrder(200)
    var.mCurShowExchange = 1
    var.mCurDonateIdx = 1
    var.mPanelDonate:addClickEventListener(function (pSender)
    	var.mPanelDonate:hide()
    end)
    var.mPanelDonateGold:addClickEventListener(function (pSender)
    	var.mPanelDonateGold:hide()
    end)
    var.mPanelDonate:getWidgetByName("Button_cancel_donate"):addClickEventListener(function (pSender)
    	var.mPanelDonate:hide()
    end)
    var.mPanelDonate:getWidgetByName("Button_confirm_donate"):addClickEventListener(function (pSender)
		NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "exchangedegree",num=EXCHANGE_DEGREE_LIST[var.mCurShowExchange][var.mCurDonateIdx],typeid=var.mCurShowExchange}))
    end)
    var.mPanelDonate:getWidgetByName("Button_close"):addClickEventListener(function (pSender)
    	var.mPanelDonate:hide()
    end)
    var.mPanelDonate:getWidgetByName("Image_donate_sel"):addClickEventListener(function (pSender)
    	var.mPanelDonateGold:show()
    	for i=1,4 do
    		local btn_item = var.mPanelDonateGold:getWidgetByName("Button_item_"..i)
    		btn_item:setTitleText(EXCHANGE_DEGREE_LIST[var.mCurShowExchange][i])
    		btn_item:addClickEventListener(function (pSender)
    			btn_item:getParent():hide()
    			PanelGuild.updateDonateByTag(i)
    		end)
    	end
    end)
    -- PanelGuild.registeEvent()
    PanelGuild.addMenuTabClickEventDonate()
    return var.widget
end

function PanelGuild.InitPanelsByTag(tag)
	if tag == 0 then
		for i=1,7 do
    		if i ~= 1 then
    			var.widget:getWidgetByName("Button_guild_"..i):hide()
    		else
    			var.widget:getWidgetByName("Button_guild_"..i):setTitleText("行会列表     ")
    		end
    	end
    	var.widget:getWidgetByName("Button_last"):hide()
    	var.widget:getWidgetByName("Button_next"):hide()
    	var.widget:getWidgetByName("Button_guild_1"):setBrightStyle(BRIGHT_HIGHLIGHT)
    	var.widget:getWidgetByName("Button_guild_1"):setTouchEnabled(false)
	    var.curLeftArrow = 0
    	PanelGuild.updatePanelByTag(0)
	elseif tag == 1 then
    	var.widget:getWidgetByName("Button_guild_1"):setBrightStyle(BRIGHT_NORMAL)
    	var.widget:getWidgetByName("Button_guild_1"):setTouchEnabled(true)
		for i=1,7 do
			var.widget:getWidgetByName("Button_guild_"..i):show()
			if i == 1 then
    			var.widget:getWidgetByName("Button_guild_"..i):setTitleText("行会信息     ")
			end
    	end
		-- var.widget:getWidgetByName("Button_last"):addClickEventListener(function (pSender)
		--     var.curLeftArrow = 0
		--     PanelGuild.InitLeftBtnsByPage()
  --   	end)
    	UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_last"), callback=function (pSender)
    		var.curLeftArrow = 0
    		PanelGuild.InitLeftBtnsByPage()
    	end,types={UIRedPoint.REDTYPE.GUILD_FULI,UIRedPoint.REDTYPE.GUILD_SKILL}})
    	UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_next"), callback=function (pSender)
    		var.curLeftArrow = 1
    		PanelGuild.InitLeftBtnsByPage()
    	end,types={UIRedPoint.REDTYPE.GUILD_APPLY,UIRedPoint.REDTYPE.GUILD_LEVEL}})
    	PanelGuild.addMenuTabClickEvent()
		PanelGuild.InitLeftBtnsByPage()
    end
end

function PanelGuild.InitLeftBtnsByPage()
	local btn_3 = var.widget:getWidgetByName("Button_guild_3")
	local btn_4 = var.widget:getWidgetByName("Button_guild_4")
	local btn_6 = var.widget:getWidgetByName("Button_guild_6"):setLocalZOrder(10)
	local btn_7 = var.widget:getWidgetByName("Button_guild_7")
	if var.curLeftArrow == 0 then
		var.widget:getWidgetByName("Button_last"):hide()
		var.widget:getWidgetByName("Button_next"):show()
		if var.selectTab <= 7 then
			var.RadionButtonGroup:setButtonSelected(var.selectTab)
		else
			var.RadionButtonGroup:clearSelect()
		end
		if btn_4 and btn_4.point then
			btn_4.point:setPosition(cc.p(125,61))
		end
		if btn_3 and btn_3.point then
			btn_3.point:setPosition(cc.p(125,61))
		end
		if btn_6 and btn_6.point then
			btn_6.point:setPosition(cc.p(125,-1000))
		end
		if btn_7 and btn_7.point then
			btn_7.point:setPosition(cc.p(125,-1000))
		end
	else
    	var.widget:getWidgetByName("Button_last"):show()
    	var.widget:getWidgetByName("Button_next"):hide()
		if var.selectTab <= 3 then
			var.RadionButtonGroup:clearSelect()
		else
			var.RadionButtonGroup:setButtonSelected(var.selectTab-3)
		end
		if btn_4 and btn_4.point then
			btn_4.point:setPosition(cc.p(125,61+240))
		end
		if btn_3 and btn_3.point then
			btn_3.point:setPosition(cc.p(125,-1000))
		end
		if btn_6 and btn_6.point then
			btn_6.point:setPosition(cc.p(125,61))
		end
		if btn_7 and btn_7.point then
			btn_7.point:setPosition(cc.p(125,61))
		end
	end
	for i=1,7 do
		var.widget:getWidgetByName("Button_guild_"..i):setTitleText(left_btn_tab[i+var.curLeftArrow*3])
	end
end

function PanelGuild.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local cp = cc.p(125,61)
    var.RadionButtonGroup = UIRadioButtonGroup.new()
        :addButton(var.widget:getWidgetByName("Button_guild_1"))
        :addButton(var.widget:getWidgetByName("Button_guild_2"))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_guild_3"), position=cp, types={UIRedPoint.REDTYPE.GUILD_SKILL}}))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_guild_4"), position=cp, types={UIRedPoint.REDTYPE.GUILD_FULI}}))
        :addButton(var.widget:getWidgetByName("Button_guild_5"))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_guild_6"), position=cp, types={UIRedPoint.REDTYPE.GUILD_LEVEL}}))
        :addButton(UIRedPoint.addUIPoint({parent=var.widget:getWidgetByName("Button_guild_7"), position=cp, types={UIRedPoint.REDTYPE.GUILD_APPLY}}))
        :onButtonSelectChanged(function(event)
            PanelGuild.updatePanelByTag(event.selected)
        end)
    var.RadionButtonGroup:setButtonSelected(var.selectTab)
end

function PanelGuild.addMenuTabClickEventDonate()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    var.mRadionButtonGroup = UIRadioButtonGroup.new()
        :addButton(var.mPanelDonate:getWidgetByName("btn_gold"))
        :addButton(var.mPanelDonate:getWidgetByName("btn_vcoin"))
        :onButtonSelectChanged(function(event)
            -- PanelGuild.updatePanelByTag(event.selected)
            var.mCurShowExchange = event.selected
            var.mPanelDonate:getWidgetByName("btn_gold"):getTitleRenderer():setPositionY(17)
            var.mPanelDonate:getWidgetByName("btn_vcoin"):getTitleRenderer():setPositionY(17)
            if event.sender then
                event.sender:getTitleRenderer():setPositionY(23)
            end
            if var.mCurShowExchange == 1 then
            	var.mPanelDonate:getWidgetByName("label_gold_num"):setString(EXCHANGE_DEGREE_LIST[var.mCurShowExchange][1])
            	var.mPanelDonate:getWidgetByName("gold_do_label"):setString("金币捐献：")
            else
            	var.mPanelDonate:getWidgetByName("label_gold_num"):setString(EXCHANGE_DEGREE_LIST[var.mCurShowExchange][1])
            	var.mPanelDonate:getWidgetByName("gold_do_label"):setString("元宝捐献：")
            end
            PanelGuild.updateDonateByTag(1)
        end)
    var.mRadionButtonGroup:setButtonSelected(var.mCurShowExchange)
end

function PanelGuild.showGuildRL()
	if var.selectTab == 2 then
		if var.widget:getChildByName("child_widget") then
			var.mEventProxy:removeAllEventListeners()
			var.widget:removeChildByName("child_widget")
	    end
	    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildRL.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildrl")

		var.storeView = var.curPanel:getWidgetByName("PageView_guild_store")
	    var.storeView:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
	    var.storeView:setIndicatorPosition(cc.p(var.storeView:getContentSize().width/2, 5))
	    var.storeView:setIndicatorSpaceBetweenIndexNodes(10)

		var.mViewInitReady = false
		var.mDepotSortTab = {}
		var.mGuildCT = 0
		var.mOnlyShowJob = false
		var.mOnlyShowCanBuy = false
		var.mRongLian = true
	    var.huishouTijianPanel = {}
	    var.recycle_tem_tab = {}
    	var.huishouListView = var.curPanel:getWidgetByName("ListView_ronglian")
	    var.huishouTijianPanel[1] = var.curPanel:getWidgetByName("Panel_huishou_lv"):hide()
	    var.huishouTijianPanel[2] = var.curPanel:getWidgetByName("Panel_huishou_job"):hide()
	    var.huishouTijianPanel[3] = var.curPanel:getWidgetByName("Panel_huishou_color"):hide()
	    var.huishouTijianPanel[4] = var.curPanel:getWidgetByName("Panel_huishou_sex"):hide()

	    var.curPanel:getWidgetByName("check_store_auto"):addClickEventListener(function (pSender)
	    	if var.guild_title < Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then
	    		pSender:setSelected(var.mAutoRecycle ~= 0 and true or false)
	    		NetClient:alertLocalMsg("您没有权限这么做","alert")
	    		return
	    	end
	    	local auto = 0
	    	if pSender:isSelected() then auto = 1 end
    		NetClient:PushLuaTable("newgui.guilddepot.onGetJsonData",util.encode({actionid = "setautorecycle",auto = auto}))
	    end)

	    PanelGuild.initRongLianPanel()
	    
	    PanelGuild.registeEventRL()
    	NetClient:PushLuaTable("newgui.guilddepot.onGetJsonData",util.encode({actionid = "query",}))
	end
end

function PanelGuild.updatePanelByTag(tag)
	if var.widget:getChildByName("child_widget") then
		if var.selectTab == var.curLeftArrow*3 + tag then
			return
		end
		var.mEventProxy:removeAllEventListeners()
		var.widget:removeChildByName("child_widget")
    end
	var.selectTab = var.curLeftArrow*3 + tag
	if var.selectTab == 0 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildInfo.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildinfo")
		var.curPanel:getWidgetByName("Panel_create_confirm"):hide()
		var.curPanel:getWidgetByName("check_guild_leader"):setSelected(false)

		var.curPanel:getWidgetByName("Button_create"):addClickEventListener(function (pSender)
			var.curPanel:getWidgetByName("Panel_create_confirm"):show()
		end)
		var.curPanel:getWidgetByName("Button_cancel"):addClickEventListener(function (pSender)
			var.curPanel:getWidgetByName("Panel_create_confirm"):hide()
		end)

		var.curPanel:getWidgetByName("Button_onekey"):addClickEventListener(function (pSender)
			NetClient:JoinGuild("",0)
		end)

		var.isLeaderOnline = false

	    local inputBg = var.curPanel:getWidgetByName("img_input_bg")
	    local bgSize = inputBg:getContentSize()
	    var.mCreateInput = util.newEditBox({
	        image = "null.png",
	        size = bgSize,
	        x = 0,
	        y = 0,
	        placeHolder = "输入行会名称",
	        placeHolderSize = 20,
	        fontSize = 22,
	        anchor = cc.p(0,0),
	        inputMode = Const.EditBox_InputMode.ANY,
	    })

	    var.mCreateInput:setMaxLength(6)
	    inputBg:addChild(var.mCreateInput)

	    var.curPanel:getWidgetByName("Button_confirm"):addClickEventListener(function (pSender)
			local str = var.mCreateInput:getText()
			if str ~= "" then
				local needitem_num = NetClient:getBagItemNumberById(10059)
				if needitem_num <= 0 then
					local param = {
				        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "所需奴玛号角不足，是否前往购买？建立行会需要奴玛号角（同时获得行会召唤令）",
				        confirmTitle = "前往购买", cancelTitle = "取  消",
				        autoclose = true,
				        confirmCallBack = function ()
							local param = {
					            	name = Notify.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
					            	itemid = 10059,itemprice = 500,itemnum = 1,
					            	itembuyflag = 0,itembindflag = 0,
					            	confirmTitle = "购 买", cancelTitle = "取 消",
					            	confirmCallBack = function (num)
					                  -- 购买令牌
					                	NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({
					                    	actionid = "quickbuy",
					                    	typeid=10059,
					                    	subtype=5,
					                    	num=num
					                }))
					            end
					        }
					        NetClient:dispatchEvent(param)
				        end
				    }
				    NetClient:dispatchEvent(param)
				else
					NetClient:CreateGuild(str,0)
				end
			else
				NetClient:alertLocalMsg("请输入行会名称！","alert")
			end
		end)
		UIItem.getItem({
            parent = var.curPanel:getWidgetByName("hj_bg"),
            typeId = 10059,
        })
		-- var.curPanel:getWidgetByName("item_hj"):addClickEventListener(function (pSender)

		-- end)
	    var.curPanel:getWidgetByName("check_guild_leader"):addClickEventListener(function (pSender)
			if pSender:isSelected() then
				var.isLeaderOnline = true
			else
				var.isLeaderOnline = false
			end
			PanelGuild.handleGuildList()
		end)

	    PanelGuild.registeEventList()
	    NetClient:ListGuild(0)
    elseif var.selectTab == 1 then
    	local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildMem.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildmem")
		
		var.curPanel:getWidgetByName("Panel_mem_operate"):hide():addClickEventListener(function (pSender)
			pSender:hide()
		end)
		var.curPanel:getWidgetByName("Panel_guild_desp"):hide():addClickEventListener(function (pSender)
			pSender:hide()
		end)

		if var.guild_title < 300 then
			var.curPanel:getWidgetByName("Button_editdesp"):hide()
			var.curPanel:getWidgetByName("Button_exit"):setPositionX(765)
		end
		var.curPanel:getWidgetByName("Button_check_equip"):addClickEventListener(function (pSender)
			if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
				NetClient:CheckPlayerEquip(var.mLastSelectName)
				var.curPanel:getWidgetByName("Panel_mem_operate"):hide()
			end
		end)
		var.curPanel:getWidgetByName("Button_private_chat"):addClickEventListener(function (pSender)
			if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
        		NetClient:privateChatTo(var.mLastSelectName)
				var.curPanel:getWidgetByName("Panel_mem_operate"):hide()
			end
		end)
		var.curPanel:getWidgetByName("Button_apply_group"):addClickEventListener(function (pSender)
			if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
				if #NetClient.mGroupMembers > 0 then
		            NetClient:alertLocalMsg("你已经在队伍中了！","alert")
		        else
		            local group_id = NetClient:getGroupIDByName(var.mLastSelectName)
		            if not group_id then
		                NetClient:alertLocalMsg("对方不是队长！","alert")
		            elseif NetClient:getNearGroupMemberByID(group_id) >= Const.GROUP_MAX_MEMBER then
		                NetClient:alertLocalMsg("队伍人数已达上限！","alert")
		            else
		                NetClient:JoinGroup(group_id)
		            end
		        end
				var.curPanel:getWidgetByName("Panel_mem_operate"):hide()
			end
		end)
		var.curPanel:getWidgetByName("Button_add_friend"):addClickEventListener(function (pSender)
			if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
        		NetClient:FriendChange(var.mLastSelectName, Const.FRIEND_TITLE.FRIEND)
				var.curPanel:getWidgetByName("Panel_mem_operate"):hide()
			end
		end)
		var.curPanel:getWidgetByName("Button_black_list"):addClickEventListener(function (pSender)
			if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
        		NetClient:FriendChange(var.mLastSelectName, Const.FRIEND_TITLE.BLACK)
				var.curPanel:getWidgetByName("Panel_mem_operate"):hide()
			end
		end)
		for i=1,3 do
			var.curPanel:getWidgetByName("Button_backup_"..i):addClickEventListener(function (pSender)
				if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
					if var.guild_title == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADMIN then--会长
						if i == 1 then
							if var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then--撤销长老
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,(-1)*Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER)
							else--任命长老
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER)
							end
		    			elseif i == 2 then
		    				if var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then--撤销副会
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,(-1)*Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV)
							else--任命副会
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV)
							end
						elseif i == 3 then
							NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,-1)
						end
					elseif var.guild_title == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then--副会长
						if i == 1 then
							if var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,(-1)*Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER)
							elseif var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_NORMAL then
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER)
							else
								NetClient:alertLocalMsg("您没有权限这么做","alert")
							end
						elseif i == 2 then
							if var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADMIN then--会长
								NetClient:alertLocalMsg("您没有权限这么做","alert")
							else
								NetClient:ChangeGuildMemberTitle(var.guild_name,var.mLastSelectName,-1)
							end
						end
					else
				    	NetClient:alertLocalMsg("您没有权限这么做","alert")
					end
				end
				var.curPanel:getWidgetByName("Panel_mem_operate"):hide()
    			NetClient:ListGuildMember(var.guild_name,101)
			end)
		end

		local function onEdit(event,editBox)
	        if event == "began" then
	            -- 保持面板不被关闭
	            editBox:hide()
	            editBox:setText(var.curPanel:getWidgetByName("label_input_desp"):getString())
	        elseif event == "changed" then
	            -- 输入框内容发生变化
	        elseif event == "ended" then
	            -- 输入结束
	        elseif event == "return" then
	            var.curPanel:getWidgetByName("label_input_desp"):setString(editBox:getText())
	            editBox:setText("")
	            editBox:show()
	        end
	    end

		local inputBg = var.curPanel:getWidgetByName("img_desp_input_bg")
	    local bgSize = inputBg:getContentSize()
	    var.mDespInput = util.newEditBox({
	        image = "null.png",
	        size = bgSize,
	        x = 0,
	        y = 0,
        	listener = onEdit,
	        fontSize = 22,
	        anchor = cc.p(0,0),
	        inputMode = Const.EditBox_InputMode.ANY,
	    })

	    var.mDespInput:setMaxLength(80)
	    inputBg:addChild(var.mDespInput)

		var.curPanel:getWidgetByName("Button_exit"):addClickEventListener(function (pSender)
			local param = {
		        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "您确定要退出行会吗？",
		        confirmTitle = "确  定", cancelTitle = "关  闭",
		        autoclose = true,
		        confirmCallBack = function ()
					NetClient:LeaveGuild(var.guild_name)
		        end
		    }
		    NetClient:dispatchEvent(param)
		end)
		var.curPanel:getWidgetByName("Button_editdesp"):addClickEventListener(function (pSender)
			var.curPanel:getWidgetByName("Panel_guild_desp"):show()
		end)
		var.curPanel:getWidgetByName("Button_confirm_desp"):addClickEventListener(function (pSender)
			NetClient:SetGuildInfo(var.guild_name,"",var.curPanel:getWidgetByName("label_input_desp"):getString())
			var.curPanel:getWidgetByName("Panel_guild_desp"):hide()
		end)
		var.curPanel:getWidgetByName("Button_cancel_desp"):addClickEventListener(function (pSender)
			var.curPanel:getWidgetByName("Panel_guild_desp"):hide()
		end)

		local guild_notice = var.curPanel:getWidgetByName("label_guild_notice")
		guild_notice:getVirtualRenderer():setLineBreakWithoutSpace(true)
		guild_notice:getVirtualRenderer():setDimensions(323,0)
    	local desp_label = var.curPanel:getWidgetByName("label_input_desp")
		desp_label:getVirtualRenderer():setLineBreakWithoutSpace(true)
		desp_label:getVirtualRenderer():setDimensions(400,0)

		var.mMemberData = {}
		PanelGuild.registeEventMem()
	    NetClient:ListGuild(0)
	    NetClient:GetGuildInfo(var.guild_name,0)
    	NetClient:ListGuildMember(var.guild_name,101)
	elseif var.selectTab == 2 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildStore.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildstore")

		var.mViewInitReady = false
		var.mDepotSortTab = {}
		var.mGuildCT = 0
		var.mOnlyShowJob = false
		var.mOnlyShowCanBuy = false
		var.mRongLian = false

		var.pageView = var.curPanel:getWidgetByName("PageView_guild")
	    var.pageView:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
	    var.pageView:setIndicatorPosition(cc.p(var.pageView:getContentSize().width/2, 5))
	    var.pageView:setIndicatorSpaceBetweenIndexNodes(10)

		var.storeView = var.curPanel:getWidgetByName("PageView_guild_store")
	    var.storeView:setIndicatorEnabled(true, "fenye_bg.png", "fenye_point.png", UI_TEX_TYPE_PLIST)
	    var.storeView:setIndicatorPosition(cc.p(var.storeView:getContentSize().width/2, 5))
	    var.storeView:setIndicatorSpaceBetweenIndexNodes(10)

	    var.curPanel:getWidgetByName("check_store_2"):setSelected(false):addClickEventListener(function (pSender)
	    	var.mOnlyShowJob = not var.mOnlyShowJob
	    	PanelGuild.updateStoreByCheckBox()
	    end)
	    var.curPanel:getWidgetByName("check_store_1"):setSelected(false):addClickEventListener(function (pSender)
	    	var.mOnlyShowCanBuy = not var.mOnlyShowCanBuy
	    	PanelGuild.updateStoreByCheckBox()
	    end)

	    var.curPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.01), cc.CallFunc:create(function()
	        PanelGuild.initPageView()
	    end)))
	    var.curPanel:getWidgetByName("btn_plus_con"):addClickEventListener(function (pSender)
	    	PanelGuild.showContribure()
	    end)
	    local rl_btn = var.curPanel:getWidgetByName("Button_equip_rl")
	    if var.guild_title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then
	    	rl_btn:show()
		    rl_btn:addClickEventListener(function (pSender)
		    	if var.guild_title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then
		    		PanelGuild.showGuildRL()
		    	else
				    NetClient:alertLocalMsg("您没有权限这么做","alert")
		    	end
		    end)
	    else
	    	rl_btn:hide()
	    end
	    var.curPanel:getWidgetByName("Text_Count_Tip"):hide()--:setString(NetClient:getBagCount().."/"..(Const.ITEM_BAG_SIZE + NetClient.mBagSlotAdd))
    	PanelGuild.registeEventDepot()
    	NetClient:PushLuaTable("newgui.guilddepot.onGetJsonData",util.encode({actionid = "query",}))
	elseif var.selectTab == 3 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildSkill.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildskill")
		var.mGuildSkillData = {}
		var.mSkillFlagData = {}
		PanelGuild.registeEventSkill()

		var.curPanel:getWidgetByName("btn_plus_donate"):addClickEventListener(function (pSender)
			PanelGuild.showContribure()
		end)
    	NetClient:PushLuaTable("newgui.guildbuff.onGetJsonData",util.encode({actionid = "query",}))
	elseif var.selectTab == 4 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildActivity.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildactivity")

		var.mMijingState = 0
		local get_btn = var.curPanel:getWidgetByName("Button_zb_get")
		local start_btn = var.curPanel:getWidgetByName("Button_zb_start")
		if NetClient.mWarState == 1 then
	    	get_btn:setBrightStyle(BRIGHT_NORMAL)
	    	get_btn:setTouchEnabled(true)
	    	get_btn:setTitleColor(Const.COLOR_YELLOW_2_C3B)
	    	start_btn:setBright(true)
	    	start_btn:setTitleText("参  与")
	    	start_btn:setTouchEnabled(true)
	    	start_btn:setTitleColor(Const.COLOR_YELLOW_2_C3B)
	    	get_btn:addClickEventListener(function (pSender)
	    		EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_king_jf"})
	    	end)
	    	start_btn:addClickEventListener(function (pSender)
    			NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "gowar",}))
	    		EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_guild"})
	    	end)
	    else
	    	get_btn:setBright(false)
	    	get_btn:setTouchEnabled(false)
	    	start_btn:setBright(false)
	    	start_btn:setTouchEnabled(false)
		end

        -- UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("Button_get_fl"),types={UIRedPoint.REDTYPE.GUILD_FULI}})
    	var.curPanel:getWidgetByName("Button_get_fl"):addClickEventListener(function (pSender)
    		NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "drawguildgift",}))
    	end)
    	var.curPanel:getWidgetByName("Button_mj"):addClickEventListener(function (pSender)
    		if var.mMijingState == 0 then
    			NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "openguildcopy",}))
	    		EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_guild"})
			elseif var.mMijingState == 1 then
    			NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "enterguildcopy",}))
	    		EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_guild"})
    		end
    	end)
		PanelGuild.registeEventAc()
    	NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildpanelinfo",}))
	elseif var.selectTab == 5 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildAlliance.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildalliance")
		var.isAllianceOnline = false
		var.curPanel:getWidgetByName("label_alliance_intro"):hide()
    	var.curPanel:getWidgetByName("Button_exit_alliance"):addClickEventListener(function (pSender)
			NetClient:GuildUnion(NetClient.mGuildUnioned[1],GUILD_WAR_OPCODE.GUILD_UNION_DISMISS)
    	end)
	    var.curPanel:getWidgetByName("check_guild_leader"):setSelected(false):addClickEventListener(function (pSender)
			if pSender:isSelected() then
				var.isAllianceOnline = true
			else
				var.isAllianceOnline = false
			end
			PanelGuild.handleGuildAllianceList()
		end)

	    PanelGuild.registeEventAList()
	    NetClient:ListGuildUnion(0)--0已结盟 1 别人申请结盟 2 自己申请结盟
	    NetClient:ListGuildUnion(1)
	    NetClient:ListGuildUnion(2)
	    NetClient:ListGuild(0)
    elseif var.selectTab == 6 then
    	local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildLog.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildlog")
	    PanelGuild.registeEventLog()
    	NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildrizhi",page=1}))
    elseif var.selectTab == 7 then
		local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildInfo.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildinfo")
		var.curPanel:getWidgetByName("Panel_create_confirm"):hide()
		var.curPanel:getWidgetByName("check_guild_leader"):setSelected(false)
		var.curPanel:getWidgetByName("check_guild_leader"):addClickEventListener(function (pSender)
			if pSender:isSelected() then
				var.isLeaderOnline = true
			else
				var.isLeaderOnline = false
			end
			PanelGuild.handleGuildList()
		end)

    	var.curPanel:getWidgetByName("Button_onekey"):hide()
    	var.curPanel:getWidgetByName("Button_create"):hide()
	    PanelGuild.registeEventList()
	    NetClient:ListGuild(0)
    elseif var.selectTab == 8 then
    	local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildFight.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildfight")
		var.isFightOnline = false
		var.curPanel:getWidgetByName("check_guild_leader"):setSelected(false):addClickEventListener(function (pSender)
			if pSender:isSelected() then
				var.isFightOnline = true
			else
				var.isFightOnline = false
			end
			PanelGuild.handleGuildWarList()
		end)
	    PanelGuild.registeEventFight()
	    NetClient:ListGuildWar()
	    NetClient:ListGuild(0)
    elseif var.selectTab == 9 then
    	local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildLevel.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildlevel")

		var.mGuildLevelData = {}

		var.curPanel:getWidgetByName("Button_level"):addClickEventListener(function (pSender)
			NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildlevel",}))
		end)
		UIRedPoint.addUIPoint({parent=var.curPanel:getWidgetByName("Button_level"),types={UIRedPoint.REDTYPE.GUILD_LEVEL}})

		var.curPanel:getWidgetByName("btn_plus_donate"):addClickEventListener(function (pSender)
			PanelGuild.showContribure()
		end)

		PanelGuild.registeEventLevel()
    	NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildpanelinfo",}))
	elseif var.selectTab == 10 then
    	local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelGuild/PanelGuildApply.csb")
		widget:setName("child_widget")
		widget:addTo(var.widget)
		var.curPanel = widget:getChildByName("Panel_guildapply")
		var.mAutoAgree = ""

		local guild_notice = var.curPanel:getWidgetByName("label_guild_notice")
		guild_notice:getVirtualRenderer():setLineBreakWithoutSpace(true)
		guild_notice:getVirtualRenderer():setDimensions(323,0)

		var.curPanel:getWidgetByName("check_auto_agree"):setSelected(false):addClickEventListener(function (pSender)
			if pSender:isSelected() then
				if var.guild_title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
    				NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "setautoagreejoin",auto=1}))
    			else
				    NetClient:alertLocalMsg("您没有权限这么做","alert")
    				var.curPanel:getWidgetByName("check_auto_agree"):setSelected(false)
    			end
			else
				if var.guild_title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
    				NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "setautoagreejoin",auto=0}))
    			else
				    NetClient:alertLocalMsg("您没有权限这么做","alert")
    				var.curPanel:getWidgetByName("check_auto_agree"):setSelected(true)
    			end
			end
		end)
		var.curPanel:getWidgetByName("Button_exit"):addClickEventListener(function (pSender)
			local param = {
		        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "您确定要退出行会吗？",
		        confirmTitle = "确  定", cancelTitle = "关  闭",
		        autoclose = true,
		        confirmCallBack = function ()
					NetClient:LeaveGuild(var.guild_name)
		        end
		    }
		    NetClient:dispatchEvent(param)
		end)
		PanelGuild.registeEventApply()
	    NetClient:GetGuildInfo(var.guild_name,0)
    	NetClient:ListGuildMember(var.guild_name,100)
    	NetClient:PushLuaTable("newgui.guildprocess.onGetJsonData",util.encode({actionid = "guildpanelinfo",}))
    end
end

function PanelGuild.registeEventList()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_GUILD_LIST, PanelGuild.handleGuildList)
		:addEventListener(Notify.EVENT_GUILD_TITLE, PanelGuild.handleGuildTitleChange)
end

function PanelGuild.registeEventAList()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_GUILD_LIST, PanelGuild.handleGuildAllianceList)
		:addEventListener(Notify.EVENT_GUILD_UNION_LIST, PanelGuild.updateGuildAllianceList)
end

function PanelGuild.registeEventMem()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_GUILD_MEMBER, PanelGuild.handleGuildMem)
		:addEventListener(Notify.EVENT_GUILD_INFO, PanelGuild.handleGuildInfo)
		:addEventListener(Notify.EVENT_GUILD_TITLE, PanelGuild.handleGuildTitleChange)
end

function PanelGuild.registeEventDepot()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildDonate)
		:addEventListener(Notify.EVENT_GUILD_ITEM_CHANGE, PanelGuild.handleGuildDepotChange)
		:addEventListener(Notify.EVENT_ITEM_CHANGE, PanelGuild.handleGuildBagChange)
end

function PanelGuild.registeEventRL()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildRLResult)
		:addEventListener(Notify.EVENT_GUILD_ITEM_CHANGE, PanelGuild.handleGuildDepotChange)
end

function PanelGuild.registeEventSkill()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildSkill)
end

function PanelGuild.registeEventAc()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildAc)
end

function PanelGuild.registeEventLog()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildLog)
end

function PanelGuild.registeEventFight()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_GUILD_LIST, PanelGuild.handleGuildWarList)
		:addEventListener(Notify.EVENT_GUILD_WAR_LIST, PanelGuild.handleGuildWarList)
end

function PanelGuild.registeEventLevel()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildLevel)
end

function PanelGuild.registeEventApply()
	var.mEventProxy = dw.EventProxy.new(NetClient, var.widget)
		:addEventListener(Notify.EVENT_GUILD_MEMBER, PanelGuild.handleGuildMemApply)
		:addEventListener(Notify.EVENT_GUILD_INFO, PanelGuild.handleGuildInfoApply)
		:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelGuild.handleGuildLuaApply)
		:addEventListener(Notify.EVENT_GUILD_TITLE, PanelGuild.handleGuildTitleChange)
end

function PanelGuild.handleGuildDonate(event)
	if event and event.type == "query_guild_contribute" then
        local depot_data = json.decode(event.data)
        if not depot_data then return end
        var.mGuildCT = depot_data.curvalue
        var.curPanel:getWidgetByName("label_guild_exp"):setString(depot_data.guild_exp)
        var.curPanel:getWidgetByName("label_contribute"):setString(depot_data.curvalue)
        if tonumber(depot_data.curvalue) < tonumber(depot_data.guild_exp) and var.selectTab ~= 2 then
        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_RED_1_C3B)
        else
        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_WHITE_1_C3B)
        end
    end
end

function PanelGuild.handleGuildRLResult(event)
	if event and event.type == "recycle_guild_item" then
        local depot_data = json.decode(event.data)
        if not depot_data then return end
        if depot_data == 1 then
        	var.recycle_tem_tab = {}
			PanelGuild.updateRLListView()
			PanelGuild.updateStoreByCheckBox()
        end
    elseif event and event.type == "query_guild_contribute" then
        local depot_data = json.decode(event.data)
        if not depot_data then return end
        var.mAutoRecycle = tonumber(depot_data.auto_recycle) or 0
        var.curPanel:getWidgetByName("check_store_auto"):setSelected(tonumber(depot_data.auto_recycle)~=0 and true or false)
    end
end

function PanelGuild.handleGuildDepotChange()
	-- if not var.mViewInitReady then
		PanelGuild.updateStoreByCheckBox()
	-- end
end

function PanelGuild.handleGuildBagChange(event)
	if event then
		-- print(event.pos,event.oldType,event.newType)
		-- oldType存在并且newType==-1捐献物品
		-- oldType==nil并且newType存在获得物品
		PanelGuild.initPageView()
	end
end

function PanelGuild.updateStoreByCheckBox()
	var.mDepotSortTab = {}
	for i=Const.ITEM_GUILDDEPOT_BEGIN,Const.ITEM_GUILDDEPOT_BEGIN+Const.ITEM_GUILDDEPOT_SIZE do
		local guildItem = NetClient:getGuildDepotItem(i)
		if guildItem then
			local itemdef = NetClient:getItemDefByID(guildItem.mTypeID)
			if itemdef then
				if var.mOnlyShowJob or var.mOnlyShowCanBuy then
					if var.mOnlyShowJob and var.mOnlyShowCanBuy then
						if (itemdef.mJob == 0 or itemdef.mJob == game.GetMainNetGhost():NetAttr(Const.net_job)) and (itemdef.mGuildCT <= var.mGuildCT) then
							table.insert(var.mDepotSortTab,guildItem)
						end
					else
						if var.mOnlyShowJob and (itemdef.mJob == 0 or itemdef.mJob == game.getRoleJob()) then
							table.insert(var.mDepotSortTab,guildItem)
						end
						if var.mOnlyShowCanBuy and (itemdef.mGuildCT <= var.mGuildCT) then
							table.insert(var.mDepotSortTab,guildItem)
						end
					end
				else
					table.insert(var.mDepotSortTab,guildItem)
				end
			end
		end
	end
	if #var.mDepotSortTab > 0 then
		PanelGuild.initStoreView()
    	var.curPanel:getWidgetByName("label_store_empty"):hide()
	else
    	if var.mOnlyShowJob and var.mOnlyShowCanBuy then
    		var.curPanel:getWidgetByName("label_store_empty"):setString("没有符合条件的装备"):show()
    	elseif var.mOnlyShowJob and not var.mOnlyShowCanBuy then
    		var.curPanel:getWidgetByName("label_store_empty"):setString("没有符合条件的装备"):show()
		elseif not var.mOnlyShowJob and var.mOnlyShowCanBuy then
    		var.curPanel:getWidgetByName("label_store_empty"):setString("没有可兑换的装备"):show()
		else
    		var.curPanel:getWidgetByName("label_store_empty"):setString("工会仓库空空如也"):show()
    	end
		var.storeView:removeAllPages()
	end
end

function PanelGuild.handleGuildList( event )
	local listView = var.curPanel:getWidgetByName("list_guild")
	local tempGuildList = {}
	for i=1,#NetClient.mGuildList do
		local temp_data = NetClient.mGuildList[i]
		if var.isLeaderOnline and temp_data.online_state == 1 then
			table.insert(tempGuildList,temp_data)
		elseif not var.isLeaderOnline then
			table.insert(tempGuildList,temp_data)
		end
	end
	if #listView:getItems() <= 0 or #listView:getItems() ~= #tempGuildList then
		listView:removeAllItems()
		for i=1,#tempGuildList do
			local guild_data = tempGuildList[i]
			local item_model = var.curPanel:getWidgetByName("model_achieve"):clone()
			PanelGuild.updateGuildModelByData(guild_data,item_model)
			if var.selectTab == 7 then
		    	item_model:getWidgetByName("Button_apply"):hide()
			end
			item_model:getWidgetByName("Button_apply"):addClickEventListener(function (pSender)
				NetClient:JoinGuild(guild_data.mName,0)
			end)
			listView:pushBackCustomItem(item_model)
		end
	else
		for i=1,#tempGuildList do
			local guild_data = tempGuildList[i]
			local item_model = listView:getItem(i-1)
			if guild_data and item_model then
				PanelGuild.updateGuildModelByData(guild_data,item_model)
			end
		end
	end
end

function PanelGuild.handleGuildAllianceList(event)
	local listView = var.curPanel:getWidgetByName("list_guild")
	local tempGuildList = {}
	for i=1,#NetClient.mGuildList do
		if NetClient.mGuildList[i].mName ~= var.guild_name then
			local notInUnioned = true
			for i=1,#NetClient.mGuildUnioned do
				if NetClient.mGuildUnioned[i] == NetClient.mGuildList[i].mName then
					notInUnioned = false
				end
			end
			local notLeaderOnline = true
			if var.isAllianceOnline and NetClient.mGuildList[i].online_state ~= 1 then
				notLeaderOnline = false
			end
			if notInUnioned and notLeaderOnline then
				table.insert(tempGuildList,NetClient.mGuildList[i])
			end
		end
	end
	if #listView:getItems() <= 0 or #listView:getItems() ~= #tempGuildList then
		listView:removeAllItems()
		for i=1,#tempGuildList do
			local guild_data = tempGuildList[i]
			local item_model = var.curPanel:getWidgetByName("model_achieve"):clone()
			PanelGuild.updateGuildAllianceByData(guild_data,item_model)
			local applyed = false
			for j=1,#NetClient.mGuildUnionSelfApply do
				if guild_data.mName == NetClient.mGuildUnionSelfApply[j] then
					applyed = true
				end
			end
			local apply_btn = item_model:getWidgetByName("Button_apply")
			if applyed then
				apply_btn:setTitleText("取  消")
			else
				apply_btn:setTitleText("结  盟")
			end
			apply_btn.applyed = applyed
			apply_btn:addClickEventListener(function (pSender)
				if pSender.applyed then
					NetClient:GuildUnion(guild_data.mName,GUILD_WAR_OPCODE.GUILD_UNION_REQ_CANCEL)
				else
					NetClient:GuildUnion(guild_data.mName,GUILD_WAR_OPCODE.GUILD_UNION_REQ)
				end
			end)
			listView:pushBackCustomItem(item_model)
		end
	else
		for i=1,#tempGuildList do
			local guild_data = tempGuildList[i]
			local item_model = listView:getItem(i-1)
			if guild_data and item_model then
				PanelGuild.updateGuildAllianceByData(guild_data,item_model)
			end
		end
	end
end

function PanelGuild.updateGuildAllianceList(event)
	if event and event.list_type == 1 then
		if #NetClient.mGuildUnionApply > 0 then
			local listView = var.curPanel:getWidgetByName("list_apply")
			if #listView:getItems() <= 0 or #listView:getItems() ~= #NetClient.mGuildUnionApply then
				listView:removeAllItems()
				for i=1,#NetClient.mGuildUnionApply do
					local item_model = var.curPanel:getWidgetByName("model_apply"):clone()
					item_model:getWidgetByName("Image_high"):hide()
					item_model:getWidgetByName("label_guild_name"):setString(NetClient.mGuildUnionApply[i])

					item_model:getWidgetByName("Button_apply_cancel"):addClickEventListener(function (pSender)
						NetClient:GuildUnion(NetClient.mGuildUnionApply[i],GUILD_WAR_OPCODE.GUILD_UNION_REFUSE)
					end)
					item_model:getWidgetByName("Button_apply_agree"):addClickEventListener(function (pSender)
						NetClient:GuildUnion(NetClient.mGuildUnionApply[i],GUILD_WAR_OPCODE.GUILD_UNION_AGREE)
					end)
					listView:pushBackCustomItem(item_model)
				end
			end
		else
			var.curPanel:getWidgetByName("list_apply"):removeAllItems()
		end
	elseif event and event.list_type == 0 then
		if #NetClient.mGuildUnioned > 0 then
			var.curPanel:getWidgetByName("label_alliance_name"):setString(NetClient.mGuildUnioned[1])
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setBrightStyle(BRIGHT_NORMAL)
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setTouchEnabled(true)
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setBright(true)
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setTitleColor(Const.COLOR_YELLOW_2_C3B)
		else
			var.curPanel:getWidgetByName("label_alliance_name"):setString("无")
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setBright(false)
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setTouchEnabled(false)
	    	var.curPanel:getWidgetByName("Button_exit_alliance"):setTitleColor(Const.COLOR_GRAY_1_C3B)
		end
	end
end

function PanelGuild.handleGuildWarList(event)
	local listView = var.curPanel:getWidgetByName("list_guild")
	local tempGuildList = {}
	for i=1,#NetClient.mGuildList do
		if NetClient.mGuildList[i].mName ~= var.guild_name then
			local notFightOnline = true
			if var.isFightOnline and NetClient.mGuildList[i].online_state ~= 1 then
				notFightOnline = false
			end
			if notFightOnline then
				table.insert(tempGuildList,NetClient.mGuildList[i])
			end
		end
	end
	if #listView:getItems() <= 0 or #listView:getItems() ~= #tempGuildList then
		listView:removeAllItems()
		for i=1,#tempGuildList do
			local guild_data = tempGuildList[i]
			local item_model = var.curPanel:getWidgetByName("model_achieve"):clone()
			PanelGuild.updateGuildFightByData(guild_data,item_model)
			local apply_btn = item_model:getWidgetByName("Button_fight")
			local applyed = false
			for j=1,#NetClient.mGuildWar do
				if guild_data.mName == NetClient.mGuildWar[j].guild_name then
					applyed = true
					item_model:getWidgetByName("label_left_time"):setString(game.convertSecondsToH( NetClient.mGuildWar[j].lefttime ))
				end
			end
			if applyed then
				apply_btn:setTitleText("宣战中")
			else
				apply_btn:setTitleText("宣  战")
			end
			apply_btn.applyed = applyed
			apply_btn:addClickEventListener(function (pSender)
				if pSender.applyed then
			    	NetClient:alertLocalMsg("无法取消宣战！","alert")
					-- NetClient:GuildWar(guild_data.mName,GUILD_WAR_OPCODE.END_GUILD_WAR)
				else
					NetClient:GuildWar(guild_data.mName,GUILD_WAR_OPCODE.START_GUILD_WAR)
				end
			end)
			listView:pushBackCustomItem(item_model)
		end
	else
		for i=1,#tempGuildList do
			local guild_data = tempGuildList[i]
			local item_model = listView:getItem(i-1)
			if guild_data and item_model then
				local applyed = false
				local apply_btn = item_model:getWidgetByName("Button_fight")
				for j=1,#NetClient.mGuildWar do
					if guild_data.mName == NetClient.mGuildWar[j].guild_name then
						applyed = true
						item_model:getWidgetByName("label_left_time"):setString(game.convertSecondsToH( NetClient.mGuildWar[j].lefttime ))
					end
				end
				if applyed then
					apply_btn:setTitleText("宣战中")
				else
					apply_btn:setTitleText("宣  战")
				end
				apply_btn.applyed = applyed
				PanelGuild.updateGuildFightByData(guild_data,item_model)
			end
		end
	end
end

function PanelGuild.updateGuildModelByData(guild_data,item_model)
	item_model:getWidgetByName("Image_high"):hide()
	item_model:getWidgetByName("label_guild_name"):setString(guild_data.mName):setColor(Const.COLOR_WHITE_1_C3B)
	item_model:getWidgetByName("label_guild_leader"):setString(guild_data.mLeader)
	if guild_data.online_state == 1 then
		item_model:getWidgetByName("label_guild_name"):setColor(Const.COLOR_GREEN_1_C3B)
	else
		item_model:getWidgetByName("label_guild_name"):setColor(Const.COLOR_YELLOW_1_C3B)
	end
	item_model:getWidgetByName("label_mem_num"):setString(guild_data.mMemberNumber.."/"..guild_data.maxnum)
	if guild_data.entering > 0 then
		item_model:getWidgetByName("Button_apply"):setTitleText("取消申请")
	else
		item_model:getWidgetByName("Button_apply"):setTitleText("申请加入")
	end
end

function PanelGuild.updateGuildAllianceByData(guild_data,item_model)
	item_model:getWidgetByName("Image_high"):hide()
	item_model:getWidgetByName("label_guild_name"):setString(guild_data.mName)
	item_model:getWidgetByName("label_guild_num"):setString(guild_data.mMemberNumber)
	item_model:getWidgetByName("label_guild_fight"):setString(guild_data.fight)
	local apply_btn = item_model:getWidgetByName("Button_apply")
	if guild_data.opcode then
		if guild_data.opcode == 7 then
			apply_btn:setTitleText("结  盟")
			apply_btn.applyed = false
		elseif guild_data.opcode == 8 then
			apply_btn:setTitleText("取  消")
			apply_btn.applyed = true
		end
	end
end

function PanelGuild.updateGuildFightByData(guild_data,item_model)
	item_model:getWidgetByName("Image_high"):hide()
	item_model:getWidgetByName("label_guild_name"):setString(guild_data.mName)
	item_model:getWidgetByName("label_mem_num"):setString(guild_data.mMemberNumber)
	item_model:getWidgetByName("label_guild_fight"):setString(guild_data.fight)
end

function PanelGuild.handleGuildTitleChange( event )
	local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
    	local new_name = MainAvatar:NetAttr(Const.net_guild_name)
    	local new_title = MainAvatar:NetAttr(Const.net_guild_title)
    	if var.guild_name == "" and new_name ~= "" and var.guild_title == 0 and new_title > 100 then
    		var.mEventProxy:removeAllEventListeners()
    		if var.widget:getChildByName("child_widget") then
				var.widget:removeChildByName("child_widget")
		    end
    		var.guild_name = new_name
    		var.guild_title = new_title
    		var.selectTab = 1
    		PanelGuild.InitPanelsByTag(1)
    	elseif var.guild_name ~= "" and new_name == "" and var.guild_title > 100 and new_title == 0 then 
    		var.mEventProxy:removeAllEventListeners()
    		if var.widget:getChildByName("child_widget") then
				var.widget:removeChildByName("child_widget")
		    end
    		var.guild_name = new_name
    		var.guild_title = new_title
    		PanelGuild.InitPanelsByTag(0)
    	else
    		var.guild_name = new_name
    		var.guild_title = new_title
    	end
    end
end

function PanelGuild.updateGuildMemByData(data,item_model,index)
	item_model:getWidgetByName("label_player_name"):setString(data.nick_name)
	item_model:getWidgetByName("label_title"):setString(Const.GUILD_TITLE[data.title])
	if data.nick_name == var.self_name then
		item_model:getWidgetByName("label_player_name"):setColor(Const.COLOR_YELLOW_3_C3B)
		item_model:getWidgetByName("label_job"):setColor(Const.COLOR_YELLOW_3_C3B)
		item_model:getWidgetByName("label_level"):setColor(Const.COLOR_YELLOW_3_C3B)
		item_model:getWidgetByName("label_contribute"):setColor(Const.COLOR_YELLOW_3_C3B)
		item_model:getWidgetByName("label_state"):setColor(Const.COLOR_YELLOW_3_C3B)
		if data.title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
			item_model:getWidgetByName("label_title"):setColor(Const.COLOR_YELLOW_2_C3B)
		else
			item_model:getWidgetByName("label_title"):setColor(Const.COLOR_YELLOW_3_C3B)
		end
	else
		item_model:getWidgetByName("label_player_name"):setColor(Const.COLOR_YELLOW_1_C3B)
		item_model:getWidgetByName("label_job"):setColor(Const.COLOR_YELLOW_1_C3B)
		item_model:getWidgetByName("label_level"):setColor(Const.COLOR_YELLOW_1_C3B)
		item_model:getWidgetByName("label_contribute"):setColor(Const.COLOR_YELLOW_1_C3B)
		item_model:getWidgetByName("label_state"):setColor(Const.COLOR_YELLOW_1_C3B)
		if data.title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
			item_model:getWidgetByName("label_title"):setColor(Const.COLOR_YELLOW_2_C3B)
		else
			item_model:getWidgetByName("label_title"):setColor(Const.COLOR_YELLOW_1_C3B)
		end
	end
	item_model:getWidgetByName("label_job"):setString(Const.JOB[data.job])
	item_model:getWidgetByName("label_level"):setString(data.level)
	item_model:getWidgetByName("label_contribute"):setString(data.guildpt)
	item_model:getWidgetByName("label_state"):setString(Const.ONLINE[data.online])
	if data.online == 1 then
		item_model:getWidgetByName("label_state"):setColor(Const.COLOR_GREEN_1_C3B)
	else
		local out_str = "离线"
		local left_time = os.time()-data.last_out
		if left_time > 0 then
			local day = math.floor(left_time/(60*60*24))
            local left = left_time%(60*60*24)
            local hour = math.floor(left/(60*60))
            left = left%(60*60)
            local min = math.floor(left/60)
            if day > 0 then
            	out_str = day.."天前"
            elseif hour > 0 then
            	out_str = hour.."小时前"
            elseif min > 0 then
            	out_str = min.."分前"
            else
            	out_str = "刚刚"
            end
		end
		item_model:getWidgetByName("label_state"):setString(out_str)
	end
	item_model:getWidgetByName("Image_high"):hide()
	item_model.mem_data = data
	if index%2 == 0 then
		item_model:getWidgetByName("Image_frame"):loadTexture("touming.png",UI_TEX_TYPE_PLIST)
	end
end

function PanelGuild.handleGuildMem(event)
	if event and event.data then
		local guild = event.data
		if guild and guild.mRealMembers and var.selectTab == 1 then
			local compFunction = function(member1,member2)
				if member1.title == member2.title then
					return member1.level > member2.level
				end
				return member1.title > member2.title
			end
			var.mMemberData = {}
			for k,v in pairs(guild.mRealMembers) do
				local member = {}
				member.nick_name		= v.nick_name
				member.title			= v.title
				member.online			= v.online
				member.gender			= v.gender
				member.job				= v.job
				member.level			= v.level
				member.fight			= v.fight
				member.last_out			= v.last_out
				member.guildpt			= v.guildpt
				member.reinlv			= v.reinlv
				table.insert(var.mMemberData,member)
			end
			table.sort(var.mMemberData, compFunction )
			local listView = var.curPanel:getWidgetByName("list_guild")
			if #listView:getItems() <= 0 then
				listView:removeAllItems()
				var.mLastSelect = nil
				var.mLastSelectName = ""
				var.mLastSelectTitle = 0
				for i=1,#var.mMemberData do
					local mem_data = var.mMemberData[i]
					local item_model = var.curPanel:getWidgetByName("model_mem"):clone()
					PanelGuild.updateGuildMemByData(mem_data,item_model,i)
					item_model.mem_data = mem_data
					item_model:addClickEventListener(function (pSender)
						if var.mLastSelect then
							var.mLastSelect:getWidgetByName("Image_high"):hide()
						end
						var.mLastSelect = pSender
						pSender:getWidgetByName("Image_high"):show()
						var.mLastSelectName = pSender.mem_data.nick_name
						var.mLastSelectTitle = pSender.mem_data.title
						if pSender.mem_data.nick_name ~= var.self_name then
							PanelGuild.updateGuildMemOperate()
						end
					end)
					listView:pushBackCustomItem(item_model)
				end
			else
				var.mLastSelect = nil
				for i=1,#listView:getItems() do
					local item = listView:getItem(i-1)
					if item then
						if var.mMemberData[i] then
							PanelGuild.updateGuildMemByData(var.mMemberData[i],item,i)
						else
							listView:removeItem(i-1)
						end
					end
				end
			end
		end
	end
end

function PanelGuild.handleGuildMemApply(event)
	if event and event.data then
		local guild = event.data
		if guild and var.selectTab == 10 then
			var.mApplyMemberData = {}
			for k,v in pairs(guild.mEnteringMembers) do
				local member = {}
				member.nick_name		= v.nick_name
				member.title			= v.title
				member.online			= v.online
				member.gender			= v.gender
				member.job				= v.job
				member.level			= v.level
				member.fight			= v.fight
				member.last_out			= v.last_out
				member.guildpt			= v.guildpt
				member.reinlv			= v.reinlv
				table.insert(var.mApplyMemberData,member)
			end
			local listView = var.curPanel:getWidgetByName("list_guild")
			if #listView:getItems() <= 0 or #listView:getItems() ~= #var.mApplyMemberData then
				listView:removeAllItems()
				for i=1,#var.mApplyMemberData do
					local mem_data = var.mApplyMemberData[i]
					local item_model = var.curPanel:getWidgetByName("model_achieve"):clone()
					item_model:getWidgetByName("Image_high"):hide()
					item_model:getWidgetByName("label_player_name"):setString(mem_data.nick_name)
					item_model:getWidgetByName("label_job"):setString(Const.JOB[mem_data.job])
					item_model:getWidgetByName("label_level"):setString(mem_data.level)
					item_model:getWidgetByName("label_contribute"):setString(mem_data.guildpt)
					local btn_approve = item_model:getWidgetByName("Button_approve")
					btn_approve.player_name = mem_data.nick_name
					btn_approve:addClickEventListener(function (pSender)
						if var.guild_title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
			    			NetClient:ChangeGuildMemberTitle(var.guild_name,pSender.player_name,1)
	    					NetClient:ListGuildMember(var.guild_name,100)
	    				else
				    		NetClient:alertLocalMsg("您没有权限这么做","alert")
	    				end
					end)
					local btn_refuse = item_model:getWidgetByName("Button_cancel")
					btn_refuse.player_name = mem_data.nick_name
					btn_refuse:addClickEventListener(function (pSender)
						if var.guild_title >= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
			    			NetClient:ChangeGuildMemberTitle(var.guild_name,pSender.player_name,0)
	    					NetClient:ListGuildMember(var.guild_name,100)
	    				else
				    		NetClient:alertLocalMsg("您没有权限这么做","alert")
	    				end
					end)
					listView:pushBackCustomItem(item_model)
				end
			end
		end
	end
end

function PanelGuild.handleGuildLuaApply(event)
	if event and event.type == "setautoagreejoin" then
        local ac_data = json.decode(event.data)
        if not ac_data then return end
        var.mAutoAgree = ac_data.autoagreejoin
        var.curPanel:getWidgetByName("check_auto_agree"):setSelected(ac_data.autoagreejoin == "1" and true or false)
    end
end

function PanelGuild.handleGuildInfo(event)
	local pGuild = NetClient:getGuildByName(var.guild_name)
	if pGuild and var.selectTab == 1 then
		local notice_str = pGuild.mNotice
		if notice_str == "" then notice_str = "暂无公告" end
		var.curPanel:getWidgetByName("label_guild_notice"):setString(notice_str)
		var.curPanel:getWidgetByName("label_input_desp"):setString(notice_str)
		var.curPanel:getWidgetByName("AtlasLabel_fight"):setString(pGuild.fight)
		var.curPanel:getWidgetByName("label_guild_num"):setString(pGuild.mMemberNumber.."/"..pGuild.maxnum)
	end
end

function PanelGuild.handleGuildInfoApply(event)
	local pGuild = NetClient:getGuildByName(var.guild_name)
	if pGuild and var.selectTab == 10 then
		local notice_str = pGuild.mNotice
		if notice_str == "" then notice_str = "暂无公告" end
		var.curPanel:getWidgetByName("label_guild_notice"):setString(notice_str)
	end
end

function PanelGuild.initPageView()
    var.pageView:removeAllPages()
    var.mBagItemTab = {}
    for i=0,119 do
    	local item = NetClient:getNetItem(i)
        if item then
            if game.IsEquipment(item.mTypeID) and PanelGuild.CanDepotDonate(i) then
            	table.insert(var.mBagItemTab,i)
            end
        end
    end
    if #var.mBagItemTab > 0 then
    	var.curPanel:getWidgetByName("label_bag_empty"):hide()
    else
    	var.curPanel:getWidgetByName("label_bag_empty"):show()
    end
    var.gridPageView = UIGridPageView.new({
        pv = var.pageView,
        parent = var.curPanel:getWidgetByName("bagview_layout"),
        count = #var.mBagItemTab,--LEFT_ROWS*LEFT_COLUMNS*LEFT_PAGE_COUNT,
        padding = {left = 0, right = 0, top = 0, bottom = 30},
        row = LEFT_ROWS,
        column = LEFT_COLUMNS,
        initGridListener = PanelGuild.showGridItem
    })
end

function PanelGuild.initStoreView()
	var.storeView:removeAllPages()
	var.mViewInitReady = true
	var.storePageView = UIGridPageView.new({
        pv = var.storeView,
        parent = var.curPanel:getWidgetByName("storeview_layout"),
        count = #var.mDepotSortTab,
        padding = {left = 0, right = 0, top = 0, bottom = 30},
        row = RIGHT_ROWS,
        column = RIGHT_COLUMNS,
        initGridListener = PanelGuild.showGridItemRight
    })
    if var.mRongLian then
    	PanelGuild.onRLSetting()
    end
end

function PanelGuild.showGridItem(gridWidget, index)
    local itemBg = gridWidget:getChildByName("gridbg")
    if itemBg then
        gridWidget:removeChildByName("gridbg")
    end

    local itemBg = var.curPanel:getWidgetByName("item_bg"):clone()
    itemBg:setName("gridbg")
    itemBg:addTo(gridWidget)
    itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    itemBg:show()

    local curbagpos = var.mBagItemTab[index]--Const.ITEM_BAG_BEGIN + index - 1
    itemBg.mpos = curbagpos
    itemBg.index = index
    gridWidget.pos = curbagpos
    itemBg:getWidgetByName("lock_flag"):hide()
    local mItem = NetClient:getNetItem(curbagpos)
	if not mItem then return end
    -- if game.IsPosInBag(curbagpos) and PanelGuild.CanDepotDonate(curbagpos) then
        -- itemBg:getWidgetByName("lock_flag"):hide()
        UIItem.getItem({
            parent = itemBg,
            pos = curbagpos,
            showSelectEffect = true,
            itemCallBack = function(pSender)
                -- PanelBag.onLeftItemSelected(pSender.mpos)
                local netItem = NetClient:getNetItem(pSender.mpos)
    			if not netItem then return end
                NetClient:dispatchEvent(
	            {
	                name = Notify.EVENT_HANDLE_ITEM_TIPS,
	                pos = pSender.mpos,
	                typeId = netItem.mTypeID,
	                toGDepot = true,
	            })
            end
        })
    -- end
end

function PanelGuild.CanDepotDonate(pos)
    local mItem = NetClient:getNetItem(pos)
	if not mItem then return end
	local canInsert = true
	--绑定
	if mItem.mItemFlags%2 == 1 then
		canInsert = false
	end
	--强化
	if mItem.mLevel > 0 then
		canInsert = false
	end
	--升阶
	local nmod1 = math.fmod(mItem.mTypeID,1000)
	local nQuality=math.floor(nmod1/100)
	if nQuality > 1 then
		canInsert = false
	end
	--神铸
	if mItem.mShenzhu > 0 then
		canInsert = false
	end
	local itemdef = NetClient:getItemDefByID(mItem.mTypeID)
	if not itemdef then return end
	if itemdef.mGuildCT <= 0 then
		canInsert = false
	end
	return canInsert
end

function PanelGuild.showGridItemRight(gridWidget, index)
	local itemBg = gridWidget:getChildByName("gridbg")
    if itemBg then
        gridWidget:removeChildByName("gridbg")
    end

    local model = var.curPanel:getWidgetByName("item_bg")
    if model:getChildByName("iconNode") then
    	model:removeChildByName("iconNode")
    end
    local itemBg = model:clone()
    itemBg:setName("gridbg")
    itemBg:addTo(gridWidget)
    itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    itemBg:show()

    local posData = var.mDepotSortTab[index]
    local curbagpos = -999
    if posData then curbagpos = var.mDepotSortTab[index].position end--Const.ITEM_GUILDDEPOT_BEGIN + index - 1
    itemBg.mpos = curbagpos
    itemBg.index = index
    gridWidget.pos = curbagpos
    itemBg:getWidgetByName("lock_flag"):hide()
    if game.IsPosInGuildDepot(curbagpos) then
        UIItem.getItem({
            parent = itemBg,
            pos = curbagpos,
            showSelectEffect = true,
            itemCallBack = function(pSender)
            	if not var.mRongLian then
	                local netItem = NetClient:getGuildDepotItem(pSender.mpos)
	    			if not netItem then return end
	                NetClient:dispatchEvent(
		            {
		                name = Notify.EVENT_HANDLE_ITEM_TIPS,
		                pos = pSender.mpos,
		                typeId = netItem.mTypeID,
		                -- toGDepot = true,
		            })
	            else
	            	for _, v in ipairs(var.recycle_tem_tab) do
				        if v.pos == pSender.mpos then
				            return
				        end
				    end
				    if #var.recycle_tem_tab > 30 then
				    	NetClient:alertLocalMsg("最多放入30件装备！","alert")
				    	return
				    end
    				table.insert(var.recycle_tem_tab, {pos = pSender.mpos})
    				PanelGuild.updateRLListView()
	            end
            end
        })

    end
end

function PanelGuild.handleGuildSkill(event)
	if event and event.type == "skill_base_data" then
        local skill_data = json.decode(event.data)
        if not skill_data then return end
        var.mGuildSkillData = skill_data.base_data
        var.mSkillFlagData = skill_data.real_ldflag
        var.mMyGuildCont = skill_data.guild_con
		PanelGuild.initGuildSkillView()
    elseif event and event.type == "skill_upgrade" then
    	local skill_data = json.decode(event.data)
        if not skill_data then return end
        var.mMyGuildCont = skill_data.guild_con
    	if var.mSkillFlagData[skill_data.id] then
    		var.mSkillFlagData[skill_data.id][1] = skill_data.level
    		PanelGuild.initGuildSkillView()
			PanelGuild.updateGuildSkillByTag(skill_data.id,skill_data.level)
    	end
	elseif event and event.type == "query_guild_contribute" then
        local depot_data = json.decode(event.data)
        if not depot_data then return end
        var.mMyGuildCont = depot_data.curvalue
        -- var.curPanel:getWidgetByName("label_contribute"):setString(depot_data.curvalue)
        if var.mLastSelectSkill then
			PanelGuild.updateGuildSkillByTag(var.mLastSelectSkill.tag,var.mSkillFlagData[var.mLastSelectSkill.tag][1])
        end
    end
end

function PanelGuild.initGuildSkillView()
	local listView = var.curPanel:getWidgetByName("list_guild_skill")
	if var.mGuildSkillData and var.mSkillFlagData then
		if #listView:getItems() <= 0 then
			listView:removeAllItems()
			var.mLastSelectSkill = nil
	        for i=1,#var.mGuildSkillData do
	        	local skill_level = var.mSkillFlagData[i][1] or 0
	        	local temp_data = var.mGuildSkillData[i]
	        	local item_model = var.curPanel:getWidgetByName("model_guildskill"):clone()
	        	item_model:getWidgetByName("Image_high"):hide()
	        	item_model:getWidgetByName("name"):setString(temp_data.name)
	        	item_model:getWidgetByName("level"):setString(skill_level.."级")
	        	item_model:getWidgetByName("skill_icon"):loadTexture(GUILD_SKILL_PATH[i],UI_TEX_TYPE_PLIST)
	        	item_model.tag = i
	        	item_model:addClickEventListener(function (pSender)
					if var.mLastSelectSkill then
						var.mLastSelectSkill:getWidgetByName("Image_high"):hide()
					end
					var.mLastSelectSkill = pSender
					pSender:getWidgetByName("Image_high"):show()
					PanelGuild.updateGuildSkillByTag(var.mLastSelectSkill.tag,var.mSkillFlagData[var.mLastSelectSkill.tag][1])
				end)
				item_model:getWidgetByName("Button_level"):addClickEventListener(function (pSender)
					if var.mLastSelectSkill then
						var.mLastSelectSkill:getWidgetByName("Image_high"):hide()
					end
					var.mLastSelectSkill = pSender:getParent()
					var.mLastSelectSkill:getWidgetByName("Image_high"):show()
					PanelGuild.updateGuildSkillByTag(var.mLastSelectSkill.tag,var.mSkillFlagData[var.mLastSelectSkill.tag][1])
					NetClient:PushLuaTable("newgui.guildbuff.onGetJsonData",util.encode({actionid = "upgrade",id=i}))
				end)
				if i == 1 then
					var.mLastSelectSkill = item_model
					var.mLastSelectSkill:getWidgetByName("Image_high"):show()
					PanelGuild.updateGuildSkillByTag(1,var.mSkillFlagData[i][1])
				end
				listView:pushBackCustomItem(item_model)
	        end
	    else
	    	for i=1,#listView:getItems() do
	    		local item_model = listView:getItem(i-1)
	    		if item_model then
	        		item_model:getWidgetByName("level"):setString(var.mSkillFlagData[i][1].."级")
	    		end
	    	end
	    end
	end
end

function PanelGuild.updateGuildSkillByTag(tag,level)
	local temp_data = var.mGuildSkillData[tag]
	if temp_data then
		local pGuild = NetClient:getGuildByName(var.guild_name)
		local cur_skill = level--var.mSkillFlagData[tag][1]
		local skilllv_job = (game.getRoleJob()-99)*100+cur_skill
		local nextlv = skilllv_job + 1
		if cur_skill == 0 then
			skilllv_job = 1
		end
		if cur_skill == 60 then
			nextlv = 1
		end
		local statu_def = NetClient:getStatusDefByID(temp_data.buffid, skilllv_job)
		if statu_def then
			if tag == 1 then
				var.curPanel:getWidgetByName("label_cur"):setString("+"..statu_def.hpmaxadd)
				var.curPanel:getWidgetByName("cur_info"):setString("生命上限：")
				var.curPanel:getWidgetByName("next_info"):setString("生命上限：")
				local next_statu_def = NetClient:getStatusDefByID(temp_data.buffid, nextlv)
				if next_statu_def then
					var.curPanel:getWidgetByName("label_next"):setString("+"..next_statu_def.hpmaxadd)
				end
			elseif tag == 2 then
				var.curPanel:getWidgetByName("cur_info"):setString("物理防御：")
				var.curPanel:getWidgetByName("next_info"):setString("物理防御：")
				var.curPanel:getWidgetByName("label_cur"):setString("+"..statu_def.mAC.."-"..statu_def.mACmax)
				local next_statu_def = NetClient:getStatusDefByID(temp_data.buffid, nextlv)
				if next_statu_def then
					var.curPanel:getWidgetByName("label_next"):setString("+"..next_statu_def.mAC.."-"..next_statu_def.mACmax)
				end
			elseif tag == 3 then
				var.curPanel:getWidgetByName("cur_info"):setString("魔法防御：")
				var.curPanel:getWidgetByName("next_info"):setString("魔法防御：")
				var.curPanel:getWidgetByName("label_cur"):setString("+"..statu_def.mMAC.."-"..statu_def.mMACmax)
				local next_statu_def = NetClient:getStatusDefByID(temp_data.buffid, nextlv)
				if next_statu_def then
					var.curPanel:getWidgetByName("label_next"):setString("+"..next_statu_def.mMAC.."-"..next_statu_def.mMACmax)
				end
			elseif tag == 4 then
				var.curPanel:getWidgetByName("cur_info"):setString("基础攻击：")
				var.curPanel:getWidgetByName("next_info"):setString("基础攻击：")
				if game.getRoleJob() == 100 then
					var.curPanel:getWidgetByName("label_cur"):setString("+"..statu_def.mDC.."-"..statu_def.mDCmax)
					local next_statu_def = NetClient:getStatusDefByID(temp_data.buffid, nextlv)
					if next_statu_def then
						var.curPanel:getWidgetByName("label_next"):setString("+"..next_statu_def.mDC.."-"..next_statu_def.mDCmax)
					end
				elseif game.getRoleJob() == 101 then
					var.curPanel:getWidgetByName("label_cur"):setString("+"..statu_def.mMC.."-"..statu_def.mMCmax)
					local next_statu_def = NetClient:getStatusDefByID(temp_data.buffid, nextlv)
					if next_statu_def then
						var.curPanel:getWidgetByName("label_next"):setString("+"..next_statu_def.mMC.."-"..next_statu_def.mMCmax)
					end
				elseif game.getRoleJob() == 102 then
					var.curPanel:getWidgetByName("label_cur"):setString("+"..statu_def.mSC.."-"..statu_def.mSCmax)
					local next_statu_def = NetClient:getStatusDefByID(temp_data.buffid, nextlv)
					if next_statu_def then
						var.curPanel:getWidgetByName("label_next"):setString("+"..next_statu_def.mSC.."-"..next_statu_def.mSCmax)
					end
				end
			end
			var.curPanel:getWidgetByName("label_need_level"):setString("Lv."..temp_data.upgrade[tostring(cur_skill)].need_glv)
			var.curPanel:getWidgetByName("label_cur_level"):setString("Lv."..pGuild.mLevelGuild)
			local need_type = temp_data.upgrade[tostring(cur_skill)].mtype
			if need_type == 4 then
				var.curPanel:getWidgetByName("guild_contribute"):setString("绑定金币：")
				var.curPanel:getWidgetByName("label_contribute"):setString(NetClient.mCharacter.mGameMoneyBind)
		        if NetClient.mCharacter.mGameMoneyBind < temp_data.upgrade[tostring(cur_skill)].need_money then
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_RED_1_C3B)
		        else
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_WHITE_1_C3B)
		        end
			else
				var.curPanel:getWidgetByName("guild_contribute"):setString("行会贡献度：")
				var.curPanel:getWidgetByName("label_contribute"):setString(var.mMyGuildCont)
		        if var.mMyGuildCont < temp_data.upgrade[tostring(cur_skill)].need_money then
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_RED_1_C3B)
		        else
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_WHITE_1_C3B)
		        end
			end
			var.curPanel:getWidgetByName("label_need_contribute"):setString("/"..temp_data.upgrade[tostring(cur_skill)].need_money)
		end
	end
	for i=1,4 do
		local skill_temp = var.mSkillFlagData[i]
		local data_temp = var.mGuildSkillData[i]
		if skill_temp and data_temp then
			local attr_label = "0-0"
			local skilllv_job = (game.getRoleJob()-99)*100+skill_temp[1]
			if skill_temp[1] == 0 then
				skilllv_job = 1
			end
			local statu_def = NetClient:getStatusDefByID(data_temp.buffid, skilllv_job)
			if statu_def then
				if i == 1 then
					attr_label = statu_def.hpmaxadd
				elseif i == 2 then
					attr_label = statu_def.mAC.."-"..statu_def.mACmax
				elseif i == 3 then
					attr_label = statu_def.mMAC.."-"..statu_def.mMACmax
				elseif i == 4 then
					if game.getRoleJob() == 100 then
						attr_label = statu_def.mDC.."-"..statu_def.mDCmax
					elseif game.getRoleJob() == 101 then
						attr_label = statu_def.mMC.."-"..statu_def.mMCmax
					elseif game.getRoleJob() == 102 then
						attr_label = statu_def.mSC.."-"..statu_def.mSCmax
					end
				end
			end
			var.curPanel:getWidgetByName("label_all_"..((i-1) > 0 and (i-1) or 4)):setString(attr_label)
		end
	end
end

function PanelGuild.handleGuildAc(event)
	if event and event.type == "guildpanelinfo" then
        local ac_data = json.decode(event.data)
        if not ac_data then return end
        if #ac_data.copyaward > 0 then
        	for i=1,#ac_data.copyaward do
        		local item_bg = var.curPanel:getWidgetByName("mj_icon_"..i)
        		UIItem.getItem({
	                parent = item_bg,
	                typeId = ac_data.copyaward[i].typeid,
	            })
        	end
        end
	elseif event and event.type == "guildgift" then
		local ac_data = json.decode(event.data)
        if not ac_data then return end
        if #ac_data.gifts > 0 then
        	for i=1,#ac_data.gifts do
        		local item_bg = var.curPanel:getWidgetByName("fuli_icon_"..i)
        		UIItem.getItem({
	                parent = item_bg,
	                typeId = ac_data.gifts[i].typeid,
	                num = ac_data.gifts[i].num,
            		bind = ac_data.gifts[i].bindflag
	            })
        	end
        end
	elseif event and event.type == "guildpanelchangeinfo" then
        local ac_data = json.decode(event.data)
        if not ac_data then return end
        local get_btn = var.curPanel:getWidgetByName("Button_get_fl")
        if ac_data.giftflag ~= 0 then
	    	get_btn:setBright(false)
	    	get_btn:setTitleText("已领取")
	    	get_btn:setTouchEnabled(false)
	    	get_btn:setTitleColor(Const.COLOR_GRAY_1_C3B)
	    	get_btn:removeAllChildren()
	    else
            gameEffect.getNormalBtnSelectEffect()
            :setPosition(cc.p(get_btn:getContentSize().width/2,get_btn:getContentSize().height/2))
            :addTo(get_btn)
        end
        if ac_data.openflag == 1 then--尚未开启
        	var.mMijingState = 0
        elseif ac_data.enterflag == 1 then--开启进入
        	var.mMijingState = 1
	    	var.curPanel:getWidgetByName("Button_mj"):setTitleText("进  入")
	    	var.curPanel:getWidgetByName("Button_mj"):setBright(true)
	    	var.curPanel:getWidgetByName("Button_mj"):setTouchEnabled(true)
	    	var.curPanel:getWidgetByName("Button_mj"):setTitleColor(Const.COLOR_YELLOW_2_C3B)
        else
        	var.mMijingState = 2--已结束
	    	var.curPanel:getWidgetByName("Button_mj"):setTitleText("未开启")
	    	var.curPanel:getWidgetByName("Button_mj"):setBright(false)
	    	var.curPanel:getWidgetByName("Button_mj"):setTouchEnabled(false)
	    	var.curPanel:getWidgetByName("Button_mj"):setTitleColor(Const.COLOR_GRAY_1_C3B)
        end
    end
end

function PanelGuild.handleGuildLog(event)
	if event and event.type == "guildrizhi" then
        local log_data = json.decode(event.data)
        if not log_data then return end
        if log_data.len > 0 then
			local listView = var.curPanel:getWidgetByName("list_log")
			if #listView:getItems() <= 0 then
				listView:removeAllItems()
				for i=1,#log_data.data do
					local item_model = var.curPanel:getWidgetByName("model_mem"):clone()
					-- local richLabel, richWidget = util.newRichLabel(cc.size(600, 0), 0)
     --                util.setRichLabel(richLabel, log_data.data[i].desc, "panel_guild_log", 24)
     --                richLabel:setPosition(cc.p(120,richLabel:getRealHeight()+10))
     --                item_model:addChild(richWidget)
					item_model:getWidgetByName("label_log_info"):setString(game.clearHtmlText(log_data.data[i].desc))
                    item_model:getWidgetByName("label_log_time"):setString(os.date("%Y-%m-%d %H:%M:%S",log_data.data[i].t))
					if i%2 == 0 then
						item_model:getWidgetByName("Image_frame"):loadTexture("touming.png",UI_TEX_TYPE_PLIST)
					end
					listView:pushBackCustomItem(item_model)
				end
			end
		end
    end
end

function PanelGuild.handleGuildLevel(event)
	if event and event.type == "guildpanelinfo" then
        local ac_data = json.decode(event.data)
        if not ac_data then return end
        var.mGuildLevelData = ac_data
        local pGuild = NetClient:getGuildByName(var.guild_name)
        if pGuild then
        	local guildlevel = pGuild.mLevelGuild
        	if pGuild.mLevelGuild ~= ac_data.guildlv then
        		pGuild.mLevelGuild = ac_data.guildlv
        		guildlevel = pGuild.mLevelGuild
        	end
        	var.curPanel:getWidgetByName("label_curguild_level"):setString("当前行会等级："..guildlevel)
        	var.curPanel:getWidgetByName("label_level_cur"):setString(guildlevel.."级行会")

        	local statu_def = NetClient:getStatusDefByID(ac_data.buffid,guildlevel)
        	if statu_def then
        		var.curPanel:getWidgetByName("label_cur_1"):setString(statu_def.mDC.."-"..statu_def.mDCmax)
        		var.curPanel:getWidgetByName("label_cur_2"):setString(statu_def.mMC.."-"..statu_def.mMCmax)
        		var.curPanel:getWidgetByName("label_cur_3"):setString(statu_def.mSC.."-"..statu_def.mSCmax)
        		var.curPanel:getWidgetByName("label_cur_4"):setString(string.format("%.1f",statu_def.mHPmax/100).."%")
        	end
        	var.curPanel:getWidgetByName("label_contribute"):setString(ac_data.guild_exp)
        	if guildlevel < 15 then
        		local next_level = guildlevel + 1
        		var.curPanel:getWidgetByName("label_level_next"):setString(next_level.."级行会")
        		local next_def = NetClient:getStatusDefByID(ac_data.buffid,next_level)
        		if next_def then
	        		var.curPanel:getWidgetByName("label_next_1"):setString(next_def.mDC.."-"..next_def.mDCmax)
	        		var.curPanel:getWidgetByName("label_next_2"):setString(next_def.mMC.."-"..next_def.mMCmax)
	        		var.curPanel:getWidgetByName("label_next_3"):setString(next_def.mSC.."-"..next_def.mSCmax)
	        		var.curPanel:getWidgetByName("label_next_4"):setString(string.format("%.1f",next_def.mHPmax/100).."%")
        		end
        		if #ac_data.level_list > 0 and ac_data.level_list[next_level] then
        			var.curPanel:getWidgetByName("label_need_contribute"):setString("/"..ac_data.level_list[next_level].exp)
        		end
        		if ac_data.guild_exp < ac_data.level_list[next_level].exp then
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_RED_1_C3B)
		        else
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_WHITE_1_C3B)
        		end
        	else
        		var.curPanel:getWidgetByName("label_level_next"):setString("已满级")
        		var.curPanel:getWidgetByName("label_need_contribute"):setString("/0")
        		var.curPanel:getWidgetByName("Button_level"):setBright(false)
        		var.curPanel:getWidgetByName("Button_level"):setTouchEnabled(false)
        		var.curPanel:getWidgetByName("Button_level"):setTitleColor(Const.COLOR_GRAY_1_C3B)
        	end
        end
	elseif event and event.type == "query_guild_contribute" then
        local depot_data = json.decode(event.data)
        if not depot_data then return end
        var.curPanel:getWidgetByName("label_contribute"):setString(depot_data.guild_exp)
        local pGuild = NetClient:getGuildByName(var.guild_name)
        if pGuild then
        	local guildlevel = pGuild.mLevelGuild
        	if guildlevel < 15 and var.mGuildLevelData then
        		local next_level = guildlevel + 1
        		if tonumber(depot_data.guild_exp) < var.mGuildLevelData.level_list[next_level].exp then
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_RED_1_C3B)
		        else
		        	var.curPanel:getWidgetByName("label_contribute"):setColor(Const.COLOR_WHITE_1_C3B)
        		end
        	end
        end
    end
end

function PanelGuild.updateRLListView()
	if var.selectTab == 2 and var.mRongLian then
		local allExp = 0
		for k, v in pairs(var.storePageView:getItems()) do
	        NetClient:dispatchEvent(
	            {
	                name = Notify.EVENT_ITEM_SELECT,
	                pos = v.pos,
	                visible = false
	            })
	    end
	    var.huishouListView:removeAllItems()
	    if #var.recycle_tem_tab == 0 then
	    	var.curPanel:getWidgetByName("num_exp"):setString("0")
	        return
	    end
	    UIGridView.new({
	        list = var.huishouListView,
	        gridCount = #var.recycle_tem_tab,
	        cellSize = cc.size(410, 80),
	        columns = 5,
	        initGridListener = function(gridWidget, index)
	            local itemBg = var.curPanel:getWidgetByName("item_bg"):clone():show()
	            itemBg:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
	            :addTo(gridWidget)
	            local pos = var.recycle_tem_tab[index].pos
	            itemBg:getWidgetByName("lock_flag"):hide()
	            itemBg.index = index
	            itemBg.pos = pos
	            UIItem.getItem({
	                parent = itemBg,
	                pos = pos,
	                itemCallBack = function(pSender)
	                    table.remove(var.recycle_tem_tab, pSender.index)
	                    NetClient:dispatchEvent(
                        {
                            name = Notify.EVENT_ITEM_SELECT,
                            pos = pSender.pos,
                            visible = false
                        })
	                    PanelGuild.updateRLListView()
	                end
	            })

	            NetClient:dispatchEvent(
                {
                    name = Notify.EVENT_ITEM_SELECT,
                    pos = pos,
                    visible = true
                })
                local netItem = NetClient:getGuildDepotItem(pos)
	            if netItem then
	                local itemdef = NetClient:getItemDefByID(netItem.mTypeID)
	                if itemdef then
	                	allExp = allExp + itemdef.mGongxian
	                end
	            end
	        end
	    })
	    var.curPanel:getWidgetByName("num_exp"):setString(allExp)
	end
end

function PanelGuild.onRLSetting()
	local needinfo = {}
    for k, v in ipairs(var.huishouTijian) do
    	if not game.SETTING_TABLE[guild_rl_set[k]] then game.SETTING_TABLE[guild_rl_set[k]] = 1 end
    	local tjconfig = HUISHOU_SETTING[k][game.SETTING_TABLE[guild_rl_set[k]]]
    	if tjconfig.lv then
            needinfo.lv = tjconfig.lv
        end

        if tjconfig.zslv then
            needinfo.zslv = tjconfig.zslv
        end

        if tjconfig.job then
            needinfo.job = tjconfig.job
        end

        if tjconfig.color then
            needinfo.color = tjconfig.color
        end

        if tjconfig.sex then
            needinfo.sex = tjconfig.sex
        end

        v:getWidgetByName("Text_name"):setString(tjconfig.text)
        v:setTouchEnabled(true)
        v.index = k
        if k ~= 3 then
	        v:addClickEventListener(function(pSender)
	            var.huishouTijianPanel[pSender.index]:show()
	        end)
	    else
	    	v:setTouchEnabled(false)
	    end
        v:show()
    end
    var.recycle_tem_tab = {}
    for k, v in pairs(var.storePageView:getItems()) do
        local item = NetClient:getGuildDepotItem(v.pos)
        if item then
            local itemdef = NetClient:getItemDefByID(item.mTypeID)
            if PanelGuild.checkRecycleCfg(netItem, itemdef, needinfo) then
                table.insert( var.recycle_tem_tab,{pos=v.pos} )
                NetClient:dispatchEvent(
                    {
                        name = Notify.EVENT_ITEM_SELECT,
                        pos = v.pos,
                        visible = true
                    })
            end
        end
    end
    PanelGuild.updateRLListView()
end

function PanelGuild.checkRecycleCfg(netItem, itemdef, needinfo)
    if not needinfo then return true end

    local itemlv = 0
    if itemdef.mNeedType == 0 then itemlv = itemdef.mNeedParam end
    local itemzslv = 0
    if itemdef.mNeedType == 4 then itemzslv = itemdef.mNeedParam end

    if needinfo.lv and itemlv  > needinfo.lv then
        return false
    end
    if needinfo.lv and not needinfo.zslv and itemzslv > 0 then
    	return false
    end
    if needinfo.zslv and itemzslv > needinfo.zslv then
        return false
    end
    if needinfo.sex  and needinfo.sex ~= 0 and itemdef.mSex ~= needinfo.sex then
        return false
    end
    if needinfo.job  and needinfo.job ~= 0 and itemdef.mJob ~= needinfo.job then
        return false
    end
    if needinfo.color and itemdef.mColor and itemdef.mColor ~= 0 then
        local checkcolor = false
        if Const.Item_Def_color[needinfo.color] then
            for i = needinfo.color, 1, -1 do
                for _, vcolor in ipairs(Const.Item_Def_color[i].colors) do
                    if vcolor == itemdef.mColor then
                        checkcolor = true
                        break
                    end
                end
                if checkcolor then break end
            end
        end
        if not checkcolor then
            return false
        end
    end

    return true
end

function PanelGuild.initRongLianPanel()
	if var.selectTab == 2 and var.mRongLian then
		var.huishouTijian = {}
	    var.huishouTijian[1] = var.curPanel:getWidgetByName("Image_lv"):hide()
	    var.huishouTijian[2] = var.curPanel:getWidgetByName("Image_job"):hide()
	    var.huishouTijian[3] = var.curPanel:getWidgetByName("Image_color"):setTouchEnabled(false):hide()
	    var.huishouTijian[4] = var.curPanel:getWidgetByName("Image_sex"):hide()
		var.curPanel:getWidgetByName("num_exp"):setString("0")
	    var.curPanel:getWidgetByName("Button_rl"):addClickEventListener(function (pSender)
			NetClient:PushLuaTable("newgui.guilddepot.onGetJsonData",util.encode({actionid = "recycle_guild_item",items = var.recycle_tem_tab}))
	    end)
	    var.curPanel:getWidgetByName("Button_clear"):addClickEventListener(function (pSender)
	    	var.recycle_tem_tab = {}
			PanelGuild.updateRLListView()
	    end)
	    for k, v in ipairs(var.huishouTijianPanel) do
	        v.index = k
	        local copybtn = v:getWidgetByName("Button_item"):hide()

	        local hs = HUISHOU_SETTING[k]
	        local py = copybtn:getPositionY()
	        for i = 1, #hs do
	            local btn = copybtn:clone():show()
	            btn:setTitleText(hs[i].text)
	            btn.index = i
	            btn.typeindex = k
	            btn:setPositionY(py)
	            btn:addClickEventListener(function (pSender)
	                game.SETTING_TABLE[guild_rl_set[pSender.typeindex]]=pSender.index
	                PanelGuild.onRLSetting()
	                pSender:getParent():hide()
	            end)
	            btn:addTo(v)
	            py = py + 40
	        end

	        v:addClickEventListener(function (pSender)
	            pSender:hide()
	        --            var.huishouTijian[pSender.index]:getWidgetByName("Text_name"):show()
	        end)
	    end
	end
end

function PanelGuild.showContribure()
	var.mPanelDonate:show()
end

function PanelGuild.updateDonateByTag(tag)
	var.mCurDonateIdx = tag
	local num = EXCHANGE_DEGREE_LIST[var.mCurShowExchange][tag]
	if num and num > 0 then
		var.mPanelDonate:getWidgetByName("label_gold_num"):setString(num)
		local exp_cal = num
		local con_cal = num
		if var.mCurShowExchange == 1 then
			con_cal = math.floor(num/MIN_DONATE_GOLD*EXCHANGE_DEGREE_GLOD)
			num_cal = math.floor(num/MIN_DONATE_GOLD*EXCHANGE_GUILDEXP_GLOD)
		else
			con_cal = math.floor(num/MIN_DONATE_VCOIN*EXCHANGE_DEGREE_VCOIN)
			num_cal =math.floor(num/MIN_DONATE_VCOIN*EXCHANGE_GUILDEXP_VCOIN)
		end
		var.mPanelDonate:getWidgetByName("label_guild_exp"):setString(num_cal)
		var.mPanelDonate:getWidgetByName("label_self_contribute"):setString(con_cal)
	end
end

function PanelGuild.updateGuildMemOperate()
	if var.mLastSelectName ~= "" and var.mLastSelectTitle ~= 0 then
		var.curPanel:getWidgetByName("Panel_mem_operate"):show()
		var.curPanel:getWidgetByName("Panel_mem_operate"):getWidgetByName("label_select_name"):setString(var.mLastSelectName)
		for i=1,3 do
				var.curPanel:getWidgetByName("Button_backup_"..i):hide()
			end
		if var.guild_title <= Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then--长老以下
			for i=1,3 do
				var.curPanel:getWidgetByName("Button_backup_"..i):hide()
			end
		elseif var.guild_title == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then--副会长
			if var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADMIN then
				for i=1,3 do
					var.curPanel:getWidgetByName("Button_backup_"..i):hide()
				end
			elseif var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
				--撤销长老以及踢出行会
				var.curPanel:getWidgetByName("Button_backup_1"):show():setTitleText("撤销长老")
				var.curPanel:getWidgetByName("Button_backup_2"):show():setTitleText("踢出行会")
				var.curPanel:getWidgetByName("Button_backup_3"):hide()
			else
				--任命长老以及踢出行会
				var.curPanel:getWidgetByName("Button_backup_1"):show():setTitleText("任命长老")
				var.curPanel:getWidgetByName("Button_backup_2"):show():setTitleText("踢出行会")
				var.curPanel:getWidgetByName("Button_backup_3"):hide()
			end
		elseif var.guild_title == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADMIN then--会长
			if var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_ADV then
				--任命长老、撤销副会以及踢出行会
				var.curPanel:getWidgetByName("Button_backup_1"):show():setTitleText("任命长老")
				var.curPanel:getWidgetByName("Button_backup_2"):show():setTitleText("撤销副会")
				var.curPanel:getWidgetByName("Button_backup_3"):show():setTitleText("踢出行会")
			elseif var.mLastSelectTitle == Const.GUILD_TITLE_TYPE.GUILD_TITLE_TYPE_LEADER then
				--撤销长老、任命副会以及踢出行会
				var.curPanel:getWidgetByName("Button_backup_1"):show():setTitleText("撤销长老")
				var.curPanel:getWidgetByName("Button_backup_2"):show():setTitleText("任命副会")
				var.curPanel:getWidgetByName("Button_backup_3"):show():setTitleText("踢出行会")
			else
				--任命长老、任命副会以及踢出行会
				var.curPanel:getWidgetByName("Button_backup_1"):show():setTitleText("任命长老")
				var.curPanel:getWidgetByName("Button_backup_2"):show():setTitleText("任命副会")
				var.curPanel:getWidgetByName("Button_backup_3"):show():setTitleText("踢出行会")
			end
		end
	end
end

return PanelGuild