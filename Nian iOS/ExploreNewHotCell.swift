//
//  ExploreNewHotCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/22/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit
import QuartzCore   

class ExploreNewHotCell: UITableViewCell {

    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelTag: UILabel! //标签
    @IBOutlet var labelSupport: UILabel!  //点赞
    @IBOutlet var labelStep: UILabel!
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var viewHolder: UIView!
    
    var data :NSDictionary!
    var largeImageURL: String = ""
    var uid: String = ""
    var tmpLineHeight: CGFloat = 0.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.labelTag.setX(globalWidth-66)
        self.viewLine.setWidth(globalWidth - 32)
        self.viewLine.setHeight(0.5)
        self.viewHolder.setX(globalWidth/2-160)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = SADecode(SADecode(self.data.stringAttributeForKey("title")))
        var img = self.data.stringAttributeForKey("img")
        var tag = self.data.stringAttributeForKey("type")
        var likes = self.data.stringAttributeForKey("likes")
        var content = SADecode(SADecode(self.data.stringAttributeForKey("content")))
        var steps = self.data.stringAttributeForKey("steps")
  
        switch tag {
        case "0":
            self.labelTag.text = "最新"
        case "1":
            self.labelTag.text = "榜单"
        case "2":
            self.labelTag.text = "精选"
        case "3":
            self.labelTag.text = "推广"
        default:
            break
        }
        
        self.labelTag.setRadius(4, isTop: false)
        
        var titleHeight = title.stringHeightBoldWith(18, width: 240)
        self.labelTitle.text = SADecode(title)
        self.labelContent.text = content
        self.labelSupport.text = SAThousand(likes)  //点赞
        self.labelStep.text = SAThousand(steps)
        
        var heightFit = content.stringHeightWith(12, width: 248)
        var heightMax = "\n\n".stringHeightWith(12, width: 248)
        var heightContent = heightFit > heightMax ? heightMax : heightFit
        
        self.labelContent.setHeight(heightContent)
        self.labelTitle.setHeight(titleHeight)
        self.labelContent.setY(self.labelTitle.bottom() + 8)
        var bottom = self.labelContent.bottom()
        if content == "" {
            bottom = self.labelTitle.bottom()
        }
        
        self.viewLeft.setY(bottom + 16)
        self.viewRight.setY(bottom + 16)
        self.viewHolder.setHeight(self.viewLeft.bottom() + 33)
        if img != "" {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        } else {
            self.imageHead.image = UIImage(named: "drop")
            self.imageHead.contentMode = .Center
            self.imageHead.backgroundColor = IconColor
        }
        self.viewLine.setY(self.viewLeft.bottom() + 32)
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var title = SADecode(SADecode(data.stringAttributeForKey("title")))
        var content = SADecode(SADecode(data.stringAttributeForKey("content")))
        var tag = data.stringAttributeForKey("type")
        var titleHeight = title.stringHeightBoldWith(18, width: 240)
        if content == "" {
            return 204.5 + titleHeight - 8
        }
        
        var heightFit = content.stringHeightWith(12, width: 248)
        var heightMax = "\n\n".stringHeightWith(12, width: 248)
        var heightContent = heightFit > heightMax ? heightMax : heightFit
        return heightContent + 204.5 + titleHeight
    }
}
