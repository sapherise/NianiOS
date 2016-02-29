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
    
    var marks: [Bool] = [Bool](count: 32, repeatedValue: false)
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
                    if let data = json!.objectForKey("data") {
                        if let user = data.objectForKey("user") as? NSDictionary {
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
                self.marks = [Bool](count: 32, repeatedValue: false)
                let items = json!.objectForKey("items") as! NSArray
                for item in items {
                    let lastdate = (item.objectForKey("lastdate") as! NSString).doubleValue
                    let date = V.getDay(lastdate)
                    self.marks[Int(date)!] = true
                }
                self.layoutAMonth(self.marks)
                self.labelMonthLeft.text = "\(self.textLeft)"
                self.labelMonthRight.text = "\(self.textRight)"
            }
        }
    }
    
    func layoutAMonth(marks: [Bool]) {
        let calendar = NSCalendar.currentCalendar()
        let comoponents = calendar.components([NSCalendarUnit.NSYearCalendarUnit, NSCalendarUnit.NSMonthCalendarUnit], fromDate: NSDate())
        let year = comoponents.year
        let month = comoponents.month
        
        let dffd = NSDateFormatter()
        dffd.dateFormat = "MM/dd/yyyy"
        let firstDay :NSDate = dffd.dateFromString("\(month)/01/\(year)")!
        
        let dfmn = NSDateFormatter()
        dfmn.dateFormat = "MM"
        let strMonthNum = dfmn.stringFromDate(firstDay)
        
        let dfm = NSDateFormatter()
        dfm.dateFormat = "MMMM"
        
        let df = NSDateFormatter()
        df.dateFormat = "e"
        let theDayOfWeekForFirst :NSString! = df.stringFromDate(firstDay)
        
        let i: Int = theDayOfWeekForFirst.integerValue
        var theDayOfWeek :CGFloat! = CGFloat(i)
        var thePosY :CGFloat! = 40
        
        let todayD = NSDateFormatter()
        todayD.dateFormat = "d"
        let todayDInt = Int(todayD.stringFromDate(NSDate()))!
        
        let numDaysInMonth = 31
        
        for index in 1 ... numDaysInMonth {
            
            var thePosX = (40 * (theDayOfWeek - 1)) + 15 + 12
            // -1 because you want the first to be 0
            
            let strAll = "\(strMonthNum)/\(index)/\(year)"
            
            let todayF = NSDateFormatter()
            todayF.dateFormat = "MM/d/yyyy"
            let firstDay = todayF.stringFromDate(NSDate())
            let cF = NSDateFormatter()
            cF.dateFormat = "MM/dd/yyyy"
                //make a button
                let myB = UILabel()
                myB.text = "\(index)"
                myB.textAlignment = NSTextAlignment.Center
                myB.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
                myB.font = UIFont(name: "Verdana", size: 11)
                myB.frame = CGRectMake(thePosX, thePosY, 24, 24)
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
                    myB.textColor = UIColor.whiteColor()
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