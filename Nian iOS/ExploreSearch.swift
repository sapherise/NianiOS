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
    var radius: CGFloat = 26
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.leftViewMode = .always
        self.leftView  = UIView()
        self.leftView?.contentMode = .center
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x, y: bounds.origin.y, width: radius , height: radius)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.size.width - 25, y: bounds.origin.y, width: radius, height: radius)
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
                    userTableView.isHidden = false
                }
            }
        }
    }
    var dataArrayDream = NSMutableArray() {
        didSet {
            if dataArrayDream.count > 0 {
                if index == 1 {
                    dreamTableView.isHidden = false
                }
            }
        }
    }
    var dataArrayStep = NSMutableArray() {
        didSet {
            if dataArrayStep.count > 0 {
                if index == 2 {
                    stepTableView.isHidden = false
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
    @IBOutlet weak var floatView: UIView!
    
    var hasFollowTag: Bool = false
    var tagFollowActionSheet: UIActionSheet?
    // MARK: -
    
    var index: Int = 0     /* 用来指示当前的 table，在其他文件里可能相当于 current */
    var dreamPage: Int = 1
    var userPage: Int = 1
    var stepPage: Int = 1
    
    /* 改变 Button 的颜色时使用 */
    var btnArray:[UIButton] = []
    
    /* 统一 UITableview 的 header call back 和 footer call back */
    var tableDict = Dictionary<Int, UITableView>()
    
    /* 代码生成的搜索框 */
    var searchText = NITextfield(frame: CGRect(x: 48, y: 8, width: globalWidth - 72, height: 26))
    
    // 用在计算 table view 滚动时应不应该加载图片
    //    var targetRect: NSValue?
    
    // MARK: - all table view 都是延迟加载的
    
    lazy var userTableView: UITableView = {
        let userTableView = UITableView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 104))
        userTableView.register(UINib(nibName: "SAUserCell", bundle: nil), forCellReuseIdentifier: "SAUserCell")
        userTableView.separatorStyle = .none
        
        userTableView.dataSource = self
        userTableView.delegate = self
        
        if self.dataArrayUser.count == 0 {
            userTableView.isHidden = true
        }
        
        return userTableView
    }()
    
    lazy var dreamTableView: UITableView = {
        let dreamTableView = UITableView(frame: CGRect(x: globalWidth, y: 0, width: globalWidth, height: globalHeight - 104))
        dreamTableView.register(UINib(nibName: "ExploreNewHotCell", bundle: nil), forCellReuseIdentifier: "ExploreNewHotCell")
        dreamTableView.separatorStyle = .none
        
        dreamTableView.dataSource = self
        dreamTableView.delegate = self
        
        if self.dataArrayDream.count == 0 {
            dreamTableView.isHidden = true
        }
        
        return dreamTableView
    }()
    
    lazy var stepTableView: VVeboTableView = {
        let stepTableView = VVeboTableView(frame: CGRect(x: globalWidth * 2, y: 0, width: globalWidth, height: globalHeight - 104))
        stepTableView.separatorStyle = .none
        
        stepTableView.dataSource = self
        stepTableView.delegate = self
        
        if self.dataArrayStep.count == 0 {
            stepTableView.isHidden = true
        }
        
        return stepTableView
    }()
    
    // MARK: - View Controller 的生命周期和 View 的颜色、位置的控制
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.showTableViewWithIndex(index)
        self.viewBackFix()
        
        if preSetSearch.characters.count > 0 {
            searchText.text = preSetSearch
        }
        
        self.navigationController?.navigationBar.addSubview(searchText)
        searchText.alpha = 0.0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.searchText.alpha = 1.0
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        self.navigationController?.navigationBar.addSubview(searchText)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: nil, queue: OperationQueue.main) { _ in
            if self.searchText.text != "" {
                self.searchText.rightViewMode = .always
            } else {
                self.searchText.rightViewMode = .never
            }
        }
        
        /* 现在可能预先设置的搜索来自 Dream cell top, 对应 index == 1； Topic cell top 对应 index == 3  */
        let flowViewOffset = index == 1 ? (globalWidth/2 - 40 + 15) : (globalWidth/2 - 120 + 15)
        
        if (preSetSearch.characters.count > 0 && shouldPerformSearch) {
            if let _ = self.tableDict[index] {
                UIView.animate(withDuration: 0.2, animations: { () -> Void in
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
    
    override func viewWillDisappear(_ animated: Bool) {
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
        userButton.setX(_tmpWidth - 120)
        dreamButton.setX(_tmpWidth - 40)
        stepButton.setX(_tmpWidth + 40)
        
        floatView.setX(_tmpWidth - 120 + 15)
        floatView.backgroundColor = UIColor.HighlightColor()
        
        btnArray = [userButton, dreamButton, stepButton]
        dataSourceArray = [dataArrayUser, dataArrayDream, dataArrayStep]
        
        let color = UIColor(red: 0xd8/255, green: 0xd8/255, blue: 0xd8/255, alpha: 1)
        //        searchText = NITextfield(frame: CGRectMake(48, 8, globalWidth - 96, 26))
        searchText.layer.cornerRadius = 13
        searchText.layer.masksToBounds = true
        searchText.backgroundColor = UIColor(red: 0x3b/255, green: 0x40/255, blue: 0x44/255, alpha: 1.0)
        searchText.leftViewMode = .always
        searchText.leftView  = UIImageView(image: UIImage(named: "search"))
        searchText.leftView?.contentMode = .center
        searchText.rightView = UIImageView(image: UIImage(named: "close-1"))
        searchText.rightView!.contentMode = .center
        searchText.rightView!.isUserInteractionEnabled = true
        searchText.rightView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreSearch.clearText(_:))))
        searchText.attributedPlaceholder = NSAttributedString(string: "搜索", attributes: [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12.0)])
        searchText.contentVerticalAlignment = .center
        searchText.font = UIFont.systemFont(ofSize: 12.0)
        searchText.textColor = UIColor(red: 0xff/255, green: 0xff/255, blue: 0xff/255, alpha: 1)
        searchText.returnKeyType = .search
        searchText.clearsOnBeginEditing = false
        searchText.delegate = self
        //        self.navigationController?.navigationBar.addSubview(searchText)
        
        scrollView.scrollsToTop = false
        scrollView.contentSize = CGSize(width: globalWidth * 3, height: scrollView.frame.size.height)
        scrollView.delegate = self
    }
    
    func setupButtonColor(_ index: Int) {
        
        /* 改变 Button 的颜色 */
        for (_index, _btn) in self.btnArray.enumerated() {
            if _index == index {
                _btn.setTitleColor(UIColor.HighlightColor(), for: UIControlState())
            } else {
                _btn.setTitleColor(UIColor.black, for: UIControlState())
            }
        }
        
        /* 修改 scrollsToTop */
        for (_index, _table) in self.tableDict {
            if _index == index {
                _table.scrollsToTop = true
            } else {
                _table.scrollsToTop = false
            }
        }
    }
    
    /**
    <#Description#>
    
    :param: index <#index description#>
    */
    func showTableViewWithIndex(_ index: Int) {
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
        default:
            break
        }
    }
    
    func load(_ index: Int, clear: Bool) {
        currenTableView = nil
        for (_index, _table) in self.tableDict {
            if _index == index {
                _table.isHidden = false
                self.beginSearch(clear: clear, index: _index)
            }
        }
        
    }
    
    /**
     <#Description#>
     
     :param: clear <#clear description#>
     :param: table <#table description#>
     */
    func beginSearch(clear: Bool, index: Int) {
        if index == 0 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            userSearch(clear)
        } else if index == 1 {
            self.scrollView.setContentOffset(CGPoint(x: globalWidth, y: 0), animated: true)
            
            dreamSearch(clear)
        } else if index == 2 {
            self.scrollView.setContentOffset(CGPoint(x: globalWidth * 2, y: 0), animated: true)
            
            stepSearch(clear)
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView is UITableView {
            searchText.resignFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text != "" {
            searchText.rightViewMode = .always
        }
    }
    
    @objc func clearText(_ sender: UITapGestureRecognizer) {
        searchText.text = ""
        searchText.rightViewMode = .never
        searchText.becomeFirstResponder()
    }
    
    /* */
    //MARK: -
    
    @IBAction func user(_ sender: AnyObject) {
        let tmp = index
        index = 0
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 120 + 15)
        })
        
        self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        if searchText.text != "" && (tmp == index || self.dataArrayUser.count == 0) {
            self.userTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func dream(_ sender: AnyObject) {
        let tmp = index
        index = 1
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 - 40 + 15)
        })
        
        self.scrollView.setContentOffset(CGPoint(x: globalWidth, y: 0), animated: true)
        
        if searchText.text != "" && (tmp == index || self.dataArrayDream.count == 0) {
            self.dreamTableView.headerBeginRefreshing()
        }
    }
    
    @IBAction func step(_ sender: AnyObject) {
        let tmp = index
        index = 2
        setupButtonColor(index)
        showTableViewWithIndex(index)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.floatView.setX(globalWidth/2 + 40 + 15)
        })
        
        self.scrollView.setContentOffset(CGPoint(x: globalWidth * 2, y: 0), animated: true)
        
        if searchText.text != ""  && (tmp == index || self.dataArrayStep.count == 0) {
            self.stepTableView.headerBeginRefreshing()
        }
    }
    
    func userSearch(_ clear: Bool) {
        if clear {
            userPage = 1
        }
        
        Api.getSearchUsers(searchText.text!, page: userPage, callback: {
            json in
            if json != nil {
                if clear {
                    self.dataArrayUser.removeAllObjects()
                }
                let items = json!.object(forKey: "users") as? NSArray
                if items != nil {
                    for item in items! {
                        self.dataArrayUser.add(item)
                    }
                    if items!.count < 30 {
                        self.userTableView.setFooterHidden(true)
                    }
                }
                
                if self.dataArrayUser.count == 0 {
                    let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 64 - 40))
                    v.addGhost("没有人叫这个名字...\n所以你只搜到了这只鬼")
                    self.userTableView.tableHeaderView = v
                } else {
                    self.userTableView.tableHeaderView = nil
                }
                self.userPage += 1
            }
            self.userTableView.reloadData()
            self.userTableView.headerEndRefreshing()
            self.userTableView.footerEndRefreshing()
        })
    }
    
    func dreamSearch(_ clear: Bool) {
        if clear {
            dreamPage = 1
        }
        Api.getSearchDream(searchText.text!, page: dreamPage, callback: { json in
            if json != nil {
                if clear {
                    self.dataArrayDream.removeAllObjects()
                }
                if let j = json as? NSDictionary {
                    if let data = j.object(forKey: "data") as? NSDictionary {
                        if let dreams = data.object(forKey: "dreams") as? NSArray {
                            for item in dreams {
                                self.dataArrayDream.add(item)
                            }
                        }
                    }
                }
                if self.dataArrayDream.count == 0 {
                    let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 64 - 40))
                    v.addGhost("没有记本有这个标签！\n如果你想搜索带有关键字的进展，\n可以试试旁边的进展！")
                    self.dreamTableView.tableHeaderView = v
                } else {
                    self.dreamTableView.tableHeaderView = nil
                }
                self.dreamPage += 1
            }
            self.dreamTableView.reloadData()
            self.dreamTableView.headerEndRefreshing()
            self.dreamTableView.footerEndRefreshing()
        })
    }
    
    func stepSearch(_ clear: Bool) {
        currenTableView = stepTableView
        if clear {
            stepPage = 1
        }
        Api.getSearchSteps(searchText.text!, page: stepPage, callback: {
            json in
            if json != nil {
                if clear {
                    globalVVeboReload = true
                    self.dataArrayStep.removeAllObjects()
                } else {
                    globalVVeboReload = false
                }
                if let j = json as? NSDictionary {
                    if let data = j.object(forKey: "data") as? NSDictionary {
                        if let steps = data.object(forKey: "steps") as? NSArray {
                            for item in steps {
                                let d = VVeboCell.SACellDataRecode(item as! NSDictionary)
                                self.dataArrayStep.add(d)
                            }
                        }
                    }
                }
                self.currentDataArray = self.dataArrayStep
                if self.dataArrayStep.count == 0 {
                    let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 64 - 40))
                    v.addGhost("没有一个进展里有这个关键字！\n我还以为世界上没有人能看到这条错误提示呢...")
                    self.stepTableView.tableHeaderView = v
                } else {
                    self.stepTableView.tableHeaderView = nil
                }
                self.stepPage += 1
            }
            self.stepTableView.reloadData()
            self.stepTableView.headerEndRefreshing()
            self.stepTableView.footerEndRefreshing()
        })
    }
    
    // MARK: - table view delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch index {
        case 0:
            return self.dataArrayUser.count
        case 1:
            return self.dataArrayDream.count
        case 2:
            return self.dataArrayStep.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch index {
        case 0:
            let cell = self.userTableView.dequeueReusableCell(withIdentifier: "SAUserCell", for: indexPath) as? SAUserCell
            let data = self.dataArrayUser[(indexPath as NSIndexPath).row] as! NSDictionary
            cell?.data = data
            cell?.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreSearch.toUser(_:))))
            cell?.btnMain.tag = (indexPath as NSIndexPath).row
            cell?.btnMain.addTarget(self, action: #selector(ExploreSearch.onFollow(_:)), for: UIControlEvents.touchUpInside)
            
            return cell!
        case 1:
            let cell = self.dreamTableView.dequeueReusableCell(withIdentifier: "ExploreNewHotCell", for: indexPath) as? ExploreNewHotCell
            cell!.data = self.dataArrayDream[(indexPath as NSIndexPath).row] as! NSDictionary
            
            if (indexPath as NSIndexPath).row == self.dataArrayDream.count - 1 {
                cell!.viewLine.isHidden = true
            } else {
                cell!.viewLine.isHidden = false
            }
            cell!._layoutSubviews()
            
            return cell!
        case 2:
            return getCell(indexPath, dataArray: dataArrayStep, type: 0)
        default:
            let cell = UITableViewCell()
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if index == 0 {
            //            let index = indexPath.row
            //            let data = self.dataArrayStep[index] as! NSDictionary
            //            let dream = data.stringAttributeForKey("dream")
            //            SADream(dream)
        } else if index == 1 {
            let DreamVC = DreamViewController()
            DreamVC.Id = (self.dataArrayDream[(indexPath as NSIndexPath).row] as! NSDictionary)["id"] as! String
            
            self.navigationController?.pushViewController(DreamVC, animated: true)
        } else if index == 2 {
            let viewController = DreamViewController()
            let data = dataArrayStep[(indexPath as NSIndexPath).row] as! NSDictionary
            viewController.Id = data.stringAttributeForKey("dream")
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if index == 0 {
            return 71
        } else if index == 1 {
            let data = dataArrayDream[(indexPath as NSIndexPath).row] as! NSDictionary
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
                dataArrayDream.replaceObject(at: (indexPath as NSIndexPath).row, with: d)
                return heightCell
            } else {
                return heightCell.toCGFloat()
            }
        } else if index == 2 {
            return getHeight(indexPath, dataArray: dataArrayStep)
        } else {
            return 0
        }
    }
    
    // MARK: -
    
    @objc func toUser(_ sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            SAUser("\(tag)")
        }
    }
    
    func toDream(_ sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            SADream("\(tag)")
        }
    }
    
    func onFollowDream(_ sender: UIButton) {
        let tag = sender.tag
        let data = self.dataArrayDream[tag] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let follow = data.stringAttributeForKey("follow")
        let newFollow = follow == "0" ? "1" : "0"
        let mutableData = NSMutableDictionary(dictionary: data)
        mutableData.setValue(newFollow, forKey: "follow")
        self.dataArrayDream[tag] = mutableData
        self.dreamTableView.reloadData()
        Api.getFollowDream(id) { json in
        }
    }
    
    @objc func onFollow(_ sender: UIButton) {
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
            Api.getUnfollow(uid) { json in }
        } else {
            Api.getFollow(uid) { json in }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchText.resignFirstResponder()
        if searchText.text != "" {
            searchText.rightViewMode = .always
            
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

// MARK: - UIActionSheet Delegate
extension ExploreSearch: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            let type = self.hasFollowTag ? "unfollow" : "follow"
            
            Api.postSearchFollow(self.searchText.text!.encode(), type: type) {
                json in
                
                if json != nil {
                    if let _data = json!.object(forKey: "data") as? String {
                        if _data == "success" {
                            if self.hasFollowTag {
                                self.showTipText("已取消关注标签 #\(self.searchText.text!)")
                            } else {
                                self.showTipText("已关注标签 #\(self.searchText.text!)")
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView is UITableView {
        } else if scrollView.isMember(of: UIScrollView.self) {
            let xOffset = scrollView.contentOffset.x
            let page: Int = Int(xOffset / globalWidth)
            
            /* */
            index = page
            /* */
            
            setupButtonColor(page)
            
            UIView.animate(withDuration: 0.2, animations: {
                self.floatView.setX((globalWidth - 320)/2 + 40 + CGFloat(page * 80) + 15.0)
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 当判断到右滑返回时，取消其他所有手势
        if gestureRecognizer.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
            return true
        }
        return false
    }
    
}



