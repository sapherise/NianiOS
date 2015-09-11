//
//  EditorRecomCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/18/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class EditorRecomCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: NICollectionView!
    @IBOutlet weak var sepLine: UIView!
    @IBOutlet weak var moreButton: UIButton!
    
    var data: NSMutableArray?
    
    /* 用队列下载图片，减轻 mainQueue 的压力 */
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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        _layoutSubview()
        
    }

    func _layoutSubview() {
        
        if data?.count > 0 {
            self.collectionView.reloadData()
        }
        
    }
    
    @IBAction func onEditorMore(sender: UIButton) {
        
    }
}

extension EditorRecomCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let _count = self.data?.count {
            return _count
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
        let _tmpData = self.data?.objectAtIndex(indexPath.row) as! NSDictionary
        
        if let _img = _tmpData.objectForKey("image") as? String {

            let imgOp = NSBlockOperation(block: {
                if isiPhone6 || isiPhone6P {
                    (collectionCell as! CollectionViewCell_XL).imageView?.setImageWithRounded(6.0, urlString: "http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                } else {
                    (collectionCell as! CollectionViewCell).imageView?.setImageWithRounded(6.0, urlString: "http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
                }           
            })
            
            cellImageDict[indexPath] = imgOp
            currentQueue.addOperations([imgOp], waitUntilFinished: false)
        }
        
        if isiPhone6 || isiPhone6P {
            (collectionCell as! CollectionViewCell_XL).label?.text = SADecode(_tmpData.objectForKey("title") as! String)
        } else {
            (collectionCell as! CollectionViewCell).label?.text = SADecode(_tmpData.objectForKey("title") as! String)
        }
        
        return collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let DreamVC = DreamViewController()
        DreamVC.Id = (self.data?.objectAtIndex(indexPath.row) as! NSDictionary)["id"] as! String
        
        //
        (self.findRootViewController() as! ExploreViewController).scrollView.scrollEnabled = true   
        
        if DreamVC.Id != "0" && DreamVC.Id != "" {
            self.findRootViewController()?.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }
    
    /**
    
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






