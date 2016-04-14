//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, delegateInput {
    
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 1
    var replySheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var viewTop: UIView!
    
    var dreamID: Int = 0
    var stepID: Int = 0
    
    var dreamowner: Int = 0 //如果是0，就不是主人，是1就是主人
    
//    var ReplyContent:String = ""
//    var ReplyRow:Int = 0
//    var ReplyCid:String = ""
    var rowSelected = -1
    var isAnimating = false
//    var activityIndicatorView: UIActivityIndicatorView!
    
    var desHeight: CGFloat = 0
    var keyboardView: InputView!
    var viewBottom: UIView!
    var keyboardHeight: CGFloat = 0
    var lastContentOffset: CGFloat?
    var name: String?
    var index: Int = -1
    var Locking = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        load(true)
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
        navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, 0))
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.scrollsToTop = true
        
        self.tableView.registerNib(UINib(nibName:"Comment", bundle: nil), forCellReuseIdentifier: "Comment")
        self.tableView.registerNib(UINib(nibName:"CommentEmoji", bundle: nil), forCellReuseIdentifier: "CommentEmoji")
        self.tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCommentViewController.onCellTap(_:))))
        self.view.addSubview(self.tableView)
        
        self.viewTop = UIView(frame: CGRectMake(0, 0, globalWidth, 56))
        self.viewBottom = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        self.tableView.tableFooterView = self.viewBottom
        
        //输入框
        keyboardView = InputView()
        keyboardView.setup()
        keyboardView.delegate = self
        
        self.view.addSubview(keyboardView)
        if name != nil {
            keyboardView.inputKeyboard.text = "@\(name!) "
            keyboardView.labelPlaceHolder.hidden = true
        }
        
        tableView.setHeight(globalHeight - 64 - keyboardView.heightCell)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.text = "回应"
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewLoadingShow()
        
        tableView.addHeaderWithCallback { () -> Void in
            self.load(false)
        }
    }
    
    /* 发送内容到服务器 */
    func send(replyContent: String, type: String) {
        keyboardView.inputKeyboard.text = ""
        if let name = Cookies.get("user") as? String {
            let newinsert = NSDictionary(objects: [replyContent, "" , "sending", "\(SAUid())", "\(name)", type], forKeys: ["content", "id", "lastdate", "uid", "user", "type"])
            self.dataArray.insertObject(self.dataDecode(newinsert), atIndex: 0)
            self.tableView.reloadData()
            //当提交评论后滚动到最新评论的底部
            
            //  提交到服务器
            let content = SAEncode(SAHtml(replyContent))
            var success = false
            var finish = false
            var IDComment = 0
            Api.postDreamStepComment("\(self.dreamID)", step: "\(self.stepID)", content: content, type: type) { json in
                if json != nil {
                    if let status = json!.objectForKey("status") as? NSNumber {
                        if status == 200 {
                            IDComment = Int((json as! NSDictionary).stringAttributeForKey("data"))!
                            success = true
                            if finish {
                                self.newInsert(replyContent, id: IDComment, type: type)
                            }
                        } else {
                            self.showTipText("对方设置了不被回应...")
                            self.keyboardView.inputKeyboard.text = replyContent
                        }
                    } else {
                        self.showTipText("服务器坏了...")
                        self.keyboardView.inputKeyboard.text = replyContent
                    }
                }
            }
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableView.contentOffset.y = max(self.tableView.contentSize.height - self.tableView.bounds.size.height, 0)
                }) { (Bool) -> Void in
                    if success {
                        self.newInsert(replyContent, id: IDComment, type: type)
                    } else {
                        finish = true
                    }
            }
        }
    }
    
    /* 插入新回应并在 UI 上显示 */
    func newInsert(content: String, id: Int, type: String) {
        if let name = Cookies.get("user") as? String {
            let newinsert = NSDictionary(objects: [content, "\(id)" , V.now(), "\(SAUid())", "\(name)", type], forKeys: ["content", "id", "lastdate", "uid", "user", "type"])
            self.tableView.beginUpdates()
            self.dataArray.replaceObjectAtIndex(0, withObject: self.dataDecode(newinsert))
            self.tableView.reloadData()
            self.tableView.endUpdates()
        }
    }
    
    func load(clear: Bool) {
        if !isAnimating {
            isAnimating = true
            if clear {
                page = 1
            }
            let heightBefore = self.tableView.contentSize.height
            Api.getDreamStepComment("\(stepID)", page: page) { json in
                if json != nil {
                    print(json)
                    self.viewLoadingHide()
                    let data = json!.objectForKey("data") as! NSDictionary
                    let comments = data.objectForKey("comments") as! NSArray
                    var i = 0
                    for comment in comments {
                        if let _d = comment as? NSDictionary {
                            let d = self.dataDecode(_d)
                            self.dataArray.addObject(d)
                            i += 1
                        }
                    }
                    
                    if !clear {
                        delay(0.3, closure: { () -> () in
                            /* 当加载内容不足时，停止加载更多内容 */
                            if i < 15 {
                                self.tableView.setHeaderHidden(true)
                            }
                        
                        /* 因为 tableView 的弹性，需要延时 0.3 秒来加载内容 */
                            self.tableView.reloadData()
                            let h = self.tableView.contentSize.height - heightBefore - 2
                            self.tableView.setContentOffset(CGPointMake(0, max(h, 0)), animated: false)
                            self.page += 1
                            self.isAnimating = false
                        })
                    } else {
                        self.tableView.reloadData()
                        let h = self.tableView.contentSize.height - self.tableView.height()
                        self.tableView.setContentOffset(CGPointMake(0, max(h, 0)), animated: false)
                        self.page += 1
                        self.isAnimating = false
                    }
                }
                self.tableView.headerEndRefreshing()
            }
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
        let type = data.stringAttributeForKey("type")
        if type == "0" || type == "2" {
            /* 文本或奖励 */
            let c = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath) as! Comment
            c.data = data
            c.labelHolder.tag = dataArray.count - 1 - index
            c.labelHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DreamCommentViewController.onBubbleClick(_:))))
            c.labelHolder.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(DreamCommentViewController.onMore(_:))))
            c.setup()
            return c
        } else {
            /* 表情 */
            let c = tableView.dequeueReusableCellWithIdentifier("CommentEmoji", forIndexPath: indexPath) as! CommentEmoji
            c.data = data
            c.labelHolder.tag = dataArray.count - 1 - index
            c.labelHolder.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(DreamCommentViewController.onMore(_:))))
            c.setup()
            return c
        }
    }
    
    func onMore(sender: UILongPressGestureRecognizer) {
        resign()
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
    
    func onCellTap(sender:UITapGestureRecognizer) {
        resign()
    }
    
    /* 收起键盘 */
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        let data = self.dataArray[self.dataArray.count - 1 - index] as! NSDictionary
        let heightCell = data.objectForKey("heightCell") as! CGFloat
        return heightCell
    }
    
    func commentVC(){
        if index >= 0 {
            let data = dataArray[index] as! NSDictionary
            let name = data.stringAttributeForKey("user")
            let text = keyboardView.inputKeyboard.text
            if text == "" {
                self.keyboardView.inputKeyboard.text = "@\(name) "
            } else {
                self.keyboardView.inputKeyboard.text = "\(text) @\(name) "
            }
            if self.keyboardView.inputKeyboard.isFirstResponder() {
                keyboardView.resignEmoji()
                keyboardView.labelPlaceHolder.hidden = true
                keyboardView.textViewDidChange(keyboardView.inputKeyboard)
            } else {
                self.keyboardView.inputKeyboard.becomeFirstResponder()
            }
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
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: rowSelected, inSection: 0)], withRowAnimation: .Fade)
                self.tableView.reloadData()
                self.tableView.endUpdates()
                Api.postDeleteComment(cid) { json in
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        keyboardHeight = max(keyboardSize.height, keyboardHeight)
        
        /* 移除表情界面，修改按钮样式 */
        keyboardView.resignEmoji()
        keyboardView.resizeTableView()
        keyboardView.labelPlaceHolder.hidden = true
    }
    
    override func keyboardWillBeHidden(notification: NSNotification){
        if !Locking {
            keyboardHeight = 0
            keyboardView.resizeTableView()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }else{
            return true
        }
    }
    
    /* 将数据转码 */
    func dataDecode(data: NSDictionary) -> NSDictionary {
        let mutableData = NSMutableDictionary(dictionary: data)
        var content = data.stringAttributeForKey("content").decode()
        let type = data.stringAttributeForKey("type")
        if type == "2" {
            var _content = ""
            if content == "棒棒糖" {
                _content = "我送了一个 🍭 给你！"
            } else if content == "布丁" {
                _content = "我送了一个 🍮 给你！"
            } else if content == "咖啡" {
                _content = "我送了一个 ☕️ 给你！"
            } else if content == "啤酒" {
                _content = "我送了一个 🍺 给你！"
            } else if content == "刨冰" {
                _content = "我送了一个 🍧 给你！"
            } else if content == "巧克力蛋糕" {
                _content = "我送了一个 💩 给你！"
            }
            content = _content
        }
        let h = content.stringHeightWith(15, width: 208)
        var time = data.stringAttributeForKey("lastdate")
        if time != "sending" {
            time = V.relativeTime(time)
        }
        var wImage: CGFloat = 72
        var hImage: CGFloat = 72
        var wContent: CGFloat = 0
        var heightCell: CGFloat = 0
        if type == "0" || type == "2" {
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
        mutableData.setValue(time, forKey: "lastdate")
        mutableData.setValue(heightCell, forKey: "heightCell")
        return mutableData as NSDictionary
    }
}

