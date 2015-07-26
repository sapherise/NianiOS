//
//  PetNiAlert.swift
//  Nian iOS
//
//  Created by Sa on 15/7/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController: NIAlertDelegate, ShareDelegate {
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == self.upgradeView {
            if didselectAtIndex == 1 {
                niAlert.dismissWithAnimation(.normal)
            } else if didselectAtIndex == 0 {
                let _btn = niAlert.niButtonArray.firstObject as! NIButton
                _btn.startAnimating()
                let tag = upgradeView!.tag
                Api.getPetUpgrade("\(tag)") {
                    json in
                    _btn.stopAnimating()
                    
                    if json != nil {
                        let err = json!.objectForKey("error") as! NSNumber
                        if err == 0 {
                            self.isUpgradeSuccess = true
                            globalWillNianReload = 1
                            var data = json!.objectForKey("data") as! NSDictionary
                            var id = data.stringAttributeForKey("id")
                            var level = data.stringAttributeForKey("level")
                            var image = data.stringAttributeForKey("image")
                            var name = data.stringAttributeForKey("name")
                            if self.dataArray.count >= 1 {
                                for i: Int in 0...self.dataArray.count - 1 {
                                    var d = self.dataArray[i] as! NSDictionary
                                    var _id = d.stringAttributeForKey("id")
                                    if _id == id {
                                        var mutableData = NSMutableDictionary(dictionary: d)
                                        mutableData.setValue(image, forKey: "image")
                                        mutableData.setValue(level, forKey: "level")
                                        self.dataArray[i] = mutableData
                                        self.setPetTitle()
                                        if level == "5" || level == "10" {
                                            self.evolutionView = NIAlert()
                                            self.evolutionView!.delegate = self
                                            self.evolutionView!.dict = NSMutableDictionary(objects: [self.imageView, name, "\(name)进化了！", [" 嗯！"]],
                                                forKeys: ["img", "title", "content", "buttonArray"])
                                            self.upgradeView?.dismissWithAnimationSwtichEvolution(self.evolutionView!, url: image)
                                            break
                                        } else {
                                            self.tableViewPet.reloadData()
                                            self.upgradeView?.dismissWithAnimation(.normal)
                                            break
                                        }
                                    }
                                }
                            }
                        } else if err == 1 {
                            self.isUpgradeSuccess = false
                            self.upgradeResultView = NIAlert()
                            self.upgradeResultView!.delegate = self
                            self.upgradeResultView!.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "念币不足", "没有足够的念币...", ["哦"]],
                                forKeys: ["img", "title", "content", "buttonArray"])
                            self.upgradeView?.dismissWithAnimationSwtich(self.upgradeResultView!)
                        } else {
                            self.isUpgradeSuccess = false
                            self.upgradeResultView = NIAlert()
                            self.upgradeResultView!.delegate = self
                            self.upgradeResultView!.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "奇怪的错误", "遇到了一个奇怪的错误...", ["哦"]],
                                forKeys: ["img", "title", "content", "buttonArray"])
                            self.upgradeView?.dismissWithAnimationSwtich(self.upgradeResultView!)
                        }
                    }
                }
            }
            
        } else if niAlert == self.petDetailView {
            if didselectAtIndex == 0 {
                var data = dataArray[current] as! NSDictionary
                var owned = data.stringAttributeForKey("owned")
                if owned == "1" {
                    shareVC()
                } else {
                    petDetailView?.dismissWithAnimation(.normal)
                }
            }
        } else if niAlert == self.upgradeResultView {
            if isUpgradeSuccess {
                tableViewPet.reloadData()
            } else {
                upgradeView?.dismissWithAnimation(.normal)
                upgradeResultView?.dismissWithAnimation(.normal)
            }
        } else if niAlert == self.evolutionView {
            tableViewPet.reloadData()
            self.upgradeView?.dismissWithAnimation(.normal)
            self.evolutionView?.dismissWithAnimation(.normal)
        } else if niAlert == self.giftView {
            if energy >= 100 {
                let _btn = giftView!.niButtonArray.firstObject as! NIButton
                _btn.startAnimating()
                var coins = energy/100
                Api.getConsume("energy", coins: coins) { json in
                    if json != nil {
                        println(json)
                        globalWillNianReload = 1
                        // todo: API 完善后，首先修改变量 energy（应该是服务器返回的 energy），然后修改 UI 上的数值
                    }
                }
            } else {
                giftView?.dismissWithAnimation(.normal)
            }
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        if niAlert == self.upgradeView {
            self.upgradeView?.dismissWithAnimation(.normal)
        } else if niAlert == self.upgradeResultView {
            self.upgradeView?.dismissWithAnimation(.normal)
            self.upgradeResultView?.dismissWithAnimation(.normal)
        } else if niAlert == self.evolutionView {
            tableViewPet.reloadData()
            self.upgradeView?.dismissWithAnimation(.normal)
            self.evolutionView?.dismissWithAnimation(.normal)
        } else if niAlert == self.giftView {
            giftView?.dismissWithAnimation(.normal)
        }
    }
    
    func shareVC() {
        var card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
        var data = dataArray[current] as! NSDictionary
        var name = data.stringAttributeForKey("name")
        var image = data.stringAttributeForKey("image")
        var content = "我在念里拿到了可爱的「\(name)」"
        card.content = content
        card.widthImage = "360"
        card.heightImage = "360"
        card.url = "http://img.nian.so/pets/\(image)!d"//todo
        var img = card.getCard()
        var avc = SAActivityViewController.shareSheetInView([img, content], applicationActivities: [], isStep: true)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func onEgg() {
        var v = SAEgg()
        v.delegateShare = self
        v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "抽蛋", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
            forKeys: ["img", "title", "content", "buttonArray"])
        v.showWithAnimation(.flip)
    }
    
    func saEgg(saEgg: SAEgg, lotteryResult: NSDictionary) {
        var id = lotteryResult.stringAttributeForKey("id")
        
        if self.dataArray.count >= 1 {
            for i: Int in 0...self.dataArray.count - 1 {
                var d = self.dataArray[i] as! NSDictionary
                var _id = d.stringAttributeForKey("id")
                var level = d.stringAttributeForKey("level")
                if _id == id && level == "1" {
                    var mutableData = NSMutableDictionary(dictionary: d)
                    mutableData.setValue(level, forKey: "level")
                    mutableData.setValue("1", forKey: "owned")
                    self.dataArray[i] = mutableData
                    self.setPetTitle()
                    self.tableViewPet.reloadData()
                    break
                }
            }
        }
    }
    
    func onGift() {
        println("haha")
        giftView = NIAlert()
        giftView?.delegate = self
        if energy >= 100 {
            giftView!.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "礼物", "要将 \(energy) 个礼物\n兑换为 \(energy/100) 念币吗", [" 嗯！"]],
                forKeys: ["img", "title", "content", "buttonArray"])
        } else {
            giftView!.dict = NSMutableDictionary(objects: [UIImage(named: "coinless")!, "礼物", "这是宠物送给你的礼物\n每 100 个可以兑换 1 念币", ["好"]],
                forKeys: ["img", "title", "content", "buttonArray"])
        }
        giftView?.showWithAnimation(.flip)
    }
    
//    func saEgg(saEgg: SAEgg, lotteryResult: NSDictionary) {
//        let _id = lotteryResult.objectForKey("id") as! String
//        let img = lotteryResult.stringAttributeForKey("image")
//
//        var contained: Bool = false
//
//        // 遍历 petInfoArray, 看是否包含新抽得的宠物
//
//        for item in self.petInfoArray {
//            let id = (item as! NSDictionary).objectForKey("id") as! String
//
//            if id == _id {
//                contained = true
//            }
//        }
}