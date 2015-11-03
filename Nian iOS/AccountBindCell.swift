//
//  AccountBindCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 11/3/15.
//  Copyright © 2015 Sa. All rights reserved.
//

import UIKit

class AccountBindCell: UITableViewCell {
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.contentView.bounds = UIScreen.mainScreen().bounds
    }
    
    /**
     
     */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .None
        
//        detailLabel = UILabel(frame: CGRectMake(104, 14, self.frame.width - 104, 15))
//        detailLabel?.textColor = UIColor(red: 0xB3/255.0, green: 0xB3/255.0, blue: 0xB3/255.0, alpha: 1.0)
//        detailLabel?.textAlignment = .Right
//        
//        self.addSubview(detailLabel!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
