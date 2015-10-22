//
//  SATextField.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension UIView {
    // 需要创建 UIView，还要创建 UITextField，还要设置 delegate
    func setTextField(inputKeyboard: UITextField) {
        self.frame = CGRectMake(0, globalHeight - 56, globalWidth, 56)
        let inputLineView = UIView(frame: CGRectMake(0, 0, globalWidth, 0.5))
        inputLineView.backgroundColor = UIColor.e6()
        self.addSubview(inputLineView)
        inputKeyboard.frame = CGRectMake(64, 0, globalWidth - 64 - 16, 56)
        inputKeyboard.layer.cornerRadius = 4
        inputKeyboard.layer.masksToBounds = true
        inputKeyboard.font = UIFont.systemFontOfSize(12)
        inputKeyboard.returnKeyType = UIReturnKeyType.Send
        inputKeyboard.placeholder = "回应一下！"
        inputKeyboard.setValue(UIColor.b3(), forKeyPath: "_placeholderLabel.textColor")
        let imageHead = UIImageView(frame: CGRectMake(16, 12, 32, 32))
        imageHead.setHead(SAUid())
        imageHead.layer.cornerRadius = 16
        imageHead.layer.masksToBounds = true
        self.addSubview(imageHead)
        self.addSubview(inputKeyboard)
    }
}