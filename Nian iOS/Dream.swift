//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, AddCommentDelegate, UIGestureRecognizerDelegate{
    
    let identifier = "dream"
    let identifier2 = "dreamtop"
    let identifier3 = "comment"
    var lefttableView:UITableView?
    var righttableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var toggle:String = "0"
    var deleteSheet:UIActionSheet?
    var replySheet:UIActionSheet?
    var ownerMoreSheet:UIActionSheet?
    var guestMoreSheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var deleteDreamSheet:UIActionSheet?
    var deleteId:Int = 0        //删除按钮的tag，进展编号
    var deleteViewId:Int = 0    //删除按钮的View的tag，indexPath
    
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
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        if toggle == "0" {
            SAReloadData()
        }else{
            SARightReloadData()
        }
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
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(Id)")
        if content[1] as NSString != "" {
            var theimgurl:String = content[1] as String
            var imgurl = NSURL.URLWithString(theimgurl)
            var cacheFilename = imgurl.lastPathComponent
            var cachePath = FileUtility.cachePath(cacheFilename)
            var image:AnyObject = FileUtility.imageDataFromPath(cachePath)
            self.activityViewController = UIActivityViewController(
                activityItems: [ content[0], url, image ],
                applicationActivities: nil)
            self.presentViewController(self.activityViewController!, animated: true, completion: nil)
        }else{
            self.activityViewController = UIActivityViewController(
                activityItems: [ content[0], url ],
                applicationActivities: nil)
            self.presentViewController(self.activityViewController!, animated: true, completion: nil)
        }
    }
    
    func ShareDream(){
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(self.Id)")
        let activityViewController = UIActivityViewController(
            activityItems: [ "喜欢念上的这个梦想！「\(self.titleJson)」", url ],
            applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func setupViews()
    {
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        var width = self.view.frame.size.width
        var height = self.view.frame.size.height - 64
        self.lefttableView = UITableView(frame:CGRectMake(0,0,width,height))
        self.lefttableView!.delegate = self;
        self.lefttableView!.dataSource = self;
        self.lefttableView!.backgroundColor = BGColor
        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.righttableView = UITableView(frame:CGRectMake(0,0,width,height))
        self.righttableView!.delegate = self;
        self.righttableView!.dataSource = self;
        self.righttableView!.backgroundColor = BGColor
        self.righttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"DreamCell", bundle: nil)
        var nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        if toggle == "0" {
            self.lefttableView!.hidden = false
            self.righttableView!.hidden = true
        }else{
            self.lefttableView!.hidden = true
            self.righttableView!.hidden = false
        }
        
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.righttableView?.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.righttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.lefttableView!)
        self.view.addSubview(self.righttableView!)
        
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = IconColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        //主人
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            var url = NSURL(string:"http://nian.so/api/dream.php?id=\(self.Id)&uid=\(safeuid)&shell=\(safeshell)")
            var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var dream: AnyObject! = json.objectForKey("dream")
            var owneruid: String = dream.objectForKey("uid") as String
            self.titleJson = dream.objectForKey("title") as String
            self.percentJson = dream.objectForKey("percent") as String
            self.followJson = dream.objectForKey("follow") as String
            self.likeJson = dream.objectForKey("like") as String
            self.imgJson = dream.objectForKey("img") as String
            self.privateJson = dream.objectForKey("private") as String
            self.contentJson = dream.objectForKey("content") as String
            
            dispatch_async(dispatch_get_main_queue(), {
                if safeuid == owneruid {
                    self.dreamowner = 1
                    var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStepButton")
                    rightButton.image = UIImage(named:"add")
                    var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "ownerMore")
                    moreButton.image = UIImage(named:"more")
                    if self.percentJson == "0" {
                        self.navigationItem.rightBarButtonItems = [ rightButton, moreButton]
                    }else{
                        self.navigationItem.rightBarButtonItems = [ moreButton]
                    }
                }else{
                    self.dreamowner = 0
                    var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "commentVC")
                    rightButton.image = UIImage(named:"bbs_add")
                    var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "guestMore")
                    moreButton.image = UIImage(named:"more")
                    self.navigationItem.rightBarButtonItems = [ rightButton, moreButton]
                }
            })
        })
        
        dispatch_async(dispatch_get_main_queue(), {
            self.activityViewController = UIActivityViewController()
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
    
    
    func loadData()
    {
        var url = urlString()
        // self.refreshView!.startLoading()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull()
            {
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
            }
            self.lefttableView!.reloadData()
            self.lefttableView!.footerEndRefreshing()
            self.page++
        })
    }
    func RightloadData()
    {
        var url = "http://nian.so/api/comment.php?page=\(page)&id=\(Id)"
        // self.refreshView!.startLoading()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull()
            {
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            
            for data : AnyObject  in arr
            {
                self.dataArray2.addObject(data)
            }
            self.righttableView!.reloadData()
            self.righttableView!.footerEndRefreshing()
            self.page++
        })
    }
    
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = "http://nian.so/api/step.php?page=0&id=\(Id)&uid=\(safeuid)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            self.lefttableView!.reloadData()
            self.lefttableView!.headerEndRefreshing()
            self.page = 1
        })
    }
    func SARightReloadData(){
        var url = "http://nian.so/api/comment.php?page=0&id=\(Id)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray2.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray2.addObject(data)
            }
            self.righttableView!.reloadData()
            self.righttableView!.headerEndRefreshing()
            self.page = 1
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
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? DreamCellTop
            var index = indexPath.row
            var dreamid = Id
            c!.dreamid = dreamid
            if tableView == lefttableView {
                c!.Seg!.selectedSegmentIndex = 0
            }else{
                c!.Seg!.selectedSegmentIndex = 1
            }
            c!.Seg!.addTarget(self, action: "hello:", forControlEvents: UIControlEvents.ValueChanged)
            cell = c!
        }else{
            if tableView == lefttableView {
                var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? DreamCell
                var index = indexPath.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                c!.indexPathRow = index
                c!.goodbye!.addTarget(self, action: "SAdelete:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.edit!.addTarget(self, action: "SAedit:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c!.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
                c!.tag = index + 10
                cell = c!
            }else{
                var c = tableView.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? CommentCell
                var index = indexPath.row
                var data = self.dataArray2[index] as NSDictionary
                c!.data = data
                c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                cell = c!
            }
        }
        return cell
    }
    
    func likeclick(sender:UITapGestureRecognizer){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(LikeVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = UserViewController()
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
            return  190
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if tableView == righttableView {
            if indexPath.section != 0 {
            self.righttableView!.deselectRowAtIndexPath(indexPath, animated: false)
            var index = indexPath.row
            var data = self.dataArray2[index] as NSDictionary
            var user = data.stringAttributeForKey("user")
            var uid = data.stringAttributeForKey("uid")
            var content = data.stringAttributeForKey("content")
            var cid = data.stringAttributeForKey("id")
                self.ReplyUser = "\(user)"
                self.ReplyRow = index
                self.ReplyContent = "\(content)"
                self.ReplyCid = "\(cid)"
                self.replySheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                if self.dreamowner == 1 {   //主人
                    self.replySheet!.addButtonWithTitle("回应@\(user)")
                    self.replySheet!.addButtonWithTitle("复制")
                    self.replySheet!.addButtonWithTitle("删除")
                    self.replySheet!.addButtonWithTitle("取消")
                    self.replySheet!.cancelButtonIndex = 3
                    self.replySheet!.showInView(self.view)
                }else{  //不是主人
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
                }
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
        
        self.righttableView!.addHeaderWithCallback({
            self.SARightReloadData()
        })
        
        self.righttableView!.addFooterWithCallback({
            self.RightloadData()
        })
    }
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    func hello(sender: UISegmentedControl){
        var x = sender.selectedSegmentIndex
        if x == 0 {
            sender.selectedSegmentIndex = 1
            self.righttableView!.hidden = true
            self.lefttableView!.hidden = false
            var y = self.righttableView!.contentOffset.y
            self.lefttableView!.setContentOffset(CGPointMake(0, y), animated: false)
            SAReloadData()
        }else if x == 1 {
            sender.selectedSegmentIndex = 0
            self.lefttableView!.hidden = true
            self.righttableView!.hidden = false
            var y = self.lefttableView!.contentOffset.y
            self.righttableView!.setContentOffset(CGPointMake(0, y), animated: false)
            SARightReloadData()
        }
    }
    func SAedit(sender:UIButton){
        var data = self.dataArray[sender.tag] as NSDictionary
        var addstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        addstepVC.isEdit = 1
        addstepVC.data = data
        addstepVC.row = sender.tag
        addstepVC.delegate = self
        self.navigationController!.pushViewController(addstepVC, animated: true)
    }
    
    func SAdelete(sender:UIButton){
        self.deleteId = sender.tag
        var cell:AnyObject
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1){
            cell = sender.superview!.superview!.superview!.superview! as UITableViewCell
            self.deleteViewId = cell.tag
        }else{
            cell = sender.superview!.superview!.superview! as UITableViewCell
            self.deleteViewId = cell.tag
        }
        self.deleteSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.deleteSheet!.addButtonWithTitle("确定")
        self.deleteSheet!.addButtonWithTitle("取消")
        self.deleteSheet!.cancelButtonIndex = 1
        self.deleteSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.deleteSheet {
            if buttonIndex == 0 {
                var visibleCells:NSArray = self.lefttableView!.visibleCells()
                for cell  in visibleCells {
                    if cell.tag == self.deleteViewId {
                        var newpath = self.lefttableView!.indexPathForCell(cell as UITableViewCell)
                        self.dataArray.removeObjectAtIndex(newpath!.row)
                        self.lefttableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                        self.lefttableView!.reloadData()
                        break
                    }
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
                    if(sa == "1"){
                    }
                })
            }
        }else if actionSheet == self.replySheet {
            if buttonIndex == 0 {
                self.commentVC()
            }else if buttonIndex == 1 { //复制
                var pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }else if buttonIndex == 2 {
                var data = self.dataArray2[self.ReplyRow] as NSDictionary
                var uid = data.stringAttributeForKey("uid")
                if (( uid == safeuid ) || ( self.dreamowner == 1 )) {
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
                self.dataArray2.removeObjectAtIndex(self.ReplyRow)
                var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 1)
                self.righttableView!.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.righttableView!.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_comment.php")
                    if(sa == "1"){
                    }
                })
            }
        }else if actionSheet == self.deleteDreamSheet {
            if buttonIndex == 0 {       //删除梦想
                self.navigationItem.rightBarButtonItems = buttonArray()
                //          NSNotificationCenter.defaultCenter().postNotificationName("restartDream", object:"1")
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
                var editdreamVC = AddDreamController(nibName: "AddDreamController", bundle: nil)
                editdreamVC.isEdit = 1
                editdreamVC.editId = self.Id
                editdreamVC.editTitle = self.titleJson
                editdreamVC.editContent = self.contentJson
                editdreamVC.editImage = self.imgJson
                editdreamVC.editPrivate = self.privateJson
                self.navigationController!.pushViewController(editdreamVC, animated: true)
            }else if buttonIndex == 1 { //完成梦想
                var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStepButton")
                rightButton.image = UIImage(named:"add")
                var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "ownerMore")
                moreButton.image = UIImage(named:"more")
                if self.percentJson == "1" {
                    self.percentJson = "0"
                    self.navigationItem.rightBarButtonItems = [ rightButton, moreButton]
                }else if self.percentJson == "0" {
                    self.percentJson = "1"
                    self.navigationItem.rightBarButtonItems = [ moreButton]
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&percent=\(self.percentJson)", "http://nian.so/api/dream_complete_query.php")
                    if sa != "" && sa != "err" {
                    }
                })
            }else if buttonIndex == 2 {     //分享梦想
                ShareDream()
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
                if self.likeJson == "1" {
                    self.likeJson = "0"
                }else if self.likeJson == "0" {
                    self.likeJson = "1"
                }
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("id=\(self.Id)&&uid=\(safeuid)&&shell=\(safeshell)&&cool=\(self.likeJson)", "http://nian.so/api/dream_cool_query.php")
                    if sa != "" && sa != "err" {
                    }
                })
            }else if buttonIndex == 2 { //分享梦想
                ShareDream()
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
    
    func commentVC(){
        var addCommentVC = AddCommentViewController(nibName: "AddCommentViewController", bundle: nil)
        addCommentVC.delegate = self
        if self.ReplyUser != "" {
            addCommentVC.content = "@\(self.ReplyUser) "
        }else{
            addCommentVC.content = ""
        }
        addCommentVC.Id = self.Id
        addCommentVC.Row = self.ReplyRow
        self.navigationController!.pushViewController(addCommentVC, animated: true)
    }
    
    func commentFinish(){
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeuser = Sa.objectForKey("user") as String
        
        var newinsert = NSDictionary(objects: ["\(self.ReturnReplyContent)", "\(self.ReturnReplyId)", "0s", "\(safeuid)", "\(safeuser)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
        self.dataArray2.insertObject(newinsert, atIndex: self.ReturnReplyRow)
        var newindexpath = NSIndexPath(forRow: self.ReturnReplyRow, inSection: 1)
        self.righttableView!.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.Bottom)
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
    
    
    func DreamimageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController!.pushViewController(imgVC, animated: true)
    }
    
    
}
