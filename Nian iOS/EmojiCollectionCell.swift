//
//  EmojiCollectionCell.swift
//  Nian iOS
//
//  Created by Sa on 16/3/1.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class EmojiCollectionCell: UICollectionViewCell {
    @IBOutlet var imageHead: UIImageView!
    var path = ""
    var padding: CGFloat = 12
    var num = 0
    func setup() {
        if globalWidth == 320 {
            padding = 15
        }
        let w = self.frame.size.width
        let h = self.frame.size.height
        let n = min(w, h) - padding * 2
        var x = (w - h) / 2 + padding
        var y: CGFloat = padding
        if w < h {
            x = padding
            y = (h - w) / 2 + padding
        }
        imageHead.frame = CGRect(x: x, y: y, width: n, height: n)
        imageHead.setImageIgnore(path)
        imageHead.tag = num
        imageHead.isUserInteractionEnabled = true
    }
}
