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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        navHide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navShow()
    }
    
    func setupViews() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        labelLeft = UILabel()
        labelLeft.setupLabel(globalWidth/2 - 64, content: "关注")
        labelRight = UILabel()
        labelRight.setupLabel(globalWidth/2, content: "所有")
        self.view.addSubview(labelLeft)
        self.view.addSubview(labelRight)
        
        scrollView = UIScrollView(frame: CGRectMake(0, 64, globalWidth * 2, globalHeight - 64))
        scrollView.backgroundColor = UIColor.yellowColor()
        self.view.addSubview(scrollView)
        
        tableViewLeft = UITableView(frame: CGRectMake(0, 0, globalWidth, globalHeight - 64))
        tableViewLeft.backgroundColor = IconColor
        tableViewRight = UITableView(frame: CGRectMake(globalWidth, 0, globalWidth, globalHeight - 64))
        tableViewRight.backgroundColor = SeaColor
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