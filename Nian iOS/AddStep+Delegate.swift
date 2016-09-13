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
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c = tableView.dequeueReusableCell(withIdentifier: "AddStepCell", for: indexPath) as! AddStepCell
        let data = self.dataArray[(indexPath as NSIndexPath).row] as? NSDictionary
        c.data = data
        c.setup()
        return c
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    @objc(tableView:didSelectRowAtIndexPath:) func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        let id = data.stringAttributeForKey("id")
        let title = data.stringAttributeForKey("title").decode()
        let image = data.stringAttributeForKey("image")
        let userImageURL = "http://img.nian.so/dream/\(image)!dream"
        self.imageDream.setImage(userImageURL)
        self.idDream = id
        self.labelDream.text = title
        
        tableView.isHidden = true
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.imageArrow.transform = CGAffineTransform(rotationAngle: 0)
        })
    }
    
    /* collectionView */
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c: AddStepImageCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "AddStepImageCell", for: indexPath) as? AddStepImageCell
        c.image = imageArray[(indexPath as NSIndexPath).row]
        c.setup()
        return c
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        field2.resignFirstResponder()
        actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        actionSheet.addButton(withTitle: "移除")
        actionSheet.addButton(withTitle: "取消")
        actionSheet.cancelButtonIndex = 1
        actionSheet.show(in: self.view)
        rowDelete = (indexPath as NSIndexPath).row
    }
    
    /* ActionSheet */
    @objc(actionSheet:clickedButtonAtIndex:) func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            if rowDelete >= 0 {
                imageArray.remove(at: rowDelete)
                hasUploadedArray.remove(at: rowDelete)
                reLayout()
            }
        }
    }
    
    /* shareDelegate */
    func onShare(_ avc: UIActivityViewController) {
        self.present(avc, animated: true, completion: nil)
    }
    
    
}
