//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//  change the world

import UIKit
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate, WXApiDelegate {
    var window: UIWindow?
    
    var isNoti = false
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = BGColor
        
        let welcomeStoryboard = UIStoryboard(name: "Welcome", bundle: nil)
        let welcomeViewController = welcomeStoryboard.instantiateViewControllerWithIdentifier("welcomeViewController")
        
        let navigationViewController = UINavigationController(rootViewController: welcomeViewController)
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.window!.rootViewController = navigationViewController
        self.window!.makeKeyAndVisible()

        WeiboSDK.enableDebugMode(false)
        WeiboSDK.registerApp("4189056912")
        WXApi.registerApp("wx08fea299d0177c01")
        MobClick.startWithAppkey("54b48fa8fd98c59154000ff2")
        
        /* 极光推送 */
        /**
        * 1 << 0 : UIUserNotificationType.Sound
        * 1 << 1 : UIUserNotificationType.Alert
        * 1 << 2 : UIUserNotificationType.Badge
        */
        APService.registerForRemoteNotificationTypes( 1 << 0 | 1 << 1 | 1 << 2, categories: nil)
        APService.setupWithOption(launchOptions)
        
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
        
        // check current shortcut item
        if #available(iOS 9.0, *) {
            if let item = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                QuickActionsForItem(item)
            }
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
//        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("AppDeactive", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
    }
    
    // todo: 添加照片可以预览
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppEnterForeground", object: nil)
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.applicationIconBadgeNumber = 1
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        go {
            let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var newDeviceToken = SAReplace("\(deviceToken)", before: "<", after: "")
            newDeviceToken = SAReplace("\(newDeviceToken)", before: ">", after: "")
            newDeviceToken = SAReplace("\(newDeviceToken)", before: " ", after: "")
            Sa.setObject(newDeviceToken, forKey:"DeviceToken")
            Sa.synchronize()
        }
        
        /* 设置极光推送 */
        APService.registerDeviceToken(deviceToken)
        Api.postJpushBinding(){ _ in }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {       
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
        fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
            let aps = userInfo["aps"] as! NSDictionary
            
            handleReceiveRemoteNotification(aps)
            APService.handleRemoteNotification(userInfo)
            completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let s = url.scheme
        if s == "nian" {
            delay(1, closure: { () -> () in
                NSNotificationCenter.defaultCenter().postNotificationName("AppURL", object: "\(url)")
            })
            return true
        } else if s == "wb4189056912" {
            return WeiboSDK.handleOpenURL(url, delegate: self)
        } else if s == "tencent1104358951" {
            return TencentOAuth.HandleOpenURL(url)
        } else if s == "wx08fea299d0177c01" {
            return WXApi.handleOpenURL(url, delegate: self)
        }
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let s = url.scheme
        if s == "wb4189056912" {
            return WeiboSDK.handleOpenURL(url, delegate: self)
        } else if s == "tencent1104358951" {
            return TencentOAuth.HandleOpenURL(url)
        }
        return true
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        if response.userInfo != nil  {
            let json = response.userInfo as NSDictionary
            let uid = json.stringAttributeForKey("uid")
            let token = json.stringAttributeForKey("access_token")
            
            NSNotificationCenter.defaultCenter().postNotificationName("weibo", object:[uid, token])
        }
    }
    
    // 收到消息通知， JPush
    func handleReceiveRemoteNotification(aps: NSDictionary) {
        navTo_MEVC()
    }
    
    /**
    到 tab[3] 对应的 VC， 即私信界面
    */
    func navTo_MEVC() {
    }
    
    func onResp(resp: BaseResp!) {
        if resp.isKindOfClass(SendAuthResp) {
            let _resp = resp as! SendAuthResp
            
            let manager = AFHTTPSessionManager()
            let WX_APP_ID = "wx08fea299d0177c01"
            let WX_SECRET_ID = "64dc8c89f7310a91b29e9b636b7472cb"
            
            let accessUrlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(WX_APP_ID)&secret=\(WX_SECRET_ID)&code=\(_resp.code)&grant_type=authorization_code"
            
            manager.GET(accessUrlStr,
                parameters: nil,
                success: {
                    (task, id) in
                    print("21")
                    NSNotificationCenter.defaultCenter().postNotificationName("Wechat", object: id)
                    
                }, failure: {
                    (task, error) in
                    print(error)
            })   
        }
    }
    
}



//MARK: - Handle QuickActions For ShorCut Items -> AppDelegate Extension
typealias HandleForShorCutItem = AppDelegate
extension HandleForShorCutItem {
    
    /// Define quick actions type
    enum QuickActionsType: String {
        case AddStep =     "quickactions.addstep"
        case Egg =   "quickactions.egg"
    }
    
    
    /// Shortcut Item, also called a Home screen dynamic quick action, specifies a user-initiated action for app.
    @available(iOS 9.0, *)
    func QuickActionsForItem(shortcutItem: UIApplicationShortcutItem) {
        if !isNoti {
            isNoti = true
            if let shorchutItemType = QuickActionsType.init(rawValue: shortcutItem.type) {
                switch shorchutItemType {
                case .AddStep:
                    delay(1, closure: { () -> () in
                        NSNotificationCenter.defaultCenter().postNotificationName("QuickActions", object: "1")
                        self.isNoti = false
                    })
                case .Egg:
                    delay(1, closure: { () -> () in
                        NSNotificationCenter.defaultCenter().postNotificationName("QuickActionsEgg", object: "2")
                        self.isNoti = false
                    })
                }
            }
        }
    }
    
    /// Calls - user selects a Home screen quick action for app
    @available(iOS 9.0, *)
    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        // perform action for shortcut item selected
        QuickActionsForItem(shortcutItem)
    }
}
