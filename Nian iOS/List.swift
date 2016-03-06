//
//  List.swift
//  Nian iOS
//
//  Created by Sa on 16/1/12.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

enum ListType {
    /* 从记本页面进来，想要 */
    case Members
    case Invite
}

class List: SAViewController, UITableViewDataSource, UITableViewDelegate, ListDelegate, UIActionSheetDelegate {
    
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var type: ListType!
    
    /* 其他页面传入的 id */
    var id: String = "-1"
    var page = 1
    var willShowInviteButton = false
    
    /* 移除用户弹窗 */
    var actionSheet: UIActionSheet!
    
    var indexDelete = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        load(true)
    }
    
    func setup() {
        if type == ListType.Members {
            _setTitle("成员")
            if willShowInviteButton {
                setBarButtonImage("addFriend", actionGesture: "onInvite")
            }
        } else if type == ListType.Invite {
            _setTitle("邀请")
        }
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        tableView.separatorStyle = .None
        view.addSubview(tableView)
        tableView.addHeaderWithCallback { () -> Void in
            self.load(true)
        }
        tableView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
    }
    
    /* 当点击了邀请后 */
    func onInvite() {
        let vc = List()
        vc.type = ListType.Invite
        vc.id = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c: ListCell! = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as? ListCell
        let data = dataArray[indexPath.row] as! NSDictionary
        c.data = data
        c.type = type
        c.hasSelected = data.stringAttributeForKey("inviting") != "0"
        c.num = indexPath.row
        c.id = id
        c.setup()
        c.delegate = self
        return c
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70 + globalHalf
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        indexDelete = indexPath.row
        if let dataMe = dataArray[0] as? NSDictionary {
            let uid = dataMe.stringAttributeForKey("uid")
            if uid == SAUid() {
                /* 确保是创建者本人 
                ** 同时是成员页面
                ** 同时不是第一个 indexPath
                */
                if type == ListType.Members && indexPath.row > 0 {
                    actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    actionSheet.addButtonWithTitle("移出这个记本")
                    actionSheet.addButtonWithTitle("取消")
                    actionSheet.cancelButtonIndex = 1
                    actionSheet.showInView(self.view)
                }
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            /* 需要先获得 uid 再移除，不然会越界 */
            if let data = dataArray[indexDelete] as? NSDictionary {
                let uid = data.stringAttributeForKey("uid")
                Api.getKick(id, uid: uid) { json in
                }
            }
            dataArray.removeObjectAtIndex(indexDelete)
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: indexDelete, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Left)
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    func update(index: Int, key: String, value: String) {
        if let data = dataArray[index] as? NSDictionary {
           let mutableData = NSMutableDictionary(dictionary: data)
            mutableData.setValue(value, forKey: key)
            dataArray.replaceObjectAtIndex(index, withObject: mutableData)
            tableView.reloadData()
        }
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        /* 邀请列表 */
        if type == ListType.Invite {
            Api.getMultiInviteList(id, page: page) { json in
                if json != nil {
                    if let err = json!.objectForKey("error") as? NSNumber {
                        if err == 0 {
                            if let items = json!.objectForKey("data") as? NSArray {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                for item in items {
                                    self.dataArray.addObject(item)
                                }
                            }
                            self.page++
                            self.tableView.reloadData()
                            self.tableView.headerEndRefreshing()
                            self.tableView.footerEndRefreshing()
                        } else {
                            self.showTipText("服务器坏了")
                        }
                    }
                }
            }
        } else if type == ListType.Members {
            Api.getMultiDreamList(id, page: page) { json in
                if json != nil {
                    if let err = json!.objectForKey("error") as? NSNumber {
                        if err == 0 {
                            if let items = json!.objectForKey("data") as? NSArray {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                for item in items {
                                    self.dataArray.addObject(item)
                                }
                            }
                            self.page++
                            self.tableView.reloadData()
                            self.tableView.headerEndRefreshing()
                            self.tableView.footerEndRefreshing()
                        } else {
                            self.showTipText("服务器坏了")
                        }
                    }
                }
            }
        }
    }
}