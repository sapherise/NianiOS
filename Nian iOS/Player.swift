//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, UIGestureRecognizerDelegate, AddstepDelegate{
    
    let identifier = "PlayerCell"
    let identifier3 = "step"
    var tableViewDream:UITableView!
    var tableViewStep:UITableView!
    var dataArray = NSMutableArray()
    var dataArrayStep = NSMutableArray()
    var page :Int = 0
    var Id:String = "0"
    var deleteSheet:UIActionSheet?
    var replySheet:UIActionSheet?
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
    
    var EditId:Int = 0
    var EditContent:String = ""
    var ReplyUser:String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReturnReplyRow:Int = 0
    var ReplyCid:String = ""
    var activityViewController:UIActivityViewController?
    
    var ReturnReplyContent:String = ""
    var ReturnReplyId:String = ""
    
    var titleJson: String = ""
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
    
    var desHeight:CGFloat = 0
    
    var topCell:PlayerCellTop!
    var navView: UIImageView!
    var rowComment:Int = 0
    var isBan: Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
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
        var sid:Int = content[2] as Int
        var row:Int = (content[3] as Int)-10
        var url:NSURL = NSURL(string: "http://nian.so/m/step/\(sid)")!
        
        var customActivity = SAActivity()
        customActivity.saActivityTitle = "举报"
        customActivity.saActivityImage = UIImage(named: "flag")!
        customActivity.saActivityFunction = {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)", "http://nian.so/api/a.php")
                if(sa == "1"){
                    dispatch_async(dispatch_get_main_queue(), {
                        UIView.showAlertView("谢谢", message: "如果这个进展不合适，我们会将其移除。")
                    })
                }
            })
        }
        //删除按钮
        var deleteActivity = SAActivity()
        deleteActivity.saActivityTitle = "删除"
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
        //编辑按钮
        var editActivity = SAActivity()
        editActivity.saActivityTitle = "编辑"
        editActivity.saActivityImage = UIImage(named: "edit")!
        editActivity.saActivityFunction = {
            var data = self.dataArray[row] as NSDictionary
            var addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
            addstepVC.isEdit = 1
            addstepVC.data = data
            addstepVC.row = row
            addstepVC.delegate = self
            self.navigationController!.pushViewController(addstepVC, animated: true)
        }
        var ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), customActivity ]
        
        if self.dreamowner == 1 {
            ActivityArray = [WeChatSessionActivity(), WeChatMomentsActivity(), editActivity, deleteActivity ]
        }
        
        
        if content[1] as NSString != "" {
            var theimgurl:String = content[1] as String
            var imgurl = NSURL(string: theimgurl)!
            var cacheFilename = imgurl.lastPathComponent
            var cachePath = FileUtility.cachePath(cacheFilename!)
            var image:AnyObject = FileUtility.imageDataFromPath(cachePath)
            self.activityViewController = UIActivityViewController(
                activityItems: [ content[0], url, image ],
                applicationActivities: ActivityArray)
            self.activityViewController?.excludedActivityTypes = [
                UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
            ]
            self.presentViewController(self.activityViewController!, animated: true, completion: nil)
        }else{
            self.activityViewController = UIActivityViewController(
                activityItems: [ content[0], url ],
                applicationActivities: ActivityArray)
            self.activityViewController?.excludedActivityTypes = [
                UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
            ]
            self.presentViewController(self.activityViewController!, animated: true, completion: nil)
        }
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid:String = Sa.objectForKey("uid") as String
        if self.Id != safeuid {
            var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "userMore")
            moreButton.image = UIImage(named:"more")
            self.navigationItem.rightBarButtonItems = [ moreButton ]
            self.dreamowner = 0
        }else{
            self.dreamowner = 1
        }
        self.navView = UIImageView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.navView.hidden = true
        self.navView.clipsToBounds = true
        self.topCell = (NSBundle.mainBundle().loadNibNamed("PlayerCellTop", owner: self, options: nil) as NSArray).objectAtIndex(0) as PlayerCellTop
        self.topCell.frame = CGRectMake(0, 0, globalWidth, 364)
        self.setupPlayerTop(self.Id.toInt()!)
        var nib = UINib(nibName:"PlayerCell", bundle: nil)
        var nib3 = UINib(nibName:"StepCell", bundle: nil)
        self.tableViewDream = UITableView(frame:CGRectMake(0, 0, globalWidth,globalHeight))
        self.tableViewDream.delegate = self
        self.tableViewDream.dataSource = self
        self.tableViewDream.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableViewDream.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableViewDream.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.tableViewStep = UITableView(frame:CGRectMake(0, 0, globalWidth,globalHeight))
        self.tableViewStep.delegate = self
        self.tableViewStep.dataSource = self
        self.tableViewStep.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableViewStep.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableViewStep.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.tableViewStep.hidden = true
        self.view.addSubview(self.tableViewStep)
        self.view.addSubview(self.tableViewDream)
        self.view.addSubview(self.topCell)
        self.view.addSubview(self.navView)
        
        
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
                var safeuid = Sa.objectForKey("uid") as String
                var safeshell = Sa.objectForKey("shell") as String
                var newpath = NSIndexPath(forRow: self.deleteViewId, inSection: 1)
                self.dataArray.removeObjectAtIndex(newpath!.row)
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
                var safeuid = Sa.objectForKey("uid") as String
                var safeshell = Sa.objectForKey("shell") as String
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
        if scrollView == self.tableViewDream || scrollView == self.tableViewStep {
            var height = scrollView.contentOffset.y
            self.scrollLayout(height)
        }
    }
    
    func scrollLayout(height:CGFloat){
        
        println(height)
        if height > 0 {
            // 这里要求整个跟着向上滚动
            // 同时图片要带着阻尼滚动
            self.topCell.setY(-height)
            self.topCell.BGImage.setY(height/5)
        }
//        if height > 0 {
//            self.topCell.setY(-height)
//            self.tableViewStep.setY(364 + 30 - height)
//            self.tableViewDream.setY(364 + 14 - height)
//        }
//        var newHeight = -height - 64
//        println(newHeight)
//        if newHeight > 0 {
//            self.topCell.BGImage.frame = CGRectMake(0, -newHeight, globalWidth, 320 + newHeight)
//        }else{
//            self.topCell.viewHolder.setY(newHeight)
//            self.topCell.BGImage.frame = CGRectMake(newHeight/10, newHeight, globalWidth-newHeight/5, 320)
//            self.topCell.viewBlack.setY(newHeight)
//        }
//        
//        scrollHidden(self.topCell.UserHead, height: newHeight, scrollY: 70)
//        scrollHidden(self.topCell.UserName, height: newHeight, scrollY: 138)
//        scrollHidden(self.topCell.UserFo, height: newHeight, scrollY: 161)
//        scrollHidden(self.topCell.UserFoed, height: newHeight, scrollY: 161)
//        scrollHidden(self.topCell.btnMain, height: newHeight, scrollY: 214)
//        scrollHidden(self.topCell.btnLetter, height: newHeight, scrollY: 214)
        if height >= 320 - 44 {
            self.navView.hidden = false
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
        self.ownerMoreSheet!.addButtonWithTitle("编辑梦想")
        if self.percentJson == "1" {
            self.ownerMoreSheet!.addButtonWithTitle("还未完成梦想")
        }else if self.percentJson == "0" {
            self.ownerMoreSheet!.addButtonWithTitle("完成梦想")
        }
        self.ownerMoreSheet!.addButtonWithTitle("分享梦想")
        self.ownerMoreSheet!.addButtonWithTitle("删除梦想")
        self.ownerMoreSheet!.addButtonWithTitle("取消")
        self.ownerMoreSheet!.cancelButtonIndex = 4
        self.ownerMoreSheet!.showInView(self.view)
    }
    
    func guestMore(){
        self.guestMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        if self.followJson == "1" {
            self.guestMoreSheet!.addButtonWithTitle("取消关注梦想")
        }else if self.followJson == "0" {
            self.guestMoreSheet!.addButtonWithTitle("关注梦想")
        }
        if self.likeJson == "1" {
            self.guestMoreSheet!.addButtonWithTitle("取消赞")
        }else if self.likeJson == "0" {
            self.guestMoreSheet!.addButtonWithTitle("赞梦想")
        }
        self.guestMoreSheet!.addButtonWithTitle("分享梦想")
        self.guestMoreSheet!.addButtonWithTitle("标记为不合适")
        self.guestMoreSheet!.addButtonWithTitle("取消")
        self.guestMoreSheet!.cancelButtonIndex = 4
        self.guestMoreSheet!.showInView(self.view)
    }
    
    func loadData() {
        Api.getUserDream(Id, page: page) { json in
            if json != nil {
                var arr = json!["items"] as NSArray
                for data: AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                self.tableViewDream.reloadData()
                self.tableViewDream.footerEndRefreshing()
                self.page++
                if let total = json!["total"] as? Int {
                    if total < 30 {
                        self.tableViewDream.setFooterHidden(true)
                    }
                }
            }
        }
    }
    
    func loadDataStep() {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        
        var url = "http://nian.so/api/user_active.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                var arr = data["items"] as NSArray
                for data : AnyObject  in arr {
                    self.dataArrayStep.addObject(data)
                }
                self.tableViewStep.reloadData()
                self.tableViewStep.footerEndRefreshing()
                self.page++
                if ( data["total"] as Int ) < 30 {
                    self.tableViewStep.setFooterHidden(true)
                }
            }
        })
    }
    
    
    func SAReloadData(){
        Api.getUserDream(Id, page: 0) { json in
            if json != nil {
                var arr = json!["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data: AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                self.tableViewDream.reloadData()
                self.tableViewDream.headerEndRefreshing()
                self.page++
                if let total = json!["total"] as? Int {
                    if total < 30 {
                        self.tableViewDream.setFooterHidden(true)
                    }
                }
            }
        }
    }
    
    func SAReloadDataStep(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        self.tableViewStep.setFooterHidden(false)
            var url = "http://nian.so/api/user_active.php?page=0&uid=\(Id)&myuid=\(safeuid)"
            SAHttpRequest.requestWithURL(url,completionHandler:{ data in
                if data as NSObject != NSNull() {
                    var arr = data["items"] as NSArray
                    self.dataArrayStep.removeAllObjects()
                    for data : AnyObject  in arr{
                        self.dataArrayStep.addObject(data)
                    }
                    self.tableViewStep.reloadData()
                    self.tableViewStep.headerEndRefreshing()
                    self.page = 1
                    if ( data["total"] as Int ) < 30 {
                        self.tableViewStep.setFooterHidden(true)
                    }
                    self.tableViewStep.setContentOffset(CGPointZero, animated: false)
                }
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section == 0 {
            var c = UITableViewCell()
            return c
        }else{
            if tableView == self.tableViewDream {
                var c = tableView.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? StepCell
                var dictionary:Dictionary<String, String> = ["id":"", "title":"", "img":"", "percent":""]
                var index = indexPath.row * 3
                if index<self.dataArray.count {
                    c!.data1 = self.dataArray[index] as NSDictionary
                    c!.img1?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data1 = dictionary
                }
                if index+1<self.dataArray.count {
                    c!.data2 = self.dataArray[index + 1] as NSDictionary
                    c!.img2?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data2 = dictionary
                }
                if index+2<self.dataArray.count {
                    c!.data3 = self.dataArray[index + 2] as NSDictionary
                    c!.img3?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data3 = dictionary
                }
                cell = c!
            }else{
                var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as PlayerCell
                var index = indexPath.row
                var data = self.dataArrayStep[index] as NSDictionary
                c.data = data
                c.indexPathRow = index
                c.tag = index + 10
                c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c.nickLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
                c.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick:"))
                c.imageholder!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
                if indexPath.row == self.dataArrayStep.count - 1 {
                    c.viewLine.hidden = true
                }else{
                    c.viewLine.hidden = false
                }
                cell = c
            }
        }
        return cell
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view  = self.findTableCell(sender.view)!
        var img = dataArrayStep[view.tag - 10].objectForKey("img") as String
        var img0 = dataArrayStep[view.tag - 10].objectForKey("img0") as NSString
        var img1 = dataArrayStep[view.tag - 10].objectForKey("img1") as NSString
        var yPoint = sender.view!.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!)
        var w = CGFloat(img0.floatValue)
        var h = CGFloat(img1.floatValue)
        if w != 0 {
            h = h * globalWidth / w
            var rect = CGRectMake(-yPoint.x, -yPoint.y, globalWidth, h)
            if let v = sender.view as? UIImageView {
                v.showImage(V.urlStepImage(img, tag: .Large), rect: rect)
            }
        }
    }
    
    func findTableCell(view: UIView?) -> UIView? {
        for var v = view; v != nil; v = v!.superview {
            if v! is UITableViewCell {
                return v
            }
        }
        return nil
    }
    
    func onCommentClick(sender:UIGestureRecognizer){
        var view  = self.findTableCell(sender.view)!
        var dream = dataArrayStep[view.tag - 10].objectForKey("dream") as String
        var tag = sender.view!.tag
        var DreamCommentVC = DreamCommentViewController()
        var totalComment = SAReplace(( sender.view! as UILabel ).text!, " 评论", "") as String
        DreamCommentVC.dreamID = dream.toInt()!
        DreamCommentVC.stepID = tag
        DreamCommentVC.dreamowner = self.dreamowner
        self.navigationController!.pushViewController(DreamCommentVC, animated: true)
    }
    
    func likeclick(sender:UITapGestureRecognizer){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.section == 0 {
            if tableView == self.tableViewDream {
                return 364 + 30
            }else{
                return 320
            }
        }else{
            if tableView == self.tableViewDream {
                return  129
            }else{
                var index = indexPath!.row
                var data = self.dataArrayStep[index] as NSDictionary
                return  PlayerCell.cellHeightByData(data)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            var dream = data.stringAttributeForKey("dream")
            if tableView == self.tableViewDream && indexPath.section > 0 {
                var DreamVC = DreamViewController()
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
    }
    
    func setupRefresh(){
        self.tableViewDream.addFooterWithCallback({
            self.loadData()
        })
        self.tableViewStep.addFooterWithCallback({
            self.loadDataStep()
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
                var data = json!["user"] as NSDictionary
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
                self.topCell.UserFo.text = fo
                self.topCell.UserFoed.text = foed
                self.topCell.UserFo.setX(foX)
                self.topCell.UserFoed.setX(foedX)
                self.topCell.UserFo.setWidth(foWidth)
                self.topCell.UserFoed.setWidth(foedWidth)
                self.topCell.UserHead.setHead("\(theUid)")
                self.topCell.UserHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserHeadClick:"))
                
                var wantPress = UILongPressGestureRecognizer(target: self, action: "onIWANTYOU:")
                wantPress.minimumPressDuration = 10
                self.topCell.UserHead.addGestureRecognizer(wantPress)
                
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
                self.topCell.labelMenuLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
                self.topCell.labelMenuRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
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
                var safeuid = Sa.objectForKey("uid") as String
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
    
    func onIWANTYOU(sender: UILongPressGestureRecognizer) {
        if let duid = self.Id.toInt() {
            if FollowBlacklist.isblacked(duid) {
                FollowBlacklist.unblack(duid)
                sender.view!.showTipText("I WANT YOU", delay: 1)
            }
        }
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
        if tag == 100 {
            self.tableViewDream.hidden = false
            self.tableViewStep.hidden = true
            self.topCell.labelMenuLeft.textColor = SeaColor
            self.topCell.labelMenuRight.textColor = UIColor.blackColor()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.topCell.labelMenuSlider.setX(self.topCell.labelMenuLeft.x()+15)
            })
            self.SAReloadData()
        }else if tag == 200 {
            self.tableViewDream.hidden = true
            self.tableViewStep.hidden = false
            self.topCell.labelMenuRight.textColor = SeaColor
            self.topCell.labelMenuLeft.textColor = UIColor.blackColor()
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.topCell.labelMenuSlider.setX(self.topCell.labelMenuRight.x()+15)
            })
            self.SAReloadDataStep()
        }
        
        
        var h = self.tableViewDream.frame
        var h2 = self.tableViewStep.frame
        println("dream 的高度是 \(h)")
        println("step 的高度是 \(h2) ")
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
        var numberFoed = textFoed.toInt()! + 1
        self.topCell.UserFoed.text = "\(numberFoed) 听众"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)&&fo=1", "http://nian.so/api/fo.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func SAunfo(sender:UIButton){
        sender.setTitle("关注", forState: UIControlState.Normal)
        sender.removeTarget(self, action: "SAunfo:", forControlEvents: UIControlEvents.TouchUpInside)
        sender.addTarget(self, action: "SAfo:", forControlEvents: UIControlEvents.TouchUpInside)
        var textFoed = SAReplace(self.topCell.UserFoed.text!, " 听众", "") as String
        var numberFoed = textFoed.toInt()! - 1
        self.topCell.UserFoed.text = "\(numberFoed) 听众"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)&&unfo=1", "http://nian.so/api/fo.php")
            if sa != "" && sa != "err" {
            }
        })
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
        self.SAReloadData()
    }
    
    func Editstep() {
        self.dataArrayStep[self.editStepRow] = self.editStepData!
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.tableViewStep.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
}

