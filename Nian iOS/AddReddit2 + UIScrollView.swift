//
//  AddReddit + UIScrollView.swift
//  Nian iOS
//
//  Created by Sa on 15/9/2.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddReddit2 {
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
        keyboardEndObserve()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info: Dictionary = notification.userInfo!
        let keyboardSize: CGSize = (info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size)!
        let hKey = keyboardSize.height
        textView.setHeight(globalHeight - 44 - 64 - hKey)
        self.viewBottom.setY(globalHeight - 44 - hKey)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        textView.setHeight(globalHeight - 44 - 64)
        self.viewBottom.setY(globalHeight - 44)
    }
}