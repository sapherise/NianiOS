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
    
    private var _containView: UIView?
    
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
    
    func setBarButtonImage(image: String, actionGesture: Selector) {
        let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: actionGesture)
        rightButton.image = UIImage(named: image)
        self.navigationItem.rightBarButtonItems = [rightButton];
    }
    
    
    func startAnimating() {
        _containView = UIView(frame: CGRectMake((globalWidth - 50)/2, (globalHeight - 50)/2, 50, 50))
        _containView!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        _containView!.layer.cornerRadius = 4.0
        _containView!.layer.masksToBounds = true
        
        
        let _activity = UIActivityIndicatorView(frame: CGRectMake(10, 10, 30, 30))
        _activity.color = UIColor.whiteColor()
        _activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        _activity.startAnimating()
        
        _containView!.addSubview(_activity)
        self.view.addSubview(_containView!)
    }
    
    
    func stopAnimating() {
        _containView?.removeFromSuperview()
    }
    
    func handleBaseJsonWithError(error: NSError?, id: AnyObject?) -> JSON? {
        
        if let _error = error {
            #if DEBUG
                logError("\(_error.localizedDescription)")
            #else
                let alertView = UIAlertView(title: "", message: "未能解析服务器数据", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            #endif
            
            return nil
        }
        
        let json = JSON(id!)
        
        if json["error"] != 0 {
            #if DEBUG
                logError("\(json["message"].string)")
            #else
                let alertView = UIAlertView(title: "", message: "未能提供正确数据", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            #endif
            
            return nil
        }
        
        return json
    }
    
    
}


























