//
//  ProductList.swift
//  Nian iOS
//
//  Created by Sa on 16/2/28.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ProductList: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let padding: CGFloat = 16
    var dataArray = NSMutableArray()
    var name = ""
    
    var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        collectionView.headerBeginRefreshing()
    }
    
    /* 加载表情们的购买状态 */
    func load() {
        if name == "表情" {
            Api.getEmoji() { json in
                if json != nil {
                    self.dataArray.removeAllObjects()
                    print(json)
                    /* 为了判断是否购买过表情 */
                    let items = json!.objectForKey("data") as! NSArray
                    for _item in items {
                        if let item = _item as? NSDictionary {
                            let type = item.stringAttributeForKey("type")
                            if type == "expression" {
                                self.dataArray.addObject(item)
                            }
                        }
                    }
                    Cookies.set(self.dataArray, forKey: "emojis")
                    self.collectionView.reloadData()
                    self.collectionView.headerEndRefreshing()
                }
            }
        } else {
            /* 如果是插件 */
            dataArray = [
                ["name": "请假", "banner": "http://img.nian.so/banner/rabbit.png", "background_color": "#FF8B8B", "cost": "2", "description": "72 小时内不会被停号！如果你开启了日更模式，出去玩时记得买张请假条！", "owned": "0"],
                ["name": "推广", "banner": "http://img.nian.so/banner/dragon.png", "background_color": "#8FD2B4", "cost": "20", "description": "在接下来的 24 小时里，置顶你的记本到发现页面。多次购买可重复叠加时间！", "owned": "0"],
                ["name": "毕业证", "banner": "http://img.nian.so/banner/penguin.png", "background_color": "#ffeb61", "cost": "100", "description": "永不停号，愿你已从念获益。", "owned": "0"]
            ]
            collectionView.headerEndRefreshing()
        }
    }
    
    func setup() {
        _setTitle(name)
        
        let w = (globalWidth - padding * 3) / 2
        let h = w / 3 * 4 + 48
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = padding
        flowLayout.minimumLineSpacing = padding
        flowLayout.itemSize = CGSize(width: w, height: h)
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "ProductListCell", bundle: nil), forCellWithReuseIdentifier: "ProductListCell")
        self.view.addSubview(collectionView)
        collectionView.addHeaderWithCallback { () -> Void in
            self.load()
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: ProductListCell! = collectionView.dequeueReusableCellWithReuseIdentifier("ProductListCell", forIndexPath: indexPath) as? ProductListCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.setup()
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let vc = Product()
        let data = dataArray[indexPath.row] as! NSDictionary
        vc.type = name == "表情" ? Product.ProductType.Emoji : Product.ProductType.Plugin
        vc.data = data
        self.navigationController?.pushViewController(vc, animated: true)
    }
}