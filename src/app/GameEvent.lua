EVENT={

LUAEVENT_INIT_GAME=0,
LUAEVENT_ASYNCLOAD_TEXTURE=1,
LUAEVENT_ASYNCLOAD_FRAMES=2,
LUAEVENT_SOCKET_ERROR=3,
LUAEVENT_ON_MESSAGE=4,

LUAEVENT_ENTER_GAME=10,
LUAEVENT_ENTER_MAP=11,
LUAEVENT_SCENE_GAME_ENTER=12,
LUAEVENT_SCENE_GAME_EXIT=13,
LUAEVENT_SCENE_GAME_UPDATE=14,
LUAEVENT_SELECT_SOME_ONE=15,
LUAEVENT_ON_ATTACKED=16,

LUAEVENT_DO_ACTION=20,
LUAEVENT_AUTOMOVE_START=21,
LUAEVENT_AUTOMOVE_END=22,
LUAEVENT_MAINROLE_ATTACH=23,
LUAEVENT_MAINROLE_DETACH=24,
LUAEVENT_MAINROLE_UPDATE=25,
LUAEVENT_MAINROLE_TICK_UPDATE=26,
LUAEVENT_MAINROLE_ACTIONSTART=27,
LUAEVENT_MAINROLE_ACTIONEND=28,

LUAEVENT_MAP_MEET=29,
LUAEVENT_MAP_BYE=30,

LUAEVENT_GHOST_DIE=31,
LUAEVENT_GHOST_INJURY=32,
LUAEVENT_STATUS_CHANGE=33,
LUAEVENT_UPDATE_NAME=34,
LUAEVENT_PING_UPDATE=35,
LUAEVENT_UPDATE_NPC_FLAG=36,
}

local framescallback={}

function asyncload_frames(filename,filetype,callback,txttype)
	if type(filename) == "string" then
		if not framescallback[filename] then
			framescallback[filename]={}
        end
        if #framescallback[filename] > 0 then
            table.insert(framescallback[filename],callback)
        else
            table.insert(framescallback[filename],callback)
            cc.SpriteManager:getInstance():asyncLoadSpriteFrames(filename,filetype,txttype)
        end
	end
end

function remove_frames(filename,filetype)
    print(string.format("remove_frames==%s%s", filename or "",filetype or ""))
	cc.SpriteManager:getInstance():removeFramesByFile(filename)
	
	if filetype then 
		cc.CacheManager:getInstance():releaseCache(filename..filetype)
	end
	
end

function remove_frames_by_callback(filename,filetype, callback)
    if not framescallback[filename] then remove_frames(filename,filetype) return end
    remove_frames_callback(filename, callback)
    if framescallback[filename] and type(framescallback[filename])=="table" then
        if #framescallback[filename] == 0 then
            remove_frames(filename,filetype)
        end
    end
end

function remove_frames_callback(filename, callback)
    if callback and type(filename) == "string" then
        if framescallback[filename] and type(framescallback[filename])=="table" then
            for k,v in pairs(framescallback[filename]) do
                if v == callback then
                    table.remove(framescallback[filename], k)
                    return
                end
            end
        end
    end
end

function frames_callback(filename)
	if framescallback[filename] and type(framescallback[filename])=="table" then
		for _,v in pairs(framescallback[filename]) do
			if v then
				v(filename)
			end
		end
		framescallback[filename]=nil
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ASYNCLOAD_FRAMES,"frames_callback")

local loadcallback={}

function asyncload_callback(filepath,ccnode,callback,retain)
	if not retain then retain =false end
	
	if type(filepath) == "string" then
		if not loadcallback[filepath] then
			loadcallback[filepath]={}
			-- setmetatable(loadcallback[filepath],{__mode = "v"}) 		
		end
		table.insert(loadcallback[filepath],callback)
		if ccnode then
			cc(ccnode):addNodeEventListener(cc.NODE_EVENT, function(event)
	            if event.name == "exit" then
	                -- callback=nil
	                if loadcallback[filepath] then
	                	table.removebyvalue(loadcallback[filepath],callback)
	                end
	            end
	        end)
		else
			print("asyncload_callback has not target !!!")
		end
	end
	cc.CacheManager:getInstance():asyncLoad(filepath,retain)
end

function asyncload_list(filelist,ccnode,callback)
	if type(filelist)=="table" then
		local len=#filelist
		local step=0
		local res={}
		for i=1,len do
			asyncload_callback(filelist[i],ccnode,function(path,pic)
				step=step+1
				res[path]=pic
				pic:retain()
				if step>=len then
					callback(filelist,res)
					for _,v in pairs(res) do
						if v and v.release then
							v:release()
						end
					end
				end
			end)
		end
	end
end

function texture_callback(filepath,texture)
	-- print(filepath)
	if loadcallback[filepath] and type(loadcallback[filepath])=="table" then
--		print(#loadcallback[filepath])
		for _,v in pairs(loadcallback[filepath]) do
			if v then
				v(filepath,texture)
			end
		end
		loadcallback[filepath]=nil
	end
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ASYNCLOAD_TEXTURE,"texture_callback")

function update_ghost_name( ghostid,mnametext,str )
	local item=NetCC:getGhostByID(ghostid)
	if item then
		if item:NetAttr(Const.net_type) == Const.GHOST_ITEM then
			local item_name = item:NetAttr(Const.net_name)
			local itemdef = NetClient:getItemDefByName(item_name)
			if itemdef then
				if mnametext then
					mnametext:setColor(game.getColor( itemdef.mColor ))
				end
				if (not game.IsDissipative(itemdef.mTypeID)) and game.SETTING_TABLE["check_show_level"] and itemdef.mNeedParam < game.SETTING_TABLE["num_show_level"] then--需求显示等级
					mnametext:getParent():hide()
				end
			end
		end
	end
end

cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_UPDATE_NAME,"update_ghost_name")
