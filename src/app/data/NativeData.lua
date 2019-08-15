--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/11/25 17:27
-- To change this template use File | Settings | File Templates.
--
-- TODO 这里面的变量 以后要保存到手机上，便于下次登录时读取
NativeData = {}

NativeData.REFUSE_GROUP = false -- 自动拒绝组队
NativeData.FABAO_UP_USE_VCOIN = false -- 法宝器灵升级自动用元宝
NativeData.AUTO_GROUP = true --自动入队
NativeData.HAND_GROUP = false  --手动组队

NativeData.CHAT_SHOW_SETTING = {2,3,4,5,6,7} -- 主界面显示的聊天频道

NativeData.LAST_LOGIN_INFO = {
    [1] = {serverkey = "server_id", areakey = "area_id"},
    [2] = {serverkey = "server_id_b", areakey = "area_id_b"},
}

NativeData._last_login_info = {}

NativeData.load = function()
    NativeData._last_login_info = {}
    for _, v in ipairs(NativeData.LAST_LOGIN_INFO) do
        local serverid = cc.UserDefault:getInstance():getIntegerForKey(v.serverkey, 0)
        local areaid = cc.UserDefault:getInstance():getIntegerForKey(v.areakey, 0)
        if serverid and serverid > 0 and areaid and areaid > 0 then
            table.insert(NativeData._last_login_info, {serverid = serverid, areaid = areaid})
        end
    end
    NativeData._last_account = cc.UserDefault:getInstance():getStringForKey("last_account", "")
end

NativeData.saveLastAccount = function(ac)
    NativeData._last_account = ac
    cc.UserDefault:getInstance():setStringForKey("last_account", NativeData._last_account)
end

NativeData.getLastAccount = function()
    return  NativeData._last_account or ""
end

NativeData.getLastLoginInfo = function()
    return NativeData._last_login_info or {}
end

NativeData.setLastLoginInfo = function(area_id, server_id)
    if not area_id or area_id < 1 or not server_id or server_id < 1 then
        print("NativeData.setLastLoginInfo, 参数错误==>>", area_id, server_id)
        return
    end

    local serid1
    local areaid1
    if NativeData._last_login_info[1] then
        areaid1 = NativeData._last_login_info[1].areaid
        serid1 = NativeData._last_login_info[1].serverid
    end

    if serid1 and serid1 > 0 and areaid1 and areaid1 > 0 and serid1 == server_id and areaid1 == area_id then
        return
    end

    if serid1 and serid1 > 0 and areaid1 and areaid1 > 0 then
        NativeData._last_login_info[2] = {serverid = serid1, areaid = areaid1 }
    end
    NativeData._last_login_info[1] = {serverid = server_id, areaid = area_id }

    for k, v in ipairs(NativeData._last_login_info) do
        local info = NativeData.LAST_LOGIN_INFO[k]
        cc.UserDefault:getInstance():setIntegerForKey(info.serverkey, v.serverid)
        cc.UserDefault:getInstance():setIntegerForKey(info.areakey, v.areaid)
    end
end

NativeData.settingInfo = {}

NativeData.loadSetting = function(charname)
    local xmlkey = "setting_"..charname
    local settingstr = cc.UserDefault:getInstance():getStringForKey(xmlkey, "")
    if settingstr == "" then
        NativeData.saveSettingInfo(charname)
    else
        game.SETTING_TABLE = util.decode(settingstr)
    end
end

NativeData.saveSettingInfo = function(charname)
    cc.UserDefault:getInstance():setStringForKey("setting_"..charname,util.encode(game.SETTING_TABLE))
end

NativeData.isOpenPickUp = function()
    return NativeData.settingInfo["pick_control"] or false
end

NativeData.load()