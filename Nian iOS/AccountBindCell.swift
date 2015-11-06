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
        
        self.accessoryType = .DisclosureIndicator
        self.selectionStyle = .None
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
