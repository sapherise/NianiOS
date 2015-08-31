//
//  Topic + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension TopicViewController: UITableViewDataSource, UITableViewDelegate {
    func setupTableViews() {
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "TopicCellHeader", bundle: nil), forCellReuseIdentifier: "TopicCellHeader")
        tableView.registerNib(UINib(nibName: "TopicCell", bundle: nil), forCellReuseIdentifier: "TopicCell")
        tableView.separatorStyle = .None
        view.addSubview(tableView)
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    func setupRefresh() {
        tableView.addHeaderWithCallback {
            self.load()
        }
        tableView.addFooterWithCallback {
            self.load(false)
        }
    }
    
    func load(clear: Bool = true) {
        if clear {
            page = 1
        }
        Api.getBBSComment(id, page: page, isAsc: true) { json in
            if json != nil {
                let data = json!.objectForKey("data")
                if clear {
                    if let bbs = data!.objectForKey("bbs") as? NSDictionary {
                        self.dataArrayTop = bbs
                    }
                    self.dataArray.removeAllObjects()
                }
                let comments = data!.objectForKey("comments") as! NSArray
                for d in comments {
                    self.dataArray.addObject(d)
                }
                self.tableView.reloadData()
                self.tableView.headerEndRefreshing()
                self.tableView.footerEndRefreshing()
                self.page++
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let title = dataArrayTop!.stringAttributeForKey("title").decode()
            let content = dataArrayTop!.stringAttributeForKey("content").decode()
            let hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            return hTitle + hContent + 152
        } else {
            let data = dataArray[indexPath.row] as! NSDictionary
            let content = data.stringAttributeForKey("content").decode()
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            return hContent + 72 + 72 + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCellHeader", forIndexPath: indexPath) as! TopicCellHeader
            c.data = dataArrayTop!
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath) as! TopicCell
            let data = dataArray[indexPath.row] as! NSDictionary
            c.data = data
            return c
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataArrayTop == nil {
            return 0
        }
        if section == 0 {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}