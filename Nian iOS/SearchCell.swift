//
//  SearchCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import Foundation
import UIKit

class searchResultCell: MKTableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var footView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headImageView.layer.cornerRadius = 4.0
        self.headImageView.layer.masksToBounds = true
        self.footView.setWidth(globalWidth - 70)
        self.footView.setX(70)
        self.followButton.layer.cornerRadius = 15
        self.followButton.layer.masksToBounds = true
        self.followButton.setX(globalWidth - 85)
    }
    
    func bindData(data: ExploreSearch.DreamSearchData, tableView: UITableView) {
        self.title.text = data.title
        self.content.text = data.lastdate
        self.headImageView.setImage("http://img.nian.so/dream/\(data.img)!dream", placeHolder: IconColor)
        
//        if data.follow == "0" {
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
//        } else {
//            self.followButton.layer.borderWidth = 0
//            self.followButton.setTitleColor(SeaColor, forState: .Normal)
//            self.followButton.backgroundColor = SeaColor
//            self.followButton.setTitle("关注中", forState: .Normal)
//        }
    }
    
    
    @IBAction func follow(sender: AnyObject) {
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.headImageView.cancelImageRequestOperation()
        self.headImageView.image = nil
    }
    
}

class searchUserResultCell: MKTableViewCell {
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var footView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.headImageView.layer.cornerRadius = 20.0
        self.headImageView.layer.masksToBounds = true
        self.footView.setWidth(globalWidth - 85)
        self.followButton.layer.cornerRadius = 15
        self.followButton.layer.masksToBounds = true
        self.followButton.setX(globalWidth - 85)
    }
   
    func bindData(data: ExploreSearch.UserSearchData, tableview: UITableView) {
        self.title.text = data.user
        
        if data.follow == "0" {
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
        } else {
            self.followButton.layer.borderWidth = 0
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = SeaColor
            self.followButton.setTitle("关注中", forState: .Normal)
        }
        
        self.headImageView.setImage(V.urlHeadImage(data.uid, tag: .Head), placeHolder: IconColor)
    }
    
    override func prepareForReuse() {
       super.prepareForReuse()
        
        self.headImageView.cancelImageRequestOperation()
        self.headImageView.image = nil
    }
}

class dreamSearchStepCell: MKTableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageContent: UIImageView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewControl: UIView!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnUnlike: UIButton!
    @IBOutlet weak var labelComment: UILabel!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var viewLine: UIView!
    
    var cellData: ExploreSearch.DreamStepData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.followButton.setX(globalWidth-15-70)
        self.viewControl.setWidth(globalWidth)
        self.labelContent.setWidth(globalWidth-30)
        self.viewLine.setWidth(globalWidth)
        self.btnLike.setX(globalWidth-50)
        self.btnUnlike.setX(globalWidth-50)
        self.btnMore.setX(globalWidth-90)
        btnLike.addTarget(self, action: "onLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        btnUnlike.addTarget(self, action: "onUnlikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.followButton.layer.cornerRadius = 15.0
        self.followButton.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageHead.cancelImageRequestOperation()
        self.imageHead.image = nil
        self.imageContent.cancelImageRequestOperation()
        self.imageContent.image = nil
    }
    
    func bindData(data: ExploreSearch.DreamStepData, tableview: UITableView) {
        cellData = data
        var imageDelta: CGFloat =  0
        var textHeight = data.content.stringHeightWith(16, width: globalWidth-30)
        if data.content == "" {
            textHeight = 0
        }
        var textDelta = CGFloat(textHeight - labelContent.height())
        labelContent.setHeight(textHeight)
        if !data.img0.isZero && !data.img1.isZero {     //有图片
            imageDelta = CGFloat(data.img1 * Float(globalWidth) / data.img0)
            
            imageContent.setImage(V.urlStepImage(data.img, tag: .Large), placeHolder: IconColor)
            imageContent.setHeight(imageDelta)
            imageContent.setWidth(globalWidth)
            imageContent.setX(0)
            imageContent.hidden = false
            labelContent.setY(imageContent.bottom() + 15)
        }else if data.content == "" {
            imageContent.image = UIImage(named: "check")
            imageContent.setHeight(23)
            imageContent.setWidth(50)
            imageContent.setX(15)
            imageContent.hidden = false
            labelContent.setY(imageContent.bottom() + 15)
        }else{
            imageContent.hidden = true
            labelContent.setY(70)
        }
        if data.content == "" {
            viewControl.setY(labelContent.bottom()-10)
        }else{
            viewControl.setY(labelContent.bottom()+5)
        }
        viewLine.setY(viewControl.bottom()+10)
        imageHead.setHead(data.uid)
        
        labelName.text = data.user
        labelDream.text = data.title
        labelContent.text = data.content
        var liked = (data.liked != 0)
        btnLike.hidden = liked
        btnUnlike.hidden = !liked
        setCommentText(data.comment)
        setLikeText(data.like)
        
//        if data.follow == "0" {
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
//        } else {
//            self.followButton.layer.borderWidth = 0
//            self.followButton.setTitleColor(SeaColor, forState: .Normal)
//            self.followButton.backgroundColor = SeaColor
//            self.followButton.setTitle("关注中", forState: .Normal)
//        }
    }
    
    func setLikeText(like: Int) {
        if like == 0 {
            self.labelLike.hidden = true
        }else{
            self.labelLike.hidden = false
        }
        var likeText = "\(like) 赞"
        labelLike.text = likeText
        var likeWidth = likeText.stringWidthWith(13, height: 30) + 17
        labelLike.setWidth(likeWidth)
    }
    
    func setCommentText(comment: Int) {
        var commentText = ""
        if comment != 0 {
            commentText = "\(comment) 评论"
        }else{
            commentText = "评论"
        }
        labelComment.text = commentText
        var commentWidth = commentText.stringWidthWith(13, height: 30) + 17
        labelComment.setWidth(commentWidth)
        labelLike.setX(commentWidth + 23)
    }
    
    func onLikeClick() {
        self.cellData!.liked = 1
        self.btnLike.hidden = true
        self.btnUnlike.hidden = false
        self.cellData!.like = self.cellData!.like + 1
        self.setLikeText(self.cellData!.like)
        Api.postLikeStep(cellData!.sid, like: 1) {
            result in
            if result != nil && result == "1" {
            }
        }
    }
    
    func onUnlikeClick() {
        self.cellData!.liked = 0
        self.btnLike.hidden = false
        self.btnUnlike.hidden = true
        self.cellData!.like = self.cellData!.like - 1
        self.setLikeText(self.cellData!.like)
        Api.postLikeStep(cellData!.sid, like: 0) {
            result in
            if result != nil && result == "1" {
            }
        }
    }
    
    class func heightWithData(content: String, w: Float, h: Float) -> CGFloat {
        var height = content.stringHeightWith(16, width: globalWidth-30)
        if h == 0.0 || w == 0.0 {
            if content == "" {
                return 156 + 23
            }else{
                return height + 151
            }
        } else {
            if content == "" {
                return 156 + CGFloat(h * Float(globalWidth) / w)
            }else{
                return height + 171 + CGFloat(h * Float(globalWidth) / w)
            }
        }
    }
}



















































