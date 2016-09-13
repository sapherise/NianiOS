//
//  Lock.swift
//  Nian iOS
//
//  Created by Sa on 16/1/6.
//  Copyright © 2016年 Sa. All rights reserved.
//

import Foundation
import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


enum lockType: Int {
    /* 启用应用锁，要输入两次 */
    case on
    
    /* 关闭应用锁 */
    case off
    
    /* 验证 */
    case verify
}

class Lock: SAViewController, UITextViewDelegate {
    let padding: CGFloat = 12
    let size_width: CGFloat = 50
    let size_y: CGFloat = 100
    var label: UILabel!
    var textView: UITextView!
    var type: lockType?
    
    /* 设置里开关的协议 */
    var delegate: LockDelegate?
    
    /* 需要两次验证的密码 */
    var passwordTmp = ""
    
    var titleString = ""
    var contentString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        
        titleString = "应用密码"
        if type == lockType.verify {
            titleString = ""
        }
        _setTitle(titleString)
        self.view.backgroundColor = UIColor.NavColor()
        
        /* 添加四个视图 */
        var x = (globalWidth - size_width * 4 - padding * 3) / 2
        for _ in 0...3 {
            let v = LockView()
            v.frame.origin = CGPoint(x: x, y: size_y + 64)
            x += size_width + padding
            self.view.addSubview(v)
            v.isUserInteractionEnabled = true
            v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Lock.onInput)))
        }
        
        /* 添加引导文案 */
        if type == lockType.on {
            contentString = "创造一个可爱的应用密码"
        } else {
            contentString = "输入应用密码"
        }
        label = UILabel(frame: CGRect(x: globalWidth/2 - 80, y: size_y + 64 + size_width + 20, width: 160, height: 50))
        label.text = contentString
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = UIColor.b3()
        label.font = UIFont.systemFont(ofSize: 13)
        self.view.addSubview(label)
        
        /* 设置一个隐藏的输入框 */
        textView = UITextView(frame: CGRect(x: 40, y: 300, width: 0, height: 0))
        textView.keyboardType = .numberPad
        textView.isHidden = true
        textView.delegate = self
        self.view.addSubview(textView)
        textView.becomeFirstResponder()
        
        /* 判断是否可以返回 */
        setBack()
    }
    
    /* 设置是否允许手势返回 */
    func setBack(_ isAble: Bool) {
        if isAble {
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = true
            self.navigationController?.fd_interactivePopDisabled = false
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            self.navigationController?.fd_fullscreenPopGestureRecognizer.isEnabled = false
            self.navigationController?.fd_interactivePopDisabled = true
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setBack()
    }
    
    /* 依据不同情况决定是否可以返回 */
    func setBack() {
        var shouldBack = true
        if type == lockType.verify {
            shouldBack = false
        }
        setBack(shouldBack)
        setBackButton(shouldBack)
    }
    
    /* 设置是否允许按钮返回 */
    func setBackButton(_ isAble: Bool) {
        if isAble {
            let leftButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(self.backNavigation))
            leftButton.image = UIImage(named:"newBack")
            self.navigationItem.leftBarButtonItem = leftButton
        } else {
            let leftButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(Lock.onNoBack))
            leftButton.image = UIImage()
            self.navigationItem.leftBarButtonItem = leftButton
        }
    }
    
    /* 禁用左上角返回 */
    func onNoBack() {
    }
    
    /* 弹起键盘 */
    func onInput() {
        textView.becomeFirstResponder()
    }
    
    /* 根据 textView 的内容来改变密码框的样式 */
    func textViewDidChange(_ textView: UITextView) {
        let content = textView.text! as NSString
        let l  = content.length
        var i = 0
        
        /* 改变密码框样式 */
        for view in self.view.subviews {
            if let v = view as? LockView {
                if i > 3 {
                    break
                }
                if i < l {
                    v.setup(true)
                } else {
                    v.setup(false)
                }
                i += 1
            }
        }
        
        
        if l == 4 {
            if type == lockType.verify {
                if let password = Cookies.get("Lock") as? String {
                    if content as String == password {
                        setBack(true)
                        self.navigationController?.popToRootViewController(animated: true)
                    } else {
                        wrong()
                    }
                }
            } else if type == lockType.on {
                /* 第一次密码 */
                if passwordTmp == "" {
                    passwordTmp = textView.text!
                    clear()
                    label.text = "确认应用密码"
                } else {
                    if textView.text! == passwordTmp {
                        /* 两次输入的密码都一样，保存并返回 */
                        setBack(true)
                        self.navigationController?.popViewController(animated: true)
                        delegate?.setLockState(true)
                        Cookies.set(passwordTmp as AnyObject?, forKey: "Lock")
                        self.showTipText("应用密码设好了")
                    } else {
                        wrong()
                    }
                }
            } else if type == lockType.off {
                if let password = Cookies.get("Lock") as? String {
                    if content as String == password {
                        setBack(true)
                        self.navigationController?.popViewController(animated: true)
                        delegate?.setLockState(false)
                        Cookies.remove("Lock")
                        self.showTipText("应用密码关掉了")
                    } else {
                        wrong()
                    }
                }
            }
        }
    }
    
    /* 错误时，把数据都清除，然后抖动提示 */
    func wrong() {
        clear()
        let x = label.x()
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.label.setX(x - 5)
            }, completion: { (Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.label.setX(x + 5)
                    }, completion: { (Bool) -> Void in
                        UIView.animate(withDuration: 0.1, animations: { () -> Void in
                            self.label.setX(x - 5)
                            }, completion: { (Bool) -> Void in
                                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                                    self.label.setX(x + 5)
                                    }, completion: { (Bool) -> Void in
                                        self.label.setX(x)
                                }) 
                        }) 
                }) 
        }) 
    }
    
    /* 清除密码框 */
    func clear() {
        var i = 0
        for view in self.view.subviews {
            if let v = view as? LockView {
                if i > 3 {
                    break
                }
                v.setup(false)
                i += 1
            }
        }
        textView.text = ""
    }
    
    /* 判断是否可以改变 textView 内容 */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        /* 说明输入的是数字 */
        if Int(text) != nil {
            let content = textView.text!
            if content == "" {
                /* 输入框为空，允许输入 */
                return true
            }
            let b = Int(content)
            if b != nil {
                if b < 1000 {
                    /* 之前的输入框中是三位数，允许输入 */
                    return true
                }
            }
        } else if text == "" {
            /* 输入栅格键，允许输入 */
            return true
        }
        return false
    }
}

class LockView: UIView {
    var isInputed = false
    var point: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.frame.size = CGSize(width: 50, height: 50)
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        point = UIView()
        point.frame.size = CGSize(width: 12, height: 12)
        point.center = self.center
        point.backgroundColor = UIColor.b3()
        point.layer.masksToBounds = true
        point.layer.cornerRadius = 6
        point.isHidden = true
        self.addSubview(point)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(_ isInputed: Bool) {
        if isInputed {
            point.isHidden = false
        } else {
            point.isHidden = true
        }
    }
}
