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
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
    func textViewDidChange(_ textView: UITextView) {
        let h = resize()
        resizeView(h)
        if textView.text == "" {
            labelPlaceHolder.isHidden = false
        } else {
            labelPlaceHolder.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let c: EmojiCell! = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath) as? EmojiCell
        c.data = dataArray[(indexPath as NSIndexPath).row] as! NSDictionary
        c.setup()
        c.contentView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI/2))
        return c
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dataArray.count > 0 {
            for i in 0...(dataArray.count - 1) {
                current = (indexPath as NSIndexPath).row
                let data = dataArray[i] as! NSDictionary
                let d = NSMutableDictionary(dictionary: data)
                let isClicked = i == (indexPath as NSIndexPath).row ? "1" : "0"
                d.setValue(isClicked, forKey: "isClicked")
                dataArray.replaceObject(at: i, with: d)
            }
            tableView.reloadData()
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
                viewCollectionHolder.isHidden = false
            } else {
                viewCollectionHolder.isHidden = true
            }
            return 8
        }
        viewCollectionHolder.isHidden = true
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let c: EmojiCollectionCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCollectionCell", for: indexPath) as? EmojiCollectionCell
        if dataArray.count > current {
            let data = dataArray[current] as! NSDictionary
            let code = data.stringAttributeForKey("code")
            c.path = "http://img.nian.so/emoji/\(code)/\((indexPath as NSIndexPath).row + 1).gif!dream"
            c.num = (indexPath as NSIndexPath).row
            c.imageHead.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(InputView.onEmojiLongPress(_:))))
            c.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InputView.onEmojiTap(_:))))
            c.setup()
        }
        return c
    }
    
    /* 表情长按预览 */
    func onEmojiLongPress(_ sender: UIGestureRecognizer) {
        if let view = sender.view {
            let point = view.convert(view.frame.origin, from: self.viewEmoji)
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
            viewEmojiHolder.qs_setGifImageWithURL(URL(string: url)!, progress: nil, completed: nil)
            viewEmojiHolder.frame = CGRect(x: xNew, y: yNew, width: w, height: w)
            viewEmojiHolder.isHidden = sender.state == UIGestureRecognizerState.ended
            if sender.state == UIGestureRecognizerState.ended {
                viewEmojiHolder.animatedImage = nil
            }
        }
    }
    
    /* 表情单击 */
    func onEmojiTap(_ sender: UIGestureRecognizer) {
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
