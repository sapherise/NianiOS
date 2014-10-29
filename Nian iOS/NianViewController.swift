//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class MediaCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!
    @IBOutlet var imageView: UIImageView!
}

class MySupplementaryView : UICollectionReusableView {
    @IBOutlet var coinButton:UIButton!
    @IBOutlet var levelButton:UIButton!
}

class NianViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    @IBOutlet var collectionView: UICollectionView!
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
        setupRefresh()
    }
    
    func setupViews(){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.contentInset.bottom = 60
        self.extendedLayoutIncludesOpaqueBars = true
    }
    func SAReloadData(){
        var url = urlString()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray.removeAllObjects()
            for data2 : AnyObject  in arr{
                self.dataArray.addObject(data2)
            }
            self.collectionView.reloadData()
            self.collectionView.headerEndRefreshing()
            })
    }
    func urlString()->String{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/nian.php?uid=\(safeuid)&shell=\(safeshell)"
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var header : MySupplementaryView? = nil
        if (kind == UICollectionElementKindSectionHeader) {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "NianHeader", forIndexPath: indexPath)
                as? MySupplementaryView
//            header?.coinButton.backgroundColor = LineColor
//            header?.levelButton.backgroundColor = LineColor
//            header?.coinButton.setTitleColor(BGColor, forState: UIControlState.Normal)
//            header?.levelButton.setTitleColor(BGColor, forState: UIControlState.Normal)
//            header?.coinButton.layer.cornerRadius = 4
//            header?.levelButton.layer.cornerRadius = 4
//            
//            header?.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
        }
        return header!
    }
    
    func levelClick(){
        var levelVC = LevelViewController(nibName: "Level", bundle: nil)
        self.navigationController!.pushViewController(levelVC, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var title = data.stringAttributeForKey("title")
        var img = data.stringAttributeForKey("img")
        var imgURL = "http://img.nian.so/dream/\(img)!step" as NSString
        var percent = data.stringAttributeForKey("percent")
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCell", forIndexPath: indexPath) as MediaCell
        mediaCell.label.textColor = IconColor
        mediaCell.label.text = "\(title)"
        mediaCell.imageView.setImage(imgURL, placeHolder: LessBlueColor)
        mediaCell.imageView.layer.cornerRadius = 6
        mediaCell.imageView.layer.masksToBounds = true
        return mediaCell
    }
    
    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!){
        var controllers = self.navigationController!.viewControllers
        self.navigationController!.viewControllers = controllers
        var DreamVC = DreamViewController()
        var index = indexPath!.row
        var data = self.dataArray[index] as NSDictionary
        DreamVC.Id = data.stringAttributeForKey("id")
        self.navigationController!.pushViewController(DreamVC, animated: true)
    }
    
    
    func setupRefresh(){
        self.collectionView.addHeaderWithCallback{
            self.SAReloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        if globalWillNianReload == 1 {
            self.SAReloadData()
            globalWillNianReload = 0
        }
    }
    
}