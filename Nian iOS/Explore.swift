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
    @IBOutlet weak var btnHot: UILabel!
    @IBOutlet weak var imageSearch: UIImageView!
    @IBOutlet weak var imageFriend: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var navTopView: UIView!
    @IBOutlet weak var navHolder: UIView!
    
    var tableView: VVeboTableView!
    var tableViewDynamic: VVeboTableView!
    var tableViewHot: UITableView!
    var tableViewEditor: UITableView!
    var tableViewNewest: UITableView!
    var dataArray = NSMutableArray()
    var dataArrayDynamic = NSMutableArray()
    var dataArrayHot = NSMutableArray()
    var dataArrayEditor = NSMutableArray()
    var dataArrayNewest = NSMutableArray()
    
    var current = -1
    var page = 1
    var pageDynamic = 1
    var pageHot = 1
    
    var isLoadingHot = false
    
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
            let type = data.stringAttributeForKey("type")
            if type == "0" {
                let c = t.dequeueReusableCellWithIdentifier("ExploreDynamicDreamCell", forIndexPath: indexPath) as! ExploreDynamicDreamCell
                c.data = data
                return c
            } else {
                return getCell(indexPath, dataArray: d, type: 2)
            }
        } else if tableView == self.tableViewHot {
            let c = tableView.dequeueReusableCellWithIdentifier("ExploreNewHotCell", forIndexPath: indexPath) as? ExploreNewHotCell
            c!.data = self.dataArrayHot[indexPath.row] as! NSDictionary
            c!.indexPath = indexPath
            c!._layoutSubviews()
            return c!
        } else if tableView == self.tableViewEditor {
            var c = tableViewEditor.dequeueReusableCellWithIdentifier("NewestCell") as? NewestCell
            if c == nil {
                c = NewestCell(style: .Default, reuseIdentifier: "NewestCell")
            }
            if dataArrayEditor.count == 0 {
                c?.data = NSDictionary()
            } else {
                c?.data = dataArrayEditor[indexPath.row] as! NSDictionary
            }
            c!.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            return c!
        } else if tableView == self.tableViewNewest {
            var c = tableViewNewest.dequeueReusableCellWithIdentifier("NewestCell") as? NewestCell
            if c == nil {
                c = NewestCell(style: .Default, reuseIdentifier: "NewestCell")
            }
            if dataArrayNewest.count == 0 {
                c?.data = NSDictionary()
            } else {
                c?.data = dataArrayNewest[indexPath.row] as! NSDictionary
            }
            c!.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
            return c!
        }
        return getCell(indexPath, dataArray: d)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var d = dataArray
        let vc = DreamViewController()
        if tableView == self.tableViewDynamic {
            d = dataArrayDynamic
        } else if tableView == self.tableViewHot {
            d = dataArrayHot
        } else if tableView == self.tableViewEditor || tableView == self.tableViewNewest {
            if dataArrayEditor.count == 0 || dataArrayNewest.count == 0 {
                return
            }
            d = tableView == self.tableViewEditor ? dataArrayEditor : dataArrayNewest
            let data = d[indexPath.row] as! NSDictionary
            vc.Id = data.stringAttributeForKey("id")
            self.navigationController?.pushViewController(vc, animated: true)
            return
        }
        let data = d[indexPath.row] as! NSDictionary
        vc.Id = tableView != tableViewHot ? data.stringAttributeForKey("dream") : data.stringAttributeForKey("id")
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
        } else if tableView == self.tableViewHot {
            let data = dataArrayHot[indexPath.row] as! NSDictionary
            let heightCell = data.objectForKey("heightCell") as! CGFloat
            return heightCell
        } else if tableView == self.tableViewEditor {
            return 96
        } else if tableView == self.tableViewNewest {
            return 96
        }
        return t.getHeight(indexPath, dataArray: d)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var d = dataArray
        if tableView == self.tableViewDynamic {
            d = dataArrayDynamic
        } else if tableView == self.tableViewHot {
            d = dataArrayHot
        } else if tableView == self.tableViewEditor {
            d = dataArrayEditor
            if dataArrayEditor.count == 0 {
                return 6
            }
        } else if tableView == self.tableViewNewest {
            d = dataArrayNewest
            if dataArrayNewest.count == 0 {
                return 6
            }
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
        self.navTopView.backgroundColor = BarColor
        self.navTopView.setWidth(globalWidth)
        self.navHolder.setX((globalWidth - self.navHolder.frame.size.width)/2)
        self.imageSearch.setX(globalWidth - 43)
        self.imageFriend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFriendClick"))
        self.imageSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onSearchClick"))
        view.backgroundColor = UIColor.whiteColor()
        
        scrollView.setWidth(globalWidth)
        scrollView.contentSize = CGSizeMake(globalWidth * 3, scrollView.frame.size.height)
//        recomTableView.frame.origin.x = globalWidth * 2
        
        btnFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnDynamic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        btnHot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTabClick:"))
        
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
                } else {
                    tableViewHot.headerBeginRefreshing()
                }
            }
        } else {
            if tab < 2 {
                if tab == 0 {
                    tableView.headerBeginRefreshing()
                } else if tab == 1 {
                    tableViewDynamic.headerBeginRefreshing()
                }
            } else {
                tableViewHot.headerBeginRefreshing()
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
            self.btnHot.setTabAlpha(x, index: 2)
        } else if scrollView == tableViewHot {
            let y = tableViewHot.contentOffset.y + tableViewHot.height()
            let height = tableViewHot.contentSize.height
            if y + 400 > height && dataArrayHot.count > 0 {
                tableViewHot.footerBeginRefreshing()
            }
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
            tableViewHot.scrollsToTop = false
        } else if tab == 1 {
            tableView.scrollsToTop = false
            tableViewDynamic.scrollsToTop = true
            tableViewHot.scrollsToTop = false
        } else if tab == 2 {
            tableView.scrollsToTop = false
            tableViewDynamic.scrollsToTop = false
            tableViewHot.scrollsToTop = true
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
