//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class CareViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate{
    
    var picker:UIPickerView!
    var startTime:Int = 20
    var delayTime:Int = 0
    var Greetings:String = ""
    var navView:UIView!
    
    func setupViews(){
        self.navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        self.navView.backgroundColor = BarColor
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = BGColor
        
        self.picker = UIPickerView(frame: CGRectMake(0, 64, globalWidth, globalWidth))
        self.picker.dataSource = self
        self.picker.delegate = self
        self.picker.selectRow(19, inComponent: 0, animated: false)
        
        self.view.addSubview(self.picker)
        
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "每日设定"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "startPush")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        self.viewBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
            return 24
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.startTime = row + 1
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let pkView = UILabel(frame: CGRectMake(0, 0, globalWidth, 50))
        pkView.text = "每日 \(row+1) 时"
        pkView.textColor = UIColor.blackColor()
        pkView.textAlignment = NSTextAlignment.Center
        return pkView
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func startPush(){
        let date = NSDate()
        let comp = NSCalendar.currentCalendar().components( [NSCalendarUnit.NSHourCalendarUnit, NSCalendarUnit.NSMinuteCalendarUnit, NSCalendarUnit.NSSecondCalendarUnit] , fromDate: date)
        let hour = comp.hour
        let min = comp.minute
        let sec = comp.second
        if hour < self.startTime {
            self.delayTime = (( self.startTime - hour ) * 60 * 60 - min * 60 - sec )
        }else{
            self.delayTime = (( 24 - hour + self.startTime ) * 60 * 60 - min * 60 - sec )
        }
        
        if self.startTime < 1 {
            self.Greetings = "晚安。"
        }else if self.startTime < 3 {
            self.Greetings = "早点休息。"
        }else if self.startTime < 11 {
            self.Greetings = "早安。"
        }else if self.startTime < 13 {
            self.Greetings = "中午好。"
        }else if self.startTime < 18 {
            self.Greetings = "下午好。"
        }else if self.startTime < 24 {
            self.Greetings = "晚安。"
        }
        
        let notification = UILocalNotification()
        let pushDate = date.dateByAddingTimeInterval(Double(self.delayTime))
        notification.fireDate = pushDate
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.soundName = UILocalNotificationDefaultSoundName
//        var alertBodys = ["有句话我怕说出来我们就做不了朋友了，可是，你今天更新念了嘛？", "\(self.startTime) 点了！更新时间到！", "你收到这条消息，是因为在过去你设置了每日提醒。啊，过去的你是多么的冰雪聪明。", "打赌你今天还没更念，谁赢谁今天就不用更，怎样！", "要是忘了更新念，小心我请你喝咖啡啦！", "过去的你深情款款地对你说：「更吗？」", "每天都不忘了提醒你更新念，真羡慕你有这样尽责的朋友。", "现在是 \(self.startTime) 点整。我是今天第一个跟你说话的人吗？", "又到了每天一次的骚扰环节了。真担心我这样每天提醒你更新，你会不小心爱上我。千万别爱我啦。", "再不更念就阵亡啦。"]
//        _ = arc4random() % 10
        notification.alertBody = "记得更新念。\(self.Greetings)"
        let Sa:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        Sa.setObject("1", forKey:"pushMode")
        Sa.synchronize()
        notification.repeatInterval = NSCalendarUnit.Day
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
