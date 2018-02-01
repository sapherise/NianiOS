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
    @IBOutlet weak var sp6HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sp7HeightConstraint: NSLayoutConstraint!
    @IBOutlet var viewSteps: UIView!
    @IBOutlet var viewLikeSteps: UIView!
    @IBOutlet var viewLikeDreams: UIView!
    @IBOutlet var viewFollowDreams: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self._setTitle("收藏")
        self.setSeperateViewHeight()
        self.view.backgroundColor = UIColor.C96()
        self.automaticallyAdjustsScrollViewInsets = false
        viewSteps.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActivitiesViewController.onSteps)))
        viewLikeSteps.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActivitiesViewController.onLikeSteps)))
        viewLikeDreams.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActivitiesViewController.onLikeDreams)))
        viewFollowDreams.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActivitiesViewController.onFollowDreams)))
    }
    
    func onSteps() {
        let vc = MySteps()
        vc.type = CollectType.mysteps
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func onLikeSteps() {
        let vc = MySteps()
        vc.type = CollectType.likesteps
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func onLikeDreams() {
        let vc = ExploreNext()
        vc.type = 3
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func onFollowDreams() {
        let vc = ExploreNext()
        vc.type = 4
        self.navigationController?.pushViewController(vc, animated: true)
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
    }
}












