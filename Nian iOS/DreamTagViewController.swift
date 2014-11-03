//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class TagMediaCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
}

protocol DreamTagDelegate {
    
    func onTagSelected(tag: String)
}

class DreamTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var dreamTagDelegate: DreamTagDelegate?
    
    let dataArray = ["日常", "摄影", "恋爱", "创业", "阅读", "追剧", "绘画", "英语", "收集", "健身", "音乐", "写作", "旅行", "美食", "设计", "游戏", "工作", "习惯", "写字", "其他"]
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset.bottom = 60
        self.extendedLayoutIncludesOpaqueBars = true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("TagMediaCell", forIndexPath: indexPath) as TagMediaCell
        mediaCell.label.text = "\(self.dataArray[index])"
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!) {
        dreamTagDelegate?.onTagSelected(dataArray[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
}
