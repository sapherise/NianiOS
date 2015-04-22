//
//  ExploreNewHotCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/22/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit
import QuartzCore   

class ExploreNewHotCell: MKTableViewCell {

    @IBOutlet weak var contView: UIView!
    @IBOutlet weak var imageHead: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var footImage: UIView!
    
    var largeImageURL: String = ""
    var data: NSDictionary?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .None
//        self.setWidth(globalWidth)
        self.contView.setWidth(globalWidth)
        
        self.footImage.setX(72)
        self.footImage.setWidth(globalWidth - 72)
        
        self.followButton.setX(globalWidth - 73)
        self.followButton.layer.cornerRadius = 12.0
        self.followButton.layer.masksToBounds = true
        self.followButton.layer.borderColor = SeaColor.CGColor
        self.followButton.layer.borderWidth = 1
        self.followButton.setTitleColor(SeaColor, forState: .Normal)
        self.followButton.backgroundColor = .whiteColor()
    }

    func bindData(data: ExploreNewHot.Data, tableview: UITableView) {
        labelTitle.text = data.title
        labelContent.text = data.content
        
        imageHead.setImage(V.urlDreamImage(data.img, tag: .Dream), placeHolder: IconColor)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        imageHead.image = nil   
    }
    
}
