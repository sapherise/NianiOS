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
    optional func niAlert(niALert: NIAlert, didselectAtIndex: Int)
    optional func niAlert(niAlert: NIAlert, tapBackground: Bool)
}


enum showAnimationStyle: Int {
    case spring   // 弹簧效果
    case flip     // 反转效果
}

class NIAlert: UIView {
    
    var imgView: UIImageView?
    var titleLabel: UILabel?
    var contentLabel: UILabel?
    
    //将 niButtons 放入一个 Array
    var niButtonArray: NSMutableArray = NSMutableArray()
    
    private var _containerView: UIView?
    
    weak var delegate: NIAlertDelegate?
    
    /**
    :param: dict 包含构建界面的全部信息
    
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
        self._containerView?.frame = CGRect.zeroRect
        
        self.addSubview(_containerView!)
        
        self.layer.opacity = 1.0
        self.layer.backgroundColor = UIColor(white: 0.0, alpha: 0.6).CGColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "dismissWithAnimation:")
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func _commonSetup() {
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        self._containerView!.layer.cornerRadius = 8.0
        self._containerView!.layer.masksToBounds = true
        self._containerView!.backgroundColor = UIColor.whiteColor()
        
        self._containerView!.setWidth(272)
        
        var title = self.dict?.objectForKey("title") as! String
        var content = self.dict?.objectForKey("content") as! String
        var buttonArray = self.dict?.objectForKey("buttonArray") as! NSArray
        
        if let img = (self.dict?.objectForKey("img") as? UIImage) {
            var imgSize = img.size
            imgView = UIImageView(frame: CGRectMake((self._containerView!.frame.width - 80)/2, 40, 80, 80))
            imgView?.contentMode = UIViewContentMode.ScaleAspectFill
            imgView!.image = img
            self._containerView!.addSubview(imgView!)
            
            titleLabel = UILabel(frame: CGRectMake(48, imgView!.frame.height + 64, 176, 20))
            titleLabel!.font = UIFont.boldSystemFontOfSize(18) // (name: "HelveticaBold", size: 18)
            titleLabel!.textColor = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
            titleLabel!.textAlignment = NSTextAlignment.Center
            titleLabel!.text = title
            self._containerView!.addSubview(titleLabel!)
            
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
        
        var _cHeight = content.stringHeightWith(12, width: 176) // 计算 content 的高度
        contentLabel = UILabel(frame: CGRectMake(48, titleLabel!.bottom() + 16, 176, _cHeight))
        contentLabel!.font = UIFont.systemFontOfSize(12)
        contentLabel!.textColor = UIColor(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0, alpha: 1.0)
        contentLabel!.textAlignment = NSTextAlignment.Center
        contentLabel!.numberOfLines = 0
        contentLabel!.text = content
        self._containerView!.addSubview(contentLabel!)
        
        var contentBottom = contentLabel!.bottom() + 16.0
        
        // 16.0 : 上边距; 16.0 : 下边距
        self._containerView!.setHeight(self._containerView!.height() + _cHeight + 16.0 + 16.0)   // 调整高度
        
        for var i = 0; i < buttonArray.count; i++ {
            var _title = buttonArray[i] as! String
            var _width = _title.stringWidthWith(12, height: 36)
            var _posY = Float(contentBottom) + Float((i + 1)) * 8.0 + Float(i) * 36
            
            var button = NIButton(string: _title, frame: CGRectMake((self._containerView!.frame.width - 120)/2, CGFloat(_posY), 120, 36))
            button.tag = 41000 + i
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
    
    func buttonTouch(sender: NIButton) {
        var _index = sender.tag - 41000
        
        delegate?.niAlert?(self, didselectAtIndex: _index)
    }
 
    func showWithAnimation(animation: showAnimationStyle) {
//        self.layoutSubviews()
        self._commonSetup()
        
        var _windowView = UIApplication.sharedApplication().windows.first as! UIView
        
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

            var rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
            self._containerView!.layer.transform = CATransform3DPerspect(rotate, CGPointZero, 1000)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self._containerView!.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0)
            })
            
        default:
           break
        }
    }
    
    func dismissWithAnimation() {
        self._removeSubView()
    }
    
    func dismissWithAnimation(sender: UITapGestureRecognizer) {
        self._removeSubView()
        delegate?.niAlert?(self, tapBackground: true)
    }
    
    private func _removeSubView() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            var newTransform = CGAffineTransformScale(self.transform, 1.2, 1.2)
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
}

class NIButton: UIButton {
    
    var bgColor: BgColor? {
        didSet {
            switch bgColor! {
            case .blue:
                self.backgroundColor = UIColor(red: 0x6c/255.0, green: 0xc5/255.0, blue: 0xee/255.0, alpha: 1.0)
            case .grey:
                self.backgroundColor = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
            default:
                break
            }
        }
    }
    
    private var _spinner: UIActivityIndicatorView?
    private var _titleString: String?
    
    required init(coder aDecoder: NSCoder) {
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
        
        self._spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self._spinner!.frame.origin = CGPointMake((self.frame.width - 20)/2, (self.frame.height - 20)/2)
        self._spinner!.hidden = true
        self.addSubview(self._spinner!)
    }

    func startAnimating() {
//        self.titleLabel!.text = ""
        self.setTitle("", forState: UIControlState.Normal)
        self.bringSubviewToFront(self._spinner!)
        self._spinner!.hidden = false
        self._spinner!.startAnimating()
    }
    
    func stopAnimating() {
//        self.titleLabel?.text = _titleString
        self.setTitle(self._titleString, forState: UIControlState.Normal)
        self.sendSubviewToBack(self._spinner!)
        self._spinner!.stopAnimating()
        self._spinner!.hidden = true
    }
}
