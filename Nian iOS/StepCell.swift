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
    var data1 :NSDictionary!
    var data2 :NSDictionary!
    var data3 :NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        var tap = UITapGestureRecognizer(target: self, action: "imageViewTapped:")
    }
    
    override func layoutSubviews()
    {
        
        
        super.layoutSubviews()
        var id1 = self.data1.stringAttributeForKey("id")
        var title1 = self.data1.stringAttributeForKey("title")
        var img1 = self.data1.stringAttributeForKey("img")
        var id2 = self.data2.stringAttributeForKey("id")
        var title2 = self.data2.stringAttributeForKey("title")
        var img2 = self.data2.stringAttributeForKey("img")
        var id3 = self.data3.stringAttributeForKey("id")
        var title3 = self.data3.stringAttributeForKey("title")
        var img3 = self.data3.stringAttributeForKey("img")
        
        
        if(id1 != ""){
            self.title1!.text = title1
            self.title1!.textColor = BlueColor
            self.img1!.setImage("http://img.nian.so/dream/\(img1)!ios",placeHolder: UIImage(named: "1.jpg"))
            self.img1?.userInteractionEnabled = true
            self.img1?.tag = id1.toInt()!
            self.img1!.userInteractionEnabled = true
        }else{
            self.title1?.hidden = true
            self.img1?.hidden = true
            self.img1?.tag = 1
        }
        
        if(id2 != ""){
            self.title2!.text = title2
            self.title2!.textColor = BlueColor
            self.img2!.setImage("http://img.nian.so/dream/\(img2)!ios",placeHolder: UIImage(named: "1.jpg"))
            self.img2?.userInteractionEnabled = true
            self.img2?.tag = id2.toInt()!
            self.img2!.userInteractionEnabled = true
        }else{
            self.title2?.hidden = true
            self.img2?.hidden = true
            self.img2?.tag = 1
        }
        
        if(id3 != ""){
            self.title3!.text = title3
            self.title3!.textColor = BlueColor
            self.img3!.setImage("http://img.nian.so/dream/\(img3)!ios",placeHolder: UIImage(named: "1.jpg"))
            self.img3?.userInteractionEnabled = true
            self.img3?.tag = id3.toInt()!
            self.img3!.userInteractionEnabled = true
        }else{
            self.title3?.hidden = true
            self.img3?.hidden = true
            self.img3?.tag = 1
        }
        
        self.img1!.layer.cornerRadius = 4;
        self.img2!.layer.cornerRadius = 4;
        self.img3!.layer.cornerRadius = 4;
        self.img1!.layer.masksToBounds = true;
        self.img2!.layer.masksToBounds = true;
        self.img3!.layer.masksToBounds = true;
        
        self.View!.backgroundColor = BGColor
        
    }
}
