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
let BGColor:UIColor = UIColor.whiteColor()
let FontColor:UIColor = UIColor(red:0.78, green:0.26,blue:0.26,alpha: 1)   //字体灰
let BarColor:UIColor = UIColor(red:0.11, green:0.12, blue:0.13, alpha:1)
let DarkColor:UIColor = UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)   //图片底色
let LightBlueColor:UIColor = UIColor(red:0.00, green:0.67,blue:0.93,alpha: 1)   //念蓝
let LessBlueColor:UIColor = UIColor(red:0.00, green:0.67,blue:0.93,alpha: 0.2)   //念蓝
let LineColor:UIColor = UIColor(red:0.30, green:0.35,blue:0.40,alpha: 1)   //线条
let LittleLineColor:UIColor = UIColor(red:0.30, green:0.35,blue:0.40,alpha: 0.2)   //线条
let GoldColor:UIColor = UIColor(red:0.96, green:0.77,blue:0.23,alpha: 1)   //金色
let NavColor:UIColor = UIColor(red:0, green:0, blue:0, alpha:1)
let SeaColor:UIColor = UIColor(red:0.42, green:0.81, blue:0.99, alpha:1) //深海蓝

let product_coin12 = "so.nian.c12"
let product_coin30 = "so.nian.c30"
let product_coin65 = "so.nian.c65"
let product_coin140 = "so.nian.c140"
let product_coin295 = "so.nian.c295"

let TextLoadFailed = "加载数据失败了..."

var globalWillNianReload:Int = 0
var globalWillBBSReload:Int = 0
var globalNumberDream:Int = 0
var globalImageYPoint:CGFloat = 0

var globalWidth = UIScreen.mainScreen().bounds.width
var globalHeight = UIScreen.mainScreen().bounds.height

func SAPost(postString:String, urlString:String)->String{
    var strRet:NSString? = ""
    var request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.URL = NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    request!.HTTPMethod = "POST"
    request!.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    var response : NSURLResponse?
    var error : NSError?
    var returnData : NSData? = NSURLConnection.sendSynchronousRequest(request!, returningResponse : &response, error: &error)
    if  error == nil {
        strRet = NSString(data: returnData!, encoding:NSUTF8StringEncoding)
    }else{
        strRet = "err"
    }
    return strRet!
}

func SAGet(getString:String, urlString:String)->String{
    var request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.URL = NSURL(string: urlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
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
func SAHtml(content:String) -> String {
    var s = CFStringCreateMutableCopy(nil, 0, content)
    var r = CFRangeMake(0, 0)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "&", "&amp;", r, CFStringCompareFlags.allZeros)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "<", "&lt;", r, CFStringCompareFlags.allZeros)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, ">", "&gt;", r, CFStringCompareFlags.allZeros)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "\"", "&quot;", r, CFStringCompareFlags.allZeros)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "'", "&#039;", r, CFStringCompareFlags.allZeros)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, " ", "&nbsp;", r, CFStringCompareFlags.allZeros)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "\n", "<br>", r, CFStringCompareFlags.allZeros)
//    var newContent = SAReplace(content, "&", "&amp;");
//    newContent = SAReplace(newContent, "<", "&lt;");
//    newContent = SAReplace(newContent, ">", "&gt;");
//    newContent = SAReplace(newContent, "\"", "&quot;");
//    newContent = SAReplace(newContent, "'", "&#039;");
//    newContent = SAReplace(newContent, " ", "&nbsp;");
//    newContent = SAReplace(newContent, "\n", "<br>");
    return s
}

func SAEncode(content:String) -> String {
    let legalURLCharactersToBeEscaped: CFStringRef = "=\"#%/<>?@\\^`{|}&"
    return CFURLCreateStringByAddingPercentEscapes(nil, content, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue)
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

        var hash = NSMutableString(capacity: digestLen)
        for var i = 0; i < digestLen; i++ {
            hash.appendFormat("%02x", result[i])
        }

        result.destroy()

        return String(format: hash)
    }
    
    func isValidEmail()->Bool {
        let regex :String = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return emailTest!.evaluateWithObject(self)
    }
    
    func isValidName()->Bool {
        var regex = "^[A-Za-z0-9_\\-\\u4e00-\\u9fa5]+$"
        var nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest!.evaluateWithObject(self)
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

func getSaveKey(title:NSString, png:NSString) -> NSString{
    var date = NSDate().timeIntervalSince1970
    var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    var safeuid = Sa.objectForKey("uid") as String
    var string = NSString(string: "/\(title)/\(safeuid)_\(Int(date)).\(png)")
    return string
}

func checkNetworkStatus() -> Int{
    let reachability: Reachability = Reachability.reachabilityForInternetConnection()
    let networkStatus: NetworkStatus = reachability.currentReachabilityStatus()
    return networkStatus.rawValue    //0 无网络，1 流量，2 WIFI
}

func buttonArray()->[UIBarButtonItem]{
    var spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
    spaceButton.width = -14
    var rightButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
    var activity = UIActivityIndicatorView()
    activity.startAnimating()
    activity.color = IconColor
    activity.frame = CGRectMake(14, 9, 12, 12)
    rightButtonView.addSubview(activity)
    var rightLoadButton = UIBarButtonItem(customView: rightButtonView)
    return [ spaceButton, rightLoadButton ]
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func viewBack(VC:UIViewController){
    var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: VC, action: "back")
    leftButton.image = UIImage(named:"newBack")
    VC.navigationItem.leftBarButtonItem = leftButton;
    VC.navigationController!.interactivePopGestureRecognizer.enabled = true
}

func SAstrlen(stremp:NSString)->Int{
    let cfEncoding = CFStringConvertWindowsCodepageToEncoding(54936)
    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
    var da:NSData = stremp.dataUsingEncoding(gbkEncoding)!
    return da.length
}

extension UIVisualEffectView {
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        return view == self ? nil : view
    }
}

class fakeView:UIView{
    override internal func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, withEvent: event)
        return view == self ? nil : view
    }
}

class SAActivity: UIActivity {
    var saActivityTitle:String = ""
    var saActivityImage:UIImage! = UIImage()
    var saActivityFunction: (() -> Void)?
    override func activityType() -> String {
        return ""
    }
    override func activityTitle() -> String  {
        return saActivityTitle
    }
    override func activityImage() -> UIImage {
        return saActivityImage
    }
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        saActivityFunction!()
    }
}


