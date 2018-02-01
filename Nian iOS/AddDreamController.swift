//
//  YRAboutViewController.swift
//  JokeClient-Swift
//
//  Created by YANGReal on 14-6-5.
//  Copyright (c) 2014年 YANGReal. All rights reserved.
//

import UIKit

protocol editDreamDelegate {
    func editDream(_ editPrivate: Int, editTitle:String, editDes:String, editImage:String, editTags: NSArray, editPermission: Int)
}

class AddDreamController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate, delegatePrivate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var uploadWait: UIActivityIndicatorView!
    @IBOutlet weak var field1: UITextField!
    @IBOutlet weak var field2: SZTextView!
    @IBOutlet weak var tokenView: TITokenFieldView!
    @IBOutlet weak var setPrivate: UIImageView!
    @IBOutlet weak var imageDreamHead: UIImageView!
    @IBOutlet weak var seperatorView: UIView!
    
    var actionSheet: UIActionSheet?
    var setDreamActionSheet: UIActionSheet?
    var imagePicker: UIImagePickerController?
    var delegate: editDreamDelegate?
    var delegateAddDream: AddDreamDelegate?
    
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
    /* 0 为只接受邀请，1 为好友加入，2 为所有人可加入 */
    var permission: Int = 0
    
    var swipeGesuture: UISwipeGestureRecognizer?
    
    func uploadClick() {
        self.dismissKeyboard()
        
        self.actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: nil, destructiveButtonTitle: nil)
        
        self.actionSheet!.addButton(withTitle: "相册")
        self.actionSheet!.addButton(withTitle: "拍照")
        self.actionSheet!.addButton(withTitle: "取消")
        
        self.actionSheet!.cancelButtonIndex = 2
        
        self.actionSheet!.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if actionSheet == self.actionSheet {
            if buttonIndex == 0 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                self.imagePicker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.present(self.imagePicker!, animated: true, completion: nil)
            } else if buttonIndex == 1 {
                self.imagePicker = UIImagePickerController()
                self.imagePicker!.delegate = self
                self.imagePicker!.allowsEditing = true
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                    self.imagePicker!.sourceType = UIImagePickerControllerSourceType.camera
                    self.present(self.imagePicker!, animated: true, completion: nil)
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
    
    func update(_ key: String, value: Int) {
        if key == "private" {
            isPrivate = value
        } else if key == "permission" {
            permission = value
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        self.dismiss(animated: true, completion: nil)
        self.uploadFile(image)
    }
    
    func uploadFile(_ img:UIImage){
        self.uploadWait!.isHidden = false
        self.imageDreamHead.image = UIImage(named: "add_no_plus")
        self.uploadWait!.startAnimating()
        let uy = UpYun()
        uy.successBlocker = ({ data in
            if let d = data as? NSDictionary {
                self.uploadWait!.isHidden = true
                self.uploadUrl = d.stringAttributeForKey("url")
                self.uploadUrl = SAReplace(self.uploadUrl, before: "/dream/", after: "") as String
                let url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
                self.imageDreamHead.contentMode = .scaleToFill
                self.imageDreamHead.image = img
                setCacheImage(url, img: img, width: (globalWidth - 40) * globalScale)
                self.uploadWait!.stopAnimating()
            }
        })
        uy.failBlocker = ({ err in
            self.uploadWait.isHidden = true
            self.uploadWait.stopAnimating()
            self.imageDreamHead.image = UIImage(named: "add_plus")
        })
        uy.uploadImage(resizedImage(img, newWidth: 260), savekey: getSaveKey("dream", png: "png") as String)
    }
    
    //MARK: view load 相关的方法
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AddDreamController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(AddDreamController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let height = 78 + field2.frame.size.height + tokenView.tokenField.frame.size.height
        let tmpSize: CGSize = CGSize(width: self.containerView.frame.size.width, height: max(height, UIScreen.main.bounds.size.height - 64))
        self.scrollView.contentSize = tmpSize
        
        self.view.layoutIfNeeded()
    }
    
    func setupViews(){
        self.automaticallyAdjustsScrollViewInsets = false
        
        let navView = UIView(frame: CGRect(x: 0, y: 0, width: globalWidth, height: 64))
        navView.backgroundColor = UIColor.NavColor()
        
        let titleLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titleLabel.textColor = UIColor.white
        titleLabel.text = self.isEdit == 1 ? "编辑记本" : "新记本！"
        titleLabel.textAlignment = NSTextAlignment.center
        self.navigationItem.titleView = titleLabel
        
        self.viewBack()
        self.view.addSubview(navView)
        
        swipeGesuture = UISwipeGestureRecognizer(target: self, action: #selector(AddDreamController.dismissKeyboard(_:)))
        swipeGesuture!.direction = UISwipeGestureRecognizerDirection.down
        swipeGesuture!.cancelsTouchesInView = true
        self.view.addGestureRecognizer(swipeGesuture!)

        self.setPrivate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddDreamController.setDream)))
        
        self.imageDreamHead.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AddDreamController.uploadClick)))
        self.imageDreamHead.layer.cornerRadius = 4.0
        self.imageDreamHead.layer.masksToBounds = true
        
        self.scrollView.setWidth(globalWidth)
        self.scrollView.setHeight(globalHeight - 64)
        self.containerView.setWidth(globalWidth)
        self.containerView.setHeight(self.scrollView.frame.height - 1)
        self.field1.setWidth(globalWidth - 124)
        self.setPrivate.setX(globalWidth - 44)
        self.field2.setWidth(globalWidth)
        UIScreen.main.bounds.height > 480 ? self.field2.setHeight(120) : self.field2.setHeight(96)
        self.field2.textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        self.tokenView.setY(self.field2.frame.maxY)
        self.tokenView.setWidth(globalWidth)
        self.seperatorView.setWidth(globalWidth)
        self.seperatorView.backgroundColor = UIColor(red:0.9, green:0.9, blue:0.9, alpha:1)
        
        self.view.backgroundColor = UIColor.BackgroundColor()
//        self.field1!.setValue(UIColor(red: 0, green: 0, blue: 0, alpha: 0.3), forKeyPath: "_placeholderLabel.textColor")
        self.field1.attributedPlaceholder = NSAttributedString(string: "标题", attributes: [NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field1.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        
        self.field2.attributedPlaceholder = NSAttributedString(string: "记本简介（可选）" ,
                                                            attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                                                                NSForegroundColorAttributeName: UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)])
        self.field2.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1)
        self.field2.delegate = self
        
        self.scrollView.delegate = self
        
        setPrivate.image = UIImage(named: "dream_settings")
        
        uploadWait.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        uploadWait.center = imageDreamHead.center
        uploadWait.color = UIColor(red:0.6, green:0.6, blue:0.6, alpha:0.6)
    
        //设置 tag view ---- 引用了第三方库
        tokenView.delegate = self
        tokenView.tokenField.delegate = self
        tokenView.shouldSearchInBackground = false
        tokenView.tokenField.tokenizingCharacters = CharacterSet(charactersIn: "#")
        tokenView.tokenField.setPromptText("     ")
        tokenView.tokenField.tokenLimit = 20;
        tokenView.tokenField.placeholder = "添加标签"
        tokenView.canCancelContentTouches = false
        tokenView.delaysContentTouches = false
        tokenView.isScrollEnabled = false

        if self.isEdit == 1 {
            self.field1!.text = self.editTitle.decode()
            self.field2.text = self.editContent.decode()
            
            if tagsArray.count > 0 {
                for i in 0...(tagsArray.count - 1) {
                    tokenView.tokenField.addToken(withTitle: tagsArray[i].decode())
                    tokenView.tokenField.layoutTokens(animated: false)
                }
            }
            
            self.uploadUrl = self.editImage
            let url = "http://img.nian.so/dream/\(self.uploadUrl)!dream"
            imageDreamHead.setImage(url)
            let rightButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(AddDreamController.editDreamOK))
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        } else {
            let rightButton = UIBarButtonItem(title: "  ", style: .plain, target: self, action: #selector(AddDreamController.addDreamOK))
            rightButton.image = UIImage(named:"newOK")
            self.navigationItem.rightBarButtonItems = [rightButton];
        }
        
        self.uploadWait!.isHidden = true
    }
    
    /* 添加或修改记本的更多设置 */
    func setDream(){
        let vc = AddDreamMore()
        vc.permission = permission
        vc.isPrivate = isPrivate
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func dismissKeyboard(_ sender: UISwipeGestureRecognizer){
        self.dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.field1!.resignFirstResponder()
        self.field2.resignFirstResponder()
        self.tokenView.tokenField.resignFirstResponder()
    }
    
    //MARK: 添加 new Dream
    
    func addDreamOK(){
        let title = (self.field1.text)!
        let content = (self.field2.text)!
        let tags = self.tokenView.tokenTitles
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            Api.postAddDream(title, content: content, uploadUrl: self.uploadUrl, isPrivate: self.isPrivate, tags: tags!, permission: "\(permission)") {
                json in
                if SAValue(json, "error") == "0" {
                    let data = json!.object(forKey: "data") as! NSDictionary
                    let id = data.stringAttributeForKey("dream")
                    let img = data.stringAttributeForKey("image")
                    self.delegateAddDream?.addDreamCallback(id, img: img, title: (self.field1.text)!)
                    _ = self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }

    }
    
    //MARK: edit dream
    
    func editDreamOK(){
        let title = self.field1.text!
        let content = self.field2.text!
        let tags = self.tokenView.tokenTitles!
        
        if title != "" {
            self.navigationItem.rightBarButtonItems = buttonArray()
            Api.postEditDream(self.editId, title: title, content: content, uploadUrl: self.uploadUrl, editPrivate: self.isPrivate, tags: tags, permission: "\(permission)"){
                json in
                    if SAValue(json, "error") == "0" {
                        if let dreams = Cookies.get("NianDreams") as? NSMutableArray {
                            var i = 0
                            let arr = NSMutableArray(array: dreams)
                            for _dream in dreams {
                                if let dream = _dream as? NSDictionary {
                                    let id = dream.stringAttributeForKey("id")
                                    if id == self.editId {
                                        let mutableData = NSMutableDictionary(dictionary: dream)
                                        mutableData.setValue(self.field1!.text!, forKey: "title")
                                        mutableData.setValue(self.uploadUrl, forKey: "image")
                                        arr.replaceObject(at: i, with: mutableData)
                                        Cookies.set(arr, forKey: "NianDreams")
                                        Nian.loadFromLocal()
                                        break
                                    }
                                }
                                i += 1
                            }
                        }
                        
                        self.delegate?.editDream(self.isPrivate, editTitle: (self.field1?.text)!, editDes: (self.field2.text)!, editImage: self.uploadUrl, editTags: tags, editPermission: self.permission)
                        _ = self.navigationController?.popViewController(animated: true)
                    }
            }
        } else {
            self.field1!.becomeFirstResponder()
        }
    }
    
    func onTagSelected(_ tag: String, tagType: Int) {
//        self.labelTag?.text = tag
//        self.tagType = tagType + 1
    }
    
    //MARK: keyboard notification && UITextView Delegate method
   
    func handleKeyboardWillShowNotification(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        // Convert the keyboard frame from screen to view coordinates.
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        let originDelta = keyboardViewEndFrame.height   // abs(keyboardViewEndFrame.origin.y - keyboardViewBeginFrame.origin.y)
        keyboardHeight = originDelta
        
        if self.tokenView.tokenField.isFirstResponder {
            tokenView.frame.size = CGSize(width: self.tokenView.frame.width, height: UIScreen.main.bounds.height - keyboardHeight - 64)
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 78 + field2.frame.height + tokenView.frame.height)
            self.containerView.setHeight(self.scrollView.contentSize.height - 1)
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.field2.frame.height + 78), animated: false)
            }, completion: nil)
        }
        
        if field2.isFirstResponder {
            let _rect = field2.caretRect(for: (field2.selectedTextRange?.end)!)
            let a = (_rect.origin.y + UIFont.systemFont(ofSize: 14).lineHeight + 78 + keyboardHeight)
            if (a > (UIScreen.main.bounds.height - 64)) {
                let extraHeight = _rect.origin.y + 78 - self.scrollView.contentOffset.y + keyboardHeight + UIFont.systemFont(ofSize: 14).lineHeight
                let heightExcludeNavbar = UIScreen.main.bounds.height - 64
                let extraScrollOffset = extraHeight - heightExcludeNavbar
                
                UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y + extraScrollOffset), animated: false)
                }, completion: nil)
            }
        }
        
        keyboardShown = true
    }

    func handleKeyboardWillHideNotification(_ notification: Notification) {
        keyboardShown = false
        
        let userInfo = (notification as NSNotification).userInfo!
        let animationDuration: TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 78 + field2.frame.height + tokenView.tokenField.frame.maxY)
        self.containerView.setHeight(self.scrollView.contentSize.height - 1)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }, completion: nil)
    }

    // text view delegate 
    /* 在编辑 “记本简介” 时，根据选择的内容来实现滚动 */
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.tag == 16555 {
            /**/
            let tmpField2Height = textView.text.stringHeightWith(14.0, width: textView.contentSize.width - textView.contentInset.left * 2) + textView.contentInset.top * 2
            let field2DefaultHeight: CGFloat = UIScreen.main.bounds.height > 480 ? 120 : 96
            self.field2.frame.size.height = field2DefaultHeight > tmpField2Height ? field2DefaultHeight : tmpField2Height
            self.tokenView.frame.origin.y = self.field2.frame.maxY
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: 78 + field2.frame.height + tokenView.frame.height)
            self.containerView.frame.size = CGSize(width: self.containerView.frame.width, height: self.scrollView.contentSize.height)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.tag == 16555 {
            let _rect = field2.caretRect(for: (field2.selectedTextRange?.end)!)
            let a = (_rect.origin.y + UIFont.systemFont(ofSize: 14).lineHeight + 78 + keyboardHeight)
            if (a > (UIScreen.main.bounds.height - 64)) {
                let extraHeight = _rect.origin.y + 78 - self.scrollView.contentOffset.y + keyboardHeight + UIFont.systemFont(ofSize: 14).lineHeight
                let heightExcludeNavbar = UIScreen.main.bounds.height - 64
                let extraScrollOffset = extraHeight - heightExcludeNavbar
                
                UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y + extraScrollOffset), animated: false)
                }, completion: nil)
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isKind(of: UITableView.self) || touch.view!.isKind(of: UITableViewCell.self) {
            return false
        }
        
        return true
    }
    
}

//MARK: token field delegate

extension AddDreamController: TITokenFieldDelegate {
    func tokenFieldDidBeginEditing(_ field: TITokenField!) {
        if self.tokenView.tokenField.isFirstResponder {
            if keyboardShown {
                tokenView.frame.size = CGSize(width: self.tokenView.frame.width, height: UIScreen.main.bounds.height - keyboardHeight - 64)
                
                self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width, height: 78 + field2.frame.height + tokenView.frame.height)
                self.containerView.setHeight(self.scrollView.contentSize.height - 1)
                
                UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.field2.frame.height + 78), animated: false)
                }, completion: nil)
            }
        }
    }
    
    func tokenField(_ field: TITokenField!, shouldUseCustomSearchForSearch searchString: String!) -> Bool {
        return true
    }
    
    func tokenField(_ field: TITokenField!, performCustomSearchForSearch searchString: String!, withCompletionHandler completionHandler: (([Any]?) -> Void)!) {
        if searchString.characters.count > 0 {
            Api.getAutoComplete(searchString) { json in
                if json != nil {
                    if SAValue(json, "error") == "0" {
                        if let d = json!.object(forKey: "data") as? Array<String> {
                            var data = d
                            if d.count > 0 {
                                for i in 0...(d.count - 1) {
                                    data[i] = d[i].decode()
                                }
                            }
                            completionHandler(data)
                        }
                    }
                }
            }
        }
    }
    
    func tokenField(_ tokenField: TITokenField!, didAdd token: TIToken!) {
//        _string.removeAtIndex(advance(token.title.startIndex, 0))
        if self.tagsArray.contains(token.title) {
            return
        }
        
        Api.postTag(SAEncode(SAHtml(token.title)), callback: {
            json in
        })
    }
    
    func tokenField(_ tokenField: TITokenField!, didChangeFrame frame: CGRect) {
    }
    
}

//MARK: UIScrollView Delegate

extension AddDreamController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.dismissKeyboard()
    }
}





















