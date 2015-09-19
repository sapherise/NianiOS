//
//  LatestNoteCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/18/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class LatestNoteCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: NICollectionView!
    @IBOutlet weak var sepLine: UIView!
    
    var data: NSMutableDictionary?
    var promoArray: NSArray?
    var itemsArray: NSArray?
    
    /* 用队列来下载图片，减轻 mainQueue 的压力 */
    var currentQueue = NSOperationQueue.mainQueue()
    
    var cellImageDict = Dictionary<NSIndexPath, NSBlockOperation>()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.sepLine.setHeightHalf()
        
        if isiPhone6 || isiPhone6P {
            self.collectionView.registerNib(UINib(nibName: "CollectionViewCell_XL", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell_XL")
        } else {
            self.collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        _layoutSubview()
        
    }

    func _layoutSubview() {
        if data?.count > 0 {
            self.promoArray = self.data?.objectForKey("promo") as? NSArray
            self.itemsArray = self.data?.objectForKey("items") as? NSArray
            
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func onLatestMore(sender: UIButton) {
        
        
    }
    
}

extension LatestNoteCell: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _itemsCount = self.itemsArray?.count {
            if let _promoCount = self.promoArray?.count {
                return _itemsCount + _promoCount
            } else {
                return _itemsCount
            }
        } else {
            return 0
        }
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var collectionCell = UICollectionViewCell()
        
        if isiPhone6 || isiPhone6P {
            collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell_XL", forIndexPath: indexPath) as! CollectionViewCell_XL
        } else {
            collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        }
        var _tmpData: NSDictionary?
        
        if indexPath.row < 3 {
            _tmpData = self.promoArray?.objectAtIndex(indexPath.row) as? NSDictionary
        } else {
            _tmpData = self.itemsArray?.objectAtIndex(indexPath.row - 3) as? NSDictionary
        }
        
        if let _img = _tmpData!.objectForKey("image") as? String {
            let imgOp = NSBlockOperation(block: {
                if isiPhone6 || isiPhone6P {
                    (collectionCell as! CollectionViewCell_XL).imageView?.setImageWithRounded(6.0, urlString: "http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                        //setImage("http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                } else {
                    (collectionCell as! CollectionViewCell).imageView?.setImageWithRounded(6.0, urlString: "http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                        //setImage("http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                }
            })
            cellImageDict[indexPath] = imgOp
            currentQueue.addOperations([imgOp], waitUntilFinished: false)
        }
        
        if isiPhone6 || isiPhone6P {
            (collectionCell as! CollectionViewCell_XL).label?.text = (_tmpData!.objectForKey("title") as! String).decode()
        } else {
            (collectionCell as! CollectionViewCell).label?.text = (_tmpData!.objectForKey("title") as! String).decode()
        }
        
        return collectionCell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let DreamVC = DreamViewController()
        
        if indexPath.row < 3 {
            DreamVC.Id = (self.promoArray?.objectAtIndex(indexPath.row) as! NSDictionary)["id"] as! String
        } else {
            DreamVC.Id = (self.itemsArray?.objectAtIndex(indexPath.row - 3) as! NSDictionary)["id"] as! String
        }
        
        // 
        (self.findRootViewController() as! ExploreViewController).scrollView.scrollEnabled = true
        
        if DreamVC.Id != "0" && DreamVC.Id != "" {
            self.findRootViewController()?.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }

    
    /**
    <#Description#>
    */
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let op = cellImageDict[indexPath]
        
        if let _op = op {
            if _op.ready || _op.executing {
                cellImageDict[indexPath]?.cancel()
                cellImageDict[indexPath] = nil
            }
        }
    }
    
}








