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
    @IBOutlet var labelFollow: UILabel!
    
    var data :NSDictionary!
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.setWidth(globalWidth)
        self.labelTag.setX(globalWidth - labelFollow.width() - 16)
        self.viewLine.setWidth(globalWidth - 32)
        self.viewHolder.setX(globalWidth/2-160)
        viewLine.setHeight(globalHalf)
        labelFollow.isHidden = true
    }
    
    func _layoutSubviews() {
        if data != nil {
            let title = self.data.stringAttributeForKey("title")
            let img = self.data.stringAttributeForKey("image")
            let likes = self.data.stringAttributeForKey("likes")
            let content = self.data.stringAttributeForKey("content")
            let steps = self.data.stringAttributeForKey("steps")
            
            if let row = (indexPath as NSIndexPath?)?.row {
                self.labelTag.text = "#\(row + 1)"
            }
            
            self.labelTag.setRadius(4, isTop: false)
            self.labelFollow.setRadius(4, isTop: false)
            
            let heightTitle = data.object(forKey: "heightTitle") as! CGFloat
            let heightContent = data.object(forKey: "heightContent") as! CGFloat
            
            self.labelTitle.text = title
            self.labelContent.text = content
            self.labelSupport.text = SAThousand(likes)  //点赞
            self.labelStep.text = SAThousand(steps)
            
            
            self.labelContent.setHeight(heightContent)
            self.labelTitle.setHeight(heightTitle)
            self.labelContent.setY(self.labelTitle.bottom() + 8)
            var bottom = self.labelContent.bottom()
            if content == "" {
                bottom = self.labelTitle.bottom()
            }
            
            self.viewLeft.setY(bottom + 16)
            self.viewRight.setY(bottom + 16)
            self.viewHolder.setHeight(self.viewLeft.bottom() + 33)
            if img != "" {
                self.imageHead.setImage("http://img.nian.so/dream/\(img)!dream")
            } else {
                self.imageHead.image = UIImage(named: "drop")
                self.imageHead.contentMode = .center
                self.imageHead.backgroundColor = UIColor.GreyColor1()
            }
            self.viewLine.setY(self.viewLeft.bottom() + 32)
        }
        
        labelFollow.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ExploreNewHotCell.onFollow)))
    }
    
    @objc func onFollow() {
        labelFollow.isHidden = true
        let id = data.stringAttributeForKey("id")
        Api.getFollowDream(id) { json in }
    }
    
    class func cellHeight(_ data: NSDictionary) -> NSArray {
        let content = data.stringAttributeForKey("content").decode()
        let title = data.stringAttributeForKey("title").decode()
        let hTitle = title.stringHeightBoldWith(18, width: 248)
        var hContent = content.stringHeightWith(12, width: 248)
        hContent = min(hContent, 43)
        var height = hContent + 204.5 + hTitle
        if content == "" {
            height = hTitle + 204.5 - 8
        }
        return [height, hContent, hTitle, content, title]
    }
    
    override func prepareForReuse() {
        imageHead.image = nil
        imageHead.cancelImageRequestOperation()
    }
}









