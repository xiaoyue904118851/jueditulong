local PanelFuben = {}
local var = {}
local fuben_bg_tab = {"huanchongdongku.png","womasimiao.png","shimuzhudong.png","zumasimiao.png","niumodongku.png","chiyuemoku.png","huyaodongxue.png"}

function PanelFuben.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelFuben/PanelFuben.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_fuben")
    var.list_model = var.widget:getWidgetByName("fuben_model")
    var.listView = var.widget:getWidgetByName("ListFubenView")
    var.saodangResultPanel = var.widget:getWidgetByName("Panel_saodang_result"):hide()
    var.awardClone = var.saodangResultPanel:getWidgetByName("itembg"):hide()
    var.selectFuben = 1
    var.fuben_data = {}
    var.panelExtend = params.extend.mParam or ""
    if var.panelExtend == "personal" then
	    NetClient:PushLuaTable("newgui.fuben.onGetFubenData",util.encode({actionid = "openPanel"}))
	end

	var.widget:getWidgetByName("Button_go"):addClickEventListener(function (pSender)
        PanelFuben.onStartGo(pSender)
	end)
    var.widget:getWidgetByName("Button_saodang"):addClickEventListener(function (pSender)
        PanelFuben.onSaodang(pSender)
    end)
    var.widget:getWidgetByName("Button_buy_jz"):addClickEventListener(function (pSender)
        if var.subtype then  game.queryQuickBuyInfo(var.subtype) end
    end)
    var.widget:getWidgetByName("Button_close_fb"):addClickEventListener(function (pSender)
        for i=1,#var.listView:getItems() do
            local item_mod = var.listView:getItem(i-1)
            if item_mod then
                item_mod:getWidgetByName("fuben_bg"):getVirtualRenderer():setState(0)
                item_mod:getWidgetByName("fuben_img"):getVirtualRenderer():setState(0)
            end
        end
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_fuben"})
    end)
    var.saodangResultPanel:addClickEventListener(function (pSender)
        pSender:hide()
    end)
    var.saodangResultPanel:getWidgetByName("Button_closes"):addClickEventListener(function (pSender)
        var.saodangResultPanel:hide()
    end)
    PanelFuben.registeEvent()

    return var.widget
end

function PanelFuben.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    	:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelFuben.handlePanelData)
    	:addEventListener(Notify.EVENT_ITEM_CHANGE, PanelFuben.handleItemChange)
end

function PanelFuben.handleItemChange()
    local lpnum = NetClient:getBagItemNumberById(var.fuben_data[var.selectFuben].enter_need_item_id)
    var.widget:getWidgetByName("label_need_num"):setString(lpnum.."/"..var.fuben_data[var.selectFuben].enter_need_item_num)

end

function PanelFuben.handlePanelData(event)
    if not event or not event.type then return end
    local d = json.decode(event.data)
	if event.type == "sigle_fuben_data" then
		var.fuben_data = d.subdata
		var.subtype = d.subType
		if not var.fuben_data then return end
        local mLevel = game.getRoleLevel()
		var.listView:removeAllItems()
        local selectIndex = nil
		for i=1,#var.fuben_data do
			local model = var.list_model:clone()
			local sigle_data = var.fuben_data[i]
			model:getWidgetByName("fuben_name"):setString(sigle_data.name)
			model:getWidgetByName("fuben_type"):setString(sigle_data.type)
			model:getWidgetByName("fuben_high"):hide()

			model:getWidgetByName("fuben_img"):loadTexture(fuben_bg_tab[i],UI_TEX_TYPE_PLIST)
			if mLevel < sigle_data.level then
				model:getWidgetByName("fuben_condition"):show():setString(sigle_data.level.."级\n开启")
				model:getWidgetByName("spr_lock"):show()
				model:getWidgetByName("fuben_bg"):getVirtualRenderer():setState(1)
				model:getWidgetByName("fuben_img"):getVirtualRenderer():setState(1)
				model:getWidgetByName("fuben_name"):setTextColor(cc.c3b(178,178,178))
				model:getWidgetByName("fuben_type"):setTextColor(cc.c3b(178,178,178))
                model:getWidgetByName("Image_tongguan"):hide()
			else
				model:getWidgetByName("fuben_condition"):hide()
                model:getWidgetByName("Image_tongguan"):setVisible(sigle_data.curnum == 0)
				model:getWidgetByName("spr_lock"):hide()
				model:getWidgetByName("fuben_bg"):getVirtualRenderer():setState(0)
				model:getWidgetByName("fuben_img"):getVirtualRenderer():setState(0)
				model:getWidgetByName("fuben_name"):setTextColor(cc.c3b(255,172,8))
				model:getWidgetByName("fuben_type"):setTextColor(cc.c3b(212,192,139))
			end
			model:getWidgetByName("fuben_bg"):addClickEventListener(function (pSender)
				if mLevel >= sigle_data.level then
					PanelFuben.selectFubenByTag(i)
				end
			end)
            if mLevel >= sigle_data.level and sigle_data.curnum > 0 and not selectIndex then
                selectIndex = i
            end
			var.listView:pushBackCustomItem(model)
        end
        if selectIndex then var.selectFuben = selectIndex end
		PanelFuben.selectFubenByTag(var.selectFuben)
		--[[
	elseif event and event.type == "ybquickbuy" then
		local infodata = json.decode(event.data)
		local neednum = var.fuben_data[var.selectFuben].enter_need_item_num
		local hasnum = var.fuben_data[var.selectFuben].has_enter_item_num
		local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "是否使用"..infodata.sellyb.."*"..(neednum-hasnum).."绑定元宝购买副本卷轴",
            confirmTitle = "确 定", cancelTitle = "取 消",
            confirmCallBack = function ()
                var.buyitemType = true
                NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({
                actionid = "quickbuy",
                typeid=infodata.typeid,
                subtype=infodata.subtype,
                num=neednum-hasnum,
                buytype=infodata.buytype
                }))
                end
            }
        NetClient:dispatchEvent(param)
    elseif event and event.type == "quickbuyjuanzhouopen" then
    	NetClient:PushLuaTable("newgui.fuben.onGetFubenData",util.encode({actionid = var.cmd}))
    	]]
	elseif event.type == "sigle_fuben_saodang" then
        PanelFuben.showSaodangResult(d)
    end
end

function PanelFuben.selectFubenByTag(tag)
    local addGuild = false
	var.selectFuben = tag
	for i=1,#var.fuben_data do
		local mItem = var.listView:getItem(i-1)
		if mItem then
			mItem:getWidgetByName("fuben_high"):hide()
		end
	end
	local curSelet = var.listView:getItem(tag-1)
	if curSelet then
		curSelet:getWidgetByName("fuben_high"):show()
		local fuben_data = var.fuben_data[tag]
		if fuben_data then
			for j=1,2 do
				var.widget:getWidgetByName("item_icon_"..j):removeAllChildren()
				UIItem.getSimpleItem({
	                parent = var.widget:getWidgetByName("item_icon_"..j),
	                name = fuben_data.award[j].name,
                    num = fuben_data.award[j].num,
	                itemCallBack = function () end,
	            })
            end
			var.widget:getWidgetByName("label_left_time"):setString(fuben_data.curnum)
            local lpnum = NetClient:getBagItemNumberById(fuben_data.enter_need_item_id)
			var.widget:getWidgetByName("label_need_num"):setString(lpnum.."/"..fuben_data.enter_need_item_num)

            if fuben_data.curnum > 0 then
                UIButtonGuide.setFubenGuide()
            end
		end
    end
    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.EXPFUBENTASK) then
        UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_go"),"点击此处进入副本",UIButtonGuide.UI_TYPE_LEFT)
    else
        UIButtonGuide.handleButtonGuideClicked(var.widget:getWidgetByName("Button_go"))
    end

--    VIP 增加副本进入次数
    local opened,lv = game.checkVipOpened("fubencishu")
    if not opened then
        var.widget:getWidgetByName("label_vip_jinru_num"):setString(string.format("VIP%d",lv))
        var.widget:getWidgetByName("label_vip_jinru_tips"):setString("可增加副本挑战次数")
        var.widget:getWidgetByName("label_vip_jinru_tips"):setPositionX(var.widget:getWidgetByName("label_vip_jinru_num"):getPositionX()+var.widget:getWidgetByName("label_vip_jinru_num"):getContentSize().width)
    else
        var.widget:getWidgetByName("label_vip_jinru_tips"):hide()
        var.widget:getWidgetByName("label_vip_jinru_num"):hide()
    end

    PanelFuben.updateSaodangBtn()
end

function PanelFuben.onStartGo(pSender)
    if not game.checkBtnClick() then return end
    if var.fuben_data and var.fuben_data[var.selectFuben] then
        UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.EXPFUBENTASK})
        local cmd = var.fuben_data[var.selectFuben].cmd
        var.cmd = cmd
        local neednum = var.fuben_data[var.selectFuben].enter_need_item_num
        local hasnum = NetClient:getBagItemNumberById(var.fuben_data[var.selectFuben].enter_need_item_id)
        local lefttimes = var.fuben_data[var.selectFuben].curnum

        if lefttimes == 0 then
            local opened,lv = game.checkVipOpened("fubencishu")
            if not opened then
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = "成为VIP"..lv.."可增加进入次数",
                    confirmTitle = "充 值", cancelTitle = "取 消",
                    confirmCallBack = function ()
                        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_charge"})
                    end
                }
                NetClient:dispatchEvent(param)
            else
                NetClient:alertLocalMsg("今日挑战次数已用完","alert")
            end
            return
        end

        if hasnum < neednum then
            game.queryQuickBuyInfo(var.subtype)
        else
            NetClient:PushLuaTable("newgui.fuben.onGetFubenData",util.encode({actionid = cmd}))
        end
    end

end

function PanelFuben.updateSaodangBtn()
    if not var.fuben_data or not var.fuben_data[var.selectFuben] then return end
    local lefttimes = var.fuben_data[var.selectFuben].curnum
    local opened,lv = game.checkVipOpened("fubensaodang")
    local enabled = false
    if opened and lefttimes > 0 then
        enabled = true
    end
    var.widget:getWidgetByName("Button_saodang"):setTouchEnabled(enabled)
    var.widget:getWidgetByName("Button_saodang"):setBright(enabled)


    if not opened then
        var.widget:getWidgetByName("label_saodang_num"):setString(string.format("VIP%d",lv))
        var.widget:getWidgetByName("label_saodang_tips"):setString("可解锁此功能")
        var.widget:getWidgetByName("label_saodang_tips"):setPositionX(var.widget:getWidgetByName("label_saodang_num"):getPositionX()+var.widget:getWidgetByName("label_saodang_num"):getContentSize().width)
    else
        var.widget:getWidgetByName("label_saodang_tips"):hide()
        var.widget:getWidgetByName("label_saodang_num"):hide()
    end
end

function PanelFuben.onSaodang(pSender)
    if not var.fuben_data or not var.fuben_data[var.selectFuben] then return end
    if not game.checkBtnClick() then return end
    NetClient:PushLuaTable("newgui.fuben.onGetFubenData",util.encode({actionid = "quickfinish", param = var.selectFuben}))
end

function PanelFuben.showSaodangResult(awards)
    local listview = var.saodangResultPanel:getWidgetByName("ListView_sd")
    listview:removeAllItems()
    UIGridView.new({
        parent = var.saodangResultPanel,
        list = listview,
        gridCount = #awards,
        cellSize = cc.size(listview:getContentSize().width,var.awardClone:getContentSize().height+5),
        columns = 4,
        async = true,
        initGridListener = function(gridWidget, k)
            local nodeItem = var.awardClone:clone():show()
            :align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
            :addTo(gridWidget)
            UIItem.getSimpleItem({
                parent = nodeItem,
                typeId = awards[k].typeid,
                num = awards[k].num,
                name = awards[k].name,
                itemCallBack = function () end,
            })
        end,
    })

    var.saodangResultPanel:show()
end

function PanelFuben.onPanelClose()
    if var.saodangResultPanel:isVisible() then
        var.saodangResultPanel:hide()
        return false
    end
    UIButtonGuide.setGuideEnd(UIButtonGuide.GUILDTYPE.EXPFUBENTASK)
    return true
end

return PanelFuben