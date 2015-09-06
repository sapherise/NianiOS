//
//  AddReddit + UIScrollView.swift
//  Nian iOS
//
//  Created by Sa on 15/9/2.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddReddit {
    
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
        //        self.keyboardView.setY( globalHeight - self.keyboardHeight - 56 )
        //        let heightScroll = globalHeight - 56 - 64 - self.hKey
        ////        let contentOffsetTableView = self.tableview.contentSize.height >= heightScroll ? self.tableview.contentSize.height - heightScroll : 0
        //        self.tableview.setHeight( heightScroll )
        
        textView.setHeight(globalHeight - 44 - 64 - hKey)
        self.viewBottom.setY(globalHeight - 44 - hKey)
        //        self.tableview.setContentOffset(CGPointMake(0, contentOffsetTableView ), animated: false)
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        textView.setHeight(globalHeight - 44 - 64)
        self.viewBottom.setY(globalHeight - 44)
    }
}