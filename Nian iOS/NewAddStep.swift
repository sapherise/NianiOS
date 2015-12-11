//
//  NewAddStep.swift
//  Nian iOS
//
//  Created by WebosterBob on 12/9/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit
import ImageIO

class NewAddStep: UIView {

    let TEXTVIEW_DEFAULT_HEIGHT: CGFloat = globalHeight <= 568 ? 96 : globalHeight == 667 ? 195 : 264
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var noteCoverImage: UIImageView!
    
    @IBOutlet weak var noteTitleField: UITextField!
    
    @IBOutlet weak var indicateArrow: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var contentTextView: SZTextView!
    
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    
    
    
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
    
    
    
    
    
    func dismissKeyboard() {
        UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    
    @IBAction func pickerImages(sender: UIButton) {
        self.dismissKeyboard()
        
        if self.collectionView.numberOfItemsInSection(0) == 9 {

            
            return
        }
        

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
    
    
    
    func uploadNewStep() {
        self.setStepType()
        
        self.dismissKeyboard()
        
        
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
                

                
                if let _ = error {

                } else {
                    let json = JSON(responseObject!)
                    
                    if json["error"].numberValue.integerValue != 0 {

                    } else {

                    }
                }
            }) // AddStepModel.postAddStep
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

            })
        })
        
        uy.uploadImage(image, savekey: saveKey)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}





/*=========================================================================================================================================*/

extension NewAddStep: UICollectionViewDataSource, UICollectionViewDelegate {
    
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
//            self.reloadCollectionViewWithoutAssets(inIndexPath: [indexPath])
        }))
        
        alertController.addCancelActionWithHandler { action -> Void in
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
        
//        alertController.showWithSender(nil, arrowDirection: .Any, controller: self, animated: true, completion: nil)
        
        logError("indexPath = \(indexPath)")
    }
    
}


extension NewAddStep: UICollectionViewDelegateFlowLayout {
    
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

extension NewAddStep: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
}


extension NewAddStep: UINavigationControllerDelegate {
    
    
}




extension NewAddStep: QBImagePickerControllerDelegate {
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didSelectAsset asset: ALAsset!) {
        
        self.reloadCollectionViewWithAssets([asset])
        
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didSelectAssets assets: [AnyObject]!) {
        
        self.reloadCollectionViewWithAssets(assets)
        
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
//        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reloadCollectionViewWithAssets(assets: [AnyObject]!) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            for(var _index = 0; _index < assets.count; _index++) {
                let _asset = assets[_index]
                let rep = _asset.defaultRepresentation()
                let resolutionRef = rep?.CGImageWithOptions([kCGImageSourceThumbnailMaxPixelSize : 720])
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











































