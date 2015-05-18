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

    @IBOutlet weak var imageHead: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelContent: UILabel!
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
        self.labelTag.setX(globalWidth-72)
        self.viewLine.setWidth(globalWidth - 40)
        self.viewHolder.setX(globalWidth/2-160)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.stringAttributeForKey("id")
        var title = self.data.stringAttributeForKey("title")
        var img = self.data.stringAttributeForKey("img")
        var tag = self.data.stringAttributeForKey("type")
        var likes = self.data.stringAttributeForKey("likes")
        var content = SADecode(SADecode(self.data.stringAttributeForKey("content")))
        var steps = self.data.stringAttributeForKey("steps")
        likes = SAThousand(likes)
        steps = SAThousand(steps)
  
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
        
        var titleHeight = title.stringHeightBoldWith(19, width: 242)
        self.labelSupport.text = likes  //点赞
        self.labelTitle.text = SADecode(title)
        self.labelStep.text = steps
        self.labelContent.text = content
        
        var heightFit = content.stringHeightWith(13, width: 250)
        var heightMax = "\n\n".stringHeightWith(13, width: 250)
        var heightContent = heightFit > heightMax ? heightMax : heightFit
        
        self.labelContent.setHeight(heightContent)
        self.labelTitle.setHeight(titleHeight)
        self.labelContent.setY(self.labelTitle.bottom() + 8)
        var bottom = self.labelContent.bottom()
        if content == "" {
            bottom = self.labelTitle.bottom()
        }
        
        self.viewLeft.setY(bottom + 15)
        self.viewRight.setY(bottom + 15)
        self.viewHolder.setHeight(self.viewLeft.bottom() + 33)
        if img != "" {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        } else {
            self.imageHead.image = UIImage(named: "drop")
            self.imageHead.contentMode = .Center
            self.imageHead.backgroundColor = IconColor
        }
        
        if tag == "0" {
            self.viewLeft.hidden = true
            self.viewRight.hidden = true
            self.labelContent.hidden = true
            self.viewLine.setY(bottom + 33)
        } else {
            self.viewLeft.hidden = false
            self.viewRight.hidden = false
            self.labelContent.hidden = false
            self.viewLine.setY(self.viewLeft.bottom() + 33)
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var title = SADecode(data.stringAttributeForKey("title"))
        var content = SADecode(SADecode(data.stringAttributeForKey("content")))
        var tag = data.stringAttributeForKey("type")
        var d: CGFloat = 0
        if tag == "0" {
            d = -69
        }
        var titleHeight = title.stringHeightBoldWith(19, width: 242)
        if content == "" || tag == "0" {
            return 212 + titleHeight - 8 + d
        }
        
        var heightFit = content.stringHeightWith(13, width: 250)
        var heightMax = "\n\n".stringHeightWith(13, width: 250)
        var heightContent = heightFit > heightMax ? heightMax : heightFit
        return heightContent + 212 + titleHeight
    }
}
