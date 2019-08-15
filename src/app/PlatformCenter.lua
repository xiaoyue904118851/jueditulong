PlatformCenter={}
PlatformCenter.Logined = false
PlatformCenter.Isevent = false
PlatformCenter.onPayListener=nil

function PlatformCenter.login()
	PlatformTool.callPlatformFunc({func="login"})
end

function PlatformCenter.logout()
	game.gameKey=""
	PlatformCenter.Logined = false
	PlatformCenter.Isevent = false
	PlatformTool.callPlatformFunc({func="logout"})-- 登出帐号
end

function PlatformCenter.pay(number,listener)
	PlatformCenter.onPayListener=listener
	if tonumber(number) then
		PlatformTool.callPlatformFunc({func="pay",number=tonumber(number)})
	else
		PlatformTool.showMsg("信息错误!")
	end
end

function PlatformCenter.showExit()
	if device.platform == "android" then
		PlatformTool.callPlatformFunc({func="showExit"})
	else
		local param = {
			name = Notify.EVENT_OPEN_PANEL, str = "panel_confirm", strMsg = "确定退出游戏嘛，还有很多活动没参加哦~",
			confirmTitle = "再玩会", cancelTitle = "退出",
			cancelCallBack = function()
				cc.Director:getInstance():endToLua()
			    os.exit()
			end
		}
		NetClient:dispatchEvent(param)
	end
end

-------------------------------listener-----------------------------
function PlatformCenter.onLogin(param)
	game.gameKey=string.sub(param,9,string.len(param))
	if game.gameKey then 
		PlatformCenter.Logined=true
		NetClient:dispatchEvent({name = Notify.EVENT_PLATFORM_LOGIN})
	end
end

function PlatformCenter.onLogout()
	if not PlatformCenter.Isevent then
		game.gameKey=""
		if PlatformCenter.Logined == true then
			PlatformCenter.Isevent = true
			NetClient:dispatchEvent({name=Notify.EVENT_PLATFORM_LOGOUT})
		end
		PlatformTool.showMsg("账号已退出")
		PlatformCenter.Logined=false
		-- PlatformCenter.login()
	end
end

return PlatformCenter