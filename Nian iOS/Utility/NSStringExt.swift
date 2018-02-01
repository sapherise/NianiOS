//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//


import UIKit
import Foundation

extension String {
    
    func stringHeightWith(_ fontSize:CGFloat,width:CGFloat)->CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: width,height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let  attributes = [NSAttributedStringKey.font:font,
            NSAttributedStringKey.paragraphStyle:paragraphStyle]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.height, dot: 0, isCeil: true)
    }
    
    // 拥有行距的 TextView 的函数
    func stringHeightWithSZTextView(_ fontSize: CGFloat, width: CGFloat) -> CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        paragraphStyle.lineSpacing = 8
        let attrDictionary = [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: paragraphStyle]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: attrDictionary, context: nil)
        return SACeil(rect.size.height, dot: 0, isCeil: true)
    }
    
    func stringHeightBoldWith(_ fontSize:CGFloat,width:CGFloat)->CGFloat {
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        let size = CGSize(width: width,height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let  attributes = [NSAttributedStringKey.font:font,
            NSAttributedStringKey.paragraphStyle:paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.height, dot: 0, isCeil: true)
    }
    
    func stringWidthWith(_ fontSize:CGFloat,height:CGFloat)->CGFloat {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let  attributes = [NSAttributedStringKey.font:font,
            NSAttributedStringKey.paragraphStyle:paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.width, dot: 0, isCeil: true)
    }
    
    func stringWidthBoldWith(_ fontSize:CGFloat,height:CGFloat)->CGFloat {
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        let size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let  attributes = [NSAttributedStringKey.font:font,
            NSAttributedStringKey.paragraphStyle:paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.width, dot: 0, isCeil: true)
    }
}
