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
//    var data: ExploreNewHot.Data!
    var uid: String = ""
    
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
        labelTitle.text = SADecode(data.title)
        self.uid = data.id
        
        switch data.type.toInt()! {
        case 0:
            labelContent.text = "最近更新"
        case 1:
            labelContent.text = "榜单第 \(data.content) 位"
        case 2:
            labelContent.text = SADecode(data.content)
        case 3:
            labelContent.text = "热门"
            labelContent.textColor = GoldColor
        default:
            break
        }
        
        imageHead.setImage(V.urlDreamImage(data.img, tag: .Dream), placeHolder: IconColor)
        
        if data.follow == "0" {
            self.followButton.tag = 1000
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
        } else {
            self.followButton.tag = 2000
            self.followButton.layer.borderWidth = 0
            self.followButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            self.followButton.backgroundColor = SeaColor
            self.followButton.setTitle("关注中", forState: .Normal)
        }
    }
    
    @IBAction func onFollowClick(sender: UIButton) {
        var tag = sender.tag
        if tag == 1000 {     //没有关注
            sender.tag = 2000
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(self.uid, follow: "1", callback: {
                    String in
                    if String == "fo" {
                    } else {
                    }
                })
            })
        }else if tag == 2000 {   //正在关注
            sender.tag = 1000
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                Api.postFollowDream(self.uid, follow: "0", callback: {
                    String in
                    if String == "" {
                    } else {
                    }
                })
            })
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        imageHead.image = nil
        self.labelContent.textColor = UIColor(red: 128/255, green: 128/255, blue: 128/255, alpha: 1)
    }
    
}
