//
//  NianViewController+LXR.swift
//  Nian iOS
//
//  Created by Sa on 15/12/23.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

extension NianViewController {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell
        let index = (indexPath as NSIndexPath).row
        let c = collectionView.dequeueReusableCell(withReuseIdentifier: "NianCell", for: indexPath) as! NianCell
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
        
        c.setup()
        
        cell = c
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = (indexPath as NSIndexPath).row
        let data = self.dataArray[index] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        self.onDreamClick(id)
    }
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, willMoveTo toIndexPath: IndexPath!) {
        let object = dataArray.object(at: fromIndexPath.item)
        dataArray.removeObject(at: fromIndexPath.item)
        dataArray.insert(object, at: toIndexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView!, itemAt fromIndexPath: IndexPath!, canMoveTo toIndexPath: IndexPath!) -> Bool {
        return true
    }
    
    //
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didBeginDraggingItemAt indexPath: IndexPath!) {
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, didEndDraggingItemAt indexPath: IndexPath!) {
        // 将移动后的记本排序保存到缓存中
        Cookies.set(self.dataArray, forKey: "NianDreams")
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willBeginDraggingItemAt indexPath: IndexPath!) {
    }
    
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, willEndDraggingItemAt indexPath: IndexPath!) {
    }
}
