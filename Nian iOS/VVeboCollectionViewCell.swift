//
//  VVeboCollecionViewCell.swift
//  Nian iOS
//
//  Created by Sa on 16/1/4.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class VVeboCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    var image: NSDictionary?
    var index: Int!
    var images: NSArray!
    
    func setup() {
        if image != nil {
            let path = image!.stringAttributeForKey("path")
            imageView.setImage("http://img.nian.so/step/\(path)!200x")
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(VVeboCollectionViewCell.onImage)))
        }
    }
    
    @objc func onImage() {
        imageView.open(images, index: index, exten: "!200x")
    }
}

