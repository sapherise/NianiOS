//
//  TopicComment + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension TopicComment: UITableViewDataSource, UITableViewDelegate {
    func setupTableViews() {
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64 - 56))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "TopicCommentCellHeader", bundle: nil), forCellReuseIdentifier: "TopicCommentCellHeader")
        tableView.registerNib(UINib(nibName: "TopicCommentCell", bundle: nil), forCellReuseIdentifier: "TopicCommentCell")
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        tableView.addHeaderWithCallback { () -> Void in
            self.load()
        }
        tableView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
        tableView.headerBeginRefreshing()
    }
    
    func load(clear: Bool = true) {
        if clear {
            page = 1
        }
        Api.getBBSComment("59288", page: page, isAsc: true) { json in
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCommentCellHeader", forIndexPath: indexPath) as! TopicCommentCellHeader
            c.data = dataArrayTop
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCommentCell", forIndexPath: indexPath) as! TopicCommentCell
            let data = dataArray[indexPath.row] as! NSDictionary
            c.data = data
            return c
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            let content = dataArrayTop!.stringAttributeForKey("content").decode()
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            return hContent + 97
        } else {
            let data = dataArray[indexPath.row] as! NSDictionary
            let content = data.stringAttributeForKey("content").decode()
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            return hContent + 97
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return dataArrayTop == nil ? 0 : 1
        } else {
            return dataArray.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}