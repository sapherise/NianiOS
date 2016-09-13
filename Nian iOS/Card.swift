//
//  Card.swift
//  Nian iOS
//
//  Created by Sa on 15/7/10.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import AssetsLibrary

class Card: UIView {
    @IBOutlet var image: UIImageView!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var viewLineTop: UIView!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var viewNian: UIView!
    var content: String = ""
    var url: String = ""
    var widthImage: String = "0"
    var heightImage: String = "0"
    var num: CGFloat = 48
    var widthCard: CGFloat = 360
    
    override func awakeFromNib() {
        self.frame = CGRect(x: 10, y: 10, width: widthCard, height: widthCard)
        viewLine.setHeight(globalHalf)
        viewLineTop.setHeight(globalHalf)
    }
    
    func getCard() -> UIImage {
        
        if self.content == "" {
            self.content = V.enTime()
        }
        var heightNew: CGFloat = 0
        let w = self.widthImage.toCGFloat()
        let h = SACeil(self.heightImage.toCGFloat(), dot: 0, isCeil: false)
        if w != 0 {
            heightNew = h * (self.widthCard - self.num * 2) / w
            self.image.frame = CGRect(x: self.num, y: self.num * 2 + 1, width: self.widthCard - self.num * 2, height: heightNew)
            self.labelContent.setY(self.image.bottom() + self.num)
            let imageCache = SDImageCache.shared().imageFromDiskCache(forKey: self.url)
            self.image.image = imageCache
        } else {
            self.image.isHidden = true
            self.labelContent.setY(self.num * 2)
        }
        let heightLine = "".stringHeightWith(12, width: self.widthCard - self.num * 4)
        var heightContent = self.content.stringHeightWith(12, width: self.widthCard - self.num * 4)
        if SAstrlen(self.content as NSString) > 200 {
            heightContent = self.content.stringHeightWith(12, width: self.widthCard - self.num * 2)
            self.labelContent.setX(self.num)
            self.labelContent.setWidth(self.widthCard - self.num * 2)
        }
        self.labelContent.text = self.content
        self.labelContent.setHeight(heightContent)
        self.labelContent.textAlignment = heightContent == heightLine ? NSTextAlignment.center : NSTextAlignment.left
        
        self.viewLine.setY(self.labelContent.bottom() + self.num)
        self.viewNian.setY(self.viewLine.bottom() + self.num)
        
        var heightView = self.image.height() + self.num * 6 + heightContent + heightLine
        if w == 0 {
            heightView = self.num * 5 + heightContent + heightLine
        }
        self.setHeight(SACeil(heightView, dot: 0, isCeil: false))
        return getImageFromView(self)
    }
    
    func onCardSave() {
        go {
            let image = self.getCard()
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }
}

