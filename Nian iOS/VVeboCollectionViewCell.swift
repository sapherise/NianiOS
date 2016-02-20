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
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        }
    }
    
    func onImage() {
//        let path = image?.stringAttributeForKey("path")
//        let w = CGFloat((image!.stringAttributeForKey("width") as NSString).floatValue)
//        let h = CGFloat((image!.stringAttributeForKey("height") as NSString).floatValue)
//        imageView.showImage("http://img.nian.so/step/\(path!)!200x", newWidth: w, newHeight: h)
        // todo: 上面的是对的
        imageView.open(images, index: index, exten: "!200x")
    }
}

