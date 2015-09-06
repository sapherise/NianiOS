//
//  AddReddit + Function.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension AddRedditController {
    func uploadClick() {
        self.dismissKeyboard()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    
    func uploadFile(image: UIImage) {
        print("哈哈")
    }
    
    func add() {
        if isEdit == 1 {
            
        }
        let title = field1.text!
        let content = field2.text!
        let tags = tokenView.tokenTitles!
        if title == "" {
            self.view.showTipText("标题不能是空的...")
            field1.becomeFirstResponder()
        } else if content == "" {
            self.view.showTipText("正文不能是空的...")
            field2.becomeFirstResponder()
        } else {
            Api.postAddReddit(title, content: content, tags: tags) { json in
                if json != nil {
                    print(json)
                } else {
                    print("是空的！")
                }
            }
        }
    }
    
    func addDreamOK(){
        let title = self.field1?.text
        let content = self.field2.text
        let tags = self.tokenView.tokenTitles
        print(tags)
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            //            title = SAEncode(SAHtml(title!))
            //            content = SAEncode(SAHtml(content!))
            Api.postAddDream(title!, content: content!, uploadUrl: self.uploadUrl, isPrivate: 0, tags: tags!) {
                json in
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        globalWillNianReload = 1
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }
        
    }
    
    //MARK: edit dream
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokenTitles
        var tagsString: String = ""
        var tagsArray: Array<String> = [String]()
        
        if (tags!).count > 0 {
            for i in 0...((tags!).count - 1){
                let tmpString = tags![i] as! String
                tagsArray.append(tmpString)
                if i == 0 {
                    tagsString = "tags[]=\(SAEncode(SAHtml(tmpString)))"
                } else {
                    tagsString = tagsString + "&&tags[]=\(SAEncode(SAHtml(tmpString)))"
                }
            }
        } else {
            tagsString = "tags[]="
        }
        
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            Api.postEditDream(self.editId, title: title!, content: content!, uploadUrl: self.uploadUrl, editPrivate: 0, tags: tagsString){
                json in
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    globalWillNianReload = 1
                    self.delegate?.editDream(0, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTags:tagsArray)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }
    }
    
    func adjustHeight(h: CGFloat) {
        field2.setHeight(h)
        self.tokenView.setY(field2.bottom())
        let hScroll = 78 + h + tokenView.frame.height
        scrollView.contentSize.height = hScroll
        self.containerView.setHeight(hScroll)
    }

}