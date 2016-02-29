//
//  Recharge.swift
//  Nian iOS
//
//  Created by Sa on 16/2/28.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Recharge: SAViewController, UITableViewDataSource, UITableViewDelegate, NIAlertDelegate {
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var alert: NIAlert!
    var alertResult: NIAlert!
    var index = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        _setTitle("念币充值")
        
        dataArray = [["title": "12", "price": "6"], ["title": "30", "price": "12"], ["title": "65", "price": "25"], ["title": "140", "price": "50"], ["title": "295", "price": "98"]]
        
        tableView = UITableView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        tableView.backgroundColor = UIColor.GreyBackgroundColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "RechargeCell", bundle: nil), forCellReuseIdentifier: "RechargeCell")
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onWechatResult:", name: "onWechatResult", object: nil)
    }
    
    func onClick(sender: UIButton) {
        /* 调用微信支付或者支付宝支付 */
        index = sender.tag
        alert = NIAlert()
        alert.delegate = self
        alert.dict = ["img": UIImage(named: "pay_wallet")!, "title": "购买", "content": "选择一种支付方式", "buttonArray": ["微信支付", "支付宝支付"]]
        alert.showWithAnimation(showAnimationStyle.flip)
    }
}