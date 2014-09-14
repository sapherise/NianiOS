//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class BBSViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,  UIActionSheetDelegate, AddBBSCommentDelegate{     //😍
    
    let identifier = "bbs"
    let identifier2 = "bbstop"
    var lefttableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var topcontent:String = ""
    var topuid:String = ""
    var toplastdate:String = ""
    var topuser:String = ""
    var getContent:String = "0"
    var toptitle:String = ""
    var sheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var ReplyUser:String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    
    
    var ReturnReplyRow:Int = 0
    var ReturnReplyContent:String = ""
    var ReturnReplyId:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
    }
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
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
        
        var nib = UINib(nibName:"BBSCell", bundle: nil)
        var nib2 = UINib(nibName:"BBSCellTop", bundle: nil)
        
        
        self.title = "梦想"
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.lefttableView!)
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStepButton")
        rightButton.image = UIImage(named:"bbs_add")
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
    
    func SAReloadData(){
        var url = "http://nian.so/api/bbs_comment.php?page=0&id=\(Id)"
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
    
    func urlString()->String
    {
        return "http://nian.so/api/bbs_comment.php?page=\(page)&id=\(Id)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return 1
        }else{
                return self.dataArray.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if indexPath.section==0{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? BBSCellTop
            c!.topcontent = topcontent
            c!.topuid = topuid
            c!.toplastdate = toplastdate
            c!.topuser = topuser
            c!.Id = "\(Id)"
            c!.getContent = getContent
            c!.toptitle = toptitle
            c!.dreamhead?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
          //  self.dreamhead!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            cell = c!
        }else{
                var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? BBSCell
                var index = indexPath.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                cell = c!
        }
        return cell
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        if indexPath.section==0{
            if getContent == "0" {
                return  BBSCellTop.cellHeightByData(topcontent, toptitle: toptitle)
            }else{
                var url = NSURL(string:"http://nian.so/api/bbstop.php?id=\(Id)")
                var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
                var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
                var sa: AnyObject! = json.objectForKey("bbstop")
                toptitle = sa.objectForKey("title") as String
                topcontent = sa.objectForKey("content") as String
                return  BBSCellTop.cellHeightByData(topcontent, toptitle: toptitle)
            }
        }else{
                var index = indexPath.row
                var data = self.dataArray[index] as NSDictionary
                return  BBSCell.cellHeightByData(data)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section != 0{
            self.lefttableView!.deselectRowAtIndexPath(indexPath, animated: false)
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            var user = data.stringAttributeForKey("user")
            var uid = data.stringAttributeForKey("uid")
            var content = data.stringAttributeForKey("content")
            var cid = data.stringAttributeForKey("id")
            
            self.ReplyContent = content
            self.ReplyUser = "\(user)"
            self.ReplyRow = index
            self.ReplyCid = "\(cid)"
            
            self.sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
            if self.topuid == safeuid {   //主人
                self.sheet!.addButtonWithTitle("回应@\(user)")
                self.sheet!.addButtonWithTitle("复制")
                self.sheet!.addButtonWithTitle("删除")
                self.sheet!.addButtonWithTitle("取消")
                self.sheet!.cancelButtonIndex = 3
            }else{  //不是主人
                if uid == safeuid {
                    self.sheet!.addButtonWithTitle("回应@\(user)")
                    self.sheet!.addButtonWithTitle("复制")
                    self.sheet!.addButtonWithTitle("删除")
                    self.sheet!.addButtonWithTitle("取消")
                    self.sheet!.cancelButtonIndex = 3
                }else{
                    self.sheet!.addButtonWithTitle("回应@\(user)")
                    self.sheet!.addButtonWithTitle("复制")
                    self.sheet!.addButtonWithTitle("取消")
                    self.sheet!.cancelButtonIndex = 2
                }
            }
            self.sheet!.showInView(self.view)
            
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        if actionSheet == self.sheet {
            if buttonIndex == 0 {
                var addVC = AddBBSCommentViewController(nibName: "AddBBSComment", bundle: nil)
                addVC.delegate = self
                addVC.content = "@\(self.ReplyUser) "
                addVC.Id = self.Id
                addVC.Row = self.ReplyRow
                self.navigationController!.pushViewController(addVC, animated: true)
            }else if buttonIndex == 1 { //复制
                var pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }else if buttonIndex == 2 {
                if buttonIndex != self.sheet!.cancelButtonIndex{
                    self.deleteCommentSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    self.deleteCommentSheet!.addButtonWithTitle("确定删除")
                    self.deleteCommentSheet!.addButtonWithTitle("取消")
                    self.deleteCommentSheet!.cancelButtonIndex = 1
                    self.deleteCommentSheet!.showInView(self.view)
                }
            }
        }else if actionSheet == self.deleteCommentSheet {
            if buttonIndex == 0 {
                self.dataArray.removeObjectAtIndex(self.ReplyRow)
                var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 1)
                self.lefttableView!.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.Fade)
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_bbscomment.php")
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
        self.dataArray.insertObject(newinsert, atIndex: self.ReturnReplyRow)
        var newindexpath = NSIndexPath(forRow: self.ReturnReplyRow, inSection: 1)
        self.lefttableView!.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    
    
    func addStepButton(){
        var addVC = AddBBSCommentViewController(nibName: "AddBBSComment", bundle: nil)
        addVC.delegate = self
        addVC.content = ""
        addVC.Id = self.Id
        addVC.Row = self.ReplyRow
        self.navigationController!.pushViewController(addVC, animated: true)
    }
    
    func countUp() {      //😍
        self.SAReloadData()
    }
    
    
    func Editstep() {      //😍
        self.SAReloadData()
    }
    func setupRefresh(){
        self.lefttableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
        
        self.lefttableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
