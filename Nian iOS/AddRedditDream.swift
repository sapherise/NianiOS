//
//  AddRedditDream.swift
//  Nian iOS
//
//  Created by Sa on 15/9/7.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class AddRedditDream: UIView {
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    var title = ""
    var content = ""
    var image = ""
    
    override func awakeFromNib() {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageHead.setImage(image, placeHolder: IconColor)
        labelTitle.text = title
        labelContent.text = content
    }
}