//
//  Lock.swift
//  Nian iOS
//
//  Created by Sa on 16/1/6.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Lock: SAViewController {
    let padding: CGFloat = 12
    let size_width: CGFloat = 50
    let size_y: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        _setTitle("设置密码")
        self.view.backgroundColor = BarColor
        
        /* 添加四个视图 */
        var x = (globalWidth - size_width * 4 - padding * 3) / 2
        for i in 0...3 {
            let v = LockView()
            v.frame.origin = CGPointMake(x, size_y + 64)
            x += size_width + padding
            self.view.addSubview(v)
            if i < 3 {
                v.isInputed = true
            }
        }
        
        /* 添加引导文案 */
        let label = UILabel(frame: CGRectMake(globalWidth/2 - 80, size_y + 64 + size_width + 20, 160, 50))
        label.text = "创造一个可爱的密码"
        label.textAlignment = .Center
        label.numberOfLines = 0
        label.textColor = UIColor.b3()
        label.font = UIFont.systemFontOfSize(13)
        self.view.addSubview(label)
    }
}

class LockView: UIView {
    var isInputed = false
    var point: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.blackColor()
        self.frame.size = CGSizeMake(50, 50)
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        point = UIView()
        point.frame.size = CGSizeMake(12, 12)
        point.center = self.center
        point.backgroundColor = UIColor.b3()
        point.layer.masksToBounds = true
        point.layer.cornerRadius = 6
        self.addSubview(point)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isInputed {
            point.hidden = false
        } else {
            point.hidden = true
        }
    }
}