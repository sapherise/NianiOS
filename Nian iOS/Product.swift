//
//  Product.swift
//  Nian iOS
//
//  Created by Sa on 16/2/25.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Product: SAViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, NIAlertDelegate {
    var imageHead: UIImageView!
    var scrollView: UIScrollView!
    var labelTitle: UILabel!
    var labelContent: UILabel!
    var labelPrice: UILabel!
    var btnMain: UIButton!
    let padding: CGFloat = 40
    var viewCover: UIView!
    var viewLine: UIView!
    var viewPrice: UILabel!
    var viewEmojiHolder: FLAnimatedImageView!
    var collectionView: UICollectionView!
    var dataArray = NSMutableArray()
    var niAlert: NIAlert!
    var niAlertResult: NIAlert!
    var content = ""
    var price = ""
    var isCoin = ""
    var type = ""
    var path = ""
    
    /* 传入的值，会员、表情、插件 */
    var name = ""
    let items = [
        ["type": "vip", "title": "会员", "content": "永久地成为念的会员，在享受念币商店 7 折优惠的基础上，还能获得一个好看的会员标识。", "price": "120", "isCoin": "false"],
        ["type": "emoji", "title": "幽灵", "content": "隐藏中的宠物，无法通过正常途径获得。喜欢帮助念的玩家更好地玩念。", "price": "100", "isCoin": "true", "path": "ghost"],
        ["type": "emoji", "title": "小白", "content": "念的实验室里的隐藏 BOSS，当感受到爱时会长出第二条尾巴。", "price": "100", "isCoin": "true", "path": "cat"],
        ["type": "plugin", "title": "请假", "content": "72 小时内不会被停号！如果你开启了日更模式，出去玩时记得买张请假条！", "price": "2", "isCoin": "true"],
        ["type": "plugin", "title": "推广", "content": "在接下来的 24 小时里，置顶你的记本到发现页面。多次购买可重复叠加时间！", "price": "20", "isCoin": "true"],
        ["type": "plugin", "title": "毕业证", "content": "永不停号，愿你已从念获益。", "price": "100", "isCoin": "true"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onWechatResult:", name: "onWechatResult", object: nil)
    }
    
    func setup() {
        
        navView.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor.HightlightColor()
        print("1")
        for _item in items {
            let item = _item as NSDictionary
            let title = item.stringAttributeForKey("title")
            if title == name {
                self.content = item.stringAttributeForKey("content")
                price = item.stringAttributeForKey("price")
                isCoin = item.stringAttributeForKey("isCoin")
                type = item.stringAttributeForKey("type")
                path = item.stringAttributeForKey("path")
                break
            }
        }
        
        /* 添加顶部头图 */
        imageHead = UIImageView(frame: CGRectMake(0, 0, globalWidth, globalWidth * 3/4))
        imageHead.image = UIImage(named: "banner_dragon")
        imageHead.backgroundColor = UIColor.HightlightColor()
        self.view.addSubview(imageHead)
        
        /* 添加遮挡视图，避免划到很上面的时候遮不住头图 */
        viewCover = UIView(frame: CGRectMake(0, globalWidth * 3/4, globalWidth, globalHeight - globalWidth * 3/4))
        viewCover.backgroundColor = UIColor.BackgroundColor()
        self.view.addSubview(viewCover)
        
        /* 添加滚动视图 */
        scrollView = UIScrollView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        self.view.addSubview(scrollView)
        
        /* 添加标题和简介 */
        labelTitle = UILabel(frame: CGRectMake(padding, imageHead.height() + 8, globalWidth, 56))
        labelTitle.text = name
        labelTitle.textColor = UIColor.MainColor()
        labelTitle.font = UIFont.systemFontOfSize(18)
        scrollView.addSubview(labelTitle)
        
        labelContent = UILabel(frame: CGRectMake(padding, labelTitle.bottom(), globalWidth - padding * 2, 24))
        labelContent.text = content
        labelContent.textColor = UIColor.AuxiliaryColor()
        labelContent.font = UIFont.systemFontOfSize(14)
        labelContent.setHeight(content.stringHeightWith(14, width: globalWidth - padding * 2))
        labelContent.numberOfLines = 0
        scrollView.addSubview(labelContent)
        
        /* 价格 */
        viewPrice = UILabel(frame: CGRectMake(0, imageHead.height() + 8, 0, 56))
        price = isCoin == "true" ? price : "¥ \(price)"
        viewPrice.text = price
        let w = price.stringWidthWith(14, height: 56)
        viewPrice.setWidth(w)
        viewPrice.setX(globalWidth - padding - w)
        viewPrice.textColor = UIColor.Accomplish()
        viewPrice.font = UIFont.systemFontOfSize(14)
        viewPrice.textAlignment = NSTextAlignment.Right
        scrollView.addSubview(viewPrice)
        
        /* 价格左边的图标 */
        if isCoin == "true" {
            let imageCoin = UIImageView(frame: CGRectMake(0, 0, 16, 56))
            imageCoin.image = UIImage(named: "recharge")
            imageCoin.setX(viewPrice.x() - 24)
            imageCoin.setY(viewPrice.y())
            imageCoin.contentMode = UIViewContentMode.ScaleAspectFit
            scrollView.addSubview(imageCoin)
        }
        
        /* 按钮 */
        btnMain = UIButton(frame: CGRectMake(padding, labelContent.bottom() + 16, globalWidth - padding * 2, 48))
        btnMain.layer.cornerRadius = 24
        btnMain.layer.masksToBounds = true
        btnMain.titleLabel?.font = UIFont.systemFontOfSize(16)
        btnMain.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(btnMain)
        setButtonEnable(Product.btnMainState.willBuy)
        
        /* 分割线 */
        viewLine = UIView(frame: CGRectMake(padding, btnMain.bottom() + 24 - globalHalf / 2, globalWidth - padding * 2, globalHalf))
        viewLine.backgroundColor = UIColor.LineColor()
        scrollView.addSubview(viewLine)
        
        /* 列表 */
        
        let flowLayout = UICollectionViewFlowLayout()
        var frame: CGRect?
        var cell = ""
        var heightContentSize: CGFloat = 0
        
        /* 如果是会员 */
        if type == "vip" {
            dataArray = [["title": "购买优惠", "content": "念币商店表情、主题 30% 的折扣。", "image": "vip_discount"], ["title": "身份标识", "content": "每条进展都有好看的会员标识。", "image": "vip_mark"], ["title": "表达你的喜爱", "content": "蟹蟹你对念的支持 :))", "image": "vip_love"]]
            let w = globalWidth - padding * 2
            let h: CGFloat = 72
            let wCollectionView = globalWidth
            let hCollectionView = CGFloat(dataArray.count) * h
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: w, height: h)
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            frame = CGRectMake(0, viewLine.bottom() + padding, wCollectionView, hCollectionView)
            cell = "ProductCollectionCell"
            heightContentSize = hCollectionView
        } else if type == "emoji" {
            dataArray = [
                ["image": "http://img.nian.so/emoji/\(path)/1.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/2.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/3.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/4.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/5.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/6.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/7.gif"],
                ["image": "http://img.nian.so/emoji/\(path)/8.gif"]
            ]
            let w = (globalWidth - padding * 2) / 4
            let h: CGFloat = w
            let wCollectionView = globalWidth
            let hCollectionView = 2 * w
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: w, height: h)
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
            frame = CGRectMake(0, viewLine.bottom() + padding, wCollectionView, hCollectionView)
            cell = "ProductEmojiCollectionCell"
            heightContentSize = hCollectionView
        } else if type == "plugin" {
            dataArray = []
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: 0, height: 0)
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            frame = CGRectMake(0, 0, 0, 0)
            cell = "ProductEmojiCollectionCell"
            heightContentSize = 0
        }
        collectionView = UICollectionView(frame: frame!, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.BackgroundColor()
        collectionView.registerNib(UINib(nibName: cell, bundle: nil), forCellWithReuseIdentifier: cell)
        collectionView.contentSize.height = heightContentSize
        scrollView.addSubview(collectionView)
        scrollView.contentSize.height = collectionView.bottom() + 100
        scrollView.showsVerticalScrollIndicator = false
        
        /*  查看表情动图的视图 */
        viewEmojiHolder = FLAnimatedImageView()
        viewEmojiHolder.backgroundColor = UIColor(white: 1, alpha: 0.9)
        viewEmojiHolder.layer.borderColor = UIColor.LineColor().CGColor
        viewEmojiHolder.layer.borderWidth = 0.5
        viewEmojiHolder.layer.cornerRadius = 4
        viewEmojiHolder.layer.masksToBounds = true
        viewEmojiHolder.hidden = true
        scrollView.addSubview(viewEmojiHolder)
    }
    
    func onClick() {
        niAlert = NIAlert()
        niAlert.delegate = self
        niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "pay_wallet")!, "购买", "选择一种支付方式", ["微信支付", "支付宝支付"]], forKeys: ["img", "title", "content", "buttonArray"])
        niAlert.showWithAnimation(.flip)
    }
    
    func onWechatResult(sender: NSNotification) {
        if let object = sender.object as? String {
            print("获取到观察对象：\(object)")
            niAlertResult = NIAlert()
            niAlertResult.delegate = self
            if object == "0" {
                /* 微信支付成功 */
                niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付好了", "获得念的永久会员啦！\n蟹蟹你对念的支持", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                niAlert.dismissWithAnimationSwtich(niAlertResult)
                
                /* 按钮的状态变化 */
                setButtonEnable(Product.btnMainState.hasBought)
            } else if object == "-1" {
                niAlertResult.dict = NSMutableDictionary(objects: [UIImage(named: "pay_result")!, "支付不成功", "服务器坏了！", ["哦"]], forKeys: ["img", "title", "content", "buttonArray"])
                niAlert.dismissWithAnimationSwtich(niAlertResult)
                setButtonEnable(Product.btnMainState.willBuy)
            } else {
                if let btn = niAlert.niButtonArray.firstObject as? NIButton {
                    btn.stopAnimating()
                }
                setButtonEnable(Product.btnMainState.willBuy)
            }
        }
    }
    
    enum btnMainState {
        /* 未购买，未下载 */
        case willBuy
        
        /* 已购买，无需下载 */
        case hasBought
        
        /* 已购买，未下载 */
        case willDownload
        
        /* 已购买，已下载 */
        case hasDownload
    }
    
    /* 设置按钮的状态 */
    func setButtonEnable(state: btnMainState) {
        var enabled = true
        var content = ""
        switch state {
        case .willBuy:
            enabled = true
            content = "购买"
            break
        case .hasBought:
            enabled = false
            content = "已购买"
            break
        case .willDownload:
            enabled = true
            content = "下载"
            break
        case .hasDownload:
            enabled = false
            content = "已下载"
            break
            
        }
        btnMain.enabled = enabled
        btnMain.setTitle(content, forState: UIControlState())
        if enabled {
            btnMain.backgroundColor = UIColor.HightlightColor()
            btnMain.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
        } else {
            btnMain.backgroundColor = UIColor.WindowColor()
            btnMain.setTitleColor(UIColor.secAuxiliaryColor(), forState: UIControlState())
        }
    }
}