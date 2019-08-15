local game = {}

game.BETTER_ITEM={
		["引导"]={},
		["装备"]={},
}

-- game.GUIDE_TABLE = {
-- 	["start"]={

-- 	},
-- 	["alert"]={

-- 	},
-- 	["tips"]={
				
-- 	},
-- 	["panel"]={
				
-- 	},
-- 	["GameMainUI"]={
				
-- 	},
-- }

game.OP_BUTTONS = {
    DRESS = { text = "穿 上", name = "Button_dress", tag = 1},
    SHOW = { text = "展 示", name = "Button_show", tag = 2},
    SELL = { text = "出 售", name = "Button_sell", tag = 3},
    RECOVERY = { text = "回 收", name = "Button_huishou", tag = 4},
    DESTROY = { text = "摧 毁", name = "Button_des", tag = 5},
    CHAI = { text = "拆 分", name = "Button_split", tag = 6},
    USE = { text = "使 用", name = "Button_tips_use", tag = 7},
    UNDRESS = { text = "卸 下", name = "Button_undress", tag = 8},
    DUI = { text = "堆 叠", name = "Button_dui", tag = 9},
    UPGRADE = { text = "强 化", name = "", tag = 10},
    ACTIVE = { text = "激 活", name = "", tag = 11},
    LOTTERY_OUT = { text = "取 出", name = "", tag = 12},
    HECHENG = { text = "合 成", name = "", tag = 13},
    DEPOT_OUT = { text = "取 出", tag = 14},
    BAG_TO_DEPOT = { text = "存 入", tag = 15},
    CLOSE = { text = "取 消", tag = 16},
    EAT = { text = "吃 药", name = "Button_tips_use", tag = 17},
    MORE = { text = "更 多", name = "Button_tips_more", tag = 18},
    BAG_TO_GDEPOT = { text = "捐 献", tag = 19},
    GDEPOT_OUT = { text = "兑 换", tag = 20},
}

game.SELECT_RECOVERY = {
    ["CheckBox_white"]  = 1,
    ["CheckBox_green"]  = 1,
    ["CheckBox_blue"]   = 1,
    ["CheckBox_p_blue"] = 0,
    ["CheckBox_purple"] = 0,
    ["CheckBox_orange"] = 0,
}

game.AUTOBUYUPDXJ = 1
game.AUTOBUYUPDFU = 0
game.AUTOBUYUPDQLY = 0
game.AUTOBUYUPDFYS = 0
game.BCFRESHZIJIN = 0
game.BCPROTECT = 0

game.SETTING_TABLE = {
	--system
    ["music_control"] = true,
    ["audio_control"] = true,
    ["check_trade"] = true,
    ["check_guild"] = true,
    ["check_group"] = true,
    ["showall_control"] = false,
    ["check_weapon"] = false,
    ["check_cloth"] = false,
    ["check_wing"] = false,
    ["check_title"] = false,
    ["check_skill"] = false,
    ["check_monster"] = false,
    ["check_guild_player"] = false,
    ["check_alien_player"] = false,
    --pickup
    ["pick_control"] = true,
    ["check_gold"] = true,
    ["check_drug"] = false,
    ["check_other"] = true,
    ["check_pick_level"] = true,
    ["check_zs_item"] = true,
    ["check_show_level"] = true,
    ["num_pick_level"] = 1,
    ["num_show_level"] = 1,
    --protect
    ["protect_control"] = true,
    ["check_hp"] = true,
    ["check_mp"] = true,
    ["check_hp_fly"] = false,
    ["check_gohome"] = false,
    ["check_auto_skill"] = true,
    ["label_hp_percent"] = 95,
    ["label_mp_percent"] = 20,
    ["label_fly_percent"] = 20,
    ["label_home_percent"] = 15,
    --guild_ronglian
    ["guild_ronglian_lv"] = 1,
    ["guild_ronglian_job"] = 1,
    ["guild_ronglian_color"] = 1,
    ["guild_ronglian_sex"] = 1,
}

function game.initVar()
    game.wifiOK=false
    game.mSessionID = ""
    game.mReSelectRole = false
    game.mServerIP=""
    game.mServerPort=0
    gameLogin.initVar()
    game.resetVarWhenReSelectRole()
end

function game.resetVarWhenReSelectRole()
    game.mChrName=""
    game.mSeedName=""
    game.mGameUserid=""
    game.mAdjustSvr=nil
    game.m_bAllowTrade = true
    game.m_bIsShortCutShow = false
    game.mLastChatMsg=""
    game.loadCache=false
    game.mBetterItemPos=-999
    game.mShowLeaveMap = false
    game.panel_trade_open = false
    game.mShowBottom = ""
    game.mBottomPos = {}
    game.GamePanelShow = true
    game.mRelivePanelOn=false
    game.mBagFullShow=false
    game.mAppendText=""
    game.mRockerRun=false
    game.mWarHideWing=false
    game.mWanderFight=false
    game.httplock=false
    game.mMemTotal=150
    game.mMemUsed=0
    game.mMemFlag=1
    game.mTaskMon=""
    game.mCurGuideButton=nil
    game.m_isGuiding=false
    game.mPausedMusic = ""
    game.guideTable={}
end

function game.cleanPicCache()
    cc.AnimManager:getInstance():remAllAnimate()
    cc.SpriteManager:getInstance():removeAllFrames()
    cc.CacheManager:getInstance():releaseUnused(false)
end

function game.cleanGame()
    game.cleanPicCache()
	NetClient:init()
	MainRole.initVar()
    TaskData.init()
    UILeftCenter.cleanGame()
end

function game.onDisConnect()
    MainRole.initVar()
    MainRole.stopAutoMove()
    MainRole.handleAutoKillOn(false)
    SimpleAudioEngine:stopAllEffects()
end

function game.ExitToRelogin(relogin)
    local MainAvatar = CCGhostManager:getMainAvatar()
    if MainAvatar then
        MainAvatar:actionReset()
    end
    game.mReSelectRole = true
    NetworkCenter:disconnect()
    game.initVar()
    game.cleanGame()
    SimpleAudioEngine:stopAllEffects()
    EventDispatcher:dispatchEvent({name=Notify.EVENT_GAME_RELOGIN,str="relogin"})
end

function game.ExitToReSelect()
	local MainAvatar = CCGhostManager:getMainAvatar()
	if not MainAvatar then return end
	MainAvatar:actionReset()
    game.mReSelectRole = true
    NetworkCenter:disconnect()
    game.resetVarWhenReSelectRole()
    game.cleanGame()
    SimpleAudioEngine:stopAllEffects()
    EventDispatcher:dispatchEvent({name=Notify.EVENT_GAME_RELOGIN,str="reloginrole"})
end

function game.GetMainRole()
	return  cc.GhostManager:getInstance():getMainAvatar()
end

function game.GetMainNetGhost()
    return NetCC:getMainGhost()
end
	
-- local video=ccexp.VideoPlayer:create()
-- video:setContentSize(cc.size(600,400))
-- wdg:addChild(video)
-- video:setFileName("res/cocosvideo.mp4")
-- video:play()

-- cc.Application:getInstance():openURL("http://www.cocos2d-x.org/")

-- if not self.m_webview then
-- 	self.m_webview=ccui.Widget:create()
-- 	self.m_webview:setContentSize(cc.size(600,300))
-- 	self.m_webview:setPosition(400,300)
-- 	self.m_webview:setTouchEnabled(true)
-- 	game.addChild(self.m_webview)
-- 	cc.SystemUtil:showWebView(self.m_webview,"http://wwww.baidu.com")
-- else
-- 	self.m_webview:removeFromParent()
-- 	self.m_webview=nil
-- end

function game.EasyHttp(url,callback)
	if game.httplock or not url or tostring(url)=="" then
		return
	end

	local xhr = nil
	local function httpcallback()
		local request = xhr
        -- 请求失败，显示错误代码和错误消息
        if request.responseType~=0 then
        	game.httplock=false
        	-- print(request:getErrorCode(), request:getErrorMessage())
        	device.showAlert("http error",request:getErrorCode().." "..request:getErrorMessage(),"确定")
        	return
        end
	 
	    local code = request.status
	    if code ~= 200 then
	    	game.httplock=false
	        -- 请求结束，但没有返回 200 响应代码
	        print("httpcallback:code",code)
	        return
	    end
	    game.httplock=false
	    -- 请求成功，显示服务端返回的内容
	    local response = request.response
	    -- print(response)

	    if callback and type(callback)=="function" then
	    	callback(response)
	    end
	end
	-- print(url)
	xhr = util.httpRequest(url,httpcallback)

	game.httplock=true
end

function game.clearHtmlText(str)
	str,n=string.gsub(str,"<[^>]*>","")
	return str
end

function game.getColor(color)
--    if color == 0x12cf28 then
--        return Const.COLOR_GREEN_1_C3B
--    elseif color == 0x009dfe or color == 0x9cff then
--        return Const.COLOR_BLUE_1_C3B
--    elseif color == 0xfe30fc then
--        return Const.COLOR_PURPLE_1_C3B
--    elseif color == 0xff7901 then
--        return Const.COLOR_ORANGE_1_C3B
--    elseif color == 0xe70301 then
--        return Const.COLOR_RED_1_C3B
--    else
--        return Const.COLOR_WHITE_1_C3B
--    end

	local r,g,b
	r=bit.rshift(bit.band(color,0xFF0000),16)
	g=bit.rshift(bit.band(color,0x00FF00),8)
	b=bit.band(color,0x0000FF)
	return cc.c3b(r,g,b)
end

function game.getItemColorBg(color)
    for k, v in ipairs(Const.Item_Def_color) do
        for _, vcolor in ipairs(v.colors) do
            if vcolor == color then
                return v.imgstr
            end
        end
    end
    return "icon_color_white.png"
end

function game.getItemColor(color)
    for k, v in ipairs(Const.Item_Def_color) do
        for _, vcolor in ipairs(v.colors) do
            if vcolor == color then
                return k
            end
        end
    end
    return 0
end

--获取物品背景框名字
function game.getItemBgName( _color )
    local ret = "item_bg.png"
    -- if _color < 0 then
    --     ret = "item_bg.png"
    -- end
    if _color == 5 then --0xEE00EE
        ret = "item_bg5.png"
    end
    if _color == 2 then
        ret = "item_bg2.png"
    end
    if _color == 4 then
        ret = "item_bg4.png"
    end
    if _color == 3 then
        ret = "item_bg3.png"
    end
    if _color == 6 then
        ret = "item_bg6.png"
    end

    return ret
end

function game.getTime()
	return cc.SocketManager:getSystemTime()
end

function game.convertSecondsToStr( delay )
    local min = math.floor(delay/60)
    local second = delay%60
    local str = string.format("%02d:%02d", min, second)
    return str
end

function game.convertSecondsToH( delay )
    local hour = math.floor(delay/(60*60))
    local min = math.floor((delay%(60*60))/60)
    local second = delay%60
    local str = string.format("%02d:%02d:%02d",hour, min, second)
    return str
end

function game.getSkipTime()
	if not game.initTime then
		return 0
	else
		return cc.SocketManager:getSystemTime()-game.initTime
	end
	return 0
end

function game.getAngle(from,to)
	local angle=math.atan((to.y-from.y)/(to.x-from.x))*(180/math.pi)
	if to.x<from.x then
		angle=angle+180
	end
	if to.y<=from.y then
		angle=angle+360
	end
	angle=angle%360

	return angle
end

function game.getPixesDirection(from,to)
	local rot=game.getAngle(from,to)
	if rot>=337.5 or rot<22.5 then
		return Const.DIR_RIGHT
	end
	if rot>=22.5 and rot<67.5 then
		return Const.DIR_UP_RIGHT
	end
	if rot>=67.5 and rot<112.5 then
		return Const.DIR_UP
	end
	if rot>=112.5 and rot<157.5 then
		return Const.DIR_UP_LEFT
	end
	if rot>=157.5 and rot<202.5 then
		return Const.DIR_LEFT
	end
	if rot>=202.5 and rot<247.5 then
		return Const.DIR_DOWN_LEFT
	end
	if rot>=247.5 and rot<292.5 then
		return Const.DIR_DOWN
	end
	if rot>=292.5 and rot<337.5 then
		return Const.DIR_DOWN_RIGHT
	end
	return Const.DIR_DOWN
end

function game.getLogicDirection(from,to)
	local rot=game.getAngle(from,to)
	if rot>=337.5 or rot<22.5 then
		return Const.DIR_RIGHT
	end
	if rot>=22.5 and rot<67.5 then
		return Const.DIR_DOWN_RIGHT
	end
	if rot>=67.5 and rot<112.5 then
		return Const.DIR_DOWN
	end
	if rot>=112.5 and rot<157.5 then
		return Const.DIR_DOWN_LEFT
	end
	if rot>=157.5 and rot<202.5 then
		return Const.DIR_LEFT
	end
	if rot>=202.5 and rot<247.5 then
		return Const.DIR_UP_LEFT
	end
	if rot>=247.5 and rot<292.5 then
		return Const.DIR_UP
	end
	if rot>=292.5 and rot<337.5 then
		return Const.DIR_UP_RIGHT
	end
	return Const.DIR_UP
end

function game.getDirectionPoint(dir,num,dx,dy)
	local step = {{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},}
	for i=1,num do
		dx = dx + step[dir+1][1]
		dy = dy + step[dir+1][2]
	end
	return dx,dy
end

function game.IsEquipment(type_id)
	if type_id > Const.ITEM_EQUIP_BEGIN and type_id < Const.ITEM_EQUIP_END then
		return true
	else
		return false
	end
end

function game.IsMaterial(type_id)
    if type_id >= 10135 and type_id <= 10146 then
        return true
    else
        return false
    end
end

function game.IsMedicine( type_id )
    if not type_id then return false end
    local ret = false
    if (type_id >= 10042) and (type_id < 10059) then ret = true end
    if (type_id >= 10062) and (type_id <= 10066) then ret = true end
    if (type_id >= 10116) and (type_id <= 10120) then ret = true end
    if (type_id >= 10074) and (type_id <= 10075) then ret = true end
    if (type_id >= 10307) and (type_id <= 10310) then ret = true end

    if type_id == 10263 then ret = true end
    if type_id == 10227 then ret = true end
    if type_id == 10228 then ret = true end
    if type_id == 10297 then ret = true end
    if type_id == 15378 then ret = true end --灵芝仙草
    if type_id == 10296 then ret = true end --太阳水
    if type_id == 10299 then ret = true end --强效太阳水
    if type_id == 10301 then ret = true end --太阳水(包)
    if type_id == 10304 then ret = true end --强效太阳水(包)
    if type_id == 15012 then ret = true end --万年寒霜
    if type_id == 15013 then ret = true end --万年寒霜(包)
    if type_id == 10039 or type_id == 10043 then ret = false end

    return ret
end

function game.getBagEndPos()
    return Const.ITEM_BAG_BEGIN + Const.ITEM_BAG_SIZE + NetClient.mBagSlotAdd - 1
end

function game.getBagStartPos ()
    return Const.ITEM_BAG_BEGIN
end

function game.IsPosInBag(pos)
	if pos then
		if pos >= game.getBagStartPos() and pos <= game.getBagEndPos() then
			return true
		else
			return false
		end
	end
	return false
end

function game.IsPosInDepot(pos)
    if pos then
        if pos >= Const.ITEM_DEPOT_BEGIN and pos < (Const.ITEM_DEPOT_BEGIN + Const.ITEM_DEPOT_SIZE + NetClient.mDepotSlotAdd) then
            return true
        else
            return false
        end
    end
    return false
end

function game.IsPosInGuildDepot(pos)
    if pos then
        if pos >= Const.ITEM_GUILDDEPOT_BEGIN and pos < (Const.ITEM_GUILDDEPOT_BEGIN + Const.ITEM_GUILDDEPOT_SIZE) then
            return true
        else
            return false
        end
    end
    return false
end

function game.IsPosInLottery(pos)
    if pos then
        if pos >= Const.ITEM_LOTTERYDEPOT_BEGIN and pos < (Const.ITEM_LOTTERYDEPOT_BEGIN + Const.ITEM_LOTTERYSIZE) then
            return true
        else
            return false
        end
    end
    return false
end

function game.getAvatarPos(type_id)
    if not game.IsEquipment(type_id) then
        return
    end

    if game.IsWeapon(type_id) then
        return Const.ITEM_WEAPON_POSITION
    elseif game.IsCloth(type_id) then
        return Const.ITEM_CLOTH_POSITION
    elseif game.IsHat(type_id) then
        return Const.ITEM_HAT_POSITION
    elseif game.IsRing(type_id) then
        return Const.ITEM_RING1_POSITION
    elseif game.IsGlove(type_id) then
        return Const.ITEM_GLOVE1_POSITION
    elseif game.IsNecklace(type_id) then
        return Const.ITEM_NICKLACE_POSITION
    elseif game.IsBelt(type_id) then
        return Const.ITEM_BELT_POSITION
    elseif game.IsBoot(type_id) then
        return Const.ITEM_BOOT_POSITION
    elseif game.IsWing(type_id) then
        return Const.ITEM_WING_POSITION
--    elseif game.IsLightWing(type_id) then
--        return Const.ITEM_WING_LIGHT_POSITION
    elseif game.IsSoul(type_id) then
        return Const.ITEM_SOUL_POSITION
    elseif game.IsFashionCloth(type_id) then
        return Const.ITEM_FASHION_CLOTH_POSITION
    elseif game.IsMedal(type_id) then
        return Const.ITEM_MEDAL_POSITION
    elseif game.IsSpecailRing(type_id) then
        return Const.ITEM_TEJIE_POSITION
--    elseif game.IsWeddingRing(type_id) then
--        return Const.ITEM_FASHION_WEDDING_RING_POSITION
    elseif game.IsFashionWeapon(type_id) then
        return Const.ITEM_FASHION_WEAPON_POSITION
    elseif game.isPifeng(type_id) then
        return Const.ITEM_PIFENG_POSITION
    elseif game.isLingpai(type_id) then
        return Const.ITEM_LINGPAI_POSITION
    elseif game.isYupei(type_id) then
        return Const.ITEM_YUPEI_POSITION
    elseif game.isShenqi(type_id) then
        return Const.ITEM_SHENQI_POSTITION
    elseif game.isShenjia(type_id) then
        return Const.ITEM_SHENJIA_POSTITION
    elseif game.isLonghun(type_id) then
        return Const.ITEM_LONGHUN_POSTITION
    elseif game.isHufu(type_id) then
        return Const.ITEM_HUFU_POSITION
    elseif game.isHufu2(type_id) then
        return Const.ITEM_HUFU2_POSITION
    elseif game.isJianjia(type_id) then
        return Const.ITEM_JIANJIA_POSITION
    elseif game.isBaoshi(type_id) then
        return Const.ITEM_BAOSHI_POSITION
    elseif game.isDunpai(type_id) then
        return Const.ITEM_DUNPAI_POSITION
    elseif game.isAnqi(type_id) then
        return  Const.ITEM_ANQI_POSITION
    elseif game.isYuxi(type_id) then
        return Const.ITEM_YUXI_POSITION
    end
end

function game.isBetterInAvatar(pos)
	local mItems = NetClient.mItems
	local type_id = 0
	local itemdef
	local tempItem = NetClient:getNetItem(pos)
	if tempItem then
		type_id = tempItem.mTypeID
		itemdef = NetClient:getItemDefByID(type_id)
	else
		type_id = pos
		itemdef = NetClient:getItemDefByID(type_id)
	end
    if not itemdef then
        if game.IsPosInGuildDepot(pos) then
            itemdef = NetClient:getGuildDepotItem(pos)
            type_id = itemdef.mTypeID
        end
    end
	if not itemdef then
		return Const.ITEM_WORSE_SELF
    end

    if game.IsPosInAvatar(pos) or not game.IsEquipment(type_id) then
        return Const.ITEM_NONE_SELF
    end

    if game.IsWeapon(type_id) then
        return game.CompareItem(pos,Const.ITEM_WEAPON_POSITION)
    elseif game.IsCloth(type_id) then
        return game.CompareItem(pos,Const.ITEM_CLOTH_POSITION)
    elseif game.IsHat(type_id) then
        return game.CompareItem(pos,Const.ITEM_HAT_POSITION)
    elseif game.IsRing(type_id) then
        return game.CompareItem(pos,Const.ITEM_RING1_POSITION)
    elseif game.IsGlove(type_id) then
        return game.CompareItem(pos,Const.ITEM_GLOVE1_POSITION)
    elseif game.IsNecklace(type_id) then
        return game.CompareItem(pos,Const.ITEM_NICKLACE_POSITION)
    elseif game.IsBelt(type_id) then
        return game.CompareItem(pos,Const.ITEM_BELT_POSITION)
    elseif game.IsBoot(type_id) then
        return game.CompareItem(pos,Const.ITEM_BOOT_POSITION)
    elseif game.IsWing(type_id) then
        return game.CompareItem(pos,Const.ITEM_WING_POSITION)
--    elseif game.IsLightWing(type_id) then
--        return game.CompareItem(pos,Const.ITEM_WING_LIGHT_POSITION)
    elseif game.IsSoul(type_id) then
        return game.CompareItem(pos,Const.ITEM_SOUL_POSITION)
    elseif game.IsFashionCloth(type_id) then
        return game.CompareItem(pos,Const.ITEM_FASHION_CLOTH_POSITION)
    elseif game.IsMedal(type_id) then
        return game.CompareItem(pos,Const.ITEM_MEDAL_POSITION)
    elseif game.IsSpecailRing(type_id) then
        return game.CompareItem(pos,Const.ITEM_TEJIE_POSITION)
--    elseif game.IsWeddingRing(type_id) then
--        return game.CompareItem(pos,Const.ITEM_FASHION_WEDDING_RING_POSITION)
    elseif game.IsFashionWeapon(type_id) then
        return game.CompareItem(pos,Const.ITEM_FASHION_WEAPON_POSITION)
    elseif game.isPifeng(type_id) then
        return game.CompareItem(pos,Const.ITEM_PIFENG_POSITION)
    elseif game.isLingpai(type_id) then
        return game.CompareItem(pos,Const.ITEM_LINGPAI_POSITION)
    elseif game.isYupei(type_id) then
        return game.CompareItem(pos,Const.ITEM_YUPEI_POSITION)
    elseif game.isShenqi(type_id) then
        return game.CompareItem(pos,Const.ITEM_SHENQI_POSTITION)
    elseif game.isShenjia(type_id) then
        return game.CompareItem(pos,Const.ITEM_SHENJIA_POSTITION)
    elseif game.isLonghun(type_id) then
        return game.CompareItem(pos,Const.ITEM_LONGHUN_POSTITION)
    elseif game.isHufu(type_id) then
        return game.CompareItem(pos,Const.ITEM_HUFU_POSITION)
    elseif game.isHufu2(type_id) then
        return game.CompareItem(pos,Const.ITEM_HUFU2_POSITION)
    elseif game.isJianjia(type_id) then
        return game.CompareItem(pos,Const.ITEM_JIANJIA_POSITION)
    elseif game.isBaoshi(type_id) then
        return game.CompareItem(pos,Const.ITEM_BAOSHI_POSITION)
    elseif game.isDunpai(type_id) then
        return game.CompareItem(pos,Const.ITEM_DUNPAI_POSITION)
    elseif game.isAnqi(type_id) then
        return  game.CompareItem(pos,Const.ITEM_ANQI_POSITION)
    elseif game.isYuxi(type_id) then
        return game.CompareItem(pos,Const.ITEM_YUXI_POSITION)
    end
    return Const.ITEM_NONE_SELF
end

function game.CompareItem(posBag,posAvatar)
	local mItems = NetClient.mItems
	local MainAvatar = CCGhostManager:getMainAvatar()
	local itemBag
	if mItems[posBag] then
		itemBag = NetClient:getItemDefByID(mItems[posBag].mTypeID)
	elseif game.IsPosInGuildDepot(posBag) then
        local tempitem = NetClient:getGuildDepotItem(posBag)
        if tempitem then
            itemBag = NetClient:getItemDefByID(tempitem.mTypeID)
        end
    else
		itemBag = NetClient:getItemDefByID(posBag)
    end
	if mItems[posAvatar] then
		local itemAvatar = NetClient:getItemDefByID(mItems[posAvatar].mTypeID)
		if itemBag and itemAvatar then
			if (itemBag.mJob == nil or itemBag.mJob == 0 or MainAvatar:NetAttr(Const.net_job) == 0 or itemBag.mJob == MainAvatar:NetAttr(Const.net_job) or (itemBag.mJob + 99) == MainAvatar:NetAttr(Const.net_job))
				and (itemBag.mSex == nil or itemBag.mSex == 0 or itemBag.mSex == MainAvatar:NetAttr(Const.net_gender) ) then
				if itemBag.mAddFight > itemAvatar.mAddFight then
					return Const.ITEM_BETTER_SELF,posAvatar
				elseif itemBag.mAddFight == itemAvatar.mAddFight then
					return Const.ITEM_NONE_SELF
                end
				return Const.ITEM_WORSE_SELF
            end
			return Const.ITEM_UNUSE_SELF
        end
		return Const.ITEM_WORSE_SELF
    else
		if (itemBag.mJob == nil or itemBag.mJob == 0 or MainAvatar:NetAttr(Const.net_job) == 0 or itemBag.mJob == MainAvatar:NetAttr(Const.net_job) or (itemBag.mJob + 99) == MainAvatar:NetAttr(Const.net_job))
			and (itemBag.mSex == nil or itemBag.mSex == 0 or itemBag.mSex == MainAvatar:NetAttr(Const.net_gender) ) then
            return Const.ITEM_BETTER_SELF,posAvatar
        end
		return Const.ITEM_UNUSE_SELF
	end
end

local EQUIP_TAG = {
	WEAPON = 1,CLOTH = 2,HAT = 3,RING = 4,GLOVE = 5,NECKLACE = 6,
	BELT = 7,BOOT = 8,WING = 9,FASHION = 10,SOUL = 11,ALL = 12,
}

-- 好像没用到
local checkTab = {
	[EQUIP_TAG.WEAPON] = "IsWeapon",
	[EQUIP_TAG.CLOTH] = "IsCloth", 
	[EQUIP_TAG.HAT] = "IsHat", 	
	[EQUIP_TAG.RING] = "IsRing", 	
	[EQUIP_TAG.GLOVE] = "IsGlove", 
	[EQUIP_TAG.NECKLACE] = "IsNecklace", 
	[EQUIP_TAG.BELT] = "IsBelt", 	
	[EQUIP_TAG.BOOT] = "IsBoot", 	
	[EQUIP_TAG.WING] = "IsWing", 	
	[EQUIP_TAG.FASHION] = "IsFashionCloth",
	[EQUIP_TAG.SOUL] = "IsSoul", 	
	[EQUIP_TAG.ALL] = "IsEquipment", 	
}

function game.getEquipmentType(type_id)
	if game.IsEquipment(type_id) then
		for k,v in pairs(checkTab) do
			if game[v](type_id) then
				return k
			end
		end
		return false
	end
	return false
end

function game.isEquipMatchType(type_id, etype)
	return etype == game.getEquipmentType(type_id)
end

function game.IsDissipative(type_id)
	if type_id > 10000 and type_id < 19999 then
		return true
	else
		return false
	end
end
function game.IsDrugDissipative(type_id)
	if type_id >= 10044 and type_id <= 10059 then
		return true
	else
		return false
	end
end

function game.IsWeapon(type_id)
	if type_id > Const.ITEM_WEAPON_BEGIN and type_id < Const.ITEM_WEAPON_END then
		return true
	else
		return false
	end
end

-- 时装武器
function game.IsFashionWeapon(type_id)
	if type_id > Const.ITEM_FASHION_WEAPON_BEGIN and type_id < Const.ITEM_FASHION_WEAPON_END then
		return true
	else
		return false
	end
end

-- 时装衣服
function game.IsFashionCloth(type_id)
    if type_id > Const.ITEM_FASHION_CLOTH_BEGIN and type_id < Const.ITEM_FASHION_CLOTH_END then
        return true
    else
        return false
    end
end

function game.IsCloth(type_id)
	if type_id > Const.ITEM_CLOTH_BEGIN and type_id < Const.ITEM_CLOTH_END then
		return true
	else
		return false
	end
end

function game.IsHat(type_id)
	if type_id > Const.ITEM_HAT_BEGIN and type_id < Const.ITEM_HAT_END then
		return true
	else
		return false
	end
end

function game.IsRing(type_id)
	if type_id > Const.ITEM_RING_BEGIN and type_id < Const.ITEM_RING_END then
        return true
	else
		return false
	end
end

function game.IsSpecailRing(type_id)
    if type_id > Const.ITEM_TEJIE_BEGIN and type_id < Const.ITEM_TEJIE_END then
        return true
    else
        return false
    end
end

function game.IsWeddingRing( type_id )
    return false
end

function game.IsGlove(type_id)
	if type_id > Const.ITEM_GLOVE_BEGIN and type_id < Const.ITEM_GLOVE_END then
		return true
	else
		return false
	end
end

function game.IsNecklace(type_id)
	if type_id > Const.ITEM_NECKLACE_BEGIN and type_id < Const.ITEM_NECKLACE_END then
		return true
	else
		return false
	end
end

function game.IsBelt(type_id)
	if type_id > Const.ITEM_BELT_BEGIN and type_id < Const.ITEM_BELT_END then
		return true
	else
		return false
	end
end

function game.IsBoot(type_id)
	if type_id > Const.ITEM_BOOT_BEGIN and type_id < Const.ITEM_BOOT_END then
		return true
	else
		return false
	end
end

-- 护符
function game.isHufu(type_id)
    if type_id > Const.ITEM_HUFU_BEGIN and type_id < Const.ITEM_HUFU_END then
        return true
    else
        return false
    end
end

-- 虎符
function game.isHufu2(type_id)
    if type_id > Const.ITEM_HUFU2_BEGIN and type_id < Const.ITEM_HUFU2_END then
        return true
    else
        return false
    end
end

--勋章
function game.IsMedal(type_id)
	if type_id > Const.ITEM_MEDAL_BEGIN and type_id < Const.ITEM_MEDAL_END then
		return true
	else
		return false
	end
end

--翅膀
function game.IsWing(type_id)
	if type_id > Const.ITEM_WING_BEGIN and type_id < Const.ITEM_WING_END then
		return true
	else
        return false
    end
end

-- 光翼
function game.IsLightWing(type_id)
    return false
end

--魂器
function game.IsSoul(type_id)
	if type_id > Const.ITEM_HUNQI_BEGIN and type_id < Const.ITEM_HUNQI_END then
		return true
	else
		return false
	end
end

--令牌
function  game.isLingpai( type_id )
    if not type_id then return false end
    if ( type_id >= Const.ITEM_LINGPAI_BEGIN ) and ( type_id < Const.ITEM_LINGPAI_END ) then
        return true
    end
    return false
end

--玉佩
function  game.isYupei( type_id )
    if not type_id then return false end
    if ( type_id >= Const.ITEM_YUPEI_BEGIN ) and ( type_id < Const.ITEM_YUPEI_END ) then
        return true
    end
    return false
end

--披风
function game.isPifeng( type_id )
    if not type_id then return false end
    if ( type_id >= Const.ITEM_PIFENG_BEGIN ) and ( type_id < Const.ITEM_PIFENG_END ) then
        return true
    end
    return false
end

-- 神器
function game.isShenqi(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_SHENQI_BEGIN ) and ( type_id < Const.ITEM_SHENQI_END ) then
        return true
    end
    return false
end

-- 神甲
function game.isShenjia(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_SHENJIA_BEGIN ) and ( type_id < Const.ITEM_SHENJIA_END ) then
        return true
    end
    return false
end

-- 龙魂
function game.isLonghun(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_LONGHUN_BEGIN ) and ( type_id < Const.ITEM_LONGHUN_END ) then
        return true
    end
    return false
end

--肩甲
function game.isJianjia(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_JIANJIA_BEGIN ) and ( type_id < Const.ITEM_JIANJIA_END ) then
        return true
    end
    return false
end

--宝石
function game.isBaoshi(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_BAOSHI_BEGIN) and ( type_id < Const.ITEM_BAOSHI_END ) then
        return true
    end
    return false
end

--盾牌
function game.isDunpai(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_DUNPAI_BEGIN ) and ( type_id < Const.ITEM_DUNPAI_END ) then
        return true
    end
    return false
end

--暗器
function game.isAnqi(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_ANQI_BEGIN ) and ( type_id < Const.ITEM_ANQI_END ) then
        return true
    end
    return false
end

--玉玺
function game.isYuxi(type_id)
    if not type_id then return false end
    if ( type_id >= Const.ITEM_YUXI_BEGIN ) and ( type_id < Const.ITEM_YUXI_END ) then
        return true
    end
    return false
end

function game.IsPosInAvatar(pos)
	if pos then
		if pos > -999 and pos < 0 then
			return true
		else
			return false
		end
	end
	return false
end
-- 自动设置快捷键的技能
function game.IsAutoSetSkill(skill_type)
    local list = SkillDef.AUTO_LEARN_LIST[game.getRoleJob()]
    for _, v in pairs(list) do
        if v== skill_type then return true end
    end
    return false
end

function game.IsPassiveSkill(skill_type) --被动技能
    local list = SkillDef.PASSIVE_LIST[game.getRoleJob()]
    for _, v in pairs(list) do
        if v== skill_type then return true end
    end
    return false
end

function game.IsAssistSkill(skill_type)--辅助技能
    local list = SkillDef.ASSIST_LIST[game.getRoleJob()]
    for _, v in pairs(list) do
        if v== skill_type then return true end
    end
    return false
end

function game.getMySkillList()
    local job = game.getRoleJob()
    local skills = SkillDef.SKILL_LIST[job] or {}
    local zsskills = SkillDef.SKILL_ZS_LIST[job] or {}

    local removeSkillId = {}
    for zsSkillId,oldIds in pairs(zsskills) do
        if NetClient.m_netSkill[zsSkillId] and NetClient.m_netSkill[zsSkillId].mLevel > 0 then
            for i = 1, #oldIds do
                table.insert(removeSkillId, oldIds[i])
            end
        end
    end

    local removeIndex = {}
    for i = 1, #removeSkillId do
        for j = 1, #skills do
            if skills[j] == removeSkillId[i] then
                table.insert(removeIndex, j)
                break
            end
        end
    end

    for i = 1, #removeIndex do
        table.remove(skills, removeIndex[i])
    end

    for i,v in pairs(NetClient.mItems) do
        if i == Const.ITEM_RING1_POSITION or i == Const.ITEM_RING2_POSITION or i == Const.ITEM_TEJIE_POSITION then
            if math.floor( v.mTypeID / 10 ) == 5037 then
                table.insert(skills, Const.SKILL_TYPE_BaoLieHuoYan)
            end
        end
    end
    return skills
end

function game.checkUp(skillid,rolelv, zslv,money)
    local lvinfo = NetClient:getSkillUpLevelInfo(skillid)
    if not lvinfo then return SkillDef.SKILL_LEARN_STATE.UNABLE end

    local skillDef = NetClient:getSkillDefByID(skillid)
    if not skillDef then return SkillDef.SKILL_LEARN_STATE.UNABLE end

    local learnInfo =  NetClient.m_netSkill[skillid]

    local needinfo
    if not learnInfo then
        needinfo = {}

        if  skillDef.NeedL1ZS > 0 then
            needinfo.needlvzs = skillDef.NeedL1ZS
        end

        if  skillDef.mNeedL1 > 0 then
            needinfo.needlv = skillDef.mNeedL1
        end

        if  skillDef.needgold > 0 then
            needinfo.bindgold = skillDef.needgold
        end

        if  skillDef.preskill > 0 then
            needinfo.needskill = skillDef.preskill
            needinfo.needskilllv = 1
        end

        if skillDef.objid > 0 then
            needinfo.needitem=skillDef.objid
            needinfo.needitemname="不存在"
            local itemdef = NetClient:getItemDefByID(needinfo.needitem)
            if itemdef then
                needinfo.needitemname=itemdef.mName
            end
            needinfo.neednum=1
        end
    else
        if learnInfo.mLevel >= skillDef.mLevelMax then
            return SkillDef.SKILL_LEARN_STATE.MAXLEVEL
        end
        needinfo = lvinfo[learnInfo.mLevel]
    end

    if not needinfo then return SkillDef.SKILL_LEARN_STATE.UNABLE end

    -- 玩家角色
    if (needinfo.needlv and rolelv < needinfo.needlv)
            or (needinfo.needlvzs and zslv < needinfo.needlvzs )
            or (needinfo.bindgold and money < needinfo.bindgold)
            or (needinfo.needitem and  needinfo.neednum and NetClient:getBagItemNumberById(needinfo.needitem) < needinfo.neednum )
    then
        if not learnInfo then
            return SkillDef.SKILL_LEARN_STATE.UNLEARN,needinfo
        else
            return SkillDef.SKILL_LEARN_STATE.UNUP,needinfo
        end
    end

    -- 前置技能
    if needinfo.needskill and  needinfo.needskilllv then
        local nowLevel = 0
        if NetClient.m_netSkill[needinfo.needskill] then
            nowLevel = NetClient.m_netSkill[needinfo.needskill].mLevel
        end
        if nowLevel < needinfo.needskilllv then
            if not learnInfo then
                return SkillDef.SKILL_LEARN_STATE.UNLEARN,needinfo
            else
                return SkillDef.SKILL_LEARN_STATE.UNUP,needinfo
            end
        end
    end

    if learnInfo then
        return SkillDef.SKILL_LEARN_STATE.CANUP,needinfo
    else
        return SkillDef.SKILL_LEARN_STATE.CANLEARN,needinfo
    end
end

function game.ShowExit()
	cc.Director:getInstance():endToLua()
	os.exit()
end

function game.getShorNum(_num)
    local num = _num or 0
    num = checkint( num )
    if num >= 100000000 then
        if num%100000000 == 0 then
            return math.floor( num/100000000 ).."亿"
        else
            return string.format("%0.1f亿", num/100000000)
        end
    elseif num >= 10000 then
        if num%10000 == 0 then
            return math.floor( num/10000 ).."万"
        else
            return string.format("%0.1f万", num/10000)
        end
    else
        return num
    end
end

function game.getJobStr(mjob)
    if mjob == Const.JOB_ZS then
        return Const.str_zs
    elseif mjob == Const.JOB_FS then
        return Const.str_fs
    elseif mjob == Const.JOB_DS then
        return Const.str_ds
    end
    return "无"
end

function game.isRareEquip(type_id,color )
    return false
--    return game.IsEquipment(type_id) and color > 3
end

function game.canRecyle(itemdef)
    if itemdef.mHunshi > 0 or itemdef.mHuishouExp > 0 then
        return true
    end
    -- TODO 还有其他条件
    return false
end

function game.getSellPrice(itemDef, netItem)
    if itemDef == nil then
        return 0
    end

    local price = itemDef.mPrice
    local sp = 0

    if netItem and game.IsEquipment(itemDef.mTypeID) then
        sp = math.floor( price * netItem.mDuration / 3 / netItem.mDuraMax )
    else
        sp = math.floor( price / 3 )
    end

    if sp <= 0 then
        sp = 1
    end

    return sp
end

-- 返回 nil 不能修理
function game.getRepairPreice(itemDef, netItem)
    if itemDef == nil or netItem == nil then
        return nil
    end

    local du = math.floor(netItem.mDuration/1000 + 1)
    local duma = math.floor(netItem.mDuraMax/1000 + 1)

    if du >= duma then
        return nil
    end


    local d = netItem.mDuraMax - math.min( netItem.mDuraMax,math.max( 0,netItem.mDuration ) )
    local gold =  math.floor( itemDef.mPrice / 3.0 / netItem.mDuraMax * d)

    if gold <= 0 then
        return nil
    end


    return gold
end

function game.getRoleJob()
    if game.GetMainNetGhost() then
        return game.GetMainNetGhost():NetAttr(Const.net_job)
    end

    return 0
end

function game.getRoleGender()
    if game.GetMainNetGhost() then
        return game.GetMainNetGhost():NetAttr(Const.net_gender)
    end

    return 0
end

function game.getRoleLevel()
    if game.GetMainNetGhost() then
        return game.GetMainNetGhost():NetAttr(Const.net_level)
    end

    return 0
end

function game.getVipLevel()
    local vipLevel = NetClient.mVIPLevel
    return vipLevel
end

-- 1 差值 2 下级VIP需要的总共的元宝
function game.getNextVipLevelNeedTotal()
    if NetClient.mVIPLevel == #VipDefData.list then
        print("11111")
        return  -1,VipDefData.list[#VipDefData.list].mNeedYuanbao -- 已达最高级
    end

    local nextinfo = VipDefData.list[NetClient.mVIPLevel+1]
    if not nextinfo then
        print("33333")
        return -1,VipDefData.list[#VipDefData.list].mNeedYuanbao -- 已达最高级
    end

    return math.max(nextinfo.mNeedYuanbao - NetClient.mLeijiChongzhiYb,0), nextinfo.mNeedYuanbao
end

function game.getZsLevel()
    return NetClient.mRebornLevel or 0
end

function game.haveGuild()
    local mainRole = NetCC:getMainGhost()
    if mainRole:NetAttr(Const.net_guild_title) and mainRole:NetAttr(Const.net_guild_title) > 101 and mainRole:NetAttr(Const.net_guild_name) and string.len(mainRole:NetAttr(Const.net_guild_name)) > 0 then
        return true
    else
       return false
    end
end

function game.addAniToBody(group, srcid, binid, dir, offset)
    if binid <= 0 then
        return
    end

    local pixesAvatar = CCGhostManager:getPixesAvatarByID(srcid)
    if not pixesAvatar then
        return
    end

    local ptype = pixesAvatar:getType()
    if ptype ~= Const.GHOST_PLAYER and ptype ~= Const.GHOST_THIS then
        return
    end

    local aniImg = cc.Sprite:create()
    if cc.AnimManager:getInstance():getBinAnimateAsync(aniImg,group,binid,dir) then
        local body = pixesAvatar:getSprite()
        aniImg:setScale(0.5)
        aniImg:setPosition(offset)
        body:addChild(aniImg, 50)
    end
end

function game.getMyInsigh(parent)
    if not parent then return end

    -- 翅膀
    local wing
    if NetClient.mCharacter.mLookWing and NetClient.mCharacter.mLookWing > 0 then
        wing=NetClient.mCharacter.mLookWing
    end
    -- 衣服
    local cloth
    local netitem = NetClient:getNetItem(Const.ITEM_CLOTH_POSITION)
    if netitem then
        local itemdef = NetClient:getItemDefByID(netitem.mTypeID)
        if itemdef then
            cloth = itemdef.mIconID
        end
    else
        cloth = Const.DEFAULT_STATEITEM[game.GetMainNetGhost():NetAttr(Const.net_gender)]
    end

    -- 武器
    local weapon
    local netitem = NetClient:getNetItem(Const.ITEM_WEAPON_POSITION)
    if netitem then
        local itemdef = NetClient:getItemDefByID(netitem.mTypeID)
        if itemdef then
            weapon = itemdef.mIconID
        end
    end
    game.getInsigh({parent = parent,wing = wing,cloth = cloth,weapon = weapon})
end

function game.getInsigh(params)
    if not params then return end
    if not params.parent then return end

    local bgSize = params.parent:getContentSize()
    local scale = params.scale or 1.3
    if params.wing then
        ccui.ImageView:create("stateitem/"..params.wing..".png",UI_TEX_TYPE_LOCAL)
        :align(display.CENTER, bgSize.width/2-10, bgSize.height/2)
        :addTo(params.parent)
        :setScale(scale)
    end

    if params.cloth then
        ccui.ImageView:create("stateitem/"..params.cloth..".png",UI_TEX_TYPE_LOCAL)
        :align(display.CENTER, bgSize.width/2, bgSize.height/2)
        :addTo(params.parent)
        :setScale(scale)
    end

    if params.weapon then
        ccui.ImageView:create("stateitem/"..params.weapon..".png",UI_TEX_TYPE_LOCAL)
        :align(display.CENTER, bgSize.width/2, bgSize.height/2)
        :addTo(params.parent)
        :setScale(scale)
    end
end

function game.getMyModel(typeid,resid)
    local modelBg = cc.Sprite:create()
    local mycloth = game.GetMainRole():NetAttr(Const.net_cloth)
    local clothImg = cc.Sprite:create()
    if cc.AnimManager:getInstance():getBinAnimateAsync(clothImg,Const.AVATAR_TYPE.AVATAR_CLOTH,mycloth*100,4) then
        clothImg:addTo(modelBg)
    end

    local groupid
    local dir

    if game.IsCloth(typeid) or game.IsFashion(typeid) then
        clothImg:removeFromParent()
        groupid = Const.AVATAR_TYPE.AVATAR_CLOTH
        dir = 4
    elseif game.IsWeapon(typeid) or game.IsFashionWeapon(typeid) then
        groupid = Const.AVATAR_TYPE.AVATAR_WEAPON
        dir = 0
    elseif game.IsWing(typeid) or game.IsLightWing(typeid) then
        groupid = Const.AVATAR_TYPE.AVATAR_WING
        dir = 4
    end

    if groupid and dir then
        local ani = cc.Sprite:create()
        if cc.AnimManager:getInstance():getBinAnimateAsync(ani,groupid,resid*100,dir) then
            ani:addTo(modelBg,-1)
        end
    end

    return modelBg
end

function game.numberRound( number , keep )
    if not number or not keep or type(keep) ~= "number" then return end
    str = tostring(number)
    tag = "%.".. keep .."f"
    ret = tonumber(string.format(tag, str))
    return ret
end

function game.clearNumStr(str)
    local ret= string.gsub(str, "(%d+)", "")
    return ret
end

function game.checkBtnClick()
    if game.lastClickBtn == nil then
        game.lastClickBtn = game.getTime()
        return true
    end

    local cur = game.getTime()
    if cur - game.lastClickBtn < 1000 then
        return false
    end

    game.lastClickBtn = cur
    return true
end

-- #define kCCNetworkStatusNotReachable     0
-- #define kCCNetworkStatusReachableViaWiFi 1
-- #define kCCNetworkStatusReachableViaWWAN 2
function game.isLocalWiFiAvailable()
    -- 因为IOS的底层方法判断错误，要修改一下调用的方法
    if device.platform == "ios" then
        return ncc.Network:getInternetConnectionStatus() == 1 -- 1是wifi的枚举
    else
        return cc.Network:isLocalWiFiAvailable()
    end
end

function game.unicode_to_utf8(convertStr)

    if type(convertStr)~="string" then
        return convertStr
    end

    local bit = require("bit")
    local resultStr=""
    local i=1
    while true do
        
        local num1=string.byte(convertStr,i)
        local unicode
        
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end

        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit.band(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
            resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
        end
    end
    resultStr=resultStr..'\0'
    resultStr = string.gsub(resultStr,'\\','')
    return resultStr
end

function game.checkDuidie(srcnetitem)
    if game.IsEquipment(srcnetitem.mTypeID) then
        return false
    end

    for pos,netItem in pairs(NetClient.mItems) do
        if netItem.mTypeID == typeId and pos ~= srcnetitem.position and game.IsPosInBag(pos) and netItem.mItemFlags == srcnetitem.mItemFlags then
            return pos
        end
    end
    return false
end

function game.checkSplit(srcnetitem)
    if game.IsEquipment(srcnetitem.mTypeID) then
        return false
    end

    return srcnetitem.mNumber > 1
end

function game.checkActive(srcnetitem)
    if srcnetitem.mTypeID >= 12001 and srcnetitem.mTypeID <= 12012 then
        return true
    end

    return false
end

function game.isFuncOpen(id)
    for k, v in ipairs(NetClient.mOpenFunc) do
        if v == id then
            return true
        end
    end

    return false
end

function game.getFuncInfo(id)
    return GuideDef.list[id]
end

function game.getFuncOpenLevel(id)
    local def = GuideDef.list[id]
    if not def then return 0 end
    if def.level and def.level > 0 then
        return def.level
    end
    return 0
end

function game.getPreFuncInfo(mlv)
    for _, v in ipairs(NetClient.mPromptInfo) do
        if mlv < v.level and not game.isFuncOpen(v.funcid) then
            local finfo = game.getFuncInfo(v.funcid)
            if finfo then
                return finfo
            end
        end
    end
end

function game.calc_advance_item_type(typeID)
    local nmod1 = math.fmod(typeID,1000);
    local nmod2 = math.fmod(nmod1,100);
    local nQuality=math.floor(nmod1/100);
    local nNewQuality = nQuality + 1;
    local newTypeID = typeID - nmod1;
    newTypeID = newTypeID + math.floor(nNewQuality*100) + nmod2;
    return newTypeID;
end

function game.calc_item_quality(typeID)
    local nmod1 = math.fmod(typeID,1000);
    local nQuality=math.floor(nmod1/100);
    return nQuality;
end

function game.make_str_with_color( color,text )
    return "<font color='"..color.."'>"..text.."</font>"
end

game.chatFacePatternStr = "#f%d+#"

function game.tranFaceShow(msg)
    local oldstr = string.match(msg, game.chatFacePatternStr)
    while oldstr do
        local fid = checkint(string.match(oldstr, "%d+"))
        local restr = string.format("<pic src='face_%02d.png'/>", fid)
        msg = string.gsub(msg,oldstr,restr)
        oldstr = string.match(msg, game.chatFacePatternStr)
    end
    return msg
end

function game.get_net_msg_str(netChat)
    if not netChat then return "" end

    local colorStr = "#FFFF00"

    if netChat.m_strType then
        colorStr = Const.CHANNEL_COLOR[netChat.m_strType].prefixColor
    end

    local strMsg = ""
    if netChat.m_strType then
        strMsg = "<font color=\""..colorStr.."\" >"..netChat.m_strType.."</font>"
    end

    if netChat.m_strName == nil then netChat.m_strName = "" end

    -- TODO GM

    if netChat.m_strName ~= "" then
        if netChat.m_strName == game.mChrName then
            strMsg = strMsg..game.make_str_with_color(Const.COLOR_YELLOW_3_OX, "你")
        else
            if netChat.m_strType == Const.chat_prefix_private then
                strMsg = strMsg.."<a href=\"event:speeker_"..netChat.m_strName.."\" color=\""..Const.COLOR_BLUE_1_OX.."\" islabel=1>"..netChat.m_strName.."</a>"
            else
                strMsg = strMsg.."<a href=\"event:speeker_"..netChat.m_strName.."\" color=\""..Const.COLOR_BLUE_1_OX.."\" islabel=\"1\">"..netChat.m_strName.."</a>"
            end
        end
    end

    strMsg = strMsg..netChat.m_strMsg
    return strMsg
end

game.chatItemPatternStr = "##%--%d+,.-[^#]##"

-- 消息发送出去之前，解析装备<a></>信息
function game.tranItemShow(msg)
    local itempos
    local netitem
    local arrstr
    local oldstr = string.match(msg, game.chatItemPatternStr)
    while oldstr do
        arrstr = string.gsub(oldstr, "#", "")
        local attr = string.split(arrstr, ",")
        local tostr = attr[2] or ""
        itempos = checkint(attr[1])
        netitem = NetClient:getNetItem(itempos)
        local itemdef = NetClient:getItemDefByID(netitem.mTypeID)
--        print("", oldstr, arrstr, tostr, itempos, netitem, itemdef)
        if netitem and itemdef then
--            tostr = "<a href=\"event:itemshow_"..game.genChatItemTip(netitem).."\" islabel=\"1\">["..itemdef.mName.."]</a>"
            tostr = "<p>"..game.genChatItemTip(netitem).."</p>"
        end
        msg = cc.SystemUtil:replaceStr(msg,oldstr,tostr)--string.gsub(msg,oldstr,tostr)
        oldstr = string.match(msg, game.chatItemPatternStr)
    end

--    print("oldstr====", oldstr)
    return msg
end

function game.getMapSound(map_id)
    local FilePath = cc.FileUtils:getInstance():fullPathForFilename("map/"..map_id..".txt")
    local mapTxt = {}
    local soundFile = io.open(FilePath)
    local mp3FileName = nil
    if soundFile then
        local ls = {}
        local index = 0
        for l in soundFile:lines() do
            index = index + 1
            ls[index] = l
        end
        mapTxt = string.split(ls[1],",")
        soundFile:close()
        if #mapTxt > 0 then
            mp3FileName = mapTxt[#mapTxt]
            return mp3FileName
        end
    end
    print("音效文件",mp3FileName)
    return mp3FileName
end

function game.genChatItemTip(netitem)
    local str = netitem.position..","..netitem.mTypeID..","..netitem.mDuraMax..","..netitem.mDuration..","..netitem.mItemFlags..","..
            netitem.mLevel..","..netitem.mNumber..","..netitem.mAddAC..","..netitem.mAddMAC..","..netitem.mAddDC..","..
            netitem.mAddMC ..","..netitem.mAddSC..","..netitem.mUpdAC..","..netitem.mUpdMAC..","..netitem.mUpdDC..","..
            netitem.mUpdMC ..","..netitem.mUpdSC..","..netitem.mLuck..","..netitem.mProtect..","..netitem.mAddHp..","..
            netitem.mAddMp
    return str
end

function game.parseChatItemTip(str)
    local attr = string.split(str, ",")
    if #attr == 0 then return end
    local netitem = {}
    netitem.position = checkint(attr[1])
    netitem.mTypeID = checkint(attr[2])
    netitem.mDuraMax = checkint(attr[3])
    netitem.mDuration = checkint(attr[4])
    netitem.mItemFlags   = checkint(attr[5])
    netitem.mLevel = checkint(attr[6])
    netitem.mNumber = checkint(attr[7])
    netitem.mAddAC = checkint(attr[8])
    netitem.mAddMAC = checkint(attr[9])
    netitem.mAddDC = checkint(attr[10])
    netitem.mAddMC = checkint(attr[11])
    netitem.mAddSC = checkint(attr[12])
    netitem.mUpdAC = checkint(attr[13])
    netitem.mUpdMAC = checkint(attr[14])
    netitem.mUpdDC = checkint(attr[15])
    netitem.mUpdMC = checkint(attr[16])
    netitem.mUpdSC = checkint(attr[17])
    netitem.mLuck = checkint(attr[18])
    netitem.mProtect = checkint(attr[19])
    netitem.mAddHp = checkint(attr[20])
    netitem.mAddMp = checkint(attr[21])

    return netitem
end

function game.genNetItemByLevel(type_id,level)

    local itemdef = NetClient:getItemDefByID(type_id)
    if not itemdef then return end
    if not EquipDefData[level]  then return end
    local lv_info = EquipDefData[level]


    local rac,rmac,rdc,rmc,rsc=0,0,0,0,0;
    local rdc_max, rmc_max, rsc_max=0,0,0;

    if itemdef.mACMax > 0 then rac=lv_info.rac; end;
    if itemdef.mMACMax > 0 then rmac=lv_info.rmac; end;
    if itemdef.mDCMax > 0 then rdc=lv_info.rdc; rdc_max=lv_info.rmdc; end;
    if itemdef.mMCMax > 0 then rmc=lv_info.rmc; rmc_max=lv_info.rmmc; end;
    if itemdef.mSCMax > 0 then rsc=lv_info.rsc; rsc_max=lv_info.rmsc; end;

    local netitem = {}
    netitem.mItemFlags = 0
    netitem.mLevel = level
    netitem.mNumber = 1
    netitem.mUpdAC = rac
    netitem.mUpdMAC = rmac
    netitem.mUpdDC = rdc --物理攻击
    netitem.mUpdMC = rmc -- 魔法攻击
    netitem.mUpdSC = rsc --道术攻击

    netitem.mUpdDCMAX = rdc_max -- 最大物理攻击
    netitem.mUpdMCMAX = rmc_max -- 最大魔法攻击
    netitem.mSCMAX = rsc_max--最大道术攻击

    return netitem
end

function game.getItemTipsView(params)
    local detailBg
    if game.IsEquipment(params.typeID) then
        detailBg = require("app.views.tips.EquipTipsView").new(params)
    else
        detailBg = require("app.views.tips.PropTipsView").new(params)
    end
    return detailBg
end

function game.showActOpenView()
    if not NetClient.isEnterGame then return end
    local actname, actid
    local strarr = string.split(NetClient.mDailyActOpenStr, "_")
    if checkint(strarr[5]) <= game.getRoleLevel() and checkint(strarr[6]) == 1 then
        actname = strarr[1]
        actid = strarr[2]
    end

    if not actid or not actname then
       return
    end

    local param = {
        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = game.make_str_with_color( Const.COLOR_YELLOW_2_STR,actname ).."开始啦！点击确定传送到活动入口处参与吧",
        confirmTitle = "确  定", cancelTitle = "关  闭",
        autoclose = true,
        confirmCallBack = function ()
            NetClient:PushLuaTable("actlist",util.encode({actionid="goact",param=actid}))
        end
    }
    NetClient:dispatchEvent(param)
end

function game.playSoundByID(sound_id,loop,isBGM)
   if not loop then loop = false end
   if isBGM then game.mPausedMusic = sound_id end
   if isBGM and game.SETTING_TABLE["music_control"] then
       SimpleAudioEngine:playMusic(sound_id,loop)
   elseif isBGM then
       SimpleAudioEngine:stopMusic(true)
       return
   end
   if game.SETTING_TABLE["audio_control"] then
       SimpleAudioEngine:playEffect(sound_id,loop)
   end
end

function game.preloadEffect(sound_id)
   SimpleAudioEngine:preloadEffect(sound_id)
end

function game.isDamageSkill(skill_type)
    if skill_type == Const.SKILL_TYPE_YiBanGongJi or skill_type == Const.SKILL_TYPE_HuoQiuShu
        or skill_type == Const.SKILL_TYPE_LeiDianShu or skill_type == Const.SKILL_TYPE_BingPaoXiao
        or skill_type == Const.SKILL_TYPE_HuoLongQiYan or skill_type == Const.SKILL_TYPE_LiuXingHuoYu
        or skill_type == Const.SKILL_TYPE_LieHuoLiaoYuan or skill_type == Const.SKILL_TYPE_HanBingZhang
        or skill_type == Const.SKILL_TYPE_FenTianLieYan or skill_type == Const.SKILL_TYPE_ShiDuShu
        or skill_type == Const.SKILL_TYPE_LingHunHuoFu then
        return true
    end
    return false
end

function game.checkBagSlotFreeOpen(index)
    if not SlotDefData[index] then return end
    if SlotDefData[index].mOpenType == Const.SLOT_OPEN_TYPE.LEVEL or SlotDefData[index].mOpenType == Const.SLOT_OPEN_TYPE.LEVEL_OR_VCOIN then
        if game.getRoleLevel() >= SlotDefData[index].mMinLevel then
            return true
        end
        return false, SlotDefData[index].mMinLevel
    end

    return false
end

function game.getBagSlotPrice()
--    print(" game.getBagSlotPrice()", Const.ITEM_BAG_SIZE, NetClient.mBagSlotAdd)
    local startid = Const.ITEM_BAG_SIZE + NetClient.mBagSlotAdd + 1;
    local addnum = 0
    local addexp = 0
    local needvcoin = 0
    local needLevel = 0
    for i = startid, #SlotDefData do
--        print("", i)
        addnum = addnum + 1
        addexp = addexp + SlotDefData[i].mExp
        if SlotDefData[i].mOpenType == Const.SLOT_OPEN_TYPE.LEVEL then
--            只等级
            needlevel = math.max(needLevel, SlotDefData[i].mMinLevel)
        elseif SlotDefData[i].mOpenType == Const.SLOT_OPEN_TYPE.VCOIN then
            --                只元宝
            needvcoin = needvcoin + SlotDefData[i].mNeedYuanbao
        elseif SlotDefData[i].mOpenType == Const.SLOT_OPEN_TYPE.LEVEL_OR_VCOIN then
            -- 等级和元宝都可以
            needvcoin = needvcoin + SlotDefData[i].mNeedYuanbao
            needLevel = math.max(needLevel, SlotDefData[i].mMinLevel)
        end
        if SlotDefData[i].mStop == 1 then
            break
        end
    end
    if needLevel > 0 and needvcoin > 0 then
        if game.getRoleLevel() >= needLevel  then
            needvcoin = 0
        end
    end

--    print("", needvcoin,addnum,addexp)

    return needvcoin,addnum,addexp
end

function game.queryQuickBuyInfo(subType)
    NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({actionid="queryquickbuyitem",subtype=subType}))
end

function game.queryManyQuickBuyInfo(subTypes)
    NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({actionid="queryquickbuyitem_many"}))
end

function game.showQuickByPanel(param)
    NetClient:dispatchEvent( {
        name = Notify.EVENT_PANEL_ON_ALERT, panel = "buy", visible = true,
        itemid = param.typeid,itemprice = param.sellyb,itemnum = 1,
        itembuyflag = param.priceflag-1,itembindflag = param.bindflag,
        confirmTitle = "购 买", cancelTitle = "取 消",
        confirmCallBack = function (num,typeid)
            NetClient:PushLuaTable("newgui.quickbuy.process_quick_buy",util.encode({actionid="new_quickbuy", param={itemid=typeid,num=num}}))
        end
    })
end

function game.isKingLeader()
    if NetClient.mHasKing ~= 1 or NetClient.mKingOfKings ~= game.GetMainRole():NetAttr(Const.net_name) then
        return false
    end
    return true
end

function game.openFangchengmi()
    NetClient:dispatchEvent({name=Notify.EVENT_FANGCHENMI_CHANGE})
    if NetClient.mFcmInfo.china_id ~= Const.FCM_TYPE.PASS then
        if NetClient.mFcmInfo.china_limit_lv == 1 then
            NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_fcm"})
        elseif NetClient.mFcmDescList[NetClient.mFcmInfo.china_limit_lv] then
            if  NetClient.mFcmInfo.china_id == Const.FCM_TYPE.UNVALID then
                local param = {
                    nname = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true, lblConfirm = NetClient.mFcmDescList[NetClient.mFcmInfo.china_limit_lv],
                    confirmTitle = "实名认证", cancelTitle = "取 消",
                    confirmCallBack = function ()
                        NetClient:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_fcm"})
                    end
                }
                NetClient:dispatchEvent(param)
            else
                local param = {
                    name = Notify.EVENT_PANEL_ON_ALERT, panel = "alert", visible = true, lblAlert=NetClient.mFcmDescList[NetClient.mFcmInfo.china_limit_lv],
                    alertTitle = "知道了",
                    alertCallBack = function ()
                    end
                }
                NetClient:dispatchEvent(param)
            end
        end
    end

end

function game.getStatusDescDefByID(statusid, lv)
    local ids = {Const.STATUS_TYPE_MOFADUN, Const.STATUS_TYPE_YINGSHEN,Const.STATUS_TYPE_YOULINGDUN,Const.STATUS_TYPE_SHENSHENGZHANJIASHU,
        Const.STATUS_TYPE_POSION_HP,Const.STATUS_TYPE_POSION_ARMOR,Const.STATUS_TYPE_MOFADUN_ADV,Const.STATUS_TYPE_POSION_ATTACK }
    for k, v in ipairs(ids) do
        if statusid == v then
            lv = 1
            break
        end
    end
    local desc = StatusDescDefData[tostring(statusid*10000+lv)]
    if not desc then
        return
    end

    if not desc.mShowType or desc.mShowType == 0 then
        return
    end

    return desc
end

function game.getVersionStr()
    return string.format("v:%s src:%d", PlatformUtil.getApkVersionName(), 10)
end

-- 返回 选择可领的第一个 选择没领过的第一个
function game.getSevenLoginSelectedId()
    local firstValidId
    local firstNextId
    for i = 1, #SevenLoginDefData do
        local getInfo = NetClient.mSevenLoginInfo.state[i]
        if getInfo then
            if getInfo.accept ~= 1 then
                if getInfo.allow == 1 then
                    if not firstValidId then firstValidId = i end
                else
                    if not firstNextId then firstNextId = i end
                end
            end
        end
    end
    return firstValidId,firstNextId
end

function game.getSevenLoginDef(id)
    local sevenLoginDef = SevenLoginDefData[id]
    return sevenLoginDef
end

function game.checkVipOpened(key)
    local openLevel = 0
    for level, info in ipairs(VipDefData.list) do
        if info.tequanlist[key] ~= 0 then
            openLevel = level
            break
        end
    end

    local myVipLevel = game.getVipLevel()
    if myVipLevel < openLevel then
        return false,openLevel
    else
        return true,openLevel
    end
end

function game.isLiehuoSkill(skill_type)
    if not skill_type then return false end
    if skill_type == Const.SKILL_TYPE_PoTianZhan
            or skill_type == Const.SKILL_TYPE_LieHuoJianFa or skill_type == Const.SKILL_TYPE_ZhuRiJianFa
            or skill_type == Const.SKILL_TYPE_PoKongJianFa or skill_type == Const.SKILL_TYPE_ZhuTianJianFa then
        return true
    end
end

function game.isAllCishaSkill(skill_type)
    if not skill_type then return false end
    if skill_type == Const.SKILL_TYPE_BanYueWanDao
    or skill_type == Const.SKILL_TYPE_CiShaJianShu or skill_type == Const.SKILL_TYPE_LongYingJianQi then
        return true
    end
end

function game.isZsChongZhuangSkill(skill_type)
    if not skill_type then return false end
    if skill_type == Const.SKILL_TYPE_YeManChongZhuang
            or skill_type == Const.SKILL_TYPE_LeiTingChongJi then
        return true
    end
end

function game.isFsDun(skill_type)
    if not skill_type then return false end
    if skill_type == Const.SKILL_TYPE_MoFaDun
            or skill_type == Const.SKILL_TYPE_XuanGuangDun then
        return true
    end

end

function game.isDsDu(skill_type)
    if not skill_type then return false end
    if skill_type == Const.SKILL_TYPE_ShiDuShu
            or skill_type == Const.SKILL_TYPE_TianZunQunDu then
        return true
    end
end

return game
