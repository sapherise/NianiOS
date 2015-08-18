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
        var font = UIFont.systemFontOfSize(fontSize)
        var size = CGSizeMake(width,CGFloat.max)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        var  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle]
        var text = self as NSString
        var rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        
        if globaliOS >= 8.4 {
            return rect.size.height + 0.1
        }
        return rect.size.height
    }
    
    func stringHeightBoldWith(fontSize:CGFloat,width:CGFloat)->CGFloat {
        var font = UIFont.boldSystemFontOfSize(fontSize)
        var size = CGSizeMake(width,CGFloat.max)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        var  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        var text = self as NSString
        var rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        
        if globaliOS >= 8.4 {
            return rect.size.height + 0.1
        }
        return rect.size.height
    }
    
    func stringWidthWith(fontSize:CGFloat,height:CGFloat)->CGFloat {
        var font = UIFont.systemFontOfSize(fontSize)
        var size = CGSizeMake(CGFloat.max, height)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        var  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        var text = self as NSString
        var rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        
        if globaliOS >= 8.4 {
            return rect.size.width + 0.1
        }
        return rect.size.width
    }
    
    func stringWidthBoldWith(fontSize:CGFloat,height:CGFloat)->CGFloat {
        var font = UIFont.boldSystemFontOfSize(fontSize)
        var size = CGSizeMake(CGFloat.max, height)
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        var  attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        var text = self as NSString
        var rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        
        if globaliOS >= 8.4 {
            return rect.size.width + 0.1
        }
        return rect.size.width
    }
}
