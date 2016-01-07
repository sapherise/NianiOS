//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UITextFieldDelegate{
    
    var tableview:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var replySheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var dataTotal: Int = 0
    var viewTop: UIView!
    
    var dreamID: Int = 0
    var stepID: Int = 0
    
    var dreamowner: Int = 0 //如果是0，就不是主人，是1就是主人
    
//    var ReplyContent:String = ""
//    var ReplyRow:Int = 0
//    var ReplyCid:String = ""
    var rowSelected = -1
    var animating: Int = 0   //加载顶部内容的开关，默认为0，初始为1，当为0时加载，1时不动
    var activityIndicatorView: UIActivityIndicatorView!
    
    var desHeight: CGFloat = 0
    var inputKeyboard: UITextField!
    var keyboardView: UIView!
    var viewBottom: UIView!
    var keyboardHeight: CGFloat = 0
    var lastContentOffset: CGFloat?
    var name: String?
    var index: Int = -1
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        self.viewLoadingHide()
        keyboardEndObserve()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.tableview = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 56))
        self.tableview.backgroundColor = UIColor.clearColor()
        self.tableview.delegate = self;
        self.tableview.dataSource = self;
        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableview.registerNib(UINib(nibName:"CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        self.tableview.registerNib(UINib(nibName:"CommentCellMe", bundle: nil), forCellReuseIdentifier: "CommentCellMe")
        self.tableview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.view.addSubview(self.tableview)
        
        self.viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 56))
        self.activityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(globalWidth / 2 - 10, 21, 20, 20))
        self.activityIndicatorView.hidden = false
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.color = SeaColor
        self.tableview.tableHeaderView = self.viewTop
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableview.tableFooterView = self.viewBottom
        
        //输入框
        keyboardView = UIView()
        inputKeyboard = UITextField()
        inputKeyboard.delegate = self
        keyboardView.setTextField(inputKeyboard)
        self.view.addSubview(keyboardView)
        if name != nil {
            inputKeyboard.text = "@\(name!) "
        }
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.text = "回应"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewLoadingShow()
    }
    
    //按下发送后调用此函数
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let contentComment = self.inputKeyboard.text
        if contentComment != "" {
            commentFinish(contentComment!)
        }
        return true
    }
    
    func commentFinish(replyContent:String){
        self.inputKeyboard.text = ""
        if let name = Cookies.get("user") as? String {
            let newinsert = NSDictionary(objects: [replyContent, "" , "sending", "\(SAUid())", "\(name)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
            self.dataArray.insertObject(newinsert, atIndex: 0)
            self.tableview.reloadData()
            //当提交评论后滚动到最新评论的底部
            
            //  提交到服务器
            let content = SAEncode(SAHtml(replyContent))
            var success = false
            var finish = false
            var IDComment = 0
            Api.postDreamStepComment("\(self.dreamID)", step: "\(self.stepID)", content: content) { json in
                if json != nil {
                    if let status = json!.objectForKey("status") as? NSNumber {
                        if status == 200 {
                            IDComment = Int((json as! NSDictionary).stringAttributeForKey("data"))!
                            success = true
                            if finish {
                                let newinsert = NSDictionary(objects: [replyContent, "\(IDComment)" , "0s", "\(SAUid())", "\(name)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
                                self.tableview.beginUpdates()
                                self.dataArray.replaceObjectAtIndex(0, withObject: newinsert)
                                self.tableview.reloadData()
                                self.tableview.endUpdates()
                            }
                        } else {
                            self.showTipText("对方设置了不被回应...")
                            self.inputKeyboard.text = replyContent
                        }
                    } else {
                        self.showTipText("服务器坏了...")
                        self.inputKeyboard.text = replyContent
                    }
                }
            }
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                let offset = self.tableview.contentSize.height - self.tableview.bounds.size.height
                if offset > 0 {
                    self.tableview.contentOffset.y = offset
                }
                }) { (Bool) -> Void in
                    if success {
                        let newinsert = NSDictionary(objects: [replyContent, "\(IDComment)" , "0s", "\(SAUid())", "\(name)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
                        self.tableview.beginUpdates()
                        self.dataArray.replaceObjectAtIndex(0, withObject: newinsert)
                        self.tableview.reloadData()
                        self.tableview.endUpdates()
                    } else {
                        finish = true
                    }
            }
        }
    }
    
    func SAloadData() {
        let heightBefore = self.tableview.contentSize.height
        let url = "http://nian.so/api/comment_step.php?page=\(page)&id=\(stepID)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull() {
                let arr = data.objectForKey("items") as! NSArray
                let total = data.objectForKey("total") as! NSString!
                self.dataTotal = Int("\(total)")!
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableview.reloadData()
                let heightAfter = self.tableview.contentSize.height
                let heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                self.tableview.setContentOffset(CGPointMake(0, heightChange), animated: false)
                self.page++
                self.animating = 0
            }
        })
    }
    
    func SAReloadData(){
        let url = "http://nian.so/api/comment_step.php?page=0&id=\(stepID)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                let arr = data.objectForKey("items") as! NSArray
                let total = data.objectForKey("total") as! NSString!
                self.dataTotal = Int("\(total)")!
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                if self.dataTotal < 15 {
                    self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
                }
                self.tableview.reloadData()
                self.viewLoadingHide()
                self.tableview.headerEndRefreshing()
                if self.tableview.contentSize.height > self.tableview.bounds.size.height {
                    self.tableview.setContentOffset(CGPointMake(0, self.tableview.contentSize.height-self.tableview.bounds.size.height), animated: false)
                }
                self.page = 1
            }
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let y = scrollView.contentOffset.y
        if self.dataTotal == 15 {
            self.viewTop.addSubview(self.activityIndicatorView)
            if y < 40 {
                if self.animating == 0 {
                    self.animating = 1
                    delay(0.5, closure: { () -> () in
                        self.SAloadData()
                    })
                }
            }
        }else{
            self.activityIndicatorView.hidden = true
            self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, 0))
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func onBubbleClick(sender:UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            index = tag
            commentVC()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let data = self.dataArray[dataArray.count - 1 - index] as! NSDictionary
        let uid = data.stringAttributeForKey("uid")
        if uid == SAUid() {
            let c = tableView.dequeueReusableCellWithIdentifier("CommentCellMe", forIndexPath: indexPath) as! CommentCellMe
            c.data = data
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.imageContent.tag = dataArray.count - 1 - index
            c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.imageContent.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onMore:"))
            c.View.tag = index
            c._layoutSubviews()
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
            c.data = data
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.imageContent.tag = dataArray.count - 1 - index
            c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
            c.imageContent.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "onMore:"))
            c.View.tag = index
            c._layoutSubviews()
            return c
        }
    }
    
    func onMore(sender: UILongPressGestureRecognizer) {
        if let tag = sender.view?.tag {
            index = tag
            if sender.state == UIGestureRecognizerState.Began {
                let index = sender.view!.tag
                let data = self.dataArray[index] as! NSDictionary
                let user = data.stringAttributeForKey("user")
                let uid = data.stringAttributeForKey("uid")
                rowSelected = index
                self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                if self.dreamowner == 1 {   //主人
                    self.replySheet!.addButtonWithTitle("回应@\(user)")
                    self.replySheet!.addButtonWithTitle("复制")
                    self.replySheet!.addButtonWithTitle("删除")
                    self.replySheet!.addButtonWithTitle("取消")
                    self.replySheet!.cancelButtonIndex = 3
                    self.replySheet!.showInView(self.view)
                }else{  //不是主人
                    if uid == SAUid() {
                        self.replySheet!.addButtonWithTitle("回应@\(user)")
                        self.replySheet!.addButtonWithTitle("复制")
                        self.replySheet!.addButtonWithTitle("删除")
                        self.replySheet!.addButtonWithTitle("取消")
                        self.replySheet!.cancelButtonIndex = 3
                        self.replySheet!.showInView(self.view)
                    }else{
                        self.replySheet!.addButtonWithTitle("回应@\(user)")
                        self.replySheet!.addButtonWithTitle("复制")
                        self.replySheet!.addButtonWithTitle("举报")
                        self.replySheet!.addButtonWithTitle("取消")
                        self.replySheet!.cancelButtonIndex = 3
                        self.replySheet!.showInView(self.view)
                    }
                }
            }
        }
    }

    func onCellClick(sender:UIPanGestureRecognizer){
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
    
    func userclick(sender:UITapGestureRecognizer){
        self.inputKeyboard.resignFirstResponder()
        let UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
//        return  CommentCell.cellHeightByData(data)
        
        
//        let data = dataArray[index] as! NSDictionary
        let heightCell = data.stringAttributeForKey("heightCell")
        // 当高度
        if heightCell == "" {
            let arr = CommentCell.cellHeightByData(data)
            let hCell = arr[0] as! CGFloat
            let hContent = arr[1] as! CGFloat
            let wImage = arr[2] as! CGFloat
            let hImage = arr[3] as! CGFloat
            let d = NSMutableDictionary(dictionary: data)
            d.setValue(hCell, forKey: "heightCell")
            d.setValue(hContent, forKey: "heightContent")
            d.setValue(wImage, forKey: "widthImage")
            d.setValue(hImage, forKey: "heightImage")
            dataArray.replaceObjectAtIndex(dataArray.count - 1 - index, withObject: d)
            return hCell
        } else {
            return CGFloat((heightCell as NSString).floatValue)
        }
    }
    
    func commentVC(){
        if index >= 0 {
            let data = dataArray[index] as! NSDictionary
            let name = data.stringAttributeForKey("user")
            self.inputKeyboard.text = "@\(name) "
            self.inputKeyboard.becomeFirstResponder()
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let safeuid = SAUid()
        if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                self.commentVC()
            }else if buttonIndex == 1 { //复制
                let pasteBoard = UIPasteboard.generalPasteboard()
                let data = self.dataArray[rowSelected] as! NSDictionary
                pasteBoard.string = data.stringAttributeForKey("content")
            }else if buttonIndex == 2 {
                let data = self.dataArray[rowSelected] as! NSDictionary
                let uid = data.stringAttributeForKey("uid")
                if (( uid == safeuid ) || ( self.dreamowner == 1 )) {
                    self.deleteCommentSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    self.deleteCommentSheet!.addButtonWithTitle("确定删除")
                    self.deleteCommentSheet!.addButtonWithTitle("取消")
                    self.deleteCommentSheet!.cancelButtonIndex = 1
                    self.deleteCommentSheet!.showInView(self.view)
                }else{
                    UIView.showAlertView("谢谢", message: "如果这个回应不合适，我们会将其移除。")
                }
            }
        }else if actionSheet == self.deleteCommentSheet {
            if buttonIndex == 0 {
                let data = dataArray[rowSelected] as! NSDictionary
                let cid = data.stringAttributeForKey("id")
                self.dataArray.removeObjectAtIndex(rowSelected)
                self.tableview.beginUpdates()
                self.tableview.deleteRowsAtIndexPaths([NSIndexPath(forRow: rowSelected, inSection: 0)], withRowAnimation: .Fade)
                self.tableview.reloadData()
                self.tableview.endUpdates()
                Api.postDeleteComment(cid) { json in
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        self.keyboardHeight = keyboardSize.height
        self.keyboardView.setY( globalHeight - self.keyboardHeight - 56 )
        let heightScroll = globalHeight - 56 - 64 - self.keyboardHeight
        let contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        self.tableview.setHeight( heightScroll )
        self.tableview.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        let heightScroll = globalHeight - 56 - 64
        self.keyboardView.setY( globalHeight - 56 )
        self.tableview.setHeight( heightScroll )
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }else{
            return true
        }
    }
}

