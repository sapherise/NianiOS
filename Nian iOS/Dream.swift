//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, EditstepDelegate, AddCommentDelegate{     //😍
    
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
    var deleteCommentSheet:UIActionSheet?
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
    
    var ReturnReplyContent:String = ""
    var ReturnReplyId:String = ""
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
    }
    override func viewDidAppear(animated: Bool) {
        if EditId == 0 {
            if toggle == "0" {
                SAReloadData()
            }else{
                SARightReloadData()
            }
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
            let activityViewController = UIActivityViewController(
                activityItems: [ content[0], url, image ],
                applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }else{
            let activityViewController = UIActivityViewController(
                activityItems: [ content[0], url ],
                applicationActivities: nil)
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    func setupViews()
    {
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
        
        
        self.title = "梦想"
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.righttableView?.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.righttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.lefttableView!)
        self.view.addSubview(self.righttableView!)
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStepButton")
        rightButton.image = UIImage(named:"add")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = IconColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        //主人
        var Sa = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = NSURL(string:"http://nian.so/api/dream.php?id=\(Id)&uid=\(safeuid)&shell=\(safeshell)")
        var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
        var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        var dream: AnyObject! = json.objectForKey("dream")
        var owneruid: String = dream.objectForKey("uid") as String
        if safeuid == owneruid {
            self.dreamowner = 1
        }else{
            self.dreamowner = 0
        }
        
        var swipe = UISwipeGestureRecognizer(target: self, action: "back")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipe)
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
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        
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
        if indexPath.section != 0 {
            self.righttableView!.deselectRowAtIndexPath(indexPath, animated: false)
            var index = indexPath.row
            var data = self.dataArray2[index] as NSDictionary
            var user = data.stringAttributeForKey("user")
            var uid = data.stringAttributeForKey("uid")
            var content = data.stringAttributeForKey("content")
            var cid = data.stringAttributeForKey("id")
            if tableView == righttableView {
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
                }else{  //不是主人
                    var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    var safeuid = Sa.objectForKey("uid") as String
                    if uid == safeuid {
                        self.replySheet!.addButtonWithTitle("回应@\(user)")
                        self.replySheet!.addButtonWithTitle("复制")
                        self.replySheet!.addButtonWithTitle("删除")
                        self.replySheet!.addButtonWithTitle("取消")
                        self.replySheet!.cancelButtonIndex = 3
                    }else{
                        self.replySheet!.addButtonWithTitle("回应@\(user)")
                        self.replySheet!.addButtonWithTitle("复制")
                        self.replySheet!.addButtonWithTitle("取消")
                        self.replySheet!.cancelButtonIndex = 2
                    }
                }
                self.replySheet!.showInView(self.view)
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
        println("改好了")
        var newid = self.EditId - 10
        self.dataArray[newid].setObject(self.EditContent, forKey: "content")
        var newpath = NSIndexPath(forRow: newid, inSection: 1)
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
            SAReloadData()
        }else if x == 1 {
            sender.selectedSegmentIndex = 0
            self.lefttableView!.hidden = true
            self.righttableView!.hidden = false
            SARightReloadData()
        }
    }
    func SAedit(sender:UIButton){
        var tag = sender.tag
        var cell:AnyObject
        var EditVC = EditStepViewController(nibName: "EditStepViewController", bundle: nil)
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1){
            cell = sender.superview!.superview!.superview!.superview! as UITableViewCell
            EditVC.pushEditId = cell.tag
        }else{
            cell = sender.superview!.superview!.superview! as UITableViewCell
            EditVC.pushEditId = cell.tag
        }
        EditVC.sid = "\(sender.tag)"
        EditVC.delegate = self
        self.navigationController!.pushViewController(EditVC, animated: true)
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
                        break
                    }
                }
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
                    if(sa == "1"){
                    }
                }
            }else if actionSheet == self.replySheet {
                if buttonIndex == 0 {
                    var addCommentVC = AddCommentViewController(nibName: "AddCommentViewController", bundle: nil)
                    addCommentVC.delegate = self
                    addCommentVC.content = "@\(self.ReplyUser) "
                    addCommentVC.Id = self.Id
                    addCommentVC.Row = self.ReplyRow
                    self.navigationController!.pushViewController(addCommentVC, animated: true)
                }else if buttonIndex == 1 { //复制
                    var pasteBoard = UIPasteboard.generalPasteboard()
                    pasteBoard.string = self.ReplyContent
                }else if buttonIndex == 2 {
                    if buttonIndex != self.replySheet!.cancelButtonIndex{
                        self.deleteCommentSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                        self.deleteCommentSheet!.addButtonWithTitle("确定删除")
                        self.deleteCommentSheet!.addButtonWithTitle("取消")
                        self.deleteCommentSheet!.cancelButtonIndex = 1
                        self.deleteCommentSheet!.showInView(self.view)
                    }
                }
        }else if actionSheet == self.deleteCommentSheet {
                if buttonIndex == 0 {
                    self.dataArray2.removeObjectAtIndex(self.ReplyRow)
                    var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 1)
                    self.righttableView!.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.Fade)
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_comment.php")
                    println(self.ReplyCid)
                    if(sa == "1"){
                    }
                }
        }
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
