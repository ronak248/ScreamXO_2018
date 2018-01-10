
//
//  PostDetailsVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 04/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
//import MobilePlayer

@objc protocol commentActionDelegate  {
    func actionOnData()
    @objc optional func actionOnpostData()
    @objc optional func btnLikeClickedmedia(_ sender:UIButton)
}

protocol PostMediaViaPostDetailDelegate {
    func actionOnPostMediaViaPostDetail()
}

class commentCell : UITableViewCell {
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: KILabel!
    @IBOutlet weak var lblTime: UILabel!
}
class HeaderCell : UITableViewCell {
    
}

class PostDetailsVC: UIViewController,MessageComposerViewDelegate,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate, UICollectionViewDelegate, UICollectionViewDataSource,UITextViewDelegate {
    
    // MARK: Properties
    
    enum postTypeenum : Int {
        case stream = 0,image,video,audio
    }
    var spinner : UIActivityIndicatorView?
    var isAction:Bool = false
     var isPlayVideo :Bool = false
    var delegate : commentActionDelegate!
    var msgComposerView : MessageComposerView?
    var Posttype : Int?
    var isViewComment : Int?
    var arrayComments = NSMutableArray ()
    var playerFInal:MobilePlayerViewController!
    var totalcomment:Int = 0
    var offset:Int = 1
    var limit:Int = 10
    var isRefresh:Bool=true
    var orientationValue = false
    var postDetails = NSDictionary()
    
    var isBusyFetching : Bool = false
    var isreloadtbl : Bool = false
    var typedString: String = String()
    var typedFlag = false
    var filterString:String = ""
    var searchStr = ""
    var searchOffset = 1
    var searchLimit = 10
    var searchTotalUser = 0
    var posttagids = [String]()
    var filterArray = [SearchResult]()
    
    var lastCount:Int = 0
    var scollToBottom : Bool = true
    var likeaction = Int()
    var framefinal : CGRect?
    var isPlayingLandscape = false
    var emojiBtn = UIButton()
    var imgProfile = UIImageView()
    var urlimg: String = ""
    var ShareURL: String!
    var delegatePostMedia: PostMediaViaPostDetailDelegate?

    // MARK: IBOutlets
    
    @IBOutlet var lblMediaPostTitle: KILabel!
    @IBOutlet var viewHeader: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var imgMedia: UIImageView!
    @IBOutlet weak var btnTotalcomment: UIButton!
    @IBOutlet weak var btntotalLikes: UIButton!
    @IBOutlet weak var lbllocation: UILabel!
    @IBOutlet var btnUserNameBoost: UIButton!
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblDescription: MLLinkLabel!
    @IBOutlet var emojiViewCollection: emojiSetView!
    @IBOutlet var tblTagging: UITableView!
    @IBOutlet var bottomTagging: NSLayoutConstraint!
    
    @IBOutlet weak var tblTimer: UITableView!
    @IBOutlet var constHeightTblTimer: NSLayoutConstraint!
    var timerSelectedIndexPath: IndexPath?
    var isTimerVisible = true
    var selectedDate:Int?
    var timerArray = [["title": "30 min", "value": 30], ["title": "1 Hour", "value": 60],["title": "4 Hours", "value": 240],["title": "12 Hours", "value": 720], ["title": "24 Hours", "value": 1440]]
    
    var item_id: Int!
    var  boost_type: Int!
    var newResults: [NSIndexPath]!
    @IBOutlet weak var userCircleImg: UIImageView!
    
    // MARK: View life cycle methods

    
    override func viewDidLoad() {
        let notificationName = Notification.Name("myhomescreen")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        let  tap = UITapGestureRecognizer(target: self, action: #selector(self.tableTapped))
        tblTimer.addGestureRecognizer(tap)
        let  tapTag = UITapGestureRecognizer(target: self, action: #selector(self.tableTappedOnTagging))
        tblTagging.addGestureRecognizer(tapTag)
        super.viewDidLoad()
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedData), name: NSNotification.Name(rawValue: "DataUpdated"), object: nil)

        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        emojiViewCollection.emojiCollectionView.delegate = self
        emojiViewCollection.emojiCollectionView.dataSource = self
        msgComposerView?.messageTextView.delegate = self
        
        msgComposerView?.messageTextView.returnKeyType = UIReturnKeyType.send
        self.setupMessageComoser()
        
        getPostDetails()
        constHeightTblTimer.constant = 0
        tblView.isHidden = true
        self.tblView.tableHeaderView = UIView()
        tblView.estimatedSectionHeaderHeight = 250.0
        tblView.sectionHeaderHeight = UITableViewAutomaticDimension
        tblView.estimatedRowHeight = 120.0
        tblView.rowHeight = UITableViewAutomaticDimension
        
        tblTagging.isHidden = true
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner?.color = colors.KOrangeTextColor
        spinner?.startAnimating()
       
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailsVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailsVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PostDetailsVC.openImage(_:)))
        imgMedia.addGestureRecognizer(tapGesture)
        tapGesture.numberOfTapsRequired = 1
        
        let hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(PostDetailsVC.dismissKeyboard))
        self.view.addGestureRecognizer(hideKeyboardGesture)
        tapGesture.numberOfTapsRequired = 1
        
        let doubletapGesturedoubleTap = UITapGestureRecognizer(target: self, action: #selector(PostDetailsVC.btnLikeClicked(_:)))
        doubletapGesturedoubleTap.numberOfTapsRequired=2
        imgMedia.addGestureRecognizer(doubletapGesturedoubleTap)
        tapGesture.require(toFail: doubletapGesturedoubleTap)
        
        let tapGesturea = UITapGestureRecognizer(target: self, action: #selector(PostDetailsVC.openImage(_:)))
        imgUserProfile.addGestureRecognizer(tapGesturea)
        //msgComposerView?.messageTextView.text = "Add Comment"
        lblMediaPostTitle.font = UIFont(name: "ProximaNova-Regular", size: 12.0)
    }
    
    override func viewDidLayoutSubviews() {
        if playerFInal != nil && isPlayingLandscape == false {
            playerFInal.view.frameHeight = imgMedia.frameHeight
        }
    }
    
    
    func handleUpdatedData(notification: NSNotification) {
//        if tblTimer.isHidden {
//            msgComposerView?.messageTextView.resignFirstResponder()
//            tblTimer.isHidden = false
//        } else {
//            tblTimer.isHidden = true
//        }
        
        self.msgComposerView?.messageTextView.endEditing(true)
        if isTimerVisible {
            self.showTimer()
        } else {
            self.hideTimer()
            //self.msgComposerView?.messageTextView.becomeFirstResponder()
            
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        userCircleImg.layer.cornerRadius = userCircleImg.frame.width / 2
        userCircleImg.layer.masksToBounds = true
        msgComposerView?.messageTextView.enablesReturnKeyAutomatically = true
        tblView.reloadData()
        if self.isViewComment == 0 {
            msgComposerView!.messageTextView.becomeFirstResponder()
            emojiBtn.setImage(UIImage(named: "like"), for: .normal)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailsVC.btnLikeClicked(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(PostDetailsVC.playVideoinlandscapeMode), name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailsVC.stopVideo), name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PostDetailsVC.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)
        
        // Hide status bar
        
        UIApplication.shared.isStatusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        // Position round menu
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
        
          self.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // Hide status bar
        
        UIApplication.shared.isStatusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if isAction == true && self.Posttype==postTypeenum.stream.rawValue {
            isAction = false
            if self.delegate != nil {
            
                self.delegate.actionOnData();
            }
        } else if isAction == true && self.Posttype==postTypeenum.video.rawValue {
            isAction = false
            if self.delegate != nil {
                
                self.delegate.actionOnData();
            }
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Show status bar
        
        UIApplication.shared.isStatusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        
        // Reposition round menu
        
        objAppDelegate.repositiongsm()
        
        tblView.setContentOffset(CGPoint.zero, animated: true)

    }
    
    
    func deviceDidRotate(notification: NSNotification) {
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        print(orientation)
        if orientation.isLandscape {
            if isPlayVideo == true {
                msgComposerView?.isHidden = true
                print(orientation.rawValue)
                //playVideoinlandscape()
            }
        } else if orientation.isPortrait {
            if isPlayVideo == true {
            msgComposerView?.isHidden = false
            //playVideoinlandscape()
            }
        }
    }

    
    
    func showTblTagging() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tblTagging.isHidden = false
            
        })
    }
    
    func hideTblTagging() {
        msgComposerView?.messageTextView.becomeFirstResponder()
        UIView.animate(withDuration: 0.3, animations: {
            self.tblTagging.isHidden = true
        })
    }
    
    

    func cancelTimerTapped() {
        msgComposerView?.isHidden = false
        msgComposerView?.messageTextView.becomeFirstResponder()
    }
    
    
    func showTimer() {
        msgComposerView?.isHidden = true
        isTimerVisible = false
        constHeightTblTimer.constant = 270
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        
        tblTimer.reloadData()
        tblTimer.selectRow(at: timerSelectedIndexPath, animated: false, scrollPosition: .none)
    }
    
    func hideTimer() {
        isTimerVisible = true
        msgComposerView?.isHidden = true
        constHeightTblTimer.constant = 270
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        
        tblTimer.reloadData()
        tblTimer.selectRow(at: timerSelectedIndexPath, animated: false, scrollPosition: .none)
    }

    
    
    
    // MARK: TextView delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.hideTblTagging()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("chnge")
        msgComposerView?.messageTextView.textViewDidChange(textView)
    }
    
    var recordingHashTag = false
    var startParse = 0
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print(text)
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
                    finalStr?
                        .remove(at: (finalStr?.index((finalStr?.endIndex)!, offsetBy: -1))!)
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
        return (msgComposerView?.messageTextView.shouldChangeText(in: range, replacementText: text))!
    }
    func filterHashTagTableWithHash(_ hash: String) {
        searchOffset = 1
        searchLimit = 10
        SearchFriend(hash)
    }
    func SearchFriend(_ hash: String) {
        var useridStringArray: String = ""
        
        if let annotationList = msgComposerView?.messageTextView.annotationList
        {
            for annotation in (msgComposerView?.messageTextView.annotationList)!
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
    
    // MARK: Swipe from bottom
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                
            case UISwipeGestureRecognizerDirection.up:
                self.navigationController?.popViewController(animated: true)
            default:
                break
            }
        }
    }
    
    // MARK: - setup message composer view -
    
    func setupMessageComoser() {
        
        if ((msgComposerView?.isDescendant(of: self.view)) != nil) {
            return
        }
        
        msgComposerView = MessageComposerView(keyboardOffset: 0, andMaxHeight: 100)
        msgComposerView!.delegate = self
//        msgComposerView?.frame = CGRect(x: 0, y: Int(UIScreen.main.bounds.height-50), width: Int(UIScreen.main.bounds.size.width), height: 40)
        self.view.addSubview(msgComposerView!)
        msgComposerView!.messagePlaceholder = "Add Comment"
        msgComposerView?.messageTextView.font = UIFont(name: fontsName.KfontproxisemiBold, size: 13.0)
        msgComposerView?.messageTextView.textColor = .black
        imgProfile = UIImageView(frame: CGRect(x: 0, y: -5, width: 40, height: 40))
        emojiBtn = UIButton(frame: CGRect(x: 9, y: 7, width: 40, height: 40))
        emojiBtn.addTarget(self, action: #selector(self.emojiBtnClicked), for: .touchUpInside)
        
        let usr = UserManager.userManager
        
        if usr.profileImage != nil {
            imgProfile.sd_setImageWithPreviousCachedImage(with: URL(string: usr.profileImage!), placeholderImage: UIImage(named: "like"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
            })
        }
        
        imgProfile.contentMode=UIViewContentMode.scaleAspectFill
        imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2
        imgProfile.layer.masksToBounds = true
        
        emojiBtn.contentMode=UIViewContentMode.scaleAspectFill
        emojiBtn.layer.cornerRadius = emojiBtn.frame.size.height / 2
        emojiBtn.layer.masksToBounds = true
        
        emojiBtn.setImage(UIImage(named: "like"), for: UIControlState())
        
        msgComposerView?.addSubview(imgProfile)
        msgComposerView?.addSubview(emojiBtn)
        msgComposerView?.bringSubview(toFront: emojiBtn)
        msgComposerView?.configure(withAccessory: imgProfile)
        msgComposerView?.configure(withAccessory: emojiBtn)
        msgComposerView?.messageTextView.returnKeyType = UIReturnKeyType.send
    }
    
  
    func emojiBtnClicked(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            msgComposerView?.messageTextView.resignFirstResponder()
            msgComposerView?.messageTextView.inputView = self.emojiViewCollection.emojiCollectionView
            msgComposerView?.messageTextView.becomeFirstResponder()
            sender.setImage(UIImage(named: "ico-keyboard"), for: UIControlState())
            msgComposerView?.messageTextView.reloadInputViews()
        } else if sender.tag == 1{
            sender.tag = 0
            msgComposerView?.messageTextView.resignFirstResponder()
            msgComposerView?.messageTextView.inputView = nil
            msgComposerView?.messageTextView.becomeFirstResponder()
            sender.setImage(UIImage(named: "like"), for: UIControlState())
            msgComposerView?.messageTextView.reloadInputViews()
        }
    }
    
    @IBAction func btnTotalLikedClicked(_ sender: AnyObject) {
        
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    @IBAction func btnLikeClicked(_ sender: AnyObject) {
        
        isAction = true
        let mgrpost = PostManager.postManager
        if (mgrpost.isPostLike! == 0)
        {
            likeaction = 0
            mgrpost.isPostLike=1
            mgrpost.PostLikes = mgrpost.PostLikes + 1
            btntotalLikes.setTitle("\(mgrpost.PostLikes)", for: UIControlState())
            btnLike.setImage(UIImage(named: "like"), for: UIControlState())
            postlikeMethod()
        }
        else
        {
            likeaction = 1
            mgrpost.isPostLike = 0
            mgrpost.PostLikes = mgrpost.PostLikes - 1
            btntotalLikes.setTitle("\(mgrpost.PostLikes)", for: UIControlState())
            btnLike.setImage(UIImage(named: "unlike"), for: UIControlState())
            postlikeMethod()
        }
        
        if (sender.isKind(of: UIButton.self))
        {
            if((delegate) != nil)
            {
                
                self.delegate.btnLikeClickedmedia?(sender as! UIButton)
            }
        }
        tblView.reloadData()
        
        
        
    }
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
    }
    
    func btnDashboardClicked() {
        if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
            
            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                sideMenuLeftVC.sideMenuViewController.hideViewController()
                objAppDelegate.setViewAfterLogin()
            }
            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                sideMenuLeftVC.selectedrow = 0
            }
        }
    }
    
    func btnMoreClicked() {
        let mgrpost = PostManager.postManager
        
        let alert:UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let Delete = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            mgrpost.PostTypecheck="1"
            mgrpost.deletepost({ (dic, result) -> Void in
                if result == APIResultpost.apiSuccess {
                    if self.delegate != nil {
                        self.delegate.actionOnpostData!()
                    }
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        
        let cameraAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            var textToShare = ""
            
            var url = mgrpost.PostImg
            
            if ((url) == nil) {
                
                url = ""
                
                textToShare = mgrpost.PostText
            }
            
            if let myWebsite = URL(string: url!) {
                let objectsToShare = [textToShare, myWebsite] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
//                let button = sender as! UIButton
                if (IS_IPAD) {
                    
                    activityVC.popoverPresentationController!.sourceRect = self.view.bounds
                    activityVC.popoverPresentationController!.sourceView = self.view
          
                }
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        
        let gallaryAction = UIAlertAction(title: "Report Post", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            mgrpost.reportPost()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        // Add the actions
        if mgrpost.PostismyPost == "1" {
            
            alert.addAction(Delete)
        } else {
            alert.addAction(gallaryAction)
        }
        alert.addAction(cameraAction)
        alert.addAction(cancelAction)
        // Present the actionsheet
        
//        let button = sender as! UIButton
        if (IS_IPAD) {
            
            alert.popoverPresentationController!.sourceRect = self.view.bounds
            alert.popoverPresentationController!.sourceView = self.view
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    func btnBoostClicked(_ sender: UIButton) {
        let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
        boostViewController.item_id =  item_id
        boostViewController.boost_type =  boost_type
        if isPlayVideo {
            playerFInal.stop()
        }
        self.navigationController?.pushViewController(boostViewController, animated: true)
    }
    
    func btnUserProfileClicked(_ sender: UIButton) {
        
        let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
        objfriends.ispushtype=1;
        objfriends.shareFlag = true
        objfriends.shareUrl = ShareURL
        self.navigationController!.pushViewController(objfriends, animated: true)
        
//        let shareItems:Array = []
//        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
//        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo]
//        self.present(activityViewController, animated: true, completion: nil)
        
        
//        let user = UserManager.userManager
//        let mgrfriend = FriendsManager.friendsManager
//        mgrfriend.FriendName = "\((self.postDetails.value(forKey: "result") as AnyObject).value(forKey: "fname") as! String)"  +  " \((self.postDetails.value(forKey: "result") as AnyObject).value(forKey: "lname") as! String)"
//        mgrfriend.FriendPhoto = "\((self.postDetails.value(forKey: "result") as AnyObject).value(forKey: "userphoto") as! String)"
//        mgrfriend.FUsername = "\((self.postDetails.value(forKey: "result") as AnyObject).value(forKey: "username") as! String)"
//        mgrfriend.FriendID = "\((self.postDetails.value(forKey: "result") as AnyObject).value(forKey: "posted_by") as! String as String)"
//        if (mgrfriend.FriendID == user.userId)
//        {
//            if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
//                leftVC.selectedrow = leftVC.profileRow
//                leftVC.tblView.reloadData()
//            }
//            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
//            self.navigationController?.pushViewController(VC1, animated: true)
//        } else {
//            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
//            self.navigationController?.pushViewController(VC1, animated: true)
//        }
    }
    
    
    // MARK: UITableView delegate Methods
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == tblTimer {
            
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
        } else {
            return nil
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblTimer {
           return 34
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        if tableView == tblTimer {
         return 34
        }
        return UITableViewAutomaticDimension
       
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if tableView == tblTagging {
            return filterArray.count
        }
        if tableView == tblTimer {
            return  timerArray.count
        }
        if (isreloadtbl==false)
        {
            return 0
        }
        
        if self.Posttype==postTypeenum.stream.rawValue
        {
            if (section==0)
            {
                return 1
                
            }
            return arrayComments.count
            
        }
        return arrayComments.count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if tableView == tblTimer {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = UIColor.init(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            let lblHeader = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height + 100))
            lblHeader.font = UIFont(name: fontsName.KfontproxisemiBold, size: 22)
            lblHeader.text = "Time"
            
            lblHeader.textAlignment = NSTextAlignment.center
            headerView.addSubview(lblHeader)
            return headerView
        }
        if tableView != tblTagging {
            
        
        if self.Posttype==postTypeenum.stream.rawValue {
            return UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 0));
        }
        
        lblMediaPostTitle.userHandleLinkTapHandler = { label, handle, range in
            let postmngr = PostManager.postManager
            let strWithId = postmngr.PostTextOld
            let mystr = strWithId
            let searchstr = "@:@:"
            let ranges: [NSRange]
            
            do {
                // Create the regular expression.
                let regex = try NSRegularExpression(pattern: searchstr, options: [])
                
                // Use the regular expression to get an array of NSTextCheckingResult.
                // Use map to extract the range from each result.
                ranges = regex.matches(in: mystr!, options: [], range: NSMakeRange(0, mystr!.characters.count)).map {$0.range}
            }
            catch {
                // There was a problem creating the regular expression
                ranges = []
            }
            
            print(ranges)
            if postmngr.PostTagIds == nil {
                return
            }
            if postmngr.PostTagIds.count <= 0 {
                return
            }
            if ranges.count > 0 {
                if (label.text! as NSString).range(of: handle).location >= 0 {
                    if let ids = postmngr.PostTagIds!.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                        let arrStr = ids.components(separatedBy: ",")
                        if arrStr.count > 0 {
                            let otherId = arrStr[arrStr.count-1]
                            let struser:String=postmngr.PostOwnerfname
                            let strimg:String=postmngr.PostOwnerimg!
                            let user = UserManager.userManager
                            
                            let mgrfriend = FriendsManager.friendsManager
                            mgrfriend.FriendName = struser + struser
                            mgrfriend.FriendPhoto = strimg
                            mgrfriend.FUsername = struser
                            mgrfriend.FriendID = otherId
                            
                            if (mgrfriend.FriendID == user.userId) {
                                if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                                    leftVC.selectedrow = leftVC.profileRow
                                    leftVC.tblView.reloadData()
                                }
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                                self.navigationController?.pushViewController(VC1, animated: true)
                            } else {
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                                self.navigationController?.pushViewController(VC1, animated: true)
                            }
                        }
                    }
                }
            }
        }
        return viewHeader
        } else {
            return nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == tblTimer {
            return 50.0
        } else {
            return 0.01
        }
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTimer {
            return 50.0
        }
        if tableView == tblTagging {
            return 0.1
        }
        if self.Posttype==postTypeenum.stream.rawValue
        {
            return 0.00;
        }
        return UITableViewAutomaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        print(indexPath.section);
        print(indexPath.row);
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
        
        if tableView == tblTimer {
                let cellIdentifier = "tblTimerCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! tblTimerCell
                cell.contentView.backgroundColor = UIColor.init(red: 10/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0)
                cell.lblTime.text = timerArray[indexPath.row]["title"] as? String
                return cell
        }
        if self.Posttype == postTypeenum.stream.rawValue && indexPath.row == 0 && indexPath.section == 0 {
            let CELL_ID = "streamCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! streamCell
            cell.selectionStyle = .none
            cell.backView.layer.masksToBounds = true
            cell.backView.layer.cornerRadius = 12.0
            cell.backgroundColor = UIColor.clear
            cell.btnlikecount.addTarget(self, action: #selector(PostDetailsVC.btnTotalLikedClicked(_:)), for: .touchUpInside)
            cell.btnLike.addTarget(self, action: #selector(PostDetailsVC.btnLikeClicked(_:)), for: .touchUpInside)
            cell.btnMore.addTarget(self, action: #selector(PostDetailsVC.btnMoreClicked), for: .touchUpInside)
            cell.btnMore.tag=indexPath.row
            
            cell.btnLike.tag=indexPath.row
            cell.btnLike.restorationIdentifier=String(indexPath.section)
            
            cell.btnComment.tag = indexPath.row
            cell.btnlikecount.tag=indexPath.row
            cell.btntalcomments.tag=indexPath.row
            let mgrItm = PostManager.postManager
            
            let strisLike:Int?=mgrItm.isPostLike
            var strDescription:String?=mgrItm.PostText
            let strusername:String?=mgrItm.PostOwner
            let strimgname:String?=mgrItm.PostOwnerimg
            let strlikeCount:Int=mgrItm.PostLikes
            let strcommentCOunt:Int=mgrItm.PostComments
            var strtime:String?=mgrItm.PostTime
            strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
            if (strisLike == 0) {
                cell.btnLike.setImage(UIImage(named: "unlike"), for: UIControlState())
            } else {
                cell.btnLike.setImage(UIImage(named: "like"), for: UIControlState())
            }
            
            cell.imguser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
            
            cell.imguser.contentMode=UIViewContentMode.scaleAspectFill
            cell.imguser.layer.cornerRadius = cell.imguser.frame.size.height / 2
            cell.imguser.layer.masksToBounds = true
            cell.lblName.text=strusername
            
            if (strusername == "" || strusername == nil) {
                cell.lblName.text="\(mgrItm.PostOwnerfname)"  +  "\(mgrItm.PostOwnerlname)"
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeScreen.openImage(_:)))
            cell.imguser.addGestureRecognizer(tapGesture)
            cell.lbltime.text=strtime
            cell.btntalcomments.setTitle("\(strcommentCOunt)", for: UIControlState())
            cell.btnlikecount.setTitle("\(strlikeCount)", for: UIControlState())
            
            if (strDescription == nil) {
                strDescription = ""
            }
            
            if let strDesc = strDescription {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                          NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 10)!]
                
                let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
                var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
                
                for emojiName in customEmojis.emojiItemsArray {
                    objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
                }
                
                cell.lbldescription.attributedText = mutableStrDesc
            }
            cell.lbldescription.userHandleLinkTapHandler = { label, handle, range in
                let postmngr = PostManager.postManager
                let strWithId = postmngr.PostTextOld
                let mystr = strWithId
                let searchstr = "@:@:"
                let ranges: [NSRange]
                
                do {
                    // Create the regular expression.
                    let regex = try NSRegularExpression(pattern: searchstr, options: [])
                    
                    // Use the regular expression to get an array of NSTextCheckingResult.
                    // Use map to extract the range from each result.
                    ranges = regex.matches(in: mystr!, options: [], range: NSMakeRange(0, mystr!.characters.count)).map {$0.range}
                }
                catch {
                    // There was a problem creating the regular expression
                    ranges = []
                }
                
                print(ranges)
                if postmngr.PostTagIds == nil {
                    return
                }
                if postmngr.PostTagIds.count <= 0 {
                    return
                }
                if ranges.count > 0 {
                    if (label.text! as NSString).range(of: handle).location >= 0 {
                        if let ids = postmngr.PostTagIds!.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                            let arrStr = ids.components(separatedBy: ",")
                            if arrStr.count > 0 {
                                let otherId = arrStr[arrStr.count-1]
                                let struser:String=postmngr.PostOwnerfname
                                let strimg:String=postmngr.PostOwnerimg!
                                let user = UserManager.userManager
                                let mgrfriend = FriendsManager.friendsManager
                                
                                //mgrfriend.clearManager()
                                
                                mgrfriend.FriendName = struser + struser
                                mgrfriend.FriendPhoto = strimg
                                mgrfriend.FUsername = struser
                                mgrfriend.FriendID = otherId
                                
                                if (mgrfriend.FriendID == user.userId) {
                                    if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                                        leftVC.selectedrow = leftVC.profileRow
                                        leftVC.tblView.reloadData()
                                    }
                                    let VC1 = (objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                                    self.navigationController?.pushViewController(VC1, animated: true)
                                } else {
                                    let VC1 = (objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                                    self.navigationController?.pushViewController(VC1, animated: true)
                                    
                                }
                            }
                        }
                    }
                }
            }
            return cell
        }
        
        let CELL_ID = "commentCell"
        print(indexPath.row)
        print(indexPath.section)
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! commentCell
        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        lblName.textColor = UIColor.black
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        let userPic:UIImageView = cell.contentView.viewWithTag(101) as! UIImageView
        userPic.layer.masksToBounds = true
        
        let strusername:String?=(self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "username")! as? String
        
        let strimgname:String?=(self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "userphoto")! as? String
        
        let strtime:String?=(self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commenttime")! as? String
        
        let strDesc:String?=(self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commentdesc")! as? String
        
        cell.lblTime.text=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
        cell.lblName.text = strusername
        
        if (strusername == "" || strusername == nil)
        {
            cell.lblName.text="\((self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  +  "\((self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
        }
        
        // StringToEmoji
        cell.lblDescription.tag = indexPath.row
        cell.lblDescription.userHandleLinkTapHandler = { label, handle, range in
            let strOld = (self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "commentolddesc")! as? String
            let strWithId = strOld
            let mystr = strWithId
            let searchstr = "@:@:"
            let ranges: [NSRange]
            
            do {
                // Create the regular expression.
                let regex = try NSRegularExpression(pattern: searchstr, options: [])
                
                // Use the regular expression to get an array of NSTextCheckingResult.
                // Use map to extract the range from each result.
                ranges = regex.matches(in: mystr!, options: [], range: NSMakeRange(0, mystr!.characters.count)).map {$0.range}
            }
            catch {
                // There was a problem creating the regular expression
                ranges = []
            }
            
            print(ranges)
            if (((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "post_comment_tagids")! as? NSString) != nil) {
                return
            }
            var dictTags = NSDictionary()
            if let arrTags = (self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "post_comment_tagids")! as? NSArray {
                if arrTags.count == 1 {
                    let dict = ["0":arrTags.object(at: 0)]
                    dictTags = dict as NSDictionary
                    if dictTags.count <= 0 {
                        return
                    }
                    if ranges.count > 0 {
                        if (label.text! as NSString).range(of: handle).location >= 0 {
                            if let ids = dictTags.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                                let arrStr = ids.components(separatedBy: ",")
                                if arrStr.count > 0 {
                                    
                                    let otherId = arrStr[arrStr.count-1]
                                    let struser:String=((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "username")! as? String)!
                                    let strimg:String=((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "userphoto")! as? String)!
                                    let user = UserManager.userManager
                                    let mgrfriend = FriendsManager.friendsManager
                                    
                                    //mgrfriend.clearManager()
                                    
                                    mgrfriend.FriendName = struser + struser
                                    mgrfriend.FriendPhoto = strimg
                                    mgrfriend.FUsername = struser
                                    mgrfriend.FriendID = otherId
                                    
                                    if (mgrfriend.FriendID == user.userId)
                                    {
                                        if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                                            leftVC.selectedrow = leftVC.profileRow
                                            leftVC.tblView.reloadData()
                                        }
                                        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                                        self.navigationController?.pushViewController(VC1, animated: true)
                                    }
                                    else
                                    {
                                        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                                        self.navigationController?.pushViewController(VC1, animated: true)
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                return
            }
            if ((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "post_comment_tagids")! as? NSDictionary)!.count <= 0 {
                return
            }
            if ranges.count > 0 {
                if (label.text! as NSString).range(of: handle).location >= 0 {
                    if let ids = ((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "post_comment_tagids")! as? NSDictionary)!.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                        let arrStr = ids.components(separatedBy: ",")
                        if arrStr.count > 0 {
                            
                            let otherId = arrStr[arrStr.count-1]
                            let struser:String=((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "username")! as? String)!
                            let strimg:String=((self.arrayComments.object(at: label.tag) as AnyObject).value(forKey: "userphoto")! as? String)!
                            let user = UserManager.userManager
                            let mgrfriend = FriendsManager.friendsManager
                            
                            //mgrfriend.clearManager()
                            mgrfriend.FriendName = struser + struser
                            mgrfriend.FriendPhoto = strimg
                            mgrfriend.FUsername = struser
                            mgrfriend.FriendID = otherId
                            
                            if (mgrfriend.FriendID == user.userId) {
                                if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                                    leftVC.selectedrow = leftVC.profileRow
                                    leftVC.tblView.reloadData()
                                }
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                                self.navigationController?.pushViewController(VC1, animated: true)
                            } else {
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                                self.navigationController?.pushViewController(VC1, animated: true)
                                
                            }
                        }
                    }
                }
            }
        }
        
        let strDescription = strDesc
        
        if let strDesc:String = strDescription {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                      NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 10)!]
            
            let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
            var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
            
            for emojiName in customEmojis.emojiItemsArray {
                objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
            }
            
            cell.lblDescription.attributedText = mutableStrDesc
        }
        
        
        cell.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        cell.imgUser.layer.cornerRadius = userPic.frame.size.height / 2
        cell.imgUser.layer.masksToBounds = true
        cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        
        return cell
    }
    
    
    
    
     // MARK: - scrollview delegates -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tblView.contentOffset.y <= 0.0 && !isBusyFetching {
            if arrayComments.count < totalcomment {
                offset += 1
                self.getCommentItm()
            }
        }
        if arrayComments.count >= totalcomment {
            spinner?.stopAnimating()
        }
        
        guard let visibleIndexPaths = tblView.indexPathsForVisibleRows else { return }
        let zeroIndex = IndexPath(row: 0, section: 0)
        
        if visibleIndexPaths.contains(zeroIndex) {
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.transitionFlipFromTop, animations: {
                constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-icon_menu")
                constant.btnObj1.tag = 0
                constant.btnObj1.removeTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: {
                if constant.btnObj1.buttonsIsShown() {
                    constant.btnObj1.onTap()
                    if let firstTimeMenuLoaded = Defaults.firstTimeMenuLoaded.value as? String {
                        if firstTimeMenuLoaded != "1" {
                            constant.btnObj2.onTap()
                        }
                    }
                }
                
                constant.btnObj1.frame.origin.x = self.view.frame.maxX - constant.btnObj1.frame.width
                constant.btnObj1.frame.origin.y = self.view.frame.maxY - constant.btnObj1.frame.height
                constant.btnObj2.frame.origin = constant.btnObj1.frame.origin
                objAppDelegate.circleMenuOrigin = constant.btnObj1.frame.origin
                constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-uparrow")
                constant.btnObj1.tag = 1
                constant.btnObj1.addTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
            }, completion: nil)
        }
    }
    
    
    
    
    // MARK: - custom button methods
    
    func btnGoToTopClicked(_ sender: Any) {
        if UserManager.userManager.userId == "1" {
        }else {
            guard tblView.numberOfRows(inSection: 0) > 0 else { return }
            tblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    

    
    
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        if tableView == tblTagging {
            return 1
        }
        
        if tableView == tblTimer {
            return 1
        }
        if self.Posttype==postTypeenum.stream.rawValue
        {
            return 2
            
        }
        return 1
    }
    
    func tableTapped(_ tap: UITapGestureRecognizer) {
        let location: CGPoint = tap.location(in: tblTimer)
        let path: IndexPath? = tblTimer.indexPathForRow(at: location)
        if path != nil {
            
            tblTimer.deselectRow(at: path!, animated: true)
            timerSelectedIndexPath = path
            self.selectedDate = self.timerArray[(path?.row)!]["value"] as? Int
            print(timerArray[(path?.row)!]["value"] as! Int)
            //self.hideTimer()
            msgComposerView?.isHidden = false
            msgComposerView?.messageTextView.becomeFirstResponder()
            //tblTimer(tblTimer, didSelectRowAt: path!)
            
        }
        else {
            // handle tap on empty space below existing rows however you want
        }
    }

    func tableTappedOnTagging(_ tap: UITapGestureRecognizer) {
        let location: CGPoint = tap.location(in: tblTagging)
        let path: IndexPath? = tblTagging.indexPathForRow(at: location)
        if path != nil {
        tblTagging.deselectRow(at: path!, animated: true)
        let newAnnoation = MintAnnotation()
        newAnnoation.usr_id = "\(filterArray[(path?.row)!].userid)"
        newAnnoation.usr_name = filterArray[(path?.row)!].username
        
        let str = (msgComposerView?.messageTextView.text)! as NSString
        let lastComma = str.range(of: filterString, options: .backwards).toTextRange(textInput: (msgComposerView?.messageTextView)!)
        if let comma = lastComma {
            msgComposerView?.messageTextView.replace(comma, withText: "")
        }
        recordingHashTag = false
        msgComposerView?.messageTextView.nameTagColor = UIColor.clear
        self.msgComposerView?.messageTextView.add(newAnnoation)
        _ = self.msgComposerView?.messageTextView.makeStringWithTag()
        hideTblTagging()
        msgComposerView?.messageTextView.becomeFirstResponder()
        filterString = ""
        return
        } else {
    }
    }


    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if tableView == tblTagging {
//            let newAnnoation = MintAnnotation()
//            newAnnoation.usr_id = "\(filterArray[indexPath.row].userid)"
//            newAnnoation.usr_name = filterArray[indexPath.row].username
//            
//            let str = (msgComposerView?.messageTextView.text)! as NSString
//            let lastComma = str.range(of: filterString, options: .backwards).toTextRange(textInput: (msgComposerView?.messageTextView)!)
//            if let comma = lastComma {
//                msgComposerView?.messageTextView.replace(comma, withText: "")
//            }
//            recordingHashTag = false
//            msgComposerView?.messageTextView.nameTagColor = UIColor.clear
//            self.msgComposerView?.messageTextView.add(newAnnoation)
//            _ = self.msgComposerView?.messageTextView.makeStringWithTag()
//            hideTblTagging()
//            msgComposerView?.messageTextView.becomeFirstResponder()
//            filterString = ""
//            return
        }
            if tableView == tblTimer {
//                tableView.deselectRow(at: indexPath, animated: true)
//                timerSelectedIndexPath = indexPath
//                self.selectedDate = self.timerArray[indexPath.row]["value"] as? Int
//                print(timerArray[indexPath.row]["value"] as! Int)
//                //self.hideTimer()
//                msgComposerView?.isHidden = false
//                msgComposerView?.messageTextView.becomeFirstResponder()
        }
        
        if self.Posttype==postTypeenum.stream.rawValue  && indexPath.section == 0 {
            
            btnUserProfileClicked(btnComment)
        } else {
            
            let usr = UserManager.userManager
            let postmgr = PostManager.postManager
            let cmtmanger = CommentManager.commentManager
            var dic :NSMutableDictionary?
            // mgrfriend.clearManager()
            
            if let cmID: String  = (self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commentid") as? String {
                
                cmtmanger.CommentID = Int(cmID)
                
            }
            let mutDict = NSMutableDictionary(dictionary: self.arrayComments.object(at: indexPath.row) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;
            
            
            
            if let uID: String  = dic?.value(forKey: "userid") as? String {
                if (usr.userId == uID || usr.userId==postmgr.PostOwID) {
                    let mgrItm = PostManager.postManager
                    
                    let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    let reply = UIAlertAction(title: "Copy", style: UIAlertActionStyle.default) {
                        
                        UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                        UIPasteboard.general.string = (self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commentdesc")! as? String
                        
                    }
                    let delete = UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive) {
                        UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                        self.isAction = true
                        var cmntID = ""
                        if let cmID  = (self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commentid") as? Int {
                            cmntID = "\(cmID)"
                        }
                        if let cmID  = (self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commentid") as? String  {
                            cmntID = "\(cmID)"
                        }
                        let deleteParams = ["uid":usr.userId,"commentid":"\(cmntID)","postid":mgrItm.PostId]
                        cmtmanger.deletecomment(deleteParams as NSDictionary, successClosure: { (dic, result) -> Void in
                            if result == APIResultcmt.apiSuccess
                            {
                                SVProgressHUD.dismiss()
                                self.arrayComments.removeObject(at: indexPath.row)
                                var paths:[IndexPath]!
                                self.tblView.beginUpdates()
                                
                                if self.Posttype==postTypeenum.stream.rawValue
                                {
                                    paths = [IndexPath(row: (indexPath.row), section: 1)]
                                }
                                else
                                {
                                    paths = [IndexPath(row: (indexPath.row), section: 0)]
                                }
                                self.tblView.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                                self.tblView.endUpdates()
                                
                                mgrItm.PostComments = mgrItm.PostComments - 1
                                
                                self.btnTotalcomment.setTitle("\(mgrItm.PostComments)", for: UIControlState())
                                self.tblView.reloadData()
                            }
                            
                        })
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    // Add the actions
                    alert.addAction(reply)
                    alert.addAction(delete)
                    alert.addAction(cancelAction)
                    
                    if (IS_IPAD) {
                        let aFrame: CGRect = tblView.rectForRow(at: IndexPath(row: indexPath.row, section: indexPath.section))
                        alert.popoverPresentationController!.sourceRect = aFrame;
                        alert.popoverPresentationController!.sourceView = tblView;
                        
                    }
                    // Present the actionsheet
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                    
                    let reply = UIAlertAction(title: "Copy", style: UIAlertActionStyle.default) {
                        UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                        
                        
                        UIPasteboard.general.string = (self.arrayComments.object(at: indexPath.row) as AnyObject).value(forKey: "commentdesc")! as? String
                        
                    }
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                        UIAlertAction in
                        alert.dismiss(animated: true, completion: nil)
                    }
                    // Add the actions
                    alert.addAction(reply)
                    alert.addAction(cancelAction)
                    
                    if (IS_IPAD) {
                        let aFrame: CGRect = self.tblView.rectForRow(at: IndexPath(row: indexPath.row, section: indexPath.section))
                        
                        
                        alert.popoverPresentationController!.sourceRect = aFrame;
                        alert.popoverPresentationController!.sourceView = self.tblView;
                        
                    }
                    // Present the actionsheet
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
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
        mutAttrString.append((msgComposerView?.messageTextView.attributedText)!)
        mutAttrString.append(attrStringWithImage)
        let txtViewFontSize = msgComposerView?.messageTextView.font?.pointSize
        
        let textAttrib = [NSForegroundColorAttributeName : colors.kTextViewColor,
                          NSFontAttributeName : UIFont(name: (msgComposerView?.messageTextView.font?.fontName)!, size: txtViewFontSize!)!]
        
        mutAttrString.addAttributes(textAttrib, range: NSRange(location: 0,length: mutAttrString.length))
        
        msgComposerView?.messageTextView.attributedText = mutAttrString
        if msgComposerView?.messageTextView.attributedText.containsAttachments(in: NSRange(location: 0, length: (msgComposerView?.messageTextView.attributedText.length)!)) == true {
            msgComposerView?.sendButton.isEnabled = true
        }
    }
    
    // MARK: GSM Method
    
    func btnGSMClicked(_ btnIndex: Int) {
        
        switch btnIndex {
        case 0:
            if Posttype == 0 {
                let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePostVC")) as! CreatePostVC
                self.navigationController?.pushViewController(VC1, animated: true)
                
            } else {
                let VC1 = (objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePost_Media")) as! CreatePost_Media
                VC1.delegate = self
                self.navigationController?.pushViewController(VC1, animated: true)
            }
            
        case 6:
            btnDashboardClicked()
        case 7:
            btnMoreClicked()
        default:
            break
        }
    }
    
    // MARK: - keyboard methods -
    
    func keyboardWillShow(_ notification: Notification) {
        if emojiBtn.tag == 0 {
            emojiBtn.setImage(UIImage(named: "like"), for: UIControlState())
        } else {
            emojiBtn.setImage(UIImage(named: "ico-keyboard"), for: UIControlState())
        }
        
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomTagging.constant = frame.size.height + 50
        framefinal = frame
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frame.size.height, right: 0)
        tblView.contentInset = contentInsets
        tblView.scrollIndicatorInsets = contentInsets
        //tblChat.reloadData()
        //[tblChat setContentOffset:CGPointMake(0, CGFLOAT_MAX)]
        
        let numberOfSections = tblView.numberOfSections
        let numberOfRows = tblView.numberOfRows(inSection: numberOfSections-1)
        
        if numberOfRows > 0 {
            self.scrollToBottom()
        }
    }
    
    // MARK: - custom button Methods
    
    func dismissKeyboard(_sender: UIButton) {
        msgComposerView?.isHidden = false
        hideTblTagging()
        view.endEditing(true)
    }
    
    
    func keyboardWillHide(_ notification: Notification) {
        constHeightTblTimer.constant = 0
        
        
        //emojiBtn.setImage(imgProfile.image, for: UIControlState())
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        bottomTagging.constant = frame.size.height + 50
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0, right: 0)
        
        tblView.contentInset = contentInsets
        tblView.scrollIndicatorInsets = contentInsets
    }
    
    
    
    func performAction() {
        
        //action events
    }
    
    
    // MARK: - message composer delegates -
    
    func showHideTableBtnAction() {
        
    }
    
    
    func messageComposerSendMessageClicked(withMessage message: String!) {
        self.view.endEditing(true)
        view.endEditing(true)
        
        
        var strMsg1 = message.trimmingCharacters(in: CharacterSet.whitespaces)
        if strMsg1.characters.last == "\n" {
            strMsg1 = String(strMsg1.characters.dropLast())
        }
        print(strMsg1)
        
        if strMsg1.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter comment")
            
        } else {
        let txtPostAttribString = msgComposerView?.messageTextView.taggedString()
        
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
            }
        })
        print(txtMutableAttribString.string)
        
        let strMessage =  txtMutableAttribString.string
        
        var strMsg = strMessage.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if strMsg.characters.last == "\n" {
            strMsg = String(strMsg.characters.dropLast())
        }
        print(strMsg)
        
        if strMsg.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter comment")
        } else {
            
            let mgrCMt = CommentManager.commentManager
            mgrCMt.COmmentMessage=strMsg
            sendMessage()
        }
        
        if !mainInstance.connected() {
            return
        }
        
        if framefinal != nil {
            
            let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: framefinal!.size.height+50, right: 0)
            tblView.contentInset = contentInsets
            tblView.scrollIndicatorInsets = contentInsets
        }
        self.scrollToBottom()
    }
    }
    
    func messageComposerFrameDidChange(_ frame: CGRect, withAnimationDuration duration: CGFloat) {
        
    }
    
    func messageComposerUserTyping() {
        
        let strTyped = msgComposerView?.messageTextView.text
        typedString = strTyped!
        if let lastText = strTyped!.characters.last {
            if (lastText == "@") {
                recordingHashTag = true
                startParse = ((strTyped! as NSString).range(of: "@", options: NSString.CompareOptions.backwards)).location
            }
            if startParse > ((strTyped! as NSString).range(of: "\(lastText)", options: NSString.CompareOptions.backwards)).location {
                recordingHashTag = false
                return
            }
        }
        if recordingHashTag == true {
            var value = ""
            if startParse == 0 {
                let finalStr = strTyped!
                if startParse < (finalStr as NSString).length - startParse {
                    if (finalStr as NSString).length - startParse > 0 {
                        value = (finalStr as NSString).substring(with: NSRange(location: startParse, length: (finalStr as NSString).length - startParse))
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
            } else if startParse > 0 {
                let finalStr = strTyped
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
        }
    }
    // MARK: - dateformation -
    
    func getDateString() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let s = formatter.string(from: Date())
        return s
    }
    func getDateStringForDisplayy(_ strDate : String) -> String? {
        //        2015-10-08T20:00:00Z
        //        print(strDate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss dd MMM yyyy"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: strDate) {
            let s = dateFormatter.string(from: date)
            return s
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            if let  date = formatter.date(from: strDate) {
                
                let s = dateFormatter.string(from: date)
                return s
            }
        }
        return nil
    }
    
    //MARK: - dateformation -
    
    func scrollToBottom() {
        
        var numberOfRows : Int = 0
        //[tblView setContentOffset:CGPointMake(0, CGFLOAT_MAX)]
        if self.Posttype==postTypeenum.stream.rawValue {
            numberOfRows = tblView.numberOfRows(inSection: 1)
        } else {
            numberOfRows = tblView.numberOfRows(inSection: 0)
        }
        if numberOfRows > 0 {
            
            if self.Posttype==postTypeenum.stream.rawValue {
                let indexPath = IndexPath(row: numberOfRows-1, section: 1)
                tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
            } else {
                let indexPath = IndexPath(row: numberOfRows-1, section: 0)
                tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
            }
        }
    }
    
    
    
    // MARK: - post Details
    
    func getPostDetails() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = PostManager.postManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrItm.PostId, forKey: "postid")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(usr.userId, forKey: "myid")
        
        print(parameterss)
        
        SVProgressHUD.show(withStatus: "Fetching Details", maskType: SVProgressHUDMaskType.clear)
        mgr.getPostDetails(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "commentcount") as? Int {
                    
                    self.postDetails = dic!
                    if let mypost :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "mypost") as? Int {
                        mgrItm.PostismyPost = "\(mypost)"
                    }
                    
                    let keyExists = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "media") as AnyObject).count
                    if keyExists! > 0 {
                        
                        
                        
                        let mType:String = (((dic?.value(forKey: "result") as! NSDictionary).value(forKey: "media") as! NSArray).object(at: 0) as AnyObject).value(forKey: "media_type") as! String
                        self.ShareURL = (((dic?.value(forKey: "result") as! NSDictionary).value(forKey: "media") as! NSArray).object(at: 0) as AnyObject).value(forKey: "media_url") as! String
                        let murl:String = (((dic?.value(forKey: "result") as! NSDictionary).value(forKey: "media") as! NSArray).object(at: 0) as AnyObject).value(forKey: "media_url") as! String
                        
                        mgrItm.PostType = mType
                        mgrItm.PostImg = murl
                        
                    } else {
                        mgrItm.PostType = "0"
                    }
                    
                    
                    let itmImgString = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "userphoto")as! String
                    var imgurl: URL!
                    if let imageURL = URL(string: itmImgString) {
                        imgurl = imageURL
                        self.userCircleImg.sd_setImageWithPreviousCachedImage(with: imgurl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: { (img, error, type, url) -> Void in
                        })
                    } else {
                        
                    }

                    self.totalcomment = countShop
                    mgrItm.PostComments = self.totalcomment
                    self.arrayComments.removeAllObjects()
                    
                    if self.totalcomment > 0 {
                        
                        let tempArray = NSMutableArray(array: (dic?.value(forKey: "result") as AnyObject).value(forKey: "comments") as! NSArray)
                        if tempArray.count > 0 {
                            if self.arrayComments.count == 0 {
                                self.arrayComments.addObjects(from: tempArray as [AnyObject])
                            } else {
                                for i in 0  ..< tempArray.count {
                                    self.arrayComments.insert(tempArray[i], at: 0)
                                }
                            }
                            self.tblView.reloadData()
                            print(self.arrayComments.count)
                            if self.scollToBottom {
                                self.scrollToBottom()
                                self.scollToBottom = false
                            } else {
                                
                                if self.lastCount > 0 {
                                    
                                    if self.Posttype==postTypeenum.stream.rawValue {
                                        
                                        let indexPath = IndexPath(row: tempArray.count, section: 1)
                                        self.tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                                        
                                    } else {
                                        
                                        let indexPath = IndexPath(row: tempArray.count, section: 0)
                                        self.tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                                    }
                                }
                            }
                        }
                    }
                }
                
                let resultDic = dic?.value(forKey: "result") as! NSDictionary
                mgrItm.PostLikes=resultDic.value(forKey: "likecount")! as! Int
                mgrItm.PostComments=resultDic.value(forKey: "commentcount") as! Int
                mgrItm.PostTime=resultDic.value(forKey: "created_date") as! String
                mgrItm.isPostLike=resultDic.value(forKey: "islike") as! Int
                mgrItm.isPostComment=resultDic.value(forKey: "iscomment") as! Int
                mgrItm.PostOwID=resultDic.value(forKey: "posted_by") as? String
                mgrItm.PostOwAdd = resultDic.value(forKey: "usercity") as? String
                mgrItm.PostOwner = resultDic.value(forKey: "username") as! String
                mgrItm.PostOwnerfname = resultDic.value(forKey: "fname") as! String
                mgrItm.PostOwnerlname = resultDic.value(forKey: "lname") as! String
                mgrItm.PostOwnerimg = resultDic.value(forKey: "userphotothumb") as? String
                mgrItm.PostTextOld = resultDic.value(forKey: "post_oldtitle") as? String
                mgrItm.PostTagIds = resultDic.value(forKey: "post_tagids") as? NSDictionary
                if mgrItm.PostTagIds == nil {
                    if let arrTags = resultDic.value(forKey: "post_tagids") as? NSArray {
                        if arrTags.count == 1 {
                            let dict = ["0":arrTags.object(at: 0)]
                            mgrItm.PostTagIds = dict as NSDictionary
                        }
                    }
                }
                
                
                if resultDic.value(forKey: "post_title") is NSNull {
                    
                    mgrItm.PostText = ""
                }
                else {
                    
                    mgrItm.PostText = resultDic.value(forKey: "post_title") as? String
                    if let post = mgrItm.PostText {
                        let arr = post.components(separatedBy: "@@:-:@@")
                        if arr.count>0 {
                            mgrItm.PostText = arr[0]
                            self.lblMediaPostTitle.text = mgrItm.PostText
                            
                        }
                    }
                    if let post = mgrItm.PostTextOld {
                        let arr = post.components(separatedBy: "@@:-:@@")
                        if arr.count>0 {
                            mgrItm.PostTextOld = arr[arr.count-1]
                            self.lblMediaPostTitle.text = mgrItm.PostTextOld

                        }
                    }
                }
                self.lblMediaPostTitle.text = resultDic.value(forKey: "username") as? String
                self.isreloadtbl = true
                SVProgressHUD.dismiss()
                self.tblView.isHidden = false;
                
                self.renDerheaderData()
                self.tblView.reloadData()
                
            } else if result == APIResult.apiError {
                print(dic)
                self.view.endEditing(true)
                _ = SweetAlert().showAlert("ScreamXO", subTitle: dic!.value(forKey: "msg")! as! NSString as String, style: AlertStyle.error, buttonTitle: "OK", action: {
                    result in
                    if result {
                        if let dele = self.delegate {
                            dele.actionOnpostData!()
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                SVProgressHUD.dismiss()
            }
            else {
                self.view.endEditing(true)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: - comment Details
    
    func getCommentItm() {
        
        isBusyFetching = true
        spinner?.startAnimating()
        
        if arrayComments.count >= totalcomment {
            spinner?.stopAnimating()
        }
        
        if arrayComments.count == 0 {
            SVProgressHUD.show(withStatus: "Fetching old comments..")
        }
        if !self.scollToBottom {
            lastCount = arrayComments.count
        }
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = PostManager.postManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrItm.PostId, forKey: "postid")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        spinner?.startAnimating()
        
        mgr.getCommentList(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                
                if !self.scollToBottom {
                    self.lastCount = self.arrayComments.count
                }
                
                if self.arrayComments.count >= self.totalcomment {
                    self.spinner?.stopAnimating()
                }
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "commentcount") as? Int {
                    self.totalcomment = countShop
                    mgrItm.PostComments = self.totalcomment
                    
                    if let tempArray = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "comments") as! NSArray) as? NSMutableArray {
                        
                        if tempArray.count > 0 {
                            if self.arrayComments.count == 0 {
                                self.arrayComments.addObjects(from: tempArray as [AnyObject])
                            }
                            else {
                                for i in 0  ..< tempArray.count {
                                    self.arrayComments.insert(tempArray[i], at: 0)
                                }
                            }
                            self.tblView.reloadData()
                            print(self.arrayComments.count)
                            if self.scollToBottom {
                                self.scrollToBottom()
                                self.scollToBottom = false
                            } else {
                                if self.lastCount > 0 {
                                    
                                    if self.Posttype==postTypeenum.stream.rawValue {
                                        let indexPath = IndexPath(row: tempArray.count, section: 1)
                                        self.tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                                    } else {
                                        let indexPath = IndexPath(row: tempArray.count, section: 0)
                                        self.tblView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
                                    }
                                }
                            }
                        } else {
                            self.spinner?.stopAnimating()
                        }
                        
                    }
                }
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                
                self.view.endEditing(true)
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                
            } else {
                self.view.endEditing(true)
                
                mainInstance.showSomethingWentWrong()
            }
            
            self.isBusyFetching = false
        })
    }
    
    // MARK: - Send Message
    
    func sendMessage() {
        
        isAction = true
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = PostManager.postManager
        let mgrCMt = CommentManager.commentManager
        
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrItm.PostId, forKey: "postid")
        parameterss.setValue(usr.userId, forKey: "commentby")
        parameterss.setValue(mgrCMt.COmmentMessage, forKey: "commentdesc")
        var dict = [String:String]()
        mgrCMt.COmmentMessageOld = msgComposerView?.messageTextView.makeStringWithoutTagString()
        print(mgrCMt.COmmentMessageOld)
        if msgComposerView?.messageTextView.rangesOfAt != nil {
            if (msgComposerView?.messageTextView.rangesOfAt.count)! > 0 {
                if msgComposerView?.messageTextView.rangesOfAt.count == msgComposerView?.messageTextView.rangesOfAtOriginal.count {
                    for index in 0..<(msgComposerView?.messageTextView.rangesOfAt)!.count {
                        dict[msgComposerView?.messageTextView.rangesOfAtOriginal.object(at: index) as! String] = msgComposerView?.messageTextView.rangesOfAt.object(at: index) as? String
                    }
                }
            }
        }
        print(dict)
        mgrCMt.COmmentTagIds = dict as NSDictionary
        parameterss.setValue(dict, forKey: "commenttagids")
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        mgr.SendComment(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                
                if let commentID :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "commentid") as? Int
                {
                    
                    mgrCMt.CommentID=commentID
                    
                    let parameterss = NSMutableDictionary()
                    parameterss.setValue(mgrItm.PostId, forKey: "postid")
                    parameterss.setValue(usr.userId, forKey: "commentby")
                    parameterss.setValue((dic!.value(forKey: "result")! as AnyObject).value(forKey: "commentdesc") as! String, forKey: "commentdesc")
                    parameterss.setValue((dic!.value(forKey: "result")! as AnyObject).value(forKey: "commentolddesc") as! String, forKey: "commentolddesc")
                    parameterss.setValue(mgrCMt.COmmentTagIds, forKey: "post_comment_tagids")
                    parameterss.setValue(usr.profileImage, forKey: "userphoto")
                    
                    if  ((usr.username == nil || ( usr.username == "")))
                    {
                        parameterss.setValue(usr.fullName, forKey: "username")
                    }
                    else
                    {
                        parameterss.setValue(usr.username, forKey: "username")
                    }
                    parameterss.setValue(self.getDateString(), forKey: "commenttime")
                    self.totalcomment = mgrItm.PostComments + 1
                    mgrItm.PostComments = mgrItm.PostComments + 1
                    
                    parameterss.setValue(usr.userId, forKey: "userid")
                    parameterss.setValue(mgrCMt.CommentID, forKey: "commentid")
                    self.arrayComments.add(parameterss)
                    
                    if self.Posttype==postTypeenum.stream.rawValue {
                    self.tblView.reloadData()
                    } else {
                    self.tblView.beginUpdates()
                    self.newResults = [IndexPath(row: self.arrayComments.count - 1 , section: 0) as NSIndexPath]
                    self.tblView.insertRows(at: self.newResults! as [IndexPath], with: .none)
                    self.tblView.endUpdates()
                    }
                    self.btnTotalcomment.setTitle("\(mgrItm.PostComments)", for: UIControlState())
                }
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                self.view.endEditing(true)
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                self.view.endEditing(true)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    
    // MARK: - render data ofHeader
    
    func renDerheaderData() {
        let mgrItm = PostManager.postManager
        isPlayVideo = false
        if (mgrItm.PostOwnerimg != nil && !(mgrItm.PostType == "0")) {
            
            if mgrItm.PostOwnerimg != nil {
                imgUserProfile.sd_setImageWithPreviousCachedImage(with: URL(string: (mgrItm.PostOwnerimg)!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
                })            }
            
            imgUserProfile.contentMode=UIViewContentMode.scaleAspectFill
            imgUserProfile.layer.cornerRadius = imgUserProfile.frame.size.height / 2
            imgUserProfile.layer.masksToBounds = true
            
            print(mgrItm.PostOwner)
            
            lbllocation.text = mgrItm.PostOwAdd
            
            
            btnTotalcomment.setTitle("\(mgrItm.PostComments)", for: UIControlState())
            btntotalLikes.setTitle("\(mgrItm.PostLikes)", for: UIControlState())
            
            
            if  ( mgrItm.PostType == "video/quicktime" || mgrItm.PostType == "audio/m4a" || mgrItm.PostType == "audio/mp3" || mgrItm.PostType == "video/mp4") {
                
                let bundle = Bundle.main
                let config = MobilePlayerConfig(fileURL: bundle.url(
                    forResource: "Skin",
                    withExtension: "json")!)
                playerFInal = MobilePlayerViewController(
                    contentURL: URL(string: mgrItm.PostImg)!,
                    config: config)
                playerFInal.title = mgrItm.PostText
                isPlayVideo = true
                playerFInal.activityItems = [URL(string: mgrItm.PostImg)!]
                playerFInal.view.center = self.imgMedia.center
                playerFInal.view.frame=self.imgMedia.frame
                playerFInal.shouldAutoplay = true
                playerFInal.play()
                playerFInal.view.tag=1001
                viewHeader.addSubview(playerFInal.view)
            } else {
                if (playerFInal != nil) {
                    playerFInal!.view.removeFromSuperview()
                }
                
                imgMedia.sd_setImageWithPreviousCachedImage(with: URL(string: mgrItm.PostImg!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
                })
            }
            if let islike :  Int? = mgrItm.isPostLike {
                
                if (islike == 0) {
                    btnLike.setImage(UIImage(named: "unlike"), for: UIControlState())
                } else {
                    
                    btnLike.setImage(UIImage(named: "like"), for: UIControlState())
                }
            }
            imgUserProfile.layer.cornerRadius = imgUserProfile.frame.size.height / 2
            imgUserProfile.layer.masksToBounds = true
        }
        
        if mgrItm.PostismyPost == "1" {
            btnUserNameBoost.removeTarget(self, action: #selector(btnUserProfileClicked(_:)), for: .touchUpInside)
            
            btnUserNameBoost.setTitleColor(.white, for: .normal)
            btnUserNameBoost.setTitle("BOOST", for: .normal)
            btnUserNameBoost.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
            btnUserNameBoost.addTarget(self, action: #selector(btnBoostClicked(_:)), for: .touchUpInside)
        } else {
            
            btnUserNameBoost.removeTarget(self, action: #selector(btnBoostClicked(_:)), for: .touchUpInside)
//            if mgrItm.PostType == "0" {
//                
//                if mgrItm.PostOwnerfname != "" {
//                    let userName = "\(mgrItm.PostOwnerfname)"
//                    btnUserNameBoost.setTitle(userName, for: .normal)
//                } else {
//                    btnUserNameBoost.setTitle(mgrItm.PostOwner, for: .normal)
//                }
//            } else if mgrItm.PostType == "1" {
//                btnUserNameBoost.setTitle(mgrItm.PostText, for: .normal)
//            }
//            
//            if (btnUserNameBoost.currentTitle == "" || btnUserNameBoost.currentTitle == nil) {
//                let userName = "\(mgrItm.PostOwnerfname)"
//                btnUserNameBoost.setTitle(userName, for: .normal)
//            }
            
            btnUserNameBoost.setTitleColor(.white, for: .normal)
            btnUserNameBoost.setTitle("SHARE", for: .normal)
            btnUserNameBoost.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
            btnUserNameBoost.addTarget(self, action: #selector(btnUserProfileClicked(_:)), for: .touchUpInside)
            
        }
    }
    
    // MARK: - Like WebServiceCalled
    
    func postlikeMethod() {
        
        let mgrpost = PostManager.postManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(likeaction, forKey: "action")
        parameterss.setValue(mgrpost.PostId, forKey: "postid")
        
        mgr.likePost(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess{
                
            } else if result == APIResult.apiError {
                self.view.endEditing(true)
                
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                self.view.endEditing(true)
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: - DZNEmptyDataSetSource Methods -
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let textAttrib = [NSForegroundColorAttributeName : colors.kLightgrey155,
                          NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 24)!]
        let finalString = NSMutableAttributedString(string: "No Comments yet, you can post it", attributes: textAttrib)
        return finalString
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo")
    }
    // MARK: - scrollview delegates -
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//    
//        if tblView.contentOffset.y <= 0.0 && !isBusyFetching {
//            if arrayComments.count < totalcomment {
//                offset += 1
//                self.getCommentItm()
//            }
//        }
//        if arrayComments.count >= totalcomment {
//            spinner?.stopAnimating()
//        }
//    }
    
    // MARK: - Open Image VIewer  -
    
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
    
    // MARK: - previewActionItems
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let likeAction = UIPreviewAction(title: "Close", style: .default) { (action, viewController) -> Void in
            print("You liked the photo")
        }
        
        return [likeAction]
    }
    
    
    // MARK: - video play methods for landscape
    
    
    
    func playVideoinlandscape() {
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        if orientation.isPortrait {
            msgComposerView?.isHidden = false
            print(orientation.isPortrait)
            playerFInal.view.backgroundColor = UIColor.red
            if(playerFInal.view.frame.height == self.view.frame.height) {
                UIView.animate(withDuration: 0.25, animations:{
                    self.playerFInal.view.transform = CGAffineTransform.identity
                    self.playerFInal.view.center = self.imgMedia.center
                    self.playerFInal.view.frame = self.imgMedia.frame
                    self.viewHeader.addSubview(self.playerFInal.view)
                })
            }
            self.orientationValue = false
        } else if orientation.isLandscape {
            
            UIApplication.shared.isStatusBarHidden = true
            UIView.animate(withDuration: 0.50, animations:{
                if orientation.rawValue == 4 {
                    if orientation.isLandscape == self.orientationValue {
                        self.playerFInal.view.frame.size.width=self.view.frame.size.width
                        self.playerFInal.view.frame.size.height=self.view.frame.size.height
                        self.playerFInal.view.frame.origin.y = 6
                    } else {
                        self.playerFInal.view.frame.size.width=self.view.frame.size.height
                        self.playerFInal.view.frame.size.height=self.view.frame.size.width
                        self.playerFInal.view.frame.origin.y = 6
                    }
                    self.playerFInal.view.transform = CGAffineTransform(rotationAngle: -.pi/2)
                    self.playerFInal.view.center = self.view.center
                    self.playerFInal.fitVideo()
                    self.playerFInal.view.frame.origin.y = 6
                    self.playerFInal.loadViewIfNeeded()
                   
                } else if orientation.rawValue == 3 {
                    if orientation.isLandscape == self.orientationValue {
                        self.playerFInal.view.frame.size.width=(self.view.frame.size.width)
                        self.playerFInal.view.frame.size.height=(self.view.frame.size.height)
                        self.playerFInal.view.frame.origin.y = 6
                        
                    } else {
                        self.playerFInal.view.frame.size.width=(self.view.frame.size.height)
                        self.playerFInal.view.frame.size.height=(self.view.frame.size.width)
                        self.playerFInal.view.frame.origin.y = 6
                    }
                    self.playerFInal.view.transform = CGAffineTransform(rotationAngle: .pi/2)
                    self.playerFInal.view.center = self.view.center
                    self.playerFInal.fitVideo()
                    self.playerFInal.view.frame.origin.y = 6
                    self.playerFInal.loadViewIfNeeded()
                } else {
                }
            })
            self.orientationValue = true
        }
    }

    
    
    func playVideoinlandscapeMode() {
        guard playerFInal != nil else {
            return
        }
        
        if(playerFInal.view.frame.height == self.view.frame.height) {
            
            UIView.animate(withDuration: 0.25, animations:{
                self.playerFInal.view.transform = CGAffineTransform.identity
                self.playerFInal.view.center = self.imgMedia.center
                self.playerFInal.view.frame = self.imgMedia.frame
                self.viewHeader.addSubview(self.playerFInal.view)
            })
            isPlayingLandscape = false

        } else {
            UIView.animate(withDuration: 0.25, animations:{
                self.playerFInal.view.frame.size.width = self.view.frame.size.height
                self.playerFInal.view.frame.size.height = self.view.frame.size.width
                self.playerFInal.view.frame.origin.x = self.view.frame.origin.y
                self.playerFInal.view.transform = CGAffineTransform(rotationAngle: .pi/2)
                self.playerFInal.view.center = self.view.center
                self.playerFInal.fitVideo()
                self.playerFInal.loadViewIfNeeded()
                self.view.addSubview(self.playerFInal.view)
            })
            isPlayingLandscape = true

        }
    }
    
    func stopVideo() {
        
        if (playerFInal != nil) {
            
            if(playerFInal.view.frame == self.view.frame) {
                playerFInal.view.frame = imgMedia.frame
                viewHeader.addSubview(playerFInal.view)
                
            } else {
                
                playerFInal.view.frame = self.view.frame
                self.view.addSubview(playerFInal.view)
            }
        }
    }
    func sharemedia() {
        let textToShare = ""
        
        let mgrItm = PostManager.postManager
        
        let objectsToShare = [textToShare, mgrItm.PostImg]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }
}

extension PostDetailsVC: PostmediaActionDelegate {
    func postmediaData() {
        if delegatePostMedia != nil {
            delegatePostMedia?.actionOnPostMediaViaPostDetail()
        }
    }
}


