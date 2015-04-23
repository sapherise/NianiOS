//
//  ExploreNewHot.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/22/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class ExploreNewHot: ExploreProvider, UITableViewDelegate, UITableViewDataSource {
    
    class Data {
        var id: String!
        var title: String!
        var img: String!
        var type: String!
        var content: String!
    }
    
    weak var bindViewController: ExploreViewController?
    var dataSource = [Data]()
    var page = 0
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
    }

    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreNewHot("\(page++)", callback: {
            json in
            var success = false
            
            if json != nil {
                var items = json!["items"] as! NSArray
                
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                }
                success = true
                
                for item in items {
                    var data = Data()
                    data.id = item["id"] as! String
                    data.title = item["title"] as! String
                    data.img = item["img"] as! String
                    data.content = item["content"] as! String
                    data.type = item["type"] as! String
                    self.dataSource.append(data)
                }
            }
            callback(success)
        })
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
            UIView.animateWithDuration(0.2,
                animations: { () -> Void in
                    self.bindViewController!.tableView.setContentOffset(CGPointZero, animated: false)
            }, completion: { (Bool) -> Void in
                    self.bindViewController!.tableView.headerBeginRefreshing()
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
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return  81
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExploreNewHotCell", forIndexPath: indexPath) as? ExploreNewHotCell
        cell!.bindData(dataSource[indexPath.row], tableview: tableView)
        
        if indexPath.row == self.dataSource.count - 1 {
            
        } else {
            
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[indexPath.row].id
        var data = dataSource[indexPath.row]
       
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }


    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var visiblePaths = bindViewController!.tableView.indexPathsForVisibleRows()! as Array
        
        for item in visiblePaths {
            let indexPath = item as! NSIndexPath
            let cell = bindViewController!.tableView.cellForRowAtIndexPath(indexPath) as! ExploreNewHotCell
            
            if cell.imageHead.image == nil {
                cell.bindData(dataSource[indexPath.row], tableview: bindViewController!.tableView)
            }
        }
    }
    

    
    
}
