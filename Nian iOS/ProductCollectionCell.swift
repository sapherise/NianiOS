//
//  ProductCollectionCell.swift
//  Nian iOS
//
//  Created by Sa on 16/2/25.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ProductCollectionCell: UICollectionViewCell {
    var data: NSDictionary!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    
    func setup() {
        let title = data.stringAttributeForKey("title")
        let content = data.stringAttributeForKey("content")
        let image = data.stringAttributeForKey("image")
        imageHead.image = UIImage(named: image)
        labelTitle.text = title
        labelContent.text = content
        labelTitle.textColor = UIColor.MainColor()
        labelContent.textColor = UIColor.secAuxiliaryColor()
    }
}