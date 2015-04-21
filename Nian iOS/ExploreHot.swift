//
//  ExploreHotCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/13.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreHotProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    class Data {
        var id: String!
        var uid: String!
        var user: String!
        var des: String!
        var title: String!
        var img: String!
        var step: String!
        var like: String!
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
                var items = json!["items"] as! NSArray
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                    success = true
                    for item in items {
                        var data = Data()
                        data.id = item["id"] as! String
                        data.uid = item["uid"] as! String
                        data.user = item["user"] as! String
                        data.des = item["des"] as! String
                        data.title = item["title"] as! String
                        data.img = item["img"] as! String
                        data.step = item["step"] as! String
                        data.like = item["like"] as! String
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
    
    override func onShow(loading: Bool) {
        bindViewController!.tableView.setFooterHidden(true)
        bindViewController!.tableView.reloadData()
        if dataSource.isEmpty {
            bindViewController!.tableView.headerBeginRefreshing()
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.bindViewController!.tableView.setContentOffset(CGPointZero, animated: false)
                }, completion: { (Bool) -> Void in
                    if loading {
                        self.bindViewController!.tableView.headerBeginRefreshing()
                    }
            })
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
        return 300
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExploreHotCell", forIndexPath: indexPath) as? ExploreHotCell
        cell!.bindData(dataSource[indexPath.row], tableview: tableView)
        cell!.tag = indexPath.row
        cell!.labelRank.text = "\(indexPath.row + 1)"
        cell!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamTap:"))
        cell!.btnMain.addTarget(self, action: "onBtnMainClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if indexPath.row == self.dataSource.count - 1 {
            cell!.viewLine.hidden = true
        }else{
            cell!.viewLine.hidden = false
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50;
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
       var visiblePaths = bindViewController!.tableView.indexPathsForVisibleRows()! as Array
        
        for item in visiblePaths {
            let indexPath = item as! NSIndexPath
            
            let cell = bindViewController!.tableView.cellForRowAtIndexPath(indexPath) as! ExploreHotCell
            
            if cell.imageDream.image == nil {
                cell.bindData(dataSource[indexPath.row], tableview: bindViewController!.tableView)
            }
        }
        
    }

    func onDreamTap(sender: UITapGestureRecognizer) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].id
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onBtnMainClick(sender: UIButton) {
        var viewController = DreamViewController()
        viewController.Id = "\(sender.tag)"
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
}

class ExploreHotCell: UITableViewCell {
    
    @IBOutlet var labelRank: UILabel!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelLike: UILabel!
    @IBOutlet var labelStep: UILabel!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewHolder: UIView!
    
    override func awakeFromNib() {
        self.viewLine.setWidth(globalWidth)
        viewHolder.setX(globalWidth/2-160)
    }
    
    func bindData(data: ExploreHotProvider.Data, tableview: UITableView) {
        labelTitle.text = data.title
        labelStep.text = data.step
        labelLike.text = data.like

        imageDream.setImage(V.urlDreamImage(data.img, tag: .iOS), placeHolder: IconColor)
        btnMain.tag = data.id.toInt()!
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageDream.cancelImageRequestOperation()   
        self.imageDream.image = nil
    }
}