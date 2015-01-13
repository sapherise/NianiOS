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
    
    var closeable = false
    var transDirectly = true
    
    var activity: UIActivityIndicatorView!
    var imageView: UIImageView!
    var callback: ((FilmCell) -> Void)!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: nil))
        self.btnBuy.addTarget(self, action: "onBuyClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func onBuyClick(){
        if transDirectly {
            self.onStartLoading()
            closeable = false
            self.btnBuy.enabled = false
            self.btnBuy.setTitle("", forState: UIControlState.Normal)
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.btnBuy.setWidth(30)
                self.btnBuy.setX(120)
                }, completion: {
                    finish in
                    self.callback(self)
            });
        }else{
            self.callback(self)
        }
    }
    
    func onStartLoading() {
        self.activity = UIActivityIndicatorView(frame: CGRectMake(0, 0, 20, 20))
        self.activity.transform = CGAffineTransformMakeScale(0.7, 0.7)
        self.activity.center = self.btnBuy.center
        self.activity.hidden = false
        self.activity.startAnimating()
        self.addSubview(self.activity)
    }
    
    func onStopLoading() {
        self.activity.stopAnimating()
        self.activity.hidden = true
    }
    
    func showOK() {
        globalViewFilmExist = false
        self.onStopLoading()
        self.imageView = UIImageView(frame: CGRectMake(0, 0, 24, 24))
        self.imageView.image = UIImage(named: "newOK")
        self.imageView.contentMode = UIViewContentMode.Center
        self.imageView.center = self.btnBuy.center
        self.addSubview(self.imageView)
        delay(1.5, { () -> () in
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                if self.superview != nil {
                    self.superview!.alpha = 0
                }
                }, completion: { finish in
                    if self.superview != nil {
                        self.superview!.removeFromSuperview()
                    }
            })
        })
    }
    
    func showError(string:String) {
        closeable = true
        self.onStopLoading()
        self.btnBuy.enabled = true
        UIView.animateWithDuration(0.5, animations: {
            () -> Void in
            self.btnBuy.setWidth(70)
            self.btnBuy.setX(100)
            }, completion: {
                finish in
                self.btnBuy.setTitle(string, forState: UIControlState.Normal)
        })
    }
}