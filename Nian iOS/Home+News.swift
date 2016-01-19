//
//  Home+News.swift
//  Nian iOS
//
//  Created by Sa on 15/8/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

extension HomeViewController: NIAlertDelegate {
    func SANews() {
        Api.getNews() { json in
            if json != nil {
                let data = json!.objectForKey("news") as! NSDictionary
                let title = data.stringAttributeForKey("title")
                if title != "" {
                    // 新闻
                    let content = data.stringAttributeForKey("content")
                    let button = data.stringAttributeForKey("button")
                    let version = data.stringAttributeForKey("version")
                    let v: AnyObject? = Cookies.get("SANews.\(version)")
                    if v == nil {
                        self.ni = NIAlert()
                        self.ni!.delegate = self
                        self.ni!.dict = NSMutableDictionary(objects: [UIImage(named: "pet_egg2")!, title, content, [button]],
                            forKeys: ["img", "title", "content", "buttonArray"])
                        self.ni!.showWithAnimation(.flip)
                        Cookies.set("1", forKey: "SANews.\(version)")
                    }
                } else {
                    let numberVersion = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
                    
                    let data = Cookies.get("rewards") as? NSDictionary
                    
                    // 如果未加入过奖励系统
                    if data == nil {
                        // 创建该版本的奖励系统
                        let d = NSDictionary(objects: [numberVersion, "0"], forKeys: ["version", "hasGotRewards"])
                        Cookies.set(d, forKey: "rewards")
                    } else {
                        // 已加入过奖励系统
                        let version = data?.stringAttributeForKey("version")
                        if version != numberVersion {
                            // 如果奖励系统版本号是早期版本
                            // 设定该版本的奖励
                            let d = NSDictionary(objects: [numberVersion, "0"], forKeys: ["version", "hasGotRewards"])
                            Cookies.set(d, forKey: "rewards")
                        } else {
                            // 是当前版本
                            let hasGotRewards = data?.stringAttributeForKey("hasGotRewards")
                            if hasGotRewards == "0" {
                                // 未获得该版本奖励，通过网络请求获得奖励
                                // 市场评分，查看是否还有这个活动存在
                                let numberActivity = "0924"
                                /*
                                **  每次上线新版本时，修改 numberActivity 的值
                                **  然后在数据库里插入这个值
                                */
                                Api.getRewardsActivity(numberActivity) { json in
                                    if json != nil {
                                        let hasActivity = json!.objectForKey("hasActivity") as? String
                                        // 如果存在
                                        if hasActivity == "1" {
                                            // 奖励 3 念币
                                            Api.getRewards(numberActivity) { json in
                                                self.niAppStore = NIAlert()
                                                self.niAppStore?.delegate = self
                                                self.niAppStore?.shouldTapBackgroundToDismiss = false
                                                self.niAppStore?.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "新版奖励！", "因为下载了新版的念\n念奖励了你 3 念币！", ["好"]], forKeys: ["img", "title", "content", "buttonArray"])
                                                self.niAppStore?.showWithAnimation(.flip)
                                                let mutableDic = NSMutableDictionary(dictionary: data!)
                                                mutableDic.setValue("1", forKey: "hasGotRewards")
                                                Cookies.set(mutableDic, forKey: "rewards")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == ni {
            niAlert.dismissWithAnimation(.normal)
        } else if niAlert == niAppStore {
            niAppStoreStar = NIAlert()
            niAppStoreStar?.delegate = self
            niAppStoreStar?.shouldTapBackgroundToDismiss = false
            self.niAppStoreStar?.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "喜欢念吗", "要不要去 App Store 给念打分？", [" 嗯！", " 不！"]], forKeys: ["img", "title", "content", "buttonArray"])
            niAppStore?.dismissWithAnimationSwtich(niAppStoreStar!)
        } else if niAlert == niAppStoreStar {
            if didselectAtIndex == 0 {
                openAppStore()
                delay(1, closure: { () -> () in
                    self.niAppStore?.dismissWithAnimation(.normal)
                    self.niAppStoreStar?.dismissWithAnimation(.normal)
                })
            } else {
                niAppStore?.dismissWithAnimation(.normal)
                niAppStoreStar?.dismissWithAnimation(.normal)
            }
        } else {
            if didselectAtIndex == 1 {
                delay(0.5) { () -> () in
                    if self.newEditDreamId == "" {
                        let dreamVC = DreamViewController()
                        dreamVC.Id = self.newEditDreamId
                        
                        self.selectedViewController!.navigationController?.pushViewController(dreamVC, animated: true)
                    }
                }
            } 
        }
    }
}

func openAppStore() {
    UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/cn/app/id929448912")!)
}