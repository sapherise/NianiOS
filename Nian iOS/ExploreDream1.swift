////
////  PhotosViewController.swift
////  InstaDude
////
////  Created by Ashley Robinson on 19/06/2014.
////  Copyright (c) 2014 Ashley Robinson. All rights reserved.
////
//
//import Foundation
//import UIKit
//
//class ExploreDreamViewController: UIViewController, AddDelegate{
//    @IBOutlet var collectionView: UICollectionView!
//    @IBOutlet var scrollView:UIScrollView!
//    var dataArray = NSMutableArray()
//    var page :Int = 0
//    //  @IBOutlet strong var View: UIView
//    
//    override func viewDidLoad() {
//        setupViews()
//        //   self.View?.headerBeginRefreshing()
//        loadData()
//        setupRefresh()
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//    }
//    
//    func setupViews(){
//        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
//        visualEffectView.layer.borderWidth = 1.0
//        collectionView.alwaysBounceVertical = true
//        self.extendedLayoutIncludesOpaqueBars = true
//        collectionView.contentInset = UIEdgeInsetsMake(51, 0, 20, 0)
//    }
//    
//    func loadData(){
//        var url = urlString()
//        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
//            if data as NSObject == NSNull(){
//                UIView.showAlertView("提示",message:"加载失败")
//                return
//            }
//            var arr = data["items"] as NSArray
//            for data : AnyObject  in arr{
//                self.dataArray.addObject(data)
//            }
//            self.collectionView!.reloadData()
//            self.collectionView!.footerEndRefreshing()
//            self.page++
//            })
//    }
//    func SAReloadData(){
//        var url = urlString()
//        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
//            if data as NSObject == NSNull(){
//                UIView.showAlertView("提示",message:"加载失败")
//                return
//            }
//            var arr = data["items"] as NSArray
//            self.dataArray.removeAllObjects()
//            for data2 : AnyObject  in arr{
//                self.dataArray.addObject(data2)
//            }
//            self.collectionView?.reloadData()
//            })
//    }
//    func urlString()->String{
//        return "http://nian.so/api/explore_all.php?page=\(page)"
//    }
//    
//    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
//        return self.dataArray.count
//    }
//    
//    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
//        var index = indexPath!.row
//        var data = self.dataArray[index] as NSDictionary
//        var title = data.stringAttributeForKey("title")
//        var img = data.stringAttributeForKey("img")
//        var promo = data.stringAttributeForKey("promo")
//        var imgURL = "http://img.nian.so/dream/\(img)!dream" as NSString
//        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCell", forIndexPath: indexPath) as MediaCell
//        if(promo=="1"){
//            mediaCell.label.textColor = GoldColor
//        }else{
//            mediaCell.label.textColor = IconColor
//        }
//        mediaCell.label.text = "\(title)"
//        mediaCell.imageView.setImage(imgURL, placeHolder: SAColorImg(IconColor))
//        mediaCell.imageView.layer.cornerRadius = 6
//        mediaCell.imageView.layer.masksToBounds = true
//        return mediaCell
//    }
//    
//    func collectionView(collectionView:UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath!){
//        var controllers = self.navigationController.viewControllers
//        self.navigationController.viewControllers = controllers
//        var DreamVC = DreamViewController()
//        var index = indexPath!.row
//        var data = self.dataArray[index] as NSDictionary
//        DreamVC.Id = data.stringAttributeForKey("id")
//        self.navigationController.pushViewController(DreamVC, animated: true)
//    }
//    
//    
//    func countUp() {      //😍
//        println("1")
//    }
//    
//    
//    func setupRefresh(){
//    }
//}