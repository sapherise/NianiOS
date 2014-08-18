//
//  ViewController.swift
//  Nian iOS
//
//  Created by Sa on 14-7-7.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: NSDictionary?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Override point for customization after application launch.
        var mainViewController = HomeViewController(nibName:nil,  bundle: nil)
        mainViewController.selectedIndex = 2
        mainViewController.sadelegate = RootViewController(nibName: nil,bundle: nil)
        
        //导航栏的颜色
        var navigationViewController = UINavigationController(rootViewController: mainViewController)
        navigationViewController.navigationBar.setBackgroundImage(SAColorImg(BarColor), forBarMetrics: UIBarMetrics.Default)
        navigationViewController.navigationBar.tintColor = IconColor
        navigationViewController.navigationBar.translucent = false
        
        self.window!.rootViewController = navigationViewController
        
        
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

