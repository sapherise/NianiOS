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
        labelTitle.text = data.stringAttributeForKey("title")
//        let url = data.stringAttributeForKey("image")
        let color = data.stringAttributeForKey("color")
        let price = data.stringAttributeForKey("price")
        imageView.image = UIImage(named: "banner_dragon")
        imageView.backgroundColor = UIColor.colorWithHex(color)
        labelTitle.textColor = UIColor.MainColor()
        labelContent.textColor = UIColor.Accomplish()
        labelContent.text = "\(price) 念币"
    }
}