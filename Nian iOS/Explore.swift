//
//  Explore.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreProvider: NSObject {
    
    func findTableCell(view: UIView?) -> UIView? {
        for var v = view; v != nil; v = v!.superview {
            if v! is UITableViewCell {
                return v
            }
        }
        return nil
    }
    
    func onHide() {
    }
    
    func onShow(loading: Bool) {
    }
    
    func onRefresh() {
    }
    
    func onLoad() {
    }
}

class ExploreViewController: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    @IBOutlet var btnFollow: UILabel!
    @IBOutlet var btnDynamic: UILabel!
    @IBOutlet var btnHot: UILabel!
    
    @IBOutlet weak var imageSearch: UIImageView!
    @IBOutlet var imageFriend: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dynamicTableView: UITableView!
    @IBOutlet weak var recomTableView: UITableView!
    
    @IBOutlet var navTopView: UIView!
    @IBOutlet var navHolder: UIView!
    
    var appear = false
    var current = -1
    var currentProvider: ExploreProvider!
    
    var buttons: [UILabel]!
    var providers: [ExploreProvider]!
    
    override func viewDidLoad() {
        self.buttons = [
            btnFollow,
            btnDynamic,
            btnHot, // 推荐
        ]
        setupViews()
        
        // brief: tableView = followTableView
        tableView.dataSource = providers[0] as? UITableViewDataSource
        tableView.delegate = providers[0] as? UITableViewDelegate
        dynamicTableView.dataSource = providers[1] as? UITableViewDataSource
        dynamicTableView.delegate = providers[1] as? UITableViewDelegate
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
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "exploreTop", object:nil)
        navShow()
    }
    
    func exploreTop(noti: NSNotification){
        if current == -1 {
            switchTab(0)
        }else{
            if let v = "\(noti.object!)".toInt() {
                if v > 0 {
                    switchTab(current)
                    if self.tableView.contentOffset.y  > 0 {
                        delay(0.2, {
                            self.tableView.headerBeginRefreshing()
                        })
                    }else{
                        self.tableView.headerBeginRefreshing()
                    }
                }
            }
        }
    }
    
    func setupViews() {
        self.providers = [
            ExploreFollowProvider(viewController: self),
            ExploreDynamicProvider(viewController: self),
            ExploreNewHot(viewController: self),
        ]
        globalNumExploreBar = 0
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
        dynamicTableView.frame.origin.x = globalWidth
        recomTableView.frame.origin.x = globalWidth * 2
        
        btnFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnDynamic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnHot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
        dynamicTableView.addHeaderWithCallback(onPullDown)
        dynamicTableView.addFooterWithCallback(onPullUp)
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
        if current != -1 {
            currentProvider.onHide()
        }
        var loading = current == tab ? true : false
        current = tab
        currentProvider = self.providers[tab]

        switch tab {
        case 0:
            self.btnFollow.alpha = 1.0
            self.btnDynamic.alpha = 0.4
            self.btnHot.alpha = 0.4
        case 1:
            self.btnFollow.alpha = 0.4
            self.btnDynamic.alpha = 1.0
            self.btnHot.alpha = 0.4
        case 2:
            self.btnFollow.alpha = 0.4
            self.btnDynamic.alpha = 0.4
            self.btnHot.alpha = 1.0
        default:
            break
        }

        currentProvider.onShow(loading)
    }
    
    func onTabClick(sender: UIGestureRecognizer) {
        switchTab(sender.view!.tag - 1100)
        globalNumExploreBar = sender.view!.tag - 1100
        
        scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(globalNumExploreBar), 0), animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var xOffset = scrollView.contentOffset.x
        var page: Int = Int(xOffset / globalWidth)
        
        switchTab(page)
    }
    
    func onFriendClick() {
        self.navigationController?.pushViewController(FindViewController(), animated: true)
    }
    
    func onSearchClick() {
        self.performSegueWithIdentifier("toSearch", sender: nil)
    }
}
