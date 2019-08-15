
local PanelSetting = {}
local var = {}

local sys_control = {"music_control","audio_control","showall_control"}
local sys_check = {"check_trade","check_guild","check_group","check_weapon","check_cloth",
    "check_wing","check_title","check_skill","check_monster","check_guild_player","check_alien_player"
}
local show_check = {"check_weapon","check_cloth","check_wing","check_title","check_skill","check_monster","check_guild_player","check_alien_player"}

local pick_check = {"check_gold","check_drug","check_other","check_pick_level","check_zs_item","check_show_level"}

local protect_check = {"check_hp","check_mp","check_hp_fly","check_gohome","check_auto_skill"}

local protect_slider = {"Slider_hp","Slider_mp","Slider_fly","Slider_home"}

local protect_label = {"label_hp_percent","label_mp_percent","label_fly_percent","label_home_percent"}

local bottom_btn = {"Button_account","Button_role","Button_default"}

local INIT_SETTING_TABLE = {
    --system
    ["music_control"] = true,
    ["audio_control"] = true,
    ["check_trade"] = true,
    ["check_guild"] = true,
    ["check_group"] = true,
    ["showall_control"] = false,
    ["check_weapon"] = false,
    ["check_cloth"] = false,
    ["check_wing"] = false,
    ["check_title"] = false,
    ["check_skill"] = false,
    ["check_monster"] = false,
    ["check_guild_player"] = false,
    ["check_alien_player"] = false,
    --pickup
    ["pick_control"] = true,
    ["check_gold"] = true,
    ["check_drug"] = false,
    ["check_other"] = true,
    ["check_pick_level"] = true,
    ["check_zs_item"] = true,
    ["check_show_level"] = true,
    ["num_pick_level"] = 1,
    ["num_show_level"] = 1,
    --protect
    ["protect_control"] = true,
    ["check_hp"] = true,
    ["check_mp"] = true,
    ["check_hp_fly"] = false,
    ["check_gohome"] = false,
    ["check_auto_skill"] = true,
    ["label_hp_percent"] = 95,
    ["label_mp_percent"] = 20,
    ["label_fly_percent"] = 20,
    ["label_home_percent"] = 15,
}

function PanelSetting.initView(params)
    local params = params or {}

    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSetting/PanelSetting.csb")
    widget:addTo(params.parent, params.zorder)
    var.selectTab = 1
    var.widget = widget:getChildByName("Panel_setting")

    var.widget:addClickEventListener(function (pSender)
        NetClient:dispatchEvent({name = Notify.EVENT_CLOSE_PANEL,str = "panel_setting"})
    end)
    --system init
    for i=1,#sys_control do
        var.widget:getWidgetByName(sys_control[i]):addClickEventListener(function (pSender)
            game.SETTING_TABLE[pSender:getName()] = not game.SETTING_TABLE[pSender:getName()]
            PanelSetting.switchButton(pSender,game.SETTING_TABLE[pSender:getName()])
        end)
    end
    for i=1,#sys_check do
        local function check_click(sender)
            local pSender = sender
            if sender:getName() == "label_check" then
                pSender = sender:getParent()
            end
            game.SETTING_TABLE[pSender:getName()] = not game.SETTING_TABLE[pSender:getName()]
            pSender:setSelected(game.SETTING_TABLE[pSender:getName()])
            game.GetMainRole():setPAttr(Const.AVATAR_SET_CHANGE,1)
            if i > 3 then
                if not game.SETTING_TABLE[pSender:getName()] then
                    game.SETTING_TABLE["showall_control"] = false
                    PanelSetting.switchButton(var.widget:getWidgetByName("showall_control"),false,true)
                end
            end
        end
        var.widget:getWidgetByName(sys_check[i]):addClickEventListener(check_click)
        var.widget:getWidgetByName(sys_check[i]):getWidgetByName("label_check"):addClickEventListener(check_click)
    end

    --pick init
    local input_bg = var.widget:getWidgetByName("img_pick_bg")
    var.mPickLevelEdit = util.newEditBox({
        image = "null.png",
        size = input_bg:getContentSize(),
        listener = function (event,editBox)
            if event == "return" then
                local editBoxNum = (tonumber(editBox:getText()) > 0 and tonumber(editBox:getText()) or 1)
                game.SETTING_TABLE["num_pick_level"] = editBoxNum
                editBox:setText(game.SETTING_TABLE["num_pick_level"])
            end
        end,
        x = 5,
        y = 2,
        placeHolder = "1",
        placeHolderSize = 24,
        placeHolderColor = cc.c3b(18,207,40),
        fontSize = 24,
        anchor = cc.p(0,0),
        inputMode = Const.EditBox_InputMode.NUMERIC,
        color = cc.c3b(18,207,40),
    })
    var.mPickLevelEdit:setMaxLength(2)
    input_bg:addChild(var.mPickLevelEdit)

    local input_s_bg = var.widget:getWidgetByName("img_show_bg")
    var.mShowLevelEdit = util.newEditBox({
        image = "null.png",
        size = input_s_bg:getContentSize(),
        listener = function (event,editBox)
            if event == "return" then
                local editBoxNum = (tonumber(editBox:getText()) > 0 and tonumber(editBox:getText()) or 1)
                game.SETTING_TABLE["num_show_level"] = editBoxNum
                editBox:setText(game.SETTING_TABLE["num_show_level"])
            end
        end,
        x = 5,
        y = 2,
        placeHolder = "1",
        placeHolderSize = 24,
        placeHolderColor = cc.c3b(18,207,40),
        fontSize = 24,
        anchor = cc.p(0,0),
        inputMode = Const.EditBox_InputMode.NUMERIC,
        color = cc.c3b(18,207,40),
    })
    var.mShowLevelEdit:setMaxLength(2)
    input_s_bg:addChild(var.mShowLevelEdit)

    var.widget:getWidgetByName("pick_control"):addClickEventListener(function (pSender)
        game.SETTING_TABLE[pSender:getName()] = not game.SETTING_TABLE[pSender:getName()]
        PanelSetting.switchButton(pSender,game.SETTING_TABLE[pSender:getName()])
    end)

    for i=1,#pick_check do
        local function check_click(sender)
            local pSender = sender
            if sender:getName() == "label_check" then
                pSender = sender:getParent()
            end
            game.SETTING_TABLE[pSender:getName()] = not game.SETTING_TABLE[pSender:getName()]
            pSender:setSelected(game.SETTING_TABLE[pSender:getName()])
        end
        var.widget:getWidgetByName(pick_check[i]):addClickEventListener(check_click)
        var.widget:getWidgetByName(pick_check[i]):getWidgetByName("label_check"):addClickEventListener(check_click)
    end
    --protect init
    var.widget:getWidgetByName("protect_control"):addClickEventListener(function (pSender)
        game.SETTING_TABLE[pSender:getName()] = not game.SETTING_TABLE[pSender:getName()]
        PanelSetting.switchButton(pSender,game.SETTING_TABLE[pSender:getName()])
    end)

    for i=1,#protect_check do
        local function check_click(sender)
            local pSender = sender
            if sender:getName() == "label_check" or sender:getName() == "label_check_1" or sender:getName() == "label_check_2" then
                pSender = sender:getParent()
            end
            game.SETTING_TABLE[pSender:getName()] = not game.SETTING_TABLE[pSender:getName()]
            pSender:setSelected(game.SETTING_TABLE[pSender:getName()])
        end
        var.widget:getWidgetByName(protect_check[i]):addClickEventListener(check_click)
        if protect_check[i] ~= "check_auto_skill" then
            var.widget:getWidgetByName(protect_check[i]):getWidgetByName("label_check_1"):addClickEventListener(check_click)
            var.widget:getWidgetByName(protect_check[i]):getWidgetByName("label_check_2"):addClickEventListener(check_click)
        else
            var.widget:getWidgetByName(protect_check[i]):getWidgetByName("label_check"):addClickEventListener(check_click)
        end
    end

    for i=1,#protect_slider do
        var.widget:getWidgetByName(protect_slider[i]):addEventListener(function (pSlider)
            local label_name = protect_label[i]
            game.SETTING_TABLE[label_name] = math.floor(pSlider:getPercent())
            var.widget:getWidgetByName(protect_label[i]):setString(math.floor(pSlider:getPercent()))
        end)
    end

    --3btn init
    for i=1,#bottom_btn do
        var.widget:getWidgetByName(bottom_btn[i]):addClickEventListener(function (pSender)
            if pSender:getName() == "Button_account" then
                game.ExitToRelogin(true)
            elseif pSender:getName() == "Button_role" then
                game.ExitToReSelect()
            elseif pSender:getName() == "Button_default" then
                NetClient:PushLuaTable("player.setGameData",util.encode(INIT_SETTING_TABLE))
                NetClient:PushLuaTable("player.getGameData","")
            end
        end)
    end

    if game.GetMainRole() then
        local job = game.getRoleJob()
        local temp_str = "自动释放护盾"
        if job == Const.JOB_ZS then
            temp_str = "自动释放烈火"
        elseif job == Const.JOB_FS then
            temp_str = "自动释放护盾"
        elseif job == Const.JOB_DS then
            temp_str = "自动召唤神兽"
        end
        var.widget:getWidgetByName("check_auto_skill"):getWidgetByName("label_check"):setString(temp_str)

    end

    PanelSetting.addMenuTabClickEvent()
    PanelSetting.registeEvent()
    -- NetClient:PushLuaTable("player.getGameData","")

    return var.widget
end

function PanelSetting.switchButton(pSender,value,notPass)
    if not value then
        pSender:loadTexture("img_input03.png",UI_TEX_TYPE_PLIST)
        pSender:getWidgetByName("control_bg"):setPositionX(15)
        if pSender:getName() == "showall_control" and (not notPass) then
            for i=1,#show_check do
                local temp_check = var.widget:getWidgetByName(show_check[i])
                game.SETTING_TABLE[temp_check:getName()] = false
                temp_check:setSelected(false)
            end
        end
        if pSender:getName() == "music_control" then
            SimpleAudioEngine:stopMusic(true)
        end
    else
        pSender:loadTexture("control_open.png",UI_TEX_TYPE_PLIST)
        pSender:getWidgetByName("control_bg"):setPositionX(70)
        if pSender:getName() == "showall_control" and (not notPass) then
            for i=1,#show_check do
                local temp_check = var.widget:getWidgetByName(show_check[i])
                game.SETTING_TABLE[temp_check:getName()] = true
                temp_check:setSelected(true)
            end
        end
        if pSender:getName() == "music_control" then
            if game.mPausedMusic ~= "" and not SimpleAudioEngine:isMusicPlaying() then
                SimpleAudioEngine:playMusic(game.mPausedMusic,true)
            end
        end
    end
end

function PanelSetting.addMenuTabClickEvent()
    --  加入的顺序重要 就是updateListViewByTag的回调参数
    local RadionButtonGroup = UIRadioButtonGroup.new()
        :addButton(var.widget:getWidgetByName("Button_system"))
        :addButton(var.widget:getWidgetByName("Button_pickup"))
        :addButton(var.widget:getWidgetByName("Button_protect"))
        :onButtonSelectChanged(function(event)
            PanelSetting.updatePanelByTag(event.selected)
        end)
    RadionButtonGroup:setButtonSelected(var.selectTab)
end

function PanelSetting.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
        :addEventListener(Notify.EVENT_GAME_SETTING, PanelSetting.handleUpdateSet)
end

function PanelSetting.handleUpdateSet(event)
    if event and event.str ~= "" then
        game.SETTING_TABLE = util.decode(event.str)
        PanelSetting.updatePanelByTag(var.selectTab)
    else
        NetClient:PushLuaTable("player.setGameData",util.encode(INIT_SETTING_TABLE))
    end
end

function PanelSetting.updatePanelByTag(tag)
    var.selectTab = tag
    var.widget:getWidgetByName("Panel_system"):hide()
    var.widget:getWidgetByName("Panel_pickup"):hide()
    var.widget:getWidgetByName("Panel_protect"):hide()
    if tag == 1 then
        var.widget:getWidgetByName("Panel_system"):show()
        for i=1,#sys_control do
            local control_name = sys_control[i]
            PanelSetting.switchButton(var.widget:getWidgetByName(control_name),game.SETTING_TABLE[control_name],true)
        end
        for i=1,#sys_check do
            local check_name = sys_check[i]
            var.widget:getWidgetByName(check_name):setSelected(game.SETTING_TABLE[check_name])
        end
        var.widget:getWidgetByName("img_title_show"):hide()
        var.widget:getWidgetByName("check_trade"):hide()
        var.widget:getWidgetByName("check_guild"):hide()
        var.widget:getWidgetByName("check_group"):hide()
    elseif tag == 2 then
        var.widget:getWidgetByName("Panel_pickup"):show()
        var.mPickLevelEdit:setText(game.SETTING_TABLE["num_pick_level"])
        var.mShowLevelEdit:setText(game.SETTING_TABLE["num_show_level"])
        PanelSetting.switchButton(var.widget:getWidgetByName("pick_control"),game.SETTING_TABLE["pick_control"])
        for i=1,#pick_check do
            local check_name = pick_check[i]
            var.widget:getWidgetByName(check_name):setSelected(game.SETTING_TABLE[check_name])
        end
    elseif tag == 3 then
        var.widget:getWidgetByName("Panel_protect"):show()
        PanelSetting.switchButton(var.widget:getWidgetByName("protect_control"),game.SETTING_TABLE["protect_control"])
        for i=1,#protect_label do
            local label_name = protect_label[i]
            var.widget:getWidgetByName(protect_slider[i]):setPercent(game.SETTING_TABLE[label_name])
            var.widget:getWidgetByName(label_name):setString(game.SETTING_TABLE[label_name])
        end
        for i=1,#protect_check do
            local check_name = protect_check[i]
            var.widget:getWidgetByName(check_name):setSelected(game.SETTING_TABLE[check_name])
        end
    end
end

function PanelSetting.onPanelClose()
    NetClient:PushLuaTable("player.setGameData",util.encode(game.SETTING_TABLE))
    NativeData.saveSettingInfo(game.GetMainRole():NetAttr(Const.net_name))
    game.GetMainRole():setPAttr(Const.AVATAR_SET_CHANGE,1)
end

return PanelSetting