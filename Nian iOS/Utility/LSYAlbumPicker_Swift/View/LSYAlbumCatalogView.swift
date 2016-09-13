//
//  LSYAlbumCatalogView.swift
//  AlbumPicker
//
//  Created by okwei on 15/8/5.
//  Copyright (c) 2015年 okwei. All rights reserved.
//

import Foundation
import UIKit
import AssetsLibrary

class LSYAlbumCatalogCell: UITableViewCell {
    var group:ALAssetsGroup!{
        didSet{
            self.imageView?.image = UIImage(cgImage: group.posterImage().takeUnretainedValue())
            self.setupGroupTitle()
        }
    }
    fileprivate func setupGroupTitle(){
        let numberOfAssetsAttribute:Dictionary! = [NSForegroundColorAttributeName:UIColor.gray,NSFontAttributeName:UIFont.systemFont(ofSize: 17)]
        let groupTitle:String! = self.group.value(forProperty: ALAssetsGroupPropertyName) as? String
        let numberOfAssets:Int = self.group.numberOfAssets()
        let attributedString :NSMutableAttributedString! = NSMutableAttributedString(string: "\(groupTitle)（\(numberOfAssets)）", attributes: numberOfAssetsAttribute)
        self.textLabel?.attributedText = attributedString
        
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
}
