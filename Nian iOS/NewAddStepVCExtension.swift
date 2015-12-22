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
        } else if collectionView == self.noteCollectionView {
            return self.dreamArray.count
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
        } else if collectionView == self.noteCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AddStepNoteCell", forIndexPath: indexPath) as! AddStepNoteCell
            
            if self.dreamArray.count > indexPath.row {
                let _imgUrl = (self.dreamArray[indexPath.row] as! NSDictionary)["img"] as! String
                
                cell.imageView.setImage("http://img.nian.so/dream/\(_imgUrl)!dream")
                cell.label.text = (self.dreamArray[indexPath.row] as! NSDictionary)["title"] as? String
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
        } else if collectionView == self.noteCollectionView {
            let _imgUrl = (self.dreamArray[indexPath.row] as! NSDictionary)["img"] as! String
            
            self.noteCoverView.setImage("http://img.nian.so/dream/\(_imgUrl)!dream")
            self.noteTitleField.text = (self.dreamArray[indexPath.row] as! NSDictionary)["title"] as? String
            self.dreamId = (self.dreamArray[indexPath.row] as! NSDictionary)["id"] as! String
            
            self.view.layoutIfNeeded()
            self.dreamArray.removeAllObjects()
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.notesHeightConstraint.constant = 0
                self.noteCollectionView.reloadData()
                self.view.layoutIfNeeded()
                self.indicateArrow.transform = CGAffineTransformMakeRotation(0)
                }, completion: { finished in
                    self.view.sendSubviewToBack(self.noteCollectionView)
            })
            
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
            return CGSizeMake(80, 120)
        }
    }
    
}

extension NewAddStepViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
}

/*=========================================================================================================================================*/

extension NewAddStepViewController {
    // MARK: - Keyboard Event Notifications
    
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
        let tempHeight = keyboardHeight + self.contentTextView.frame.size.height + self.collectionView.frame.size.height + 32 + (isInConvenienceWay ? 64 : 0)
        
        if tempHeight > globalHeight - 64 {
            self.contentTextView.scrollEnabled = true
            self.textViewHeightConstraint.constant = globalHeight - keyboardHeight - 64
            
            self.view.setNeedsUpdateConstraints()
            
            let animationOptions: UIViewAnimationOptions = [animationCurve, .BeginFromCurrentState]
            UIView.animateWithDuration(animationDuration, delay: 0, options: animationOptions, animations: {
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    let _tempHeight = self.collectionView.frame.size.height + 32 + (self.isInConvenienceWay ? 64 : 0)
                    self.scrollView.setContentOffset(CGPointMake(0, _tempHeight), animated: false)
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
                self.scrollView.setContentOffset(CGPointMake(0, 0), animated: true)
        })
        
        keyboardHeight = 0
    }
    
}


/*=========================================================================================================================================*/

extension NewAddStepViewController: UITextViewDelegate {
    
    func textViewDidChange(textView: UITextView) {
        let tempHeight = keyboardHeight + self.textViewHeight() + self.collectionView.frame.size.height + 32 + (isInConvenienceWay ? 64 : 0)
        if needUpdateTextViewHeight {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, max(globalHeight - 64, self.contentView.frame.height))

            if (tempHeight > globalHeight - 64) || (self.textViewHeight() > TEXTVIEW_DEFAULT_HEIGHT) {
                self.needUpdateTextViewHeight = false
                
                self.contentTextView.scrollEnabled = true
                self.textViewHeightConstraint.constant = globalHeight - keyboardHeight - 64

                self.view.setNeedsUpdateConstraints()
                
                UIView.animateWithDuration(0.5, animations: {
                    self.view.layoutIfNeeded()
                    }, completion: { finished in
                        let _tempHeight = self.collectionView.frame.size.height + 32 + (self.isInConvenienceWay ? 64 : 0)
                        self.scrollView.setContentOffset(CGPointMake(0, _tempHeight), animated: false)
                })
            }
            
        }
        
        if tempHeight > globalHeight - 64 {
            self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.needUpdateTextViewHeight = true
    }
    
}














































