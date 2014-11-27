//
//  ExploreFriend.swift
//  Nian iOS
//
//  Created by vizee on 14/11/21.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

class ExploreFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    class Data {
        var uid: String!
        var user: String!
        var detail: String!
        var weibouid: String!
        var weibohead: String!
        var weiboname: String!
    }
    
    let sections = 2
    let titles = ["同类标签推荐", "微博好友推荐", "通讯录好友推荐"]
    
    @IBOutlet var tableView: UITableView!
    
    var tagShowFooter = false
    var weiboShowFooter = false
    var tagPage = 0
    var weiboPage = 0
    var tagSource: [Data] = []
    var weiboSource: [Data] = []
    
    override func viewDidLoad() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(navView)
        viewBack(self)
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = IconColor
        titleLabel.text = "发现好友"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        loadWeibo() {
            success in
            self.tableView.reloadData()
        }
    }
    
    func back() {
        navigationController!.popViewControllerAnimated(true)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return tagSource.count
        case 1:
            return weiboSource.count
        case 2:
            return 0
        default:
            break
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section < sections {
            if (section == 0 && tagSource.count == 0) || (section == 1 && weiboSource.count == 0) {
                return 0
            }
            return 50.5
        }
        return 0
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < sections {
            if section == 0 && (tagSource.count == 0 || !tagShowFooter) {
                return 0
            }
            if  section == 1 && (weiboSource.count == 0 || !weiboShowFooter) {
                return 0
            }
            return 36
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section < sections {
            if section == 0 && tagSource.count == 0 {
                return nil
            }
            if  section == 1 && weiboSource.count == 0 {
                return nil
            }
            var labelTitle = UILabel()
            labelTitle.text = titles[section]
            labelTitle.sizeToFit()
            var v = UIView(frame: CGRectMake(0, 0, 320, 50.5))
            v.backgroundColor = UIColor.whiteColor()
            var frame = labelTitle.frame
            frame.origin.y = 15
            frame.origin.x = (320 - frame.size.width) / 2
            labelTitle.frame = frame
            v.addSubview(labelTitle)
            return v
        }
        return nil
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < sections {
            if section == 0 && (tagSource.count == 0 || !tagShowFooter) {
                return nil
            }
            if  section == 1 && (weiboSource.count == 0 || !weiboShowFooter) {
                return nil
            }
            var button = UIButton(frame: CGRectMake(15, 0, 290, 36))
            button.titleLabel!.font = UIFont.systemFontOfSize(14)
            button.backgroundColor = UIColor.blackColor()
            button.setTitle("加载更多", forState: UIControlState.Normal)
            button.tag = section
            button.addTarget(self, action: "onMoreClick:", forControlEvents: UIControlEvents.TouchUpInside)
            var v = UIView(frame: CGRectMake(0, 0, 320, 36))
            v.backgroundColor = UIColor.whiteColor()
            v.addSubview(button)
            return v
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(indexPath.section == 0 ? "ExploreFriendCell" : "ExploreWeiboCell", forIndexPath: indexPath) as ExploreFriendCell
        switch indexPath.section {
        case 0:
            var data = tagSource[indexPath.row]
            cell.labelName.text = data.user
            cell.labelDetail.text = data.detail
            cell.imageHead.setImage(V.urlHeadImage(data.uid, tag: .Head), placeHolder: IconColor)
            break
        case 1:
            var data = weiboSource[indexPath.row]
            cell.labelName.text = data.weiboname
            cell.imageHead.setImage(data.weibohead, placeHolder: IconColor, bool: true, cacheName: "weibo_\(data.weibouid)");
            break
        default:
            break
        }
        return cell
    }
    
    func onFollowClick(sender: UIButton) {
        
    }
    
    func onMoreClick(sender: UIButton) {
        sender.enabled = false
        sender.setTitle(nil, forState: UIControlState.Normal)
        var loadingView = sender.viewWithTag(101) as UIActivityIndicatorView?
        if loadingView == nil {
            loadingView = UIActivityIndicatorView(frame: CGRectMake(140, 13, 10, 10))
            sender.addSubview(loadingView!)
        } else {
            loadingView!.hidden = false
        }
        loadingView!.startAnimating()
        var callback: (Bool) -> Void = {
            success in
            sender.setTitle("加载更多", forState: UIControlState.Normal)
            loadingView!.stopAnimating()
            loadingView!.hidden = true
            self.tableView.reloadData()
            sender.enabled = true
        }
        switch sender.tag {
        case 0:
            loadTag(callback)
            break
        case 1:
            loadWeibo(callback)
            break
        default:
            break
        }
    }
    
    func loadWeibo(callback: (Bool) -> Void) {
        Api.getFriendFromWeibo("\(weiboPage++)") {
            json in
            if json == nil {
                self.view.showTipText(TextLoadFailed, delay: 1)
            }
            var success = false
            var weibobind = (json!["weibobind"] as String).toInt()!
            if weibobind == 1 {
                var items = json!["items"] as NSArray
                if items.count > 0 {
                    success = true
                    for item in items {
                        var data = Data()
                        data.uid = item["uid"] as String
                        data.user = item["user"] as String
                        data.weibohead = item["weibohead"] as String
                        data.weibouid = item["weibouid"] as String
                        data.weiboname = item["weiboname"] as String
                        self.weiboSource.append(data)
                    }
                }
            }
            self.weiboShowFooter = success
            callback(success)
        }
    }
    
    func loadTag(callback: (Bool) -> Void) {
        callback(false)
    }
}