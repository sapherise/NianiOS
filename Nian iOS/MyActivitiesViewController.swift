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
    case myResponse
}


class MyActivitiesViewController: SAViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var activityType: ActivityType? {
        didSet {
            switch activityType! {
            case .myStep:
//                self.tableView.registerNib(<#T##nib: UINib?##UINib?#>, forCellReuseIdentifier: <#T##String#>)
                break
            case .myLikeStep:
                break
            case .myTopic:
                break
            case .myResponse:
                break
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }
    
    
    
    

}


extension MyActivitiesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        return cell
    }

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }




}























