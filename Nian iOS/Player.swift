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
    let identifier2 = "PlayerCellTop"
    let identifier3 = "step"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
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
    var toggle:Int = 0 //梦想或者进展
    
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
    
    var topCell:PlayerCellTop?
    var navView:UIImageView!
    var rowComment:Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ShareContent", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "DreamimageViewTapped", object:nil)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ShareContent:", name: "ShareContent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "DreamimageViewTapped:", name: "DreamimageViewTapped", object: nil)
    }
    
    func ShareContent(noti:NSNotification){
        var content:AnyObject = noti.object!
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(Id)")!
        var sid:Int = content[2] as Int
        var row:Int = (content[3] as Int)-10
        
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
        var ActivityArray = [ customActivity ]
        
        if self.dreamowner == 1 {
            ActivityArray = [ editActivity, deleteActivity ]
        }
        
        
        if content[1] as NSString != "" {
            var theimgurl:String = content[1] as String
            var imgurl = NSURL(string: theimgurl)!
            var cacheFilename = imgurl.lastPathComponent
            var cachePath = FileUtility.cachePath(cacheFilename)
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
    
    func shareDream(){
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(self.Id)")!
        let activityViewController = UIActivityViewController(
            activityItems: [ "喜欢念上的这个梦想！「\(self.titleJson)」", url ],
            applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func setupViews()
    {
        viewBack(self)
        
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
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
        
        self.tableView = UITableView(frame:CGRectMake(0, -64, globalWidth,globalHeight+64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"PlayerCell", bundle: nil)
        var nib2 = UINib(nibName:"PlayerCellTop", bundle: nil)
        var nib3 = UINib(nibName:"StepCell", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.tableView?.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.view.addSubview(self.tableView!)
        
        self.navView = UIImageView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.navView.hidden = true
        self.navView.clipsToBounds = true
        self.navView.alpha = 0
        self.view.addSubview(self.navView)
        self.setupPlayerTop(self.Id.toInt()!)
    }
    
    func userMore(){
        self.userMoreSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.userMoreSheet.addButtonWithTitle("拖进小黑屋")
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
                self.tableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView!.reloadData()
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
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/ban.php")
                    if sa == "1" {
                        dispatch_async(dispatch_get_main_queue(), {
                            UIView.showAlertView("再见啦", message: "成功拖进小黑屋")
                        })
                    }
                })
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var height = scrollView.contentOffset.y
        self.scrollLayout(height)
    }
    
    func scrollLayout(height:CGFloat){
        var newHeight = height + 64
        if self.topCell != nil {
            if newHeight > 0 {
                self.topCell!.BGImage.frame = CGRectMake(0, newHeight, 320, 320 - newHeight )
            }else{
                self.topCell!.viewHolder.setY(newHeight)
                self.topCell!.BGImage.frame = CGRectMake(newHeight/10, newHeight, 320-newHeight/5, 320)
            }
            scrollHidden(self.topCell!.UserHead, height: newHeight, scrollY: 70)
            scrollHidden(self.topCell!.UserName, height: newHeight, scrollY: 138)
            scrollHidden(self.topCell!.UserFo, height: newHeight, scrollY: 161)
            scrollHidden(self.topCell!.UserFoed, height: newHeight, scrollY: 161)
            scrollHidden(self.topCell!.btnMain, height: newHeight, scrollY: 214)
        }
        if height >= 192 {
            self.navView.hidden = false
            self.navView.alpha = 1
        }else{
            self.navView.hidden = true
            self.navView.alpha = 0
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
    
    
    func loadData()
    {
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                var arr = data["items"] as NSArray
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.footerEndRefreshing()
                self.page++
                if ( data["total"] as Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
            }
        })
    }
    
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        self.tableView!.setFooterHidden(false)
        if toggle == 0 {
            var url = "http://nian.so/api/user_dream.php?page=0&uid=\(Id)"
            SAHttpRequest.requestWithURL(url,completionHandler:{ data in
                if data as NSObject != NSNull() {
                    var arr = data["items"] as NSArray
                    self.dataArray.removeAllObjects()
                    for data : AnyObject  in arr{
                        self.dataArray.addObject(data)
                    }
                    self.tableView!.reloadData()
                    self.tableView!.headerEndRefreshing()
                    self.page = 1
                    if ( data["total"] as Int ) < 30 {
                        self.tableView!.setFooterHidden(true)
                    }
                }
            })
        }else if toggle == 1 {
            var url = "http://nian.so/api/user_active.php?page=0&uid=\(Id)&myuid=\(safeuid)"
            SAHttpRequest.requestWithURL(url,completionHandler:{ data in
                if data as NSObject != NSNull() {
                    var arr = data["items"] as NSArray
                    self.dataArray.removeAllObjects()
                    for data : AnyObject  in arr{
                        self.dataArray.addObject(data)
                    }
                    self.tableView!.reloadData()
                    self.tableView!.headerEndRefreshing()
                    self.page = 1
                    if ( data["total"] as Int ) < 30 {
                        self.tableView!.setFooterHidden(true)
                    }
                }
            })
        }
    }
    
    func urlString()->String
    {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if toggle == 0 {
            return "http://nian.so/api/user_dream.php?page=\(page)&uid=\(Id)"
        }else{
            return "http://nian.so/api/user_active.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onStepClick(){
        UIView.animateWithDuration(0.3, animations: {
            self.tableView!.contentOffset.y = 287
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as PlayerCellTop
            var index = indexPath.row
            var dreamid = Id
            self.topCell = c
            cell = c
        }else{
            if toggle == 0 {
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
                var data = self.dataArray[index] as NSDictionary
                c.data = data
                c.indexPathRow = index
                c.tag = index + 10
                c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c.nickLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
                c.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick:"))
                c.imageholder!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
                if indexPath.row == self.dataArray.count - 1 {
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
        var img = dataArray[view.tag - 10].objectForKey("img") as String
        var img0 = dataArray[view.tag - 10].objectForKey("img0") as NSString
        var img1 = dataArray[view.tag - 10].objectForKey("img1") as NSString
        var yPoint = sender.view!.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!).y
        self.view.showImage(V.urlStepImage(img, tag: .Large), width: img0.floatValue, height: img1.floatValue, yPoint: -yPoint)
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
        var dream = dataArray[view.tag - 10].objectForKey("dream") as String
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
    
    func imageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController!.pushViewController(imgVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.section==0{
            if toggle == 0 {
                return  364 + 30
            }else{
                return 364 + 14
            }
        }else{
            if toggle == 0 {
                return  129
            }else{
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                return  PlayerCell.cellHeightByData(data)
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section != 0 {
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            var dream = data.stringAttributeForKey("dream")
            if toggle == 1 {
                var DreamVC = DreamViewController()
                DreamVC.Id = dream
                self.navigationController!.pushViewController(DreamVC, animated: true)
            }
        }
    }
    
    func setupRefresh(){
        self.tableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func commentVC(){
        var addCommentVC = AddCommentViewController(nibName: "AddCommentViewController", bundle: nil)
        if self.ReplyUser != "" {
            addCommentVC.content = "@\(self.ReplyUser) "
        }else{
            addCommentVC.content = ""
        }
        addCommentVC.Id = self.Id
        addCommentVC.Row = self.ReplyRow
        self.navigationController!.pushViewController(addCommentVC, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            if toggle == 0 {
                return Int(ceil(Double(self.dataArray.count)/3))
            }else{
            return self.dataArray.count
            }
        }
    }
    
    func DreamimageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController!.pushViewController(imgVC, animated: true)
    }
    
    func setupPlayerTop(theUid:Int){
        Api.getUserTop(theUid){ json in
            if json != nil {
                var sa: AnyObject! = json!.objectForKey("user")
                var name: String! = sa.objectForKey("name") as String
                var fo: String! = sa.objectForKey("fo") as String
                var foed: String! = sa.objectForKey("foed") as String
                var isfo: String! = sa.objectForKey("isfo") as String
                var cover: String! = sa.objectForKey("cover") as String
                fo = "\(fo) 关注，"
                foed = "\(foed) 听众"
                var foWidth = fo.stringWidthBoldWith(12, height: 21)
                var foedWidth = foed.stringWidthBoldWith(12, height: 21)
                var foX = ( globalWidth - foWidth - foedWidth ) / 2
                var foedX = foX + foWidth
                var userImageURL = "http://img.nian.so/head/\(theUid).jpg!dream"
                var AllCoverURL = "http://img.nian.so/cover/\(cover)!cover"
                if self.topCell != nil {
                    self.topCell!.UserName.text = name
                    self.topCell!.UserFo.text = fo
                    self.topCell!.UserFoed.text = foed
                    self.topCell!.UserFo.setX(foX)
                    self.topCell!.UserFoed.setX(foedX)
                    self.topCell!.UserFo.setWidth(foWidth)
                    self.topCell!.UserFoed.setWidth(foedWidth)
                    self.topCell!.UserHead.setImage(userImageURL, placeHolder: IconColor)
                    self.topCell!.btnMain.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.55)
                    if cover == "" {
                        self.navView.image = UIImage(named: "bg")
                    }else{
                        self.navView.setImage(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                    }
                    self.navView.contentMode = UIViewContentMode.Center
                    self.topCell!.UserFo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFoClick"))
                    self.topCell!.UserFoed.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFoedClick"))
                    self.topCell!.labelMenuLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
                    self.topCell!.labelMenuRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
                    if isfo == "1" {
                        self.topCell!.btnMain.addTarget(self, action: "SAunfo:", forControlEvents: UIControlEvents.TouchUpInside)
                        self.topCell!.btnMain.setTitle("正在关注", forState: UIControlState.Normal)
                    }else{
                        self.topCell!.btnMain.addTarget(self, action: "SAfo:", forControlEvents: UIControlEvents.TouchUpInside)
                        self.topCell!.btnMain.setTitle("关注", forState: UIControlState.Normal)
                    }
                    if cover == "" {
                        self.topCell!.BGImage.contentMode = UIViewContentMode.ScaleAspectFill
                        self.topCell!.BGImage.image = UIImage(named: "bg")
                    }else{
                        self.topCell!.BGImage.setImage(AllCoverURL, placeHolder: UIColor.blackColor(), bool: false)
                    }
                }
            }
        }
    }
    
    func onMenuClick(sender:UIGestureRecognizer){
        var tag = sender.view!.tag
        if self.topCell != nil {
            if tag == 100 {
                self.topCell!.labelMenuLeft.textColor = SeaColor
                self.topCell!.labelMenuRight.textColor = UIColor.blackColor()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.topCell!.labelMenuSlider.setX(self.topCell!.labelMenuLeft.x()+15)
                })
                self.toggle = 0
                self.SAReloadData()
            }else if tag == 200 {
                self.topCell!.labelMenuRight.textColor = SeaColor
                self.topCell!.labelMenuLeft.textColor = UIColor.blackColor()
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.topCell!.labelMenuSlider.setX(self.topCell!.labelMenuRight.x()+15)
                })
                self.toggle = 1
                self.SAReloadData()
            }
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
        var textFoed = SAReplace(self.topCell!.UserFoed.text!, " 听众", "") as String
        var numberFoed = textFoed.toInt()! + 1
        self.topCell!.UserFoed.text = "\(numberFoed) 听众"
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
        var textFoed = SAReplace(self.topCell!.UserFoed.text!, " 听众", "") as String
        var numberFoed = textFoed.toInt()! - 1
        self.topCell!.UserFoed.text = "\(numberFoed) 听众"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var sa = SAPost("uid=\(self.Id)&&myuid=\(safeuid)&&shell=\(safeshell)&&unfo=1", "http://nian.so/api/fo.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func countUp() {
        self.SAReloadData()
    }
    
    func Editstep() {
        self.dataArray[self.editStepRow] = self.editStepData!
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.tableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
}

