//
//  SATextField+Delegate.swift
//  Nian iOS
//
//  Created by Sa on 16/3/1.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

extension InputView {
    /* 提交回应 */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            delegate?.send()
            let h = resize()
            resizeView(h)
            return false
        }
        return true
    }
    
    /* 改变文本时，调整整个视图 */
    func textViewDidChange(textView: UITextView) {
        let h = resize()
        resizeView(h)
        if textView.text == "" {
            labelPlaceHolder.hidden = false
        } else {
            labelPlaceHolder.hidden = true
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let c: EmojiCell! = tableView.dequeueReusableCellWithIdentifier("EmojiCell", forIndexPath: indexPath) as? EmojiCell
        c.data = dataArray[indexPath.row] as! NSDictionary
        c.setup()
        c.contentView.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        return c
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if dataArray.count > 0 {
            for i in 0...(dataArray.count - 1) {
                current = indexPath.row
                let data = dataArray[i] as! NSDictionary
                let d = NSMutableDictionary(dictionary: data)
                let isClicked = i == indexPath.row ? "1" : "0"
                d.setValue(isClicked, forKey: "isClicked")
                dataArray.replaceObjectAtIndex(i, withObject: d)
            }
            tableView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: EmojiCollectionCell! = collectionView.dequeueReusableCellWithReuseIdentifier("EmojiCollectionCell", forIndexPath: indexPath) as? EmojiCollectionCell
        if dataArray.count > current {
            let data = dataArray[current] as! NSDictionary
            let code = data.stringAttributeForKey("code")
            c.path = "http://img.nian.so/emoji/\(code)/\(indexPath.row + 1).gif!dream"
            c.num = indexPath.row
            c.setup()
        }
        return c
    }
}