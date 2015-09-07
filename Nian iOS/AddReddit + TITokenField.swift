//
//  AddReddit + TITokenField.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddRedditController: TITokenFieldDelegate {
    func tokenFieldDidBeginEditing(field: TITokenField!) {
        if tokenView.tokenField.isFirstResponder() {
            tokenView.frame.size.height = globalHeight - keyboardHeight - 64
            adjustScroll()
            self.scrollView.setContentOffset(CGPointMake(0, self.field2.frame.height + 57), animated: true)
        }
    }
    
    func tokenField(field: TITokenField!, shouldUseCustomSearchForSearchString searchString: String!) -> Bool {
        return true
    }
    
    func tokenField(field: TITokenField!, performCustomSearchForSearchString searchString: String!, withCompletionHandler completionHandler: (([AnyObject]!) -> Void)!) {
        var data: Array<String> = []
        
        if searchString.characters.count > 0 {
            let _string = SAEncode(SAHtml(searchString))
            Api.getAutoComplete(_string, callback: {
                json in
                if json != nil {
                    let error = json!.objectForKey("error") as! NSNumber
                    
                    if error == 0 {
                        data = json!.objectForKey("data") as! Array
                        
                        if data.count > 0 {
                            for i in 0...(data.count - 1) {
                                data[i] = data[i].decode()
                            }
                        }
                    }
                }
                completionHandler(data)
            })
        }
    }
    
    func tokenField(tokenField: TITokenField!, didAddToken token: TIToken!) {
        if self.tagsArray.contains(token.title) {
            return
        }
        
        Api.postTag(SAEncode(SAHtml(token.title)), callback: {
            json in
        })
    }
    
    func tokenField(tokenField: TITokenField!, didChangeFrame frame: CGRect) {
    }
    
}