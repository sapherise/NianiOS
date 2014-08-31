//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class DreamViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, AddstepDelegate, EditstepDelegate{     //😍
    
    let identifier = "dream"
    let identifier2 = "dreamtop"
    let identifier3 = "comment"
    var lefttableView:UITableView?
    var righttableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        self.lefttableView!.headerBeginRefreshing()
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
        var content:AnyObject = noti.object
        println(content)
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
        self.righttableView!.hidden = true
        
        var nib = UINib(nibName:"DreamCell", bundle: nil)
        var nib2 = UINib(nibName:"DreamCellTop", bundle: nil)
        var nib3 = UINib(nibName:"CommentCell", bundle: nil)
        
        
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
        self.navigationController.navigationBar.tintColor = IconColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
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
                self.dataArray.addObject(data)
            }
            self.righttableView!.reloadData()
            self.righttableView!.footerEndRefreshing()
            self.page++
            })
    }
    
    
    func SAReloadData(){
        var url = "http://nian.so/api/step.php?page=0&id=\(Id)"
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
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            self.righttableView!.reloadData()
            self.righttableView!.headerEndRefreshing()
            self.page = 1
            })
    }
    
    
    
    
    func urlString()->String
    {
        return "http://nian.so/api/step.php?page=\(page)&id=\(Id)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        var cell:UITableViewCell
        
        if indexPath!.section==0{
            var c = tableView?.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? DreamCellTop
            var index = indexPath!.row
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
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? DreamCell
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                c!.goodbye!.addTarget(self, action: "SAdelete:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.edit!.addTarget(self, action: "SAedit:", forControlEvents: UIControlEvents.TouchUpInside)
                cell = c!
            }else{
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? CommentCell
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                var tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "SAreply:")
                c!.avatarView!.addGestureRecognizer(tap)
                cell = c!
            }
        }
        return cell
    }
    
    func imageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController.pushViewController(imgVC, animated: true)
    }
    
    func SAreply(sender:UITapGestureRecognizer){
        println(sender.view.tag)
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
                var data = self.dataArray[index] as NSDictionary
                return  CommentCell.cellHeightByData(data)
            }
        }
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
    }
    
    
    func addStepButton(){
        var AddstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        AddstepVC.Id = self.Id
        AddstepVC.delegate = self    //😍
        self.navigationController.pushViewController(AddstepVC, animated: true)
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
        
        self.righttableView!.addHeaderWithCallback({
            self.SARightReloadData()
            })
        
        self.righttableView!.addFooterWithCallback({
            self.RightloadData()
            })
    }
    func back(){
        self.navigationController.popViewControllerAnimated(true)
    }
    func hello(sender: AnyObject){
        var control:UISegmentedControl = sender as UISegmentedControl
        var x = control.selectedSegmentIndex
        if x == 0 {
            self.righttableView!.hidden = true
            self.lefttableView!.hidden = false
            SAReloadData()
        }else if x == 1 {
            self.lefttableView!.hidden = true
            self.righttableView!.hidden = false
            SARightReloadData()
        }
    }
    func SAedit(sender:UIButton){
        var tag = sender.tag
        println(tag)
        
        var EditVC = EditStepViewController(nibName: "EditStepViewController", bundle: nil)
        EditVC.sid = "\(sender.tag)"
        EditVC.delegate = self
//        AddstepVC.Id = self.Id
//        AddstepVC.delegate = self    //😍
        self.navigationController.pushViewController(EditVC, animated: true)
        
//        var button:UIButton = self.lefttableView!.viewWithTag(sender.tag) as UIButton
//        button.hidden = true
//        var theview:UIView? = button.superview?.superview as UIView?
//        theview?.backgroundColor = BlueColor
//        theview.
//        var cell:UITableViewCell = button.superview?.superview?.superview as UITableViewCell
//        var indexPath = self.lefttableView!.indexPathForCell(cell)
//        self.dataArray.removeObjectAtIndex(indexPath.row)
//        self.lefttableView!.deleteRowsAtIndexPaths([ indexPath ], withRowAnimation: UITableViewRowAnimation.Fade)
    }
    func SAdelete(sender:UIButton){
        println("删除")
        if NSClassFromString("UIAlertController") != nil {
            var alertController = UIAlertController(title: "再见", message: "进展 #\(sender.tag)", preferredStyle: UIAlertControllerStyle.ActionSheet)
            var deleteConfirm = UIAlertAction(title: "确定", style: UIAlertActionStyle.Default){ action in
                var sa = SAPost("sa=223&&uid=1&sid=\(sender.tag)", "http://nian.so/api/delete_step.php")
                if(sa == "1"){
                    var button:UIButton = self.lefttableView!.viewWithTag(sender.tag) as UIButton
                    var cell:UITableViewCell = button.superview?.superview?.superview as UITableViewCell
                    var indexPath = self.lefttableView!.indexPathForCell(cell)
                    self.dataArray.removeObjectAtIndex(indexPath.row)
                    self.lefttableView!.deleteRowsAtIndexPaths([ indexPath ], withRowAnimation: UITableViewRowAnimation.Fade)
                }
            }       //这是删除按钮
            alertController.addAction(deleteConfirm)
            alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))   //取消按钮
            self.presentViewController(alertController, animated: true, completion:nil)
        } else {
            var alertTest = UIAlertView()
            alertTest.delegate = self
            alertTest.title = "再见"
            alertTest.message = "进展 #\(sender.tag)"
            alertTest.tag = sender.tag
            alertTest.addButtonWithTitle("确认")
            alertTest.addButtonWithTitle("取消")
            alertTest.show()
        }
    }
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            println("确定")
            var sa = SAPost("sa=223&uid=1&sid=\(alertView.tag)", "http://nian.so/api/delete_step.php")
            var tag = alertView.tag
            println(tag)
            if(sa == "1"){
                var button:UIButton = self.lefttableView!.viewWithTag(alertView.tag) as UIButton
                var cell:UITableViewCell = button.superview?.superview?.superview as UITableViewCell
//                cell.hidden = true
                var indexPath = self.lefttableView!.indexPathForCell(cell)
                self.dataArray.removeObjectAtIndex(indexPath.row)
                self.lefttableView!.deleteRowsAtIndexPaths([ indexPath ], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        case 1:
            println("取消")
        default:
            println("错误")
        }
    }
    
    
    func DreamimageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController.pushViewController(imgVC, animated: true)
    }

    
}
