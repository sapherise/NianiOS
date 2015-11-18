//
//  ActivitiesViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/12/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class ActivitiesViewController: SAViewController {
    
    @IBOutlet weak var myStepLabel: UILabel!
    
    @IBOutlet weak var myGoodStepLabel: UILabel!
    
    @IBOutlet weak var myGoodNoteLabel: UILabel!
    
    @IBOutlet weak var myTopicLabel: UILabel!
    
    @IBOutlet weak var myResponseLabel: UILabel!
    
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp4HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp5HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp6HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp7HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp8HeightConstraint: NSLayoutConstraint!
    
    var tmpType: ActivityType?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("我的动态")
        self.setSeperateViewHeight()
        self.view.backgroundColor = UIColor.colorWithHex("#F5F5F5")
        
        self.startAnimating()
        
        ActivitiesSummaryModel.getMyAcitiviesSummary({[unowned self]
            (task, responseObject, error) -> Void in
            
            self.stopAnimating()
            
            if let _ = error {
                self.view.showTipText("网络有点问题，等一会儿再试")
            } else {
                
                let json = JSON(responseObject!)
                
                if json["error"] != 0 {
                    
                } else {
                    let _data = json["data"].dictionaryObject!
                    
                    self.myStepLabel.text = _data["total_steps"] as? String
                    self.myGoodStepLabel.text = _data["liked_steps"] as? String
                    self.myGoodNoteLabel.text = _data["liked_dreams"] as? String
                    self.myTopicLabel.text = _data["total_topics"] as? String
                    self.myResponseLabel.text = _data["total_replies"] as? String
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "toTableView" {
            let myActivitiesVC = segue.destinationViewController as! MyActivitiesViewController
            myActivitiesVC.tmpType = self.tmpType
            
        }
    }

}


extension ActivitiesViewController {
    
    /**
     <#Description#>
     */
    @IBAction func tapOnMyStep(sender: UITapGestureRecognizer) {
        self.tmpType = .myStep
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

    /**
     <#Description#>
     */
    @IBAction func tapOnGoodStep(sender: UITapGestureRecognizer) {
        self.tmpType = .myLikeStep
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

    /**
     <#Description#>
     */
    @IBAction func tapOnGoodNote(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("toCollectionView", sender: nil)
    }

    /**
     <#Description#>
     */
    @IBAction func tapOnMyTopic(sender: UITapGestureRecognizer) {
        self.tmpType = .myTopic
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

    /**
     <#Description#>
     */
    @IBAction func tapOnMyResponse(sender: UITapGestureRecognizer) {
        self.tmpType = .myResponsedTopic
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

}


extension ActivitiesViewController {
    
    func setSeperateViewHeight() {
        sp1HeightConstraint.constant = globalHalf   
        sp2HeightConstraint.constant = globalHalf
        sp3HeightConstraint.constant = globalHalf
        sp4HeightConstraint.constant = globalHalf
        sp5HeightConstraint.constant = globalHalf
        sp6HeightConstraint.constant = globalHalf
        sp7HeightConstraint.constant = globalHalf
        sp8HeightConstraint.constant = globalHalf
    }
}












