//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class ExploreController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "group"
    let identifier3 = "exploreall"
    var lefttableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "bbsRefresh", object:nil)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "bbsRefresh:", name: "bbsRefresh", object: nil)
        if globalWillBBSReload == 1 {
            self.SAReloadData()
            globalWillBBSReload = 0
        }
    }
    
    func bbsRefresh(noti:NSNotification){
        if noti.object! as Int != 0 {
                self.lefttableView!.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }
    
    func setupViews()
    {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = NavColor
        self.view.addSubview(navView)
        
        self.lefttableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.lefttableView!.delegate = self;
        self.lefttableView!.dataSource = self;
        self.lefttableView!.backgroundColor = BGColor
        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"GroupCell", bundle: nil)
        var nib2 = UINib(nibName:"ExploreTop", bundle: nil)
        var nib3 = UINib(nibName:"ExploreDreamCell", bundle: nil)
        
        
        self.title = "梦想"
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        
        self.view.addSubview(self.lefttableView!)
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
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
    
    
    
    
    func urlString()->String
    {
        return "http://nian.so/api/bbs.php?page=\(page)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if tableView == lefttableView {
            return self.dataArray.count
            }else{
            return self.dataArray2.count/3
            }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        if tableView == lefttableView {
            var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? GroupCell
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            c!.data = data
            cell = c!
        }else{
            var index = indexPath.row * 3
            var c = tableView.dequeueReusableCellWithIdentifier(identifier3, forIndexPath: indexPath) as? ExploreDreamCell
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
        return cell
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
            if tableView == lefttableView {
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                return  GroupCell.cellHeightByData(data)
            }else{
                return  140
            }
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
            if tableView == lefttableView {
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                var BBSVC = BBSViewController()
                BBSVC.Id = data.stringAttributeForKey("id")
                BBSVC.topcontent = data.stringAttributeForKey("content")
                BBSVC.topuid = data.stringAttributeForKey("uid")
                BBSVC.topuser = data.stringAttributeForKey("user")
                BBSVC.toplastdate = data.stringAttributeForKey("lastdate")
                BBSVC.toptitle = data.stringAttributeForKey("title")
                self.navigationController!.pushViewController(BBSVC, animated: true)
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
    }
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
