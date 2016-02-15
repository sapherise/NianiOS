//
//  Instagram.swift
//  Nian iOS
//
//  Created by Sa on 16/2/4.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class Instagram: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let size_field_padding: CGFloat = 12
    let size_collectionview_padding: CGFloat = 8
    let size_height_contentsize: CGFloat = 100
    var dataArray = NSMutableArray()
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("图册")
        setupViews()
    }
    
    func setupViews() {
        /* 设置 UICollectionView */
        let w = (globalWidth - size_field_padding * 2 - size_collectionview_padding * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = size_collectionview_padding
        flowLayout.itemSize = CGSize(width: w, height: w)
        flowLayout.sectionInset = UIEdgeInsets(top: size_field_padding, left: size_field_padding, bottom: 0, right: size_field_padding)
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerNib(UINib(nibName: "AddStepImageCell", bundle: nil), forCellWithReuseIdentifier: "AddStepImageCell")
        view.addSubview(collectionView)
        collectionView.addHeaderWithCallback { () -> Void in
            self.load()
        }
        collectionView.headerBeginRefreshing()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: AddStepImageCell! = collectionView.dequeueReusableCellWithReuseIdentifier("AddStepImageCell", forIndexPath: indexPath) as? AddStepImageCell
        c.imageView.setImage(dataArray[indexPath.row] as! String)
//        c.image = imageArray[indexPath.row]
//        c.setup()
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
//        return 10
    }
    
    func load() {
        Api.getInstagram(token) { json in
            if json != nil {
                let data = json!.objectForKey("data") as! NSArray
                for _d in data {
                    let d = _d as! NSDictionary
                    let images = d.objectForKey("images") as! NSDictionary
                    let image = images.objectForKey("standard_resolution") as! NSDictionary
                    let url = image.stringAttributeForKey("url")
                    print(url)
                    self.dataArray.addObject(url)
                    self.collectionView.reloadData()
                    self.collectionView.headerEndRefreshing()
                }
            }
        }
    }
}