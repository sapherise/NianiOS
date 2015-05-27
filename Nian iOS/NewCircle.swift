//
//  NewCircle.swift
//  Nian iOS
//
//  Created by Sa on 15/5/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class NewCircleController: UIViewController, UIScrollViewDelegate {
    
    var navView: UIView!
    var tableViewStep: UITableView!
    var tableViewBBS: UITableView!
    var tableViewChat: UITableView!
    var scrollView: UIScrollView!
    var tab: Int = -1
    var viewMenu: SAMenu!
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews() {
        self.viewBack()
        self.view.backgroundColor = UIColor.whiteColor()
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        scrollView = UIScrollView(frame: CGRectMake(0, 104, globalWidth, globalHeight - 104))
        scrollView.backgroundColor = UIColor.greenColor()
        scrollView.contentSize.width = globalWidth * 3
        scrollView.delegate = self
        scrollView.pagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        tableViewStep = UITableView()
        tableViewBBS = UITableView()
        tableViewChat = UITableView()
        
        scrollView.addSubview(tableViewStep)
        scrollView.addSubview(tableViewBBS)
        scrollView.addSubview(tableViewChat)
        tableViewStep.frame = CGRectMake(0, 0, globalWidth, globalHeight - 104)
        tableViewBBS.frame = CGRectMake(globalWidth, 0, globalWidth, globalHeight - 104)
        tableViewChat.frame = CGRectMake(globalWidth * 2, 0, globalWidth, globalHeight - 104)
        tableViewStep.backgroundColor = SeaColor
        tableViewBBS.backgroundColor = lineColor
        tableViewChat.backgroundColor = GoldColor
        
        viewMenu = (NSBundle.mainBundle().loadNibNamed("SAMenu", owner: self, options: nil) as NSArray).objectAtIndex(0) as! SAMenu
        viewMenu.frame.origin.y = 64
        viewMenu.arr = ["进展", "话题", "聊天"]
        viewMenu.viewLeft.backgroundColor = UIColor.redColor()
        viewMenu.viewRight.backgroundColor = UIColor.yellowColor()
        viewMenu.viewMiddle.backgroundColor = UIColor.blueColor()
        viewMenu.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMenuClick:"))
        self.view.addSubview(viewMenu)
    }
    
    func onMenuClick(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            println(tag)
            viewMenu.switchTab(tag)
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        var x = scrollView.contentOffset.x
        var page = Int(x / globalWidth)
        switchTab(page)
    }
    
    func switchTab(tab: Int) {
        scrollView.setContentOffset(CGPointMake(globalWidth * CGFloat(tab), 0), animated: true)
    }
}