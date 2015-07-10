//
//  ExploreDynamicCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/14.
//  Copyright (c) 2014年 Sa. All rights reserved.
//

import UIKit

//import UIKit

class ExploreDynamicProvider: ExploreProvider, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, delegateSAStepCell{
    
    class Data {
        var id: String!
        var sid: String!
        var uid: String!
        var user: String!
        var content: String!
        var lastdate: String!
        var title: String!
        var img: String!
        var img0: Float!
        var img1: Float!
        var like: Int!
        var liked: Int!
        var comment: Int!
        var uidlike: String!
        var userlike: String!
        var type: Int!
    }
    
    weak var bindViewController: ExploreViewController?
    var page = 1
    var dataArray = NSMutableArray()
    
    init(viewController: ExploreViewController) {
        self.bindViewController = viewController
        viewController.dynamicTableView.registerNib(UINib(nibName: "ExploreDynamicDreamCell", bundle: nil), forCellReuseIdentifier: "ExploreDynamicDreamCell")
        viewController.dynamicTableView.registerNib(UINib(nibName: "SAStepCell", bundle: nil), forCellReuseIdentifier: "SAStepCell")
    }
    
    func load(clear: Bool) {
        if clear {
            page = 1
        }
        Api.getExploreDynamic("\(page++)", callback: {
            json in
            if json != nil {
                globalTab[1] = false
                var data = json!["data"]
                var items = data!!["items"] as! NSArray
                if items.count != 0 {
                    if clear {
                        self.dataArray.removeAllObjects()
                    }
                    for item in items {
                        self.dataArray.addObject(item)
                    }
                    self.bindViewController?.dynamicTableView.tableHeaderView = nil
                }else if clear {
                    var viewHeader = UIView(frame: CGRectMake(0, 0, globalWidth, 400))
                    var viewQuestion = viewEmpty(globalWidth, content: "这是动态页面！\n你关注的人赞过的内容\n都会出现在这里")
                    viewQuestion.setY(50)
                    viewHeader.addSubview(viewQuestion)
                    self.bindViewController?.dynamicTableView.tableHeaderView = viewHeader
                }
                if self.bindViewController!.current == 1 {
                    self.bindViewController?.dynamicTableView.headerEndRefreshing()
                    self.bindViewController?.dynamicTableView.footerEndRefreshing()
                    self.bindViewController?.dynamicTableView.reloadData()
                }
            }
        })
    }
    
    override func onHide() {
        bindViewController!.dynamicTableView.headerEndRefreshing(animated: false)
    }
    
    override func onShow(loading: Bool) {
        bindViewController!.dynamicTableView.reloadData()
        if dataArray.count == 0 {
            bindViewController!.dynamicTableView.headerBeginRefreshing()
        } else {
            if loading {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.bindViewController!.dynamicTableView.setContentOffset(CGPointZero, animated: false)
                    }, completion: { (Bool) -> Void in
                        self.bindViewController!.dynamicTableView.headerBeginRefreshing()
                })
            }
        }
    }
    
    override func onRefresh() {
        load(true)
    }
    
    override func onLoad() {
        load(false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var viewController = DreamViewController()
        var data = self.dataArray[indexPath.row] as! NSDictionary
        var id = data.stringAttributeForKey("dream")
        viewController.Id = id
        bindViewController!.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var data = dataArray[indexPath.row] as! NSDictionary
        var type = data.stringAttributeForKey("type")
        switch type {
        case "0":
            return 77
        case "1":
            var h = SAStepCell.cellHeightByData(data)
            return h
        default:
            break
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = nil
        var data = dataArray[indexPath.row] as! NSDictionary
        var type = data.stringAttributeForKey("type")
        switch type {
        case "0":
            var c = tableView.dequeueReusableCellWithIdentifier("ExploreDynamicDreamCell", forIndexPath: indexPath) as? ExploreDynamicDreamCell
//            dreamCell!.bindData(data, tableview: tableView)
            var data = dataArray[indexPath.row] as! NSDictionary
            c?.data = data
            if indexPath.row == self.dataArray.count - 1 {
                c!.viewLine.hidden = true
            }else{
                c!.viewLine.hidden = false
            }
            cell = c
            break
        case "1":
            var c = tableView.dequeueReusableCellWithIdentifier("SAStepCell", forIndexPath: indexPath) as! SAStepCell
            c.delegate = self
            c.isDynamic = true
            c.data = self.dataArray[indexPath.row] as! NSDictionary
            c.index = indexPath.row
            if indexPath.row == self.dataArray.count - 1 {
                c.viewLine.hidden = true
            } else {
                c.viewLine.hidden = false
            }
            cell = c
            
            break
        default:
            break
        }
        return cell!
    }
    
    // 更新数据
    func updateStep(index: Int, key: String, value: String) {
        SAUpdate(self.dataArray, index, key, value, bindViewController!.dynamicTableView!)
    }
    
    // 更新某个格子
    func updateStep(index: Int) {
        SAUpdate(index, 0, bindViewController!.dynamicTableView!)
    }
    
    // 重载表格
    func updateStep() {
        SAUpdate(bindViewController!.dynamicTableView!)
    }
    
    // 删除某个格子
    func updateStep(index: Int, delete: Bool) {
        SAUpdate(delete, self.dataArray, index, bindViewController!.dynamicTableView!, 0)
    }
}

class ExploreDynamicDreamCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    override func awakeFromNib() {
        imageCover.setX(globalWidth - 52)
        self.viewLine.setWidth(globalWidth - 40)
    }
    
    override func layoutSubviews() {
        var uidlike = data.stringAttributeForKey("uidlike")
        var userlike = data.stringAttributeForKey("userlike")
        var img = data.stringAttributeForKey("image")
        var title = data.stringAttributeForKey("title").decode()
        self.imageHead.setHead(uidlike)
        self.imageCover.setImage("http://img.nian.so/dream/\(img)!dream", placeHolder: IconColor)
        self.labelName.text = userlike
        self.labelDream.text = "赞了「\(title)」"
        self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        self.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
    }
    
    func onUserClick() {
        var uid = data.stringAttributeForKey("uidlike")
        var userVC = PlayerViewController()
        userVC.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(userVC, animated: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageCover.cancelImageRequestOperation()
        self.imageCover.image = nil
    }
    
}