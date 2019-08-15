--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/07 14:12
-- To change this template use File | Settings | File Templates.
--LayerMinMap

local LayerMinMap = class("LayerMinMap", function()
    return ccui.Layout:create()
end)

function LayerMinMap:ctor(params)
    self:enableNodeEvents()
    params = params or {}
    self.lastTouchTime = 0
    self.isRadar = checkint(params.isRadar)
    self:setTouchEnabled(self.isRadar ~= 1)

    self.TeamMeb = {}

    self.moveCallBack = params.moveCallBack
    self.mainRole = CCGhostManager:getMainAvatar()
    self:addMap()

    self.miniNpcList = self:getNPCList()
    self.miniNpcConnList = self:getConnList()

    self:showPointOnMap()
    self:showSafeArea()
--    self:runSelfPointTimer()
    self:updateMainRoleMark()
end

function LayerMinMap:registeEvent()
    dw.EventProxy.new(NetClient, self)
    :addEventListener(Notify.EVENT_BOSS_FRESH, handler(self,self.handleBossFresh))
    :addEventListener(Notify.EVENT_POS_CHANGE, handler(self,self.handlePosChange))
    :addEventListener(Notify.EVENT_NOTIFY_TEAMPLAYERPOS, handler(self,self.handleTeamPlayerPosChange))
end

function LayerMinMap:getNPCList()
    local currentNetMapID = NetClient.mNetMap.mMapID
    local miniNpcList = {}
    for i=1,#NetClient.mMiniNpc do
        local nmmn = NetClient.mMiniNpc[i]
        if nmmn.mMapID == currentNetMapID then
            table.insert(miniNpcList, nmmn)
        end
    end

    return miniNpcList
end

-- 传送门
function LayerMinMap:getConnList()
    local currentNetMapID = NetClient.mNetMap.mMapID
    local miniNpcConnList = {}
    local mapCon = MapConnDefData[currentNetMapID]
    if mapCon then
        for i=1,#mapCon do
            local nmc = NetClient.mMapConn[mapCon[i]]
            table.insert(miniNpcConnList, nmc)
        end
    end

    return miniNpcConnList
end

function LayerMinMap:addMap()
    self.mapImg = ccui.ImageView:create()
    self.mapImg:align(display.LEFT_BOTTOM, 0, 0)
    self.mapImg:setTouchEnabled(self.isRadar ~= 1)
    self.minimapID = NetClient.mNetMap.mMiniMapID
    if self.minimapID then
        self.mapImg:loadTexture(string.format("minimap/%05d.jpg", self.minimapID),UI_TEX_TYPE_LOCAL)
    end
    self.origSize = self.mapImg:getContentSize()
    self:setContentSize(self.origSize)
    self:addChild(self.mapImg)

    self.mapImg:addClickEventListener(function (pSender)
        if game.getTime() - self.lastTouchTime < 150 then
            return
        end

        self.touchEndPos = pSender:convertToNodeSpace(pSender:getTouchEndPosition())
        self.changeRoad = true
        local mapPos = self:miniPosToMap(self.touchEndPos)
        MainRole.startAutoMoveToMap(NetClient.mNetMap.mMapID,mapPos.x,mapPos.y,0)
        -- self.mainRole:startAutoMoveToPos(mapPos.x,mapPos.y)

        if not self.gotoTargetImg then
            self.gotoTargetImg = ccui.ImageView:create()
            self.gotoTargetImg:loadTexture("goto_target.png",UI_TEX_TYPE_PLIST)
            self.gotoTargetImg:setAnchorPoint(cc.p(0.5,0))
            self.mapImg:addChild(self.gotoTargetImg)
        end
        self.gotoTargetImg:setPosition(self.touchEndPos)

        self.lastTouchTime = game.getTime()
    end)
end

-- 显示地图上的NPC，连接点，自己，怪物等
function LayerMinMap:showPointOnMap()
    if not self.mapImg then return end
    self:addNpcOnMap()
    self:addConnOnMap()
    self:addMonsterOnMap()
    self:handleTeamPlayerPosChange()
end

function LayerMinMap:addNpcOnMap()
    for i = 1, #self.miniNpcList do
        local nmmn = self.miniNpcList[i]
        local mPos = self:mapPosToMini(cc.p(nmmn.mX,nmmn.mY))

        local npc_mark = ccui.ImageView:create()
        npc_mark:align(display.CENTER, 0.5, 0.5)
        npc_mark:setPosition(mPos)

        --        mShowNpcFlag  TODO

        if self.isRadar ~= 1  then
            local npc_name = ccui.Text:create()
            npc_name:align(display.LEFT_CENTER, 0, 0.5)
            npc_name:setString(nmmn.mNpcShortName)
            npc_name:setFontSize(18)
            npc_name:setFontName(Const.DEFAULT_FONT_NAME)
            --
            --npc_mark:addChild(npc_name)
            npc_mark:loadTexture("npc_mark.png",UI_TEX_TYPE_PLIST)
            --[[
            if string.find(nmmn.mNpcName,"Lv:") then
               -- 怪物
                npc_name:setPosition(cc.p(0,0))
                npc_name:setColor(cc.c3b(255, 0, 0))
            else
                npc_name:setPosition(cc.p(16,17))
                npc_mark:loadTexture("npc.png",UI_TEX_TYPE_PLIST)
                npc_name:setColor(cc.c3b(0, 255, 0))
            end
            ]]
        else
            npc_mark:loadTexture("npc_mark.png",UI_TEX_TYPE_PLIST)
        end

        if string.find(nmmn.mNpcName,"Lv:") then
            npc_mark:setColor(cc.c3b(255, 0, 0))
        else
            npc_mark:setColor(Const.COLOR_GREEN_1_C3B)
        end
        self.mapImg:addChild(npc_mark, 10)
    end
end

function LayerMinMap:addConnOnMap()
    -- 传送点
    for i = 1, #self.miniNpcConnList do
        local nmc = self.miniNpcConnList[i]
        local mPos = self:mapPosToMini(cc.p(nmc.mFromX,nmc.mFromY))
        local npc_mark = ccui.ImageView:create()
        npc_mark:align(display.CENTER, mPos.x, mPos.y)
        npc_mark:loadTexture("img_map_chuan.png",UI_TEX_TYPE_PLIST)


        local npc_name = ccui.Text:create()
        npc_name:setString(nmc.mDesMapName)
        npc_name:setFontSize(18)
        npc_name:setFontName(Const.DEFAULT_FONT_NAME)
        npc_name:setColor(Const.COLOR_GREEN_1_C3B)
        npc_name:align(display.CENTER_BOTTOM, npc_mark:getContentSize().width/2, npc_mark:getContentSize().height)
        npc_mark:addChild(npc_name)

        self.mapImg:addChild(npc_mark, 10)
    end
end

function LayerMinMap:addMonsterOnMap()
    self.monsterFreshNode = {}

    for monsername, nmc in pairs(NetClient.mMapMonster) do
        local mPos = self:mapPosToMini(cc.p(nmc.mX,nmc.mY))
        local mon_mark = ccui.ImageView:create()
        mon_mark:align(display.CENTER, mPos.x, mPos.y)
        mon_mark:loadTexture("boss_mark.png",UI_TEX_TYPE_PLIST)

        local monster_name = ccui.Text:create()
        monster_name:setString(nmc.mNpcShortName)
        monster_name:setFontSize(18)
        monster_name:setFontName(Const.DEFAULT_FONT_NAME)
        monster_name:align(display.CENTER_BOTTOM, mon_mark:getContentSize().width/2, mon_mark:getContentSize().height + 20)
        monster_name:setColor(Const.COLOR_GREEN_1_C3B)
        mon_mark:addChild(monster_name)

        local fresh_label = ccui.Text:create()
        fresh_label:setString("")
        fresh_label:setFontSize(18)
        fresh_label:setFontName(Const.DEFAULT_FONT_NAME)
        fresh_label:align(display.CENTER_BOTTOM, mon_mark:getContentSize().width/2, mon_mark:getContentSize().height)
        fresh_label:setColor(Const.COLOR_GREEN_1_C3B)
        mon_mark:addChild(fresh_label)

        self.monsterFreshNode[monsername] = fresh_label
        self:updateMonsterFreshTime(monsername)
        self.mapImg:addChild(mon_mark, 10)
    end

end

function LayerMinMap:updateMonsterFreshTime(monstername)
    local fresh_label = self.monsterFreshNode[monstername]
    if not fresh_label then return end
    local nmc = NetClient.mMapMonster[monstername]
    if not nmc then return end
    fresh_label:stopAllActions()
    if nmc.mReliveTime > 0 then
        fresh_label.cd = nmc.mReliveTime
        fresh_label:setColor(Const.COLOR_RED_1_C3B)
        fresh_label:setString("("..game.convertSecondsToH(fresh_label.cd)..")")
        fresh_label:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.CallFunc:create(function(pSender)
                pSender.cd = nmc.mReliveTime
                if pSender.cd <= 0 then
                    fresh_label:setColor(Const.COLOR_GREEN_1_C3B)
                    fresh_label:setString("刷新点")
                    pSender:stopAllActions()
                else
                    pSender:setString("("..game.convertSecondsToH(pSender.cd)..")")
                end
            end)
        )))
    else
        fresh_label:setColor(Const.COLOR_GREEN_1_C3B)
        fresh_label:setString("刷新点")
    end
end

function LayerMinMap:handleBossFresh(event)
    if not event or not event.bossname then return end
    self:updateMonsterFreshTime(event.bossname)
end

function LayerMinMap:handlePosChange()
    self:updateMainRoleMark()
end

function LayerMinMap:handleTeamPlayerPosChange()
    if #NetClient.mGroupMembers > 0 then
        for i=1,#NetClient.mGroupMembers do 
            if NetClient.mGroupMembers[i].showFlag then
                if NetClient.mGroupMembers[i].showFlag == 1 or NetClient.mGroupMembers[i].showFlag == 2 then
                    local selfPos = self:mapPosToMini(cc.p(NetClient.mGroupMembers[i].PosX,NetClient.mGroupMembers[i].PosY))
                    if not self:getTeamPlayer(NetClient.mGroupMembers[i].name) then
                        local  teamImg = ccui.ImageView:create()
                        teamImg:loadTexture("teamer_mark.png",UI_TEX_TYPE_PLIST)
                        teamImg:setAnchorPoint(cc.p(0.5,0.5))
                        teamImg:setPosition(selfPos)
                        teamImg:setName(NetClient.mGroupMembers[i].name)
                        self.TeamMeb[NetClient.mGroupMembers[i].name] = teamImg
                        self.mapImg:addChild(teamImg, 10)
                    else
                        self:getTeamPlayer(NetClient.mGroupMembers[i].name):setPosition(selfPos)
                    end
                end
            end
        end
    end
    self:RefreashTeamMark()
end

function LayerMinMap:getTeamPlayer(name)
    if not self.TeamMeb then return end
    for k,v in pairs(self.TeamMeb) do 
        if k == name then
            return v 
        end
    end
    return false  
end

function LayerMinMap:RefreashTeamMark()
    if not self.TeamMeb then return end
    for k,v in pairs(self.TeamMeb) do 
        if not self:checkTeamMeb(k) then
            self.mapImg:removeChildByName(k)
            v =nil
        end
    end  
end

function LayerMinMap:checkTeamMeb(name)
    for i = 1,#NetClient.mGroupMembers do 
        if NetClient.mGroupMembers[i].name == name then
            if NetClient.mGroupMembers[i].showFlag then
                if NetClient.mGroupMembers[i].showFlag == 1 or NetClient.mGroupMembers[i].showFlag == 2 then
                    return true
                end
            end
        end
    end
    return false  
end

function LayerMinMap:updateMainRoleMark()
    if not self.mainRole then return end
    local selfPos = self:mapPosToMini(cc.p(self.mainRole:PAttr(Const.AVATAR_X),self.mainRole:PAttr(Const.AVATAR_Y)))
    if not self.selfImg then
        self.selfImg = ccui.ImageView:create()
        self.selfImg:loadTexture("mainrole_mark.png",UI_TEX_TYPE_PLIST)
        self.selfImg:setAnchorPoint(cc.p(0.5,0.5))
        self.selfImg:setPosition(selfPos)
        if self.moveCallBack then self.moveCallBack() end
        self.mapImg:addChild(self.selfImg, 10)
    else
        local xDis = math.abs(self.selfImg:getPositionX() - selfPos.x)
        local yDis = math.abs(self.selfImg:getPositionY() - selfPos.y)
        if xDis > 1 or yDis > 1 then
            self.selfImg:setPosition(selfPos)
            if self.moveCallBack then self.moveCallBack() end
        end
    end
end

function LayerMinMap:runSelfPointTimer()
    if not self.mapImg then return end
    self.selfImg = ccui.ImageView:create()
    self.selfImg:loadTexture("mainrole_mark.png",UI_TEX_TYPE_PLIST)
    if not self.mainRole then return end
    local selfPos = self:mapPosToMini(cc.p(self.mainRole:PAttr(Const.AVATAR_X),self.mainRole:PAttr(Const.AVATAR_Y)))
    self.selfImg:setAnchorPoint(cc.p(0.5,0.5))
    --self.selfImg:setColor(cc.c3b(0, 0, 255))
    self.selfImg:setPosition(selfPos)
    self.mapImg:addChild(self.selfImg, 10)

    self.mapImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
        -- if game.mReSelectRole then self.mapImg:stopAllActions() return end
        local rolePos = self:mapPosToMini(cc.p(self.mainRole:PAttr(Const.AVATAR_X),self.mainRole:PAttr(Const.AVATAR_Y)))

        if not self.selfImg or not rolePos then return end

        local xDis = math.abs(self.selfImg:getPositionX() - rolePos.x)
        local yDis = math.abs(self.selfImg:getPositionY() - rolePos.y)
        if xDis > 1 or yDis > 1 then
            self.selfImg:setPosition(rolePos)
            if self.moveCallBack then self.moveCallBack() end
        end
    end))))
end

function LayerMinMap:showSafeArea()
    if NetClient.mSafeArea == nil then return end
    local safeAreaImg = "uilayout/image/safearea_point.png"
    local batchNode = cc.SpriteBatchNode:create(safeAreaImg, 20)
    self.mapImg:addChild(batchNode, 10)

    local safeArea = NetClient.mSafeArea
    local mX = safeArea.mX
    local mY = safeArea.mY
    local size = safeArea.mSize
    local safe_scale = 0.6

    for i = -size, size, 3 do
        local s = size - math.abs( i )
        local x = mX + i - 0
        local y = mY + s
        local safe = display.newSprite(safeAreaImg)
        safe:setPosition( self:mapPosToMini(cc.p(x, y)) )
        safe:setScale(safe_scale)
        batchNode:addChild( safe )

        if s ~= 0 then
            y = mY - s
            safe = display.newSprite(safeAreaImg)
            safe:setPosition( self:mapPosToMini(cc.p(x, y)) )
            safe:setScale(safe_scale)
            batchNode:addChild( safe )
        end

    end



--    for i = 1, 10 do
--        local safe = display.newSprite(safeAreaImg)
--        safe:setPosition( self:mapPosToMini(cc.p(x, y)) )
--        batchNode:addChild( safe )
--        x = x + 1
----        y = y + 1
--
--    end

end

function LayerMinMap:getSelfPos()
    if not self.selfImg then return end
    return cc.p(self.selfImg:getPositionX(), self.selfImg:getPositionY())
end

function LayerMinMap:mapPosToMini(mpos)
    if not NetCC then return mpos end
    local map = NetCC:getMap()
    if not map then return mpos end

    local mapWidth = NetCC:getMap():LogicWidth()
    local mapHeight = NetCC:getMap():LogicHeight()
    return cc.p(self.origSize.width/mapWidth*mpos.x, self.origSize.height - self.origSize.height/mapHeight * mpos.y)
end

function LayerMinMap:miniPosToMap(mpos)
    local mapWidth = cc.NetClient:getInstance():getMap():LogicWidth()
    local mapHeight = cc.NetClient:getInstance():getMap():LogicHeight()

    return cc.p(mpos.x * mapWidth / self.origSize.width, mapHeight - mpos.y * mapHeight / self.origSize.height)
end

function LayerMinMap:updateMapRes()
    
    if self.minimapID and NetClient.mNetMap.mMiniMapID then
        if self.minimapID ~= NetClient.mNetMap.mMiniMapID then
            self.minimapID = NetClient.mNetMap.mMiniMapID
            self.mapImg:loadTexture(string.format("minimap/%05d.jpg", self.minimapID),UI_TEX_TYPE_LOCAL)
        end
    end
end

function LayerMinMap:onEnter()
    self:registeEvent()
end

return LayerMinMap