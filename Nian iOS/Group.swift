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
    var tableView:UITableView?
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
                self.tableView!.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }
    
    func setupViews()
    {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"GroupCell", bundle: nil)
        var nib2 = UINib(nibName:"ExploreTop", bundle: nil)
        
        
        self.title = "梦想"
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        
        self.view.addSubview(self.tableView!)
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
    }
    
    
    func loadData() {
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                var arr = data["items"] as NSArray
                for data : AnyObject  in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.footerEndRefreshing()
                self.page++
            }
        })
    }
    
    
    func SAReloadData(){
        var url = "http://nian.so/api/bbs.php?page=0"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull(){
                var arr = data["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
                self.page = 1
            }
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
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? GroupCell
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        c!.data = data
        if indexPath.row == self.dataArray.count - 1 {
            c!.viewLine.hidden = true
        }else{
            c!.viewLine.hidden = false
        }
        cell = c!
        return cell
    }
    
    func dreamclick(sender:UITapGestureRecognizer){
        var DreamVC = DreamViewController()
        DreamVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        return  GroupCell.cellHeightByData(data)
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
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
    
    func countUp() {      //😍
        self.SAReloadData()
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
            })
        
        self.tableView!.addFooterWithCallback({
            self.loadData()
            })
    }
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
}
