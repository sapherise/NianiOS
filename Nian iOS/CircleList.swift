//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CircleListController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate{
    
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
    
    override func viewWillAppear(animated: Bool) {
        if globalWillCircleReload == 1 {
            globalWillCircleReload = 0
            self.SAReloadData()
        }
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        var labelNav = UILabel(frame: CGRectMake(0, 20, globalWidth, 44))
        labelNav.text = "梦境"
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
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
                if self.dataArray.count < (self.page + 1) * 30 {
                    self.tableView.setFooterHidden(true)
                }
                self.tableView.reloadData()
                self.tableView.footerEndRefreshing(animated: true)
                self.page++
            }
        }
    }
    
    
    func SAReloadData() {
        self.tableView.setFooterHidden(false)
        Api.postCircle("0"){ json in
            if json != nil {
                var arr = json!["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data:AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing(animated: true)
                if self.dataArray.count < 30 {
                    self.tableView.setFooterHidden(true)
                }
                if self.dataArray.count == 0 {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
                    var viewQuestion = viewEmpty(globalWidth, content: "这里是空的\n要去发现梦境吗")
                    viewQuestion.setY(50)
                    viewQuestion.setHeight(110)
                    var btnGo = UIButton()
                    btnGo.setButtonNice("  嗯！")
                    btnGo.setX(globalWidth/2-50)
                    btnGo.setY(viewQuestion.bottom())
                    btnGo.addTarget(self, action: "onBtnGoClick", forControlEvents: UIControlEvents.TouchUpInside)
                    viewHeader.addSubview(viewQuestion)
                    viewHeader.addSubview(btnGo)
                    self.tableView.tableHeaderView = viewHeader
                }else{
                    self.tableView.tableHeaderView = UIView()
                }
                self.page = 1
            }
        }
    }
    
    func onBtnGoClick() {
        var circleexploreVC = CircleExploreController()
        self.navigationController?.pushViewController(circleexploreVC, animated: true)
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
        cell = c!
        return cell
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return  81
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var data = self.dataArray[indexPath.row] as NSDictionary
        var mutableItem = NSMutableDictionary(dictionary: data)
        mutableItem.setObject("0", forKey: "count")
        self.dataArray.replaceObjectAtIndex(indexPath.row, withObject: mutableItem)
        self.tableView.reloadData()
        var id = data.objectForKey("id") as String
        var CircleVC = CircleController()
        CircleVC.ID = id.toInt()!
        self.navigationController!.pushViewController(CircleVC, animated: true)
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback({
            self.SAReloadData()
        })
        self.tableView.addFooterWithCallback({
            self.loadData()
        })
    }
}