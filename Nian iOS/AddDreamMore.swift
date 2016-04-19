//
//  AddDreamMore.swift
//  NianiOS
//
//  Created by Sa on 16/4/13.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation

protocol delegatePrivate {
    func update(key: String, value: Int)
}

class AddDreamMore: SAViewController, UIActionSheetDelegate {
    var alert: UIActionSheet?
    var data: [String]!
    var labelInviteMember: UILabel!
    var permission = 0
    var isPrivate = 0
    var btn: UISwitch!
    var delegate: delegatePrivate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setTitle("记本选项")
        setupViews()
    }
    
    func setupViews() {
        let h: CGFloat = 44
        let marginTop: CGFloat = 16
        let paddingLeft: CGFloat = 16
        data = ["没有人", "我关注的人", "所有人"]
        
        let scrollView = UIScrollView(frame: CGRectMake(0, 64, globalWidth, globalHeight - 64))
        self.view.addSubview(scrollView)
        scrollView.backgroundColor = UIColor.GreyBackgroundColor()
        scrollView.alwaysBounceVertical = true
        
        /* 私密设置 */
        let viewPrivate = UIView(frame: CGRectMake(0, marginTop, globalWidth, h))
        scrollView.addSubview(viewPrivate)
        let labelPrivate = UILabel(frame: CGRectMake(paddingLeft, 0, 200, h))
        labelPrivate.text = "设为私密"
        labelPrivate.textColor = UIColor.MainColor()
        labelPrivate.font = UIFont.systemFontOfSize(16)
        viewPrivate.addSubview(labelPrivate)
        /* 私密开关 */
        btn = UISwitch()
        btn.setX(globalWidth - btn.width() - paddingLeft)
        btn.setY((h - btn.height())/2)
        btn.onTintColor = UIColor.HighlightColor()
        btn.addTarget(self, action: #selector(self.setPrivate(_:)), forControlEvents: UIControlEvents.ValueChanged)
        viewPrivate.addSubview(btn)
        
        /* 邀请设置 */
        let viewInvite = UIView(frame: CGRectMake(0, viewPrivate.bottom(), globalWidth, h))
        viewInvite.userInteractionEnabled = true
        viewInvite.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.invite)))
        scrollView.addSubview(viewInvite)
        let labelInvite = UILabel(frame: CGRectMake(paddingLeft, 0, 200, h))
        labelInvite.text = "自由加入记本"
        labelInvite.textColor = UIColor.MainColor()
        labelInvite.font = UIFont.systemFontOfSize(16)
        viewInvite.addSubview(labelInvite)
        /* 邀请开关 */
        let arrow = UIImageView(frame: CGRectMake(0, 0, 8, h))
        arrow.setX(globalWidth - arrow.width() - paddingLeft)
        arrow.image = UIImage(named: "setting_cell_arrow")
        viewInvite.addSubview(arrow)
        /* 邀请成员文案 */
        labelInviteMember = UILabel(frame: CGRectMake(0, 0, 100, h))
        labelInviteMember.setX(globalWidth - arrow.width() - paddingLeft - 8 - labelInviteMember.width())
        labelInviteMember.textAlignment = .Right
        labelInviteMember.font = UIFont.systemFontOfSize(14)
        labelInviteMember.textColor = UIColor.secAuxiliaryColor()
        viewInvite.addSubview(labelInviteMember)
        
        viewPrivate.addLine(true)
        viewInvite.addLine(true)
        viewInvite.addLine(false)
        viewPrivate.backgroundColor = UIColor.BackgroundColor()
        viewInvite.backgroundColor = UIColor.BackgroundColor()
        
        setPrivate()
        setPermission()
    }
    
    /* 邀请弹窗 */
    func invite() {
        alert = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        alert?.addButtonWithTitle(data[0])
        alert?.addButtonWithTitle(data[1])
        alert?.addButtonWithTitle(data[2])
        alert?.addButtonWithTitle("取消")
        alert?.cancelButtonIndex = 3
        alert?.showInView(self.view)
    }
    
    /* 设置私密或公开 */
    func setPrivate(sender: UISwitch) {
        if sender.on {
            delegate?.update("private", value: 1)
        } else {
            delegate?.update("private", value: 0)
        }
    }
    
    func setPrivate() {
        if isPrivate == 0 {
            btn.setOn(false, animated: false)
        } else {
            btn.setOn(true, animated: false)
        }
    }
    
    func setPermission() {
        labelInviteMember.text = data[permission]
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == alert {
            if buttonIndex < 3 {
                permission = buttonIndex
                setPermission()
                delegate?.update("permission", value: buttonIndex)
            }
        }
    }
}

extension UIView {
    func addLine(isTop: Bool) {
        let y = isTop ? 0 : self.height()
        let line = UIView(frame: CGRectMake(0, y, globalWidth, globalHalf))
        line.backgroundColor = UIColor.LineColor()
        line.setY(y - globalHalf / 2)
        self.addSubview(line)
    }
}