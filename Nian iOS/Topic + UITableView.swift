//
//  Topic + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension TopicViewController: UITableViewDataSource, UITableViewDelegate, TopicDelegate {
    func setupTableViews() {
        // tableViewLeft
        tableViewLeft = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableViewLeft.delegate = self
        tableViewLeft.dataSource = self
        tableViewLeft.registerNib(UINib(nibName: "TopicCellHeader", bundle: nil), forCellReuseIdentifier: "TopicCellHeader")
        tableViewLeft.registerNib(UINib(nibName: "TopicCell", bundle: nil), forCellReuseIdentifier: "TopicCell")
        tableViewLeft.separatorStyle = .None
        view.addSubview(tableViewLeft)
        
        // tableViewRight
        tableViewRight = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableViewRight.delegate = self
        tableViewRight.dataSource = self
        tableViewRight.registerNib(UINib(nibName: "TopicCellHeader", bundle: nil), forCellReuseIdentifier: "TopicCellHeader")
        tableViewRight.registerNib(UINib(nibName: "TopicCell", bundle: nil), forCellReuseIdentifier: "TopicCell")
        tableViewRight.separatorStyle = .None
        view.addSubview(tableViewRight)
        tableViewRight.hidden = true
        
        setupRefresh()
        tableViewLeft.headerBeginRefreshing()
    }
    
    func setupRefresh() {
        tableViewLeft.addHeaderWithCallback {
            self.load()
        }
        tableViewLeft.addFooterWithCallback {
            self.load(false)
        }
        
        tableViewRight.addHeaderWithCallback {
            self.loadRight()
        }
        tableViewRight.addFooterWithCallback {
            self.loadRight(false)
        }
    }
    
    func load(clear: Bool = true) {
        if clear {
            pageLeft = 1
        }
        Api.getBBSComment(id, page: pageLeft, isAsc: true) { json in
            if json != nil {
                let data = json!.objectForKey("data")
                if clear {
                    if let bbs = data!.objectForKey("bbs") as? NSDictionary {
//                        self.dataArrayTop = bbs
                    }
                    self.dataArrayLeft.removeAllObjects()
                }
                let comments = data!.objectForKey("comments") as! NSArray
                for d in comments {
                    self.dataArrayLeft.addObject(d)
                }
                self.tableViewLeft.reloadData()
                self.tableViewLeft.headerEndRefreshing()
                self.tableViewLeft.footerEndRefreshing()
                self.pageLeft++
            }
        }
    }
    
    func loadRight(clear: Bool = true) {
        if clear {
            pageRight = 1
        }
        Api.getBBSComment(id, page: pageRight, isAsc: false) { json in
            if json != nil {
                let data = json!.objectForKey("data")
                if clear {
                    if let bbs = data!.objectForKey("bbs") as? NSDictionary {
//                        self.dataArrayTop = bbs
                    }
                    self.dataArrayRight.removeAllObjects()
                }
                let comments = data!.objectForKey("comments") as! NSArray
                for d in comments {
                    self.dataArrayRight.addObject(d)
                }
                self.tableViewRight.reloadData()
                self.tableViewRight.headerEndRefreshing()
                self.tableViewRight.footerEndRefreshing()
                self.pageRight++
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let title = dataArrayTop!.stringAttributeForKey("title").decode()
            let content = dataArrayTop!.stringAttributeForKey("content").decode()
            let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            return hTitle + hContent + 152 + 52
        } else {
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = d[indexPath.row] as! NSDictionary
            let content = data.stringAttributeForKey("content").decode()
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            return hContent + 72 + 72 + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCellHeader", forIndexPath: indexPath) as! TopicCellHeader
            c.data = dataArrayTop!
            c.delegate = self
            c.index = tableView == tableViewLeft ? 0 : 1
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath) as! TopicCell
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = d[indexPath.row] as! NSDictionary
            c.data = data
            return c
        }
    }
    
    func changeTopic(index: Int) {
        if index == 0 {
            tableViewLeft.hidden = false
            tableViewRight.hidden = true
            tableViewLeft.reloadData()
            let y = tableViewRight.contentOffset.y
            tableViewLeft.setContentOffset(CGPointMake(0, y), animated: false)
        } else {
            tableViewLeft.hidden = true
            tableViewRight.hidden = false
            tableViewRight.reloadData()
            let y = tableViewLeft.contentOffset.y
            tableViewRight.setContentOffset(CGPointMake(0, y), animated: false)
            if dataArrayRight.count == 0 {
                loadRight()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataArrayTop == nil {
            return 0
        }
        if section == 0 {
            return 1
        } else {
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            return d.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}