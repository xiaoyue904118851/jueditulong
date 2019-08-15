SceneSelectRole = class("SceneSelectRole", cc.load("mvc").ViewBase)

SceneSelectRole.RESOURCE_FILENAME = "uilayout/SceneSelectRole/SceneSelectRole.csb"

local job_list = {
    [Const.JOB_ZS] = {Const.str_zs,"uilayout/image/login/despzs.png","button_zs.png", "button_zs_sel.png",},
    [Const.JOB_FS] = {Const.str_fs,"uilayout/image/login/despfs.png","button_fs.png", "button_fs_sel.png",},
    [Const.JOB_DS] = {Const.str_ds,"uilayout/image/login/despds.png" ,"button_ds.png", "button_ds_sel.png",},
}

local gender_list = {
    {"uilayout/image/login/showzsf.png","uilayout/image/login/showfsm.png","uilayout/image/login/showdsm.png"},
    {"uilayout/image/login/showzsm.png","uilayout/image/login/showfsf.png","uilayout/image/login/showdsf.png"},
}

local list_pos = {
    cc.p(280,603),cc.p(232,474),cc.p(233,316),cc.p(281,176),
}

function SceneSelectRole:onCreate()
    require("app.layers.LayerAlert").new():addTo(self, 999)
    self.widget = self:getResourceNode():getChildByName("Panel_selectrole")
    self.widget:align(display.CENTER, display.cx, display.cy)
    self.widget:setScale(Const.minScale)
--    self.widget:getWidgetByName("img_login_bg"):loadTexture("uilayout/image/loading2.jpg",UI_TEX_TYPE_LOCAL)--:setContentSize(cc.size(Const.VISIBLE_WIDTH,Const.VISIBLE_HEIGHT))
    self.roleItemNode = self.widget:getWidgetByName("Button_role"):hide()
    self.createNode = self.widget:getWidgetByName("Panel_create"):hide()
    self.mRoleIntro =self.widget:getWidgetByName("ImageView_rolelist")
    self.mRoleList = {}
    self.lastClickTime = 0
    self.widget:getWidgetByName("Button_gamestart"):addClickEventListener(function (sender)
        if self.m_pCurChar then

            game.mChrName=self.m_pCurChar.mName
            game.mSeedName=self.m_pCurChar.mSeedName
            self:getApp():enterScene("SceneLoading")
        end
    end)

    self.widget:getWidgetByName("Button_delete"):addClickEventListener(function (sender)
        self:onDelChar(sender)
    end)

    self.widget:getWidgetByName("Button_back"):addClickEventListener(function ( pSender )
        NetworkCenter:disconnect()
        game.cleanGame()
        asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
            self:getApp():enterScene("SceneLogin")
        end)
    end)

    self.mRoleCurr = ccui.ImageView:create()
            :align(display.CENTER, display.cx-(Const.VISIBLE_WIDTH-Const.WIN_WIDTH)/2, Const.VISIBLE_Y+Const.WIN_HEIGHT/2)
            :addTo(self.widget)
end

function SceneSelectRole:onEnter( ... )
    self.m_handler = dw.EventProxy.new(NetClient,self.widget)
    self.m_handler:addEventListener(Notify.EVENT_LOADCHAR_LIST, handler(self,self.handleCharLoaded))
    self.m_handler:addEventListener(Notify.EVENT_GAME_RELOGIN, handler(self,self.reLogin))

    if game.mReSelectRole then--重新登录
        NetworkCenter:connect(game.mServerIP,game.mServerPort)
    else
        self:handleCharLoaded()
    end
end

function SceneSelectRole:reLogin(event)
    if event and event.str then
        if event.str == "relogin" then
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
                self:getApp():enterScene("SceneLogin")
            end)
        end
    end
end

function SceneSelectRole:onExit( ... )
    if self.m_handler then
        self.m_handler:removeAllEventListeners()
    end

    if game.mReSelectRole then--重新登录
        game.mReSelectRole = false
    end

end

function SceneSelectRole:handleCharLoaded(event)
    -- self:updateRoleList()
    self:updateListCharactor()
end

function SceneSelectRole:updateListCharactor()
    if #NetClient.mNetChar <= 0 then
        asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
            self:getApp():enterScene("SceneCreateRole")
        end)
        return
    end
    NetClient.curSelect = math.max(NetClient.curSelect, 1)
    for _, v in ipairs(self.mRoleList) do
        v:removeFromParent()
    end
    self.mRoleList={}
    for i=1,#NetClient.mNetChar do
        local netchar = NetClient.mNetChar[i]
        local roleWidget = self.roleItemNode:clone():show():addTo(self.widget)
        roleWidget:getWidgetByName("Label_lv"):setString("Lv."..netchar.mLevel)
        roleWidget:getWidgetByName("Label_name"):setString(netchar.mName)
        roleWidget.netchar = netchar
        roleWidget:addClickEventListener(function ( pSender )
            if i == self.curIndex then
                pSender:setBrightStyle(BRIGHT_HIGHLIGHT)
                if self.lastClickTime > 0 then
                    if game.getTime() - self.lastClickTime < 200 then
                        if self.m_pCurChar then
                            self.lastClickTime = 0
                            game.mChrName=self.m_pCurChar.mName
                            game.mSeedName=self.m_pCurChar.mSeedName
                            self:getApp():enterScene("SceneLoading")
                        end
                    else
                        self.lastClickTime = game.getTime()
                    end
                else
                    self.lastClickTime = game.getTime()
                end
            else
                self.lastClickTime = game.getTime()
                self:selectRole(pSender)
                self.m_pCurChar = pSender.netchar
                self.curIndex = i
            end
        end)
        roleWidget:setPosition(list_pos[#self.mRoleList + 1])
        table.insert(self.mRoleList, roleWidget)

        if i == NetClient.curSelect then
            self:selectRole(roleWidget,NetClient.curSelect)
            self.m_pCurChar = netchar
            self.curIndex = NetClient.curSelect
        else
            roleWidget:getWidgetByName("Image_job"):loadTexture(job_list[netchar.mJob][3],UI_TEX_TYPE_PLIST)
        end
    end
    if #NetClient.mNetChar < 4 then
        for i = 1, 4-#NetClient.mNetChar do
            local Panel_create = self.createNode:clone():show():addTo(self.widget)
            Panel_create:getWidgetByName("Button_cr"):addClickEventListener(function ( pSender )
               asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
                    self:getApp():enterScene("SceneCreateRole")
                end)
            end)
            Panel_create:setPosition(list_pos[#self.mRoleList + 1])
            table.insert(self.mRoleList, Panel_create)
        end
    end
end

function SceneSelectRole:selectRole(pSender,index)
    if not index then
        for i=1,#NetClient.mNetChar do
            local btn = self.mRoleList[i]
            btn:setTouchEnabled(true):setBrightStyle(BRIGHT_NORMAL)
            btn:getWidgetByName("Image_job"):loadTexture(job_list[btn.netchar.mJob][3],UI_TEX_TYPE_PLIST)
            btn:getWidgetByName("Image_bg"):loadTexture("role_list.png",UI_TEX_TYPE_PLIST)
            btn:getWidgetByName("Label_lv"):setTextColor(Const.COLOR_YELLOW_2_C3B)
            btn:getWidgetByName("Label_name"):setTextColor(Const.COLOR_YELLOW_2_C3B)
        end
    end
    pSender:getWidgetByName("Image_bg"):loadTexture("role_list_sel.png",UI_TEX_TYPE_PLIST)
    pSender:getWidgetByName("Image_job"):loadTexture(job_list[pSender.netchar.mJob][4],UI_TEX_TYPE_PLIST)
    pSender:getWidgetByName("Label_lv"):setTextColor(Const.COLOR_WHITE_1_C3B)
    pSender:getWidgetByName("Label_name"):setTextColor(Const.COLOR_WHITE_1_C3B)
    pSender:setBrightStyle(BRIGHT_HIGHLIGHT)
    self.mRoleIntro:loadTexture(job_list[pSender.netchar.mJob][2],UI_TEX_TYPE_LOCAL)
    self.mRoleCurr:loadTexture(gender_list[pSender.netchar.mGender-199][pSender.netchar.mJob-99],UI_TEX_TYPE_LOCAL):stopAllActions()

end

function SceneSelectRole:onDelChar(psender)
    if not self.m_pCurChar then
        return
    end

    if self.isDeleteCool then
        local param = {
            name = Notify.EVENT_PANEL_ON_ALERT, panel = "alert", visible = true,
            lblAlert ="稍等一会儿再删除吧",
            alertTitle = "关 闭",
        }
        NetClient:dispatchEvent(param)
        return
    end

    local param = {
        name = Notify.EVENT_PANEL_ON_ALERT, panel = "confirm", visible = true,
        lblConfirm = {
            "确定删除角色"..game.make_str_with_color(Const.COLOR_GREEN_1_STR,self.m_pCurChar.mName).."？",
            "删除后无法恢复！",
        },
        confirmTitle = "取 消", cancelTitle = "删 除",
        cancelCallBack = function ()
            NetClient:DeleteCharacter(self.m_pCurChar.mName)
            self.isDeleteCool = true
            psender:stopAllActions()
            psender:runAction(
                cc.Sequence:create(cc.DelayTime:create(6), cc.CallFunc:create(function()
                    self.isDeleteCool = false
                end)))
        end
    }
    NetClient:dispatchEvent(param)
end

return SceneSelectRole
