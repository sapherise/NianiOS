//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit


class SignViewController: UIViewController {
    @IBOutlet var inputName:UITextField!
    @IBOutlet var holder:UIView!
    @IBOutlet var next:UIButton!
    @IBOutlet var errLabel:UILabel!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.view.backgroundColor = BGColor
        self.inputName.textColor = BlueColor
        self.inputName.textAlignment = NSTextAlignment.Center
        let attributesDictionary = [NSForegroundColorAttributeName: LineColor]
        self.inputName.attributedPlaceholder = NSAttributedString(string: "昵称", attributes: attributesDictionary)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard:"))
        
        var leftButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "back")
        leftButton.image = UIImage(named:"back")
        self.navigationItem.leftBarButtonItem = leftButton;
        
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = IconColor
        titleLabel.text = "注册"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.next.layer.borderWidth = 1
        self.next.layer.borderColor = LineColor.CGColor
        self.next.setTitleColor(IconColor, forState: UIControlState.Normal)
        self.next.addTarget(self, action: "checkName", forControlEvents: UIControlEvents.TouchUpInside)
        self.errLabel.alpha = 0
    }
    
    func back(){
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func checkName(){
        if self.inputName.text != "" {
            shakeAnimation(self.holder)
            UIView.animateWithDuration(0.3, delay:0, options: UIViewAnimationOptions.allZeros, animations: {
                self.errLabel.frame.offset(dx: 0, dy: -5)
                self.errLabel.alpha = 1
                }, completion: { (complete: Bool) in
                    UIView.animateWithDuration(0.1, delay:1.2, options: UIViewAnimationOptions.allZeros, animations: {
                        self.errLabel.frame.offset(dx: 0, dy: +5)
                        self.errLabel.alpha = 0
                        }, completion: { (complete: Bool) in
                    })
            })
        }else{
            self.navigationController!.pushViewController(SignNextController(nibName: "SignNext", bundle: nil), animated: true)
        }
    }
    override func viewDidAppear(animated: Bool) {
        self.inputName.becomeFirstResponder()
    }
    
    func dismissKeyboard(sender:UITapGestureRecognizer){
        self.inputName.resignFirstResponder()
    }
    
    func shakeAnimation(view:UIView){
        var viewLayer:CALayer = view.layer
        var position:CGPoint = viewLayer.position
        var x:CGPoint = CGPointMake(position.x + 3 , position.y)
        var y:CGPoint = CGPointMake(position.x - 3 , position.y)
        var animation:CABasicAnimation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(CGPoint: x)
        animation.toValue = NSValue(CGPoint: y)
        animation.autoreverses = true
        animation.duration = 0.1
        animation.repeatCount = 2
        viewLayer.addAnimation(animation, forKey: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
