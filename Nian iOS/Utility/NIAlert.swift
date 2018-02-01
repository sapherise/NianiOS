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
    @objc optional func niAlert(_ niAlert: NIAlert, didselectAtIndex: Int)
    @objc optional func niAlert(_ niAlert: NIAlert, tapBackground: Bool)
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
        self.init(frame: UIScreen.main.bounds)
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
    
    fileprivate func _commonSetup() {
        if shouldTapBackgroundToDismiss {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NIAlert.dismissWithAnimation(_:) as (NIAlert) -> (UITapGestureRecognizer) -> ()))
            tapGesture.delegate = self
            self.addGestureRecognizer(tapGesture)
        }
        
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        self._containerView!.layer.cornerRadius = 8.0
        self._containerView!.layer.masksToBounds = true
        self._containerView!.backgroundColor = UIColor.white
        
        self._containerView!.setWidth(272)
        
        let title = self.dict?.object(forKey: "title") as! String
        let content = self.dict?.object(forKey: "content") as! String
        let buttonArray = self.dict?.object(forKey: "buttonArray") as! NSArray
        
        /* 如果是 UIImage */
        if let img = (self.dict?.object(forKey: "img") as? UIImage) {
            imgView = UIImageView(frame: CGRect(x: (self._containerView!.frame.width - 80)/2, y: 40, width: 80, height: img.size.height))
            imgView?.contentMode = UIViewContentMode.center
            imgView!.image = img
            self._containerView!.addSubview(imgView!)
            setTitle(title)
            self._containerView!.setHeight(imgView!.frame.height + 64 + 20)
        } else if let img = (self.dict?.object(forKey: "img") as? String) {
            /* 如果是 String */
            imgView = UIImageView(frame: CGRect(x: (self._containerView!.frame.width - 80)/2, y: 40, width: 80, height: 80))
            imgView?.contentMode = UIViewContentMode.scaleAspectFit
            if img != "" {
                imgView?.setImageIgnore(img)
            }
            self._containerView!.addSubview(imgView!)
            setTitle(title)
            self._containerView!.setHeight(imgView!.frame.height + 64 + 20)
        } else if let img = (self.dict?.object(forKey: "img") as? UIImageView) {
            /* 如果是 UIImageView */
            imgView = UIImageView(frame: CGRect(x: (self._containerView!.frame.width - img.width())/2, y: 40, width: img.width(), height: img.height()))
            imgView?.contentMode = UIViewContentMode.scaleAspectFit
            imgView?.image = img.image
            self._containerView!.addSubview(imgView!)
            setTitle(title)
            self._containerView!.setHeight(imgView!.frame.height + 64 + 20)
        } else {
            titleLabel = UILabel(frame: CGRect(x: 48, y: 40, width: 176, height: 20))
            titleLabel!.font = UIFont.boldSystemFont(ofSize: 18) // (name: "HelveticaBold", size: 18)
            titleLabel!.textColor = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
            titleLabel!.textAlignment = NSTextAlignment.center
            titleLabel!.text = title
            self._containerView!.addSubview(titleLabel!)
            
            self._containerView!.setHeight(60)
        }
        
        let _cHeight = content.stringHeightWith(12, width: 176) // 计算 content 的高度
        contentLabel = UILabel(frame: CGRect(x: 48, y: titleLabel!.bottom() + 16, width: 176, height: _cHeight))
        contentLabel!.font = UIFont.systemFont(ofSize: 12)
        contentLabel!.textColor = UIColor(red: 0x66/255.0, green: 0x66/255.0, blue: 0x66/255.0, alpha: 1.0)
        contentLabel!.textAlignment = NSTextAlignment.center
        contentLabel!.numberOfLines = 0
        contentLabel!.text = content
        self._containerView!.addSubview(contentLabel!)
        
        let contentBottom = contentLabel!.bottom() + 16.0
        
        // 16.0 : 上边距; 16.0 : 下边距
        self._containerView!.setHeight(self._containerView!.height() + _cHeight + 16.0 + 16.0)   // 调整高度
        
        for i in 0 ..< buttonArray.count {
            let _title = buttonArray[i] as! String
            let _posY = contentBottom + 44 * CGFloat(i) + 8
            
            let button = NIButton(string: _title, frame: CGRect(x: (self._containerView!.frame.width - 120)/2, y: _posY, width: 120, height: 36))
            button.index = i
            button.addTarget(self, action: #selector(NIAlert.buttonTouch(_:)), for: UIControlEvents.touchUpInside)
            
            if i == 0 {
                button.bgColor = BgColor.blue
            } else {
                button.bgColor = BgColor.grey
            }
            
            self._containerView!.addSubview(button)
            self.niButtonArray.add(button)
            
            self._containerView!.setHeight(self._containerView!.height() + 8 + 36)  // 根据 button 调整高度
        }
        
        self._containerView!.setHeight(self._containerView!.height() + 40)    //  再次调整高度
    }
    
    func setTitle(_ title: String) {
        titleLabel = UILabel(frame: CGRect(x: 48, y: imgView!.frame.height + 64, width: 176, height: 20))
        titleLabel!.font = UIFont.boldSystemFont(ofSize: 18) // (name: "HelveticaBold", size: 18)
        titleLabel!.textColor = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
        titleLabel!.textAlignment = NSTextAlignment.center
        titleLabel!.text = title
        self._containerView!.addSubview(titleLabel!)
    }
    
    @objc func buttonTouch(_ sender: NIButton) {
        let _index = sender.index!
        
        delegate?.niAlert?(self, didselectAtIndex: _index)
    }
 
    func showWithAnimation(_ animation: showAnimationStyle) {
        self._commonSetup()
        
        if let _windowView = UIApplication.shared.windows.first {
            switch animation {
            case .spring:
                self._containerView!.setX((globalWidth - 272)/2)
                _windowView.addSubview(self)
                UIView.animate(withDuration: 0.4,
                    delay: 0,
                    usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 0.5,
                    options: UIViewAnimationOptions(),
                    animations: { () -> Void in
                        self._containerView!.setY((globalHeight - self._containerView!.frame.height)/2)
                    },
                    completion: nil)
                
            case .flip:
                self._containerView!.setX((globalWidth - 272)/2)
                self._containerView!.setY((globalHeight - self._containerView!.frame.height)/2)
                _windowView.addSubview(self)
                
                let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
                self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPoint.zero, disZ: 1000)
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self._containerView!.layer.transform = CATransform3DMakeRotation(0, 0, 0, 0)
                })
            }
        }
        
        if isLayerHidden {
            self.backgroundColor = UIColor.clear
        } else {
            self.backgroundColor = UIColor(white: 0, alpha: 0.6)
        }
        
    }
    
    @objc func dismissWithAnimation(_ sender: UITapGestureRecognizer) {
        self._removeSubView()
        delegate?.niAlert?(self, tapBackground: true)
    }
    
    func dismissWithAnimation(_ animation: dismissAnimationStyle) {
        switch animation {
        case .normal:
            self._removeSubView()
        case .flip:
            let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPoint.zero, disZ: -1000)
            }, completion: { (Bool) -> Void in
                self.removeFromSuperview()
            })
        }
    }
    
    func dismissWithAnimationSwtich(_ view: UIView) {
        let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPoint.zero, disZ: -1000)
            }, completion: { (Bool) -> Void in
                self._containerView!.removeFromSuperview()
                if let v = view as? NIAlert {
                    v.isLayerHidden = true
                    v.showWithAnimation(showAnimationStyle.flip)
                }
        })
    }
    
    func dismissWithAnimationSwtichEvolution(_ view: UIView, url: String) {
        let rotate = CATransform3DMakeRotation(CGFloat(M_PI)/2, 0, -1, 0)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self._containerView!.layer.transform = CATransform3DPerspect(rotate, center: CGPoint.zero, disZ: -1000)
            }, completion: { (Bool) -> Void in
                self._containerView!.removeFromSuperview()
                if let v = view as? NIAlert {
                    v.isLayerHidden = true
                    v.showWithAnimation(showAnimationStyle.flip)
                    v.evolution(url)
                }
        })
    }
    
    fileprivate func _removeSubView() {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            let newTransform = self.transform.scaledBy(x: 1.2, y: 1.2)
            self.transform = newTransform
            self.alpha = 0
            }, completion: { (Bool) -> Void in
                self._containerView?.removeFromSuperview()
                self.removeFromSuperview()
        }) 
    }
}

extension NIAlert: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
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
                self.backgroundColor = UIColor.white
            }
        }
    }
    
    var index: Int?  // 目的是确定自己在 NIAlert 的位置，从而确定 Delegate 怎么响应点击事件
    
    fileprivate var _spinner: UIActivityIndicatorView?
    fileprivate var _titleString: String?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(string: String, frame: CGRect) {
        super.init(frame: frame)
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24)
        self.layer.cornerRadius = 18.0
        self.layer.masksToBounds = true

        self._titleString = string
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.setTitle(self._titleString, for: UIControlState())
        self.setTitleColor(UIColor.white, for: UIControlState())
        
        self._spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        self._spinner!.frame.origin = CGPoint(x: (self.frame.width - 20)/2, y: (self.frame.height - 20)/2)
        self._spinner!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        self._spinner!.isHidden = true
        self.addSubview(self._spinner!)
    }

    func startAnimating() {
//        self.titleLabel!.text = ""
        self.setTitle("", for: UIControlState())
//        self.bgColor = BgColor.white
        self._spinner!.isHidden = false
        self._spinner!.startAnimating()
    }
    
    func stopAnimating() {
//        self.titleLabel?.text = _titleString
        self.setTitle(self._titleString, for: UIControlState())
        self._spinner!.stopAnimating()
        self._spinner!.isHidden = true
    }
    
    
}
