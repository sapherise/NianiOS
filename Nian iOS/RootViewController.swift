//
//  RootViewController.swift
//  ACSSegmentedViewController
//
//  Created by Albert Chu on 14/6/30.
//  Copyright (c) 2014年 ACS. All rights reserved.
//

import UIKit

class RootViewController: UIViewController,CountUpDelegate{
    
    var segmentedControl:UISegmentedControl = UISegmentedControl(frame: CGRectMake(30, 5, 140, 27))
    var currentViewController: UIViewController?
    var currentIndex: Int?
    
    
    var viewControllers: Array<UIViewController> = [ExploreViewController(), UIStoryboard(name: "ExploreDream", bundle: nil).instantiateViewControllerWithIdentifier("ExploreDreamViewController") as UIViewController]
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.navigationItem.titleView = self.segmentedControl
        self.segmentedControl.addTarget(self,action: "segmentedControlSelected",forControlEvents: UIControlEvents.ValueChanged)
        
            self.segmentedControl.insertSegmentWithTitle("话题",atIndex: 0,animated: false)
            self.segmentedControl.insertSegmentWithTitle("梦想",atIndex: 1,animated: false)
        self.segmentedControl.sizeToFit()
        self.segmentedControl.selectedSegmentIndex = 0
        self.currentIndex = 0
        
        self.hellochild()
        
        for viewController: UIViewController in self.viewControllers {
            viewController.view.frame = self.view.bounds
            self.addChildViewController(viewController)
        }
        self.currentViewController = self.childViewControllers[0] as? UIViewController
        self.view.addSubview(viewControllers[0].view)
    }
    
    func segmentedControlSelected() -> Void {
        if self.currentIndex == 0 {
        self.transitionFromViewController(
            self.childViewControllers[0] as UIViewController,
            toViewController: self.childViewControllers[1] as UIViewController,
            duration: 0.0,
            options: UIViewAnimationOptions.TransitionNone,
            animations: nil,
            completion: { (finished: Bool) in
                if finished {
                    self.currentViewController = self.childViewControllers[1] as? UIViewController
                    self.currentIndex = 1
                    println(self.childViewControllers[1])
                }
            }
        )
        }else{
            self.transitionFromViewController(
                self.childViewControllers[1] as UIViewController,
                toViewController: self.childViewControllers[0] as UIViewController,
                duration: 0.0,
                options: UIViewAnimationOptions.TransitionNone,
                animations: nil,
                completion: { (finished: Bool) in
                    if finished {
                        self.currentViewController = self.childViewControllers[0] as? UIViewController
                        self.currentIndex = 0
                        println(self.currentIndex)
                    }
                }
            )
        }
    }
    func hellochild(){
    }
    
    func countUp() {        //😍    我的工作职责
        self.segmentedControlSelected()
    }
    
}
