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

private let NORMAL_WIDTH: CGFloat  = 48.0
private let NORMAL_HEIGHT: CGFloat = 100.0

class LevelViewController: UIViewController, LTMorphingLabelDelegate, ShareDelegate{
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
    
    var tapOnTableView: UITapGestureRecognizer?  // 绑定在 table 上
    
    @IBOutlet var petName: UILabel!  // 显示 pet name, 不属于 tableView
    @IBOutlet var PetNormalView: UIImageView!
    @IBOutlet weak var petLevel: UILabel!
    
    var petId: String? // 没有显示
    
    var ownPet: Bool? {
        didSet {
            if ownPet! {
                self.upgrade?.bgColor = BgColor.blue
                self.upgrade?.enabled = true
            } else {
                self.upgrade!.bgColor = BgColor.grey
                self.upgrade?.enabled = false
            }
            
        }
    }
    
    @IBOutlet weak var good: UIView!
    @IBOutlet weak var step: UIView!
    @IBOutlet weak var listener: UIView!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var rightLine: UIView!
    
    var upgrade: NIButton?  //---- 界面上唯一用代码生成的控件
    var rightLabel: UILabel?
    
    //---
    /* 通过 KVO 来获得数据变化刷新 UI */
    
    var lotteryFromRightLabel: NSDictionary? {
        didSet {
            self.petInfoArray.addObject(lotteryFromRightLabel!)
            
            if self.petInfoArray.count > 0 {
                self.tableview.reloadData()
            }
        }
    }
    
    //--- 好几个 NIAlert
    var upgradeView: NIAlert?      //
    var coinInsufficientView: NIAlert?
    var lotteryRusltView: NIAlert?
    var petDetailView: NIAlert?
    var upgradeResultView: NIAlert?
    
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
            } else {
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
        navView.userInteractionEnabled = true
        self.view.addSubview(navView)
        self.viewBack()
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "宠物"
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
        
        rightLabel = UILabel(frame: CGRectMake(navView.frame.width - 60, 20, 60, 44))
        rightLabel!.textColor = UIColor.whiteColor()
        rightLabel!.text = "抽蛋"
        rightLabel!.font = UIFont.systemFontOfSize(14)
        rightLabel!.textAlignment = NSTextAlignment.Right
        rightLabel!.userInteractionEnabled = true
        rightLabel!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onEgg"))
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel!)]
        
        self.view.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.viewTop.setWidth(globalWidth)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 879)
        self.viewTopHolder.frame = CGRectMake(0, 360, globalWidth, 94)
        self.viewCalendar.setX(globalWidth/2-160)
        self.labelCalendar.setX(globalWidth/2-145)
        self.viewBottom.setWidth(globalWidth)
        self.viewBottomHolder.setX(globalWidth/2-160)
        self.petName.setX((globalWidth - 100)/2)
        
        self.upgrade = NIButton(string: "升级", frame:  CGRectMake((globalWidth - 100)/2, 295, 100, 36))
        self.upgrade!.bgColor = BgColor.blue
        self.upgrade?.addTarget(self, action: "toUpgrade:", forControlEvents: UIControlEvents.TouchUpInside)
        self.viewTop.addSubview(self.upgrade!)
        
        self.tableview.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI/2))
        self.tableview.frame = CGRectMake(0, 95, globalWidth, 200)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, 200, globalWidth/2 - 24))
        self.tableview.tableFooterView = UIView(frame: CGRectMake(0, 0, 200, globalWidth/2 - 24))
        
        tapOnTableView = UITapGestureRecognizer(target: self, action: "showPetInfo")
        tapOnTableView!.delegate = self
        self.tableview.addGestureRecognizer(tapOnTableView!)
        
        self.preContentOffsetX = 0.0    // 设置 tableView 的 content offset X
        self.PetNormalView.setX((globalWidth - 120)/2)
        self.petLevel.setX((globalWidth - 42)/2)
        
        //-----------
        self.step.setX((globalWidth - 90)/2)
        self.leftLine.setX(self.step.x() - 1)
        self.good.setX(self.leftLine.x() - 90)
        self.rightLine.setX(self.step.x() + 90)
        self.listener.setX(self.rightLine.x() + 1)

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
        
        var networkStatus = checkNetworkStatus()
        
        if networkStatus == 0 {
            var safeuid = SAUid()
            let (results, err) = SD.executeQuery("select * from `pet` where owner = '\(safeuid)'")
            self.petInfoArray.removeAllObjects()
            
            for row in results {
                var id = (row["id"]?.asString())!
                var level = (row["level"]?.asString())!
                var name = (row["name"]?.asString())!
                var property = (row["property"]?.asString())!
                var img = (row["img"]?.asString())!
                var getat = (row["getat"]?.asString())!
                var updateat = (row["updateat"]?.asString())!
                
                var data = NSDictionary(objects: [id, level, name, property, img, getat, updateat],
                                        forKeys: ["id", "level", "name", "property", "image", "getat", "updateat"])
                self.petInfoArray.addObject(data)
            }
            
            if self.petInfoArray.count > 0 {
                self.tableview.reloadData()
            }
            
        } else {
            Api.getAllPets() { json in
                if json != nil {
                    let err = json!["error"] as! NSNumber
                    
                    if err == 0 {
                        for item in ((json!["data"] as! NSDictionary).objectForKey("pets") as! NSArray) {
                            self.petInfoArray.addObject(item)
                        }
                        
                        if self.petInfoArray.count > 0 {
                            self.tableview.reloadData()
                        }
                    }
                }
            }
        }
        
        // 因为有两个地方用到 “念币不足”，所以放在了 viewDidload 里面
        coinInsufficientView = NIAlert()
        coinInsufficientView?.delegate = self
        coinInsufficientView!.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "念币不足", "抽蛋需要花费 3 念币\n但是你当前只有 \(coinTotal!) 念币......", ["知道了", "获得念币"]] ,
            forKeys: ["img", "title", "content", "buttonArray"])
    }

    func onEgg() {
        if coinTotal!.toInt() > 3 {
            var v = SAEgg()
            v.delegateShare = self
            v.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "抽蛋", "要以 3 念币抽一次\n宠物吗？", [" 嗯！", "不要"]],
                                        forKeys: ["img", "title", "content", "buttonArray"])
            v.showWithAnimation(.flip)
        } else {
            coinInsufficientView?.showWithAnimation(.flip)
        }
    }
    
    // MARK: - SAEgg delegate
    
    func onShare(avc: UIActivityViewController) {
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
    func saEgg(saEgg: SAEgg, tapBackground: Bool) {
        if tapBackground == true {
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel!)]
        }
    }
    
    func saEgg(saEgg: SAEgg, lotteryResult: NSDictionary) {
        let _id = lotteryResult.objectForKey("id") as! String
        var contained: Bool = false
        
        for item in self.petInfoArray {
            let id = (item as! NSDictionary).objectForKey("id") as! String
            
            if id == _id {
                contained = true
            }
        }
        
        if !contained {
            globalWillNianReload = 1
            self.lotteryFromRightLabel = lotteryResult
        }
    }
    
    // MARK: - 用户交互事件
    
    func toUpgrade(sender: UIButton) {
        if coinTotal?.toInt()! > 3 {
            upgradeView = NIAlert()
            upgradeView!.delegate = self
            upgradeView!.dict = NSMutableDictionary(objects: [UIImage(named: "coin")!, "花费 3 念币", "要以 3 念币让\(self.petName.text!)\n升级吗？", ["嗯！", "不要"]],
                                                    forKeys: ["img", "title", "content", "buttonArray"])
            upgradeView!.showWithAnimation(.flip)
        } else {
            self.coinInsufficientView?.showWithAnimation(.flip)
        }
    }
    
    func showPetInfo() {
        petDetailView = NIAlert()
        petDetailView?.delegate = self
        petDetailView?.dict = NSMutableDictionary(objects: [self.PetNormalView.image!, self.petName.text!, "显示啥", ["分享"]],
                                                  forKeys: ["img", "title", "content", "buttonArray"])
        petDetailView?.showWithAnimation(.flip)
    }
    
}

extension LevelViewController {
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
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let tHHeight = tableview.tableHeaderView!.frame.height
        let tFHeight = tableview.tableFooterView!.frame.height
        
        var tableViewCenter: CGFloat = globalWidth / 2.0

        if gestureRecognizer == tapOnTableView {
            var point = gestureRecognizer.locationInView(tableview)
            var HeaderXInScreen: CGFloat = point.y - tableview.contentOffset.y
            var FooterXInScreen: CGFloat = point.y - tableview.contentOffset.y
            
            if abs(HeaderXInScreen - tableViewCenter) < 60 && abs(FooterXInScreen - tableViewCenter) < 60 {
                return true
            } else {
                return false
            }
        }
        
        return true
    }
}

extension LevelViewController: NIAlertDelegate {
    func niAlert(niAlert: NIAlert, didselectAtIndex: Int) {
        if niAlert == self.upgradeView {
            if didselectAtIndex == 1 {
                niAlert.dismissWithAnimation(.normal)
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel!)]
            } else if didselectAtIndex == 0 {
                let _btn = niAlert.niButtonArray.firstObject as! NIButton
                _btn.startAnimating()
                
                Api.getPetUpgrade(self.petId!) {
                    json in
                    _btn.stopAnimating()
                    
                    if json != nil {
                        let err = json!["error"] as! NSNumber
                        if err == 0 {
                            // 升级成功，先把念币扣了
                            coinTotal = String(coinTotal!.toInt()! - 3)
                            niAlert.dismissWithAnimation(.normal)
                            globalWillNianReload = 1
                            
                            let data = json!["data"] as! NSMutableDictionary
                            self.SQLInsertUpgradeInfo(data)
                        } else if err == 2 {
                            niAlert.dismissWithAnimation(.normal)
                            self.coinInsufficientView?.showWithAnimation(.flip)
                        }
                    }
                }
            }
            
        } else if niAlert == self.coinInsufficientView {
            if didselectAtIndex == 0 {
                niAlert.dismissWithAnimation(.normal)
            }
        } else if niAlert == self.petDetailView {
            if didselectAtIndex == 0 {
                shareVC()
            }
        }
    }
    
    func niAlert(niAlert: NIAlert, tapBackground: Bool) {
        if niAlert == self.petDetailView {
            niAlert.dismissWithAnimation(.normal)
        } else {
            niAlert.dismissWithAnimation(.normal)
            self.navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightLabel!)]
        }
    }
    
// MARK: - help function 
    func SQLInsertUpgradeInfo(info: NSMutableDictionary) {
        let id = info.stringAttributeForKey("id")
        let level = info.stringAttributeForKey("level")
        let name = info.stringAttributeForKey("name")
        let property = info.stringAttributeForKey("property")
        let img = info.stringAttributeForKey("image")
        let getAtDate = info.stringAttributeForKey("get_at")
        let updateAtDate = info.stringAttributeForKey("update_at")
        
        var _tmpDict = NSMutableDictionary(dictionary: info)
        
        SQLPetContent(id, level, name, property, img, getAtDate, updateAtDate) {
            //TODO: - 升级动画
            
            self.petInfoArray.enumerateObjectsUsingBlock({(obj, idx, stop) -> Void in
                var _id = (obj as! NSDictionary).objectForKey("id") as! String
                if _id == id {
                    _tmpDict.setObject("1", forKey: "owned")
                    self.petInfoArray.replaceObjectAtIndex(idx, withObject: _tmpDict)
                    self.tableview.reloadData()
                }
            })
        }  // end of ' SQLPetContent '
    }
    
    func shareVC() {
        var card = (NSBundle.mainBundle().loadNibNamed("Card", owner: self, options: nil) as NSArray).objectAtIndex(0) as! Card
        let petName = self.petName.text!
        let petImage = self.PetNormalView.image!
        var content = "我在念里拿到了可爱的「\(petName)」"
        card.content = content
        card.widthImage = "360"
        card.heightImage = "360"
        card.url = "http://img.nian.so/pets/\(petImage)"
        var img = card.getCard()
        var avc = SAActivityViewController.shareSheetInView([img, content], applicationActivities: [], isStep: true)
        self.presentViewController(avc, animated: true, completion: nil)
    }
    
}


// MARK: - Level View Controller 实现 uitableview delegate 和 uitableview data source
extension LevelViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.petInfoArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        cellString = self.pickupCellType(tableView, indexPath: indexPath)
        
        cell = tableview.dequeueReusableCellWithIdentifier("PetCell", forIndexPath: indexPath) as! petCell
        var dict = self.petInfoArray[indexPath.row] as? NSDictionary
        (cell as! petCell).info = dict
        (cell as! petCell)._layoutSubviews()
        
        if cellString == "PetZoomInCell" {
            self.PetNormalView.image = (cell as! petCell).imgView.image
            (cell as! petCell).imgView.image = nil
            self.PetNormalView.backgroundColor = UIColor.clearColor()
            self.petName.text = dict!.stringAttributeForKey("name")
            self.petLevel.text = "Lv " + dict!.stringAttributeForKey("level")
            self.petId = dict!.stringAttributeForKey("id")
            
            var ownShip = (cell as! petCell).info?.objectForKey("owned") as! String
            
            if ownShip == "0" {
                self.ownPet = false
            } else {
                self.ownPet = true
            }
        }
        
        cell!.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/2))
        
        return cell!
    }

    /**
    根据 content offset, 计算中间的 UIImageView 显示哪一个
    
    :param: tableView       <#tableView description#>
    
    :returns: String: "PetCell" "PetZoomInCell"
    */
    private func pickupCellType(tableView: UITableView, indexPath: NSIndexPath) -> String {
        let tHHeight = tableView.tableHeaderView!.frame.height
        let tFHeight = tableView.tableFooterView!.frame.height
        
        var _cellString: String?
        var tableViewCenter: CGFloat = globalWidth / 2.0
        var cellHeaderXInScreen: CGFloat = tHHeight + CGFloat(indexPath.row * 48) - tableView.contentOffset.y
        var cellFooterXInScreen: CGFloat = tFHeight + CGFloat((indexPath.row + 1) * 48) - tableView.contentOffset.y

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
            if abs((scrollView as! UITableView).contentOffset.y - preContentOffsetX!) >= 24.0 {
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


