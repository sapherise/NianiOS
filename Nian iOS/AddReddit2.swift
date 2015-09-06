//
//  AddReddit.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class AddReddit2: SAViewController, UITextViewDelegate {
    var total: Int = 0
    var viewBottom: UIView!
    var y: CGFloat = 64
    var textView: UITextView!
    var dict = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        _setTitle("新话题！")
        setBarButtonImage("newOK", actionGesture: "post")
        
        // 底部菜单栏
        viewBottom = UIView(frame: CGRectMake(0, globalHeight - 44, globalWidth, 44))
//        viewBottom.backgroundColor = UIColor.yellowColor()
        self.view.addSubview(viewBottom)
        viewBottom.userInteractionEnabled = true
        viewBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imageInsert"))
        
        // 输入框
        textView = UITextView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 44 - 64))
//        textView.backgroundColor = SeaColor
        textView.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        textView.font = UIFont.systemFontOfSize(14)
        textView.delegate = self
        self.view.addSubview(textView)
    }
    
    func post() {
        if textView.attributedText == nil {
            print("没有富文本！")
        } else {
            var content = ""
            let range = NSMakeRange(0, textView.attributedText.length)
            textView.attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (dict, range, _) -> Void in
                if let d = dict["NSAttachment"] {
//                    print(dict)
                    let textAttachment = d as! NSTextAttachment
                    let b = self.dict.stringAttributeForKey("\(textAttachment.image!)")
                    content += b
                } else {
                    let str = (self.textView.attributedText.string as NSString).substringWithRange(range)
                    content += str
                }
            })
            print("内容为：\(content)")
        }
    }
    
    func uploadFile(img:UIImage){
    }
    
    func imageInsert() {
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "bg")
        attachment.bounds = CGRectMake(0, 0, globalWidth - 32 - 9, globalWidth)
        let attStr = NSAttributedString(attachment: attachment)
        let mutableStr = NSMutableAttributedString(attributedString: textView.attributedText)
        let selectedRange = textView.selectedRange
        mutableStr.insertAttributedString(attStr, atIndex: selectedRange.location)
        mutableStr.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14), range: NSMakeRange(0,mutableStr.length))
        let newSelectedRange = NSMakeRange(selectedRange.location+1, 0)
        textView.attributedText = mutableStr
        textView.selectedRange = newSelectedRange
        print("开始上传图片")
        self.navigationItem.rightBarButtonItems = buttonArray()
        let uy = UpYun()
        uy.successBlocker = ({(data: AnyObject!) in
            self.setBarButtonImage("newOK", actionGesture: "post")
            var url = data.objectForKey("url") as! String
            url = SAReplace(url, before: "/bbs/", after: "<img:") as String
            url = "\(url)>"
            self.dict.setValue("\(url)", forKey: "\(attachment.image!)")
        })
        // todo: 下面的宽度要改成 500
        uy.uploadImage(resizedImage(attachment.image!, newWidth: 50), savekey: getSaveKey("bbs", png: "png") as String)
    }
}