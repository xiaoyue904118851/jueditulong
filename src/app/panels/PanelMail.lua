--
-- Created by IntelliJ IDEA.
-- @author: wyl
-- @date: 2017/11/14 20:36
-- To change this template use File | Settings | File Templates.
-- PanelMail

local PanelMail = {}
local var = {}

local recyclelist = true
function PanelMail.initView(params)
    local params = params or {}
    var = {}
    local widget = WidgetHelper:getWidgetByCsb("uilayout/PanelMail/UI_Mail_BG.csb"):addTo(params.parent, params.zorder)
    var.widget = widget:getChildByName("Panel_mail")
    var.rightPanel = var.widget:getWidgetByName("Image_right")
    var.leftPanel = var.widget:getWidgetByName("Image_left")
    var.countText = var.leftPanel:getWidgetByName("Text_num")
    var.countText:setString("0/0")
    var.mailListView = var.leftPanel:getWidgetByName("ListView_mail")
    var.mailListView:hide()
    var.mailListView:setItemModel(var.mailListView:getItem(0))
    var.mailCopyItem = var.leftPanel:getWidgetByName("Panel_list_item"):hide()
    PanelMail.initRightPanel()
    PanelMail.addBtnClickEvent()
    PanelMail.registeEvent()
    var.unReadNum = 0
    if #NetClient.mMailList == 0 or NetClient.mReqMailList then
        NetClient:reqMailList()
    else
        PanelMail.updateMailListView()
    end

    NetClient.openMailType = true
    NetClient:dispatchEvent({name=Notify.EVENT_RECEIVE_MAIL_LIST})

    return var.widget
end

function PanelMail.registeEvent()
    dw.EventProxy.new(NetClient, var.widget)
    :addEventListener(Notify.EVENT_RECEIVE_MAIL_LIST, PanelMail.updateMailListView)
    :addEventListener(Notify.EVENT_RECEIVE_FUJIAN_SUCCESS, PanelMail.handleReceiveFujian)
    :addEventListener(Notify.EVENT_DELETE_MAIL_SUCCESS, PanelMail.handleDeleteMail)
end

function PanelMail.addBtnClickEvent()
    var.leftPanel:getWidgetByName("Button_getall"):addClickEventListener(function(pSender)
        NetClient:doGetAllMailItems()
    end)
    var.leftPanel:getWidgetByName("Button_deleteall"):addClickEventListener(function(pSender)
        NetClient:doDeleteAllMails()
    end)
end

function PanelMail.initRightPanel()
    if not var.getFlag then
        var.getFlag = var.rightPanel:getWidgetByName("Image_tiquflag")
        var.copyItem = var.rightPanel:getWidgetByName("item_icon"):hide()
        var.getBtn = var.rightPanel:getWidgetByName("Button_getitem")
        var.delBtn = var.rightPanel:getWidgetByName("Button_delete")
        var.fujianlistView = var.rightPanel:getWidgetByName("ListView_fujian")
        var.mailSubjectText = var.rightPanel:getWidgetByName("Text_sub")
        var.contentText = var.rightPanel:getWidgetByName("Text_content")
        var.fromText = var.rightPanel:getWidgetByName("Text_from"):hide()
--        var.contentScrollView = var.rightPanel:getWidgetByName("ScrollView_content")
    end
    var.getFlag:hide()
    var.getBtn:hide()
    var.getBtn:hide()
    var.delBtn:hide()
    var.fromText:hide()
    var.fujianlistView:removeAllItems()
    var.mailSubjectText:setString("")
    var.contentText:setString("")
--    var.contentScrollView:removeAllChildren()
--    var.contentScrollView:hide()

end

function PanelMail.onItemClicked(itemBg)
    local mailID = itemBg.mailID
    local mailInfo = NetClient.mMailList[mailID]
    if not mailID or not mailInfo then
        PanelMail.initRightPanel()
        return
    end

    var.selectedMailID = mailID
    if mailInfo.isOpen ~= 1 then
        mailInfo.isOpen = 1
        var.unReadNum = var.unReadNum - 1
        var.countText:setString(var.unReadNum.."/"..#var.sortlist)
        if NetClient.mNewMailNum and NetClient.mNewMailNum > 0 then
            NetClient.mNewMailNum = NetClient.mNewMailNum - 1
            UIRedPoint.handleChange({UIRedPoint.REDTYPE.NEWMAIL})
        end
        NetClient:openMail(mailID)
        PanelMail.updateItemReadFlag(itemBg,mailInfo)
    end

    table.walk(var.mailListView:getItems(),function(v,k)
        v:getWidgetByName("Image_high"):setVisible(v.mailID==mailID)
    end)
    var.mailSubjectText:setString(mailInfo.title)
    var.contentText:setString(mailInfo.content)
    var.fromText:show()
    var.delBtn:show()
    var.delBtn.mailID = mailID
    var.delBtn:addClickEventListener(function(pSender)
        NetClient:deleteMails(0,{pSender.mailID})
    end)

    PanelMail.updateGetBtn(mailInfo)
    if #mailInfo.fujinItems > 0 then
        var.fujianlistView:removeAllItems()
        var.fujianlistView:show()
        for _, v in ipairs(mailInfo.fujinItems) do
            local itemiconbg = var.copyItem:clone():show()
            itemiconbg:getWidgetByName("Text_num"):setString(v.num):setVisible(v.num>1)
            UIItem.getSimpleItem({
                parent = itemiconbg,
                typeId = v.typeid,
            })
            var.fujianlistView:pushBackCustomItem(itemiconbg)
        end
    else
        var.fujianlistView:hide()
    end
end

function PanelMail.updateGetBtn(mailInfo)
    if #mailInfo.fujinItems > 0 then
        if mailInfo.isReceive == 1 then
            var.getBtn:hide()
            var.getFlag:show()
        else
            var.getBtn:show()
            var.getFlag:hide()
            var.getBtn.mailID = mailInfo.mailID
            var.getBtn:addClickEventListener(function(pSender)
                NetClient:receiveMailItems({pSender.mailID})
            end)
        end
    else
        var.getBtn:show()
        var.getBtn:addClickEventListener(function(pSender) end)
        var.getFlag:hide()
    end
end

function PanelMail.handleReceiveFujian(event)
    NetClient:alertLocalMsg("成功收取附件", "alert")
    for _, mailID in ipairs(event.receiveids) do
        local mailInfo = NetClient.mMailList[mailID]
        if mailInfo then
            if recyclelist then
                for _, itemBg in ipairs(var.mailListView:getItems()) do
                    if itemBg.mailID == mailID then
                        PanelMail.updateItemFujianFlag(itemBg,mailInfo)
                        PanelMail.updateItemReadFlag(itemBg,mailInfo)
                        break
                    end
                end
            else
                local listindex = table.keyof(var.sortlist, mailID)
                if listindex then
                    PanelMail.updateItemFujianFlag(var.mailListView:getItem(listindex-1),mailInfo)
                    PanelMail.updateItemReadFlag(var.mailListView:getItem(listindex-1),mailInfo)
                end
            end
            if var.selectedMailID == mailID then
                PanelMail.updateGetBtn(mailInfo)
            end
        end
    end
end

function PanelMail.handleDeleteMail(event)
    NetClient:alertLocalMsg("成功删除邮件", "alert")
    for _, mailID in ipairs(event.deleteids) do
        if recyclelist then
            table.removebyvalue(var.sortlist, mailID)
        else
            local listindex = table.keyof(var.sortlist, mailID)
            if listindex then
                table.remove(var.sortlist,listindex)
                var.mailListView:removeItem(listindex-1)
            end
        end
    end
    if recyclelist then
        PanelMail.addRecycleList()
    end
    var.countText:setString(var.unReadNum.."/"..#var.sortlist)
    if #var.sortlist > 0 then
        var.mailListView:getItem(0).click(var.mailListView:getItem(0))
    else
        PanelMail.initRightPanel()
    end
end

function PanelMail.updateMailListView()
    var.sortlist = {}
    var.unReadNum = 0
    table.walk(NetClient.mMailList,function(v,k)
        table.insert(var.sortlist, k)
        if v.isOpen ~= 1 then var.unReadNum = var.unReadNum + 1 end
    end)
    var.countText:setString(var.unReadNum.."/"..#var.sortlist)
    local function sortF(sa, sb)
        return NetClient.mMailList[sa].senddate > NetClient.mMailList[sb].senddate
    end
    table.sort( var.sortlist, sortF )

    if recyclelist then
        PanelMail.addRecycleList()
    else
        PanelMail.addAllItem()
    end
end

function PanelMail.addAllItem()
    var.mailListView:show()
    var.mailListView:removeAllItems()
    if #var.sortlist <= 0 then
        return
    end
    for k, mailID in ipairs(var.sortlist) do
        local mailInfo = NetClient.mMailList[mailID]
        if mailInfo then
            local itemBg = var.mailCopyItem:clone():show()
            PanelMail.updateItemInfo(mailInfo,itemBg)
            var.mailListView:pushBackCustomItem(itemBg)
            if k == 1 then itemBg.click(itemBg) end
        end
    end
end

function PanelMail.addRecycleList()
    var.mailListView:show()
    local params = {
        list			= var.mailListView,
        totalLength		= #var.sortlist,
        updateFunc	= PanelMail.updateRecycleMailListItem,
    }
    CCRecycleList.new(params)
    if #var.sortlist > 0 then
        var.mailListView:getItem(0).click(var.mailListView:getItem(0))
    end
end

function PanelMail.updateItemFujianFlag(itemBg,mailInfo)
    if #mailInfo.fujinItems > 0 then
        itemBg:getWidgetByName("Image_fujian"):show()
        itemBg:getWidgetByName("Image_fujian"):loadTexture(mailInfo.isReceive == 1 and "fujian_yishou.png" or "fujian_weishou.png",UI_TEX_TYPE_PLIST)
    else
        itemBg:getWidgetByName("Image_fujian"):hide()
    end
end

function PanelMail.updateItemReadFlag(itemBg,mailInfo)
    itemBg:getWidgetByName("Image_read"):ignoreContentAdaptWithSize(true)
    itemBg:getWidgetByName("Image_read"):loadTexture(mailInfo.isOpen ~= 1 and "youjian_weidu.png" or "youjian_yidu.png",UI_TEX_TYPE_PLIST)
end

function PanelMail.updateRecycleMailListItem(item)
    local mailID = var.sortlist[item.tag]
    local mailInfo = NetClient.mMailList[mailID]
    if mailInfo then
        PanelMail.updateItemInfo(mailInfo,item)
    end
end

function PanelMail.updateItemInfo(mailInfo,itemBg)
    itemBg:addClickEventListener(function(pSender)
        PanelMail.onItemClicked(pSender)
    end)
    itemBg.click = PanelMail.onItemClicked
    itemBg.mailID = mailInfo.mailID
    itemBg:getWidgetByName("Image_high"):setVisible(var.selectedMailID==mailInfo.mailID)
    itemBg:getWidgetByName("name"):setString(mailInfo.title)
    itemBg:getWidgetByName("Text_time"):setString(DateHelper.toDateStr(mailInfo.senddate))
    PanelMail.updateItemReadFlag(itemBg,mailInfo)
    PanelMail.updateItemFujianFlag(itemBg,mailInfo)
end

return PanelMail