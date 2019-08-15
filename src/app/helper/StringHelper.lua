--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/01/18 10:40
-- To change this template use File | Settings | File Templates.
-- StringHelper

local StringHelper = {}

--一维字典
--{k1=v1,k2=v2} k1=v1,k2=v2
--TODO KEY为字符串
function StringHelper.split1dDic( str, d1, d2, numKey )
    local res = {}
    local arr1d = string.split( str, d1 )
    for k, v in ipairs( arr1d ) do
        local arr2d = string.split( v, d2 )
        if arr2d and #arr2d > 1 then
            local key = arr2d[1]
            if numKey then key = tonumber(key) end
            res[key] = arr2d[2]
        end
    end
    return res
end

return StringHelper