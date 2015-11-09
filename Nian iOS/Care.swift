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
        thepush("记得更新念。\(Greetings)", dateSinceNow: NSTimeInterval(delayTime), willReapt: true, id: "dailyPush")
        Cookies.set("on", forKey: "pushMode")
        self.navigationController?.popViewControllerAnimated(true)
    }
}


// content: 推送内容
// dataSinceNow: 几秒后开始推送
// repeatInterval: 推送周期
// id: 推送编号
func thepush(content: String, dateSinceNow: NSTimeInterval, willReapt: Bool, id: String) {
    let date = NSDate(timeIntervalSinceNow: dateSinceNow)
    let noti = UILocalNotification()
    noti.fireDate = date
    noti.timeZone = NSTimeZone.defaultTimeZone()
    if willReapt {
        noti.repeatInterval = NSCalendarUnit.Day
    }
    noti.alertBody = content
    noti.userInfo = ["id": id]
    UIApplication.sharedApplication().scheduleLocalNotification(noti)
}
