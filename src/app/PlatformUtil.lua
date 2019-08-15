--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/12/27 10:13
-- To change this template use File | Settings | File Templates.
--


--类型名   类型
--I                     整数，或者Lua function
--F                     浮点数
--Z                     布尔值
--Ljava/lang/String;    字符串
--V                     Void空，仅用于指定一个Java方法不返回任何值

local PlatformUtil = {}
local CLASS_NAME = "org/cocos2dx/lua/AppActivity"
local target = cc.Application:getInstance():getTargetPlatform()
local luaj

if target == cc.PLATFORM_OS_ANDROID then
    luaj = require "cocos.cocos2d.luaj"
end

function PlatformUtil.isAndroid()
    if target == cc.PLATFORM_OS_ANDROID then
        return true
    end
    return false
end

function PlatformUtil.isIOS()
    if target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
        return true
    end
    return false
end

function PlatformUtil.getApkVersionName()
    print('getApkVersionName')
    if PlatformUtil.isAndroid() then
        return "android" --androidGetApkVersionName
    elseif PlatformUtil.isIOS() then
        return PlatformUtil.iosGetApkVersionName()
    end

    return "windows"
end

function PlatformUtil.androidGetApkVersionName()
    local javaMethodName = "getVersionName"
    local javaParams = {}
    local javaMethodSig = "()Ljava/lang/String;"

    local ok,ret = luaj.callStaticMethod(CLASS_NAME, javaMethodName, javaParams, javaMethodSig)
    if ok then
        return ret
    else
        printError("",ok, ret)
    end
end

function PlatformUtil.iosGetApkVersionName()
    return "TODO"
end

return PlatformUtil