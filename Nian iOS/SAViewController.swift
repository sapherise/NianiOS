//
//  SAViewController.swift
//  Nian iOS
//
//  Created by Sa on 15/7/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class SAViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加导航栏
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        self.viewBack()
        
        // 设置背景为白色
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    func _setTitle(content: String) {
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = content
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    func setBarButton(content: String, actionGesture: Selector) {
        let rightLabel = UILabel(frame: CGRectMake(globalWidth - 60, 20, 60, 44))
        rightLabel.textColor = UIColor.whiteColor()
        rightLabel.text = content
        rightLabel.font = UIFont.systemFontOfSize(14)
        rightLabel.textAlignment = NSTextAlignment.Right
        rightLabel.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: actionGesture)
        rightLabel.addGestureRecognizer(tap)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel)]
    }
}