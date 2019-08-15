--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/28 15:22
-- To change this template use File | Settings | File Templates.
--
dw = dw or {}
dw.EventProxy = import(".EventProxy")


-- quick的cjson cocos自带的json解析会出错
local cjson = import(".json")
if cjson then
     json = cjson
else
    require("cocos.cocos2d.json")
end
htmlParse = require("app.lib.html")
UIGridView = import(".UIGridView")
UIGridPageView = import(".UIGridPageView")
UIRadioButtonGroup = import(".UIRadioButtonGroup")
Scheduler = import(".scheduler")