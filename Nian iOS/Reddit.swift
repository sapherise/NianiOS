//
//  Reddit.swift
//  Nian iOS
//
//  Created by Sa on 15/8/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
class RedditViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, RedditDelegate, NIAlertDelegate {
    var labelLeft: UILabel!
    var labelRight: UILabel!
    var scrollView: UIScrollView!
    var tableViewLeft: UITableView!
    var tableViewRight: UITableView!
    var imageRight: UIImageView!
    var navView: UIView!
    var ac: NiceAc!
    var ni: NIAlert!
    var niResult: NIAlert!
    
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
        navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        labelLeft = UILabel()
        labelLeft.setupLabel(globalWidth/2 - 64, content: "关注")
        labelRight = UILabel()
        labelRight.setupLabel(globalWidth/2, content: "所有")
        navView.addSubview(labelLeft)
        navView.addSubview(labelRight)
        
        // 导航栏菜单
        imageRight = UIImageView(frame: CGRectMake(globalWidth - 44, 20, 44, 44))
        imageRight.image = UIImage(named: "plus")
        imageRight.userInteractionEnabled = true
        imageRight.contentMode = .Center
        let tap = UITapGestureRecognizer(target: self, action: "addReddit")
        imageRight.addGestureRecognizer(tap)
        navView.addSubview(imageRight)
        
        ac = NiceAc(frame: CGRectMake(0, 0, 20, 20))
        ac.center = imageRight.center
        navView.addSubview(ac)
        
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
    
    func addReddit() {
        imageRight.hidden = true
        ac.startAnimating()
        ac.hidden = false
        Api.getPassportStatus() { json in
            if json != nil {
                self.imageRight.hidden = false
                self.ac.hidden = true
                self.ac.stopAnimating()
                if let data = json!.objectForKey("data") as? String {
                    if data == "0" {
                        // 未获得通行证
                        self.ni = NIAlert()
                        self.ni.delegate = self
                        self.ni.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "购买钥匙", "念的广场目前处于半开放状态\n发帖需要以 10 念币购买钥匙\n（发布不适宜内容，\n可能导致钥匙被回收）", ["购买"]], forKeys: ["img", "title", "content", "buttonArray"])
                        self.ni.showWithAnimation(.flip)
                    } else if data == "1" {
                        // 已获得通行证
                        let vc = AddTopic(nibName: "AddTopic", bundle: nil)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == ni {
            let btn = niAlert.niButtonArray.firstObject as! NIButton
            btn.startAnimating()
            Api.getPassport() { json in
                if json != nil {
                    self.niResult = NIAlert()
                    self.niResult.delegate = self
                    self.niResult.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "购买成功", "你获得了一把广场钥匙！\n请尽量让自己的话题对他人有帮助", ["好"]], forKeys: ["img", "title", "content", "buttonArray"])
                    self.ni.dismissWithAnimationSwtich(self.niResult)
                }
            }
        } else {
            niResult.dismissWithAnimation(.normal)
            ni.dismissWithAnimation(.normal)
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        if niAlert == ni {
            ni.dismissWithAnimation(.normal)
        } else {
            if niResult != nil {
                niResult.dismissWithAnimation(.normal)
                ni.dismissWithAnimation(.normal)
            }
        }
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