//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class WebViewController: UIViewController, UIWebViewDelegate{
    var urlString = ""
    var webTitle = ""
    var actionSheet: UIActionSheet?
    
    func setupViews(_ string: String, title: String){
        self.view.backgroundColor = BGColor
        
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(navView)
        
        let btnMore = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(WebViewController.setupNavBtn))
        btnMore.image = UIImage(named: "more")
        self.navigationItem.rightBarButtonItems = [btnMore]
        
        let web = UIWebView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalHeight - 64))
        web.delegate = self
        web.isUserInteractionEnabled = true
        self.view.addSubview(web)
        
        let url = URL(string: string)
        if url != nil {
            let request = URLRequest(url: url!)
            web.loadRequest(request)
        } else {
            self.showTipText("网址错误")
        }
        
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.text = webTitle
        titleLabel.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews(urlString, title: webTitle)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return true
    }
    
    func setupNavBtn() {
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil, otherButtonTitles: "在 Safari 中打开")
        
        self.actionSheet!.show(in: self.view)
    }
    
}

extension WebViewController: UIActionSheetDelegate {
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            UIApplication.shared.openURL(URL(string: urlString)!)
        }
    }
}
