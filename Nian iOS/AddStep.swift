//
//  AddTopic.swift
//  Nian iOS
//
//  Created by Sa on 15/9/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import AssetsLibrary

@objc protocol AddstepDelegate {
    func Editstep()
    optional func countUp(coin: String, isfirst: String)
    optional func countUp(coin: String, total: String, isfirst: String)
    optional func update(data: NSDictionary)
    var editStepRow:Int { get set }
    var editStepData:NSDictionary? { get set }
}

class AddStep: SAViewController, UIActionSheetDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, LSYAlbumPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, upYunDelegate, ShareDelegate {
    
    @IBOutlet var viewDream: UIView!
    @IBOutlet var field2: UITextView!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var imageUpload: UIImageView!
    @IBOutlet var seperatorView2: UIView!
    @IBOutlet var labelPlaceholder: UILabel!
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageArrow: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var collectionView: UICollectionView!
    let size_field_padding: CGFloat = 12
    let size_collectionview_padding: CGFloat = 8
    let size_height_contentsize: CGFloat = 100
    
    var actionSheet: UIActionSheet!
    var rowDelete = -1
    var dict = NSMutableDictionary()
    var id: String = ""
    var idDream: String = "-1"
    var imageArray: [AnyObject] = []
    
    var keyboardHeight: CGFloat = 0.0  // 键盘的高度
    var dataArray = NSMutableArray()
    var tableView: UITableView!
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    /* 多图上传 */
    let queue = NSOperationQueue()
    
    /* 多图上传传递给服务器的数组 */
    var uploadArray = NSMutableArray()
    
    /* 是否编辑 */
    var willEdit = false
    
    /* 编辑的数据 */
    var dataEdit: NSDictionary?
    var rowEdit = -1
    var delegate: AddstepDelegate?
    
    /* 如果是编辑的图片，就跳过上传 */
    var hasUploadedArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        /* 如果是新增进展，返回的时候保存到草稿中 */
        if !willEdit {
            let content = field2.text
            if content != nil {
                Cookies.set(content, forKey: "draft")
            }
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        _setTitle("新进展！")
        setBarButtonImage("newOK", actionGesture: "add")
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard")
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.Down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)
        
        /* 设置 scrollView */
        let rect = CGRectMake(0, self.seperatorView.bottom(), globalWidth, globalHeight - self.viewDream.height() - 64 - viewHolder.height() - seperatorView2.height() * 2)
        scrollView.frame = rect
        scrollView.contentSize = CGSizeMake(scrollView.width(), size_height_contentsize + size_field_padding * 2)
        
        /* 设置 UICollectionView */
        let w = (globalWidth - size_field_padding * 2 - size_collectionview_padding * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = size_collectionview_padding
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: CGRectMake(size_field_padding, size_field_padding, rect.width - size_field_padding * 2, 0), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "AddStepImageCell", bundle: nil), forCellWithReuseIdentifier: "AddStepImageCell")
        scrollView.addSubview(collectionView)
        
        /* 设置 field2 */
        field2.frame = CGRectMake(size_field_padding, collectionView.bottom(), rect.width - size_field_padding * 2, scrollView.height() - size_field_padding * 2 - collectionView.height())
        labelPlaceholder.frame.origin = CGPointMake(field2.x() + 6, field2.y() + 6)
        
        seperatorView.setWidth(globalWidth)
        seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        seperatorView2.setWidth(globalWidth)
        seperatorView2.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        seperatorView2.setY(self.scrollView.bottom())
        viewHolder.setY(seperatorView2.bottom())
        imageUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        
        /* 初始化 UITableView*/
        tableView = UITableView(frame: CGRectMake(0, seperatorView.bottom(), globalWidth, 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "AddStepCell", bundle: nil), forCellReuseIdentifier: "AddStepCell")
        tableView.hidden = true
        tableView.separatorStyle = .None
        self.view.addSubview(tableView)
        
        
        self.viewDream.setWidth(globalWidth)
        if !willEdit {
            self.viewDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onViewDream"))
        }
        
        
        /* 先判断是否有记本 id 传入
        ** 如果有的话，显示该记本
        ** 否则从缓存中拉取
        */
        if let NianDreams = Cookies.get("NianDreams") as? NSMutableArray {
            self.dataArray = NianDreams
            tableView.reloadData()
            var count = 0
            
            /* 先从传值来找到记本封面 */
            for d in dataArray {
                let id = (d as! NSDictionary).stringAttributeForKey("id")
                if idDream != "-1" && idDream == id {
                    let data = d
                    let title = data.objectForKey("title") as! String
                    let image = data.objectForKey("image") as! String
                    let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                    self.imageDream.setImage(userImageURL)
                    self.idDream = id
                    self.labelDream.text = title
                    count = 1
                    break
                }
            }
            
            /* 再从缓存中的最新来找到记本封面 */
            if count == 0 {
                for d in dataArray {
                    let id = (d as! NSDictionary).stringAttributeForKey("id")
                    if id == Cookies.get("DreamNewest") as? String {
                        let data = d
                        let title = data.objectForKey("title") as! String
                        let image = data.objectForKey("image") as! String
                        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                        self.imageDream.setImage(userImageURL)
                        self.idDream = id
                        self.labelDream.text = title
                        count = 1
                        break
                    }
                }
            }
            
            if count == 0 {
                let data = dataArray[0] as! NSDictionary
                let id = data.stringAttributeForKey("id")
                let title = data.stringAttributeForKey("title")
                let image = data.stringAttributeForKey("image")
                let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                self.imageDream.setImage(userImageURL)
                self.idDream = id
                self.labelDream.text = title
            }
        }
        
        /* 设置箭头位置*/
        imageArrow.setX(globalWidth - 10 - imageArrow.width())
        if willEdit {
            imageArrow.hidden = true
        }
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.field2.delegate = self
        
        /* 如果传入的 dataEdit 不为空，先提取出相关的内容 */
        if dataEdit != nil {
            let content = dataEdit!.stringAttributeForKey("content")
            if let images = dataEdit!.objectForKey("images") as? NSArray {
                if images.count > 0 {
                    for i in 0...(images.count - 1) {
                        let image = images[i] as! NSDictionary
                        let path = image.stringAttributeForKey("path")
                        var imageCache = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("http://img.nian.so/step/\(path)!large")
                        if imageCache == nil {
                            imageCache = SDImageCache.sharedImageCache().imageFromDiskCacheForKey("http://img.nian.so/step/\(path)!200x")
                        }
                        imageArray.append(imageCache)
                        hasUploadedArray.append(i)
                    }
                }
            }
            field2.text = content
            if content != "" {
                labelPlaceholder.hidden = true
            }
            reLayout()
        } else {
            /* 草稿功能完成 */
            if let draft = Cookies.get("draft") as? String {
                if draft != "" {
                    field2.text = draft
                    labelPlaceholder.hidden = true
                }
            }
        }
    }
    
    func dismissKeyboard() {
        self.field2.resignFirstResponder()
    }
}