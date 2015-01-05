//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, UIGestureRecognizerDelegate, editDreamDelegate{
    
    let identifier = "dream"
    let identifier2 = "dreamtop"
    let identifier3 = "comment"
    var lefttableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var deleteSheet:UIActionSheet?
    var ownerMoreSheet:UIActionSheet?
    var guestMoreSheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteDreamSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    var navView:UIView!
    
    var dreamowner:Int = 0 //如果是0，就不是主人，是1就是主人
    
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
    var likedreamJson: String = ""
    var likestepJson: String = ""
    var liketotalJson: Int = 0
    var stepJson: String = ""
    var desJson:String = ""
    
    var desHeight:CGFloat = 0
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    var topCell:DreamCellTop!
    var hashtag:String = "0"
    var userImageURL:String = "0"
    
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
        self.viewBackFix()
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
    
    func shareDream(){
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(self.Id)")!
        let activityViewController = UIActivityViewController(
            activityItems: [ "喜欢念上的这个梦想！「\(self.titleJson)」", url ],
            applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func setupViews()
    {
        self.viewBack()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.lefttableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.lefttableView!.delegate = self;
        self.lefttableView!.dataSource = self;
        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"DreamCell", bundle: nil)
        var nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.lefttableView!)
        
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        //主人
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var url = NSURL(string:"http://nian.so/api/dream.php?id=\(self.Id)&uid=\(safeuid)&shell=\(safeshell)")
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            if data != nil {
                var json: AnyObject = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)!
                var dream: AnyObject! = json.objectForKey("dream")
                self.owneruid = dream.objectForKey("uid") as String
                self.titleJson = dream.objectForKey("title") as String
                self.percentJson = dream.objectForKey("percent") as String
                self.followJson = dream.objectForKey("follow") as String
                self.likeJson = dream.objectForKey("like") as String
                self.imgJson = dream.objectForKey("img") as String
                self.privateJson = dream.objectForKey("private") as String
                self.contentJson = dream.objectForKey("content") as String
                self.desJson = dream.objectForKey("content") as String
                self.hashtag = dream.objectForKey("hashtag") as String
                self.likedreamJson = dream.objectForKey("like_dream") as String
                self.likestepJson = dream.objectForKey("like_step") as String
                self.liketotalJson = self.likedreamJson.toInt()! + self.likestepJson.toInt()!
                self.stepJson = dream.objectForKey("step") as String
                self.desHeight = self.contentJson.stringHeightWith(11,width:200)
                dispatch_async(dispatch_get_main_queue(), {
                    if safeuid == self.owneruid {
                        self.dreamowner = 1
                        var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "ownerMore")
                        moreButton.image = UIImage(named:"more")
                        self.navigationItem.rightBarButtonItems = [ moreButton]
                    }else{
                        self.dreamowner = 0
                        var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "guestMore")
                        moreButton.image = UIImage(named:"more")
                        self.navigationItem.rightBarButtonItems = [ moreButton]
                    }
                    self.loadDreamTopcell()
                })
            }
        })
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
        self.lefttableView!.setFooterHidden(false)
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                if ( data["total"] as Int ) < 15 {
                    self.lefttableView!.setFooterHidden(true)
                }
                var arr = data["items"] as NSArray
                for data : AnyObject  in arr
                {
                    self.dataArray.addObject(data)
                }
                self.lefttableView!.reloadData()
                self.lefttableView!.footerEndRefreshing()
                self.page++
            }
        })
    }
    
    
    func SAReloadData(){
        self.lefttableView!.setFooterHidden(false)
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = "http://nian.so/api/step.php?page=0&id=\(Id)&uid=\(safeuid)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull(){
                if ( data["total"] as Int ) < 15 {
                    self.lefttableView!.setFooterHidden(true)
                }
                var arr = data["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.lefttableView!.reloadData()
                self.lefttableView!.headerEndRefreshing()
                self.page = 1
            }
        })
    }
    
    
    
    
    func urlString()->String
    {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/step.php?page=\(page)&id=\(Id)&uid=\(safeuid)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onStepClick(){
        UIView.animateWithDuration(0.3, animations: {
            self.lefttableView!.contentOffset.y = 287
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as DreamCellTop
            var index = indexPath.row
            var dreamid = Id
            c.dreamid = dreamid
            c.numMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onStepClick"))
            c.numLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeDream"))
            c.numRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTagClick"))
            self.topCell = c
            cell = c
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as DreamCell
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            c.data = data
            c.indexPathRow = index
            c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.nickLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
            c.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick:"))
            c.imageholder!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
            c.tag = index + 10
            if indexPath.row == self.dataArray.count - 1 {
                c.viewLine.hidden = true
            }else{
                c.viewLine.hidden = false
            }
            cell = c
        }
        return cell
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view  = self.findTableCell(sender.view)!
        var img = dataArray[view.tag - 10].objectForKey("img") as String
        var img0 = dataArray[view.tag - 10].objectForKey("img0") as NSString
        var img1 = dataArray[view.tag - 10].objectForKey("img1") as NSString
        var yPoint = sender.view!.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!)
        self.view.showImage(V.urlStepImage(img, tag: .Large), width: img0.floatValue, height: img1.floatValue, yPoint: yPoint)
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
        var tag = sender.view!.tag
        var DreamCommentVC = DreamCommentViewController()
        DreamCommentVC.dreamID = self.Id.toInt()!
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
            return  287 + 14
        }else{
            if tableView == lefttableView {
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                return  DreamCell.cellHeightByData(data)
            }else{
                var index = indexPath!.row
                var data = self.dataArray2[index] as NSDictionary
                return  CommentCell.cellHeightByData(data)
            }
        }
    }
    
    func addStepButton(){
        var AddstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        AddstepVC.Id = self.Id
        AddstepVC.delegate = self    //😍
        self.navigationController!.pushViewController(AddstepVC, animated: true)
    }
    
    func countUp() {      //😍
        self.SAReloadData()
        var stepNum = self.topCell.numMiddleNum.text!.toInt()!
        self.topCell.numMiddleNum.text = "\(stepNum + 1)"
    }
    
    
    func Editstep() {      //😍
        self.dataArray[self.editStepRow] = self.editStepData!
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 1)
        self.lefttableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func setupRefresh(){
        self.lefttableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
        
        self.lefttableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.deleteSheet {
            if buttonIndex == 0 {
                var newpath = NSIndexPath(forRow: self.deleteViewId, inSection: 1)
                self.dataArray.removeObjectAtIndex(newpath!.row)
                self.lefttableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.lefttableView!.reloadData()
                var stepNum = self.topCell.numMiddleNum.text!.toInt()!
                self.topCell.numMiddleNum.text = "\(stepNum - 1)"
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
                    if(sa == "1"){
                    }
                })
            }
        }else if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {       //删除梦想
                self.navigationItem.rightBarButtonItems = buttonArray()
                globalWillNianReload = 1
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&id=\(self.Id)", "http://nian.so/api/delete_dream.php")
                    if(sa == "1"){
                        dispatch_async(dispatch_get_main_queue(), {
                        self.back()
                        })
                    }
                })
            }
        }else if actionSheet == self.ownerMoreSheet {
            if buttonIndex == 0 {   //编辑梦想
                self.editMyDream()
            }else if buttonIndex == 1 { //完成梦想
                var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "ownerMore")
                moreButton.image = UIImage(named:"more")
                if self.percentJson == "1" {
                    self.percentJson = "0"
                }else if self.percentJson == "0" {
                    self.percentJson = "1"
                }
                self.navigationItem.rightBarButtonItems = [ moreButton]
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&percent=\(self.percentJson)", "http://nian.so/api/dream_complete_query.php")
                    if sa != "" && sa != "err" {
                    }
                })
            }else if buttonIndex == 2 {     //分享梦想
                shareDream()
            }else if buttonIndex == 3 {     //删除梦想
                self.deleteDreamSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                self.deleteDreamSheet!.addButtonWithTitle("确定删除")
                self.deleteDreamSheet!.addButtonWithTitle("取消")
                self.deleteDreamSheet!.cancelButtonIndex = 1
                self.deleteDreamSheet!.showInView(self.view)
            }
        }else if actionSheet == self.guestMoreSheet {
            if buttonIndex == 0 {   //关注梦想
                if self.followJson == "1" {
                    self.followJson = "0"
                }else if self.followJson == "0" {
                    self.followJson = "1"
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&fo=\(self.followJson)", "http://nian.so/api/dream_fo_query.php")
                    if sa != "" && sa != "err" {
                    }
                })
            }else if buttonIndex == 1 {     //赞梦想
                onDreamLikeClick()
            }else if buttonIndex == 2 { //分享梦想
                shareDream()
            }else if buttonIndex == 3 { //不合适
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/a.php")
                    if(sa == "1"){
                        dispatch_async(dispatch_get_main_queue(), {
                            UIView.showAlertView("谢谢", message: "如果这个梦想不合适，我们会将其移除。")
                        })
                    }
                })
            }
        }
    }
    
    func editMyDream(readyForTag:Int = 0){
        var editdreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
        editdreamVC.delegate = self
        editdreamVC.isEdit = 1
        editdreamVC.editId = self.Id
        editdreamVC.editTitle = self.titleJson
        editdreamVC.editContent = self.contentJson
        editdreamVC.editImage = self.imgJson
        editdreamVC.editPrivate = self.privateJson
        editdreamVC.tagType = self.hashtag.toInt()!
        editdreamVC.readyForTag = readyForTag
        self.navigationController!.pushViewController(editdreamVC, animated: true)
    }
    
    func editDream(editPrivate:String, editTitle:String, editDes:String, editImage:String, editTag:String){
        self.titleJson = editTitle
        self.privateJson = editPrivate
        self.contentJson = editDes
        self.desJson = editDes
        self.imgJson = editImage
        self.hashtag = editTag
        loadDreamTopcell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            if tableView == self.lefttableView {
                return self.dataArray.count
            }else{
                return self.dataArray2.count
            }
        }
    }
    
    func loadDreamTopcell(){
        if self.privateJson == "1" {
            var string = NSMutableAttributedString(string: "\(self.titleJson)（私密）")
            var len = string.length
            string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, len-4))
            string.addAttribute(NSForegroundColorAttributeName, value: SeaColor, range: NSMakeRange(len-4, 4))
            self.topCell.nickLabel.attributedText = string
        }else if self.percentJson == "1" {
            var string = NSMutableAttributedString(string: "\(self.titleJson)（已完成）")
            var len = string.length
            string.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, len-5))
            string.addAttribute(NSForegroundColorAttributeName, value: GoldColor, range: NSMakeRange(len-5, 5))
            self.topCell.nickLabel.attributedText = string
        }else{
            self.topCell.nickLabel.text = "\(self.titleJson)"
        }
        
        var Sa = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        self.topCell.btnMain.hidden = false
        UIView.animateWithDuration(0.3, animations: {
            self.topCell.btnMain.alpha = 1
        })
        if self.owneruid == safeuid {
            self.topCell.btnMain.setTitle("更新", forState: UIControlState.Normal)
            self.topCell.btnMain.addTarget(self, action: "addStepButton", forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            if self.likeJson == "0" {
                self.topCell.btnMain.setTitle("赞", forState: UIControlState.Normal)
                self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                self.topCell.btnMain.setTitle("分享", forState: UIControlState.Normal)
                self.topCell.btnMain.addTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        
        self.topCell.numLeftNum.text = "\(self.liketotalJson)"
        self.topCell.numMiddleNum.text = "\(self.stepJson)"
        
        if self.hashtag == "0" {
            self.topCell.numRightNum.text = "0"
            if self.dreamowner == 1 {
                self.topCell.numRightNum.textColor = SeaColor
            }else{
                // 如果没有标签又不是自己，那么就把标签隐藏起来
                self.topCell.numRightNum.textColor = UIColor.blackColor()
                self.topCell.numRight.hidden = true
                self.topCell.viewLineRight.hidden = true
                self.topCell.numLeft.setX(70)
                self.topCell.numMiddle.setX(161)
                self.topCell.viewLineLeft.setX(160)
            }
        }else{
            self.topCell.numRightNum.text = "1"
            self.topCell.numRightNum.textColor = UIColor.blackColor()
        }
        
        
        if self.desJson == "" {
            self.desJson = "暂无简介"
        }
        
        self.topCell.labelDes.text = self.desJson
        var desHeight = self.desJson.stringHeightWith(12,width:200)
        self.topCell.labelDes.setHeight(desHeight)
        self.topCell.labelDes.setY( 110 - desHeight / 2 )
        self.userImageURL = "http://img.nian.so/dream/\(self.imgJson)!dream"
        self.topCell.dreamhead!.setImage(self.userImageURL,placeHolder: IconColor)
    }
    
    
    func likeDream(){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(self.Id)"
        LikeVC.urlIdentify = 3
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func onDreamLikeClick(){
        if self.likeJson == "1" {
            self.likeJson = "0"
            self.topCell.btnMain.setTitle("赞", forState: UIControlState.Normal)
            self.topCell.btnMain.removeTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
            self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
            var numLike = self.topCell.numLeftNum.text!.toInt()!
            self.topCell.numLeftNum.text = "\(numLike - 1)"
        }else if self.likeJson == "0" {
            self.likeJson = "1"
            self.topCell.btnMain.setTitle("已赞", forState: UIControlState.Normal)
            self.topCell.btnMain.removeTarget(self, action: "shareDream", forControlEvents: UIControlEvents.TouchUpInside)
            self.topCell.btnMain.addTarget(self, action: "onDreamLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
            var numLike = self.topCell.numLeftNum.text!.toInt()!
            self.topCell.numLeftNum.text = "\(numLike + 1)"
        }
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&cool=\(self.likeJson)", "http://nian.so/api/dream_cool_query.php")
            if sa != "" && sa != "err" {
            }
        })
    }
    
    func onTagClick(){
        if self.hashtag == "0" {
            if self.dreamowner == 1 {
                self.editMyDream(readyForTag: 1)
            }
        }else{
            var TagVC = TagViewController()
            TagVC.Id = self.hashtag
            self.navigationController!.pushViewController(TagVC, animated: true)
        }
    }
    
}

