//
//  NewAddStepVCExtension.swift
//  Nian iOS
//
//  Created by WebosterBob on 12/11/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import Foundation


extension NewAddStepViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return self.imagesArray.count
        } else {
            return 0
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddStepCollectionCell", forIndexPath: indexPath) as! AddStepCollectionCell
            
            if self.imagesArray.count > indexPath.row {
                cell.imageView.image = self.imagesArray[indexPath.row]
            } else {
                let asset = self.imagesDataSource[indexPath.row] as? ALAsset
                cell.imageView.image = UIImage(CGImage: asset!.thumbnail().takeUnretainedValue())
                
            }
            
            return cell
        } else {
            let cell = UICollectionViewCell()
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == self.collectionView {
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
    
}


extension NewAddStepViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if collectionView == self.collectionView {
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
        } else {
            return CGSizeMake(0, 0)
        }
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

















































