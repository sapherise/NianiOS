//
//  AddTopic.swift
//  Nian iOS
//
//  Created by Sa on 15/9/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

@objc protocol AddstepDelegate {
    func Editstep()
    @objc optional func countUp(_ coin: String, isfirst: String)
    @objc optional func countUp(_ coin: String, total: String, isfirst: String)
    @objc optional func update(_ data: NSDictionary)
    var editStepRow:Int { get set }
    var editStepData:NSDictionary? { get set }
}

class AddStep: SAViewController, UIActionSheetDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, imagesPickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, upYunDelegate, ShareDelegate {
    
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
    let queue = OperationQueue()
    
    /* 多图上传传递给服务器的数组 */
    var uploadArray = NSMutableArray()
    
    /* 是否编辑 */
    var willEdit = false
    
    /* 编辑的数据 */
    var dataEdit: NSDictionary?
    var rowEdit = -1
    var delegate: AddstepDelegate?
    
    /* 第一次进入要 focus，但是上传图片之类的就不要 focus 了 */
    var isFirstTimeToAppear = true
    
    /* 如果是编辑的图片，就跳过上传 */
    var hasUploadedArray: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        /* 如果是新增进展，返回的时候保存到草稿中 */
        if !willEdit {
            let content = field2.text
            if content != nil {
                Cookies.set(content as AnyObject?, forKey: "draft")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(self.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !willEdit && isFirstTimeToAppear {
            isFirstTimeToAppear = false
            field2.becomeFirstResponder()
        }
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        _setTitle("新进展！")
        setBarButtonImage("newOK", actionGesture: #selector(self.add))
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: #selector(AddStep.dismissKeyboard))
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)
        
        /* 设置 scrollView */
        let rect = CGRect(x: 0, y: self.seperatorView.bottom(), width: globalWidth, height: globalHeight - self.viewDream.height() - 64 - viewHolder.height() - seperatorView2.height() * 2)
        scrollView.frame = rect
        scrollView.contentSize = CGSize(width: scrollView.width(), height: size_height_contentsize + size_field_padding * 2)
        
        /* 设置 UICollectionView */
        let w = (globalWidth - size_field_padding * 2 - size_collectionview_padding * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = size_collectionview_padding
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: CGRect(x: size_field_padding, y: size_field_padding, width: rect.width - size_field_padding * 2, height: 0), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UINib(nibName: "AddStepImageCell", bundle: nil), forCellWithReuseIdentifier: "AddStepImageCell")
        scrollView.addSubview(collectionView)
        
        /* 设置 field2 */
        field2.frame = CGRect(x: size_field_padding, y: collectionView.bottom(), width: rect.width - size_field_padding * 2, height: scrollView.height() - size_field_padding * 2 - collectionView.height())
        labelPlaceholder.frame.origin = CGPoint(x: field2.x() + 6, y: field2.y() + 6)
        
        seperatorView.setWidth(globalWidth)
        seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        seperatorView2.setWidth(globalWidth)
        seperatorView2.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        seperatorView2.setY(self.scrollView.bottom())
        viewHolder.setY(seperatorView2.bottom())
        imageUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddStep.onImage)))
        
        /* 初始化 UITableView*/
        tableView = UITableView(frame: CGRect(x: 0, y: seperatorView.bottom(), width: globalWidth, height: 0))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "AddStepCell", bundle: nil), forCellReuseIdentifier: "AddStepCell")
        tableView.isHidden = true
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        
        self.viewDream.setWidth(globalWidth)
        if !willEdit {
            self.viewDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onViewDream)))
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
                    let title = (data as AnyObject).object(forKey: "title") as! String
                    let image = (data as AnyObject).object(forKey: "image") as! String
                    let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                    self.imageDream.setImage(userImageURL)
                    self.idDream = id
                    self.labelDream.text = title.decode()
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
                        let title = (data as AnyObject).object(forKey: "title") as! String
                        let image = (data as AnyObject).object(forKey: "image") as! String
                        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                        self.imageDream.setImage(userImageURL)
                        self.idDream = id
                        self.labelDream.text = title.decode()
                        count = 1
                        break
                    }
                }
            }
            
            if count == 0 {
                if dataArray.count > 0 {
                    let data = dataArray[0] as! NSDictionary
                    let id = data.stringAttributeForKey("id")
                    let title = data.stringAttributeForKey("title")
                    let image = data.stringAttributeForKey("image")
                    let userImageURL = "http://img.nian.so/dream/\(image)!dream"
                    self.imageDream.setImage(userImageURL)
                    self.idDream = id
                    self.labelDream.text = title.decode()
                }
            }
        }
        
        /* 设置箭头位置*/
        imageArrow.setX(globalWidth - 10 - imageArrow.width())
        if willEdit {
            imageArrow.isHidden = true
        }
        
        self.view.backgroundColor = UIColor.white
        self.field2.delegate = self
        
        /* 如果传入的 dataEdit 不为空，先提取出相关的内容 */
        if dataEdit != nil {
            let content = dataEdit!.stringAttributeForKey("content")
            if let images = dataEdit!.object(forKey: "images") as? NSArray {
                if images.count > 0 {
                    for i in 0...(images.count - 1) {
                        let image = images[i] as! NSDictionary
                        let path = image.stringAttributeForKey("path")
                        var imageCache = SDImageCache.shared().imageFromDiskCache(forKey: "http://img.nian.so/step/\(path)!large")
                        if imageCache == nil {
                            imageCache = SDImageCache.shared().imageFromDiskCache(forKey: "http://img.nian.so/step/\(path)!200x")
                        }
                        if imageCache != nil {
                            imageArray.append(imageCache!)
                            hasUploadedArray.append(i)
                        }
                    }
                }
            }
            field2.text = content
            if content != "" {
                labelPlaceholder.isHidden = true
            }
            reLayout()
        } else {
            /* 草稿功能完成 */
            if let draft = Cookies.get("draft") as? String {
                if draft != "" {
                    field2.text = draft
                    labelPlaceholder.isHidden = true
                }
            }
        }
    }
    
    func dismissKeyboard() {
        self.field2.resignFirstResponder()
    }
    
    /* tableView */
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "AddStepCell", for: indexPath) as! AddStepCell
        let data = self.dataArray[(indexPath as NSIndexPath).row] as? NSDictionary
        c.data = data
        c.setup()
        return c
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let title = data.stringAttributeForKey("title").decode()
        let image = data.stringAttributeForKey("image")
        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
        self.imageDream.setImage(userImageURL)
        self.idDream = id
        self.labelDream.text = title
        
        tableView.isHidden = true
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.imageArrow.transform = CGAffineTransform(rotationAngle: 0)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        field2.resignFirstResponder()
        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet.addButton(withTitle: "移除")
        actionSheet.addButton(withTitle: "取消")
        actionSheet.cancelButtonIndex = 1
        actionSheet.show(in: self.view)
        rowDelete = (indexPath as NSIndexPath).row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c: AddStepImageCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStepImageCell", for: indexPath) as? AddStepImageCell
        c.image = imageArray[(indexPath as NSIndexPath).row]
        c.setup()
        return c
    }
    
    /* ActionSheet */
    @objc(actionSheet:clickedButtonAtIndex:) func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            if rowDelete >= 0 {
                imageArray.remove(at: rowDelete)
                hasUploadedArray.remove(at: rowDelete)
                reLayout()
            }
        }
    }
    
    /* shareDelegate */
    func onShare(_ avc: UIActivityViewController) {
        self.present(avc, animated: true, completion: nil)
    }
}
