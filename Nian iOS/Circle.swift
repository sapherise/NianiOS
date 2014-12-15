//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
    let identifier = "circle"
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var page :Int = 0
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.interactivePopGestureRecognizer.enabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        SAReloadData()
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.backgroundColor = BGColor
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"CircleCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: identifier)
        self.view.addSubview(self.tableView)
    }
    
    
    func loadData() {
        Api.postCircle("\(self.page)"){ json in
            if json != nil {
                var arr = json!["items"] as NSArray
                for data:AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                self.tableView.footerEndRefreshing(animated: true)
                self.page++
            }
        }
    }
    
    
    func SAReloadData() {
        Api.postCircle("0"){ json in
            if json != nil {
                var arr = json!["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data:AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing(animated: true)
                self.page = 1
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        var c = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? CircleCell
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
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        return  CircleCell.cellHeightByData(data)
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback({
            self.SAReloadData()
        })
        self.tableView.addFooterWithCallback({
            self.loadData()
        })
    }
    
    func back() {
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
}