//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class TagViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "tagCell"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var navView:UIView!
    let tagArray = ["日常", "摄影", "恋爱", "创业", "阅读", "追剧", "绘画", "英语", "收集", "健身", "音乐", "写作", "旅行", "美食", "设计", "游戏", "工作", "习惯", "写字", "其他"]
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        self.tableView!.headerBeginRefreshing()
        SAReloadData()
    }
    
    func setupViews()
    {
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        var nib = UINib(nibName:"TagCell", bundle: nil)
        
        self.tableView!.registerNib(nib, forCellReuseIdentifier: identifier)
        self.tableView!.tableHeaderView = UIView(frame: CGRectMake(0, 0, 320, 10))
        self.tableView!.tableFooterView = UIView(frame: CGRectMake(0, 0, 320, 20))
        self.view.addSubview(self.tableView!)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        var hashtag = self.Id.toInt()! - 1
        if hashtag >= 0 {
            titleLabel.text = "\(self.tagArray[hashtag])标签"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
    }
    
    
    func loadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull(){
                var arr = data["items"] as NSArray
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.footerEndRefreshing()
                self.page++
                if ( data["total"] as Int ) < 30 {
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
            if data as NSObject != NSNull(){
                if ( data["total"] as Int ) < 30 {
                    self.tableView!.setFooterHidden(true)
                }
                var arr = data["items"] as NSArray
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
        return "http://nian.so/api/tag.php?page=\(page)&tag=\(self.Id)"
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? TagCell
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        cell!.data = data
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return  70
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var id = data.objectForKey("id") as String
        var DreamVC = DreamViewController()
        DreamVC.Id = id
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
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
    
}
