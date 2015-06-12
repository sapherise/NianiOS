//
//  NewCircle.swift
//  Nian iOS
//
//  Created by Sa on 15/5/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class NewCircleController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, delegateSAStepCell, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var navView: UIView!
    var tableViewStep: UITableView!
    var tableViewBBS: UITableView!
    var tableViewChat: UITableView!
    var scrollView: UIScrollView!
    var current: Int = 0
    var viewMenu: SAMenu!
    var dataArrayStep = NSMutableArray()
    var dataArrayBBS = NSMutableArray()
    var dataArrayChat = NSMutableArray()
    var pageStep = 1
    var pageBBS = 1
    var pageChat = 0
    var id: String = "0"
    var isAnimating: Bool = false
    var totalChat: Int = 0
    var keyboardView: SABottom!
    var inputKeyboard: UITextField!
    var actionSheetPhoto: UIActionSheet!
    var keyboardHeight: CGFloat = 0
    var imagePicker: UIImagePickerController?
    var textTitle: String = ""
    
    override func viewDidLoad() {
        setupViews()
        setupRefresh()
        switchTab(current)
        self.refresh()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "Poll:", name: "Poll", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        viewBackFix()
    }
    
    override func viewWillDisappear(animated: Bool) {
        keyboardEndObserve()
    }
    
    override func viewWillAppear(animated: Bool) {
        keyboardStartObserve()
        if let idCurrent = id.toInt() {
            globalCurrentCircle = idCurrent
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        globalCurrentCircle = 0
    }
    
    
    func Poll(noti: NSNotification) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var data = noti.object as! NSDictionary
            var circle = data.stringAttributeForKey("to")
            if circle == self.id {
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
                var commentReplyRow = self.dataArrayChat.count
                var absoluteTime = V.absoluteTime(time)
                if (safeuid != uid) || (type != "1" && type != "2") {     // 如果是朋友们发的
                    var newinsert = NSDictionary(objects: [content, "\(commentReplyRow)" , absoluteTime, uid, name,"\(type)", title, cid], forKeys: ["content", "id", "lastdate", "uid", "user","type","title","cid"])
                    self.dataArrayChat.insertObject(newinsert, atIndex: 0)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableViewChat.reloadData()
                        var offset = self.tableViewChat.contentSize.height - self.tableViewChat.bounds.size.height
                        if offset > 0 && offset - self.tableViewChat.contentOffset.y < globalHeight * 0.5 {
                            self.tableViewChat.setContentOffset(CGPointMake(0, offset), animated: true)
                        }
                    })
                }
            }
        })
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        scrollView = UIScrollView(frame: CGRectMake(0, 104, globalWidth, globalHeight - 104))
        scrollView.contentSize.width = globalWidth * 3
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        tableViewStep = UITableView()
        tableViewBBS = UITableView()
        tableViewChat = UITableView()
        tableViewStep.delegate = self
        tableViewStep.dataSource = self
        tableViewBBS.delegate = self
        tableViewBBS.dataSource = self
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        
        scrollView.addSubview(tableViewStep)
        scrollView.addSubview(tableViewBBS)
        scrollView.addSubview(tableViewChat)
        tableViewStep.frame = CGRectMake(0, 0, globalWidth, globalHeight - 104)
        tableViewBBS.frame = CGRectMake(globalWidth, 0, globalWidth, globalHeight - 104)
        tableViewChat.frame = CGRectMake(globalWidth * 2, 0, globalWidth, globalHeight - 104 - 44)
        tableViewStep.backgroundColor = UIColor.whiteColor()
        tableViewBBS.backgroundColor = UIColor.whiteColor()
        tableViewChat.backgroundColor = UIColor.whiteColor()
        
        tableViewStep.separatorStyle = .None
        tableViewBBS.separatorStyle = .None
        tableViewChat.separatorStyle = .None
        
        var nib = UINib(nibName:"GroupCell", bundle: nil)
        
        tableViewStep.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        tableViewBBS.registerNib(UINib(nibName:"GroupCell", bundle: nil), forCellReuseIdentifier: "GroupCell")
        
        self.tableViewChat.registerNib(UINib(nibName:"CircleBubbleCell", bundle: nil), forCellReuseIdentifier: "CircleBubbleCell")
        self.tableViewChat.registerNib(UINib(nibName:"CircleImageCell", bundle: nil), forCellReuseIdentifier: "CircleImageCell")
        self.tableViewChat.registerNib(UINib(nibName:"CircleType", bundle: nil), forCellReuseIdentifier: "CircleType")
        
        
        viewMenu = (NSBundle.mainBundle().loadNibNamed("SAMenu", owner: self, options: nil) as NSArray).objectAtIndex(0) as! SAMenu
        viewMenu.frame.origin.y = 64
        viewMenu.arr = ["进展", "话题", "聊天"]
        viewMenu.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        viewMenu.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        viewMenu.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        self.view.addSubview(viewMenu)
        
        
        var pan = UIPanGestureRecognizer(target: self, action: "onCellPan:")
        pan.delegate = self
        self.tableViewChat.addGestureRecognizer(pan)
        self.tableViewChat.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCellTap:"))
        self.tableViewChat.tableFooterView = UIView(frame: CGRectMake(0, 0, globalWidth, 20))
        
        // 输入框
        self.keyboardView = (NSBundle.mainBundle().loadNibNamed("SABottom", owner: self, options: nil) as NSArray).objectAtIndex(0) as! SABottom
        self.keyboardView.pointX = globalWidth * 2
        self.keyboardView.pointY = globalHeight - 44 - 104
        
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
        scrollView.addSubview(self.keyboardView)
        self.inputKeyboard.returnKeyType = UIReturnKeyType.Send
        
        //  发布新话题
        var viewAddBBS = (NSBundle.mainBundle().loadNibNamed("SABottom", owner: self, options: nil) as NSArray).objectAtIndex(0) as! SABottom
        viewAddBBS.pointX = globalWidth
        viewAddBBS.pointY = globalHeight - 44 - 104
        viewAddBBS.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onAddBBSClick"))
        var imageBBS = UIImageView(frame: CGRectMake(globalWidth/2 - 22, 0, 44, 44))
        imageBBS.image = UIImage(named: "newtopic")
        imageBBS.contentMode = UIViewContentMode.Center
        viewAddBBS.addSubview(imageBBS)
        scrollView.addSubview(viewAddBBS)
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.textTitle
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "onCircleDetailClick")
        rightButton.image = UIImage(named:"newList")
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func onAddBBSClick() {
        var vc = AddBBSController(nibName: "AddBBSController", bundle: nil)
        vc.circle = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewStep {
            return dataArrayStep.count
        } else if tableView == tableViewBBS {
            return dataArrayBBS.count
        } else {
            return dataArrayChat.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tableViewStep {
            var data = dataArrayStep[indexPath.row] as! NSDictionary
            return SAStepCell.cellHeightByData(data)
        } else if tableView == tableViewBBS {
            var data = dataArrayBBS[indexPath.row] as! NSDictionary
            return  GroupCell.cellHeightByData(data)
        } else {
            var data = self.dataArrayChat[self.dataArrayChat.count - 1 - indexPath.row] as! NSDictionary
            var type = data.stringAttributeForKey("type")
            if type == "2" {
                return CircleImageCell.cellHeightByData(data)
            } else {
                return CircleBubbleCell.cellHeightByData(data)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == tableViewStep {
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArrayStep.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        } else if tableView == tableViewBBS {
            var c = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath) as! GroupCell
            var data = self.dataArrayBBS[indexPath.row] as! NSDictionary
            c.data = data
            if indexPath.row == self.dataArrayBBS.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        } else {
            var data = self.dataArrayChat[dataArrayChat.count - 1 - indexPath.row] as! NSDictionary
            var type = data.stringAttributeForKey("type")
            var cid = data.stringAttributeForKey("cid")
            // 1: 文字消息，2: 图片消息，3: 进展更新，4: 成就通告，5: 用户加入，6: 管理员操作，7: 邀请用户
            if type == "1" {
                var c = tableView.dequeueReusableCellWithIdentifier("CircleBubbleCell", forIndexPath: indexPath) as! CircleBubbleCell
                c.data = data
                c.textContent.tag = indexPath.row
                c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c.textContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onBubbleClick:"))
                c.View.tag = indexPath.row
                c.isDream = 0
                return c
            }else if type == "2" {
                var c = tableView.dequeueReusableCellWithIdentifier("CircleImageCell", forIndexPath: indexPath) as! CircleImageCell
                c.data = data
                c.imageContent.tag = indexPath.row
                c.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
                c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c.View.tag = indexPath.row
                return c
            } else {
                var c = tableView.dequeueReusableCellWithIdentifier("CircleType", forIndexPath: indexPath) as! CircleTypeCell
                c.data = data
                return c
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == tableViewStep {
            var data = dataArrayStep[indexPath.row] as! NSDictionary
            var dream = data.stringAttributeForKey("dream")
            SADream(dream)
        } else if tableView == tableViewBBS {
            var data = self.dataArrayBBS[indexPath.row] as! NSDictionary
            var BBSVC = BBSViewController()
            BBSVC.Id = data.stringAttributeForKey("id")
            BBSVC.topcontent = data.stringAttributeForKey("content")
            BBSVC.topuid = data.stringAttributeForKey("uid")
            BBSVC.topuser = data.stringAttributeForKey("user")
            BBSVC.toplastdate = data.stringAttributeForKey("lastdate")
            BBSVC.toptitle = data.stringAttributeForKey("title")
            self.navigationController!.pushViewController(BBSVC, animated: true)
        }
    }
    
    func loadStep(clear: Bool = true) {
        if clear {
            pageStep = 1
        }
        Api.getCircleStep(id, page: pageStep) { json in
            if json != nil {
                var datajson = json!["data"]
                var steps = datajson!!["steps"] as! NSArray
                if clear {
                    self.dataArrayStep.removeAllObjects()
                }
                for data in steps {
                    self.dataArrayStep.addObject(data)
                }
                self.tableViewStep.reloadData()
                self.tableViewStep.headerEndRefreshing()
                self.tableViewStep.footerEndRefreshing()
                self.pageStep++
            }
        }
    }
    
    func loadBBS(clear: Bool = true) {
        if clear {
            pageBBS = 1
        }
        Api.getBBS(id, page: pageBBS) { json in
            if json != nil {
                var data = json!["data"]
                var arr = data!!["bbs"] as! NSArray
                if clear {
                    self.dataArrayBBS.removeAllObjects()
                }
                for data in arr {
                    self.dataArrayBBS.addObject(data)
                }
                self.tableViewBBS.reloadData()
                self.tableViewBBS.headerEndRefreshing()
                self.tableViewBBS.footerEndRefreshing()
                self.pageBBS++
            }
        }
    }
    
    func loadChat(clear: Bool = true) {
        if clear {
            pageChat = 0
            totalChat = 0
            dataArrayChat.removeAllObjects()
        }
        var safeuid = SAUid()
        var (resultSet, err) = SD.executeQuery("SELECT * FROM circle where circle ='\(id)' and owner = '\(safeuid)' and type != 3 order by id desc limit \(pageChat*30),30")
        if err == nil {
            self.pageChat++
            var title: String?
            for row in resultSet {
                var id = row["id"]?.asString()
                var uid = row["uid"]?.asString()
                var user = row["name"]?.asString()
                var cid = row["cid"]?.asString()
                var cname = row["cname"]?.asString()
                var content = row["content"]?.asString()
                var type = row["type"]?.asString()
                var lastdate = row["lastdate"]?.asString()
                var time = V.relativeTime(lastdate!)
                var title = row["title"]?.asString()
                var data = NSDictionary(objects: [id!, uid!, user!, cid!, cname!, content!, type!, time, title!], forKeys: ["id", "uid", "user", "cid", "cname", "content", "type", "lastdate", "title"])
                self.dataArrayChat.addObject(data)
                self.totalChat++
            }
            var heightBefore = self.tableViewChat.contentSize.height
            self.tableViewChat.reloadData()
            var heightAfter = self.tableViewChat.contentSize.height
            if clear {
                var offset = self.tableViewChat.contentSize.height - self.tableViewChat.bounds.size.height
                if offset > 0 {
                    self.tableViewChat.setContentOffset(CGPointMake(0, offset), animated: false)
                }
            }else{
                var heightChange = heightAfter > heightBefore ? heightAfter - heightBefore : 0
                self.tableViewChat.contentOffset = CGPointMake(0, heightChange)
            }
            isAnimating = false
        }
    }
    
    //  设置更新
    func setupRefresh() {
        tableViewStep.addHeaderWithCallback {
            self.loadStep()
        }
        tableViewStep.addFooterWithCallback {
            self.loadStep(clear: false)
        }
        tableViewBBS.addHeaderWithCallback {
            self.loadBBS()
        }
        tableViewBBS.addFooterWithCallback {
            self.loadBBS(clear: false)
        }
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArrayStep, index, key, value, self.tableViewStep)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 0, self.tableViewStep)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableViewStep)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArrayStep, index, self.tableViewStep, 0)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func onMenuClick(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            if current == tag {
                refresh()
            }
            switchTab(tag)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var x = scrollView.contentOffset.x
            var page = Int(x / globalWidth)
            switchTab(page)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.tableViewChat {
            if totalChat == 30 * pageChat {
                var y = scrollView.contentOffset.y
                if y < 40 {
                    if isAnimating == false {
                        isAnimating = true
                        self.loadChat(clear: false)
                    }
                }
            }
        }
    }
    
    func switchTab(tab: Int) {
        inputKeyboard.resignFirstResponder()
        current = tab
        viewMenu.switchTab(tab)
        scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(tab), 0), animated: true)
        switch tab {
        case 0:
            if dataArrayStep.count == 0 {
                tableViewStep.headerBeginRefreshing()
            }
            break
        case 1:
            if dataArrayBBS.count == 0 {
                tableViewBBS.headerBeginRefreshing()
            }
            break
        case 2:
            if dataArrayChat.count == 0 {
                loadChat()
            }
            break
        default:
            break
        }
    }
    
    // 刷新当前表格
    func refresh() {
        switch current {
        case 0:
            tableViewStep.headerBeginRefreshing()
            break
        case 1:
            tableViewBBS.headerBeginRefreshing()
            break
        case 2:
            tableViewChat.headerBeginRefreshing()
            break
        default:
            break
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
        circledetailVC.Id = id
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
            var commentReplyRow = self.dataArrayChat.count
            var data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArrayChat.insertObject(data, atIndex: 0)
            self.tableViewChat.reloadData()
            var offset = self.tableViewChat.contentSize.height - self.tableViewChat.bounds.size.height
            if offset > 0 {
                self.tableViewChat.setContentOffset(CGPointMake(0, offset), animated: true)
            }
        })
    }
    
    func postWord(replyContent: String, type: Int = 1) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeuser = Sa.objectForKey("user") as! String
            var commentReplyRow = self.dataArrayChat.count
            var data = NSDictionary(objects: [replyContent, "\(commentReplyRow)" , "sending", "\(safeuid)", "\(safeuser)","\(type)"], forKeys: ["content", "id", "lastdate", "uid", "user","type"])
            self.dataArrayChat.insertObject(data, atIndex: 0)
            
            var offset = self.tableViewChat.contentSize.height - self.tableViewChat.bounds.size.height + replyContent.stringHeightWith(15,width:208) + 60
            if offset > 0 {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.tableViewChat.contentOffset.y = offset
                })
            }
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                self.addReply(replyContent, type: 1)
            })
            self.tableViewChat.beginUpdates()
            self.tableViewChat.insertRowsAtIndexPaths([NSIndexPath(forRow: self.dataArrayChat.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Right)
            self.tableViewChat.endUpdates()
            CATransaction.commit()
        })
    }
    
    func tableUpdate(contentAfter: String) {
        for var i: Int = 0; i < self.dataArrayChat.count; i++ {
            var data = self.dataArrayChat[i] as! NSDictionary
            var contentBefore = data.stringAttributeForKey("content")
            var lastdate = data.stringAttributeForKey("lastdate")
            var type = data.stringAttributeForKey("type")
            if (contentAfter == contentBefore || type == "2") && lastdate == "sending" {
                var lastdate = V.absoluteTime(NSDate().timeIntervalSince1970)
                var mutableItem = NSMutableDictionary(dictionary: data)
                mutableItem.setObject(lastdate, forKey: "lastdate")
                mutableItem.setObject(contentAfter, forKey: "content")
                self.dataArrayChat.replaceObjectAtIndex(i, withObject: mutableItem)
                var row = self.dataArrayChat.count - 1 - i
                if row > 0 {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableViewChat.reloadRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    })
                }
                break
            }
        }
    }
    
    //将内容发送至服务器
    func addReply(contentAfter:String, type:Int = 1){
        var content = SAEncode(contentAfter)
            Api.postCircleChat(id.toInt()!, content: content, type: type) { json in
                if json != nil {
                    var success = json!["success"] as? String
                    if success == "1" {
                        self.tableUpdate(contentAfter)
                    }
                }
            }
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
        var data = self.dataArrayChat[dataArrayChat.count - 1 - index] as! NSDictionary
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
//        var index = sender.view!.tag
//        var data = self.dataArrayChat[self.dataArrayChat.count - 1 - index] as! NSDictionary
//        var user = data.stringAttributeForKey("user")
//        var uid = data.stringAttributeForKey("uid")
//        var content = data.stringAttributeForKey("content")
//        var cid = data.stringAttributeForKey("cid")
//        var type = data.stringAttributeForKey("type")
//        self.ReplyRow = self.dataArrayChat.count - 1 - index
//        self.ReplyContent = content
//        self.ReplyCid = cid
//        self.ReplyUserName = user
//        self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
//        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
//        var safeuid = Sa.objectForKey("uid") as! String
//        if type == "3" {
//            var StepVC = SingleStepViewController()
//            StepVC.Id = cid
//            self.navigationController?.pushViewController(StepVC, animated: true)
//        }else{
//            self.replySheet!.addButtonWithTitle("回应@\(user)")
//            self.replySheet!.addButtonWithTitle("复制")
//            self.replySheet!.addButtonWithTitle("取消")
//            self.replySheet!.cancelButtonIndex = 2
//            self.replySheet!.showInView(self.view)
//        }
    }
    
    
    func commentVC(){
        //这里是回应别人
//        self.inputKeyboard.text = "@\(self.ReplyUserName) "
//        delay(0.3, {
//            self.inputKeyboard.becomeFirstResponder()
//            return
//        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
//        if actionSheet == self.replySheet {
//            if buttonIndex == 0 {
//                self.commentVC()
//            }else if buttonIndex == 1 { //复制
//                var pasteBoard = UIPasteboard.generalPasteboard()
//                pasteBoard.string = self.ReplyContent
//            }
//        }else
            if actionSheet == self.actionSheetPhoto {
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
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        var keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size)!
        self.keyboardHeight = keyboardSize.height
        self.keyboardView.pointY = globalHeight - self.keyboardHeight - 44 - 104
        self.keyboardView.layoutSubviews()
        var heightScroll = globalHeight - 44 - 104 - self.keyboardHeight
        var contentOffsetTableView = self.tableViewChat.contentSize.height >= heightScroll ? self.tableViewChat.contentSize.height - heightScroll : 0
        self.tableViewChat.setHeight( heightScroll )
        self.tableViewChat.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        var heightScroll = globalHeight - 44 - 104
        var contentOffsetTableView = self.tableViewChat.contentSize.height >= heightScroll ? self.tableViewChat.contentSize.height - heightScroll : 0
        self.keyboardView.pointY = globalHeight - 44 - 104
        self.keyboardView.layoutSubviews()
        self.tableViewChat.setHeight(heightScroll)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }
}