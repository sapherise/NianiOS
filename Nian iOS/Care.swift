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
        self.navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        self.navView.backgroundColor = UIColor.NavColor()
        self.view.addSubview(self.navView)
        
        self.view.backgroundColor = BGColor
        
        self.picker = UIPickerView(frame: CGRect(x: 0, y: 64, width: globalWidth, height: globalWidth))
        self.picker.dataSource = self
        self.picker.delegate = self
        self.picker.selectRow(19, inComponent: 0, animated: false)
        
        self.view.addSubview(self.picker)
        
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.text = "每日设定"
        titleLabel.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLabel
        
        let rightButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(CareViewController.startPush))
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton];
        
        self.viewBack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
            return 24
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.startTime = row + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pkView = UILabel(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 50))
        pkView.text = "每日 \(row+1) 时"
        pkView.textColor = UIColor.black
        pkView.textAlignment = NSTextAlignment.center
        return pkView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    @objc func startPush(){
        let date = Date()
        
        let comp = (Calendar.current as NSCalendar).components( [NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second] , from: date)
        let hour = comp.hour
        let min = comp.minute
        let sec = comp.second
        if hour! < self.startTime {
            let a = (self.startTime - hour!) * 60 * 60
            self.delayTime = (a - min! * 60 - sec! )
        }else{
            let a = (24 - hour! + self.startTime) * 60 * 60
            self.delayTime = (a - min! * 60 - sec! )
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
        thepush("记得更新念。\(Greetings)", dateSinceNow: TimeInterval(delayTime), willReapt: true, id: "dailyPush")
        Cookies.set("on" as AnyObject?, forKey: "pushMode")
        _ = self.navigationController?.popViewController(animated: true)
    }
}


// content: 推送内容
// dataSinceNow: 几秒后开始推送
// repeatInterval: 推送周期
// id: 推送编号
func thepush(_ content: String, dateSinceNow: TimeInterval, willReapt: Bool, id: String) {
    let date = Date(timeIntervalSinceNow: dateSinceNow)
    let noti = UILocalNotification()
    noti.fireDate = date
    noti.timeZone = TimeZone.current
    if willReapt {
        noti.repeatInterval = NSCalendar.Unit.day
    }
    noti.alertBody = content
    noti.userInfo = ["id": id]
    
    if #available(iOS 8.0, *) {
        let _local = UIUserNotificationSettings(types: UIUserNotificationType.alert, categories: nil)
        UIApplication.shared.registerUserNotificationSettings(_local)
    } else {
        // Fallback on earlier versions
    }
    UIApplication.shared.scheduleLocalNotification(noti)
}

func cancelPush(_ id: String) {
    if let notis = UIApplication.shared.scheduledLocalNotifications {
        for noti in notis {
            if let dict = noti.userInfo!["id"] {
                if "\(dict)" == id {
                    UIApplication.shared.cancelLocalNotification(noti)
                }
            }
        }
    }
}
