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
    func send(_ replyContent: String, type: String)
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
        super.init(frame: CGRect(x: 0, y: globalHeight - heightCell, width: globalWidth, height: 56))
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
        inputKeyboard.frame = CGRect(x: padding * 2 + widthImageHead, y: 0, width: widthInput, height: 0)
        inputKeyboard.font = UIFont.systemFont(ofSize: 12)
        inputKeyboard.returnKeyType = UIReturnKeyType.send
        inputKeyboard.delegate = self
        inputKeyboard.layoutManager.allowsNonContiguousLayout = false
        inputKeyboard.scrollsToTop = false
        heightInputOneLine = resize()
        inputKeyboard.setY((heightCell - heightInputOneLine)/2)
        
        /* 输入框左侧的头像 */
        imageHead = UIImageView(frame: CGRect(x: padding, y: (heightCell - heightImageHead)/2, width: widthImageHead, height: heightImageHead))
        imageHead.setHead(SAUid())
        imageHead.layer.cornerRadius = 16
        imageHead.layer.masksToBounds = true
        
        /* placeHolder */
        labelPlaceHolder = UILabel(frame: CGRect(x: 5, y: 0, width: inputKeyboard.width(), height: heightInputOneLine))
        labelPlaceHolder.text = "回应一下！"
        labelPlaceHolder.textColor = UIColor.secAuxiliaryColor()
        labelPlaceHolder.font = UIFont.systemFont(ofSize: 12)
        
        self.addSubview(inputKeyboard)
        self.addSubview(imageHead)
        inputKeyboard.addSubview(labelPlaceHolder)
        
        /* 表情输入 */
        imageEmoji = UIImageView(frame: CGRect(x: globalWidth - widthEmoji - padding, y: (heightCell - widthEmoji) / 2, width: widthEmoji, height: widthEmoji))
        imageEmoji.image = UIImage(named: "keyemoji")
        self.addSubview(imageEmoji)
        
        /* 发送图片 */
        if inputType == inputTypeEnum.letter {
            imageUpload = UIImageView(frame: CGRect(x: globalWidth - widthEmoji - padding - widthUpload, y: (heightCell - widthEmoji) / 2, width: widthEmoji, height: widthEmoji))
            imageUpload?.image = UIImage(named: "keyimage")
            imageUpload?.isUserInteractionEnabled = true
            self.addSubview(imageUpload!)
        }
        
        /* 分割线 */
        let viewLine = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHalf))
        viewLine.backgroundColor = UIColor.LineColor()
        self.addSubview(viewLine)
        
        /* 绑定事件 */
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputView.onTap)))
        self.isUserInteractionEnabled = true
        imageEmoji.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputView.onEmoji)))
        imageEmoji.isUserInteractionEnabled = true
        
        /* 表情键盘构建 */
        viewEmoji = UIView(frame: CGRect(x: 0, y: globalHeight, width: globalWidth, height: heightEmoji))
        viewEmoji.backgroundColor = UIColor.BackgroundColor()
        viewEmoji.isHidden = true
        
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
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: heightEmoji - 44), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.BackgroundColor()
        collectionView.register(UINib(nibName: "EmojiCollectionCell", bundle: nil), forCellWithReuseIdentifier: "EmojiCollectionCell")
        collectionView.alwaysBounceHorizontal = true
        viewEmoji.addSubview(collectionView)
        
        /* 当表情未购买时的说明 */
        viewCollectionHolder = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: heightEmoji - 44))
        viewCollectionHolder.backgroundColor = UIColor.BackgroundColor()
        viewEmoji.addSubview(viewCollectionHolder)
        
        /* 当未下载时候显示的引导 */
        let p: CGFloat = 16
        let wImage: CGFloat = 96
        let hTitle: CGFloat = 18
        let wBtn: CGFloat = 96
        let hBtn: CGFloat = 36
        
        imageCollectionHolder = UIImageView(frame: CGRect(x: p, y: p, width: wImage, height: wImage))
        imageCollectionHolder.backgroundColor = UIColor.HighlightColor()
        imageCollectionHolder.layer.masksToBounds = true
        imageCollectionHolder.layer.cornerRadius = 8
        viewCollectionHolder.addSubview(imageCollectionHolder)
        
        titleCollectionHolder = UILabel(frame: CGRect(x: wImage + 2 * p, y: p, width: globalWidth - wImage - 3 * p, height: hTitle))
        titleCollectionHolder.text = "标题"
        titleCollectionHolder.textColor = UIColor.MainColor()
        viewCollectionHolder.addSubview(titleCollectionHolder)
        
        contentCollectionHolder = UILabel(frame: CGRect(x: wImage + 2 * p, y: p * 2 + hTitle, width: globalWidth - wImage - 3 * p, height: heightEmoji - 44 - p * 3 - hBtn))
        contentCollectionHolder.text = "正文"
        contentCollectionHolder.textColor = UIColor.MainColor()
        contentCollectionHolder.numberOfLines = 0
        contentCollectionHolder.textColor = UIColor.AuxiliaryColor()
        contentCollectionHolder.font = UIFont.systemFont(ofSize: 14)
        viewCollectionHolder.addSubview(contentCollectionHolder)
        
        btnCollectionHolder = UIButton(frame: CGRect(x: globalWidth - wBtn - p, y: heightEmoji - 44 - p - hBtn, width: wBtn, height: hBtn))
        btnCollectionHolder.backgroundColor = UIColor.HighlightColor()
        btnCollectionHolder.layer.cornerRadius = hBtn / 2
        btnCollectionHolder.layer.masksToBounds = true
        btnCollectionHolder.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btnCollectionHolder.setTitleColor(UIColor.BackgroundColor(), for: UIControlState())
        btnCollectionHolder.setTitle("购买", for: UIControlState())
        btnCollectionHolder.addTarget(self, action: #selector(InputView.onProduct), for: UIControlEvents.touchUpInside)
        viewCollectionHolder.addSubview(btnCollectionHolder)
        
        let v1 = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHalf))
        v1.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v1)
        
        let v2 = UIView(frame: CGRect(x: 0, y: heightEmoji - 44 - globalHalf, width: globalWidth, height: globalHalf))
        v2.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v2)
        
        /* 可滚动的表情选择 */
        tableView = UITableView()
        tableView.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI/2))
        tableView.frame = CGRect(x: 0, y: heightEmoji - 44, width: globalWidth - 44, height: 44)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "EmojiCell", bundle: nil), forCellReuseIdentifier: "EmojiCell")
        viewEmoji.addSubview(tableView)
        
        /* 前往表情商店 */
        let imageStore = UIImageView(frame: CGRect(x: globalWidth - 44, y: heightEmoji - 44, width: 44, height: 44))
        imageStore.image = UIImage(named: "keysettings")
        imageStore.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputView.onStore)))
        imageStore.isUserInteractionEnabled = true
        viewEmoji.addSubview(imageStore)
        
        let v3 = UIView(frame: CGRect(x: globalWidth - 44, y: heightEmoji - 44, width: globalHalf, height: 44))
        v3.backgroundColor = UIColor.LineColor()
        viewEmoji.addSubview(v3)
        
        /*  查看表情动图的视图 */
        viewEmojiHolder = FLAnimatedImageView()
        viewEmojiHolder.backgroundColor = UIColor(white: 1, alpha: 0.9)
        viewEmojiHolder.layer.borderColor = UIColor.LineColor().cgColor
        viewEmojiHolder.layer.borderWidth = 0.5
        viewEmojiHolder.layer.cornerRadius = 4
        viewEmojiHolder.layer.masksToBounds = true
        viewEmojiHolder.isHidden = true
        viewEmoji.addSubview(viewEmojiHolder)
        
        tableView.scrollsToTop = false
        collectionView.scrollsToTop = false
    }
    
    /* 弹起系统自带键盘 */
    @objc func onTap() {
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
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                v.setY(globalHeight)
                }, completion: { (Bool) -> Void in
                    v.removeFromSuperview()
            })
        }
    }
    
    /* 点击表情按钮 */
    @objc func onEmoji() {
        /* 如果不是表情键盘 */
        if !isEmojing {
            self.isEmojing = true
            imageEmoji.image = UIImage(named: "keyboard")
            delegate?.Locking = true
            self.delegate?.keyboardHeight = heightEmoji
            inputKeyboard.resignFirstResponder()
            viewEmoji.isHidden = false
            /* 设置表情的界面 */
            self.findRootViewController()?.view.addSubview(viewEmoji)
            load()
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
//                self.delegate?.resize()
                self.resizeTableView()
                self.viewEmoji.setY(globalHeight - self.heightEmoji)
                }, completion: { (Bool) -> Void in
                    self.delegate?.Locking = false
            }) 
            
        } else {
            /* 如果是表情键盘，弹出自带键盘 */
            onTap()
        }
    }
    
    /* 根据内容来调整输入框高度 */
    func resize() -> CGFloat {
        let size = CGSize(width: inputKeyboard.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        let h = min(inputKeyboard.sizeThatFits(size).height, heightInputMax)
        self.inputKeyboard.frame.size.height = h
        return h
    }
    
    /* 根据输入框高度来调整整个视图 */
    func resizeView(_ heightInput: CGFloat) -> CGFloat {
        let h = heightInput + heightCell - heightInputOneLine
        let heightOrigin = self.height()
        if h != heightOrigin {
            self.imageHead.setY(heightOrigin - self.imageHead.height() - (self.heightCell - self.imageHead.height()) / 2)
            self.imageEmoji.setY(heightOrigin - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
            self.imageUpload?.setY(heightOrigin - self.imageEmoji.height() - (self.heightCell - self.imageEmoji.height()) / 2)
            self.setY(globalHeight - heightOrigin - delegate!.keyboardHeight)
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
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
                    dataArray.add(e)
                }
                i += 1
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
                    let items = json!.object(forKey: "data") as! NSArray
                    var i = 0
                    for _item in items {
                        if let item = _item as? NSDictionary {
                            let type = item.stringAttributeForKey("type")
                            if type == "expression" {
                                let e = NSMutableDictionary(dictionary: item)
                                let isClicked = i == self.current ? "1" : "0"
                                e.setValue(isClicked, forKey: "isClicked")
                                self.dataArray.add(e)
                            }
                        }
                        i += 1
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
    @objc func onProduct() {
        if dataArray.count > current {
            let vc = Product()
            let data = dataArray[current] as! NSDictionary
            vc.type = Product.ProductType.emoji
            vc.data = data
            vc.delegate = self
            self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func onStore() {
        let vc = ProductList()
        vc.name = "表情"
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}
