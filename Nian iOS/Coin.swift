//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class CoinViewController: UIViewController, UIGestureRecognizerDelegate{
    @IBOutlet var scrollView:UIScrollView!
    
    override func viewDidLoad(){
        setupViews()
    }
    
    func setupViews(){
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        self.scrollView.frame = CGRectMake(0, 0, globalWidth, globalHeight)
        self.scrollView.contentSize = CGSizeMake(globalWidth, 820)
        self.view.backgroundColor = BGColor
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}