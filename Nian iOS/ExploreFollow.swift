//
//  ExploreFollowCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/11.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

struct FollowBlacklist {
    
    private static let blackfile: String = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String).stringByAppendingPathComponent("blacklist.gift")
    
    private static var blacklist = [Int]()
    private static var loaded = false
    
    static func load() {
        if loaded {
            return
        }
        loaded = true
        blacklist = [] //[Int]()
        if let data = NSData(contentsOfFile: blackfile) {
            var json: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: nil)
            if json == nil {
                return
            }
            if let items = json!["blacked"] as? NSArray {
                for item in items {
                    if let id = item as? Int {
                        blacklist.append(id)
                    }
                }
            }
        }
    }
    
    static func save() {
        var data = NSJSONSerialization.dataWithJSONObject(["blacked": blacklist], options: NSJSONWritingOptions.allZeros, error: nil)
        data!.writeToFile(blackfile, atomically: true)
    }
    
    static func isblacked(uid: Int) -> Bool {
        load()
        for id in blacklist {
            if id == uid {
                return true
            }
        }
        return false
    }
    
    static func black(uid: Int) {
        load()
        if !isblacked(uid) {
            blacklist.append(uid)
            save()
        }
    }
    
    static func unblack(uid: Int) {
        load()
        for var i = 0; i < blacklist.count; i++ {
            if blacklist[i] == uid {
                blacklist.removeAtIndex(i)
                save()
                break
            }
        }
    }
}

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
    var locked = false
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
                }else if clear {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    var viewQuestion = viewEmpty(globalWidth, content: "这是关注页面！\n当你关注了一些人或梦想时\n这里会发生微妙变化")
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
        load(true) { success in
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
        for var i = dataSource.count; i > 0; i-- {
            if let suid = dataSource[i - 1].uid.toInt() {
                if FollowBlacklist.isblacked(suid) {
                    dataSource.removeAtIndex(i - 1)
                }
            }
        }
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
        ///=======
        var hatePress = UILongPressGestureRecognizer(target: self, action: "onIHATEYOU:")
        hatePress.minimumPressDuration = 10
        cell!.imageHead.addGestureRecognizer(hatePress)
        ///=======
        cell!.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onNameTap:"))
        cell!.labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLikeTap:"))
        cell!.labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onCommentTap:"))
        cell!.imageContent.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImageTap:"))
        cell!.btnMore.addTarget(self, action: "onMoreClick:", forControlEvents: UIControlEvents.TouchUpInside)
        if indexPath.row == self.dataSource.count - 1 {
            cell!.viewLine.hidden = true
        }else{
            cell!.viewLine.hidden = false
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[indexPath.row].id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onIHATEYOU(sender: UILongPressGestureRecognizer) {
        if locked {
            return
        }
        var tag = findTableCell(sender.view)!.tag
        if dataSource.count <= tag {
            return
        }
        var uid = dataSource[tag].uid
        if let duid = uid.toInt() {
            if FollowBlacklist.isblacked(duid) {
                return
            }
            FollowBlacklist.black(duid)
            locked = true
            delay(9) {
                self.locked = false
            }
            sender.view!.showTipText("I LOVE \(dataSource[tag].user)", delay: 1)
            bindViewController!.tableView.reloadData()
        }
    }
    
    func onHeadTap(sender: UITapGestureRecognizer) {
        var viewController = PlayerViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].uid
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onNameTap(sender: UITapGestureRecognizer) {
        var viewController = PlayerViewController()
        viewController.Id = dataSource[findTableCell(sender.view)!.tag].uid
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func onImageTap(sender: UITapGestureRecognizer) {
        var view = findTableCell(sender.view)!
        var data = dataSource[view.tag]
        if let imageView = sender.view as? UIImageView {
            var yPoint = imageView.convertPoint(CGPointMake(0, 0), fromView: sender.view!.window!)
            var w = CGFloat(data.img0)
            var h = CGFloat(data.img1)
            if w != 0 {
                h = h * globalWidth / w
                var rect = CGRectMake(-yPoint.x, -yPoint.y, globalWidth, h)
                imageView.showImage(V.urlStepImage(data.img, tag: .Large), rect: rect)
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

class ExploreFollowCell: UITableViewCell {
    
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
    @IBOutlet var labelLastdate: UILabel!
    @IBOutlet var viewLine: UIView!
    
    var cellData: ExploreFollowProvider.Data?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.setWidth(globalWidth)
        self.labelLastdate.setX(globalWidth-15-92)
        self.viewControl.setWidth(globalWidth)
        self.labelContent.setWidth(globalWidth-30)
        self.viewLine.setWidth(globalWidth)
        self.btnLike.setX(globalWidth-50)
        self.btnUnlike.setX(globalWidth-50)
        self.btnMore.setX(globalWidth-90)
        btnLike.addTarget(self, action: "onLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        btnUnlike.addTarget(self, action: "onUnlikeClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func bindData(data: ExploreFollowProvider.Data) {
        cellData = data
        var imageDelta: CGFloat =  0
        var textHeight = data.content.stringHeightWith(14, width: globalWidth-30)
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
        imageHead.setImage(V.urlHeadImage(data.uid, tag: .Dream), placeHolder: IconColor)
        labelName.text = data.user
        labelDream.text = data.title
        labelLastdate.text = data.lastdate
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
        var height = content.stringHeightWith(14, width: globalWidth-30)
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