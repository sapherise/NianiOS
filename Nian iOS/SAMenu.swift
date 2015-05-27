//
//  SAMenu.swift
//  Nian iOS
//
//  Created by Sa on 15/5/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class SAMenu: UIView {
    @IBOutlet var viewLeft: UILabel!
    @IBOutlet var viewMiddle: UILabel!
    @IBOutlet var viewRight: UILabel!
    @IBOutlet var viewLine: UIView!
    var arr = ["", ""]
    
    override func awakeFromNib() {
        self.setX(globalWidth/2 - 160)
        viewLeft.tag = 0
        viewMiddle.tag = 1
        viewRight.tag = 2
    }
    
    override func layoutSubviews() {
        if arr.count == 2 {
            viewRight.hidden = true
            viewLeft.setX(320/2 - 86)
            viewMiddle.setX(320/2)
            viewLeft.text = arr[0]
            viewMiddle.text = arr[1]
        } else if arr.count == 3 {
            viewRight.hidden = false
            viewLeft.text = arr[0]
            viewMiddle.text = arr[1]
            viewRight.text = arr[2]
        }
    }
    
    func switchTab(tab: Int) {
        let arrView = [viewLeft, viewMiddle, viewRight]
        viewLeft.textColor = greyColor
        viewMiddle.textColor = greyColor
        viewRight.textColor = greyColor
        arrView[tab].textColor = SeaColor
    }
}