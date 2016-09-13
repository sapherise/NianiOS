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
    
    func handleKeyboardWillShowNotification(_ notification: Notification) {
        let info: Dictionary = (notification as NSNotification).userInfo!
        let h = (info[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size.height
        keyboardHeight = h
        if field2.isFirstResponder {
            let hNew = globalHeight - self.viewDream.height() - 64 - viewHolder.height() - keyboardHeight
            if hNew > 0 {
                scrollView.setHeight(hNew)
                let hField = hNew - collectionView.height() - size_field_padding * 2
                if field2.height() < hField {
                    field2.setHeight(hField)
                }
                setScrollContentHeight()
                seperatorView2.setY(self.scrollView.bottom())
                viewHolder.setY(seperatorView2.bottom())
            }
        }
    }
    
    func handleKeyboardWillHideNotification(_ notification: Notification) {
        let h = globalHeight - self.viewDream.height() - 64 - viewHolder.height()
        if h > 0 {
            scrollView.setHeight(h)
            let hField = h - collectionView.height() - size_field_padding * 2
            if field2.height() < hField {
                field2.setHeight(hField)
            }
            seperatorView2.setY(self.scrollView.bottom())
            viewHolder.setY(seperatorView2.bottom())
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView == field2 {
            if field2.text != "" {
                labelPlaceholder.isHidden = true
            } else {
                labelPlaceholder.isHidden = false
            }
            setScrollContentHeight()
            
            /* 改变 scrollView 的contentOffset */
            let point = field2.caretRect(for: (field2.selectedTextRange?.end)!)
            let yPoint = point.origin.y
            let hOffset = yPoint - scrollView.height() + 50 + collectionView.height()
            let y = scrollView.contentOffset.y
            if hOffset > 0 &&  y < hOffset {
                scrollView.contentOffset.y = hOffset
            }
        }
        
    }
    
    /* 通过 field2 来设置 scrollView 的高度 */
    func setScrollContentHeight() {
        let w = field2.width()
        let h = field2.sizeThatFits(CGSize(width: w, height: CGFloat.greatestFiniteMagnitude)).height
        let hContentHeight = h + size_field_padding * 2 + collectionView.height()
        /* 当 scrollView 内容超过本身高度时，调整 field2 */
        if scrollView.height() <= hContentHeight {
            field2.frame.size.height = h
        }
        scrollView.contentSize.height = hContentHeight
    }
    
}
