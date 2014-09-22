//
//  YRImageViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-7.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

class SAImageViewController: UIViewController, UIGestureRecognizerDelegate{
    
    var imageURL:String = ""
    var imageZoongView:SAImageZoomingView!
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews()
    {
        self.navigationController!.navigationBar.tintColor = IconColor
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.text = "图片"
        titleLabel.textColor = IconColor
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        var theview:UIView = UIView(frame: CGRectMake(0, 0, 320, 568-64))
        self.view.addSubview(theview)
        
        self.imageZoongView = SAImageZoomingView(frame:theview.frame)
        self.imageZoongView.imageURL = self.imageURL
        theview.addSubview(self.imageZoongView)
        self.view.backgroundColor = BGColor
        
        viewBack(self)
        self.navigationController!.interactivePopGestureRecognizer.delegate = self
        
        
//        
        var longTap = UILongPressGestureRecognizer(target: self, action: "longTapped:")
        longTap.minimumPressDuration = 0.5
        self.imageZoongView.addGestureRecognizer(longTap)
    }
    
    func longTapped(sender:UILongPressGestureRecognizer){
        if sender.state == UIGestureRecognizerState.Began {
            var url = NSURL.URLWithString(imageURL)
            var cacheFilename = url.lastPathComponent
            var cachePath = FileUtility.cachePath(cacheFilename)
            var image : AnyObject = FileUtility.imageDataFromPath(cachePath)
            let activityViewController = UIActivityViewController(
                activityItems: [ "喜欢念上的这张照片。http://nian.so", image ],
                applicationActivities: nil)
            
            activityViewController.excludedActivityTypes = [
                UIActivityTypeAssignToContact,
                UIActivityTypePrint,
                UIActivityTypeCopyToPasteboard,
                UIActivityTypeMail,
                UIActivityTypeMessage
            ]
            //        activityViewController.excludedActivityTypes =  [
            //            UIActivityTypePostToTwitter,
            //            UIActivityTypePostToFacebook,
            //            UIActivityTypePostToWeibo,
            //            UIActivityTypeMessage,
            //            UIActivityTypeMail,
            //            UIActivityTypePrint,
            //            UIActivityTypeCopyToPasteboard,
            //            UIActivityTypeAssignToContact,
            //            UIActivityTypeSaveToCameraRoll,
            //            UIActivityTypeAddToReadingList,
            //            UIActivityTypePostToFlickr,
            //            UIActivityTypePostToVimeo,
            //            UIActivityTypePostToTencentWeibo
            //        ]
            ///
            self.presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
}
