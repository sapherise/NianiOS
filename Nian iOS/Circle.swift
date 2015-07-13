//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
            var data = noti.object as! NSDictionary
            var circle = data.stringAttributeForKey("to")
            if circle == "\(self.ID)" {
                var id = data.stringAttributeForKey("msgid")
                var uid = data.stringAttributeForKey("from")
                var name = data.stringAttributeForKey("fromname")
                var content = data.stringAttributeForKey("msg")
                var title = data.stringAttributeForKey("title")
                var type = data.stringAttributeForKey("msgtype")
                var time = (data.stringAttributeForKey("time") as NSString).doubleValue
                var cid = data.stringAttributeForKey("cid")
//                content = SADecode(SADecode(content))
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeuser = Sa.objectForKey("user") as! String
                var commentReplyRow = self.dataArray.count
                var absoluteTime = V.absoluteTime(time)
                if (safeuid != uid) || (type != "1" && type != "2") {     // 如果是朋友们发的
                    var newinsert = NSDictionary(objects: [content, "\(commentReplyRow)" , absoluteTime, uid, name,"\(type)", title, cid], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
                    self.dataArray.insertObject(newinsert, atIndex: 0)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableview.reloadData()
                        var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
                        if offset > 0 && offset - self.tableview.contentOffset.y < globalHeight * 0.5 {
                            self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
                        }
                    })
                }
            }
        })
    }
    
    func Letter(noti: NSNotification) {
        var data = noti.object as! NSDictionary
        var uid = data.stringAttributeForKey("from")
        if uid == "\(self.ID)" {
            var id = data.stringAttributeForKey("msgid")
            var circle = data.stringAttributeForKey("to")
            var name = data.stringAttributeForKey("fromname")
            var content = data.stringAttributeForKey("msg")
            var title = data.stringAttributeForKey("title")
            var type = data.stringAttributeForKey("msgtype")
            var time = (data.stringAttributeForKey("time") as NSString).doubleValue
            content = SADecode(SADecode(content))
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeuser = Sa.objectForKey("user") as! String
            var commentReplyRow = self.dataArray.count
            var absoluteTime = V.absoluteTime(time)
            var newinsert = NSDictionary(objects: [content, "\(commentReplyRow)" , absoluteTime, uid, name,"\(type)", title, "0"], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
            self.dataArray.insertObject(newinsert, atIndex: 0)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.tableview.reloadData()
                var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
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
        var nib = UINib(nibName:"CircleBubbleCell", bundle: nil)
        self.tableview.registerNib(nib, forCellReuseIdentifier: "CircleBubbleCell")
        var nib4 = UINib(nibName:"CircleImageCell", bundle: nil)
        self.tableview.registerNib(nib4, forCellReuseIdentifier: "CircleImageCell")
        
        
        var pan = UIPanGestureRecognizer(target: self, action: "onCellPan:")
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
        
        var inputLineView = UIView(frame: CGRectMake(0, 0, globalWidth, 1))
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
        var imagePhoto = UIImageView(frame: CGRectMake(8, 8, 28, 28))
        imagePhoto.image = UIImage(named: "camera")
        imagePhoto.contentMode = UIViewContentMode.Center
        imagePhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onPhotoClick:"))
        imagePhoto.userInteractionEnabled = true
        self.keyboardView.addSubview(imagePhoto)
        self.view.addSubview(self.keyboardView)
        self.inputKeyboard.returnKeyType = UIReturnKeyType.Send
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func onPhotoClick(sender:UITapGestureRecognizer){
        self.actionSheetPhoto = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetPhoto!.addButtonWithTitle("相册")
        self.actionSheetPhoto!.addButtonWithTitle("拍照")
        self.actionSheetPhoto!.addButtonWithTitle("取消")
        self.actionSheetPhoto!.cancelButtonIndex = 2
        self.actionSheetPhoto!.showInView(self.view)
    }
    
    func onCircleDetailClick(){
        var circledetailVC = CircleDetailController()
        circledetailVC.Id = "\(self.ID)"
        self.navigationController?.pushViewController(circledetailVC, animated: true)
    }
    
    //按下发送后调用此函数
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        var contentComment = self.inputKeyboard.text
        if contentComment != "" {
            postWord(contentComment)
            self.inputKeyboard.text = ""
        }
        return true
    }
    
    func commentFinish(replyContent:String, type: Int = 1){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeuser = Sa.objectForKey("user") as! String
            var commentReplyRow = self.dataArray.count
            var data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArray.insertObject(data, atIndex: 0)
            self.tableview.reloadData()
            var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
            if offset > 0 {
                self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
            }
        })
    }
    
    func postWord(replyContent: String, type: Int = 1) {
        back {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeuser = Sa.objectForKey("user") as! String
            var commentReplyRow = self.dataArray.count
            var data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArray.insertObject(data, atIndex: 0)
            var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height + replyContent.stringHeightWith(15,width:208) + 60
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
            var data = self.dataArray[i] as! NSDictionary
            var contentBefore = data.stringAttributeForKey("content")
            var lastdate = data.stringAttributeForKey("lastdate")
            var type = data.stringAttributeForKey("type")
            if (contentAfter == contentBefore || type == "2") && lastdate == "sending" {
                var lastdate = V.absoluteTime(NSDate().timeIntervalSince1970)
                var mutableItem = NSMutableDictionary(dictionary: data)
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
        var content = SAEncode(contentAfter)
            Api.postLetterChat(self.ID, content: content, type: type) { json in
                if json != nil {
                    var success = json!["success"] as! String
                    var msgid = json!["msgid"] as! String
                    var lastdate = json!["lastdate"] as! String
                    if success == "1" {
                        self.tableUpdate(contentAfter)
                        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                        var safeuid = Sa.objectForKey("uid") as! String
                        Api.postName(self.ID) { result in
                            if result != nil {
                                SQLLetterContent(msgid, safeuid, result!, "\(self.ID)", contentAfter, "\(type)", lastdate, 1) {}
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
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
            var (resultSet, err) = SD.executeQuery("SELECT * FROM letter where circle ='\(self.ID)' and owner = '\(safeuid)' order by id desc limit \(self.page*30),30")
            if err == nil {
                self.page++
                var title: String?
                for row in resultSet {
                    var id = row["id"]?.asString()
                    var uid = row["uid"]?.asString()
                    var user = row["name"]?.asString()
                    var content = row["content"]?.asString()
                    var type = row["type"]?.asString()
                    var lastdate = row["lastdate"]?.asString()
                    var time = V.absoluteTime((lastdate! as NSString).doubleValue)
                    var data = NSDictionary(objects: [id!, uid!, user!, content!, type!, time], forKeys: ["id", "uid", "user", "content", "type", "lastdate"])
                    self.dataArray.addObject(data)
                    self.dataTotal++
                }
                var heightBefore = self.tableview.contentSize.height
                self.tableview.reloadData()
                var heightAfter = self.tableview.contentSize.height
                if clear {
                    var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
                    if offset > 0  {
                        self.tableview.setContentOffset(CGPointMake(0, offset), animated: false)
                    }
                    if let v = (self.navigationItem.titleView as? UILabel) {
                        v.text = self.circleTitle
                    }
                }else{
                    var heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                    self.tableview.contentOffset = CGPointMake(0, heightChange)
                    self.animating = 0
                }
            }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var y = scrollView.contentOffset.y
        if self.dataTotal == 30 * self.page {
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    self.SAloadData(clear: false)
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var index = indexPath.row
        var data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        var type = data.stringAttributeForKey("type")
        var cid = data.stringAttributeForKey("cid")
        // 1: 文字消息，2: 图片消息，3: 进展更新，4: 成就通告，5: 用户加入，6: 管理员操作，7: 邀请用户
        if type == "1" {
            var c = tableView.dequeueReusableCellWithIdentifier("CircleBubbleCell", forIndexPath: indexPath) as! CircleBubbleCell
            c.data = data
            c.textContent.tag = index
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.textContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.View.tag = index
            c.isDream = 0
            cell = c
        }else if type == "2" {
            var c = tableView.dequeueReusableCellWithIdentifier("CircleImageCell", forIndexPath: indexPath) as! CircleImageCell
            c.data = data
            c.imageContent.tag = index
            c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.View.tag = index
            cell = c
        } else {
            var c = tableView.dequeueReusableCellWithIdentifier("CircleType", forIndexPath: indexPath) as! CircleTypeCell
            c.data = data
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
            var distanceX = sender.translationInView(self.view).x
            var distanceY = sender.translationInView(self.view).y
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
        var index = sender.view!.tag
        var data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        var content = data.objectForKey("content") as! String
        var arrContent = content.componentsSeparatedByString("_")
        if arrContent.count == 4 {
            var img0 = CGFloat(NSNumberFormatter().numberFromString(arrContent[2])!)
            var img1 = CGFloat(NSNumberFormatter().numberFromString(arrContent[3])!)
            if img0 != 0 {
                if let v = sender.view as? UIImageView {
                    var w = sender.view!.width()
                    var h = sender.view!.height()
                    var url = "http://img.nian.so/circle/\(arrContent[0])_\(arrContent[1]).png!large"
                    var yPoint = sender.view?.convertPoint(CGPointZero, fromView: self.view.window)
                    var rect = CGRectMake(-yPoint!.x, -yPoint!.y, w, h)
                    v.showImage(url, rect: rect)
                }
            }
        }
    }
    
    func userclick(sender:UITapGestureRecognizer){
        self.inputKeyboard.resignFirstResponder()
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onBubbleClick(sender:UIGestureRecognizer) {
        var index = sender.view!.tag
        var data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
        var user = data.stringAttributeForKey("user")
        var uid = data.stringAttributeForKey("uid")
        var content = data.stringAttributeForKey("content")
        var cid = data.stringAttributeForKey("cid")
        var type = data.stringAttributeForKey("type")
        self.ReplyRow = self.dataArray.count - 1 - index
        self.ReplyContent = content
        self.ReplyCid = cid
        self.ReplyUserName = user
        self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        if type == "3" {
            var StepVC = SingleStepViewController()
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
        var index = indexPath.row
        var data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
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
        delay(0.3, {
            self.inputKeyboard.becomeFirstResponder()
            return
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                self.commentVC()
            }else if buttonIndex == 1 { //复制
                var pasteBoard = UIPasteboard.generalPasteboard()
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
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeuser = Sa.objectForKey("user") as! String
        self.commentFinish("\(safeuid)_loading_\(width)_\(height)", type: 2)
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            var uploadUrl = data.objectForKey("url") as! String
            setCacheImage("http://img.nian.so\(uploadUrl)!large", img, 500)
            uploadUrl = SAReplace(uploadUrl, "/circle/", "") as String
            uploadUrl = SAReplace(uploadUrl, ".png", "") as String
            var content = "\(uploadUrl)_\(width)_\(height)"
            self.addReply(content, type: 2)
        })
        uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("circle", "png") as String)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        var keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size)!
        self.keyboardHeight = keyboardSize.height
        self.keyboardView.pointY = globalHeight - self.keyboardHeight - 44
        self.keyboardView.layoutSubviews()
        var heightScroll = globalHeight - 44 - 64 - self.keyboardHeight
        var contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.tableview.setHeight( heightScroll )
        self.tableview.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        var heightScroll = globalHeight - 44 - 64
        var contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.keyboardView.pointY = globalHeight - 44
        self.keyboardView.layoutSubviews()
        self.tableview.setHeight(heightScroll)
    }
}

