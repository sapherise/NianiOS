//
//  SATextField.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

protocol delegateInput {
    
    /* 获取键盘高度 */
    var keyboardHeight: CGFloat { get set }
    var Locking: Bool { get set }
    var tableView: UITableView! { get set }
    
    /* 按下 Send 后的操作 */
    func send(replyContent: String, type: String)
}

class InputView: UIView, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, delegateEmoji {
    let heightCell: CGFloat = 56
    let widthImageHead: CGFloat = 32
    let heightImageHead: CGFloat = 32
    let widthUpload: CGFloat = 44
    let padding: CGFloat = 16
    let heightInputMax: CGFloat = 75
    let widthEmoji: CGFloat = 44
    var delegate: delegateInput?
    var heightInputOneLine: CGFloat = 0
    var imageEmoji: UIImageView!
    var isEmojing = false
    var viewEmoji: UIView!
    var imageUpload: UIImageView?
    var tableView: UITableView!
    var dataArray = NSMutableArray()
    var collectionView: UICollectionView!
    
    var inputType = inputTypeEnum.comment
    
    /* 类型 */
    enum inputTypeEnum {
        case comment
        case letter
    }
    
    /* 空状态引导去购买表情 */
    var viewCollectionHolder: UIView!
    var imageCollectionHolder: UIImageView!
    var titleCollectionHolder: UILabel!
    var contentCollectionHolder: UILabel!
    var btnCollectionHolder: UIButton!
    
    var viewEmojiHolder: FLAnimatedImageView!
    
    /* 当前选择的图片 */
    var current = 0
    
    /* 表情键盘的高度 */
    let heightEmoji: CGFloat = 224
    
    
    var labelPlaceHolder: UILabel!
    
    /* 输入框 */
    var inputKeyboard: UITextView!
    
    /* 输入框的头像 */
    var imageHead: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: CGRectMake(0, globalHeight - heightCell, globalWidth, 56))
        self.backgroundColor = UIColor.BackgroundColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        /* 输入框 */
        var widthInput = globalWidth - padding * 3 - widthEmoji - widthImageHead
        if inputType == inputTypeEnum.letter {
            widthInput = widthInput - widthUpload
        }
        
        inputKeyboard = UITextView()
        inputKeyboard.frame = CGRectMake(padding * 2 + widthImageHead, 0, widthInput, 0)
        inputKeyboard.font = UIFont.systemFontOfSize(12)
        inputKeyboard.returnKeyType = UIReturnKeyType.Send
        inputKeyboard.delegate = self
        inputKeyboard.layoutManager.allowsNonContiguousLayout = false
        inputKeyboard.scrollsToTop = false
        heightInputOneLine = resize()
        inputKeyboard.setY((heightCell - heightInputOneLine)/2)
        
        /* 输入框左侧的头像 */
        imageHead = UIImageView(frame: CGRectMake(padding, (heightCell - heightImageHead)/2, widthImageHead, heightImageHead))
        imageHead.setHead(SAUid())
        imageHead.layer.cornerRadius = 16
        imageHead.layer.masksToBounds = true
        
        /* placeHolder */
        labelPlaceHolder = UILabel(frame: CGRectMake(5, 0, inputKeyboard.width(), heightInputOneLine))
        labelPlaceHolder.text = "回应一下！"
        labelPlaceHolder.textColor = UIColor.secAuxiliaryColor()
        labelPlaceHolder.font = UIFont.systemFontOfSize(12)
        
        self.addSubview(inputKeyboard)
        self.addSubview(imageHead)
        inputKeyboard.addSubview(labelPlaceHolder)
        
        /* 表情输入 */
        imageEmoji = UIImageView(frame: CGRectMake(globalWidth - widthEmoji - padding, (heightCell - widthEmoji) / 2, widthEmoji, widthEmoji))
        imageEmoji.image = UIImage(named: "keyemoji")
        self.addSubview(imageEmoji)
        
        /* 发送图片 */
        if inputType == inputTypeEnum.letter {
            imageUpload = UIImageView(frame: CGRectMake(globalWidth - widthEmoji - padding - widthUpload, (heightCell - widthEmoji) / 2, widthEmoji, widthEmoji))
            imageUpload?.image = UIImage(named: "keyimage")
            imageUpload?.userInteractionEnabled = true
            self.addSubview(imageUpload!)
        }
        
        /* 分割线 */
        let viewLine = UIView(frame: CGRectMake(0, 0, globalWidth, globalHalf))
        viewLine.backgroundColor = UIColor.LineColor()
        self.addSubview(viewLine)
        
        /* 绑定事件 */
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTap"))
        self.userInteractionEnabled = true
        imageEmoji.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onEmoji"))
        imageEmoji.userInteractionEnabled = true
        
        /* 表情键盘构建 */
        viewEmoji = UIView(frame: CGRectMake(0, globalHeight, globalWidth, heightEmoji))
        viewEmoji.backgroundColor = UIColor.BackgroundColor()
        viewEmoji.hidden = true
        
        /* 默认是 iPhone 6 */
        var paddingH: CGFloat = 20
        var paddingV: CGFloat = 8
        var w = (heightEmoji - 44 - paddingV * 2)/2
        
        /* iPhone 4 */
        if globalWidth == 320 {
            paddingH = 0
            paddingV = (heightEmoji - globalWidth/2 - 44) / 2
            w = globalWidth/4
        } else if globalWidth == 414 {
            /* iPhone 6 Plus */
            paddingH = 0
        }
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: paddingV, left: paddingH, bottom: paddingV, right: paddingH)
        collectionView = UICollectionView(frame: CGRectMake(0, 0, globalWidth, heightEmoji - 44), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.BackgroundColor()
        collectionView.registerNib(UINib(nibName: "EmojiCollectionCell", bundle: nil), forCellWithReuseIdentifier: "EmojiCollectionCell")
        collectionView.alwaysBounceHorizontal = true
        viewEmoji.addSubview(collectionView)
        
        /* 当表情未购买时的说明 */
        viewCollectionHolder = UIView(frame: CGRectMake(0, 0, globalWidth, heightEmoji - 44))
        viewCollectionHolder.backgroundColor = UIColor.BackgroundColor()
        viewEmoji.addSubview(viewCollectionHolder)
        
        /* 当未下载时候显示的引导 */
        let p: CGFloat = 16
        let wImage: CGFloat = 96
        let hTitle: CGFloat = 18
        let wBtn: CGFloat = 96
        let hBtn: CGFloat = 36
        
        imageCollectionHolder = UIImageView(frame: CGRectMake(p, p, wImage, wImage))
        imageCollectionHolder.backgroundColor = UIColor.HighlightColor()
        imageCollectionHolder.layer.masksToBounds = true
        imageCollectionHolder.layer.cornerRadius = 8
        viewCollectionHolder.addSubview(imageCollectionHolder)
        
        titleCollectionHolder = UILabel(frame: CGRectMake(wImage + 2 * p, p, globalWidth - wImage - 3 * p, hTitle))
        titleCollectionHolder.text = "标题"
        titleCollectionHolder.textColor = UIColor.MainColor()
        viewCollectionHolder.addSubview(titleCollectionHolder)
        
        contentCollectionHolder = UILabel(frame: CGRectMake(wImage + 2 * p, p * 2 + hTitle, globalWidth - wImage - 3 * p, heightEmoji - 44 - p * 3 - hBtn))
        contentCollectionHolder.text = "正文"
        contentCollectionHolder.textColor = UIColor.MainColor()
        contentCollectionHolder.numberOfLines = 0
        contentCollectionHolder.textColor = UIColor.AuxiliaryColor()
        contentCollectionHolder.font = UIFont.systemFontOfSize(14)
        viewCollectionHolder.addSubview(contentCollectionHolder)
        
        btnCollectionHolder = UIButton(frame: CGRectMake(globalWidth - wBtn - p, heightEmoji - 44 - p - hBtn, wBtn, hBtn))
        btnCollectionHolder.backgroundColor = UIColor.HighlightColor()
        btnCollectionHolder.layer.cornerRadius = hBtn / 2
        btnCollectionHolder.layer.masksToBounds = true
        btnCollectionHolder.titleLabel?.font = UIFont.systemFontOfSize(14)
        btnCollectionHolder.setTitleColor(UIColor.BackgroundColor(), forState: UIControlState())
        btnCollectionHolder.setTitle("购买", forState: UIControlState())
        btnCollectionHolder.addTarget(self, action: "onProduct", forControlEvents: UIControlEvents.TouchUpInside)
        viewCollectionHolder.addSubview(btnCollectionHolder)
        
        let v1 = UIView(frame: CGRectMake(0, 0, globalWidth, globalHalf))
        v1.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v1)
        
        let v2 = UIView(frame: CGRectMake(0, heightEmoji - 44 - globalHalf, globalWidth, globalHalf))
        v2.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v2)
        
        /* 可滚动的表情选择 */
        tableView = UITableView()
        tableView.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        tableView.frame = CGRectMake(0, heightEmoji - 44, globalWidth - 44, 44)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        tableView.registerNib(UINib(nibName: "EmojiCell", bundle: nil), forCellReuseIdentifier: "EmojiCell")
        viewEmoji.addSubview(tableView)
        
        /* 前往表情商店 */
        let imageStore = UIImageView(frame: CGRectMake(globalWidth - 44, heightEmoji - 44, 44, 44))
        imageStore.image = UIImage(named: "keysettings")
        imageStore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onStore"))
        imageStore.userInteractionEnabled = true
        viewEmoji.addSubview(imageStore)
        
        let v3 = UIView(frame: CGRectMake(globalWidth - 44, heightEmoji - 44, globalHalf, 44))
        v3.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v3)
        
        /*  查看表情动图的视图 */
        viewEmojiHolder = FLAnimatedImageView()
        viewEmojiHolder.backgroundColor = UIColor(white: 1, alpha: 0.9)
        viewEmojiHolder.layer.borderColor = UIColor.LineColor().CGColor
        viewEmojiHolder.layer.borderWidth = 0.5
        viewEmojiHolder.layer.cornerRadius = 4
        viewEmojiHolder.layer.masksToBounds = true
        viewEmojiHolder.hidden = true
        viewEmoji.addSubview(viewEmojiHolder)
        
        tableView.scrollsToTop = false
        collectionView.scrollsToTop = false
    }
    
    /* 弹起系统自带键盘 */
    func onTap() {
        inputKeyboard.becomeFirstResponder()
        resignEmoji()
    }
    
    /* 移除表情键盘 */
    func resignEmoji() {
        self.isEmojing = false
        
        /* 修改表情按钮为笑脸 */
        imageEmoji.image = UIImage(named: "keyemoji")
        
        /* 移除表情键盘 */
        if let v = viewEmoji {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                v.setY(globalHeight)
                }, completion: { (Bool) -> Void in
                    v.removeFromSuperview()
            })
        }
    }
    
    /* 点击表情按钮 */
    func onEmoji() {
        /* 如果不是表情键盘 */
        if !isEmojing {
            self.isEmojing = true
            imageEmoji.image = UIImage(named: "keyboard")
            delegate?.Locking = true
            self.delegate?.keyboardHeight = heightEmoji
            inputKeyboard.resignFirstResponder()
            viewEmoji.hidden = false
            /* 设置表情的界面 */
            self.findRootViewController()?.view.addSubview(viewEmoji)
            load()
            UIView.animateWithDuration(0.3, animations: { () -> Void in
//                self.delegate?.resize()
                self.resizeTableView()
                self.viewEmoji.setY(globalHeight - self.heightEmoji)
                }) { (Bool) -> Void in
                    self.delegate?.Locking = false
            }
            
        } else {
            /* 如果是表情键盘，弹出自带键盘 */
            onTap()
        }
    }
    
    /* 根据内容来调整输入框高度 */
    func resize() -> CGFloat {
        let size = CGSizeMake(inputKeyboard.contentSize.width, CGFloat.max)
        let h = min(inputKeyboard.sizeThatFits(size).height, heightInputMax)
        self.inputKeyboard.frame.size.height = h
        return h
    }
    
    /* 根据输入框高度来调整整个视图 */
    func resizeView(heightInput: CGFloat) -> CGFloat {
        let h = heightInput + heightCell - heightInputOneLine
        let heightOrigin = self.height()
        if h != heightOrigin {
            self.imageHead.setY(heightOrigin - self.imageHead.height() - (self.heightCell - self.imageHead.height()) / 2)
            self.imageEmoji.setY(heightOrigin - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
            self.imageUpload?.setY(heightOrigin - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
            self.setY(globalHeight - heightOrigin - delegate!.keyboardHeight)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.imageHead.setY(h - self.imageHead.height() - (self.heightCell - self.imageHead.height()) / 2)
                self.imageEmoji.setY(h - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
                self.imageUpload?.setY(h - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
                self.setHeight(h)
                self.resizeTableView()
            })
        }
        return h
    }
    
    func load() {
        if let emojis = Cookies.get("emojis") as? NSMutableArray {
            var i = 0
            dataArray.removeAllObjects()
            for _emoji in emojis {
                if let emoji = _emoji as? NSDictionary {
                    let e = NSMutableDictionary(dictionary: emoji)
                    let isClicked = i == current ? "1" : "0"
                    e.setValue(isClicked, forKey: "isClicked")
                    dataArray.addObject(e)
                }
                i++
            }
            tableView.reloadData()
            collectionView.reloadData()
        } else {
            let loading = UIActivityIndicatorView()
            loading.center = collectionView.center
            loading.color = UIColor.HighlightColor()
            loading.startAnimating()
            collectionView.addSubview(loading)
            Api.getEmoji() { json in
                if json != nil {
                    self.dataArray.removeAllObjects()
                    let items = json!.objectForKey("data") as! NSArray
                    var i = 0
                    for _item in items {
                        if let item = _item as? NSDictionary {
                            let type = item.stringAttributeForKey("type")
                            if type == "expression" {
                                let e = NSMutableDictionary(dictionary: item)
                                let isClicked = i == self.current ? "1" : "0"
                                e.setValue(isClicked, forKey: "isClicked")
                                self.dataArray.addObject(e)
                            }
                        }
                        i++
                    }
                    Cookies.set(self.dataArray, forKey: "emojis")
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    loading.removeFromSuperview()
                }
            }
        }
    }
    
    /*  调整 tableView 的高度
    **  调整输入框的坐标
    */
    func resizeTableView() {
        if let de = delegate {
            let h = globalHeight - self.height() - 64 - de.keyboardHeight
            
            /* 当 tableview 原来就是在底部的时候，才选择继续滚到底部 */
            let h1 = de.tableView.contentSize.height - de.tableView.height()
            if de.tableView.contentOffset.y == h1 || h1 < 0 {
                de.tableView.contentOffset.y = max(de.tableView.contentSize.height - h, 0)
            }
            de.tableView.setHeight(h)
            self.setY(h + 64)
        }
    }
    
    /* 前往购买表情 */
    func onProduct() {
        if dataArray.count > current {
            let vc = Product()
            let data = dataArray[current] as! NSDictionary
            vc.type = Product.ProductType.Emoji
            vc.data = data
            vc.delegate = self
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onStore() {
        let vc = ProductList()
        vc.name = "表情"
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}