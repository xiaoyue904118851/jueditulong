SceneLoading = class("SceneLoading", cc.load("mvc").ViewBase)

SceneLoading.RESOURCE_FILENAME = "uilayout/SceneLoading/SceneLoading.csb"

local game_tips = {
    "通关锁妖塔可快速冲级！",
    "加入行会，是生存之根本！",
    "行会争霸活动可获得巨额经验！",
    "挑战试炼之塔，可获得大量装备！",
    "积分神器，助你称霸全服！",
    "每日副本与循环任务，可助你快速升级！",
}

local cache_res = {
    "uilayout/image/bord_common.png",
    "uilayout/image/huodong_frame.png",
    "uilayout/image/frame_common_left.png",
    "uilayout/image/frame_common_right.png",

--    "uilayout/image/safearea_point.png",
--    "pic/shadow.png",
--    "pic/cloth_loading.png",
--    "pic/blood_normal.png",
--    "pic/blood_normal_bg.png",
--    "atlas/injury.png",
--    "atlas/injury_self.png",
--    "cloth/100000.png",
--    "cloth/100001.png",
--    "cloth/100002.png",
--    "cloth/100003.png",
--    "cloth/100004.png",
--    "cloth/100005.png",
--    "cloth/100006.png",
--    "cloth/100007.png",
--    "cloth/100010.png",
--    "cloth/100011.png",
--    "cloth/100012.png",
--    "cloth/100013.png",
--    "cloth/100013.png",
}

function SceneLoading:onCreate()

    self.freshHandle = nil
    self.mPercent = 0
    self.mLastStep = 0
    self.mResStep = 0
    self.mStep = 0
    self.mTick = 0

    self.widget = self:getResourceNode():getChildByName("Panel_loading")
    self.widget:align(display.CENTER, display.cx, display.cy)
    self.widget:setScale(Const.minScale)
--    local logo_bg = self.widget:getWidgetByName("img_login_bg"):loadTexture("uilayout/image/login_logo.png",UI_TEX_TYPE_LOCAL)
--    local back_url = "uilayout/image/login_bkg2.jpg"
--    local rand = math.random(100000)
--    back_url = "uilayout/image/login_bkg"..(rand%4+2)..".jpg"
--    local logo_position = cc.p(0,Const.VISIBLE_Y+Const.WIN_HEIGHT)
--    display.align(logo_bg, display.LEFT_TOP)
--    if ((rand%4+2) == 4) or ((rand%4+2) == 5) then
--        display.align(logo_bg,display.RIGHT_TOP)
--        logo_position = cc.p(Const.WIN_WIDTH,Const.VISIBLE_Y+Const.WIN_HEIGHT)
--    end
--    logo_bg:setPosition(logo_position)
    
    self.widget:getWidgetByName("img_login_bg"):loadTexture(back_url,UI_TEX_TYPE_LOCAL)--:setContentSize(cc.size(Const.VISIBLE_WIDTH,Const.VISIBLE_HEIGHT))
    -- self.widget:setBackGroundImage(back_url,UI_TEX_TYPE_LOCAL)
    
    local randNum = math.random(1,#game_tips)
    self.widget:getWidgetByName("Label_tips"):setString(game_tips[randNum])

    self.widget:getWidgetByName("ImageView_96"):loadTexture("uilayout/image/collect_bg.png",UI_TEX_TYPE_LOCAL)
    self.loading_bar = self.widget:getWidgetByName("LoadingBar_loading"):loadTexture("uilayout/image/collect_bar.png",UI_TEX_TYPE_LOCAL):setPercent(0)
    self.loading_label = self.widget:getWidgetByName("Label_progress"):setString("0%")

    self.widget:getWidgetByName("Text_version"):setString(game.getVersionStr())
    SimpleAudioEngine:stopAllEffects()
end

function SceneLoading:onResEnterGame(event)
    print("SceneLoading:onResEnterGame "..event.result)
    if event.result==100 then
        self.isResEnterGame = true
        if  MAIN_IS_IN_GAME==nil or MAIN_IS_IN_GAME==false then
            self:checkEnter()
        else
            cc.GhostManager:getInstance():remAllEffect()
            cc.GhostManager:getInstance():remAllSkill()
            cc.CacheManager:getInstance():releaseUnused(false)
        end
    elseif event.result==103 then
        self.widget:getWidgetByName("Label_tips"):setString("您的账号已经在线,重新登录中")
        -- device.showAlert("提示","账号重复登录","确定",function (event)
        --     game.ExitToRelogin()
        -- end)
    else
        -- game.ExitToRelogin()
    end
end

function SceneLoading:onCharacterLoad()
    self.isCharacterLoad = true
    if MAIN_IS_IN_GAME==nil or MAIN_IS_IN_GAME==false then
        self:checkEnter()
    end
end

function SceneLoading:checkEnter()
    print('self.isCharacterLoad==',self.isCharacterLoad)
    self.isCharacterLoad = true
    if self.isCharacterLoad and self.isResEnterGame then
        print("SceneLoading==>>tart goto sceneGame")
        self:getApp():enterScene("SceneGame")
    end
end

function SceneLoading:onEnter( ... )
    self.m_handler =  dw.EventProxy.new(NetClient,self.widget)
    self.m_handler:addEventListener(Notify.EVENT_RES_ENTER_GAME, handler(self,self.onResEnterGame))
    self.m_handler:addEventListener(Notify.EVENT_NOTIFY_CHARACTER_LOAD, handler(self,self.onCharacterLoad))
    local function runLoading( dt )
        if not game.mChrName or not game.mSeedName or tostring(game.mChrName)=="" or tostring(game.mSeedName)=="" then
            game.ExitToRelogin()
        end
        self.mTick=self.mTick+1
        if self.mTick>=600 then
            -- game.ExitToRelogin()
        end

        if self.mPercent<100 then
            self.mPercent=self.mPercent+1
        end
        self.loading_bar:setPercent(self.mPercent)
        self.loading_label:setString(self.mPercent.."%")
        if self.mLastStep == self.mStep then
            self.mLastStep=self.mLastStep+1
            if self.mStep== 0 then
--                remove_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG)
                game.cleanPicCache()
                self.mStep=self.mStep+1
            elseif self.mStep < #cache_res then
                    self.mStep=self.mStep+1
                    self.mResStep = self.mResStep + 1
                    if cache_res[self.mResStep] then
--                        asyncload_callback(cache_res[self.mResStep], nil, nil, true)
                    end
            elseif self.mStep==#cache_res then
                asyncload_frames("uilayout/MainUI/MainUI",Const.TEXTURE_TYPE.PNG,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<50 then self.mPercent=50 end
                end)
            elseif self.mStep==#cache_res+1 then
                asyncload_frames("uilayout/UI_Common",Const.TEXTURE_TYPE.PNG,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<55 then self.mPercent=55 end
                end)
            elseif self.mStep==#cache_res+2 then
                asyncload_frames("uilayout/UI_Common1",Const.TEXTURE_TYPE.PNG,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<60 then self.mPercent=60 end
                end)
            elseif self.mStep==#cache_res+3 then
                cc.BinManager:getInstance():loadBiz(0,"biz/cloth.biz")
                self.mStep=self.mStep+1
                if self.mPercent<65 then self.mPercent=65 end
            elseif self.mStep==#cache_res+4 then
                cc.BinManager:getInstance():loadBiz(1,"biz/weapon.biz")
                self.mStep=self.mStep+1
                if self.mPercent<70 then self.mPercent=70 end
            elseif self.mStep==#cache_res+5 then
                cc.BinManager:getInstance():loadBiz(4,"biz/effect.biz")
                self.mStep=self.mStep+1
                if self.mPercent<75 then self.mPercent=75 end
            elseif self.mStep==#cache_res+6 then
                cc.BinManager:getInstance():loadBiz(2,"biz/mount.biz")
                cc.BinManager:getInstance():loadBiz(3,"biz/wing.biz")
                cc.BinManager:getInstance():loadBiz(6,"biz/fabao.biz")
                self.mStep=self.mStep+1
                if self.mPercent<80 then self.mPercent=80 end
            elseif self.mStep==#cache_res+7 then
                asyncload_frames("scenebg/guajizhongok",Const.TEXTURE_TYPE.PVR,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<81 then self.mPercent=81 end
                end)
            elseif self.mStep==#cache_res+8 then
                asyncload_frames("scenebg/xunluzhongok",Const.TEXTURE_TYPE.PVR,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<82 then self.mPercent=82 end
                end)
            elseif self.mStep==#cache_res+9 then
                asyncload_frames("scenebg/shouzhiok",Const.TEXTURE_TYPE.PVR,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<83 then self.mPercent=83 end
                end)
            elseif self.mStep==#cache_res+10 then
                asyncload_frames("scenebg/shengjiok",Const.TEXTURE_TYPE.PVR,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<84 then self.mPercent=84 end
                end)
            elseif self.mStep==#cache_res+11 then
                asyncload_frames("scenebg/zhandouli",Const.TEXTURE_TYPE.PVR,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<85 then self.mPercent=85 end
                end)
            elseif self.mStep==#cache_res+12 then
                asyncload_frames("uilayout/UI_Face",Const.TEXTURE_TYPE.PVR,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<86 then self.mPercent=86 end
                end)
            elseif self.mStep==#cache_res+13 then
                asyncload_frames("uilayout/UI_Skill",Const.TEXTURE_TYPE.PNG,function ()
                    self.mStep=self.mStep+1
                    if self.mPercent<87 then self.mPercent=87 end
                end)
            elseif self.mStep==#cache_res+14 then
                game.preloadEffect("sound/1110.mp3")--升级
                game.preloadEffect("sound/1114.mp3")--打开面板
                game.preloadEffect("sound/1116.mp3")--关闭面板
                game.preloadEffect("sound/1113.mp3")--金币音效
                game.preloadEffect("sound/1115.mp3")--回城音效
                game.preloadEffect("sound/100050.mp3")--普攻音效
                self.mStep=self.mStep+1
                if self.mPercent<99 then self.mPercent=99 end
            elseif self.mStep==#cache_res+15 then
                saveTextureCache()
                print('game == ',game.mChrName,game.mSeedName)
                NetClient:EnterGame(game.mChrName,game.mSeedName)
            end
        end
    end
    self.freshHandle = Scheduler.scheduleGlobal(runLoading, 1/60)
end

function SceneLoading:onExit( ... )
    print("SceneLoading,onExit==>>start")
    if self.freshHandle then
        Scheduler.unscheduleGlobal(self.freshHandle)
        self.freshHandle = nil
    end
    cc.CacheManager:getInstance():releaseUnused(false)

    if self.m_handler then
        self.m_handler:removeAllEventListeners()
    end
    print("SceneLoading,onExit==>>end")
end

return SceneLoading
