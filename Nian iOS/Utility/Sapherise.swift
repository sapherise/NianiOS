//
//  Sapherise.swift
//  Nian iOS
//
//  Created by Sa on 14-7-9.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation


let IconColor:UIColor = UIColor(red:0.97, green:0.97,blue:0.97,alpha: 1)    //字体灰
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
var globalImageYPoint:CGRect = CGRectZero
var globalWillCircleChatReload:Int = 0
var globalWillCircleJoinReload:Int = 0
var globalWillReEnter: Int = 0
var globalURL:String = ""
var globalViewLoading:UIView?
var globalViewFilm:ILTranslucentView?
var globalViewFilmExist: Bool = false
var globalNumExploreBar: Int = -1
var globalTabBarSelected: Int = 0
var globalCurrentCircle: Int = 0
var globalCurrentLetter: Int = 0
var globalNoticeNumber: Int = 0

var globalWidth = UIScreen.mainScreen().bounds.width
var globalHeight = UIScreen.mainScreen().bounds.height
var globaliPhone: Int =  globalHeight < 500 ? 4 : 5
var globaliOS: Double = (UIDevice.currentDevice().systemVersion as NSString).doubleValue

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
    return s
}

func SAEncode(content:String) -> String {
    let legalURLCharactersToBeEscaped: CFStringRef = "=\"#%/<>?@\\^`{|}&+"
    return CFURLCreateStringByAddingPercentEscapes(nil, content, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue)
}

func SADecode(word: String) -> String {
    var content = word
    content = SAReplace(content, "&amp;", "&")
    content = SAReplace(content, "&lt;", "<")
    content = SAReplace(content, "&gt;", ">")
    content = SAReplace(content, "&quot;", "\\")
    content = SAReplace(content, "&#039;", "'")
    content = SAReplace(content, "&nbsp;", " ")
    content = SAReplace(content, "<br>", "\n")
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
    
    func isValidPhone()->Bool {
        let regex :String = "^(1(([35][0-9])|(47)|[8][01236789]))\\d{8}$"
        let PhoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return PhoneTest!.evaluateWithObject(self)
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

extension UIViewController: UIGestureRecognizerDelegate {
    func viewBack(){
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "backNavigation")
        leftButton.image = UIImage(named:"newBack")
        self.navigationItem.leftBarButtonItem = leftButton
        if let v = self.navigationController {
            v.interactivePopGestureRecognizer.enabled = true
            v.interactivePopGestureRecognizer.delegate = self
        }
    }
    func backNavigation(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
    func viewBackFix(){
        if let v = self.navigationController {
            v.interactivePopGestureRecognizer.enabled = true
            v.interactivePopGestureRecognizer.delegate = self
        }
    }
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

func viewEmpty(width:CGFloat, content:String = "这里是空的")->UIView {
    var viewEmpty = UIView(frame: CGRectMake(0, 0, width, 55))
    var imageEmpty = UIImageView(frame: CGRectMake(0, 0, width, 35))
    imageEmpty.image = UIImage(named: "smile")
    imageEmpty.contentMode = UIViewContentMode.Center
    var labelEmpty = UILabel(frame: CGRectMake(0, 40, width, 20))
    labelEmpty.font = UIFont.systemFontOfSize(11)
    labelEmpty.textAlignment = NSTextAlignment.Center
    labelEmpty.textColor = UIColor(red:0.65, green:0.65, blue:0.65, alpha:1)
    labelEmpty.numberOfLines = 0
    labelEmpty.text = content
    var height = content.stringHeightWith(11, width: width)
    labelEmpty.setHeight(height)
    viewEmpty.addSubview(imageEmpty)
    viewEmpty.addSubview(labelEmpty)
    viewEmpty.setHeight(height + 60)
    return viewEmpty
}

extension UIViewController {
    func viewLoadingShow() {
        globalViewLoading = UIView(frame: CGRectMake((globalWidth-50)/2, (globalHeight-50)/2, 50, 50))
        globalViewLoading!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        globalViewLoading!.layer.cornerRadius = 4
        globalViewLoading!.layer.masksToBounds = true
        globalViewLoading!.userInteractionEnabled = false
        globalViewLoading?.hidden = true
        var activity = UIActivityIndicatorView(frame: CGRectMake(10, 10, 30, 30))
        activity.color = UIColor.whiteColor()
        activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        activity.hidden = false
        activity.startAnimating()
        globalViewLoading!.addSubview(activity)
        if let v = self.navigationController?.navigationBar.window {
            v.addSubview(globalViewLoading!)
            delay(0.3, { () -> () in
                globalViewLoading!.hidden = false
                return
            })
        }
    }
    func viewLoadingHide() {
        globalViewLoading?.removeFromSuperview()
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

extension UIImage{
    func resetToSize(size:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let lResultImage:UIImage=UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return lResultImage;
    }
}

extension UIImageView{
    func SAMaskImage(isMe: Bool = true){
        var textMask = "bubble"
        if isMe {
            textMask = "bubble_me"
        }
        var size = CGSizeMake(self.bounds.size.width, self.bounds.size.height)
        UIGraphicsBeginImageContext(size)
        var ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColor(ctx, [1.0,1.0,1.0,1.0])
        CGContextFillRect(ctx, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height))
        var background = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        var subLayer = CALayer()
        subLayer.frame = self.bounds
        subLayer.contents = background.CGImage
        subLayer.rasterizationScale = UIScreen.mainScreen().scale
        var maskLayer = CALayer()
        maskLayer.frame = self.bounds
        subLayer.mask = maskLayer
        var roundCornerLayer = CALayer()
        roundCornerLayer.frame = self.bounds
        roundCornerLayer.contents = UIImage(named: textMask)!.resetToSize(self.bounds.size).CGImage
        self.layer.addSublayer(subLayer)
        self.layer.mask = roundCornerLayer
    }
    
    func setHolder(){
        self.image = UIImage(named: "drop")
        self.backgroundColor = IconColor
        self.contentMode = UIViewContentMode.Center
    }
}

extension UIViewController {
    func onURL(sender: NSNotification){
        var url = sender.object as String
        var urlArray = "\(url)".componentsSeparatedByString("nian://")
        if urlArray.count == 2 {
            urlArray = urlArray[1].componentsSeparatedByString("/")
            if urlArray.count == 2 {
                if let id = urlArray[1].toInt() {
                    if urlArray[0] == "dream" {
                        var DreamVC = DreamViewController()
                        DreamVC.Id = "\(id)"
                        self.navigationController?.pushViewController(DreamVC, animated: true)
                    }else if urlArray[0] == "user" {
                        var UserVC = PlayerViewController()
                        UserVC.Id = "\(id)"
                        self.navigationController?.pushViewController(UserVC, animated: true)
                    }
                }
            }
        }
    }
}

extension UIButton {
    func startLoading() {
        var height = self.height()
        self.enabled = false
        self.setTitle("", forState: UIControlState.allZeros)
        var activity = UIActivityIndicatorView(frame: CGRectMake(self.width()/2 - 10, self.height()/2 - 10, 20, 20))
        activity.color = UIColor.whiteColor()
        activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        self.addSubview(activity)
        activity.hidden = false
        activity.startAnimating()
    }
    func endLoading(text: String) {
        var views:NSArray = self.subviews
        for view:AnyObject in views {
            if NSStringFromClass(view.classForCoder) == "UIActivityIndicatorView"  {
                view.removeFromSuperview()
            }
        }
        var imageView = UIImageView(frame: CGRectMake(self.width()/2 - 12, self.height()/2 - 12, 24, 24))
        imageView.image = UIImage(named: "newOK")
        imageView.contentMode = UIViewContentMode.Center
        self.addSubview(imageView)
        delay(2, { () -> () in
            self.setTitle(text, forState: UIControlState.allZeros)
            imageView.removeFromSuperview()
            self.enabled = true
            return
        })
    }
    func setButtonNice(content:String){
        self.frame = CGRectMake(0, 0, 100, 36)
        self.layer.cornerRadius = 18
        self.backgroundColor = SeaColor
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.allZeros)
        self.titleLabel!.font = UIFont.systemFontOfSize(13)
        self.setTitle(content, forState: UIControlState.allZeros)
    }
}

extension UIViewController {
    
    // transDirectly 为真的时候，直接与服务器交互，否则会先跳转到某个页面进行选择，如推广、废纸篓
    // globalViewfilmExist 为真的时候，直接在当前的幕布下修改，否则创建一个幕布进行修改
    func showFilm(title: String, prompt: String, button: String, transDirectly: Bool, callback: (FilmCell) -> Void) {
        if !globalViewFilmExist {
            globalViewFilmExist = true
            globalViewFilm = ILTranslucentView(frame: CGRectMake(0, 0, globalWidth, globalHeight))
            globalViewFilm!.alpha = 0
            globalViewFilm!.translucentAlpha = 1
            globalViewFilm!.translucentStyle = UIBarStyle.Default
            globalViewFilm!.translucentTintColor = UIColor.clearColor()
            globalViewFilm!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
            globalViewFilm!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onFilmTap:"))
            globalViewFilm!.userInteractionEnabled = true
            var nib = NSBundle.mainBundle().loadNibNamed("Film", owner: self, options: nil) as NSArray
            var viewFilmDialog: FilmCell = nib.objectAtIndex(0) as FilmCell
            viewFilmDialog.frame.origin.x = ( globalWidth - 270 ) / 2
            viewFilmDialog.frame.origin.y = -270
            viewFilmDialog.labelTitle.text = title
            viewFilmDialog.labelDes.text = prompt
            viewFilmDialog.labelDes.setHeight(prompt.stringHeightWith(12, width: 200))
            viewFilmDialog.btnBuy.setTitle(button, forState: UIControlState.Normal)
            viewFilmDialog.btnBuy.setY(viewFilmDialog.labelDes.bottom()+22)
            viewFilmDialog.transDirectly = transDirectly
            viewFilmDialog.callback = callback
            globalViewFilm!.addSubview(viewFilmDialog)
            view.addSubview(globalViewFilm!)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                globalViewFilm!.alpha = 1
                viewFilmDialog.frame.origin.y = (globalHeight - globalWidth)/2 + 45
            })
            delay(0.3, {
                UIView.animateWithDuration(0.1, animations: { () -> Void in
                    viewFilmDialog.frame.origin.y = (globalHeight - globalWidth)/2 + 25
                })
            })
        }else{
            var views:NSArray = globalViewFilm!.subviews
            for view:AnyObject in views {
                if NSStringFromClass(view.classForCoder) == "Nian_iOS.FilmCell" {
                    if let v = view as? FilmCell {
                        v.labelTitle.text = title
                        v.labelDes.text = prompt
                        v.labelDes.setHeight(prompt.stringHeightWith(12, width: 200))
                        v.btnBuy.setTitle(button, forState: UIControlState.Normal)
                        v.btnBuy.setY(v.labelDes.bottom()+22)
                        v.transDirectly = transDirectly
                        v.callback = callback
                    }
                }
            }
        }
    }
    
    // 点击 Film 的其他部分，消失并移除这个 Film
    func onFilmTap(sender: UIGestureRecognizer){
        globalViewFilmExist = false
        UIView.animateWithDuration(0.3, animations: {
            () -> Void in
            if sender.view != nil {
                sender.view!.alpha = 0
            }
            }, completion: {
                finish in
                if sender.view != nil {
                    sender.view!.removeFromSuperview()
                }
        })
    }
    
    // 关闭当前的 Film
    func onFilmClose(){
        if globalViewFilm != nil {
            globalViewFilm!.removeFromSuperview()
            globalViewFilmExist = false
        }
    }
}
