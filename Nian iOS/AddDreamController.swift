//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol editDreamDelegate {
    func editDream(editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTags: Array<String>)
}

class AddDreamController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var uploadWait: UIActivityIndicatorView!
    @IBOutlet weak var field1: UITextField!  //title text field
    @IBOutlet weak var field2: SZTextView!
    @IBOutlet weak var tokenView: TITokenFieldView!
    @IBOutlet weak var setPrivate: UIImageView!
    @IBOutlet weak var imageDreamHead: UIImageView!
    @IBOutlet weak var seperatorView: UIView!
    
    var actionSheet: UIActionSheet?
    var setDreamActionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editDreamDelegate?
    
    var uploadUrl: String = ""
    
    var isEdit: Int = 0
    var editId: String = ""
    var editTitle: String = ""
    var editContent: String = ""
    var editImage: String = ""
    var tagsArray: Array<String> = [String]()
    
    var caretPosition: CGFloat = 0.0   // 获得 caret(光标)的位置
    var keyboardHeight: CGFloat = 0.0  // 键盘的高度
    var keyboardShown: Bool = false
    
    var isPrivate: Int = 0  // 0: 公开；1：私密
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    func uploadClick() {
        self.dismissKeyboard()
        
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        self.actionSheet!.addButtonWithTitle("相册")
        self.actionSheet!.addButtonWithTitle("拍照")
        self.actionSheet!.addButtonWithTitle("取消")
        
        self.actionSheet!.cancelButtonIndex = 2
        
        self.actionSheet!.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                self.presentViewController(self.imagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.Camera
                    self.presentViewController(self.imagePicker!, animated: true, completion: nil)
                }
            }
        } else if actionSheet == self.setDreamActionSheet {
            if buttonIndex == 0 {
                if self.isPrivate == 0 {
                    //设置为私密
                    self.isPrivate = 1
                    self.setPrivate.image = UIImage(named: "lock")
                } else if self.isPrivate == 1 {
                    //设置为公开
                    self.isPrivate = 0
                    self.setPrivate.image = UIImage(named: "unlock")
                }
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(img:UIImage){
        self.uploadWait!.hidden = false
        self.imageDreamHead.image = UIImage(named: "add_no_plus")
        self.uploadWait!.startAnimating()
        let uy = UpYun()
        uy.successBlocker = ({(data: AnyObject!) in
            self.uploadWait!.hidden = true
            self.uploadUrl = data.objectForKey("url") as! String
            self.uploadUrl = SAReplace(self.uploadUrl, before: "/dream/", after: "") as String
            let url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            self.imageDreamHead.contentMode = .ScaleToFill
            self.imageDreamHead.image = img
            setCacheImage(url, img: img, width: (globalWidth - 40) * globalScale)
            self.uploadWait!.stopAnimating()
        })
        uy.failBlocker = ({(error: NSError!) in
            self.uploadWait!.hidden = true
            self.uploadWait!.stopAnimating()
            self.imageDreamHead.image = UIImage(named: "add_plus")
        })
        uy.uploadImage(resizedImage(img, newWidth: 260), savekey: getSaveKey("dream", png: "png") as String)
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
        
        let height = 78 + field2.frame.size.height + tokenView.tokenField.frame.size.height
        let tmpSize: CGSize = CGSizeMake(self.containerView.frame.size.width, max(height, UIScreen.mainScreen().bounds.size.height - 64))
        self.scrollView.contentSize = tmpSize
        
        self.view.layoutIfNeeded()
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        
        let navView = UIView(frame: CGRectMake(0, 0, globalWidth, 64))
        navView.backgroundColor = BarColor
        
        let titleLabel:UILabel = UILabel(frame: CGRectMake(0, 0, 200, 40))
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.text = self.isEdit == 1 ? "编辑记本" : "新记本！"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        self.view.addSubview(navView)
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: "dismissKeyboard:")
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.Down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)

        self.setPrivate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "setDream"))
        
        self.imageDreamHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "uploadClick"))
        self.imageDreamHead.layer.cornerRadius = 4.0
        self.imageDreamHead.layer.masksToBounds = true
        
        self.scrollView.setWidth(globalWidth)
        self.scrollView.setHeight(globalHeight - 64)
        self.containerView.setWidth(globalWidth)
        self.containerView.setHeight(self.scrollView.frame.height - 1)
        self.field1.setWidth(globalWidth - 124)
        self.setPrivate.setX(globalWidth - 44)
        self.field2.setWidth(globalWidth)
        UIScreen.mainScreen().bounds.height > 480 ? self.field2.setHeight(120) : self.field2.setHeight(96)
        self.field2.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tokenView.setY(CGRectGetMaxY(self.field2.frame))
        self.tokenView.setWidth(globalWidth)
        self.seperatorView.setWidth(globalWidth)
        self.seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        self.view.backgroundColor = UIColor.whiteColor()
//        self.field1!.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), forKeyPath: "_placeholderLabel.textColor")
        self.field1.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field1.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        
        self.field2.attributedPlaceholder = NSAttributedString(string: "记本简介（可选）" ,
                                                            attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14),
                                                                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field2.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        self.field2.delegate = self
        
        self.scrollView.delegate = self
        
//        if UIScreen.mainScreen().bounds.height > 480 {
//            self.field2.frame.size.height = 120
//        } else {
//            self.field2.frame.size.height = 96
//        }
        
        if isPrivate == 0 {
            setPrivate.image = UIImage(named: "unlock")
        } else {
            setPrivate.image = UIImage(named: "lock")
        }
        
        uploadWait.transform = CGAffineTransformMakeScale(0.7, 0.7)
        uploadWait.center = imageDreamHead.center
        uploadWait.color = UIColor(red:0.6, green:0.6, blue:0.6, alpha:0.6)
    
        //设置 tag view ---- 引用了第三方库
        tokenView.delegate = self
        tokenView.tokenField.delegate = self
        tokenView.shouldSearchInBackground = false
        tokenView.tokenField.tokenizingCharacters = NSCharacterSet(charactersInString: "#")
        tokenView.tokenField.setPromptText("     ")
        tokenView.tokenField.tokenLimit = 20;
        tokenView.tokenField.placeholder = "添加标签"
        tokenView.canCancelContentTouches = false
        tokenView.delaysContentTouches = false
        tokenView.scrollEnabled = false

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
            let url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            imageDreamHead.setImage(url, placeHolder: IconColor, bool: false)
            let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "editDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        } else {
            let rightButton = UIBarButtonItem(title: "  ", style: .Plain, target: self, action: "addDreamOK")
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        
        self.uploadWait!.hidden = true
    }
    
    func setDream(){
        self.dismissKeyboard()
        self.setDreamActionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        if self.isPrivate == 0 {
            self.setDreamActionSheet!.addButtonWithTitle("设为私密")
        } else if self.isPrivate == 1 {
            self.setDreamActionSheet!.addButtonWithTitle("设为公开")
        }
        
        self.setDreamActionSheet!.addButtonWithTitle("取消")
        self.setDreamActionSheet!.cancelButtonIndex = 1
        self.setDreamActionSheet!.showInView(self.view)
    }
    
    func dismissKeyboard(sender: UISwipeGestureRecognizer){
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.tokenField.resignFirstResponder()
    }
    
    //MARK: 添加 new Dream
    
    func addDreamOK(){
        let title = self.field1?.text
        let content = self.field2.text
        let tags = self.tokenView.tokenTitles
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            Api.postAddDream(title!, content: content!, uploadUrl: self.uploadUrl, isPrivate: self.isPrivate, tags: tags!) {
                json in
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    dispatch_async(dispatch_get_main_queue(), {
                        globalWillNianReload = 1
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }

    }
    
    //MARK: edit dream
    
    func editDreamOK(){
        var title = self.field1?.text
        var content = self.field2.text
        var tags = self.tokenView.tokenTitles
        var tagsString: String = ""
        var tagsArray: Array<String> = [String]()
        
        if (tags!).count > 0 {
            for i in 0...((tags!).count - 1){
                let tmpString = tags![i] as! String
                tagsArray.append(tmpString)
                if i == 0 {
                    tagsString = "tags[]=\(SAEncode(SAHtml(tmpString)))"
                } else {
                    tagsString = tagsString + "&&tags[]=\(SAEncode(SAHtml(tmpString)))"
                }
            }
        } else {
            tagsString = "tags[]="
        }
        
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            title = SAEncode(SAHtml(title!))
            content = SAEncode(SAHtml(content!))
            
            Api.postEditDream(self.editId, title: title!, content: content!, uploadUrl: self.uploadUrl, editPrivate: self.isPrivate, tags: tagsString){
                json in
                let error = json!.objectForKey("error") as! NSNumber
                if error == 0 {
                    globalWillNianReload = 1
                    self.delegate?.editDream(self.isPrivate, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTags:tagsArray)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }
    }
    
    func onTagSelected(tag: String, tagType: Int) {
//        self.labelTag?.text = tag
//        self.tagType = tagType + 1
    }
    
    //MARK: keyboard notification && UITextView Delegate method
   
    func handleKeyboardWillShowNotification(notification: NSNotification) {
        let userInfo = notification.userInfo!
        
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        let keyboardViewEndFrame = view.convertRect(keyboardScreenEndFrame, fromView: view.window)
        let originDelta = keyboardViewEndFrame.height   // abs(keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y)
        keyboardHeight = originDelta
        
        if self.tokenView.tokenField.isFirstResponder() {
            tokenView.frame.size = CGSize(width: self.tokenView.frame.width, height: UIScreen.mainScreen().bounds.height - keyboardHeight - 64)
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 78 + field2.frame.height + tokenView.frame.height)
            self.containerView.setHeight(self.scrollView.contentSize.height - 1)
            
            UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                self.scrollView.setContentOffset(CGPointMake(0, self.field2.frame.height + 78), animated: false)
            }, completion: nil)
        }
        
        if field2.isFirstResponder() {
            let _rect = field2.caretRectForPosition((field2.selectedTextRange?.end)!)
            
            if ((_rect.origin.y + UIFont.systemFontOfSize(14).lineHeight + 78 + keyboardHeight) > (UIScreen.mainScreen().bounds.height - 64)) {
                let extraHeight = _rect.origin.y + 78 - self.scrollView.contentOffset.y + keyboardHeight + UIFont.systemFontOfSize(14).lineHeight
                let heightExcludeNavbar = UIScreen.mainScreen().bounds.height - 64
                let extraScrollOffset = extraHeight - heightExcludeNavbar
                
                UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.contentOffset.y + extraScrollOffset), animated: false)
                }, completion: nil)
            }
        }
        
        keyboardShown = true
    }

    func handleKeyboardWillHideNotification(notification: NSNotification) {
        keyboardShown = false
        
        let userInfo = notification.userInfo!
        let animationDuration: NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 78 + field2.frame.height + CGRectGetMaxY(tokenView.tokenField.frame))
        self.containerView.setHeight(self.scrollView.contentSize.height - 1)
        
        UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
            self.scrollView.setContentOffset(CGPointMake(0, 0), animated: false)
            }, completion: nil)
    }

    // text view delegate 
    /* 在编辑 “记本简介” 时，根据选择的内容来实现滚动 */
    func textViewDidChangeSelection(textView: UITextView) {
        if textView.tag == 16555 {
            /**/
            let tmpField2Height = textView.text.stringHeightWith(14.0, width: textView.contentSize.width - textView.contentInset.left * 2) + textView.contentInset.top * 2
            let field2DefaultHeight: CGFloat = UIScreen.mainScreen().bounds.height > 480 ? 120 : 96
            self.field2.frame.size.height = field2DefaultHeight > tmpField2Height ? field2DefaultHeight : tmpField2Height
            self.tokenView.frame.origin.y = CGRectGetMaxY(self.field2.frame)
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 78 + field2.frame.height + tokenView.frame.height)
            self.containerView.frame.size = CGSize(width: self.containerView.frame.width, height: self.scrollView.contentSize.height)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        if textView.tag == 16555 {
            let _rect = field2.caretRectForPosition((field2.selectedTextRange?.end)!)
            
            if ((_rect.origin.y + UIFont.systemFontOfSize(14).lineHeight + 78 + keyboardHeight) > (UIScreen.mainScreen().bounds.height - 64)) {
                let extraHeight = _rect.origin.y + 78 - self.scrollView.contentOffset.y + keyboardHeight + UIFont.systemFontOfSize(14).lineHeight
                let heightExcludeNavbar = UIScreen.mainScreen().bounds.height - 64
                let extraScrollOffset = extraHeight - heightExcludeNavbar
                
                UIView.animateWithDuration(0, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.contentOffset.y + extraScrollOffset), animated: false)
                }, completion: nil)
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isKindOfClass(UITableView) || touch.view!.isKindOfClass(UITableViewCell) {
            return false
        }
        
        return true
    }
    
}

//MARK: token field delegate

extension AddDreamController: TITokenFieldDelegate {
    func tokenFieldDidBeginEditing(field: TITokenField!) {
        if self.tokenView.tokenField.isFirstResponder() {
            if keyboardShown {
                tokenView.frame.size = CGSize(width: self.tokenView.frame.width, height: UIScreen.mainScreen().bounds.height - keyboardHeight - 64)
                
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 78 + field2.frame.height + tokenView.frame.height)
                self.containerView.setHeight(self.scrollView.contentSize.height - 1)
                
                UIView.animateWithDuration(0.25, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: {
                    self.scrollView.setContentOffset(CGPointMake(0, self.field2.frame.height + 78), animated: false)
                }, completion: nil)
            }
        }
    }
    
    func tokenField(field: TITokenField!, shouldUseCustomSearchForSearchString searchString: String!) -> Bool {
        return true
    }
    
    func tokenField(field: TITokenField!, performCustomSearchForSearchString searchString: String!, withCompletionHandler completionHandler: (([AnyObject]!) -> Void)!) {
        var data: Array<String> = []
        
        if searchString.characters.count > 0 {
            let _string = SAEncode(SAHtml(searchString))
            Api.getAutoComplete(_string, callback: {
                json in
                if json != nil {
                    let error = json!.objectForKey("error") as! NSNumber
                    
                    if error == 0 {
                        data = json!.objectForKey("data") as! Array
                        
                        if data.count > 0 {
                            for i in 0...(data.count - 1) {
                                data[i] = data[i].decode()
                            }
                        }
                    }
                }
                completionHandler(data)
            })
        }
    }
    
    func tokenField(tokenField: TITokenField!, didAddToken token: TIToken!) {
//        _string.removeAtIndex(advance(token.title.startIndex, 0))
        if self.tagsArray.contains(token.title) {
            return
        }
        
        Api.postTag(SAEncode(SAHtml(token.title)), callback: {
            json in
        })
    }
    
    func tokenField(tokenField: TITokenField!, didChangeFrame frame: CGRect) {
    }
    
}

//MARK: UIScrollView Delegate

extension AddDreamController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
}





















