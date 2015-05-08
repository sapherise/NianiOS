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

class ExploreViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var btnFollow: UILabel!
    @IBOutlet var btnDynamic: UILabel!
    @IBOutlet var btnHot: UILabel!
    @IBOutlet var imageFriend: UIImageView!
    @IBOutlet weak var imageSearch: UIImageView!
    @IBOutlet weak var floatView: UIView!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var navView: UIView!
    @IBOutlet var navTopView: UIView!
    @IBOutlet var navTitle: UILabel!
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
            btnHot,
        ]
        setupViews()
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
        self.view.frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
        tableView.setWidth(globalWidth)
        
        self.navTopView.backgroundColor = BarColor
        self.navTopView.setWidth(globalWidth)
        self.navTitle.setX(globalWidth/2-22)
        self.navView.setWidth(globalWidth)
        self.navHolder.setX(globalWidth/2-120)
        self.imageSearch.setX(globalWidth - 43)
        self.imageFriend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFriendClick"))
        self.imageSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSearchClick"))
        view.backgroundColor = UIColor.whiteColor()
        
        btnFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnDynamic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnHot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
    }
    
    func onPullDown() {
        self.currentProvider.onRefresh()
    }
    
    func onPullUp() {
        self.currentProvider.onLoad()
    }
    
    func switchTab(tab: Int) {
        if current != -1 {
        //    buttons[current].selected = false
            buttons[current].textColor = UIColor.blackColor()
            currentProvider.onHide()
        }
        var loading = current == tab ? true : false
        current = tab
        currentProvider = self.providers[tab]
        buttons[tab].textColor = SeaColor

        tableView.delegate = currentProvider as? UITableViewDelegate
        tableView.dataSource = currentProvider as? UITableViewDataSource

        currentProvider.onShow(loading)
    }
    
    func onTabClick(sender: UIGestureRecognizer) {
        switchTab(sender.view!.tag - 1100)
        globalNumExploreBar = sender.view!.tag - 1100
        tableView.tableHeaderView = UIView()
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.floatView.setX(19 + 76 * CGFloat(globalNumExploreBar))
        })
        
    }
    
    func onFriendClick() {
        self.navigationController?.pushViewController(FindViewController(), animated: true)
    }
    
    func onSearchClick() {
        self.performSegueWithIdentifier("toSearch", sender: nil)
    }
}
