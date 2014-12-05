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
    
    func onTagSelected(tag: String, tagType: Int)
}

class DreamTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var dreamTagDelegate: DreamTagDelegate?
    
    let dataArray = ["日常", "摄影", "恋爱", "创业", "阅读", "追剧", "绘画", "英语", "收集", "健身", "音乐", "写作", "旅行", "美食", "设计", "游戏", "工作", "习惯", "写字", "其他"]
    let imgArray = ["daily", "camera", "love", "startup", "read", "us", "draw", "english", "collection", "fit", "music", "write", "travel", "food", "design", "game", "work", "habit", "handwriting", "others"]
    
    override func viewDidLoad() {
        setupViews()
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        self.view.addSubview(navView)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset.bottom = 60
        self.extendedLayoutIncludesOpaqueBars = true
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "选择标签"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("TagMediaCell", forIndexPath: indexPath) as TagMediaCell
        mediaCell.label.text = "\(self.dataArray[index])"
        mediaCell.imageView.image = UIImage(named: "tag\(self.imgArray[index])")
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!) {
        dreamTagDelegate?.onTagSelected(dataArray[indexPath.row], tagType: indexPath.row)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
}
