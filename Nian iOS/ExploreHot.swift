//
//  ExploreHotCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/13.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreHotProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource {
    
    class Data {
        var id: String!
        var uid: String!
        var user: String!
        var des: String!
        var title: String!
        var img: String!
    }
    
    weak var bindViewController: ExploreViewController?
    var dataSource = [Data]()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "ExploreHotCell", bundle: nil), forCellReuseIdentifier: "ExploreHotCell")
    }
    
    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreHot() {
            json in
            var success = false
            if json != nil {
                var items = json!["items"] as NSArray
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                    success = true
                    for item in items {
                        var data = Data()
                        data.id = item["id"] as String
                        data.uid = item["uid"] as String
                        data.user = item["user"] as String
                        data.des = item["des"] as String
                        data.title = item["title"] as String
                        data.img = item["img"] as String
                        self.dataSource.append(data)
                    }
                }
            }
            callback(success)
        }
    }
    
    override func onHide() {
        bindViewController!.tableView.headerEndRefreshing(animated: false)
        self.bindViewController!.tableView.setFooterHidden(false)
    }
    
    override func onShow() {
        bindViewController!.tableView.setFooterHidden(true)
        bindViewController!.tableView.reloadData()
        if dataSource.isEmpty {
            bindViewController!.tableView.headerBeginRefreshing()
        } else {
            bindViewController!.tableView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    override func onRefresh() {
        load(true) {
            success in
            if self.bindViewController!.current == 2 {
                self.bindViewController!.tableView.headerEndRefreshing()
                self.bindViewController!.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 171
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExploreHotCell", forIndexPath: indexPath) as? ExploreHotCell
        cell!.bindData(dataSource[indexPath.row])
        cell!.tag = indexPath.row
        cell!.labelRank.text = "\(indexPath.row + 1)"
        cell!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamTap:"))
        return cell!
    }
    
    func onDreamTap(sender: UITapGestureRecognizer) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].id
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
}

class ExploreHotCell: UITableViewCell {
    
    @IBOutlet var labelRank: UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var labelUser: UILabel!
    @IBOutlet var imageDream: UIImageView!
    
    func bindData(data: ExploreHotProvider.Data) {
        labelUser.text = data.user
        labelUser.sizeToFit()
        var userFrame = labelUser.frame
        if userFrame.size.width > 200 {
            userFrame.size.width = 200
            labelUser.frame = userFrame
        }
        labelTitle.text = data.title
        labelTitle.sizeToFit()
        var titleFrame = labelTitle.frame
        if titleFrame.size.width > 200 {
            titleFrame.size.width = 200
            labelTitle.frame = titleFrame
        }
        labelContent.text = data.des.isEmpty ? "暂无简介" : data.des
        imageDream.setImage(V.urlDreamImage(data.img, tag: .iOS), placeHolder: IconColor)
    }
}