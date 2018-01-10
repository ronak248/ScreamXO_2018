//
//  CreatePost_Media.swift
//  ScreamXO
//
//  Created by Ronak Barot on 29/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking
import GTMOAuth2
import AVKit
import GoogleAPIClient
import GoogleSignIn
import MSAL

protocol PostmediaActionDelegate  {
    func postmediaData()
}

class tblTimerCell: UITableViewCell {
    
    @IBOutlet var lblTime: UILabel!
}

class tblAudioCell: UITableViewCell {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var imgView: UIImageView!
}

class CreatePost_Media: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate, UIDocumentPickerDelegate,UIDocumentMenuDelegate, UITableViewDataSource, UITableViewDelegate,UITextViewDelegate, GIDSignInDelegate,GIDSignInUIDelegate,URLSessionDelegate {
    
    ///// for google drive
    
    enum MediaType : NSInteger
    {
        case isPhoto = 0,isVideo,isAudio,isMusic,ismp3,ismp4,ism4A
    }
    
    // MARK: Properties
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var popovermain: UIPopoverController!
    
    var imgPhoto: UIImage!
    var urlVideo: URL!
    var dataVideofnl: Data!
    
    var blurEffectView = UIVisualEffectView()
    var imgartWorkup: UIImage!
    var isartwork :Bool = false
    var typeMedia:Int?
    var typeFile:Int = 1
    var isPickerVisible  = true
    var isTimerVisible = true
    var isAudioVisible = true
    var delegate : PostmediaActionDelegate!
    var recorder: AVAudioRecorder!
    var player:AVAudioPlayer!
    var meterTimer:Timer!
    var dataGdrive:Data!
    
    var soundFileURL:URL!
    var isImage :Bool!
    
    var strsongname :String = ""
    var strartistname :String = ""
    
    var timerArray = [["title": "30 min", "value": 30], ["title": "1 Hour", "value": 60],["title": "4 Hours", "value": 240],["title": "12 Hours", "value": 720], ["title": "24 Hours", "value": 1440]]
    
    var audioArray = ["iCloud Drive", "Google Drive", "OneDrive", "More"]
    var audioImgArray = [UIImage(named: "ico_iCloud"), UIImage(named: "ico_google_drive"), UIImage(named: "ico_onedrive"), UIImage(named: "ico_more")]
    var audiDict: [String: UIImage] = ["iCloud Drive": UIImage(named: "ico_iCloud")!, "Google Drive": UIImage(named: "ico_google_drive")!, "OneDrive": UIImage(named: "ico_onedrive")!, "More": UIImage(named: "ico_more")!]
    
    var selectedDate: Int?
    
    var videoUrl: URL? = nil
    var timerSelectedIndexPath: IndexPath?
    var searchOffset = 1
    var searchLimit = 10
    var isRecord = false
    
    
    // MARK: IBOutlets
    
    @IBOutlet var imgMiceImg: RoundImage!
    @IBOutlet var viewPreview: UIView!
    @IBOutlet var viewAudioPreview: UIView!
    @IBOutlet var viewCustomCameraPreview: UIView!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var imgPreview: UIImageView!
    @IBOutlet weak var imgartwork: RoundImage!
    @IBOutlet var viewThumbnail: UIView!
    @IBOutlet weak var txtsongname: UITextField!
    
    @IBOutlet var viewArtistView: UIControl!
    @IBOutlet weak var btnmusic: UIButton!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnphoto: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet var tblTimer: UITableView!
    @IBOutlet var constHeightTblTimer: NSLayoutConstraint!
    @IBOutlet var txtPost: MintAnnotationChatView!
    @IBOutlet var tblAudio: UITableView!
    @IBOutlet var tblTagging: UITableView!
    var filterString:String = ""
    var searchStr = ""
    var searchTotalUser = 0
    var posttagids = [String]()
    var filterArray = [SearchResult]()
    var placeholderLabel : UILabel!
    
    @IBOutlet var constHeightTblAudio: NSLayoutConstraint!
    
    
    // MARK: - Google Drive instance Var
    
    
    private let scopes = [kGTLAuthScopeDriveReadonly]
    
    private let service = GTLServiceDrive() //GTLDriveService()
    let signInButton:GIDSignInButton!     = GIDSignInButton() //GIDSignInButton()
    let output = UITextView()
    
    
    // MARK: - One Drive instance Var
    
    
    
    let kClientID = "5494c57c-8e9a-47cb-82da-adcd4be5a304"
    let kAuthority = "https://login.microsoftonline.com/common/v2.0"
    
    let kGraphURI = "https://graph.microsoft.com/v1.0/me/"
    let kScopes: [String] = ["https://graph.microsoft.com/user.read"]
    
    var accessToken = String()
    var applicationContext = MSALPublicClientApplication.init()
    
    @IBOutlet weak var loggingText: UITextView!
    @IBOutlet weak var signoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: Selector(("handleDidLinkNotification:")), name: NSNotification.Name(rawValue: "didLinkToDropboxAccountNotification"), object: nil)

        
        
        if let navController = self.navigationController {
            navController.interactivePopGestureRecognizer?.delegate = nil
        }
        
        txtsongname.delegate = self
        tblTagging.isHidden = true
        constHeightTblTimer.constant = 50
        constHeightTblAudio.constant = 0
        tblTimer.delegate = self
        tblTimer.dataSource = self
        tblTimer.isScrollEnabled = false
        tblAudio.delegate = self
        tblAudio.dataSource = self
        self.isImage = false
        clearData()
        placeholderTextView()
        
        
        do {
            self.applicationContext = try MSALPublicClientApplication.init(clientId: kClientID, authority: kAuthority)
        } catch {
            self.loggingText.text = "Unable to create Application Context. Error: \(error)"
        }
  
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !DBSession.shared().isLinked() {
            DBSession.shared().link(from: self)
        }
        else {
            DBSession.shared().unlinkAll()
        }
        
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
        
        if self.accessToken.isEmpty {
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
        
        if self.recorder != nil {
            self.recorder.stop()
            self.meterTimer.invalidate()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
                
            } catch let error as NSError {
                print("could not make session inactive")
                print(error.localizedDescription)
            }
        }
    }
    
    
    
   //MARK:- Call the Microsoft Graph API using the token you just obtained
    
    func getContentWithToken() {
        
        let sessionConfig = URLSessionConfiguration.default
        
        // Specify the Graph API endpoint
        let url = URL(string: kGraphURI)
        var request = URLRequest(url: url!)
        
        // Set the Authorization header for the request. We use Bearer tokens, so we specify Bearer + the token we got from the result
        request.setValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        let urlSession = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        urlSession.dataTask(with: request) { data, response, error in
            let result = try? JSONSerialization.jsonObject(with: data!, options: [])
            if result != nil {
                
                self.loggingText.text = result.debugDescription
            }
            }.resume()
    }
    
    //MARK:- Call the Microsoft Set up sign-out
    
    @IBAction func signoutButton(_ sender: UIButton) {
        
        do {
            
            // Removes all tokens from the cache for this application for the provided user
            // first parameter:   The user to remove from the cache
            
            try self.applicationContext.remove(self.applicationContext.users().first)
            self.signoutButton.isEnabled = false;
            
        } catch let error {
            self.loggingText.text = "Received error signing user out: \(error)"
        }
    }
    
    
    // MARK: - One Drive Method 
    
    @IBAction func callGraphButton(_ sender: UIButton) {
        
        
        do {
            
            // We check to see if we have a current logged in user. If we don't, then we need to sign someone in.
            // We throw an interactionRequired so that we trigger the interactive signin.
            
            if  try self.applicationContext.users().isEmpty {
                throw NSError.init(domain: "MSALErrorDomain", code: MSALErrorCode.interactionRequired.rawValue, userInfo: nil)
            } else {
                
                // Acquire a token for an existing user silently
                
                try self.applicationContext.acquireTokenSilent(forScopes: self.kScopes, user: applicationContext.users().first) { (result, error) in
                    
                    if error == nil {
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Refreshing token silently)"
                        self.loggingText.text = "Refreshed Access token is \(self.accessToken)"
                        
                        self.signoutButton.isEnabled = true;
                        self.getContentWithToken()
                        
                    } else {
                        self.loggingText.text = "Could not acquire token silently: \(error ?? "No error information" as! Error)"
                        
                    }
                }
            }
        }  catch let error as NSError {
            
            // interactionRequired means we need to ask the user to sign-in. This usually happens
            // when the user's Refresh Token is expired or if the user has changed their password
            // among other possible reasons.
            
            if error.code == MSALErrorCode.interactionRequired.rawValue {
                
                self.applicationContext.acquireToken(forScopes: self.kScopes) { (result, error) in
                    if error == nil {
                        self.accessToken = (result?.accessToken)!
                        self.loggingText.text = "Access token is \(self.accessToken)"
                        self.signoutButton.isEnabled = true;
                        self.getContentWithToken()
                        
                    } else  {
                        self.loggingText.text = "Could not acquire token: \(error ?? "No error information" as! Error)"
                    }
                }
                
            }
            
        } catch {
            
            // This is the catch all error.
            
            self.loggingText.text = "Unable to acquire token. Got error: \(error)"
            
        }
    }
    

    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            //showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true
            self.output.isHidden = false
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listFiles()
        }
    }
    
    // List up to 10 files in Drive
    func listFiles() {
        let query = GTLQueryDrive.queryForFilesList() ///GTLRDriveQuery_FilesList.query()
        query?.pageSize  = 10
        service.executeQuery(query!,
                             delegate: self,
                             didFinish: #selector(displayResultWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    func displayResultWithTicket(ticket: GTLServiceTicket ,
                                 finishedWithObject result : GTLDriveFile, //GTLRDrive_FileList,
                                 error : NSError?) {
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var text = "";
        //if let files = result.files, !files.isEmpty {
          //  text += "Files:\n"
           // for file in files {
             //   text += "\(file.name!) (\(file.identifier!))\n"
           // }
       // } else {
        //    text += "No files found."
      //  }
        output.text = text
    }
    
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }



    
    // MARK: - customButton Methods
    
    @IBAction func btnAudioClicked(_ sender: AnyObject) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        signInButton.frame = CGRect(x:0,y:0,width:0,height:0)
        view.addSubview(signInButton)
        output.frame = view.bounds
        output.isEditable = false
        output.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        output.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        output.isHidden = true
        view.addSubview(output);
        
        
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.audio" as NSString as String], in: .import)
        
        importMenu.delegate = self
        
        self.present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction func btnCameraClicked(_ sender: UIButton) {
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.present(fusuma, animated: true, completion: nil)
    }
    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        if self.recorder != nil {
            self.recorder.stop()
            self.meterTimer.invalidate()
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(false)
                
            } catch let error as NSError {
                print("could not make session inactive")
                print(error.localizedDescription)
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //    @IBAction func btnPostClicked(_ sender: AnyObject) {
    //
    //
    //        if self.typeMedia == MediaType.isPhoto.rawValue {
    //
    //            if imgPhoto == nil
    //            {
    //                mainInstance.ShowAlertWithError("Error!", msg: "Please Create Post")
    //            }
    //            else
    //            {
    //                self.isImage = true
    //                UploadPost()
    //            }
    //        }
    //        else if self.typeMedia == MediaType.isVideo.rawValue
    //        {
    //            if urlVideo == nil
    //            {
    //                mainInstance.ShowAlertWithError("Error!", msg: "Please Create Post")
    //            }
    //            else
    //            {
    //                self.isImage = true
    //                UploadPost()
    //            }
    //        }
    //        else if self.typeMedia == MediaType.isAudio.rawValue
    //        {
    //
    //            if recorder==nil
    //            {
    //                mainInstance.ShowAlertWithError("Error!", msg: "Please Create Post")
    //            }
    //            else
    //            {
    //                btnAudio.setImage(UIImage(named: "mic_ic"), for: UIControlState())
    //
    //                recorder?.stop()
    //                player?.stop()
    //                lblTime.isHidden=true
    //                meterTimer.invalidate()
    //
    //                let session = AVAudioSession.sharedInstance()
    //                do {
    //                    try session.setActive(false)
    //                } catch let error as NSError {
    //                    print("could not make session inactive")
    //                    print(error.localizedDescription)
    //                }
    //                self.isImage = true
    //                UploadPost()
    //            }
    //        }
    //    }
    func setSiblings(_ view: UIView, enabled: Bool) {
        for sibling: UIView in view.superview!.subviews {
            if sibling != view {
                sibling.isUserInteractionEnabled = enabled
            }
        }
    }
    
    @IBAction func btnMiceClicked(_ sender: AnyObject) {
        
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission({
            granted in
            if granted
            {
                self.typeMedia=2;
                self.typeFile = 3
                
                if self.recorder == nil {
                    self.lblTime.isHidden=false
                    self.setSessionPlayback()
                    self.recordWithPermission(true)
                    self.btnAudio.setImage(UIImage(named: "mic_selec"), for: UIControlState())
                    self.setSiblings(self.btnAudio, enabled: false)
                } else {
                    
                    self.setSiblings(self.btnAudio, enabled: true)
                    self.btnAudio.setImage(UIImage(named: "mic_ic"), for: UIControlState())
                    self.recorder?.stop()
                    self.player?.stop()
                    self.lblTime.isHidden=true
                    self.meterTimer.invalidate()
                    let session = AVAudioSession.sharedInstance()
                    do {
                        try session.setActive(false)
                        
                    } catch let error as NSError {
                        print("could not make session inactive")
                        print(error.localizedDescription)
                    }
                    self.isImage = true
                    self.viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
                    UIView.transition(with: self.view, duration: 0.5, options: .transitionFlipFromTop, animations: {
                        self.intialSetupForPreview()
                        self.imgartwork.image = UIImage(named: "mic_ic")
                        self.viewCustomCameraPreview.isHidden = true
                        self.viewAudioPreview.isHidden = false
                        self.view.addSubview(self.viewPreview)
                        self.tblTagging.isHidden = true
                    }, completion: nil)
                    self.isRecord = true
                }
            }
            else
            {
                let alertHide = UIAlertController(title: "Microphone Access Denied", message:"You must allow microphone access in Settings", preferredStyle: .alert)
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                })
                let Setting = UIAlertAction(title: "Settings", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.shared.openURL(url)
                    }
                    
                })
                alertHide.addAction(Cancel)
                alertHide.addAction(Setting)
                self.present(alertHide, animated: true, completion: nil)
            }
        })
    }
    
    
    @IBAction func btnCancelClicked(_ sender: AnyObject) {
        
        viewThumbnail.removeFromSuperview()
        blurEffectView.removeFromSuperview()
    }
    @IBAction func btnpostClicked(_ sender: AnyObject) {
        
        if mainInstance.isTextfieldBlank(txtsongname) {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter song name")
        }
        else
        {
            
            typeMedia = 2;
            UploadPost()
        }
        
    }
    
    @IBAction func btnartworkClicked(_ sender: AnyObject) {
        //        typeMedia=2
        isartwork=true
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
            {
                self.picker!.sourceType = UIImagePickerControllerSourceType.camera
                self.picker?.delegate = self
                self.picker!.allowsEditing = true
                self.present(self.picker!, animated: true, completion: nil)
            }
            
        }
        let gallaryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary))
            {
                self.picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.picker?.delegate = self
                self.picker!.allowsEditing = true
                self.present(self.picker!, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            //            if self.typeMedia == 2 {
            //                self.typeMedia = nil
            //                self.isartwork = false
            //            }
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
    }
    
    func btnTimerClicked(_ sender: UIButton) {
        
        if isTimerVisible {
            self.showTimer()
        } else {
            self.hideTimer()
        }
    }
    
    @IBAction func btnMusicClicked(_ sender: AnyObject) {
        
        
        let importMenu = UIDocumentMenuViewController(documentTypes: ["public.audio" as NSString as String], in: .import)
        
        importMenu.delegate = self
        
        self.present(importMenu, animated: true, completion: nil)
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
    
    func showTimer() {
        isTimerVisible = false
        tblTimer.isScrollEnabled = true
        tblTimer.backgroundColor = UIColor(hexString: "27B9B8")
        constHeightTblTimer.constant = 270
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        tblTimer.reloadData()
        tblTimer.selectRow(at: timerSelectedIndexPath, animated: false, scrollPosition: .none)
    }
    
    func hideTimer() {
        isTimerVisible = true
        tblTimer.isScrollEnabled = false
        tblTimer.backgroundColor = .clear
        
        UIView.animate(withDuration: 0.4, animations: {
            self.constHeightTblTimer.constant = 50
            self.view.layoutIfNeeded()
        })
        tblTimer.reloadData()
    }
    
    func showAudio() {
        isAudioVisible = false
        constHeightTblAudio.constant = 300
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func hideAudio() {
        isAudioVisible = true
        
        constHeightTblAudio.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func cancelTimerTapped() {
        self.hideTimer()
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.hideTblTagging()
    }
    
    func textViewDidChange(_ textView: UITextView)
    {
        print("chnge")
        placeholderLabel.isHidden = !txtPost.text.isEmpty
        self.txtPost.textViewDidChange(textView)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //  let resultPredicate = NSPredicate(format: "name contains[c] %@", textView.text)
    }
    var recordingHashTag = false
    var startParse = 0
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
        let newLength = 250 - ((textView.text! as NSString).length + (text as NSString).length - range.length)
        if newLength >= 0 {
            if (text == "@") {
                recordingHashTag = true
                startParse = range.location
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
        } else {
            return false
        }
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
        parameterss.setValue(hash, forKey: "string")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(searchOffset, forKey: "offset")
        parameterss.setValue(searchLimit, forKey: "limit")
        if useridStringArray.characters.count > 0
        {
            print(useridStringArray)
            parameterss.setValue(useridStringArray, forKey: "userids")
        }
        
        SVProgressHUD.show(withStatus: "Fetching Users", maskType: SVProgressHUDMaskType.clear)
        mgr.SearchFriendTagging(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                
                self.filterArray.removeAll()
                for searchObject in (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray {
                    let json = SearchResult.Populate(searchObject as! NSDictionary)
                    self.filterArray.append(json)
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
                print(dic)
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
    
    // MARK: UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblTagging {
            return filterArray.count
        }
        if tableView == tblTimer {
            
            return timerArray.count
        } else {
            return audioArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if tableView == tblTagging {
            return UIView()
        }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
        let btnTime = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerView.frame.height))
        btnTime.addTarget(self, action: #selector(self.btnTimerClicked), for: .touchUpInside)
        //        headerView.backgroundColor = UIColor.init(red: 46.0/255.0, green: 185.0/255.0, blue: 184.0/255.0, alpha: 1.0)
        //        headerView.backgroundColor = .clear
        btnTime.titleLabel?.font = UIFont(name: fontsName.KfontproxiBold, size: 28)
        
        btnTime.setImage(UIImage(named: "ico_mediapost_timer"), for: UIControlState())
        
        if tableView == tblTimer {
            btnTime.setTitle("Control", for: UIControlState())
        } else {
            btnTime.setTitle("Music", for: UIControlState())
        }
        btnTime.setTitleColor(.white, for: .normal)
        btnTime.titleEdgeInsets.left = 20
        
        if isTimerVisible {
            btnTime.titleEdgeInsets.top = -10
            btnTime.imageEdgeInsets.top = -10
        } else {
            btnTime.titleEdgeInsets.top = 0
            btnTime.imageEdgeInsets.top = 0
        }
        
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
        //        footerView.backgroundColor = .clear
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        }
        if tableView == tblTimer
        {
            let cellIdentifier = "tblTimerCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! tblTimerCell
            cell.contentView.backgroundColor = UIColor.init(red: 10/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0)
            cell.lblTime.text = timerArray[indexPath.row]["title"] as? String
            return cell
        }
        else
        {
            let cellIdentifier = "tblAudioCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! tblAudioCell
            cell.lblName.text = audioArray[indexPath.row]
            cell.imgView.image = audioImgArray[indexPath.row]
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
            self.txtPost.nameTagColor = UIColor.clear
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
    
    // MARK: - ImagePicker delegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if typeMedia==2 {
            typeMedia = nil
            isartwork=false
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        imgartwork.image = (info[UIImagePickerControllerEditedImage] as? UIImage)?.resizeArtWorkImage()
        imgartWorkup = imgartwork.image
    }
    
    // MARK: - Audio Player
    
    func setupRecorder() {
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        print(currentFileName)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.soundFileURL = documentsDirectory.appendingPathComponent(currentFileName)
        
        if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("soundfile \(soundFileURL.absoluteString) exists")
        }
        
        let recordSettings:[String : Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVEncoderAudioQualityKey : AVAudioQuality.low.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0,
            AVLinearPCMIsFloatKey : false,
            AVLinearPCMIsBigEndianKey : false
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.record(atTime: 0.0, forDuration: 600.0)
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
        } catch let error as NSError {
            recorder = nil
            print(error.localizedDescription)
        }
    }
    
    func recordWithPermission(_ setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 0.1,
                                                           target:self,
                                                           selector:#selector(CreatePost_Media.updateAudioMeter(_:)),
                                                           userInfo:nil,
                                                           repeats:true)
                    self.meterTimer.fire()
                    self.lblTime.isHidden = false
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func setSessionPlayAndRecord() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
    }
    
    func deleteAllRecordings() {
        let docsDir =
            NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return name.hasSuffix("m4a")
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
        
    }
    
    func updateAudioMeter(_ timer:Timer) {
        
        if recorder.isRecording {
            let min = Int(recorder.currentTime / 60)
            let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
            let s = String(format: "%02d:%02d", min, sec)
            print("\(s)")
            lblTime.text = s
            recorder.updateMeters()
        }
    }
    
    // MARK: - clear date
    
    func clearData() {
        self.recorder = nil
        self.imgPhoto = nil
        self.urlVideo = nil
        btnphoto.setImage(UIImage(named: "cam_new_icon"), for: UIControlState())
        btnmusic.setImage(UIImage(named: "music_new_icon"), for: .normal)
        btnAudio.setImage(UIImage(named: "mic_ic"), for: UIControlState())
    }
    
    // MARK: - upload Image
    
    func UploadPost()
    {
        if mainInstance.connected()
        {
            let usr = UserManager.userManager
            SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
            let mgr = APIManager.apiManager
            
            var Strfulltitle = "\(strsongname) --- \(strartistname)"
            
            if (Strfulltitle == " --- " || Strfulltitle == "")
            {
                Strfulltitle = txtsongname.text!
            }
            
            let parameterss = NSMutableDictionary()
            parameterss.setValue(typeFile, forKey: "posttype")
            parameterss.setValue(usr.userId, forKey: "postedby")
            
            let txtPostAttribString = self.txtPost.taggedString()
            self.txtPost.makeStringWithoutTagString()
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
            if selectedDate != nil && selectedDate != 0 {
                parameterss.setValue("\(selectedDate!)", forKey: "posttiming")
            }
            
            print("parameter : %@",parameterss)
            
            mgr.manager.responseSerializer.acceptableContentTypes=NSSet(array: ["text/html"]) as? Set<String>
            mgr.manager.requestSerializer.timeoutInterval = TimeInterval(300)
            if let sessionStr:String = mgr.sessionToken {
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
                                if(self.isImage == true){
                                        
                                    if self.typeMedia == MediaType.isPhoto.rawValue {
                                        formData.appendPart(withFileData: UIImagePNGRepresentation(self.imgPhoto)!, name: "media[1]", fileName: "Postcreation.png", mimeType: "image/png")
                                    } else if self.typeMedia == MediaType.isVideo.rawValue {
                                        var dataVideo = try? Data(contentsOf: self.urlVideo!)
                                        
                                        if (dataVideo == nil) {
                                            dataVideo = self.dataVideofnl
                                        }
                                        
                                        formData.appendPart(withFileData: dataVideo!, name: "media[1]", fileName: "testvideo.mp4", mimeType: "video/mp4")
                                    } else if self.typeMedia == MediaType.ismp3.rawValue {
                                        do {
                                            
                                            try   formData.appendPart(withFileURL: self.soundFileURL, name: "media[1]", fileName: "audio.mp3", mimeType: "audio/mp3")
                                            
                                            if ((self.imgartWorkup) != nil)
                                            {
                                                formData.appendPart(withFileData: UIImageJPEGRepresentation(self.imgartWorkup!, 1.0)!, name: "audioimage", fileName: "artwork.png", mimeType: "image/png")
                                            }
                                        } catch {
                                        }
                                    } else if self.typeMedia == MediaType.isAudio.rawValue||self.typeMedia == MediaType.ism4A.rawValue {
                                        do {
                                            
                                            try   formData.appendPart(withFileURL: self.soundFileURL, name: "media[1]", fileName: "audio.m4a", mimeType: "audio/m4a")
                                            
                                            if ((self.imgartWorkup) != nil) {
                                                formData.appendPart(withFileData: UIImageJPEGRepresentation(self.imgartWorkup!, 1.0)!, name: "audioimage", fileName: "artwork.png", mimeType: "image/png")
                                            }
                                        } catch {
                                        }
                                    } else {
                                        do {
                                            try   formData.appendPart(withFileURL: self.soundFileURL, name: "media[1]", fileName: "audio.mp3", mimeType: "audio/mp3")
                                        }
                                            
                                        catch {
                                        }
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
                    
                    self.clearData()
                    if self.delegate != nil {
                        self.delegate.postmediaData()
                    }
                   // self.delegate.postmediaData()
//                    self.navigationController?.popViewController(animated: true)
//                    mainInstance.ShowAlertWithSucess("ScreamXO", msg: info.value(forKey: "msg")! as! NSString)
                    
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
    
    // MARK: - picker  Methods
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        // Do something
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.txtPost.text = ""
            self.placeholderLabel.isHidden = !self.txtPost.text.isEmpty
            self.viewCustomCameraPreview.isHidden = true
            self.viewAudioPreview.isHidden = false
            self.imgartwork.image = UIImage(named: "audsc")
            
            self.view.addSubview(self.viewPreview)
            
            self.tblTagging.isHidden = true
        }, completion: nil)
        print(url)
        typeFile = 4
        let  assest = AVURLAsset.init(url: url)
        NSLog("%@", assest)
        for format: String in assest.availableMetadataFormats {
            for item: AVMetadataItem in assest.metadata(forFormat: format) {
                if (item.commonKey == "title") {
                    if let strtitle = item.value as? String
                    {
                        strsongname = strtitle
                        txtsongname.text = strsongname
                    }
                }
                if (item.commonKey == "artwork")
                {
                    let data: Data = (item.value  as? Data)!
                    imgartWorkup = UIImage(data: data)
                    imgartwork.image = imgartWorkup
                }
                
                if (item.commonKey == "artist") {
                    if let strartist = item.value as? String
                    {
                        strartistname = strartist
                    }
                }
            }
        }
        if assest.availableMetadataFormats.count == 0 {
            self.intialSetupForPreview()
        }
        
        let strPath: NSString  = url.absoluteString as NSString
        
        if (strPath.pathExtension == "mp3")
        {
            self.typeMedia = MediaType.ismp3.rawValue
            self.isImage = true
            self.imgartwork.image = UIImage(named: "audsc")
            
        }
        else if (strPath.pathExtension == "m4a")
        {
            self.typeMedia = MediaType.ism4A.rawValue
            self.isImage = true
            self.imgartwork.image = UIImage(named: "audsc")
            
        }
        self.soundFileURL = url
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController)
    {
        documentPicker.delegate = self
        self.present(documentPicker, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CameraSegue" {
            
        }
    }
    

}
extension CreatePost_Media: FusumaDelegate {
    func fusumaClosed() {
        
        print("Called when the close button is pressed")
    }
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    func fusumaImageSelected(_ image: UIImage) {
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.intialSetupForPreview()
            self.viewAudioPreview.isHidden = true
            self.viewCustomCameraPreview.isHidden = false
            self.view.addSubview(self.viewPreview)
            self.tblTagging.isHidden = true
        }, completion: nil)
        btnPlay.isHidden = true
        videoUrl = nil
        print("Image selected")
        imgPreview.image = image
        self.typeMedia = 0
        
    }
    func intialSetupForPreview() {
        self.txtsongname.text = ""
        self.txtPost.text = ""
        self.imgartwork.image = UIImage(named: "mic_ic")
        self.placeholderLabel.isHidden = !self.txtPost.text.isEmpty
    }
    func fusumaVideoCompletedwithData(withFileURL dataass: Data, fileURLL: URL) {
        
        
        
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.intialSetupForPreview()
            self.viewAudioPreview.isHidden = true
            self.viewCustomCameraPreview.isHidden = false
            self.view.addSubview(self.viewPreview)
            self.tblTagging.isHidden = true
        }, completion: nil)
        btnPlay.isHidden = false
        thumbnail(fileURLL)
        videoUrl = fileURLL
        dataVideofnl = dataass
        self.typeMedia = 1
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.intialSetupForPreview()
            self.viewAudioPreview.isHidden = true
            self.viewCustomCameraPreview.isHidden = false
            self.view.addSubview(self.viewPreview)
            self.tblTagging.isHidden = true
        }, completion: nil)
        btnPlay.isHidden = false
        thumbnail(fileURL)
        videoUrl = fileURL
        self.typeMedia = 1
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("Called just after dismissed FusumaViewController")
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
    
    
    @IBAction func btnDonePressed(_ sender: AnyObject) {
        self.viewPreview.endEditing(true)
        isRecord = false
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromTop, animations: {
            self.viewPreview.removeFromSuperview()
        }, completion: {
            result in
            
            if self.typeMedia == MediaType.isPhoto.rawValue
            {
                self.imgPhoto=self.imgPreview.image?.fixOrientation()
                self.typeFile = 2
                
                self.btnphoto.setImage(UIImage(named: "cam_new_icon"), for: UIControlState())
            }
            else if self.typeMedia == MediaType.isVideo.rawValue
            {
                self.typeFile = 1
                self.btnphoto.setImage(UIImage(named: "cam_new_icon"), for: UIControlState())
                
                self.urlVideo=self.videoUrl
            }
            self.isImage = true
            
            self.UploadPost()
        })
        
    }
    @IBAction func btnClosePressed(_ sender: AnyObject) {
        UIView.transition(with: view, duration: 0.5, options: .transitionFlipFromBottom, animations: {
            self.viewPreview.removeFromSuperview()
            self.recorder = nil
        }, completion: nil)
        if isRecord == false {
            
            let fusuma = FusumaViewController()
            fusuma.delegate = self
            self.present(fusuma, animated: true, completion: nil)
        } else {
            isRecord = false
        }
        
        
    }
}
extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform = CGAffineTransform.identity
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(M_PI));
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
            
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1);
            
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx = CGContext(
            data: nil,
            width: Int(self.size.width),
            height: Int(self.size.height),
            bitsPerComponent: self.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: self.cgImage!.colorSpace!,
            bitmapInfo: UInt32(self.cgImage!.bitmapInfo.rawValue)
        )
        
        ctx!.concatenate(transform);
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height,height: self.size.width));
            
        default:
            ctx!.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width,height: self.size.height));
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage()
        
        let img = UIImage(cgImage: cgimg!)
        
        return img;
    }
}
extension CreatePost_Media: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtsongname {
            let newLength = 25 - ((textField.text! as NSString).length + (string as NSString).length - range.length)
            if newLength >= 0 {
                return true
            } else {
                return false
            }
        }
        return true
    }
}
