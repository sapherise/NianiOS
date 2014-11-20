//
//  Film.swift
//  Nian iOS
//
//  Created by Sa on 14/11/17.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import Foundation

class FilmCell: UIView {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelDes: UILabel!
    @IBOutlet var btnBuy: UIButton!
    var activity:UIActivityIndicatorView!
    var imageView:UIImageView!
    var hashTag:Int = 0
    override func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
        self.btnBuy.addTarget(self, action: "onBuyClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func onBuyClick(){
        self.btnBuy.enabled = false
        self.btnBuy.setTitle("", forState: UIControlState.Normal)
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.btnBuy.setWidth(30)
            self.btnBuy.setX(120)
        })
        delay(0.5, { () -> () in
            self.activity = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
            self.activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
            self.activity.center = self.btnBuy.center
            self.activity.hidden = false
            self.activity.startAnimating()
            self.addSubview(self.activity)
            var Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            var safeuid = Sa.objectForKey("uid") as String
            var safeshell = Sa.objectForKey("shell") as String
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                var sa = SAPost("id=\(self.hashTag)&&uid=\(safeuid)&&shell=\(safeshell)", "http://nian.so/api/lab_trip.php")
                if sa == "1" {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.imageView = UIImageView(frame: CGRectMake(0, 0, 24, 24))
                        self.imageView.image = UIImage(named: "newOK")
                        self.imageView.contentMode = UIViewContentMode.Center
                        self.imageView.center = self.btnBuy.center
                        self.activity.stopAnimating()
                        self.activity.hidden = true
                        self.addSubview(self.imageView)
                        delay(1.5, { () -> () in
                            UIView.animateWithDuration(0.3, animations: { () -> Void in
                                self.superview!.alpha = 0
                                }, completion: { (complete: Bool) in
                                    self.superview!.hidden = true
                            })
                        })
                    })
                }else if sa == "2" {
                    self.labError("念币不足")
                }else if sa == "3" {
                    self.labError("毕业过啦")
                }
            })
        })
    }
    
    func labError(string:String){
        dispatch_async(dispatch_get_main_queue(), {
            self.activity.stopAnimating()
            self.activity.hidden = true
            self.btnBuy.enabled = true
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.btnBuy.setWidth(70)
                self.btnBuy.setX(100)
                }, completion: { (complete: Bool) in
                    self.btnBuy.setTitle(string, forState: UIControlState.Normal)
            })
        })
    }
}