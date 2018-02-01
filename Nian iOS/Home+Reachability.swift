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
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.reachabilityChanged(_:)),name: ReachabilityChangedNotification,object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
        }
    }
    
    // 获取网络改变的通知时
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        let status = reachability.currentReachabilityString
        Cookies.set(status as AnyObject?, forKey: "reachability")
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
