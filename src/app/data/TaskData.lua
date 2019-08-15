--
-- Created by IntelliJ IDEA.
-- @author: ElanWu
-- @date: 2016/10/26 18:49
-- To change this template use File | Settings | File Templates.
--

TaskData = {
    list = {}
}

function TaskData.init()
    TaskData.list = {}
end

function TaskData.taskChange(mMsg)
    local param = {}
    local taskid = mMsg:readInt()

    param.mTaskID = taskid
    param.mFlags = mMsg:readInt()
    param.mState = mMsg:readShort()
    param.mParam_1 = mMsg:readShort()
    param.mParam_2 = mMsg:readShort()
    param.mParam_3 = mMsg:readInt()
    param.mParam_4 = mMsg:readInt()
    param.mName = mMsg:readString()
    param.mShortDesp = mMsg:readString()
    param.mChapter = mMsg:readString()
    param.mSort = mMsg:readInt()
    param.mTaskBombDesp = mMsg:readString()
    if taskid ~= Const.TASK_MAIN_ID and --taskid ~= Const.TASK_ID_CYCLE_TASK and
       taskid ~= Const.TASK_ID_YABIAO and taskid ~= Const.TASK_ID_FUBEN_I and
       taskid ~= Const.TASK_ID_JINGYING_RC and taskid ~= Const.TASK_ID_RICHANG and
       taskid ~= Const.TASK_ID_XIANGMO and taskid ~= Const.TASK_ID_RICHANG3 and
       taskid ~= Const.TASK_ID_FUBEN_MAINTASK and taskid ~= Const.TASK_ID_FUBEN_SEXP
    then
        return
    end

    if param.mShortDesp ~= "" then 
        param.mInfo = json.decode(param.mShortDesp)
    end

    local state = math.fmod(param.mState,10)
    local statechange = true
    if TaskData.list[taskid] then
        statechange = (math.fmod(TaskData.list[taskid].mState,10) ~= state)
    end

    TaskData.list[taskid] = param

    if taskid == Const.TASK_MAIN_ID and state == 4 then
        MainRole.mAimGhostID = 0
    end

    if taskid == Const.TASK_MAIN_ID and state ~= 4 then
        NetClient.mAutoTaskDone = true
    end

    EventDispatcher:dispatchEvent({name = Notify.EVENT_TASK_CHANGE,tid=taskid,statechange=statechange})
end

function TaskData.sortList()
    local sortF = function(fa, fb)
        return fa.online_state > fb.online_state
    end
    if #listData > 1 and needsort then
        table.sort( listData, sortF )
    end
end


