--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/12/14 17:34
-- To change this template use File | Settings | File Templates.
--

local PanelFumo = {}
local var = {}
local xmf_num = {2,5,12}
local xmf_btn_name = {"单倍领取","双倍领取","四倍领取"}

function PanelFumo.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/challenge/UI_Fumo_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_fumo")
    var.panelExtend = params.extend.mParam or ""
    var.rightBtnTab = {}
    for i=1,4 do
    	var.rightBtnTab[i] = var.widget:getWidgetByName("Button_reward_"..i)
    	if i > 1 then
    		var.rightBtnTab[i]:hide()
			var.widget:getWidgetByName("Label_reward_info"..i):hide()
    	end
    end
    
    var.upLabel = var.widget:getWidgetByName("Label_explain10")
    var.downLabel = var.widget:getWidgetByName("Label_explain11")
    if var.panelExtend == "richang" then
    	var.widget:getWidgetByName("Label_Title"):setString("日常任务")
	    NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "openPanel"}))
	elseif var.panelExtend == "richangjy" then
    	var.widget:getWidgetByName("Label_Title"):setString("剿灭精英")
	    NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "openPanel"}))
    elseif var.panelExtend == "richangxm" then
    	var.widget:getWidgetByName("Label_Title"):setString("降魔任务")
    	var.rightBtnTab[1]:show():setTitleText("立即前往")
    	for i=2,4 do
			var.widget:getWidgetByName("Label_reward_info"..i):show():setString("上交降魔符*"..xmf_num[i-1])
			var.rightBtnTab[i]:show():setTitleText(xmf_btn_name[i-1])
	    end
	    NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "openPanel"}))
    elseif var.panelExtend == "caikuang" then
	    NetClient:PushLuaTable("npc.richang3.onGetJsonData",util.encode({actionid = "openPanel"}))
	end

    PanelFumo.registeEvent()

    return var.widget
end

function PanelFumo.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    	:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelFumo.handlePanelData)
end

function PanelFumo.handlePanelData(event)
	if event and event.type == "richang_data" then
		local fumo_data = json.decode(event.data)
		if not fumo_data then return end
		for i=1,4 do
			var.widget:getWidgetByName("ImageView_RewardItem"..i):removeAllChildren()
			if i <= #fumo_data.award then
				UIItem.getItem({
	                parent = var.widget:getWidgetByName("ImageView_RewardItem"..i),
	                typeId = fumo_data.award[i].id,
	                num = fumo_data.award[i].num,
	                itemCallBack = function () end,
	            })
			else
				var.widget:getWidgetByName("ImageView_RewardItem"..i):hide()
			end
		end

		-- var.widget:getWidgetByName("Label_explain7"):setString(fumo_data.honor.."点")
		var.widget:getWidgetByName("Label_explain9"):setString(fumo_data.name)
		var.upLabel:setString("您今天还可接领"..fumo_data.can_use_count.."次任务")
		var.downLabel:setString("(可用元宝额外接领"..fumo_data.can_buy_count.."次)")
		if fumo_data.type == 2 or fumo_data.type == 1 then
			for i=1,4 do
				if i == 1 then
			    	var.rightBtnTab[i]:show():setTitleText("接受任务"):addClickEventListener(function (pSender)
			    		if fumo_data.can_use_count > 0 then
							NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "task_accept"}))
							EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_fumo"})
		    			elseif fumo_data.can_buy_count > 0 then
			                local param = {
			                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "购买额外任务次数需要花费"..fumo_data.buy_count_yuanbao.."元宝",
			                    confirmTitle = "购 买", cancelTitle = "取 消",
			                    confirmCallBack = function ()
			                        -- 购买斩妖令
									NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "buy_once"}))
	    							NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "openPanel"}))
			                    end
			                }
			                NetClient:dispatchEvent(param)
			            end
			    	end)
		    	else
		    		var.rightBtnTab[i]:hide()
	    			var.widget:getWidgetByName("Label_reward_info"..i):hide()
		    	end
		    end
		elseif fumo_data.type == 3 then
	    	var.widget:getWidgetByName("Button_reward_1"):setTitleText("立即前往"):addClickEventListener(function (pSender)
				NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "task_go"}))
				EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_fumo"})
	    	end)
			for i=1,4 do
		    	if i > 1 then
		    		var.rightBtnTab[i]:hide()
		    		var.widget:getWidgetByName("Label_reward_info"..i):hide()
		    	end
		    end
		elseif fumo_data.type == 4 then
			for i=1,4 do
				if i == 1 then
			    	var.rightBtnTab[i]:setTitleText("完成任务")
			    elseif i < 4 then
		    		var.widget:getWidgetByName("Label_reward_info"..i):show()
			    end
			    if i < 4 then
				    var.rightBtnTab[i]:show():addClickEventListener(function (pSender)
						NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "task_done"..i}))
	    				NetClient:PushLuaTable("npc.richang.onGetJsonData",util.encode({actionid = "openPanel"}))
			    	end)
				end
		    end
		end
	elseif event and event.type == "richangjy_data" then
		local fumo_data = json.decode(event.data)
		if not fumo_data then return end
		for i=1,4 do
			var.widget:getWidgetByName("ImageView_RewardItem"..i):removeAllChildren()
			if i <= #fumo_data.award then
				UIItem.getItem({
	                parent = var.widget:getWidgetByName("ImageView_RewardItem"..i),
	                typeId = fumo_data.award[i].id,
	                num = fumo_data.award[i].num,
	                itemCallBack = function () end,
	            })
			else
				var.widget:getWidgetByName("ImageView_RewardItem"..i):hide()
			end
		end
		var.widget:getWidgetByName("Label_explain9"):setString(fumo_data.name)
		var.upLabel:setString("您今天还可接领"..fumo_data.can_use_count.."次任务")
		var.downLabel:setString("(可用元宝额外接领"..fumo_data.can_buy_count.."次)(会员功能)")
		if fumo_data.type == 2 or fumo_data.type == 1 then
			var.widget:getWidgetByName("Button_reward_1"):setTitleText("接受任务"):addClickEventListener(function (pSender)
	    		if fumo_data.can_use_count > 0 then
					NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "task_accept"}))
					EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_fumo"})
    			elseif fumo_data.can_buy_count > 0 then
	                local param = {
	                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "购买额外任务次数需要花费"..fumo_data.buy_count_yuanbao.."元宝",
	                    confirmTitle = "购 买", cancelTitle = "取 消",
	                    confirmCallBack = function ()
	                        -- 购买斩妖令
							NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "buy_once"}))
							NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "openPanel"}))
	                    end
	                }
	                NetClient:dispatchEvent(param)
	            end
	    	end)
		elseif fumo_data.type == 3 then
	    	var.widget:getWidgetByName("Button_reward_1"):setTitleText("立即前往"):addClickEventListener(function (pSender)
				NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "task_go"}))
				EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_fumo"})
	    	end)
		elseif fumo_data.type == 4 then
	    	var.widget:getWidgetByName("Button_reward_1"):setTitleText("完成任务"):addClickEventListener(function (pSender)
				NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "task_done"}))
				NetClient:PushLuaTable("npc.jingyingRC.onGetJsonData",util.encode({actionid = "openPanel"}))
	    	end)
		end
	elseif event and event.type == "richangxm_data" then
		local fumo_data = json.decode(event.data)
		if not fumo_data then return end
		for i=1,4 do
			var.widget:getWidgetByName("ImageView_RewardItem"..i):removeAllChildren()
			if i <= #fumo_data.award then
				UIItem.getItem({
	                parent = var.widget:getWidgetByName("ImageView_RewardItem"..i),
	                name = fumo_data.award[i].name,
	                num = fumo_data.award[i].num,
	                itemCallBack = function () end,
	            })
			else
				var.widget:getWidgetByName("ImageView_RewardItem"..i):hide()
			end
		end
		var.widget:getWidgetByName("Label_explain9"):setString(fumo_data.name)
		var.upLabel:setString("您今天还可接领"..fumo_data.can_use_count.."次任务")
		var.widget:getWidgetByName("Label_explain6"):setString("当前拥有降魔符:")
		var.widget:getWidgetByName("Label_explain7"):setString(fumo_data.have_num.."个")
		for i=2,4 do
			local need_num = fumo_data.need_tab[i-1]
			if not need_num then need_num = 0 end
			var.widget:getWidgetByName("Label_reward_info"..i):show():setString("上交降魔符*"..need_num)
	    end
		var.downLabel:hide()
		var.rightBtnTab[1]:addClickEventListener(function (pSender)
			NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "task_go"}))
			EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_fumo"})
    	end)
    	for i=2,4 do
			var.rightBtnTab[i]:addClickEventListener(function (pSender)
				NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "task_done"..i}))
				NetClient:PushLuaTable("npc.xiangmodian.onGetJsonData",util.encode({actionid = "openPanel"}))
	    	end)
	    end
    elseif event and event.type == "caikuang_data" then
    	local fumo_data = json.decode(event.data)
		if not fumo_data then return end
		for i=1,4 do
			var.widget:getWidgetByName("ImageView_RewardItem"..i):removeAllChildren()
			if i <= #fumo_data.award then
				UIItem.getItem({
	                parent = var.widget:getWidgetByName("ImageView_RewardItem"..i),
	                name = fumo_data.award[i].name,
	                num = fumo_data.award[i].num,
	                itemCallBack = function () end,
	            })
			else
				var.widget:getWidgetByName("ImageView_RewardItem"..i):hide()
			end
		end
		var.widget:getWidgetByName("Label_explain9"):setString(fumo_data.desc)
		var.upLabel:setString("您今天还可接领"..fumo_data.left_count.."次采集矿石")
		var.downLabel:hide()
		local btn_command = {{"接受任务","task_accept"},{"接受任务","task_accept"},{"立即前往","task_go"},{"完成任务","task_done"},}
		for i=1,4 do
			if i == 1 then
		    	var.rightBtnTab[i]:show():setTitleText(btn_command[fumo_data.type][1]):addClickEventListener(function (pSender)
					NetClient:PushLuaTable("npc.richang3.onGetJsonData",util.encode({actionid = btn_command[fumo_data.type][2]}))
					EventDispatcher:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL, str = "panel_fumo"})
		    	end)
	    	else
	    		var.rightBtnTab[i]:hide()
    			var.widget:getWidgetByName("Label_reward_info"..i):hide()
	    	end
	    end
	end
end

return PanelFumo