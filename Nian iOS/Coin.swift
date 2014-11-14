//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import UIKit

class CoinViewController: UIViewController, UIGestureRecognizerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    typealias CoinCellData = (icon: String, title: String, description: String, cost: String)
    
    let coinItems: [CoinCellData] = [
        ("", "5 念币", "⽴刻获得 5 枚念币。", "¥ 5.00"),
        ("", "12 念币", "⽴刻获得 12 枚念币。", "¥ 10.00"),
        ("", "25 念币", "⽴刻获得 25 枚念币。", "¥ 20.00"),
        ("", "65 念币", "⽴刻获得 65 枚念币。", "¥ 50.00"),
        ("", "140 念币", "⽴刻获得 140 枚念币。", "¥ 100.00")
    ]
    
    let propItems: [CoinCellData] = [
        ("", "理想等级", "开启你的梦想的等级、进度条与自我奖励模块～", "5 念币"),
        ("", "计数器", "可以一直增加计数！这么无聊的东西千万别买！", "5 念币"),
        ("", "小伙伴", "可以让好友一同监督协助你更新进展！", "5 念币"),
        ("", "请假", "72小时内不会被停号，这么酷的功能请在紧急状况下购买！", "2 念币"),
        ("", "废纸篓", "还记得最初的梦想吗？在这里可以找回来。", "去恢复"),
        ("", "毕业证", "永不停号。入手这一份证明时，希望你已从念获益。", "100 念币")
    ]
    
    @IBOutlet var tableView: UITableView!
    var headerCoin: UILabel!
    
    var navView: UIView!
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews() {
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(self.navView)
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = IconColor
        titleLabel.text = "念币"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        self.view.backgroundColor = BGColor
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.allowsSelection = false
        var header = UIView(frame: CGRectMake(0, 0, globalWidth, 200))
        var headerClickable = UIView(frame: CGRectMake((globalWidth - 180) / 2, 10, 180, 180))
        headerClickable.backgroundColor = UIColor.blackColor()
        headerClickable.layer.masksToBounds = true
        headerClickable.layer.cornerRadius = 90
        headerClickable.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHeaderCoinClick"))
        header.addSubview(headerClickable)
        var headerText = UILabel(frame: CGRectMake((globalWidth - 40) / 2, 60, 40, 20))
        headerText.textColor = UIColor.whiteColor()
        headerText.textAlignment = NSTextAlignment.Center
        headerText.text = "念币"
        header.addSubview(headerText)
        self.headerCoin = UILabel(frame: CGRectMake(0, 90, 0, 0))
        self.headerCoin.font = UIFont.systemFontOfSize(24)
        self.headerCoin.textColor = BlueColor
        header.addSubview(self.headerCoin)
        self.tableView.tableHeaderView = header
        Api.getUserMe() { json in
            if json != nil {
                var sa: AnyObject! = json!.objectForKey("user")
                var coin: AnyObject! = sa.objectForKey("coin") as String
                self.setCoin("\(coin)")
            }
        }
    }
    
    func back() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func setCoin(number: String) {
        self.headerCoin.text = number
        self.headerCoin.sizeToFit()
        self.headerCoin.setX((globalWidth - headerCoin.width()) / 2)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return coinItems.count
        case 1:
            return propItems.count
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CoinCell", forIndexPath: indexPath) as? CoinCell
        cell!.btnBuy.tag = indexPath.row
        var (icon, title, desp, cost) = indexPath.section == 0 ? coinItems[indexPath.row] : propItems[indexPath.row]
        cell!.setupView(icon, title: title, description: desp, cost: cost)
        if indexPath.section == 0 {
            cell!.btnBuy.addTarget(self, action: "onBuyCoinClick:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell!.btnBuy.addTarget(self, action: "onBuyPropClick:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let (_, _, desp, _) = indexPath.section == 0 ? coinItems[indexPath.row] : propItems[indexPath.row]
        return CoinCell.getDespHeight(desp) + 54
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "念铺" : "实验室"
    }
    
    func onHeaderCoinClick() {
        var storyboard = UIStoryboard(name: "CoinDetail", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("CoinDetailViewController") as UIViewController
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onBuyCoinClick(sender: UIButton) {
        switch sender.tag {
        case 0:
            break
        default:
            break
        }
    }
    
    func onBuyPropClick(sender: UIButton) {
        switch sender.tag {
        case 0:
            break
        default:
            break
        }
    }
}
