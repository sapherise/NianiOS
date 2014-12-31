//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class WebViewController: UIViewController, UIGestureRecognizerDelegate, UIWebViewDelegate{
    
    func setupViews(){
        self.view.backgroundColor = BGColor
        
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        var web = UIWebView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        web.delegate = self
        web.userInteractionEnabled = true
        self.view.addSubview(web)
        
        let url = NSURL(string: "http://nian.so/privacy.php")
        let request = NSURLRequest(URL: url!)
        web.loadRequest(request)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "隐私政策"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
}
