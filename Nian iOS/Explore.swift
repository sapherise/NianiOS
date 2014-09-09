//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class ExploreController: UIViewController,UITableViewDelegate,UITableViewDataSource{     //😍
    
    let identifier = "group"
    let identifier2 = "exploretop"
    let identifier3 = "exploreall"
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
        //        [[self navigationController] setNavigationBarHidden:YES];
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    
    func setupViews()
    {
        var width = self.view.frame.size.width
        var height = self.view.frame.size.height - 64
        self.lefttableView = UITableView(frame:CGRectMake(0,0,width,height - 49))
        self.lefttableView!.delegate = self;
        self.lefttableView!.dataSource = self;
        self.lefttableView!.backgroundColor = BGColor
        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.righttableView = UITableView(frame:CGRectMake(0,0,width,height - 49))
        self.righttableView!.delegate = self;
        self.righttableView!.dataSource = self;
        self.righttableView!.backgroundColor = BGColor
        self.righttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        self.righttableView!.hidden = true
        
        var nib = UINib(nibName:"GroupCell", bundle: nil)
        var nib2 = UINib(nibName:"ExploreTop", bundle: nil)
        var nib3 = UINib(nibName:"ExploreDreamCell", bundle: nil)
        
        
        self.title = "梦想"
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.righttableView?.registerNib(nib3, forCellReuseIdentifier: identifier3)
        self.righttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        
        self.view.addSubview(self.lefttableView!)
        self.view.addSubview(self.righttableView!)
        
//        var rightButton = UIBarButtonItem(title: "更新", style: .Plain, target: self, action: "addStepButton")
//        self.navigationItem.rightBarButtonItem = rightButton;
        
        //标题颜色
        self.navigationController.navigationBar.tintColor = IconColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        
        //        AFImageViewer* afView = [[AFImageViewer alloc] initWithFrame:CGRectMake(0,0, 320, 200)];
        //        afView.backgroundColor=[UIColor blackColor];
        //        [afView setContentMode:UIViewContentModeScaleAspectFill];
        //        afView.delegate=self;
        //        contentTableView.tableHeaderView = afView;
        //UILabel(frame: CGRectMake(0, 0, 200, 40))
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
        var url = "http://nian.so/api/explore_all.php?page=\(page)"
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
        var url = "http://nian.so/api/bbs.php?page=0"
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
        var url = "http://nian.so/api/explore_all.php?page=0"
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
        return "http://nian.so/api/bbs.php?page=\(page)"
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
            return self.dataArray2.count/3
            }
        }
    }
    
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        var cell:UITableViewCell
        
        if indexPath!.section==0{
            var c = tableView?.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? ExploreTop
            var index = indexPath!.row
            if tableView == lefttableView {
                c!.Seg!.selectedSegmentIndex = 0
            }else{
                c!.Seg!.selectedSegmentIndex = 1
            }
            c!.Seg!.addTarget(self, action: "hello:", forControlEvents: UIControlEvents.ValueChanged)
            cell = c!
        }else{
            if tableView == lefttableView {
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? GroupCell
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                cell = c!
            }else{
                var index = indexPath!.row * 3
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? ExploreDreamCell
           //     var index = indexPath!.row
                var data1 = self.dataArray2[index] as NSDictionary
                var data2 = self.dataArray2[index+1] as NSDictionary
                var data3 = self.dataArray2[index+2] as NSDictionary
                c!.data1 = data1
                c!.data2 = data2
                c!.data3 = data3
                
                c!.head1!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                c!.head2!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                c!.head3!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dreamclick:"))
                cell = c!
            }
        }
        return cell
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view.tag)"
        self.navigationController.pushViewController(DreamVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        if indexPath.section==0{
            return  69
        }else{
            if tableView == lefttableView {
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                return  GroupCell.cellHeightByData(data)
            }else{
                return  140
            }
        }
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        if indexPath.section == 0 {
        }else{
            if tableView == lefttableView {
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                var BBSVC = BBSViewController()
                BBSVC.Id = data.stringAttributeForKey("id")
                BBSVC.topcontent = data.stringAttributeForKey("content")
                BBSVC.topuid = data.stringAttributeForKey("uid")
                BBSVC.topuser = data.stringAttributeForKey("user")
                BBSVC.toplastdate = data.stringAttributeForKey("lastdate")
                self.navigationController.pushViewController(BBSVC, animated: true)
            }
        }
    }
    
    func countUp() {      //😍
        self.SAReloadData()
    }
    
    func imageViewTapped(noti:NSNotification)
    {
        //        var imageURL = noti.object as String
        //        var imgVC = YRImageViewController(nibName: nil, bundle: nil)
        //        imgVC.imageURL = imageURL
        //        self.navigationController.pushViewController(imgVC, animated: true)
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
    
}
