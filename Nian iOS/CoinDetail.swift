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
    
    let things = ["", "更新进展", "解除封号"]
    
    var coinDetails = [(String, String, Int, String)]()
    var page = 0
    
    override func viewDidLoad() {
        setupViews()
        setupRefresh()
    }
    
    func setupViews() {
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        var titleLabel:UILabel = UILabel(frame: CGRectZero)
        titleLabel.textColor = IconColor
        titleLabel.text = "念币详情"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.view.backgroundColor = BGColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
    }
    
    func setupRefresh() {
        self.tableView.addHeaderWithCallback(onPullToRefresh)
        self.tableView.addFooterWithCallback(onPullToLoad)
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
    
    func loadData(forHeader: Bool) {
        Api.getCoinDetial("\(page++)") { json in
            let current = (json!.objectForKey("time") as NSString).doubleValue
            let items = json!.objectForKey("items") as NSArray
            for item in items {
                self.coinDetails.append(("", (item.objectForKey("coin") as String), (item.objectForKey("thing") as String).toInt()!, V.relativeTime((item.objectForKey("lastdate") as NSString).doubleValue, current: current)))
            }
            self.tableView.reloadData()
            if forHeader {
                self.tableView.headerEndRefreshing()
            } else {
                self.tableView.footerEndRefreshing()
            }
        }
    }
    
    func onPullToRefresh() {
        page = 0
        coinDetails.removeAll(keepCapacity: true)
        loadData(true)
    }
    
    func onPullToLoad() {
        loadData(false)
    }
}
