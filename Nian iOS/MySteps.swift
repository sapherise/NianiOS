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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewBackFix()
    }
    
    func setupViews() {
        viewBack()
        navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(navView)
        self.view.backgroundColor = UIColor.white
        
        tableView = VVeboTableView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        currenTableView = tableView
        
        navigationController?.navigationBar.tintColor = UIColor.white
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.text = type == CollectType.mysteps ? "我的进展" : "赞过的进展"
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
    }
    
    func load(_ clear: Bool) {
        if clear {
            page = 1
        }
        if type == CollectType.mysteps {
            Api.getUserActive(SAUid(), page: page) { json in
                if json != nil {
                    let data = json!.object(forKey: "data")
                    let arr = (data! as AnyObject).object(forKey: "steps") as! NSArray
                    if clear {
                        self.dataArray.removeAllObjects()
                        globalVVeboReload = true
                    } else {
                        globalVVeboReload = false
                    }
                    for data in arr {
                        let d = VVeboCell.SACellDataRecode(data as! NSDictionary)
                        self.dataArray.add(d)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.reloadData()
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.page += 1
                }
            }
        } else {
            Api.getLikeSteps(page) { json in
                if json != nil {
                    let arr = json!.object(forKey: "data") as! NSArray
                    if clear {
                        self.dataArray.removeAllObjects()
                        globalVVeboReload = true
                    } else {
                        globalVVeboReload = false
                    }
                    for data in arr {
                        let d = VVeboCell.SACellDataRecode(data as! NSDictionary)
                        self.dataArray.add(d)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.reloadData()
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.page += 1
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(indexPath, dataArray: dataArray, type: 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeight(indexPath, dataArray: dataArray)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
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
