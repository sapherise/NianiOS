//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class BBSViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, AddstepDelegate, EditstepDelegate{     //😍
    
    let identifier = "bbs"
    let identifier2 = "bbstop"
    var lefttableView:UITableView?
    var dataArray = NSMutableArray()
    var page :Int = 0
    var Id:String = "1"
    var topcontent:String = ""
    var topuid:String = ""
    var toplastdate:String = ""
    var topuser:String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupViews()
        setupRefresh()
        self.lefttableView!.headerBeginRefreshing()
        SAReloadData()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    func setupViews()
    {
        var width = self.view.frame.size.width
        var height = self.view.frame.size.height - 64
        self.lefttableView = UITableView(frame:CGRectMake(0,0,width,height))
        self.lefttableView!.delegate = self;
        self.lefttableView!.dataSource = self;
        self.lefttableView!.backgroundColor = BGColor
        self.lefttableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        
        var nib = UINib(nibName:"BBSCell", bundle: nil)
        var nib2 = UINib(nibName:"BBSCellTop", bundle: nil)
        
        
        self.title = "梦想"
        self.lefttableView?.registerNib(nib, forCellReuseIdentifier: identifier)
        self.lefttableView?.registerNib(nib2, forCellReuseIdentifier: identifier2)
        self.view.addSubview(self.lefttableView!)
        
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addStepButton")
        rightButton.image = UIImage(named:"add")
        self.navigationItem.rightBarButtonItem = rightButton;
        
        
        //标题颜色
        self.navigationController.navigationBar.tintColor = IconColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        var swipe = UISwipeGestureRecognizer(target: self, action: "back")
        swipe.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipe)
    }
    
    
    func loadData()
    {
        var url = urlString()
        // self.refreshView!.startLoading()
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull()
            {
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            
            for data : AnyObject  in arr
            {
                self.dataArray.addObject(data)
            }
            self.lefttableView!.reloadData()
            self.lefttableView!.footerEndRefreshing()
            self.page++
        })
    }
    
    func SAReloadData(){
        var url = "http://nian.so/api/bbs_comment.php?page=0&id=\(Id)&uid=1"
        SAHttpRequest.requestWithURL(url,completionHandler:{ data in
            if data as NSObject == NSNull(){
                UIView.showAlertView("提示",message:"加载失败")
                return
            }
            var arr = data["items"] as NSArray
            self.dataArray.removeAllObjects()
            for data : AnyObject  in arr{
                self.dataArray.addObject(data)
            }
            self.lefttableView!.reloadData()
            self.lefttableView!.headerEndRefreshing()
            self.page = 1
        })
    }
    
    func urlString()->String
    {
        return "http://nian.so/api/bbs_comment.php?page=\(page)&id=\(Id)&uid=1"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        if section==0{
            return 1
        }else{
                return self.dataArray.count
        }
    }
    
    
    func tableView(tableView: UITableView?, cellForRowAtIndexPath indexPath: NSIndexPath?) -> UITableViewCell? {
        var cell:UITableViewCell
        
        if indexPath!.section==0{
            var c = tableView?.dequeueReusableCellWithIdentifier(identifier2, forIndexPath: indexPath) as? BBSCellTop
            c!.topcontent = topcontent
            c!.topuid = topuid
            c!.toplastdate = toplastdate
            c!.topuser = topuser
            cell = c!
        }else{
                var c = tableView?.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as? BBSCell
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                c!.data = data
                c!.avatarView!.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "userclick:"))
                cell = c!
        }
        return cell
    }
    
    func userclick(sender:UITapGestureRecognizer){
        var UserVC = UserViewController()
        UserVC.Id = "\(sender.view.tag)"
        self.navigationController.pushViewController(UserVC, animated: true)
    }
    
    func imageViewTapped(noti:NSNotification){
        var imageURL = noti.object as String
        var imgVC = SAImageViewController(nibName: nil, bundle: nil)
        imgVC.imageURL = "\(imageURL)"
        self.navigationController.pushViewController(imgVC, animated: true)
    }
    
    func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat
    {
        
        if indexPath.section==0{
            return  BBSCellTop.cellHeightByData(topcontent)
        }else{
                var index = indexPath!.row
                var data = self.dataArray[index] as NSDictionary
                return  BBSCell.cellHeightByData(data)
        }
    }
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!){
    }
    
    
    func addStepButton(){
        var AddstepVC = AddStepViewController(nibName: "AddStepViewController", bundle: nil)
        AddstepVC.Id = self.Id
        AddstepVC.delegate = self    //😍
        self.navigationController.pushViewController(AddstepVC, animated: true)
    }
    
    func countUp() {      //😍
        self.SAReloadData()
    }
    
    
    func Editstep() {      //😍
        self.SAReloadData()
    }
    func setupRefresh(){
        self.lefttableView!.addHeaderWithCallback({
            self.SAReloadData()
        })
        
        self.lefttableView!.addFooterWithCallback({
            self.loadData()
        })
    }
    func back(){
        self.navigationController.popViewControllerAnimated(true)
    }
}
