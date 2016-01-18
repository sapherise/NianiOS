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

class List: SAViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var type: ListType!
    
    /* 其他页面传入的 id */
    var id: String = "-1"
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        load(true)
    }
    
    func setup() {
        if type == ListType.Members {
            _setTitle("邀请")
        } else if type == ListType.Invite {
            
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c: ListCell! = tableView.dequeueReusableCellWithIdentifier("ListCell", forIndexPath: indexPath) as? ListCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.setup()
        return c
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70 + globalHalf
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getMultiInviteList(id, page: page) { json in
            if json != nil {
                if let err = json!.objectForKey("error") as? NSNumber {
                    if err == 0 {
                        if let items = json!.objectForKey("data") as? NSArray {
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