--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/24 16:42
-- To change this template use File | Settings | File Templates.
--

--io.output():setvbuf('no')
--local pt = print
--print = function(...)
--    if writeLogFileName and (GAME_TAG == "Debug" or IS_DEBUG_MODE)then
--        local curData = os.date("*t")
--        local content = string.format("%d-%d-%d, %02d:%02d:%02d\t", curData.year, curData.month, curData.day, curData.hour, curData.min, curData.sec)
--
--        local arg = {... }
--        for k, v in pairs(arg) do
--            arg[k] = v
--            content = content..v.."\t"
--        end
--
--        local fp = io.open(writeLogFileName, "a+")
--        fp:write(content.."\n")
--        fp:close()
--    end
--    pt(...)
--end

--local lfs, os, io = require "lfs", os, io
--local function checkDirOK(path)
--    local prepath = lfs.currentdir()
--
--    if lfs.chdir(path) then
--        lfs.chdir(prepath)
--        return true
--    end
--
--    if lfs.mkdir(path) then
--        return true
--    end
--end

--local function removeFile(path)
--    if not io.exists(path) then
--        return
--    end
--    os.remove(path)
--end
--
local curData = os.date("*t")
local platform = cc.Application:getInstance():getTargetPlatform()
if platform == cc.PLATFORM_OS_ANDROID then
--    writeDebugLog = false
--    local path = "/mnt/sdcard/dwnet/"
--    IS_DEBUG_MODE = io.exists(path.."isdebug")
--    if  IS_DEBUG_MODE then
--        writeLogFileName = path.."lc_log_debug.log"
--    end
elseif platform == cc.PLATFORM_OS_WINDOWS then
--    writeDebugLog = true
    local path = cc.FileUtils:getInstance():getWritablePath()..""
--    checkDirOK(path)
    writeLogFileName = path..string.format("lc_log_debug_%d_%d_%d_%d_%d.log", curData.year, curData.month, curData.day, curData.hour, curData.min)
--elseif platform == cc.PLATFORM_OS_IPHONE or platform == cc.PLATFORM_OS_IPAD then
--    writeDebugLog = false
--    local path = cc.FileUtils:getInstance():getWritablePath().."dwnet/"
--    checkDirOK(path)
--    writeLogFileName = path.."lc_log_debug.log"
end
--
--if not writeDebugLog and writeLogFileName then
--    removeFile(writeLogFileName)
--end
function saveTextureCache()
    if writeLogFileName and writeLogFileName ~="" then
        -- local curData = os.date("*t")
        -- local fp = io.open(writeLogFileName, "a+")
        -- local content = string.format("%d-%d-%d, %02d:%02d:%02d\t print textureCache info ===>>>\n", curData.year, curData.month, curData.day, curData.hour, curData.min, curData.sec)
        -- content = content..cc.Director:getInstance():getTextureCache():getCachedTextureInfo().."\n"
        -- fp:write(content)
        -- fp:close()
    end
end