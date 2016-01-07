//
//  cell.swift
//  Nian iOS
//
//  Created by Sa on 15/10/14.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

protocol delegateSAStepCell {
    func updateData(index: Int, data: NSDictionary)
    func updateStep(index: Int, key: String, value: AnyObject)
    func updateStep(index: Int)
    func updateStep()
    func updateStep(index: Int, delete: Bool)
}

/*
**  使用以下方法需要满足
**  1 将 UIViewController 改为 VVeboViewController
**  2 删除原来的 delegateSAStepCell
**  3 将 UITableView 改为 VVebo
**  4 设定 currentTable，不需要时应改为 nil
**  5 在加载网络数据时候，如果 clear 则 tableView.clearVisibleCell()
**  6 删除四个原来的 SAUpdate 函数
**  7 修改 cellfor 和 heightfor
**  8 dataArray 在添加数据时，数据应转码，完成后设定 currentDataArray
*/

class VVeboCell: UITableViewCell, AddstepDelegate, UIActionSheetDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    var data: NSDictionary! {
        didSet {
            let heightCell = data["heightCell"] as! CGFloat
            let widthComment = data["widthComment"] as! CGFloat
            let uid = data.stringAttributeForKey("uid")
            let widthLike = data["widthLike"] as! CGFloat
            let liked = data.stringAttributeForKey("liked")
            let comments = data.stringAttributeForKey("comments")
            let likes = data.stringAttributeForKey("likes")
            let typeimages = data.stringAttributeForKey("type")
            let heightImage = data["heightImage"] as! CGFloat
            // 多图
            if typeimages == "3" || typeimages == "4" {
                if let _ = data.objectForKey("images") as? NSArray {
                    collectionView.setHeight(heightImage + SIZE_COLLECTION_PADDING)
                                        collectionView.reloadData()
                }
            }
            
            let yButton = heightCell - SIZE_PADDING - SIZE_LABEL_HEIGHT
            viewLine?.setY(heightCell - globalHalf)
            labelComment.setY(yButton)
            labelComment.setWidth(widthComment)
            labelComment.text = comments == "0" ? "回应" : "回应 \(comments)"
            labelLike.setWidth(widthLike)
            labelLike.setX(widthComment + 8 + SIZE_PADDING)
            labelLike.text = likes == "0" ? "" : "赞 \(likes)"
            labelLike.hidden = likes == "0" ? true : false
            labelLike.setY(yButton)
            if liked == "0" {
                btnLike.setImage(UIImage(named: "like"), forState: UIControlState())
                btnLike.backgroundColor = UIColor.clearColor()
                btnLike.layer.borderColor = lineColor.CGColor
                btnLike.layer.borderWidth = 1
            } else {
                btnLike.setImage(UIImage(named: "liked"), forState: UIControlState())
                btnLike.backgroundColor = SeaColor
                btnLike.layer.borderColor = nil
                btnLike.layer.borderWidth = 0
            }
            
            let uidlike = data.stringAttributeForKey("uidlike")
            if type == 2 {
                imageHead.setHead(uidlike)
            } else {
                imageHead.setHead(uid)
            }
            
            btnMore.frame.origin = CGPointMake(globalWidth - SIZE_PADDING - SIZE_LABEL_HEIGHT - SIZE_LABEL_HEIGHT - 8, yButton)
            btnLike.frame.origin = CGPointMake(globalWidth - SIZE_PADDING - SIZE_LABEL_HEIGHT, yButton)
            if uid == SAUid() {
                btnLike.hidden = true
                btnMore.frame.origin = CGPointMake(globalWidth - SIZE_PADDING - SIZE_LABEL_HEIGHT, yButton)
            } else {
                btnLike.hidden = false
            }
        }
    }
    
    var drawed = false
    var label: VVeboLabel?
    var drawColorFlag: UInt32?
    var postBGView: UIImageView!
    var imageHead: UIImageView!
    var imageHeadCover: UIImageView!
    var imageHolder: UIImageView!
    var labelComment: UILabel!
    var labelLike: UILabel!
    var btnMore: UIButton!
    var btnNoLike: UIButton!
    var btnLike: UIButton!
    var num = -1
    var viewLine: UIView?
    var type = 0    // 0 为关注，1 为记本，2 为动态
    var actionSheetDelete: UIActionSheet!
    var activityViewController: UIActivityViewController!
    var editStepRow:Int = -1
    var editStepData:NSDictionary?
    var delegate: delegateSAStepCell?
    var collectionView: UICollectionView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.clipsToBounds = true
        postBGView = UIImageView(frame: CGRectZero)
        contentView.insertSubview(postBGView, atIndex: 0)
        viewLine = UIView(frame: CGRectMake(SIZE_PADDING, 0, globalWidth - SIZE_PADDING * 2, globalHalf))
        viewLine?.backgroundColor = UIColor.e6()
        contentView.addSubview(viewLine!)
        
        
        // 头像
        imageHead = UIImageView(frame: CGRectMake(SIZE_PADDING, SIZE_PADDING, SIZE_IMAGEHEAD_WIDTH, SIZE_IMAGEHEAD_WIDTH))
        imageHead.backgroundColor = UIColor.whiteColor()
        imageHead.layer.masksToBounds = true
        contentView.addSubview(imageHead)
        
        // 头像遮罩
        imageHeadCover = UIImageView(frame: CGRectMake(0, 0, SIZE_IMAGEHEAD_WIDTH, SIZE_IMAGEHEAD_WIDTH))
        imageHeadCover.image = UIImage(named: "cover")
        imageHeadCover.center = imageHead.center
        contentView.addSubview(imageHeadCover)
        
        // 添加配图
        imageHolder = UIImageView(frame: CGRectMake(SIZE_PADDING, SIZE_PADDING * 2 + SIZE_IMAGEHEAD_WIDTH, globalWidth - SIZE_PADDING * 2, 0))
        imageHolder.backgroundColor = IconColor
        contentView.addSubview(imageHolder)
        
        // 添加多图
        let w = (globalWidth - SIZE_PADDING * 2 - SIZE_COLLECTION_PADDING * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = SIZE_COLLECTION_PADDING
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: CGRectMake(SIZE_PADDING, SIZE_PADDING * 2 + SIZE_IMAGEHEAD_WIDTH, globalWidth - SIZE_PADDING * 2, 0), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "VVeboCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "VVeboCollectionViewCell")
        contentView.addSubview(collectionView)
        
        // 回应
        labelComment = UILabel(frame: CGRectMake(SIZE_PADDING, 0, 0, SIZE_LABEL_HEIGHT))
        labelComment.backgroundColor = IconColor
        labelComment.textAlignment = .Center
        labelComment.textColor = UIColor.b3()
        labelComment.font = UIFont.systemFontOfSize(13)
        labelComment.opaque = true
        contentView.addSubview(labelComment)
        
        // 赞
        labelLike = UILabel(frame: CGRectMake(0, 0, 0, SIZE_LABEL_HEIGHT))
        labelLike.backgroundColor = IconColor
        labelLike.textAlignment = .Center
        labelLike.textColor = UIColor.b3()
        labelLike.font = UIFont.systemFontOfSize(13)
        contentView.addSubview(labelLike)
        
        // 更多
        btnMore = UIButton(frame: CGRectMake(0, 0, SIZE_LABEL_HEIGHT, SIZE_LABEL_HEIGHT))
        btnMore.setImage(UIImage(named: "btnmore"), forState: UIControlState())
        btnMore.layer.cornerRadius = SIZE_LABEL_HEIGHT / 2
        btnMore.layer.masksToBounds = true
        btnMore.layer.borderColor = lineColor.CGColor
        btnMore.layer.borderWidth = 1
        contentView.addSubview(btnMore)
        
        // 赞
        btnLike = UIButton(frame: CGRectMake(0, 0, SIZE_LABEL_HEIGHT, SIZE_LABEL_HEIGHT))
        btnLike.layer.cornerRadius = SIZE_LABEL_HEIGHT / 2
        btnLike.layer.masksToBounds = true
        contentView.addSubview(btnLike)
        
        // 绑定事件
        imageHolder.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        imageHeadCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHead"))
        labelComment.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onComment"))
        labelLike.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onLike"))
        btnMore.addTarget(self, action: "onMoreClick", forControlEvents: UIControlEvents.TouchUpInside)
        btnLike.addTarget(self, action: "onLikeClick", forControlEvents: UIControlEvents.TouchUpInside)
        imageHolder.userInteractionEnabled = true
        imageHeadCover.userInteractionEnabled = true
        labelComment.userInteractionEnabled = true
        labelLike.userInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func draw() {
        if drawed {
            return
        }
        drawed = true
        let flag = drawColorFlag
        go {
            let heightCell = self.data["heightCell"] as! CGFloat
            let rect = CGRectMake(0, 0, globalWidth, heightCell + 1)
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
            let context = UIGraphicsGetCurrentContext()
            UIColor.whiteColor().set()
            CGContextFillRect(context, rect)
            
            // 昵称
            var name = self.data.stringAttributeForKey("user") as NSString
            if self.type == 2 {
                name = self.data.stringAttributeForKey("userlike") as NSString
            }
            name.drawInContext(context, withPosition: CGPointMake(SIZE_PADDING + SIZE_IMAGEHEAD_WIDTH + 8, SIZE_PADDING), andFont: UIFont.systemFontOfSize(14), andTextColor: SeaColor, andHeight: Float(SIZE_IMAGEHEAD_WIDTH/2))
            
            // 时间或标题
            var textSubtitle = self.data.stringAttributeForKey("title") as NSString
            if self.type == 1 {
                textSubtitle = self.data.stringAttributeForKey("lastdate") as NSString
            } else if self.type == 2 {
                textSubtitle = self.data.stringAttributeForKey("title")
                textSubtitle = "赞了「\(textSubtitle)」"
            }
            textSubtitle.drawInContext(context, withPosition: CGPointMake(SIZE_PADDING + SIZE_IMAGEHEAD_WIDTH + 8, SIZE_PADDING + SIZE_IMAGEHEAD_WIDTH / 2 + 4), andFont: UIFont.systemFontOfSize(12), andTextColor: UIColor.b3(), andHeight: Float(SIZE_IMAGEHEAD_WIDTH/2))
            
            if self.type != 1 {
                let time = self.data.stringAttributeForKey("lastdate") as NSString
                time.drawInContext(context, withPosition: CGPointMake(globalWidth - SIZE_PADDING - 82, SIZE_PADDING), andFont: UIFont.systemFontOfSize(12), andTextColor: UIColor.b3(), andHeight: Float(SIZE_IMAGEHEAD_WIDTH/2), andWidth: 82, andAlignment: CTTextAlignment.Right)
            }
            
            // 签到
            let content = self.data.stringAttributeForKey("content")
            let heightImage = self.data["heightImage"] as! CGFloat
            if content == "" && heightImage == 0 {
                UIImage(named: "check")?.drawInRect(CGRectMake(SIZE_PADDING, SIZE_PADDING * 2 + SIZE_IMAGEHEAD_WIDTH, 50, 23), blendMode: CGBlendMode.Normal, alpha: 1)
            }
            
            let temp = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            back {
                if flag == self.drawColorFlag {
                    self.postBGView.frame = rect
                    self.postBGView.image = nil
                    self.postBGView.image = temp
                }
            }
        }
        drawText()
        drawThumb()
        
        //        cell.layer.shouldRasterize = YES;
        //        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        contentView.layer.shouldRasterize = true
        contentView.layer.rasterizationScale = globalScale
    }
    
    // 绑定事件
    func onImage() {
        let img = data.stringAttributeForKey("image")
        imageHolder.showImage(V.urlStepImage(img, tag: .Large))
    }
    
    func onHead() {
        let uid = data.stringAttributeForKey("uid")
        let uidlike = data.stringAttributeForKey("uidlike")
        let vc = PlayerViewController()
        vc.Id = type == 2 ? uidlike : uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onComment() {
        let id = data.stringAttributeForKey("dream")
        let sid = data.stringAttributeForKey("sid")
        let uid = data.stringAttributeForKey("uid")
        let vc = DreamCommentViewController()
        vc.dreamID = Int(id)!
        vc.stepID = Int(sid)!
        vc.dreamowner = uid == SAUid() ? 1 : 0
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onLike() {
        let sid = data.stringAttributeForKey("sid")
        let vc = LikeViewController()
        vc.Id = sid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onMoreClick() {
        btnMore.setImage(nil, forState: UIControlState())
        let ac = UIActivityIndicatorView()
        ac.transform = CGAffineTransformMakeScale(0.7, 0.7)
        ac.color = UIColor.b3()
        contentView.addSubview(ac)
        ac.center = btnMore.center
        ac.startAnimating()
        go {
            let sid = self.data!.stringAttributeForKey("sid")
            let content = self.data!.stringAttributeForKey("content").decode()
            let uid = self.data!.stringAttributeForKey("uid")
            let url = NSURL(string: "http://nian.so/m/step/\(sid)")!
            let row = self.num
            
            // 分享的内容
            var arr = [content, url]
            let card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
            card.content = content
            card.widthImage = self.data!.stringAttributeForKey("width")
            card.heightImage = self.data!.stringAttributeForKey("height")
            card.url = "http://img.nian.so/step/" + self.data!.stringAttributeForKey("image") + "!large"
            arr.append(card.getCard())
            
            let customActivity = SAActivity()
            customActivity.saActivityTitle = "举报"
            customActivity.saActivityType = "举报"
            customActivity.saActivityImage = UIImage(named: "av_report")
            customActivity.saActivityFunction = {
                self.findRootViewController()!.showTipText("举报好了！")
            }
            // 保存卡片
            let cardActivity = SAActivity()
            cardActivity.saActivityTitle = "保存卡片"
            cardActivity.saActivityType = "保存卡片"
            cardActivity.saActivityImage = UIImage(named: "card")
            cardActivity.saActivityFunction = {
                card.onCardSave()
                self.findRootViewController()!.showTipText("保存好了！")
            }
            //编辑按钮
            let editActivity = SAActivity()
            editActivity.saActivityTitle = "编辑"
            editActivity.saActivityType = "编辑"
            editActivity.saActivityImage = UIImage(named: "av_edit")
            editActivity.saActivityFunction = {
                let vc = AddStep(nibName: "AddStep", bundle: nil)
                vc.willEdit = true
                vc.dataEdit = self.data
                vc.rowEdit = row
                vc.idDream = self.data.stringAttributeForKey("dream")
                vc.delegate = self
                self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
            }
            //删除按钮
            let deleteActivity = SAActivity()
            deleteActivity.saActivityTitle = "删除"
            deleteActivity.saActivityType = "删除"
            deleteActivity.saActivityImage = UIImage(named: "av_delete")
            deleteActivity.saActivityFunction = {
                self.actionSheetDelete = UIActionSheet(title: "再见了，进展 #\(sid)", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                self.actionSheetDelete.addButtonWithTitle("确定")
                self.actionSheetDelete.addButtonWithTitle("取消")
                self.actionSheetDelete.cancelButtonIndex = 1
                self.actionSheetDelete.showInView((self.findRootViewController()?.view)!)
            }
            
            var ActivityArray = [customActivity, cardActivity]
            if uid == SAUid() {
                ActivityArray = [deleteActivity, editActivity, cardActivity]
            }
            self.activityViewController = SAActivityViewController.shareSheetInView(arr, applicationActivities: ActivityArray, isStep: true)
            
            // 禁用原来的保存图片
            self.activityViewController.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypePostToFacebook, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]
            back {
                ac.removeFromSuperview()
                self.btnMore.setImage(UIImage(named: "btnmore"), forState: UIControlState())
                self.findRootViewController()?.presentViewController(self.activityViewController, animated: true, completion: nil)
            }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == actionSheetDelete {
            if buttonIndex == 0 {
                delegate?.updateStep(num, delete: true)
                let sid = data!.stringAttributeForKey("sid")
                Api.postDeleteStep(sid) { string in
                }
            }
        }
    }
    
    func onLikeClick() {
        globalVVeboReload = false
        let isLiked = data.stringAttributeForKey("liked")
        if isLiked == "0" {
            // 点赞
            if let like = Int(data!.stringAttributeForKey("likes")) {
                let numLike = "\(like + 1)"
                delegate?.updateStep(num, key: "likes", value: numLike)
                delegate?.updateStep(num, key: "liked", value: "1")
                let widthLike = "赞 \(numLike)".stringWidthWith(13, height: 32) + 16
                delegate?.updateStep(num, key: "widthLike", value: widthLike)
                delegate?.updateStep()
                let sid = data!.stringAttributeForKey("sid")
                Api.postLike(sid, like: "1") { json in
                }
            }
        } else {
            // 取消赞
            if let like = Int(data!.stringAttributeForKey("likes")) {
                let numLike = "\(like - 1)"
                delegate?.updateStep(num, key: "likes", value: numLike)
                delegate?.updateStep(num, key: "liked", value: "0")
                let widthLike = "赞 \(numLike)".stringWidthWith(13, height: 32) + 16
                delegate?.updateStep(num, key: "widthLike", value: widthLike)
                delegate?.updateStep()
                let sid = data!.stringAttributeForKey("sid")
                Api.postLike(sid, like: "0") { json in
                }
            }
        }
    }
    
    func Editstep() {
        if editStepData != nil {
            clear()
            delegate?.updateData(num, data: editStepData!)
            delegate?.updateStep(num)
        }
    }
    
    func drawThumb() {
        let heightImage = data["heightImage"] as! CGFloat
        let urlImage = data.stringAttributeForKey("image")
        let typeImages = data.stringAttributeForKey("type")
        if typeImages != "3" && typeImages != "4" {
            if heightImage > 0 {
                imageHolder.setHeight(heightImage)
                imageHolder.hidden = false
                imageHolder.setImage("http://img.nian.so/step/\(urlImage)!large")
            }
        } else {
            collectionView.hidden = false
        }
    }
    
    
    func drawText() {
        if label == nil {
            addLabel()
        }
        let heightContent = data["heightContent"] as! CGFloat
        let heightImage = data["heightImage"] as! CGFloat
        var yLabel = SIZE_PADDING * 2 + SIZE_IMAGEHEAD_WIDTH
        if heightImage > 0 {
            yLabel += heightImage + SIZE_PADDING
        }
        label!.frame = CGRectMake(SIZE_PADDING, yLabel, globalWidth - SIZE_PADDING * 2, heightContent)
    }
    
    func addLabel() {
        label?.removeFromSuperview()
        label = nil
        let heightContent = data["heightContent"] as! CGFloat
        label = VVeboLabel(frame: CGRectMake(20, 20, globalWidth - SIZE_PADDING * 2, heightContent))
        label?.backgroundColor = UIColor.whiteColor()
        label?.text = data.stringAttributeForKey("content")
        
        // 网页跳转
        label?.URLHandler = { string in
            if !string.hasPrefix("http://") && !string.hasPrefix("https://") {
                let urlString = "http://\(string)"
                let web = WebViewController()
                web.urlString = urlString
                self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
            } else {
                let web = WebViewController()
                web.urlString = string
                self.findRootViewController()?.navigationController?.pushViewController(web, animated: true)
            }
        }
        
        // 用户跳转
        label?.AccountHandler = { string in
            var _string = string
            _string.removeAtIndex(string.startIndex.advancedBy(0))
            self.findRootViewController()?.viewLoadingShow()
            Api.postUserNickName(_string) {
                json in
                if json != nil {
                    let error = json!.objectForKey("error") as! NSNumber
                    self.findRootViewController()?.viewLoadingHide()
                    if error == 0 {
                        if let uid = json!.objectForKey("data") as? String {
                            let UserVC = PlayerViewController()
                            UserVC.Id = uid
                            self.findRootViewController()?.navigationController?.pushViewController(UserVC, animated: true)
                        }
                    } else {
                        self.findRootViewController()!.showTipText("没有人叫这个名字...")
                    }
                }
            }
        }
        contentView.addSubview(label!)
    }
    
    func clear() {
        if !drawed {
            return
        }
        postBGView.frame = CGRectZero
        postBGView.image = nil
        label?.clear()
        label?.removeFromSuperview()
        label = nil
        imageHolder.cancelImageRequestOperation()
        imageHolder.image = nil
        imageHolder.hidden = true
        labelLike.hidden = true
        collectionView.hidden = true
        
        drawColorFlag = arc4random()
        drawed = false
    }
    
    // 转换一个 NSDictionay
    class func SACellDataRecode(dataOriginal: NSDictionary) -> NSDictionary {
        let data = NSMutableDictionary(dictionary: dataOriginal)
        let content = data.stringAttributeForKey("content").decode()
        let lastdate = data.stringAttributeForKey("lastdate")
        let title = data.stringAttributeForKey("title").decode()
        let img0 = (data.stringAttributeForKey("width") as NSString).floatValue
        let img1 = (data.stringAttributeForKey("height") as NSString).floatValue
        let typeImages = data.stringAttributeForKey("type")
        var comment = data.stringAttributeForKey("comments")
        comment = comment == "0" ? "回应" : "回应 \(comment)"
        var like = data.stringAttributeForKey("likes")
        like = like == "0" ? like : "赞 \(like)"
        let widthLike = like.stringWidthWith(13, height: 32) + 16
        let widthComment = comment.stringWidthWith(13, height: 32) + 16
        let heightContent = (content as NSString).sizeWithConstrainedToWidth(globalWidth - 40, fromFont: UIFont.systemFontOfSize(16), lineSpace: 5).height
        var heightCell: CGFloat = 0
        var heightImage: CGFloat = 0
        
        /* 文本 */
        if (img0 == 0.0) {
            heightCell = content == "" ? 155 + 23 : heightContent + SIZE_PADDING * 4 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
        } else {
            /* 多图带文字 */
            if typeImages == "3" {
                if let images = data.objectForKey("images") as? NSArray {
                    let count = ceil(CGFloat(images.count) / 3)
                    var h = (globalWidth - SIZE_PADDING * 2 - SIZE_COLLECTION_PADDING * 2) / 3 + SIZE_COLLECTION_PADDING
                    heightImage = h * count - SIZE_COLLECTION_PADDING
                    heightCell = heightContent + heightImage + SIZE_PADDING * 5 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                }
            } else if typeImages == "4" {
                /* 多图不带文字 */
                if let images = data.objectForKey("images") as? NSArray {
                    let count = ceil(CGFloat(images.count) / 3)
                    var h = (globalWidth - SIZE_PADDING * 2 - SIZE_COLLECTION_PADDING * 2) / 3 + SIZE_COLLECTION_PADDING
                    heightImage = h * count - SIZE_COLLECTION_PADDING
                    heightCell = heightImage + SIZE_PADDING * 4 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
                }
            } else {
                heightImage = CGFloat(img1 * Float(globalWidth - 40) / img0)
                heightCell = content == "" ?  heightImage + SIZE_PADDING * 4 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT : heightContent + heightImage + SIZE_PADDING * 5 + SIZE_IMAGEHEAD_WIDTH + SIZE_LABEL_HEIGHT
            }
        }
        data["heightImage"] = heightImage
        data["heightCell"] = heightCell
        data["content"] = content
        data["heightContent"] = heightContent
        data["widthComment"] = widthComment
        data["widthLike"] = widthLike
        data["lastdate"] = V.relativeTime(lastdate)
        data["title"] = title
        return data
    }
    
}