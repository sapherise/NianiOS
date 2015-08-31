//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SingleStepViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate,AddstepDelegate, delegateSAStepCell{
    
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
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "进展"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    
    func SAReloadData(){
        Api.getSingleStep(self.Id) { json in
            if json != nil {
                self.dataArray.removeAllObjects()
                let data = json!.objectForKey("data") as! NSDictionary
                let hidden = data.stringAttributeForKey("hidden")
                if hidden == "1" {
                    let viewTop = viewEmpty(globalWidth, content: "这条进展\n不见了")
                    viewTop.setY(40)
                    let viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
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
        let c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
        c.delegate = self
        c.data = self.dataArray[indexPath.row] as! NSDictionary
        c.index = indexPath.row
        if indexPath.row == self.dataArray.count - 1 {
            c.viewLine.hidden = true
        } else {
            c.viewLine.hidden = false
        }
        c._layoutSubviews()
        return c
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = self.dataArray[indexPath.row] as! NSDictionary
        
        return tableView.fd_heightForCellWithIdentifier("SAStepCell", cacheByIndexPath: indexPath, configuration: { cell in
            (cell as! SAStepCell).celldataSource = self
            (cell as! SAStepCell).fd_enforceFrameLayout = true
            (cell as! SAStepCell).data  = data
            (cell as! SAStepCell).indexPath = indexPath
        })
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
        SAUpdate(self.dataArray, index: index, key: key, value: value, tableView: self.tableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, section: 0, tableView: self.tableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, dataArray: self.dataArray, index: index, tableView: self.tableView, section: 0)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
}

extension SingleStepViewController: SAStepCellDatasource {
    
    func saStepCell(indexPath: NSIndexPath, content: String, contentHeight: CGFloat) {
        
        var _tmpDict = NSMutableDictionary(dictionary: self.dataArray[indexPath.row] as! NSDictionary)      //= ["content": content, "contentHeight": contentHeight]
        _tmpDict.setObject(content as NSString, forKey: "content")
        
        #if CGFLOAT_IS_DOUBLE
            _tmpDict.setObject(NSNumber(double: Double(contentHeight)), forKey: "contentHeight")
            #else
            _tmpDict.setObject(NSNumber(float: Float(contentHeight)), forKey: "contentHeight")
        #endif
        
        self.dataArray.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
    }
}



