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
    
    func stringHeightWith(fontSize:CGFloat,width:CGFloat)->CGFloat {
        let font = UIFont.systemFontOfSize(fontSize)
        let size = CGSizeMake(width,CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle]
        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.height, dot: 0, isCeil: true)
    }
    
    func stringHeightBoldWith(fontSize:CGFloat,width:CGFloat)->CGFloat {
        let font = UIFont.boldSystemFontOfSize(fontSize)
        let size = CGSizeMake(width,CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.height, dot: 0, isCeil: true)
    }
    
    func stringWidthWith(fontSize:CGFloat,height:CGFloat)->CGFloat {
        let font = UIFont.systemFontOfSize(fontSize)
        let size = CGSizeMake(CGFloat.max, height)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.width, dot: 0, isCeil: true)
    }
    
    func stringWidthBoldWith(fontSize:CGFloat,height:CGFloat)->CGFloat {
        let font = UIFont.boldSystemFontOfSize(fontSize)
        let size = CGSizeMake(CGFloat.max, height)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return SACeil(rect.size.width, dot: 0, isCeil: true)
    }
}
