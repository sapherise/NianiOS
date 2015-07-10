//
//  PetViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 7/7/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

class PetViewController: UIViewController {
    
    let BUBBLE_DIAMETER: CGFloat = 100.0
    let BUBBLE_PADDING: CGFloat  = 10.0
    
    @IBOutlet weak var petInfo: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var index: UILabel!
    @IBOutlet weak var upgrade: UILabel!
    @IBOutlet weak var step: UILabel!
    @IBOutlet weak var listener: UILabel!
    @IBOutlet weak var good: UILabel!
    

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupView()
        
        setupCell()
        
        // 通过网络请求数据
        
        
        
    }
    
    func setupView() {
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "宠物"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
    }
    
    func setupCell() {
        var totalNum = 100
        
        for item in self.contentView.subviews {
            (item as! UIView).removeFromSuperview()
        }
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        var x: CGFloat = CGFloat((self.scrollView.frame.size.width - BUBBLE_DIAMETER) / 2.0)
        var y: CGFloat = CGFloat((self.scrollView.frame.size.height - BUBBLE_DIAMETER) / 2.0)
        
        var i = 0
        for(; i < totalNum; ++i) {
            var frame = CGRectMake(x, y, BUBBLE_DIAMETER, BUBBLE_DIAMETER)
            var imgView: UIImageView = UIImageView(frame: frame)
            imgView.contentMode = UIViewContentMode.Center
            imgView.image = UIImage(named: "reset_password")
            imgView.backgroundColor = UIColor.colorWithHex("5a62d2")
            imgView.layer.cornerRadius = frame.size.width / 2.0
            imgView.layer.masksToBounds = true
            imgView.autoresizingMask = UIViewAutoresizing.FlexibleTopMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleRightMargin
            
            self.contentView.addSubview(imgView)
            x += CGFloat(BUBBLE_DIAMETER + BUBBLE_PADDING)
        }
        
        self.contentViewWidthConstraint.constant = x + (self.scrollView.frame.size.width) / 2.0
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
}


extension PetViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.snapToNearestItem()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.snapToNearestItem()
    }

    func snapToNearestItem() {
        var targetOffset = self.nearestTargetOffsetForOffset(self.scrollView.contentOffset)
        self.scrollView.setContentOffset(targetOffset, animated: true)
    }
    
    func nearestTargetOffsetForOffset(offset: CGPoint) -> CGPoint {
        var pageSize = CGFloat(BUBBLE_DIAMETER + BUBBLE_PADDING)
        var page: NSInteger = NSInteger(roundf(Float(offset.x / pageSize)))
        var targetX = pageSize * CGFloat(page)
        
        return CGPointMake(targetX, offset.y)
    }
}