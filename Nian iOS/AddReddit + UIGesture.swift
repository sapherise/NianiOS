//
//  AddReddit + UIGesture.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddRedditController {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isKindOfClass(UITableView) || touch.view!.isKindOfClass(UITableViewCell) {
            return false
        }
        
        return true
    }
    
    /* 在编辑 “记本简介” 时，根据选择的内容来实现滚动 */
    func textViewDidChangeSelection(textView: UITextView) {
        if textView == field2 {
            print("1")
            let tmpField2Height = textView.text.stringHeightWith(14.0, width: textView.contentSize.width - 24) + 12 + getImageHeight()
            let field2DefaultHeight: CGFloat = globalHeight > 480 ? 120 : 96
            let h = max(field2DefaultHeight, tmpField2Height)
            adjustHeight(h)
            adjustPoint()
        }
    }
    
    // 设定 scrollView 的滚动距离
    func adjustPoint() {
        let y = field2.caretRectForPosition((field2.selectedTextRange?.end)!).origin.y
        let hN = y + UIFont.systemFontOfSize(14).lineHeight + 78 + keyboardHeight + 12 - (globalHeight - 64)
        if hN > 0 {
            self.scrollView.contentOffset.y = hN
        }
    }
}