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
    var collectionView: UICollectionView!
    var dataArray = NSMutableArray()
    var niAlert: NIAlert!
    var niAlertResult: NIAlert!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onWechatResult:", name: "onWechatResult", object: nil)
//            NSNotificationCenter.defaultCenter().addObserver(self, selector: "onURL:", name: "AppURL", object: nil)
    }
    
    func setup() {
        navView.backgroundColor = UIColor.clearColor()
        self.view.backgroundColor = UIColor.HightlightColor()
        
        /* 添加顶部头图 */
        imageHead = UIImageView(frame: CGRectMake(0, 0, globalWidth, globalWidth * 3/4))
        imageHead.setImage("http://img.nian.so/product/graduation.png!large")
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
        labelTitle.text = "会员"
        labelTitle.textColor = UIColor.MainColor()
        labelTitle.font = UIFont.systemFontOfSize(18)
        scrollView.addSubview(labelTitle)
        
        let content = "永久地成为念的会员，在享受念币商店 7 折优惠的基础上，还能获得一个好看的会员标识。"
        labelContent = UILabel(frame: CGRectMake(padding, labelTitle.bottom(), globalWidth - padding * 2, 24))
        labelContent.text = content
        labelContent.textColor = UIColor.AuxiliaryColor()
        labelContent.font = UIFont.systemFontOfSize(14)
        labelContent.setHeight(content.stringHeightWith(14, width: globalWidth - padding * 2))
        labelContent.numberOfLines = 0
        scrollView.addSubview(labelContent)
        
        /* 价格 */
        viewPrice = UILabel(frame: CGRectMake(padding, imageHead.height() + 8, globalWidth - padding * 2, 56))
        viewPrice.text = "¥ 120"
        viewPrice.textColor = UIColor.Accomplish()
        viewPrice.textAlignment = NSTextAlignment.Right
        scrollView.addSubview(viewPrice)
        
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
        dataArray = [["title": "购买优惠", "content": "念币商店表情、主题 30% 的折扣。", "image": "vip_discount"], ["title": "身份标识", "content": "每条进展都有好看的会员标识。", "image": "vip_mark"], ["title": "表达你的喜爱", "content": "蟹蟹你对念的支持 :))", "image": "vip_love"]]
        let w = globalWidth - padding * 2
        let h: CGFloat = 72
        let wCollectionView = w
        let hCollectionView = CGFloat(dataArray.count) * h
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: w, height: h)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: CGRectMake(padding, viewLine.bottom() + padding, wCollectionView, hCollectionView), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.BackgroundColor()
        collectionView.registerNib(UINib(nibName: "ProductCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionCell")
        collectionView.contentSize.height = hCollectionView
        scrollView.addSubview(collectionView)
        print(hCollectionView)
        print(collectionView.contentSize.height)
        scrollView.contentSize.height = collectionView.bottom() + 100
        scrollView.showsVerticalScrollIndicator = false
    }
    
    func onClick() {
        niAlert = NIAlert()
        niAlert.delegate = self
        niAlert.dict = NSMutableDictionary(objects: ["", "选择支付方式", "选择一个支付方式", ["微信支付", "支付宝支付"]], forKeys: ["img", "title", "content", "buttonArray"])
        niAlert.showWithAnimation(.flip)
    }
    
    func onWechatResult(sender: NSNotification) {
        if let object = sender.object as? String {
            print("获取到观察对象：\(object)")
            niAlertResult = NIAlert()
            niAlertResult.delegate = self
            if object == "0" {
                /* 微信支付成功 */
                niAlertResult.dict = NSMutableDictionary(objects: ["", "支付好了", "获得念的永久会员啦！\n蟹蟹你对念的支持", [" 嗯！"]], forKeys: ["img", "title", "content", "buttonArray"])
                niAlert.dismissWithAnimationSwtich(niAlertResult)
                
                /* 按钮的状态变化 */
                setButtonEnable(Product.btnMainState.hasBought)
            } else if object == "-1" {
                niAlertResult.dict = NSMutableDictionary(objects: ["", "支付不成功", "服务器坏了！", ["哦"]], forKeys: ["img", "title", "content", "buttonArray"])
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