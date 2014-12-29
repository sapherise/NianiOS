//
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-6.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit
import QuartzCore


class SlideScrollView: UITableViewCell {
    
    @IBOutlet var nickLabel:UILabel?
    @IBOutlet var dreamhead:UIImageView?
    @IBOutlet var dreamadd:UILabel?
    
    var data :NSDictionary!;
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.nickLabel!.text = "Sa"
        var userImageURL = "http://img.nian.so/head/1.jpg!head"
        self.dreamhead!.setImage(userImageURL,placeHolder: UIImage(named: "1.jpg"))
        
        self.dreamadd!.layer.cornerRadius = 4;
        self.dreamadd!.layer.masksToBounds = true;
    }
}
