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
        let hKeyboard = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!.height
        // 这个是弹起键盘后的 tableView 的高度
        let h = globalHeight - 64 - 56 - hKeyboard
        tableView.setHeight(h)
        inputKeyboard.setY(tableView.bottom())
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
                let dic = NSMutableDictionary(objects: [content, "-1", "-1", uid, name!], forKeys: ["content", "created_at", "id", "user_id", "username"])
                dataArray.insertObject(dic, atIndex: 0)
                tableView.reloadData()
                tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: UITableViewRowAnimation.Left)
                Api.postTopicCommentComment(id, content: content) { json in
                    if json != nil {
                        dic.setValue(time, forKey: "created_at")
                        self.dataArray.replaceObjectAtIndex(0, withObject: dic)
                        self.tableView.reloadData()
                    }
                }
                textField.text = ""
            }
        }
        return true
    }
}