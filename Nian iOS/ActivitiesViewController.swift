//
//  ActivitiesViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/12/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class ActivitiesViewController: SAViewController {
    
    @IBOutlet weak var sp1HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp3HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp4HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp5HeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._setTitle("收藏")
        self.setSeperateViewHeight()
        self.view.backgroundColor = UIColor.C96()
        self.automaticallyAdjustsScrollViewInsets = false
    }
}

extension ActivitiesViewController {
    func setSeperateViewHeight() {
        sp1HeightConstraint.constant = globalHalf   
        sp2HeightConstraint.constant = globalHalf
        sp3HeightConstraint.constant = globalHalf
        sp4HeightConstraint.constant = globalHalf
        sp5HeightConstraint.constant = globalHalf
    }
}












