//
//  SearchCell.swift
//  Nian iOS
//
//  Created by WebosterBob on 4/25/15.
//  Copyright (c) 2015 Sa. All rights reserved.
//

import Foundation
import UIKit

class searchCell: UITableViewCell {
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        self.headImageView.layer.cornerRadius = 4.0
        self.headImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        
    }
}


class searchResultCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var headImageView: UIImageView!
    
    override func awakeFromNib() {
        self.headImageView.layer.cornerRadius = 4.0
        self.headImageView.layer.masksToBounds = true
    }
    
    
    @IBAction func follow(sender: AnyObject) {
        
        
    }
    
    override func prepareForReuse() {
        
    }
    
}

class searchHistoryCell: UITableViewCell {
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        self.headImageView.layer.cornerRadius = 20.0
        self.headImageView.layer.masksToBounds = true
    }
    

    @IBAction func remove(sender: AnyObject) {
        
    }
    
    override func prepareForReuse() {
        
    }
}

class searchUserResultCell: UITableViewCell {
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func awakeFromNib() {
        self.headImageView.layer.cornerRadius = 20.0
        self.headImageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        
    }
    
    
}



















