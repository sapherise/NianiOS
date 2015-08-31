//
//  CoinCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/4.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

class CoinCell : UITableViewCell {
    
    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet var textTitle: UILabel!
    @IBOutlet var textDescription: UILabel!
    @IBOutlet var btnBuy: UIButton!
    @IBOutlet var viewLine: UIView!
    @IBOutlet var labelImage: UILabel!
    
    override func awakeFromNib() {
        self.btnBuy.setX(globalWidth-85)
        self.btnBuy.backgroundColor = SeaColor
        self.viewLine.setWidth(globalWidth-85)
    }
    
    func setupView(imageURL: String, title: String, description: String, cost: String, sectionNumber: Int) {
        self.imageIcon.layer.cornerRadius = 20
        self.imageIcon.layer.masksToBounds = true
        self.textTitle.text = title
        self.btnBuy.setTitle(cost, forState: UIControlState.Normal)
        self.textDescription.numberOfLines = 0
        self.textDescription.text = description
        self.imageIcon.layer.borderColor = SeaColor.CGColor
        self.imageIcon.layer.borderWidth = 1
        if sectionNumber == 0 {
            self.textDescription.hidden = true
            self.viewLine.setY(80)
            self.textTitle.setY(30)
            self.labelImage.text = imageURL
            self.labelImage.textColor = SeaColor
        }else{
            self.textDescription.setHeight(CoinCell.getDespHeight(description))
            self.textDescription.hidden = false
            self.viewLine.setY(self.textDescription.bottom()+20)
            self.imageIcon.image = UIImage(named: imageURL)
            self.imageIcon.contentMode = UIViewContentMode.Center
        }
    }
    
    class func getDespHeight(desp: String) -> CGFloat {
        return desp.stringHeightWith(13, width: 155)
    }
}
