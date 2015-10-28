//
//  NicknameViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/28/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class NicknameViewController: UIViewController {
    
    @IBOutlet weak var nameTextfield: NITextfield!
    @IBOutlet weak var button: CustomButton!
    
    var originalType: String = ""
    var id: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.nameTextfield.layer.cornerRadius = 22
        self.nameTextfield.layer.masksToBounds = true
        
        self.button.layer.cornerRadius = 22
        self.button.layer.masksToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmRegister(sender: UIButton) {
        if nameTextfield.text?.characters.count > 0 {
            LogOrRegModel.registerVia3rd(self.id, type: self.originalType, name: self.nameTextfield.text!) {
                (task, responseObject, error) in
                
            }
            
        } else {
            
        }
        
        
        
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
