//
//  ExploreDynamicCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/14.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

import UIKit

class ExploreDynamicProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource {
    
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
        var uidlike: String!
        var userlike: String!
        var type: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 0
    var dataSource = [Data]()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.tableView.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        viewController.tableView.registerNib(UINib(nibName: "ExploreDynamicStepCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicStepCell")
    }
    
    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreDynamic("\(page++)", callback: {
            json in
            var success = false
            if json != nil {
                var items = json!["items"] as! NSArray
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                    success = true
                    for item in items {
                        var data = Data()
                        data.id = item["id"] as! String
                        data.uid = item["uid"] as! String
                        data.user = item["user"] as! String
                        data.title = item["title"] as! String
                        data.img = item["img"] as! String
                        data.uidlike = item["uidlike"] as! String
                        data.userlike = item["userlike"] as! String
                        data.type = (item["type"] as! String).toInt()
                        if data.type == 1 {
                            data.sid = item["sid"] as! String
                            data.content = item["content"] as! String
                            data.lastdate = item["lastdate"] as! String
                            data.img0 = (item["img0"] as! NSString).floatValue
                            data.img1 = (item["img1"] as! NSString).floatValue
                            data.like = (item["like"] as! String).toInt()
                            data.liked = (item["liked"] as! String).toInt()
                            data.comment = (item["comment"] as! String).toInt()
                        }
                        self.dataSource.append(data)
                    }
                }else if clear {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    var viewQuestion = viewEmpty(globalWidth, content: "这是动态页面！\n你关注的人赞过的内容\n都会出现在这里")
                    viewQuestion.setY(50)
                    viewHeader.addSubview(viewQuestion)
                    self.bindViewController?.tableView.tableHeaderView = viewHeader
                }
            }
            callback(success)
        })
    }
    
    override func onHide() {
        bindViewController!.tableView.headerEndRefreshing(animated: false)
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.tableView.reloadData()
        if dataSource.isEmpty {
            bindViewController!.tableView.headerBeginRefreshing()
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.bindViewController!.tableView.setContentOffset(CGPointZero, animated: false)
                }, completion: { (Bool) -> Void in
                    if loading {
                        self.bindViewController!.tableView.headerBeginRefreshing()
                    }
            })
        }
    }
    
    override func onRefresh() {
        page = 0
        load(true) {
            success in
            if self.bindViewController!.current == 1 {
                self.bindViewController!.tableView.headerEndRefreshing()
                self.bindViewController!.tableView.reloadData()
            }
        }
    }
    
    override func onLoad() {
        load(false) {
            success in
            if self.bindViewController!.current == 1 {
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[indexPath.row].id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var data = dataSource[indexPath.row]
        switch data.type {
        case 0:
            return 85
        case 1:
            return ExploreDynamicStepCell.heightWithData(data.content, w: data.img0, h: data.img1)
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        var data = dataSource[indexPath.row]
        switch data.type {
        case 0:
            var dreamCell = tableView.dequeueReusableCellWithIdentifier("ExploreDynamicDreamCell", forIndexPath: indexPath) as? ExploreDynamicDreamCell
            dreamCell!.bindData(data, tableview: tableView)
            dreamCell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserTap:"))
            dreamCell!.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserTap:"))
            dreamCell!.labelDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamTap:"))
            dreamCell!.imageCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamTap:"))
            cell = dreamCell
            break
        case 1:
            var stepCell = tableView.dequeueReusableCellWithIdentifier("ExploreDynamicStepCell", forIndexPath: indexPath) as? ExploreDynamicStepCell
            stepCell!.bindData(data, tableview: tableView)
            stepCell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserTap:"))
            stepCell!.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserTap:"))
            stepCell!.labelDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDreamTap:"))
            stepCell!.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLikeTap:"))
            stepCell!.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentTap:"))
            stepCell!.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
            stepCell!.btnMore.addTarget(self, action: "onMoreClick:", forControlEvents: UIControlEvents.TouchUpInside)
            if indexPath.row == self.dataSource.count - 1 {
                stepCell!.viewLine.hidden = true
            }else{
                stepCell!.viewLine.hidden = false
            }
            cell = stepCell
            break
        default:
            break
        }
        cell!.tag = indexPath.row
        return cell!
    }
    
    func onUserTap(sender: UITapGestureRecognizer) {
        var viewController = PlayerViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].uidlike
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onDreamTap(sender: UITapGestureRecognizer) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view = findTableCell(sender.view)!
        var data = dataSource[view.tag]
        var yPoint = sender.view!.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!)
        var w = CGFloat(data.img0)
        var h = CGFloat(data.img1)
        if w != 0 {
            h = h * globalWidth / w
            var rect = CGRectMake(-yPoint.x, -yPoint.y, globalWidth, h)
            if let v = sender.view as? UIImageView {
                v.showImage(V.urlStepImage(data.img, tag: .Large), rect: rect)
            }
        }
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
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
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
            items.append(FileUtility.imageDataFromPath(V.imageCachePath(V.urlStepImage(data.img, tag: .Large))))
        }
        sender.popupActivity(items, activities: [WeChatSessionActivity(), WeChatMomentsActivity(), reportActivity], exclude: [
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

class ExploreDynamicStepCell: UITableViewCell {
    
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
    @IBOutlet var viewLine: UIView!
    
    var cellData: ExploreDynamicProvider.Data?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        btnLike.addTarget(self, action: "onLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        btnUnlike.addTarget(self, action: "onUnlikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        self.setWidth(globalWidth)
        self.labelDate.setX(globalWidth-15-92)
        self.viewControl.setWidth(globalWidth)
        self.labelContent.setWidth(globalWidth-30)
        self.viewLine.setWidth(globalWidth)
        self.btnLike.setX(globalWidth-50)
        self.btnUnlike.setX(globalWidth-50)
        self.btnMore.setX(globalWidth-90)
    }
    
    func bindData(data: ExploreDynamicProvider.Data, tableview: UITableView) {
        cellData = data
        var imageDelta: CGFloat =  0
        if !data.img0.isZero && !data.img1.isZero {
            imageDelta = CGFloat(data.img1 * Float(globalWidth) / data.img0)
            
            if !tableview.dragging && !tableview.decelerating {
                imageContent.setImage(V.urlStepImage(data.img, tag: .Large), placeHolder: IconColor)
            }
            // data.img.pathExtension
            imageContent.setHeight(imageDelta)
            imageContent.setWidth(globalWidth)
            imageContent.hidden = false
            labelContent.setY(imageContent.bottom() + 15)
        }else{
            imageContent.hidden = true
            labelContent.setY(70)
        }
        var textHeight = data.content.stringHeightWith(16, width: globalWidth-30)
        if data.content == "" {
            textHeight = 0
        }
        labelContent.setHeight(textHeight)
        if data.content == "" {
            viewControl.setY(labelContent.bottom()-10)
        }else{
            viewControl.setY(labelContent.bottom()+5)
        }
        viewLine.setY(viewControl.bottom()+10)
      //  imageHead.setImage(V.urlHeadImage(data.uidlike, tag: .Dream), placeHolder: IconColor)
        imageHead.setHead(data.uidlike)
        labelName.text = data.userlike
        labelDate.text = data.lastdate
        labelDream.text = "赞了「\(data.title)」"
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
                return 136
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

class ExploreDynamicDreamCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var viewLine: UIView!
    
    var cellData: ExploreDynamicProvider.Data?
    
    override func awakeFromNib() {
        imageCover.setX(globalWidth-55)
        self.viewLine.setWidth(globalWidth)
    }
    
    func bindData(data: ExploreDynamicProvider.Data, tableview: UITableView) {
        if !tableview.dragging && !tableview.decelerating {
            imageCover.setImage(V.urlDreamImage(data.img, tag: .Dream), placeHolder: IconColor)
        }
        
        if !tableview.dragging && !tableview.decelerating {
            imageHead.setImage(V.urlHeadImage(data.uidlike, tag: .Dream), placeHolder: IconColor)
        }
        
        labelName.text = data.userlike
        labelDream.text = "赞了「\(data.title)」"
    }
}