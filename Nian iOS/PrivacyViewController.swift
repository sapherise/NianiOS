//
//  PrivacyViewController.swift
//  Nian iOS
//
//  Created by WebosterBob on 10/30/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController {
    
    @IBOutlet weak var web: UIWebView!
    
    var urlString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let url = URL(string: urlString)
        if url != nil {
            let request = URLRequest(url: url!)
            web.loadRequest(request)
        } else {
            self.showTipText("网址错误")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     返回之前的界面
     */
    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
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
