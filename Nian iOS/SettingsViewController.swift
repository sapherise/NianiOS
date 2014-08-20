//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController: UIViewController{
    @IBOutlet var scrollView:UIScrollView!
    @IBOutlet var head:UIImageView!
    @IBOutlet var name:UIView!
    @IBOutlet var email:UIView!
    @IBOutlet var exp:UIView!
    @IBOutlet var glory:UIView!
    @IBOutlet var lab:UIView!
    @IBOutlet var logout:UIView!
    @IBOutlet var label1:UILabel!
    @IBOutlet var label2:UILabel!
    @IBOutlet var label3:UILabel!
    
    override func viewDidLoad(){
        setupViews()
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
    
    func setupViews(){
        self.view.backgroundColor = BGColor
        self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 170)
        
        var img = "1.jpg"
        var userImageURL = "http://img.nian.so/head/\(img)!head"
        self.head.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        
        self.name.backgroundColor = BGColor
        self.email.backgroundColor = BGColor
        self.exp.backgroundColor = BGColor
        self.glory.backgroundColor = BGColor
        self.lab.backgroundColor = BGColor
        self.logout.backgroundColor = BGColor
        
        self.label1.textColor = BlueColor
        self.label2.textColor = BlueColor
        self.label3.textColor = BlueColor
        
    }
}