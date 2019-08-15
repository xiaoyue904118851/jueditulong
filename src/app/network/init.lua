--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/24 12:14
-- To change this template use File | Settings | File Templates.
--

NetProtocol = import(".NetProtocol")
NetworkDispatcher = require("cocos.framework.components.event")
NetworkCenter = import(".NetworkCenter").new()

NetworkEvent = {
    EVENT_SOCKET_ERROR = "EVENT_SOCKET_ERROR",
    EVENT_CONNECT_ON = "EVENT_CONNECT_ON",
    EVENT_CONNECT_FAILED = "EVENT_CONNECT_FAILED",
}

function on_socket_error(code)
    NetworkCenter:onError(code)
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_SOCKET_ERROR,"on_socket_error")


function on_message(type, bytearray)
    NetworkCenter:receiveMsg(type,bytearray)
end
cc.LuaEventListener:addLuaEventListener(EVENT.LUAEVENT_ON_MESSAGE,"on_message")