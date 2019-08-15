SceneLogin = class("SceneLogin", cc.load("mvc").ViewBase)

SceneLogin.RESOURCE_FILENAME = "uilayout/SceneLogin/SceneLogin.csb"

function SceneLogin:onCreate()
    
    self.widget = self:getResourceNode():getChildByName("Panel_login")
    self.widget:align(display.CENTER, display.cx, display.cy)
    self.widget:setScale(Const.minScale)

    self.panel_info = self.widget:getWidgetByName("Panel_info")
    self.panel_gonggao = self.widget:getWidgetByName("Panel_gonggao"):hide()
    self.notice_slide_= self.panel_gonggao:getWidgetByName("ListView_Notice")
    self.notice_slide_size = self.notice_slide_:getContentSize()

    self.widget:getWidgetByName("ImageView_logo"):loadTexture("uilayout/image/login_logo.png",UI_TEX_TYPE_LOCAL)
    self.server_label = self.widget:getWidgetByName("label_servername")
    self.login_btn = self.widget:getWidgetByName("Button_EnterGame")
    self.login_btn:setTouchEnabled(false)
        :setBright(false)
        :addClickEventListener(function (pSender)
            if not game.checkBtnClick() then return end
            -- if not PlatformCenter.Logined and device.platform ~= "windows" then
            --     PlatformCenter.login()
            --     return
            -- end
            if gameLogin._login_account ~= "" then

                gameLogin.setLoginAccount(gameLogin._login_account)
                gameLogin.LoginGame()
       
            else
                if device.platform == "windows" then
                    gameLogin.setLoginAccount("123")
                    gameLogin.LoginGame()
                else
                    PlatformTool.login()
                end
              
            end
        end)

    self.panel_info:getWidgetByName("Button_notice"):addClickEventListener(function (pSender)
        self:showNotice()
    end)

    self.panel_gonggao:getWidgetByName("Button_IKnow"):addClickEventListener(function (pSender)
        self:hideNotice()
    end)

    self.serverchoice_btn = self.widget:getWidgetByName("Button_SeverChoice")
    self.serverchoice_btn:setTouchEnabled(false)
    :addClickEventListener(function ( ... )
        if not game.checkBtnClick() then return end
        if self.mSendText:getString() ~= "" then
            -- gameLogin.setLoginAccount(self.mSendText:getString())
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
                self:getApp():enterScene("SceneServerList")
            end)
        else
            print("帐号为空")
        end
    end)

    local function onEdit(event,editBox)
        if event == "began" then
            -- 保持面板不被关闭
        elseif event == "changed" then
            -- 输入框内容发生变化
        elseif event == "ended" then
            -- 输入结束
        elseif event == "return" then
            -- gameLogin.setLoginAccount(self.mSendText:getString())
        end
    end

--    local inputBg = self.widget:getWidgetByName("ImageView_inputBg")
--    local bgSize = inputBg:getContentSize()
--    self.mSendText = util.newEditBox({
--        image = "uilayout/image/transparency.png",
--        size = bgSize,
--        listener = onEdit,
--        x = 0,
--        y = 0,
--        placeHolder = "请输入账号",
--        placeHolderSize = 28,
--        fontSize = 30,
--        anchor = cc.p(0,0),
--    })
--    self.mSendText:setTouchEnabled(false)
--    self.mSendText:setMaxLength(40)
--    self.mSendText:setString(NativeData.getLastAccount())
--    inputBg:addChild(self.mSendText)
    self.mSendText = self.widget:getWidgetByName("TextField_account")
    self.mSendText:setString(gameLogin._login_account)
    self.mSendText:setTouchEnabled(false)
    -- self.mSendText:setVisible(false)
    -- game.playSoundByID("sound/4001.mp3",true,true)
    self.panel_info:getWidgetByName("Text_version"):setString(game.getVersionStr())
    gameLogin.SceneLogin = self
    if not PlatformCenter.Logined and device.platform ~= "windows" then
        PlatformCenter.login()
    end
end

function SceneLogin:showSendText()
    -- body
    gameLogin.SceneLogin.mSendText:setString(gameLogin._login_account)
end
function SceneLogin:showNotice()
    self.panel_info:hide()
    self.panel_gonggao:setPositionY(Const.WIN_HEIGHT)
    self.panel_gonggao:show()
    local action = cc.EaseExponentialOut:create(cc.MoveBy:create( 0.5,cc.p( 0 , -Const.WIN_HEIGHT)))
    local function cb( ... )
        self:showNoticeContent()
    end
    local actions = cc.Sequence:create(action,cc.CallFunc:create(cb))
    self.panel_gonggao:runAction(actions)
end

function SceneLogin:showNoticeContent()
    self.notice_slide_:removeAllItems()
    self.content_tbl =  string.split( gameLogin.getChannelNotice(),"<UPDATELOG>" )
    local n_msg = self.content_tbl[1]
    local line_tbl =  string.split( n_msg,"###" )
    for k,line in ipairs(line_tbl) do
        local label = self:creatRichText(line)
        self.notice_slide_:pushBackCustomItem(label)
    end
    self.notice_slide_:setInnerContainerSize(cc.size(746,360))
    self.notice_slide_:jumpToTop()
end

function SceneLogin:creatRichText( _str )
    local txt_tbl =  string.split( _str,"$" )
    local label = ccui.RichText:create()
    label:ignoreContentAdaptWithSize( false )
    local str_width = 0
    for i,txt in ipairs(txt_tbl) do
        local att_tbl = {}
        local pos = string.find( txt,"}")
        local is_have_att = false
        if pos then
            local str1 = string.sub( txt,1,pos)
            local str2 = loadstring( "return "..str1 )
            if str2  then
                str2 = str2()
                att_tbl = str2
                is_have_att = true
            end
        end
        local tmpStr
        if is_have_att then
            tmpStr = string.sub( txt,pos+1 )
        else
            tmpStr = txt
        end

        local color
        if att_tbl.color then
            color = att_tbl.color
        else
            color = display.COLOR_WHITE
        end

        local size = att_tbl.size or 28
        local font = att_tbl.font or Const.DEFAULT_FONT_NAME
        local element_cnt = ccui.RichElementText:create( i, color, 255, tmpStr, font, size )
        local sum,en,ch = util.stringcount( tmpStr )
        str_width = en * 24/2 + ch * 24 + str_width
        label:pushBackElement( element_cnt )

    end
    local nLine = math.ceil( str_width / self.notice_slide_size.width )
    label:setContentSize(cc.size(self.notice_slide_size.width, nLine*28))
    return label
end

function SceneLogin:hideNotice()
    self.panel_info:show()
    local action = cc.EaseExponentialOut:create(cc.MoveBy:create( 0.5,cc.p( 0 , Const.WIN_HEIGHT)))
    local function cb( ... )
        self.panel_gonggao:hide()
    end
    local actions = cc.Sequence:create(action,cc.CallFunc:create(cb))
    self.panel_gonggao:runAction(actions)
end

function SceneLogin:onEnter( ... )
    gameLogin.startGetChannelInfo()
    self.m_handler =  dw.EventProxy.new(NetClient,self.widget)
    self.m_handler:addEventListener(Notify.EVENT_LOADCHAR_LIST,handler(self,self.handleCharLoaded))
    self.m_handler:addEventListener(Notify.EVENT_GET_CHANNEL_INFO_FAILED,handler(self,self.handleChannelInfoFaild))
    self.m_handler:addEventListener(Notify.EVENT_GET_CHANNEL_INFO_SUCCESS,handler(self,self.handleChannelInfoSucess))
    self.m_handler:addEventListener(Notify.EVENT_GET_SERVERLIST_INFO_FAILED, handler(self,self.handleGetServerListFaild))
    self.m_handler:addEventListener(Notify.EVENT_GET_SERVERLIST_INFO_SUCCESS, handler(self,self.handleGetServerListSucess))
    self.m_handler:addEventListener(Notify.EVENT_GAMESERVER_FAILED, handler(self,self.handleGameServerFaild))
end

function SceneLogin:onExit( ... )
    if self.m_handler then
        self.m_handler:removeAllEventListeners()
    end
end

function SceneLogin:handleCharLoaded( event )
    if #NetClient.mNetChar > 0 then
        asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
            self:getApp():enterScene("SceneSelectRole")
        end)
    else
        asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
            self:getApp():enterScene("SceneCreateRole")
        end)
    end
end

function SceneLogin:handleChannelInfoFaild()
    self:setLoginBtnEnabled(false)
    self:setServerChoiceBtnEnabled(false)
    self:setAccountTextEnabled(false)
end

function SceneLogin:handleChannelInfoSucess()
    self:showNotice()
end

function SceneLogin:handleGetServerListFaild()
    self:setLoginBtnEnabled(false)
    self:setServerChoiceBtnEnabled(false)
    self:setAccountTextEnabled(false)
end

function SceneLogin:handleGetServerListSucess(event)
    if event and event.reserver then
        self:setLoginBtnEnabled(true)
        self:setServerChoiceBtnEnabled(true)
        self:setAccountTextEnabled(true)
        gameLogin.setCurrentServerInfo(event.reserver)
        self.server_label:setString(event.reserver.name)
    else
        self:setLoginBtnEnabled(false)
        self:setServerChoiceBtnEnabled(false)
        self:setAccountTextEnabled(false)
    end
end

function SceneLogin:handleGameServerFaild()
    self:setLoginBtnEnabled(true)
end

function SceneLogin:setLoginBtnEnabled(enable)
    if self.login_btn then
        self.login_btn:setTouchEnabled(enable)
        self.login_btn:setBright(enable)
    end
end

function SceneLogin:setAccountTextEnabled(enable)
    if self.mSendText then
        self.mSendText:setTouchEnabled(enable)
    end
end

function SceneLogin:setServerChoiceBtnEnabled(enable)
    if self.serverchoice_btn then
        self.serverchoice_btn:setTouchEnabled(enable)
    end
end

return SceneLogin
