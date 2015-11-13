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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("我的动态")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension ActivitiesViewController {
    
    /**
     <#Description#>
     */
    @IBAction func tapOnMyStep(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

    /**
     <#Description#>
     */
    @IBAction func tapOnGoodStep(sender: UITapGestureRecognizer) {
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
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

    /**
     <#Description#>
     */
    @IBAction func tapOnMyResponse(sender: UITapGestureRecognizer) {
        self.performSegueWithIdentifier("toTableView", sender: nil)
    }

}















