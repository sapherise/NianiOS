//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FindViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var btnConnect:UIButton!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "发现好友"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"FindCell", bundle: nil)
        var nib2 = UINib(nibName:"FindCellTop", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: "FindCell")
        self.tableView!.registerNib(nib2, forCellReuseIdentifier: "FindCellTop")
        
        var viewFooter = UIView(frame: CGRectMake(0, 0, globalWidth, 120))
        btnConnect = UIButton()
        btnConnect.setButtonNice("连接微博")
        viewFooter.addSubview(btnConnect)
        btnConnect.center = viewFooter.center
        btnConnect.addTarget(self, action: "onWeiboClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.tableView.tableFooterView = viewFooter
        
        self.view.addSubview(self.tableView!)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return self.dataArray.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var cell = tableView.dequeueReusableCellWithIdentifier("FindCellTop", forIndexPath: indexPath) as? FindCellTop
            return cell!
        }else{
            var cell = tableView.dequeueReusableCellWithIdentifier("FindCell", forIndexPath: indexPath) as? FindCell
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            cell!.data = data
            cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick:"))
            return cell!
        }
    }
    
    func onUserClick(sender:UIGestureRecognizer) {
        var tag = sender.view!.tag
        var UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onWeiboClick() {
        var request: WBAuthorizeRequest! = WBAuthorizeRequest.request() as WBAuthorizeRequest
        request.redirectURI = "https://api.weibo.com/oauth2/default.html"
        request.scope = "follow_app_official_microblog"
        WeiboSDK.sendRequest(request)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 74
        }else{
            return 71
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            var index = indexPath.row
            var data = self.dataArray[index] as NSDictionary
            var letterVC = LetterController()
            if let id = data.stringAttributeForKey("uid").toInt() {
                letterVC.ID = id
                self.navigationController?.pushViewController(letterVC, animated: true)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "weibo", object:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "weibo:", name: "weibo", object: nil)
    }
    
    func weibo(sender: NSNotification) {
        self.viewLoadingShow()
        var object: NSArray? = sender.object as? NSArray
        if object != nil {
            var uid = "\(object![0])"
            var token = "\(object![1])"
            Api.getWeibo(uid, Token: token) { json in
                if json != nil {
                    self.viewLoadingHide()
                    var arr = json!["items"] as NSArray
                    self.dataArray.removeAllObjects()
                    for data : AnyObject  in arr{
                        self.dataArray.addObject(data)
                    }
                    self.tableView!.reloadData()
                    if self.dataArray.count == 0 {
                        var viewEm = viewEmpty(globalWidth, content: "微博上的好友们\n还没有来玩念")
                        var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                        viewEm.setY(40)
                        viewHolder.addSubview(viewEm)
                        self.tableView.tableFooterView = viewHolder
                    }else{
                        self.tableView.tableFooterView = UIView()
                    }
                }
            }
        }
    }
    
}