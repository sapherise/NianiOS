//
//  ExploreNewHot.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/22/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreNewHot: ExploreProvider, UITableViewDelegate, UITableViewDataSource {
    
    weak var bindViewController: ExploreViewController?
    var dataArray = NSMutableArray()
    var page = 1
    var lastID = "0"
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.recomTableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
    }
    
    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreNewHot("\(lastID)", page: "\(page++)", callback: {
            json in
            var success = false
            
            if json != nil {
                var arr = json!["items"] as! NSArray
                
                if clear {
                    self.dataArray.removeAllObjects()
                }
                
                success = true
                
                for data: AnyObject in arr {
                    self.dataArray.addObject(data)
                }
                
                var count = self.dataArray.count
                
                if count >= 1 {
                    var data = self.dataArray[count - 1] as! NSDictionary
                    self.lastID = data.stringAttributeForKey("id")
                }
            }
            callback(success)
        })
    }
    
    
    override func onHide() {
        bindViewController!.recomTableView.headerEndRefreshing(animated: false)
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.recomTableView.reloadData()
        
        if dataArray.count == 0 {
            bindViewController!.recomTableView.headerBeginRefreshing()
        } else {
//            UIView.animateWithDuration(0.2,
//                animations: { () -> Void in
//                    self.bindViewController!.recomTableView.setContentOffset(CGPointZero, animated: false)
//                }, completion: { (Bool) -> Void in
//                    if loading {
//                        self.bindViewController!.recomTableView.headerBeginRefreshing()
//                    }
//            })
        }
    }
    
    override func onRefresh() {
        page = 1
        self.lastID = "0"
        load(true) {
            success in
            if self.bindViewController!.current == 2 {
                self.bindViewController!.recomTableView.headerEndRefreshing()
                self.bindViewController!.recomTableView.reloadData()
            }
        }
    }
    
    override func onLoad() {
        load(false) {
            success in
            if self.bindViewController!.current == 2 {
                if success {
                    self.bindViewController!.recomTableView.footerEndRefreshing()
                    self.bindViewController!.recomTableView.reloadData()
                } else {
                    self.bindViewController!.view.showTipText("已经到底啦", delay: 1)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        
        if index == self.dataArray.count - 1 {
            return ExploreNewHotCell.cellHeightByData(data) - 15
        }
        
        return  ExploreNewHotCell.cellHeightByData(data)
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExploreNewHotCell", forIndexPath: indexPath) as? ExploreNewHotCell
        cell!.data = self.dataArray[indexPath.row] as! NSDictionary
        
        if indexPath.row == self.dataArray.count - 1 {
            cell!.viewLine.hidden = true
        } else {
            cell!.viewLine.hidden = false
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        viewController.Id = (dataArray[indexPath.row] as! NSDictionary).objectForKey("id") as! String
        
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
}
