--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/24 15:30
-- To change this template use File | Settings | File Templates.
--
local lfs, os, io = require "lfs", os, io
local FileHelper = {}

function FileHelper.checkDirOK(path)
    local prepath = lfs.currentdir()

    if lfs.chdir(path) then
        lfs.chdir(prepath)
        return true
    end

    if lfs.mkdir(path) then
        return true
    end
end

function FileHelper.removeFile(path)
    if not io.exists(path) then
        return
    end
    os.remove(path)
end

return FileHelper