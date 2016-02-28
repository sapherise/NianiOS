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
        self.backgroundColor = UIColor.yellowColor()
        labelTitle.text = data.stringAttributeForKey("title")
        let url = data.stringAttributeForKey("image")
        let color = data.stringAttributeForKey("color")
//        imageView.backgroundColor = UIColor.HightlightColor()
//        imageView.layer.backgroundColor = UIColor.HightlightColor().CGColor
        imageView.image = UIImage(named: url)
        imageView.backgroundColor = UIColor.clearColor()
        imageView.opaque = false
        imageView.layer.opaque = false
    }
}