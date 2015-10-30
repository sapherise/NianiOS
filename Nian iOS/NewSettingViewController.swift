//
//  NewSettingViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class NewSettingViewController: UIViewController {
    /// 封面
    @IBOutlet weak var coverImageView: UIImageView!
    /// 头像
    @IBOutlet weak var avatarImageView: UIImageView!
    /// 模糊背景
    @IBOutlet weak var settingCoverBlurView: FXBlurView!
    /// 模糊背景
    @IBOutlet weak var settingAvatarBlurView: FXBlurView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - 处理各个 Switcher
extension NewSettingViewController{
    
    /**
     <#Description#>
     */
    @IBAction func dailyModeChanged(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func downloadPictureViaCellerOrNot(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func saveStepCardOrNot(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func remindOnDailyUpdate(sender: UISwitch) {
    }
    
    /**
     <#Description#>
     */
    @IBAction func findMeOnlyViaName(sender: UISwitch) {
    }
}

// MARK: - 处理相关的 tap 手势
extension NewSettingViewController {
    
    @IBAction func setCoverImage(sender: UITapGestureRecognizer) {
    }
    
    
    @IBAction func setAvatar(sender: UITapGestureRecognizer) {
    }
    
    @IBAction func editMyProfile(sender: UITapGestureRecognizer) {
    }
    
    
    @IBAction func setAccountBind(sender: UITapGestureRecognizer) {
    }
    
    
    @IBAction func cleanCache(sender: UITapGestureRecognizer) {
    }
    
    @IBAction func introduceNian(sender: UITapGestureRecognizer) {
    }
    
    
    @IBAction func fiveStarOnAppStore(sender: UITapGestureRecognizer) {
    }
    
    
    @IBAction func logout(sender: UITapGestureRecognizer) {
    }
}































