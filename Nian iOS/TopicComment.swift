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
    var id = ""
    var row = 0
    var delegate: RedditDelegate?   // 投票后，影响 Topic 的结果
    var index: Int = 0  // 在评论页面投票后，Topic 中 index 为这个的 cell 进行刷新
    var titleContent: String?   // 评论页面显示标题
    
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