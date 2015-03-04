//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SingleStepViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, UIGestureRecognizerDelegate{
    
    let identifier = "dream"
    let identifier3 = "comment"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
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
    
    var owneruid: String = ""
    
    var desHeight:CGFloat = 0
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    var topCell:DreamCellTop!
    var userImageURL:String = "0"
    
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
    
    func setupViews()
    {
        self.viewBack()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"DreamCell", bundle: nil)
        var nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView!)
        
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "进展"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        self.tableView?.setFooterHidden(false)
        Api.getSingleStep(self.Id) { json in
            if json != nil {
                self.dataArray.removeAllObjects()
                var uid = json!["uid"] as String
                var thePrivate = json!["private"] as String
                var arr = json!["items"] as NSArray
                if thePrivate == "2" {
                    // 删除
                    var viewTop = viewEmpty(globalWidth, content: "这条进展\n不见了")
                    viewTop.setY(40)
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    viewHolder.addSubview(viewTop)
                    self.tableView?.tableHeaderView = viewHolder
                }else{
                    for data: AnyObject in arr {
                        var theData = data as NSDictionary
                        var hidden = theData.stringAttributeForKey("hidden")
                        if hidden == "1" {
                            var viewTop = viewEmpty(globalWidth, content: "这条进展\n不见了")
                            viewTop.setY(40)
                            var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                            viewHolder.addSubview(viewTop)
                            self.tableView?.tableHeaderView = viewHolder
                        }else{
                            self.dataArray.addObject(data)
                        }
                    }
                }
                self.dreamowner = safeuid == uid ? 1 : 0
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as DreamCell
        var index = indexPath.row
        var data = self.dataArray[index] as NSMutableDictionary
        c.data = data
        c.indexPathRow = index
        c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
        c.nickLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
        c.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
        c.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentClick:"))
        c.imageholder!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
        c.likebutton.addTarget(self, action: "onLikeTap:", forControlEvents: UIControlEvents.TouchUpInside)
        c.liked.addTarget(self, action: "onLikedTap:", forControlEvents: UIControlEvents.TouchUpInside)
        c.tag = index + 10
        c.likebutton.tag = index
        c.liked.tag = index
        if indexPath.row == self.dataArray.count - 1 {
            c.viewLine.hidden = true
        }else{
            c.viewLine.hidden = false
        }
        cell = c
        return cell
    }
    
    // 赞
    func onLikeTap(sender: UIButton) {
        var tag = sender.tag
        var data = self.dataArray[tag] as NSDictionary
        if let numLike = data.stringAttributeForKey("like").toInt() {
            var numNew = numLike + 1
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setValue("\(numNew)", forKey: "like")
            mutableItem.setValue("1", forKey: "liked")
            self.dataArray.replaceObjectAtIndex(tag, withObject: mutableItem)
            self.tableView?.reloadData()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "1") { json in
            }
        }
    }
    
    // 取消赞
    func onLikedTap(sender: UIButton) {
        var tag = sender.tag
        var data = self.dataArray[tag] as NSDictionary
        if let numLike = data.stringAttributeForKey("like").toInt() {
            var numNew = numLike - 1
            var mutableItem = NSMutableDictionary(dictionary: data)
            mutableItem.setValue("\(numNew)", forKey: "like")
            mutableItem.setValue("0", forKey: "liked")
            self.dataArray.replaceObjectAtIndex(tag, withObject: mutableItem)
            self.tableView?.reloadData()
            var sid = data.stringAttributeForKey("sid")
            Api.postLike(sid, like: "0") { json in
            }
        }
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view  = self.findTableCell(sender.view)!
        var img = dataArray[view.tag - 10].objectForKey("img") as String
        var img0 = dataArray[view.tag - 10].objectForKey("img0") as NSString
        var img1 = dataArray[view.tag - 10].objectForKey("img1") as NSString
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
        var dream:String = self.dataArray[0].objectForKey("dream") as String
        var tag = sender.view!.tag
        var DreamCommentVC = DreamCommentViewController()
        DreamCommentVC.dreamID = dream.toInt()!
        DreamCommentVC.stepID = self.Id.toInt()!
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
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        return  DreamCell.cellHeightByData(data)
    }
    
    func Editstep() {      //😍
        var newpath = NSIndexPath(forRow: self.editStepRow, inSection: 0)
        self.tableView!.reloadRowsAtIndexPaths([newpath], withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    func countUp(){
        
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.deleteSheet {
            if buttonIndex == 0 {
                var newpath = NSIndexPath(forRow: 0, inSection: 0)
                self.dataArray.removeObjectAtIndex(newpath!.row)
                self.tableView!.deleteRowsAtIndexPaths([newpath!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView!.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&sid=\(self.deleteId)", "http://nian.so/api/delete_step.php")
                    if(sa == "1"){
                    }
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
}

