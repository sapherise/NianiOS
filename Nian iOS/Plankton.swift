//
//  Plankton.swift
//  Nian iOS
//
//  Created by Sa on 15/11/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Plankton: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource, NIAlertDelegate {
    var collectionView: UICollectionView!
    var total = 0
    var nialert: NIAlert!
    let contentArray = ["虽然没有抽到宠物\n但你抽到了一个抱抱","作为一个烧麦\n不知道被吃掉\n是幸运还是不幸呀","(・ω・) -__- )・∀・)\n好挤呀","今天我从天空飘着时\n看到地上有个\n可爱的女孩子在玩念","我们还会见面的！\n吖，别摔手机啊","作为一个医生\n我每天都被自己帅晕","打劫念币啦","谢谢你的念币\n终于凑够钱买别墅了","不好意思\n跑错片场了","谢谢你喂我\n我已经快十分钟没吃过东西了","是 你 在 召 唤 我 吗","同样是独角\n为什么它是传说中的宠物\n而我只能做美男子呢","你说你原本想抽的不是我？\n我的心碎了","如果看到一只拉风的炸鸡\n接下来一辈子都会交好运","我妈说花开的时候\n就会遇到真爱","每当有人对我说 \ngive me five 的时候\n我都既快乐又困扰"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("浮游生物")
        
        let width: CGFloat = 120
        let paddingCell: CGFloat = 40
        let paddingView = (globalWidth - width*2 - paddingCell*1)/2
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = paddingCell
        flowLayout.minimumLineSpacing = paddingCell
        flowLayout.itemSize = CGSize(width: width, height: width)
        flowLayout.sectionInset = UIEdgeInsets(top: paddingView, left: paddingView, bottom: paddingView, right: paddingView)
        
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        self.collectionView.registerNib(UINib(nibName: "PlanktonCell", bundle: nil), forCellWithReuseIdentifier: "PlanktonCell")
        if let _total = Cookies.get("plankton") as? String {
            let _t = Int(_total)
            if _t != nil {
                total = _t!
            }
        }
        collectionView.reloadData()
        if total == 0 {
            self.view.addGhost("还没见过\n任何一只浮游生物...")
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCellWithReuseIdentifier("PlanktonCell", forIndexPath: indexPath) as! PlanktonCell
        c.imageView.image = UIImage(named: "pet\(indexPath.row + 1)")
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return total
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        nialert = NIAlert()
        nialert.delegate = self
        nialert.dict = NSMutableDictionary(objects: [UIImage(named: "pet\(indexPath.row + 1)")!, "浮游生物", contentArray[indexPath.row], [" 好"]], forKeys: ["img", "title", "content", "buttonArray"])
        nialert.showWithAnimation(.flip)
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        nialert.dismissWithAnimation(.normal)
    }
    
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        nialert.dismissWithAnimation(.normal)
    }
}