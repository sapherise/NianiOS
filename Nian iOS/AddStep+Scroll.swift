//
//  AddReddit + UIScrollView.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddStep {
    
    //MARK: keyboard notification && UITextView Delegate method
    
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let info: Dictionary = notification.userInfo!
        let h = info[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size.height
        keyboardHeight = h
        if field2.isFirstResponder() {
            adjustPoint()
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        adjustScroll()
        //        self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
}