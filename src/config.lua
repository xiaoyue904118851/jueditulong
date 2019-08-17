
-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = cc.Director:getInstance():getVisibleSize().width,
    height = cc.Director:getInstance():getVisibleSize().height,
    autoscale = "SHOW_ALL",
    callback = function(framesize)
        local ratio = framesize.width / framesize.height
        if ratio <= 1.34 then
            -- iPad 768*1024(1536*2048) is 4:3 screen
            return {autoscale = "SHOW_ALL"}
        end
    end
}


GAME_TAG = "Debug"

TEST_ACCOUNT=""
--
CHARGE_CFG = {
    { rmb = 10, num = 5000, icon = 0},
    { rmb = 50, num = 25000, icon = 1},
    { rmb = 100, num = 50000, icon = 2},
    { rmb = 500, num = 250000, icon = 3},
    { rmb = 1000, num = 500000, icon = 4},
    { rmb = 2000, num = 1000000, icon = 5},
    --{ rmb = 5000, num = 500000, icon = 5},
    --{ rmb = 10000, num = 1000000, icon = 5},
    --{ rmb = 20000, num = 2000000, icon = 5},
}
if GAME_TAG == "Release" then
    CC_SHOW_FPS = false
end
CHANNEL_ID = 1
CENTER_URL =  "http://47.94.37.110/"