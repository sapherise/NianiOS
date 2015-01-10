//
//  YRJokeCell.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class MeCellTop: UITableViewCell, UIGestureRecognizerDelegate{
    @IBOutlet var viewLeft: UIView!
    @IBOutlet var viewMiddle: UIView!
    @IBOutlet var viewRight: UIView!
    @IBOutlet var numLeft: UILabel!
    @IBOutlet var numMiddle: UILabel!
    @IBOutlet var numRight: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        self.viewLeft.tag = 1
        self.viewMiddle.tag = 2
        self.viewRight.tag = 3
        self.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMeTopClick:"))
        self.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMeTopClick:"))
        self.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onMeTopClick:"))
    }
    
    func onMeTopClick(sender:UIGestureRecognizer){
        if let tag = sender.view?.tag {
            var MeNextVC = MeNextViewController()
            MeNextVC.tag = tag
            self.findRootViewController()?.navigationController?.pushViewController(MeNextVC, animated: true)
        }
        if let v = sender.view {
            var views:NSArray = v.subviews
            for view:AnyObject in views {
                if NSStringFromClass(view.classForCoder) == "UILabel"  {
                    var l = view as UILabel
                    if l.frame.origin.y == 25 {
                        l.text = "0"
                        l.textColor = UIColor.blackColor()
                    }
                }
            }
        }
        
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
    }
}
