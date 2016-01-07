//
//  Reddit + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
extension RedditViewController {
    
    func setupTable() {
        tableViewLeft.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        tableViewRight.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        tableViewLeft.delegate = self
        tableViewRight.delegate = self
        tableViewLeft.dataSource = self
        tableViewRight.dataSource = self
        
        tableViewLeft.separatorStyle = .None
        tableViewRight.separatorStyle = .None
        
        tableViewRight.scrollsToTop = true
        tableViewLeft.scrollsToTop = false
        scrollView.scrollsToTop = false
        
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
        Api.getRedditFollow(pageLeft) { json in
            if json != nil {
                let err = json!.objectForKey("error") as! NSNumber
                let data = json!.objectForKey("data") as! NSArray
                if err == 0 {
                    if clear {
                        self.dataArrayLeft.removeAllObjects()
                    }
                    for d in data {
                        self.dataArrayLeft.addObject(d)
                    }
                    if self.dataArrayLeft.count == 0 {
                        let v = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 49))
                        v.addGhost("关注一些标签后\n这里会出现新的东西")
                        self.tableViewLeft.tableHeaderView = v
                    } else {
                        self.tableViewLeft.tableHeaderView = nil
                    }
                    self.tableViewLeft.reloadData()
                    self.tableViewLeft.headerEndRefreshing()
                    self.tableViewLeft.footerEndRefreshing()
                    self.pageLeft++
                } else {
                    self.showTipText("服务器坏了")
                }
            }
        }
    }
    
    func loadRight(clear: Bool = true) {
        if clear {
            pageRight = 1
        }
        Api.getReddit(pageRight) { json in
            if json != nil {
                let err = json!.objectForKey("error") as! NSNumber
                let data = json!.objectForKey("data") as! NSArray
                if err == 0 {
                    if clear {
                        self.dataArrayRight.removeAllObjects()
                    }
                    for d in data {
                        self.dataArrayRight.addObject(d)
                    }
                    self.tableViewRight.reloadData()
                    self.tableViewRight.headerEndRefreshing()
                    self.tableViewRight.footerEndRefreshing()
                    self.pageRight++
                } else {
                    self.showTipText("服务器坏了")
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let dataArray = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
        let data = dataArray[indexPath.row] as! NSDictionary
        let title = data.stringAttributeForKey("title").decode()
        let content = data.stringAttributeForKey("content").decode().toRedditReduce()
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let d = current == 0 ? dataArrayLeft : dataArrayRight
        let data = d[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let vc = TopicViewController()
        vc.id = id
        vc.index = indexPath.row
        vc.delegate = self
        vc.dataArrayTopLeft = NSMutableDictionary(dictionary: data)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateData(index: Int, key: String, value: String, section: Int) {
        let d = current == 0 ? dataArrayLeft : dataArrayRight
        let t = current == 0 ? tableViewLeft : tableViewRight
        SAUpdate(d, index: index, key: key, value: value, tableView: t)
    }
    
    func updateTable() {
        let t = current == 0 ? tableViewLeft : tableViewRight
        t.reloadData()
    }
    
    func deleteCellInTable(index: Int) {
        let d = current == 0 ? dataArrayLeft : dataArrayRight
        
        d.removeObjectAtIndex(index)
    }
}