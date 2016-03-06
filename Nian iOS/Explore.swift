//
//  Explore.swift
//  Nian iOS
//
//  Created by vizee on 14/11/10.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

// MARK: - explore view controller
class ExploreViewController: VVeboViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var btnFollow: UILabel!
    @IBOutlet weak var btnDynamic: UILabel!
    @IBOutlet weak var imageSearch: UIImageView!
    @IBOutlet weak var imageFriend: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navTopView: UIView!
    @IBOutlet weak var navHolder: UIView!
    
    var tableView: VVeboTableView!
    var tableViewDynamic: VVeboTableView!
    var dataArray = NSMutableArray()
    var dataArrayDynamic = NSMutableArray()
    
    var current = -1
    var page = 1
    var pageDynamic = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let type = data.stringAttributeForKey("type_of")
            if type == "1" {
                let c = t.dequeueReusableCellWithIdentifier("ExploreDynamicDreamCell", forIndexPath: indexPath) as! ExploreDynamicDreamCell
                c.data = data
                c.setup()
                return c
            } else {
                //                return getCell(indexPath, dataArray: d, type: 2)
                return getCell(indexPath, dataArray: d, type: 2)
            }
        }
        return getCell(indexPath, dataArray: d, type: 0)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var d = dataArray
        let vc = DreamViewController()
        if tableView == self.tableViewDynamic {
            d = dataArrayDynamic
        }
        let data = d[indexPath.row] as! NSDictionary
        vc.Id = data.stringAttributeForKey("dream")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var t = self.tableView
        var d = dataArray
        if tableView == self.tableViewDynamic {
            t = self.tableViewDynamic
            d = dataArrayDynamic
            let data = dataArrayDynamic[indexPath.row] as! NSDictionary
            let type = data.stringAttributeForKey("type_of")
            if type == "1" {
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
    
    func setupViews() {
        globalNumExploreBar = 0
        
        self.view.frame = CGRectMake(0, 0, globalWidth, globalHeight - 49)
        self.navTopView.backgroundColor = UIColor.NavColor()
        self.navTopView.setWidth(globalWidth)
        self.navHolder.setX((globalWidth - self.navHolder.frame.size.width)/2)
        self.imageSearch.setX(globalWidth - 43)
        self.imageFriend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFriendClick"))
        self.imageSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSearchClick"))
        view.backgroundColor = UIColor.BackgroundColor()
        
        scrollView.setWidth(globalWidth)
        scrollView.contentSize = CGSizeMake(globalWidth * 2, scrollView.frame.size.height)
        
        btnFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnDynamic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        
        setupTables()
    }
    
    func switchTab(tab: Int) {
        let _current = current
        current = tab
        if tab == 0 {
            currenTableView = tableView
            currentDataArray = dataArray
        } else if tab == 1 {
            currenTableView = tableViewDynamic
            currentDataArray = dataArrayDynamic
        } else {
            currenTableView = nil
            currentDataArray = nil
        }
        
        if _current != tab {
            if !globalTabhasLoaded[tab] {
                if tab < 2 {
                    if tab == 0 {
                        tableView.headerBeginRefreshing()
                    } else if tab == 1 {
                        tableViewDynamic.headerBeginRefreshing()
                    }
                }
            } else {
                /* 当启动后是关注页面时，确保再次点击会重载 */
                if _current == -1 {
                    tableView.headerBeginRefreshing()
                }
            }
        } else {
            if tab < 2 {
                if tab == 0 {
                    tableView.headerBeginRefreshing()
                } else if tab == 1 {
                    tableViewDynamic.headerBeginRefreshing()
                }
            }
        }
        _setupScrolltoTop(current)
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
            
            // 当页面有变化时才考虑是否加载
            if page != current {
                switchTab(page)
            }
        } else {
            super.scrollViewDidEndScrollingAnimation(scrollView)
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let x = scrollView.contentOffset.x
            self.btnFollow.setTabAlpha(x, index: 0)
            self.btnDynamic.setTabAlpha(x, index: 1)
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
        } else if tab == 1 {
            tableView.scrollsToTop = false
            tableViewDynamic.scrollsToTop = true
        }
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