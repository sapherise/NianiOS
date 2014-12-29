//
//  ExploreNewCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/17.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

class ExploreNewProvider: ExploreProvider, UICollectionViewDelegate, UICollectionViewDataSource {
    
    class Data {
        
        var id: String!
        var img: String!
        var title: String!
        var promo: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 0
    var dataSource = [Data]()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.collectionView.registerNib(UINib(nibName: "ExploreNewCell", bundle: nil), forCellWithReuseIdentifier: "ExploreNewCell")
    }
    
    func load(clear: Bool, callback: Bool -> Void) {
        Api.getExploreNew("\(page++)", callback: {
            json in
            var success = false
            if json != nil {
                var items = json!["items"] as NSArray
                if items.count != 0 {
                    if clear {
                        self.dataSource.removeAll(keepCapacity: true)
                    }
                    success = true
                    for item in items {
                        var data = Data()
                        data.id = item["id"] as String
                        data.title = item["title"] as String
                        data.img = item["img"] as String
                        data.promo = (item["promo"] as String).toInt()!
                        self.dataSource.append(data)
                    }
                }
            }
            callback(success)
        })
    }
    
    override func onShow() {
        bindViewController!.collectionView.reloadData()
        if dataSource.isEmpty {
            bindViewController!.collectionView.headerBeginRefreshing()
        } else {
            var point = bindViewController!.collectionView.contentOffset
            point.y = 0
            bindViewController!.collectionView.setContentOffset(point, animated: true)
        }
    }
    
    override func onRefresh() {
        page = 0
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
        cell!.imageCover.setImage(V.urlDreamImage(data.img, tag: .Dream), placeHolder: IconColor)
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        viewController.Id = dataSource[indexPath.row].id
        bindViewController!.navigationController!.pushViewController(viewController, animated: true)
    }
}

class ExploreNewCell: UICollectionViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var imageCover: UIImageView!
}