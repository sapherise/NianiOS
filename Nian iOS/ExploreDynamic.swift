//
//  ExploreDynamicCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/14.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreDynamicProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource, delegateSAStepCell {
    
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
        var uidlike: String!
        var userlike: String!
        var type: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 1
    var dataArray = NSMutableArray()
    
    // 设置一个滚动时的 target rect, 目的是为了判断要不要加载图片
    var targetRect: NSValue?
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.dynamicTableView.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        viewController.dynamicTableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreDynamic("\(page++)", callback: {
            json in
            if json != nil {
                globalTab[1] = false
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    if clear {
                        self.dataArray.removeAllObjects()
                    }
                    for item in items {
                        self.dataArray.addObject(item)
                    }
                    self.bindViewController?.dynamicTableView.tableHeaderView = nil
                } else if clear {
                    let viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    let viewQuestion = viewEmpty(globalWidth, content: "这是动态页面！\n你关注的人赞过的内容\n都会出现在这里")
                    viewQuestion.setY(50)
                    viewHeader.addSubview(viewQuestion)
                    self.bindViewController?.dynamicTableView.tableHeaderView = viewHeader
                }
                if self.bindViewController!.current == 1 {
                    self.bindViewController?.dynamicTableView.headerEndRefreshing()
                    self.bindViewController?.dynamicTableView.footerEndRefreshing()
                    self.bindViewController?.dynamicTableView.reloadData()
                }
            }
        })
    }
    
    override func onHide() {
        bindViewController!.dynamicTableView.headerEndRefreshing(false)
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.dynamicTableView.reloadData()
        if dataArray.count == 0 {
            bindViewController!.dynamicTableView.headerBeginRefreshing()
        } else {
            if loading {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.bindViewController!.dynamicTableView.setContentOffset(CGPointZero, animated: false)
                    }, completion: { (Bool) -> Void in
                        self.bindViewController!.dynamicTableView.headerBeginRefreshing()
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let viewController = DreamViewController()
        let data = self.dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("dream")
        viewController.Id = id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
//    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 200
//    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = dataArray[indexPath.row] as! NSDictionary
        let type = data.stringAttributeForKey("type")
        switch type {
        case "0":
            return 77
        case "1":
            return tableView.fd_heightForCellWithIdentifier("SAStepCell", cacheByIndexPath: indexPath, configuration: { cell in
                (cell as! SAStepCell).celldataSource = self
                (cell as! SAStepCell).fd_enforceFrameLayout = true
                (cell as! SAStepCell).data  = data
                (cell as! SAStepCell).indexPath = indexPath
            })
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        let data = dataArray[indexPath.row] as! NSDictionary
        let type = data.stringAttributeForKey("type")
        
        switch type {
        case "0":
            let c = tableView.dequeueReusableCellWithIdentifier("ExploreDynamicDreamCell", forIndexPath: indexPath) as? ExploreDynamicDreamCell
//            dreamCell!.bindData(data, tableview: tableView)
            let data = dataArray[indexPath.row] as! NSDictionary
            c?.data = data
            if indexPath.row == self.dataArray.count - 1 {
                c!.viewLine.hidden = true
            }else{
                c!.viewLine.hidden = false
            }
            cell = c
            break
        case "1":
            let c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.isDynamic = true
            c.data = self.dataArray[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArray.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            let _shouldLoadImage = self.shouldLoadCellImage(c, withIndexPath: indexPath)
            c._layoutSubviews(_shouldLoadImage)
            cell = c
            
            break
        default:
            break
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let data = dataArray[indexPath.row] as! NSDictionary
        let type = data.stringAttributeForKey("type")
        
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
    - returns: Bool值，代表是否要加载图片
    */
    func shouldLoadCellImage(cell: SAStepCell, withIndexPath indexPath: NSIndexPath) -> Bool {
        if (self.targetRect != nil) && !CGRectIntersectsRect(self.targetRect!.CGRectValue(), self.bindViewController!.dynamicTableView.rectForRowAtIndexPath(indexPath)) {
            return false
        }
        
        return true
    }
    
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArray, index: index, key: key, value: value, tableView: bindViewController!.dynamicTableView!)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, section: 0, tableView: bindViewController!.dynamicTableView!)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(bindViewController!.dynamicTableView!)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, dataArray: self.dataArray, index: index, tableView: bindViewController!.dynamicTableView!, section: 0)
    }
}

// MARK: - 实现 UIScrollviewDelegate
extension ExploreDynamicProvider : UIScrollViewDelegate  {
    func scrollViewDidScroll(scrollView: UIScrollView) {
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.targetRect = nil
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetRect: CGRect = CGRectMake(targetContentOffset.memory.x, targetContentOffset.memory.y, scrollView.frame.size.width, scrollView.frame.size.height)
        self.targetRect = NSValue(CGRect: targetRect)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView is UITableView {
            self.targetRect = nil
            
            self.loadImagesForVisibleCells()
        }
    }
    
    func loadImagesForVisibleCells() {
        let cellArray = self.bindViewController?.dynamicTableView.visibleCells
        
        for cell in cellArray! {
            if cell is SAStepCell {
                let indexPath = self.bindViewController?.dynamicTableView.indexPathForCell(cell as! SAStepCell)
                
                var _tmpShouldLoadImg = false
                    _tmpShouldLoadImg = self.shouldLoadCellImage(cell as! SAStepCell, withIndexPath: indexPath!)
                
                if _tmpShouldLoadImg {
                    self.bindViewController?.dynamicTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
                }
            }
        }
    }
    
}

// MARK: -
extension ExploreDynamicProvider: SAStepCellDatasource {
    
    func saStepCell(indexPath: NSIndexPath, content: String, contentHeight: CGFloat) {
        
        var _tmpDict = NSMutableDictionary(dictionary: self.dataArray[indexPath.row] as! NSDictionary)
        _tmpDict.setObject(content as NSString, forKey: "content")
        
        #if CGFLOAT_IS_DOUBLE
        _tmpDict.setObject(NSNumber(double: Double(contentHeight)), forKey: "contentHeight")
        #else
        _tmpDict.setObject(NSNumber(float: Float(contentHeight)), forKey: "contentHeight")
        #endif
        
        self.dataArray.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
    }
}

// MARK: - explore dynamic dream cell
class ExploreDynamicDreamCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    
    override func awakeFromNib() {
        imageCover.setX(globalWidth - 52)
        self.viewLine.setWidth(globalWidth - 40)
    }
    
    override func layoutSubviews() {
        let uidlike = data.stringAttributeForKey("uidlike")
        let userlike = data.stringAttributeForKey("userlike")
        let img = data.stringAttributeForKey("image")
        let title = data.stringAttributeForKey("title").decode()
        self.imageHead.setHead(uidlike)
        self.imageCover.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor, bool: false)
        self.labelName.text = userlike
        self.labelDream.text = "赞了「\(title)」"
        self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.viewLine.setHeightHalf()
    }
    
    func onUserClick() {
        let uid = data.stringAttributeForKey("uidlike")
        let userVC = PlayerViewController()
        userVC.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(userVC, animated: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageCover.cancelImageRequestOperation()
        self.imageCover.image = nil
    }
    
}