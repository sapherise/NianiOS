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
    @IBOutlet weak var followButton: UIButton!
    
    override func awakeFromNib() {
        self.headImageView.layer.cornerRadius = 20.0
        self.headImageView.layer.masksToBounds = true
    }
   
    func bindData(data: ExploreSearch.UserSearchData, tableview: UITableView) {
        self.title.text = data.user
        
        self.followButton.layer.cornerRadius = 15
        self.followButton.layer.masksToBounds = true
        
        if data.follow == "0" {
            self.followButton.layer.borderColor = SeaColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = .whiteColor()
            self.followButton.setTitle("关注", forState: .Normal)
        } else {
            self.followButton.layer.borderWidth = 0
            self.followButton.setTitleColor(SeaColor, forState: .Normal)
            self.followButton.backgroundColor = SeaColor
            self.followButton.setTitle("关注中", forState: .Normal)
        }
        
        self.headImageView.setImage(V.urlHeadImage(data.uid, tag: .Head), placeHolder: IconColor)
    }
    
    override func prepareForReuse() {
       super.prepareForReuse()
        
        self.headImageView.cancelImageRequestOperation()
        self.headImageView.image = nil
    }
    
    
}



















