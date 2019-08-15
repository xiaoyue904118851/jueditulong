local platform_ios=false
local platform_android=false

local luaoc=nil
local luaj=nil

if device.platform == "ios" then
	luaoc=require("cocos.cocos2d.luaoc")
	platform_ios=true
elseif device.platform == "android" then
	luaj=require("cocos.cocos2d.luaj")
	platform_android=true
else
	platform_windows=true
end

PlatformTool={}

local javaClassName = "org/cocos2dx/lua/LuaJavaBridge"
local ocClassName = "LuaObjectCBridge"

function platform_listener(param)
	print("platform_listener", param)
	local params=string.split(param,"|")
	if params then
		if params[1]=="onLogin" then
			PlatformCenter.onLogin(param)
		elseif params[1]=="onLogout" then
			PlatformCenter.onLogout()
		end
	end
end
function callback(result)
    print("setLoginCallback"+result) -- 会打印出ok
end
function G_CallbackFromJava(msg)
	print("setLoginCallback"+msg) -- 会打印出ok
end
function PlatformTool.setPlatfromListener()
	if platform_android then
		local javaMethodName = "setPlatfromListener"
		local javaParams = {platform_listener}

		local javaMethodSig = "(I)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		end
	elseif platform_ios then
		local ocMethodName = "setPlatfromListener"
		local ocParams = {listener=platform_listener}
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		if not ok then
			print("luaoc error:", ret)
		end
	end
end

function PlatformTool.callPlatformFunc(params)
	if type(params)~="table" then return end
	if platform_android then
		local javaMethodName = "callPlatformFunc"
		local javaParams = {util.encode(params)}

		local javaMethodSig = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		end
	elseif platform_ios then
		local ocMethodName = "callPlatformFunc"
		local ocParams = params
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		if not ok then
			print("luaoc error:", ret)
		end
	end
end

function  PlatformTool.login()
	if platform_android then
		local javaMethodName = "onLogin"
		local javaParams = {}
		local javaMethodSig = "()V"
		local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity",javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		end
	elseif platform_ios then
		-- local ocMethodName = "callPlatformFunc"
		-- local ocParams = params
		-- local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		-- if not ok then
		-- 	print("luaoc error:", ret)
		-- end
	end
end
function  PlatformTool.setLoginCallback()
	if platform_android then
		function tempCallBack(msg)
			-- body
			print("msg +++++++++:", msg)
			local params=string.split(msg,"&")
			for i=1,#params do
				print("params",params[i])
			end
			if gameLogin and params then 	
				gameLogin.channelId = params[2]
				gameLogin.channelUid = params[3]
				local name = params[1]
				gameLogin.setLoginAccount(name)	

				if gameLogin.SceneLogin then
					gameLogin.SceneLogin.showSendText()
				end		

			end
		end
		local javaMethodName = "setLoginCallback"
		
		-- local viplevel = game.getVipLevel()
  --  		local rolelevel = game.getRoleLevel()

		local javaParams = {"callbacklua",tempCallBack}
		local javaMethodSig = "(Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity",javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		end
	elseif platform_ios then
		-- local ocMethodName = "callPlatformFunc"
		-- local ocParams = params
		-- local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		-- if not ok then
		-- 	print("luaoc error:", ret)
		-- end
	end
end
function  PlatformTool.pay(params)
	if platform_android then
		local javaMethodName = "onPay"
		local javaParams = {util.encode({num=tonumber(params.num),rmb=tonumber(params.rmb)})}
		local javaMethodSig = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity",javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		end
	elseif platform_ios then
		-- local ocMethodName = "callPlatformFunc"
		-- local ocParams = params
		-- local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)
		-- if not ok then
		-- 	print("luaoc error:", ret)
		-- end
	end
end
function PlatformTool.getConfigString(key)
	print('getConfigString????');
	if platform_windows then
		if key=="version_name" then
			return "1.3"
		elseif key == "platform_id" then
			return "1"
		elseif key == "platform_tag" then
			return "moxi"
		end
	elseif platform_android then
		local javaMethodName = "getConfigString"
		local javaParams = {key}
		local javaMethodSig = "(Ljava/lang/String;)Ljava/lang/String;"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
		if not ok then
			print("luaj error:", ret)
		else
			return ret
		end
	elseif platform_ios then
		local ocMethodName = "getConfigString"
		local ocParams = {key=key}
		local ok,ret = luaoc.callStaticMethod(ocClassName,ocMethodName,ocParams)   
		if not ok then
			print("luaoc error:", ret)
		else
			return ret
		end
	end
	return ""
end
function PlatformTool.DebugLog(params)
	-- body
	if platform_android then
		local javaMethodName = "DebugLog"
		local javaParams = {params}
		local javaMethodSig =  "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(javaClassName,javaMethodName,javaParams,javaMethodSig)
	end
end
return PlatformTool