--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/11 15:48
-- To change this template use File | Settings | File Templates.
-- DateHelper

local DateHelper = {}

-- 得到当前月份的总共天数
function DateHelper.getDaysOfCurMonth()
    return os.date("%d", os.time({year = os.date("%Y"), month = os.date("%m") + 1, day = 0}))
end

function DateHelper.getCurTime(formatstr)
    formatstr = formatstr or "%d-%02d-%02d %02d:%02d:%02d"
    local curData = os.date("*t")
    local str = string.format(formatstr, curData.year, curData.month, curData.day, curData.hour, curData.min, curData.sec)
    return str
end

function DateHelper.toDateStr(t,formatstr)
    formatstr = formatstr or "%d-%02d-%02d %02d:%02d:%02d"
    local curData = os.date("*t", t)
    local str = string.format(formatstr, curData.year, curData.month, curData.day, curData.hour, curData.min, curData.sec)
    return str
end

-- 秒数转化为文字描述
function DateHelper.convertSecondsToStr( sec,short )
    local day = math.floor(sec / 86400)
    local hour = math.floor((sec - day*86400)/3600)
    local min = math.floor( (sec - day*86400 - hour*3600)/60 )
    local str = ""
    if day > 0 then
        str = str..day.."天"
        if short then return str end
    end
    if hour > 0 then
        str = str..hour.."小时"
    end
    if min > 0 then
        str = str..min.."分"
        if short and hour > 0 then return str end
    end
    sec = sec - day*86400 - hour*3600 - min*60
    if sec > 0 then
        str = str..sec.."秒"
    end

    return str
end

return DateHelper