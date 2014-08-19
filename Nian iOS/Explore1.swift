////
////  YRJokeTableViewController.swift
////  JokeClient-Swift
////
////  Created by YANGReal on 14-6-5.
////  Copyright (c) 2014年 YANGReal. All rights reserved.
////
//
//import UIKit
//
//class ExploreViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{     //😍
//    
//    let identifier = "explore"
//    var lefttableView:UITableView?
//    var dataArray = NSMutableArray()
//    var page :Int = 0
//    var Id:String = "1"
//    
//    override func viewDidLoad()
//    {
//        super.viewDidLoad()
//        setupViews()
//        setupRefresh()
//        self.lefttableView!.headerBeginRefreshing()
//        SAReloadData()
//    }
//    
//    override func viewWillDisappear(animated: Bool)
//    {
//        super.viewWillDisappear(animated)
//        //        [[self navigationController] setNavigationBarHidden:YES];
//    }
//    override func viewWillAppear(animated: Bool)
//    {
//        super.viewWillAppear(animated)
//    }
//    
//    
//    func setupViews()
//    {
//        var width = self.view.frame.size.width
//        var height = self.view.frame.size.height - 64
//        self.lefttableView = UITableView(frame:CGRectMake(0,0,width,height - 49))
//        self.lefttableView!.tableHeaderView = UIView(frame: CGRectMake(0, 0, 320, 51))
//        self.lefttableView!.delegate = self;
//        self.lefttableView!.dataSource = self;
//        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
//        
//        
//        var nib = UINib(nibName:"ExploreCell", bundle: nil)
//        var nib2 = UINib(nibName:"ExploreCellTop", bundle: nil)
//        
//        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
//        
//        self.view.addSubview(self.lefttableView)
//        
//    }
//    
//    
//    func loadData(){
//        var url = urlString()
//        // self.refreshView!.startLoading()
//        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
//            if data as NSObject == NSNull()
//            {
//                UIView.showAlertView("提示",message:"加载失败")
//                return
//            }
//            var arr = data["items"] as NSArray
//            
//            for data : AnyObject  in arr
//            {
//                self.dataArray.addObject(data)
//            }
//            self.lefttableView!.reloadData()
//            self.lefttableView!.footerEndRefreshing()
//            self.page++
//            })
//    }
//
//    func SAReloadData(){
//        var url = "http://nian.so/api/bbs.php?page=0"
//        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
//            if data as NSObject == NSNull(){
//                UIView.showAlertView("提示",message:"加载失败")
//                return
//            }
//            var arr = data["items"] as NSArray
//            self.dataArray.removeAllObjects()
//            for data : AnyObject  in arr{
//                self.dataArray.addObject(data)
//            }
//            self.lefttableView!.reloadData()
//            self.lefttableView!.headerEndRefreshing()
//            self.page = 1
//            })
//    }
//    
//    
//    
//    func urlString()->String
//    {
//        return "http://nian.so/api/bbs.php?page=\(page)"
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }
//    
//    
//    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
//        return 1
//    }
//    
//    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
//            return self.dataArray.count
//    }
//    
//    
//    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
//        var cell:UITableViewCell
//            var c = tableView?.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? ExploreCell
//            var index = indexPath!.row
//            var data = self.dataArray[index] as NSDictionary
//            c!.data = data
//            cell = c!
//        return cell
//    }
//    
//    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
//    {
//            var index = indexPath!.row
//            var data = self.dataArray[index] as NSDictionary
//            return  ExploreCell.cellHeightByData(data)
//    }
//    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
//    }
//    
//    func countUp() {      //😍
//        self.SAReloadData()
//    }
//    
//    func imageViewTapped(noti:NSNotification)
//    {
//        //        var imageURL = noti.object as String
//        //        var imgVC = YRImageViewController(nibName: nil, bundle: nil)
//        //        imgVC.imageURL = imageURL
//        //        self.navigationController.pushViewController(imgVC, animated: true)
//    }
//    func setupRefresh(){
//        self.lefttableView!.addHeaderWithCallback({
//            self.SAReloadData()
//            })
//        
//        self.lefttableView!.addFooterWithCallback({
//            self.loadData()
//            })
//        
//    }
//    func back(){
//        self.navigationController.popViewControllerAnimated(true)
//    }
//    
//}
