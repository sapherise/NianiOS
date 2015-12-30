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
            let hNew = globalHeight - self.viewDream.height() - 64 - size_field_padding * 2 - viewHolder.height() - keyboardHeight
            if hNew > 0 {
                field2.setHeight(hNew)
                seperatorView2.setY(self.field2.bottom() + size_field_padding)
                viewHolder.setY(seperatorView2.bottom())
            }
        }
    }
    
    func handleKeyboardWillHideNotification(notification: NSNotification) {
        let h = globalHeight - self.viewDream.height() - 64 - size_field_padding * 2 - viewHolder.height()
        if h > 0 {
            field2.setHeight(h)
            seperatorView2.setY(self.field2.bottom() + size_field_padding)
            viewHolder.setY(seperatorView2.bottom())
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView == field2 {
            if field2.text != "" {
                labelPlaceholder.hidden = true
            } else {
                labelPlaceholder.hidden = false
            }
        }
    }
    
}