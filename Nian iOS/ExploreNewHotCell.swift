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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.labelTag.setX(globalWidth-72)
        self.viewLine.setWidth(globalWidth)
        self.viewHolder.setX(globalWidth/2-160)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        var id = self.data.objectForKey("id") as! String
        var title = self.data.objectForKey("title") as! String
        var img = self.data.objectForKey("img") as! String
        var tag = self.data.objectForKey("type") as! String
        var likes = self.data.objectForKey("likes") as! String
        var content = self.data.objectForKey("content") as! String
        var steps = self.data.objectForKey("steps") as! String
  
        switch tag.toInt()! {
        case 0:
            self.labelTag.text = "最近更新"
        case 1:
            self.labelTag.text = "榜单"
        case 2:
            self.labelTag.text = "小编精选"
        case 3:
            self.labelTag.text = "热门"
        default:
            break
        }
        
        var height = content.stringHeightWith(13, width: 250)
        var titleHeight = title.stringHeightBoldWith(19, width: 242)
        self.labelSupport.text = likes  //点赞
        self.labelTitle.text = SADecode(title)
        self.labelStep.text = steps
        self.labelContent.text = SADecode(content)
        self.labelContent.setHeight(height)
        self.labelTitle.setHeight(titleHeight)
        self.labelContent.setY(self.labelTitle.frame.origin.y + titleHeight + 8)
        var bottom = self.labelContent.bottom()
        if content == "" {
            bottom = self.labelTitle.bottom()
        }
        self.viewLeft.setY(bottom + 15)
        self.viewRight.setY(bottom + 15)
        self.viewLine.setY(bottom + 109)
        if img != "" {
            self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        } else {
            self.imageHead.image = UIImage(named: "drop")
            self.imageHead.contentMode = .Center
            self.imageHead.backgroundColor = IconColor
        }
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        var title = data.stringAttributeForKey("title")
        var content = data.stringAttributeForKey("content")
        var titleHeight = title.stringHeightBoldWith(19, width: 242)
        if content == "" {
            return 256 + titleHeight - 31
        }
        var height = content.stringHeightWith(13, width: 250)
        return height + 264 + titleHeight - 31
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        imageHead.image = nil
    }
}
