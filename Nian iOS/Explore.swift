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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(ExploreViewController.exploreTop(_:)), name: NSNotification.Name(rawValue: "exploreTop"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "exploreTop"), object:nil)
        navShow()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var t = self.tableView
        var d = dataArray
        if tableView == self.tableViewDynamic {
            t = self.tableViewDynamic
            d = dataArrayDynamic
            let data = dataArrayDynamic[(indexPath as NSIndexPath).row] as! NSDictionary
            let type = data.stringAttributeForKey("type_of")
            if type == "1" {
                let c = t?.dequeueReusableCell(withIdentifier: "ExploreDynamicDreamCell", for: indexPath) as! ExploreDynamicDreamCell
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var d = dataArray
        let vc = DreamViewController()
        if tableView == self.tableViewDynamic {
            d = dataArrayDynamic
        }
        let data = d[(indexPath as NSIndexPath).row] as! NSDictionary
        vc.Id = data.stringAttributeForKey("dream")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var t = self.tableView
        var d = dataArray
        if tableView == self.tableViewDynamic {
            t = self.tableViewDynamic
            d = dataArrayDynamic
            let data = dataArrayDynamic[(indexPath as NSIndexPath).row] as! NSDictionary
            let type = data.stringAttributeForKey("type_of")
            if type == "1" {
                return 77
            }
        }
        return t!.getHeight(indexPath, dataArray: d)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var d = dataArray
        if tableView == self.tableViewDynamic {
            d = dataArrayDynamic
        }
        return d.count
    }
    
    @objc func exploreTop(_ noti: Notification){
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
        
        self.view.frame = CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 49)
        self.navTopView.backgroundColor = UIColor.NavColor()
        self.navTopView.setWidth(globalWidth)
        self.navHolder.setX((globalWidth - self.navHolder.frame.size.width)/2)
        self.imageSearch.setX(globalWidth - 43)
        self.imageFriend.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.onFriendClick)))
        self.imageSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.onSearchClick)))
        view.backgroundColor = UIColor.BackgroundColor()
        
        scrollView.setWidth(globalWidth)
        scrollView.contentSize = CGSize(width: globalWidth * 2, height: scrollView.frame.size.height)
        
        btnFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.onTabClick(_:))))
        btnDynamic.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.onTabClick(_:))))
        
        setupTables()
    }
    
    func switchTab(_ tab: Int) {
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
    
    @objc func onTabClick(_ sender: UIGestureRecognizer) {
        globalNumExploreBar = sender.view!.tag - 1100
        let x1 = scrollView.contentOffset.x
        let x2 = globalWidth * CGFloat(globalNumExploreBar)
        if x1 == x2 {
            self.switchTab(sender.view!.tag - 1100)
        } else {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.scrollView.setContentOffset(CGPoint(x: globalWidth * CGFloat(globalNumExploreBar), y: 0), animated: false)
                }, completion: { (Bool) -> Void in
                    self.switchTab(sender.view!.tag - 1100)
            }) 
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let x = scrollView.contentOffset.x
            self.btnFollow.setTabAlpha(x, index: 0)
            self.btnDynamic.setTabAlpha(x, index: 1)
        }
    }
    
    @objc func onFriendClick() {
        self.navigationController?.pushViewController(FindViewController(), animated: true)
    }
    
    @objc func onSearchClick() {
        self.performSegue(withIdentifier: "toSearch", sender: nil)
    }
    
    fileprivate func _setupScrolltoTop(_ tab: Int) {
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
    func setTabAlpha(_ x: CGFloat, index: CGFloat) {
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
