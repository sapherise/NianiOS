//
//  Reddit + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
extension RedditViewController: UITableViewDelegate, UITableViewDataSource, RedditDelegate {
    
    func setupTable() {
        tableViewLeft.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        tableViewRight.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        tableViewLeft.delegate = self
        tableViewRight.delegate = self
        tableViewLeft.dataSource = self
        tableViewRight.dataSource = self
        
        tableViewLeft.separatorStyle = .None
        tableViewRight.separatorStyle = .None
        
        tableViewLeft.addHeaderWithCallback {
            self.loadLeft()
        }
        tableViewLeft.addFooterWithCallback {
            self.loadLeft(false)
        }
        tableViewRight.addHeaderWithCallback {
            self.loadRight()
        }
        tableViewRight.addFooterWithCallback {
            self.loadRight(false)
        }
    }
    
    func loadLeft(clear: Bool = true) {
        if clear {
            pageLeft = 1
        }
        Api.getBBS("0", page: pageLeft) { json in
            if json != nil {
                let data = json!.objectForKey("data") as! NSDictionary
                let bbs = data.objectForKey("bbs") as! NSArray
                if clear {
                    self.dataArrayLeft.removeAllObjects()
                }
                for d in bbs {
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
        Api.getBBS("0", page: pageRight) { json in
            if json != nil {
                let data = json!.objectForKey("data") as! NSDictionary
                let bbs = data.objectForKey("bbs") as! NSArray
                if clear {
                    self.dataArrayRight.removeAllObjects()
                }
                for d in bbs {
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
        let dataArray = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
        let data = dataArray[indexPath.row] as! NSDictionary
        let title = data.stringAttributeForKey("title").decode()
        let content = data.stringAttributeForKey("content").decode()
        var hTitle = title.stringHeightWith(16, width: globalWidth - 80)
        var hContent = content.stringHeightWith(12, width: globalWidth - 80)
        let hTitleMax = "\n".stringHeightWith(16, width: globalWidth - 80)
        let hContentMax = "\n\n\n".stringHeightWith(12, width: globalWidth - 80)
        hTitle = min(hTitle, hTitleMax)
        hContent = min(hContent, hContentMax)
        return hTitle + hContent + 99
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableViewLeft {
            return dataArrayLeft.count
        }
        return dataArrayRight.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("RedditCell", forIndexPath: indexPath) as! RedditCell
        let i = indexPath.row
        if tableView == tableViewLeft {
            c.data = dataArrayLeft[i] as! NSDictionary
        } else {
            c.data = dataArrayRight[i] as! NSDictionary
        }
        c.index = i
        c.delegate = self
        return c
    }
    
    
    func updateData(index: Int, key: String, value: String) {
        let d = current == 0 ? dataArrayLeft : dataArrayRight
        let t = current == 0 ? tableViewLeft : tableViewRight
        SAUpdate(d, index: index, key: key, value: value, tableView: t)
    }
    
    func updateTable() {
        let t = current == 0 ? tableViewLeft : tableViewRight
        t.reloadData()
    }
}