//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FollowViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    let identifier = "follow"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ShareContent", object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "foRefresh", object:nil)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageViewTapped:", name: "imageViewTapped", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "ShareContent:", name: "ShareContent", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "foRefresh:", name: "foRefresh", object: nil)
    }
    
    func foRefresh(noti:NSNotification){
        if noti.object! as Int != 0 {
            self.tableView!.setContentOffset(CGPointMake(0, 0), animated: true)
        }
    }
    
    func ShareContent(noti:NSNotification){
        var content:AnyObject = noti.object!
        var url:NSURL = NSURL(string: "http://nian.so/dream/\(Id)")!
        if content[1] as NSString != "" {
            var theimgurl:String = content[1] as String
            var imgurl = NSURL(string: theimgurl)
            var cacheFilename = imgurl!.lastPathComponent
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
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = NavColor
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64 - 49))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"FollowCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView!.tableHeaderView = UIView(frame: CGRectMake(0, 0, 320, 10))
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, 320, 20))
        self.view.addSubview(self.tableView!)
        
    }
    
    
func loadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
        if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
        }
        var arr = data["items"] as NSArray
        for data : AnyObject  in arr{
                self.dataArray.addObject(data)
       }
            self.tableView!.reloadData()
            self.tableView!.footerEndRefreshing()
            self.page++
       })
}
    func SAReloadData(){
        self.page = 0
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray = NSMutableArray()
//            for var i = 0; i < self.dataArray.count; i++ {
//                self.dataArray.removeObjectAtIndex(i)
//            }
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            Sa.setObject(self.dataArray, forKey: "followData")
            Sa.synchronize()
            self.tableView!.reloadData()
            self.tableView!.headerEndRefreshing()
            self.page++
            })
    }
    func SAReloadCache(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if Sa.objectForKey("followData") != nil {
            self.page = 0
            self.dataArray = Sa.objectForKey("followData") as NSMutableArray
            self.tableView!.reloadData()
            self.tableView!.headerEndRefreshing()
            self.page++
        }
    }
    
    
    func urlString()->String{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/explore_fo.php?page=\(page)&uid=\(safeuid)"
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? FollowCell
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        cell!.data = data
        var userclick:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "userclick:")
        cell!.avatarView?.addGestureRecognizer(userclick)
        cell!.like!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "likeclick:"))
        return cell!
    }
    
    func likeclick(sender:UITapGestureRecognizer){
        var LikeVC = LikeViewController()
        LikeVC.Id = "\(sender.view!.tag)"
        self.navigationController!.pushViewController(LikeVC, animated: true)
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
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        return  FollowCell.cellHeightByData(data)
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var DreamVC = DreamViewController()
        DreamVC.Id = data.stringAttributeForKey("id")
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
            })
        self.tableView!.addFooterWithCallback({
            self.loadData()
        })
    }
}
