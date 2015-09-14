//
//  ExploreNewHotCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/22/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit
import QuartzCore

/**
*  @author Bob Wei, 15-09-14 13:09:53
*
*  @brief  ExploreNewHotCell datasource
*/
@objc protocol ENHCDataSource {
    optional func enhcDataCell(indexPath: NSIndexPath, contentHeight: CGFloat, titleHeight: CGFloat)
    optional func enhcDataCell(indexPath: NSIndexPath, content: String, title: String)
}

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
    
    var content: String = ""
    var contentHeight: CGFloat?
    var title: String = ""
    var titleHeight: CGFloat?
    
    var cellDataSource: ENHCDataSource?
    var indexPath: NSIndexPath?
    
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

    func _layoutSubviews() {
//        super.layoutSubviews()
        let title = self.data.stringAttributeForKey("title")
        let img = self.data.stringAttributeForKey("image")
        let likes = self.data.stringAttributeForKey("likes")
        let content = self.data.stringAttributeForKey("content")
        let steps = self.data.stringAttributeForKey("steps")
  
        self.labelTag.text = "热门"

        self.labelTag.setRadius(4, isTop: false)
        
        if let value = self.data["titleHeight"] as? NSNumber {
            #if CGFLOAT_IS_DOUBLE
            titleHeight = CGFloat(value.doubleValue)
            #else
            titleHeight = CGFloat(value.floatValue)
            #endif
        } else {
            titleHeight = title.stringHeightBoldWith(18, width: 248)
        }
        
        self.labelTitle.text = title
        self.labelContent.text = content
        self.labelSupport.text = SAThousand(likes)  //点赞
        self.labelStep.text = SAThousand(steps)
        
        if let value = self.data["contentHeight"] as? NSNumber {
            #if CGFLOAT_IS_DOUBLE
            contentHeight = CGFloat(value.doubleValue)
            #else
            contentHeight = CGFloat(value.floatValue)
            #endif
        } else {
            contentHeight = content.stringHeightWith(12, width: 248)
        }
        
        // 43 = "\n\n".stringHeightWith(12, width: 248)
        self.labelContent.setHeight(contentHeight! > 43 ? 43 : contentHeight!)
        self.labelTitle.setHeight(titleHeight!)
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
        viewLine.setHeightHalf()
    }
    
    class func cellHeightByData(data:NSDictionary)->CGFloat {
        let title = SADecode(SADecode(data.stringAttributeForKey("title")))
        let content = SADecode(SADecode(data.stringAttributeForKey("content")))
        let titleHeight = title.stringHeightBoldWith(18, width: 240)
        if content == "" {
            return 204.5 + titleHeight - 8
        }
        
        let heightFit = content.stringHeightWith(12, width: 248)
//        let heightMax = "\n\n".stringHeightWith(12, width: 248)
//        let heightContent = heightFit > heightMax ? heightMax : heightFit
        let heightContent = heightFit > 43 ? 43 : heightFit
        return heightContent + 204.5 + titleHeight
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        title = SADecode(SADecode(data.stringAttributeForKey("title")))
        content = SADecode(SADecode(data.stringAttributeForKey("content")))
        
        titleHeight = title.stringHeightBoldWith(18, width: 240)
        
        if content == "" {
            return CGSizeMake(size.width, 204.5 + titleHeight! - 8)
        }
        
        contentHeight = content.stringHeightWith(12, width: 248)
        
        // 43 = "\n\n".stringHeightWith(12, width: 248)
        contentHeight = contentHeight > 43.0 ? 43.0 : contentHeight
        
        self.cellDataSource?.enhcDataCell?(indexPath!, contentHeight: contentHeight!, titleHeight: titleHeight!)
        self.cellDataSource?.enhcDataCell?(indexPath!, content: content, title: title)
        
        return CGSizeMake(size.width, 204.5 + titleHeight! + contentHeight!)
    }
    
    
    
}














