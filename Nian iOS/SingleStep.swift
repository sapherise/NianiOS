//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SingleStepViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, UIGestureRecognizerDelegate, delegateSAStepCell{
    
    var tableView:UITableView!
    var dataArray = NSMutableArray()
    var Id:String = "1"
    var navView:UIView!
    
    //editStepdelegate
    var editStepRow:Int = 0
    var editStepData:NSDictionary?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.viewBackFix()
    }
    
    func setupViews() {
        self.viewBack()
        
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.tableView = UITableView(frame:CGRectMake(0, 64, globalWidth,globalHeight - 64))
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        self.view.addSubview(self.tableView)
        
        //标题颜色
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "进展"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    
    func SAReloadData(){
        Api.getSingleStep(self.Id) { json in
            if json != nil {
                self.dataArray.removeAllObjects()
                var data = json!.objectForKey("data") as! NSDictionary
                var hidden = data.stringAttributeForKey("hidden")
                if hidden == "1" {
                    var viewTop = viewEmpty(globalWidth, content: "这条进展\n不见了")
                    viewTop.setY(40)
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    viewHolder.addSubview(viewTop)
                    self.tableView?.tableHeaderView = viewHolder
                } else {
                    self.dataArray.addObject(data)
                }
                self.tableView!.reloadData()
                self.tableView!.headerEndRefreshing()
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
        c.delegate = self
        c.data = self.dataArray[indexPath.row] as! NSDictionary
        c.index = indexPath.row
        if indexPath.row == self.dataArray.count - 1 {
            c.viewLine.hidden = true
        } else {
            c.viewLine.hidden = false
        }
        return c
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var data = self.dataArray[indexPath.row] as! NSDictionary
        var h = SAStepCell.cellHeightByData(data)
        return h
    }
    
    func Editstep() {
        self.SAReloadData()
    }
    
    func countUp(coin: String, isfirst: String){
        self.SAReloadData()
    }
    
    func setupRefresh(){
        self.tableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArray, index, key, value, self.tableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 0, self.tableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArray, index, self.tableView, 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
}

