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
*
*  @brief  <#Description#>
*
*/
class ExploreSearch: VVeboViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var dataArrayUser = NSMutableArray() {
        didSet {
            if dataArrayUser.count > 0 {
                if index == 0 {
                    userTableView.hidden = false
                }
            }
        }
    }
    var dataArrayDream = NSMutableArray() {
        didSet {
            if dataArrayDream.count > 0 {
                if index == 1 {
                    dreamTableView.hidden = false
                }
            }
        }
    }
    var dataArrayStep = NSMutableArray() {
        didSet {
            if dataArrayStep.count > 0 {
                if index == 2 {
                    stepTableView.hidden = false
                }
            }
        }
    }
    var dataArrayTopic = NSMutableArray() {
        didSet {
            if dataArrayTopic.count > 0 {
                if index == 3 {
                    topicTableView.hidden = false
                }
            }
        }
    }
    
    /* dataSourceArray 里面存的是上面的 dataArray */
    var dataSourceArray: [NSMutableArray] = []
    
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
    
    var hasFollowTag: Bool = false
    var tagFollowActionSheet: UIActionSheet?
    // MARK: -
    
    var index: Int = 0     /* 用来指示当前的 table，在其他文件里可能相当于 current */
    var dreamPage: Int = 1
    var userPage: Int = 1
    var stepPage: Int = 1
    var topicPage: Int = 1
    
    /* 改变 Button 的颜色时使用 */
    var btnArray:[UIButton] = []
    
    /* 统一 UITableview 的 header call back 和 footer call back */
    var tableDict = Dictionary<Int, UITableView>()
    
    /* 代码生成的搜索框 */
    var searchText = NITextfield()
    
    /*  */
    var rightButton: UIBarButtonItem?
    
    // 用在计算 table view 滚动时应不应该加载图片
//    var targetRect: NSValue?
    
    // MARK: - all table view 都是延迟加载的
    
    lazy var userTableView: UITableView = {
        let userTableView = UITableView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 104))
        userTableView.registerNib(UINib(nibName: "SAUserCell", bundle: nil), forCellReuseIdentifier: "SAUserCell")
        userTableView.separatorStyle = .None
        
        userTableView.dataSource = self
        userTableView.delegate = self
        
        if self.dataArrayUser.count == 0 {
            userTableView.hidden = true
        }
        
        return userTableView
    }()
    
    lazy var dreamTableView: UITableView = {
        let dreamTableView = UITableView(frame: CGRectMake(globalWidth, 0, globalWidth, globalHeight - 104))
        dreamTableView.registerNib(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
        dreamTableView.separatorStyle = .None
        
        dreamTableView.dataSource = self
        dreamTableView.delegate = self
        
        if self.dataArrayDream.count == 0 {
            dreamTableView.hidden = true
        }
        
        return dreamTableView
    }()
   
    lazy var stepTableView: VVeboTableView = {
        let stepTableView = VVeboTableView(frame: CGRectMake(globalWidth * 2, 0, globalWidth, globalHeight - 104))
        stepTableView.separatorStyle = .None
        
        stepTableView.dataSource = self
        stepTableView.delegate = self
        
        if self.dataArrayStep.count == 0 {
            stepTableView.hidden = true
        }
        
        return stepTableView
    }()
   
    lazy var topicTableView: UITableView = {
        let topicTableView = UITableView(frame: CGRectMake(globalWidth * 3, 0, globalWidth, globalHeight - 104))
        topicTableView.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
        topicTableView.separatorStyle = .None
        
        topicTableView.dataSource = self
        topicTableView.delegate = self
        
        if self.dataArrayTopic.count == 0 {
            topicTableView.hidden = true
        }
        
        return topicTableView
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
        
        self.showTableViewWithIndex(index)
        self.viewBackFix()
        
        if preSetSearch.characters.count > 0 {
            searchText.text = preSetSearch
        }
        
        self.navigationController?.navigationBar.addSubview(searchText)
        searchText.alpha = 0.0
        
        UIView.animateWithDuration(0.5, animations: {
            self.searchText.alpha = 1.0
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        self.navigationController?.navigationBar.addSubview(searchText)
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { _ in
            if self.searchText.text != "" {
                self.searchText.rightViewMode = .Always
            } else {
                self.searchText.rightViewMode = .Never
            }
        }
        
        /* 现在可能预先设置的搜索来自 Dream cell top, 对应 index == 1； Topic cell top 对应 index == 3  */
        let flowViewOffset = index == 1 ? (globalWidth/2 - 65) : (index == 3 ? globalWidth/2 + 95 : 0)
        
        if (preSetSearch.characters.count > 0 && shouldPerformSearch) {
            if let _ = self.tableDict[index] {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.floatView.setX(flowViewOffset)
                })
                setupButtonColor(index)
            } else {
                self.showTableViewWithIndex(index)
            }
            
            preSetSearch = ""
            self.tableDict[index]?.headerBeginRefreshing()
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
        
        rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "Follow:")
        rightButton!.image = UIImage(named:"more")
        self.navigationItem.rightBarButtonItems = [rightButton!];
        
        let _tmpWidth = globalWidth/2
        userButton.setX(_tmpWidth - 160)
        dreamButton.setX(_tmpWidth - 80)
        stepButton.setX(_tmpWidth)
        topicButton.setX(_tmpWidth + 80)
        
        floatView.setX(_tmpWidth - 160 + 15)
        floatView.backgroundColor = SeaColor
        
        btnArray = [userButton, dreamButton, stepButton, topicButton]
        dataSourceArray = [dataArrayUser, dataArrayDream, dataArrayStep, dataArrayTopic]
        
        let color = UIColor(red: 0xd8/255, green: 0xd8/255, blue: 0xd8/255, alpha: 1)
        searchText = NITextfield(frame: CGRectMake(48, 8, globalWidth - 96, 26))
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
    }
    
    func setupButtonColor(index: Int) {
        
        /* 改变 Button 的颜色 */
        for (_index, _btn) in self.btnArray.enumerate() {
            if _index == index {
                _btn.setTitleColor(SeaColor, forState: .Normal)
            } else {
                _btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
            }
        }
    }
    
    /**
    which table 能 scrollToTop
    */
    func tableScrollToTop() {
        for (_index, _table) in self.tableDict {
            if _index == index {
                _table.scrollsToTop = true
            } else {
                _table.scrollsToTop = false
            }
        }
    }
    
    // MARK: - 数据加载和 Table 的使用控制
    
    /**
    <#Description#>
    
    :param: index <#index description#>
    */
    func showTableViewWithIndex(index: Int) {
        currenTableView = nil
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
            currenTableView = stepTableView
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
    }
    
    func load(index: Int, clear: Bool) {
        currenTableView = nil
        for (_index, _table) in self.tableDict {
            if _index == index {
                _table.hidden = false
                self.beginSearch(clear: clear, index: _index)
            }
        }
        
    }
    
    /**
    <#Description#>
    
    :param: clear <#clear description#>
    :param: table <#table description#>
    */
    func beginSearch(clear clear: Bool, index: Int) {
        if index == 0 {
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
            
            userSearch(clear)
        } else if index == 1 {
            self.scrollView.setContentOffset(CGPointMake(globalWidth, 0), animated: true)
            
            dreamSearch(clear)
        } else if index == 2 {
            self.scrollView.setContentOffset(CGPointMake(globalWidth * 2, 0), animated: true)
            
            stepSearch(clear)
        } else if index == 3 {
            self.scrollView.setContentOffset(CGPointMake(globalWidth * 3, 0), animated: true)
            
            topicSearch(clear)
        }
        
        tableScrollToTop()
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
    
    // MARK: - 关注搜索的内容
    /* */
    // TODO: -
    func Follow(sender: AnyObject) {
        if self.searchText.text?.characters.count > 0{
            self.navigationItem.rightBarButtonItems = buttonArray()
            self.searchText.resignFirstResponder()
        
            Api.getHasFollowTopic(self.searchText.text!.encode()) {
                [unowned self] json in
                if json != nil {
                    self.navigationItem.rightBarButtonItems = [self.rightButton!]
                    
                    if let _data = json!.objectForKey("data") as? String {
                        self.hasFollowTag = _data == "1" ? true : false
                        let tag = self.searchText.text!
                        let content = _data == "1" ? "取消关注 #\(tag)" : "关注 #\(tag)"
                        self.tagFollowActionSheet = UIActionSheet()
                        self.tagFollowActionSheet?.delegate = self
                        self.tagFollowActionSheet?.addButtonWithTitle(content)
                        self.tagFollowActionSheet?.addButtonWithTitle("取消")
                        self.tagFollowActionSheet?.cancelButtonIndex = 1
                        self.tagFollowActionSheet?.showInView(self.view)
                    }
                }
            }
        }
    }
    
    /* */
    //MARK: -
    
    @IBAction func user(sender: AnyObject) {
        let tmp = index
        index = 0
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 145)
        })
        
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)

        if searchText.text != "" && (tmp == index || self.dataArrayUser.count == 0) {
            self.userTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func dream(sender: AnyObject) {
        let tmp = index
        index = 1
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 65)
        })
        
        self.scrollView.setContentOffset(CGPointMake(globalWidth, 0), animated: true)
        
        if searchText.text != "" && (tmp == index || self.dataArrayDream.count == 0) {
            self.dreamTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func step(sender: AnyObject) {
        let tmp = index
        index = 2
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 15)
        })
        
        self.scrollView.setContentOffset(CGPointMake(globalWidth * 2, 0), animated: true)

        if searchText.text != ""  && (tmp == index || self.dataArrayStep.count == 0) {
            self.stepTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func topic(sender: AnyObject) {
        let tmp = index
        index = 3
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 95)
        })
        
        self.scrollView.setContentOffset(CGPointMake(globalWidth * 3, 0), animated: true)

        if searchText.text != "" && (tmp == index || self.dataArrayTopic.count == 0) {
            self.topicTableView.headerBeginRefreshing()
        }
    }
    
    func userSearch(clear: Bool) {
        if clear {
            userPage = 1
        }
        
        Api.getSearchUsers(searchText.text!.encode(), page: userPage++, callback: {
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
                
                if self.dataArrayUser.count == 0 {
                    let v = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 40))
                    v.addGhost("没有人叫这个名字...\n所以你只搜到了这只鬼")
                    self.userTableView.tableHeaderView = v
                } else {
                    self.userTableView.tableHeaderView = nil
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
        Api.getSearchDream(searchText.text!.encode(), page: dreamPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayDream.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let itemsDream = data?.objectForKey("dreams") as? NSArray
                if itemsDream != nil {
                    for item in itemsDream! {
                        self.dataArrayDream.addObject(item)
                    }
                }
                if self.dataArrayDream.count == 0 {
                    let v = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 40))
                    v.addGhost("没有记本有这个标签！\n如果你想搜索带有关键字的进展，\n可以试试旁边的进展！")
                    self.dreamTableView.tableHeaderView = v
                } else {
                    self.dreamTableView.tableHeaderView = nil
                }
            }
            self.dreamTableView.reloadData()
            self.dreamTableView.headerEndRefreshing()
            self.dreamTableView.footerEndRefreshing()
        })
    }
    
    func stepSearch(clear: Bool) {
        currenTableView = stepTableView
        if clear {
            stepPage = 1
        }
        Api.getSearchSteps(searchText.text!.encode(), page: stepPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.stepTableView.clearVisibleCell()
                    self.dataArrayStep.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let itemsStep = data?.objectForKey("steps") as? NSArray
                if itemsStep != nil {
                    for item in itemsStep! {
                        let d = SACell.SACellDataRecode(item as! NSDictionary)
                        self.dataArrayStep.addObject(d)
                    }
                }
                self.currentDataArray = self.dataArrayStep
                if self.dataArrayStep.count == 0 {
                    let v = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 40))
                    v.addGhost("没有一个进展里有这个关键字！\n我还以为世界上没有人能看到这条错误提示呢...")
                    self.stepTableView.tableHeaderView = v
                } else {
                    self.stepTableView.tableHeaderView = nil
                }
            }
            self.stepTableView.reloadData()
            self.stepTableView.headerEndRefreshing()
            self.stepTableView.footerEndRefreshing()
        })
    }
    
    func topicSearch(clear: Bool) {
        if clear {
            topicPage = 1
        }
        Api.getSearchTopics(searchText.text!.encode(), page: topicPage++, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayTopic.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let itemTopic = data?.objectForKey("topics") as? NSArray
                if itemTopic != nil {
                    for item in itemTopic! {
                        self.dataArrayTopic.addObject(item)
                    }
                }
                if self.dataArrayTopic.count == 0 {
                    let v = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 40))
                    v.addGhost("还没有这个标签的话题...")
                    self.topicTableView.tableHeaderView = v
                } else {
                    self.topicTableView.tableHeaderView = nil
                }
                
                self.hasFollowTag = (data?.objectForKey("followed") as? String) == "1" ? true : false
            }
            
            self.topicTableView.reloadData()
            self.topicTableView.headerEndRefreshing()
            self.topicTableView.footerEndRefreshing()
        })
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            return getCell(indexPath, dataArray: dataArrayStep)
        case 3:
            // TODO: - 完成 topic cell
            let cell = self.topicTableView.dequeueReusableCellWithIdentifier("RedditCell", forIndexPath: indexPath) as! RedditCell  
            cell.delegate = self
            cell.data = self.dataArrayTopic[indexPath.row] as! NSDictionary
            cell.index = indexPath.row
            
            return cell
        default:
            let cell = UITableViewCell()
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if index == 0 {
//            let index = indexPath.row
//            let data = self.dataArrayStep[index] as! NSDictionary
//            let dream = data.stringAttributeForKey("dream")
//            SADream(dream)
        } else if index == 1 {
            let DreamVC = DreamViewController()
            DreamVC.Id = (self.dataArrayDream[indexPath.row] as! NSDictionary)["id"] as! String
            
            self.navigationController?.pushViewController(DreamVC, animated: true)
        } else if index == 2 {
            let viewController = DreamViewController()
            let data = dataArrayStep[indexPath.row] as! NSDictionary
            viewController.Id = data.stringAttributeForKey("dream")
            
            self.navigationController?.pushViewController(viewController, animated: true)
        } else if index == 3 {
            // TODO: - topic cell select 事件
            let dict = dataArrayTopic[indexPath.row] as! NSDictionary
            
            let TopicVC = TopicViewController()
            TopicVC.id = dict["id"] as! String
            TopicVC.index = indexPath.row
            TopicVC.dataArrayTopLeft = NSMutableDictionary(dictionary: dict)
            TopicVC.delegate = self
            
            self.navigationController?.pushViewController(TopicVC, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if index == 0 {
            return 71
        } else if index == 1 {
            let data = dataArrayDream[indexPath.row] as! NSDictionary
            let heightCell = data.stringAttributeForKey("heightCell")
            if heightCell == "" {
                let arr = ExploreNewHotCell.cellHeight(data)
                let heightCell = arr[0] as! CGFloat
                let heightContent = arr[1] as! CGFloat
                let heightTitle = arr[2] as! CGFloat
                let content = arr[3] as! String
                let title = arr[4] as! String
                let d = NSMutableDictionary(dictionary: data)
                d.setValue(heightCell, forKey: "heightCell")
                d.setValue(heightContent, forKey: "heightContent")
                d.setValue(heightTitle, forKey: "heightTitle")
                d.setValue(content, forKey: "content")
                d.setValue(title, forKey: "title")
                dataArrayDream.replaceObjectAtIndex(indexPath.row, withObject: d)
                return heightCell
            } else {
                return heightCell.toCGFloat()
            }
        } else if index == 2 {
            return getHeight(indexPath, dataArray: dataArrayStep)
        } else if index == 3 {
            // TODO: - topic cell 高度
            let data = dataArrayTopic[indexPath.row] as! NSDictionary
            let title = data.stringAttributeForKey("title").decode()
            let content = data.stringAttributeForKey("content").decode()
            var hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            var hContent = content.stringHeightWith(12, width: globalWidth - 80)
            let hTitleMax = "\n".stringHeightWith(16, width: globalWidth - 80)
            let hContentMax = "\n\n\n".stringHeightWith(12, width: globalWidth - 80)
            hTitle = min(hTitle, hTitleMax)
            hContent = min(hContent, hContentMax)
            
            return hTitle + hContent + 99
        } else {
            return 0
        }
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

            for (_index, _table) in self.tableDict {
                if _index == index {
                    showTableViewWithIndex(index)
                    _table.headerBeginRefreshing()
                }
            }
            
        }
        return true
    }
}

extension ExploreSearch: RedditDelegate {
    /**
    <#Description#>
    */
    func updateData(index: Int, key: String, value: String, section: Int) {
        SAUpdate(self.dataArrayTopic, index: index, key: key, value: value, tableView: self.topicTableView)
    }
    
    func updateTable() {
        self.topicTableView.reloadData()
    }
    
    func updateTableFooter() {
        self.topicTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
    }
}

// MARK: - UIActionSheet Delegate
extension ExploreSearch: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            let type = self.hasFollowTag ? "unfollow" : "follow"
            
            Api.postSearchFollow(self.searchText.text!.encode(), type: type) {
                json in
                
                if json != nil {
                    if let _data = json!.objectForKey("data") as? String {
                        if _data == "success" {
                            if self.hasFollowTag {
                                self.view.showTipText("已取消关注标签 #\(self.searchText.text!)")
                            } else {
                                self.view.showTipText("已关注标签 #\(self.searchText.text!)")
                            }
                        }
                    }
                    
                }
            }
        }
    }
}
//
//<<<<<<< HEAD
//=======
// MARK: - 实现 UIScrollView Delegate
extension ExploreSearch {
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView is UITableView {
            
            if index == 2 {
//                self.loadImagesForVisibleCells()
            }
        } else if scrollView .isMemberOfClass(UIScrollView) {
            let xOffset = scrollView.contentOffset.x
            let page: Int = Int(xOffset / globalWidth)
            
            /* */
            index = page
            /* */
            
            setupButtonColor(page)
            tableScrollToTop()
            
            UIView.animateWithDuration(0.2, animations: {
               self.floatView.setX((globalWidth - 320)/2 + CGFloat(page * 80) + 15.0)
            })
            
            if self.dataSourceArray[index].count == 0 {
                showTableViewWithIndex(index)
                self.tableDict[index]?.headerBeginRefreshing()
            }
        }
    }
}
// MARK: - UIGestureRecognizerDelegate
extension ExploreSearch {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 当判断到右滑返回时，取消其他所有手势
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }

}














