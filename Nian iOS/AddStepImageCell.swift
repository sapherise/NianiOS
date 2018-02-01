//
//  AddStepImageCell.swift
//  Nian iOS
//
//  Created by Sa on 16/1/2.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class AddStepImageCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var image: AnyObject!
    
    func setup() {
        imageView.backgroundColor = UIColor.GreyColor1()
        
        if let a = image as? UIImage {
            imageView.image = a
        }
    }
}
