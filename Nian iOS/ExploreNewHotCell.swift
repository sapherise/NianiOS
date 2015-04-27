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
        self.contView.setWidth(globalWidth)
        
        self.footImage.setX(72)
        self.footImage.setWidth(globalWidth - 72)
        
        self.imageHead.layer.cornerRadius = 4.0
        self.imageHead.layer.masksToBounds = true
        
        self.followButton.setX(globalWidth - 85)
        self.followButton.layer.cornerRadius = 15.0
        self.followButton.layer.masksToBounds = true
        self.followButton.layer.borderColor = SeaColor.CGColor
        self.followButton.layer.borderWidth = 1
        self.followButton.setTitleColor(SeaColor, forState: .Normal)
        self.followButton.backgroundColor = .whiteColor()
    }

    func bindData(data: ExploreNewHot.Data, tableview: UITableView) {
        labelTitle.text = data.title
        
        switch data.type.toInt()! {
        case 0:
            labelContent.text = "最近更新"
        case 1:
            labelContent.text = "榜单第 \(data.content) 位"
        case 2:
            labelContent.text = data.content
        case 3:
            labelContent.text = "热门"
            labelContent.textColor = GoldColor
        default:
            break
        }
        
        imageHead.setImage(V.urlDreamImage(data.img, tag: .Dream), placeHolder: IconColor)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        imageHead.image = nil   
    }
    
}
