//
//  NewAddStepViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/24/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit
import ImageIO

public let NIUploadImagesCompletionNotification: String = "NIUploadImagesCompletionNotification"

@objc protocol NewAddStepDelegate {
    func newEditstep()
    optional func newCountUp(coin: String, isfirst: String)
    optional func newCountUp(coin: String, total: String, isfirst: String)
    optional func newUpdate(data: NSDictionary)
    
    var newEditStepRow: Int { set get }
    var newEditStepData: NSDictionary? { set get }
}


class NewAddStepViewController: SAViewController {
    
    let TEXTVIEW_DEFAULT_HEIGHT: CGFloat = globalHeight <= 568 ? 96 : globalHeight == 667 ? 195 : 264
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var noteCoverView: UIImageView!
    
    @IBOutlet weak var noteTitleField: UITextField!
    
    @IBOutlet weak var indicateArrow: UIImageView!
    
    @IBOutlet weak var noteCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var contentTextView: SZTextView!

    @IBOutlet weak var scrollViewToTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var notesHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var collectionToTopContraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    
    weak var delegate: NewAddStepDelegate?
    
    var isInConvenienceWay: Bool = false
    
    var dreamArray = NSMutableArray()
    
    var data: NSMutableDictionary?
    var dreamId: String = ""
    var isEdit: Int = 0
    var row: Int = 0
    
    // 0 向下， 1 向上
    var indicateArrowDirection: Int = 0
    
    var stepType = StepType(rawValue: 0)
    
    var keyboardHeight: CGFloat = 0
    
    var imagesDataSource = NSMutableArray()
    var imagesArray = Array<UIImage>()
    var imagesShouldUpload = NSDictionary()
    var imagesInfo = NSMutableArray()
    
    private var uploadAllImagesSuccess = false
    
    var regularCellSize = CGSizeMake((globalWidth - 32 - 4)/3, (globalWidth - 32 - 4)/3)
    var largerCellSize  = CGSizeMake((globalWidth - ((globalWidth - 32 - 4)/3) - 32 - 2), (globalWidth - 32 - 4)/3)
    var largestCellSize = CGSizeMake(globalWidth - 32, (globalWidth - 32 - 4) / 3)
    
    var needUpdateTextViewHeight: Bool = true
    
    let collectionConstraintGroup = ConstraintGroup()
    let notesConstraintGroup = ConstraintGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        sp1HeightConstraint.constant = globalHalf
        
        self.noteCoverView.layer.cornerRadius = 4.0
        self.noteCoverView.layer.masksToBounds = true
        
        self.contentTextView.attributedPlaceholder = NSAttributedString(string: "进展正文" ,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        
        self.textViewHeightConstraint.constant = TEXTVIEW_DEFAULT_HEIGHT
        self.contentTextView.delegate = self
        
        self.collectionView.collectionViewLayout = yy_collectionViewLayout()
        self.collectionView.registerClass(AddStepCollectionCell.self, forCellWithReuseIdentifier: "AddStepCollectionCell")
        
        self.scrollViewToTopConstraint.constant = 64
        
        let x = (globalWidth - 240.0) / 8
        let y = x + x
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = x
        flowLayout.minimumLineSpacing = y
        flowLayout.itemSize = CGSize(width: 80, height: 120)
        flowLayout.sectionInset = UIEdgeInsetsMake(y, y, y, y)
        
        self.noteCollectionView.collectionViewLayout = flowLayout
        self.noteCollectionView.registerClass(AddStepNoteCell.self, forCellWithReuseIdentifier: "AddStepNoteCell")
        
        if self.isEdit == 1 {
            self.setFakeNaviBar(isEdit: true)
            
            self.noteCollectionView.removeFromSuperview()
            self.headerView.removeFromSuperview()
            
            self.contentTextView.text = self.data?.stringAttributeForKey("content").decode()
            
            self.imagesArray.appendContentsOf(self.data?.objectForKey("imageArray") as! [UIImage])
            
            let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
            
            self.collectionToTopContraint.constant = 16
            
            constrain(self.collectionView, replace: collectionConstraintGroup) { (view1) -> () in
                view1.height == collectionViewHeight
            }
            
            self.collectionView.reloadData()
            
        } else {
            self.setFakeNaviBar(isEdit: false)
            
            if !isInConvenienceWay {
                self.noteCollectionView.removeFromSuperview()
                self.headerView.removeFromSuperview()
                self.collectionToTopContraint.constant = 0
            } else {
                self.noteCollectionView.delegate = self
                self.noteCollectionView.dataSource = self
                self.collectionToTopContraint.constant = 64
            }
            
            constrain(self.collectionView, replace: collectionConstraintGroup) { (view1) -> () in
                view1.height == 0
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleImagesUploadCompletion:", name: NIUploadImagesCompletionNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.textViewHeightConstraint.constant = self.textViewHeight()
        self.scrollView.contentSize = CGSizeMake(self.scrollView.width(), max(globalHeight - 64, self.contentView.frame.height))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.keyboardHeight = 0
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        notificationCenter.removeObserver(self, name: NIUploadImagesCompletionNotification, object: nil)
    }
    
    // 加一个假的 NavBar
    func setFakeNaviBar(isEdit isEdit: Bool) {
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = isEdit ? "编辑进展" : "新进展"
        titleLabel.sizeToFit()
        
        let leftButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        leftButton.setImage(UIImage(named: "navigationbar_cancel"), forState: .Normal)
        leftButton.addTarget(self, action: "dismiss:", forControlEvents: .TouchUpInside)
        leftButton.highlighted = false
        
        let rightButton = UIButton(frame: CGRectMake(0, 0, 44, 44))
        rightButton.setImage(UIImage(named: "newOK"), forState: .Normal)
        if isEdit {
            rightButton.addTarget(self, action: "uploadEditStep", forControlEvents: .TouchUpInside)
        } else {
            rightButton.addTarget(self, action: "uploadNewStep", forControlEvents: .TouchUpInside)
        }
        rightButton.highlighted = false
        
        self.navView.addSubview(titleLabel)
        self.navView.addSubview(leftButton)
        self.navView.addSubview(rightButton)
        
        constrain(leftButton, rightButton) { (leftButton, rightButton) -> () in
            leftButton.top    == leftButton.superview!.top + 20
            leftButton.left   == leftButton.superview!.left
            leftButton.width  == 44
            leftButton.height == 44
            
            rightButton.top    == rightButton.superview!.top + 20
            rightButton.right  == rightButton.superview!.right
            rightButton.width  == 44
            rightButton.height == 44
        }
        
        constrain(leftButton, rightButton, titleLabel) { (leftButton, rightButton, titleLabel) -> () in
            titleLabel.centerX == titleLabel.superview!.centerX
            align(centerY: leftButton, rightButton, titleLabel)
        }
    }
    
    func textViewHeight() -> CGFloat {
        let textViewHeight = self.contentTextView.intrinsicContentSize().height
        
        return max(textViewHeight, TEXTVIEW_DEFAULT_HEIGHT)
    }
    
    @IBAction func tapOnBackground(sender: UIControl) {
        self.dismissKeyboard()
    }
    
    @IBAction func tapOnContentView(sender: UIControl) {
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
         UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    func dismiss(sender: UIButton) {
        self.dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickerImages(sender: UIButton) {
        self.dismissKeyboard()
        if self.collectionView.numberOfItemsInSection(0) == 9 {
            self.view.showTipText("请先删除几张图片")
            
            return
        }
        
        let alertController = PSTAlertController.actionSheetWithTitle(nil)
        
        alertController.addAction(PSTAlertAction(title: "拍照", style: .Default, handler: { action in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            
            if UIImagePickerController.isSourceTypeAvailable(.Camera) {
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        }))
        
        alertController.addAction(PSTAlertAction(title: "相册", style: .Default, handler: {action in
            let imagePickerVC = QBImagePickerController()
            imagePickerVC.maximumNumberOfSelection = UInt(9 - self.collectionView.numberOfItemsInSection(0))
            imagePickerVC.delegate = self
            imagePickerVC.allowsMultipleSelection = true
            imagePickerVC.showsNumberOfSelectedAssets = true
            
            self.presentViewController(imagePickerVC, animated: true, completion: nil)
        }))
        
        alertController.addCancelActionWithHandler(nil)
        
        alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
    }
    
    func setStepType() {
        if self.imagesArray.count == 0 {
            if self.contentTextView.text == "" {
                self.stepType = StepType.attendance
            } else {
                self.stepType = StepType.text
            }
        } else if self.imagesArray.count >= 1 {
            if self.contentTextView.text == "" {
                self.stepType = StepType.multiPicWithoutText
            } else {
                self.stepType = StepType.multiPicWithText
            }
        } else if self.imagesArray.count == 1 {
            if self.contentTextView.text == "" {
                self.stepType = StepType.singlePicWithoutText
            } else {
                self.stepType = StepType.singlePicWithText
            }
        }
    }
    
    
    func uploadEditStep() {
        self.setStepType()
        
        self.dismissKeyboard()
        
        self.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if self.imagesArray.count > 0 {
                
                let opQueue = NSOperationQueue()
                opQueue.maxConcurrentOperationCount = 1
                
                let _uid = CurrentUser.sharedCurrentUser.uid!
                let _array = self.data?.objectForKey("imageArray") as! [UIImage]
                
                var _tmpIndex = 0
                
                for _image: UIImage in self.imagesArray {
                    if !_array.contains(_image) {
                        let op = NSBlockOperation(block: { () -> Void in
                            let _date = Int(NSDate().timeIntervalSince1970)
                            let saveKey = "/step/\(_uid)_\(_date).png"
                            
                            NSThread.sleepForTimeInterval(1)
                            
                            self.uploadImageHelper(image: _image.fixOrientation(), saveKey: saveKey)
                        })
                        
                        opQueue.addOperations([op], waitUntilFinished: true)
                    } else {
                        _tmpIndex++
                    }
                }
                
                if _tmpIndex == self.imagesArray.count {
                    self.uploadAllImagesSuccess = true
                    NSNotificationCenter.defaultCenter().postNotificationName(NIUploadImagesCompletionNotification, object: nil)                   
                }
                
            } else {
                self.uploadAllImagesSuccess = true
                NSNotificationCenter.defaultCenter().postNotificationName(NIUploadImagesCompletionNotification, object: nil)
            }
        }
    }
    
    func uploadNewStep() {
        
        if self.dreamId == "" {
            self.view.showTipText("请先选择记本")
            return
        }
        
        self.setStepType()
        
        self.dismissKeyboard()
        
        self.startAnimating()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            if self.imagesArray.count > 0 {
                
                let opQueue = NSOperationQueue()
                opQueue.maxConcurrentOperationCount = 1
                
                let _uid = CurrentUser.sharedCurrentUser.uid!
                
                for _image: UIImage in self.imagesArray {
                    
                    let op = NSBlockOperation(block: { () -> Void in
                        let _date = Int(NSDate().timeIntervalSince1970)
                        let saveKey = "/step/\(_uid)_\(_date).png"
                        
                        NSThread.sleepForTimeInterval(1)

                        self.uploadImageHelper(image: _image.fixOrientation(), saveKey: saveKey)
                    })
                    
                    opQueue.addOperations([op], waitUntilFinished: true)
                }
            } else {
                self.uploadAllImagesSuccess = true
                NSNotificationCenter.defaultCenter().postNotificationName(NIUploadImagesCompletionNotification, object: nil)
            }
        }

    }
    
    func handleImagesUploadCompletion(noti: NSNotification) {
        if self.isEdit == 0 {
            AddStepModel.postAddStep(content: self.contentTextView.text, stepType: self.stepType!, images: self.imagesInfo, dreamId: self.dreamId, callback: {
                (task, responseObject, error) -> Void in
                
                self.stopAnimating()
                
                if let _ = error {
                    self.view.showTipText("发布进展不成功")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["error"].numberValue.integerValue != 0 {
                        self.view.showTipText("发布进展不成功")
                    } else {
                        self.addStepSuccessHelper(json: json)
                    }
                }
            }) // AddStepModel.postAddStep
        } else if self.isEdit == 1 {
            self.imagesInfo.addObjectsFromArray(self.data!["images"] as! NSArray as [AnyObject])
            
            AddStepModel.postEditStep(content: self.contentTextView.text, stepType: self.stepType!,images: self.imagesInfo, sid: self.data!.stringAttributeForKey("sid"),  callback: {
                (task, responseObject, error) -> Void in
                
                self.stopAnimating()
                
                if let _ = error {
                    self.view.showTipText("更新进展不成功")
                } else {
                    let json = JSON(responseObject!)
                    
                    if json["error"].numberValue.integerValue != 0 {
                        self.view.showTipText("更新进展不成功")
                    } else {
                        self.editStepSuccessHelper()
                    }
                }
            })
        }
    }
    
    
    func uploadImageHelper(image image: UIImage, saveKey: String) {
        
        let uy = UpYun()
        uy.successBlocker = ({ (data: AnyObject!) in
            let json = JSON(data)
            
            var imageUrl = json["url"].stringValue
            imageUrl = SAReplace(imageUrl, before: "/step/", after: "") as String
            
            let imageWidth = json["image-width"].stringValue
            let imageHeight = json["image-height"].stringValue
            
            synchronized(self.imagesInfo, closure: { () -> () in
                self.imagesInfo.addObject(NSDictionary(dictionary: ["path": "\(imageUrl)", "width": "\(imageWidth)", "height": "\(imageHeight)"]))
                let __count = (self.data != nil) ? ((self.data?.allKeys.filter({ $0 as! String == "imageArray" }).count)! > 0 ? (self.data?.objectForKey("imageArray") as! [UIImage]).count : 0) : 0
                
                if self.imagesInfo.count == self.imagesArray.count - __count {
                    self.uploadAllImagesSuccess = true
                    NSNotificationCenter.defaultCenter().postNotificationName(NIUploadImagesCompletionNotification, object: nil)
                }
                
            })
            
            SDImageCache.sharedImageCache().storeImage(image, forKey: "http://img.nian.so/step/\(imageUrl)!large")
        })
        
        uy.failBlocker = ({ (error: NSError!) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.view.showTipText("上传图片失败，请稍后再试")
            })
        })
        
        uy.uploadImage(image, savekey: saveKey)
    }
    
    func addStepSuccessHelper(json json: JSON) {
        globalWillNianReload = 1
        
        let data = json["data"].dictionaryValue
        let coin = data["coin"]?.stringValue
        let isfirst = data["isfirst"]?.stringValue
        let totalCoin = data["totalCoin"]?.stringValue
        let sid = data["id"]?.stringValue
        
        let modeCard = SACookie("modeCard")
        
        if modeCard != "off" {
            let card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
            card.content = self.contentTextView.text
            card.widthImage = String(self.collectionView.frame.size.width)
            card.heightImage = String(self.collectionView.frame.size.height)
           
            if self.collectionView.frame.size.height != 0 {
                UIGraphicsBeginImageContextWithOptions(self.collectionView.frame.size, false, globalScale)
                self.collectionView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
                card.image.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
            card.onCardSave()
        }
        
        let d = NSMutableDictionary()
        d["content"] = self.contentTextView.text
        d["images"] = self.imagesInfo
        
        if self.imagesArray.count == 1 {
            d["width"] = self.imagesArray[0].size.width
            d["height"] = self.imagesArray[0].size.height
        } else {
            d["width"] = self.collectionView.frame.width
            d["height"] = VVeboCell.calculateCollectionViewHeight(self.imagesArray)
        }
        d["lastdate"] = V.now()
        d["comments"] = 0
        d["likes"] = 0
        d["liked"] = 0
        d["dream"] = self.dreamId
        d["sid"] = sid
        d["title"] = ""
        d["uid"] = CurrentUser.sharedCurrentUser.uid!
        d["type"] = String(self.stepType!.rawValue)
        
        if let user = Cookies.get("user") as? String {
            d["user"] = user
        } else {
            d["user"] = ""
        }
        
        self.delegate?.newCountUp!(coin!, total: totalCoin!, isfirst: isfirst!)
        self.delegate?.newUpdate!(VVeboCell.SACellDataRecode(d as NSDictionary))
        //
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func editStepSuccessHelper() {
        globalWillNianReload = 1
        dispatch_async(dispatch_get_main_queue(), {
            if self.data != nil {
                let mutableData = NSMutableDictionary(dictionary: self.data!)
                mutableData.setValue(self.contentTextView.text, forKey: "content")
                mutableData.setValue(NSArray(array: self.imagesInfo), forKey: "images")
                
                if self.imagesArray.count == 1 {
                    mutableData["width"] = self.collectionView.frame.width
                    mutableData["height"] = self.collectionView.frame.width
                } else {
                    mutableData["width"] = self.collectionView.frame.width
                    mutableData["height"] = VVeboCell.calculateCollectionViewHeight(self.imagesArray)
                }
                
                self.delegate?.newEditStepRow = self.row
                self.delegate?.newEditStepData = mutableData
                self.delegate?.newEditstep()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
    }
}

/*=========================================================================================================================================*/

extension NewAddStepViewController: QBImagePickerControllerDelegate {

    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didSelectAsset asset: ALAsset!) {
        
        self.reloadCollectionViewWithAssets([asset])
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didSelectAssets assets: [AnyObject]!) {
        
        self.reloadCollectionViewWithAssets(assets)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reloadCollectionViewWithAssets(assets: [AnyObject]!) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            for(var _index = 0; _index < assets.count; _index++) {
                let _asset = assets[_index]
                let rep = _asset.defaultRepresentation()
                let resolutionRef = rep?.CGImageWithOptions([kCGImageSourceThumbnailMaxPixelSize : 1000, kCGImageSourceCreateThumbnailWithTransform : true])
                let image = UIImage(CGImage: resolutionRef!.takeUnretainedValue(), scale: 1.0, orientation: UIImageOrientation(rawValue: rep!.orientation().rawValue)!)
                
                synchronized(self.imagesArray, closure: { () -> () in
                    self.imagesArray.append(image)
                })

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                    self.collectionView.performBatchUpdates({ () -> Void in
                        self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: self.imagesArray.count - 1, inSection: 0)])

                    }, completion: { finished in
                        let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
                        
                        if collectionViewHeight > 0 {
                            if self.isInConvenienceWay {
                                self.collectionToTopContraint.constant = 80 
                            } else {
                                self.collectionToTopContraint.constant = 16
                            }
                        }
                        
                        constrain(self.collectionView, replace: self.collectionConstraintGroup) { (view1) -> () in
                            view1.height == collectionViewHeight
                        }
                        
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.collectionView.layoutIfNeeded()
                            }, completion: nil)
                    })
                })
            }
        })
        
    }
    
    
    func reloadCollectionViewWithoutAssets(inIndexPath inIndexPath: [NSIndexPath]) {
        
        self.collectionView.performBatchUpdates({ () -> Void in
            for indexpath in inIndexPath {
                self.imagesArray.removeAtIndex(indexpath.row)
                if self.isEdit == 1 {
                    if (self.data?["images"] as? NSArray)!.count > indexpath.row {
                        let tmpArray = NSMutableArray(array: (self.data?["images"] as! NSArray))
                        tmpArray.removeObjectAtIndex(indexpath.row)
                        
                        self.data?.setObject(tmpArray, forKey: "images")
                    }
                }
            }
            
            self.collectionView.deleteItemsAtIndexPaths(inIndexPath)
            
            }, completion: { finished in
                let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
                
                if collectionViewHeight == 0 {
                    self.collectionToTopContraint.constant = 0
                }
                
                constrain(self.collectionView, replace: self.collectionConstraintGroup) { (view1) -> () in
                    view1.height == collectionViewHeight
                }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.collectionView.layoutIfNeeded()
                    }, completion: nil)
        })
    }
    
    func calculateCollectionHeightWith(dataSource dataSource: NSArray) -> CGFloat {
        let _index = dataSource.count / 3
        let _tmpIndex = dataSource.count % 3
        let __index = _tmpIndex == 0 ? _index : _index + 1
        
        return CGFloat(__index) * ceil(self.regularCellSize.height) + CGFloat(_index * 2)
    }
}


extension NewAddStepViewController {

    @IBAction func selectNote(sender: UITapGestureRecognizer) {
        
        if self.indicateArrowDirection == 0 {
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            dreamArray = NSMutableArray(array: userDefaults.arrayForKey("NianDreams")!)
            let _temp = (dreamArray.count / 3) + (dreamArray.count % 3 == 0 ? 0 : 1)
            
            self.view.layoutIfNeeded()
            self.contentView.bringSubviewToFront(self.noteCollectionView)
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                var extraSpacing: CGFloat = 0
                if _temp > 1 {
                    extraSpacing = CGFloat(_temp - 1) * (globalWidth - 240) / 8
                }
                
                self.notesHeightConstraint.constant = CGFloat((_temp > 2 ? 2 : _temp) * 120) + extraSpacing
                self.view.layoutIfNeeded()
                
                self.indicateArrow.transform = CGAffineTransformMakeRotation(CGFloat(M_PI))
                }, completion: { finished in
                    self.noteCollectionView.reloadData()
                    self.indicateArrowDirection = 1
            })
        } else if self.indicateArrowDirection == 1 {
            
            self.view.layoutIfNeeded()
            self.dreamArray.removeAllObjects()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.notesHeightConstraint.constant = 0
                self.noteCollectionView.reloadData()
                self.view.layoutIfNeeded()
                self.indicateArrow.transform = CGAffineTransformMakeRotation(0)
                }, completion: { finished in
                    self.view.sendSubviewToBack(self.noteCollectionView)
                    self.indicateArrowDirection = 0
            })
            
        }
        
    }
}


extension NewAddStepViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        synchronized(self.imagesArray, closure: { () -> () in
            self.imagesArray.append(resizedImage(image, newWidth: 1000))
        })
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: self.imagesArray.count - 1, inSection: 0)])
                
                }, completion: { finished in
                    let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
                    
                    if collectionViewHeight > 0 {
                        if self.isInConvenienceWay {
                            self.collectionToTopContraint.constant = 80
                        } else {
                            self.collectionToTopContraint.constant = 16
                        }
                    }
                    
                    constrain(self.collectionView, replace: self.collectionConstraintGroup) { (view1) -> () in
                        view1.height == collectionViewHeight
                    }
                    
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.collectionView.layoutIfNeeded()
                        }, completion: nil)
            })
        })
        
    }
    
}
























































