--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/09/15 12:32
-- To change this template use File | Settings | File Templates.
--

local PanelSkillSetting = {}
local var = {}

function PanelSkillSetting.initView(params)
    local params = params or {}
    var = {}
    var.totalPage = 2
    var.curPage = 1
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelSkillSetting/UI_Skill_Setting_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_SkillSetting")
    var.skilllistView = var.widget:getWidgetByName("ListView_skil")

    var.copyNode = var.widget:getWidgetByName("daojuBox"):hide()
    var.btnClone = var.widget:getWidgetByName("Button_skill_sel"):hide()
    var.dragIcon = var.widget:getWidgetByName("Image_dragicon"):hide()
    var.dragIcon:ignoreContentAdaptWithSize(true)

    var.widget:getWidgetByName("Button_go_skill")
    :addClickEventListener(function(pSender)
        EventDispatcher:dispatchEvent({name = Notify.EVENT_OPEN_PANEL, str = "panel_roleInfo",  pdata = {tag = 2}})
    end)

    PanelSkillSetting.init_ui_attack()
    PanelSkillSetting.initItemListView()
    PanelSkillSetting.updateSkillListView()
    PanelSkillSetting.handleShortcutChange()
    PanelSkillSetting.registeEvent()

    return var.widget
end

function PanelSkillSetting.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_SHORTCUT_CHANGE, PanelSkillSetting.handleShortcutChange)
end

function PanelSkillSetting.init_ui_attack()
    var.skillLayer = var.widget:getWidgetByName("Panel_attack")
    var.btnLayer_1 = var.skillLayer:getWidgetByName("Panel_btn"):getWidgetByName("Panel_btn1")
    var.btnLayer_2 = var.skillLayer:getWidgetByName("Panel_btn"):getWidgetByName("Panel_btn2"):hide()

    var.btnWidget = {}
    for i = 1, 8 do
        local btnLayer = var.btnLayer_1
        if i > 4 then btnLayer = var.btnLayer_2 end
        local btn = btnLayer:getWidgetByName("skillBox_"..i)
        if btn then
            btn:getWidgetByName("kuang"):hide()
            btn:addTouchEventListener(function(sender,touchType)
                PanelSkillSetting.onTouchShortIcon(sender, touchType)
            end)
            btn.iconImag = btn:getWidgetByName("shortcut")
            btn:setTouchEnabled(false)
            table.insert(var.btnWidget, btnLayer:getWidgetByName("skillBox_"..i))
        end
    end

    var.btnNext = var.skillLayer:getWidgetByName("Button_next")
    var.btnNext:addClickEventListener(function(pSender)
        PanelSkillSetting.onChangePage(1)
    end)

    var.btnPre = var.skillLayer:getWidgetByName("Button_pre")
    var.btnPre:addClickEventListener(function(pSender)
        PanelSkillSetting.onChangePage(-1)
    end)
end

function PanelSkillSetting.initItemListView()
    var.itemlistView = var.widget:getWidgetByName("ListView_item")
    var.itemlistView:removeAllItems()
    for k, v in ipairs(Const.Skill_Setting_Item) do
        local node = var.copyNode:clone():show()
        local btn = node:getWidgetByName("skillImg")
        local itemdef = NetClient:getItemDefByID(v.id)
        if itemdef then
            node:getWidgetByName("shortcut"):ignoreContentAdaptWithSize(true)
            node:getWidgetByName("shortcut"):loadTexture("icon/"..itemdef.mIconID..".png",UI_TEX_TYPE_LOCAL)
            node:getWidgetByName("name"):setString(itemdef.mName)
            btn:addTouchEventListener(function(sender,touchType)
                PanelSkillSetting.onTouchLeftItemIcon(sender, touchType)
            end)
            btn.cutinfo = {type = Const.ShortCutType.Item, param = v.id}
            btn:setTouchEnabled(true)
        else
            btn:setTouchEnabled(false)
        end
        var.itemlistView:pushBackCustomItem(node)
    end
end

function PanelSkillSetting.updateSkillListView()
    var.skilllistView:removeAllItems()
    local skills = game.getMySkillList()
    var.skillListData = {}
    for k, v in ipairs(skills) do
        if not game.IsPassiveSkill( v ) and NetClient.m_netSkill[v] then
            table.insert(var.skillListData, v)
        end
    end
    UIGridView.new({
        list = var.skilllistView,
        gridCount = #var.skillListData,
        cellSize = cc.size(var.skilllistView:getContentSize().width, var.btnClone:getContentSize().height),
        columns = 3,
        initGridListener = PanelSkillSetting.addGridItem
    })
end

function PanelSkillSetting.addGridItem(gridWidget, index)
    local node = var.btnClone:clone()
    node:show()
    node:align(display.CENTER, gridWidget:getContentSize().width/2, gridWidget:getContentSize().height/2)
    node:addTo(gridWidget)

    local btn = node:getWidgetByName("skillImg")

    local skillid = var.skillListData[index]
    local skillDef = NetClient:getSkillDefByID(skillid)
    if skillDef then
        node:getWidgetByName("shortcut"):ignoreContentAdaptWithSize(true)
        node:getWidgetByName("shortcut"):loadTexture("skill"..skillid..".png",UI_TEX_TYPE_PLIST)
        node:getWidgetByName("name"):setString(skillDef.mName)
        btn:addTouchEventListener(function(sender,touchType)
            PanelSkillSetting.onTouchLeftItemIcon(sender, touchType)
        end)
        btn.cutinfo = {type = Const.ShortCutType.Skill, param = skillid}
        btn:setTouchEnabled(true)
        node:getWidgetByName("lv"):setString(NetClient.m_netSkill[skillid].mLevel)
    else
        btn:setTouchEnabled(false)
    end
end

function PanelSkillSetting.getIconStr(cutinfo)
    if cutinfo.type == Const.ShortCutType.Skill then
        return "skill"..cutinfo.param..".png",UI_TEX_TYPE_PLIST
    elseif cutinfo.type == Const.ShortCutType.Item then
        local itemdef = NetClient:getItemDefByID(cutinfo.param)
        if itemdef then
            return "icon/"..itemdef.mIconID..".png",UI_TEX_TYPE_LOCAL
        end
    end
    print("快捷键错误", cutinfo.type, cutinfo.param)
    return ""
end

function PanelSkillSetting.onTouchShortIcon(sender, touchType)
    if touchType == ccui.TouchEventType.began then
        var.dragIcon:loadTexture(PanelSkillSetting.getIconStr(sender.cutinfo))
        return true
    elseif touchType == ccui.TouchEventType.moved then
        local pos = sender:getTouchMovePosition()
        var.dragIcon:show()
        var.dragIcon:setPosition( var.widget:convertToNodeSpace(pos))
        if cc.pDistanceSQ(sender:getTouchBeganPosition(), pos) > 60*60 then
            sender.iconImag:hide()
        end
    elseif touchType == ccui.TouchEventType.canceled or touchType == ccui.TouchEventType.ended then
        var.dragIcon:hide()
        local endpos = sender:getTouchEndPosition()
        if cc.pDistanceSQ(sender:getTouchBeganPosition(), endpos) > 60*60 then
            local cutPos = PanelSkillSetting.getEndPos(endpos)
            if cutPos == nil then
                NetClient.mShortCut[sender.cutinfo.cut_id] = nil
                NetClient:SaveShortcut()
                NetClient:dispatchEvent({name=Notify.EVENT_SHORTCUT_CHANGE})
            else
                local ret = PanelSkillSetting.changeShortcut(cutPos, sender.cutinfo)
                if not ret then sender.iconImag:show() end
            end
        else
            sender.iconImag:show()
        end
    end
end

function PanelSkillSetting.onChangePage(flag)
    local page = var.curPage + flag
    if page > var.totalPage or page < 1 or flag == 0 then
        return
    end
    var.btnPre:setVisible(page==2)
    var.btnNext:setVisible(page==1)
    var.curPage = page
    var.btnLayer_1:setVisible(page==1)
    var.btnLayer_2:setVisible(page==2)
    --    var.btnLayer:runAction( cc.Sequence:create( cc.RotateTo:create(2, (var.curPage - 1) * -120 ),cc.CallFunc:create(function()
    --        UIRightBottom.updateArrow()
    --    end)) )
end

function PanelSkillSetting.handleShortcutChange()
    for i = 1, #var.btnWidget do
        var.btnWidget[i].cutinfo = nil
        var.btnWidget[i]:setTouchEnabled(false)
        var.btnWidget[i]:getWidgetByName("skillImg"):setTouchEnabled(false)
        var.btnWidget[i].iconImag:hide()
    end

    for cut_id, cutinfo in pairs(NetClient.mShortCut) do
        local cutBtn = var.btnWidget[cut_id]
        if cutBtn then
            cutBtn.iconImag:ignoreContentAdaptWithSize(true)
            cutBtn.iconImag:loadTexture(PanelSkillSetting.getIconStr(cutinfo))
            cutBtn.iconImag:show()
            cutBtn.cutinfo = cutinfo
            cutBtn:setTouchEnabled(true)
            cutBtn:getWidgetByName("skillImg"):setTouchEnabled(false)
        end
    end
end

function PanelSkillSetting.getEndPos(pos)
    local cutPos
    local start =  (var.curPage - 1)*4 + 1
    for i = start , start + 3 do
        local btn = var.btnWidget[i]
        local size = btn:getContentSize()
        local  pos_new = btn:convertToNodeSpace(pos )
        if pos_new.x >= 0 and pos_new.x <= size.width and pos_new.y >= 0 and pos_new.y <= size.height then
            cutPos = i
            break
        end
    end
    return cutPos
end

function PanelSkillSetting.onTouchLeftItemIcon(sender, touchType)
    if touchType == ccui.TouchEventType.began then
        var.itemlistView:setTouchEnabled(false)
        var.skilllistView:setTouchEnabled(false)

        var.dragIcon:loadTexture(PanelSkillSetting.getIconStr(sender.cutinfo))
        return true
    elseif touchType == ccui.TouchEventType.moved then
        var.dragIcon:show()
        var.dragIcon:setPosition( var.widget:convertToNodeSpace(sender:getTouchMovePosition()))
    elseif touchType == ccui.TouchEventType.canceled or touchType == ccui.TouchEventType.ended then
        var.itemlistView:setTouchEnabled(true)
        var.skilllistView:setTouchEnabled(true)
        var.dragIcon:hide()
        local cutPos = PanelSkillSetting.getEndPos(sender:getTouchEndPosition())
        if cutPos ~= nil then
            PanelSkillSetting.changeShortcut(cutPos, sender.cutinfo)
        end
    end
end

function PanelSkillSetting.changeShortcut(cutPos, srccutinfo)
    local oldCutinfo = NetClient.mShortCut[cutPos] --目标位置
    if oldCutinfo and  oldCutinfo.type == srccutinfo.type and oldCutinfo.param == srccutinfo.param then
        return false
    end

    --    -- 如果某个位置有 则删除 策划不需要删除 两个位置可以有相同的
    --    local removePos
    --    for cut_id, cutinfo in pairs(NetClient.mShortCut) do
    --        if cutinfo.type == srccutinfo.type and cutinfo.param == srccutinfo.param then
    --            removePos = cut_id
    --            break
    --        end
    --    end
    --    if removePos then
    --        NetClient.mShortCut[removePos] = nil
    --    end


    if not oldCutinfo and srccutinfo.cut_id then
        -- 从一个位置挪到另一个位置 如果目标位置是空的 则把老的删除
        NetClient.mShortCut[srccutinfo.cut_id] = nil
    elseif oldCutinfo and srccutinfo.cut_id then
        -- 如果两个都有 位置互换
        oldCutinfo.cut_id = srccutinfo.cut_id
        NetClient.mShortCut[oldCutinfo.cut_id] = oldCutinfo
    end

    local cutinfo = {}
    cutinfo.cut_id = cutPos
    cutinfo.type = srccutinfo.type
    cutinfo.param = srccutinfo.param
    cutinfo.itemnum = 1
    NetClient.mShortCut[cutPos] = cutinfo
    NetClient:SaveShortcut()
    NetClient:dispatchEvent({name=Notify.EVENT_SHORTCUT_CHANGE})
    return true
end

return PanelSkillSetting