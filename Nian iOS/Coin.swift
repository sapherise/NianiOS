//
//  Coin.swift
//  Nian iOS
//
//  Created by Sa on 16/2/24.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Coin: SAViewController, UITableViewDataSource, UITableViewDelegate {
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
        print("重载了该界面")
    }
    
    func setup() {
        _setTitle("念币")
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.GreyBackgroundColor()
        tableView.registerNib(UINib(nibName: "CoinProductCell", bundle: nil), forCellReuseIdentifier: "CoinProductCell")
        tableView.registerNib(UINib(nibName: "CoinProductTop", bundle: nil), forCellReuseIdentifier: "CoinProductTop")
        self.view.addSubview(tableView)
        dataArray = [["title": "会员", "content": "骄傲地成为念的会员", "image": "coin_pro"], ["title": "表情", "content": "表情商店", "image": "coin_emoji"], ["title": "主题", "content": "主题商店", "image": "coin_theme"], ["title": "插件", "content": "一些没用的插件", "image": "coin_plugin"]]
        if SAUid() == "171264" {
            dataArray = [["title": "表情", "content": "表情商店", "image": "coin_emoji"], ["title": "主题", "content": "主题商店", "image": "coin_theme"], ["title": "插件", "content": "一些没用的插件", "image": "coin_plugin"]]
        }
    }
}