//
//  WelcomeViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/20/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    var shouldNavToMe: Bool = false
    
    /// 进入 “LogOrRegViewController”
    @IBOutlet weak var logInButton: UIButton!

    @IBOutlet weak var wechatButton: SocialMediaButton!
    @IBOutlet weak var qqButton: SocialMediaButton!
    @IBOutlet weak var weiboButton: SocialMediaButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.logInButton.layer.cornerRadius = 22.0
        self.logInButton.layer.borderWidth = 0.5
        self.logInButton.layer.borderColor = UIColor.colorWithHex("0x333333").CGColor
        self.logInButton.layer.masksToBounds = true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        // toLORVC : to LogOrRegViewController
        if segue.identifier == "toLORVC" {
            
            /*   */
            let logOrRegViewController = segue.destinationViewController as! LogOrRegViewController
            logOrRegViewController.functionalType = FunctionType.confirm
        }

        
    }


}
