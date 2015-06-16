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
    func delegateTag(title: String, id: String)
}
protocol DreamPromoDelegate {
    func onPromoClick(id: Int, content: String)
}

class CircleTagViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var circleTagDelegate: CircleTagDelegate?
    var dreamPromoDelegate: DreamPromoDelegate?
    var dataArray = NSMutableArray()
    
    let imgArray = ["daily", "camera", "love", "startup", "read", "us", "draw", "english", "collection", "fit", "music", "write", "travel", "food", "design", "thegame", "work", "habit", "handwriting", "others"]
    
    override func viewDidLoad() {
        setupViews()
        load()
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
        if dreamPromoDelegate != nil {
            titleLabel.text = "推广记本"
        }else{
            titleLabel.text = "绑定记本"
        }
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.collectionView.frame.size = CGSizeMake(globalWidth, globalHeight)
        self.view.frame.size = CGSizeMake(globalWidth, globalHeight)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("TagMediaCell", forIndexPath: indexPath) as! TagMediaCell
        var data = self.dataArray[index] as! NSDictionary
        var title = data.objectForKey("title") as! String
        var img = data.objectForKey("img") as! String
        mediaCell.label.text = "\(title)"
        mediaCell.imageView.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath) {
        var index = indexPath.row
        var data = self.dataArray[index] as! NSDictionary
        var id = data.stringAttributeForKey("id")
        var title = data.stringAttributeForKey("title")
        if dreamPromoDelegate != nil {  // 如果是推广记本
            if let v = id.toInt() {
                dreamPromoDelegate?.onPromoClick(v, content: title)
                self.navigationController?.popViewControllerAnimated(true)
            }
        }else if circleTagDelegate != nil { // 如果是梦境绑定标签
            circleTagDelegate?.delegateTag(title, id: id)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func load(){
        Api.postCircleTag() { json in
            if json != nil {
                var arr = json!["items"] as! NSArray
                self.dataArray.removeAllObjects()
                for data in arr {
                    self.dataArray.addObject(data)
                }
                if self.dataArray.count == 0 {
                    var textEmpty = "要先有一个\n公开中的记本"
                    var viewTop = viewEmpty(globalWidth, content: textEmpty)
                    viewTop.setY(104)
                    var viewHolder = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    viewHolder.addSubview(viewTop)
                    self.view.addSubview(viewHolder)
                    self.collectionView?.hidden = true
                }
                self.collectionView.reloadData()
            }
        }
    }
}
