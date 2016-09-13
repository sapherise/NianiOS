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
    var image: AnyObject!
    
    func setup() {
        imageView.backgroundColor = UIColor.GreyColor1()
        
        if let a = image as? UIImage {
            imageView.image = a
        } else if let a = image as? ALAsset {
            imageView.image = UIImage(cgImage: a.thumbnail().takeUnretainedValue())
            go {
                let img = UIImage(cgImage: a.aspectRatioThumbnail().takeUnretainedValue())
                let imgLarge = resizedImage(img, newWidth: self.width() * globalScale)
                back {
                    self.imageView.image = imgLarge
                }
            }
        }
    }
}
