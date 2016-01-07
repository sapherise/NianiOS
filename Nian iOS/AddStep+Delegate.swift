//
//  AddStep+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 15/12/28.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import AssetsLibrary

extension AddStep {
    
    /* tableView */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCellWithIdentifier("AddStepCell", forIndexPath: indexPath) as! AddStepCell
        let data = self.dataArray[indexPath.row] as? NSDictionary
        c.data = data
        c.setup()
        return c
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = dataArray[indexPath.row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let title = data.stringAttributeForKey("title")
        let image = data.stringAttributeForKey("image")
        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
        self.imageDream.setImage(userImageURL)
        self.idDream = id
        self.labelDream.text = title
        
        tableView.hidden = true
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.imageArrow.transform = CGAffineTransformMakeRotation(0)
        })
    }
    
    /* collectionView */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: AddStepImageCell! = collectionView.dequeueReusableCellWithReuseIdentifier("AddStepImageCell", forIndexPath: indexPath) as? AddStepImageCell
        c.image = imageArray[indexPath.row]
        c.setup()
        return c
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        field2.resignFirstResponder()
        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet.addButtonWithTitle("移除")
        actionSheet.addButtonWithTitle("取消")
        actionSheet.cancelButtonIndex = 1
        actionSheet.showInView(self.view)
        rowDelete = indexPath.row
    }
    
    /* ActionSheet */
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if rowDelete >= 0 {
                imageArray.removeAtIndex(rowDelete)
                hasUploadedArray.removeAtIndex(rowDelete)
                reLayout()
            }
        }
    }
    
    /* shareDelegate */
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    
}