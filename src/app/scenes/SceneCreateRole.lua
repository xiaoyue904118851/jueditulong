SceneCreateRole = class("SceneCreateRole", cc.load("mvc").ViewBase)

SceneCreateRole.RESOURCE_FILENAME = "uilayout/SceneCreateRole/SceneCreateRole.csb"

local job_list = {
    [100] = {Const.str_zs,"uilayout/image/login/despzs.png"},
    [101] = {Const.str_fs,"uilayout/image/login/despfs.png"},
    [102] = {Const.str_ds,"uilayout/image/login/despds.png"}
}

local gender_list = {
    {"uilayout/image/login/showzsf.png","uilayout/image/login/showfsm.png","uilayout/image/login/showdsm.png"},
    {"uilayout/image/login/showzsm.png","uilayout/image/login/showfsf.png","uilayout/image/login/showdsf.png"},
}

function SceneCreateRole:onCreate()
    
    self.widget = self:getResourceNode():getChildByName("panel_createrole")
    self.widget:align(display.CENTER, display.cx, display.cy)
    -- self.widget:setScaleX(Const.SCALE_X)
    -- self.widget:setScaleY(Const.SCALE_Y)
    self.widget:setScale(Const.minScale)
--    self.widget:getWidgetByName("img_login_bg"):loadTexture("uilayout/image/loading2.jpg",UI_TEX_TYPE_LOCAL)--:setContentSize(cc.size(Const.VISIBLE_WIDTH,Const.VISIBLE_HEIGHT))
    -- self.widget:setBackGroundImage("uilayout/image/loading2.jpg",UI_TEX_TYPE_LOCAL)
    self.widget:getWidgetByName("image_rename"):hide()
    self.widget:getWidgetByName("image_rename"):loadTexture("uilayout/image/backgroup_5.png",UI_TEX_TYPE_LOCAL)
    self.widget:getWidgetByName("Button_gamestart_cr"):setLocalZOrder(100):addClickEventListener(function ( pSender )
        NetClient:CreateCharacter(self.inputName:getText(),self.mSelectJob+99,self.mSelectGender+199,"")
    end)
    self.widget:getWidgetByName("Button_back"):addClickEventListener(function ( pSender )
        if #NetClient.mNetChar > 0 then
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
                self:getApp():enterScene("SceneSelectRole")
            end)
        else
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
                NetworkCenter:disconnect()
                game.cleanGame()
                self:getApp():enterScene("SceneLogin")
            end)
        end
    end)
    -- self.inputName = self.widget:getWidgetByName("TextField_nameinput"):setLocalZOrder(100)
    self.widget:getWidgetByName("Button_randname"):setLocalZOrder(100):addClickEventListener(function ( pSender )
        self.inputName:setText(self:randName())
    end)
    self.mRoleIntro =self.widget:getWidgetByName("ImageView_depictbg")

    self.layerMale = self.widget:getWidgetByName("layer_male")--:hide()
    self.layerFemale = self.widget:getWidgetByName("layer_female")--:hide()

    self.buttonNv = self.widget:getWidgetByName("Button_nv")
    self.buttonNan = self.widget:getWidgetByName("Button_nan")

    self.mSelectJob =  os.time() % 3 + 1
    self.mSelectGender =  os.time() % 2 + 1
    self.btnJobTab = {}

    local inputBg = self.widget:getWidgetByName("ImageView_usernamebg"):setLocalZOrder(100)
    local bgSize = inputBg:getContentSize()
    self.inputName = util.newEditBox({
        image = "null.png",
        size = cc.size(bgSize.width-40,bgSize.height),
        -- listener = onEdit,
        x = 20,
        y = 0,
        placeHolder = "请输入账号",
        placeHolderSize = 28,
        fontSize = 30,
        anchor = cc.p(0,0),
    })

    self.inputName:setMaxLength(40):setText(self:randName())
    inputBg:addChild(self.inputName)
    for i=1,3 do
        local roleJob = self.widget:getWidgetByName("btnRoleJob_"..i)
        roleJob.job = i
        roleJob:addClickEventListener(function ( pSender )
            self.mSelectJob = pSender.job
            self:selectJob( pSender )
        end)
        table.insert(self.btnJobTab, roleJob)
        if i == self.mSelectJob then
            self:selectJob( roleJob )
        end
    end
    self:selectGender(self.mSelectJob,self.mSelectGender)
    self.errorTip = self.widget:getWidgetByName("Text_error"):hide()
    self.errorTip:setZOrder(100)
end

function SceneCreateRole:selectJob( pSender )
    for i=1,#self.btnJobTab do
        self.btnJobTab[i]:setTouchEnabled(true):setBrightStyle(BRIGHT_NORMAL)
    end
    pSender:setTouchEnabled(false):setBrightStyle(BRIGHT_HIGHLIGHT)
    self.mRoleIntro:loadTexture(job_list[pSender.job+99][2],UI_TEX_TYPE_LOCAL)
--    self.mSelectGender =  os.time() % 2 + 1
    self:selectGender( pSender.job,self.mSelectGender )
end

function SceneCreateRole:selectGender( job,gender )

    if not self.mRoleMale then
        self.mRoleMale = ccui.ImageView:create()
            :addTo(self.layerMale):setTouchEnabled(false)
        self.widget:getWidgetByName("Button_nan"):addClickEventListener(function ( pSender )
                if self.mSelectGender ~= 1 then
                    self.mSelectGender = 1
                    self:selectGender(self.mSelectJob,self.mSelectGender)
                else
                    pSender:setBrightStyle(BRIGHT_HIGHLIGHT)
                end
--                self.inputName:setText(self:randName())
            end)
    end
    if not self.mRoleFeMale then
        self.mRoleFeMale = ccui.ImageView:create()
            :addTo(self.layerFemale):setTouchEnabled(false)
        self.widget:getWidgetByName("Button_nv"):addClickEventListener(function ( pSender )
                if self.mSelectGender ~= 2 then
                    self.mSelectGender = 2
                    self:selectGender(self.mSelectJob,self.mSelectGender)
                else
                    pSender:setBrightStyle(BRIGHT_HIGHLIGHT)
                end
--                self.inputName:setText(self:randName())
            end)
    end
    if self.mSelectGender == 1 then
        self.buttonNan:setBrightStyle(BRIGHT_HIGHLIGHT)
        self.buttonNv:setBrightStyle(BRIGHT_NORMAL)
        self.layerFemale:hide()
        self.layerMale:show()
    elseif self.mSelectGender == 2 then
        self.buttonNv:setBrightStyle(BRIGHT_HIGHLIGHT)
        self.buttonNan:setBrightStyle(BRIGHT_NORMAL)
        self.layerMale:hide()
        self.layerFemale:show()
    end

    self.mRoleMale:loadTexture(gender_list[1][job],UI_TEX_TYPE_LOCAL):stopAllActions():align(display.CENTER, 150, 200)
    self.mRoleFeMale:loadTexture(gender_list[2][job],UI_TEX_TYPE_LOCAL):stopAllActions():align(display.CENTER, 150, 200)
    local selectList = {
        --------缩放 灰度 x坐标
        {male = {1,255,255,255,180},female = {0.75,120,120,120,120}},
        {male = {0.75,120,120,120,180},female = {1,255,255,255,120}},
    }
    local pSpawnMale = cc.Spawn:create(cc.ScaleTo:create(0.1,selectList[gender].male[1]),
        cc.TintTo:create(0.1,selectList[gender].male[2],selectList[gender].male[3],selectList[gender].male[4]),
        cc.MoveTo:create(0.1,cc.p(selectList[gender].male[5],200 )))
    self.mRoleMale:runAction(pSpawnMale)
    local pSpawnFemale = cc.Spawn:create(cc.ScaleTo:create(0.1,selectList[gender].female[1]),
        cc.TintTo:create(0.1,selectList[gender].female[2],selectList[gender].female[3],selectList[gender].female[4]),
        cc.MoveTo:create(0.1,cc.p(selectList[gender].female[5],200 )))
    self.mRoleFeMale:runAction(pSpawnFemale)
end

function SceneCreateRole:randName(  )
    -- local randName = RandomNameDef.XING[math.random(1, #RandomNameDef.XING)]
    -- local mingattr = RandomNameDef.MING[self.mSelectGender+199]
    -- randName = randName..mingattr[math.random(1, #mingattr)]
    local randName = RandomNameDef.ALL[math.random(1, #RandomNameDef.ALL)]
    return randName
end

function SceneCreateRole:onEnter( ... )
    self.m_handler = dw.EventProxy.new(NetClient,self.widget)
    self.m_handler:addEventListener(Notify.EVENT_CREATECHARACTOR, handler(self,self.handleRoleCreated))
    self.m_handler:addEventListener(Notify.EVENT_GAME_RELOGIN, handler(self,self.reLogin))
end

function SceneCreateRole:reLogin(event)
    if event and event.str then
        if event.str == "relogin" then
            asyncload_frames("uilayout/SceneLogin/SceneLogin",Const.TEXTURE_TYPE.PNG,function ()
                self:getApp():enterScene("SceneLogin")
            end)
        end
    end
end

function SceneCreateRole:handleRoleCreated(event)
    if event.result==100 then
        game.mChrName = self.inputName:getText()
        game.mSeedName = event.seedname
        self:getApp():enterScene("SceneLoading")
--        NativeData.loadSetting(game.mChrName)
    else
        if event.error_msg then
            self.errorTip:show()
            self.errorTip:setString(event.error_msg)
        end
        print("create character error :",event.result)
    end
end

function SceneCreateRole:onExit( ... )
    if self.m_handler then
        self.m_handler:removeAllEventListeners()
    end
end

return SceneCreateRole
