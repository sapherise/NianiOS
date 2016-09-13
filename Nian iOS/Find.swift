//
//  YRJokeTableViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class FindViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    var tableView:UITableView!
    var tableViewPhone: UITableView!
    var viewPromo: UIView!
    var dataArray = NSMutableArray()
    var dataArrayPhone = NSMutableArray()
    var page :Int = 0
    var Id:String = ""
    var viewFindCellTop: FindCellTop!
    var imagePromo: UIImageView!
    
    var arr = ["weibo", "phone", "recommend"]
    var arrSelected = ["weibo_s", "phone_s", "recommend_s"]
    
    override func viewDidLoad(){
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        viewBack()
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        let labelNav = UILabel(frame: CGRect(x: 0, y: 20, width: globalWidth, height: 44))
        labelNav.text = "发现好友"
        labelNav.textColor = UIColor.white
        labelNav.font = UIFont.systemFont(ofSize: 17)
        labelNav.textAlignment = NSTextAlignment.center
        navView.addSubview(labelNav)
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(navView)
        
        // 创建三个舞台
        self.tableView = setupTable()
        self.tableViewPhone = setupTable()
        self.tableViewPhone.frame.origin.x = globalWidth
        self.viewPromo = UIView(frame: CGRect(x: globalWidth * 2, y: 64 + 75, width: globalWidth, height: globalHeight - 64 - 75))
        imagePromo = UIImageView(frame: CGRect(x: globalWidth/2-80, y: globalHeight/2-200, width: 160, height: 160))
        imagePromo.backgroundColor = UIColor.GreyColor1()
        imagePromo.layer.masksToBounds = true
        imagePromo.layer.cornerRadius = 8
        self.viewPromo.addSubview(imagePromo)
        let btnPromo = UIButton()
        btnPromo.setButtonNice("发给伙伴")
        btnPromo.frame = CGRect(x: globalWidth/2-50, y: imagePromo.bottom() + 16, width: 100, height: 36)
        btnPromo.addTarget(self, action: #selector(FindViewController.sharePromo), for: UIControlEvents.touchUpInside)
        self.viewPromo.addSubview(btnPromo)
        self.view.addSubview(self.viewPromo)
        
        let safeuid = SAUid()
        
        Api.getUserTop(Int(safeuid)!){ json in
            if json != nil {
                let _data  = json!.object(forKey: "data") as! NSDictionary
                let data = _data.object(forKey: "user") as! NSDictionary
                let name = data.stringAttributeForKey("name")
                let coverURL = data.stringAttributeForKey("cover")
                let urlCover = "http://img.nian.so/cover/\(coverURL)!cover"
                let imageHead = UIImageView(frame: CGRect(x: 60, y: 45, width: 40, height: 40))
                imageHead.layer.cornerRadius = 20
                imageHead.layer.masksToBounds = true
                imageHead.setHead(safeuid)
                self.imagePromo.contentMode = UIViewContentMode.scaleAspectFill
                self.imagePromo.addSubview(imageHead)
                if coverURL == "" {
                    self.imagePromo.image = UIImage(named: "bg")
                }else{
                    self.imagePromo.setImage(urlCover)
                }
                let labelName = UILabel(frame: CGRect(x: 0, y: imageHead.bottom()+10, width: 160, height: name.stringHeightWith(13, width: 160)))
                labelName.text = name
                labelName.textAlignment = NSTextAlignment.center
                labelName.textColor = UIColor.white
                labelName.font = UIFont.boldSystemFont(ofSize: 13)
                labelName.numberOfLines = 0
                self.imagePromo.addSubview(labelName)
                let textPromo = "来念找我玩"
                let label = UILabel(frame: CGRect(x: 0, y: labelName.bottom()+5, width: 160, height: textPromo.stringHeightWith(11, width: 160)))
                label.text = textPromo
                label.textAlignment = NSTextAlignment.center
                label.textColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 11)
                label.numberOfLines = 0
                self.imagePromo.addSubview(label)
            }
        }
        
        
        
        // 顶部
        let nib2 = Bundle.main.loadNibNamed("FindCellTop", owner: self, options: nil)
        self.viewFindCellTop = nib2?.first as! FindCellTop
        self.viewFindCellTop.viewLeft.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FindViewController.onTopClick(_:))))
        self.viewFindCellTop.viewMiddle.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FindViewController.onTopClick(_:))))
        self.viewFindCellTop.viewRight.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FindViewController.onTopClick(_:))))
        self.viewFindCellTop.imageLeft.image = UIImage(named: arrSelected[0])
        self.viewFindCellTop.frame.origin.y = 64
        self.view.addSubview(self.viewFindCellTop)
        
        // 底部
        self.tableView.tableFooterView = setupFooter("连接微博", funcButton: #selector(FindViewController.onWeiboClick))
        self.tableViewPhone.tableFooterView = setupFooter("开启通讯录", funcButton: #selector(FindViewController.onPhoneClick(_:)))
        
        self.view.addSubview(self.tableView)
        self.view.addSubview(self.tableViewPhone)
    }
    
    func onTopClick(_ sender:UIGestureRecognizer){
        self.viewFindCellTop.imageLeft.image = UIImage(named: arr[0])
        self.viewFindCellTop.imageMiddle.image = UIImage(named: arr[1])
        self.viewFindCellTop.imageRight.image = UIImage(named: arr[2])
        let tag = sender.view!.tag
        if tag == 1 {
            self.tableView.isHidden = false
            self.viewFindCellTop.imageLeft.image = UIImage(named: arrSelected[0])
        }else if tag == 2 {
            self.tableViewPhone.isHidden = false
            self.viewFindCellTop.imageMiddle.image = UIImage(named: arrSelected[1])
        }else if tag == 3 {
            self.viewFindCellTop.imageRight.image = UIImage(named: arrSelected[2])
        }
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.tableView.frame.origin.x = CGFloat(1 - tag) * globalWidth
            self.tableViewPhone.frame.origin.x = CGFloat(2 - tag) * globalWidth
            self.viewPromo.frame.origin.x = CGFloat(3 - tag) * globalWidth
        }, completion: { (Bool) -> Void in
            if tag == 1 {
                self.tableView.isHidden = false
            }else if tag == 2 {
                self.tableView.isHidden = true
                self.tableViewPhone.isHidden = false
            }else if tag == 3 {
                self.tableView.isHidden = true
                self.tableViewPhone.isHidden = true
            }
        }) 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.dataArray.count
        }else{
            return self.dataArrayPhone.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindCell", for: indexPath) as? FindCell
        let index = (indexPath as NSIndexPath).row
        if tableView == self.tableView {
            let data = self.dataArray[index] as! NSDictionary
            cell!.data = data
            cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FindViewController.onUserClick(_:))))
            cell!.setup()
            return cell!
        }else{
            let data = self.dataArrayPhone[index] as! NSDictionary
            cell!.data = data
            cell!.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FindViewController.onUserClick(_:))))
            cell!.setup()
            return cell!
        }
    }
    
    func onUserClick(_ sender:UIGestureRecognizer) {
        let tag = sender.view!.tag
        let UserVC = PlayerViewController()
        UserVC.Id = "\(tag)"
        self.navigationController?.pushViewController(UserVC, animated: true)
    }
    
    func onWeiboClick() {
        let request: WBAuthorizeRequest! = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = "https://api.weibo.com/oauth2/default.html"
        request.scope = "follow_app_official_microblog"
        WeiboSDK.send(request)
    }
    
    // 获得通讯录权限
    func onPhoneClick(_ sender: UIButton) {
        let addressBook = ContactsHelper()
        let status = addressBook.determineStatus()
        if status {
            self.transPhone()
        }else{
            sender.setTitle("发现通讯录", for: UIControlState())
            sender.removeTarget(self, action: #selector(FindViewController.onPhoneClick(_:)), for: UIControlEvents.touchUpInside)
            sender.addTarget(self, action: #selector(FindViewController.onPhoneFindClick), for: UIControlEvents.touchUpInside)
        }
    }
    
    // 搜索通讯录
    func onPhoneFindClick() {
        let addressBook = ContactsHelper()
        let status = addressBook.determineStatus()
        if status {
            self.transPhone()
        }else{
            self.tableViewPhone.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 64 - 75))
            self.tableViewPhone.tableFooterView?.addGhost("失败了\n念不能获得你的通讯录")
        }
    }
    
    // 将通讯录提交到数据库
    func transPhone() {
        self.viewLoadingShow()
        let addressBook = ContactsHelper()
        addressBook.createAddressBook()
        let list = addressBook.getContactNames()
        Api.postPhone(list) { json in
            self.viewLoadingHide()
            if json != nil {
                let arr = json!.object(forKey: "items") as! NSArray
                self.dataArrayPhone.removeAllObjects()
                for data in arr{
                    self.dataArrayPhone.add(data)
                }
                self.tableViewPhone!.reloadData()
                if self.dataArrayPhone.count == 0 {
                    self.tableViewPhone.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 64 - 75))
                    self.tableViewPhone.tableFooterView?.addGhost("手机里的好友们\n还没有来玩念")
                }else{
                    self.tableViewPhone.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 71
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "weibo"), object:nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(FindViewController.weibo(_:)), name: NSNotification.Name(rawValue: "weibo"), object: nil)
    }
    
    func weibo(_ sender: Notification) {
        self.viewLoadingShow()
        let object: NSArray? = sender.object as? NSArray
        if object != nil {
            let uid = "\(object![0])"
            let token = "\(object![1])"
            Api.getWeibo(uid, Token: token) { json in
                self.viewLoadingHide()
                if json != nil {
                    let arr = json!.object(forKey: "items") as! NSArray
                    self.dataArray.removeAllObjects()
                    for data  in arr{
                        self.dataArray.add(data)
                    }
                    self.tableView!.reloadData()
                    if self.dataArray.count == 0 {
                        self.tableViewPhone.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: globalHeight - 64 - 75))
                        self.tableViewPhone.tableFooterView?.addGhost("微博上的好友们\n还没有来玩念")
                    }else{
                        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 50))
                    }
                }
            }
        }
    }
    
    func setupTable() -> UITableView {
        let theTableView = UITableView(frame:CGRect(x: 0, y: 64 + 75, width: globalWidth, height: globalHeight - 64 - 75))
        theTableView.delegate = self
        theTableView.dataSource = self
        theTableView.backgroundColor = BGColor
        theTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        let nib = UINib(nibName:"FindCell", bundle: nil)
        theTableView.register(nib, forCellReuseIdentifier: "FindCell")
        return theTableView
    }
    
    func setupFooter(_ textButton: String, funcButton: Selector) -> UIView {
        let viewFooter = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 120))
        let btnConnect = UIButton()
        btnConnect.setButtonNice(textButton)
        viewFooter.addSubview(btnConnect)
        btnConnect.center = viewFooter.center
        btnConnect.addTarget(self, action: funcButton, for: UIControlEvents.touchUpInside)
        return viewFooter
    }
    
    func sharePromo() {
        let url:URL = URL(string: "http://nian.so/m/user/\(SAUid())")!
        imagePromo.layer.cornerRadius = 0
        let image = getImageFromView(imagePromo)
        var avc = SAActivityViewController.shareSheetInView([image, "来念上找我玩" as AnyObject, url as AnyObject], applicationActivities: [])
        avc = SAActivityViewController.shareSheetInView([image, "来念上找我玩" as AnyObject, url as AnyObject], applicationActivities: [], isStep: true)
        self.present(avc, animated: true, completion: { () -> Void in
            self.imagePromo.layer.cornerRadius = 8
        })
    }
    
}
