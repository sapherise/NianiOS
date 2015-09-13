//
//  Topic + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension TopicViewController: UITableViewDataSource, UITableViewDelegate, TopicDelegate, RedditDelegate {
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
        Api.getTopicCommentHot(id, page: pageLeft) { json in
            if json != nil {
                let err = json!.objectForKey("error") as! NSNumber
                if err == 0 {
                    if clear {
                        self.dataArrayLeft.removeAllObjects()
                    }
                    let data = json!.objectForKey("data") as! NSArray
                    for d in data {
                        self.dataArrayLeft.addObject(d)
                    }
                    self.tableViewLeft.reloadData()
                    self.pageLeft++
                } else {
                    self.view.showTipText("服务器坏了")
                }
                self.tableViewLeft.headerEndRefreshing()
                self.tableViewLeft.footerEndRefreshing()
            }
        }
    }
    
    func loadRight(clear: Bool = true) {
        if clear {
            pageRight = 1
        }
        Api.getTopicCommentNew(id, page: pageRight) { json in
            if json != nil {
                let err = json!.objectForKey("error") as! NSNumber
                if err == 0 {
                    if clear {
                        self.dataArrayRight.removeAllObjects()
                    }
                    let data = json!.objectForKey("data") as! NSArray
                    for d in data {
                        self.dataArrayRight.addObject(d)
                    }
                    self.tableViewRight.reloadData()
                    self.pageRight++
                } else {
                    self.view.showTipText("服务器坏了")
                }
                self.tableViewRight.headerEndRefreshing()
                self.tableViewRight.footerEndRefreshing()
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let title = dataArrayTop!.stringAttributeForKey("title").decode()
            let content = dataArrayTop!.stringAttributeForKey("content").decode()
            let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
//            return hTitle + hContent + 152 + 52
            return 600
        } else {
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = d[indexPath.row] as! NSDictionary
            let content = data.stringAttributeForKey("content").decode()
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            let hContentMax = "\n\n\n".stringHeightWith(14, width: globalWidth - 80)
            return min(hContent, hContentMax) + 72 + 72 + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCellHeader", forIndexPath: indexPath) as! TopicCellHeader
            c.data = dataArrayTop!
            c.delegate = self
            c.index = tableView == tableViewLeft ? 0 : 1
            c.delegateVote = self
            c.indexVote = 0
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath) as! TopicCell
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = d[indexPath.row] as! NSDictionary
            c.data = data
            c.indexVote = indexPath.row
            c.delegate = self
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
    
    func updateData(index: Int, key: String, value: String) {
        let mutableItem = NSMutableDictionary(dictionary: dataArrayTop!)
        mutableItem.setValue(value, forKey: key)
        dataArrayTop = mutableItem
    }
    
    func updateTable() {
        tableViewLeft.reloadData()
        tableViewRight.reloadData()
    }
}