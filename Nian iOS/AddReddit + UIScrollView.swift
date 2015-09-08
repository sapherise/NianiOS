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
        let info: Dictionary = notification.userInfo!
        let h = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size.height
        keyboardHeight = h
        if field2.isFirstResponder() {
            adjustPoint()
        }
        if tokenView.isFirstResponder() {
            tokenView.frame.size.height = globalHeight - keyboardHeight - 64
            adjustScroll()
            self.scrollView.setContentOffset(CGPointMake(0, self.field2.frame.height + 57), animated: false)
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        tokenView.frame.size.height = tokenView.tokenField.frame.size.height + 1
        adjustScroll()
//        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
}