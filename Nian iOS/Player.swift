//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class PlayerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, AddstepDelegate, delegateSAStepCell{
    
    var tableViewDream: UITableView!
    var tableViewStep: UITableView!
    var dataArray = NSMutableArray()
    var dataArrayStep = NSMutableArray()
    var page: Int = 0
    var pageStep: Int = 0
    var Id:String = "0"
    var deleteSheet:UIActionSheet?
    var ownerMoreSheet:UIActionSheet?
    var guestMoreSheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteDreamSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    var dreamowner:Int = 0 //如果是0，就不是主人，是1就是主人
    var userMoreSheet:UIActionSheet!
    
    var ReplyUser:String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReturnReplyRow:Int = 0
    var ReplyCid:String = ""
    var activityViewController:UIActivityViewController?
    
    var percentJson: String = ""
    var followJson: String = ""
    var likeJson: String = ""
    var imgJson: String = ""
    var privateJson: String = ""
    var contentJson: String = ""
    var owneruid: String = ""
    var likestepJson: String = ""
    var liketotalJson: Int = 0
    var stepJson: String = ""
    var desJson:String = ""
    
    var topCell:PlayerCellTop!
    var navView: UIImageView!
    var isBan: Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SALoadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ShareContent", object:nil)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ShareContent:", name: "ShareContent", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func ShareContent(noti:NSNotification){
        var content:AnyObject = noti.object!
        var sid:Int = content[2] as! Int
        var row:Int = (content[3] as! Int)-10
        var url:NSURL = NSURL(string: "http://nian.so/m/step/\(sid)")!
        
        var customActivity = SAActivity()
        customActivity.saActivityTitle = "举报"
        customActivity.saActivityImage = UIImage(named: "flag")!
        customActivity.saActivityFunction = {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var safeshell = Sa.objectForKey("shell") as! String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)", "http://nian.so/api/a.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        UIView.showAlertView("谢谢", message: "如果这个进展不合适，我们会将其移除。")
                    })
                }
            })
        }
        //编辑按钮
        var editActivity = SAActivity()
        editActivity.saActivityTitle = "编辑"
        editActivity.saActivityType = "编辑"
        editActivity.saActivityImage = UIImage(named: "edit")!
        editActivity.saActivityFunction = {
            var data = self.dataArrayStep[row] as! NSDictionary
            var addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
            addstepVC.isEdit = 1
            addstepVC.data = data
            addstepVC.row = row
            addstepVC.delegate = self
            self.navigationController!.pushViewController(addstepVC, animated: true)
        }
        //删除按钮
        var deleteActivity = SAActivity()
        deleteActivity.saActivityTitle = "删除"
        deleteActivity.saActivityType = "删除"
        deleteActivity.saActivityImage = UIImage(named: "goodbye")!
        deleteActivity.saActivityFunction = {
            self.deleteId = sid
            self.deleteViewId = row
            self.deleteSheet = UIActionSheet(title: "再见了，进展 #\(sid)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            self.deleteSheet!.addButtonWithTitle("确定")
            self.deleteSheet!.addButtonWithTitle("取消")
            self.deleteSheet!.cancelButtonIndex = 1
            self.deleteSheet!.showInView(self.view)
        }

        var ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), customActivity ]
        
        if self.dreamowner == 1 {
            ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), deleteActivity, editActivity]
        }
        var arr = [content[0], url]
        var image = getCacheImage("\(content[1])")
        if image != nil {
            arr.append(image!)
        }
        self.activityViewController = UIActivityViewController(
            activityItems: arr,
            applicationActivities: ActivityArray)
        self.activityViewController?.excludedActivityTypes = [
            UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
        ]
        self.presentViewController(self.activityViewController!, animated: true, completion: nil)
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid:String = Sa.objectForKey("uid") as! String
        if self.Id != safeuid {
            var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "userMore")
            moreButton.image = UIImage(named:"more")
            self.navigationItem.rightBarButtonItems = [ moreButton ]
            self.dreamowner = 0
        }else{
            self.dreamowner = 1
        }
        self.navView = UIImageView(frame: CGRectMake(0, -64, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.navView.hidden = true
        self.navView.clipsToBounds = true
        self.view.addSubview(self.navView)
        self.topCell = (NSBundle.mainBundle().loadNibNamed("PlayerCellTop", owner: self, options: nil) as NSArray).objectAtIndex(0) as! PlayerCellTop
        self.topCell.frame = CGRectMake(0, -64, globalWidth, 364)
        self.setupPlayerTop(self.Id.toInt()!)
        var nib3 = UINib(nibName:"StepCell", bundle: nil)
        self.tableViewDream = UITableView(frame:CGRectMake(0, -64, globalWidth,globalHeight))
        self.tableViewDream.delegate = self
        self.tableViewDream.dataSource = self
        self.tableViewDream.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableViewDream.registerNib(nib3, forCellReuseIdentifier: "step")
        self.tableViewDream.showsVerticalScrollIndicator = false
        self.tableViewStep = UITableView(frame:CGRectMake(0, -64, globalWidth,globalHeight))
        self.tableViewStep.delegate = self
        self.tableViewStep.dataSource = self
        self.tableViewStep.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableViewStep.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        self.tableViewStep.showsVerticalScrollIndicator = false
        self.tableViewStep.hidden = true
        
        self.topCell.labelMenuLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        self.topCell.labelMenuRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        self.view.addSubview(self.tableViewStep)
        self.view.addSubview(self.tableViewDream)
        self.view.addSubview(self.topCell)
    }
    
    func userMore(){
        self.userMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.isBan == 0 {
            self.userMoreSheet.addButtonWithTitle("拖进小黑屋")
        }else{
            self.userMoreSheet.addButtonWithTitle("取消小黑屋")
        }
        self.userMoreSheet.addButtonWithTitle("取消")
        self.userMoreSheet.cancelButtonIndex = 1
        self.userMoreSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.deleteSheet {
            if buttonIndex == 0 {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                var newpath = NSIndexPath(forRow: self.deleteViewId, inSection: 1)
                self.dataArrayStep.removeObjectAtIndex(newpath!.row)
                self.tableViewStep.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableViewStep.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
                    if(sa == "1"){
                    }
                })
            }
        }else if actionSheet == self.userMoreSheet {
            if buttonIndex == 0 {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                if self.isBan == 0 {    // 拖进小黑屋
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/ban.php")
                        if sa == "1" {
                            dispatch_async(dispatch_get_main_queue(), {
                                UIView.showAlertView("再见啦", message: "成功拖进小黑屋")
                                self.isBan = 1
                            })
                        }
                    })
                }else{      // 取消小黑屋
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                        var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)&&noban=1", "http://nian.so/api/ban.php")
                        if sa == "1" {
                            dispatch_async(dispatch_get_main_queue(), {
                                UIView.showAlertView("和好了", message: "成功取消小黑屋")
                                self.isBan = 0
                            })
                        }
                    })
                }
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var height = scrollView.contentOffset.y
        if scrollView == self.tableViewDream || scrollView == self.tableViewStep {
            self.scrollLayout(height)
        }
    }
    
    func scrollLayout(height:CGFloat){
        if height > 0 {
            self.topCell.setY(-height-64)
            self.topCell.BGImage.setY(height/2)
        }else{
            self.topCell.setY(-64)
            self.topCell.BGImage.frame = CGRectMake(height/10, height/10, globalWidth-height/5, 320-height/5)
        }
        scrollHidden(self.topCell.viewHolderHead, height: height, scrollY: 68)
        scrollHidden(self.topCell.imageBadge, height: height, scrollY: 68)
        scrollHidden(self.topCell.UserName, height: height, scrollY: 138)
        scrollHidden(self.topCell.imageSex, height: height, scrollY: 138)
        scrollHidden(self.topCell.UserFo, height: height, scrollY: 161)
        scrollHidden(self.topCell.UserFoed, height: height, scrollY: 161)
        scrollHidden(self.topCell.btnMain, height: height, scrollY: 214)
        scrollHidden(self.topCell.btnLetter, height: height, scrollY: 214)
        if height >= 320 - 64 {
            self.navView.hidden = false
            self.view.bringSubviewToFront(self.navView)
        }else{
            self.navView.hidden = true
        }
    }
    
    func scrollHidden(theView:UIView, height:CGFloat, scrollY:CGFloat){
        if ( height > scrollY - 50 && height <= scrollY ) {
            theView.alpha = ( scrollY - height ) / 50
        }else if height > scrollY {
            theView.alpha = 0
        }else{
            theView.alpha = 1
        }
    }
    
    func ownerMore(){
        self.ownerMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.ownerMoreSheet!.addButtonWithTitle("编辑记本")
        if self.percentJson == "1" {
            self.ownerMoreSheet!.addButtonWithTitle("还未完成记本")
        }else if self.percentJson == "0" {
            self.ownerMoreSheet!.addButtonWithTitle("完成记本")
        }
        self.ownerMoreSheet!.addButtonWithTitle("分享记本")
        self.ownerMoreSheet!.addButtonWithTitle("删除记本")
        self.ownerMoreSheet!.addButtonWithTitle("取消")
        self.ownerMoreSheet!.cancelButtonIndex = 4
        self.ownerMoreSheet!.showInView(self.view)
    }
    
    func guestMore(){
        self.guestMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.followJson == "1" {
            self.guestMoreSheet!.addButtonWithTitle("取消关注记本")
        }else if self.followJson == "0" {
            self.guestMoreSheet!.addButtonWithTitle("关注记本")
        }
        if self.likeJson == "1" {
            self.guestMoreSheet!.addButtonWithTitle("取消赞")
        }else if self.likeJson == "0" {
            self.guestMoreSheet!.addButtonWithTitle("赞记本")
        }
        self.guestMoreSheet!.addButtonWithTitle("分享记本")
        self.guestMoreSheet!.addButtonWithTitle("标记为不合适")
        self.guestMoreSheet!.addButtonWithTitle("取消")
        self.guestMoreSheet!.cancelButtonIndex = 4
        self.guestMoreSheet!.showInView(self.view)
    }
    
    func SALoadData(isClear: Bool = true) {
        if isClear {
            self.tableViewDream.setFooterHidden(false)
            self.page = 0
            var v = UIView(frame: CGRectMake(0, 0, globalWidth, 70))
            var activity = UIActivityIndicatorView()
            activity.color = SeaColor
            activity.startAnimating()
            activity.hidden = false
            v.addSubview(activity)
            activity.center = v.center
            self.tableViewDream.tableFooterView = v
        }
        Api.getUserDream(Id, page: page) { json in
            if json != nil {
                self.tableViewDream.tableFooterView = UIView()
                var arr = json!["items"] as! NSArray
                if isClear {
                    self.dataArray.removeAllObjects()
                }
                for data: AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                self.tableViewDream.reloadData()
                self.tableViewStep.footerEndRefreshing()
                self.page++
                if let total = json!["total"] as? Int {
                    if total < 30 {
                        self.tableViewDream.setFooterHidden(true)
                    }
                }
            }
        }
    }
    
    func SALoadDataStep(isClear: Bool = true) {
        if isClear {
            self.tableViewStep.setFooterHidden(false)
            self.pageStep = 0
            var v = UIView(frame: CGRectMake(0, 0, globalWidth, 70))
            var activity = UIActivityIndicatorView()
            activity.color = SeaColor
            activity.startAnimating()
            activity.hidden = false
            v.addSubview(activity)
            activity.center = v.center
            self.tableViewStep.tableFooterView = v
        }
        Api.getUserActive(Id, page: self.pageStep) { json in
            if json != nil {
                self.tableViewStep.tableFooterView = UIView()
                var arr = json!["items"] as! NSArray
                if isClear {
                    self.dataArrayStep.removeAllObjects()
                }
                for data: AnyObject in arr {
                    self.dataArrayStep.addObject(data)
                }
                self.tableViewStep.reloadData()
                self.tableViewStep.footerEndRefreshing()
                self.pageStep++
                if let total = json!["total"] as? Int {
                    if total < 30 {
                        self.tableViewStep.setFooterHidden(true)
                    }
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section == 0 {
            var c = UITableViewCell()
            c.hidden = true
            c.selectionStyle = .None
            return c
        }else{
            if tableView == self.tableViewDream {
                var c = tableView.dequeueReusableCellWithIdentifier("step", forIndexPath: indexPath) as? StepCell
                var dictionary:Dictionary<String, String> = ["id":"", "title":"", "img":"", "percent":""]
                var index = indexPath.row * 3
                if index<self.dataArray.count {
                    c!.data1 = self.dataArray[index] as! NSDictionary
                    c!.img1?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data1 = dictionary
                }
                if index+1<self.dataArray.count {
                    c!.data2 = self.dataArray[index + 1] as! NSDictionary
                    c!.img2?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data2 = dictionary
                }
                if index+2<self.dataArray.count {
                    c!.data3 = self.dataArray[index + 2] as! NSDictionary
                    c!.img3?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data3 = dictionary
                }
                cell = c!
            }else{
                var c = tableViewStep.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
                c.delegate = self
                c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
                c.index = indexPath.row
                if indexPath.row == self.dataArrayStep.count - 1 {
                    c.viewLine.hidden = true
                } else {
                    c.viewLine.hidden = false
                }
                return c
            }
        }
        return cell
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArrayStep, index, key, value, self.tableViewStep)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 1, self.tableViewStep)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableViewStep)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArrayStep, index, self.tableViewStep, 1)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if tableView == self.tableViewDream {
                return 364 + 30
            }else{
                return 364
            }
        }else{
            if tableView == self.tableViewDream {
                return  129
            }else{
                var data = self.dataArrayStep[indexPath.row] as! NSDictionary
                var h = SAStepCell.cellHeightByData(data)
                return h
            }
        }
    }
    
    func setupRefresh(){
        self.tableViewDream.addFooterWithCallback({
            self.SALoadData(isClear: false)
        })
        self.tableViewStep.addFooterWithCallback({
            self.SALoadDataStep(isClear: false)
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            if tableView == self.tableViewDream {
                return Int(ceil(Double(self.dataArray.count)/3))
            }else{
                return self.dataArrayStep.count
            }
        }
    }
    
    func setupPlayerTop(theUid:Int){
        Api.getUserTop(theUid){ json in
            if json != nil {
                var data = json!["user"] as! NSDictionary
                var name = data.stringAttributeForKey("name")
                var fo = data.stringAttributeForKey("fo")
                var foed = data.stringAttributeForKey("foed")
                var isfo = data.stringAttributeForKey("isfo")
                var cover = data.stringAttributeForKey("cover")
                var black = data.stringAttributeForKey("isban")
                var sex = data.stringAttributeForKey("sex")
                if let v = black.toInt() {
                    self.isBan = v
                }
                if sex == "1" {
                    self.topCell.imageSex.image = UIImage(named: "user_male")
                    self.topCell.imageSex.hidden = false
                }else if sex == "2" {
                    self.topCell.imageSex.image = UIImage(named: "user_female")
                    self.topCell.imageSex.hidden = false
                }
                fo = "\(fo) 关注，"
                foed = "\(foed) 听众"
                var foWidth = fo.stringWidthBoldWith(12, height: 21)
                var foedWidth = foed.stringWidthBoldWith(12, height: 21)
                var foX = ( globalWidth - foWidth - foedWidth ) / 2
                var foedX = foX + foWidth
                var AllCoverURL = "http://img.nian.so/cover/\(cover)!cover"
                self.topCell.UserName.text = name
                var width = name.stringWidthBoldWith(19, height: 23)
                self.topCell.UserName.setWidth(width)
                self.topCell.UserName.setX((globalWidth-width)/2)
                self.topCell.imageSex.setX((globalWidth-width)/2+width)
                self.topCell.UserFo.text = fo
                self.topCell.UserFoed.text = foed
                self.topCell.UserFo.setX(foX)
                self.topCell.UserFoed.setX(foedX)
                self.topCell.UserFo.setWidth(foWidth)
                self.topCell.UserFoed.setWidth(foedWidth)
                self.topCell.UserHead.setHead("\(theUid)")
                self.topCell.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserHeadClick:"))
                var vip = data.stringAttributeForKey("vip")
                self.topCell.imageBadge.setType(vip)
                
                self.topCell.btnMain.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)
                self.topCell.btnLetter.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)
                if cover == "" {
                    self.navView.image = UIImage(named: "bg")
                    self.navView.contentMode = UIViewContentMode.ScaleAspectFill
                }else{
                    self.navView.setCover(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                }
                self.topCell.UserFo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFoClick"))
                self.topCell.UserFoed.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFoedClick"))
                if isfo == "1" {
                    self.topCell.btnMain.addTarget(self, action: "SAunfo:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.topCell.btnMain.setTitle("正在关注", forState: UIControlState.Normal)
                }else{
                    self.topCell.btnMain.addTarget(self, action: "SAfo:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.topCell.btnMain.setTitle("关注", forState: UIControlState.Normal)
                }
                self.topCell.btnLetter.addTarget(self, action: "SALetter:", forControlEvents: UIControlEvents.TouchUpInside)
                self.topCell.btnLetter.setTitle("写信", forState: UIControlState.Normal)
                
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                if self.Id == safeuid {
                    self.topCell.btnLetter.hidden = true
                    self.topCell.btnMain.setTitle("设置", forState: UIControlState.allZeros)
                    self.topCell.btnMain.setX(globalWidth/2 - 50)
                    self.topCell.btnMain.removeTarget(self, action: "SAunfo:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.topCell.btnMain.removeTarget(self, action: "SAfo:", forControlEvents: UIControlEvents.TouchUpInside)
                    self.topCell.btnMain.addTarget(self, action: "SASettings", forControlEvents: UIControlEvents.TouchUpInside)
                }
                if cover == "" {
                    self.topCell.BGImage.contentMode = UIViewContentMode.ScaleAspectFill
                    self.topCell.BGImage.image = UIImage(named: "bg")
                }else{
                    self.topCell.BGImage.setCover(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false, animated: true)
                }
            }
        }
    }
    
    func SASettings() {
        var vc = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onUserHeadClick(sender:UIGestureRecognizer) {
        if let v = sender.view as? UIImageView {
            var yPoint = v.convertPoint(CGPointMake(0, 0), fromView: v.window!)
            var rect = CGRectMake(-yPoint.x, -yPoint.y, 60, 60)
            v.showImage("http://img.nian.so/head/\(self.Id).jpg!large", rect: rect)
        }
    }
    
    func onMenuClick(sender:UIGestureRecognizer){
        var tag = sender.view!.tag
        var y1 = self.tableViewDream.contentOffset.y
        var y2 = self.tableViewStep.contentOffset.y
        if tag == 100 {
            self.tableViewDream.contentOffset.y = y2
            self.tableViewStep.hidden = true
            self.tableViewDream.hidden = false
            self.topCell.labelMenuLeft.textColor = SeaColor
            self.topCell.labelMenuRight.textColor = UIColor.blackColor()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.topCell.labelMenuSlider.setX(self.topCell.labelMenuLeft.x()+15)
            })
            if self.dataArray.count == 0 {
                self.SALoadData()
            }
        }else if tag == 200 {
            self.tableViewStep.contentOffset.y = y1
            self.tableViewDream.hidden = true
            self.tableViewStep.hidden = false
            self.topCell.labelMenuRight.textColor = SeaColor
            self.topCell.labelMenuLeft.textColor = UIColor.blackColor()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.topCell.labelMenuSlider.setX(self.topCell.labelMenuRight.x()+15)
            })
            if self.dataArrayStep.count == 0 {
                self.SALoadDataStep()
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section > 0 && tableView == self.tableViewStep {
            var index = indexPath.row
            var data = self.dataArrayStep[index] as! NSDictionary
            var dream = data.stringAttributeForKey("dream")
            var DreamVC = DreamViewController()
            DreamVC.Id = dream
            self.navigationController!.pushViewController(DreamVC, animated: true)
        }
    }
    
    func onFoClick(){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 1
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    func onFoedClick(){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 2
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func SAfo(sender:UIButton){
        sender.setTitle("正在关注", forState: UIControlState.Normal)
        sender.removeTarget(self, action: "SAfo:", forControlEvents: UIControlEvents.TouchUpInside)
        sender.addTarget(self, action: "SAunfo:", forControlEvents: UIControlEvents.TouchUpInside)
        var textFoed = SAReplace(self.topCell.UserFoed.text!, " 听众", "") as String
        if let num = textFoed.toInt() {
            self.topCell.UserFoed.text = "\(num + 1) 听众"
        }
        Api.postFollow(self.Id, follow: 1) { string in
        }
    }
    
    func SAunfo(sender:UIButton){
        sender.setTitle("关注", forState: UIControlState.Normal)
        sender.removeTarget(self, action: "SAunfo:", forControlEvents: UIControlEvents.TouchUpInside)
        sender.addTarget(self, action: "SAfo:", forControlEvents: UIControlEvents.TouchUpInside)
        var textFoed = SAReplace(self.topCell.UserFoed.text!, " 听众", "") as String
        if let num = textFoed.toInt() {
            self.topCell.UserFoed.text = "\(num - 1) 听众"
        }
        Api.postUnfollow(self.Id) { result in
        }
    }
    
    func SALetter(sender: UIButton) {
        var letterVC = CircleController()
        if let id = self.Id.toInt() {
            letterVC.ID = id
            letterVC.isCircle = false
            self.navigationController?.pushViewController(letterVC, animated: true)
        }
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func countUp(coin: String, isfirst: String){
        self.SALoadData()
    }
    
    func Editstep() {
        if self.editStepData != nil {
            self.dataArrayStep[self.editStepRow] = self.editStepData!
            var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
            self.tableViewStep.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
}

