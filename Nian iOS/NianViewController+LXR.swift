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
        c.data = data
        c.total = self.dataArray.count
        c.index = index
        c.labelTitle.text = (data.stringAttributeForKey("title") as NSString).stringByDecodingHTMLEntities().stringByDecodingHTMLEntities()
        c.imageCover.setHolder()
        
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
        
//        print(dataArray)
        
        for i in 0...dataArray.count - 1 {
            let data = dataArray[i] as! NSDictionary
            let name = data.stringAttributeForKey("title")
            print(name)
        }
        
        print("==")
        print(fromIndexPath.item)
        print(toIndexPath.item)
        
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
        print("did begin drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("did end drag")
        // 将移动后的记本排序保存到缓存中
        Cookies.set(self.dataArray, forKey: "NianDreams")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("will begin drag")
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAtIndexPath indexPath: NSIndexPath!) {
        print("will end drag")
    }
}