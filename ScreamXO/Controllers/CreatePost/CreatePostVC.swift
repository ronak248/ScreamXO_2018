//
//  CreatePostVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 29/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import Foundation
extension UIImage {
    
    func isEqualToImage(_ image: UIImage) -> Bool {
        let data1: Data = UIImagePNGRepresentation(self)!
        let data2: Data = UIImagePNGRepresentation(image)!
        return (data1 == data2)
    }
}

protocol PostplainActionDelegate  {
    func postData()
}

class TaggingCell: UITableViewCell {
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var imgUser: UIImageView!
    override func awakeFromNib() {
        self.layoutIfNeeded()
    }
    override func layoutSubviews() {
        self.imgUser.layer.masksToBounds = true
        self.imgUser.layer.cornerRadius = self.imgUser.bounds.width/2
    }
}

class CreatePostVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    
    var delegate : PostplainActionDelegate!
    var objEmojiView: emojiView?
    var finalMesage:String = ""
    var filterString:String = ""
    var filterArray = [SearchResult]()
    var searchStr = ""
    var searchOffset = 1
    var searchLimit = 10
    var searchTotalUser = 0
    var posttagids = [String]()
    var recordingHashTag = false
    var startParse = 0
    var createPostClicked = false
    
    var timerArray = [["title": "30 min", "value": 30], ["title": "1 Hour", "value": 60],["title": "4 Hours", "value": 240],["title": "12 Hours", "value": 720], ["title": "24 Hours", "value": 1440]]
    var selectedDate: Int?
    var tblType: String?
    var timerSelectedIndexPath: IndexPath?
    var isTimerVisible = true
    
    // MARK: IBOutlets
    
    @IBOutlet weak var txtPost: MintAnnotationChatView!
    @IBOutlet var addEmojiView: emojiView!
    @IBOutlet var emojiViewCollection: emojiSetView!
    @IBOutlet var btnDatePicker: UIButton!
    @IBOutlet var tblTagging: UITableView!
    @IBOutlet var tblTimer: UITableView!
     @IBOutlet var userLbl: HeaderLable!
    
    // MARK: Contstraint IBOutlet
    
    @IBOutlet var constHeightUserDetailView: NSLayoutConstraint!
    @IBOutlet var constHeightTblTimer: NSLayoutConstraint!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        hideTimer()
        hideTblTagging()
        tblTagging.delegate = self
        tblTagging.dataSource = self
        tblTimer.delegate = self
        tblTimer.dataSource = self
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        emojiViewCollection.emojiCollectionView.delegate = self
        emojiViewCollection.emojiCollectionView.dataSource = self
        addEmojiView.createPostVC = self
        addEmojiView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40)
        
        txtPost.delegate = self
        txtPost.inputAccessoryView = addEmojiView
        txtPost.becomeFirstResponder()
        txtPost.isSelectable = true
        txtPost.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.openImage(_:)))
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(CreatePostVC.dismissKeyboard))
        self.view.addGestureRecognizer(hideKeyboardGesture)
        tapGesture.numberOfTapsRequired = 1
        
        txtPost.enablesReturnKeyAutomatically = true
        
        addEmojiView.userImg.layer.masksToBounds = true
        addEmojiView.userImg.layer.cornerRadius = addEmojiView.userImg.bounds.width/2
        print(UserManager.userManager.profileImage!)
      addEmojiView.userImg.sd_setImageWithPreviousCachedImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: {
            (a, b , url) -> Void in
        }, completed: {
            (img, error, type, url) -> Void in
            if img != nil {
                
            } else {
            }
        })
        
       
        //addEmojiView.userImg.sd_setImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeholder"))
        
        self.view.layoutIfNeeded()
        txtPost.placeholderText = "     (Text starts here)..."
        txtPost.nameTagColor = UIColor.lightGray
    }
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  UITextViewDelegateMethods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.hideTblTagging()
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        print("chnge")
        self.txtPost.textViewDidChange(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        //  let resultPredicate = NSPredicate(format: "name contains[c] %@", textView.text)
        
    }
    
 
    
    
 
    func openImage(_ sender: AnyObject) {
        
        let tapguesture = sender as! UITapGestureRecognizer
        let imageInfo = JTSImageInfo()
        let imgVIew = tapguesture.view as! UIImageView
        imageInfo.image = imgVIew.image
        imageInfo.referenceView = imgVIew
        imageInfo.referenceRect = imgVIew.frame
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
        imageViewer?.show(from: self, transition: JTSImageViewControllerTransition.fromOriginalPosition)
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
        
        
        if textView == txtPost {
            if txtPost.text.characters.count > 0 {
              txtPost.enablesReturnKeyAutomatically = false
            }
            
            if text == "\n" {
                if(textView.text.characters.count > 0) {
                    self.sendMessage()
                    return false
                }
            } else if text == "@" {
            }
        } else {
        
        
        if (text == "@") {
            recordingHashTag = true
            startParse = range.location
        }
        
        if recordingHashTag == true {
            var value = ""
            if startParse == 0
            {
                if text != ""
                {
                    var finalStr = textView.text
                    finalStr = finalStr! + text
                    if (finalStr! as NSString).length - startParse > startParse
                    {
                        if (finalStr! as NSString).length - startParse > 0
                        {
                            value = (finalStr! as NSString).substring(with: NSRange(location: startParse, length: (finalStr! as NSString).length - startParse))
                            if value.characters.count > 0
                            {
                                filterString = value
                                if "\(value.characters.first!)" == "@"
                                {
                                    value.remove(at: value.startIndex)
                                }
                                searchStr = value
                                self.filterHashTagTableWithHash(value)
                            }
                            else
                            {
                                hideTblTagging()
                            }
                        }
                    }
                } else if text == "" {
                    var finalStr = textView.text
                    if (finalStr?.characters.count)! > 0 {
                        finalStr?.remove(at: (finalStr?.index((finalStr?.endIndex)!, offsetBy: -1))!)
                        if startParse < (finalStr! as NSString).length - startParse {
                            if (finalStr! as NSString).length - startParse > 0 {
                                value = (finalStr! as NSString).substring(with: NSRange(location: startParse, length: (finalStr! as NSString).length - startParse))
                                if value.characters.count > 0 {
                                    filterString = value
                                    if "\(value.characters.first!)" == "@" {
                                        value.remove(at: value.startIndex)
                                    }
                                    self.filterHashTagTableWithHash(value)
                                } else {
                                    hideTblTagging()
                                }
                            }
                        }
                    }
                }
            } else if text != "" {
                var finalStr = textView.text
                finalStr = finalStr! + text
                if startParse > (finalStr! as NSString).length - startParse {
                    if (finalStr! as NSString).length - startParse > 0 {
                        value = (finalStr! as NSString).substring(with: NSRange(location: startParse, length: (finalStr! as NSString).length - startParse))
                        if value.characters.count > 0 {
                            filterString = value
                            value.remove(at: value.startIndex)
                            self.filterHashTagTableWithHash(value)
                        } else {
                            hideTblTagging()
                        }
                    }
                }
            } else if text == "" {
                var finalStr = textView.text
                if (finalStr?.characters.count)! > 0 {
                    finalStr?.remove(at: (finalStr?.index((finalStr?.endIndex)!, offsetBy: -1))!)
                    if startParse > (finalStr! as NSString).length - startParse {
                        if (finalStr! as NSString).length - startParse > 0 {
                            value = (finalStr! as NSString).substring(with: NSRange(location: startParse, length: (finalStr! as NSString).length - startParse))
                            if value.characters.count > 0 {
                                filterString = value
                                if "\(value.characters.first!)" == "@" {
                                    value.remove(at: value.startIndex)
                                }
                                self.filterHashTagTableWithHash(value)
                            } else {
                                hideTblTagging()
                            }
                        }
                    }
                }
            }
            print(value)
        }
        }
        return self.txtPost.shouldChangeText(in: range, replacementText: text)
        
    }
    
    func filterHashTagTableWithHash(_ hash: String) {
        searchOffset = 1
        searchLimit = 10
        SearchFriend(hash)
    }
    func SearchFriend(_ hash: String)
    {
        var useridStringArray: String = ""
        
        if let annotationList = txtPost.annotationList
        {
            for annotation in (txtPost.annotationList)!
            {
                let mintAnnotation = annotation as! MintAnnotation
                if annotationList.index(of: annotation) == (annotationList.count - 1)
                {
                    useridStringArray += mintAnnotation.usr_id
                }
                else
                {
                    useridStringArray += "\(mintAnnotation.usr_id),"
                }
            }
        }
        
        print(hash)
        if hash.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            hideTblTagging()
            return
        }
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(searchOffset, forKey: "offset")
        parameterss.setValue(searchLimit, forKey: "limit")
        parameterss.setValue(hash, forKey: "string")
        parameterss.setValue(usr.userId, forKey: "uid")
    
        if useridStringArray.characters.count > 0
        {
            print(useridStringArray)
            parameterss.setValue(useridStringArray, forKey: "userids")

        }

        print(parameterss)
        
        SVProgressHUD.show(withStatus: "Fetching Friends", maskType: SVProgressHUDMaskType.clear)
        mgr.SearchFriendTagging(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                print(dic!)
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int {
                    self.searchTotalUser = countShop
                }
                if self.searchOffset == 1 {
                    self.filterArray.removeAll()
                    for searchObject in (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray {
                        let json = SearchResult.Populate(searchObject as! NSDictionary)
                        self.filterArray.append(json)
                    }
                } else {
                    for searchObject in (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray {
                        let json = SearchResult.Populate(searchObject as! NSDictionary)
                        self.filterArray.append(json)
                    }
                }
                if self.filterArray.count > 0 {
                    self.showTblTagging()
                }
                else {
                    self.hideTblTagging()
                }
                self.tblTagging.reloadData()
                SVProgressHUD.dismiss()
                
            } else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.view.endEditing(true)
                
            } else {
                SVProgressHUD.dismiss()
                self.view.endEditing(true)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    // MARK: UICollectionViewDelegateMethods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == emojiViewCollection.emojiCollectionView {
            return 1
        } else {
            return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customEmojis.emojiItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "EmojiCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! EmojiCollectionViewCell
        cell.emojiImage?.image =  customEmojis.emojiItems[customEmojis.emojiItemsArray[indexPath.row]]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let textAttachment = MyTextAttachment()
        let emoji =  customEmojis.emojiItemsArray[indexPath.row]
        textAttachment.image = customEmojis.emojiItems[emoji]
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        let mutAttrString = NSMutableAttributedString()
        mutAttrString.append(txtPost.attributedText)
        mutAttrString.append(attrStringWithImage)
        let txtViewFontSize = txtPost.font?.pointSize
        
        let textAttrib = [NSForegroundColorAttributeName : colors.kTextViewColor,
                          NSFontAttributeName : UIFont(name: (txtPost.font?.fontName)!, size: txtViewFontSize!)!]
        
        mutAttrString.addAttributes(textAttrib, range: NSRange(location: 0,length: mutAttrString.length))
        
        txtPost.attributedText = mutAttrString
        print(txtPost.attributedText)
    }
    
    // MARK: UITableView Delegate Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tblTagging {
            return filterArray.count
        } else {
            return timerArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tblTagging {
            return UIView()
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        
        let btnTime = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerView.frame.height))
        headerView.backgroundColor = UIColor.init(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
        btnTime.titleLabel?.font = UIFont(name: fontsName.KfontproxisemiBold, size: 22)
        
        btnTime.setImage(UIImage(named: "timer_new_icon"), for: UIControlState())
        btnTime.setTitle("Control", for: UIControlState())
        btnTime.setTitleColor(UIColor(hexString: "28BAB7"), for: UIControlState())
        btnTime.titleEdgeInsets.left = 20
        btnTime.titleLabel?.textAlignment = NSTextAlignment.center
        headerView.addSubview(btnTime)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == tblTagging {
            return UIView()
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        footerView.backgroundColor = UIColor.init(red: 163.0/255.0, green: 182.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        let btnFooter = UIButton(frame: CGRect(x: 0, y: 0, width: footerView.frame.width, height: footerView.frame.height))
        btnFooter.titleLabel?.font = UIFont(name: fontsName.KfontproxiRegular, size: 14)!
        btnFooter.addTarget(self, action: #selector(self.cancelTimerTapped), for: .touchUpInside)
        btnFooter.setTitle("Cancel", for: UIControlState())
        btnFooter.titleLabel?.textAlignment = NSTextAlignment.center
        btnFooter.setTitleColor(UIColor.black, for: UIControlState())
        footerView.addSubview(btnFooter)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == tblTagging {
            return 0.1
        }
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTagging {
            return 0.1
        }
        return 50.0
    }
    
    func tableView(_ tableView:  UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblTagging {
            let cellIdentifier = "TaggingCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TaggingCell
            cell.lblUserName.text = filterArray[indexPath.row].username
            cell.imgUser.sd_setImage(with: URL(string: filterArray[indexPath.row].photo), placeholderImage: UIImage(named: "profile"))
            if indexPath.row == filterArray.count-1 && searchTotalUser > filterArray.count {
                searchOffset = searchOffset + 1
                SearchFriend(searchStr)
            }
            return cell
        } else {
                let cellIdentifier = "tblTimerCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! tblTimerCell
                cell.contentView.backgroundColor = UIColor.init(red: 10/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0)
                cell.lblTime.text = timerArray[indexPath.row]["title"] as? String
                return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == tblTagging {
            let newAnnoation = MintAnnotation()
            newAnnoation.usr_id = "\(filterArray[indexPath.row].userid)"
            newAnnoation.usr_name = filterArray[indexPath.row].username
            
            let str = txtPost.text as NSString
            let lastComma = str.range(of: filterString, options: .backwards).toTextRange(textInput: txtPost)
            if let comma = lastComma {
                txtPost.replace(comma, withText: "")
            }
            recordingHashTag = false
            self.txtPost.add(newAnnoation)
            self.txtPost.makeStringWithTag()
            hideTblTagging()
            txtPost.becomeFirstResponder()
            filterString = ""
        }
        
        if tableView == tblTimer {
            
            self.selectedDate = self.timerArray[indexPath.row]["value"] as? Int
            print(timerArray[indexPath.row]["value"] as! Int)
            timerSelectedIndexPath = indexPath
            self.hideTimer()
        }
        
    }
    // MARK: - customButton Methods
    @IBAction func btnDatePickerClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        if isTimerVisible {
            self.showTimer()
        } else {
            self.hideTimer()
        }
    }
    
    func cancelTimerTapped() {
        self.hideTimer()
    }
    
    func showTimer()
    {
        isTimerVisible = false
        tblTimer.isScrollEnabled = true
        constHeightTblTimer.constant = 270
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        tblTimer.reloadData()
        tblTimer.selectRow(at: timerSelectedIndexPath, animated: false, scrollPosition: .none)
    }
    
    func hideTimer()
    {
        isTimerVisible = true
        tblTimer.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            self.constHeightTblTimer.constant = 0
            self.view.layoutIfNeeded()
        })
        txtPost.becomeFirstResponder()
        tblTimer.reloadData()
    }
    
    func sendMessage() {
        if txtPost.text.characters.count == 0
        {
            dismissKeyboard()
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter text")
            
        }
        else if createPostClicked == false
        {
            createPostClicked = true
            if mainInstance.connected()
            {
                let txtPostAttribString = self.txtPost.taggedString()
                self.txtPost.makeStringWithoutTagString()
                
                let txtMutableAttribString = NSMutableAttributedString(attributedString: txtPostAttribString!)
                
                txtMutableAttribString.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, txtMutableAttribString.length), options: [], using: {(value: Any?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if (value is NSTextAttachment) {
                        let attachment = (value as! NSTextAttachment)
                        var image: UIImage!
                        if attachment.image != nil  {
                            
                            image = attachment.image
                            
                            if let emojiName = objAppDelegate.getEmojiName(image) {
                                txtMutableAttribString.replaceCharacters(in: range, with: NSAttributedString(string: emojiName))
                            }
                        }
                        return
                    }
                    var annoation: MintAnnotation? = nil
                    if (value != nil) {
                        annoation = self.txtPost.annotation(forId: value as! String)
                    }
                    if annoation != nil {
                        let replaceTo = "@:@:\(annoation!.usr_id)"
                        txtMutableAttribString.replaceCharacters(in: range, with: replaceTo)
                    }
                })
                print(txtMutableAttribString.string)
                
                var strMsg =  txtMutableAttribString.string
                //message.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                if strMsg.characters.last == "\n"
                {
                    strMsg = String(strMsg.characters.dropLast())
                }
                
                let stringAsData = strMsg.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                let dstString = NSString(data: stringAsData, encoding: String.Encoding.utf8.rawValue)!
                dstString // => "
                
                let usr = UserManager.userManager
                let parameterss = NSMutableDictionary()
                parameterss.setValue("0", forKey: "posttype")
                parameterss.setValue(usr.userId, forKey: "postedby")
                parameterss.setValue(txtMutableAttribString.string, forKey: "posttitle")
//                for ids in txtPost.annotationList {
//                    posttagids.append((ids as! MintAnnotation).usr_id)
//                }
                var dict = [String:String]()
                if txtPost.rangesOfAt != nil {
                    if txtPost.rangesOfAt.count > 0 {
                        if txtPost.rangesOfAt.count == txtPost.rangesOfAtOriginal.count {
                            for index in 0..<txtPost.rangesOfAt.count {
                                dict[txtPost.rangesOfAtOriginal.object(at: index) as! String] = txtPost.rangesOfAt.object(at: index) as? String
                            }
                        }
                    }
                }
                
                print(dict)
                parameterss.setValue(dict, forKey: "posttagids")
                if selectedDate != nil && selectedDate != 0 {
                    parameterss.setValue("\(selectedDate!)", forKey: "posttiming")
                }
                
                let mgr = APIManager.apiManager
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                
                mgr.createPost(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess
                    {
                        SVProgressHUD.dismiss()
                        if self.delegate == nil
                        {
                        }
                        else
                        {
                            self.delegate.postData()
                        }
                        self.view.endEditing(true)
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        
                        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "HomeScreen")) as! HomeScreen
                        self.navigationController?.pushViewController(VC1, animated: true)
                        
                        //self.navigationController?.popViewController(animated: true)
                    }
                    else if result == APIResult.apiError
                    {
                        print(dic!)
                        self.view.endEditing(true)
                        
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                    }
                    else
                    {
                        self.view.endEditing(true)
                        mainInstance.showSomethingWentWrong()
                    }
                })
            }
            else
            {
                mainInstance.ShowAlertWithError("No internet connection", msg: (constant.kinternetMessage as NSString))
            }
        }
    }
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    // MARK: Methods
    
    func showTblTagging() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tblTagging.isHidden = false
            
        })
    }
    
    func hideTblTagging() {
        self.txtPost.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.tblTagging.isHidden = true
        })
        
    }
    
//    func keyboardDidShow() {
//        addEmojiView.isHidden = false
//    }
//    
//    func keyboardDidHide() {
//        addEmojiView.isHidden = true
//    }
    
    
}
extension UITextView {
    
    func resolveHashTags(){
        
        // turn string in to NSString
        let nsText:NSString = (self.text as NSString?)!
        
        // this needs to be an array of NSString.  String does not work.
        let words:[NSString] = (nsText.components(separatedBy: " ") as [NSString])
        
        // you can't set the font size in the storyboard anymore, since it gets overridden here.
        let attrs = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 17.0)
        ]
        
        // you can staple URLs onto attributed strings
        let attrString = NSMutableAttributedString(string: nsText as String, attributes:attrs)
        
        // tag each word if it has a hashtag
        for word in words {
            
            // found a word that is prepended by a hashtag!
            // homework for you: implement @mentions here too.
            if word.hasPrefix("#") {
                
                // a range is the character position, followed by how many characters are in the word.
                // we need this because we staple the "href" to this range.
                let matchRange:NSRange = nsText.range(of: word as String)
                
                // convert the word from NSString to String
                // this allows us to call "dropFirst" to remove the hashtag
                var stringifiedWord:String = word as String
                
                // drop the hashtag
                stringifiedWord = String(stringifiedWord.characters.dropFirst())
                
                // check to see if the hashtag has numbers.
                // ribl is "#1" shouldn't be considered a hashtag.
                let digits = CharacterSet.decimalDigits
                
                if let numbersExist = stringifiedWord.rangeOfCharacter(from: digits) {
                    // hashtag contains a number, like "#1"
                    // so don't make it clickable
                } else {
                    // set a link for when the user clicks on this word.
                    // it's not enough to use the word "hash", but you need the url scheme syntax "hash://"
                    // note:  since it's a URL now, the color is set to the project's tint color
                    attrString.addAttribute(NSLinkAttributeName, value: "hash:\(stringifiedWord)", range: matchRange)
                }
                
            }
        }
        
        // we're used to textView.text
        // but here we use textView.attributedText
        // again, this will also wipe out any fonts and colors from the storyboard,
        // so remember to re-add them in the attrs dictionary above
        self.attributedText = attrString
    }
}
extension NSRange {
    func toTextRange(textInput:UITextInput) -> UITextRange? {
        if let rangeStart = textInput.position(from: textInput.beginningOfDocument, offset: location),
            let rangeEnd = textInput.position(from: rangeStart, offset: length) {
            return textInput.textRange(from: rangeStart, to: rangeEnd)
        }
        return nil
    }
}
class SearchResult {
    var address = ""
    var city = ""
    var fname = ""
    var friendshipid = 0
    var isfriend = 0
    var issent = 0
    var lname = ""
    var photo = ""
    var userid = 0
    var username = ""
    func Populate(_ dictionary:NSDictionary) {
        if let answer = dictionary["address"] as? String
        {
            address = answer
        }
        if let answer = dictionary["city"] as? String
        {
            city = answer
        }
        if let answer = dictionary["fname"] as? String
        {
            fname = answer
        }
        if let answer = dictionary["friendshipid"] as? Int
        {
            friendshipid = answer
        }
        if let answer = dictionary["isfriend"] as? Int
        {
            isfriend = answer
        }
        if let answer = dictionary["issent"] as? Int
        {
            issent = answer
        }
        if let avatarImg = dictionary["lname"] as? String
        {
            lname = avatarImg
        }
        if let avatarImg = dictionary["photo"] as? String
        {
            photo = avatarImg
        }
        if dictionary["username"] != nil
        {
            username = dictionary["username"] as! String
        }
        if let answer = dictionary["userid"] as? Int
        {
            userid = answer
        } else if let answer = dictionary["userid"] as? String {
            userid = Int(answer)!
        }
    }
    class func Populate(_ dictionary:NSDictionary) -> SearchResult
    {
        let result = SearchResult()
        result.Populate(dictionary)
        return result
    }
}

