//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class HelpViewController: UIViewController {
    
    func setupViews(){
        var width = self.view.frame.size.width  //宽度
        var height = self.view.frame.size.height   //高度
        self.view.backgroundColor = BGColor
        
        var titlestring1 = "一、念是什么！"
        var contentstring1 = "虽然说念是一个记录梦想的网站，可是人们却在上面写日记、写博客、当豆瓣用、当歌单用。让人很是困扰。\n这个网站唯一的亮点，就是一天不更新就会被停号。"
        
        var titlestring2 = "二、怎么会有这么可怕的网站！什么情况下会被停号？"
        var contentstring2 = "如果你有一天没有更新进展，就会被停用账号。以下的情况下，你是不会被停用账号的：\n1、有三个梦想，却只更新了其中一个，不会被停号；\n2、更新了进展却又删除了，也不会被停号。\n3、所有的梦想里没有在进行的，没有进展/ 已经完成的两个类型的梦想，不更新也不要紧。"
        
        var titlestring3 = "三、我被停号了，心都碎了！"
        var contentstring3 = "这时候你会面临三种选择：\n1、删除梦想。如果你只有一个梦想并且开始没多久，你可以删除这个梦想，来继续使用念的服务。如果你有很多个梦想，你只能仿佛做了一场噩梦一般，删除所有进行中的梦想。\n2、支付5念币。如果你在意梦想，你可以支付5念币来回购梦想。相信在更新进展的时候已经使你有足够的念币了！\n3、退出账号。你可以停用这个账号，重新注册一个全新的小号。\n4、求助管理员。请到新浪微博@念官方微博来求助管理员。"
        
        var titlestring4 = "四、念币是什么？我可以兑换成人民币吗？"
        var contentstring4 = "念币是在念上所使用的货币。每天的第一次更新，你会获得1念币。你也可以前往广场的念铺购买更多念币。\n念币不能换成人民币，以后会很有用途的——也有可能管理员只是在哄你开心……"
        
        var titlestring5 = "五、有网页版吗？"
        var contentstring5 = "网页版的功能比应用更加全面，你可以登录 http://nian.so 来玩念。"
        
        var titlestring6 = "六、我超爱管理员的，怎么请他喝杯咖啡？"
        var contentstring6 = "管理员不爱喝咖啡。"
        
        
        var scrollView = UIScrollView(frame: CGRectMake(20, 20, 280, 484))
        scrollView.contentSize = CGSizeMake(280, 1100)
        scrollView.backgroundColor = BlueColor
        
        var title1 = UILabel(frame: CGRectMake(0, 0, 280, 0))
        title1.text = titlestring1
        title1.setHeight(titlestring1.stringHeightWith(17, width: 280))
        
        scrollView.addSubview(title1)
        
        self.view.addSubview(scrollView)
        
//        var login:UIButton = UIButton(frame: CGRectMake(20, height-48-64-20, 280, 48))
//        login.setTitle("登录", forState: UIControlState.Normal)
//        login.layer.borderColor = LineColor.CGColor
//        login.layer.borderWidth = 1
//        login.addTarget(self, action: "login", forControlEvents: UIControlEvents.TouchUpInside)
//        login.titleLabel!.font = UIFont(name: "system", size: 17)
//        login.setTitleColor(IconColor, forState: UIControlState.Normal)
//        
//        var sign:UIButton = UIButton(frame: CGRectMake(20, height-48-64-20-47, 280, 48))
//        sign.setTitle("注册", forState: UIControlState.Normal)
//        sign.layer.borderColor = LineColor.CGColor
//        sign.layer.borderWidth = 1
//        sign.addTarget(self, action: "sign", forControlEvents: UIControlEvents.TouchUpInside)
//        sign.titleLabel!.font = UIFont(name: "system", size: 17)
//        sign.setTitleColor(IconColor, forState: UIControlState.Normal)
//        
//        self.view.addSubview(login)
//        self.view.addSubview(sign)
//        
//        var des:UILabel = UILabel(frame: CGRectMake(20, 80, width-40, 128))
//        var content:String = "在这个宇宙最残酷\n记梦应用里，\n只有每天坚持\n更新你的梦想，\n才不会被停用账号。"
//        des.font = UIFont.systemFontOfSize(14)
//        des.setHeight(128)
//        des.text = content
//        des.numberOfLines = 0
//        des.textAlignment = NSTextAlignment.Center
//        des.textColor = IconColor
//        self.view.addSubview(des)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
}
