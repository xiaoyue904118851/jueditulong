PixesGhost = {}

function PixesGhost.getPixesGhost(id)
	local pixesGhost = CCGhostManager:getPixesGhostByID(id)
	return pixesGhost
end

function PixesGhost.updateTutomName(id,guildname)
    --print("PixesGhost.updateTutomName", id, guildname)
    local pixesAvatar = CCGhostManager:getPixesAvatarByID(id)
    --print("", pixesAvatar)
    if not pixesAvatar or not pixesAvatar:getSprite() then print("11111") return end
    pixesAvatar:setBelongGuild(guildname)
    local fd = pixesAvatar:getDressFrame(0)
    if not fd then print("2222") return end

    local h = fd:GetValue(0,0,3)
    if h>200 then h=200 end
    local guildLabel = pixesAvatar:getSprite():getChildByName("onwer_guild")
    if not guildLabel then
        guildLabel = util.newUILabel({
            text = "",
            fontSize = 18,
            anchor = cc.p(0.5,0.5),
            color = Const.COLOR_YELLOW_3_C3B,
            position = cc.p(0,h/2),
        })
        guildLabel:addTo(pixesAvatar:getSprite(),10)
    end
    local textstr = "无"
    if guildname and guildname ~= "" then
        textstr = guildname
    end
    guildLabel:setString("行会："..textstr)
end

function PixesGhost.addTypewritter(ghost,str)
    if true then return end
	local length = cc.SystemUtil:getUtf8StrLen(str)
	local baseSprite = ghost:getSprite()
	if baseSprite:getChildByName("bubble") then return end
	local bubble = ccui.ImageView:create()
	bubble:loadTexture("beautyBully.png",UI_TEX_TYPE_PLIST)
	local fd = ghost:getDressFrame(0)
	if fd then
		local h = fd:GetValue(0,0,3)
		bubble:setContentSize(300,100)
		bubble:setAnchorPoint(cc.p(0.5,0))
		bubble:setScale9Enabled(true)
		bubble:setPosition(cc.p(24,h-16))
		bubble:setName("bubble")
		baseSprite:addChild(bubble)
		local label_test = util.newUILabel({
			text = str,
			font = Const.DEFAULT_FONT_NAME,
			fontSize = 24,
		})
		label_test:setVisible(false)
		bubble:addChild(label_test)
		local maxWidth = label_test:getContentSize().width < 300 and (label_test:getContentSize().width+30) or 300
		if maxWidth < 73 then maxWidth = 90 end
		local typer=cc.GuiTextTyper:create(280,0,24)
		if typer then
			local height = typer:setTextTyper(str,24,cc.c3b(0,0,0))
			typer:setPosition(cc.p(15,height+25))
			typer:setAnchorPoint(cc.p(0,1))
			bubble:addChild(typer)
			bubble:setContentSize(maxWidth,height+40)
			typer:runScheduler(length*50)
		end
	end
	local time = length*100 > 2000 and length*100 or 2000
	bubble:runAction(cc.Sequence:create(
		cc.DelayTime:create(time/1000),
		cc.CallFunc:create(function (dx)
			if baseSprite:getChildByName("bubble") then
				baseSprite:removeChildByName("bubble")
			end
	end)))
end


return PixesGhost