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
    var id: String?
    var level: String?
    var name: String?
    var property: String?
    var imgPath: String?
    var getAtDate: String?
    var updateAtDate: String?
    
    var isFirstLoad: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // todo: 设置 cell
        self.selectionStyle = .None
    }
    
    func _layoutSubviews() {
        // 刷新界面
        let imgF = self.info?.stringAttributeForKey("image")
        id = self.info?.stringAttributeForKey("id")
        level = self.info?.stringAttributeForKey("level")
        name = self.info?.stringAttributeForKey("name")
        property = self.info?.stringAttributeForKey("property")
        getAtDate = self.info?.stringAttributeForKey("owned")
        updateAtDate = self.info?.stringAttributeForKey("updated_at")
        
        var imgURLString = "http://img.nian.so/pets/"
        
        if globalWidth > 375 {
            imgURLString += imgF!
        } else {
            imgURLString += imgF! + "!d"
        }
        
        self.imgView?.setImageWithBlock(imgURLString, placeHolder: IconColor, bool: false, ignore: false) {
            image in
            if self.getAtDate == "0" {
                self.imgView?.image = image.convertToGrayscale()
            } else {
                self.imgView?.image = image
            }
        }
        self.imgView?.backgroundColor = UIColor.clearColor()
        
        if isFirstLoad {
            SQLPetContent(id!, level!, name!, property!, imgF!, getAtDate!, updateAtDate!) {
            }
            
            isFirstLoad = false 
        }
    }
    
    override func prepareForReuse() {
        self.imgView?.cancelImageRequestOperation()
        self.imgView!.image = nil
    }
}
