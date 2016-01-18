//
//  AddStepCell.swift
//  Nian iOS
//
//  Created by Sa on 15/12/28.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
import UIKit

class AddStepCell: UITableViewCell {
    
    @IBOutlet var imageDream: UIImageView!
    @IBOutlet var labelTitle: UILabel!
    var data: NSDictionary?
    func setup() {
        if data != nil {
            let title:String = self.data!.objectForKey("title") as! String
            let image:String = self.data!.objectForKey("image") as! String
            let userImageURL = "http://img.nian.so/dream/\(image)!dream"
            self.labelTitle.text = title.decode()
            self.imageDream.setImage(userImageURL)
        }
    }
    
    override func awakeFromNib() {
        self.selectionStyle = .None
    }
}