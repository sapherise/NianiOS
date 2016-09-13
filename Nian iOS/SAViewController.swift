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
    
    fileprivate var _containView: UIView?
    var navView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* 添加导航栏 */
        navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        navView.isUserInteractionEnabled = true
        self.view.addSubview(navView)
        self.viewBack()
        
        /* 设置背景为白色 */
        self.view.backgroundColor = UIColor.white
    }
    
    /* 添加导航栏标题 */
    func _setTitle(_ content: String) {
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        titleLabel.textColor = UIColor.white
        titleLabel.text = content
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    /* 添加导航栏按钮文案 */
    func setBarButton(_ content: String, actionGesture: Selector) {
        let rightLabel = UILabel(frame: CGRect(x: globalWidth - 60, y: 20, width: 60, height: 44))
        rightLabel.textColor = UIColor.white
        rightLabel.text = content
        rightLabel.font = UIFont.systemFont(ofSize: 14)
        rightLabel.textAlignment = NSTextAlignment.right
        rightLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: actionGesture)
        rightLabel.addGestureRecognizer(tap)
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel)]
    }
    
    /* 添加导航栏按钮图片 */
    func setBarButtonImage(_ image: String, actionGesture: Selector) {
        let rightButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: actionGesture)
        rightButton.image = UIImage(named: image)
        self.navigationItem.rightBarButtonItems = [rightButton];
    }
    
    /* 添加导航栏加载状态 */
    func setBarButtonLoading() {
        self.navigationItem.rightBarButtonItems = buttonArray()
    }
    
    /* 页面载入状态 */
    func startAnimating() {
        _containView = UIView(frame: CGRect(x: (globalWidth - 50)/2, y: (globalHeight - 50)/2, width: 50, height: 50))
        _containView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        _containView!.layer.cornerRadius = 4.0
        _containView!.layer.masksToBounds = true
        let _activity = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        _activity.color = UIColor.white
        _activity.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        _activity.startAnimating()
        _containView!.addSubview(_activity)
        self.view.addSubview(_containView!)
    }
    
    /* 页面结束载入状态 */
    func stopAnimating() {
        _containView?.removeFromSuperview()
    }
    
    
    
    
    
    
    
    
}


























