//
//  Card.swift
//  Nian iOS
//
//  Created by Sa on 15/7/10.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
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
        self.frame = CGRectMake(10, 10, widthCard, widthCard)
        viewLine.setHeight(0.5)
        viewLineTop.setHeight(0.5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getCard() -> UIImage {
        
        if self.content == "" {
            self.content = V.enTime()
        }
        self.image.setImage(self.url, placeHolder: IconColor)
        var heightNew: CGFloat = 0
        var w = CGFloat((self.widthImage as NSString).floatValue)
        var h = SACeil(CGFloat((self.heightImage as NSString).floatValue), 0, isCeil: false)
        if w != 0 {
            heightNew = h * (self.widthCard - self.num * 2) / w
            self.image.frame = CGRectMake(self.num, self.num * 2 + 1, self.widthCard - self.num * 2, heightNew)
            self.labelContent.setY(self.image.bottom() + self.num)
        } else {
            self.image.hidden = true
            self.labelContent.setY(self.num * 2)
        }
        var heightLine = "".stringHeightWith(12, width: self.widthCard - self.num * 4)
        var heightContent = self.content.stringHeightWith(12, width: self.widthCard - self.num * 4)
        if SAstrlen(self.content) > 200 {
            heightContent = self.content.stringHeightWith(12, width: self.widthCard - self.num * 2)
            self.labelContent.setX(self.num)
            self.labelContent.setWidth(self.widthCard - self.num * 2)
        }
        self.labelContent.text = self.content
        self.labelContent.setHeight(heightContent)
        self.labelContent.textAlignment = heightContent == heightLine ? NSTextAlignment.Center : NSTextAlignment.Left
        
        self.viewLine.setY(self.labelContent.bottom() + self.num)
        self.viewNian.setY(self.viewLine.bottom() + self.num)
        
        var heightView = self.image.height() + self.num * 6 + heightContent + heightLine
        if w == 0 {
            heightView = self.num * 5 + heightContent + heightLine
        }
        self.setHeight(SACeil(heightView, 0, isCeil: false))
        return getImageFromView(self)
    }
    
    func onCardSave() {
        go {
            var image = self.getCard()
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
        }
    }
}