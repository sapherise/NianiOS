//
//  MyActivitiesViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/16/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

enum ActivityType: Int {
    case myStep
    case myLikeStep
    case myTopic
    case myResponsedTopic
}


class MyActivitiesViewController: SAViewController {
    
    @IBOutlet weak var tableView: VVeboTableView!
    @IBOutlet weak var topicTableView: UITableView!
    
    var currentTableIndex: Int?
    
    var tmpType: ActivityType?
    var tableDataSource = NSMutableArray()
    
    var activityUrl: String = ""
    var page = 1
    var isLoading = false
    
    let _uid = CurrentUser.sharedCurrentUser.uid!
    let _shell = CurrentUser.sharedCurrentUser.shell!
    
    private var activityType: ActivityType? {
        didSet {
            switch activityType! {
            case .myStep:
                self._setTitle("我的进展")
                self.activityUrl = "user/\(_uid)/steps?page=\(page)&&uid=\(_uid)&&shell=\(_shell)"
                self.topicTableView.hidden = true
                self.tableView.registerClass(VVeboCell.self, forCellReuseIdentifier: "myStepCell")
            case .myLikeStep:
                self._setTitle("我赞过的进展")
                self.activityUrl = "user/\(_uid)/like/steps?page=\(page)&&uid=\(_uid)&&shell=\(_shell)"
                self.topicTableView.hidden = true
                self.tableView.registerClass(VVeboCell.self, forCellReuseIdentifier: "myLikeStepCell")
            case .myTopic:
                self._setTitle("我发起的话题")
                self.activityUrl = "user/\(_uid)/topics?uid=\(_uid)&&shell=\(_shell)&&type=topic&&page=\(page)"
                self.tableView.hidden = true
                self.topicTableView.registerNib(UINib(nibName: "RedditCell", bundle: nil), forCellReuseIdentifier: "RedditCell")
            case .myResponsedTopic:
                self._setTitle("我回应的话题")
                self.activityUrl = "user/\(_uid)/topics?uid=\(_uid)&&shell=\(_shell)&&type=reply&&page=\(page)"
                self.tableView.hidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.activityType = self.tmpType
        
        self.tableView.addHeaderWithCallback{ self.load() }
        self.tableView.addFooterWithCallback{ self.load(false) }
        
        self.topicTableView.addHeaderWithCallback{ self.load() }
        self.topicTableView.addFooterWithCallback{ self.load(false) }
        
        if self.tableView.hidden  {
            currentTableIndex = 0
            self.topicTableView.headerBeginRefreshing()
        } else {
            currentTableIndex = 1
            self.tableView.headerBeginRefreshing()
        }
    }
    
    
    func load(clear: Bool = true) {
        if !isLoading {
            isLoading = true
            
            if clear {
                page = 1
            }
    
            ActivitiesSummaryModel.getMyActitvity(url: self.activityUrl, callback: {
                (_, responseObject, error) -> Void in
                
                let json = self.handleBaseJsonWithError(error, id: responseObject)
                
                if let _json = json {
                    if clear {
                        self.tableDataSource.removeAllObjects()
                    }
                    
                    if self.activityType! == .myStep {
                        self.tableDataSource.addObjectsFromArray(_json["data"]["steps"].arrayObject!)
                    } else {
                        self.tableDataSource.addObjectsFromArray(_json["data"].arrayObject!)
                    }
                    
                    if self.currentTableIndex == 0 {
                        self.topicTableView.reloadData()
                        clear ? self.topicTableView.headerEndRefreshing() : self.topicTableView.footerEndRefreshing()
                    } else {
                        self.tableView.reloadData()
                        clear ? self.tableView.headerEndRefreshing() : self.tableView.footerEndRefreshing()
                    }
                    
                    self.page++
                    self.isLoading = false
                }
            })
        }
    }
    

}


extension MyActivitiesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch activityType! {
        case .myStep:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("myStepCell") as? VVeboCell
            cell?.type = 1
            self.tableView.drawCell(cell!, indexPath: indexPath, dataArray: self.tableDataSource)
            cell?.delegate = self
            
            return cell!
            
        case .myLikeStep:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("myLikeStepCell") as? VVeboCell
            cell?.type = 0
            self.tableView.drawCell(cell!, indexPath: indexPath, dataArray: self.tableDataSource)
            cell?.delegate = self
            
            return cell!
            
        case .myTopic:
            let cell = self.topicTableView.dequeueReusableCellWithIdentifier("RedditCell") as? RedditCell
            cell?.index = indexPath.row
            cell?.data = self.tableDataSource[indexPath.row] as! NSDictionary
            cell?.delegate = self
            
            return cell!
            
        case .myResponsedTopic:
            let cell = self.topicTableView.dequeueReusableCellWithIdentifier("responsedTopicCell") as? RedditCell
            cell?.index = indexPath.row
            cell?.data = self.tableDataSource[indexPath.row] as! NSDictionary
            cell?.delegate = self
            
            return cell!

        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch activityType! {
        case .myStep:
            fallthrough
        case .myLikeStep:
            self.tableDataSource.replaceObjectAtIndex(indexPath.row,
                withObject: VVeboCell.SACellDataRecode(self.tableDataSource[indexPath.row] as! NSDictionary))
            
            return self.tableView.getHeight(indexPath, dataArray: self.tableDataSource)
        case .myTopic:
            fallthrough
        case .myResponsedTopic:
            let data = self.tableDataSource[indexPath.row] as! NSDictionary
            let title = data.stringAttributeForKey("title").decode()
            let content = data.stringAttributeForKey("content").decode().toRedditReduce()
            var hTitle = title.stringHeightWith(16, width: globalWidth - 80)
            var hContent = content.stringHeightWith(12, width: globalWidth - 80)
            let hTitleMax = "\n".stringHeightWith(16, width: globalWidth - 80)
            let hContentMax = "\n\n\n".stringHeightWith(12, width: globalWidth - 80)
            hTitle = min(hTitle, hTitleMax)
            hContent = min(hContent, hContentMax)
            
            return hTitle + hContent + 99
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if currentTableIndex == 0 {
            if self.activityType! == .myTopic {
                let data = tableDataSource[indexPath.row] as! NSDictionary
                let id = data.stringAttributeForKey("id")
                let vc = TopicViewController()
                vc.id = id
                vc.index = indexPath.row
                vc.delegate = self
                vc.dataArrayTopLeft = NSMutableDictionary(dictionary: data)
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else if self.activityType! == .myResponsedTopic {
                let data = tableDataSource[indexPath.row] as! NSDictionary
                let id = data.stringAttributeForKey("id")
                let vc = TopicViewController()
                vc.id = id
                vc.index = indexPath.row
                vc.delegate = self
                vc.dataArrayTopLeft = NSMutableDictionary(dictionary: data)
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else if currentTableIndex == 1 {
            let dreamVC = DreamViewController()
            let data = self.tableDataSource[indexPath.row] as! NSDictionary
            dreamVC.Id = data.stringAttributeForKey("dream")
            
            self.navigationController?.pushViewController(dreamVC, animated: true)
        }
    }

}


extension MyActivitiesViewController: delegateSAStepCell {

    func updateStep(index: Int, key: String, value: AnyObject) {
        
    }
    
    func updateStep(index: Int) {
        
    }
    
    func updateStep() {
        
    }
    
    func updateStep(index: Int, delete: Bool) {

    }
}

extension MyActivitiesViewController: RedditDelegate {
    
    func updateData(index: Int, key: String, value: String, section: Int) {
        
    }
    
    func updateTable() {
        
    }
    
}









