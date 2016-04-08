//
//  Home + Reachability.swift
//  Nian iOS
//
//  Created by Sa on 15/9/19.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
extension HomeViewController {
    func setupReachability() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        reachability?.startNotifier()
        if let reachability = reachability {
            let status = reachability.currentReachabilityString
//            Cookies.set(status, forKey: "reachability")
            globalReachability = status
        }
    }
    
    // 获取网络改变的通知时
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        let status = reachability.currentReachabilityString
//        Cookies.set(status, forKey: "reachability")
        globalReachability = status
    }
}

// 获取当前网络状态
func getStatus() -> Int {
    let status = globalReachability
    if status == "WiFi" {
        return 2
    } else if status == "Cellular" {
        return 1
    }
    return 0
}