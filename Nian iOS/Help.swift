//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class HelpViewController: UIViewController {
    var navView:UIView!
    
    func setupViews(){
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.navView)
        self.view.backgroundColor = BGColor
        
        let titlestring1 = "一、念是什么！"
        let contentstring1 = "虽然说念是一个记录记本的应用，可是人们却在上面写日记、写博客、当豆瓣用、当歌单用。让人很是困扰。\n这个应用唯一的亮点，就是一天不更新就会被停号。"
        
        let titlestring2 = "二、怎么会有这么可怕的应用！什么情况下会被停号？"
        let contentstring2 = "如果你有一天没有更新进展，就会被停用账号。以下的情况下，你是不会被停用账号的：\n1、有三个记本，却只更新了其中一个，不会被停号；\n2、更新了进展却又删除了，也不会被停号。\n3、所有的记本里没有在进行的，没有进展/ 已经完成的两个类型的记本，不更新也不要紧。"
        
        let titlestring3 = "三、我被停号了，心都碎了！"
        let contentstring3 = "这时候你会面临三种选择：\n1、删除记本。如果你只有一个记本并且开始没多久，你可以删除这个记本，来继续使用念的服务。如果你有很多个记本，你只能仿佛做了一场噩梦一般，删除所有进行中的记本。\n2、支付5念币。如果你在意记本，你可以支付5念币来回购记本。相信在更新进展的时候已经使你有足够的念币了！\n3、退出账号。你可以停用这个账号，重新注册一个全新的小号。\n4、求助管理员。请到新浪微博 @念的官微 来求助管理员。"
        
        let titlestring4 = "四、念币是什么？我可以兑换成人民币吗？"
        let contentstring4 = "念币是在念上所使用的货币。每天的第一次更新，你会获得1念币。你也可以前往广场的念铺购买更多念币。\n念币不能换成人民币，以后会很有用途的——也有可能管理员只是在哄你开心……"
        
        let titlestring5 = "五、有网页版吗？"
        let contentstring5 = "网页版的功能比应用更加全面，试试登录 http://nian.so"
        
        let titlestring6 = "六、我超爱管理员的，怎么请他喝杯咖啡？"
        let contentstring6 = "管理员不爱喝咖啡。"
        
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        scrollView.contentSize = CGSizeMake(globalWidth, 1050)
        
        let title1 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        title1.text = titlestring1
        title1.numberOfLines = 0
        title1.font = UIFont.systemFontOfSize(14)
        title1.textColor = UIColor.HighlightColor()
        title1.setHeight(titlestring1.stringHeightWith(14, width: globalWidth - 80))
        
        let content1 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        content1.text = contentstring1
        content1.numberOfLines = 0
        content1.font = UIFont.systemFontOfSize(14)
        content1.textColor = UIColor.blackColor()
        content1.setHeight(contentstring1.stringHeightWith(14, width: globalWidth - 80))
        content1.setY(title1.bottom()+10)
        
        let title2 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        title2.text = titlestring2
        title2.numberOfLines = 0
        title2.font = UIFont.systemFontOfSize(14)
        title2.textColor = UIColor.HighlightColor()
        title2.setHeight(titlestring2.stringHeightWith(14, width: globalWidth - 80))
        title2.setY(content1.bottom()+20)
        
        let content2 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        content2.text = contentstring2
        content2.numberOfLines = 0
        content2.font = UIFont.systemFontOfSize(14)
        content2.textColor = UIColor.blackColor()
        content2.setHeight(contentstring2.stringHeightWith(14, width: globalWidth - 80))
        content2.setY(title2.bottom()+10)
        
        let title3 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        title3.text = titlestring3
        title3.numberOfLines = 0
        title3.font = UIFont.systemFontOfSize(14)
        title3.textColor = UIColor.HighlightColor()
        title3.setHeight(titlestring3.stringHeightWith(14, width: globalWidth - 80))
        title3.setY(content2.bottom()+20)
        
        let content3 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        content3.text = contentstring3
        content3.numberOfLines = 0
        content3.font = UIFont.systemFontOfSize(14)
        content3.textColor = UIColor.blackColor()
        content3.setHeight(contentstring3.stringHeightWith(14, width: globalWidth - 80))
        content3.setY(title3.bottom()+10)
        
        let title4 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        title4.text = titlestring4
        title4.numberOfLines = 0
        title4.font = UIFont.systemFontOfSize(14)
        title4.textColor = UIColor.HighlightColor()
        title4.setHeight(titlestring4.stringHeightWith(14, width: globalWidth - 80))
        title4.setY(content3.bottom()+20)
        
        let content4 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        content4.text = contentstring4
        content4.numberOfLines = 0
        content4.font = UIFont.systemFontOfSize(14)
        content4.textColor = UIColor.blackColor()
        content4.setHeight(contentstring4.stringHeightWith(14, width: globalWidth - 80))
        content4.setY(title4.bottom()+10)
        
        let title5 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        title5.text = titlestring5
        title5.numberOfLines = 0
        title5.font = UIFont.systemFontOfSize(14)
        title5.textColor = UIColor.HighlightColor()
        title5.setHeight(titlestring5.stringHeightWith(14, width: globalWidth - 80))
        title5.setY(content4.bottom()+20)
        
        let content5 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        content5.text = contentstring5
        content5.numberOfLines = 0
        content5.font = UIFont.systemFontOfSize(14)
        content5.textColor = UIColor.blackColor()
        content5.setHeight(contentstring5.stringHeightWith(14, width: globalWidth - 80))
        content5.setY(title5.bottom()+10)
        
        let title6 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        title6.text = titlestring6
        title6.numberOfLines = 0
        title6.font = UIFont.systemFontOfSize(14)
        title6.textColor = UIColor.HighlightColor()
        title6.setHeight(titlestring6.stringHeightWith(14, width: globalWidth - 80))
        title6.setY(content5.bottom()+20)
        
        let content6 = UILabel(frame: CGRectMake(40, 40, globalWidth - 80, 0))
        content6.text = contentstring6
        content6.numberOfLines = 0
        content6.font = UIFont.systemFontOfSize(14)
        content6.textColor = UIColor.blackColor()
        content6.setHeight(contentstring6.stringHeightWith(14, width: globalWidth - 80))
        content6.setY(title6.bottom()+10)
        
        scrollView.addSubview(title1)
        scrollView.addSubview(content1)
        scrollView.addSubview(title2)
        scrollView.addSubview(content2)
        scrollView.addSubview(title3)
        scrollView.addSubview(content3)
        scrollView.addSubview(title4)
        scrollView.addSubview(content4)
        scrollView.addSubview(title5)
        scrollView.addSubview(content5)
        scrollView.addSubview(title6)
        scrollView.addSubview(content6)
        
        self.view.addSubview(scrollView)
        
        
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "攻略"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}
