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
            field2.setHeight(999999)
            let hN = field2.layoutManager.usedRectForTextContainer(textView.textContainer).size.height + 12
            let field2DefaultHeight: CGFloat = globalHeight > 480 ? 120 : 96
            let h = max(field2DefaultHeight, hN)
            adjustHeight(h)
            adjustPoint()
        }
    }
    
    // 设定 scrollView 的滚动距离
    func adjustPoint() {
        let point = field2.caretRectForPosition((field2.selectedTextRange?.end)!)
        let yPoint = point.origin.y
        let hPoint = point.size.height
        let h = yPoint + hPoint + 116 - (globalHeight - keyboardHeight - 64)
        // 前半段是光标距离设备顶部的高度，后半段是弹起键盘后、去除导航栏的显示区域高度
        if !isinf(h) {
            self.scrollView.contentOffset.y = max(h, 0)
        }
    }
}

extension SZTextView {
    override public func caretRectForPosition(position: UITextPosition) -> CGRect {
        var originalRect = super.caretRectForPosition(position)
        originalRect.size.height = 18
        return originalRect
    }
}