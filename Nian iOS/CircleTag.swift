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
    func onTagSelected(tag: String, tagType: Int, dreamType: Int)
}

class CircleTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var circleTagDelegate: CircleTagDelegate?
    var dataArray = NSMutableArray()
    
    let imgArray = ["daily", "camera", "love", "startup", "read", "us", "draw", "english", "collection", "fit", "music", "write", "travel", "food", "design", "game", "work", "habit", "handwriting", "others"]
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.viewBack()
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
        var data = self.dataArray[index] as NSDictionary
        var title = data.objectForKey("title") as String
        var img = data.objectForKey("img") as String
        mediaCell.label.text = "\(title)"
        mediaCell.imageView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!) {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var tag = (data.objectForKey("hashtag") as String).toInt()
        var dreamType = (data.objectForKey("id") as String).toInt()
        var textTag = "未选标签"
        if tag != nil {
            if tag >= 1 {
                textTag = V.Tags[tag!-1]
            }
        }else{
            tag = 0
        }
        circleTagDelegate?.onTagSelected(textTag, tagType: tag!, dreamType: dreamType!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func SAReloadData(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        var url = "http://nian.so/api/circle_tag.php?uid=\(safeuid)"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject != NSNull() {
                var arr = data["items"] as NSArray
                self.dataArray.removeAllObjects()
                for data : AnyObject  in arr{
                    self.dataArray.addObject(data)
                }
                self.collectionView.reloadData()
            }
        })
    }
}
