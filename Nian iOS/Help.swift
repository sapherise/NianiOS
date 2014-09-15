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
        var contentstring1 = "虽然说念是一个记录梦想的应用，可是人们却在上面写日记、写博客、当豆瓣用、当歌单用。让人很是困扰。\n这个应用唯一的亮点，就是一天不更新就会被停号。"
        
        var titlestring2 = "二、怎么会有这么可怕的应用！什么情况下会被停号？"
        var contentstring2 = "如果你有一天没有更新进展，就会被停用账号。以下的情况下，你是不会被停用账号的：\n1、有三个梦想，却只更新了其中一个，不会被停号；\n2、更新了进展却又删除了，也不会被停号。\n3、所有的梦想里没有在进行的，没有进展/ 已经完成的两个类型的梦想，不更新也不要紧。"
        
        var titlestring3 = "三、我被停号了，心都碎了！"
        var contentstring3 = "这时候你会面临三种选择：\n1、删除梦想。如果你只有一个梦想并且开始没多久，你可以删除这个梦想，来继续使用念的服务。如果你有很多个梦想，你只能仿佛做了一场噩梦一般，删除所有进行中的梦想。\n2、支付5念币。如果你在意梦想，你可以支付5念币来回购梦想。相信在更新进展的时候已经使你有足够的念币了！\n3、退出账号。你可以停用这个账号，重新注册一个全新的小号。\n4、求助管理员。请到新浪微博 @念官方微博 来求助管理员。"
        
        var titlestring4 = "四、念币是什么？我可以兑换成人民币吗？"
        var contentstring4 = "念币是在念上所使用的货币。每天的第一次更新，你会获得1念币。你也可以前往广场的念铺购买更多念币。\n念币不能换成人民币，以后会很有用途的——也有可能管理员只是在哄你开心……"
        
        var titlestring5 = "五、有网页版吗？"
        var contentstring5 = "网页版的功能比应用更加全面，试试登录 http://nian.so ！"
        
        var titlestring6 = "六、我超爱管理员的，怎么请他喝杯咖啡？"
        var contentstring6 = "管理员不爱喝咖啡。"
        
        
        var scrollView = UIScrollView(frame: CGRectMake(0, 0, 320, height - 64))
        scrollView.contentSize = CGSizeMake(320, 1200)
        
        var title1 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        title1.text = titlestring1
        title1.numberOfLines = 0
        title1.font = UIFont.systemFontOfSize(14)
        title1.textColor = BlueColor
        title1.setHeight(titlestring1.stringHeightWith(14, width: 240))
        
        var content1 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        content1.text = contentstring1
        content1.numberOfLines = 0
        content1.font = UIFont.systemFontOfSize(14)
        content1.textColor = IconColor
        content1.setHeight(contentstring1.stringHeightWith(14, width: 240))
        content1.setY(title1.bottom()+10)
        
        var title2 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        title2.text = titlestring2
        title2.numberOfLines = 0
        title2.font = UIFont.systemFontOfSize(14)
        title2.textColor = BlueColor
        title2.setHeight(titlestring2.stringHeightWith(14, width: 240))
        title2.setY(content1.bottom()+20)
        
        var content2 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        content2.text = contentstring2
        content2.numberOfLines = 0
        content2.font = UIFont.systemFontOfSize(14)
        content2.textColor = IconColor
        content2.setHeight(contentstring2.stringHeightWith(14, width: 240))
        content2.setY(title2.bottom()+10)
        
        var title3 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        title3.text = titlestring3
        title3.numberOfLines = 0
        title3.font = UIFont.systemFontOfSize(14)
        title3.textColor = BlueColor
        title3.setHeight(titlestring3.stringHeightWith(14, width: 240))
        title3.setY(content2.bottom()+20)
        
        var content3 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        content3.text = contentstring3
        content3.numberOfLines = 0
        content3.font = UIFont.systemFontOfSize(14)
        content3.textColor = IconColor
        content3.setHeight(contentstring3.stringHeightWith(14, width: 240))
        content3.setY(title3.bottom()+10)
        
        var title4 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        title4.text = titlestring4
        title4.numberOfLines = 0
        title4.font = UIFont.systemFontOfSize(14)
        title4.textColor = BlueColor
        title4.setHeight(titlestring4.stringHeightWith(14, width: 240))
        title4.setY(content3.bottom()+20)
        
        var content4 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        content4.text = contentstring4
        content4.numberOfLines = 0
        content4.font = UIFont.systemFontOfSize(14)
        content4.textColor = IconColor
        content4.setHeight(contentstring4.stringHeightWith(14, width: 240))
        content4.setY(title4.bottom()+10)
        
        var title5 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        title5.text = titlestring5
        title5.numberOfLines = 0
        title5.font = UIFont.systemFontOfSize(14)
        title5.textColor = BlueColor
        title5.setHeight(titlestring5.stringHeightWith(14, width: 240))
        title5.setY(content4.bottom()+20)
        
        var content5 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        content5.text = contentstring5
        content5.numberOfLines = 0
        content5.font = UIFont.systemFontOfSize(14)
        content5.textColor = IconColor
        content5.setHeight(contentstring5.stringHeightWith(14, width: 240))
        content5.setY(title5.bottom()+10)
        
        var title6 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        title6.text = titlestring6
        title6.numberOfLines = 0
        title6.font = UIFont.systemFontOfSize(14)
        title6.textColor = BlueColor
        title6.setHeight(titlestring6.stringHeightWith(14, width: 240))
        title6.setY(content5.bottom()+20)
        
        var content6 = UILabel(frame: CGRectMake(40, 40, 240, 0))
        content6.text = contentstring6
        content6.numberOfLines = 0
        content6.font = UIFont.systemFontOfSize(14)
        content6.textColor = IconColor
        content6.setHeight(contentstring6.stringHeightWith(14, width: 240))
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
        
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "攻略"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        var swipe = UISwipeGestureRecognizer(target: self, action: "back")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipe)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
