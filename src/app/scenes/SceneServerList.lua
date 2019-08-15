SceneServerList = class("SceneServerList", cc.load("mvc").ViewBase)

SceneServerList.RESOURCE_FILENAME = "uilayout/SceneServerList/SceneServerList.csb"

local propSpeedtag = {
        [0] = "red",
        [1] = "green",
        [2] = "dark",
    }

function SceneServerList:onCreate()
    self.widget = self:getResourceNode():getChildByName("panel_serverlist")
    self.widget:align(display.CENTER, display.cx, display.cy)
    self.widget:setScaleX(Const.SCALE_X)
    self.widget:setScaleY(Const.SCALE_Y)
    -- self.widget:setBackGroundImage("uilayout/image/login_bg.jpg",UI_TEX_TYPE_LOCAL)
--    self.widget:getWidgetByName("img_login_bg"):loadTexture("uilayout/image/login_bg.jpg",UI_TEX_TYPE_LOCAL)--:setContentSize(cc.size(Const.VISIBLE_WIDTH,Const.VISIBLE_HEIGHT))
    self.widget:getWidgetByName("Button_back"):addClickEventListener(function ( ... )
        asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
            self:getApp():enterScene("SceneLogin")
        end)
    end)
    self:initData()
    self.image_view_bg = self.widget:getChildByName("ImageView_bg")
    self.model_daqu = self.widget:getWidgetByName("Button_daqu"):hide()
    self.model_server = self.widget:getWidgetByName("Button_server"):hide()
    self.list_daqu = self.widget:getWidgetByName("ListView_shard_list")
    self.listView_server = self.widget:getWidgetByName("ListView_server")
    self.widget:getWidgetByName("Button_start"):addClickEventListener(function ( ... )
        local serverinfo = gameLogin.getServerInfo(self.selectAreaId, self.selectServerId)
        if serverinfo then
            gameLogin.setCurrentServerInfo(serverinfo)
            gameLogin.LoginGame()
        else
            print("SceneServerList==>没有选择服务器")
        end
    end)
    self.curSelectArea = 1
end

function SceneServerList:initData()
--    self.area_btn_list = {}
--    self.server_btn_list = {}
    self.last_login_btn_list = {}
    self.selectAreaId = 0
    self.selectServerId = 0
    self.isSelectList = false
--    self.last_refresh_time = 0
--    self.propUItag = {
--        [0] = "default",
--        [1] = "new",
--    }
--
--    self.propSpeedtag = {
--        [0] = "red",
--        [1] = "green",
--        [2] = "dark",
--    }
end

function SceneServerList:onEnter( ... )
    self.leftButtonGroup = UIRadioButtonGroup.new():onButtonSelectChanged(function(event)
--        if not game.checkBtnClick() then return end
        self:resetServerList(event)
    end)
    self.serverButtonGroup = UIRadioButtonGroup.new():onButtonSelectChanged(function(event)
--        if not game.checkBtnClick() then return end
        self.isSelectList = true
        self.lastloginButtonGroup:clearSelect()
        local serverinfo = gameLogin.getServerInfo(event.sender.areaid, event.sender.serverid)
        if serverinfo then
            self.selectAreaId = event.sender.areaid
            self.selectServerId = event.sender.serverid
        end
    end)
    for area,areainfo in pairs(gameLogin._server_list) do
        local daqu = self.model_daqu:clone():show()
        daqu:loadTextures("button_shard.png","button_shard_sel.png","",UI_TEX_TYPE_PLIST)
        daqu:setTitleText("第"..area.."大区")
        daqu.area = area
        self.list_daqu:pushBackCustomItem(daqu)
        self.leftButtonGroup:addButton(daqu)
    end
    self.leftButtonGroup:setButtonSelected(1)
    self:initLastLogin()
    EventDispatcher:on(Notify.EVENT_LOADCHAR_LIST,handler(self,self.handleCharLoaded))
end

function SceneServerList:onExit()
    EventDispatcher:removeEventListenersByEvent(Notify.EVENT_LOADCHAR_LIST)
end

function SceneServerList:handleCharLoaded( event )
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

function SceneServerList:createOneRow( width , height )
    local row = ccui.Layout:create()
    row:setContentSize( cc.size( width, height ) )
    return row
end

function SceneServerList:resetServerList(event)
    self.listView_server:removeAllItems()
    self.serverButtonGroup:clearItems()
    local columns = 3
    local columnW = self.listView_server:getContentSize().width
    local columnH = self.model_server:getContentSize().height + 20
    local modelW = self.model_server:getContentSize().width
    local hspace = 16
    local n = 0
    local oneRow
    for serverid,serverinfo in pairs(gameLogin._server_list[event.sender.area]) do
        local server = self.model_server:clone():show()
        server:loadTextures("button_sever.png","button_sever_sel.png","",UI_TEX_TYPE_PLIST)
        server:getWidgetByName("Label_severname"):setString(serverinfo.name)
        server:getWidgetByName("ImageView_sign"):loadTexture("title_"..(serverinfo.uitag == 0 and "default" or "new")..".png", UI_TEX_TYPE_PLIST)
        server:getWidgetByName("ImageView_status"):loadTexture("img_" .. propSpeedtag[serverinfo.speedtag] .. ".png", UI_TEX_TYPE_PLIST)
        server.serverid = serverid
        server.areaid = event.sender.area
        self.serverButtonGroup:addButton(server)
        server:align(display.LEFT_CENTER, (n%columns)*(modelW + hspace),columnH/2)
        if n%columns == 0 then
            oneRow = self:createOneRow(columnW,columnH)
            self.listView_server:pushBackCustomItem( oneRow )
        end
        if oneRow then
            oneRow:addChild(server)
        end
        n = n + 1
    end
    self.curSelectArea = event.sender.area
    if self.isSelectList then
        self.serverButtonGroup:setButtonSelected(1)
    end
end

function SceneServerList:initLastLogin()
    if not self.image_view_bg then return end

    local last_login_info_tbl = NativeData.getLastLoginInfo()
    if #last_login_info_tbl == 0 then
        self.image_view_bg:getChildByName("Button_lasttime1"):hide()
        self.image_view_bg:getChildByName("Button_lasttime2"):hide()
        return
    end

    self.lastloginButtonGroup = UIRadioButtonGroup.new():onButtonSelectChanged(function(event)
    --        if not game.checkBtnClick() then return end
        self.isSelectList = false
        self.serverButtonGroup:clearSelect()
        local serverinfo = gameLogin.getServerInfo(event.sender.areaid, event.sender.serverid)
        if serverinfo then
            self.selectAreaId = event.sender.areaid
            self.selectServerId = event.sender.serverid
        end
    end)

    for i=1,2 do
        local lastinfo = last_login_info_tbl[i]
        local name = "Button_lasttime" .. i
        self.last_login_btn_list[i] = self.image_view_bg:getChildByName( name )
        if not lastinfo then
            self.last_login_btn_list[i]:hide()
            self.last_login_btn_list[i]:setTouchEnabled(false)
            self.last_login_btn_list[i].serverid = nil
        else
            local serverInfo = gameLogin.getServerInfo(lastinfo.areaid, lastinfo.serverid)
            if serverInfo then
                self.last_login_btn_list[i]:show()
                self.last_login_btn_list[i]:getWidgetByName("Label_severname"):setString(serverInfo.name)
                self.last_login_btn_list[i]:getWidgetByName("ImageView_sign"):loadTexture("title_"..(serverInfo.uitag == 0 and "default" or "new")..".png", UI_TEX_TYPE_PLIST)
                self.last_login_btn_list[i]:getWidgetByName("ImageView_status"):loadTexture("img_" .. propSpeedtag[serverInfo.speedtag] .. ".png", UI_TEX_TYPE_PLIST)
                self.last_login_btn_list[i].serverid = lastinfo.serverid
                self.last_login_btn_list[i].areaid = lastinfo.areaid
                self.lastloginButtonGroup:addButton(self.last_login_btn_list[i])
                if i == 1 then
                    self.last_login_btn_list[i]:setTouchEnabled(true)
                    self.lastloginButtonGroup:setButtonSelected(1)
                end
            else
                self.last_login_btn_list[i]:setTouchEnabled(false)
                self.last_login_btn_list[i]:hide()
                self.last_login_btn_list[i].serverid = nil
            end
        end
    end
end

return SceneServerList
