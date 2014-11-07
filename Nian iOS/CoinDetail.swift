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
    
    var coinDetails = [String]()
    
    override func viewDidLoad() {
        coinDetails.append("")
        coinDetails.append("")
        
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
        
        return cell!
    }
    
    func onPullToRefresh() {
        self.tableView.headerEndRefreshing()
    }
    
    func onPullToLoad() {
        self.tableView.footerEndRefreshing()
    }
}
