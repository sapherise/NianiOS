//
//  ListCell.swift
//  Nian iOS
//
//  Created by Sa on 16/1/12.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit

class ListCell: UITableViewCell {
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelButton: UILabel!
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var viewLine: UIView!
//    @IBOutlet weak var heightViewLine: NSLayoutConstraint!
    
    var data: NSDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
//        heightViewLine.constant = globalHalf
        viewLine.frame = CGRectMake(70, 70, globalWidth - 85, globalHalf)
        imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onHead"))
    }
    
    func setup() {
        let uid = data.stringAttributeForKey("uid")
        let name = data.stringAttributeForKey("name")
        
        /* 当 inviting 为 0 时，不要高亮 */
        let isHighlight = data.stringAttributeForKey("inviting") != "0"
        labelTitle.text = name
        imageHead.setHead(uid)
    }
    
    func onHead() {
        let uid = data.stringAttributeForKey("uid")
        let vc = PlayerViewController()
        vc.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(vc, animated: true)
    }
}