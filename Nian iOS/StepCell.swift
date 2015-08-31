//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class StepCell: UITableViewCell {
    
    @IBOutlet var img1:UIImageView?
    @IBOutlet var img2:UIImageView?
    @IBOutlet var img3:UIImageView?
    @IBOutlet var title1:UILabel?
    @IBOutlet var title2:UILabel?
    @IBOutlet var title3:UILabel?
    @IBOutlet var View:UIView?
    @IBOutlet var viewHolder: UIView!
    var data1 :NSDictionary!
    var data2 :NSDictionary!
    var data3 :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.title1?.hidden = true
        self.img1?.hidden = true
        self.title2?.hidden = true
        self.img2?.hidden = true
        self.title3?.hidden = true
        self.img3?.hidden = true
        self.img1!.layer.cornerRadius = 4
        self.img2!.layer.cornerRadius = 4
        self.img3!.layer.cornerRadius = 4
        self.img1!.layer.masksToBounds = true
        self.img2!.layer.masksToBounds = true
        self.img3!.layer.masksToBounds = true
        self.View!.backgroundColor = BGColor
        self.viewHolder.setX(globalWidth/2 - 160)
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        let id1 = self.data1.stringAttributeForKey("id")
        let title1 = self.data1.stringAttributeForKey("title")
        let img1 = self.data1.stringAttributeForKey("img")
        let id2 = self.data2.stringAttributeForKey("id")
        let title2 = self.data2.stringAttributeForKey("title")
        let img2 = self.data2.stringAttributeForKey("img")
        let id3 = self.data3.stringAttributeForKey("id")
        let title3 = self.data3.stringAttributeForKey("title")
        let img3 = self.data3.stringAttributeForKey("img")
        
        
        if(id1 != ""){
            self.title1!.text = title1
            self.img1!.setImage("http://img.nian.so/dream/\(img1)!ios",placeHolder: IconColor)
            self.img1?.tag = Int(id1)!
            self.title1?.hidden = false
            self.img1?.hidden = false
        }else{
            self.img1?.tag = 1
        }
        
        if(id2 != ""){
            self.title2!.text = title2
            self.img2!.setImage("http://img.nian.so/dream/\(img2)!ios",placeHolder: IconColor)
            self.img2?.tag = Int(id2)!
            self.title2?.hidden = false
            self.img2?.hidden = false
        }else{
            self.img2?.tag = 1
        }
        
        if(id3 != ""){
            self.title3!.text = title3
            self.img3!.setImage("http://img.nian.so/dream/\(img3)!ios",placeHolder: IconColor)
            self.img3?.tag = Int(id3)!
            self.title3?.hidden = false
            self.img3?.hidden = false
        }else{
            self.img3?.tag = 1
        }
        
        
    }
}
