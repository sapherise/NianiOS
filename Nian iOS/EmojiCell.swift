//
//  EmojiCell.swift
//  Nian iOS
//
//  Created by Sa on 16/3/1.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class EmojiCell: UITableViewCell {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    var isClicked = false
    
    func setup() {
        self.selectionStyle = .none
        let code = data.stringAttributeForKey("code")
        let isClicked = data.stringAttributeForKey("isClicked")
        imageHead.setImageIgnore("http://img.nian.so/emoji/\(code)/thumb.png")
        self.backgroundColor = isClicked == "1" ? UIColor.GreyBackgroundColor() : UIColor.BackgroundColor()
        viewLine.backgroundColor = UIColor.LineColor()
        viewLine.setWidth(globalHalf)
        viewLine.setX(44 - globalHalf)
    }
}
