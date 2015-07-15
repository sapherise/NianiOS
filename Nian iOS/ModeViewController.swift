//
//  ModeViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 7/15/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import UIKit

@objc enum PlayMode: Int {
    case simple
    case tough
}

class ModeViewController: UIViewController {
    
    let C5Color = UIColor(red: 0x33/255.0, green: 0x33/255.0, blue: 0x33/255.0, alpha: 1.0)
    let C7Color = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewBack()
        var navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        self.view.addSubview(navView)
        
        var titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = "模式"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
       
        self.playMode = PlayMode.tough
    }
    
    override func viewWillAppear(animated: Bool) {
        var rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "toSignNext:")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton]
    }
    
    @IBAction func touchOnLeftView(sender: UITapGestureRecognizer) {
//        self.toughImageView.image = UIImage(named: "xxx")
        self.simpleLabel.textColor = C7Color
        self.simpleIllustate.textColor = C7Color
        
//        self.simpleImageView.image = UIImage(named: "zzz")
        self.toughLabel.textColor = C5Color
        self.toughIllustrate.textColor = C5Color
        
        self.playMode = PlayMode.tough
    }
    
    @IBAction func touchOnRightView(sender: UITapGestureRecognizer) {
//        self.toughImageView.image = UIImage(named: "xxx")
        self.simpleLabel.textColor = C5Color
        self.simpleIllustate.textColor = C5Color
        
//        self.simpleImageView.image = UIImage(named: "zzz")
        self.toughLabel.textColor = C7Color
        self.toughIllustrate.textColor = C7Color
        
        self.playMode = PlayMode.simple
    }
    
    func toSignNext(sender: AnyObject) {
        self.signInfo.mode = self.playMode
        var signNextVC = SignNextController(nibName: "SignNext", bundle: nil)
        signNextVC.signInfo = self.signInfo
        self.navigationItem.rightBarButtonItems = []
        self.navigationController!.pushViewController(signNextVC, animated: true)
    }
}


extension ModeViewController: UIGestureRecognizerDelegate {
    
    
    
    
}