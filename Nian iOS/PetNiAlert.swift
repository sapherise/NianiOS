//
//  PetNiAlert.swift
//  Nian iOS
//
//  Created by Sa on 15/7/27.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension PetViewController {
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
                            let data = json!.objectForKey("data") as! NSDictionary
                            let id = data.stringAttributeForKey("id")
                            let level = data.stringAttributeForKey("level")
                            let image = data.stringAttributeForKey("image")
                            let name = data.stringAttributeForKey("name")
                            
                            /* 如果最后的等级是 2，那么就扣除 5 念币 */
                            var reduce = 5
                            if Int(level)! > 10 {
                                reduce = 15
                            } else if Int(level)! > 5 {
                                reduce = 10
                            }
                            if let coin = Cookies.get("coin") as? String {
                                if let _coin = Int(coin) {
                                    let coinNew = _coin - reduce
                                    Cookies.set("\(coinNew)", forKey: "coin")
                                }
                            }
                            
                            if self.dataArray.count >= 1 {
                                for i: Int in 0...self.dataArray.count - 1 {
                                    let d = self.dataArray[i] as! NSDictionary
                                    let _id = d.stringAttributeForKey("id")
                                    if _id == id {
                                        if level == "5" || level == "10" {
                                            self.evolutionView = NIAlert()
                                            self.evolutionView!.delegate = self
                                            self.evolutionView!.dict = NSMutableDictionary(objects: [self.imageView, name, "\(name)进化了！", [" 嗯！"]],
                                                forKeys: ["img", "title", "content", "buttonArray"])
                                            self.upgradeView?.dismissWithAnimationSwtichEvolution(self.evolutionView!, url: image)
                                            let mutableData = NSMutableDictionary(dictionary: d)
                                            mutableData.setValue(image, forKey: "image")
                                            mutableData.setValue(level, forKey: "level")
                                            self.dataArray[i] = mutableData
                                            self.tableViewPet.reloadData()
                                            delay(1, closure: {
                                                self.setPetTitle()
                                            })
                                            break
                                        } else {
                                            let mutableData = NSMutableDictionary(dictionary: d)
                                            mutableData.setValue(image, forKey: "image")
                                            mutableData.setValue(level, forKey: "level")
                                            self.dataArray[i] = mutableData
                                            self.tableViewPet.reloadData()
                                            self.setPetTitle()
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
                let data = dataArray[current] as! NSDictionary
                let owned = data.stringAttributeForKey("owned")
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
                let coins = energy/100
                Api.getConsume("energy", coins: coins) { json in
                    if json != nil {
                        let err = json!.objectForKey("error") as! NSNumber
                        self.giftView?.dismissWithAnimation(.normal)
                        if err == 0 {
                            print("获得了这么多念币：\(coins)")
                            if let coin = Cookies.get("coin") as? String {
                                if let _coin = Int(coin) {
                                    let coinNew = _coin + coins
                                    Cookies.set("\(coinNew)", forKey: "coin")
                                    print("设置新的念币为\(coinNew)，既原来的\(_coin)，和新增加的\(coins)")
                                }
                            }
                            self.energy = self.energy - coins * 100
                            self.setPetTitle()
                        } else {
                            self.showTipText("遇到了一个奇怪的错误...")
                        }
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
        let card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
        let data = dataArray[current] as! NSDictionary
        let name = data.stringAttributeForKey("name")
        let image = data.stringAttributeForKey("image")
        let content = "我在念里拿到了可爱的「\(name)」"
        card.content = content
        card.widthImage = "360"
        card.heightImage = "360"
        card.url = "http://img.nian.so/pets/\(image)!d"
        let img = card.getCard()
        let avc = SAActivityViewController.shareSheetInView([img, content], applicationActivities: [], isStep: true)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func onEgg() {
        let v = SAEgg()
        v.delegateShare = self
        v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "抽蛋", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
            forKeys: ["img", "title", "content", "buttonArray"])
        v.showWithAnimation(.flip)
    }
    
    func saEgg(saEgg: SAEgg, lotteryResult: NSDictionary) {
        let id = lotteryResult.stringAttributeForKey("id")
        if self.dataArray.count >= 1 {
            for i: Int in 0...self.dataArray.count - 1 {
                let d = self.dataArray[i] as! NSDictionary
                let _id = d.stringAttributeForKey("id")
                let level = d.stringAttributeForKey("level")
                if _id == id && level == "1" {
                    let mutableData = NSMutableDictionary(dictionary: d)
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
    
    func onPlankton() {
        let vc = Plankton()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}