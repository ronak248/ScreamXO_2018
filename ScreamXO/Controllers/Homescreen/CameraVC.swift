//
//  CameraVC.swift
//  ScreamXO
//
//  Created by Jasmin Patel on 15/12/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AVKit
import AFNetworking
class CameraVC: UIViewController , UIScrollViewDelegate {
    
    @IBOutlet var viewPreview: UIView!
    
    
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var imgPreview: UIImageView!
    @IBOutlet var txtPost: MintAnnotationChatView!
    @IBOutlet var tblTagging: UITableView!
    var imgPhoto: UIImage!
    
    var recordingHashTag = false
    var startParse = 0
    var searchStr = ""
    var searchOffset = 1
    var searchLimit = 5
    var searchTotalUser = 0
    var filterString:String = ""
    var posttagids = [String]()
    var filterArray = [SearchResult]()
    var placeholderLabel : UILabel!
    var dataVideofnl : Data?
    var videoUrl: URL? = nil
    
    
    //camera
    lazy var cameraView = FSCameraView.instance()
    @IBOutlet weak var cameraShotContainer: UIView!
    var delegate: FusumaDelegate? = nil
    var delegatePost : PostmediaActionDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtPost.delegate = self
        cameraView.delegate = self
        cameraShotContainer.addSubview(cameraView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyBoardNew(_:)), name: NSNotification.Name(rawValue: "hideKeyBoardNew"), object: nil)
    }
    
    
    func hideKeyBoardNew(_ sender:AnyObject)  {
       self.view.endEditing(true)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        txtPost.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
        cameraView.layoutIfNeeded()
        
        placeholderTextView()
        hideTblTagging()
    }
    
    func placeholderTextView() {
        txtPost.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Write caption"
        placeholderLabel.sizeToFit()
        txtPost.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: txtPost.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.isHidden = !txtPost.text.isEmpty
    }
    
    func UploadPost(_ typeFile: Int,data: Data?,typeMedia: String) {
        if mainInstance.connected() {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "goToPageMiddle"), object: nil)
            let usr = UserManager.userManager
            SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
            let mgr = APIManager.apiManager
            
            let parameterss = NSMutableDictionary()
            parameterss.setValue(typeFile, forKey: "posttype")
            parameterss.setValue(usr.userId, forKey: "postedby")
            
            let txtPostAttribString = self.txtPost.taggedString()
            self.txtPost.makeStringWithoutTagString()
            var Strfulltitle = ""
            if (txtPostAttribString?.string.characters.count)! > 0 {
                Strfulltitle = Strfulltitle + "@@:-:@@" + (txtPostAttribString?.string)!
            }
            parameterss.setValue(Strfulltitle, forKey: "posttitle")
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

            print("parameter : %@",parameterss)
            
            mgr.manager.responseSerializer.acceptableContentTypes=NSSet(array: ["text/html"]) as? Set<String>
            mgr.manager.requestSerializer.timeoutInterval = TimeInterval(300)
            if let sessionStr:String = mgr.sessionToken
            {
                mgr.manager.requestSerializer.setValue(sessionStr, forHTTPHeaderField: "usertoken")
                mgr.manager.requestSerializer.setValue(UserManager.userManager.userId, forHTTPHeaderField: "uid")
                if ( mgr.deviceID != nil)
                {
                    mgr.manager.requestSerializer.setValue(mgr.deviceID, forHTTPHeaderField: "userdevice")
                  
                }
                else
                {
                    mgr.manager.requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
                    mgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                    
                }
            }
            
            mgr.manager.post(APIManager.APIConstants.ScreamXOBaseUrl + APIManager.APIConstants.createPostEndPoint,
                             parameters: parameterss, constructingBodyWith: {(formData: AFMultipartFormData!) -> Void in
                                if data != nil {
                                    
                                    if typeMedia == "image"
                                    {
                                        formData.appendPart(withFileData: UIImagePNGRepresentation(self.imgPhoto)!, name: "media[1]", fileName: "Postcreation.png", mimeType: "image/png")
                                    }
                                    else if typeMedia == "video"
                                    {
                                        
                                        formData.appendPart(withFileData: data!, name: "media[1]", fileName: "testvideo.mp4", mimeType: "video/mp4")
                                    }
                                }
                },success: { operation,responseObject in
                    print((responseObject! as AnyObject).description)
                    SVProgressHUD.dismiss()
                    let info = responseObject as! NSDictionary
                    print(info)
                    if(info.object(forKey: "status") as! String == "0"){
                        
                        mainInstance.ShowAlertWithError("Error!", msg: info.object(forKey: "msg") as! String as NSString)
                        
                    } else {
                        
                        if self.delegatePost == nil
                        {
                        }
                        else
                        {
                            self.delegatePost.postmediaData()
                        }
                        
                        
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: info.value(forKey: "msg")! as! NSString)
                        
                    }
                },
                  failure: { operation,error in
                    print(error.localizedDescription)
                    SVProgressHUD.dismiss()
                    mainInstance.ShowAlertWithError("Error!", msg: constant.ktimeout as NSString)
                    
            })            
        }
        else
        {
            mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
        }
        
    }
    func openCamera() {
        if cameraView.session == nil {
            cameraView.initialize()
        } else {
            cameraView.startCamera()
        }
    }
    func dismissCamera() {
        self.stopAll()
    }
    func stopAll() {
        self.cameraView.stopCamera()
    }
}
extension CameraVC {
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            self.viewPreview.removeFromSuperview()
            }, completion: {
                result in
                self.cameraView.initialize()
                var movieData: Data?
                var type = ""
                if let url = self.videoUrl {
                    //video
                    type = "video"
                    if let dataVideo = try? Data(contentsOf: url) {
                        movieData = dataVideo
                    } else {
                        movieData = self.dataVideofnl
                    }
                    
                } else {
                    //image
                    type = "image"
                    let image = self.imgPreview.image
                    self.imgPhoto=self.imgPreview.image?.fixOrientation()
                    movieData = UIImageJPEGRepresentation(image!, 0.8)
                    
                }
                self.UploadPost(1, data: movieData, typeMedia: type)
        })
        }
    }
    
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {

        cameraView.initialize()
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            self.viewPreview.removeFromSuperview()
            
            }, completion: { result in
            self.cameraView.initialize()
        })
    }
    
        func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
    }
    
    func thumbnail(_ sourceURL:URL) -> Void {
        
        let asset = AVURLAsset(url: sourceURL, options: nil)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(0.1, 1)
        
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
            requestedTime, thumbnail, actualTime, result, error in
            DispatchQueue.main.async(execute: { () -> Void in
                self.imgPreview.image = UIImage(cgImage: thumbnail!)
            })
        }
    }
    @IBAction func btnPlayPressed(_ sender: AnyObject) {
        if let url = videoUrl {
            let player = AVPlayer(url: url)
            let controller=AVPlayerViewController()
            controller.player=player
            self.present(controller, animated: false, completion: nil)
            player.play()
        }
    }
    
    
}

extension CameraVC: FSCameraViewDelegate {
    func intialSetupForPreview() {
        self.txtPost.text = ""
        self.placeholderLabel.isHidden = !self.txtPost.text.isEmpty
        self.txtPost.resignFirstResponder()
    }
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        intialSetupForPreview()
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            
            self.view.addSubview(self.viewPreview)
            
            }, completion: nil)
        btnPlay.isHidden = true
        videoUrl = nil
        print("Image selected")
        imgPreview.image = image
        delegate?.fusumaImageSelected(image)
        self.dismiss(animated: false, completion: {
            
            self.delegate?.fusumaDismissedWithImage?(image)
        })
    }
    func videoFinishedFinal(withFileURL dataasset: Data,fileUrl:URL) {
        intialSetupForPreview()
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            
            self.view.addSubview(self.viewPreview)
            
            }, completion: nil)
        btnPlay.isHidden = false
        thumbnail(fileUrl)
        videoUrl = fileUrl
        dataVideofnl = dataasset
        self.dismiss(animated: false, completion: nil)
        delegate?.fusumaVideoCompletedwithData(withFileURL: dataasset, fileURLL: fileUrl)
    }
    // MARK: FSAlbumViewDelegate
    func albumViewCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        delegate?.fusumaCameraRollUnauthorized()
    }
    
    func videoFinished(withFileURL fileURL: URL) {
        intialSetupForPreview()
        delegate?.fusumaVideoCompleted(withFileURL: fileURL)
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            
            self.view.addSubview(self.viewPreview)
            
            }, completion: nil)
        btnPlay.isHidden = false
        thumbnail(fileURL)
        videoUrl = fileURL
        self.dismiss(animated: false, completion: nil)
    }
    
}
extension CameraVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.text = nil
        self.hideTblTagging()
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        print("chnge")
        placeholderLabel.isHidden = !txtPost.text.isEmpty
        self.txtPost.textViewDidChange(textView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
        if (text == "@") {
            recordingHashTag = true
            startParse = range.location
        } else if text == "\n" {
        
            txtPost.resignFirstResponder()
            return false

        }
        if recordingHashTag == true {
            var value = ""
            if startParse == 0 {
                if text != "" {
                    var finalStr = textView.text
                    finalStr = finalStr! + text
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
                                searchStr = value
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
        return self.txtPost.shouldChangeText(in: range, replacementText: text)
    }
    func filterHashTagTableWithHash(_ hash: String) {
        searchOffset = 1
        searchLimit = 10
        SearchFriend(hash)
    }
    func SearchFriend(_ hash: String)
    {
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
        SVProgressHUD.show(withStatus: "Fetching Users", maskType: SVProgressHUDMaskType.clear)
        mgr.SearchFriendTagging(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
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
                self.showTblTagging()
                SVProgressHUD.dismiss()
                
            } else if result == APIResult.apiError {
                
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
}
extension CameraVC: UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
        
    {
        return filterArray.count
        
    }
    

 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TaggingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! TaggingCell
        cell.lblUserName.text = filterArray[indexPath.row].username
        cell.imgUser.sd_setImage(with: URL(string: filterArray[indexPath.row].photo), placeholderImage: UIImage(named: "profile"))
        if indexPath.row == filterArray.count-1 && searchTotalUser > filterArray.count {
            searchOffset = searchOffset + 1
            SearchFriend(searchStr)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newAnnoation = MintAnnotation()
        newAnnoation.usr_id = "\(filterArray[indexPath.row].userid)"
        newAnnoation.usr_name = filterArray[indexPath.row].username
        
        let str = txtPost.text as NSString
        let lastComma = str.range(of: filterString, options: .backwards).toTextRange(textInput: txtPost)
        if let comma = lastComma {
            txtPost.replace(comma, withText: "")
        }
        recordingHashTag = false
        self.txtPost.nameTagColor = UIColor.clear
        self.txtPost.add(newAnnoation)
        self.txtPost.makeStringWithTag()
        hideTblTagging()
        txtPost.becomeFirstResponder()
        filterString = ""
    }
}


