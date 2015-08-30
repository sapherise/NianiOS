//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    var tableview:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var replySheet:UIActionSheet?
    var actionSheetPhoto:UIActionSheet?
    var navView:UIView!
    var dataTotal:Int = 30
    var ID:Int = 0
    var circleTitle: String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    var ReplyUserName:String = ""
    var ReturnReplyContent:String = ""
    var animating:Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var desHeight:CGFloat = 0
    var inputKeyboard:UITextField!
    var keyboardView: SABottom!
    var viewBottom:UIView!
    var keyboardHeight:CGFloat = 0
    var imagePicker:UIImagePickerController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        SAloadData()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll:", name: "Poll", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Letter:", name: "Letter", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardEndObserve()
    }
    
    override func viewDidDisappear(animated: Bool) {
        globalCurrentCircle = 0
        globalCurrentLetter = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
            globalCurrentLetter = self.ID
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func Poll(noti: NSNotification) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let data = noti.object as! NSDictionary
            let circle = data.stringAttributeForKey("to")
            if circle == "\(self.ID)" {
                _ = data.stringAttributeForKey("msgid")
                let uid = data.stringAttributeForKey("from")
                let name = data.stringAttributeForKey("fromname")
                let content = data.stringAttributeForKey("msg")
                let title = data.stringAttributeForKey("title")
                let type = data.stringAttributeForKey("msgtype")
                let time = (data.stringAttributeForKey("time") as NSString).doubleValue
                let cid = data.stringAttributeForKey("cid")
//                content = SADecode(SADecode(content))
                
                let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//                var safeshell = uidKey.objectForKey(kSecValueData) as! String
                
                let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//                var safeuid = Sa.objectForKey("uid") as! String
                _ = Sa.objectForKey("user") as! String
                
                let commentReplyRow = self.dataArray.count
                let absoluteTime = V.absoluteTime(time)
                if (safeuid != uid) || (type != "1" && type != "2") {     // 如果是朋友们发的
                    let newinsert = NSDictionary(objects: [content, "\(commentReplyRow)" , absoluteTime, uid, name,"\(type)", title, cid], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
                    self.dataArray.insertObject(newinsert, atIndex: 0)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableview.reloadData()
                        let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
                        if offset > 0 && offset - self.tableview.contentOffset.y < globalHeight * 0.5 {
                            self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
                        }
                    })
                }
            }
        })
    }
    
    func Letter(noti: NSNotification) {
        let data = noti.object as! NSDictionary
        let uid = data.stringAttributeForKey("from")
        if uid == "\(self.ID)" {
            let name = data.stringAttributeForKey("fromname")
            var content = data.stringAttributeForKey("msg")
            let title = data.stringAttributeForKey("title")
            let type = data.stringAttributeForKey("msgtype")
            let time = (data.stringAttributeForKey("time") as NSString).doubleValue
            content = SADecode(SADecode(content))
            
            let commentReplyRow = self.dataArray.count
            let absoluteTime = V.absoluteTime(time)
            let newinsert = NSDictionary(objects: [content, "\(commentReplyRow)" , absoluteTime, uid, name,"\(type)", title, "0"], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
            self.dataArray.insertObject(newinsert, atIndex: 0)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableview.reloadData()
                let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
                if offset > 0 && offset - self.tableview.contentOffset.y < self.tableview.bounds.size.height * 0.5 {
                    self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
                }
            })
        }
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        
        self.tableview = UITableView(frame:CGRectMake(0,64,globalWidth,globalHeight - 64 - 44))
        self.tableview.backgroundColor = UIColor.clearColor()
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.None
        let nib = UINib(nibName:"CircleBubbleCell", bundle: nil)
        self.tableview.registerNib(nib, forCellReuseIdentifier: "CircleBubbleCell")
        let nib4 = UINib(nibName:"CircleImageCell", bundle: nil)
        self.tableview.registerNib(nib4, forCellReuseIdentifier: "CircleImageCell")
        
        
        let pan = UIPanGestureRecognizer(target: self, action: "onCellPan:")
        pan.delegate = self
        self.tableview.addGestureRecognizer(pan)
        self.tableview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.view.addSubview(self.tableview)
        
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableview.tableFooterView = self.viewBottom
        
        
        // 输入框
        
        
        self.keyboardView = (NSBundle.mainBundle().loadNibNamed("SABottom", owner: self, options: nil) as NSArray).objectAtIndex(0) as! SABottom
        self.keyboardView.pointX = 0
        self.keyboardView.pointY = globalHeight - 44
        
        let inputLineView = UIView(frame: CGRectMake(0, 0, globalWidth, 1))
        inputLineView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        self.keyboardView.addSubview(inputLineView)
        self.inputKeyboard = UITextField(frame: CGRectMake(8+28+8, 8, globalWidth-16-36, 28))
        self.inputKeyboard.layer.cornerRadius = 4
        self.inputKeyboard.layer.masksToBounds = true
        self.inputKeyboard.font = UIFont.systemFontOfSize(13)
        
        self.inputKeyboard.leftView = UIView(frame: CGRectMake(0, 0, 8, 28))
        self.inputKeyboard.rightView = UIView(frame: CGRectMake(0, 0, 8, 28))
        self.inputKeyboard.leftViewMode = UITextFieldViewMode.Always
        self.inputKeyboard.rightViewMode = UITextFieldViewMode.Always
        
        self.inputKeyboard.delegate = self
        self.inputKeyboard.backgroundColor = UIColor.whiteColor()
        self.keyboardView.addSubview(self.inputKeyboard)
        
        // 发送图片
        let imagePhoto = UIImageView(frame: CGRectMake(8, 8, 28, 28))
        imagePhoto.image = UIImage(named: "camera")
        imagePhoto.contentMode = UIViewContentMode.Center
        imagePhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPhotoClick:"))
        imagePhoto.userInteractionEnabled = true
        self.keyboardView.addSubview(imagePhoto)
        self.view.addSubview(self.keyboardView)
        self.inputKeyboard.returnKeyType = UIReturnKeyType.Send
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func onPhotoClick(sender:UITapGestureRecognizer){
        inputKeyboard.resignFirstResponder()
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
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let contentComment = self.inputKeyboard.text
        if contentComment != "" {
            postWord(contentComment!)
            self.inputKeyboard.text = ""
        }
        return true
    }
    
    func commentFinish(replyContent:String, type: Int = 1){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//                var safeshell = uidKey.objectForKey(kSecValueData) as! String
            
            let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//            var safeuid = Sa.objectForKey("uid") as! String
            let safeuser = Sa.objectForKey("user") as! String
            let commentReplyRow = self.dataArray.count
            let data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArray.insertObject(data, atIndex: 0)
            self.tableview.reloadData()
            let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
            if offset > 0 {
                self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
            }
        })
    }
    
    func postWord(replyContent: String, type: Int = 1) {
        back {
            let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//                var safeshell = uidKey.objectForKey(kSecValueData) as! String
            
            let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//            var safeuid = Sa.objectForKey("uid") as! String
            let safeuser = Sa.objectForKey("user") as! String
            let commentReplyRow = self.dataArray.count
            let data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArray.insertObject(data, atIndex: 0)
            let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height + replyContent.stringHeightWith(15,width:208) + 60
            if offset > 0 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.tableview.contentOffset.y = offset
                })
            }
            self.addReply(replyContent, type: 1)
            self.tableview.reloadData()
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
                    self.tableview.reloadData()
                }
                break
            }
        }
    }
    
    //将内容发送至服务器
    func addReply(contentAfter:String, type:Int = 1){
        let content = SAEncode(contentAfter)
            Api.postLetterChat(self.ID, content: content, type: type) { json in
                if json != nil {
                    let success = json!.objectForKey("success") as! String
                    let msgid = json!.objectForKey("msgid") as! String
                    let lastdate = json!.objectForKey("lastdate") as! String
                    if success == "1" {
                        self.tableUpdate(contentAfter)
                        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
                        let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
                        
                        Api.postName(self.ID) { result in
                            if result != nil {
                                SQLLetterContent(msgid, uid: safeuid, name: result!, circle: "\(self.ID)", content: contentAfter, type: "\(type)", time: lastdate, isread: 1) {}
                            }
                        }
                    }
                }
            }
    }
    
    func SAloadData(clear: Bool = true){
        if clear {
            self.page = 0
            self.dataTotal = 0
            self.dataArray.removeAllObjects()
        }
        let (resultSet, err) = SD.executeQuery("SELECT * FROM letter where circle ='\(self.ID)' and owner = '\(SAUid())' order by id desc limit \(self.page*30),30")
        if err == nil {
            self.page++
            for row in resultSet {
                let id = row["id"]?.asString()
                let uid = row["uid"]?.asString()
                let user = row["name"]?.asString()
                let content = row["content"]?.asString()
                let type = row["type"]?.asString()
                let lastdate = row["lastdate"]?.asString()
                let time = V.absoluteTime((lastdate! as NSString).doubleValue)
                let data = NSDictionary(objects: [id!, uid!, user!, content!, type!, time], forKeys: ["id", "uid", "user", "content", "type", "lastdate"])
                self.dataArray.addObject(data)
                self.dataTotal++
            }
            let heightBefore = self.tableview.contentSize.height
            self.tableview.reloadData()
            let heightAfter = self.tableview.contentSize.height
            if clear {
                let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
                if offset > 0  {
                    self.tableview.setContentOffset(CGPointMake(0, offset), animated: false)
                }
                if let v = (self.navigationItem.titleView as? UILabel) {
                    v.text = self.circleTitle
                }
            }else{
                let heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                self.tableview.contentOffset = CGPointMake(0, heightChange)
                self.animating = 0
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if self.dataTotal == 30 * self.page {
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    self.SAloadData(false)
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        let index = indexPath.row
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        let type = data.stringAttributeForKey("type")
        // 1: 文字消息，2: 图片消息，3: 进展更新，4: 成就通告，5: 用户加入，6: 管理员操作，7: 邀请用户
        if type == "1" {
            let c = tableView.dequeueReusableCellWithIdentifier("CircleBubbleCell", forIndexPath: indexPath) as! CircleBubbleCell
            c.data = data
            c.textContent.tag = index
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.textContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.View.tag = index
            cell = c
        }else{
            let c = tableView.dequeueReusableCellWithIdentifier("CircleImageCell", forIndexPath: indexPath) as! CircleImageCell
            c.data = data
            c.imageContent.tag = index
            c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.View.tag = index
            cell = c
        }
        return cell
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
    
    func onCellPan(sender:UIPanGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Changed {
            let distanceX = sender.translationInView(self.view).x
            let distanceY = sender.translationInView(self.view).y
            if fabs(distanceY) > fabs(distanceX) {
                self.inputKeyboard.resignFirstResponder()
            }
        }
    }
    
    func onCellTap(sender:UITapGestureRecognizer) {
        self.inputKeyboard.resignFirstResponder()
    }
    
    func onImageTap(sender:UITapGestureRecognizer) {
        self.inputKeyboard.resignFirstResponder()
        let index = sender.view!.tag
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        let content = data.objectForKey("content") as! String
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            let img0 = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
            if img0 != 0 {
                if let v = sender.view as? UIImageView {
                    let w = sender.view!.width()
                    let h = sender.view!.height()
                    let url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!large"
                    let yPoint = sender.view?.convertPoint(CGPointZero, fromView: self.view.window)
                    let rect = CGRectMake(-yPoint!.x, -yPoint!.y, w, h)
                    v.showImage(url, rect: rect)
                }
            }
        }
    }
    
    func userclick(sender:UITapGestureRecognizer){
        self.inputKeyboard.resignFirstResponder()
        let UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
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
    
    func commentVC(){
        //这里是回应别人
        self.inputKeyboard.text = "@\(self.ReplyUserName) "
        delay(0.3, closure: {
            self.inputKeyboard.becomeFirstResponder()
            return
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                self.commentVC()
            }else if buttonIndex == 1 { //复制
                let pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }
        }else if actionSheet == self.actionSheetPhoto {
            if buttonIndex == 0 {
                self.inputKeyboard.resignFirstResponder()
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            }else if buttonIndex == 1 {
                self.inputKeyboard.resignFirstResponder()
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
        
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        let safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        self.commentFinish("\(safeuid)_loading_\(width)_\(height)", type: 2)
        let uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            var uploadUrl = data.objectForKey("url") as! String
            setCacheImage("http://img.nian.so\(uploadUrl)!large", img: img, width: 500)
            uploadUrl = SAReplace(uploadUrl, before: "/circle/", after: "") as String
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
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        self.keyboardHeight = keyboardSize.height
        self.keyboardView.pointY = globalHeight - self.keyboardHeight - 44
        self.keyboardView.layoutSubviews()
        let heightScroll = globalHeight - 44 - 64 - self.keyboardHeight
        let contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.tableview.setHeight( heightScroll )
        self.tableview.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        let heightScroll = globalHeight - 44 - 64
        self.keyboardView.pointY = globalHeight - 44
        self.keyboardView.layoutSubviews()
        self.tableview.setHeight(heightScroll)
    }
}

