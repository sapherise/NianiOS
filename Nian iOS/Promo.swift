//
//  Promo.swift
//  Nian iOS
//
//  Created by Sa on 16/2/29.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Promo: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource, NIAlertDelegate {
    var collectionView: UICollectionView!
    let padding: CGFloat = 16
    var dataArray = NSMutableArray()
    var alert: NIAlert!
    var alertResult: NIAlert!
    var id = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        load()
    }
    
    func setup() {
        _setTitle("推广记本")
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        flowLayout.itemSize = CGSize(width: 80, height: 124)
        flowLayout.sectionInset = UIEdgeInsets(top: (globalWidth - 320)/2, left: (globalWidth - 320)/2 + 20, bottom: (globalWidth - 320)/2, right: (globalWidth - 320)/2 + 20)
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.BackgroundColor()
        collectionView.registerNib(UINib(nibName: "PromoCell", bundle: nil), forCellWithReuseIdentifier: "PromoCell")
        collectionView.alwaysBounceVertical = true
        self.view.addSubview(collectionView)
    }
    
    func load() {
        if let dreams = Cookies.get("NianDreams") as? NSMutableArray {
            for dream in dreams {
                print(dream)
                dataArray.addObject(dream)
            }
            collectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        return UICollectionViewCell()
        let c: PromoCell! = collectionView.dequeueReusableCellWithReuseIdentifier("PromoCell", forIndexPath: indexPath) as? PromoCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.setup()
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let data = dataArray[indexPath.row] as! NSDictionary
        id = data.stringAttributeForKey("id")
        alert = NIAlert()
        alert.delegate = self
        alert.dict = ["img": UIImage(named: "coin")!, "title": "推广", "content": "确定推广这个记本吗？\n（确保你的推广对他人有益）", "buttonArray": [" 嗯！"]]
        alert.showWithAnimation(showAnimationStyle.flip)
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == self.alert {
            if didselectAtIndex == 0 {
                // todo loding
                if let btn = alert.niButtonArray.firstObject as? NIButton {
                    btn.startAnimating()
                }
                Api.postPromo(id) { json in
                    if json != nil {
                        print(json)
                        if let j = json as? NSDictionary {
                            let error = j.stringAttributeForKey("error")
                            if error == "0" {
                                self.alertResult = NIAlert()
                                self.alertResult.delegate = self
                                self.alertResult.dict = ["img": UIImage(named: "coin")!, "title": "推广好了", "content": "你的记本已经在推广中了~\n去发现看看吧！", "buttonArray": [" 嗯！"]]
                                self.alert.dismissWithAnimationSwtich(self.alertResult)
                                if let coin = Cookies.get("coin") as? String {
                                    if let _coin = Int(coin) {
                                        let coinNew = _coin - 20
                                        Cookies.set("\(coinNew)", forKey: "coin")
                                    }
                                }
                            } else {
                                self.alertResult = NIAlert()
                                self.alertResult.delegate = self
                                self.alertResult.dict = ["img": UIImage(named: "coin")!, "title": "失败了", "content": "念币不够...", "buttonArray": [" 嗯！"]]
                                self.alert.dismissWithAnimationSwtich(self.alertResult)
                            }
                        }
                    }
                }
            }
        } else if niAlert == self.alertResult {
            alert.dismissWithAnimation(.normal)
            alertResult.dismissWithAnimation(.normal)
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        alert.dismissWithAnimation(.normal)
        if alertResult != nil {
            alertResult.dismissWithAnimation(.normal)
        }
    }
}