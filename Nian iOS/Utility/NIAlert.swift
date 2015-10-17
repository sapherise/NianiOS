//
//  NIAlert.swift
//  Nian iOS
//
//  Created by WebosterBob on 6/23/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

/**
*  NIAlert Delegate
*/
@objc protocol NIAlertDelegate {
    
    /**
    <#Description#>
    */
    optional func niAlert(niAlert: NIAlert, didselectAtIndex: Int)
    optional func niAlert(niAlert: NIAlert, tapBackground: Bool)
}


enum showAnimationStyle: Int {
    case spring   // 弹簧效果
    case flip     // 反转效果
}

enum dismissAnimationStyle: Int {
    case normal   // 弹簧效果
    case flip     // 反转效果
}

class NIAlert: UIView {
    
    var imgView: UIImageView?
    var titleLabel: UILabel?
    var contentLabel: UILabel?
    
    //将 niButtons 放入一个 Array
    var niButtonArray: NSMutableArray = NSMutableArray()
    
    var _containerView: UIView?
    var isLayerHidden: Bool = false
    var shouldTapBackgroundToDismiss: Bool = true
    
    weak var delegate: NIAlertDelegate?
    
    /**
    - parameter dict: 包含构建界面的全部信息
    
    :contain: 
        img:          UIImage
        title:        String
        content:      String
        buttonArray:  Array = [String]()
    */
    var dict: NSMutableDictionary?
    
    convenience init() {
        self.init(frame: UIScreen.mainScreen().bounds)
        self._containerView = UIView()
        self._containerView?.frame = CGRect.zero
        
        self.addSubview(_containerView!)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func _commonSetup() {
        if shouldTapBackgroundToDismiss {
            let tapGesture = UITapGestureRecognizer(target: self, action: "dismissWithAnimation:")
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
        }
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self._containerView!.layer.cornerRadius = 8.0
        self._containerView!.layer.masksToBounds = true
        self._containerView!.backgroundColor = UIColor.whiteColor()
        
        self._containerView!.setWidth(272)
        
        let title = self.dict?.objectForKey("title") as! String
        let content = self.dict?.objectForKey("content") as! String
        let buttonArray = self.dict?.objectForKey("buttonArray") as! NSArray
        
        if let img = (self.dict?.objectForKey("img") as? UIImage) {
            imgView = UIImageView(frame: CGRectMake((self._containerView!.frame.width - 80)/2, 40, 80, img.size.height))
            imgView?.contentMode = UIViewContentMode.Center
            imgView!.image = img
            self._containerView!.addSubview(imgView!)
            setTitle(title)
            self._containerView!.setHeight(imgView!.frame.height + 64 + 20)
        } else if let img = (self.dict?.objectForKey("img") as? String) {
            imgView = UIImageView(frame: CGRectMake((self._containerView!.frame.width - 80)/2, 40, 80, 80))
            imgView?.contentMode = UIViewContentMode.ScaleAspectFit
            if img != "" {
                imgView?.setImageIgnore(img)
            }
            self._containerView!.addSubview(imgView!)
            setTitle(title)
            self._containerView!.setHeight(imgView!.frame.height + 64 + 20)
        } else if let img = (self.dict?.objectForKey("img") as? UIImageView) {
            imgView = UIImageView(frame: CGRectMake((self._containerView!.frame.width - img.width())/2, 40, img.width(), img.height()))
            imgView?.contentMode = UIViewContentMode.ScaleAspectFit
            imgView?.image = img.image
            self._containerView!.addSubview(imgView!)
            setTitle(title)
            self._containerView!.setHeight(imgView!.frame.height + 64 + 20)
        } else {
            titleLabel = UILabel(frame: CGRectMake(48, 40, 176, 20))
            titleLabel!.font = UIFont.boldSystemFontOfSize(18) // (name: "HelveticaBold", size: 18)
            titleLabel!.textColor = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
            titleLabel!.textAlignment = NSTextAlignment.Center
            titleLabel!.text = title
            self._containerView!.addSubview(titleLabel!)
            
            self._containerView!.setHeight(60)
        }
        
        let _cHeight = content.stringHeightWith(12, width: 176) // 计算 content 的高度
        contentLabel = UILabel(frame: CGRectMake(48, titleLabel!.bottom() + 16, 176, _cHeight))
        contentLabel!.font = UIFont.systemFontOfSize(12)
        contentLabel!.textColor = UIColor(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0, alpha: 1.0)
        contentLabel!.textAlignment = NSTextAlignment.Center
        contentLabel!.numberOfLines = 0
        contentLabel!.text = content
        self._containerView!.addSubview(contentLabel!)
        
        let contentBottom = contentLabel!.bottom() + 16.0
        
        // 16.0 : 上边距; 16.0 : 下边距
        self._containerView!.setHeight(self._containerView!.height() + _cHeight + 16.0 + 16.0)   // 调整高度
        
        for var i = 0; i < buttonArray.count; i++ {
            let _title = buttonArray[i] as! String
            let _posY = contentBottom + 44 * CGFloat(i) + 8
            
            let button = NIButton(string: _title, frame: CGRectMake((self._containerView!.frame.width - 120)/2, _posY, 120, 36))
            button.index = i
            button.addTarget(self, action: "buttonTouch:", forControlEvents: UIControlEvents.TouchUpInside)
            
            if i == 0 {
                button.bgColor = BgColor.blue
            } else {
                button.bgColor = BgColor.grey
            }
            
            self._containerView!.addSubview(button)
            self.niButtonArray.addObject(button)
            
            self._containerView!.setHeight(self._containerView!.height() + 8 + 36)  // 根据 button 调整高度
        }
        
        self._containerView!.setHeight(self._containerView!.height() + 40)    //  再次调整高度
    }
    
    func setTitle(title: String) {
        titleLabel = UILabel(frame: CGRectMake(48, imgView!.frame.height + 64, 176, 20))
        titleLabel!.font = UIFont.boldSystemFontOfSize(18) // (name: "HelveticaBold", size: 18)
        titleLabel!.textColor = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
        titleLabel!.textAlignment = NSTextAlignment.Center
        titleLabel!.text = title
        self._containerView!.addSubview(titleLabel!)
    }
    
    func buttonTouch(sender: NIButton) {
        let _index = sender.index!
        
        delegate?.niAlert?(self, didselectAtIndex: _index)
    }
 
    func showWithAnimation(animation: showAnimationStyle) {
        self._commonSetup()
        
        if let _windowView = UIApplication.sharedApplication().windows.first {
            switch animation {
            case .spring:
                self._containerView!.setX((globalWidth - 272)/2)
                _windowView.addSubview(self)
                UIView.animateWithDuration(0.4,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.5,
                    options: .CurveEaseInOut,
                    animations: { () -> Void in
                        self._containerView!.setY((globalHeight - self._containerView!.frame.height)/2)
                    },
                    completion: nil)
                
            case .flip:
                self._containerView!.setX((globalWidth - 272)/2)
                self._containerView!.setY((globalHeight - self._containerView!.frame.height)/2)
                _windowView.addSubview(self)
                
                let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
                self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPointZero, disZ: 1000)
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self._containerView!.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0)
                })
            }
        }
        
        if isLayerHidden {
            self.backgroundColor = UIColor.clearColor()
        } else {
            self.backgroundColor = UIColor(white: 0, alpha: 0.6)
        }
        
    }
    
    func dismissWithAnimation(sender: UITapGestureRecognizer) {
        self._removeSubView()
        delegate?.niAlert?(self, tapBackground: true)
    }
    
    func dismissWithAnimation(animation: dismissAnimationStyle) {
        switch animation {
        case .normal:
            self._removeSubView()
        case .flip:
            let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPointZero, disZ: -1000)
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
            })
        }
    }
    
    func dismissWithAnimationSwtich(view: UIView) {
        let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPointZero, disZ: -1000)
            }, completion: { (Bool) -> Void in
                self._containerView!.removeFromSuperview()
                if let v = view as? NIAlert {
                    v.isLayerHidden = true
                    v.showWithAnimation(showAnimationStyle.flip)
                }
        })
    }
    
    func dismissWithAnimationSwtichEvolution(view: UIView, url: String) {
        let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPointZero, disZ: -1000)
            }, completion: { (Bool) -> Void in
                self._containerView!.removeFromSuperview()
                if let v = view as? NIAlert {
                    v.isLayerHidden = true
                    v.showWithAnimation(showAnimationStyle.flip)
                    v.evolution(url)
                }
        })
    }
    
    private func _removeSubView() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let newTransform = CGAffineTransformScale(self.transform, 1.2, 1.2)
            self.transform = newTransform
            self.alpha = 0
            }) { (Bool) -> Void in
                self._containerView?.removeFromSuperview()
                self.removeFromSuperview()
        }
    }
}

extension NIAlert: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == self {
            return true
        }
        return false
    }
}

//=========================================================

/**
NIbutton background color

- blue:
- grey: 
*/
@objc enum BgColor: Int {
    case blue
    case grey
    case white   // for private use only 
}

class NIButton: UIButton {
    
    var bgColor: BgColor? {
        didSet {
            switch bgColor! {
            case .blue:
                self.backgroundColor = UIColor(red: 0x6c/255.0, green: 0xc5/255.0, blue: 0xee/255.0, alpha: 1.0)
            case .grey:
                self.backgroundColor = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
            case .white:
                self.backgroundColor = UIColor.whiteColor()
            }
        }
    }
    
    var index: Int?  // 目的是确定自己在 NIAlert 的位置，从而确定 Delegate 怎么响应点击事件
    
    private var _spinner: UIActivityIndicatorView?
    private var _titleString: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(string: String, frame: CGRect) {
        super.init(frame: frame)
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24)
        self.layer.cornerRadius = 18.0
        self.layer.masksToBounds = true

        self._titleString = string
        self.titleLabel?.font = UIFont.systemFontOfSize(12)
        self.setTitle(self._titleString, forState: UIControlState.Normal)
        self.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        self._spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        self._spinner!.frame.origin = CGPointMake((self.frame.width - 20)/2, (self.frame.height - 20)/2)
        self._spinner!.transform = CGAffineTransformMakeScale(0.7, 0.7)
        self._spinner!.hidden = true
        self.addSubview(self._spinner!)
    }

    func startAnimating() {
//        self.titleLabel!.text = ""
        self.setTitle("", forState: UIControlState.Normal)
//        self.bgColor = BgColor.white
        self._spinner!.hidden = false
        self._spinner!.startAnimating()
    }
    
    func stopAnimating() {
//        self.titleLabel?.text = _titleString
        self.setTitle(self._titleString, forState: UIControlState.Normal)
        self._spinner!.stopAnimating()
        self._spinner!.hidden = true
    }
    
    
}
