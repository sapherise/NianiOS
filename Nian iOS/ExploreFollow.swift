//
//  ExploreFollowCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/11.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreFollowProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, delegateSAStepCell {
    
    class Data {
        var id: String!
        var sid: String!
        var uid: String!
        var user: String!
        var content: String!
        var lastdate: String!
        var title: String!
        var img: String!
        var img0: Float!
        var img1: Float!
        var like: Int!
        var liked: Int!
        var comment: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 1
    var locked = false
    var dataArray = NSMutableArray()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreFollow("\(page++)", callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArray.removeAllObjects()
                }
                var data: AnyObject? = json!.objectForKey("data")
                var items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    for item in items {
                        self.dataArray.addObject(item)
                    }
                    self.bindViewController?.tableView.tableHeaderView = nil
                } else if clear {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    var viewQuestion = viewEmpty(globalWidth, content: "这是关注页面！\n当你关注了一些人或记本时\n这里会发生微妙变化")
                    viewQuestion.setY(50)
                    viewHeader.addSubview(viewQuestion)
                    self.bindViewController?.tableView.tableHeaderView = viewHeader
                }
                if self.bindViewController!.current == 0 {
                    self.bindViewController!.tableView.headerEndRefreshing()
                    self.bindViewController!.tableView.footerEndRefreshing()
                    self.bindViewController!.tableView.reloadData()
                }
            }
        })
    }
    
    override func onHide() {
        bindViewController!.tableView.headerEndRefreshing(animated: false)
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.tableView.reloadData()
        if dataArray.count == 0 {
            bindViewController!.tableView.headerBeginRefreshing()
        } else {
            if loading {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.bindViewController!.tableView.setContentOffset(CGPointZero, animated: false)
                    }, completion: { (Bool) -> Void in
                        self.bindViewController!.tableView.headerBeginRefreshing()
                })
            }
        }
    }
    
    override func onRefresh() {
        load(true)
    }
    
    override func onLoad() {
        load(false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var data = self.dataArray[indexPath.row] as! NSDictionary
        var h = SAStepCell.cellHeightByData(data)
        return h
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
        c.delegate = self
        c.data = self.dataArray[indexPath.row] as! NSDictionary
        c.index = indexPath.row
        if indexPath.row == self.dataArray.count - 1 {
            c.viewLine.hidden = true
        } else {
            c.viewLine.hidden = false
        }
        return c
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        var data = dataArray[indexPath.row] as! NSDictionary
        var id = data.stringAttributeForKey("dream")
        viewController.Id = id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArray, index, key, value, bindViewController!.tableView!)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 0, bindViewController!.tableView!)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(bindViewController!.tableView!)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArray, index, bindViewController!.tableView!, 0)
    }
    
}

// MARK: - 实现 scroll view delegate, aim --> 优化用户体验
//extension ExploreFollowProvider: UIScrollViewDelegate {
//    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if scrollView .isKindOfClass(UITableView) {
//            for cell in (scrollView as! UITableView).visibleCells() {
//                (cell as! SAStepCell).imageHolder.cancelImageRequestOperation()
//                (cell as! SAStepCell).imageHolder.image = nil
//            }
//        }
//    }
//    
//    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if scrollView.isKindOfClass(UITableView) {
//            if !decelerate {
//                
//            }
//        }
//    }
//    
//    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
//        if scrollView.isKindOfClass(UITableView) {
//            (scrollView as! UITableView).reloadData()
//        }
//    }
//}

