//
//  Topic + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension TopicViewController {
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
        navigationItem.rightBarButtonItems = buttonArray()
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
                let btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "more")
                btnMore.image = UIImage(named: "more")
                self.navigationItem.rightBarButtonItems = [btnMore]
            }
        }
    }
    
    func loadRight(clear: Bool = true) {
        if clear {
            pageRight = 1
        }
        navigationItem.rightBarButtonItems = buttonArray()
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
                let btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "more")
                btnMore.image = UIImage(named: "more")
                self.navigationItem.rightBarButtonItems = [btnMore]
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if dataArrayTopLeft != nil {
                let h = CGFloat((dataArrayTopLeft!.stringAttributeForKey("heightCell") as NSString).floatValue)
                return h
            }
            return 0
        } else {
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = d[indexPath.row] as! NSDictionary
            let content = data.stringAttributeForKey("content").decode().toRedditReduce()
            let hContent = content.stringHeightWith(14, width: globalWidth - 80)
            let hContentMax = "\n\n\n".stringHeightWith(14, width: globalWidth - 80)
            return min(hContent, hContentMax) + 72 + 72 + 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCellHeader", forIndexPath: indexPath) as! TopicCellHeader
            c.data = tableView == tableViewLeft ? dataArrayTopLeft : dataArrayTopRight
            c.index = tableView == tableViewLeft ? 0 : 1
            c.delegate = self
            c.delegateComment = self
            c.delegateVote = self
            c.delegateTop = self
            c.indexVote = 0
            c.id = id
            return c
        } else {
            let c = tableView.dequeueReusableCellWithIdentifier("TopicCell", forIndexPath: indexPath) as! TopicCell
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = d[indexPath.row] as! NSDictionary
            c.data = data
            c.indexVote = indexPath.row
            c.delegate = self
            c.delegateDelete = self
            return c
        }
    }
    
    func changeTopic(index: Int) {
        current = index
        if index == 0 {
            tableViewLeft.hidden = false
            tableViewRight.hidden = true
            tableViewLeft.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            let y = tableViewRight.contentOffset.y
            tableViewLeft.setContentOffset(CGPointMake(0, y), animated: false)
            load()
        } else {
            tableViewLeft.hidden = true
            tableViewRight.hidden = false
            dataArrayTopRight = dataArrayTopLeft
            tableViewRight.reloadData()
            let y = tableViewLeft.contentOffset.y
            tableViewRight.setContentOffset(CGPointMake(0, y), animated: false)
            loadRight()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            let d = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            return d.count
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let dataArray = tableView == tableViewLeft ? dataArrayLeft : dataArrayRight
            let data = dataArray[indexPath.row] as! NSDictionary
            let id = data.stringAttributeForKey("id")
            let vc = TopicComment()
            vc.id = id
            vc.delegate = self
            vc.index = indexPath.row
            vc.titleContent = dataArrayTopLeft?.stringAttributeForKey("title")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func updateDic(data: NSMutableDictionary) {
        if dataArrayTopLeft == nil {
            dataArrayTopLeft = data
        }
    }
    
    func updateData(index: Int, key: String, value: String, section: Int) {
        if section == 0 {
            let mutableItem = NSMutableDictionary(dictionary: dataArrayTopLeft!)
            mutableItem.setValue(value, forKey: key)
            dataArrayTopLeft = mutableItem
            dataArrayTopRight = mutableItem
            delegate?.updateData(self.index, key: key, value: value, section: 0)
        } else {
            let d = current == 0 ? dataArrayLeft[index] : dataArrayRight[index]
            let mutableItem = NSMutableDictionary(dictionary: d as! NSDictionary)
            mutableItem.setValue(value, forKey: key)
            if current == 0 {
                dataArrayLeft.replaceObjectAtIndex(index, withObject: mutableItem)
            } else {
                dataArrayRight.replaceObjectAtIndex(index, withObject: mutableItem)
            }
        }
    }
    
    // 添加新评论后的功能
    func getComment(content: String) {
        if current == 0 {
            load()
        } else {
            loadRight()
        }
    }
    
    func updateTable() {
        tableViewLeft.reloadData()
        tableViewRight.reloadData()
        delegate?.updateTable()
    }
    
    // 当删除某条回应时，进行这个操作，delegate 为 RedditDeleteDelegate
    func onDelete(index: Int) {
        let d = current == 0 ? dataArrayLeft : dataArrayRight
        let t = current == 0 ? tableViewLeft : tableViewRight
        let data = d[index] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        Api.getTopicDelete(id) { json in }
        d.removeObjectAtIndex(index)
        t.reloadData()
    }
}