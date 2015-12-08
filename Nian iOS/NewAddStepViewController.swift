//
//  NewAddStepViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/24/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var contentTextView: SZTextView!

    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    
    weak var delegate: NewAddStepDelegate?
    
    var data: NSDictionary?
    var dreamId: String = ""
    var isEdit: Int = 0
    var row: Int = 0
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        sp1HeightConstraint.constant = globalHalf
        
        self.contentTextView.attributedPlaceholder = NSAttributedString(string: "进展正文" ,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        
        self.textViewHeightConstraint.constant = TEXTVIEW_DEFAULT_HEIGHT
        self.contentTextView.delegate = self
        
        self.collectionView.collectionViewLayout = yy_collectionViewLayout()
        self.collectionView.registerClass(AddStepCollectionCell.self, forCellWithReuseIdentifier: "AddStepCollectionCell")
        
        if self.isEdit == 1 {
            self._setTitle("编辑进展")
            self.setBarButtonImage("newOK", actionGesture: "uploadEditStep")
            self.contentTextView.text = self.data?.stringAttributeForKey("content").decode()
            
            self.imagesArray.appendContentsOf(self.data?.objectForKey("imageArray") as! [UIImage])
            
            let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
            
            constrain(self.collectionView, replace: collectionConstraintGroup) { (view1) -> () in
                view1.height == collectionViewHeight
            }
            
            self.collectionView.reloadData()
            
        } else {
            self._setTitle("新进展")
            self.setBarButtonImage("newOK", actionGesture: "uploadNewStep")
            
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
    
    
    @IBAction func pickerImages(sender: UIButton) {
        self.dismissKeyboard()
        
        if self.collectionView.numberOfItemsInSection(0) == 9 {
            self.view.showTipText("请先删除几张图片")
            
            return
        }
        
        let imagePickerVC = QBImagePickerController()
        imagePickerVC.maximumNumberOfSelection = UInt(9 - self.collectionView.numberOfItemsInSection(0))
        imagePickerVC.delegate = self
        imagePickerVC.allowsMultipleSelection = true
        imagePickerVC.showsNumberOfSelectedAssets = true
        
        self.presentViewController(imagePickerVC, animated: true, completion: nil)
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
                            
                            self.uploadImageHelper(image: _image, saveKey: saveKey)
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

                        self.uploadImageHelper(image: _image, saveKey: saveKey)
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
                self.imagesInfo.addObject(["path": "\(imageUrl)", "width": "\(imageWidth)", "height": "\(imageHeight)"])
                logInfo("\(["path": "\(imageUrl)", "width": "\(imageWidth)", "height": "\(imageHeight)"])")
                
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
        logInfo("\(json)")
        
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
//            card.widthImage = self.uploadWidth
//            card.heightImage = self.uploadHeight
//            card.url = "http://img.nian.so/step/\(self.uploadUrl)!large"
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
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func editStepSuccessHelper() {
        globalWillNianReload = 1
        dispatch_async(dispatch_get_main_queue(), {
            if self.data != nil {
                let mutableData = NSMutableDictionary(dictionary: self.data!)
                mutableData.setValue(self.contentTextView.text, forKey: "content")
                mutableData.setValue(self.imagesInfo, forKey: "images")
                
                if self.imagesArray.count == 1 {
                    mutableData["width"] = self.imagesArray[0].size.width
                    mutableData["height"] = self.imagesArray[0].size.height
                } else {
                    mutableData["width"] = self.collectionView.frame.width
                    mutableData["height"] = VVeboCell.calculateCollectionViewHeight(self.imagesArray)
                }
                
                self.delegate?.newEditStepRow = self.row
                self.delegate?.newEditStepData = mutableData
                self.delegate?.newEditstep()
                self.navigationController?.popViewControllerAnimated(true)
            }
        })
    }
}

/*=========================================================================================================================================*/

extension NewAddStepViewController {
    // MARK: Keyboard Event Notifications
    
    func handleKeyboardWillShow(noti: NSNotification) {
        let userInfo = noti.userInfo!
        
        // Get information about the animation.
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenBeginFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewBeginFrame = view.convertRect(keyboardScreenBeginFrame, fromView: view.window)
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y
        
        keyboardHeight -= originDelta
        
        self.textViewHeightConstraint.constant = self.textViewHeight()
        
        if keyboardHeight + self.textViewHeightConstraint.constant + self.collectionView.frame.size.height + 32 > globalHeight - 64 {
            self.contentTextView.scrollEnabled = true
            self.textViewHeightConstraint.constant = globalHeight - 64 - keyboardHeight - 32
            
            self.view.setNeedsUpdateConstraints()
            
            let animationOptions: UIViewAnimationOptions = [animationCurve, .BeginFromCurrentState]
            UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.scrollView.setContentOffset(CGPointMake(0, 32 + self.collectionView.frame.size.height - 64), animated: true)
            })
        }
        
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
        
    }
    
    func handleKeyboardWillHide(noti: NSNotification) {
        let userInfo = noti.userInfo!
        
        // Get information about the animation.
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let rawAnimationCurveValue = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).unsignedLongValue
        let animationCurve = UIViewAnimationOptions(rawValue: rawAnimationCurveValue)
        
        self.contentTextView.scrollEnabled = false
        self.textViewHeightConstraint.constant = self.textViewHeight()
        
        self.view.setNeedsUpdateConstraints()
        
        let animationOptions: UIViewAnimationOptions = [animationCurve, .BeginFromCurrentState]
        UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.scrollView.setContentOffset(CGPointMake(0, -64), animated: true)
        })
        
        keyboardHeight = 0
    }
    
}

extension NewAddStepViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        
        if needUpdateTextViewHeight {
        
            self.textViewHeightConstraint.constant = self.textViewHeight()
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, max(globalHeight - 64, self.contentView.frame.height))
            
            if keyboardHeight + self.textViewHeightConstraint.constant + self.collectionView.frame.size.height + 32 > globalHeight - 64 {
                self.needUpdateTextViewHeight = false
                
                self.contentTextView.scrollEnabled = true
                self.textViewHeightConstraint.constant = globalHeight - 64 - keyboardHeight - 32 // - self.collectionView.frame.size.height
                
                self.scrollView.setContentOffset(CGPointMake(0, 32 + self.collectionView.frame.size.height - 64), animated: true)
                
                self.view.setNeedsUpdateConstraints()
                
                UIView.animateWithDuration(0.5, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: nil)
            }
     
        }
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.needUpdateTextViewHeight = true
    }
    
}

/*=========================================================================================================================================*/

extension NewAddStepViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesArray.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddStepCollectionCell", forIndexPath: indexPath) as! AddStepCollectionCell
        
        if self.imagesArray.count > indexPath.row {
            cell.imageView.image = self.imagesArray[indexPath.row]
        } else {
            let asset = self.imagesDataSource[indexPath.row] as? ALAsset
            cell.imageView.image = UIImage(CGImage: asset!.thumbnail().takeUnretainedValue())
            
        }
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let alertController = PSTAlertController.actionSheetWithTitle("确定删除图片？")
        
        alertController.addAction(PSTAlertAction(title: "确定", style: .Default, handler: { action in
            self.reloadCollectionViewWithoutAssets(inIndexPath: [indexPath])
        }))
        
        alertController.addCancelActionWithHandler { action -> Void in
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
        
        alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
        
        logError("indexPath = \(indexPath)")
    }
    
}


extension NewAddStepViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if self.imagesArray.count % 3 == 1 {
            if indexPath.row == self.imagesArray.count - 1 {
                return largestCellSize
            }
        } else if self.imagesArray.count % 3 == 2 {
            if indexPath.row == self.imagesArray.count - 1 {
                return largerCellSize
            }
        }
        
        return regularCellSize
    }
    
}

extension NewAddStepViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
}


extension NewAddStepViewController: UINavigationControllerDelegate {


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
                let resolutionRef = rep?.fullResolutionImage()
                let image = UIImage(CGImage: resolutionRef!.takeUnretainedValue(), scale: 1.0, orientation: UIImageOrientation(rawValue: rep!.orientation().rawValue)!)
//                image = image.fixOrientation()
                
                synchronized(self.imagesArray, closure: { () -> () in
                    self.imagesArray.append(image)
                })

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                    self.collectionView.performBatchUpdates({ () -> Void in
                        self.collectionView.insertItemsAtIndexPaths([NSIndexPath(forRow: self.imagesArray.count - 1, inSection: 0)])

                    }, completion: { finished in
                        let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
                        
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
                    if (self.data?["images"] as? NSMutableArray)!.count > indexpath.row {
                        (self.data?["images"] as? NSMutableArray)!.removeObjectAtIndex(indexpath.row)
                    }
                }
            }
            
            self.collectionView.deleteItemsAtIndexPaths(inIndexPath)
            
            }, completion: { finished in
                let collectionViewHeight = self.calculateCollectionHeightWith(dataSource: self.imagesArray)
                
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


class yy_collectionViewLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        
        self.minimumLineSpacing = 2.0
        self.minimumInteritemSpacing = 2.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.minimumInteritemSpacing = 2.0
        self.minimumLineSpacing = 2.0
    }
    
    override func collectionViewContentSize() -> CGSize {

        let _count = self.collectionView?.numberOfItemsInSection(0)
        
        let _index = _count! / 3
        let _tmpIndex = _count! % 3
        let __index = _tmpIndex == 0 ? _index : _index + 1
        
        let collectionViewHeight = CGFloat(__index) * ceil((globalWidth - 32 - 4)/3) + CGFloat(_index * 2)
        let size = CGSizeMake(self.collectionView!.frame.width, collectionViewHeight)
        
        self.collectionView?.contentSize = size
        
        return size
    }
    
    override func prepareLayout() {
        
        super.prepareLayout()
        
        
        
    }
    
    
}






























