//
//  ProductListCell.swift
//  Nian iOS
//
//  Created by Sa on 16/2/28.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ProductListCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    var data: NSDictionary!
    
    func setup() {
        labelTitle.text = data.stringAttributeForKey("name")
//        let url = data.stringAttributeForKey("image")
        let color = data.stringAttributeForKey("background_color")
        let price = data.stringAttributeForKey("cost")
        let banner = data.stringAttributeForKey("banner")
        imageView.setImage(banner)
        imageView.backgroundColor = UIColor.colorWithHex(color)
        labelTitle.textColor = UIColor.MainColor()
        labelContent.textColor = UIColor.Accomplish()
        labelContent.text = "\(price) 念币"
    }
    
    // todo: 其他用户点进成员列表，却有邀请按钮
}