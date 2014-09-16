//
//  Sapherise.swift
//  Nian iOS
//
//  Created by Sa on 14-7-9.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation


let IconColor:UIColor = UIColor(red:0.71, green:0.71,blue:0.71,alpha: 1)    //字体灰
let BGColor:UIColor = UIColor(red:0.14, green:0.19,blue:0.24,alpha: 1)   //背景白
let FontColor:UIColor = UIColor(red:0.78, green:0.26,blue:0.26,alpha: 1)   //字体灰
let BarColor:UIColor = UIColor(red:0.11, green:0.15,blue:0.19,alpha: 1)   //底栏黑
let BlueColor:UIColor = UIColor(red:0.00, green:0.67,blue:0.93,alpha: 1)   //念蓝
let LineColor:UIColor = UIColor(red:0.30, green:0.35,blue:0.40,alpha: 1)   //线条
let LittleLineColor:UIColor = UIColor(red:0.30, green:0.35,blue:0.40,alpha: 0.2)   //线条
let GoldColor:UIColor = UIColor(red:0.96, green:0.77,blue:0.23,alpha: 1)   //金色

func SAJson(SAUrl:String)->AnyObject!{
var url = NSURL(string:SAUrl)
var data = NSData.dataWithContentsOfURL(url, options: NSDataReadingOptions.DataReadingUncached, error: nil)
var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil)
var sa: AnyObject! = json.objectForKey("dream")
return "\(sa)"
}

func SAPost(postString:String, urlString:String)->String{
    var request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.URL = NSURL.URLWithString(urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    request!.HTTPMethod = "POST"
    request!.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    var response : NSURLResponse?
    var error : NSError?
    var returnData : NSData? = NSURLConnection.sendSynchronousRequest(request!, returningResponse : &response, error: &error)
    var strRet:NSString? = NSString(data: returnData!, encoding:NSUTF8StringEncoding)
    return strRet!
}


func SAGet(getString:String, urlString:String)->String{
    var request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.URL = NSURL.URLWithString(urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    request!.HTTPMethod = "GET"
    request!.HTTPBody = getString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    var response : NSURLResponse?
    var error : NSError?
    var returnData : NSData? = NSURLConnection.sendSynchronousRequest(request!, returningResponse : &response, error: &error)
    var strRet:NSString? = NSString(data: returnData!, encoding:NSUTF8StringEncoding)
    return strRet!
}


//替换，用法：var sa = SAReplace("This is my string", " ", "___")
func SAReplace(word:String, before:String, after:String)->NSString{
    return word.stringByReplacingOccurrencesOfString(before, withString: after, options: nil, range: nil)
}

//替换危险字符
func SAHtml(var content:String)->String{
    content = SAReplace(content, "&", "&amp;");
    content = SAReplace(content, "<", "&lt;");
    content = SAReplace(content, ">", "&gt;");
    content = SAReplace(content, "\"", "&quot;");
    content = SAReplace(content, "'", "&#039;");
    content = SAReplace(content, " ", "&nbsp;");
    content = SAReplace(content, "\n", "<br>");
    return content
}

func SAEncode(var content:String)->String{
    var customAllowedSet = NSCharacterSet(charactersInString:"=\"#%/<>?@\\^`{|}&").invertedSet
    content = content.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)!
    return content
}

func SAColorImg(theColor:UIColor)->UIImage{
    var rect = CGRectMake(0, 0, 1, 1)
    UIGraphicsBeginImageContext(rect.size)
    var context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, theColor.CGColor)
    CGContextFillRect(context, rect)
    var theImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return theImage
}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)

        CC_MD5(str!, strLen, result)

        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.destroy()

        return String(format: hash)
    }
 }


func resizedImage(initalImage: UIImage, newWidth:CGFloat) -> UIImage {
    var width = initalImage.size.width
    var height = initalImage.size.height
    var newheight:CGFloat = 0
    if width != 0 {
        newheight = height * newWidth / width
    }
    var newImage:UIImage
    if width >= newWidth {
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newheight))
        initalImage.drawInRect(CGRectMake(0, 0, newWidth, newheight))
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }else{
        newImage = initalImage
    }
    return newImage
}
