//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class UserViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, AddstepDelegate, EditstepDelegate{     //😍
    
    let identifier = "user"
    let identifier2 = "usertop"
    let identifier3 = "step"
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
        var nib = UINib(nibName:"UserCell", bundle: nil)
        var nib2 = UINib(nibName:"UserCellTop", bundle: nil)
        var nib3 = UINib(nibName:"StepCell", bundle: nil)
        
        
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
        var url = "http://nian.so/api/user_dream.php?page=\(page)&uid=\(Id)"
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
        var url = "http://nian.so/api/user_active.php?page=0&uid=\(Id)&myuid=1"
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
        var url = "http://nian.so/api/user_dream.php?page=0&uid=\(Id)"
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
        return "http://nian.so/api/user_active.php?page=\(page)&uid=\(Id)&myuid=1"
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
            if tableView == lefttableView {
                return self.dataArray.count
            }else{
                var thecount:Int
                if ( self.dataArray2.count % 3 > 0 ) {
                    thecount = (self.dataArray2.count)/3 + 1
                }else{
                    thecount = (self.dataArray2.count)/3
                }
                return thecount
            }
        }
    }
    
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        var cell:UITableViewCell
        
        if indexPath!.section==0{
            var c = tableView?.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? UserCellTop
            var index = indexPath!.row
            c!.userid = Id
            if tableView == lefttableView {
                c!.Seg!.selectedSegmentIndex = 0
            }else{
                c!.Seg!.selectedSegmentIndex = 1
            }
            c!.Seg!.addTarget(self, action: "hello:", forControlEvents: UIControlEvents.ValueChanged)
            cell = c!
        }else{
            if tableView == lefttableView {
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? UserCell
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                c!.goodbye!.addTarget(self, action: "SAdelete:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.edit!.addTarget(self, action: "SAedit:", forControlEvents: UIControlEvents.TouchUpInside)
                c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                c!.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
                cell = c!
            }else{
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? StepCell
                var dictionary:Dictionary<String, String> = ["id":"", "title":"", "img":"", "percent":""]
                var index = indexPath!.row * 3
                if index<self.dataArray2.count {
                    c!.data1 = self.dataArray2[index] as NSDictionary
                    c!.img1?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                c!.data1 = dictionary
                }
                if index+1<self.dataArray2.count {
                    c!.data2 = self.dataArray2[index + 1] as NSDictionary
                    c!.img2?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data2 = dictionary
                }
                if index+2<self.dataArray2.count {
                    c!.data3 = self.dataArray2[index + 2] as NSDictionary
                    c!.img3?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                }else{
                    c!.data3 = dictionary
                }
                cell = c!
            }
        }
        return cell
    }
    
    func likeclick(sender:UITapGestureRecognizer){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view.tag)"
        self.navigationController.pushViewController(LikeVC, animated: true)
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = UserViewController()
        UserVC.Id = "\(sender.view.tag)"
        self.navigationController.pushViewController(UserVC, animated: true)
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view.tag)"
        self.navigationController.pushViewController(DreamVC, animated: true)
    }
    
    func imageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController.pushViewController(imgVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        
        if indexPath.section==0{
            return  190
        }else{
            if tableView == lefttableView {
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                return  UserCell.cellHeightByData(data)
            }else{
                return  140
            }
        }
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
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
        var EditVC = EditStepViewController(nibName: "EditStepViewController", bundle: nil)
        EditVC.sid = "\(sender.tag)"
        EditVC.delegate = self
        //        AddstepVC.Id = self.Id
        //        AddstepVC.delegate = self    //😍
        self.navigationController.pushViewController(EditVC, animated: true)
    }
    func SAdelete(sender:UIButton){
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
            var sa = SAPost("sa=223&uid=1&sid=\(alertView.tag)", "http://nian.so/api/delete_step.php")
            var tag = alertView.tag
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
