//
//  Popup.swift
//  Nian iOS
//
//  Created by Sa on 15/3/13.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation

class Popup: UIView {
    @IBOutlet var viewBackGround: ILTranslucentView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var btnMain: UIButton!
    @IBOutlet var btnSub: UIButton!
    var heightImage: CGFloat = 0
    var textTitle: String = ""
    var textContent: String = ""
    var textBtnMain: String = ""
    var textBtnSub: String = ""
    override func awakeFromNib() {
        self.setWidth(globalWidth)
        self.setHeight(globalHeight)
        self.viewBackGround.setWidth(globalWidth)
        self.viewBackGround.setHeight(globalHeight)
        self.viewHolder.setX(globalWidth/2 - 135)
        self.viewBackGround.translucentAlpha = 1
        self.viewBackGround.translucentStyle = UIBarStyle.Default
        self.viewBackGround.translucentTintColor = UIColor.clearColor()
        self.btnMain.backgroundColor = UIColor.HightlightColor()
        self.btnMain.hidden = true
        self.btnSub.hidden = true
    }
    
    override func layoutSubviews() {
        self.labelTitle.text = textTitle
        self.labelTitle.setY(self.heightImage + 20)
        self.labelContent.setY(self.labelTitle.bottom() + 8)
        self.labelContent.text = textContent
        let h = textContent.stringHeightWith(13, width: 230)
        self.labelContent.setHeight(h)
        self.btnMain.setTitle(textBtnMain, forState: UIControlState())
        self.btnMain.setY(self.labelContent.bottom() + 20)
        var w = textBtnSub.stringWidthWith(14, height: 36)
        if SAstrlen(textBtnMain) > SAstrlen(textBtnSub) {
            w = textBtnMain.stringWidthWith(14, height: 36)
        }
        self.btnMain.setWidth(w+60)
        self.btnSub.setWidth(w+60)
        self.btnMain.setX((210-w)/2)
        self.btnSub.setX((210-w)/2)
        self.btnMain.hidden = false
        if self.textBtnSub != "" {
            self.btnSub.setY(self.btnMain.bottom() + 6)
            self.btnSub.setTitle(textBtnSub, forState: UIControlState())
            self.btnSub.hidden = false
        }
        let heightHolder = self.textBtnSub != "" ? h + heightImage + 180 : h + heightImage + 180 - 42
        self.viewHolder.setHeight(heightHolder)
        self.viewHolder.setY((globalHeight - heightHolder)/2)
    }
}