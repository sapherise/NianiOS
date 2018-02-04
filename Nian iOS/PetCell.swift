//
//  PetCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 7/21/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

// MARK: - pet cell
class PetCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    
    var info: NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func _layoutSubviews() {
        // 刷新界面
        let imgF = self.info?.stringAttributeForKey("image")
        let owned = self.info?.stringAttributeForKey("owned")
        if owned == "0" {
            let imgGrey = SAReplace(imgF!, before: ".png", after: "@Grey.png")
            self.imgView.setPet("http://img.nian.so/pets/\(imgGrey)!d")
        } else {
            self.imgView.setPet("http://img.nian.so/pets/\(imgF!)!d")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imgView?.cancelImageRequestOperation()
        self.imgView?.image = nil
    }
}
