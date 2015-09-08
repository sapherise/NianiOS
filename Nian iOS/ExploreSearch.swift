//
//  ExploreSearch.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit
import Foundation

//MARK: - custom textfield
class NITextfield: UITextField {
    override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.origin.x, bounds.origin.y, 26 , 26)
    }
    
    override func rightViewRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectMake(bounds.size.width - 25, bounds.origin.y, 26, 26)
    }
}

// MARK: -
// MARK: -

/**
*  @author Bob Wei, 15-09-07 17:09:24
*
*  @brief  <#Description#>
*
*/
class ExploreSearch: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, delegateSAStepCell{
    var dataArrayUser = NSMutableArray() {
        didSet {
            if dataArrayUser.count > 0 {
                if index == 0 {
                    userTableView.hidden = false
                }
            }
        }
    }
    var dataArrayDream = NSMutableArray()
    var dataArrayStep = NSMutableArray()
    var dataArrayTopic = NSMutableArray()
    
    var preSetSearch: String = ""
    var shouldPerformSearch: Bool = false
    
    // MARK: -
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navView: UIView!
    @IBOutlet weak var indiView: UIView!   //indication view
    
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var dreamButton: UIButton!
    @IBOutlet weak var stepButton: UIButton!
    @IBOutlet weak var topicButton: UIButton!
    @IBOutlet weak var floatView: UIView!
    
    // MARK: -
    
    /* 改变 Button 的颜色时使用 */
    var btnArray:[UIButton] = []
    
    /* 统一 UITableview 的 header call back 和 footer call back */
    var tableDict = Dictionary<Int, UITableView>()
    
    var searchText = NITextfield()
    
    var index: Int = 0 {
        didSet {
            
        }
    }
    var dreamPage: Int = 1
    var userPage: Int = 1
    var stepPage: Int = 1
    var topicPage: Int = 1
    
    var dreamStepArray = NSMutableArray()
    
    // 用在计算 table view 滚动时应不应该加载图片
    var targetRect: NSValue?
    
    // MARK: - all table view 都是延迟加载的
    
    lazy var userTableView: UITableView = {
        let userTableView = UITableView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        userTableView.registerNib(UINib(nibName: "SAUserCell", bundle: nil), forCellReuseIdentifier: "SAUserCell")
        
        userTableView.dataSource = self
        userTableView.delegate = self
        
        return userTableView
    }()
    
    lazy var userDataArray: NSMutableArray = {
        let userDataArray = NSMutableArray()
        return userDataArray
    }()
    
    lazy var dreamTableView: UITableView = {
        let dreamTableView = UITableView(frame: CGRectMake(0, globalWidth, globalWidth, globalHeight))
        dreamTableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
        
        dreamTableView.dataSource = self
        dreamTableView.delegate = self
        
        return dreamTableView
    }()
    
    lazy var dreamDataArray: NSMutableArray = {
        let dreamDataArray = NSMutableArray()
        return dreamDataArray
    }()
    
    lazy var stepTableView: UITableView = {
        let stepTableView = UITableView(frame: CGRectMake(0, globalWidth * 2, globalWidth, globalHeight))
        stepTableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
        
        stepTableView.dataSource = self
        stepTableView.delegate = self
        
        return stepTableView
    }()
    
    lazy var stepDataArray: NSMutableArray = {
        let stepDataArray = NSMutableArray()
        return stepDataArray
    }()
    
    lazy var topicTableView: UITableView = {
        let topicTableView = UITableView(frame: CGRectMake(0, globalWidth * 3, globalWidth, globalHeight))
        topicTableView.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        
        topicTableView.dataSource = self
        topicTableView.delegate = self
        
        return topicTableView
    }()
    
    lazy var topicDataArray: NSMutableArray = {
        let topicDataArray = NSMutableArray()
        return topicDataArray
    }()

    // MARK: - View Controller 的生命周期和 View 的颜色、位置的控制
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
//        self.dreamTableView.hidden = !(index == 0)
//        self.tableView.hidden = !self.dreamTableView.hidden
        
//        self.userTableView.hidden = !(index == 0)
//        self.tableSet.insert(self.userTableView)
        
        self.showTableViewWithIndex(index)
        
        self.viewBackFix()
        
        if preSetSearch.characters.count > 0 {
            searchText.text = preSetSearch
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.addSubview(searchText)
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            if self.searchText.text != "" {
                self.searchText.rightViewMode = .Always
            } else {
                self.searchText.rightViewMode = .Never
            }
        }
        
        if (preSetSearch.characters.count > 0 && shouldPerformSearch) {
            if index == 0 {
                self.dreamTableView.headerBeginRefreshing()
            } else {
                self.userTableView.headerBeginRefreshing()
            }
            
            if let _ = self.tableDict[index] {
            } else {
                self.showTableViewWithIndex(index)
            }
            
            self.beginSearch(clear: true, index: index, table: self.tableDict[index]!)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        searchText.removeFromSuperview()
        shouldPerformSearch = false
    }
    
    func setupView() {
        viewBack()
        
        setupButtonColor(index)
        
        navView.setWidth(globalWidth)
        indiView.setWidth(globalWidth)
        
        let _tmpWidth = globalWidth/2
        userButton.setX(_tmpWidth - 160)
        dreamButton.setX(_tmpWidth - 80)
        stepButton.setX(_tmpWidth)
        topicButton.setX(_tmpWidth + 80)
        
        floatView.setX(_tmpWidth - 160 + 15)
        floatView.backgroundColor = SeaColor
        
        btnArray = [userButton, dreamButton, stepButton, topicButton]
        
        let color = UIColor(red: 0xd8/255, green: 0xd8/255, blue: 0xd8/255, alpha: 1)
        searchText = NITextfield(frame: CGRectMake(44, 8, globalWidth-60, 26))
        searchText.layer.cornerRadius = 13
        searchText.layer.masksToBounds = true
        searchText.backgroundColor = UIColor(red: 0x3b/255, green: 0x40/255, blue: 0x44/255, alpha: 1.0)
        searchText.leftViewMode = .Always
        searchText.leftView  = UIImageView(image: UIImage(named: "search"))
        searchText.leftView?.contentMode = .Center
        searchText.rightView = UIImageView(image: UIImage(named: "close-1"))
        searchText.rightView!.contentMode = .Center
        searchText.rightView!.userInteractionEnabled = true
        searchText.rightView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "clearText:"))
        searchText.attributedPlaceholder = NSAttributedString(string: "搜索", attributes: [NSForegroundColorAttributeName: color, NSFontAttributeName: UIFont.systemFontOfSize(12.0)])
        searchText.contentVerticalAlignment = .Center
        searchText.font = UIFont.systemFontOfSize(12.0)
        searchText.textColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1)
        searchText.returnKeyType = .Search
        searchText.clearsOnBeginEditing = false
        searchText.delegate = self
        //        self.navigationController?.navigationBar.addSubview(searchText)
        
        scrollView.scrollsToTop = false
        scrollView.contentSize = CGSizeMake(globalWidth * 4, scrollView.frame.size.height)
        scrollView.delegate = self
        
//        tableView.addHeaderWithCallback(onPullDown)
//        tableView.addFooterWithCallback(onPullUp)
//        dreamTableView.addHeaderWithCallback(onPullDown)
//        dreamTableView.addFooterWithCallback(onPullUp)
    }
    
    func setupButtonColor(index: Int) {
//        if index == 0 {
//            dreamButton.setTitleColor(SeaColor, forState: .Normal)
//            userButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        } else {
//            userButton.setTitleColor(SeaColor, forState: .Normal)
//            dreamButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        }
        
        /* 改变 Button 的颜色 */
        for (_index, _btn) in self.btnArray.enumerate() {
            if _index == index {
                _btn.setTitleColor(SeaColor, forState: .Normal)
            } else {
                _btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
        }
        
    }
    
    // MARK: - 数据加载和 Table 的使用控制
    
    /**
    <#Description#>
    
    :param: index <#index description#>
    */
    func showTableViewWithIndex(index: Int) {
        switch index {
        case 0:
            if let _ = self.tableDict[index] {
            } else {
                self.tableDict[index] = userTableView
                userTableView.addHeaderWithCallback(onPullDown)
                userTableView.addFooterWithCallback(onPullUp)
                
                self.scrollView.addSubview(userTableView)
            }
        case 1:
            if let _ = self.tableDict[index] {
            } else {
                self.tableDict[index] = dreamTableView
                dreamTableView.addHeaderWithCallback(onPullDown)
                dreamTableView.addFooterWithCallback(onPullUp)
                
                self.scrollView.addSubview(dreamTableView)
            }
        case 2:
            if let _ = self.tableDict[index] {
            } else {
                self.tableDict[index] = stepTableView
                stepTableView.addHeaderWithCallback(onPullDown)
                stepTableView.addFooterWithCallback(onPullUp)
                
                self.scrollView.addSubview(stepTableView)
            }
        case 3:
            if let _ = self.tableDict[index] {
            } else {
                self.tableDict[index] = topicTableView
                topicTableView.addHeaderWithCallback(onPullDown)
                topicTableView.addFooterWithCallback(onPullUp)
                
                self.scrollView.addSubview(topicTableView)
            }
        default:
            break
        }
        
        // ????
        //使用元组
        for (_index, _table) in self.tableDict {
            if _index == index {
                _table.hidden = false
            } else {
                _table.hidden = true
            }
        }
    }
    
    func load(index: Int, clear: Bool) {
//        if index == 0 {
//            self.dreamSearch(clear)
//        } else {
//            self.userSearch(clear)
//        }
        
        for (_index, _table) in self.tableDict {
            if _index == index {
                self.beginSearch(clear: clear, index: _index, table: _table)
            }
        }
        
    }
    
    /**
    <#Description#>
    
    :param: clear <#clear description#>
    :param: table <#table description#>
    */
    func beginSearch(clear clear: Bool, index: Int, table: UITableView) {
        if index == 0 {
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
            
            userSearch(clear)
        } else if index == 1 {
            self.scrollView.setContentOffset(CGPointMake(globalWidth, 0), animated: true)
            
            dreamSearch(clear)
        } else if index == 2 {
        
        } else if index == 3 {
        
        }
    }
    
    func onRefresh() {
        load(index, clear: true)
    }
    
    func onLoad() {
        load(index, clear: false)
    }
    
    func onPullDown() {
        self.onRefresh()
    }
    
    func onPullUp() {
        self.onLoad()
    }
    

    
    /**
    <#Description#>
    
    :param: scrollView <#scrollView description#>
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView is UITableView {
            searchText.resignFirstResponder()
        } else if scrollView.isMemberOfClass(UIScrollView) {
            
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text != "" {
            searchText.rightViewMode = .Always
        }
    }
    
    func clearText(sender: UITapGestureRecognizer) {
        searchText.text = ""
        searchText.rightViewMode = .Never
        searchText.becomeFirstResponder()
    }
    
    @IBAction func dream(sender: AnyObject) {
        let tmp = index
        index = 0
        setupButtonColor(index)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 65)
        })
        
        if searchText.text != "" && (dataArrayDream.count + dataArrayStep.count == 0) {
            self.dreamTableView.headerBeginRefreshing()
        } else if tmp == 0 {
            self.dreamTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func user(sender: AnyObject) {
        let tmp = index
        index = 1
        setupButtonColor(1)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 145)
        })
        
        if searchText.text != "" && dataArrayUser.count == 0 {
            self.userTableView.headerBeginRefreshing()
        } else if tmp == 1 {
            self.userTableView.headerBeginRefreshing()
        }
    }
    
    func userSearch(clear: Bool) {
        if clear {
            userPage = 1
        }
        
        Api.getSearchUsers(searchText.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!, page: userPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayUser.removeAllObjects()
                }
                let items = json!.objectForKey("users") as? NSArray
                if items != nil {
                    for item in items! {
                        self.dataArrayUser.addObject(item)
                    }
                    if items!.count < 30 {
                        self.userTableView.setFooterHidden(true)
                    }
                }
            }
            self.userTableView.reloadData()
            self.userTableView.headerEndRefreshing()
            self.userTableView.footerEndRefreshing()
        })
    }
    
    func dreamSearch(clear: Bool) {
        if clear {
            dreamPage = 1
        }
        Api.getSearchDream(searchText.text!.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!, page: dreamPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayDream.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let itemsDream = data!.objectForKey("dreams") as? NSArray
                if itemsDream != nil {
                    for item in itemsDream! {
                        self.dataArrayDream.addObject(item)
                    }
                }
                let itemsStep = data!.objectForKey("steps") as? NSArray
                if itemsStep != nil {
                    for item in itemsStep! {
                        self.dataArrayStep.addObject(item)
                    }
                }
            }
            self.dreamTableView.reloadData()
            self.dreamTableView.headerEndRefreshing()
            self.dreamTableView.footerEndRefreshing()
        })
    }
    
    func stepSearch(clear: Bool) {
        if clear {
            stepPage = 1
        }
    }
    
    func topicSearch(clear: Bool) {
        if clear {
            topicPage = 1
        }
    }
    
    // MARK: - table view delegate

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch index {
        case 0:
            return self.dataArrayUser.count
        case 1:
            return self.dataArrayDream.count
        case 2:
            return self.dataArrayStep.count
        case 3:
            return self.dataArrayTopic.count
        default:
            return 0
        }
    }
    
//    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if index == 0 {
//            if section == 0 {
//                if self.dataArrayDream.count != 0 {
//                    let viewFooter = UIView(frame: CGRectMake(0, 0, globalWidth, 15))
//                    viewFooter.backgroundColor = IconColor
//                    return viewFooter
//                }
//            }
//        }
//        return nil
//    }
//    
//    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if index == 0 {
//            if section == 0 {
//                if self.dataArrayDream.count != 0 {
//                    return 15
//                }
//            }
//        }
//        return 0
//    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        if index == 0 {
//            if indexPath.section == 0 {
//                let c = dreamTableView.dequeueReusableCellWithIdentifier("SADoubleCell", forIndexPath: indexPath) as! SADoubleCell
//                let data = self.dataArrayDream[indexPath.row] as! NSDictionary
//                c.data = data
//                c.btnMain.tag = indexPath.row
//                c.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toDream:"))
//                c.btnMain.addTarget(self, action: "onFollowDream:", forControlEvents: UIControlEvents.TouchUpInside)
//                if indexPath.row == dataArrayDream.count - 1 {
//                    c.viewLine.hidden = true
//                }
//                return c
//            } else {
//                let c = dreamTableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
//                c.delegate = self
//                c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
//                c.index = indexPath.row
//                if indexPath.row == self.dataArrayStep.count - 1 {
//                    c.viewLine.hidden = true
//                } else {
//                    c.viewLine.hidden = false
//                }
//                c._layoutSubviews()
//                return c
//            }
//        } else {
//            let cell = self.tableView.dequeueReusableCellWithIdentifier("SAUserCell", forIndexPath: indexPath) as? SAUserCell
//            let data = self.dataArrayUser[indexPath.row] as! NSDictionary
//            cell?.data = data
//            cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser:"))
//            cell?.btnMain.tag = indexPath.row
//            cell?.btnMain.addTarget(self, action: "onFollow:", forControlEvents: UIControlEvents.TouchUpInside)
//            return cell!
//        }
        
        switch index {
        case 0:
            let cell = self.userTableView.dequeueReusableCellWithIdentifier("SAUserCell", forIndexPath: indexPath) as? SAUserCell
            let data = self.dataArrayUser[indexPath.row] as! NSDictionary
            cell?.data = data
            cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "toUser:"))
            cell?.btnMain.tag = indexPath.row
            cell?.btnMain.addTarget(self, action: "onFollow:", forControlEvents: UIControlEvents.TouchUpInside)
            return cell!           
        case 1:
            let cell = self.dreamTableView.dequeueReusableCellWithIdentifier("ExploreNewHotCell", forIndexPath: indexPath) as? ExploreNewHotCell
            cell!.data = self.dataArrayDream[indexPath.row] as! NSDictionary
            
            if indexPath.row == self.dataArrayDream.count - 1 {
                cell!.viewLine.hidden = true
            } else {
                cell!.viewLine.hidden = false
            }
            cell!._layoutSubviews()
            
            return cell!
        case 2:
            let c = stepTableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
//            c.delegate = self
            c.data = self.dataArrayStep[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArrayStep.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            c._layoutSubviews()
            return c
        case 3:
            let cell = UITableViewCell()
            
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if index == 0 {
            if indexPath.section == 1 {
                let index = indexPath.row
                let data = self.dataArrayStep[index] as! NSDictionary
                let dream = data.stringAttributeForKey("dream")
                SADream(dream)
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if index == 0 {
            return 71
            
//            if indexPath.section == 0 {
//                return 81
//            } else {
//                let data = self.dataArrayStep[indexPath.row] as! NSDictionary
//                
//                return tableView.fd_heightForCellWithIdentifier("SAStepCell", cacheByIndexPath: indexPath, configuration: { cell in
//                    (cell as! SAStepCell).celldataSource = self
//                    (cell as! SAStepCell).fd_enforceFrameLayout = true
//                    (cell as! SAStepCell).data  = data
//                    (cell as! SAStepCell).indexPath = indexPath
//                })
//            }
        } else if index == 1 {
            let index = indexPath.row
            let data = self.dataArrayDream[index] as! NSDictionary
            
            return  ExploreNewHotCell.cellHeightByData(data)
        } else if index == 2 {
            return 1
        } else if index == 3 {
            return 1
        } else {
            return 1
        }
    }
    
    /**
    - returns: Bool值，代表是否要加载图片
    */
    func shouldLoadCellImage(cell: SAStepCell, withIndexPath indexPath: NSIndexPath) -> Bool {
        if (self.targetRect != nil) && !CGRectIntersectsRect(self.targetRect!.CGRectValue(), self.dreamTableView.rectForRowAtIndexPath(indexPath)) {
            return false
        }
        
        return true
    }
    
    // MARK: -
    
    func toUser(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            SAUser("\(tag)")
        }
    }
    
    func toDream(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            SADream("\(tag)")
        }
    }
    
    func onFollowDream(sender: UIButton) {
        let tag = sender.tag
        let data = self.dataArrayDream[tag] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let follow = data.stringAttributeForKey("follow")
        let newFollow = follow == "0" ? "1" : "0"
        let mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(newFollow, forKey: "follow")
        self.dataArrayDream[tag] = mutableData
        self.dreamTableView.reloadData()
        Api.postFollowDream(id, follow: newFollow) { json in
        }
    }
    
    func onFollow(sender: UIButton) {
        let tag = sender.tag
        let data = self.dataArrayUser[tag] as! NSDictionary
        let uid = data.stringAttributeForKey("uid")
        let follow = data.stringAttributeForKey("follow")
        let newFollow = follow == "0" ? "1" : "0"
        let mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(newFollow, forKey: "follow")
        self.dataArrayUser[tag] = mutableData
        self.userTableView.reloadData()
        if follow == "1" {
            Api.postUnfollow(uid) { string in
            }
        } else {
            Api.postFollow(uid, follow: 1) { string in
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        if searchText.text != "" {
            searchText.rightViewMode = .Always
//            if index == 0 {
//                self.dreamTableView.headerBeginRefreshing()
//            } else {
//                self.userTableView.headerBeginRefreshing()
//            }
            
            for (_index, _table) in self.tableDict {
                if _index == index {
                    _table.headerBeginRefreshing()
                }
            }
            
        }
        return true
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArrayStep, index: index, key: key, value: value, tableView: self.dreamTableView)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, section: 1, tableView: self.dreamTableView)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(self.dreamTableView)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, dataArray: self.dataArrayStep, index: index, tableView: self.dreamTableView, section: 1)
    }
}

// MARK: - SAStepCellDatasource
extension ExploreSearch: SAStepCellDatasource {
    func saStepCell(indexPath: NSIndexPath, content: String, contentHeight: CGFloat) {
        if index == 0 {
            var _tmpDict = NSMutableDictionary(dictionary: self.dataArrayStep[indexPath.row] as! NSDictionary)
            _tmpDict.setObject(content as NSString, forKey: "content")
            
            #if CGFLOAT_IS_DOUBLE
                _tmpDict.setObject(NSNumber(double: Double(contentHeight)), forKey: "contentHeight")
                #else
                _tmpDict.setObject(NSNumber(float: Float(contentHeight)), forKey: "contentHeight")
            #endif
            
            self.dataArrayStep.replaceObjectAtIndex(indexPath.row, withObject: _tmpDict)
        }
    }
}

// MARK: - 实现 UIScrollView Delegate
extension ExploreSearch {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if scrollView is UITableView {
            self.targetRect = nil
        }
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView is UITableView {
            let targetRect: CGRect = CGRectMake(targetContentOffset.memory.x, targetContentOffset.memory.y, scrollView.frame.size.width, scrollView.frame.size.height)
            self.targetRect = NSValue(CGRect: targetRect)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView is UITableView {
            self.targetRect = nil
            
            if index == 0 {
                self.loadImagesForVisibleCells()
            }
        }
    }
    
    func loadImagesForVisibleCells() {
        let cellArray = self.userTableView.visibleCells
        
        for cell in cellArray {
            if cell is SAStepCell {
                let indexPath = self.dreamTableView.indexPathForCell(cell as! SAStepCell)
                var _tmpShouldLoadImg = false
                
                _tmpShouldLoadImg = self.shouldLoadCellImage(cell as! SAStepCell, withIndexPath: indexPath!)
                
                if _tmpShouldLoadImg {
                    self.dreamTableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
                }
            }
        }
    }
}

