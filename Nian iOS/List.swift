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
    /* 查看记本成员 */
    case members
    
    /* 邀请 */
    case invite
    
    /* 赞过进展的人 */
    case like
    
    /* 关注记本的人 */
    case followers
    
    /* 赞过记本的人 */
    case dreamLikes
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
        tableView.headerBeginRefreshing()
    }
    
    func setup() {
        if type == ListType.members {
            _setTitle("成员")
            if willShowInviteButton {
                setBarButtonImage("addFriend", actionGesture: #selector(List.onInvite))
            }
        } else if type == ListType.invite {
            _setTitle("邀请")
        } else if type == ListType.like {
            _setTitle("赞过")
        } else if type == ListType.dreamLikes {
            _setTitle("赞过记本")
        } else if type == ListType.followers {
            _setTitle("记本听众")
        }
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ListCell", bundle: nil), forCellReuseIdentifier: "ListCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.BackgroundColor()
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
        vc.type = ListType.invite
        vc.id = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c: ListCell! = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as? ListCell
        let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        c.data = data
        c.type = type
        c.num = (indexPath as NSIndexPath).row
        c.id = id
        c.setup()
        c.delegate = self
        return c
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70 + globalHalf
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexDelete = (indexPath as NSIndexPath).row
        if let dataMe = dataArray[0] as? NSDictionary {
            let uid = dataMe.stringAttributeForKey("uid")
            if uid == SAUid() {
                /* 确保是创建者本人 
                ** 同时是成员页面
                ** 同时不是第一个 indexPath
                */
                if type == ListType.members && (indexPath as NSIndexPath).row > 0 {
                    actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                    actionSheet.addButton(withTitle: "移出这个记本")
                    actionSheet.addButton(withTitle: "取消")
                    actionSheet.cancelButtonIndex = 1
                    actionSheet.show(in: self.view)
                }
            }
        }
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            /* 需要先获得 uid 再移除，不然会越界 */
            if let data = dataArray[indexDelete] as? NSDictionary {
                let uid = data.stringAttributeForKey("uid")
                Api.getKick(id, uid: uid) { json in
                }
            }
            dataArray.removeObject(at: indexDelete)
            tableView.beginUpdates()
            tableView.deleteRows(at: [IndexPath(row: indexDelete, section: 0)], with: UITableViewRowAnimation.left)
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
    
    func update(_ index: Int, key: String, value: String) {
        if let data = dataArray[index] as? NSDictionary {
           let mutableData = NSMutableDictionary(dictionary: data)
            mutableData.setValue(value, forKey: key)
            dataArray.replaceObject(at: index, with: mutableData)
            tableView.reloadData()
        }
    }
    
    func load(_ clear: Bool) {
        if clear {
            page = 1
        }
        /* 邀请列表 */
        if type == ListType.invite {
            Api.getMultiInviteList(id, page: page) { json in
                if json != nil {
                    if let j = json as? NSDictionary {
                        let err = j.stringAttributeForKey("error")
                        if err == "0" {
                            if let items = json!.object(forKey: "data") as? NSArray {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                for item in items {
                                    self.dataArray.add(item)
                                }
                            }
                            self.page += 1
                            self.tableView.reloadData()
                            self.tableView.headerEndRefreshing()
                            self.tableView.footerEndRefreshing()
                        } else {
                            self.showTipText("服务器坏了")
                        }
                    }
                }
            }
        } else if type == ListType.members {
            Api.getMultiDreamList(id, page: page) { json in
                if json != nil {
                    if let j = json as? NSDictionary {
                        let err = j.stringAttributeForKey("error")
                        if err == "0" {
                            if let items = json!.object(forKey: "data") as? NSArray {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                for item in items {
                                    self.dataArray.add(item)
                                }
                            }
                            self.page += 1
                            self.tableView.reloadData()
                            self.tableView.headerEndRefreshing()
                            self.tableView.footerEndRefreshing()
                        } else {
                            self.showTipText("服务器坏了")
                        }
                    }
                }
            }
        } else if type == ListType.like {
            Api.getLike(page, stepId: id) { json in
                if json != nil {
                    if let j = json as? NSDictionary {
                        let err = j.stringAttributeForKey("error")
                        if err == "0" {
                            if let items = json!.object(forKey: "data") as? NSArray {
                                if clear {
                                    self.dataArray.removeAllObjects()
                                }
                                for item in items {
                                    self.dataArray.add(item)
                                }
                            }
                            self.page += 1
                            self.tableView.reloadData()
                            self.tableView.headerEndRefreshing()
                            self.tableView.footerEndRefreshing()
                        } else {
                            self.showTipText("服务器坏了")
                        }
                    }
                }
            }
        } else if type == ListType.followers {
            Api.getDreamFollow(id, page: page) { json in
                if json != nil {
                    if let j = json as? NSDictionary {
                        let err = j.stringAttributeForKey("error")
                        if err == "0" {
                            if let data = json!.object(forKey: "data") as? NSDictionary {
                                if let users = data.object(forKey: "users") as? NSArray {
                                    if clear {
                                        self.dataArray.removeAllObjects()
                                    }
                                    for item in users {
                                        self.dataArray.add(item)
                                    }
                                }
                            }
                            self.page += 1
                            self.tableView.reloadData()
                            self.tableView.headerEndRefreshing()
                            self.tableView.footerEndRefreshing()
                        } else {
                            self.showTipText("服务器坏了")
                        }
                    }
                }
            }
        } else if type == ListType.dreamLikes {
            Api.getDreamLike(id, page: page) { json in
                if json != nil {
                    if let j = json as? NSDictionary {
                        let err = j.stringAttributeForKey("error")
                        if err == "0" {
                            if let data = json!.object(forKey: "data") as? NSDictionary {
                                if let users = data.object(forKey: "users") as? NSArray {
                                    if clear {
                                        self.dataArray.removeAllObjects()
                                    }
                                    for item in users {
                                        self.dataArray.add(item)
                                    }
                                }
                            }
                            self.page += 1
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
