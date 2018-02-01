//
//  CoinProductCell.swift
//  Nian iOS
//
//  Created by Sa on 16/2/24.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class CoinProductCell: UITableViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelContent: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var imageArrow: UIImageView!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    
    /* 得知这个 cell 是在 indexPath 中的第几个 */
    var num = -1
    var numMax = 0
    
    let padding: CGFloat = 16
    let heightCell: CGFloat = 72
    
    func setup() {
        self.selectionStyle = .none
        self.setWidth(globalWidth)
        viewLine.setHeight(globalHalf)
        viewLine.setY(heightCell - globalHalf - globalHalf/2)
        viewLine.backgroundColor = UIColor.LineColor()
        viewLine.setWidth(globalWidth - padding * 2)
        imageArrow.setX(globalWidth - padding - imageArrow.width() - 8)
        
        let image = data.stringAttributeForKey("image")
        let title = data.stringAttributeForKey("title")
        let content = data.stringAttributeForKey("content")
        imageHead.image = UIImage(named: image)
        labelTitle.text = title
        labelContent.text = content
        
        labelTitle.textColor = UIColor.MainColor()
        labelContent.textColor = UIColor.secAuxiliaryColor()
        
        if num == 0 {
            let v = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHalf))
            v.backgroundColor = UIColor.LineColor()
            v.setY(globalHalf/2)
            self.contentView.addSubview(v)
        } else if num == numMax - 1 {
            viewLine.setX(0)
            viewLine.setWidth(globalWidth)
        }
    }
}
