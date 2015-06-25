//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class ExploreController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "GroupCell"
    let identifier3 = "exploreall"
    var tableView:UITableView?
    var dataArray = NSMutableArray()
    var dataArray2 = NSMutableArray()
    var page :Int = 1
    var Id:String = "1"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView?.headerBeginRefreshing()
    }
    
    override func viewWillDisappear(animated: Bool){
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if globalWillBBSReload == 1 {
            self.load()
            globalWillBBSReload = 0
        }
    }
    
    func setupViews()
    {
        viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.tableView!.delegate = self;
        self.tableView!.dataSource = self;
        self.tableView!.backgroundColor = BGColor
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"GroupCell", bundle: nil)
        self.tableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        
        self.view.addSubview(self.tableView!)
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "广场"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addBBS")
        rightButton.image = UIImage(named:"plus")
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func addBBS() {
        var addBBSVC = AddBBSController(nibName: "AddBBSController", bundle: nil)
        self.navigationController?.pushViewController(addBBSVC, animated: true)
    }
    
    func load(clear: Bool = true) {
        if clear {
            page = 1
        }
        Api.getBBS("0", page: page) { json in
            if json != nil {
                var data = json!["data"]
                var arr = data!!["bbs"] as! NSArray
                var top = data!!["top"] as? NSArray
                if clear {
                    self.dataArray.removeAllObjects()
                }
                if top != nil {
                    for data in top! {
                        self.dataArray.addObject(data)
                    }
                }
                for data in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView?.reloadData()
                self.tableView?.headerEndRefreshing()
                self.tableView?.footerEndRefreshing()
                self.page++
            }
        }
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
        var data = self.dataArray[index] as! NSDictionary
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        return  GroupCell.cellHeightByData(data)
    }
    func tableView(tableView: UITableView,didSelectRowAtIndexPath indexPath: NSIndexPath)    {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
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
        self.load()
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.load()
        })
        self.tableView!.addFooterWithCallback({
            self.load(clear: false)
        })
    }
}
