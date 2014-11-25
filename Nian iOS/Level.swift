//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class LevelViewController: UIViewController, UIGestureRecognizerDelegate, LTMorphingLabelDelegate{
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var viewCircle: UIView!
    @IBOutlet var viewCalendar: UIView!
    @IBOutlet var viewCircleBackground:UIView!
    @IBOutlet var viewTop: UIView!
    @IBOutlet var labelLevel: LTMorphingLabel!
    @IBOutlet var menuLeft: UILabel!
    @IBOutlet var menuMiddle: UILabel!
    @IBOutlet var menuRight: UILabel!
    @IBOutlet var labelMonthLeft: UILabel!
    @IBOutlet var labelMonthRight: UILabel!
//    @IBOutlet var tableview:UITableView!
    var navView:UIView!
    var top:CAShapeLayer!
    var marks: [Bool] = [Bool](count: 32, repeatedValue: false)
    var textLeft:Int = 0
    var textRight:Int = 0
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.setupViews()
    }
    
    func levelLabelCount(totalNumber:Int){
        var x = Int(floor(Double(totalNumber) / 20) + 1)
        var y:Double = 0
        var z = 0
        for i:Int in 0...20 {
            z = z + x
            var j = z + i
            if j < totalNumber {
                var textI = ( j < 10 ) ? "0\(j)" : "\(j)"
                y = y + 0.1
                delay( y , {
                    self.labelLevel.text = textI
                })
            }else{
                delay( y + 0.1 , {
                    var textI = ( totalNumber < 10 ) ? "0\(totalNumber)" : "\(totalNumber)"
                    self.labelLevel.text = textI
                })
                break
            }
        }
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = NavColor
        self.view.addSubview(navView)
        viewBack(self)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "等级"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 720)
        
//        self.tableview.delegate = self
//        self.tableview.dataSource = self
//        var nib = UINib(nibName:"LevelGame", bundle: nil)
//        self.tableview.registerNib(nib, forCellReuseIdentifier: "GameCell")
//        self.tableview.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.viewTop.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1)
        self.viewCircleBackground.layer.cornerRadius = 84
        self.viewCircleBackground.layer.masksToBounds = true
        self.viewCircleBackground.layer.borderColor = UIColor.whiteColor().CGColor
        self.viewCircleBackground.layer.borderWidth = 8
        
        self.labelLevel.textColor = SeaColor
        self.labelLevel.morphingEffect = .Evaporate
        self.labelLevel.delegate = self
        
        Api.getUserMe() { json in
            if json != nil {
                var sa: AnyObject! = json!.objectForKey("user")
                var foed: String! = sa.objectForKey("foed") as String
                var like: String! = sa.objectForKey("like") as String
                var step: String! = sa.objectForKey("step") as String
                var level: String! = sa.objectForKey("level") as String
                self.menuLeft.text = like
                self.menuMiddle.text = step
                self.menuRight.text = foed
                var (l, e) = levelCount( (level.toInt()!)*7 )
                self.levelLabelCount(l)
                self.SACircle(CGFloat(e))
            }
        }
        
        Api.getLevelCalendar(){ json in
            if json != nil {
                self.marks = [Bool](count: 32, repeatedValue: false)
                var items = json!.objectForKey("items") as NSArray
                for item in items {
                    var lastdate = (item.objectForKey("lastdate") as NSString).doubleValue
                    var date = V.getDay(lastdate)
                    self.marks[date.toInt()!] = true
                }
                self.layoutAMonth("11", marks: self.marks)
                self.labelMonthLeft.text = "\(self.textLeft)"
                self.labelMonthRight.text = "\(self.textRight)"
            }
        }
    }
    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        self.tableview.deselectRowAtIndexPath(indexPath, animated: false)
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as GameCell
//        return cell
//    }
//    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 100
//    }
    
    
    func SACircle(float:CGFloat){
        self.top = CAShapeLayer()
        var path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, 160, 80)
        CGPathAddCurveToPoint(path, nil, 160, 35.82, 124.18, 0, 80, 0)
        CGPathAddCurveToPoint(path, nil, 35.82, 0, 0, 35.82, 0, 80)
        CGPathAddCurveToPoint(path, nil, 0, 124.18, 35.82, 160, 80, 160)
        CGPathAddCurveToPoint(path, nil, 124.18, 160, 160, 124.18, 160, 80)
        CGPathAddCurveToPoint(path, nil, 160, 35.82, 124.18, 0, 80, 0)
        
        self.top.path = path
        self.top.strokeColor = SeaColor.CGColor
        self.top.lineWidth = 8
        self.top.lineCap = kCALineCapRound
        self.top.masksToBounds = true
        let strokingPath = CGPathCreateCopyByStrokingPath(top.path, nil, 8, kCGLineCapRound, kCGLineJoinMiter, 4)
        self.top.bounds = CGPathGetPathBoundingBox(strokingPath)
        
        self.top.anchorPoint = CGPointMake(0, 0)
        self.top.position = CGPointZero
        self.top.strokeStart = 0
        self.top.strokeEnd = 0
        self.top.fillColor = UIColor.clearColor().CGColor
        
        self.top.actions = [
            "strokeStart": NSNull(),
            "strokeEnd": NSNull(),
            "transform": NSNull()
        ]
        self.viewCircle.layer.addSublayer(top)
        delay(0.5, { () -> () in
            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            strokeEnd.toValue = 0.8 * float
            strokeEnd.duration = 1
            self.top.SAAnimation(strokeEnd)
        })
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func layoutAMonth(strMonthNum: NSString, marks: [Bool]) {
        let dffd = NSDateFormatter()
        dffd.dateFormat = "MM/dd/yyyy"
        let firstDay :NSDate = dffd.dateFromString("\(strMonthNum)/01/2014")!
        
        let dfmn = NSDateFormatter()
        dfmn.dateFormat = "MM"
        let strMonthNum = dfmn.stringFromDate(firstDay)
        
        let dfm = NSDateFormatter()
        dfm.dateFormat = "MMMM"
        let dMonth = dfm.stringFromDate(firstDay)
        
        let df = NSDateFormatter()
        df.dateFormat = "e"
        let theDayOfWeekForFirst :NSString! = df.stringFromDate(firstDay)
        
        let i: Int = theDayOfWeekForFirst.integerValue
        var theDayOfWeek :CGFloat! = CGFloat(i)
        var thePosY :CGFloat! = 40
        
        let todayD = NSDateFormatter()
        todayD.dateFormat = "d"
        let todayDInt = todayD.stringFromDate(NSDate()).toInt()!
        
        var numDaysInMonth = 31
        
        for index in 1 ... numDaysInMonth {
            
            var thePosX = (40 * (theDayOfWeek - 1)) + 15 + 12
            // -1 because you want the first to be 0
            
            let strAll = "\(strMonthNum)/\(index)/2014"
            
            let todayF = NSDateFormatter()
            todayF.dateFormat = "MM/dd/yyyy"
            let firstDay = todayF.stringFromDate(NSDate())
            
            let cF = NSDateFormatter()
            cF.dateFormat = "MM/dd/yyyy"
            
            if let d = cF.dateFromString(strAll) { // date is valid
                //make a button
                let myB = UILabel()
                myB.text = "\(index)"
                myB.textAlignment = NSTextAlignment.Center
                myB.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
                myB.font = UIFont(name: "Verdana", size: 11)
                myB.frame = CGRectMake(thePosX, thePosY, 24, 24)
                if marks[index] {
                    myB.textColor = SeaColor
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
                    myB.backgroundColor = SeaColor
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
}
