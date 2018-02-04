//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//  change the world

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate, WXApiDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.setStatusBarHidden(false, with: UIStatusBarAnimation.none)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = BGColor
        
        let welcomeStoryboard = UIStoryboard(name: "Welcome", bundle: nil)
        let welcomeViewController = welcomeStoryboard.instantiateViewController(withIdentifier: "welcomeViewController")
        
        let navigationViewController = UINavigationController(rootViewController: welcomeViewController)
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationViewController.navigationBar.tintColor = UIColor.white
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.blackTranslucent
        
        self.window!.rootViewController = navigationViewController
        self.window!.makeKeyAndVisible()

        WeiboSDK.enableDebugMode(false)
        WeiboSDK.registerApp("4189056912")
        WXApi.registerApp("wx08fea299d0177c01")
        MobClick.start(withAppkey: "54b48fa8fd98c59154000ff2")
        
        application.clearBadge()
        
        // Google 广告接入
        GADMobileAds.configure(withApplicationID: "ca-app-pub-4401117476228272~7045340998")
        
        // 下面使用测试广告
//        GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/2934735716")

        
        // check current shortcut item
        if #available(iOS 9.0, *) {
            if let item = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
                QuickActionsForItem(item)
            }
        }
        
        /* 融云推送 */
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AppDeactive"), object: nil)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "AppEnterForeground"), object: nil)
        application.clearBadge()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        application.clearBadge()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let token = deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
//        RCIMClient.shared().setDeviceToken(token)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
//        RCIMClient.shared().recordRemoteNotificationEvent(userInfo)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "Notice"), object: nil)
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let s = url.scheme
        if s == "nian" {
            delay(1, closure: { () -> () in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "AppURL"), object: "\(url)")
            })
            return true
        } else if s == "wb4189056912" {
            return WeiboSDK.handleOpen(url, delegate: self)
        } else if s == "tencent1104358951" {
            return TencentOAuth.handleOpen(url)
        } else if s == "wx08fea299d0177c01" {
            return WXApi.handleOpen(url, delegate: self)
        } else if s == "nianalipay" {
            AlipaySDK.defaultService().processOrder(withPaymentResult: url) { resultDic in
            }
        }
        return true
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let s = url.scheme
        if s == "wb4189056912" {
            return WeiboSDK.handleOpen(url, delegate: self)
        } else if s == "tencent1104358951" {
            return TencentOAuth.handleOpen(url)
        }
        return true
    }
    
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        if response.userInfo != nil  {
            let json = response.userInfo as NSDictionary
            let uid = json.stringAttributeForKey("uid")
            let token = json.stringAttributeForKey("access_token")
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "weibo"), object:[uid, token])
        }
    }
    
    
    
    /* 微信回调 */
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: SendAuthResp.self) {
            let _resp = resp as! SendAuthResp
            
            let manager = AFHTTPSessionManager()
            let WX_APP_ID = "wx08fea299d0177c01"
            let WX_SECRET_ID = "64dc8c89f7310a91b29e9b636b7472cb"
            
            let accessUrlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=\(WX_APP_ID)&secret=\(WX_SECRET_ID)&code=\(_resp.code!)&grant_type=authorization_code"
            let url = accessUrlStr.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            manager.get(url,
                parameters: nil,
                success: {
                    (task, id) in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "Wechat"), object: id)
                    
                }, failure: {
                    (task, error) in
            })   
        } else if resp.isKind(of: PayResp.self) {
            let response = resp as! PayResp
            let code = response.errCode
            NotificationCenter.default.post(name: Notification.Name(rawValue: "onWechatResult"), object: "\(code)")
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
    func QuickActionsForItem(_ shortcutItem: UIApplicationShortcutItem) {
        if let shorchutItemType = QuickActionsType.init(rawValue: shortcutItem.type) {
            switch shorchutItemType {
            case .AddStep:
                delay(1, closure: { () -> () in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "QuickActions"), object: "1")
                })
            case .Egg:
                delay(1, closure: { () -> () in
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "QuickActionsEgg"), object: "2")
                })
            }
        }
    }
    
    /// Calls - user selects a Home screen quick action for app
    @objc(application:performActionForShortcutItem:completionHandler:) @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // perform action for shortcut item selected
        QuickActionsForItem(shortcutItem)
    }
}
