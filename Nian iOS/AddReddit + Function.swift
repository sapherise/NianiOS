//
//  AddReddit + Function.swift
//  Nian iOS
//
//  Created by Sa on 15/9/6.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension AddTopic {
    func onImage() {
        self.dismissKeyboard()
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        self.actionSheet!.cancelButtonIndex = 2
        self.actionSheet!.showInView(self.view)
    }
    
    func dreamSelected(id: String, title: String, content: String, image: String) {
        let v = (NSBundle.mainBundle().loadNibNamed("AddRedditDream", owner: self, options: nil) as NSArray).objectAtIndex(0) as! AddRedditDream
        v.title = title
        v.content = content
        v.image = "http://img.nian.so/dream/\(image)!dream"
        v.layoutSubviews()
        let image = getImageFromView(v)
        insertDream(image, dreamid: id)
    }
    
    func onDream() {
        let vc = ExploreNext()
        vc.type = 2
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func uploadFile(image: UIImage) {
        let attachment = NSTextAttachment()
        let _image = resizedImage(image, newWidth: globalWidth - 32 - 4)
        let w = _image.size.width
        let h = _image.size.height
        attachment.image = _image
        attachment.bounds = CGRectMake(0, 0, _image.size.width, _image.size.height)
        let attStr = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: field2.attributedText)
        let selectedRange = field2.selectedRange
        mutableStr.insertAttributedString(NSAttributedString(string: "\n"), atIndex: selectedRange.location)
        mutableStr.insertAttributedString(attStr, atIndex: selectedRange.location + 1)
        mutableStr.insertAttributedString(NSAttributedString(string: "\n"), atIndex: selectedRange.location + 2)
        mutableStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSMakeRange(0,mutableStr.length))
        let newSelectedRange = NSMakeRange(selectedRange.location + 3, 0)
        field2.attributedText = mutableStr
        field2.selectedRange = newSelectedRange
        self.navigationItem.rightBarButtonItems = buttonArray()
        let uy = UpYun()
        uy.successBlocker = ({(data: AnyObject!) in
            let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "add")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton]
            var url = data.objectForKey("url") as! String
            url = SAReplace(url, before: "/bbs/", after: "<image:") as String
            url = "\(url) w:\(w) h:\(h)>"
            self.dict.setValue("\(url)", forKey: "\(attachment.image!)")
            self.adjustAll()
        })
        uy.uploadImage(resizedImage(attachment.image!, newWidth: 500), savekey: getSaveKey("bbs", png: "png") as String)
    }
    
    func insertDream(image: UIImage, dreamid: String) {
        let attachment = NSTextAttachment()
        attachment.image = image
        attachment.bounds = CGRectMake(0, 0, image.size.width, image.size.height)
        let attStr = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: field2.attributedText)
        let selectedRange = field2.selectedRange
        mutableStr.insertAttributedString(NSAttributedString(string: "\n"), atIndex: selectedRange.location)
        mutableStr.insertAttributedString(attStr, atIndex: selectedRange.location + 1)
        mutableStr.insertAttributedString(NSAttributedString(string: "\n"), atIndex: selectedRange.location + 2)
        mutableStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSMakeRange(0,mutableStr.length))
        let newSelectedRange = NSMakeRange(selectedRange.location + 3, 0)
        field2.attributedText = mutableStr
        field2.selectedRange = newSelectedRange
        self.dict.setValue("<dream:\(dreamid)>", forKey: "\(attachment.image!)")
        adjustAll()
    }
    
    func add() {
        var content = ""
        let range = NSMakeRange(0, field2.attributedText.length)
        field2.attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (dict, range, _) -> Void in
            if let d = dict["NSAttachment"] {
                let textAttachment = d as! NSTextAttachment
                let b = self.dict.stringAttributeForKey("\(textAttachment.image!)")
                content += b
            } else {
                let str = (self.field2.attributedText.string as NSString).substringWithRange(range)
                content += str
            }
        })
        if type == 0 {
            // 发布话题
            let title = field1.text!
            let tags = tokenView.tokenTitles!
            if title == "" {
                self.view.showTipText("标题不能是空的...")
                field1.becomeFirstResponder()
            } else if content == "" {
                self.view.showTipText("正文不能是空的...")
                field2.becomeFirstResponder()
            } else {
                navigationItem.rightBarButtonItems = buttonArray()
                
                
                /* 正则表达式，看看有没有提到人 */
                /*
                matcher: 匹配的 struct
                matches: 匹配的结果的 Array
                match:   单个的匹配结果
                */
                let pattern = "(@[A-Za-z0-9_\\-\\u4e00-\\u9fa5]{2,30})"
                let matcher: RegexHelper?
                do  {
                    matcher = try RegexHelper(pattern)
                } catch _ as NSError {
                    matcher = nil
                }
                
                if matcher!.match(content) {
                    /* 当有 @某人 的时候， 首先调用 mention API，然后再调用 post add 数据的 API */
                    var tmpMatchArray = [String]()
                    for match: NSTextCheckingResult in matcher!.matches {
                        let matchRange = NSRange(location: match.range.location+1, length: match.range.length - 1)
                        let matchString = (content as NSString).substringWithRange(matchRange)
                        tmpMatchArray.append(matchString)
                    }
                    
                    Api.postMention(self.id, commentId: "", mentions: (tmpMatchArray as NSArray)) { json in
                        
                        if self.isEdit == 0 {
                            Api.postAddReddit(title, content: content, tags: tags) { json in
                                if json != nil {
                                    self.navigationItem.rightBarButtonItems = nil
                                    if let j = json as? NSDictionary {
                                        let vc = TopicViewController()
                                        vc.id = j.stringAttributeForKey("data")
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        } else if self.isEdit == 1 {
                            Api.postEditReddit(self.id, title: title, content: content, tags: tags) { json in
                                if json != nil {
                                    self.navigationItem.rightBarButtonItems = nil
                                    
                                    if let _ = json as? NSDictionary {
                                        let vc = TopicViewController()
                                        vc.id = self.id
                                        self.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if self.isEdit == 0 {
                        Api.postAddReddit(title, content: content, tags: tags) { json in
                            if json != nil {
                                self.navigationItem.rightBarButtonItems = nil
                                if let j = json as? NSDictionary {
                                    let vc = TopicViewController()
                                    vc.id = j.stringAttributeForKey("data")
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    } else if self.isEdit == 1 {
                        Api.postEditReddit(self.id, title: title, content: content, tags: tags) { json in
                            if json != nil {
                                self.navigationItem.rightBarButtonItems = nil
                                
                                if let _ = json as? NSDictionary {
                                    let vc = TopicViewController()
                                    vc.id = self.id
                                    self.navigationController?.pushViewController(vc, animated: true)
                                }
                            }
                        }
                    }
                }
            }
        } else if type == 1 {
            // 发布回应
            if content == "" {
                self.view.showTipText("正文不能是空的...")
                field2.becomeFirstResponder()
            } else {
                navigationItem.rightBarButtonItems = buttonArray()
                
                /* 正则表达式，看看有没有提到人 */
                /*
                    matcher: 匹配的 struct
                    matches: 匹配的结果的 Array
                    match:   单个的匹配结果
                */
                let pattern = "(@[A-Za-z0-9_\\-\\u4e00-\\u9fa5]{2,30})"
                let matcher: RegexHelper?
                do  {
                    matcher = try RegexHelper(pattern)
                } catch _ as NSError {
                    matcher = nil
                }
                
                if matcher!.match(content) {
                    /* 当有 @某人 的时候， 首先调用 mention API，然后再调用 post add 数据的 API */
                    var tmpMatchArray = [String]()
                    for match: NSTextCheckingResult in matcher!.matches {
                        let matchRange = NSRange(location: match.range.location+1, length: match.range.length - 1)
                        let matchString = (content as NSString).substringWithRange(matchRange)
                        tmpMatchArray.append(matchString)
                    }
                    
                    Api.postMention(self.id, commentId: "", mentions: (tmpMatchArray as NSArray)) { json in
                        Api.postAddRedditComment(self.id, content: content) { json in
                            if json != nil {
                                self.delegateComment?.getComment(content)
                                self.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    }
                    
                } else {
                    Api.postAddRedditComment(id, content: content) { json in
                        if json != nil {
                            self.delegateComment?.getComment(content)
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                }
            }
        }
    }
}
