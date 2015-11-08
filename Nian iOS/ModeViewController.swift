//
//  ModeViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 7/15/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit



class ModeViewController: UIViewController {
    
    let C5Color = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
    let C7Color = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
    
    @IBOutlet weak var widthLine: NSLayoutConstraint!
    var playMode: PlayMode?
    lazy var signInfo = SignInfo()
    
    @IBOutlet weak var toughImageView: UIImageView!
    @IBOutlet weak var simpleImageView: UIImageView!
    @IBOutlet weak var toughLabel: UILabel!
    @IBOutlet weak var simpleLabel: UILabel!
    @IBOutlet weak var toughIllustrate: UILabel!
    @IBOutlet weak var simpleIllustate: UILabel!
    @IBOutlet weak var toughView: UIView!
    @IBOutlet weak var simpleView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var viewLine: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewBack()
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "游戏模式"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "toSignNext:")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton]
        
        self.containerView.layer.borderColor = UIColor.colorWithHex("#E6E6E6").CGColor
        self.containerView.layer.borderWidth = 0.5
        self.containerView.layer.cornerRadius = 4.0
        self.containerView.layer.masksToBounds = true
        widthLine.constant = 0.5
        
        setPlayMode(PlayMode.easy)
    }
    
    @IBAction func touchOnLeftView(sender: UITapGestureRecognizer) {
        setPlayMode(PlayMode.hard)
    }
    
    @IBAction func touchOnRightView(sender: UITapGestureRecognizer) {
        setPlayMode(PlayMode.easy)
    }
    
    func setPlayMode(mode: PlayMode) {
        if mode == PlayMode.easy {
            //        self.toughImageView.image = UIImage(named: "xxx")
            self.simpleLabel.textColor = C5Color
            self.simpleIllustate.textColor = C5Color
            
            //        self.simpleImageView.image = UIImage(named: "zzz")
            self.toughLabel.textColor = C7Color
            self.toughIllustrate.textColor = C7Color
            
            self.playMode = PlayMode.easy
        } else {
            //        self.toughImageView.image = UIImage(named: "xxx")
            self.simpleLabel.textColor = C7Color
            self.simpleIllustate.textColor = C7Color
            
            //        self.simpleImageView.image = UIImage(named: "zzz")
            self.toughLabel.textColor = C5Color
            self.toughIllustrate.textColor = C5Color
            
            self.playMode = PlayMode.hard
            
        }
    }
    
    func toSignNext(sender: AnyObject) {
        self.signInfo.mode = self.playMode
        let signNextVC = SignNextController(nibName: "SignNext", bundle: nil)
        signNextVC.signInfo = self.signInfo
        self.navigationItem.rightBarButtonItems = []
        self.navigationController!.pushViewController(signNextVC, animated: true)
    }
}