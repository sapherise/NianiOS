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
    
    func setupView(imageURL: String, title: String, description: String, cost: String) {
        self.backgroundColor = BGColor
        self.textTitle.text = title
        self.btnBuy.setTitle(cost, forState: UIControlState.Normal)
        self.textDescription.numberOfLines = 0
        self.textDescription.text = description
        self.textDescription.setHeight(CoinCell.getDespHeight(description))
    }
    
    class func getDespHeight(desp: String) -> CGFloat {
        return desp.stringHeightWith(14, width: 130)
    }
}
