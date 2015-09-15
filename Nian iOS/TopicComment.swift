//
//  TopicComment.swift
//  Nian iOS
//
//  Created by Sa on 15/8/31.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation

class TopicComment: SAViewController, UITextFieldDelegate {
    var tableView: UITableView!
    var inputKeyboard: UIView!
    var textField: UITextField!
    var page: Int = 1
    var dataArrayTop: NSDictionary!
    var dataArray = NSMutableArray()
    
    /* topic id */
    var topicID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardEndObserve()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardStartObserve()
    }
    
    func setupViews() {
        _setTitle("话题回应")
        inputKeyboard = UIView()
        textField = UITextField()
        textField.delegate = self
        inputKeyboard.setTextField(textField)
        self.view.addSubview(inputKeyboard)
    }
    
    
    
}