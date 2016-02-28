//
//  RechargeCell.swift
//  Nian iOS
//
//  Created by Sa on 16/2/28.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class RechargeCell: UITableViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var btnMain: UIButton!
    var data: NSDictionary!
    
    /* 得知这个 cell 是在 indexPath 中的第几个 */
    var num = -1
    var numMax = 0
    
    let padding: CGFloat = 16
    let heightCell: CGFloat = 72
    
    func setup() {
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        viewLine.setHeight(globalHalf)
        viewLine.setY(heightCell - globalHalf - globalHalf/2)
        viewLine.backgroundColor = UIColor.LineColor()
        viewLine.setWidth(globalWidth - padding * 2)
        
        let title = data.stringAttributeForKey("title")
        let price = data.stringAttributeForKey("price")
        labelTitle.text = title
        labelTitle.textColor = UIColor.MainColor()
        
        btnMain.setX(globalWidth - btnMain.width() - padding)
        btnMain.setTitle("¥ \(price)", forState: UIControlState())
        imageHead.image = UIImage(named: "recharge")
        
        if num == 0 {
            let v = UIView(frame: CGRectMake(0, 0, globalWidth, globalHalf))
            v.backgroundColor = UIColor.LineColor()
            v.setY(globalHalf/2)
            self.contentView.addSubview(v)
        } else if num == numMax - 1 {
            viewLine.setX(0)
            viewLine.setWidth(globalWidth)
        }
    }
}