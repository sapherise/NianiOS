//
//  AddReddit + UIScrollView.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddRedditController {
    
    //MARK: keyboard notification && UITextView Delegate method
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.height   // abs(keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y)
        keyboardHeight = originDelta
        
        if self.tokenView.tokenField.isFirstResponder() {
            print(1)
            tokenView.frame.size = CGSize(width: self.tokenView.frame.width, height: globalHeight - keyboardHeight - 64)
            adjustScroll()
            self.scrollView.setContentOffset(CGPointMake(0, self.field2.frame.height + 78), animated: false)
        }
        
        if field2.isFirstResponder() {
            adjustPoint()
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        adjustScroll()
        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
    
    func adjustScroll() {
        scrollView.contentSize.height = 78 + field2.height() + tokenView.height()
        self.containerView.setHeight(self.scrollView.contentSize.height - 1)
    }
}