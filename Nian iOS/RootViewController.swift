////
////  RootViewController.swift
////  ACSSegmentedViewController
////
////  Created by Albert Chu on 14/6/30.
////  Copyright (c) 2014年 ACS. All rights reserved.
////
//
//import UIKit
//
//class RootViewController: UIViewController,CountUpDelegate{
//    
//    var currentViewController: UIViewController?
//    var currentIndex: Int?
//    var oldvc:Int?
//    var newvc:Int?
//    
//    
//    var viewControllers: Array<UIViewController> = [ExploreViewController(), UIStoryboard(name: "ExploreDream", bundle: nil).instantiateViewControllerWithIdentifier("ExploreDreamViewController") as UIViewController]
//    
//    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        
//        var segmentedControl:UISegmentedControl = UISegmentedControl(frame: CGRectMake(0, 0, 320, 51))
//        segmentedControl.addTarget(self,action: "segmentedControlSelected",forControlEvents: UIControlEvents.ValueChanged)
//        
//        segmentedControl.insertSegmentWithTitle("话题",atIndex: 0,animated: false)
//        segmentedControl.insertSegmentWithTitle("梦想",atIndex: 1,animated: false)
//        segmentedControl.sizeToFit()
//        segmentedControl.selectedSegmentIndex = 0
//        self.currentIndex = 0
//        
//        for viewController: UIViewController in self.viewControllers {
//            viewController.view.frame = self.view.bounds
//            self.addChildViewController(viewController)
//        }
//        self.currentViewController = self.childViewControllers[0] as? UIViewController
//       // self.view.addSubview(viewControllers[0].view)
//        self.view.addSubview(segmentedControl)
//    }
//    
//    func segmentedControlSelected() -> Void {
//        if self.currentIndex == 0 {
//            self.oldvc = 0
//            self.newvc = 1
//        }else{
//            self.oldvc = 1
//            self.newvc = 0
//        }
//        self.transitionFromViewController(
//            self.childViewControllers[self.oldvc!] as UIViewController,
//            toViewController: self.childViewControllers[self.newvc!] as UIViewController,
//            duration: 0.0,
//            options: UIViewAnimationOptions.TransitionNone,
//            animations: nil,
//            completion: { (finished: Bool) in
//                if finished {
//                    self.currentViewController = self.childViewControllers[self.newvc!] as? UIViewController
//                    self.currentIndex = self.newvc!
//                }
//            }
//        )
//    }
//    
//    func countUp() {        //😍    我的工作职责
//        println("WTF?")
//    }
//    
//}
