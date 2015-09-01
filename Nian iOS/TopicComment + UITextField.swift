//
//  TopicComment + UITextField.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension TopicComment {
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        let h = keyboardSize.height
        let hBefore = tableView.frame.size.height
        let hAfter = hBefore - h
        tableView.setHeight(hAfter)
        inputKeyboard.setY(tableView.bottom())
        let y = tableView.contentSize.height > hAfter ? tableView.contentSize.height - hAfter : 0
        tableView.setContentOffset(CGPointMake(0, y), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        tableView.setHeight(globalHeight - 56 - 64)
        inputKeyboard.setY(tableView.bottom())
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}