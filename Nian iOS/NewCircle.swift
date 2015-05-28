//
//  NewCircle.swift
//  Nian iOS
//
//  Created by Sa on 15/5/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class NewCircleController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource, delegateSAStepCell {
    
    var navView: UIView!
    var tableViewStep: UITableView!
    var tableViewBBS: UITableView!
    var tableViewChat: UITableView!
    var scrollView: UIScrollView!
    var current: Int = 0
    var viewMenu: SAMenu!
    var dataArrayStep = NSMutableArray()
    var dataArrayBBS = NSMutableArray()
    var dataArrayChat = NSMutableArray()
    var pageStep = 1
    var pageBBS = 1
    
    override func viewDidLoad() {
        setupViews()
        setupRefresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        viewBackFix()
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        scrollView = UIScrollView(frame: CGRectMake(0, 104, globalWidth, globalHeight - 104))
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.contentSize.width = globalWidth * 3
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        tableViewStep = UITableView()
        tableViewBBS = UITableView()
        tableViewChat = UITableView()
        tableViewStep.delegate = self
        tableViewStep.dataSource = self
        tableViewBBS.delegate = self
        tableViewBBS.dataSource = self
        tableViewChat.delegate = self
        tableViewChat.dataSource = self
        
        scrollView.addSubview(tableViewStep)
        scrollView.addSubview(tableViewBBS)
        scrollView.addSubview(tableViewChat)
        tableViewStep.frame = CGRectMake(0, 0, globalWidth, globalHeight - 104)
        tableViewBBS.frame = CGRectMake(globalWidth, 0, globalWidth, globalHeight - 104)
        tableViewChat.frame = CGRectMake(globalWidth * 2, 0, globalWidth, globalHeight - 104)
        tableViewStep.backgroundColor = SeaColor
        tableViewBBS.backgroundColor = lineColor
        tableViewChat.backgroundColor = GoldColor
        
        tableViewStep.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        
        viewMenu = (NSBundle.mainBundle().loadNibNamed("SAMenu", owner: self, options: nil) as NSArray).objectAtIndex(0) as! SAMenu
        viewMenu.frame.origin.y = 64
        viewMenu.arr = ["进展", "话题", "聊天"]
        viewMenu.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        viewMenu.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        viewMenu.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        self.view.addSubview(viewMenu)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewStep {
            return dataArrayStep.count
        } else if tableView == tableViewBBS {
            
        } else {
            
        }
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tableViewStep {
            var data = dataArrayStep[indexPath.row] as! NSDictionary
            return SAStepCell.cellHeightByData(data)
        }
        return 50
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == tableViewStep {
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArrayStep.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        }
        return UITableViewCell()
    }
    
    func load(clear: Bool = true) {
        if clear {
            pageStep = 0
        }
        Api.getDreamStep("1", page: pageStep) { json in
            if json != nil {
                var arr = json!["items"] as! NSArray
                if clear {
                    self.dataArrayStep.removeAllObjects()
                }
                for data in arr {
                    self.dataArrayStep.addObject(data)
                }
                self.tableViewStep.reloadData()
                self.tableViewStep.headerEndRefreshing()
                self.tableViewStep.footerEndRefreshing()
                self.pageStep++
            }
        }
    }
    
    //  设置更新
    func setupRefresh() {
        tableViewStep.addHeaderWithCallback {
            self.load()
        }
        tableViewStep.addFooterWithCallback {
            self.load(clear: false)
        }
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArrayStep, index, key, value, self.tableViewStep)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 0, self.tableViewStep)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.tableViewStep)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArrayStep, index, self.tableViewStep, 0)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func onMenuClick(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            switchTab(tag)
            if current == tag {
                println("到顶部 + 刷新")
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var x = scrollView.contentOffset.x
        var page = Int(x / globalWidth)
        switchTab(page)
    }
    
    func switchTab(tab: Int) {
        current = tab
        viewMenu.switchTab(tab)
        scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(tab), 0), animated: true)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false    //  不同时接受两个手势
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if current == 0 {
            return true
        }
        return false     //  只生效向右滑动返回
    }
}