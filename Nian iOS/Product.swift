//
//  Product.swift
//  Nian iOS
//
//  Created by Sa on 16/2/25.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

protocol delegateEmoji {
    
    /* 当购买表情后，刷新 UI */
    func load()
}

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
    var data: NSDictionary!
    var type: ProductType!
    var delegate: delegateEmoji?
    
    enum ProductType {
        case Emoji
        case Pro
        case Plugin
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Product.onWechatResult(_:)), name: "onWechatResult", object: nil)
    }
    
    func setup() {
        navView.backgroundColor = UIColor.clearColor()
        
        var owned = "0"
        if type == ProductType.Pro {
            if let member = Cookies.get("member") as? String {
                if member == "1" {
                    owned = "1"
                }
            }
            data = [
                "banner": "http://img.nian.so/banner/unicorn.png",
                "cost": "120",
                "description": "永久地成为念的会员，在享受念币商店 7 折优惠的基础上，还能获得一个好看的会员标识。",
                "name": "会员",
                "owned": owned,
                "background_color": "#A69DBD"
            ]
        } else {
            owned = data.stringAttributeForKey("owned")
        }
        
        /* 添加顶部头图 */
        let banner = data.stringAttributeForKey("banner")
        let bgColor = data.stringAttributeForKey("background_color")
        imageHead = UIImageView(frame: CGRectMake(0, 0, globalWidth, globalWidth * 3/4))
        imageHead.setImage(banner)
        imageHead.backgroundColor = UIColor.colorWithHex(bgColor)
        self.view.addSubview(imageHead)
        self.view.backgroundColor = UIColor.colorWithHex(bgColor)
        
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
        labelTitle.text = data.stringAttributeForKey("name")
        labelTitle.textColor = UIColor.MainColor()
        labelTitle.font = UIFont.systemFontOfSize(18)
        scrollView.addSubview(labelTitle)
        
        labelContent = UILabel(frame: CGRectMake(padding, labelTitle.bottom(), globalWidth - padding * 2, 24))
        let content = data.stringAttributeForKey("description")
        labelContent.text = content
        labelContent.textColor = UIColor.AuxiliaryColor()
        labelContent.font = UIFont.systemFontOfSize(14)
        labelContent.setHeight(content.stringHeightWith(14, width: globalWidth - padding * 2))
        labelContent.numberOfLines = 0
        scrollView.addSubview(labelContent)
        
        /* 价格 */
        viewPrice = UILabel(frame: CGRectMake(0, imageHead.height() + 8, 0, 56))
        var price = data.stringAttributeForKey("cost")
        price = type != ProductType.Pro ? price : "¥ \(price)"
        viewPrice.text = price
        let w = price.stringWidthWith(14, height: 56)
        viewPrice.setWidth(w)
        viewPrice.setX(globalWidth - padding - w)
        viewPrice.textColor = UIColor.Accomplish()
        viewPrice.font = UIFont.systemFontOfSize(14)
        viewPrice.textAlignment = NSTextAlignment.Right
        scrollView.addSubview(viewPrice)
        
        /* 价格左边的图标 */
        if type != ProductType.Pro {
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
        btnMain.addTarget(self, action: #selector(Product.onClick), forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(btnMain)
        
        /* 根据是否拥有来设置按钮状态 */
        if owned == "0" {
            setButtonEnable(Product.btnMainState.willBuy)
        } else {
            setButtonEnable(Product.btnMainState.hasBought)
        }
        
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
        if type == ProductType.Pro {
            dataArray = [["title": "购买优惠", "content": "念币商店表情、主题 30% 的折扣。", "image": "vip_discount"], ["title": "身份标识", "content": "每条进展都有好看的会员标识。", "image": "vip_mark"], ["title": "表达你的喜爱", "content": "蟹蟹你对念的支持 :))", "image": "vip_love"]]
            let w = globalWidth - padding * 2
            let h: CGFloat = 72
            let wCollectionView = globalWidth
            let hCollectionView = CGFloat(dataArray.count) * h
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: w, height: h)
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            frame = CGRectMake(0, viewLine.bottom() + 20, wCollectionView, hCollectionView)
            cell = "ProductCollectionCell"
            heightContentSize = hCollectionView
        } else if type == ProductType.Emoji {
            let code = data.stringAttributeForKey("code")
            dataArray = [
                ["image": "http://img.nian.so/emoji/\(code)/1.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/2.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/3.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/4.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/5.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/6.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/7.gif"],
                ["image": "http://img.nian.so/emoji/\(code)/8.gif"],
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
        } else if type == ProductType.Plugin {
            dataArray = []
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: 10, height: 10)
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
        /* 如果是会员 */
        if type == ProductType.Pro {
            niAlert = NIAlert()
            niAlert.delegate = self
            niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "pay_wallet")!, "购买", "选择一种支付方式", ["微信支付", "支付宝支付"]], forKeys: ["img", "title", "content", "buttonArray"])
            niAlert.showWithAnimation(.flip)
        } else if type == ProductType.Emoji {
            niAlert = NIAlert()
            niAlert.delegate = self
            niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "pay_wallet")!, "购买表情", "确定购买吗？", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
            niAlert.showWithAnimation(.flip)
        } else if type == ProductType.Plugin {
            let name = data.stringAttributeForKey("name")
            if name == "请假" {
                niAlert = NIAlert()
                niAlert.delegate = self
                niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "pay_wallet")!, "请假", "确定购买吗？", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                niAlert.showWithAnimation(.flip)
            } else if name == "推广" {
                let vc = Promo()
                self.navigationController?.pushViewController(vc, animated: true)
            } else if name == "毕业证" {
                niAlert = NIAlert()
                niAlert.delegate = self
                niAlert.dict = NSMutableDictionary(objects: [UIImage(named: "pay_wallet")!, "毕业证", "确定购买吗？", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                niAlert.showWithAnimation(.flip)
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
            btnMain.backgroundColor = UIColor.HighlightColor()
            btnMain.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
        } else {
            btnMain.backgroundColor = UIColor.WindowColor()
            btnMain.setTitleColor(UIColor.secAuxiliaryColor(), forState: UIControlState())
        }
    }
    
    /* 微信购买会员回调 */
    func onWechatResult(sender: NSNotification) {
        if let object = sender.object as? String {
            if object == "0" {
                payMemberSuccess()
            } else if object == "-1" {
                payMemberFailed()
            } else {
                payMemberCancel()
            }
        }
    }
}