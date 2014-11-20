//
//  NianCell.swift
//  Nian iOS
//
//  Created by Sa on 14/11/18.
//  Copyright (c) 2014年 Sa. All rights reserved.
//


import UIKit

class NianCell: UITableViewCell{
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data :NSDictionary?
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var title:String = data!.objectForKey("title") as String
            var percent:String = data!.objectForKey("percent") as String
            var dreamPrivate:String = data!.objectForKey("private") as String
            self.labelTitle.text = title
            
            var img:String = data!.objectForKey("img") as String
            if img != "" {
                img = "http://img.nian.so/dream/\(img)!dream"
                self.imageCover.setImage(img, placeHolder: IconColor, bool: false)
            }else{
                self.imageCover.image = UIImage(named: "drop")
                self.imageCover.backgroundColor = SeaColor
                self.imageCover.contentMode = UIViewContentMode.Center
            }
        }else{
            self.labelTitle.text = "添加梦想"
            self.imageCover.layer.borderColor = UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1).CGColor
            self.imageCover.layer.borderWidth = 3
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageCover.layer.cornerRadius = 6
        self.imageCover.layer.masksToBounds = true
        self.backgroundColor = UIColor(red:0.05, green:0.05, blue:0.05, alpha:1)
    }
}
