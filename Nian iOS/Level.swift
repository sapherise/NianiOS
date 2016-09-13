//
//  Level.swift
//  Nian iOS
//
//  Created by Sa on 15/7/26.
//  Copyright (c) 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class LevelView: UIView {
    @IBOutlet var viewCalendar: UIView!
    @IBOutlet var viewTop: UIView!
    @IBOutlet var menuLeft: UILabel!
    @IBOutlet var menuMiddle: UILabel!
    @IBOutlet var menuRight: UILabel!
    @IBOutlet var labelMonthLeft: UILabel!
    @IBOutlet var labelMonthRight: UILabel!
    @IBOutlet var viewTopHolder: UIView!
    @IBOutlet var labelCalendar: UILabel!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var viewBottomHolder: UIView!
    
    var marks: [Bool] = [Bool](repeating: false, count: 32)
    var textLeft: Int = 0
    var textRight: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewTop.setWidth(globalWidth)
        self.viewCalendar.setX(globalWidth/2-160)
        self.labelCalendar.setX(globalWidth/2-145)
        self.viewTop.setWidth(globalWidth)
        self.viewTopHolder.setX(globalWidth/2-160)
        self.viewBottom.setWidth(globalWidth)
        self.viewBottomHolder.setX(globalWidth/2-160)
    }
    
    func setup() {
        if let uid = Int(SAUid()) {
            Api.getUserTop(uid) { json in
                if json != nil {
                    if let data = json!.object(forKey: "data") {
                        if let user = data.object(forKey: "user") as? NSDictionary {
                            let likes = user.stringAttributeForKey("likes")
                            let steps = user.stringAttributeForKey("step")
                            let followed = user.stringAttributeForKey("followed")
                            self.menuLeft.text = likes
                            self.menuMiddle.text = steps
                            self.menuRight.text = followed
                        }
                    }
                }
            }
        }
        
        Api.getLevelCalendar(){ json in
            if json != nil {
                self.marks = [Bool](repeating: false, count: 32)
                let items = json!.object(forKey: "items") as! NSArray
                for item in items {
                    let lastdate = ((item as AnyObject).object(forKey: "lastdate") as! NSString).doubleValue
                    let date = V.getDay(lastdate)
                    self.marks[Int(date)!] = true
                }
                self.layoutAMonth(self.marks)
                self.labelMonthLeft.text = "\(self.textLeft)"
                self.labelMonthRight.text = "\(self.textRight)"
            }
        }
    }
    
    func layoutAMonth(_ marks: [Bool]) {
        let calendar = Calendar.current
        let comoponents = (calendar as NSCalendar).components([NSCalendar.Unit.NSYearCalendarUnit, NSCalendar.Unit.NSMonthCalendarUnit], from: Date())
        let year = comoponents.year
        let month = comoponents.month
        
        let dffd = DateFormatter()
        dffd.dateFormat = "MM/dd/yyyy"
        let firstDay :Date = dffd.date(from: "\(month)/01/\(year)")!
        
        let dfmn = DateFormatter()
        dfmn.dateFormat = "MM"
        let strMonthNum = dfmn.string(from: firstDay)
        
        let dfm = DateFormatter()
        dfm.dateFormat = "MMMM"
        
        let df = DateFormatter()
        df.dateFormat = "e"
        let theDayOfWeekForFirst :NSString! = df.string(from: firstDay) as NSString!
        
        let i: Int = theDayOfWeekForFirst.integerValue
        var theDayOfWeek :CGFloat! = CGFloat(i)
        var thePosY :CGFloat! = 40
        
        let todayD = DateFormatter()
        todayD.dateFormat = "d"
        let todayDInt = Int(todayD.string(from: Date()))!
        
        let numDaysInMonth = 31
        
        for index in 1 ... numDaysInMonth {
            
            var thePosX = (40 * (theDayOfWeek - 1)) + 15 + 12
            // -1 because you want the first to be 0
            
            let strAll = "\(strMonthNum)/\(index)/\(year)"
            
            let todayF = DateFormatter()
            todayF.dateFormat = "MM/d/yyyy"
            let firstDay = todayF.string(from: Date())
            let cF = DateFormatter()
            cF.dateFormat = "MM/dd/yyyy"
                //make a button
                let myB = UILabel()
                myB.text = "\(index)"
                myB.textAlignment = NSTextAlignment.center
                myB.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
                myB.font = UIFont(name: "Verdana", size: 11)
                myB.frame = CGRect(x: thePosX, y: thePosY, width: 24, height: 24)
                if marks[index] {
                    myB.textColor = UIColor.HighlightColor()
                    if index <= todayDInt {
                        self.textLeft = self.textLeft + 1
                        self.textRight = self.textRight + 1
                    }
                }else{
                    myB.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
                    if index < todayDInt {
                        self.textLeft = 0
                    }
                }
                
                if (strAll == firstDay) {
                    myB.backgroundColor = UIColor.HighlightColor()
                    myB.textColor = UIColor.white
                    myB.layer.cornerRadius = 3
                    myB.layer.masksToBounds = true
                }
                self.viewCalendar.addSubview(myB)
                
                theDayOfWeek = theDayOfWeek + 1
                
                if (theDayOfWeek == 8 ) {
                    theDayOfWeek = 1
                    thePosX = 15
                    thePosY = thePosY + 29
                }
        }
    }
}
