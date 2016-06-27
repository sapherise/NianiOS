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
        
        
        let config = UMAnalyticsConfig();
        config.appKey = "54b48fa8fd98c59154000ff2";
        MobClick.startWithConfigure(config);
//        MobClick.startWithAppkey("54b48fa8fd98c59154000ff2")
        
        application.clearBadge()
        
        /* 融云 IM 接入 */
        RCIMClient.sharedRCIMClient().initWithAppKey("4z3hlwrv3t1yt")
        
        // check current shortcut item
        if #available(iOS 9.0, *) {
            if let item = launchOptions?[UIApplicationLaunchOptionsShortcutItemKey] as? UIApplicationShortcutItem {
                QuickActionsForItem(item)
            }
        }
        
        /* 融云推送 */
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppDeactive", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppEnterForeground", object: nil)
        application.clearBadge()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        application.clearBadge()
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let token = deviceToken.description.stringByReplacingOccurrencesOfString("<", withString: "").stringByReplacingOccurrencesOfString(">", withString: "").stringByReplacingOccurrencesOfString(" ", withString: "")
        RCIMClient.sharedRCIMClient().setDeviceToken(token)
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        RCIMClient.sharedRCIMClient().recordRemoteNotificationEvent(userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName("Notice", object: nil)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
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
        } else if s == "nianalipay" {
            AlipaySDK.defaultService().processOrderWithPaymentResult(url) { resultDic in
            }
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
    
    
    
    /* 微信回调 */
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
                    NSNotificationCenter.defaultCenter().postNotificationName("Wechat", object: id)
                    
                }, failure: {
                    (task, error) in
            })   
        } else if resp.isKindOfClass(PayResp) {
            let response = resp as! PayResp
            let code = response.errCode
            NSNotificationCenter.defaultCenter().postNotificationName("onWechatResult", object: "\(code)")
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
        if let shorchutItemType = QuickActionsType.init(rawValue: shortcutItem.type) {
            switch shorchutItemType {
            case .AddStep:
                delay(1, closure: { () -> () in
                    NSNotificationCenter.defaultCenter().postNotificationName("QuickActions", object: "1")
                })
            case .Egg:
                delay(1, closure: { () -> () in
                    NSNotificationCenter.defaultCenter().postNotificationName("QuickActionsEgg", object: "2")
                })
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
