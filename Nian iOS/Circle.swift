//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, delegateInput {
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var replySheet:UIActionSheet?
    var actionSheetPhoto:UIActionSheet?
    var navView:UIView!
    var dataTotal:Int = 30
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    var ReplyUserName:String = ""
    var ReturnReplyContent:String = ""
    var animating:Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var desHeight:CGFloat = 0
    var keyboardView: InputView!
    var viewBottom:UIView!
    var keyboardHeight: CGFloat = 0
    var imagePicker:UIImagePickerController?
    var Locking = false
    
    /* 消息发送者的 id 和 name */
    var id: Int = 0
    var name: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        load()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Letter:", name: "Letter", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardEndObserve()
        
        /* 当离开该页面时，设置所有为已读 */
        RCIMClient.sharedRCIMClient().clearMessagesUnreadStatus(RCConversationType.ConversationType_PRIVATE, targetId: "\(id)")
    }
    
    override func viewDidDisappear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func send(replyContent: String, type: String) {
        back {
            if let name = Cookies.get("user") as? String {
                let commentReplyRow = self.dataArray.count
                let data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(SAUid())", "\(name)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
                self.dataArray.insertObject(self.dataDecode(data), atIndex: 0)
                self.tableView.reloadData()
                var success = false
                var finish = false
                var nameSelf = ""
                if let _name = Cookies.get("user") as? String {
                    nameSelf = _name
                }
                let message = RCTextMessage(content: replyContent)
                message.extra = "\(self.name):\(nameSelf)"
                RCIMClient.sharedRCIMClient().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: "\(self.id)", content: message, pushContent: "\(nameSelf)写了一封信给你！", success: { (messageID) -> Void in
                    success = true
                    if finish {
                        self.newInsert(replyContent, id: messageID, type: type)
                    }
                    }) { (err, no) -> Void in
                }
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableView.contentOffset.y = max(self.tableView.contentSize.height - self.tableView.height(), 0)
                    }, completion: { (Bool) -> Void in
                        if success {
                            self.newInsert(replyContent, id: 0, type: type)
                        } else {
                            finish = true
                        }
                })
            }
            self.keyboardView.inputKeyboard.text = ""
        }
    }
    
    /* 插入新回应并在 UI 上显示 */
    func newInsert(content: String, id: Int, type: String) {
        if let name = Cookies.get("user") as? String {
            let newinsert = NSDictionary(objects: [content, "\(id)" , "刚刚", "\(SAUid())", "\(name)", type], forKeys: ["content", "id", "lastdate", "uid", "user", "type"])
            self.tableView.beginUpdates()
            self.dataArray.replaceObjectAtIndex(0, withObject: self.dataDecode(newinsert))
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
    }
    
    func Letter(noti: NSNotification) {
        if let message = noti.object as? RCMessage {
            if "\(id)" == message.senderUserId {
                let new = IMClass().messageToDictionay(message)
                self.dataArray.insertObject(dataDecode(new), atIndex: 0)
                back {
                    self.tableView.reloadData()
                    let offset = self.tableView.contentSize.height - self.tableView.bounds.size.height
                    if offset > 0 && offset - self.tableView.contentOffset.y < self.tableView.bounds.size.height * 0.5 {
                        self.tableView.setContentOffset(CGPointMake(0, offset), animated: true)
                    }
                }
            }
        }
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.navView)
        
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, 0))
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.registerNib(UINib(nibName:"Comment", bundle: nil), forCellReuseIdentifier: "Comment")
        self.tableView.registerNib(UINib(nibName:"CommentEmoji", bundle: nil), forCellReuseIdentifier: "CommentEmoji")
        
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.view.addSubview(self.tableView)
        
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableView.tableFooterView = self.viewBottom
        
        
        // 输入框
        keyboardView = InputView()
        keyboardView.inputType = InputView.inputTypeEnum.letter
        keyboardView.setup()
        keyboardView.delegate = self
        self.view.addSubview(keyboardView)
        tableView.setHeight(globalHeight - 64 - keyboardView.heightCell)
        
        // 发送图片
        keyboardView.imageUpload?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPhotoClick:"))
        self.view.addSubview(self.keyboardView)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.name
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func onPhotoClick(sender:UITapGestureRecognizer){
        resign()
        self.actionSheetPhoto = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetPhoto!.addButtonWithTitle("相册")
        self.actionSheetPhoto!.addButtonWithTitle("拍照")
        self.actionSheetPhoto!.addButtonWithTitle("取消")
        self.actionSheetPhoto!.cancelButtonIndex = 2
        self.actionSheetPhoto!.showInView(self.view)
    }
    
    func onCircleDetailClick(){
    }
    
    //按下发送后调用此函数
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        let contentComment = self.inputKeyboard.text
//        if contentComment != "" {
//            postWord(contentComment!)
//            self.inputKeyboard.text = ""
//        }
//        return true
//    }
    
    func commentFinish(replyContent:String, type: Int = 1){
        back {
            if let name = Cookies.get("user") as? String {
                let commentReplyRow = self.dataArray.count
                let data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(SAUid())", "\(name)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
                self.dataArray.insertObject(data, atIndex: 0)
                self.tableView.reloadData()
                let offset = self.tableView.contentSize.height - self.tableView.bounds.size.height
                if offset > 0 {
                    self.tableView.setContentOffset(CGPointMake(0, offset), animated: true)
                }
            }
        }
    }
    
    func tableUpdate(contentAfter: String) {
        for var i: Int = 0; i < self.dataArray.count; i++ {
            let data = self.dataArray[i] as! NSDictionary
            let contentBefore = data.stringAttributeForKey("content")
            let lastdate = data.stringAttributeForKey("lastdate")
            let type = data.stringAttributeForKey("type")
            if (contentAfter == contentBefore || type == "2") && lastdate == "sending" {
                let lastdate = V.absoluteTime(NSDate().timeIntervalSince1970)
                let mutableItem = NSMutableDictionary(dictionary: data)
                mutableItem.setObject(lastdate, forKey: "lastdate")
                mutableItem.setObject(contentAfter, forKey: "content")
                self.dataArray.replaceObjectAtIndex(i, withObject: mutableItem)
                back {
                    self.tableView.reloadData()
                }
                break
            }
        }
    }
    
    //将内容发送至服务器
    func addReply(content: String, type: Int = 1){
        var nameSelf = ""
        if let _name = Cookies.get("user") as? String {
            nameSelf = _name
        }
        
        /* 文本 */
        if type == 1 {
            let message = RCTextMessage(content: content)
            message.extra = "\(self.name):\(nameSelf)"
            RCIMClient.sharedRCIMClient().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: "\(self.id)", content: message, pushContent: "\(nameSelf)写了一封信给你！", success: { (messageID) -> Void in
                self.tableUpdate(content)
                }) { (err, no) -> Void in
            }
        } else if type == 2 {
            /* 图片 */
            let message = RCImageMessage(imageURI: "\(content)")
            message.extra = "\(self.name):\(nameSelf)"
            RCIMClient.sharedRCIMClient().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: "\(self.id)", content: message, pushContent: "\(nameSelf)写了一封信给你！", success: { (messageID) -> Void in
                self.tableUpdate(content)
                }) { (err, no) -> Void in
            }
        }
    }
    
    /* 进入页面时，从本地拉取最新的消息 */
    func load(clear: Bool = true){
        if clear {
            self.page = 0
            self.dataTotal = 0
            self.dataArray.removeAllObjects()
        }
        
        /* 默认是拉取最新的 30 条 */
        var arr = RCIMClient.sharedRCIMClient().getLatestMessages(RCConversationType.ConversationType_PRIVATE, targetId: "\(id)", count: 30)
        
        /* 当不是在第一页时，拉取数据从最新的 id 往后 */
        let count = dataArray.count
        if count > 0 {
            let data = dataArray[count - 1] as! NSDictionary
            let oldestid = data.stringAttributeForKey("id")
            arr = RCIMClient.sharedRCIMClient().getHistoryMessages(.ConversationType_PRIVATE, targetId: "\(id)", oldestMessageId: Int(oldestid)!, count: 30)
        }
        
        self.page++
        
        for _item in arr {
            if let item = _item as? RCMessage {
                let data = IMClass().messageToDictionay(item)
                self.dataArray.addObject(dataDecode(data))
                self.dataTotal++
            }
        }
        
        let heightBefore = self.tableView.contentSize.height
        self.tableView.reloadData()
        let heightAfter = self.tableView.contentSize.height
        if clear {
            self.tableView.contentOffset.y = max(tableView.contentSize.height - tableView.height(), 0)
        }else{
            let heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
            self.tableView.contentOffset = CGPointMake(0, heightChange)
            self.animating = 0
        }
    }
    
    /* 将数据转码 */
    func dataDecode(data: NSDictionary) -> NSDictionary {
        print("\(data) 编码前")
        let mutableData = NSMutableDictionary(dictionary: data)
        let content = data.stringAttributeForKey("content").decode()
        let h = content.stringHeightWith(15, width: 208)
        let type = data.stringAttributeForKey("type")
        var wImage: CGFloat = 72
        var hImage: CGFloat = 72
        var wContent: CGFloat = 0
        var heightCell: CGFloat = 0
        if type == "1" {
            if h == "".stringHeightWith(15, width: 208) {
                wContent = content.stringWidthWith(15, height: h)
                wImage = wContent + 27
                hImage = 37
            } else {
                wImage = 235
                hImage = h + 20
                wContent = 208
            }
            heightCell = h + 60
        } else {
            heightCell = hImage + 40
        }
        mutableData.setValue(h, forKey: "heightContent")
        mutableData.setValue(wContent, forKey: "widthContent")
        mutableData.setValue(wImage, forKey: "widthImage")
        mutableData.setValue(hImage, forKey: "heightImage")
        mutableData.setValue(content, forKey: "content")
        mutableData.setValue(heightCell, forKey: "heightCell")
        print("\(mutableData) 编码后")
        return mutableData as NSDictionary
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if self.dataTotal == 30 * self.page {
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    self.load(false)
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell:UITableViewCell
//        let index = indexPath.row
//        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
//        let type = data.stringAttributeForKey("type")
//        if type == "1" {
//            let c = tableView.dequeueReusableCellWithIdentifier("CircleBubbleCell", forIndexPath: indexPath) as! CircleBubbleCell
//            c.data = data
//            c.textContent.tag = index
//            c.textContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
//            c.textContent.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onBubbleLongClick:"))
//            c.View.tag = index
//            c.setup()
//            cell = c
//        } else {
//            let c = tableView.dequeueReusableCellWithIdentifier("CircleImageCell", forIndexPath: indexPath) as! CircleImageCell
//            c.data = data
//            c.imageContent.tag = index
//            c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
//            c.View.tag = index
//            c.setup()
//            cell = c
//        }
//        return cell
        
        let index = indexPath.row
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        let type = data.stringAttributeForKey("type")
        if type == "1" {
            let c = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! Comment
            c.data = data
            c.labelHolder.tag = dataArray.count - 1 - index
            c.labelHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.labelHolder.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onMore:"))
            c.setup()
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("CommentEmoji", forIndexPath: indexPath) as! CommentEmoji
            c.data = data
            c.labelHolder.tag = dataArray.count - 1 - index
            c.labelHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.labelHolder.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onMore:"))
            c.setup()
            return c
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }
        return true
    }
    
    func onCellTap(sender:UITapGestureRecognizer) {
//        self.inputKeyboard.resignFirstResponder()
        resign()
    }
    
    func resign() {
        /* 当键盘是系统自带键盘时 */
        if self.keyboardView.inputKeyboard.isFirstResponder() {
            self.keyboardView.inputKeyboard.resignFirstResponder()
        } else {
            /* 当键盘是我们自己写的键盘（表情）时 */
            keyboardView.resignEmoji()
            keyboardHeight = 0
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.keyboardView.resizeTableView()
                }, completion: nil)
        }
    }
    
    func onImageTap(sender:UITapGestureRecognizer) {
//        self.inputKeyboard.resignFirstResponder()
        let index = sender.view!.tag
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        let content = data.objectForKey("content") as! String
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            let img0 = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
            if img0 != 0 {
                if let v = sender.view as? UIImageView {
                    let images = NSMutableArray()
                    let name = arrContent[0].componentsSeparatedByString("/")
                    let num = name.count - 1
                    if num > 0 {
                        let path = "\(name[num])_\(arrContent[1]).png"
                        let d = ["path": path, "width": arrContent[2], "height": arrContent[3]]
                        images.addObject(d)
                        v.open(images, index: 0, exten: "!a", folder: "circle")
                    }
                }
            }
        }
    }
    
    func onBubbleLongClick(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            onBubbleClick(sender)
        }
    }
    
    func onBubbleClick(sender:UIGestureRecognizer) {
        let index = sender.view!.tag
        let data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
        let user = data.stringAttributeForKey("user")
        let content = data.stringAttributeForKey("content")
        let cid = data.stringAttributeForKey("cid")
        let type = data.stringAttributeForKey("type")
        self.ReplyRow = self.dataArray.count - 1 - index
        self.ReplyContent = content
        self.ReplyCid = cid
        self.ReplyUserName = user
        self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        if type == "3" {
            let StepVC = SingleStepViewController()
            StepVC.Id = cid
            self.navigationController?.pushViewController(StepVC, animated: true)
        }else{
            self.replySheet!.addButtonWithTitle("回应@\(user)")
            self.replySheet!.addButtonWithTitle("复制")
            self.replySheet!.addButtonWithTitle("取消")
            self.replySheet!.cancelButtonIndex = 2
            self.replySheet!.showInView(self.view)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
        if let type = data.objectForKey("type") as? String {
            if type == "2" {
                return CircleImageCell.cellHeightByData(data)
            } else {
                return CircleBubbleCell.cellHeightByData(data)
            }
        }
        return 65
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
//                self.commentVC()
            }else if buttonIndex == 1 { //复制
                let pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }
        }else if actionSheet == self.actionSheetPhoto {
            if buttonIndex == 0 {
//                self.inputKeyboard.resignFirstResponder()
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }else if buttonIndex == 1 {
//                self.inputKeyboard.resignFirstResponder()
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                    self.imagePicker = UIImagePickerController()
                    self.imagePicker!.delegate = self
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                    self.imagePicker!.allowsEditing = true
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        var width = img.size.width
        var height = img.size.height
        if width * height > 0 {
            if width >= height {
                height = height * 88 / width
                width = 88
            }else{
                width = width * 88 / height
                height = 88
            }
        }
        
        /* 在上传前设置缓存 */
        let wSmall = 88 * globalScale
        let wLarge = globalWidth * globalScale
        
        let safeuid = SAUid()
        self.commentFinish("\(safeuid)_loading_\(width)_\(height)", type: 2)
        let uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            var uploadUrl = data.objectForKey("url") as! String
            uploadUrl = "http://img.nian.so\(uploadUrl)"
            setCacheImage("\(uploadUrl)!a", img: img, width: wSmall)
            setCacheImage("\(uploadUrl)!large", img: img, width: wLarge)
            uploadUrl = SAReplace(uploadUrl, before: ".png", after: "") as String
            let content = "\(uploadUrl)_\(width)_\(height)"
            self.addReply(content, type: 2)
        })
        uy.uploadImage(resizedImage(img, newWidth: 500), savekey: getSaveKey("circle", png: "png") as String)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func keyboardWasShown(notification: NSNotification) {
//        var info: Dictionary = notification.userInfo!
//        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
//        self.keyboardHeight = keyboardSize.height
//        self.keyboardView.pointY = globalHeight - self.keyboardHeight - 44
//        self.keyboardView.layoutSubviews()
//        let heightScroll = globalHeight - 44 - 64 - self.keyboardHeight
//        let contentOffsetTableView = self.tableView.contentSize.height >= heightScroll ? self.tableView.contentSize.height - heightScroll : 0
//        self.tableView.setHeight( heightScroll )
//        self.tableView.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
        
        
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        keyboardHeight = max(keyboardSize.height, keyboardHeight)
        
        /* 移除表情界面，修改按钮样式 */
        keyboardView.resignEmoji()
        keyboardView.resizeTableView()
        keyboardView.labelPlaceHolder.hidden = true
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
//        let heightScroll = globalHeight - 44 - 64
//        self.keyboardView.pointY = globalHeight - 44
//        self.keyboardView.layoutSubviews()
//        self.tableView.setHeight(heightScroll)
        
        if !Locking {
            keyboardHeight = 0
            keyboardView.resizeTableView()
        }
    }
}

