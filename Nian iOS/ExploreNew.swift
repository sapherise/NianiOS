//
//  ExploreNewCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/17.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

class ExploreNewProvider: ExploreProvider, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    
    class Data {
        var id: String!
        var img: String!
        var title: String!
        var promo: Int!
        var sid: String!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 0
    var dataSource = [Data]()
    var dataArray = NSMutableArray()
    var lastID = "0"
    
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.collectionView.registerNib(UINib(nibName: "ExploreNewCell", bundle: nil), forCellWithReuseIdentifier: "ExploreNewCell")
        
//        let flowLayout = UICollectionViewFlowLayout()
//        var width = (viewController.view.bounds.width - 48) / 2
//        flowLayout.minimumInteritemSpacing = 0.0
//        flowLayout.minimumLineSpacing = 16.0
//        flowLayout.itemSize = CGSize(width: width, height: 182)
//        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
//        viewController.collectionView.collectionViewLayout = flowLayout
        
    }
    
    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreNew("\(self.lastID)", page: self.page++, callback: {
            json in
            var success = false
            if json != nil {
                globalTab[3] = false
                
                var items = json!.objectForKey("items") as! NSArray
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                    success = true
                    for item in items {
                        var data = Data()

                        data.id = (item as! NSDictionary)["id"] as! String
                        data.title = (item as! NSDictionary)["title"] as! String
                        data.img = (item as! NSDictionary)["img"] as! String
                        data.promo = ((item as! NSDictionary)["promo"] as! String).toInt()!
                        data.sid = (item as! NSDictionary)["sid"] as! String
                        
                        self.dataSource.append(data)
                    }
                    
                    var count = self.dataSource.count
                    if count >= 1 {
                        var data = self.dataSource[count - 1]
                        self.lastID = data.sid
                    }
                }
            }
            callback(success)
        })
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.collectionView.reloadData()
        if dataSource.isEmpty {
            bindViewController!.collectionView.headerBeginRefreshing()
        } else {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.bindViewController!.collectionView.setContentOffset(CGPointZero, animated: false)
                }, completion: { (Bool) -> Void in
                    if loading {
                        self.bindViewController!.collectionView.headerBeginRefreshing()
                    }
            })
        }
    }
    
    override func onRefresh() {
        page = 0
        self.lastID = "0"
        load(true) {
            success in
            if self.bindViewController!.current == 3 {
                self.bindViewController!.collectionView.headerEndRefreshing()
                self.bindViewController!.collectionView.reloadData()
            }
        }
    }
    
    override func onLoad() {
        load(false) {
            success in
            if self.bindViewController!.current == 3 {
                if success {
                    self.bindViewController!.collectionView.footerEndRefreshing()
                    self.bindViewController!.collectionView.reloadData()
                } else {
                    self.bindViewController!.view.showTipText("已经到底啦", delay: 1)
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreNewCell", forIndexPath: indexPath) as? ExploreNewCell
        var data = dataSource[indexPath.row]
        cell!.labelTitle.textColor = data.promo == 1 ? GoldColor : UIColor.blackColor()
        cell!.labelTitle.text = data.title
        var height = data.title.stringHeightWith(13, width: 80)
        height = height > "".stringHeightWith(13, width: 80) ? "1\n1".stringHeightWith(13, width: 80) : height
        cell!.labelTitle.setHeight(height)
        cell!.imageCover.setHolder()
        cell!.imageCover.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        cell!.imageCover.layer.borderWidth = 0.5
        
        var uidKey = KeychainItemWrapper(identifier: "uidKey", accessGroup: nil)
        var safeuid = uidKey.objectForKey(kSecAttrAccount) as! String
//        var safeshell = uidKey.objectForKey(kSecValueData) as! String
        
        if safeuid == "171264" {
            cell!.imageCover.layer.cornerRadius = 0
        }
        if data.img != "" {
            cell!.imageCover.setImage(V.urlDreamImage(data.img, tag: .Dream), placeHolder: IconColor, bool: false)
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[indexPath.row].id
        var data = dataSource[indexPath.row]
        var height = data.title.stringHeightWith(13, width: 80)
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    }
}

class ExploreNewCell: UICollectionViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var imageCover: UIImageView!
    
    
     override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageCover.cancelImageRequestOperation()
        self.imageCover.image = nil
    }
}