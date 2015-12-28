//
//  NianViewController+LXR.swift
//  Nian iOS
//
//  Created by Sa on 15/12/23.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension NianViewController {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        let index = indexPath.row
        let c = collectionView.dequeueReusableCellWithReuseIdentifier("NianCell", forIndexPath: indexPath) as! NianCell
        let data = self.dataArray[index] as! NSDictionary
        let title = data.stringAttributeForKey("title").decode()
        
        c.data = data
        c.total = self.dataArray.count
        c.index = index
        c.labelTitle.text = title
//        c.imageCover.setHolder()
        
        var img = data.stringAttributeForKey("image")
        if img != "" {
            img = "http://img.nian.so/dream/\(img)!dream"
            c.imageCover.setImage(img)
        }
        
        cell = c
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let data = self.dataArray[index] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        self.onDreamClick(id)
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, willMoveToIndexPath toIndexPath: NSIndexPath!) {
        let object = dataArray.objectAtIndex(fromIndexPath.item)
        dataArray.removeObjectAtIndex(fromIndexPath.item)
        dataArray.insertObject(object, atIndex: toIndexPath.item)
    }
    
    func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView!, itemAtIndexPath fromIndexPath: NSIndexPath!, canMoveToIndexPath toIndexPath: NSIndexPath!) -> Bool {
        return true
    }
    
    //
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        // 将移动后的记本排序保存到缓存中
        Cookies.set(self.dataArray, forKey: "NianDreams")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
    }
}