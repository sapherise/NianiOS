//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    let identifier = "comment"
    var tableview:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var replySheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    var navView:UIView!
    var dataTotal:Int = 0
    var viewTop:UIView!
    var ID:Int = 0
    
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    var ReplyUserName:String = ""
    var activityViewController:UIActivityViewController?
    
    var ReturnReplyContent:String = ""
    
    var animating:Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var activityIndicatorView:UIActivityIndicatorView!
    
    var desHeight:CGFloat = 0
    var inputKeyboard:UITextField!
    var keyboardView:UIView!
    var viewBottom:UIView!
    var isKeyboardFocus:Bool = false
    var isKeyboardResign:Int = 0 //为了解决评论会收起键盘的BUG创建的开关，当提交过程中变为1，0时才收起键盘
    var keyboardHeight:CGFloat = 0
    var lastContentOffset:CGFloat?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.registerForKeyboardNotifications()
        self.deregisterFromKeyboardNotifications()
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
    }
    
    func setupViews() {
        viewBack(self)
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        
        self.tableview = UITableView(frame:CGRectMake(0,64,globalWidth,globalHeight - 64 - 44))
        self.tableview!.backgroundColor = UIColor.clearColor()
        self.tableview!.delegate = self;
        self.tableview!.dataSource = self;
        self.tableview!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"CommentCell", bundle: nil)
        var nib2 = UINib(nibName:"CircleType", bundle: nil)
        
        self.tableview?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableview?.registerNib(nib2, forCellReuseIdentifier: "CircleType")
        self.view.addSubview(self.tableview!)
        
        self.viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 44))
        self.activityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(globalWidth / 2 - 10, 21, 20, 20))
        self.activityIndicatorView.hidden = false
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.color = SeaColor
        self.tableview!.tableHeaderView = self.viewTop
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableview!.tableFooterView = self.viewBottom
        
        //输入框
        self.keyboardView = UIView(frame: CGRectMake(0, globalHeight - 44, globalWidth, 44))
        self.keyboardView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        var inputLineView = UIView(frame: CGRectMake(0, 0, globalWidth, 1))
        inputLineView.backgroundColor = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        self.keyboardView.addSubview(inputLineView)
        self.inputKeyboard = UITextField(frame: CGRectMake(8, 8, globalWidth-16, 28))
        self.inputKeyboard.layer.cornerRadius = 4
        self.inputKeyboard.layer.masksToBounds = true
        
        self.inputKeyboard.leftView = UIView(frame: CGRectMake(0, 0, 8, 28))
        self.inputKeyboard.rightView = UIView(frame: CGRectMake(0, 0, 8, 28))
        self.inputKeyboard.leftViewMode = UITextFieldViewMode.Always
        self.inputKeyboard.rightViewMode = UITextFieldViewMode.Always
        
        
        self.inputKeyboard.delegate = self
        self.inputKeyboard.backgroundColor = UIColor.whiteColor()
        self.keyboardView.addSubview(self.inputKeyboard)
        self.view.addSubview(self.keyboardView)
        
        
        self.inputKeyboard.returnKeyType = UIReturnKeyType.Send
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.text = "梦境"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "onCircleDetailClick")
        rightButton.image = UIImage(named:"newList")
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func onCircleDetailClick(){
        var circledetailVC = CircleDetailController()
        circledetailVC.Id = "\(self.ID)"
        self.navigationController!.pushViewController(circledetailVC, animated: true)
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
    
    func commentFinish(replyContent:String){
        self.isKeyboardResign = 1
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeuser = Sa.objectForKey("user") as String
        var commentReplyRow = self.dataArray.count
        var newinsert = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending...", "\(safeuid)", "\(safeuser)","1"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
        self.dataArray.insertObject(newinsert, atIndex: 0)
        var newindexpath = NSIndexPath(forRow: commentReplyRow, inSection: 0)
        self.tableview!.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.None)
        //当提交评论后滚动到最新评论的底部
        var contentOffsetHeight = self.tableview!.contentOffset.y
        if self.tableview!.contentSize.height > self.tableview!.bounds.size.height {
            self.tableview!.setContentOffset(CGPointMake(0, contentOffsetHeight + replyContent.stringHeightWith(17,width:208) + 60), animated: true)
        }
    }
    
    //将内容发送至服务器
    func addReply(contentComment:String){
        var content = SAEncode(SAHtml(contentComment))
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var safeuser = Sa.objectForKey("user") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("id=\(self.ID)&&uid=\(safeuid)&&shell=\(safeshell)&&content=\(content)", "http://nian.so/api/circle_chat.php")
            if sa != "" && sa != "err" {
                dispatch_async(dispatch_get_main_queue(), {
                    delay(0.5, { () -> () in
                        self.SAReloadData(bool: true)
                    })
                })
            }
        })
    }
    
    func SAloadData()
    {
        var heightBefore = self.tableview!.contentSize.height
        var url = "http://nian.so/api/circle_chat_list.php?page=\(page)&id=\(ID)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                var arr = data["items"] as NSArray
                var total = data["total"] as NSString!
                self.dataTotal = "\(total)".toInt()!
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableview!.reloadData()
                var heightAfter = self.tableview!.contentSize.height
                var heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                self.tableview!.setContentOffset(CGPointMake(0, heightChange), animated: false)
                self.page++
                self.animating = 0
            }
        })
    }
    
    func SAReloadData(bool:Bool = false){
        var url = "http://nian.so/api/circle_chat_list.php?page=0&id=\(ID)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull(){
                var arr = data["items"] as NSArray
                var total = data["total"] as NSString!
                self.dataTotal = "\(total)".toInt()!
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                if self.dataTotal < 15 {
                    self.tableview!.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
                }
                self.tableview!.reloadData()
                self.tableview!.headerEndRefreshing()
                if self.tableview!.contentSize.height > self.tableview!.bounds.size.height {
                    self.tableview!.setContentOffset(CGPointMake(0, self.tableview!.contentSize.height-self.tableview!.bounds.size.height), animated: bool)
                }
                self.page = 1
                self.isKeyboardResign = 0
            }
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var y = scrollView.contentOffset.y
        if self.dataTotal == 15 {
            self.viewTop.addSubview(self.activityIndicatorView)
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    delay(0.5, { () -> () in
                        self.SAloadData()
                    })
                }
            }
        }else{
            self.activityIndicatorView.hidden = true
            self.tableview?.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
        }
    }
    
    func urlString()->String
    {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/step.php?page=\(page)&id=\(self.ID)&uid=\(safeuid)"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if self.isKeyboardFocus == false {
            self.tableview!.deselectRowAtIndexPath(indexPath, animated: false)
            var index = indexPath.row
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
                    self.replySheet!.addButtonWithTitle("删除")
                    self.replySheet!.addButtonWithTitle("取消")
                    self.replySheet!.cancelButtonIndex = 3
                    self.replySheet!.showInView(self.view)
                }else{
                    self.replySheet!.addButtonWithTitle("回应@\(user)")
                    self.replySheet!.addButtonWithTitle("复制")
                    self.replySheet!.addButtonWithTitle("标记为不合适")
                    self.replySheet!.addButtonWithTitle("取消")
                    self.replySheet!.cancelButtonIndex = 3
                    self.replySheet!.showInView(self.view)
                }
        }else{
            self.inputKeyboard.resignFirstResponder()
        }
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
        if type == "1" || type == "2" {
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as CommentCell
            c.data = data
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            cell = c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier("CircleType", forIndexPath: indexPath) as CircleTypeCell
            c.data = data
            cell = c
        }
        return cell
    }
    
    func userclick(sender:UITapGestureRecognizer){
        self.inputKeyboard.resignFirstResponder()
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var index = indexPath!.row
        var data = self.dataArray[self.dataArray.count - 1 - index] as NSDictionary
        if let type = data.objectForKey("type") as? String {
            if type == "1" || type == "2" {
                return CommentCell.cellHeightByData(data)
            }
        }
        return 90
    }
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
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
            }else if buttonIndex == 2 {
                var data = self.dataArray[self.ReplyRow] as NSDictionary
                var uid = data.stringAttributeForKey("uid")
                if ( uid == safeuid ) {
                    self.deleteCommentSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    self.deleteCommentSheet!.addButtonWithTitle("确定删除")
                    self.deleteCommentSheet!.addButtonWithTitle("取消")
                    self.deleteCommentSheet!.cancelButtonIndex = 1
                    self.deleteCommentSheet!.showInView(self.view)
                }else{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)", "http://nian.so/api/a.php")
                        if(sa == "1"){
                            dispatch_async(dispatch_get_main_queue(), {
                                UIView.showAlertView("谢谢", message: "如果这个回应不合适，我们会将其移除。")
                            })
                        }
                    })
                }
            }
        }else if actionSheet == self.deleteCommentSheet {
            if buttonIndex == 0 {
                self.isKeyboardResign = 1
                self.dataArray.removeObjectAtIndex(self.ReplyRow)
                var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 0)
                self.tableview!.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.None)
                self.tableview!.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_comment.php")
                    self.isKeyboardResign = 0
                })
            }
        }
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
        var contentOffsetTableView = self.tableview!.contentSize.height >= heightScroll ? self.tableview!.contentSize.height - heightScroll : 0
        self.tableview!.setHeight( heightScroll )
        self.tableview!.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        self.isKeyboardFocus = false
        var heightScroll = globalHeight - 44 - 64
        var contentOffsetTableView = self.tableview!.contentSize.height >= heightScroll ? self.tableview!.contentSize.height - heightScroll : 0
        self.keyboardView.setY( globalHeight - 44 )
        self.tableview!.setHeight( heightScroll )
    }
}

