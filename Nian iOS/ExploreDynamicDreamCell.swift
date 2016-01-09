//
//  ExploreDynamicCell.swift
//  Nian iOS
//
//  Created by vizee on 14/11/14.
//  Copyright (c) 2014年 Sa. All rights reserved.
//
//
import UIKit

class ExploreDynamicDreamCell: UITableViewCell {
    
    @IBOutlet var imageHead: UIImageView!
    @IBOutlet var labelName: UILabel!
    @IBOutlet var labelDream: UILabel!
    @IBOutlet var imageCover: UIImageView!
    @IBOutlet var viewLine: UIView!
    var data: NSDictionary!
    
    override func awakeFromNib() {
        imageCover.setX(globalWidth - 52)
        self.viewLine.setWidth(globalWidth - 40)
        self.viewLine.setHeightHalf()
    }
    
    func setup() {
        if data != nil {
            let uidlike = data.stringAttributeForKey("uidlike")
            let userlike = data.stringAttributeForKey("userlike")
            let img = data.stringAttributeForKey("image")
            let title = data.stringAttributeForKey("title").decode()
            self.imageHead.setHead(uidlike)
            self.imageCover.setImage("http://img.nian.so/dream/\(img)!dream")
            self.labelName.text = userlike
            self.labelDream.text = "赞了「\(title)」"
            self.imageHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
            self.labelName.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onUserClick"))
        }
    }
    
    func onUserClick() {
        let uid = data.stringAttributeForKey("uidlike")
        let userVC = PlayerViewController()
        userVC.Id = uid
        self.findRootViewController()?.navigationController?.pushViewController(userVC, animated: true)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageCover.cancelImageRequestOperation()
        self.imageCover.image = nil
    }
    
}