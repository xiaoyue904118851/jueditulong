--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/01/17 17:06
-- To change this template use File | Settings | File Templates.
--

local gameEffect = {}

gameEffect.EFFECT_LEVELUP = 1
gameEffect.EFFECT_TASK_DONE = 2
gameEffect.EFFECT_XUNLU = 3
gameEffect.EFFECT_AUTOFIGHT = 4
gameEffect.EFFECT_ZHANDOULI = 5
gameEffect.EFFECT_OPEN = 6
gameEffect.EFFECT_JIANTOU = 7
gameEffect.EFFECT_SHIZI = 8
gameEffect.EFFECT_WENHAO = 9
gameEffect.EFFECT_TANHAO = 10
gameEffect.EFFECT_YUANSHEN_BG = 11
gameEffect.EFFECT_YUANSHEN_LIGHT = 12
gameEffect.EFFECT_NEIGONG_ZHANLI = 13
gameEffect.EFFECT_JUANZHOU = 14
gameEffect.EFFECT_NEIGONG_BG = 15
gameEffect.EFFECT_NEIGONG_UP = 16
gameEffect.EFFECT_NEIGONG_FULL = 17
gameEffect.EFFECT_UPGRADE_PER = 18
gameEffect.EFFECT_UPGRADE_SUCC = 19
gameEffect.EFFECT_POINT = 20
gameEffect.EFFECT_BUTTON_SELECTED = 21
gameEffect.EFFECT_BUTTON_SELECTED2 = 22
gameEffect.EFFECT_VITALITY_AWARD = 23
gameEffect.EFFECT_SELECTED_GREEN=24
gameEffect.EFFECT_SELECTED_RED=25
gameEffect.EFFECT_SELECTED_LODING=26
gameEffect.EFFECT_CAIJIZHONG=27
gameEffect.EFFECT_SEVENLOGIN=28
gameEffect.EFFECT_XUNBAO = 29
gameEffect.EFFECT_ZHANSHENSELECT = 30
gameEffect.EFFECT_ZHANSHENACTIVE = 31
gameEffect.EFFECT_MAINTOPBTN = 32
gameEffect.EFFECT_MAINACTIVEBTN = 33
gameEffect.EFFECT_MAINJIANBTN = 34
gameEffect.EFFECT_REFRESHSTAR = 35
gameEffect.EFFECT_ONLINEAWARD = 36

local EFFECT_CONFIG = {
    [gameEffect.EFFECT_LEVELUP] = {plist = "scenebg/shengjiok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "shengji_%02d.png", begin = 1, length = 9, time =  0.1, once = true},
    [gameEffect.EFFECT_TASK_DONE] =  {plist = "scenebg/renwuwancheng", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "renwuwancheng_%02d.png", begin = 1, length = 10, time =  0.15,once = true},
    [gameEffect.EFFECT_XUNLU] =  {plist = "scenebg/xunluzhongok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "xunluzhong_%02d.png", begin = 1, length = 12, time =  0.15 },
    [gameEffect.EFFECT_AUTOFIGHT] =  {plist = "scenebg/guajizhongok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "guajizhong_%02d.png", begin = 1, length = 12, time =  0.15 },
    [gameEffect.EFFECT_ZHANDOULI] =  {plist = "scenebg/zhandouli", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "zhandouli_%02d.png", begin = 1, length = 11, time = 0.15 ,once = true},
    [gameEffect.EFFECT_OPEN] =  {plist = "scenebg/xingongnengok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "xingongneng_%02d.png", begin = 1, length = 10, time = 0.15},
    [gameEffect.EFFECT_JIANTOU] =  {plist = "scenebg/jiantouok", pattern = "jiantou_%02d.png", begin = 1, length = 6, time = 0.15},
    [gameEffect.EFFECT_SHIZI] =  {plist = "scenebg/shiziok", pattern = "shizi_%02d.png", begin = 1, length = 4, time = 0.15},
    [gameEffect.EFFECT_WENHAO] =  {plist = "scenebg/wenhaook", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "wenhao_%02d.png", begin = 1, length = 8, time = 0.15 },
    [gameEffect.EFFECT_TANHAO] =  {plist = "scenebg/tanhaook", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "tanhao_%02d.png", begin = 1, length = 8, time = 0.15},
    [gameEffect.EFFECT_YUANSHEN_BG] =  {plist = "scenebg/yuanshen/yuanshen2", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "yuanshen2_%02d.png", begin = 1, length = 10, time = 0.15},
    [gameEffect.EFFECT_YUANSHEN_LIGHT] =  {plist = "scenebg/yuanshen/yuanshen1", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "yuanshen1_%02d.png", begin = 1, length = 10, time = 0.15},
    [gameEffect.EFFECT_NEIGONG_ZHANLI] =  {plist = "scenebg/yuanshen/yuanshen3", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "yuanshen3_%02d.png", begin = 1, length = 10, time = 0.15},
    [gameEffect.EFFECT_JUANZHOU] =  {plist = "scenebg/juanzhou0", pattern = "juanzhou0_%02d.png", begin = 1, length = 7, time = 0.05,once = true},
    [gameEffect.EFFECT_NEIGONG_BG] =  {plist = "scenebg/neigong/neigong03", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "neogong03_%02d.png", begin = 1, length = 8, time = 0.15},
    [gameEffect.EFFECT_NEIGONG_UP] =  {plist = "scenebg/neigong/neigong01", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "neogong01_%02d.png", begin = 1, length = 8, time = 0.15,once = true},
    [gameEffect.EFFECT_NEIGONG_FULL] =  {plist = "scenebg/neigong/neigong02",imgtype = Const.TEXTURE_TYPE.PVR, pattern = "neogong02_%02d.png", begin = 1, length = 8, time = 0.15},
    [gameEffect.EFFECT_UPGRADE_PER] =  {plist = "scenebg/saoguang", pattern = "saoguang_%02d.png", begin = 1, length = 8, time = 0.05,once = true},
    [gameEffect.EFFECT_UPGRADE_SUCC] =  {plist = "scenebg/shengjiechenggong", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "shengjiechenggong%02d.png", begin = 0, length = 9, time = 0.15,once = true },
    [gameEffect.EFFECT_POINT] =  {plist = "scenebg/shouzhiok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "shouzhi_%02d.png", begin = 1, length = 10, time = 0.05,once = true },
    [gameEffect.EFFECT_BUTTON_SELECTED] =  {plist = "scenebg/tuisong", pattern = "tuisong%02d.png", begin = 1, length = 8, time = 0.1 },
    [gameEffect.EFFECT_BUTTON_SELECTED2] =  {plist = "scenebg/qianwang", pattern = "qianwang%02d.png", begin = 1, length = 8, time = 0.1},
    [gameEffect.EFFECT_VITALITY_AWARD] =  {plist = "scenebg/baoxianghuoyue", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "baoxianghuoyue%02d.png", begin = 1, length = 8, time = 0.1 },
    [gameEffect.EFFECT_SELECTED_GREEN] =  {plist = "scenebg/jiaoxialvok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "jiaoxialv_%02d.png", begin = 1, length = 8, time = 0.1},
    [gameEffect.EFFECT_SELECTED_RED] =  {plist = "scenebg/jiaoxiahongok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "jiaoxiahong_%02d.png", begin = 1, length = 8, time = 0.1},
    [gameEffect.EFFECT_SELECTED_LODING] =  {plist = "scenebg/jiazaiok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "jiazai%02d.png", begin = 1, length = 9, time = 0.1},
    [gameEffect.EFFECT_CAIJIZHONG] =  {plist = "scenebg/caijizhongok", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "caijizhong%02d.png", begin = 1, length = 12, time = 0.1},
    [gameEffect.EFFECT_SEVENLOGIN] =  {plist = "scenebg/dengrujiangli", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "dengrujiangli000%02d.png", begin = 1, length = 7, time = 0.1},
    [gameEffect.EFFECT_XUNBAO] =  {plist = "scenebg/shengjiechenggong", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "shengjiechenggong%02d.png", begin = 0, length = 9, time = 0.1,once = true},
    [gameEffect.EFFECT_ZHANSHENSELECT] =  {plist = "scenebg/uizhanshen", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "uizhanshen%02d.png", begin = 0, length = 8, time = 0.1},
    [gameEffect.EFFECT_ZHANSHENACTIVE] =  {plist = "scenebg/jihuoanniu", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "jihuoanniu%02d.png", begin = 0, length = 8, time = 0.1},
    [gameEffect.EFFECT_MAINTOPBTN] =  {plist = "scenebg/uihuodong00", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "uihuodong%02d.png", begin = 0, length = 8, time = 0.1},
    [gameEffect.EFFECT_MAINACTIVEBTN] =  {plist = "scenebg/gongjiengquan", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "gongjiquan%02d.png", begin = 0, length = 8, time = 0.1},
    [gameEffect.EFFECT_MAINJIANBTN] =  {plist = "scenebg/UIgongnengtishi", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "UIgongnengtishi%02d.png", begin = 1, length = 8, time = 0.1},
    [gameEffect.EFFECT_REFRESHSTAR] =  {plist = "scenebg/xingjitexiao", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "xingjitexiao%02d.png", begin = 1, length = 8, time = 0.1,once = true},
    [gameEffect.EFFECT_ONLINEAWARD] =  {plist = "scenebg/jianglidating", imgtype = Const.TEXTURE_TYPE.PVR, pattern = "jianglidating%02d.png", begin = 1, length = 5, time = 0.1},
}

function gameEffect.getFrameEffect( plist,pattern, begin, length, time, txttype,imgtype)
    if not txttype then txttype = Const.TEXTURE_RES_TYPE.PLIST end
    if not imgtype then imgtype = Const.TEXTURE_TYPE.PNG end

    if txttype == Const.TEXTURE_RES_TYPE.XML or plist == "scenebg/xingongnengok" then
        local sprite = cc.Sprite:create()
        return sprite
    end

    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist..txttype)
    local frames = display.newFrames(pattern, begin, length)
    local animation = display.newAnimation(frames, time or 0.15) -- 0.5 秒播放 8 桢
    local sprite = cc.Sprite:createWithSpriteFrame(frames[1])
    sprite:playAnimationForever(animation)
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(plist..txttype)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(plist..imgtype)
    return sprite

--    local sprite = cc.Sprite:create()
--    local callback = function (filename)
--        if sprite then
--            local frames = display.newFrames(pattern, begin, length)
--            local animation = display.newAnimation(frames, time or 0.15)
--            sprite:playAnimationForever(animation)
--        end
--    end
--    asyncload_frames(plist,imgtype,callback, txttype)
--    sprite:onNodeEvent("exit", function()
--        remove_frames_by_callback(plist,imgtype, callback)
--    end)
--    return sprite
end

function gameEffect.getOnceFrameEffect( plist,pattern, begin, length, time, args, txttype,imgtype)
    if not txttype then txttype = Const.TEXTURE_RES_TYPE.PLIST end
    if not imgtype then imgtype = Const.TEXTURE_TYPE.PNG end

    if txttype == Const.TEXTURE_RES_TYPE.XML then
        local sprite = cc.Sprite:create()
        return sprite
    end

    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist..txttype)
    local frames = display.newFrames(pattern, begin, length)
    local animation = display.newAnimation(frames, time or 0.15) -- 0.5 秒播放 8 桢
    local sprite = cc.Sprite:createWithSpriteFrame(frames[1])
    sprite:playAnimationOnce(animation,args)
    cc.SpriteFrameCache:getInstance():removeSpriteFrameByName(plist..txttype)
    cc.Director:getInstance():getTextureCache():removeTextureForKey(plist..imgtype)
    return sprite

--    local sprite = cc.Sprite:create()
--    local callback = function (filename)
--        if sprite then
--            local frames = display.newFrames(pattern, begin, length)
--            local animation = display.newAnimation(frames, time or 0.15)
--            sprite:playAnimationOnce(animation,args)
--        end
--    end
--    asyncload_frames(plist,imgtype,callback, txttype)
--    sprite:onNodeEvent("exit", function()
--        remove_frames_by_callback(plist,imgtype, callback)
--    end)
--    return sprite
end

function gameEffect.getIconSelectEffect()
    return gameEffect.getFrameEffect("itemn","itemn_0%02d.png", 1, 9)
end

function gameEffect.getBtnSelectEffect()
    return gameEffect.playEffectByType(gameEffect.EFFECT_BUTTON_SELECTED, args)
end

function gameEffect.getNormalBtnSelectEffect()
    return gameEffect.playEffectByType(gameEffect.EFFECT_BUTTON_SELECTED2, args)
end

function gameEffect.getPlayEffect(tag)
    return gameEffect.playEffectByType(tag, args)
end

function gameEffect.getCacheEffect(type, args)
    local cfg = EFFECT_CONFIG[type]
    if type == gameEffect.EFFECT_TASK_DONE or not cfg then
        local sprite = cc.Sprite:create()
        return  sprite
    end

    local frames = display.newFrames(cfg.pattern, cfg.begin, cfg.length)
    if frames == 0 then
        local sprite = cc.Sprite:create()
        return  sprite
    end

    local animation = display.newAnimation(frames, cfg.time)
    local sprite = cc.Sprite:createWithSpriteFrame(frames[1])
    if cfg.once then
        sprite:playAnimationOnce(animation,args or {})
    else
        sprite:playAnimationForever(animation)
    end
    return sprite
end

function gameEffect.playJsonEffect( params )
    params = params or {}
    local filename = params.filename
    local amtName = params.amtName
    local mvName = params.mvName
    local prt = params.parent
    local anchor = params.anchor or cc.p(0.5,0.5)
    local pos = params.pos or cc.p(display.cx, display.cy)
    local cb = params.cb
    local isNode = params.isNode
    local loop = params.loop or 0
    local zorder = params.zorder or 0

    --print("amtName" .. amtName, "jsonEffect/"..filename)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo( "jsonEffect/"..filename )
    local armt = ccs.Armature:create( amtName )
    armt:setAnchorPoint(anchor)
    armt:setPosition(pos)
    if isNode then
        prt:addNode( armt, zorder )
    else
        prt:addChild( armt, zorder )
    end

    local animation = armt:getAnimation()

    if cb then
        animation:setMovementEventCallFunc(
            function (arm, eventType, movmentID)
                if eventType == ccs.MovementEventType.complete then
                    cb()
                end
            end
        )
    end

    animation:play(mvName,-1,loop)
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("jsonEffect/"..filename)
    return armt
end

function gameEffect.playEffectByType(type, args)
    local cfg = EFFECT_CONFIG[type]
    if not cfg then return end

    if cfg.once then
        return gameEffect.getOnceFrameEffect(cfg.plist,cfg.pattern, cfg.begin, cfg.length, cfg.time, args or {}, cfg.txttype, cfg.imgtype)
    else
        return gameEffect.getFrameEffect( cfg.plist,cfg.pattern, cfg.begin, cfg.length, cfg.time, cfg.txttype, cfg.imgtype)
    end
end

return gameEffect