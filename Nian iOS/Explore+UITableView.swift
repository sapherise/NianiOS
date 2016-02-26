//
//  Explore+UITableView.swift
//  Nian iOS
//
//  Created by Sa on 15/10/18.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension ExploreViewController {
    
    func setupTables() {
        
        // 关注
        tableView = VVeboTableView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 49), style: .Plain)
        scrollView.addSubview(tableView)
        currenTableView = tableView
        
        // 动态
        tableViewDynamic = VVeboTableView(frame: CGRectMake(globalWidth, 0, globalWidth, globalHeight - 64 - 49), style: .Plain)
        tableViewDynamic.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        scrollView.addSubview(tableViewDynamic)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableViewDynamic.dataSource = self
        tableViewDynamic.delegate = self
        
        scrollView.scrollsToTop = false
        tableView.scrollsToTop = true
        tableViewDynamic.scrollsToTop = false
        
        tableView.addHeaderWithCallback { () -> Void in
            self.load(true)
        }
        tableView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
        tableViewDynamic.addHeaderWithCallback { () -> Void in
            self.loadDynamic(true)
        }
        tableViewDynamic.addFooterWithCallback { () -> Void in
            self.loadDynamic(false)
        }
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreFollow("\(page++)", callback: {
            json in
            print(json)
            if json != nil {
                globalTabhasLoaded[0] = true
                if clear {
                    globalVVeboReload = true
                    self.dataArray.removeAllObjects()
                } else {
                    globalVVeboReload = false
                }
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    for item in items {
                        let data = VVeboCell.SACellDataRecode(item as! NSDictionary)
                        self.dataArray.addObject(data)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.tableHeaderView = nil
                } else if clear {
                    self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableView.tableHeaderView?.addGhost("这是关注页面！\n当你关注了一些人或记本时\n这里会发生微妙变化")
                }
                if self.current == 0 {
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func loadDynamic(clear: Bool) {
        if clear {
            pageDynamic = 1
        }
        Api.getExploreDynamic("\(pageDynamic++)", callback: {
            json in
            if json != nil {
                globalTabhasLoaded[1] = true
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    if clear {
                        globalVVeboReload = true
                        self.dataArrayDynamic.removeAllObjects()
                    } else {
                        globalVVeboReload = false
                    }
                    for item in items {
                        let data = VVeboCell.SACellDataRecode(item as! NSDictionary)
                        self.dataArrayDynamic.addObject(data)
                    }
                    self.currentDataArray = self.dataArrayDynamic
                    self.tableViewDynamic.tableHeaderView = nil
                } else if clear {
                    self.tableViewDynamic.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableViewDynamic.tableHeaderView?.addGhost("这是动态页面！\n你关注的人赞过的内容\n都会出现在这里")
                }
                if self.current == 1 {
                    self.tableViewDynamic.headerEndRefreshing()
                    self.tableViewDynamic.footerEndRefreshing()
                    self.tableViewDynamic.reloadData()
                }
            }
        })
    }
}