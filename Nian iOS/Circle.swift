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
    var page: Int = 0
    var replySheet: UIActionSheet?
    var actionSheetPhoto: UIActionSheet?
    var navView: UIView!
    var dataTotal: Int = 30
    var animating: Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var keyboardView: InputView!
    var keyboardHeight: CGFloat = 0
    var imagePicker: UIImagePickerController?
    var Locking = false
    
    var pasteContent = ""
    
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
                
                /* type = 1 时表示文本，2 表示图片，3 表示表情 */
                if type == "1" {
                    let message = RCTextMessage(content: replyContent)
                    message.extra = "\(self.name):\(nameSelf)"
                    RCIMClient.sharedRCIMClient().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: "\(self.id)", content: message, pushContent: "\(nameSelf)写了一封信给你！", success: { (messageID) -> Void in
                        success = true
                        if finish {
                            self.newInsert(replyContent, id: messageID, type: type)
                        }
                        }) { (err, no) -> Void in
                    }
                } else if type == "2" {
                } else if type == "3" {
                    
                    
                    //            私信发送 content=[表情]（暂定）extra=聊天对象昵称:自己昵称:gif:1001-1
                    let message = RCTextMessage(content: "[表情]")
                    message.extra = "\(self.name):\(nameSelf):gif:\(replyContent)"
                    RCIMClient.sharedRCIMClient().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: "\(self.id)", content: message, pushContent: "\(nameSelf)发送了一个表情给你！", success: { (messageID) -> Void in
                        success = true
                        if finish {
                            self.newInsert(replyContent, id: messageID, type: type)
                        }
                        }, error: { (err, no) -> Void in
                    })
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
                var mutableData = NSMutableDictionary(dictionary: dataDecode(new))
                mutableData = decodeToEmojiType(mutableData, message: message)
                self.dataArray.insertObject(mutableData, atIndex: 0)
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
        self.tableView.registerNib(UINib(nibName:"CommentImage", bundle: nil), forCellReuseIdentifier: "CommentImage")
//        CommentImage
        
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.view.addSubview(self.tableView)
        
        let viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableView.tableFooterView = viewBottom
        
        
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
                var mutableData = NSMutableDictionary(dictionary: dataDecode(data))
                mutableData = decodeToEmojiType(mutableData, message: item)
                self.dataArray.addObject(mutableData)
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
        let mutableData = NSMutableDictionary(dictionary: data)
        var content = data.stringAttributeForKey("content").decode()
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
            let arr = content.componentsSeparatedByString("_")
            if arr.count > 3 {
                wImage = arr[2].toCGFloat()
                hImage = arr[3].toCGFloat()
                if wImage > 0 {
                    hImage = hImage * CGFloat(88) / wImage
                    wImage = CGFloat(88)
                }
                content = "\(arr[0])_\(arr[1]).png!a"
            }
            heightCell = SACeil(hImage, dot: 0, isCeil: true) + 40
        }
        mutableData.setValue(h, forKey: "heightContent")
        mutableData.setValue(wContent, forKey: "widthContent")
        mutableData.setValue(wImage, forKey: "widthImage")
        mutableData.setValue(hImage, forKey: "heightImage")
        mutableData.setValue(content, forKey: "content")
        mutableData.setValue(heightCell, forKey: "heightCell")
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
        let index = indexPath.row
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        let type = data.stringAttributeForKey("type")
        if type == "1" {
            /* 文本 */
            let c = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! Comment
            c.data = data
            c.labelHolder.tag = dataArray.count - 1 - index
            c.labelHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.labelHolder.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.setup()
            return c
        } else if type == "2" {
            /* 图片 */
            let c = tableView.dequeueReusableCellWithIdentifier("CommentImage", forIndexPath: indexPath) as! CommentImage
            c.data = data
            c.setup()
            return c
        } else {
            /* 表情 */
            let c = tableView.dequeueReusableCellWithIdentifier("CommentEmoji", forIndexPath: indexPath) as! CommentEmoji
            c.data = data
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
    
    func onBubbleClick(sender:UIGestureRecognizer) {
//        if sender.state == UIGestureRecognizerState.Began {
//        }
        if sender is UITapGestureRecognizer {
            showPaste(sender)
        } else if sender is UILongPressGestureRecognizer {
            if sender.state == UIGestureRecognizerState.Began {
                showPaste(sender)
            }
        }
    }
    
    func showPaste(sender: UIGestureRecognizer) {
        if let v = sender.view {
            let tag = v.tag
            if let data = dataArray[tag] as? NSDictionary {
                pasteContent = data.stringAttributeForKey("content")
                replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                replySheet?.addButtonWithTitle("复制")
                replySheet?.addButtonWithTitle("取消")
                replySheet?.cancelButtonIndex = 1
                replySheet?.showInView(self.view)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
        let heightCell = data.objectForKey("heightCell") as! CGFloat
        return heightCell
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                let pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = pasteContent
            }
        } else if actionSheet == self.actionSheetPhoto {
            if buttonIndex == 0 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }else if buttonIndex == 1 {
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
        let w: CGFloat = 88
        if width * height > 0 {
            if width >= height {
                height = height * w / width
                width = w
            }else{
                width = width * w / height
                height = w
            }
        }
        
        /* 在上传前设置缓存 */
        let wSmall = w * globalScale
        let wLarge = globalWidth * globalScale
        
        send("\(SAUid())_loading_\(width)_\(height)", type: "2")
        let uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            var uploadUrl = data.objectForKey("url") as! String
            uploadUrl = "http://img.nian.so\(uploadUrl)"
            setCacheImage("\(uploadUrl)!a", img: img, width: wSmall)
            setCacheImage("\(uploadUrl)!large", img: img, width: wLarge)
            uploadUrl = SAReplace(uploadUrl, before: ".png", after: "") as String
            let content = "\(uploadUrl)_\(width)_\(height)"
            
            var i = 0
            for _data in self.dataArray {
                if let data = _data as? NSDictionary {
                    let c = data.stringAttributeForKey("content")
                    let arr = c.componentsSeparatedByString("_")
                    if arr.count > 1 {
                        if arr[1] == "loading.png!a" {
                            let newarr = content.componentsSeparatedByString("_")
                            if newarr.count > 3 {
                                let path = "\(newarr[0])_\(newarr[1]).png!a"
                                let mutableData = NSMutableDictionary(dictionary: data)
                                mutableData.setValue(path, forKey: "content")
                                self.dataArray.replaceObjectAtIndex(i, withObject: mutableData)
                            }
                            
                            break
                        }
                    }
                }
                i++
            }
            self.tableView.reloadData()
            var nameSelf = ""
            if let _name = Cookies.get("user") as? String {
                nameSelf = _name
            }
            let message = RCImageMessage(imageURI: "\(content)")
            message.extra = "\(self.name):\(nameSelf)"
            RCIMClient.sharedRCIMClient().sendMessage(RCConversationType.ConversationType_PRIVATE, targetId: "\(self.id)", content: message, pushContent: "\(nameSelf)写了一封信给你！", success: { (messageID) -> Void in
                var i = 0
                for _data in self.dataArray {
                    if let data = _data as? NSDictionary {
                        let type = data.stringAttributeForKey("type")
                        let lastdate = data.stringAttributeForKey("lastdate")
                        if type == "2" && lastdate == "sending" {
                            let mutableData = NSMutableDictionary(dictionary: data)
                            mutableData.setValue("刚刚", forKey: "lastdate")
                            self.dataArray.replaceObjectAtIndex(i, withObject: mutableData)
                            break
                        }
                    }
                    i++
                }
                back {
                    self.tableView.reloadData()
                }
                }, error: { (err, no) -> Void in
            })
        })
        uy.uploadImage(resizedImage(img, newWidth: 500), savekey: getSaveKey("circle", png: "png") as String)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        keyboardHeight = max(keyboardSize.height, keyboardHeight)
        /* 移除表情界面，修改按钮样式 */
        keyboardView.resignEmoji()
        keyboardView.resizeTableView()
        keyboardView.labelPlaceHolder.hidden = true
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        if !Locking {
            keyboardHeight = 0
            keyboardView.resizeTableView()
        }
    }
    
    /* 当收到表情时，将 type 从 1 变成 3，内容从 [表情] 替换成 extra 的另外一个样子 */
    func decodeToEmojiType(data: NSMutableDictionary, message: RCMessage) -> NSMutableDictionary {
        if let text = message.content as? RCTextMessage {
            let extra = text.extra
            let arr = extra.componentsSeparatedByString(":")
            if arr.count == 4 {
                data.setValue("3", forKey: "type")
                data.setValue(arr[3], forKey: "content")
                
                /* 见回应页面表情计算高度的方式 */
                data.setValue(72 + 40, forKey: "heightCell")
                data.setValue(72, forKey: "heightImage")
                data.setValue(72, forKey: "widthImage")
            }
        }
        return data
    }
}

