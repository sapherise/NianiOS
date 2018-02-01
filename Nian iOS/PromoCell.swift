//
//  PromoCell.swift
//  Nian iOS
//
//  Created by Sa on 16/2/29.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class PromoCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data: NSDictionary!
    
    func setup() {
        labelTitle.textColor = UIColor.MainColor()
        labelTitle.text = data.stringAttributeForKey("title").decode()
        let path = data.stringAttributeForKey("image")
        imageView.setImage("http://img.nian.so/dream/\(path)!dream")
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
    }
}