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
    var data: NSDictionary!
    var isClicked = false
    
    func setup() {
        self.selectionStyle = .None
        let code = data.stringAttributeForKey("code")
        let isClicked = data.stringAttributeForKey("isClicked")
        imageHead.setImageIgnore("http://img.nian.so/emoji/\(code)/thumb.png")
        self.backgroundColor = isClicked == "1" ? UIColor.GreyBackgroundColor() : UIColor.BackgroundColor()
    }
}