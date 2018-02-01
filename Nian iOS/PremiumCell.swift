//
//  PremiumCell.swift
//  NianiOS
//
//  Created by Sa on 16/4/7.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class PremiumCell: UITableViewCell {
    var data: NSDictionary!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewHolder: UIView!
    
    func setup() {
        self.selectionStyle = .none
        let title = data.stringAttributeForKey("title")
        let content = data.stringAttributeForKey("content")
        let image = data.stringAttributeForKey("image")
        imageHead.image = UIImage(named: image)
        labelTitle.text = title
        labelContent.text = content
        labelTitle.textColor = UIColor.MainColor()
        labelContent.textColor = UIColor.secAuxiliaryColor()
        viewHolder.setX(globalWidth/2 - 160)
    }
}
