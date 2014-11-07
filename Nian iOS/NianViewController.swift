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
    @IBOutlet var UserHead:UIImageView!
    @IBOutlet var UserName:UILabel!
    @IBOutlet var UserStep:UILabel!
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
            for data2 : AnyObject  in arr {
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
            header?.coinButton.layer.cornerRadius = 4
            header?.coinButton.layer.borderWidth = 1
            header?.coinButton.layer.borderColor = SeaColor.CGColor
            header?.levelButton.layer.cornerRadius = 4
            header?.levelButton.layer.borderWidth = 1
            header?.levelButton.layer.borderColor = SeaColor.CGColor
            
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safename = Sa.objectForKey("user") as String
            var url = NSURL(string:"http://nian.so/api/user.php?uid=\(safeuid)&myuid=\(safeuid)")
            var data = NSData(contentsOfURL: url!, options: NSDataReadingOptions.DataReadingUncached, error: nil)
            var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
            var sa: AnyObject! = json.objectForKey("user")
            var name: AnyObject! = sa.objectForKey("name") as String
            var email: AnyObject! = sa.objectForKey("email") as String
            var coin: AnyObject! = sa.objectForKey("coin") as String
            var dream: AnyObject! = sa.objectForKey("dream") as String
            var step: AnyObject! = sa.objectForKey("step") as String
            var imgURL = "http://img.nian.so/head/\(safeuid).jpg!dream" as NSString
            
            header?.coinButton.setTitle("念币 \(coin)", forState: UIControlState.Normal)
            header?.levelButton.setTitle("等级 \(coin)", forState: UIControlState.Normal)
            
            header?.UserName.text = "\(name)"
            header?.UserHead.setImage(imgURL, placeHolder: LessBlueColor)
            
            header?.UserStep.text = "\(dream)个梦想, \(step)个进展"
            header?.coinButton.addTarget(self, action: "coinClick", forControlEvents: UIControlEvents.TouchUpInside)
            header?.levelButton.addTarget(self, action: "levelClick", forControlEvents: UIControlEvents.TouchUpInside)
            header?.UserStep.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "stepClick"))
        }
        return header!
    }
    
    func stepClick(){
        var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        var safeuid = Sa.objectForKey("uid") as String
        var userVC = UserViewController()
        userVC.Id = "\(safeuid)"
        self.navigationController!.pushViewController(userVC, animated: true)
    }
    
    func levelClick(){
        var levelVC = LevelViewController(nibName: "Level", bundle: nil)
        self.navigationController!.pushViewController(levelVC, animated: true)
    }
    
    func coinClick(){
        var storyboard = UIStoryboard(name: "Coin", bundle: nil)
        var viewController = storyboard.instantiateViewControllerWithIdentifier("CoinViewController") as UIViewController
        self.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var index = indexPath.row
        var data = self.dataArray[index] as NSDictionary
        var title = data.stringAttributeForKey("title")
        var img = data.stringAttributeForKey("img")
        var imgURL = "http://img.nian.so/dream/\(img)!step" as NSString
        var percent = data.stringAttributeForKey("percent")
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCell", forIndexPath: indexPath) as MediaCell
//        mediaCell.label.textColor = IconColor
        mediaCell.label.text = "\(title)"
        mediaCell.imageView.setImage(imgURL, placeHolder: LessBlueColor)
//        mediaCell.imageView.layer.cornerRadius = 6
//        mediaCell.imageView.layer.masksToBounds = true
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