//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.backgroundColor = BGColor
        var navigationViewController = UINavigationController(rootViewController: WelcomeViewController())
        navigationViewController.navigationBar.setBackgroundImage(SAColorImg(BGColor), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = IconColor
        navigationViewController.navigationBar.translucent = false
        navigationViewController.navigationBar.clipsToBounds = true
        navigationViewController.navigationBar.barStyle = UIBarStyle.BlackTranslucent
        
        self.window!.rootViewController = navigationViewController
        
        //数据持久化
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var cookieuid: String? = Sa.objectForKey("uid") as? String
        if cookieuid == nil {
            println("没有登录啦")
        }else{
            println("当前的用户编号是：\(cookieuid!)")
        }
        
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }
    
    func applicationWillTerminate(application: UIApplication) {
    }
    
    
}

