SceneGame = class("SceneGame", cc.load("mvc").ViewBase)

SceneGame.RESOURCE_FILENAME = "uilayout/MainUI/SceneGame.csb"

function SceneGame:onCreate()
   -- self.widget = self:getResourceNode():getChildByName("Panel_loading")
end

function SceneGame:onEnter( ... )
    dw.EventProxy.new(NetClient,nil)
        :addEventListener(Notify.EVENT_GAME_RELOGIN, handler(self,self.reLogin))
        :addEventListener(Notify.EVENT_GAME_SETTING, handler(self,self.handleUpdateSet))

    NetClient:PushLuaTable("player.getGameData","")
end

function SceneGame:reLogin(event)
    if event and event.str then
        if event.str == "relogin" then
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
               self:getApp():enterScene("SceneLogin")
            end)
        elseif event.str == "reloginrole" then
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
               self:getApp():enterScene("SceneSelectRole")
            end)
        end
    end
end

function SceneGame:handleUpdateSet( event )
    if event and event.str ~= "" then
        game.SETTING_TABLE = util.decode(event.str)
        if not game.SETTING_TABLE["music_control"] then
            SimpleAudioEngine:stopMusic(true)
        end
        if game.GetMainRole() then
            NativeData.saveSettingInfo(game.GetMainRole():NetAttr(Const.net_name))
            game.GetMainRole():setPAttr(Const.AVATAR_SET_CHANGE,1)
        end
    else
        NetClient:PushLuaTable("player.setGameData",util.encode(game.SETTING_TABLE))
    end
end

function SceneGame:onExit( ... )
    EventDispatcher:removeEventListenersByEvent(Notify.EVENT_GAME_RELOGIN)
end

return SceneGame
