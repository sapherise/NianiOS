//
//  AddStepImageCell.swift
//  Nian iOS
//
//  Created by Sa on 16/1/2.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class AddStepImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var image: UIImage!
    
    func setup() {
        imageView.backgroundColor = IconColor
        imageView.image = image
//        if asset != nil {
//            let img = asset!.thumbnail().takeUnretainedValue()
//            imageView.image = UIImage(CGImage: img)
//            go {
//                let img = UIImage(CGImage: self.asset!.aspectRatioThumbnail().takeUnretainedValue())
//                let imgLarge = resizedImage(img, newWidth: self.width() * globalScale)
//                back {
//                    self.imageView.image = imgLarge
//                }
//            }
//        }
    }
}