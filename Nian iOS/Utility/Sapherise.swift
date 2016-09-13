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

var globalViewLoading:UIView?
var globalNumExploreBar: Int = -1
var globalTabBarSelected: Int = 0

// 定义三个页面为未加载状态
var globalTabhasLoaded = [false, false]
var globalReachability = ""

// 定义是否加载时清除已有 cell
var globalVVeboReload = false

let globalWidth = UIScreen.main.bounds.width
let globalHeight = UIScreen.main.bounds.height
let globalScale = UIScreen.main.scale
let globalHalf: CGFloat = globalScale > 0 ? 1 / globalScale : 0.5
var globaliPhone: Int =  globalHeight < 500 ? 4 : 5
var globaliOS: Double = (UIDevice.current.systemVersion as NSString).doubleValue
var isiPhone6: Bool = globalWidth == 375 ? true : false
var isiPhone6P: Bool = globalWidth == 414 ? true : false

func SAPost(_ postString:String, urlString:String)->String{
    var strRet:NSString? = ""
    let request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.url = URL(string: urlString)
    request!.httpMethod = "POST"
    request!.httpBody = postString.data(using: String.Encoding.utf8, allowLossyConversion : true)
    var response : URLResponse?
    var error : NSError?
    var returnData : Data?
    do {
        returnData = try NSURLConnection.sendSynchronousRequest(request! as URLRequest, returning : &response)
    } catch let error1 as NSError {
        error = error1
        returnData = nil
    }
    if  error == nil {
        strRet = NSString(data: returnData!, encoding:String.Encoding.utf8.rawValue)
    }else{
        strRet = "err"
    }
    return strRet! as String
}

func SAGet(_ getString:String, urlString:String)->String{
    let request : NSMutableURLRequest? = NSMutableURLRequest()
    request!.url = URL(string: urlString.encode())
    request!.httpMethod = "GET"
    request!.httpBody = getString.data(using: String.Encoding.utf8, allowLossyConversion : true)
    var response : URLResponse?
    var returnData : Data?
    do {
        returnData = try NSURLConnection.sendSynchronousRequest(request! as URLRequest, returning : &response)
    } catch _ as NSError {
        returnData = nil
    }
    let strRet:NSString? = NSString(data: returnData!, encoding:String.Encoding.utf8.rawValue)
    return strRet! as String
}

func SAReplace(_ word:String, before:String, after:String)->NSString{
    return word.replacingOccurrences(of: before, with: after, options: [], range: nil) as NSString
}

//替换危险字符
func SAHtml(_ content:String) -> String {
    let s = CFStringCreateMutableCopy(nil, 0, content as CFString!)
    var r = CFRangeMake(0, 0)
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "&" as CFString!, "&amp;" as CFString!, r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "<" as CFString!, "&lt;" as CFString!, r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, ">" as CFString!, "&gt;" as CFString!, r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "\"" as CFString!, "&quot;" as CFString!, r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "'" as CFString!, "&#039;" as CFString!, r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, " " as CFString!, "&nbsp;" as CFString!, r, CFStringCompareFlags())
    r.length = CFStringGetLength(s)
    CFStringFindAndReplace(s, "\n" as CFString!, "<br>" as CFString!, r, CFStringCompareFlags())
    
    return "\(s)" as String
}

func SAEncode(_ content:String) -> String {
    let legalURLCharactersToBeEscaped: CFString = "=\"#%/<>?@\\^`{|}&+" as CFString
    return CFURLCreateStringByAddingPercentEscapes(nil, content as CFString!, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
}

func SADecode(_ word: String) -> String {
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

func SAColorImg(_ theColor:UIColor)->UIImage{
    let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(theColor.cgColor)
    context?.fill(rect)
    let theImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return theImage!
}

extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        CC_MD5(str!, strLen, result)

        let hash = NSMutableString(capacity: digestLen)
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }

        result.deinitialize()

        return String(format: hash as String)
    }
    
    func encode() ->String {
        let content = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed)
        return content != nil ? content! : ""
    }
    
    func isValidEmail()->Bool {
        let regex :String = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return emailTest.evaluate(with: self)
    }
    
    func isValidPhone()->Bool {
        let regex :String = "(^(13\\d|14[57]|15[^4,\\D]|17[678]|18\\d)\\d{8}|170[059]\\d{7})$"
        let PhoneTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return PhoneTest.evaluate(with: self)
    }
    
    func isValidName()->Bool {
        let regex = "^[A-Za-z0-9_\\-\\u4e00-\\u9fa5]+$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest.evaluate(with: self)
    }
    
    func isImage() -> Bool {
        let regex = "<image:[a-z0-9._]* w:[0-9.]* h:[0-9.]*>"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest.evaluate(with: self)
    }
    
    func isDream() -> Bool {
        let regex = "<dream:[0-9]*>"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", regex)
        return nameTest.evaluate(with: self)
    }
    
    func toRedditReduce() -> String{
        var content = self.trimmingCharacters(in: CharacterSet.newlines)
        let expDream = try! NSRegularExpression(pattern: "<dream:[0-9]*>", options: NSRegularExpression.Options())
        let expImage = try! NSRegularExpression(pattern: "<image:[a-z0-9._]* w:[0-9.]* h:[0-9.]*>", options: NSRegularExpression.Options())
        content = expDream.stringByReplacingMatches(in: content, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, (content as NSString).length), withTemplate: "<记本>")
        content = expImage.stringByReplacingMatches(in: content, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, (content as NSString).length), withTemplate: "<图片>")
        return content
    }
    
    func decode() -> String {
        return SADecode(SADecode(self))
    }
}




func resizedImage(_ initalImage: UIImage, newWidth:CGFloat) -> UIImage {
    let width = initalImage.size.width
    let height = initalImage.size.height
    var newheight:CGFloat = 0
    if width != 0 {
        newheight = height * newWidth / width
        newheight = SACeil(newheight, dot: 0, isCeil: false)
    }
    var newImage: UIImage
    if width >= newWidth {
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newheight))
        initalImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newheight))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
    }else{
        newImage = initalImage
    }
    return newImage
}

func getSaveKey(_ title:NSString, png:NSString) -> NSString{
    let date = Date().timeIntervalSince1970
    let string = NSString(string: "/\(title)/\(SAUid())_\(Int(date)).\(png)")
    return string
}

func buttonArray()->[UIBarButtonItem]{
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fixedSpace, target: nil, action: nil)
    spaceButton.width = -14
    let rightButtonView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    let activity = UIActivityIndicatorView()
    activity.startAnimating()
    activity.color = UIColor.GreyColor1()
    activity.frame = CGRect(x: 14, y: 9, width: 12, height: 12)
    activity.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    rightButtonView.addSubview(activity)
    let rightLoadButton = UIBarButtonItem(customView: rightButtonView)
    return [spaceButton, rightLoadButton]
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

extension UIViewController: UIGestureRecognizerDelegate {
    func viewBack(){
        let leftButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(UIViewController.backNavigation))
        leftButton.image = UIImage(named:"newBack")
        self.navigationItem.leftBarButtonItem = leftButton
        viewBackFix()
    }
    
    func backNavigationRoot() {
        if let v = self.navigationController {
            v.popToRootViewController(animated: true)
        }
    }
    
    func backNavigation(){
        if let v = self.navigationController {
            v.popViewController(animated: true)
        }
    }
    func viewBackFix(){
        self.navigationController?.interactivePopGestureRecognizer!.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
    }
    
    func navMove(_ yPoint:CGFloat){
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
    
    func SAUser(_ uid: String) {
        let UserVC = PlayerViewController()
        UserVC.Id = uid
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func SADream(_ id: String) {
        let DreamVC = DreamViewController()
        DreamVC.Id = id
        self.navigationController?.pushViewController(DreamVC, animated: true)
    }
    
    func showTipText(_ text: String, delayTime: Double = 2.0) {
        let v: UIView? = UIView()
        v!.frame = CGRect(x: 0, y: -64, width: globalWidth, height: 64)
        v!.backgroundColor = UIColor.HighlightColor()
        v!.isUserInteractionEnabled = true
        
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 20, width: globalWidth - 40, height: 44)
        label.text = text
        label.textColor = UIColor.white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = NSTextAlignment.center
        label.alpha = 0
        
        v!.addSubview(label)
        UIApplication.shared.windows.first?.addSubview(v!)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
            v!.setY(0)
            label.alpha = 1
            }, completion: { (Bool) -> Void in
                v!.isUserInteractionEnabled = true
                v!.addGestureRecognizer(UITapGestureRecognizer(target: self.view.window, action: #selector(UIWindow.onTip(_:))))
        })
        
        delay(delayTime) { () -> () in
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
                v?.setY(-64)
                label.alpha = 0
                }) { (Bool) -> Void in
                    v?.removeFromSuperview()
            }
        }
        
    }
}

extension UIWindow {
    func onTip(_ sender: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            sender.view?.setY(-64)
            sender.view?.subviews.first?.alpha = 0
            }) { (Bool) -> Void in
                sender.view?.removeFromSuperview()
        }
    }
}


func getImageFromView(_ view: UIView)->UIImage {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, globalScale);
    view.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
}

func SAstrlen(_ stremp:NSString)->Int{
    let cfEncoding = CFStringConvertWindowsCodepageToEncoding(54936)
    let gbkEncoding = CFStringConvertEncodingToNSStringEncoding(cfEncoding)
    let da:Data = stremp.data(using: gbkEncoding)!
    return da.count
}

func viewEmpty(_ width:CGFloat, content:String = "这里是空的")->UIView {
    let viewEmpty = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 55))
    let labelEmpty = UILabel(frame: CGRect(x: 0, y: 40, width: width, height: 20))
    labelEmpty.font = UIFont.systemFont(ofSize: 11)
    labelEmpty.textAlignment = NSTextAlignment.center
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
    func launch(_ selected: Int = 0) {
        
        /* 设置传的参数进入缓存，当为自然启动时，切换到关注页面 */
        Cookies.set(selected as AnyObject?, forKey: "selected")
        
        IMClass.IMConnect()
        delay(0.2) { () -> () in
            let vc = HomeViewController(nibName:nil,  bundle: nil)
            let nav = UINavigationController(rootViewController: vc)
            nav.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            nav.navigationBar.tintColor = UIColor.white
            nav.navigationBar.isTranslucent = true
            nav.navigationBar.barStyle = UIBarStyle.blackTranslucent
            nav.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            nav.navigationBar.clipsToBounds = true
            self.present(nav, animated: true, completion: { () -> Void in
                if selected == 0 {
                    guideline()
                }
            })
            
            /* 调用 Home 中的唤醒函数 */
            NotificationCenter.default.post(name: Notification.Name(rawValue: "AppActive"), object: nil)
        }
    }
    
    /* 第二天推送 */
    func pushTomorrow() {
        thepush("Mua!", dateSinceNow: 60 * 60 * 24, willReapt: false, id: "signup")
    }
    
    func viewLoadingShow() {
        globalViewLoading = UIView(frame: CGRect(x: (globalWidth-50)/2, y: (globalHeight-50)/2, width: 50, height: 50))
        globalViewLoading!.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        globalViewLoading!.layer.cornerRadius = 4
        globalViewLoading!.layer.masksToBounds = true
        globalViewLoading!.isUserInteractionEnabled = false
        globalViewLoading?.isHidden = true
        let activity = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        activity.color = UIColor.white
        activity.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        activity.isHidden = false
        activity.startAnimating()
        globalViewLoading!.addSubview(activity)
        if let v = UIApplication.shared.windows.first {
            v.addSubview(globalViewLoading!)
            delay(0.3, closure: { () -> () in
                globalViewLoading!.isHidden = false
                return
            })
        }
    }
    
    func viewLoadingHide() {
        globalViewLoading?.removeFromSuperview()
    }
    
    func SAlogout(){
        let Sa:UserDefaults = UserDefaults.standard
        
        let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        uidKey?.resetKeychainItem()
        Sa.removeObject(forKey: "uid")
        Sa.removeObject(forKey: "shell")
        Sa.removeObject(forKey: "followData")
        Sa.removeObject(forKey: "user")
        Sa.removeObject(forKey: "emojis")
        Sa.removeObject(forKey: "explore_follow")
        Sa.removeObject(forKey: "token")
        Sa.synchronize()
        
        // 退出后应该设置三个都为未加载状态
        globalTabhasLoaded = [false, false]
        self.dismiss(animated: true, completion: nil)
        
        RCIMClient.shared().disconnect(false)
    }
}


class fakeView:UIView{
    override internal func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}

class SAActivity: UIActivity {
    var saActivityTitle:String = ""
    var saActivityImage: UIImage?
    var saActivityFunction: (() -> Void)?
    var saActivityType: String = ""
    // todo
//    override var activityType : String {
//        return saActivityType
//    }
    override var activityTitle : String  {
        return saActivityTitle
    }
    override var activityImage : UIImage? {
        return saActivityImage
    }
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    override func prepare(withActivityItems activityItems: [Any]) {
        saActivityFunction!()
    }
    override class var activityCategory : UIActivityCategory {
       return .action
    }
    override func perform() {
        
    }
    
}

extension UIImage{
    func resetToSize(_ size:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let lResultImage:UIImage=UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return lResultImage;
    }
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage!
    }
    
    class func imageFromURL(_ aURL: URL, success: @escaping ((_ image: UIImage) -> Void), error: () -> Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: { () -> Void in
            
            let mutableRequest: NSMutableURLRequest = NSMutableURLRequest(url: aURL,
                                                                          cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad,
                                                                          timeoutInterval: 30.0)
            let rcvData: Data? = try? NSURLConnection.sendSynchronousRequest(mutableRequest as URLRequest, returning: nil)
//            var img: UIImage = UIImage(data: rcvData!)!
            
            DispatchQueue.main.async(execute: {
                if let img = UIImage(data: rcvData!) {
                    success(img)
                }
            })
            
        })
    }
    
}

extension UIImageView{
    func SAMaskImage(_ isMe: Bool = true){
    }
    
    func setHolder(){
        self.contentMode = UIViewContentMode.center
    }
    
    func setAnimationWanderX(_ leftStartX: CGFloat, leftEndX: CGFloat, rightStartX: CGFloat, rightEndX: CGFloat) {
        self.setX(leftStartX)
        UIView.animate(withDuration: 4, animations: { () -> Void in
            self.setX(leftEndX)
            }, completion: { (Bool) -> Void in
                self.setX(rightStartX)
                self.layer.transform = CATransform3DConcat(self.layer.transform, CATransform3DMakeRotation(CGFloat(M_PI), 0, -1, 0))
                UIView.animate(withDuration: 4, animations: { () -> Void in
                    self.setX(rightEndX)
                    }, completion: { (Bool) -> Void in
                        self.layer.transform = CATransform3DConcat(self.layer.transform, CATransform3DMakeRotation(CGFloat(M_PI), 0, 1, 0))
                        self.setAnimationWanderX(leftStartX, leftEndX: leftEndX, rightStartX: rightStartX, rightEndX: rightEndX)
                })
        }) 
    }
    
    func setAnimationWanderY(_ startY: CGFloat, endY: CGFloat, animated: Bool = true) {
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
            UIView.animate(withDuration: 2, animations: { () -> Void in
                self.setY(endY)
            }, completion: { (Bool) -> Void in
                UIView.animate(withDuration: 2, animations: { () -> Void in
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
        let y = self.convert(CGPoint.zero, from: self.window)
        return y
    }
    
    
    func drawCornerRadius(_ radius: CGFloat, image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, image.scale)
        UIBezierPath(roundedRect: self.bounds, cornerRadius: radius).addClip()
        
        image.draw(in: self.bounds)
        self.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
}

extension UIViewController {
    
    func keyboardStartObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(_ notification: Notification) {
    }
    
    func keyboardWillBeHidden(_ notification: Notification) {
    }
    
    func keyboardEndObserve() {
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
    }
    
    func onURL(_ sender: Notification){
        let url = sender.object as! String
        var urlArray = "\(url)".components(separatedBy: "nian://")
        if urlArray.count == 2 {
            urlArray = urlArray[1].components(separatedBy: "/")
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
    func onLock(_ type: lockType) {
        if let _ = Cookies.get("Lock") as? String {
            let vc = Lock()
            vc.type = type
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
}

extension UIButton {
    func startLoading() {
        self.isEnabled = false
        self.setTitle("", for: UIControlState())
        let activity = UIActivityIndicatorView(frame: CGRect(x: self.width()/2 - 10, y: self.height()/2 - 10, width: 20, height: 20))
        activity.color = UIColor.white
        activity.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self.addSubview(activity)
        activity.isHidden = false
        activity.startAnimating()
    }
    func endLoading(_ text: String) {
        let views:NSArray = self.subviews as NSArray
        for view in views {
            if NSStringFromClass((view as AnyObject).classForCoder) == "UIActivityIndicatorView"  {
                (view as AnyObject).removeFromSuperview()
            }
        }
        let imageView = UIImageView(frame: CGRect(x: self.width()/2 - 12, y: self.height()/2 - 12, width: 24, height: 24))
        imageView.image = UIImage(named: "newOK")
        imageView.contentMode = UIViewContentMode.center
        self.addSubview(imageView)
        delay(2, closure: { () -> () in
            self.setTitle(text, for: UIControlState())
            imageView.removeFromSuperview()
            self.isEnabled = true
            return
        })
    }
    func setButtonNice(_ content:String){
        self.frame = CGRect(x: 0, y: 0, width: 100, height: 36)
        self.layer.cornerRadius = 18
        self.backgroundColor = UIColor.HighlightColor()
        self.layer.masksToBounds = true
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel!.font = UIFont.systemFont(ofSize: 13)
        self.setTitle(content, for: UIControlState())
    }
}

func shake() {
    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
}

func getCacheImage(_ url: String) -> UIImage? {
    return SDImageCache.shared().imageFromDiskCache(forKey: url)
}

func setCacheImage(_ url: String, img: UIImage, width: CGFloat) {
    var imageNew = width == 0 ? img : resizedImage(img, newWidth: width)
    imageNew = imageNew.fixOrientation()
    SDImageCache.shared().store(imageNew, forKey: url)
}

func SAUpdate(_ dataArray: NSMutableArray, index: Int, key: String, value: AnyObject, tableView: UITableView) {
    if dataArray.count > index {
        let data = dataArray[index] as! NSDictionary
        let mutableItem = NSMutableDictionary(dictionary: data)
        mutableItem.setValue(value, forKey: key)
        dataArray.replaceObject(at: index, with: mutableItem)
    }
}

func SAUpdate(_ dataArray: NSMutableArray, index: Int, data: NSDictionary, tableView: UITableView) {
    dataArray.replaceObject(at: index, with: data)
}

func SAUpdate(_ index: Int, section: Int, tableView: UITableView) {
    tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: UITableViewRowAnimation.left)
}

func SAUpdate(_ delete: Bool, dataArray: NSMutableArray, index: Int, tableView: UITableView, section: Int) {
    if delete {
        dataArray.removeObject(at: index)
        tableView.beginUpdates()
        tableView.deleteRows(at: [IndexPath(row: index, section: section)], with: UITableViewRowAnimation.fade)
        tableView.reloadData()
        tableView.endUpdates()
    }
}

func SAUid() -> String {
    let uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
    let uid = uidKey?.object(forKey: kSecAttrAccount) as? String
    if uid != nil {
        return uid!
    }
    return "0"
}

func SACeil(_ num: CGFloat, dot: Int, isCeil: Bool = true) -> CGFloat {
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
    class func colorWithHex(_ hexString: String) -> UIColor {
        let regexp = try? NSRegularExpression(pattern: "\\A#[0-9a-f]{6}\\z",
            options: .caseInsensitive)
        let num = regexp?.numberOfMatches(in: hexString,
            options: .reportProgress,
            range: NSMakeRange(0, hexString.characters.count))
        if num != 1 {
            return UIColor.HighlightColor()
        }
        var rgbValue : UInt32 = 0
        let scanner = Scanner(string: hexString)
        scanner.scanLocation = 1
        scanner.scanHexInt32(&rgbValue)
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

let BGColor:UIColor = UIColor.white
let GoldColor:UIColor = UIColor(red:0.96, green:0.77,blue:0.23,alpha: 1)   //金色
let greyColor = UIColor(red:0.18, green:0.18, blue:0.18, alpha:1) // #333333

func SAThousand(_ num: String) -> String {
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
    func setRadius(_ size: CGFloat, isTop: Bool) {
        var rectCorner: UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]
        if !isTop {
            rectCorner = [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
        }
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: rectCorner, cornerRadii: CGSize(width: size, height: size))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func addGhost(_ content: String) {
        let vHolder = UIView(frame: CGRect(x: 0, y: 0, width: 280, height: 110))
        let v = UIImageView(frame: CGRect(x: 0, y: 0, width: 280, height: 60))
        v.image = UIImage(named: "pet_ghost")
        v.contentMode = UIViewContentMode.center
        let label = UILabel(frame: CGRect(x: 0, y: 76, width: 280, height: 40))
        let h = content.stringHeightWith(13, width: 280)
        label.text = content
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.b3()
        label.setHeight(h)
        vHolder.addSubview(v)
        vHolder.addSubview(label)
        vHolder.setHeight(h + 76)
        vHolder.center = self.center
        self.addSubview(vHolder)
    }
}

func SACookie(_ key: String) -> String? {
    return UserDefaults.standard.object(forKey: key) as? String
}

class Cookies {
    class func set(_ value: AnyObject?, forKey: String) {
        let Cookie = UserDefaults.standard
        Cookie.set(value, forKey: forKey)
        Cookie.synchronize()
    }
    class func get(_ key: String) -> AnyObject? {
        let Cookie = UserDefaults.standard
        return Cookie.object(forKey: key) as AnyObject?
    }
    class func remove(_ key: String) {
        let Cookie = UserDefaults.standard
        Cookie.removeObject(forKey: key)
        Cookie.synchronize()
    }
}

/**
等价于 objective-c 里面的 synchonized

- parameter lock:    <#lock description#>
- parameter closure: <#closure description#>
*/
public func synchronized(_ lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

// 前后均会包含
// 例如 1, 4，会返回 1 2 3 4
func getRandomNumber(_ from: Int, to: Int) -> Int {
    return Int(arc4random() % UInt32(to - from + 1)) + from
}

// 冒泡排序
func bubble(_ arr: [Int]) -> [Int] {
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

func go(_ justdoit: @escaping () -> Void) {
    DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: justdoit)
}

func back(_ justdoit: @escaping () -> Void) {
    DispatchQueue.main.async(execute: justdoit)
}

/* 清除角标 */
extension UIApplication {
    func clearBadge() {
        self.applicationIconBadgeNumber = 1
        self.applicationIconBadgeNumber = 0
    }
}

func guideline() {
    if let bool = Cookies.get("guide") as? String {
        if bool == "1" {
            return
        }
    }
    let guide = Guide()
    guide.setup()
    UIApplication.shared.windows.last?.addSubview(guide)
}
