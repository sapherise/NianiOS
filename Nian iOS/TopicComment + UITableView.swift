//
//  TopicComment + UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension TopicComment: UITableViewDataSource, UITableViewDelegate, RedditDelegate, UIActionSheetDelegate {
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
        Api.getTopicCommentComment(id, page: page) { json in
            if json != nil {
                let data = json!.objectForKey("data") as! NSDictionary
                if self.dataArrayTop == nil {
                    self.dataArrayTop = data.objectForKey("answer") as! NSDictionary
                }
                let arr = data.objectForKey("comments") as! NSArray
                if clear {
                    self.dataArray.removeAllObjects()
                }
                for d in arr {
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
            c.delegateVote = self
            c.titleContent = titleContent
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
            if dataArrayTop != nil {
                let h = CGFloat((dataArrayTop!.stringAttributeForKey("heightCell") as NSString).floatValue)
                return h
            }
            return 0
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            row = indexPath.row
            textField.resignFirstResponder()
            let ac = UIActionSheet()
            ac.delegate = self
            let data = dataArray[indexPath.row] as! NSDictionary
            let userQ = dataArrayTop.stringAttributeForKey("user_id")
            let userA = data.stringAttributeForKey("user_id")
            let userMe = SAUid()
            var arr = []
            if userMe == userQ || userMe == userA {
                arr = ["回应", "删除", "举报"]
            } else {
                arr = ["回应", "举报"]
            }
            for a in arr {
                ac.addButtonWithTitle(a as? String)
            }
            ac.addButtonWithTitle("取消")
            ac.cancelButtonIndex = arr.count
            ac.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
            let data = dataArray[row] as! NSDictionary
            let userQ = dataArrayTop.stringAttributeForKey("user_id")
            let userA = data.stringAttributeForKey("user_id")
            let userMe = SAUid()
            if userMe == userQ || userMe == userA {
                if buttonIndex == 0 {
                    onReply()
                } else if buttonIndex == 1 {
                    onDelete()
                } else if buttonIndex == 2 {
                    onReport()
                }
            } else {
                if buttonIndex == 0 {
                    onReply()
                } else if buttonIndex == 1 {
                    onReport()
                }
            }
    }
    
    // 回应
    func onReply() {
        let data = dataArray[row] as! NSDictionary
        let user = data.stringAttributeForKey("username")
        textField.text = "@\(user) \(textField.text!)"
        textField.becomeFirstResponder()
    }
    
    func onDelete() {
        let data = dataArray[row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        Api.getTopicCommentDelete(id) { json in
        }
        dataArray.removeObjectAtIndex(row)
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: row, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Fade)
        tableView.reloadData()
        tableView.endUpdates()
    }
    
    func onReport() {
        self.view.showTipText("举报好了！", delay: 2)
    }
    
    func updateData(index: Int, key: String, value: String, section: Int) {
        let mutableItem = NSMutableDictionary(dictionary: dataArrayTop!)
        mutableItem.setValue(value, forKey: key)
        dataArrayTop = mutableItem
        delegate?.updateData(self.index, key: key, value: value, section: 1)
    }
    
    func updateTable() {
        tableView.reloadData()
        delegate?.updateTable()
    }
}