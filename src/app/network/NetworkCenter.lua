--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/24 12:14
-- To change this template use File | Settings | File Templates.
--

NetworkCenter = class("NetworkCenter")

function NetworkCenter:ctor(  )
    NetworkDispatcher:bind(self)
    self._connected = false
end

function NetworkCenter:connect(__host, __port, __retryConnectWhenFailure)
    if self._connected == false then
        print("NetworkCenter:start connect==>",__host,__port)
        if SocketManager:startSocket(__host,__port) then
            self._connected = true
            game.initTime = cc.SocketManager:getSystemTime()
            print("NetworkCenter:connect sucess ==> initTime ",game.initTime)
            gameLogin.removeAutoReloginUI()
            NetClient:onConnect()
        else
            NetworkDispatcher:dispatchEvent({name=NetworkEvent.EVENT_CONNECT_FAILED})
        end
    else
        print("NetworkCenter:connect==>is already connected")
    end
end

function NetworkCenter:disconnect()
    print("NetworkCenter:disconnect==")
    SocketManager:stopSocket()
    self._connected = false
    NetCC:initClient()
end

function NetworkCenter:onConnetTimeOut()
    print("NetworkCenter:onConnetTimeOut==")
    SocketManager:stopSocket()
    self._connected = false
end

function NetworkCenter:onError(code)
    print("NetworkCenter:onError==>",code)
    self._connected = false
    NetClient:onSocketError()
end

function NetworkCenter:isConnected()
    return self._connected
end

function NetworkCenter:sendMsg(msg)
    SocketManager:sendPacket()
end

-- TODO 最好将NetClient中的消息按照模块区分
--      每个消息都注册到NetworkDispatcher上来 注册一个从NetClient中删除一个

function NetworkCenter:receiveMsg(type, mMsg)
    NetClient:ParseMsg(mMsg)
end

function NetworkCenter:getSkipTime()
    if not game.initTime then
        return 0
    else
        return game.getTime() - game.initTime
    end
    return 0
end

return NetworkCenter