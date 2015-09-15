//
//  Topic.swift
//  Nian iOS
//
//  Created by Sa on 15/8/30.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class TopicViewController: SAViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViews()
    }
    
    override func viewDidAppear(animated: Bool) {
        viewBackFix()
    }
    
    func setupViews() {
        _setTitle("话题")
        let btnMore = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "more")
        btnMore.image = UIImage(named: "more")
        self.navigationItem.rightBarButtonItems = [btnMore]
    }
    
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
            let arr = [acReport]
            let avc = SAActivityViewController.shareSheetInView(["「\(title)」- 来自念", NSURL(string: "http://nian.so/m/bbs/\(self.id)")!], applicationActivities: arr)
            self.presentViewController(avc, animated: true, completion: nil)
        }
        
    }
}