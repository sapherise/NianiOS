//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class WebViewController: UIViewController, UIGestureRecognizerDelegate, UIWebViewDelegate{
    var urlString = ""
    var webTitle = ""
    var actionSheet: UIActionSheet?
    
    func setupViews(string: String, title: String){
        self.view.backgroundColor = BGColor
        
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        var btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "setupNavBtn")
        btnMore.image = UIImage(named: "more")
        self.navigationItem.rightBarButtonItems = [btnMore]
        
        var web = UIWebView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        web.delegate = self
        web.userInteractionEnabled = true
        self.view.addSubview(web)
        
        let url = NSURL(string: string)
        if url != nil {
            let request = NSURLRequest(URL: url!)
            web.loadRequest(request)
        } else {
            self.view.showTipText("网址错误", delay: 2)
        }
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = webTitle
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        
        viewLoadingShow()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews(urlString, title: webTitle)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        viewLoadingHide()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.viewLoadingHide()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func setupNavBtn() {
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "在 Safari 中打开")
        
        self.actionSheet!.showInView(self.view)
    }
    
}

extension WebViewController: UIActionSheetDelegate {
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            UIApplication.sharedApplication().openURL(NSURL(string: urlString)!)
        }
    }
}
