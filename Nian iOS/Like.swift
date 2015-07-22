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
    var navView:UIView!
    var circleID:String = "0"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView?.headerBeginRefreshing()
    }
    
    func setupViews() {
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"LikeCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView!)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        if self.urlIdentify == 0 {
            titleLabel.text = "赞过"
        }else if self.urlIdentify == 1 {
            titleLabel.text = "关注"
        }else if self.urlIdentify == 2 {
            titleLabel.text = "听众"
        }else if self.urlIdentify == 3 {
            titleLabel.text = "赞过记本"
        }else if self.urlIdentify == 4 {
            titleLabel.text = "邀请"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
    }
    
    
    func loadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                var arr = data.objectForKey("items") as! NSArray
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.footerEndRefreshing()
                self.page++
                if ( data.objectForKey("total") as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
            }
        })
    }
    func SAReloadData(){
        self.tableView!.setFooterHidden(false)
        self.page = 0
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as! NSObject != NSNull(){
                if ( data.objectForKey("total") as! Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
                var arr = data.objectForKey("items") as! NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
                self.page++
            }
        })
    }
    
    
    func urlString()->String{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as! String
        if self.urlIdentify == 0 {
            return "http://nian.so/api/like2.php?page=\(page)&id=\(Id)&myuid=\(safeuid)"
        }else if self.urlIdentify == 1 {
            return "http://nian.so/api/user_fo_list2.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }else if self.urlIdentify == 2 {
            return "http://nian.so/api/user_foed_list2.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }else if self.urlIdentify == 3{
            return "http://nian.so/api/like_dream.php?page=\(page)&id=\(Id)&myuid=\(safeuid)"
        }else{
            return "http://nian.so/api/user_fo_list2.php?page=\(page)&uid=\(Id)&myuid=\(safeuid)"
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? LikeCell
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        cell!.data = data
        cell!.urlIdentify = self.urlIdentify
        cell!.circleID = self.circleID
        cell!.ownerID = self.Id
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  71
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
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
