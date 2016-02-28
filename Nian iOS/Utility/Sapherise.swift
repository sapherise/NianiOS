//
//  Sapherise.swift
//  Nian iOS
//
//  Created by Sa on 14-7-9.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox

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
var globalViewFilmExist: Bool = false
var globalNumExploreBar: Int = -1
var globalTabBarSelected: Int = 0
var globalhasLaunched: Int = 0

// 定义三个页面为未加载状态
var globalTabhasLoaded = [false, false]
var globalReachability = ""

// 定义是否加载时清除已有 cell
var globalVVeboReload = false

let globalWidth = UIScreen.mainScreen().bounds.width
let globalHeight = UIScreen.mainScreen().bounds.height
let globalScale = UIScreen.mainScreen().scale
let globalHalf: CGFloat = globalScale > 0 ? 1 / globalScale : 0.5
var globaliPhone: Int =  globalHeight < 500 ? 4 : 5
var globaliOS: Double = (UIDevice.currentDevice().systemVersion as NSString).doubleValue
var isiPhone6: Bool = globalWidth == 375 ? true : false
var isiPhone6P: Bool = globalWidth == 414 ? true : false

func SAPost(postString:String, urlString:String)->String{
    var strRet:NSString? = ""
    let request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.URL = NSURL(string: urlString)
    request!.HTTPMethod = "POST"
    request!.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    var response : NSURLResponse?
    var error : NSError?
    var returnData : NSData?
    do {
        returnData = try NSURLConnection.sendSynchronousRequest(request!, returningResponse : &response)
    } catch let error1 as NSError {
        error = error1
        returnData = nil
    }
    if  error == nil {
        strRet = NSString(data: returnData!, encoding:NSUTF8StringEncoding)
    }else{
        strRet = "err"
    }
    return strRet! as String
}

func SAGet(getString:String, urlString:String)->String{
    let request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.URL = NSURL(string: urlString.encode())
    request!.HTTPMethod = "GET"
    request!.HTTPBody = getString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion : true)
    var response : NSURLResponse?
    var returnData : NSData?
    do {
        returnData = try NSURLConnection.sendSynchronousRequest(request!, returningResponse : &response)
    } catch _ as NSError {
        returnData = nil
    }
    let strRet:NSString? = NSString(data: returnData!, encoding:NSUTF8StringEncoding)
    return strRet! as String
}

func SAReplace(word:String, before:String, after:String)->NSString{
    return word.stringByReplacingOccurrencesOfString(before, withString: after, options: [], range: nil)
}

//替换危险字符
func SAHtml(content:String) -> String {
    let s = CFStringCreateMutableCopy(nil, 0, content)
    var r = CFRangeMake(0, 0)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "&", "&amp;", r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "<", "&lt;", r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, ">", "&gt;", r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "\"", "&quot;", r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "'", "&#039;", r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, " ", "&nbsp;", r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "\n", "<br>", r, CFStringCompareFlags())
    
    return s as String
}

func SAEncode(content:String) -> String {
    let legalURLCharactersToBeEscaped: CFStringRef = "=\"#%/<>?@\\^`{|}&+"
    return CFURLCreateStringByAddingPercentEscapes(nil, content, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
}

func SADecode(word: String) -> String {
    var content = word
    content = SAReplace(content, before: "&amp;", after: "&") as String
    content = SAReplace(content, before: "&lt;", after: "<") as String
    content = SAReplace(content, before: "&gt;", after: ">") as String
    content = SAReplace(content, before: "&quot;", after: "\"") as String
    content = SAReplace(content, before: "&#039;", after: "'") as String
    content = SAReplace(content, before: "&nbsp;", after: " ") as String
    content = SAReplace(content, before: "<br>", after: "\n") as String
    return content
}

func SAColorImg(theColor:UIColor)->UIImage{
    let rect = CGRectMake(0, 0, 1, 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    CGContextSetFillColorWithColor(context, theColor.CGColor)
    CGContextFillRect(context, rect)
    let theImage = UIGraphicsGetImageFromCurrentImageContext()
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

        let hash = NSMutableString(capacity: digestLen)
        for var i = 0; i < digestLen; i++ {
            hash.appendFormat("%02x", result[i])
        }

        result.destroy()

        return String(format: hash as String)
    }
    
    func encode() ->String {
        let content = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())
        return content != nil ? content! : ""
    }
    
    func isValidEmail()->Bool {
        let regex :String = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return emailTest.evaluateWithObject(self)
    }
    
    func isValidPhone()->Bool {
        let regex :String = "(^(13\\d|14[57]|15[^4,\\D]|17[678]|18\\d)\\d{8}|170[059]\\d{7})$"
        let PhoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return PhoneTest.evaluateWithObject(self)
    }
    
    func isValidName()->Bool {
        let regex = "^[A-Za-z0-9_\\-\\u4e00-\\u9fa5]+$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest.evaluateWithObject(self)
    }
    
    func isImage() -> Bool {
        let regex = "<image:[a-z0-9._]* w:[0-9.]* h:[0-9.]*>"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest.evaluateWithObject(self)
    }
    
    func isDream() -> Bool {
        let regex = "<dream:[0-9]*>"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest.evaluateWithObject(self)
    }
    
    func toRedditReduce() -> String{
        var content = self.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
        let expDream = try! NSRegularExpression(pattern: "<dream:[0-9]*>", options: NSRegularExpressionOptions())
        let expImage = try! NSRegularExpression(pattern: "<image:[a-z0-9._]* w:[0-9.]* h:[0-9.]*>", options: NSRegularExpressionOptions())
        content = expDream.stringByReplacingMatchesInString(content, options: NSMatchingOptions(), range: NSMakeRange(0, (content as NSString).length), withTemplate: "<记本>")
        content = expImage.stringByReplacingMatchesInString(content, options: NSMatchingOptions(), range: NSMakeRange(0, (content as NSString).length), withTemplate: "<图片>")
        return content
    }
    
    func decode() -> String {
        return SADecode(SADecode(self))
    }
}




func resizedImage(initalImage: UIImage, newWidth:CGFloat) -> UIImage {
    let width = initalImage.size.width
    let height = initalImage.size.height
    var newheight:CGFloat = 0
    if width != 0 {
        newheight = height * newWidth / width
        newheight = SACeil(newheight, dot: 0, isCeil: false)
    }
    var newImage: UIImage
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
    let date = NSDate().timeIntervalSince1970
    let string = NSString(string: "/\(title)/\(SAUid())_\(Int(date)).\(png)")
    return string
}

func buttonArray()->[UIBarButtonItem]{
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
    spaceButton.width = -14
    let rightButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
    let activity = UIActivityIndicatorView()
    activity.startAnimating()
    activity.color = UIColor.GreyColor1()
    activity.frame = CGRectMake(14, 9, 12, 12)
    activity.transform = CGAffineTransformMakeScale(0.8, 0.8)
    rightButtonView.addSubview(activity)
    let rightLoadButton = UIBarButtonItem(customView: rightButtonView)
    return [spaceButton, rightLoadButton]
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
        let leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "backNavigation")
        leftButton.image = UIImage(named:"newBack")
        self.navigationItem.leftBarButtonItem = leftButton
        viewBackFix()
    }
    
    func backNavigationRoot() {
        if let v = self.navigationController {
            v.popToRootViewControllerAnimated(true)
        }
    }
    
    func backNavigation(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
    func viewBackFix(){
        self.navigationController?.interactivePopGestureRecognizer!.enabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    
    func navMove(yPoint:CGFloat){
        var navigationFrame = self.navigationController?.navigationBar.frame
        if navigationFrame != nil {
            navigationFrame!.origin.y = yPoint
            self.navigationController?.navigationBar.frame = navigationFrame!
        }
    }
    
    func navShow() {
        navMove(20)
    }
    
    func navHide() {
        navMove(-44)
    }
    
    func SAUser(uid: String) {
        let UserVC = PlayerViewController()
        UserVC.Id = uid
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func SADream(id: String) {
        let DreamVC = DreamViewController()
        DreamVC.Id = id
        self.navigationController?.pushViewController(DreamVC, animated: true)
    }
    
    func SAXib(named: String) -> AnyObject {
        return (NSBundle.mainBundle().loadNibNamed(named, owner: self, options: nil) as NSArray).objectAtIndex(0)
    }
    
    func showTipText(text: String, delayTime: Double = 2.0) {
        let v: UIView? = UIView()
        v!.frame = CGRectMake(0, -64, globalWidth, 64)
        v!.backgroundColor = UIColor.HightlightColor()
        v!.userInteractionEnabled = true
        
        let label = UILabel()
        label.frame = CGRectMake(20, 20, globalWidth - 40, 44)
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.numberOfLines = 0
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = NSTextAlignment.Center
        label.alpha = 0
        
        v!.addSubview(label)
        UIApplication.sharedApplication().windows.first?.addSubview(v!)
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            v!.setY(0)
            label.alpha = 1
            }, completion: { (Bool) -> Void in
                v!.userInteractionEnabled = true
                v!.addGestureRecognizer(UITapGestureRecognizer(target: self.view.window, action: "onTip:"))
        })
        
        delay(delayTime) { () -> () in
            UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                v?.setY(-64)
                label.alpha = 0
                }) { (Bool) -> Void in
                    v?.removeFromSuperview()
            }
        }
        
    }
}

extension UIWindow {
    func onTip(sender: UIGestureRecognizer) {
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            sender.view?.setY(-64)
            sender.view?.subviews.first?.alpha = 0
            }) { (Bool) -> Void in
                sender.view?.removeFromSuperview()
        }
    }
}


func getImageFromView(view: UIView)->UIImage {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, globalScale);
    view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}

func SAstrlen(stremp:NSString)->Int{
    let cfEncoding = CFStringConvertWindowsCodepageToEncoding(54936)
    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
    let da:NSData = stremp.dataUsingEncoding(gbkEncoding)!
    return da.length
}

func viewEmpty(width:CGFloat, content:String = "这里是空的")->UIView {
    let viewEmpty = UIView(frame: CGRectMake(0, 0, width, 55))
    let labelEmpty = UILabel(frame: CGRectMake(0, 40, width, 20))
    labelEmpty.font = UIFont.systemFontOfSize(11)
    labelEmpty.textAlignment = NSTextAlignment.Center
    labelEmpty.textColor = UIColor(red:0.65, green:0.65, blue:0.65, alpha:1)
    labelEmpty.numberOfLines = 0
    labelEmpty.text = content
    let height = content.stringHeightWith(11, width: width)
    labelEmpty.setHeight(height)
    viewEmpty.addSubview(labelEmpty)
    viewEmpty.setHeight(height + 60)
    return viewEmpty
}

extension UIViewController {
    
    /* 邮箱登录、第三方登录、邮箱注册、第三方注册、普通启动*/
    func launch() {
        
        IMClass.IMConnect()
        delay(0.2) { () -> () in
            let mainViewController = HomeViewController(nibName:nil,  bundle: nil)
            let navigationViewController = UINavigationController(rootViewController: mainViewController)
            navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
            navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
            navigationViewController.navigationBar.translucent = true
            navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
            navigationViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            navigationViewController.navigationBar.clipsToBounds = true
            self.presentViewController(navigationViewController, animated: true, completion: nil)
            
            /* 调用 Home 中的唤醒函数 */
            NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
        }
    }
    
    /* 第二天推送 */
    func pushTomorrow() {
        thepush("Mua!", dateSinceNow: 60 * 60 * 24, willReapt: false, id: "signup")
    }
    
    func viewLoadingShow() {
        globalViewLoading = UIView(frame: CGRectMake((globalWidth-50)/2, (globalHeight-50)/2, 50, 50))
        globalViewLoading!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        globalViewLoading!.layer.cornerRadius = 4
        globalViewLoading!.layer.masksToBounds = true
        globalViewLoading!.userInteractionEnabled = false
        globalViewLoading?.hidden = true
        let activity = UIActivityIndicatorView(frame: CGRectMake(10, 10, 30, 30))
        activity.color = UIColor.whiteColor()
        activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        activity.hidden = false
        activity.startAnimating()
        globalViewLoading!.addSubview(activity)
        if let v = UIApplication.sharedApplication().windows.first {
            v.addSubview(globalViewLoading!)
            delay(0.3, closure: { () -> () in
                globalViewLoading!.hidden = false
                return
            })
        }
    }
    
    func viewLoadingHide() {
        globalViewLoading?.removeFromSuperview()
    }
    
    func SAlogout(){
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        uidKey.resetKeychainItem()
        Sa.removeObjectForKey("uid")
        Sa.removeObjectForKey("shell")
        Sa.removeObjectForKey("followData")
        Sa.removeObjectForKey("user")
        Sa.synchronize()
        
        // 退出后应该设置三个都为未加载状态
        globalTabhasLoaded = [false, false]
        self.dismissViewControllerAnimated(true, completion: nil)
        
        RCIMClient.sharedRCIMClient().disconnect(false)
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
    var saActivityImage: UIImage?
    var saActivityFunction: (() -> Void)?
    var saActivityType: String = ""
    override func activityType() -> String {
        return saActivityType
    }
    override func activityTitle() -> String  {
        return saActivityTitle
    }
    override func activityImage() -> UIImage? {
        return saActivityImage
    }
    override func canPerformWithActivityItems(activityItems: [AnyObject]) -> Bool {
        return true
    }
    override func prepareWithActivityItems(activityItems: [AnyObject]) {
        saActivityFunction!()
    }
    override class func activityCategory() -> UIActivityCategory {
       return .Action
    }
    override func performActivity() {
        
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
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.Up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.drawInRect(rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    class func imageFromURL(aURL: NSURL, success: ((image: UIImage) -> Void), error: () -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            let mutableRequest: NSMutableURLRequest = NSMutableURLRequest(URL: aURL,
                                                                          cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad,
                                                                          timeoutInterval: 30.0)
            let rcvData: NSData? = try? NSURLConnection.sendSynchronousRequest(mutableRequest, returningResponse: nil)
//            var img: UIImage = UIImage(data: rcvData!)!
            
            dispatch_async(dispatch_get_main_queue(), {
                if let img = UIImage(data: rcvData!) {
                    success(image: img)
                }
            })
            
        })
    }
    
}

extension UIImageView{
    func SAMaskImage(isMe: Bool = true){
    }
    
    func setHolder(){
        self.contentMode = UIViewContentMode.Center
    }
    
    func setAnimationWanderX(leftStartX: CGFloat, leftEndX: CGFloat, rightStartX: CGFloat, rightEndX: CGFloat) {
        self.setX(leftStartX)
        UIView.animateWithDuration(4, animations: { () -> Void in
            self.setX(leftEndX)
            }) { (Bool) -> Void in
                self.setX(rightStartX)
                self.layer.transform = CATransform3DConcat(self.layer.transform, CATransform3DMakeRotation(CGFloat(M_PI), 0, -1, 0))
                UIView.animateWithDuration(4, animations: { () -> Void in
                    self.setX(rightEndX)
                    }, completion: { (Bool) -> Void in
                        self.layer.transform = CATransform3DConcat(self.layer.transform, CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0))
                        self.setAnimationWanderX(leftStartX, leftEndX: leftEndX, rightStartX: rightStartX, rightEndX: rightEndX)
                })
        }
    }
    
    func setAnimationWanderY(startY: CGFloat, endY: CGFloat, animated: Bool = true) {
        if animated {
//            UIView.animateWithDuration(2, animations: { () -> Void in
//                self.setY(endY)
//                }) { (Bool) -> Void in
//                    UIView.animateWithDuration(2, animations: { () -> Void in
//                        self.setY(startY)
//                        }, completion: { (Bool) -> Void in
//                            self.setAnimationWanderY(startY, endY: endY)
//                    })
//            }
            UIView.animateWithDuration(2, animations: { () -> Void in
                self.setY(endY)
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(2, animations: { () -> Void in
                    self.setY(startY)
                }, completion: { (Bool) -> Void in
                    if globaliOS >= 8.0 {
                        self.setAnimationWanderY(startY, endY: endY, animated: animated)
                    }
                })
            })
        }else{
            self.setY(startY)
            delay(1, closure: { () -> () in
                self.setY(endY)
                delay(1, closure: { () -> () in
                    self.setAnimationWanderY(startY, endY: endY, animated: animated)
                })
            })
        }
    }
    
    func getPoint() -> CGPoint {
        let y = self.convertPoint(CGPointZero, fromView: self.window)
        return y
    }
    
    
    func drawCornerRadius(radius: CGFloat, image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, image.scale)
        UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).addClip()
        
        image.drawInRect(self.bounds)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
}

extension UIViewController {
    
    func keyboardStartObserve() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func keyboardEndObserve() {
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillShowNotification)
        NSNotificationCenter.defaultCenter().removeObserver(UIKeyboardWillHideNotification)
    }
    
    func onURL(sender: NSNotification){
        let url = sender.object as! String
        var urlArray = "\(url)".componentsSeparatedByString("nian://")
        if urlArray.count == 2 {
            urlArray = urlArray[1].componentsSeparatedByString("/")
            if urlArray.count == 2 {
                if let id = Int(urlArray[1]) {
                    if urlArray[0] == "dream" {
                        let DreamVC = DreamViewController()
                        DreamVC.Id = "\(id)"
                        self.navigationController?.pushViewController(DreamVC, animated: true)
                    }else if urlArray[0] == "user" {
                        let UserVC = PlayerViewController()
                        UserVC.Id = "\(id)"
                        self.navigationController?.pushViewController(UserVC, animated: true)
                    }
                }
            }
        }
    }
    
    /* 进入应用锁密码界面 */
    func onLock(type: lockType) {
        if let _ = Cookies.get("Lock") as? String {
            let vc = Lock()
            vc.type = type
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

extension UIButton {
    func startLoading() {
        self.enabled = false
        self.setTitle("", forState: UIControlState())
        let activity = UIActivityIndicatorView(frame: CGRectMake(self.width()/2 - 10, self.height()/2 - 10, 20, 20))
        activity.color = UIColor.whiteColor()
        activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        self.addSubview(activity)
        activity.hidden = false
        activity.startAnimating()
    }
    func endLoading(text: String) {
        let views:NSArray = self.subviews
        for view:AnyObject in views {
            if NSStringFromClass(view.classForCoder) == "UIActivityIndicatorView"  {
                view.removeFromSuperview()
            }
        }
        let imageView = UIImageView(frame: CGRectMake(self.width()/2 - 12, self.height()/2 - 12, 24, 24))
        imageView.image = UIImage(named: "newOK")
        imageView.contentMode = UIViewContentMode.Center
        self.addSubview(imageView)
        delay(2, closure: { () -> () in
            self.setTitle(text, forState: UIControlState())
            imageView.removeFromSuperview()
            self.enabled = true
            return
        })
    }
    func setButtonNice(content:String){
        self.frame = CGRectMake(0, 0, 100, 36)
        self.layer.cornerRadius = 18
        self.backgroundColor = UIColor.HightlightColor()
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
        self.titleLabel!.font = UIFont.systemFontOfSize(13)
        self.setTitle(content, forState: UIControlState())
    }
}

func shake() {
    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
}

func getCacheImage(url: String) -> UIImage? {
    return SDImageCache.sharedImageCache().imageFromDiskCacheForKey(url)
}

func setCacheImage(url: String, img: UIImage, width: CGFloat) {
    var imageNew = width == 0 ? img : resizedImage(img, newWidth: width)
    imageNew = imageNew.fixOrientation()
    SDImageCache.sharedImageCache().storeImage(imageNew, forKey: url)
}

func SAUpdate(dataArray: NSMutableArray, index: Int, key: String, value: AnyObject, tableView: UITableView) {
    let data = dataArray[index] as! NSDictionary
    let mutableItem = NSMutableDictionary(dictionary: data)
    mutableItem.setValue(value, forKey: key)
    dataArray.replaceObjectAtIndex(index, withObject: mutableItem)
}

func SAUpdate(dataArray: NSMutableArray, index: Int, data: NSDictionary, tableView: UITableView) {
    dataArray.replaceObjectAtIndex(index, withObject: data)
}

func SAUpdate(index: Int, section: Int, tableView: UITableView) {
    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: section)], withRowAnimation: UITableViewRowAnimation.Left)
}

func SAUpdate(delete: Bool, dataArray: NSMutableArray, index: Int, tableView: UITableView, section: Int) {
    if delete {
        dataArray.removeObjectAtIndex(index)
        tableView.beginUpdates()
        tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: section)], withRowAnimation: UITableViewRowAnimation.Fade)
        tableView.reloadData()
        tableView.endUpdates()
    }
}

func SAUid() -> String {
    let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    let uid = uidKey.objectForKey(kSecAttrAccount) as? String
    if uid != nil {
        return uid!
    }
    return "0"
}

func SACeil(num: CGFloat, dot: Int, isCeil: Bool = true) -> CGFloat {
    // ceil 向上取整
    let a = pow(10, Double(dot))
    var b: CGFloat
    if isCeil {
        b = CGFloat(ceil(Double(num) * a) / a)
    } else {
        b = CGFloat(floor(Double(num) * a) / a)
    }
    return b
}

extension UIColor {
    class func colorWithHex(hexString: String) -> UIColor {
        let regexp = try? NSRegularExpression(pattern: "\\A#[0-9a-f]{6}\\z",
            options: .CaseInsensitive)
        let num = regexp?.numberOfMatchesInString(hexString,
            options: .ReportProgress,
            range: NSMakeRange(0, hexString.characters.count))
        if num != 1 {
            return UIColor.HightlightColor()
        }
        var rgbValue : UInt32 = 0
        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = 1
        scanner.scanHexInt(&rgbValue)
        let red   = CGFloat( (rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat( (rgbValue & 0xFF00) >> 8) / 255.0
        let blue  = CGFloat( (rgbValue & 0xFF) ) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    class func b3() -> UIColor! {
        return UIColor(red:0.7, green:0.7, blue:0.7, alpha:1)
    }
    
    class func e6() -> UIColor! {
        return UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
    }
    
    class func C98() -> UIColor! {
        return UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
    }
    
    class func C33() -> UIColor! {
        return UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
    }
    
    class func f0() -> UIColor! {
        return UIColor(red:0.94, green:0.94, blue:0.94, alpha:1)
    }
    
    class func C96() -> UIColor! {
        return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
    }
    
    class func C94() -> UIColor! {
        return UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
    }
}

let BGColor:UIColor = UIColor.whiteColor()
let GoldColor:UIColor = UIColor(red:0.96, green:0.77,blue:0.23,alpha: 1)   //金色
let greyColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1) // #333333

func SAThousand(num: String) -> String {
    if var IntNum = Int(num) {
        if IntNum >= 1000 {
            IntNum = IntNum / 100
            let FloatNum = Float(IntNum) / 10
            return "\(FloatNum)K"
        } else {
            return num
        }
    }
    return ""
}

extension UIView {
    func setRadius(size: CGFloat, isTop: Bool) {
        var rectCorner: UIRectCorner = [UIRectCorner.TopLeft, UIRectCorner.TopRight]
        if !isTop {
            rectCorner = [UIRectCorner.BottomLeft, UIRectCorner.BottomRight]
        }
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSizeMake(size, size))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        self.layer.mask = maskLayer
    }
    
    func addGhost(content: String) {
        let vHolder = UIView(frame: CGRectMake(0, 0, 280, 110))
        let v = UIImageView(frame: CGRectMake(0, 0, 280, 60))
        v.image = UIImage(named: "pet_ghost")
        v.contentMode = UIViewContentMode.Center
        let label = UILabel(frame: CGRectMake(0, 76, 280, 40))
        let h = content.stringHeightWith(13, width: 280)
        label.text = content
        label.font = UIFont.systemFontOfSize(13)
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.textColor = UIColor.b3()
        label.setHeight(h)
        vHolder.addSubview(v)
        vHolder.addSubview(label)
        vHolder.setHeight(h + 76)
        vHolder.center = self.center
        self.addSubview(vHolder)
    }
}

func SACookie(key: String) -> String? {
    return NSUserDefaults.standardUserDefaults().objectForKey(key) as? String
}

class Cookies {
    class func set(value: AnyObject?, forKey: String) {
        let Cookie = NSUserDefaults.standardUserDefaults()
        Cookie.setObject(value, forKey: forKey)
        Cookie.synchronize()
    }
    class func get(key: String) -> AnyObject? {
        let Cookie = NSUserDefaults.standardUserDefaults()
        return Cookie.objectForKey(key)
    }
    class func remove(key: String) {
        let Cookie = NSUserDefaults.standardUserDefaults()
        Cookie.removeObjectForKey(key)
        Cookie.synchronize()
    }
}

/**
等价于 objective-c 里面的 synchonized

- parameter lock:    <#lock description#>
- parameter closure: <#closure description#>
*/
public func synchronized(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

// 前后均会包含
// 例如 1, 4，会返回 1 2 3 4
func getRandomNumber(from: Int, to: Int) -> Int {
    return Int(arc4random() % UInt32(to - from + 1)) + from
}

// 冒泡排序
func bubble(arr: [Int]) -> [Int] {
    var _arr = arr
    if arr.count >= 2 {
        for _ in 0...(arr.count - 1) {
            for j in 0...(arr.count - 2) {
                    if  _arr[j] > _arr[j + 1] {
                        let tmp = _arr[j]
                        _arr[j] = _arr[j + 1]
                        _arr[j + 1] = tmp
                    }
            }
        }
    }
    return _arr
}

func go(justdoit: () -> Void) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), justdoit)
}

func back(justdoit: () -> Void) {
    dispatch_async(dispatch_get_main_queue(), justdoit)
}

/* 清除角标 */
extension UIApplication {
    func clearBadge() {
        self.applicationIconBadgeNumber = 1
        self.applicationIconBadgeNumber = 0
    }
}
