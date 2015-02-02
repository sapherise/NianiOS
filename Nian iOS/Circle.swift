//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    let identifier = "CircleBubbleCell"
    var tableview:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var replySheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var actionSheetPhoto:UIActionSheet?
    var navView:UIView!
    var dataTotal:Int = 15
    var viewTop:UIView!
    var ID:Int = 0
    
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    var ReplyUserName:String = ""
    
    var ReturnReplyContent:String = ""
    
    var animating:Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var isTheEnd:Int = 0    //当没有更多内容加载时为1
    var activityIndicatorView:UIActivityIndicatorView!
    
    var desHeight:CGFloat = 0
    var inputKeyboard:UITextField!
    var keyboardView:UIView!
    var viewBottom:UIView!
    var isKeyboardFocus:Bool = false
    var keyboardHeight:CGFloat = 0
    var lastContentOffset:CGFloat?
    
    var imagePicker:UIImagePickerController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.viewLoadingHide()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
        self.deregisterFromKeyboardNotifications()
        self.viewBackFix()
        if globalWillCircleChatReload == 1 {
            globalWillCircleChatReload = 0
            self.SAReloadData()
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
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"CircleBubbleCell", bundle: nil)
        var nib2 = UINib(nibName:"CircleType", bundle: nil)
        
        self.tableview.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableview.registerNib(nib2, forCellReuseIdentifier: "CircleType")
        
        var pan = UIPanGestureRecognizer(target: self, action: "onCellPan:")
        pan.delegate = self
        self.tableview.addGestureRecognizer(pan)
        self.tableview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.view.addSubview(self.tableview)
        
        self.viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 44))
        self.activityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(globalWidth / 2 - 10, 21, 20, 20))
        self.activityIndicatorView.hidden = false
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.color = SeaColor
        self.tableview.tableHeaderView = self.viewTop
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableview.tableFooterView = self.viewBottom
        
        
        // 输入框
        self.keyboardView = UIView(frame: CGRectMake(0, globalHeight - 44, globalWidth, 44))
        self.keyboardView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
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
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "onCircleDetailClick")
        rightButton.image = UIImage(named:"newList")
        self.navigationItem.rightBarButtonItem = rightButton
        self.viewLoadingShow()
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var r = client.enter(safeuid, shell: safeshell)
        if r == 0 {
            client.pollBegin(on_poll)
        }
    }
    
    func on_poll(obj: AnyObject?) {
        var msg: AnyObject? = obj!["msg"]
        var json: AnyObject? = msg!["msg"]
        var data: AnyObject? = json![0]
        var contentJson: AnyObject? = data!["msg"]
        var uidJson: AnyObject? = data!["from"]
        var typeJson: AnyObject? = data!["totype"]
        var timeJson: AnyObject? = data!["time"]
        var content = "\(contentJson!)"
        content = content.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        var uid = "\(uidJson!)"
        var type = "\(typeJson!)".toInt()!
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeuser = Sa.objectForKey("user") as String
        var commentReplyRow = self.dataArray.count
        if safeuid != uid {     // 如果是朋友们发的
            var newinsert = NSDictionary(objects: [content, "\(commentReplyRow)" , "", uid, "昵称","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArray.insertObject(newinsert, atIndex: 0)
            var newindexpath = NSIndexPath(forRow: commentReplyRow, inSection: 0)
            self.tableview.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.None)
            self.tableview.reloadData()
            //当提交评论后滚动到最新评论的底部
            var contentOffsetHeight = self.tableview.contentOffset.y
            var contentHeight:CGFloat = 0
            if type == 1 {
                contentHeight = content.stringHeightWith(13,width:208) + 60
            }else if type == 2 {
                var arrContent = content.componentsSeparatedByString("_")
                if arrContent.count == 4 {
                    if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                        contentHeight = CGFloat(n) + 40
                    }
                }
            }
            var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
            if offset > 0 {
                self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
            }
        }else{
            delay(0.2, { () -> () in
                for var i: Int = 0; i < commentReplyRow; i++ {
                    var data = self.dataArray[i] as NSDictionary
                    var contentOri = data.stringAttributeForKey("content")
                    if content == contentOri {
                        var mutableItem = NSMutableDictionary(dictionary: data)
                        mutableItem.setObject("现在", forKey: "lastdate")
                        self.dataArray.replaceObjectAtIndex(i, withObject: mutableItem)
                        self.tableview.reloadData()
                        break
                    }
                }
            })
        }
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
            commentFinish(contentComment)
            self.inputKeyboard.text = ""
            self.addReply(contentComment)
        }
        return true
    }
    
    func commentFinish(replyContent:String, type: Int = 1){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeuser = Sa.objectForKey("user") as String
        var commentReplyRow = self.dataArray.count
        var newinsert = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending...", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
        self.dataArray.insertObject(newinsert, atIndex: 0)
        var newindexpath = NSIndexPath(forRow: commentReplyRow, inSection: 0)
        self.tableview.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.None)
        self.tableview.reloadData()
        //当提交评论后滚动到最新评论的底部
        var contentOffsetHeight = self.tableview.contentOffset.y
        var contentHeight:CGFloat = 0
        if type == 1 {
            contentHeight = replyContent.stringHeightWith(13,width:208) + 60
        }else if type == 2 {
            var arrContent = replyContent.componentsSeparatedByString("_")
            if arrContent.count == 4 {
                if let n = NSNumberFormatter().numberFromString(arrContent[3]) {
                    contentHeight = CGFloat(n) + 40
                }
            }
        }
        var offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
        if offset > 0 {
            self.tableview.setContentOffset(CGPointMake(0, offset), animated: true)
        }
    }
    
    //将内容发送至服务器
    func addReply(contentComment:String, type:Int = 1){
        var content = SAEncode(SAHtml(contentComment))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var safeuser = Sa.objectForKey("user") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("id=\(self.ID)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)&&type=\(type)", "http://nian.so/api/circle_chat.php")
        })
        on_gay(["\(self.ID)", "\(contentComment)"])
    }
    
    func SAloadData() {
        var heightBefore = self.tableview.contentSize.height
        Api.getCircleChatList(page, id: ID) { json in
            if json != nil {
                var arr = json!["items"] as NSArray
                var total = json!["total"] as NSString!
                self.dataTotal = "\(total)".toInt()!
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableview.reloadData()
                var heightAfter = self.tableview.contentSize.height
                var heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                self.tableview.contentOffset = CGPointMake(0, heightChange)
                self.page++
                self.animating = 0
            }
        }
    }
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        Api.getCircleChatList(0, id: ID) { json in
            if json != nil {
                self.viewLoadingHide()
                var arr = json!["items"] as NSArray
                var total = json!["total"] as NSString!
                self.dataTotal = "\(total)".toInt()!
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                if self.dataTotal < 15 {
                    self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
                }
                self.tableview.reloadData()
                self.tableview.headerEndRefreshing()
                if self.tableview.contentSize.height > self.tableview.bounds.size.height {
                    self.tableview.setContentOffset(CGPointMake(0, self.tableview.contentSize.height-self.tableview.bounds.size.height), animated: false)
                }
                self.page = 1
                if let v = (self.navigationItem.titleView as? UILabel) {
                    var title = json!["title"] as String
                    v.text = title
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var y = scrollView.contentOffset.y
        if self.dataTotal == 15 {
            self.viewTop.addSubview(self.activityIndicatorView)
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    delay(0.3, { () -> () in
                        self.SAloadData()
                    })
                }
            }
        }else{
            if self.isTheEnd == 0 {
                self.isTheEnd = 1
                self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
                if let v = self.activityIndicatorView {
                    v.removeFromSuperview()
                }
            }
        }
    }
    
    func urlString()->String
    {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/step.php?page=\(page)&id=\(self.ID)&uid=\(safeuid)"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var index = indexPath.row
        var data = self.dataArray[dataArray.count - 1 - index] as NSDictionary
        var type = data.objectForKey("type") as String
        // 1: 文字消息，2: 图片消息，3: 进展更新，4: 成就通告，5: 用户加入，6: 管理员操作，7: 邀请用户
        if type == "1" {
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as CircleBubbleCell
            c.data = data
            c.isImage = 0
            c.textContent.tag = index
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.textContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.View.tag = index
            cell = c
        }else if type == "2" {
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as CircleBubbleCell
            c.data = data
            c.isImage = 1
            c.imageContent.tag = index
            c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.View.tag = index
            cell = c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier("CircleType", forIndexPath: indexPath) as CircleTypeCell
            c.data = data
            cell = c
        }
        return cell
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
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
        var data = self.dataArray[dataArray.count - 1 - index] as NSDictionary
        var content = data.objectForKey("content") as String
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
        var data = self.dataArray[self.dataArray.count - 1 - index] as NSDictionary
        var user = data.stringAttributeForKey("user") as String
        var uid = data.stringAttributeForKey("uid")
        var content = data.stringAttributeForKey("content") as String
        var cid = data.stringAttributeForKey("id") as String
        self.ReplyRow = self.dataArray.count - 1 - index
        self.ReplyContent = content
        self.ReplyCid = cid
        self.ReplyUserName = user
        self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            if uid == safeuid {
                self.replySheet!.addButtonWithTitle("回应@\(user)")
                self.replySheet!.addButtonWithTitle("复制")
                self.replySheet!.addButtonWithTitle("取消")
                self.replySheet!.cancelButtonIndex = 2
                self.replySheet!.showInView(self.view)
            }else{
                self.replySheet!.addButtonWithTitle("回应@\(user)")
                self.replySheet!.addButtonWithTitle("复制")
                self.replySheet!.addButtonWithTitle("取消")
                self.replySheet!.cancelButtonIndex = 2
                self.replySheet!.showInView(self.view)
            }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var index = indexPath!.row
        var data = self.dataArray[self.dataArray.count - 1 - index] as NSDictionary
        if let type = data.objectForKey("type") as? String {
            if type == "1" {
                return CircleBubbleCell.cellHeightByData(data)
            }else if type == "2" {
                return CircleBubbleCell.cellHeightByData(data, isImage: 1)
            }
        }
        return 65
    }
    
    func commentVC(){
        //这里是回应别人
        self.inputKeyboard.text = "@\(self.ReplyUserName) "
        delay(0.5, { () -> () in
            self.inputKeyboard.becomeFirstResponder()
            return
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                self.commentVC()
            }else if buttonIndex == 1 { //复制
                var pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }
        }else if actionSheet == self.deleteCommentSheet {
            if buttonIndex == 0 {
                self.dataArray.removeObjectAtIndex(self.ReplyRow)
                var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 0)
                self.tableview.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.None)
                self.tableview.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_comment.php")
                })
            }
        }else if actionSheet == self.actionSheetPhoto {
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
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
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
        self.commentFinish("1_loading_\(width)_\(height)", type: 2)
        var uy = UpYun()
        uy.successBlocker = ({(data:AnyObject!) in
            var uploadUrl = data.objectForKey("url") as String
            uploadUrl = SAReplace(uploadUrl, "/circle/", "") as String
            uploadUrl = SAReplace(uploadUrl, ".png", "") as String
            var content = "\(uploadUrl)_\(width)_\(height)"
            self.addReply(content, type: 2)
        })
        uy.uploadImage(resizedImage(img, 500), savekey: getSaveKey("circle", "png"))
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func registerForKeyboardNotifications()->Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() -> Void {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardDidHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        self.isKeyboardFocus = true
        var info: Dictionary = notification.userInfo!
        var keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size)!
        self.keyboardHeight = keyboardSize.height
        self.keyboardView.setY( globalHeight - self.keyboardHeight - 44 )
        var heightScroll = globalHeight - 44 - 64 - self.keyboardHeight
        var contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.tableview.setHeight( heightScroll )
        self.tableview.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        self.isKeyboardFocus = false
        var heightScroll = globalHeight - 44 - 64
        var contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.keyboardView.setY( globalHeight - 44 )
        self.tableview.setHeight( heightScroll )
    }
}

