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
    
    func onShow() {
    }
    
    func onRefresh() {
    }
    
    func onLoad() {
    }
}

class ExploreViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var btnDynamic: UIButton!
    @IBOutlet var btnHot: UIButton!
    @IBOutlet var btnNew: UIButton!
    @IBOutlet var btnFriend: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    
    var appear = false
    var current = -1
    var currentProvider: ExploreProvider!
    
    var buttons: [UIButton]!
    var providers: [ExploreProvider]!
    
    override func viewDidLoad() {
        self.buttons = [
            btnFollow,
            btnDynamic,
            btnHot,
            btnNew
        ]
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.setY(-44)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.navigationBar.setY(-44)
        switchTab(0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.setY(20)
    }
    
    func setupViews() {
        self.providers = [
            ExploreFollowProvider(viewController: self),
            ExploreDynamicProvider(viewController: self),
            ExploreHotProvider(viewController: self),
            ExploreNewProvider(viewController: self)
        ]
        view.backgroundColor = BGColor
        collectionView.alwaysBounceVertical = true
        var layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
        layout.sectionInset.left = 15
        layout.sectionInset.right = 15
        collectionView.collectionViewLayout = layout
        tableView.allowsSelection = false
        btnFollow.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnDynamic.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnHot.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNew.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnFriend.addTarget(self, action: "onFriendClick", forControlEvents: UIControlEvents.TouchUpInside)
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
        collectionView.addHeaderWithCallback(onPullDown)
        collectionView.addFooterWithCallback(onPullUp)
    }
    
    func onPullDown() {
        self.currentProvider.onRefresh()
    }
    
    func onPullUp() {
        self.currentProvider.onLoad()
    }
    
    func switchTab(tab: Int) {
        if current != -1 {
            buttons[current].selected = false
            currentProvider.onHide()
        }
        current = tab
        currentProvider = self.providers[tab]
        buttons[tab].selected = true
        if tab < 3 {
            collectionView.dataSource = nil
            collectionView.delegate = nil
            collectionView.hidden = true
            tableView.delegate = currentProvider as? UITableViewDelegate
            tableView.dataSource = currentProvider as? UITableViewDataSource
            tableView.hidden = false
        } else {
            tableView.dataSource = nil
            tableView.delegate = nil
            tableView.hidden = true
            collectionView.delegate = currentProvider as? UICollectionViewDelegate
            collectionView.dataSource = currentProvider as? UICollectionViewDataSource
            collectionView.hidden = false
        }
        currentProvider.onShow()
    }
    
    func onTabClick(sender: UIButton) {
        switchTab(sender.tag - 1100)
    }
    
    func onFriendClick() {
        var storyboard = UIStoryboard(name: "ExploreFriend", bundle: nil)
        var vz = storyboard.instantiateViewControllerWithIdentifier("ExploreFriendViewController") as UIViewController
        self.navigationController!.pushViewController(vz, animated: true)
    }
}
