//
//  ProductEmojiCollectionCell.swift
//  Nian iOS
//
//  Created by Sa on 16/2/29.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ProductEmojiCollectionCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var data: NSDictionary!
    var num = 0
    func setup() {
        let image = data.stringAttributeForKey("image")
        imageView.setImage("\(image)!dream")
        imageView.tag = num
    }
}