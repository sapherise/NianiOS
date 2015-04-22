//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class BBSViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,  UIActionSheetDelegate, AddBBSCommentDelegate, UIGestureRecognizerDelegate{
    
    let identifier = "bbs"
    let identifier2 = "bbstop"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var topcontent:String = ""
    var topuid:String = ""
    var toplastdate:String = ""
    var topuser:String = ""
    var getContent: Int = 0
    var toptitle:String = ""
    var sheet:UIActionSheet?
    var deleteCommentSheet:UIActionSheet?
    var reportSheet:UIActionSheet?
    var ReplyUser:String = ""
    var ReplyContent:String = ""
    var ReplyRow:Int = 0
    var ReplyCid:String = ""
    
    
    var ReturnReplyRow:Int = 0
    var ReturnReplyContent:String = ""
    var ReturnReplyId:String = ""
    var navView:UIView!
    
    var flow:Int = 0    //默认为 0 正序，当为 1 的时候为倒序
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData(flow: self.flow)
    }
    
    func setupViews()
    {
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.viewBack()
        self.tableView = UITableView(frame:CGRectMake(0,64,globalWidth,globalHeight-64))
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = BGColor
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"BBSCell", bundle: nil)
        var nib2 = UINib(nibName:"BBSCellTop", bundle: nil)
        
        
        self.title = "记本"
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.tableView)
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStepButton")
        rightButton.image = UIImage(named:"newcomment")
        
        var moreButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "bbsMore")
        moreButton.image = UIImage(named:"more")
        
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        if safeuid == self.topuid {
            self.navigationItem.rightBarButtonItems = [ rightButton ]
        }else{
            self.navigationItem.rightBarButtonItems = [ rightButton,moreButton ]
        }
        
        
        
        //标题颜色
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
    }
    
    
    func loadData(flow:Int = 0)
    {
        var url = "http://nian.so/api/bbs_comment.php?page=\(page)&id=\(Id)"
        if flow == 1 {
            url = "http://nian.so/api/bbs_comment.php?page=\(page)&id=\(Id)&flow=1"
        }
        // self.refreshView!.startLoading()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull() {
                var arr = data["items"] as! NSArray
                if ( data["total"] as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
                for data : AnyObject  in arr
                {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                self.tableView.footerEndRefreshing()
                self.page++
            }
        })
    }
    
    func SAReloadData(flow:Int = 0){
        self.tableView!.setFooterHidden(false)
        Api.getBBSComment(0, flow: flow, id: Id) { json in
            if json != nil {
                var arr = json!["items"] as! NSArray
                var total = json!["total"] as! Int
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                if self.getContent == 1 {
                    Api.getBBSTop(self.Id) { json in
                        if json != nil {
                            var data = json!["bbstop"] as! NSDictionary
                            self.toptitle = data.stringAttributeForKey("title")
                            self.topcontent = data.stringAttributeForKey("content")
                            self.topuid = data.stringAttributeForKey("uid")
                            self.topuser = data.stringAttributeForKey("user")
                            self.toplastdate = data.stringAttributeForKey("lastdate")
                            self.tableView!.reloadData()
                            self.tableView!.headerEndRefreshing()
                            self.page = 1
                            if total < 30 {
                                self.tableView!.setFooterHidden(true)
                            }
                        }
                    }
                }else{
                    self.tableView!.reloadData()
                    self.tableView!.headerEndRefreshing()
                    self.page = 1
                    if ( json!["total"] as! Int ) < 30 {
                        self.tableView!.setFooterHidden(true)
                    }
                }
            }
        }
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
            c!.topcontent = self.topcontent
            c!.topuid = self.topuid
            c!.toplastdate = self.toplastdate
            c!.topuser = self.topuser
            c!.Id = "\(self.Id)"
            c!.toptitle = self.toptitle
            c!.dreamhead?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            c!.viewFlow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFlowClick"))
            if self.flow == 1 {
                c!.viewFlow.text = "倒序"
            }else{
                c!.viewFlow.text = "正序"
            }
            if self.dataArray.count == 0 {
                c!.Line!.hidden = true
            }else{
                c!.Line!.hidden = false
            }
            cell = c!
        }else{
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? BBSCell
            var index = indexPath.row
            var data = self.dataArray[index] as! NSDictionary
            c!.data = data
            c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
            if indexPath.row == self.dataArray.count - 1 {
                c!.Line!.hidden = true
            }else{
                c!.Line!.hidden = false
            }
            cell = c!
        }
        return cell
    }
    
    func onFlowClick(){
        self.flow = ( self.flow == 1 ? 0 : 1 )
        self.SAReloadData(flow: self.flow)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = PlayerViewController()
        UserVC.Id = "\(sender.view!.tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section==0{
            return BBSCellTop.cellHeightByData(self.topcontent, toptitle: self.toptitle)
        }else{
            var index = indexPath.row
            var data = self.dataArray[index] as! NSDictionary
            return  BBSCell.cellHeightByData(data)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if indexPath.section != 0{
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: false)
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as! String
            var index = indexPath.row
            var data = self.dataArray[index] as! NSDictionary
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
                    self.sheet!.addButtonWithTitle("标记为不合适")
                    self.sheet!.addButtonWithTitle("取消")
                    self.sheet!.cancelButtonIndex = 3
                }
            }
            self.sheet!.showInView(self.view)
            
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeshell = Sa.objectForKey("shell") as! String
        if actionSheet == self.sheet {
            if buttonIndex == 0 {
                var addVC = AddBBSCommentViewController(nibName: "AddBBSComment", bundle: nil)
                addVC.delegate = self
                addVC.content = "@\(self.ReplyUser) "
                addVC.Id = self.Id
                addVC.Row = self.ReplyRow
                self.navigationController?.pushViewController(addVC, animated: true)
            }else if buttonIndex == 1 { //复制
                var pasteBoard = UIPasteboard.generalPasteboard()
                pasteBoard.string = self.ReplyContent
            }else if buttonIndex == 2 {
                var data = self.dataArray[self.ReplyRow] as! NSDictionary
                var uid = data.stringAttributeForKey("uid")
                if (( uid == safeuid ) || ( self.topuid == safeuid )) {
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
                self.dataArray.removeObjectAtIndex(self.ReplyRow)
                var deleteCommentPath = NSIndexPath(forRow: self.ReplyRow, inSection: 1)
                self.tableView!.deleteRowsAtIndexPaths([deleteCommentPath], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView!.reloadData()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("uid=\(safeuid)&shell=\(safeshell)&cid=\(self.ReplyCid)", "http://nian.so/api/delete_bbscomment.php")
                if(sa == "1"){
                }
                })
            }
        }else if actionSheet == self.reportSheet {
            if buttonIndex == 0 {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    var sa = SAPost("uid=1", "http://nian.so/api/a.php")
                    if(sa == "1"){
                        dispatch_async(dispatch_get_main_queue(), {
                            UIView.showAlertView("谢谢", message: "如果这个话题不合适，我们会将其移除。")
                        })
                    }
                })
            }
        }
    }
    
    func commentFinish(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        var safeuser = Sa.objectForKey("user") as! String
        var newinsert = NSDictionary(objects: ["\(self.ReturnReplyContent)", "\(self.ReturnReplyId)", "0s", "\(safeuid)", "\(safeuser)"], forKeys: ["content", "id", "lastdate", "uid", "user"])
        self.dataArray.insertObject(newinsert, atIndex: self.ReturnReplyRow)
        var newindexpath = NSIndexPath(forRow: self.ReturnReplyRow, inSection: 1)
        self.tableView!.insertRowsAtIndexPaths([ newindexpath ], withRowAnimation: UITableViewRowAnimation.Bottom)
    }
    
    
    
    func addStepButton(){
        var addVC = AddBBSCommentViewController(nibName: "AddBBSComment", bundle: nil)
        addVC.delegate = self
        addVC.content = ""
        addVC.Id = self.Id
        addVC.Row = self.ReplyRow
        self.navigationController?.pushViewController(addVC, animated: true)
    }
    
    func bbsMore(){
        self.reportSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.reportSheet!.addButtonWithTitle("标记为不合适")
        self.reportSheet!.addButtonWithTitle("取消")
        self.reportSheet!.cancelButtonIndex = 1
        self.reportSheet!.showInView(self.view)
    }
    
    func countUp() {      //😍
        self.SAReloadData()
    }
    
    
    func Editstep() {      //😍
        self.SAReloadData()
    }
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData(flow: self.flow)
        })
        
        self.tableView!.addFooterWithCallback({
            self.loadData(flow: self.flow)
        })
    }
}
