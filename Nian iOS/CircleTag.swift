//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

protocol CircleTagDelegate {
    func onTagSelected(tag: String, tagType: Int)
}

class CircleTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var circleTagDelegate: CircleTagDelegate?
    
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
        return V.Tags.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("TagMediaCell", forIndexPath: indexPath) as TagMediaCell
        mediaCell.label.text = "\(V.Tags[index])"
        mediaCell.imageView.image = UIImage(named: "tag\(self.imgArray[index])")
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!) {
        circleTagDelegate?.onTagSelected(V.Tags[indexPath.row], tagType: indexPath.row)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func back(){
        if let v = self.navigationController {
            v.popViewControllerAnimated(true)
        }
    }
}
