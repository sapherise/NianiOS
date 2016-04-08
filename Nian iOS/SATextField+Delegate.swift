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
            let content = textView.text
            if content == "" {
                return true
            }
            let type = inputType == inputTypeEnum.comment ? "0" : "1"
            delegate?.send(content, type: type)
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
            collectionView.reloadData()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if dataArray.count > current {
            let data = dataArray[current] as! NSDictionary
            let owned = data.stringAttributeForKey("owned")
            if owned == "0" {
                let code = data.stringAttributeForKey("code")
                let description = data.stringAttributeForKey("description")
                let name = data.stringAttributeForKey("name")
                let h = description.stringHeightWith(14, width: contentCollectionHolder.width())
                imageCollectionHolder.setImage("http://img.nian.so/emoji/\(code)/type_sticker_cover.png")
                titleCollectionHolder.text = name
                contentCollectionHolder.text = description
                contentCollectionHolder.setHeight(h)
                viewCollectionHolder.hidden = false
            } else {
                viewCollectionHolder.hidden = true
            }
            return 8
        }
        viewCollectionHolder.hidden = true
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let c: EmojiCollectionCell! = collectionView.dequeueReusableCellWithReuseIdentifier("EmojiCollectionCell", forIndexPath: indexPath) as? EmojiCollectionCell
        if dataArray.count > current {
            let data = dataArray[current] as! NSDictionary
            let code = data.stringAttributeForKey("code")
            c.path = "http://img.nian.so/emoji/\(code)/\(indexPath.row + 1).gif!dream"
            c.num = indexPath.row
            c.imageHead.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(InputView.onEmojiLongPress(_:))))
            c.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputView.onEmojiTap(_:))))
            c.setup()
        }
        return c
    }
    
    /* 表情长按预览 */
    func onEmojiLongPress(sender: UIGestureRecognizer) {
        if let view = sender.view {
            let point = view.convertPoint(view.frame.origin, fromView: self.viewEmoji)
            let x = -point.x
            let y = -point.y
            
            /* 6 为 cell 中的 padding */
            let padding: CGFloat = 25
            let w = view.width() + padding * 2
            let xNew = min(max(x - 25 + 12, 0), globalWidth - view.width() - 50)
            let yNew = y - view.width() - 50 - 8
            let data = dataArray[current] as! NSDictionary
            let code = data.stringAttributeForKey("code")
            let url = "http://img.nian.so/emoji/\(code)/\(view.tag + 1).gif"
            viewEmojiHolder.qs_setGifImageWithURL(NSURL(string: url)!, progress: nil, completed: nil)
            viewEmojiHolder.frame = CGRectMake(xNew, yNew, w, w)
            viewEmojiHolder.hidden = sender.state == UIGestureRecognizerState.Ended
            if sender.state == UIGestureRecognizerState.Ended {
                viewEmojiHolder.animatedImage = nil
            }
        }
    }
    
    /* 表情单击 */
    func onEmojiTap(sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            let data = dataArray[current] as! NSDictionary
            let code = data.stringAttributeForKey("code")
            let type = inputType == inputTypeEnum.comment ? "1" : "3"
            delegate?.send("\(code)-\(tag + 1)", type: type)
            let h = resize()
            resizeView(h)
        }
    }
}