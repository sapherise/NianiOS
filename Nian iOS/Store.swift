//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class StoreViewController: UIViewController, UIGestureRecognizerDelegate{
    
    override func viewDidLoad(){
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    func setupViews(){
        self.view.backgroundColor = BGColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "念铺"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}