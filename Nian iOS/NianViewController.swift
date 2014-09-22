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

class NianViewController: UIViewController{
    @IBOutlet var collectionView: UICollectionView!
    var dataArray = NSMutableArray()
    
    override func viewDidLoad() {
        setupViews()
        SAReloadData()
    }
    
    func setupViews(){
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = BGColor
        self.extendedLayoutIncludesOpaqueBars = true
        collectionView.contentInset = UIEdgeInsetsMake(0, 0, 140, 0)
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
            self.collectionView?.reloadData()
            })
    }
    func urlString()->String{
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var safeshell = Sa.objectForKey("shell") as String
        return "http://nian.so/api/nian.php?uid=\(safeuid)&shell=\(safeshell)"
    }
    
    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var index = indexPath!.row
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
//        self.View!.addHeaderWithCallback({
//            self.loadData()
//            })
//        self.View!.addFooterWithCallback({
//            self.loadData()
//            })
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