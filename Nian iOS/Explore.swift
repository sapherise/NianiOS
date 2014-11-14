//
//  Explore.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var btnFollow: UIButton!
    @IBOutlet var btnDynamic: UIButton!
    @IBOutlet var btnHot: UIButton!
    @IBOutlet var btnNew: UIButton!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var tableView: UITableView!
    
    var current = -1
    var currentProvider: ExploreProviderDelegate!
    
    var buttons: [UIButton]!
    var data: [ExploreProviderDelegate]!
    
    override func viewDidLoad() {
        self.buttons = [
            btnFollow,
            btnDynamic,
            btnHot,
            btnNew
        ]
        self.data = [
            ExploreFollowProvider(bindView: tableView),
            ExploreDynamicProvider(bindView: tableView),
            ExploreHotProvider(bindView: collectionView),
            ExploreNewProvider(bindView: collectionView)
        ]
        setupViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController!.navigationBar.setY(-44)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController!.navigationBar.setY(20)
    }
    
    func setupViews() {
        view.backgroundColor = BGColor
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset.bottom = 60
        tableView.allowsSelection = false
        btnFollow.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnDynamic.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnHot.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        btnNew.addTarget(self, action: "onTabClick:", forControlEvents: UIControlEvents.TouchUpInside)
        tableView.addHeaderWithCallback(onPullDown)
        tableView.addFooterWithCallback(onPullUp)
        collectionView.addHeaderWithCallback(onPullDown)
        collectionView.addFooterWithCallback(onPullUp)
        switchTab(0);
    }
    
    func onPullDown() {
        self.currentProvider.refreshData()
    }
    
    func onPullUp() {
        self.currentProvider.loadData()
    }
    
    func switchTab(tab: Int) {
        if current == tab {
            return
        }
        if current != -1 {
            buttons[current].selected = false
        }
        current = tab
        currentProvider = self.data[tab]
        buttons[tab].selected = true
        if tab < 2 {
            collectionView.dataSource = nil
            collectionView.delegate = nil
            collectionView.hidden = true
            tableView.delegate = currentProvider as? UITableViewDelegate
            tableView.dataSource = currentProvider as? UITableViewDataSource
            tableView.hidden = false
            tableView.setContentOffset(CGPointZero, animated: true)
        } else {
            tableView.dataSource = nil
            tableView.delegate = nil
            tableView.hidden = true
            collectionView.delegate = currentProvider as? UICollectionViewDelegate
            collectionView.dataSource = currentProvider as? UICollectionViewDataSource
            collectionView.hidden = false
            collectionView.setContentOffset(CGPointZero, animated: true)
        }
        currentProvider.show()
    }
    
    func onTabClick(sender: UIButton) {
        switchTab(sender.tag - 1100)
    }
}
