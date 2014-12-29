//
//  CoinDetial.swift
//  Nian iOS
//
//  Created by vizee on 14/11/6.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class CoinDetailViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    var navView: UIView!
    
    let things = ["", "更新进展", "解除封号"]
    
    var coinDetails = [(String, String, Int, String)]()
    var page = 0
    
    override func viewDidLoad() {
        setupViews()
        setupRefresh()
        loadData(0);
    }
    
    func setupViews() {
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        var titleLabel:UILabel = UILabel(frame: CGRectZero)
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "念币详情"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.view.backgroundColor = BGColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback({
            self.page = 0
            self.coinDetails.removeAll(keepCapacity: true)
            self.loadData(1)
        })
        self.tableView.addFooterWithCallback({
            self.loadData(2)
        })
    }
    
    func back() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.coinDetails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CoinDetailCell", forIndexPath: indexPath) as? CoinDetailCell
        let (icon, coin, thing, lastdate) = self.coinDetails[indexPath.row]
        cell!.textDetail.text = "\(coin) 念币"
        cell!.textType.text = "\(things[thing])"
        cell!.textDate.text = lastdate
        return cell!
    }
    
    func loadData(forWhich: Int) {
        Api.getCoinDetial("\(page++)") { json in
            if json != nil {
                let current = (json!.objectForKey("time") as NSString).doubleValue
                let items = json!.objectForKey("items") as NSArray
                let success = (items.count != 0)
                for item in items {
                    self.coinDetails.append(("", (item.objectForKey("coin") as String), (item.objectForKey("thing") as String).toInt()!, V.relativeTime((item.objectForKey("lastdate") as NSString).doubleValue, current: current)))
                }
                if success {
                    self.tableView.reloadData()
                } else {
                    self.tableView.showTipText("已经到底了", delay: 1)
                }
            }
            switch forWhich {
            case 1:
                self.tableView.headerEndRefreshing()
                break
            case 2:
                self.tableView.footerEndRefreshing()
                break
            default:
                break
            }
        }
    }
}
