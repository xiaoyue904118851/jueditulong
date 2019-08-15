local UIItem = {}
local DEFAULT_ICON_RES = 10001 -- 默认显示的图标

function UIItem.cleanSimpleItem(parent)
    if not parent then return end
    parent:setTouchEnabled(false)
    local itemIcon = parent:getWidgetByName("iconNode")
    if itemIcon then
        itemIcon:removeFromParent()
    end
end

function UIItem.getSimpleItem(param)
    if not param.parent then
        return
    end
    UIItem.cleanSimpleItem(param.parent)
    local itemdef = NetClient:getItemDefByID(param.typeId)
    if not itemdef then
        itemdef = NetClient:getItemDefByName(param.name)
    end
    if not itemdef then return end

    local bgW = param.parent:getContentSize().width
    local bgH = param.parent:getContentSize().height
    itemIcon = ccui.Widget:create()
    itemIcon:setContentSize(cc.size(bgW, bgH))
    :align(display.CENTER,bgW/2,bgH/2)
    :addTo(param.parent)
    itemIcon:setName("iconNode")

    local colorbg = ccui.ImageView:create()
    :align(display.CENTER,bgW/2,bgH/2)
    :addTo(itemIcon)
    if itemdef.mColor and itemdef.mColor > 0 then
        colorbg:loadTexture(game.getItemColorBg(itemdef.mColor), UI_TEX_TYPE_PLIST)
    else
        colorbg:loadTexture("icon_color_white.png", UI_TEX_TYPE_PLIST)
    end

    local icon = ccui.ImageView:create()
    :align(display.CENTER,bgW/2,bgH/2)
    :addTo(itemIcon)
    icon:loadTexture("icon/"..itemdef.mIconID..".png"):setScale(1.5)

    local shownum = false
    if param.num and checkint(param.num) > 1 then
        shownum = true
        local lblNum = ccui.Text:create()
        :align(display.CENTER_TOP, bgW/2, 0)
        :addTo(itemIcon)
        lblNum:setString(game.getShorNum(param.num))
        lblNum:setFontSize(24)
        lblNum:setColor(Const.COLOR_GREEN_1_C3B)
        lblNum:setFontName(Const.DEFAULT_FONT_NAME)
        lblNum:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
    end

    if param.bind then
        local bindFlag = ccui.ImageView:create()
        :align(display.LEFT_BOTTOM,5, 5)
        :addTo(itemIcon)
        local img = "null.png"
        if param.bind and param.bind % 2 == 1 then
            img = "binding.png"
        end
        bindFlag:loadTexture(img,UI_TEX_TYPE_PLIST)
    end

    if not shownum and param.level and param.level > 0 then
        local lblLevel = ccui.Text:create()
        :align(display.RIGHT_BOTTOM, bgW - 6, 0)
        :addTo(itemIcon)
        lblLevel:enableShadow(cc.c4b(0,0,0,255),cc.size(1,-1))
        lblLevel:setFontSize(24)
        lblLevel:setFontName(Const.DEFAULT_FONT_NAME)
        lblLevel:setColor(Const.COLOR_WHITE_1_C3B)
        lblLevel:setString("+"..param.level)
--        lblLevel:setPositionY(itemIcon:getContentSize().height-5)
    end

    param.parent.typeId = itemdef.mTypeID
    param.parent.level = param.level
    param.parent:setTouchEnabled(true)
    param.parent:addClickEventListener(function(pSender)
        if pSender.itemCallBack then
            pSender.itemCallBack(pSender)
        else
            NetClient:dispatchEvent(
                {
                    name = Notify.EVENT_HANDLE_ITEM_TIPS,
                    typeId = pSender.typeId,
                    visible = true,
                    level = pSender.level,
                })
        end
    end)
end

function UIItem.getItem(param)
	if param.parent then
		local itemIcon = param.parent:getWidgetByName("iconNode")
		if not itemIcon then
            local bgW = param.parent:getContentSize().width
            local bgH = param.parent:getContentSize().height
            itemIcon = ccui.Widget:create()
            itemIcon:setContentSize(cc.size(bgW, bgH))
            :align(display.CENTER,bgW/2,bgH/2)
            :addTo(param.parent)
            itemIcon:setName("iconNode")

            if param.showSelectEffect then
                local selectbg = ccui.ImageView:create("img_select_01.png",UI_TEX_TYPE_PLIST)
                :align(display.CENTER,bgW/2, bgH/2)
                :addTo(itemIcon)
                :hide()
                :setScale9Enabled(true)
                :setContentSize(cc.size(80, 80))
                selectbg:setName("selectbg")
            end

            local icon = ccui.ImageView:create()
            :align(display.CENTER,bgW/2,bgH/2)
            :addTo(itemIcon)
            icon:setName("colorbg")

			local icon = ccui.ImageView:create()
            :align(display.CENTER,bgW/2,bgH/2)
				:addTo(itemIcon)
            icon:setName("icon")

			local lblNum = ccui.Text:create()
				:align(display.RIGHT_BOTTOM, bgW - 5, 5)
				:addTo(itemIcon)
			lblNum:setFontSize(20)
            lblNum:setColor(cc.c3b(0, 255, 0))
			lblNum:setName("lblNum")
            lblNum:setFontName(Const.DEFAULT_FONT_NAME)

            local bindFlag = ccui.ImageView:create()
            :align(display.LEFT_BOTTOM,5, 5)
            :addTo(itemIcon)
            bindFlag:setName("bindFlag")

            local betterFlag = ccui.ImageView:create()
            :align(display.LEFT_TOP,5, bgH - 5)
            :addTo(itemIcon)
            betterFlag:setName("betterFlag")

            local icon = ccui.ImageView:create()
            :align(display.CENTER,bgW/2,bgH/2)
            :addTo(itemIcon)
            icon:setName("jinyongbg")
		else
			UIItem.resetItemIcon(itemIcon)
		end

		-- itemIcon.updateFunc = param.updateFunc

		if param.pos or param.typeId or param.name then 
			--print("param.pos", param.pos, param.typeId, param.titleText)
			
			param.parent:setTouchEnabled(true)
			param.parent.itemIcon = itemIcon

			itemIcon:setTouchEnabled(false)
			itemIcon.itemCallBack = param.itemCallBack
			itemIcon.iconType = param.iconType
			itemIcon.callBack = param.callBack
			itemIcon.titleText = param.titleText
            itemIcon.fromBag = param.fromBag

			if param.pos then 
				UIItem.updateItemIconByPos(itemIcon, param.pos)
                dw.EventProxy.new(NetClient,itemIcon)
					:addEventListener(Notify.EVENT_ITEM_CHANGE, function (event)
						UIItem.handleItemChange(itemIcon, event)
					end)
                    :addEventListener(Notify.EVENT_GUILD_ITEM_CHANGE, function (event)
                        UIItem.handleItemChange(itemIcon, event)
                    end)
                    :addEventListener(Notify.EVENT_ITEM_SELECT, function (event)
                        UIItem.handleItemSelect(itemIcon, event)
                    end)
			elseif param.typeId then 
				UIItem.updateItemIconByTypeId(itemIcon, param.typeId, param.num, param.bind)
                -- add By Elan
                dw.EventProxy.new(NetClient,itemIcon)
                :addEventListener(Notify.EVENT_NOTIFY_GETITEMDESP, function (event)
                    if itemIcon.typeId == event.type_id and itemIcon.iconRes == DEFAULT_ICON_RES then
                        UIItem.updateItemIconByTypeId(itemIcon, event.type_id, param.num, param.bind)
                    end
                end)
            elseif param.name then
            	local itemdef = NetClient:getItemDefByName(param.name)
            	if itemdef then
					UIItem.updateItemIconByTypeId(itemIcon, itemdef.mTypeID, param.num, param.bind)
				end
				itemIcon.mName = param.name
				dw.EventProxy.new(NetClient,itemIcon)
	                :addEventListener(Notify.EVENT_NOTIFY_GETITEMDESP, function (event)
	                    if itemIcon.mName == event.itemname then
	                        UIItem.updateItemIconByTypeId(itemIcon, event.type_id, param.num, param.bind)
	                    end
	                end)
			end
				
			param.parent:addClickEventListener(function(pSender)
				print("item click, pos = ", itemIcon.itemPos)
                print("item click, typeId = ", itemIcon.typeId)
				if itemIcon.iconType == Const.ICONTYPE.UPGRADE then
					UIItem.resetItemIcon(itemIcon)
				elseif itemIcon.itemCallBack then
					itemIcon.itemCallBack(pSender)
                else
					NetClient:dispatchEvent(
						{
                            name = Notify.EVENT_HANDLE_ITEM_TIPS,
                            pos = itemIcon.itemPos,
                            typeId = itemIcon.typeId,
                            visible = true,
                            callBack = itemIcon.callBack,
                            titleText = itemIcon.titleText,
                            fromBag = itemIcon.fromBag,
						})
					-- UITips.freshTips(param)
				end
			end)
		end
	end
end

function UIItem.handleItemSelect(itemIcon, event)
    if event.pos == itemIcon.itemPos  then
        local high = itemIcon:getWidgetByName("selectbg")
        if high then
            high:setVisible(event.visible)
        end
    end
end

function UIItem.creatItemIcon()
	local itemIcon = ccui.ImageView:create()
	itemIcon:setName("itemIcon")
	
	cc.EventProxy.new(NetClient,itemIcon)
		:addEventListener(Notify.EVENT_ITEM_CHANGE, function (event)
			UIItem.handleItemChange(itemIcon, event)
		end)
	return itemIcon
end

function UIItem.updateItemIconByPos(itemIcon, pos)
	-- print("updateItemIconByPos", pos)
	itemIcon.itemPos = pos
	local netItem = NetClient:getNetItem(pos)
    if pos >= Const.ITEM_GUILDDEPOT_BEGIN then
        netItem = NetClient:getGuildDepotItem(pos)
    end
	if netItem then
		UIItem.updateItemIconByTypeId(itemIcon, netItem.mTypeID, netItem.mNumber, netItem.mItemFlags)
    	if itemIcon:getChildByName("item_effect") then itemIcon:removeChildByName("item_effect") end
		if netItem.mLevel > 0 then
			-- local plist,format = UIItem.getQiangHuanPath(netItem.mLevel)
   --          gameEffect.getFrameEffect( plist,format, 1, 11,0.12 )
			-- 	:setPosition(pos >= 0 and cc.p(35,35) or cc.p(40,40))
			-- 	:setName("item_effect")
			-- 	:addTo(itemIcon)
		end
	else
		UIItem.resetItemIcon(itemIcon)
	end
end

function UIItem.updateItemBind(itemIcon, flag)
    local bindFlag = itemIcon:getWidgetByName("bindFlag")
    if not bindFlag then
        return
    end
    local img = "null.png"
    if flag and flag % 2 == 1 then
        img = "lock_beibao.png"
    end
    bindFlag:setScale(0.6)
    bindFlag:loadTexture(img,UI_TEX_TYPE_PLIST)
end

function UIItem.updateItemNum(itemIcon, num ,color)
	local lblNum = itemIcon:getWidgetByName("lblNum")
    if lblNum == nil then return end
    if type(num) == "string" then
        lblNum:setString(num)
        if color then lblNum:setColor(color) end
        return
    end
    if num == nil or num <= 1 then
    	if num == 0 then
            lblNum:setPositionY(0)
	        lblNum:setString("0")
	        lblNum:setColor(Const.COLOR_WHITE_1_C3B)
	    else
			if itemIcon.itemPos then
				local netItem = NetClient:getNetItem(itemIcon.itemPos)
				if netItem then
					if netItem.mLevel > 0 then
	        			lblNum:setString("+"..netItem.mLevel)
                        lblNum:setPositionY(0)
--                        lblNum:setPositionY(itemIcon:getContentSize().height-25)
        				lblNum:setColor(Const.COLOR_WHITE_1_C3B)
        			else
	        			lblNum:setString("")
	        		end
				end
			else
	        	lblNum:setString("")
			end
	    end
    else
        lblNum:setPositionY(0)
        lblNum:setString(game.getShorNum(num))
        lblNum:setColor(Const.COLOR_WHITE_1_C3B)
    end
end

function UIItem.updateBetterFlag(itemIcon)
    local betterFlag = itemIcon:getWidgetByName("betterFlag")
    if not betterFlag then
        return
    end

    local img = "null.png"
    if itemIcon.itemPos and not game.IsPosInAvatar(itemIcon.itemPos) then
        local ret = game.isBetterInAvatar(itemIcon.itemPos)
        if ret ==  Const.ITEM_BETTER_SELF then
            img =  "better_equip.png"
        elseif ret ==  Const.ITEM_WORSE_SELF then
            img =  "worse_equip.png"
        end
    end
    betterFlag:loadTexture(img,UI_TEX_TYPE_PLIST)
end

function UIItem.updateItemIconByTypeId(itemIcon, typeId, number, flag)
	local iconRes = DEFAULT_ICON_RES
	local itemdef = NetClient:getItemDefByID(typeId)
	if itemdef then 
        iconRes = itemdef.mIconID 
    end


    itemIcon:getWidgetByName("icon"):loadTexture("icon/"..iconRes..".png"):setScale(1.5)
	if itemdef and itemdef.mColor and itemdef.mColor > 0 then
        itemIcon:getWidgetByName("colorbg"):loadTexture(game.getItemColorBg(itemdef.mColor), UI_TEX_TYPE_PLIST)
    else
        itemIcon:getWidgetByName("colorbg"):loadTexture("icon_color_white.png", UI_TEX_TYPE_PLIST)
    end

    --job different
    if itemdef and itemdef.mJob and (itemdef.mSex > 0 or itemdef.mJob > 0) then
        if (itemdef.mJob ~= game.getRoleJob() and itemdef.mJob > 0) or (itemdef.mSex ~= game.getRoleGender() and itemdef.mSex > 0) then
            if itemIcon:getWidgetByName("jinyongbg") then
                itemIcon:getWidgetByName("jinyongbg"):loadTexture("undo_bg.png", UI_TEX_TYPE_PLIST)
            end
        else
            if itemIcon:getWidgetByName("jinyongbg") then
                itemIcon:getWidgetByName("jinyongbg"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
            end
        end
    else
        if itemIcon:getWidgetByName("jinyongbg") then
            itemIcon:getWidgetByName("jinyongbg"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
        end
    end

    local equipDesc = itemIcon:getParent():getWidgetByName("Image_equp_name")
    if equipDesc then equipDesc:hide() end

	itemIcon.typeId = typeId
    itemIcon.iconRes = iconRes
    UIItem.updateItemNum(itemIcon, number)
    UIItem.updateItemBind(itemIcon, flag)
    UIItem.updateBetterFlag(itemIcon)
end

function UIItem.handleItemChange(itemIcon, event)
	if event.pos == itemIcon.itemPos then

--		print("handleItemChange and pos is ",event.pos, event.oldType)

		if itemIcon.iconType == Const.ICONTYPE.UPGRADE then print("bbbbb") UIItem.resetItemIcon(itemIcon) return end

		if event.pos then
			UIItem.updateItemIconByPos(itemIcon, event.pos)
			-- if itemIcon.updateFunc then itemIcon.updateFunc() end
		end
	else
        local netItem = NetClient:getNetItem(itemIcon.itemPos)
        if netItem then
            local avatarPos = game.getAvatarPos(netItem.mTypeID)
            if avatarPos and avatarPos == event.pos then
                if itemIcon.iconType == Const.ICONTYPE.UPGRADE then print("bbbbb") UIItem.resetItemIcon(itemIcon) return end
                UIItem.updateItemIconByPos(itemIcon, itemIcon.itemPos)
            end
        end
    end
end

function UIItem.resetItemIcon(itemIcon)
	-- print("resetItemIcon",itemIcon)
	if itemIcon then
        --print("TZ::::itemIcon.itemPos",itemIcon.itemPos)
        itemIcon:getParent():loadTexture("item_bg.png",UI_TEX_TYPE_PLIST)
        itemIcon:getWidgetByName("colorbg"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
		itemIcon:getWidgetByName("icon"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
        itemIcon:getWidgetByName("bindFlag"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
        itemIcon:getWidgetByName("betterFlag"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
        itemIcon:getWidgetByName("jinyongbg"):loadTexture("null.png", UI_TEX_TYPE_PLIST)
        if itemIcon:getChildByName("item_effect") then itemIcon:removeChildByName("item_effect") end
        if itemIcon:getChildByName("selectbg") then itemIcon:getChildByName("selectbg"):hide() end
		-- itemIcon.itemPos = nil
		itemIcon.typeId = nil
		itemIcon.iconType = nil
        itemIcon.iconRes = DEFAULT_ICON_RES
		-- itemIcon.itemCallBack = nil
		-- itemIcon.updateFunc = nil
        itemIcon:getWidgetByName("lblNum"):setString("")
        local equipDesc = itemIcon:getParent():getWidgetByName("Image_equp_name")
        if equipDesc then equipDesc:show() end
	end
end

function UIItem.getQiangHuanPath(level)
	local name 
    local ret
    local format 
    if level >= 6 and level < 9 then
        name = "qianghuastar"
        format = "qianghuastar%d.png"
    elseif level >= 9 and level <12 then
        name = "qianghuastar2"
        format = "qianghuastar2_%d.png"
    elseif level == 12 then
        name = "qianghuastar3"
        format = "qianghuastar3_%d.png"
    end
    if name then
        return name,format-- ret = resmng.getHeadNEffect(name,format,1,11,0.12)
    end
    return name,format
end

return UIItem