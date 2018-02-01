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
        
        self.contentView.bounds = UIScreen.main.bounds
    }
    
    /**
     
     */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
