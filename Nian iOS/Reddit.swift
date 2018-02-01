//
//  Reddit.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
class RedditViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var navView: UIView!
    
    var tableViewHot: UITableView!
    var tableViewEditor: UITableView!
    var tableViewNewest: UITableView!
    
    var dataArrayHot = NSMutableArray()
    var dataArrayEditor = NSMutableArray()
    var dataArrayNewest = NSMutableArray()
    
    var pageHot = 1
    var isLoadingHot = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTable()
        NotificationCenter.default.addObserver(self, selector: #selector(RedditViewController.reddit(_:)), name: NSNotification.Name(rawValue: "reddit"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
    }
    
    @objc func reddit(_ sender: Notification) {
        if dataArrayHot.count == 0 {
            tableViewHot.headerBeginRefreshing()
        } else {
            if let v = Int("\(sender.object!)") {
                if v > 0 {
                    tableViewHot.headerBeginRefreshing()
                }
            }
        }
    }
    
    func setupViews() {
        navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        navView.isUserInteractionEnabled = true
        self.view.addSubview(navView)
        
        /* 添加标题 */
        let labelNav = UILabel()
        labelNav.frame = CGRect(x: 0, y: 20, width: globalWidth, height: 44)
        labelNav.textColor = UIColor.white
        labelNav.font = UIFont.systemFont(ofSize: 17)
        labelNav.text = "热门"
        labelNav.textAlignment = NSTextAlignment.center
        navView.addSubview(labelNav)
    }
}

extension UILabel {
    // 创建导航栏按钮
    func setupLabel(_ x: CGFloat, content: String) {
        self.frame = CGRect(x: x, y: 20, width: 64, height: 44)
        self.text = content
        self.textColor = UIColor.white
        self.textAlignment = NSTextAlignment.center
        self.font = UIFont.systemFont(ofSize: 14)
    }
}

class NiceAc: UIActivityIndicatorView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = UIColor.white
        self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        self.startAnimating()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
