//
//  Premium.swift
//  NianiOS
//
//  Created by Sa on 16/4/7.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Premium: SAViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("奖励提现")
        setup()
    }
    
    func setup() {
        dataArray = [["title": "购买优惠", "content": "念币商店表情、主题 30% 的折扣。", "image": "vip_discount"], ["title": "身份标识", "content": "每条进展都有好看的会员标识。", "image": "vip_mark"], ["title": "表达你的喜爱", "content": "蟹蟹你对念的支持 :))", "image": "vip_love"]]
        
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "CoinProductTop", bundle: nil), forCellReuseIdentifier: "CoinProductTop")
        tableView.registerNib(UINib(nibName: "PremiumCell", bundle: nil), forCellReuseIdentifier: "PremiumCell")
        self.view.addSubview(tableView)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let c: CoinProductTop! = tableView.dequeueReusableCellWithIdentifier("CoinProductTop", forIndexPath: indexPath) as? CoinProductTop
            c.setup()
            c.labelTitle.text = "余额"
            c.labelContent.text = "¥ 301.41"
            c.btn.setTitle("提现", forState: UIControlState())
            c.viewLine.setX(40)
            c.viewLine.setWidth(globalWidth - 80)
            return c
        } else {
            let c: PremiumCell! = tableView.dequeueReusableCellWithIdentifier("PremiumCell", forIndexPath: indexPath) as? PremiumCell
            c.data = dataArray[indexPath.row] as! NSDictionary
            c.setup()
            return c
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 261
        } else {
            return 72
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return dataArray.count
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
}