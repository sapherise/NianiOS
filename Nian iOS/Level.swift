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

private let NORMAL_WIDTH: CGFloat  = 120.0
private let NORMAL_HEIGHT: CGFloat = 100.0

class LevelViewController: UIViewController, LTMorphingLabelDelegate{
    @IBOutlet var scrollView:UIScrollView!
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
    @IBOutlet var tableview:UITableView!
    @IBOutlet var petName: UILabel!  // 显示 pet name, 不属于 tableView
    @IBOutlet var petIndex: UILabel!  // 显示类似于 25/50
    @IBOutlet var upgrade: UILabel!  //
    @IBOutlet var PetNormalView: UIImageView!
    
    var preContentOffsetX: CGFloat?
    var cellString: String?
    var navView:UIView!
    var top:CAShapeLayer!
    var marks: [Bool] = [Bool](count: 32, repeatedValue: false)
    var textLeft:Int = 0
    var textRight:Int = 0
    
    var page: Int = 1 //--- 显示获得的宠物
    var petInfoArray = NSMutableArray()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.tableview.registerNib(UINib(nibName: "PetCell", bundle: nil), forCellReuseIdentifier: "PetCell")
        self.tableview.registerNib(UINib(nibName: "PetZoomInCell", bundle: nil), forCellReuseIdentifier: "PetZoomInCell")
        
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
//                    self.labelLevel.text = textI
                })
            }else{
                delay( y + 0.1 , {
                    var textI = ( totalNumber < 10 ) ? "0\(totalNumber)" : "\(totalNumber)"
//                    self.labelLevel.text = textI
                })
                break
            }
        }
    }
    
    func setupViews(){
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        self.viewBack()
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "等级"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        self.view.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.viewTop.setWidth(globalWidth)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 720)
        self.viewTopHolder.setX(globalWidth/2-160)
        self.viewCalendar.setX(globalWidth/2-160)
        self.labelCalendar.setX(globalWidth/2-145)
        self.viewBottom.setWidth(globalWidth)
        self.viewBottomHolder.setX(globalWidth/2-160)
        self.petName.setX((globalWidth - 100)/2)
        self.upgrade.setX((globalWidth - 60)/2)
        
        self.tableview.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        self.tableview.frame = CGRectMake(0, 34, globalWidth, 160)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, 160, globalWidth/2 - 60))
        self.tableview.tableFooterView = UIView(frame: CGRectMake(0, 0, 160, globalWidth/2 - 60))
        self.preContentOffsetX = 0.0    // 设置 tableView 的 content offset X
        self.PetNormalView.setX((globalWidth - 120)/2)

        self.labelMonthLeft.textColor = SeaColor
        self.labelMonthRight.textColor = SeaColor
        
        Api.getUserMe() { json in
            if json != nil {
                var data = json!["user"] as! NSDictionary
                var foed = data.stringAttributeForKey("foed")
                var like = data.stringAttributeForKey("like")
                var step = data.stringAttributeForKey("step")
                var level = data.stringAttributeForKey("level")
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
                var items = json!.objectForKey("items") as! NSArray
                for item in items {
                    var lastdate = (item.objectForKey("lastdate") as! NSString).doubleValue
                    var date = V.getDay(lastdate)
                    self.marks[date.toInt()!] = true
                }
                self.layoutAMonth(self.marks)
                self.labelMonthLeft.text = "\(self.textLeft)"
                self.labelMonthRight.text = "\(self.textRight)"
            }
        }
        
        Api.getUserPet(page) { json in
            if json != nil {
                let err = json!["error"] as! NSNumber
                
                if err == 0 {
                    for item in ((json!["data"] as! NSDictionary).objectForKey("pets") as! NSArray) {
                        self.petInfoArray.addObject(item)
                    }
                    
                    if self.petInfoArray.count > 0 {
                        self.tableview.reloadData()
                        self.page++
                    }
                }
            }
        }
    }
    
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
//        self.viewCircle.layer.addSublayer(top)
//        delay(0.5, { () -> () in
//            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
//            strokeEnd.toValue = 0.8 * float
//            strokeEnd.duration = 1
//            self.top.SAAnimation(strokeEnd)
//        })
    }
    
    func layoutAMonth(marks: [Bool]) {
        var calendar = NSCalendar.currentCalendar()
        var comoponents = calendar.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit, fromDate: NSDate())
        var year = comoponents.year
        var month = comoponents.month
        
        let dffd = NSDateFormatter()
        dffd.dateFormat = "MM/dd/yyyy"
        let firstDay :NSDate = dffd.dateFromString("\(month)/01/\(year)")!
        
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
            
            let strAll = "\(strMonthNum)/\(index)/\(year)"
            
            let todayF = NSDateFormatter()
            todayF.dateFormat = "MM/d/yyyy"
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

extension LevelViewController: UIGestureRecognizerDelegate {
    
}


// MARK: - Level View Controller 实现 uitableview delegate 和 uitableview data source
extension LevelViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.petInfoArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cellString = self.pickupCellType(tableView, indexPath: indexPath)
        
//        if cellString == "PetCell" {
            cell = tableview.dequeueReusableCellWithIdentifier("PetCell", forIndexPath: indexPath) as! petCell
            var dict = self.petInfoArray[indexPath.row] as? NSDictionary
            (cell as! petCell).info = dict
            (cell as! petCell)._layoutSubviews()
//        } else if cellString == "PetZoomInCell" {
//            cell = tableview.dequeueReusableCellWithIdentifier("PetZoomInCell", forIndexPath: indexPath) as! petZoomInCell
//            var dict = self.petInfoArray[indexPath.row] as? NSDictionary
//            (cell as! petZoomInCell).info = dict
//            (cell as! petZoomInCell)._layoutSubviews()
//            
//            self.petName.text = dict!.stringAttributeForKey("name")
//            self.petIndex.text = "\(indexPath.row + 1)/\(self.petInfoArray.count)"
//        }
        
        if cellString == "PetZoomInCell" {
            self.PetNormalView.image = (cell as! petCell).imgView.image
//            self.PetNormalView.layer.backgroundColor = UIColor.clearColor().CGColor
            self.PetNormalView.backgroundColor = UIColor.clearColor()   
//            (cell as! petCell).imgView.image = nil
            self.petName.text = dict!.stringAttributeForKey("name")
            self.petIndex.text = "\(indexPath.row + 1)/\(self.petInfoArray.count)"
        }
        
        cell!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        
        return cell!
    }

    /**
    根据 content offset, 选择加载不同的 cell
    
    :param: tableView       <#tableView description#>
    
    :returns: String: "PetCell" "PetZoomInCell"
    */
    private func pickupCellType(tableView: UITableView, indexPath: NSIndexPath) -> String {
        let tHHeight = tableView.tableHeaderView!.frame.height
        let tFHeight = tableView.tableFooterView!.frame.height
        
        var _cellString: String?
        var tableViewCenter: CGFloat = globalWidth / 2.0
        var cellHeaderXInScreen: CGFloat = tHHeight + CGFloat(indexPath.row * 120) - tableView.contentOffset.y
        var cellFooterXInScreen: CGFloat = tFHeight + CGFloat((indexPath.row + 1) * 120) - tableView.contentOffset.y

        if cellHeaderXInScreen < tableViewCenter &&  tableViewCenter < cellFooterXInScreen {
            _cellString = "PetZoomInCell"
        } else {
            _cellString = "PetCell"
        }
        
        return _cellString!
    }
}

// MARK: - Level View Controller 实现 uiscrollview delegate
extension LevelViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(UITableView) {
            if abs((scrollView as! UITableView).contentOffset.y - preContentOffsetX!) >= 60.0 {
                (scrollView as! UITableView).reloadData()
                preContentOffsetX = scrollView.contentOffset.y
            }
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isKindOfClass(UITableView) {
            if !decelerate {
                self.snapToNearestItem(scrollView)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView.isKindOfClass(UITableView) {
            self.snapToNearestItem(scrollView)
        }
    }
    
    private func snapToNearestItem(scrollView: UIScrollView) {
        var targetOffset = self.nearestTargetOffsetForOffset(scrollView.contentOffset)
        
        scrollView.setContentOffset(targetOffset, animated: true)
    }
    
    private func nearestTargetOffsetForOffset(offset: CGPoint) -> CGPoint {
        var PageSize = CGFloat(NORMAL_WIDTH)
        var page: NSInteger = NSInteger(roundf(Float(offset.y / PageSize)))
        var targetX = PageSize * CGFloat(page)
        
        return CGPointMake(offset.x, targetX)
    }
}

// MARK: pet cell
class petCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    
    var info: NSDictionary?
    var id: String?
    var level: String?
    var name: String?
    var property: String?
    var imgPath: String?
    var getAtDate: String?
    var updateAtDate: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // todo: 设置 cell
        self.selectionStyle = .None
    }
    
    
    func _layoutSubviews() {
        // 刷新界面
        let imgF = self.info?.stringAttributeForKey("image")
        println("imgF cell: \(imgF)")
        
        id = self.info?.stringAttributeForKey("id")
        level = self.info?.stringAttributeForKey("level")
        name = self.info?.stringAttributeForKey("name")
        property = self.info?.stringAttributeForKey("property")
        getAtDate = self.info?.stringAttributeForKey("get_at")
        updateAtDate = self.info?.stringAttributeForKey("updated_at")
        
        var imgURLString = "http://img.nian.so/pets/"
       
        if globalWidth > 375 {
            imgURLString += imgF!
        } else {
            imgURLString += imgF! + "!d"
        }
        self.imgView?.setImage(imgURLString, placeHolder: IconColor)
        self.imgView?.contentMode = UIViewContentMode.ScaleToFill
    }
    
    override func prepareForReuse() {
        self.imgView?.cancelImageRequestOperation()
        self.imgView!.image = nil
    }
}

// MARK: pet cell
class petZoomInCell: UITableViewCell {
    @IBOutlet var imgView: UIImageView!
    
    var info: NSDictionary?
    var id: String?
    var level: String?
    var name: String?
    var property: String?
    var imgPath: String?
    var getAtDate: String?
    var updateAtDate: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // todo: 设置 cell
        self.selectionStyle = .None
    }
    
    func _layoutSubviews() {
        // 刷新界面
        let imgF = self.info?.stringAttributeForKey("image")
        println("imgF Zoom In cell: \(imgF)")

        id = self.info?.stringAttributeForKey("id")
        level = self.info?.stringAttributeForKey("level")
        name = self.info?.stringAttributeForKey("name")
        property = self.info?.stringAttributeForKey("property")
        getAtDate = self.info?.stringAttributeForKey("get_at")
        updateAtDate = self.info?.stringAttributeForKey("updated_at")

        var imgURLString = "http://img.nian.so/pets/"
        
        if globalWidth > 375 {
            imgURLString += imgF!
        } else {
            imgURLString += imgF! + "!d"
        }
        self.imgView?.setImage(imgURLString, placeHolder: IconColor)
        self.imgView?.contentMode = UIViewContentMode.ScaleToFill
    }
    
    override func prepareForReuse() {
        self.imgView?.cancelImageRequestOperation()
        self.imgView!.image = nil
    }
}



