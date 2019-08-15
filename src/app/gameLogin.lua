--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2018/01/04 11:09
-- To change this template use File | Settings | File Templates.
--gameLogin

local gameLogin = {}
gameLogin.SceneLogin = nil
function gameLogin.initVar()
    gameLogin._login_account = ""
    gameLogin._server_list = {}
    gameLogin._channel_Info = {} --保存channelurl返回的所有信息
    gameLogin._current_server_info = nil
    gameLogin._isAutoLogining = false
    gameLogin._isAutoLoginSecs = 0
    gameLogin._autoLoginTimeOut = 10
    gameLogin._autoEnter = false
    gameLogin.isReLogin = false
    gameLogin.channelId = ""
    gameLogin.channelUid= "" 
end

function gameLogin.setLoginAccount(account)
    gameLogin._login_account = account
    NativeData.saveLastAccount(gameLogin._login_account)
end

function gameLogin.setCurrentServerInfo(serverInfo)
    gameLogin._current_server_info = clone(serverInfo)
    if #NativeData.getLastLoginInfo() == 0 then
        NativeData.setLastLoginInfo(gameLogin._current_server_info.area_id,gameLogin._current_server_info.server_id)
    end
end

function gameLogin.isCurrentServerInfo(serverInfo)
    if not serverInfo then return false end
    if not gameLogin._current_server_info then return false end

    if gameLogin._current_server_info.area_id == serverInfo.area_id and gameLogin._current_server_info.server_id == serverInfo.server_id then
        return true
    end
    return false
end

function gameLogin.getChannelUrl()
    local gamesdk = GAME_SDK or "none"
    local gamesdkb = GAME_SDKB or "none"
    local game_channel = GAME_CHANNEL or "none"
    local urlTail = "phone/?s=common/channel_info&channel_id="..CHANNEL_ID.."&game_channel="..game_channel.."&gamesdkb="..gamesdkb.."&platform="..gamesdk.."&app_version=1"-- .. (getAppVersion() or ""
    local url
    if GAME_TAG == "Debug" then
        url = Const.test_ip.."/phone/noticesuper.php"
    elseif GAME_TAG == "Release" then
        url = CENTER_URL .. urlTail
    end
    return  "http://"..url
end

function gameLogin.startGetChannelInfo()
    gameLogin.initVar()
    local hurl = gameLogin.getChannelUrl()
    print("start getChannelinfo url==>>",hurl )
    PlatformTool.DebugLog(hurl)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET",hurl)
    PlatformTool.login()
    local function onReadyStateChange()
--        print("33333333333", xhr.status, xhr.responseText)
        if xhr.status then
            if xhr.status == 200 then
                gameLogin.onChannelInfoCallBack(xhr.responseText)
            elseif xhr.status == 0 then
                gameLogin.removeLoginEffect()
                gameLogin.onChannelFailed()
                gameLogin.popErrorDialog({
                    errormsg="无网络链接，渠道信息获取失败",
                    alertTitle="重新登录",
                    onClickConfirm=function()
                        gameLogin.showLoginEffect()
                        gameLogin.startGetChannelInfo()
                    end
                })
            end
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr.timeout = 8
    xhr:send()
end

function gameLogin.onChannelInfoCallBack(json_res)
    json_res = game.unicode_to_utf8(json_res)
    print("getChannelinfo return==>>", json_res)
    if json_res =="" or not json_res then
        print("onChannelFailed==>> ret is nil", json_res)
        gameLogin.onChannelFailed()
        return
    end
    local ret = json.decode(json_res)
    if ret then
        if tonumber(ret["errorcode"]) ~= 1 then
            print("onChannelFailed==>> errorcode:", ret["errorcode"])
            gameLogin.onChannelFailed()
            gameLogin.popErrorDialog({errormsg="渠道信息获取失败 errorcode:"..ret["errorcode"]})
            return
        end
        gameLogin.setChannelInfo(ret)
        NetClient:dispatchEvent({name = Notify.EVENT_GET_CHANNEL_INFO_SUCCESS})
        gameLogin.startGetServerList()
    else
        gameLogin.removeLoginEffect()
        print("onChannelFailed==>> decode ret is nil", ret)
        gameLogin.onChannelFailed()
        gameLogin.popErrorDialog({errormsg="渠道信息获取失败 decode ret is nil"})
    end
end

function gameLogin.onChannelFailed()
    NetClient:dispatchEvent({name = Notify.EVENT_GET_CHANNEL_INFO_FAILED})
end

function gameLogin.setChannelInfo( _tbl )
    local info = {}
    info.notice_ = _tbl["notice"]
    info.channel_name_ = _tbl["channel_name"]
    info.channel_tag_ = _tbl["channel_tag"]
    info.update_url_ = _tbl["update_url"]
    info.update_switch_ = tonumber(_tbl["update_switch"])
    info.order_create_url_ = _tbl["order_create_url"]
    info.serlist_url_ = _tbl["serlist_url"]
    info.userlogin_url_ = _tbl["userlogin_url"] --登录验证，ticket表写数据
    info.notify_url_ = _tbl["notify_url"]
    info.channel_congzi_ = tonumber(_tbl["vsrsion"])
    info.area_tbl = {}
    if type( _tbl['areas'] ) == "table" then
        for _,v in pairs( _tbl['areas'] ) do
            table.insert( info.area_tbl , tonumber(v) )
        end
    end
    table.sort( info.area_tbl )

    local last_login_info_tbl = NativeData.getLastLoginInfo()
    if #last_login_info_tbl > 0 then
        gameLogin.target_area = last_login_info_tbl[1].areaid
    else
        gameLogin.target_area = info.area_tbl[#info.area_tbl] or 1
    end
    gameLogin._channel_Info = info
end

function gameLogin.getChannelNotice()
    return gameLogin._channel_Info.notice_
end

function gameLogin.startGetServerList()
    local gamesdkb = GAME_SDKB or "none"
    local game_channel = GAME_CHANNEL or "none"
    local target_area = gameLogin.target_area
    -- string.format()
    local url = gameLogin._channel_Info.serlist_url_ .. "&channel_id=" .. CHANNEL_ID .."&game_channel="..game_channel.."&gamesdkb="..gamesdkb.. "&area=".. target_area .."&app_version=1"-- .. (resmng.getAppVersion() or "")
    print("start getServerlist url==>>",url )
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET",url)
    local function onReadyStateChange()
        gameLogin.removeLoginEffect()
        if xhr.status and xhr.status == 200 then
            gameLogin.onGetServerListCallBack(xhr.responseText)
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr.timeout = 8
    xhr:send()
end

function gameLogin.onGetServerListCallBack(json_res)
    json_res = game.unicode_to_utf8(json_res)
    print("getServerlist return==>>", json_res)
    if json_res =="" or not json_res then
        print("onGetServerList Failed==>> ret is nil", json_res)
        gameLogin.onGetServerListFailed()
        gameLogin.popErrorDialog({errormsg="服务器列表获取失败 ret is nil"})
        return
    end
    local ret = json.decode(json_res)
    if ret then
        if tonumber(ret["errorcode"]) ~= 1 then
            print("onGetServerList Failed==>> errorcode is ", ret["errorcode"])
            gameLogin.onGetServerListFailed()
            gameLogin.popErrorDialog({errormsg="服务器列表获取失败 errorcode "..tonumber(ret["errorcode"])})
        elseif ret.data then
            local recommend_server = gameLogin.setServerList( ret.data )
            NetClient:dispatchEvent({name = Notify.EVENT_GET_SERVERLIST_INFO_SUCCESS, reserver = recommend_server})
        else
            print("onGetServerList Failed==>> data is nil", ret)
            gameLogin.onGetServerListFailed()
            gameLogin.popErrorDialog({errormsg="服务器列表获取失败 list is nil"})
        end
    else
        print("onGetServerList Failed==>> decode ret is nil", ret)
        gameLogin.onGetServerListFailed()
        gameLogin.popErrorDialog({errormsg="服务器列表获取失败 decode ret is nil"})
    end
end

function gameLogin.onGetServerListFailed()
    NetClient:dispatchEvent({name = Notify.EVENT_GET_SERVERLIST_INFO_FAILED})
end

function gameLogin.setServerList( _list )
    gameLogin._server_list = {}
    local recommend_server
    local theBigestHotServer = 0
    for _,info in pairs( _list )do
        local area_id = tonumber(info.area)
        local serverID = tonumber(info.server_id)

        if gameLogin._server_list[ area_id ] == nil then
            gameLogin._server_list[ area_id ] = {}
        end
        local server_info = {}
        server_info.server_id = serverID
        server_info.area_id = area_id
        local sockip = info.login_url
        local pos = string.find( sockip, ":" )
        server_info.ip = string.sub( sockip, 0, pos-1 )
        server_info.port = tonumber( string.sub( sockip, pos+1 ) )
        server_info.name = info.server_name
        server_info.serverid = info.serverid
        server_info.session_url = info.session_url
        server_info.status = tonumber(info.open_status)
        server_info.hot = tonumber(info.hot)
        server_info.uitag = tonumber(info.uitag)
        server_info.speedtag = tonumber(info.speedtag)
        server_info.rename_addr = info.rename_addr
        server_info.gift_url = info.gift_url

        if not recommend_server then
            recommend_server = server_info
        else
            if server_info.hot == 1 and serverID > theBigestHotServer then
                theBigestHotServer = serverID
                recommend_server = server_info
            end
        end

        gameLogin._server_list[ area_id ][ server_info.server_id ] = server_info
    end

    local last_login_info = NativeData.getLastLoginInfo()
    if #last_login_info > 0 then
        local serverInfo = gameLogin.getServerInfo(last_login_info[1].areaid, last_login_info[1].serverid)
        if serverInfo then
            recommend_server = serverInfo
        end
    end

    return recommend_server
end

function gameLogin.getServerInfo(areaid, serverid)
    local list = gameLogin._server_list[areaid]
    if not list then return end

    return list[serverid]
end

function gameLogin.LoginGame()
    if not gameLogin._channel_Info then
        print("没有平台数据")
        gameLogin.onChannelFailed()
        gameLogin.popErrorDialog({errormsg="没有渠道信息"})
        return
    end
    if not gameLogin._current_server_info then
        print("没有选择服务器")
        gameLogin.popErrorDialog({errormsg="没有选择服务器"})
        return
    end

    if gameLogin._current_server_info.speedtag and gameLogin._current_server_info.speedtag == 2 then
        print("服务器正在维护中!请选择其他服务器进入游戏")
        gameLogin.popErrorDialog({errormsg="服务器正在维护中!请选择其他服务器进入游戏"})
        return false
    end

    -- NativeData.setLastLoginInfo(gameLogin._current_server_info.area_id,gameLogin._current_server_info.server_id)

    local account = gameLogin._login_account
    print("gameLogin.LoginGame==>> account", account)

    local uid =gameLogin.channelId ..'_' .. gameLogin.channelUid
    print("uid == ",uid)
    local url = gameLogin._channel_Info.userlogin_url_ .."&uin=".. uid.."&sign="..uid..
            "&token="..uid.."&server_id="..gameLogin._current_server_info.server_id ..
            "&device=".."unknown".."&platform=".. "test" .. "&system=".. "android"--device.platform

    print("gameLog.LoinginGame==>> url", url)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr:open("GET",url)
    local function onReadyStateChange()
        if xhr.status  then
            print("gameLogin.LoginGame==>> xhr.status",xhr.status )
            if xhr.status == 200 then
                local json_res = xhr.responseText
                gameLogin.onGameServerLoginCallBack(json_res)
            elseif xhr.status == 0 then
                gameLogin.removeLoginEffect()
                gameLogin.popErrorDialog({errormsg="登录超时"})
            end
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr.timeout = 8
    xhr:send()
    gameLogin.showLoginEffect()
end

function gameLogin.onGameServerLoginCallBack(json_res)
    -- if true  then
    --     return
    -- end
    json_res = game.unicode_to_utf8(json_res)
    print("gameLogin.LoginGame return==>>", json_res)
    if json_res =="" or not json_res then
        print("login failed sessionPHP return me unExpect Content")
        gameLogin.onGameServerFailed()
        gameLogin.popErrorDialog({errormsg="login failed sessionPHP return me unExpect Content"})
        return
    end
    local ret = json.decode(json_res)
    if not ret then
        print("login failed sessionPHP return me unExpect Json")
        gameLogin.onGameServerFailed()
        gameLogin.popErrorDialog({errormsg="login failed sessionPHP return me unExpect Json"})
        return
    end
    if not ret["sign"] then
        print("login failed sessionPHP sign unExpect ")
        gameLogin.onGameServerFailed()
        gameLogin.popErrorDialog({errormsg="login failed sessionPHP sign unExpect"})
        return
    end
    local error_code = ret["error_code"]
    local errorcode = ret["errorcode"]
    if tonumber(error_code) == 1 or tonumber(errorcode) == 1 then
        game.mSessionID = ret["sign"]
        game.mServerIP = gameLogin._current_server_info.ip
        game.mServerPort = gameLogin._current_server_info.port
        NetworkCenter:connect(game.mServerIP,game.mServerPort)
    else
        print("login failed sessionPHP error_code unExpect")
        gameLogin.onGameServerFailed()
        gameLogin.popErrorDialog({errormsg="login failed sessionPHP error_code unExpect"})
        return
    end
end

function gameLogin.onGameServerFailed()
    gameLogin.removeLoginEffect()
    NetClient:dispatchEvent({name = Notify.EVENT_GAMESERVER_FAILED})
end

function gameLogin.popErrorDialog(param)
    local widgetName = "gameLoginErrorDialog"
    local runningScene = display.getRunningScene()
    if runningScene:getChildByName(widgetName) then
        runningScene:removeChildByName(widgetName)
    end

    local maskLayer = ccui.Widget:create():setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(runningScene,999)
    maskLayer:setTouchEnabled(true)
    maskLayer:addClickEventListener(function (pSender)
    end)
    maskLayer:setName(widgetName)

    local confirmWidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelAlert.csb"):addTo(maskLayer)
    confirmWidget:setScale(Const.maxScale)
    display.align(confirmWidget, display.CENTER, display.cx, display.cy)
    local panelWidget = confirmWidget:getChildByName("Panel_alert")
    panelWidget:setTouchEnabled(true)

    local function pushConfirmButtons( pSender )
        local btnName = pSender:getName()
        if btnName == "Button_alert" then
            if param.onClickConfirm then param.onClickConfirm() end
        end
        maskLayer:removeFromParent()
    end

    local btnConfirm = panelWidget:getWidgetByName("Button_alert")
    btnConfirm:setTitleText(param.alertTitle or Const.str_titletext_alert)
    btnConfirm:addClickEventListener(pushConfirmButtons)

    local textParent = panelWidget:getWidgetByName("Text_msg_1")
    local bgsize = textParent:getContentSize()
    local richLabel, richWidget = util.newRichLabel(cc.size(bgsize.width, 0), 0)
    richWidget.richLabel = richLabel
    richWidget:setTouchEnabled(false)
    util.setRichLabel(richLabel, param.errormsg, "", 24, Const.COLOR_YELLOW_1_OX)
    richWidget:setContentSize(cc.size(richLabel:getContentSize().width, richLabel:getRealHeight()))
    richWidget:setPosition(cc.p(bgsize.width/2-richLabel:getRealWidth()/2, bgsize.height-richLabel:getRealHeight()))
    textParent:addChild(richWidget)
    textParent:show()
end

function gameLogin.removeLoginEffect()
    local widgetName = "gameLoginLoading"
    local runningScene = display.getRunningScene()
    if runningScene:getChildByName(widgetName) then
        runningScene:removeChildByName(widgetName)
    end
end

function gameLogin.showLoginEffect()
    gameLogin.removeLoginEffect()
    local widgetName = "gameLoginLoading"
    local runningScene = display.getRunningScene()
    local maskLayer = ccui.Widget:create():setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(runningScene,999)
    maskLayer:setTouchEnabled(true)
    maskLayer:addClickEventListener(function (pSender)
    end)
    maskLayer:setName(widgetName)

    gameEffect.playEffectByType(gameEffect.EFFECT_SELECTED_LODING)
    :setScale(Const.maxScale)
    :align(display.CENTER, display.cx, display.cy)
    :addTo(maskLayer)
end

function gameLogin.showDisConnectUI(msg)
    local widgetName = "disconnectPanel"
    local runningScene = display.getRunningScene()
    local disPanel = runningScene:getChildByName(widgetName)
    if disPanel then
        return
    end
    gameLogin.isReLogin = true
    local msg = msg
    if not msg or msg == "" then
        msg = "与服务器断开连接，请重新连接"
    end
    local touchNode = ccui.Widget:create():setContentSize(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy):addTo(runningScene,999)
    touchNode:setTouchEnabled(true)
    touchNode:addClickEventListener(function (pSender)
    end)
    touchNode:setName(widgetName)

    local rootidget = WidgetHelper:getWidgetByCsb("uilayout/LayerAlert/PanelDisconnect.csb"):addTo(touchNode)
    rootidget:setScale(Const.maxScale)
    display.align(rootidget, display.CENTER, display.cx, display.cy)
    local panelWidget = rootidget:getChildByName("Panel_disconnect")
    panelWidget:getWidgetByName("Text_msg_1"):setString(msg)
    panelWidget:getWidgetByName("Button_ok"):addClickEventListener(function(pSender)
        pSender:setTouchEnabled(false)
        game.ExitToRelogin(true)
    end)
end

function gameLogin.removeDisConnectUI()
    local widgetName = "disconnectPanel"
    local runningScene = display.getRunningScene()
    if runningScene:getChildByName(widgetName) then
        runningScene:removeChildByName(widgetName)
    end
end

function gameLogin.onNetDisConnect()
    if MAIN_IS_IN_GAME then
        gameLogin.showAutoReloginUI()
    else
        gameLogin.showDisConnectUI()
    end
end

function gameLogin.showAutoReloginUI()
    if gameLogin._isAutoLogining then return end
    gameLogin.isReLogin = true
    gameLogin._isAutoLogining =  true
    gameLogin._autoEnter = true
    local runningScene = display.getRunningScene()
    local widgetName = "gameAutoReLogin"
    if runningScene:getChildByName(widgetName) then
        runningScene:removeChildByName(widgetName)
    end
    local maskLayer = gameLogin.createMaskBg():addTo(runningScene,999)
    maskLayer:setTouchEnabled(true)
    maskLayer:addClickEventListener(function (pSender)
    end)
    maskLayer:setName(widgetName)
    maskLayer:stopAllActions()

    ccui.ImageView:create("diaoxian.png",UI_TEX_TYPE_PLIST)
    :align(display.CENTER,display.cx,display.cy)
    :setScale(Const.maxScale)
    :addTo(maskLayer)

    gameLogin._isAutoLoginSecs = 1
    NetworkCenter:onConnetTimeOut()
    maskLayer:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.CallFunc:create(function(pSender)
            print("连接中===》》》",gameLogin._isAutoLoginSecs)
            if not gameLogin._isAutoLogining then
                pSender:stopAllActions()
                gameLogin.removeAutoReloginUI()
            else
                gameLogin._isAutoLoginSecs = gameLogin._isAutoLoginSecs + 1
                if math.fmod(gameLogin._isAutoLoginSecs,gameLogin._autoLoginTimeOut) == 0 then
                    print("gameLogin.showAutoReloginUI===》》》单次连接超时，自动重连")
                    NetworkCenter:onConnetTimeOut()
                    NetworkCenter:connect(game.mServerIP,game.mServerPort)
                elseif gameLogin._isAutoLoginSecs >= 59 then
                    print("gameLogin.showAutoReloginUI===》》》自动连接超时，显示手动连接界面")
                    pSender:stopAllActions()
                    NetworkCenter:onConnetTimeOut()
                    gameLogin.removeAutoReloginUI()
                    gameLogin.showDisConnectUI("重连失败,请重新登录")
                end
            end

        end)
    )))
end

function gameLogin.removeAutoReloginUI()
    gameLogin._isAutoLogining = false
    gameLogin._isAutoLoginSecs = 0
    local widgetName = "gameAutoReLogin"
    local runningScene = display.getRunningScene()
    if runningScene:getChildByName(widgetName) then
        runningScene:removeChildByName(widgetName)
    end
end

function gameLogin.createMaskBg()
    local mask = ccui.ImageView:create("uilayout/image/maskbg.png",UI_TEX_TYPE_LOCAL)
    mask:setOpacity(200)
    mask:setScale9Enabled(true)
    mask:setCascadeOpacityEnabled(false)
    mask:setContentSize(cc.size(Const.VISIBLE_WIDTH, Const.VISIBLE_HEIGHT))
    mask:setTouchEnabled(true)
    mask:align(display.CENTER, display.cx, display.cy)
    return mask
end

function gameLogin.removeAllLoginPanel()
    gameLogin.removeLoginEffect()
    gameLogin.removeAutoReloginUI()
    gameLogin.removeDisConnectUI()
end

return gameLogin