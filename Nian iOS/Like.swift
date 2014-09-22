//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class LikeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "like"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var urlIdentify:Int = 0
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        self.tableView!.headerBeginRefreshing()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "imageViewTapped", object:nil)
        
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "imageViewTapped:", name: "imageViewTapped", object: nil)
    }
    
    
    
    func setupViews()
    {
        var width = self.view.frame.size.width
        var height = self.view.frame.size.height - 64
        self.tableView = UITableView(frame:CGRectMake(0,0,width,height))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"LikeCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView!.tableHeaderView = UIView(frame: CGRectMake(0, 0, 320, 10))
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, 320, 20))
        self.view.addSubview(self.tableView!)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        if self.urlIdentify == 0 {
            titleLabel.text = "赞过"
        }else if self.urlIdentify == 1 {
            titleLabel.text = "关注"
        }else{
            titleLabel.text = "听众"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
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
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            self.tableView!.reloadData()
            self.tableView!.headerEndRefreshing()
            self.page++
        })
    }
    
    
    func urlString()->String{
        if self.urlIdentify == 0 {
            return "http://nian.so/api/like.php?page=\(page)&id=\(Id)"
        }else if self.urlIdentify == 1 {
            return "http://nian.so/api/user_fo_list.php?page=\(page)&uid=\(Id)"
        }else{
            return "http://nian.so/api/user_foed_list.php?page=\(page)&uid=\(Id)"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? LikeCell
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        cell!.data = data
        var userclick:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "userclick:")
        cell!.avatarView?.addGestureRecognizer(userclick)
        return cell!
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
        return  80
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
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
        self.navigationController!.popViewControllerAnimated(true)
    }
    
}
