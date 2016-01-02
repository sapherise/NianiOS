//
//  Gallery.swift
//  Nian iOS
//
//  Created by Sa on 15/12/27.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class Gallery: SAViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var collectionView: UICollectionView!
    let padding: CGFloat = 8
    var dataArray = NSMutableArray()
    
    
    var assetsLibrary: ALAssetsLibrary!
    var currentAlbum: ALAssetsGroup?
    var imageArray: [ALAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
    
    func setupViews() {
        _setTitle("相册")
        setBarButtonImage("newOK", actionGesture: "onClick")
        
        let widthImage = (globalWidth - padding * 2) / 3
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = padding
        flowLayout.itemSize = CGSize(width: widthImage, height: widthImage)
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: 0, bottom: padding, right: 0)
        
        collectionView = UICollectionView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64), collectionViewLayout: flowLayout)
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "GalleryCell", bundle: nil), forCellWithReuseIdentifier: "GalleryCell")
        view.addSubview(collectionView)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c = collectionView.dequeueReusableCellWithReuseIdentifier("GalleryCell", forIndexPath: indexPath) as! GalleryCell
//        let img = imageArray[indexPath.row].aspectRatioThumbnail().takeRetainedValue()
//        c.imageView.image = UIImage(CGImage: img)
//        var group = self.dataArray[indexPath.row] as? ALAssetsGroup
//        c.imageView.image = UIImage(CGImage: group.posterImage().takeUnretainedValue())
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func onClick() {
    }
}