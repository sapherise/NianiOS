//
//  LSYAlbumPickerView.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/5.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary
//MARK:- LSYAlbumPickerCell
class LSYAlbumPickerCell: UICollectionViewCell {
    var model: LSYAlbumModel!
    var padding: CGFloat = 0
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.layer.borderColor = SeaColor.CGColor
    }
    
    func setup() {
        let width = globalScale * (globalWidth - padding * 2) / 3
        /* 先以模糊的图片显示
        ** 之后在子线程裁剪高清图片
        */
        imageView.image = UIImage(CGImage: model.asset.thumbnail().takeUnretainedValue())
        go {
            let img = UIImage(CGImage: self.model.asset.aspectRatioThumbnail().takeUnretainedValue())
            let imgLarge = resizedImage(img, newWidth: width)
            back {
                self.imageView.image = imgLarge
            }
        }
    }
    
    func setupIsSelect(){
        imageView.layer.borderWidth = self.selected ? 8 : 0
    }
}