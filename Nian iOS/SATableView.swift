//
//  SATableView.swift
//  Nian iOS
//
//  Created by Sa on 15/10/14.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

protocol SATableViewDelegate {
    func onTouch()
}

class VVeboTableView: UITableView {
    var touchDelegate: SATableViewDelegate?
        
//        - (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
//    self = [super initWithFrame:frame style:style];
//    if (self) {
//    self.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.dataSource = self;
//    self.delegate = self;
//    datas = [[NSMutableArray alloc] init];
//    needLoadArr = [[NSMutableArray alloc] init];
//    
//    [self loadData];
//    [self reloadData];
//    }
//    return self;
//    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.separatorStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 用户触摸时第一时间加载内容
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        touchDelegate?.onTouch()
        return super.hitTest(point, withEvent: event)
    }
    
    
    
    
}
