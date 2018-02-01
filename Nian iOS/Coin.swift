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
        setBarButton("奖励提现", actionGesture: #selector(Coin.toPremium))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @objc func toPremium() {
        let vc = Premium()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setup() {
        _setTitle("念币")
        tableView = UITableView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.GreyBackgroundColor()
        tableView.register(UINib(nibName: "CoinProductCell", bundle: nil), forCellReuseIdentifier: "CoinProductCell")
        tableView.register(UINib(nibName: "CoinProductTop", bundle: nil), forCellReuseIdentifier: "CoinProductTop")
        self.view.addSubview(tableView)
        dataArray = [["title": "会员", "content": "骄傲地成为念的会员", "image": "coin_pro"], ["title": "表情", "content": "表情商店", "image": "coin_emoji"], ["title": "插件", "content": "一些没用的插件", "image": "coin_plugin"]]
        if SAUid() == "171264" {
            dataArray = [["title": "表情", "content": "表情商店", "image": "coin_emoji"], ["title": "插件", "content": "一些没用的插件", "image": "coin_plugin"]]
        }
    }
}
