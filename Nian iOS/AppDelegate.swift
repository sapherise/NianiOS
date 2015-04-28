//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//  change the world

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WeiboSDKDelegate{
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.None)
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = BGColor
        var navigationViewController = UINavigationController(rootViewController: WelcomeViewController())
        navigationViewController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = UIColor.whiteColor()
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.window!.rootViewController = navigationViewController
        self.window!.makeKeyAndVisible()
        
        if application.respondsToSelector("isRegisteredForRemoteNotifications") {
            var settings = UIUserNotificationSettings(forTypes: (UIUserNotificationType.Sound | UIUserNotificationType.Alert | UIUserNotificationType.Badge), categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert | UIRemoteNotificationType.Badge)
        }
        WeiboSDK.enableDebugMode(false)
        WeiboSDK.registerApp("4189056912")
        WXApi.registerApp("wx08fea299d0177c01")
        MobClick.startWithAppkey("54b48fa8fd98c59154000ff2")
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppDeactive", object: nil)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("CircleLeave", object: nil)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("AppActive", object: nil)
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var newDeviceToken = SAReplace("\(deviceToken)", "<", "")
            newDeviceToken = SAReplace("\(newDeviceToken)", ">", "")
            newDeviceToken = SAReplace("\(newDeviceToken)", " ", "")
            Sa.setObject(newDeviceToken, forKey:"DeviceToken")
            Sa.synchronize()
        })
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        if let s = url.scheme {
            if s == "nian" {
                delay(1, { () -> () in
                    NSNotificationCenter.defaultCenter().postNotificationName("AppURL", object: "\(url)")
                })
                return true
            }else if s == "wb4189056912" {
                return WeiboSDK.handleOpenURL(url, delegate: self)
            }
        }
        return true
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        if let s = url.scheme {
            if s == "wb4189056912" {
                return WeiboSDK.handleOpenURL(url, delegate: self)
            }
        }
        return true
    }
    
    func didReceiveWeiboRequest(request: WBBaseRequest!) {
    }
    
    func didReceiveWeiboResponse(response: WBBaseResponse!) {
        var json = response.userInfo as NSDictionary
        var uidWeibo = json.stringAttributeForKey("uid")
        var token = json.stringAttributeForKey("access_token")
        if let uid = uidWeibo.toInt() {
            NSNotificationCenter.defaultCenter().postNotificationName("weibo", object:[uid, token])
        }
    }
    
}

