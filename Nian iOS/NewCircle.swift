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
    var pageStep = 0
    var pageBBS = 0
    var pageChat = 0
    
    override func viewDidLoad() {
        setupViews()
        setupRefresh()
        switchTab(current)
        delay(0.1, { () -> () in
            self.refresh()
        })
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
        tableViewStep.backgroundColor = UIColor.whiteColor()
        tableViewBBS.backgroundColor = UIColor.whiteColor()
        tableViewChat.backgroundColor = UIColor.whiteColor()
        
        tableViewStep.separatorStyle = .None
        tableViewBBS.separatorStyle = .None
        tableViewChat.separatorStyle = .None
        
        tableViewStep.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        tableViewBBS.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        tableViewChat.registerNib(UINib(nibName:"SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        
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
            return dataArrayBBS.count
        } else {
            return dataArrayChat.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == tableViewStep {
            var data = dataArrayStep[indexPath.row] as! NSDictionary
            return SAStepCell.cellHeightByData(data)
        } else if tableView == tableViewBBS {
            var data = dataArrayBBS[indexPath.row] as! NSDictionary
            return SAStepCell.cellHeightByData(data)
        } else {
            var data = dataArrayChat[indexPath.row] as! NSDictionary
            return SAStepCell.cellHeightByData(data)
        }
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
        } else if tableView == tableViewBBS {
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.data = self.dataArrayBBS[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArrayBBS.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        } else {
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.data = self.dataArrayChat[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArrayChat.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            return c
        }
    }
    
    func loadStep(clear: Bool = true) {
        if clear {
            pageStep = 0
        }
        Api.getDreamStep("1", page: pageStep) { json in
            if json != nil {
                println("OK")
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
    
    func loadBBS(clear: Bool = true) {
        if clear {
            pageBBS = 0
        }
        Api.getDreamStep("240622", page: pageBBS) { json in
            if json != nil {
                var arr = json!["items"] as! NSArray
                if clear {
                    self.dataArrayBBS.removeAllObjects()
                }
                for data in arr {
                    self.dataArrayBBS.addObject(data)
                }
                self.tableViewBBS.reloadData()
                self.tableViewBBS.headerEndRefreshing()
                self.tableViewBBS.footerEndRefreshing()
                self.pageBBS++
            }
        }
    }
    
    func loadChat(clear: Bool = true) {
        if clear {
            pageChat = 0
        }
        Api.getDreamStep("166451", page: pageChat) { json in
            if json != nil {
                var arr = json!["items"] as! NSArray
                if clear {
                    self.dataArrayChat.removeAllObjects()
                }
                for data in arr {
                    self.dataArrayChat.addObject(data)
                }
                self.tableViewChat.reloadData()
                self.tableViewChat.headerEndRefreshing()
                self.tableViewChat.footerEndRefreshing()
                self.pageChat++
            }
        }
    }
    
    //  设置更新
    func setupRefresh() {
        tableViewStep.addHeaderWithCallback {
            self.loadStep()
        }
        tableViewStep.addFooterWithCallback {
            self.loadStep(clear: false)
        }
        tableViewBBS.addHeaderWithCallback {
            self.loadBBS()
        }
        tableViewBBS.addFooterWithCallback {
            self.loadBBS(clear: false)
        }
        tableViewChat.addHeaderWithCallback {
            self.loadChat()
        }
        tableViewChat.addFooterWithCallback {
            self.loadChat(clear: false)
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
            if current == tag {
                refresh()
            }
            switchTab(tag)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var x = scrollView.contentOffset.x
            var page = Int(x / globalWidth)
            switchTab(page)
        }
    }
    
    func switchTab(tab: Int) {
        if current != tab {
            current = tab
            viewMenu.switchTab(tab)
            scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(tab), 0), animated: true)
            switch tab {
            case 0:
                if dataArrayStep.count == 0 {
                    tableViewStep.headerBeginRefreshing()
                }
                break
            case 1:
                if dataArrayBBS.count == 0 {
                    tableViewBBS.headerBeginRefreshing()
                }
                break
            case 2:
                if dataArrayChat.count == 0 {
                    tableViewChat.headerBeginRefreshing()
                }
                break
            default:
                break
            }
        }
    }
    
    // 刷新当前表格
    func refresh() {
        switch current {
        case 0:
            tableViewStep.headerBeginRefreshing()
            break
        case 1:
            tableViewBBS.headerBeginRefreshing()
            break
        case 2:
            tableViewChat.headerBeginRefreshing()
            break
        default:
            break
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false    //  不同时接受两个手势
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}