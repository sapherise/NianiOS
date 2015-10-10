//
//  AddTopic.swift
//  Nian iOS
//
//  Created by Sa on 15/9/10.
//  Copyright © 2015年 Sa. All rights reserved.
//

import Foundation


protocol editRedditDelegate {
    func editDream(editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTags: Array<String>)
}

protocol getCommentDelegate {
    func getComment(content: String)
}

class AddTopic: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, NSLayoutManagerDelegate, TITokenFieldDelegate, DreamSelectedDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var field1: UITextField!  //title text field
    @IBOutlet var field2: SZTextView!
    @IBOutlet var tokenView: TITokenFieldView!
    @IBOutlet var seperatorView: UIView!
    @IBOutlet var viewHolder: UIView!
    @IBOutlet var imageUpload: UIImageView!
    @IBOutlet var imageDream: UIImageView!
    
    var actionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editRedditDelegate?
    var delegateComment: getCommentDelegate?
    var dict = NSMutableDictionary()
    var hImage: CGFloat = 0
    var type: Int = 0   // 0 为话题，1 为回应
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
        self.uploadFile(image)
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //        adjustScroll()
        //        self.view.layoutIfNeeded()
    }
//    - (id)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:CGRectMake(0.0, 0.0, 310, 166)];
//    if (self) {
//    self = [[[NSBundle mainBundle] loadNibNamed:@"MyView" owner:self options:nil] firstObject];
//    }
//    return self;
//    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = type == 0 ? "新话题！" : "新回应！"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        self.view.addSubview(navView)
        
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
        UIScreen.mainScreen().bounds.height > 480 ? self.field2.setHeight(120) : self.field2.setHeight(96)
        self.field2.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
        self.tokenView.setY(self.field2.bottom())
        self.tokenView.setWidth(globalWidth)
        self.seperatorView.setWidth(globalWidth)
        self.seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        field2.layoutManager.delegate = self
        
        viewHolder.setX(globalWidth - 38 * 2 - 8)
        viewHolder.setY(field2.bottom() + 1)
        imageUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onImage"))
        imageDream.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onDream"))
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.field1.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field1.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        
        self.field2.attributedPlaceholder = NSAttributedString(string: "话题正文" ,
            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field2.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        self.field2.delegate = self
        
        self.scrollView.delegate = self
        
        //设置 tag view ---- 引用了第三方库
        tokenView.delegate = self
        tokenView.tokenField.delegate = self
        tokenView.shouldSearchInBackground = false
        tokenView.tokenField.tokenizingCharacters = NSCharacterSet(charactersInString: "#")
        tokenView.tokenField.setPromptText("     ")
        tokenView.tokenField.tokenLimit = 20
        tokenView.tokenField.frame.size.width = 19
        tokenView.paddingRight = 38 * 2 + 8
        tokenView.tokenField.placeholder = "添加标签"
        tokenView.canCancelContentTouches = false
        tokenView.delaysContentTouches = false
        tokenView.scrollEnabled = false
        
        let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "add")
        rightButton.image = UIImage(named:"newOK")
        self.navigationItem.rightBarButtonItems = [rightButton]
        
        if dict.allKeys.count > 0 {
            self.editTitle = self.dict["title"] as! String
            self.editContent = self.dict["content"] as! String
        }
        
        if self.isEdit == 1 {
            self.field1!.text = self.editTitle.decode()
            self.field2.text = self.editContent.decode()
            if tagsArray.count > 0 {
                for i in 0...(tagsArray.count - 1) {
                    tokenView.tokenField.addTokenWithTitle(tagsArray[i].decode())
                    tokenView.tokenField.layoutTokensAnimated(false)
                }
            }
            self.uploadUrl = self.editImage
        }
        
        if type == 1 {
            field1.hidden = true
            field2.setY(13)
            viewHolder.setY(field2.bottom() + 1)
            seperatorView.setY(viewHolder.bottom())
            tokenView.hidden = true
        }
    }
    
    func layoutManager(layoutManager: NSLayoutManager, lineSpacingAfterGlyphAtIndex glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return 8
    }
    
    func dismissKeyboard(sender: UISwipeGestureRecognizer){
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.tokenField.resignFirstResponder()
    }
}