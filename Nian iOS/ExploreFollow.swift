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
    
    var targetRect: NSValue?
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        viewController.tableView.estimatedRowHeight = 200
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
        
        return tableView.fd_heightForCellWithIdentifier("SAStepCell", cacheByIndexPath: indexPath, configuration: { cell in
            (cell as! SAStepCell).celldataSource = self
            (cell as! SAStepCell).fd_enforceFrameLayout = true
            (cell as! SAStepCell).data = data
            (cell as! SAStepCell).indexPath = indexPath
        })
    }
    
    /* 这是一个不可用的恶魔函数 */
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        println(" !@#$%^&*()___(*^%$#@!#$%^&*() indexPath \(indexPath.row)   ")
//        
//        return 200
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
        c.delegate = self
//        if indexPath.row > self.dataArray.count {
//            return c
//        }
        c.data = self.dataArray[indexPath.row] as! NSDictionary
        c.index = indexPath.row
        if indexPath.row == self.dataArray.count - 1 {
            c.viewLine.hidden = true
        } else {
            c.viewLine.hidden = false
        }
        
        var _shouldLoadImage = self.shouldLoadCellImage(c, withIndexPath: indexPath)
        c._layoutSubviews(_shouldLoadImage)
        
        return c
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        var data = dataArray[indexPath.row] as! NSDictionary
        var id = data.stringAttributeForKey("dream")
        viewController.Id = id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        var data = dataArray[indexPath.row] as! NSDictionary
        var type = data.stringAttributeForKey("type")
        
        switch type {
        case "0":
            break
        case "1":
            (cell as! SAStepCell).imageHolder.cancelImageRequestOperation()
            (cell as! SAStepCell).imageHolder.image = nil
        default:
            break
        }
        
    }
    
    /**
    :returns: Bool值，代表是否要加载图片
    */
    func shouldLoadCellImage(cell: SAStepCell, withIndexPath indexPath: NSIndexPath) -> Bool {
        if (self.targetRect != nil) && !CGRectIntersectsRect(self.targetRect!.CGRectValue(), self.bindViewController!.tableView.rectForRowAtIndexPath(indexPath)) {
            return false
        }
        
        return true
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

extension ExploreFollowProvider: SAStepCellDatasource {
    func saStepCell(indexPath: NSIndexPath, content: String, contentHeight: CGFloat) {
        
        var _tmpDict = NSMutableDictionary(dictionary: self.dataArray[indexPath.row] as! NSDictionary)
        _tmpDict.setObject(content, forKey: "content")
        
        #if CGFLOAT_IS_DOUBLE
            _tmpDict.setObject(NSNumber(double: Double(contentHeight)), forKey: "contentHeight")
        #else
            _tmpDict.setObject(NSNumber(float: Float(contentHeight)), forKey: "contentHeight")
        #endif
        
        self.dataArray.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
    }
}


// MARK: - 实现 scroll view delegate, aim --> 优化用户体验
extension ExploreFollowProvider: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.targetRect = nil
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var targetRect: CGRect = CGRectMake(targetContentOffset.memory.x, targetContentOffset.memory.y, scrollView.frame.size.width, scrollView.frame.size.height)
        self.targetRect = NSValue(CGRect: targetRect)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.targetRect = nil
        
        self.loadImagesForVisibleCells()
    }
    
    
    func loadImagesForVisibleCells() {
        var cellArray = self.bindViewController?.tableView.visibleCells()
        
        for cell in cellArray! {
            if cell is SAStepCell {
                var indexPath = self.bindViewController?.tableView.indexPathForCell(cell as! SAStepCell)
                var _tmpShouldLoadImg = false
                
                if let _indexPath = indexPath {
                    _tmpShouldLoadImg = self.shouldLoadCellImage(cell as! SAStepCell, withIndexPath: _indexPath)
                }
                
                if _tmpShouldLoadImg {
                    self.bindViewController?.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
                }
            }
        }
    }
}
















