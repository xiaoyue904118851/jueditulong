local PanelShenQi = {}
local var = {}

function PanelShenQi.initView(params)
    local params = params or {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelShenQi/PanelShenQi.csb")
    widget:addTo(params.parent, params.zorder)

    var.widget = widget:getChildByName("Panel_shenqi")
    var.selectLTab = 1
    var.selectRTab = game.getRoleJob()-99
    var.selectMTab = 1
	var.mWeaponData = {[Const.JOB_ZS] = {},[Const.JOB_FS] = {},[Const.JOB_DS] = {}}
	var.mClothDataM = {[Const.JOB_ZS] = {},[Const.JOB_FS] = {},[Const.JOB_DS] = {}}
	var.mClothDataF = {[Const.JOB_ZS] = {},[Const.JOB_FS] = {},[Const.JOB_DS] = {}}
    var.widget:getWidgetByName("Button_zs"):getTitleRenderer():setRotationSkewY(180)
    var.widget:getWidgetByName("Button_fs"):getTitleRenderer():setRotationSkewY(180)
    var.widget:getWidgetByName("Button_ds"):getTitleRenderer():setRotationSkewY(180)

    for i=1,5 do
    	local btn = var.widget:getWidgetByName("img_shenqi_"..i)
    	btn:getWidgetByName("img_shenqi_light"):hide()
    	btn:setTouchEnabled(true)
    	btn.tag = i
    	btn:addClickEventListener(function (pSender)
    		for j=1,5 do
    			var.widget:getWidgetByName("img_shenqi_"..j):getWidgetByName("img_shenqi_light"):hide()
    		end
			pSender:getWidgetByName("img_shenqi_light"):show()
			var.selectMTab = pSender.tag
			if var.selectLTab == 1 then
				PanelShenQi.updateShenqiByJob(PanelShenQi.getJobByTag(var.selectRTab))
			else
				PanelShenQi.updateShenJiaByJob(PanelShenQi.getJobByTag(var.selectRTab))
			end
    	end)
    end
	var.widget:getWidgetByName("vcoin_box"):setSelected(false)
    var.widget:getWidgetByName("Button_get_item"):addClickEventListener(function (pSender)
        UIButtonGuide.handleButtonGuideClicked(pSender,{UIButtonGuide.GUILDTYPE.SHENQI})
    	local typeN = "weapon"
    	local useVcoin = (var.widget:getWidgetByName("vcoin_box"):isSelected() and 1 or 0)
		if var.selectLTab == 1 then
			typeN = "weapon"
		elseif var.selectLTab == 2 then
			typeN = "manCloth"
		elseif var.selectLTab == 3 then
			typeN = "womanCloth"
		end
    	NetClient:PushLuaTable("newgui.ArtifactChange.OnArtifactLua",util.encode({actionid = "changeBtn",typeName=typeN,job=var.selectRTab+99,index=var.selectMTab,useVcoin=useVcoin}))
    end)

    var.widget:getWidgetByName("sq_label_panel"):show()
    var.widget:getWidgetByName("sj_label_panel"):hide()

    PanelShenQi.registeEvent()
    PanelShenQi.addMenuTabClickEvent()
    NetClient:PushLuaTable("newgui.ArtifactChange.OnArtifactLua",util.encode({actionid = "getData",typeName="weapon"}))

    return var.widget
end

function PanelShenQi.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    	:addEventListener(Notify.EVENT_PUSH_PANEL_DATA, PanelShenQi.handlePanelData)
end

function PanelShenQi.handlePanelData(event)
	if event and event.type == "artifact_weapon" then
		local arti_data = json.decode(event.data)
        if not arti_data then return end
        local res = arti_data.res
		var.mWeaponData = {[Const.JOB_ZS] = {},[Const.JOB_FS] = {},[Const.JOB_DS] = {}}
        for i=1,#res do
        	if res[i].job == "100" then
        		table.insert(var.mWeaponData[Const.JOB_ZS],res[i])
    		elseif res[i].job == "101" then
        		table.insert(var.mWeaponData[Const.JOB_FS],res[i])
    		elseif res[i].job == "102" then
        		table.insert(var.mWeaponData[Const.JOB_DS],res[i])
        	end
        end
    	-- PanelShenQi.updatePanelByTag(var.selectLTab,var.selectRTab)
    	PanelShenQi.updateShenqiByJob(PanelShenQi.getJobByTag(var.selectRTab))
	elseif event and event.type == "artifact_cloth" then
		local arti_data = json.decode(event.data)
        if not arti_data then return end
		var.mClothDataM = {[Const.JOB_ZS] = {},[Const.JOB_FS] = {},[Const.JOB_DS] = {}}
		var.mClothDataF = {[Const.JOB_ZS] = {},[Const.JOB_FS] = {},[Const.JOB_DS] = {}}
        local man_res = arti_data.mancloth_data
        for i=1,#man_res do
        	if man_res[i].job == "100" then
        		table.insert(var.mClothDataM[Const.JOB_ZS],man_res[i])
    		elseif man_res[i].job == "101" then
        		table.insert(var.mClothDataM[Const.JOB_FS],man_res[i])
    		elseif man_res[i].job == "102" then
        		table.insert(var.mClothDataM[Const.JOB_DS],man_res[i])
        	end
        end
        local woman_res = arti_data.womancloth_data
        for i=1,#woman_res do
        	if woman_res[i].job == "100" then
        		table.insert(var.mClothDataF[Const.JOB_ZS],woman_res[i])
    		elseif woman_res[i].job == "101" then
        		table.insert(var.mClothDataF[Const.JOB_FS],woman_res[i])
    		elseif woman_res[i].job == "102" then
        		table.insert(var.mClothDataF[Const.JOB_DS],woman_res[i])
        	end
        end
    	PanelShenQi.updateShenJiaByJob(PanelShenQi.getJobByTag(var.selectRTab))
    	-- PanelShenQi.updatePanelByTag(var.selectLTab,var.selectRTab)
	elseif event and event.type == "shenqijifen" then
		local arti_data = json.decode(event.data)
        if not arti_data then return end
    	var.widget:getWidgetByName("label_my_point"):setString(arti_data)
    end

    if UIButtonGuide.isShowGuide(UIButtonGuide.GUILDTYPE.SHENQI) then
        UIButtonGuide.addGuideTip(var.widget:getWidgetByName("Button_get_item"),UIButtonGuide.getGuideStepTips(UIButtonGuide.GUILDTYPE.SHENQI),UIButtonGuide.UI_TYPE_LEFT)
    else
        UIButtonGuide.clearGuideTip(var.widget:getWidgetByName("Button_get_item"))
    end
end

function PanelShenQi.updateShenqiByJob(job)
	if var.mWeaponData and var.mWeaponData[job] then
		for i=1,#var.mWeaponData[job] do
			local shenqi_bg = var.widget:getWidgetByName("img_shenqi_"..i)
			local m_data = var.mWeaponData[job][i]
			if m_data then
				if i == var.selectMTab then
					if var.widget:getChildByName("effect") then
						var.widget:removeChildByName("effect")
					end
					var.widget:getWidgetByName("img_shenqi_"..var.selectMTab):getWidgetByName("img_shenqi_light"):show()
            		local itemdef = NetClient:getItemDefByID(tonumber(m_data.id))
            		if itemdef then
            			local label_panel = var.widget:getWidgetByName("sq_label_panel")
            			if job == Const.JOB_ZS then
            				label_panel:getWidgetByName("label_wuli"):setString(itemdef.mDC.."-"..itemdef.mDCMax)
            				PanelShenQi.fixAttrLabel()
        				elseif job == Const.JOB_FS then
            				label_panel:getWidgetByName("label_wuli"):setString(itemdef.mDC.."-"..itemdef.mDCMax)
            				label_panel:getWidgetByName("label_mofa"):setString(itemdef.mMC.."-"..itemdef.mMCMax)
            				label_panel:getWidgetByName("wuli_info_1"):setString("魔法攻击：")
            				PanelShenQi.fixAttrLabel()
        				elseif job == Const.JOB_DS then
            				label_panel:getWidgetByName("label_wuli"):setString(itemdef.mDC.."-"..itemdef.mDCMax)
            				label_panel:getWidgetByName("label_mofa"):setString(itemdef.mSC.."-"..itemdef.mSCMax)
            				label_panel:getWidgetByName("wuli_info_1"):setString("道术攻击：")
            				PanelShenQi.fixAttrLabel()
            			end
        				label_panel:getWidgetByName("label_luck"):setString("+"..(itemdef.mLuck/100).."%")
        				label_panel:getWidgetByName("label_protect"):setString("+"..itemdef.mProtect)
        				label_panel:getWidgetByName("label_hpmax"):setString("+"..itemdef.mMaxHp)
        				if itemdef.mNeedType == 0 then
        					label_panel:getWidgetByName("label_need_level"):setString(itemdef.mNeedParam.."级")
    					elseif itemdef.mNeedType == 4 then
        					label_panel:getWidgetByName("label_need_level"):setString(itemdef.mNeedParam.."转")
        				end
					    local sps = gameEffect.getFrameEffect( "scenebg/artifact/"..itemdef.mIconID, itemdef.mIconID.."_0000%02d.png", 1, 12, 0.15)
					    :addTo(var.widget)
					    sps:setPosition(cc.p(410,600)):setName("effect")
            		end
	        		if #m_data.need < 2 then
		        		var.widget:getWidgetByName("label_item_name"):setString(m_data.need[1].name)
		        		var.widget:getWidgetByName("label_need_jf"):setString(m_data.need[1].num)
		        	else
		        		var.widget:getWidgetByName("label_item_name"):setString(m_data.need[1].name)
		        		var.widget:getWidgetByName("label_need_jf"):setString(m_data.need[2].num)
		        	end
	        		var.widget:getWidgetByName("atlas_fight"):setString(m_data.FightPoint)
				end
				shenqi_bg:getWidgetByName("label_shenqi"):setString(m_data.name)
				shenqi_bg:getWidgetByName("img_shenqi_icon"):loadTexture("icon/"..m_data.id..".png",UI_TEX_TYPE_LOCAL)
			end
		end

	end
end

function PanelShenQi.updateShenJiaByJob(job)
	local ClothData
	if var.selectLTab == 2 then--神甲男
		ClothData = var.mClothDataM
	elseif var.selectLTab == 3 then--神甲女
		ClothData = var.mClothDataF
	end
	if ClothData and ClothData[job] then
		for i=1,#ClothData[job] do
			local shenqi_bg = var.widget:getWidgetByName("img_shenqi_"..i)
			local m_data = ClothData[job][i]
			if m_data then
				if i == var.selectMTab then
				    if var.widget:getChildByName("effect") then
						var.widget:removeChildByName("effect")
					end
					var.widget:getWidgetByName("img_shenqi_"..var.selectMTab):getWidgetByName("img_shenqi_light"):show()
            		local itemdef = NetClient:getItemDefByID(tonumber(m_data.id))
            		if itemdef then
            			local label_panel = var.widget:getWidgetByName("sj_label_panel")
            			if job == Const.JOB_ZS then
            				label_panel:getWidgetByName("label_wuli"):setString(itemdef.mDC.."-"..itemdef.mDCMax)
            				PanelShenQi.fixAttrLabel()
        				elseif job == Const.JOB_FS then
            				label_panel:getWidgetByName("label_wuli"):setString(itemdef.mDC.."-"..itemdef.mDCMax)
            				label_panel:getWidgetByName("label_mofa"):setString(itemdef.mMC.."-"..itemdef.mMCMax)
            				label_panel:getWidgetByName("wuli_info_1"):setString("魔法攻击：")
            				PanelShenQi.fixAttrLabel()
        				elseif job == Const.JOB_DS then
            				label_panel:getWidgetByName("label_wuli"):setString(itemdef.mDC.."-"..itemdef.mDCMax)
            				label_panel:getWidgetByName("label_mofa"):setString(itemdef.mSC.."-"..itemdef.mSCMax)
            				label_panel:getWidgetByName("wuli_info_1"):setString("道术攻击：")
            				PanelShenQi.fixAttrLabel()
            			end
        				label_panel:getWidgetByName("label_wufang"):setString(itemdef.mAC.."-"..itemdef.mACMax)
        				label_panel:getWidgetByName("label_mofang"):setString(itemdef.mMAC.."-"..itemdef.mMACMax)
        				label_panel:getWidgetByName("label_protect"):setString("+"..itemdef.mProtect)
        				label_panel:getWidgetByName("label_hpmax"):setString("+"..itemdef.mMaxHp)
        				label_panel:getWidgetByName("label_damage"):setString("+"..itemdef.mHurtImmune)
        				if itemdef.mNeedType == 0 then
        					label_panel:getWidgetByName("label_need_level"):setString(itemdef.mNeedParam.."级")
    					elseif itemdef.mNeedType == 4 then
        					label_panel:getWidgetByName("label_need_level"):setString(itemdef.mNeedParam.."转")
        				end
					    local sps = gameEffect.getFrameEffect( "scenebg/artifact/"..itemdef.mIconID, itemdef.mIconID.."_000%02d.png", 0, 8, 0.15)
					    :addTo(var.widget)
					    sps:setPosition(cc.p(410,600)):setName("effect")
            		end
	        		if #m_data.need < 2 then
		        		var.widget:getWidgetByName("label_item_name"):setString(m_data.need[1].name)
		        		var.widget:getWidgetByName("label_need_jf"):setString(m_data.need[1].num)
		        	else
		        		var.widget:getWidgetByName("label_item_name"):setString(m_data.need[1].name)
		        		var.widget:getWidgetByName("label_need_jf"):setString(m_data.need[2].num)
		        	end
	        		var.widget:getWidgetByName("atlas_fight"):setString(m_data.FightPoint)
				end
				shenqi_bg:getWidgetByName("label_shenqi"):setString(m_data.name)
				shenqi_bg:getWidgetByName("img_shenqi_icon"):loadTexture("icon/"..m_data.id..".png",UI_TEX_TYPE_LOCAL)
			end
		end

	end
end

function PanelShenQi.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local RadionButtonGroup1 = UIRadioButtonGroup.new()
        :addButton(var.widget:getWidgetByName("Button_sq"))
        :addButton(var.widget:getWidgetByName("Button_sj_m"))
        :addButton(var.widget:getWidgetByName("Button_sj_f"))
        :onButtonSelectChanged(function(event)
            PanelShenQi.updatePanelByTag(event.selected,var.selectRTab)
        end)
    RadionButtonGroup1:setButtonSelected(var.selectLTab)

    local RadionButtonGroup2 = UIRadioButtonGroup.new()
        :addButton(var.widget:getWidgetByName("Button_zs"))
        :addButton(var.widget:getWidgetByName("Button_fs"))
        :addButton(var.widget:getWidgetByName("Button_ds"))
        :onButtonSelectChanged(function(event)
            PanelShenQi.updatePanelByTag(var.selectLTab,event.selected)
        end)
    RadionButtonGroup2:setButtonSelected(var.selectRTab)
end

function PanelShenQi.updatePanelByTag(tag1,tag2)
	if tag1 == var.selectLTab and tag2 == var.selectRTab then return end
	var.selectRTab = tag2
	var.selectLTab = tag1
	
    var.selectMTab = 1
    if var.widget:getChildByName("effect") then
		var.widget:removeChildByName("effect")
	end
    for j=1,5 do
		var.widget:getWidgetByName("img_shenqi_"..j):getWidgetByName("img_shenqi_light"):hide()
	end
	
	local typeN = "weapon"
	if tag1 == 1 then
		typeN = "weapon"
	    var.widget:getWidgetByName("sq_label_panel"):show()
	    var.widget:getWidgetByName("sj_label_panel"):hide()
	else
		typeN = "cloth"
	    var.widget:getWidgetByName("sq_label_panel"):hide()
	    var.widget:getWidgetByName("sj_label_panel"):show()
	end
    NetClient:PushLuaTable("newgui.ArtifactChange.OnArtifactLua",util.encode({actionid = "getData",typeName=typeN}))
end

function PanelShenQi.fixAttrLabel()
	if var.selectLTab == 1 then
		local label_panel = var.widget:getWidgetByName("sq_label_panel")
		if var.selectRTab == 1 then--战士
			label_panel:getWidgetByName("wuli_info_1"):hide()
			label_panel:getWidgetByName("wuli_info_2"):setPositionY(172.5)
			label_panel:getWidgetByName("wuli_info_3"):setPositionY(135)
			label_panel:getWidgetByName("wuli_info_4"):setPositionY(97.5)
		elseif var.selectRTab == 2 or var.selectRTab == 3 then--法师道士
			label_panel:getWidgetByName("wuli_info_1"):show()
			label_panel:getWidgetByName("wuli_info_2"):setPositionY(150)
			label_panel:getWidgetByName("wuli_info_3"):setPositionY(120)
			label_panel:getWidgetByName("wuli_info_4"):setPositionY(90)
		end
		for i=1,5 do
			var.widget:getWidgetByName("img_shenqi_"..i):show()--:setPositionY(525-(i-1)*105)
		end
	else
		local label_panel = var.widget:getWidgetByName("sj_label_panel")
		if var.selectRTab == 1 then--战士
			label_panel:getWidgetByName("wuli_info_1"):hide()
			label_panel:getWidgetByName("wuli_info_2"):setPositionY(185)
			label_panel:getWidgetByName("wuli_info_3"):setPositionY(155)
			label_panel:getWidgetByName("wuli_info_4"):setPositionY(120)
			label_panel:getWidgetByName("wuli_info_5"):setPositionY(95)
			label_panel:getWidgetByName("wuli_info_6"):setPositionY(65)
			label_panel:getWidgetByName("wuli_info_7"):setPositionY(35)
		elseif var.selectRTab == 2 or var.selectRTab == 3 then--法师道士
			label_panel:getWidgetByName("wuli_info_1"):show()
			label_panel:getWidgetByName("wuli_info_2"):setPositionY(155)
			label_panel:getWidgetByName("wuli_info_3"):setPositionY(120)
			label_panel:getWidgetByName("wuli_info_4"):setPositionY(95)
			label_panel:getWidgetByName("wuli_info_5"):setPositionY(65)
			label_panel:getWidgetByName("wuli_info_6"):setPositionY(35)
			label_panel:getWidgetByName("wuli_info_7"):setPositionY(5)
		end
		for i=1,5 do
			var.widget:getWidgetByName("img_shenqi_"..i):show()--:setPositionY(525-(i-1)*140)
			if i == 5 then
				var.widget:getWidgetByName("img_shenqi_"..i):hide()
			end
		end
	end
end

function PanelShenQi.getJobByTag(tag)
	local job = Const.JOB_ZS
	if var.selectRTab == 1 then--战士
		job = Const.JOB_ZS
	elseif var.selectRTab == 2 then--法师
		job = Const.JOB_FS
	elseif var.selectRTab == 3 then--道士
		job = Const.JOB_DS
	end
	return job
end

function PanelShenQi.onPanelClose()
    UIButtonGuide.setGuideEnd(UIButtonGuide.GUILDTYPE.SHENQI)
end

return PanelShenQi