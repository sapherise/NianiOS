//
//  LSYAlbumPickerView.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/5.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import UIKit
//MARK:- LSYAlbumPickerCell
class LSYAlbumPickerCell: UICollectionViewCell {
    var padding: CGFloat = 0
    var representedAssetIdentifier = ""
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = UIColor.HighlightColor().cgColor
    }
    
    override func prepareForReuse() {
//        self.imageView.image = nil
    }
}
