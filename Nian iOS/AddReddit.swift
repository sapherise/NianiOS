//
//  AddReddit.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class AddReddit: SAViewController, UITextViewDelegate {
    var total: Int = 0
    var viewBottom: UIView!
    var y: CGFloat = 64
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        _setTitle("新话题！")
        setBarButtonImage("newOK", actionGesture: "hello")
        
        // 底部菜单栏
        let viewBottom = UIView(frame: CGRectMake(0, globalHeight - 44, globalWidth, 44))
        viewBottom.backgroundColor = UIColor.yellowColor()
        self.view.addSubview(viewBottom)
        viewBottom.userInteractionEnabled = true
        viewBottom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "imageInsert"))
        
        // 输入框
        textView = UITextView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 44 - 64))
        textView.backgroundColor = SeaColor
        textView.textContainerInset = UIEdgeInsetsMake(16, 16, 16, 16)
        textView.font = UIFont.systemFontOfSize(14)
        textView.delegate = self
        self.view.addSubview(textView)
    }
    
    func hello() {
        if textView.attributedText == nil {
            print("没有富文本！")
        } else {
            var content = ""
            let range = NSMakeRange(0, textView.attributedText.length)
            textView.attributedText.enumerateAttributesInRange(range, options: NSAttributedStringEnumerationOptions(rawValue: 0), usingBlock: { (dict, range, _) -> Void in
                if let _ = dict["NSAttachment"] {
                    content += "👿"
                } else {
                    let str = (self.textView.attributedText.string as NSString).substringWithRange(range)
                    content += str
                }
            })
            print(content)
        }
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
    }
}