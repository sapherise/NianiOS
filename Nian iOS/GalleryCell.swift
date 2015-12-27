//
//  GalleryCell.swift
//  Nian iOS
//
//  Created by Sa on 15/12/27.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class GalleryCell: UICollectionViewCell {
    var isImageSelected = false
    let padding: CGFloat = 8
    var reuseCount: Int = 0
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = SeaColor
        imageView.backgroundColor = UIColor.yellowColor()
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTap:"))
        imageView.layer.borderColor = SeaColor.CGColor
    }
    
    func onTap(sender: UIGestureRecognizer) {
        /* 如果图片被选中
        ** 再次点击时，取消选中状态
        */
        if isImageSelected {
            imageView.layer.borderWidth = 0
        } else {
            imageView.layer.borderWidth = 8
        }
        isImageSelected = !isImageSelected
    }
}