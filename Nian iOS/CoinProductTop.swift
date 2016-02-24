//
//  CoinProductTop.swift
//  Nian iOS
//
//  Created by Sa on 16/2/24.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class CoinProductTop: UITableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var btn: UIButton!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewHolder: UIView!
    
    var heightCell: CGFloat = 261
    
    func setup() {
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        viewHolder.setX(globalWidth/2 - 160)
        viewLine.setHeight(globalHalf)
        viewLine.setWidth(globalWidth)
        viewLine.setY(heightCell - globalHalf - globalHalf/2)
        viewLine.backgroundColor = UIColor.LineColor()
        
        let coin = Cookies.get("coin") as? String
        labelContent.text = coin
    }
}