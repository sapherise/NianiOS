//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FindCellTop: UITableViewCell, UIGestureRecognizerDelegate{
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewMiddle: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var imageLeft: UIImageView!
    @IBOutlet var imageMiddle: UIImageView!
    @IBOutlet var imageRight: UIImageView!
    var arr = ["weibo", "phone", "recommend"]
    var arrSelected = ["weibo_s", "phone_s", "recommend_s"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.imageLeft.image = UIImage(named: arrSelected[0])
        self.viewLeft.tag = 1
        self.viewMiddle.tag = 2
        self.viewRight.tag = 3
        self.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
        self.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
        self.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onTopClick:"))
    }
    
    func onTopClick(sender:UIGestureRecognizer){
        self.imageLeft.image = UIImage(named: arr[0])
        self.imageMiddle.image = UIImage(named: arr[1])
        self.imageRight.image = UIImage(named: arr[2])
        var tag = sender.view!.tag
        if tag == 1 {
            self.imageLeft.image = UIImage(named: arrSelected[0])
        }else if tag == 2 {
            self.imageMiddle.image = UIImage(named: arrSelected[1])
        }else if tag == 3 {
            self.imageRight.image = UIImage(named: arrSelected[2])
        }
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
