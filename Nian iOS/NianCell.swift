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
    @IBOutlet var labelStep: UILabel!
    var data :NSDictionary?
    override func layoutSubviews() {
        super.layoutSubviews()
        if data != nil {
            var title:String = data!.objectForKey("title") as String
            var percent:String = data!.objectForKey("percent") as String
            var dreamPrivate:String = data!.objectForKey("private") as String
            var step:String = data!.objectForKey("step") as String
            self.labelTitle.text = title
            self.labelStep.text = "\(step) 进展"
            
            var img:String = data!.objectForKey("img") as String
            if img != "" {
                img = "http://img.nian.so/dream/\(img)!dream"
                self.imageCover.setImage(img, placeHolder: IconColor, bool: false)
            }else{
                self.imageCover.image = UIImage(named: "drop")
                self.imageCover.backgroundColor = SeaColor
                self.imageCover.contentMode = UIViewContentMode.Center
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageCover.layer.cornerRadius = 6
        self.imageCover.layer.masksToBounds = true
        self.imageCover.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).CGColor
        self.imageCover.layer.borderWidth = 0.5
        self.backgroundColor = UIColor.whiteColor()
    }
}
