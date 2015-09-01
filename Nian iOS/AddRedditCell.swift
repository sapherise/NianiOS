//
//  AddRedditCell.swift
//  Nian iOS
//
//  Created by Sa on 15/9/1.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation
class AddRedditCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet var textView: UITextView!
    override func awakeFromNib() {
        self.selectionStyle = .None
        textView.setWidth(globalWidth)
        textView.backgroundColor = SeaColor
    }
}