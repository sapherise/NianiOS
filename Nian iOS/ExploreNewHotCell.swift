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
        labelTitle.text = data.title
//        self.data = data
        self.uid = data.id
        
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
        
//        if data.follow == "0" {
//            self.followButton.layer.borderColor = SeaColor.CGColor
//            self.followButton.layer.borderWidth = 1
//            self.followButton.setTitleColor(SeaColor, forState: .Normal)
//            self.followButton.backgroundColor = .whiteColor()
//            self.followButton.setTitle("关注", forState: .Normal)
//        } else {
//            self.followButton.layer.borderWidth = 0
//            self.followButton.setTitleColor(SeaColor, forState: .Normal)
//            self.followButton.backgroundColor = SeaColor
//            self.followButton.setTitle("关注中", forState: .Normal)
//        }
    }
    
    @IBAction func onFollowClick(sender: UIButton) {
        var tag = sender.tag
        if tag == 100 {     //没有关注
            sender.tag = 200
            sender.layer.borderWidth = 0
            sender.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            sender.backgroundColor = SeaColor
            sender.setTitle("关注中", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                var sa = SAPost("uid=\(self.uid)&&myuid=\(safeuid)&&shell=\(safeshell)&&fo=1", "http://nian.so/api/fo.php")
                if sa != "" && sa != "err" {
                }
            })
        }else if tag == 200 {   //正在关注
            sender.tag = 100
            sender.layer.borderColor = SeaColor.CGColor
            sender.layer.borderWidth = 1
            sender.setTitleColor(SeaColor, forState: UIControlState.Normal)
            sender.backgroundColor = UIColor.whiteColor()
            sender.setTitle("关注", forState: UIControlState.Normal)
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                var safeuid = Sa.objectForKey("uid") as! String
                var safeshell = Sa.objectForKey("shell") as! String
                var sa = SAPost("uid=\(self.uid)&&myuid=\(safeuid)&&shell=\(safeshell)&&unfo=1", "http://nian.so/api/fo.php")
                if sa != "" && sa != "err" {
                }
            })
        }
        
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        imageHead.image = nil   
    }
    
}
