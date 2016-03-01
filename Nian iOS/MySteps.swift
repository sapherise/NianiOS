//
//  MySteps.swift
//  Nian iOS
//
//  Created by Sa on 16/1/6.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

enum CollectType {
    /* 我的进展 */
    case mysteps
    
    /* 我赞过的进展 */
    case likesteps
}

class MySteps: VVeboViewController, UITableViewDelegate, UITableViewDataSource {
    var page: Int = 1
    var navView: UIView!
    var tableView: VVeboTableView!
    var dataArray = NSMutableArray()
    var type: CollectType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        tableView.headerBeginRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewBackFix()
    }
    
    func setupViews() {
        viewBack()
        navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(navView)
        self.view.backgroundColor = UIColor.whiteColor()
        
        tableView = VVeboTableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        currenTableView = tableView
        
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = type == CollectType.mysteps ? "我的进展" : "赞过的进展"
        titleLabel.textAlignment = .Center
        navigationItem.titleView = titleLabel
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        if type == CollectType.mysteps {
            Api.getUserActive(SAUid(), page: page) { json in
                if json != nil {
                    let data = json!.objectForKey("data")
                    let arr = data!.objectForKey("steps") as! NSArray
                    if clear {
                        self.dataArray.removeAllObjects()
                        globalVVeboReload = true
                    } else {
                        globalVVeboReload = false
                    }
                    for data in arr {
                        let d = VVeboCell.SACellDataRecode(data as! NSDictionary)
                        self.dataArray.addObject(d)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.reloadData()
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.page++
                }
            }
        } else {
            Api.getLikeSteps(page) { json in
                if json != nil {
                    let arr = json!.objectForKey("data") as! NSArray
                    if clear {
                        self.dataArray.removeAllObjects()
                        globalVVeboReload = true
                    } else {
                        globalVVeboReload = false
                    }
                    for data in arr {
                        let d = VVeboCell.SACellDataRecode(data as! NSDictionary)
                        self.dataArray.addObject(d)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.reloadData()
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.page++
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return getCell(indexPath, dataArray: dataArray, type: 1)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return getHeight(indexPath, dataArray: dataArray)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("dream")
        let vc = DreamViewController()
        vc.Id = id
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupRefresh() {
        tableView.addHeaderWithCallback { () -> Void in
            self.load(true)
        }
        tableView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
    }
}