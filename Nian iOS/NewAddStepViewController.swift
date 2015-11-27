//
//  NewAddStepViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/24/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

@objc protocol NewAddStepDelegate {
    
    

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
    
//    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var data: NSDictionary?
    var Id: String = ""
    
    var keyboardHeight: CGFloat = 0
    
    var imagesDataSource = NSMutableArray()
    
    var regularCellSize = CGSizeMake((globalWidth - 32 - 4)/3, (globalWidth - 32 - 4)/3)
    var largerCellSize  = CGSizeMake((globalWidth - ((globalWidth - 32 - 4)/3) - 32 - 2), (globalWidth - 32 - 4)/3)
    var largestCellSize = CGSizeMake(globalWidth - 32, (globalWidth - 32 - 4) / 3)
    
    var needUpdateTextViewHeight: Bool = true
    
    let collectionConstraintGroup = ConstraintGroup()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self._setTitle("新进展")
        self.setBarButtonImage("newOK", actionGesture: "")
        
        sp1HeightConstraint.constant = globalHalf
        
        self.contentTextView.attributedPlaceholder = NSAttributedString(string: "进展正文" ,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        
        self.textViewHeightConstraint.constant = TEXTVIEW_DEFAULT_HEIGHT
        self.contentTextView.delegate = self
        
        self.collectionView.registerNib(UINib(nibName: "AddStepCollectionCell", bundle: nil), forCellWithReuseIdentifier: "AddStepCollectionCell")
        
        constrain(self.collectionView, replace: collectionConstraintGroup) { (view1) -> () in
            view1.height == 0
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for changes to keyboard visibility so that we can adjust the text view accordingly.
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
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
    }
    
    func textViewHeight() -> CGFloat {
        let textViewHeight = self.contentTextView.intrinsicContentSize().height
        
        return max(textViewHeight, TEXTVIEW_DEFAULT_HEIGHT)
    }
    
    @IBAction func tapOnBackground(sender: UIControl) {
        self.dismissKeyboard()
    }
    
    @IBAction func tapOnContentView(sender: UITapGestureRecognizer) {
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
         UIApplication.sharedApplication().sendAction("resignFirstResponder", to: nil, from: nil, forEvent: nil)
    }
    
    
    @IBAction func pickerImages(sender: UIButton) {
        self.dismissKeyboard()
        
        let imagePickerVC = QBImagePickerController()
        imagePickerVC.maximumNumberOfSelection = 9
        imagePickerVC.delegate = self
        imagePickerVC.allowsMultipleSelection = true
        imagePickerVC.showsNumberOfSelectedAssets = true
        
        self.presentViewController(imagePickerVC, animated: true, completion: nil)
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
        
        logInfo("\(keyboardHeight), \(originDelta)")
        
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
        
        logWarn("\(keyboardHeight), ==========")
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
        return self.imagesDataSource.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddStepCollectionCell", forIndexPath: indexPath) as! AddStepCollectionCell
        
        cell.imageView.image = UIImage(CGImage: (self.imagesDataSource[indexPath.row] as! ALAsset).thumbnail().takeUnretainedValue())
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let alertController = PSTAlertController.actionSheetWithTitle("确定删除图片？")
        
        alertController.addAction(PSTAlertAction(title: "确定", style: .Default, handler: { action in
            self.reloadCollectionViewWithoutAssets(inIndexPath: [indexPath], dataSource: self.imagesDataSource)
        }))
        
        alertController.addCancelActionWithHandler { action -> Void in
            collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        }
    }
    
}


extension NewAddStepViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if self.imagesDataSource.count % 3 == 1 {
            if indexPath.row == self.imagesDataSource.count - 1 {
                return largestCellSize
            }
        } else if self.imagesDataSource.count % 3 == 2 {
            if indexPath.row == self.imagesDataSource.count - 1 {
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

/*=========================================================================================================================================*/

extension NewAddStepViewController: QBImagePickerControllerDelegate {

    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didSelectAsset asset: ALAsset!) {
        
        self.reloadCollectionViewWithAssets([asset], dataSource: self.imagesDataSource)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func qb_imagePickerController(imagePickerController: QBImagePickerController!, didSelectAssets assets: [AnyObject]!) {
        
        self.reloadCollectionViewWithAssets(assets, dataSource: self.imagesDataSource)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(imagePickerController: QBImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reloadCollectionViewWithAssets(assets: [AnyObject]!, dataSource: NSArray) {

        var currentDataSourceCount = 0
        
        self.collectionView.performBatchUpdates({ () -> Void in
            var _previousCount = dataSource.count
            
            self.imagesDataSource.addObjectsFromArray(assets)
            
            var tempIndexArray = [NSIndexPath]()
            
            var _index = _previousCount
            
            for(; _index < self.imagesDataSource.count; _index++) {
                tempIndexArray.append(NSIndexPath(forRow: _previousCount, inSection: 0))
                _previousCount++
            }
            
            currentDataSourceCount = self.imagesDataSource.count
            
            self.collectionView.insertItemsAtIndexPaths(tempIndexArray)
            
            }, completion: { finished in
                
                let _index = currentDataSourceCount / 3
                
                let _tmpIndex = currentDataSourceCount % 3
                
                let __index = _tmpIndex == 0 ? _index : _index + 1
                
                let collectionViewHeight = CGFloat(__index) * CGFloat(self.regularCellSize.height) + CGFloat(_index * 2)
                
                constrain(self.collectionView, replace: self.collectionConstraintGroup) { (view1) -> () in
                    view1.height == collectionViewHeight
                }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.collectionView.layoutIfNeeded()
                    }, completion: nil)
        })
        
    }
    
    
    func reloadCollectionViewWithoutAssets(inIndexPath inIndexPath: [NSIndexPath], dataSource: NSMutableArray) {
        
        self.collectionView.performBatchUpdates({ () -> Void in
            
            for indexpath in inIndexPath {
                self.imagesDataSource.removeObjectAtIndex(indexpath.row)
            }
            
            self.collectionView.deleteItemsAtIndexPaths(inIndexPath)
            
            }, completion: { finished in
                
                let _index = self.imagesDataSource.count / 3
                
                let _tmpIndex = self.imagesDataSource.count % 3
                
                let __index = _tmpIndex == 0 ? _index : _index + 1
                
                let collectionViewHeight = CGFloat(__index) * CGFloat(self.regularCellSize.height) + CGFloat(_index * 2)
                
                constrain(self.collectionView, replace: self.collectionConstraintGroup) { (view1) -> () in
                    view1.height == collectionViewHeight
                }
                
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.collectionView.layoutIfNeeded()
                    }, completion: nil)
        
        
        })
    }
    
}
































