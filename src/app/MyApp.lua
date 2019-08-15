require("app.Const")
require("app.helper.init")
require("app.lib.init")
PlatformUtil = require("app.PlatformUtil")
PlatformTool = require("app.PlatformTool")
PlatformCenter = require("app.PlatformCenter")
CCGhostManager = cc.GhostManager:getInstance()
SocketManager = cc.SocketManager:getInstance()
SimpleAudioEngine = cc.SimpleAudioEngine:getInstance()
NetCC = cc.NetClient:getInstance()

require("app.data.init")

Notify = require("app.Notify")
require("app.GameEvent")
require("app.network.init")
gameEffect = require("app.gameEffect")

gameLogin=require("app.gameLogin")
game=require("app.game")
game.initVar()

require("app.scenes.SceneCreateRole")
require("app.scenes.SceneSelectRole")
require("app.scenes.SceneLogin")
require("app.layers.LayerRocker")
EventDispatcher = require("cocos.framework.components.event")
UIRedPoint=require("app.UIRedPoint")
UIButtonGuide=require("app.UIButtonGuide")

NetClient = require("app.NetClient")

UISceneGame=require("app.UISceneGame")
UIAnimation=require("app.UIAnimation")

UILeftTop=require("app.UILeftTop")
UILeftBottom=require("app.UILeftBottom")
UILeftCenter=require("app.UILeftCenter")
UIRightBottom=require("app.UIRightBottom")
UIRightTop=require("app.UIRightTop")
-- UIRightCenter=require("app.UIRightCenter")

UIItem=require("app.UIItem")

ScrollFight=require("app.ScrollFight")
MainRole=require("app.MainRole")
MainRole.initVar()
require("app.util")
require("app.CCRecycleList")
require("mime")

local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(os.time())
    self.isEnterBackground = false
end

function MyApp:run()
    display.setAutoScale(CC_DESIGN_RESOLUTION)
    PlatformTool.setLoginCallback()
	-- if device.platform == "windows" and Const.test_mode==0 then
 --        cc.FileUtils:getInstance():addSearchPath("res1/")
 --    end

 --    if device.platform == "android" and Const.test_mode==1 then
 --        cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath().."res/")
 --    else
 --        cc.FileUtils:getInstance():addSearchPath("res/",true)
 --    end

    -- cc.FileUtils:getInstance():addSearchPath("res/",true)
    -- game.preloadEffect("sound/4001.mp3")


    if false then 
        local scene = cc.SceneGame:create()
        display.runScene(scene)
        local TestView = WidgetHelper:getWidgetByCsb("uilayout/TestView/TestView.csb")
        if TestView then
            scene:addChild(TestView)
        end
    else
        asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
           self:enterScene("SceneLogin")
        end)
    end

end

function MyApp:onEnterBackground()
    print("MyApp:onEnterBackground 进入后台",os.date())
    self.inBackground = os.time()
    self.isEnterBackground = true
end

function MyApp:onEnterForeground()
    print("MyApp:onEnterForeground 恢复到前台",os.date())
    if not self.isEnterBackground then return end
    self.isEnterBackground = false
    self.outBackground = os.time()
    if self.inBackground and self.outBackground and self.outBackground - self.inBackground > 5*60 then
        print("在后台时间太长，可能需要重新登录", gameLogin.isReLogin, NetworkCenter:isConnected())
        if not gameLogin.isReLogin and NetworkCenter:isConnected() then
            NetworkCenter:onError(code)
        end
    end
end

return MyApp
