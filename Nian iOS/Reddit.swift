//
//  Reddit.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
class RedditViewController: UIViewController {
    var labelLeft: UILabel!
    var labelRight: UILabel!
    var scrollView: UIScrollView!
    var tableViewLeft: UITableView!
    var tableViewRight: UITableView!
    var current: Int = 1
    var pageLeft: Int = 1
    var pageRight: Int = 1
    var dataArrayLeft = NSMutableArray()
    var dataArrayRight = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTable()
        switchTab(current)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reddit", name: "reddit", object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reddit", object:nil)
    }
    
    func reddit() {
        if current == 0 {
            tableViewLeft.headerBeginRefreshing()
        } else {
            tableViewRight.headerBeginRefreshing()
        }
    }
    
    func setupViews() {
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        labelLeft = UILabel()
        labelLeft.setupLabel(globalWidth/2 - 64, content: "关注")
        labelRight = UILabel()
        labelRight.setupLabel(globalWidth/2, content: "所有")
        self.view.addSubview(labelLeft)
        self.view.addSubview(labelRight)
        
        labelLeft.userInteractionEnabled = true
        labelRight.userInteractionEnabled = true
        labelLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLeft"))
        labelRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onRight"))
        
        scrollView = UIScrollView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64 - 49))
        scrollView.contentSize = CGSizeMake(globalWidth*2, globalHeight - 64 - 49)
        scrollView.pagingEnabled = true
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        tableViewLeft = UITableView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64 - 49))
        tableViewRight = UITableView(frame: CGRectMake(globalWidth, 0, globalWidth, globalHeight - 64 - 49))
        scrollView.addSubview(tableViewLeft)
        scrollView.addSubview(tableViewRight)
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