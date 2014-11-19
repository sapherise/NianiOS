//
//  ExploreFollowCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/11.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class ExploreFollowProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource {
    
    class Data {
        var id: String!
        var sid: String!
        var uid: String!
        var user: String!
        var content: String!
        var lastdate: String!
        var title: String!
        var img: String!
        var img0: Float!
        var img1: Float!
        var like: Int!
        var liked: Int!
        var comment: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 0
    var dataSource = [Data]()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "ExploreFollowCell", bundle: nil), forCellReuseIdentifier: "ExploreFollowCell")
    }
    
    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreFollow("\(page++)", callback: {
            json in
            var success = false
            if json != nil {
                var items = json!["items"] as NSArray
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                    success = true
                    for item in items {
                        var data = Data()
                        data.id = item["id"] as String
                        data.sid = item["sid"] as String
                        data.uid = item["uid"] as String
                        data.user = item["user"] as String
                        data.content = item["content"] as String
                        data.lastdate = item["lastdate"] as String
                        data.title = item["title"] as String
                        data.img = item["img"] as String
                        data.img0 = (item["img0"] as NSString).floatValue
                        data.img1 = (item["img1"] as NSString).floatValue
                        data.like = (item["like"] as String).toInt()
                        data.liked = (item["liked"] as String).toInt()
                        data.comment = (item["comment"] as String).toInt()
                        self.dataSource.append(data)
                    }
                }
            }
            callback(success)
        })
    }
    
    override func onShow() {
        bindViewController!.tableView.reloadData()
        if dataSource.isEmpty {
            self.onRefresh()
        } else {
            bindViewController!.tableView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
    override func onRefresh() {
        page = 0
        load(true) {
            success in
            if self.bindViewController!.current == 0 {
                self.bindViewController!.tableView.headerEndRefreshing()
                self.bindViewController!.tableView.reloadData()
            }
        }
    }
    
    override func onLoad() {
        load(false) { success in
            if self.bindViewController!.current == 0 {
                if success {
                    self.bindViewController!.tableView.footerEndRefreshing()
                    self.bindViewController!.tableView.reloadData()
                } else {
                    self.bindViewController!.view.showTipText("已经到底啦", delay: 1)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var data = dataSource[indexPath.row]
        return ExploreFollowCell.heightWithData(data.content, w: data.img0, h: data.img1)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("ExploreFollowCell", forIndexPath: indexPath) as? ExploreFollowCell
        cell!.bindData(dataSource[indexPath.row])
        cell!.tag = indexPath.row
        cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHeadTap:"))
        cell!.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onNameTap:"))
        cell!.labelDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamTap:"))
        cell!.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLikeTap:"))
        cell!.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentTap:"))
        cell!.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
        cell!.btnMore.addTarget(self, action: "onMoreClick:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell!
    }
    
    func onHeadTap(sender: UITapGestureRecognizer) {
        var viewController = UserViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].uid
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onNameTap(sender: UITapGestureRecognizer) {
        var viewController = UserViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].uid
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onDreamTap(sender: UITapGestureRecognizer) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].uid
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view = findTableCell(sender.view)!
        var data = dataSource[view.tag]
        bindViewController!.view.showImage(V.urlStepImage(data.img, tag: .Large), width: data.img0, height: data.img1)
    }
    
    func onLikeTap(sender: UITapGestureRecognizer) {
        var viewController = LikeViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].sid
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onCommentTap(sender: UITapGestureRecognizer) {
        var data = dataSource[findTableCell(sender.view)!.tag]
        var viewController = DreamCommentViewController()
        viewController.dataTotal = data.comment
        viewController.dreamID = data.id.toInt()!
        viewController.stepID = data.sid.toInt()!
        viewController.dreamowner = data.uid.toInt()!
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func onMoreClick(sender: UIButton) {
        var data = dataSource[findTableCell(sender.superview)!.tag]
        var reportActivity = V.CustomActivity(title: "举报", image: UIImage(named: "flag")) {
            items in
            Api.postReport("step", id: data.sid) {
                result in
                if result == "1" {
                    sender.showTipText("打小报告成功", delay: 1)
                }
            }
        }
        var items: [AnyObject] = [ data.content, V.urlShareDream(data.id)]
        if data.img != "" {
            items.append(FileUtility.imageDataFromPath(V.imageCachePath(V.urlStepImage(data.img, tag: .iOSFo))))
        }
        sender.popupActivity(items, activities: [ reportActivity ], exclude: [
            UIActivityTypeAddToReadingList,
            UIActivityTypeAirDrop,
            UIActivityTypeAssignToContact,
            UIActivityTypePostToFacebook,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePrint
            ])
    }
}

class ExploreFollowCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDate: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageContent: UIImageView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewControl: UIView!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnUnlike: UIButton!
    @IBOutlet weak var labelComment: UILabel!
    
    var cellData: ExploreFollowProvider.Data?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnLike.addTarget(self, action: "onLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        btnUnlike.addTarget(self, action: "onUnlikeClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func bindData(data: ExploreFollowProvider.Data) {
        cellData = data
        var imageDelta: CGFloat =  -imageContent.height()
        if !data.img0.isZero && !data.img1.isZero {
            imageDelta += CGFloat(data.img1 * 320 / data.img0)
        }
        imageContent.setImage(V.urlStepImage(data.img, tag: .iOSFo), placeHolder: IconColor)
        imageContent.setHeight(imageContent.height() + imageDelta)
        labelContent.setY(labelContent.y() + imageDelta)
        var textHeight = data.content.stringHeightWith(17, width: 290)
        var textDelta = CGFloat(textHeight - labelContent.height())
        labelContent.setHeight(textHeight)
        viewControl.setY(viewControl.y() + imageDelta + textDelta)
        imageHead.setImage(V.urlHeadImage(data.uid, tag: .Head), placeHolder: IconColor)
        labelName.text = data.user
        labelDate.text = data.lastdate
        labelDream.text = data.title
        labelContent.text = data.content
        var liked = (data.liked != 0)
        btnLike.hidden = liked
        btnUnlike.hidden = !liked
        setCommentText(data.comment)
        setLikeText(data.like)
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
        Api.likeStep(cellData!.sid, like: 1) {
            result in
            if result != nil && result == "1" {
                self.btnLike.hidden = true
                self.btnUnlike.hidden = false
                self.cellData!.like = self.cellData!.like + 1
                self.setLikeText(self.cellData!.like)
            }
        }
    }
    
    func onUnlikeClick() {
        Api.likeStep(cellData!.sid, like: 0) {
            result in
            if result != nil && result == "1" {
                self.btnLike.hidden = false
                self.btnUnlike.hidden = true
                self.cellData!.like = self.cellData!.like - 1
                self.setLikeText(self.cellData!.like)
            }
        }
    }
    
    class func heightWithData(content: String, w: Float, h: Float) -> CGFloat {
        var height = content.stringHeightWith(17, width: 290)
        if h == 0.0 || w == 0.0 {
            return height + 151
        } else {
            return height + 171 + CGFloat(h * 320 / w)
        }
    }
}