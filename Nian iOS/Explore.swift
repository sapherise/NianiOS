//
//  Explore.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreProvider: NSObject {
    func onHide() {
    }
    
    func onShow(loading: Bool) {
    }
    
    func onRefresh() {
    }
    
    func onLoad() {
    }
}

// MARK: - explore view controller
class ExploreViewController: VVeboViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnFollow: UILabel!
    @IBOutlet weak var btnDynamic: UILabel!
    @IBOutlet weak var btnHot: UILabel!
    
    @IBOutlet weak var imageSearch: UIImageView!
    @IBOutlet weak var imageFriend: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recomTableView: UITableView!
    
    @IBOutlet weak var navTopView: UIView!
    @IBOutlet weak var navHolder: UIView!
    
    @IBOutlet var btnNew: UIButton!
    @IBOutlet var btnEditor: UIButton!
    
    var tableView: VVeboTableView!
    var tableViewDynamic: VVeboTableView!
    var dataArray = NSMutableArray()
    var dataArrayDynamic = NSMutableArray()
    
    var appear = false
    var current = -1
    var currentProvider: ExploreProvider!
    
    var buttons: [UILabel]!
    var providers: [ExploreProvider]!
    var page = 1
    var pageDynamic = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.buttons = [
            btnFollow,
            btnDynamic,
            btnHot,
        ]
        setupViews()
        
        // brief: tableView = followTableView
        tableView.dataSource = self
        tableView.delegate = self
        tableViewDynamic.dataSource = self
        tableViewDynamic.delegate = self
        recomTableView.dataSource = providers[2] as? UITableViewDataSource
        recomTableView.delegate = providers[2] as? UITableViewDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "exploreTop:", name: "exploreTop", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "exploreTop", object:nil)
        navShow()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var t = self.tableView
        var d = dataArray
        if tableView == self.tableViewDynamic {
            t = self.tableViewDynamic
            d = dataArrayDynamic
            let data = dataArrayDynamic[indexPath.row] as! NSDictionary
            let type = data.stringAttributeForKey("type")
            if type == "0" {
                let c = t.dequeueReusableCellWithIdentifier("ExploreDynamicDreamCell", forIndexPath: indexPath) as! ExploreDynamicDreamCell
                c.data = data
                return c
            } else {
                return t.getCell(indexPath, dataArray: d, type: 2)
            }
        }
        return t.getCell(indexPath, dataArray: d)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("haha")
        var t = self.tableView
        var d = dataArray
        if tableView == self.tableViewDynamic {
            t = self.tableViewDynamic
            d = dataArrayDynamic
        }
        let data = d[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("dream")
        let vc = DreamViewController()
        vc.Id = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var t = self.tableView
        var d = dataArray
        if tableView == self.tableViewDynamic {
            t = self.tableViewDynamic
            d = dataArrayDynamic
            let data = dataArrayDynamic[indexPath.row] as! NSDictionary
            let type = data.stringAttributeForKey("type")
            if type == "0" {
                return 77
            }
        }
        return t.getHeight(indexPath, dataArray: d)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var d = dataArray
        if tableView == self.tableViewDynamic {
            d = dataArrayDynamic
        }
        return d.count
    }
    
    func exploreTop(noti: NSNotification){
        if current == -1 {
            switchTab(0)
        }else{
            if let v = Int("\(noti.object!)") {
                if v > 0 {
                    switchTab(current)
                }
            }
        }
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreFollow("\(page++)", callback: {
            json in
            if json != nil {
                globalTabhasLoaded[0] = true
                if clear {
                    self.dataArray.removeAllObjects()
                }
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    for item in items {
                        let data = SACell.SACellDataRecode(item as! NSDictionary)
                        self.dataArray.addObject(data)
                    }
                    self.currentDataArray = self.dataArray
                    self.tableView.tableHeaderView = nil
                } else if clear {
                    self.tableView.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableView.tableHeaderView?.addGhost("这是关注页面！\n当你关注了一些人或记本时\n这里会发生微妙变化")
                }
                if self.current == 0 {
                    self.tableView.headerEndRefreshing()
                    self.tableView.footerEndRefreshing()
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func loadDynamic(clear: Bool) {
        if clear {
            pageDynamic = 1
        }
        Api.getExploreDynamic("\(pageDynamic++)", callback: {
            json in
            if json != nil {
                globalTabhasLoaded[1] = true
                let data: AnyObject? = json!.objectForKey("data")
                let items = data!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    if clear {
                        self.dataArrayDynamic.removeAllObjects()
                    }
                    for item in items {
                        let data = SACell.SACellDataRecode(item as! NSDictionary)
                        self.dataArrayDynamic.addObject(data)
                    }
                    self.currentDataArray = self.dataArrayDynamic
                    self.tableViewDynamic.tableHeaderView = nil
                } else if clear {
                    self.tableViewDynamic.tableHeaderView = UIView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 49 - 64))
                    self.tableViewDynamic.tableHeaderView?.addGhost("这是动态页面！\n你关注的人赞过的内容\n都会出现在这里")
                }
                if self.current == 1 {
                    self.tableViewDynamic.headerEndRefreshing()
                    self.tableViewDynamic.footerEndRefreshing()
                    self.tableViewDynamic.reloadData()
                }
            }
        })
    }
    
    
    func setupViews() {
        self.providers = [
            ExploreRecommend(viewController: self),
            ExploreRecommend(viewController: self),
            ExploreRecommend(viewController: self),
        ]
        globalNumExploreBar = 0
        
        tableView = VVeboTableView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 49), style: .Plain)
        scrollView.addSubview(tableView)
        currenTableView = tableView
        
        tableViewDynamic = VVeboTableView(frame: CGRectMake(globalWidth, 0, globalWidth, globalHeight - 64 - 49), style: .Plain)
        
        //        viewController.dynamicTableView.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        tableViewDynamic.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        scrollView.addSubview(tableViewDynamic)
        
        self.scrollView.scrollsToTop = false
        self.tableView.scrollsToTop = true
        self.tableViewDynamic.scrollsToTop = false
        self.recomTableView.scrollsToTop = false
        
        self.view.frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
        self.navTopView.backgroundColor = BarColor
        self.navTopView.setWidth(globalWidth)
        self.navHolder.setX((globalWidth - self.navHolder.frame.size.width)/2)
        self.imageSearch.setX(globalWidth - 43)
        self.imageFriend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFriendClick"))
        self.imageSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSearchClick"))
        view.backgroundColor = UIColor.whiteColor()
        
        scrollView.setWidth(globalWidth)
        scrollView.contentSize = CGSizeMake(globalWidth * 3, scrollView.frame.size.height)
        tableView.frame.origin.x = 0
        recomTableView.frame.origin.x = globalWidth * 2
        
        btnFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnDynamic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnHot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        
        tableView.addHeaderWithCallback { () -> Void in
            self.load(true)
        }
        tableView.addFooterWithCallback { () -> Void in
            self.load(false)
        }
        tableViewDynamic.addHeaderWithCallback { () -> Void in
            self.loadDynamic(true)
        }
        tableViewDynamic.addFooterWithCallback { () -> Void in
            self.loadDynamic(false)
        }
        recomTableView.addHeaderWithCallback(onPullDown)
        recomTableView.addFooterWithCallback(onPullUp)
    }
    
    func onPullDown() {
        self.currentProvider.onRefresh()
    }
    
    func onPullUp() {
        self.currentProvider.onLoad()
    }
    
    func switchTab(tab: Int) {
        let _current = current
        if current != -1 {
            currentProvider.onHide()
        }
        current = tab
        currentProvider = self.providers[tab]
        _setupScrolltoTop(current)
        if tab == 0 {
            currenTableView = tableView
            currentDataArray = dataArray
        } else if tab == 1 {
            currenTableView = tableViewDynamic
            currentDataArray = dataArrayDynamic
        }
        
        if _current != tab {
            if !globalTabhasLoaded[tab] {
                currenTableView?.headerBeginRefreshing()
            }
        } else {
            currenTableView?.headerBeginRefreshing()
        }
    }
    
    func onTabClick(sender: UIGestureRecognizer) {
        globalNumExploreBar = sender.view!.tag - 1100
        let x1 = scrollView.contentOffset.x
        let x2 = globalWidth * CGFloat(globalNumExploreBar)
        if x1 == x2 {
            self.switchTab(sender.view!.tag - 1100)
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(globalNumExploreBar), 0), animated: false)
                }) { (Bool) -> Void in
                    self.switchTab(sender.view!.tag - 1100)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let xOffset = scrollView.contentOffset.x
            let page: Int = Int(xOffset / globalWidth)
            currentProvider = self.providers[page]
            switchTab(page)
        } else {
            super.scrollViewDidEndScrollingAnimation(scrollView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let x = scrollView.contentOffset.x
            self.btnFollow.setTabAlpha(x, index: 0)
            self.btnDynamic.setTabAlpha(x, index: 1)
            self.btnHot.setTabAlpha(x, index: 2)
        }
    }
    
    func onFriendClick() {
        self.navigationController?.pushViewController(FindViewController(), animated: true)
    }
    
    func onSearchClick() {
        self.performSegueWithIdentifier("toSearch", sender: nil)
    }
    
    private func _setupScrolltoTop(tab: Int) {
        if tab == 0 {
            tableView.scrollsToTop = true
            tableViewDynamic.scrollsToTop = false
            recomTableView.scrollsToTop = false
        } else if tab == 1 {
            tableView.scrollsToTop = false
            tableViewDynamic.scrollsToTop = true
            recomTableView.scrollsToTop = false
        } else if tab == 2 {
            tableView.scrollsToTop = false
            tableViewDynamic.scrollsToTop = false
            recomTableView.scrollsToTop = true
        }
    }
    
}

// MARK: -  Explore VC 不能同时响应多个手势
extension ExploreViewController {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer
        otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
    }
}


extension UILabel {
    func setTabAlpha(x: CGFloat, index: CGFloat) {
        var a:CGFloat = 0
        let big = globalWidth * (index + 1)
        let middle = globalWidth * index
        let small = globalWidth * (index - 1)
        if x <= big && x >= middle {
            a = (big - x) * 0.6 / globalWidth + 0.4
        } else if x <= middle && x >= small {
            a = (x - small) * 0.6 / globalWidth + 0.4
        } else {
            a = 0.4
        }
        self.alpha = a
    }
}
