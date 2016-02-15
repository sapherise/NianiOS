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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reddit:", name: "reddit", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
    }
    
    func reddit(sender: NSNotification) {
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
        navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = UIColor.NavColor()
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        
        /* 添加标题 */
        let labelNav = UILabel()
        labelNav.frame = CGRectMake(0, 20, globalWidth, 44)
        labelNav.textColor = UIColor.whiteColor()
        labelNav.font = UIFont.systemFontOfSize(17)
        labelNav.text = "热门"
        labelNav.textAlignment = NSTextAlignment.Center
        navView.addSubview(labelNav)
    }
}

extension UILabel {
    // 创建导航栏按钮
    func setupLabel(x: CGFloat, content: String) {
        self.frame = CGRectMake(x, 20, 64, 44)
        self.text = content
        self.textColor = UIColor.whiteColor()
        self.textAlignment = NSTextAlignment.Center
        self.font = UIFont.systemFontOfSize(14)
    }
}

class NiceAc: UIActivityIndicatorView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.color = UIColor.whiteColor()
        self.transform = CGAffineTransformMakeScale(0.8, 0.8)
//        self.startAnimating()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}