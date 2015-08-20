//
//  EditorRecomCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 8/18/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class EditorRecomCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sepLine: UIView!
    
    var data: NSMutableArray?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.sepLine.setHeightHalf()
        
        self.collectionView.registerNib(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
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
        
        var collectionCell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        var _tmpData = self.data?.objectAtIndex(indexPath.row) as! NSDictionary
        
        if let _img = _tmpData.objectForKey("image") as? String {
            collectionCell.imageView?.setImage("http://img.nian.so/dream/\(_img)!dream", placeHolder: IconColor)
        }
        
        collectionCell.label?.text = SADecode(_tmpData.objectForKey("title") as! String)
        
        return collectionCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var DreamVC = DreamViewController()
        DreamVC.Id = (self.data?.objectAtIndex(indexPath.row) as! NSDictionary)["id"] as! String
        
        if DreamVC.Id != "0" && DreamVC.Id != "" {
            self.findRootViewController()?.navigationController?.pushViewController(DreamVC, animated: true)
        }
    }
    
}

extension EditorRecomCell: UIGestureRecognizerDelegate {
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        logInfo("shouldRecognizeSimultaneouslyWithGestureRecognizer \(gestureRecognizer)")
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return false
        }
        return true
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        logVerbose("shouldBeRequiredToFailByGestureRecognizer, \(gestureRecognizer)")
        
        if gestureRecognizer.isKindOfClass(UIScreenEdgePanGestureRecognizer) {
            return true
        }
        return false
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        logWarn("shouldReceiveTouch, \(gestureRecognizer), \n  touch: \(touch)")
        
        if gestureRecognizer.isKindOfClass(UILongPressGestureRecognizer) {
            return false
        }
        return true
    }
    
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        logInfo("gesture Recognizer: \(gestureRecognizer)")
        
        return true 
    }
    
}





