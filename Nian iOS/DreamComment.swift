//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamCommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, AddCommentDelegate, UIGestureRecognizerDelegate{
    
    let identifier = "dream"
    let identifier2 = "dreamtop"
    let identifier3 = "comment"
    var righttableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var toggle:String = "1"
    var deleteSheet:UIActionSheet?
    var replySheet:UIActionSheet?
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
    var likestepJson: String = ""
    var liketotalJson: Int = 0
    var stepJson: String = ""
    var desJson:String = ""
    
    var desHeight:CGFloat = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SARightReloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func ShareContent(noti:NSNotification){
        var content:AnyObject = noti.object!
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(Id)")!
        
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
        
        
        if content[1] as NSString != "" {
            var theimgurl:String = content[1] as String
            var imgurl = NSURL(string: theimgurl)!
            var cacheFilename = imgurl.lastPathComponent
            var cachePath = FileUtility.cachePath(cacheFilename)
            var image:AnyObject = FileUtility.imageDataFromPath(cachePath)
            self.activityViewController = UIActivityViewController(
                activityItems: [ content[0], url, image ],
                applicationActivities: [ customActivity ])
            self.activityViewController?.excludedActivityTypes = [
                UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
            ]
            self.presentViewController(self.activityViewController!, animated: true, completion: nil)
        }else{
            self.activityViewController = UIActivityViewController(
                activityItems: [ content[0], url ],
                applicationActivities: [ customActivity ])
            self.activityViewController?.excludedActivityTypes = [
                UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint
            ]
            self.presentViewController(self.activityViewController!, animated: true, completion: nil)
        }
    }
    
    func setupViews()
    {
        viewBack(self)
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.blackColor()
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        self.righttableView = UITableView(frame:CGRectMake(0,64,globalWidth,globalHeight - 64))
        self.righttableView!.delegate = self;
        self.righttableView!.dataSource = self;
        self.righttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        self.righttableView?.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.view.addSubview(self.righttableView!)
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.text = "进展回应"
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as CommentCell
        var index = indexPath.row
        var data = self.dataArray2[index] as NSDictionary
        c.data = data
        c.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
        cell = c
        return cell
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = UserViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
                var index = indexPath!.row
                var data = self.dataArray2[index] as NSDictionary
                return  CommentCell.cellHeightByData(data)
    }
    
    func setupRefresh(){
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
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.replySheet {
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
                var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 0)
                self.righttableView!.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.righttableView!.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_comment.php")
                    if(sa == "1"){
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
        var newindexpath = NSIndexPath(forRow: self.ReturnReplyRow, inSection: 0)
        self.righttableView!.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray2.count
    }
}

