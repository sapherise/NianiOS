//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, circleAddDelegate, editCircleDelegate {
    
    let identifier = "circledetailcell"
    let identifier2 = "circledetailtop"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var Id:String = "1"
    var navView:UIView!
    var topCell:CircleDetailTop!
    var circleData:NSDictionary?
    var textPercent:String = "-"
    var actionSheet:UIActionSheet?
    var actionSheetQuit:UIActionSheet?
    var actionSheetDelete: UIActionSheet?
    var actionSheetPromote: UIActionSheet?
    var actionSheetFireConfirm: UIActionSheet?
    var cancelSheet:UIActionSheet?
    var addView:ILTranslucentView!
    var addStepView:CircleJoin!
    var theTag:Int = -2
    var thePrivate:String = ""
    var theLevel:String = "0"
    var editTitle:String = ""
    var editContent:String = ""
    var editImage:String = ""
    var selectUid:Int = 0
    var selectDream:Int = 0
    var selectLevel:Int = -1
    var selectRow:Int = 0
    var selectName: String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewLoadingHide()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewBackFix()
        if globalWillCircleJoinReload == 1 {
            globalWillCircleJoinReload = 0
            self.onCircleJoinClick()
        }
    }
    
    func setupViews() {
        self.viewBack()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        self.view.backgroundColor = UIColor.blackColor()
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, globalWidth, 50))
        var nib = UINib(nibName:"CircleDetailCell", bundle: nil)
        var nib2 = UINib(nibName:"CircleDetailTop", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.tableView!)
        
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "梦境资料"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func delegateLoad() {
        load()
    }
    
    func load(clear: Bool = true){
        Api.getCircleDetail(self.Id) { json in
            if json != nil {
                self.viewLoadingHide()
                var arr = json!.objectForKey("items") as! NSArray
                var i = 0
                var cicleArray = json!.objectForKey("circle") as! NSArray
                self.circleData = cicleArray[0] as? NSDictionary
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                    var num = ((data as! NSDictionary).objectForKey("num") as! String).toInt()!
                    if num > 0 {
                        i++
                    }
                }
                if self.dataArray.count > 0 {
                    var percent = Int(ceil(Double(i) / Double(self.dataArray.count) * 100))
                    self.textPercent = "\(percent)%"
                }else{
                    self.view.showTipText("这个梦境没人在...", delay: 2)
                }
                self.tableView.headerEndRefreshing()
                self.tableView!.reloadData()
            }
        }
    }
    
    func setupRefresh() {
        tableView.addHeaderWithCallback {
            self.load()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as! CircleDetailTop
            var index = indexPath.row
            var dreamid = Id
            c.dreamid = dreamid
            if self.circleData != nil {
                self.thePrivate = self.circleData!.objectForKey("private") as! String
                var textPrivate = ""
                if self.thePrivate == "0" {
                    textPrivate = "任何人都可加入"
                }else if self.thePrivate == "1" {
                    textPrivate = "需要验证后加入"
                }
                c.labelPrivate.text = textPrivate
                c.labelTag.text = "#\(self.Id)"
                c.switchNotice.addTarget(self, action: "onSwitch:", forControlEvents: UIControlEvents.ValueChanged)
                c.numLeftNum.text = "\(self.dataArray.count)"
                c.numMiddleNum.text = self.textPercent
                self.editTitle = self.circleData!.objectForKey("title") as! String
                c.nickLabel.text = self.editTitle
                self.editImage = self.circleData!.objectForKey("img") as! String
                c.dreamhead.setImage("http://img.nian.so/dream/\(self.editImage)!dream", placeHolder: IconColor)
                c.dreamhead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCircleHeadClick:"))
                var isJoin = self.circleData!.stringAttributeForKey("isJoin")
                if isJoin == "1" {
                    c.btnMain.setTitle("邀请", forState: UIControlState.Normal)
                    c.btnMain.removeTarget(self, action: "onCircleJoinClick", forControlEvents: UIControlEvents.TouchUpInside)
                    c.btnMain.addTarget(self, action: "onCircleInviteClick", forControlEvents: UIControlEvents.TouchUpInside)
                    c.viewNotice.hidden = false
                    c.labelMember.setY(212)
                    var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "onCircleDetailMoreClick")
                    rightButton.image = UIImage(named:"more")
                    self.navigationItem.rightBarButtonItem = rightButton
                }else{
                    c.btnMain.setTitle("加入", forState: UIControlState.Normal)
                    c.btnMain.removeTarget(self, action: "onCircleInviteClick", forControlEvents: UIControlEvents.TouchUpInside)
                    c.btnMain.addTarget(self, action: "onCircleJoinClick", forControlEvents: UIControlEvents.TouchUpInside)
                }
                if self.circleData!.stringAttributeForKey("doNotDisturb") == "1" {
                    c.switchNotice.switchSetup(false, cacheName: "", isCache: false)
                }
                self.editContent = self.circleData!.objectForKey("content") as! String
                var textContent = ""
                if self.editContent == "" {
                    textContent = "暂无简介"
                }else{
                    textContent = self.editContent
                }
                c.labelDes.text = textContent
                var desHeight = textContent.stringHeightWith(12,width:200)
                c.labelDes.setHeight(desHeight)
                c.labelDes.setY( 110 - desHeight / 2 )
            } else {
                c.hidden = true
            }
            self.topCell = c
            cell = c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! CircleDetailCell
            var index = indexPath.row
            c.data = self.dataArray[index] as! NSDictionary
            c.imageUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
            if indexPath.row == 0 {
                c.viewLine.hidden = true
            }else{
                c.viewLine.hidden = false
            }
            cell = c
        }
        return cell
    }
    
    
    func onSwitch(sender: UISwitch) {
        sender.switchSetup(sender.on, cacheName: "", isCache: false)
        Api.postCircleDisturb(self.Id, isDisturb: !sender.on) { json in
        }
    }
    
    func onCircleHeadClick(sender:UIGestureRecognizer) {
        if let v = sender.view as? UIImageView {
            var yPoint = v.convertPoint(CGPointMake(0, 0), fromView: v.window!)
            var rect = CGRectMake(-yPoint.x, -yPoint.y, 60, 60)
            v.showImage("http://img.nian.so/dream/\(self.editImage)!large", rect: rect)
        }
    }
    
    func onCircleInviteClick(){
        var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        var LikeVC = LikeViewController()
        LikeVC.Id = safeuid
        LikeVC.urlIdentify = 4
        LikeVC.circleID = self.Id
        self.navigationController?.pushViewController(LikeVC, animated: true)
    }
    
    func onCircleJoinClick(){
        self.addView = ILTranslucentView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        self.addView.translucentAlpha = 1
        self.addView.translucentStyle = UIBarStyle.Default
        self.addView.translucentTintColor = UIColor.clearColor()
        self.addView.backgroundColor = UIColor.clearColor()
        self.addView.alpha = 0
        self.addView.center = CGPointMake(globalWidth/2, globalHeight/2)
        var Tap = UITapGestureRecognizer(target: self, action: "onCloseConfirm")
        Tap.delegate = self
        self.addView.addGestureRecognizer(Tap)
        
        var nib = NSBundle.mainBundle().loadNibNamed("CircleJoin", owner: self, options: nil) as NSArray
        self.addStepView = nib.objectAtIndex(0) as! CircleJoin
        self.addStepView.delegate = self
        self.addStepView.circleID = self.Id
        self.addStepView.hashTag = self.theTag + 1
        self.addStepView.thePrivate = self.thePrivate
        self.addStepView.setX(globalWidth/2-140)
        self.addStepView.setY(globalHeight/2-106)
        self.addStepView.btnCancel.addTarget(self, action: "onCloseConfirm", forControlEvents: UIControlEvents.TouchUpInside)
        self.addView.addSubview(self.addStepView)
        
        self.view.addSubview(self.addView)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.addView.alpha = 1
        })
    }
    
    func onViewCloseClick(){
        self.addStepView.textView.resignFirstResponder()
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var newTransform = CGAffineTransformScale(self.addView.transform, 1.2, 1.2)
            self.addView.transform = newTransform
            self.addView.alpha = 0
            }) { (Bool) -> Void in
                self.addView.removeFromSuperview()
        }
    }
    
    func onCloseConfirm(){
        if (self.addStepView.textView.text != "我想加入这个梦境！") && (self.addStepView.textView.text != "") {
            self.addStepView.textView.resignFirstResponder()
            self.cancelSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.cancelSheet!.addButtonWithTitle("不写了")
            self.cancelSheet!.addButtonWithTitle("继续写")
            self.cancelSheet!.cancelButtonIndex = 1
            self.cancelSheet!.showInView(self.view)
        }else{
            self.onViewCloseClick()
        }
    }
    
    func onCircleDetailMoreClick(){
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.circleData != nil {
            self.theLevel = self.circleData!.objectForKey("level") as! String
            if self.theLevel == "9" {
                self.actionSheet!.addButtonWithTitle("编辑梦境资料")
                self.actionSheet!.addButtonWithTitle("解散梦境")
                self.actionSheet!.addButtonWithTitle("取消")
                self.actionSheet!.cancelButtonIndex = 2
            }else if self.theLevel == "8" {
                self.actionSheet!.addButtonWithTitle("编辑梦境资料")
                self.actionSheet!.addButtonWithTitle("退出梦境")
                self.actionSheet!.addButtonWithTitle("取消")
                self.actionSheet!.cancelButtonIndex = 2
            }else{
                self.actionSheet!.addButtonWithTitle("退出梦境")
                self.actionSheet!.addButtonWithTitle("取消")
                self.actionSheet!.cancelButtonIndex = 1
            }
        }
        self.actionSheet!.showInView(self.view)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(DreamVC, animated: true)
    }
    
    func onUserActionClick(){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(self.selectUid)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onDreamActionClick(){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(self.selectDream)"
        self.navigationController?.pushViewController(DreamVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section==0{
            if self.circleData != nil {
                var isJoin = self.circleData!.stringAttributeForKey("isJoin")
                if isJoin == "1" {
                    return  495 + 48
                }
            }
            return 495
        }else{
            var index = indexPath.row
            var data = self.dataArray[index] as! NSDictionary
            return  CircleDetailCell.cellHeightByData(data)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        if actionSheet == self.actionSheet {
            if self.theLevel == "9" {
                if buttonIndex == 0 {
                    self.circleEdit()
                }else if buttonIndex == 1 {
                    self.circleDelete()
                }
            }else if self.theLevel == "8" {
                if buttonIndex == 0 {
                    self.circleEdit()
                }else if buttonIndex == 1 {
                    self.circleQuit()
                }
            }else{
                if buttonIndex == 0 {
                    self.circleQuit()
                }
            }
        }else if actionSheet == self.actionSheetQuit {
            if buttonIndex == 0 {
                Api.postCircleQuit(self.Id) {
                    json in
                    if json != nil {
                        self.navigationController?.popToRootViewControllerAnimated(true)
                        SQLCircleListDelete(self.Id)
                    }
                }
            }
        }else if actionSheet == self.cancelSheet {
            if buttonIndex == 0 {
                self.onViewCloseClick()
            }
        }else if actionSheet == self.actionSheetDelete {
            if buttonIndex == 0 {
                Api.postCircleDelete(self.Id) {
                    json in
                    if json != nil {
                        SQLCircleListDelete(self.Id)
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    }
                }
            }
        }else if actionSheet == self.actionSheetPromote {
            if self.theLevel == "9" {
                if self.selectLevel == 9 {
                    if buttonIndex == 0 {
                        self.onUserActionClick()
                    }else if buttonIndex == 1 {
                        self.onDreamActionClick()
                    }
                }else if self.selectLevel == 8 {
                    if buttonIndex == 0 {
                        self.onDemoClick()
                    }else if buttonIndex == 1 {
                        self.onFireConfirm()
                    }
                }else if self.selectLevel == 0 {
                    if buttonIndex == 0 {
                        self.onPromoClick()
                    }else if buttonIndex == 1 {
                        self.onFireConfirm()
                    }
                }
            }else if self.theLevel == "8" {
                if self.selectLevel == 9 || self.selectLevel == 8 {
                    if buttonIndex == 0 {
                        self.onUserActionClick()
                    }else if buttonIndex == 1 {
                        self.onDreamActionClick()
                    }
                }else if self.selectLevel == 0 {
                    if buttonIndex == 0 {
                        self.onFireConfirm()
                    }
                }
            }else if self.theLevel == "0" {
                if buttonIndex == 0 {
                    self.onUserActionClick()
                }else if buttonIndex == 1 {
                    self.onDreamActionClick()
                }
            }
        }else if actionSheet == self.actionSheetFireConfirm {
            if buttonIndex == 0 {
                self.onFireClick()
            }
        }
    }
    
    func onPromoClick(){
        self.viewLoadingShow()
        Api.postCirclePromo(self.Id, promouid: self.selectUid, promoname: self.selectName){ json in
            if json != nil {
                var success = json!.objectForKey("success") as! String
                var reason = json!.objectForKey("reason") as! String
                if success == "1" {
                    globalWillCircleChatReload = 1
                    self.load()
                }else{
                    self.viewLoadingHide()
                    if  reason == "1" {
                        self.view.showTipText("你没有提升对方的权限...", delay: 2)
                    }else if reason == "2" {
                        self.view.showTipText("对方已经是小组长了~", delay: 2)
                    }else if reason == "3" {
                        self.view.showTipText("每个梦境最多只能有两个小组长...", delay: 2)
                    }else{
                        self.view.showTipText("遇到了一个神秘的错误...", delay: 2)
                    }
                }
            }
        }
    }
    
    func onDemoClick(){
        self.viewLoadingShow()
        Api.postCircleDemo(self.Id, promouid: self.selectUid, promoname: self.selectName) { json in
            if json != nil {
                var success = json!.objectForKey("success") as! String
                var reason = json!.objectForKey("reason") as! String
                if success == "1" {
                    globalWillCircleChatReload = 1
                    self.load()
                }else{
                    self.viewLoadingHide()
                    if  reason == "1" {
                        self.view.showTipText("你没有降职对方的权限...", delay: 2)
                    }else if reason == "2" {
                        self.view.showTipText("对方已经是组员了~", delay: 2)
                    }else{
                        self.view.showTipText("遇到了一个神秘的错误...", delay: 2)
                    }
                }
            }
        }
    }
    
    func onFireConfirm(){
        self.actionSheetFireConfirm = UIActionSheet(title: "真的要移除吗？", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetFireConfirm!.addButtonWithTitle(" 嗯！")
        self.actionSheetFireConfirm!.addButtonWithTitle("取消")
        self.actionSheetFireConfirm!.cancelButtonIndex = 1
        self.actionSheetFireConfirm!.showInView(self.view)
    }
    
    func onFireClick(){
        self.viewLoadingShow()
        Api.postCircleFire(self.Id, fireuid: self.selectUid){ json in
            if json != nil {
                self.viewLoadingHide()
                var success = json!.objectForKey("success") as! String
                var reason = json!.objectForKey("reason") as! String
                if success == "1" {
                    globalWillCircleChatReload = 1
                    var newpath = NSIndexPath(forRow: self.selectRow, inSection: 1)
                    self.dataArray.removeObjectAtIndex(newpath!.row)
                    self.tableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                }else{
                    self.view.showTipText("由于千奇百怪的原因，移除失败了...", delay: 2)
                }
            }
        }
    }
    
    func circleEdit(){
        if circleData != nil {
            var vc = AddCircleController(nibName: "AddCircle", bundle: nil)
            vc.isEdit = true
            vc.idCircle = self.Id
            vc.titleCircle = self.editTitle
            vc.uploadUrl = self.editImage
            vc.content = self.editContent
            vc.isPrivate = self.thePrivate == "1"
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func circleDelete(){
        self.actionSheetDelete = UIActionSheet(title: "再见了，梦境 #\(Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetDelete!.addButtonWithTitle("解散梦境")
        self.actionSheetDelete!.addButtonWithTitle("取消")
        self.actionSheetDelete!.cancelButtonIndex = 1
        self.actionSheetDelete!.showInView(self.view)
    }
    
    func circleQuit(){
        self.actionSheetQuit = UIActionSheet(title: "再见了，梦境 #\(Id)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheetQuit!.addButtonWithTitle("退出梦境")
        self.actionSheetQuit!.addButtonWithTitle("取消")
        self.actionSheetQuit!.cancelButtonIndex = 1
        self.actionSheetQuit!.showInView(self.view)
    }
    
    func editCircle(editCircleId: String, editPrivate: Int, editTitle: String, editDes: String, editImage: String) {
        self.editTitle = editTitle
        self.editContent = editDes
        self.editImage = editImage
        self.thePrivate = "\(editPrivate)"
        self.topCell.nickLabel.text = editTitle
        if editDes == "" {
            self.topCell.labelDes.text = "暂无简介"
        }else{
            self.topCell.labelDes.text = editDes
        }
        var textPrivate = ""
        if editPrivate == 0 {
            textPrivate = "任何人都可加入"
        }else if editPrivate == 1 {
            textPrivate = "需要验证后加入"
        }
        self.topCell.labelPrivate.text = textPrivate
        self.topCell.dreamhead.setImage("http://img.nian.so/dream/\(editImage)!dream", placeHolder: IconColor)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var section = indexPath.section
        if section==1 {
            self.actionSheetPromote = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            
            var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
            var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//            var safeshell = uidKey.objectForKey(kSecValueData) as! String
            
            var data = self.dataArray[indexPath.row] as! NSDictionary
            var level = data.objectForKey("level") as! String
            var uid = data.objectForKey("uid") as! String
            var dream = data.objectForKey("dream") as! String
            var name = data.stringAttributeForKey("name")
            
            self.selectUid = uid.toInt()!
            self.selectName = name
            self.selectDream = dream.toInt()!
            self.selectLevel = level.toInt()!
            self.selectRow = indexPath.row
            
            if self.circleData != nil {
                self.theLevel = self.circleData!.objectForKey("level") as! String
                if self.theLevel == "" {
                    self.theLevel = "0"
                }
                
                if self.theLevel == "9" {
                    if level == "9" {
                        self.actionSheetPromote!.addButtonWithTitle("看看自己")
                        self.actionSheetPromote!.addButtonWithTitle("看看记本")
                    }else if level == "8" {
                        self.actionSheetPromote!.addButtonWithTitle("降职为成员")
                        self.actionSheetPromote!.addButtonWithTitle("移出梦境")
                    }else if level == "0" {
                        self.actionSheetPromote!.addButtonWithTitle("升为小组长")
                        self.actionSheetPromote!.addButtonWithTitle("移出梦境")
                    }
                    self.actionSheetPromote!.addButtonWithTitle("取消")
                    self.actionSheetPromote!.cancelButtonIndex = 2
                }else if self.theLevel == "8" {
                    if level == "9" || level == "8" {
                        if safeuid == uid {
                            self.actionSheetPromote!.addButtonWithTitle("看看自己")
                        }else{
                            self.actionSheetPromote!.addButtonWithTitle("看看对方")
                        }
                        self.actionSheetPromote!.addButtonWithTitle("看看记本")
                        self.actionSheetPromote!.addButtonWithTitle("取消")
                        self.actionSheetPromote!.cancelButtonIndex = 2
                    }else if level == "0" {
                        self.actionSheetPromote!.addButtonWithTitle("移出梦境")
                        self.actionSheetPromote!.addButtonWithTitle("取消")
                        self.actionSheetPromote!.cancelButtonIndex = 1
                    }
                }else if self.theLevel == "0" {
                    if safeuid == uid {
                        self.actionSheetPromote!.addButtonWithTitle("看看自己")
                    }else{
                        self.actionSheetPromote!.addButtonWithTitle("看看对方")
                    }
                    self.actionSheetPromote!.addButtonWithTitle("看看记本")
                    self.actionSheetPromote!.addButtonWithTitle("取消")
                    self.actionSheetPromote!.cancelButtonIndex = 2
                }
            }
            self.actionSheetPromote!.showInView(self.view)
        }
    }
    
    func addDream(tag:Int){
        self.onViewCloseClick()
        globalWillCircleJoinReload = 1
        var adddreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        self.navigationController?.pushViewController(adddreamVC, animated: true)
    }
    
    // 提交验证之后修改按钮的文本
    func changeBtnMainText(content:String) {
        self.topCell.btnMain.setTitle(content, forState: UIControlState.allZeros)
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }
        if otherGestureRecognizer.view?.frame.width == 280 {
            return false
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        var v = NSStringFromClass(touch.view.classForCoder)
        if v == "UITableViewCellContentView" {
            if touch.view.frame.size.width == 278 {
                return false
            }
        }else if v == "UITextView" {
            return false
        }
        return true
    }
    
}

