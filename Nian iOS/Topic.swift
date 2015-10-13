//
//  Topic.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class TopicViewController: SAViewController, getCommentDelegate, UITableViewDataSource, UITableViewDelegate, TopicDelegate, RedditDelegate, RedditTopDelegate, RedditDeleteDelegate {
    var tableViewLeft: UITableView!
    var tableViewRight: UITableView!
    var id: String = ""
    var pageLeft: Int = 1
    var pageRight: Int = 1
    var dataArrayLeft = NSMutableArray()
    var dataArrayRight = NSMutableArray()
    var dataArrayTopLeft: NSMutableDictionary?
    var dataArrayTopRight: NSMutableDictionary?
    var delegate: RedditDelegate?
    var index: Int = -1 // 这是用来与 Reddit 建立 Delegate 的值
    var current: Int = 0 // 这是最热与最新的值，默认为最热
    
    var actionSheetDelete: UIActionSheet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        viewBackFix()
    }
    
    func setupViews() {
        _setTitle("话题")
        let btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "more")
        btnMore.image = UIImage(named: "more")
        self.navigationItem.rightBarButtonItems = [btnMore]
    }
    
    /**
    Nav Bar 上的 navBtn 事件(right bar button)
    */
    func more() {
        if dataArrayTopLeft != nil {
            let title = dataArrayTopLeft!.stringAttributeForKey("title")
            
            let acReport = SAActivity()
            acReport.saActivityTitle = "举报"
            acReport.saActivityType = "举报"
            acReport.saActivityImage = UIImage(named: "av_report")
            acReport.saActivityFunction = {
                self.view.showTipText("举报好了！", delay: 2)
            }
            
            //删除按钮
            let deleteActivity = SAActivity()
            deleteActivity.saActivityTitle = "删除"
            deleteActivity.saActivityType = "删除"
            deleteActivity.saActivityImage = UIImage(named: "av_delete")
            deleteActivity.saActivityFunction = {
                self.actionSheetDelete = UIActionSheet(title: "再见了，话题", delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
                self.actionSheetDelete.addButtonWithTitle("确定")
                self.actionSheetDelete.addButtonWithTitle("取消")
                self.actionSheetDelete.cancelButtonIndex = 1
                self.actionSheetDelete.showInView((self.view)!)
            }
            
            //编辑按钮
            let editActivity = SAActivity()
            editActivity.saActivityTitle = "编辑"
            editActivity.saActivityType = "编辑"
            editActivity.saActivityImage = UIImage(named: "av_edit")
            editActivity.saActivityFunction = {
                let addTopicVC = AddTopic(nibName: "AddTopic", bundle: nil)
                addTopicVC.isEdit = 1
                addTopicVC.dict = self.dataArrayTopLeft!
                addTopicVC.id = self.id
                addTopicVC.delegate = self
                self.navigationController?.pushViewController(addTopicVC, animated: true)
            }
            
            
            var arr = [UIActivity]()
            let _user_id = self.dataArrayTopLeft!["user_id"] as! String
            
            if index == 0 {
                if _user_id == SAUid() {
                    arr = [acReport, deleteActivity, editActivity]
                } else {
                    arr = [acReport]
                }
            } else {
                if _user_id == SAUid() {
                    arr = [acReport, deleteActivity, editActivity]
                } else {
                    arr = [acReport]
                }
            }
            let avc = SAActivityViewController.shareSheetInView(["「\(title)」- 来自念", NSURL(string: "http://nian.so/m/bbs/\(self.id)")!], applicationActivities: arr)
            self.presentViewController(avc, animated: true, completion: nil)
        }
    }
}

extension TopicViewController: UIActionSheetDelegate {
    /**
    目前主要是删除梦想，and 通过 delegate 删除并刷新 Reddit tableView
    */
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheetDelete {
            
            if buttonIndex == 0 {
                /* 删除“关注”下的 topic */
                Api.getTopicDelete(self.id, callback: {
                    json in
                    if json != nil {
                        let error = json!.objectForKey("error") as! NSNumber
                        if error == 0 {
                            self.delegate?.deleteCellInTable?(self.index)
                            self.delegate?.updateTable()
                            self.navigationController?.popViewControllerAnimated(true)
                        }
                    }
                })
            }
        }
    }
}

extension TopicViewController: editRedditDelegate {
    func editDream(editPrivate: Int, editTitle: String, editDes: String, editImage: String, editTags: Array<String>) {
        
    }
}




