--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2017/02/07 19:17
-- To change this template use File | Settings | File Templates.
--

ActivityData = {}
ActivityData.daily_reward_info = {0,0} --第一个 可领次数。第二个 0 不能领 1可以领 2 领过了
ActivityData.shouchong_shuang_bei_info = {0,"" }
ActivityData.server_start_day = 0
ActivityData.charge_reward_state = 0 -- 新区首充豪礼领取状态
ActivityData.charge_num = 0 -- 累计充值
ActivityData.charge_points = 0 -- 充值积分

-- 新区充值排名
ActivityData.character_rank_1 =  ""
ActivityData.character_rank_2 =  ""
ActivityData.character_rank_3 =  ""
ActivityData.character_rank =   0 -- 是否已领取充值排名奖励

-- 新手助力
ActivityData.helper_reward_state = 0
-- 是否可领取每日wifi登陆奖励
ActivityData.wifi_reward_items = {{10163,1} ,{10264,3} ,{10263,1}}
ActivityData.is_can_get_wifi_reward = 1 -- 默认可以领取

function ActivityData.parseMsg(lv, msg)
    local info = string.split( msg,"," )
    if not info then return end
    print("ActivityData.parseMsg===========", lv, msg)
    if lv == 100022 then
        -- 每日wifi登陆奖励是否可领取
        ActivityData.is_can_get_wifi_reward = tonumber(info[1]) or 1 -- 默认可以领取
        NetClient:dispatchEvent({name=Notify.EVENT_UPDATE_AWARD_ACT})
    elseif lv == 100045 then
        --每日首充奖励
        ActivityData.daily_reward_info[1] = tonumber(info[1]) or 0
        ActivityData.daily_reward_info[2] = tonumber(info[2]) or 0
        NetClient:dispatchEvent({name=Notify.EVENT_UPDATE_DAILY_GUI})
    elseif lv == 200000 then
        -- 新区首充豪礼
        ActivityData.charge_reward_state = tonumber(info[1]) or 0
        NetClient:dispatchEvent({name=Notify.EVENT_UPDATE_MEW_SERVER_ACT})
    elseif lv == 200001 then
        -- 累计充值
        ActivityData.charge_num = tonumber(info[1]) or 0
    elseif lv == 200002 then
        -- 开服第几天 从 0 开始
        ActivityData.server_start_day = tonumber(info[1]) or 0
    elseif lv == 200003 then
        -- 新区充值排行
        ActivityData.character_rank_1 =  info[1] or ""
        ActivityData.character_rank_2 =  info[2] or ""
        ActivityData.character_rank_3 =  info[3]  or ""
        ActivityData.character_rank =   tonumber(info[4]) or 0
        NetClient:dispatchEvent({name=Notify.EVENT_UPDATE_MEW_SERVER_ACT})
    elseif lv == 200004 then
        -- 充值积分礼包
        ActivityData.charge_points = tonumber(info[1]) or 0
        NetClient:dispatchEvent({name=Notify.EVENT_UPDATE_MEW_SERVER_ACT})
    elseif lv == 200005 then
        -- 新手加入行会礼包
        ActivityData.helper_reward_state = tonumber(info[1]) or 0
        NetClient:dispatchEvent({name=Notify.EVENT_UPDATE_MEW_SERVER_ACT})
    end



end