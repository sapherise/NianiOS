//
//  AddTopic.swift
//  Nian iOS
//
//  Created by Sa on 15/9/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation



class AddStep: SAViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, NSLayoutManagerDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var field1: UITextField!  //title text field
    @IBOutlet var field2: SZTextView!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var imageUpload: UIImageView!
    @IBOutlet var seperatorView2: UIView!
    
    var actionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editRedditDelegate?
    var delegateComment: getCommentDelegate?
    var dict = NSMutableDictionary()
    var hImage: CGFloat = 0
    var id: String = ""
    
    var uploadUrl: String = ""
    
    var isEdit: Int = 0
    var editId: String = ""
    var editTitle: String = ""
    var editContent: String = ""
    var editImage: String = ""
    var tagsArray: Array<String> = [String]()
    var keyboardHeight: CGFloat = 0.0  // 键盘的高度
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
//        self.uploadFile(image)
        // todo:
    }
    
    //MARK: view load 相关的方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "handleKeyboardWillShowNotification:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "handleKeyboardWillHideNotification:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        _setTitle("新进展！")
        setBarButtonImage("newOK", actionGesture: "add")
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard:")
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.Down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)
        
        self.scrollView.setWidth(globalWidth)
        self.scrollView.setHeight(globalHeight - 64)
        self.containerView.setWidth(globalWidth)
        self.containerView.setHeight(self.scrollView.height() - 1)
        self.field1.setWidth(globalWidth)
        self.field1.leftView = UIView(frame: CGRectMake(0, 0, 16, 1))
        self.field1.rightView = UIView(frame: CGRectMake(0, 0, 16, 1))
        self.field1.leftViewMode = .Always
        self.field1.rightViewMode = .Always
        self.field2.setWidth(globalWidth)
        globalHeight > 480 ? self.field2.setHeight(120) : self.field2.setHeight(96)
        self.field2.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
        seperatorView.setWidth(globalWidth)
        seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        seperatorView2.setY(self.field2.bottom())
        seperatorView2.setWidth(globalWidth)
        seperatorView2.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        field2.layoutManager.delegate = self
        
        viewHolder.setY(field2.bottom() + 1)
        imageUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.field1.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field1.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        
        self.field2.attributedPlaceholder = NSAttributedString(string: "话题正文" ,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field2.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        self.field2.delegate = self
        
        self.scrollView.delegate = self
        
        /* 如果传入的 dict 不为空，先提取出相关的内容 */
        if dict.allKeys.count > 0 {
            self.editTitle = self.dict["title"] as! String
            self.editContent = self.dict["content"] as! String
            self.tagsArray = self.dict["tags"] as! Array
        }
        
        if self.isEdit == 1 {
            self.field1!.text = self.editTitle.decode()
            self.field2.text = self.editContent.decode()
            self.uploadUrl = self.editImage
        }
    }
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
    
    func dismissKeyboard(sender: UISwipeGestureRecognizer){
        self.dismissKeyboard()
    }
    
    func close() {
        self.dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
    }
}