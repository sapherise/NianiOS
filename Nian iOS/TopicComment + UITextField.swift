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
        if textField == self.textField {
            let content = self.textField.text!
            if content != "" {
                let uid = SAUid()
                let name = Cookies.get("user")
                let time = V.now()
                let dic = NSDictionary(objects: [content, time, "-1", uid, name!], forKeys: ["content", "created_at", "id", "user_id", "username"])
                dataArray.addObject(dic)
                tableView.reloadData()
                let h = tableView.contentSize.height
                tableView.setContentOffset(CGPointMake(0, h - globalHeight), animated: true)
//                Api.postTopicCommentComment(id, content: content) { json in
//                    if json != nil {
//                        print(json)
//                    }
//                }
            }
        }
        return true
    }
}