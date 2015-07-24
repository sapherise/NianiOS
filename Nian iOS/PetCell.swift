//
//  PetCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 7/21/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

// MARK: - pet cell
class petCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    
    var info: NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // todo: 设置 cell
        self.selectionStyle = .None
    }
    
    func _layoutSubviews() {
        // 刷新界面
        let imgF = self.info?.stringAttributeForKey("image")
        var id = self.info?.stringAttributeForKey("id")
        var level = self.info?.stringAttributeForKey("level")
        var name = self.info?.stringAttributeForKey("name")
        var owned = self.info?.stringAttributeForKey("owned")
        
        var imgURLString = "http://img.nian.so/pets/\(imgF!)!d"
        
        self.imgView?.setImageWithBlock(imgURLString, placeHolder: UIColor.clearColor(), bool: false, ignore: false) {
            image in
            if owned == "0" {
                self.imgView?.image = image.convertToGrayscale()
            } else {
                self.imgView?.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        self.imgView?.cancelImageRequestOperation()
        self.imgView!.image = nil
    }
}
