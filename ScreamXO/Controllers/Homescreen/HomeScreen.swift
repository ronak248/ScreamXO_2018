//
//  HomeScreen.swift
//  ScreamXO
//
//  Created by Ronak Barot on 27/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation


var homescreenFlag: Bool = false
class streamCell :UITableViewCell {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lbltime: UILabel!
    @IBOutlet weak var btntalcomments: UIButton!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var imguser: circleImage!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnlikecount: UIButton!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var lbldescription: KILabel!
    @IBOutlet var lblnofounddata: UILabel!
    override func awakeFromNib() {
        btnlikecount.setTitle("0", for: UIControlState())
        btntalcomments.setTitle("0", for: UIControlState())
    }
    
    override func layoutSubviews() {
        self.imguser.layer.cornerRadius = self.imguser.frame.size.height / 2
        self.imguser.layer.masksToBounds = true
    }
}
class buffetCell :UITableViewCell {
    
    @IBOutlet weak var caroselBufeet: iCarousel!
    @IBOutlet weak var lblnofounddata: UILabel!
    @IBOutlet weak var imgIconp: UIImageView!
    @IBOutlet weak var imgItem: UIImageView!
}

class shopCell :UITableViewCell {
    
    @IBOutlet weak var lblnofounddata: UILabel!
    @IBOutlet weak var caroselShop: iCarousel!
    @IBOutlet weak var imgIconp: UIImageView!
    @IBOutlet weak var imgItem: UIImageView!
}

class HomeScreen: UIViewController,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate,WYPopoverControllerDelegate {
    
    // MARK: Properites
    
    enum Expand : NSInteger {
        case expDelete = 0,exPhalf,exPfull
    }
    var icarouselView: iCarousel!
    var icarouselItem: iCarousel!
    var selecteditemIndex:NSInteger?
    var selectedShopItmIndex: NSInteger?
    var ExpandType :Int!
    var buffetSession :Int!
    var shopSession: Int!
    var Expandshop :Int!
    var Expandstream :Int!
    var isreloadbuffet :Bool!
    var isreloaditem :Bool!
    var isBusyFetching = false
    var isShopFilter = false
    var isPrivacyFilter = false
    var isFilter :Bool = false
    var isBuffetExpand :Bool = true
    var isShopExpand :Bool = true
    var isStreamExpand :Bool = true
    var isPlayVideo :Bool = false
    var shouldRefreshMedia :Bool = true
    var tapGUesture :UITapGestureRecognizer!
    var pathsStore:[IndexPath]!
    var arrayShopItems = NSMutableArray ()
    var arrayMediaItems = NSMutableArray ()
    var arrayStream = NSMutableArray ()
    var likeaction : Int = 0
    var totalCount : Int = 0
    var dictMy : Dictionary<String, AnyObject>?
    var offsetsh:Int = 1
    var offsetMe:Int = 1
    var offsetSt:Int = 1
    var limit:Int = 10
    var totalShopCount:Int = 0
    var totalMediaCount:Int = 0
    var totalStreamPost:Int = 0
    var MediaType:String!
    var IsAddedPlayer:Bool = false
    var strFilterType:String = ""
    var VC1:ItemDetails?
    var playerFInal:MobilePlayerViewController!
    var playerFullscreen:MobilePlayerViewController!
    let mgrPost = PostManager.postManager
    var videoUrl:URL!
    var popoverController: WYPopoverController!
    var internetConnected = true
    let mgrItm = ItemManager.itemManager
    var catID = 0
    var scrollShopCarousel = false
    

    @IBOutlet weak var updatingLbl: UILabel!
    @IBOutlet weak var updatingLblHgt: NSLayoutConstraint!
    
    var strPrivacyType = "2"
    var player : AVPlayer!
    var playerLayer : AVPlayerLayer!
    var strKeyword = ""
    var orientationValue: Bool!

    var item_id: Int!
    var boost_type : Int!
    // MARK: IBOutlets
    var tempArrForNextPlay: NSMutableArray! =  NSMutableArray()
    @IBOutlet weak var tblDashboard: UITableView!
    @IBOutlet var searchDashboard: UISearchBar!
    @IBOutlet weak var fireBtn: UIButton!
    var trendingType: String! = String()
    
    // MARK: IBConstraints
    
    @IBOutlet var constTblDashTop: NSLayoutConstraint!
    
    
    // MARK: View life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        updatingLbl.alpha = 0.0
        updatingLblHgt.constant = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let notificationName = Notification.Name("myhomescreen")
            NotificationCenter.default.post(name: notificationName, object: nil)
        }
        orientationValue = false
        searchDashboard.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        searchDashboard.backgroundColor = UIColor.white
        searchDashboard.barTintColor = UIColor.clear
        let manger = APIManager.apiManager
        if manger.sessionToken != nil {
            getadminData()
        }
        if constant.onSearchDash {
            self.fireBtn.isHidden = false
            self.searchDashboard.isHidden = false
            self.constTblDashTop.constant = 44
        } else {
            self.fireBtn.isHidden = true
            self.searchDashboard.isHidden = true
            self.constTblDashTop.constant = 0
        }
        self.searchDashboard.barTintColor = UIColor.clear
        self.searchDashboard.backgroundColor = UIColor.white
        searchDashboard.backgroundImage = UIImage()
        ExpandType = 1
        Expandshop = 1
        Expandstream = 1
        isreloaditem = false
        isreloadbuffet = false
        tblDashboard.estimatedRowHeight = 145
        tblDashboard.rowHeight = UITableViewAutomaticDimension
        tblDashboard.reloadData()
        self.automaticallyAdjustsScrollViewInsets = false
        let mgr = PostManager.postManager
        mgr.clearManager()
        
        mgrItm.clearManager()
        getDasboardActivity()
        
        if( traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView:self.view)
        }
        
        
        if (objAppDelegate.isLoadVideo) {
            objAppDelegate.isLoadVideo = false
        }
        
    }
    
    
    func showDataUpdating() {
        updatingLbl.alpha = 0.0
        updatingLblHgt.constant = 0
        UIView.animate(withDuration: 1, animations: {
            self.updatingLbl.alpha = 1.0
            self.updatingLblHgt.constant = 57
        }, completion: nil)
        
    }
    
    
    func showDataUpdated() {
//        updatingLbl.alpha = 1.0
//        updatingLblHgt.constant = 57
        UIView.animate(withDuration: 1, animations: {
            self.updatingLbl.alpha = 0.0
            self.updatingLblHgt.constant = 0
        }, completion: nil)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        if (!(objAppDelegate.dicUserInfopush == nil)) {
            navigatetoRelvantPushScreen()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        view.endEditing(true)
        
         let itemMgr = ItemManager.itemManager
        if itemMgr.loadEarlier {
       
            ExpandType = 1
            Expandshop = 1
            Expandstream = 1
            isreloaditem = false
            isreloadbuffet = false
            tblDashboard.estimatedRowHeight = 145
            tblDashboard.rowHeight = UITableViewAutomaticDimension
            tblDashboard.reloadData()
            self.automaticallyAdjustsScrollViewInsets = false
            
        self.arrayMediaItems = itemMgr.arrayMediaItems
        self.arrayStream = itemMgr.arrayStream
        self.arrayShopItems = itemMgr.arrayShopItems
        
        self.tblDashboard.reloadData()
        if self.arrayMediaItems.count > 0 {
           // self.icarouselView.scrollToItem(at: 0, animated: true)
        }
        var emptyDic:[String : AnyObject] = [:]
        
        emptyDic["shop"] = self.arrayShopItems
        emptyDic["media"] = self.arrayMediaItems
        emptyDic["stream"] = self.arrayStream
        if (!IS_IPAD) {
            let manger = APIManager.apiManager
            if manger.sessionToken != nil {
                objAppDelegate.sendData(emptyDic)
            }
        }
        } else {
        
        let emptyDic:[String : AnyObject] = [:]
        if (!IS_IPAD) {
            let manger = APIManager.apiManager
            if manger.sessionToken != nil {
                objAppDelegate.sendData(emptyDic)
            }
        }
        
        }
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.playVideoinlandscapemode), name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopVideo), name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        
      
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnLikeClickedmedia(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)
        tblDashboard.reloadData()
        //        if UserManager.userManager.userId == "1" {
        //        if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
        //                snapContainer.scrollView.isScrollEnabled = false
        //            }
        //        }else{
        //            if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
        //                snapContainer.scrollView.isScrollEnabled = true
        //            }
        //        }
        
        if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
            snapContainer.scrollView.isScrollEnabled = true
        }
        
    }
    
    func deviceDidRotate(notification: NSNotification) {
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        print(orientation)
        if orientation.isLandscape {
            if isPlayVideo == true {
                print(orientation.rawValue)
                playVideoinlandscape()
            }
        } else if orientation.isPortrait {
            if isPlayVideo == true {
                playVideoinlandscape()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        objAppDelegate.fullScreenVideoIsPlaying=false
        NotificationCenter.default.removeObserver(self)
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sharemedia"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "myhomescreen"), object: nil)
        if ExpandType == Expand.exPfull.rawValue {
            
            if selecteditemIndex != -1 {
                
                objAppDelegate.fullScreenVideoIsPlaying=false
                tblDashboard.beginUpdates()
                ExpandType=1;
                let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
                selecteditemIndex = -1
            }
        }
        
        if Expandshop == Expand.exPfull.rawValue {
            
            if selectedShopItmIndex != -1 {
                tblDashboard.beginUpdates()
                Expandshop = 1
                let paths: [IndexPath] = [IndexPath(row: 1, section: 1)]
                tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
                selectedShopItmIndex = -1
            }
        }
        
        constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-icon_menu")
        constant.btnObj1.tag = 0
        constant.btnObj1.removeTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
        
        if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
            snapContainer.scrollView.isScrollEnabled = false
        }
    }
    
    
    
    // MARK: - custom button methods
    
    func btnGoToTopClicked(_ sender: Any) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            guard tblDashboard.numberOfRows(inSection: 0) > 0 else { return }
            tblDashboard.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func btntotalLikeCOuntClicked(_ sender: UIButton) {
        
        let mgrpost = PostManager.postManager
        mgrpost.clearManager()
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    
    func goToUserProfile(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            let mgrfriend = FriendsManager.friendsManager
            mgrfriend.clearManager()
            let dictChatUserInfo = arrayStream.object(at: sender.tag)
            let uID  = String(describing: ((arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "userid")!))
            let user = UserManager.userManager
            if (uID == user.userId) {
                if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                    leftVC.selectedrow = leftVC.profileRow
                    leftVC.tblView.reloadData()
                }
                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                self.navigationController?.pushViewController(VC1, animated: true)
            } else {
                mgrfriend.FriendID = uID
                mgrfriend.FriendName = ((dictChatUserInfo as AnyObject).value(forKey: "fname") as! String) + ((dictChatUserInfo as AnyObject).value(forKey: "lname") as! String)
                mgrfriend.FriendPhoto = ((dictChatUserInfo as AnyObject).value(forKey: "userphoto") as! String)
                mgrfriend.FUsername = ((dictChatUserInfo as AnyObject).value(forKey: "username") as! String)
                //            if let fID = dictChatUserInfo["isfriend"] as? Int {
                //                mgrfriend.isFriend = "\(fID)"
                //
                //                if fID == 1 {
                //                    if let fconnectionID = dictChatUserInfo["friendshipid"]! as? Int {
                //                        mgrfriend.friendConnectionID = "\(fconnectionID)"
                //
                //                    }
                //                }
                //            }
                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                self.navigationController?.pushViewController(VC1, animated: true)
            }
            
        }
    }
    
    func btntotalLikeClcikedmedia(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnLikeClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            var likeCount:Int=((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "likecount")! as? Int)!
            
            let mgrpost = PostManager.postManager
            mgrpost.clearManager()
            mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
            var dic :NSMutableDictionary?
            
            let mutDict = NSMutableDictionary(dictionary: self.arrayStream.object(at: sender.tag) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;
            
            if ((dic?.value(forKey: "islike"))! as! Int == 0) {
                dic?.setValue(1, forKey: "islike");
                
                likeaction = 0
                likeCount += 1
                
                dic?.setValue(likeCount, forKey: "likecount");
                
                self.arrayStream.replaceObject(at: sender.tag, with: dic!)
                tblDashboard.reloadData()
                self.postlikeMethod()
            } else {
                likeaction = 1
                likeCount -= 1
                dic?.setValue(likeCount, forKey: "likecount");
                dic?.setValue(0, forKey: "islike");
                self.arrayStream.replaceObject(at: sender.tag, with: dic!)
                tblDashboard.reloadData()
                self.postlikeMethod()
                
            }
        }
    }
    
    func btnCommentClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            let mgrItm = PostManager.postManager
            mgrItm.clearManager()
            mgrItm.PostId="\(((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id"))!)"
            mgrItm.PostType = "0"
            mgrItm.postTag = sender.tag
            
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
            
            VC1.Posttype=0;
            VC1.isViewComment=0;
            VC1.delegate=self
            
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnTotalCOmmentClciked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            let mgrItm = PostManager.postManager
            mgrItm.clearManager()
            mgrItm.PostId="\(((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id"))!)"
            mgrItm.PostType = "0"
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
            mgrItm.postTag = sender.tag
            
            VC1.Posttype=0;
            VC1.isViewComment=1;
            VC1.delegate=self
            
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnMoreoptionClicked(_ sender: UIButton) {
        let mgrpost = PostManager.postManager
        
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        
        if let mypost :  Int = (self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "mypost") as? Int {
            mgrpost.PostismyPost = "\(mypost)"
        }
        
        let strshare = (self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "post_title") as! String
        
        let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let Delete = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            
            mgrpost.PostTypecheck="0"
            
            mgrpost.deletepost({ (dic, result) -> Void in
                if result == APIResultpost.apiSuccess {
                    
                    print("tag:: %d",(sender.tag))
                    self.arrayStream.removeObject(at: sender.tag)
                    self.tblDashboard.reloadData()
                }
                
            })
        }
        
        let share = UIAlertAction(title: "Share", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            let textToShare = ""
            
            let objectsToShare = [textToShare, strshare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            let button = sender
            if (IS_IPAD) {
                activityVC.popoverPresentationController!.sourceRect = button.bounds;
                activityVC.popoverPresentationController!.sourceView = button;
            }
            if UserManager.userManager.userId == "1"{
                self.setLoginViewForGuest()
            } else {
                
                self.present(activityVC, animated: true, completion: nil)
            }
        }
        let report = UIAlertAction(title: "Report Post", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            if UserManager.userManager.userId == "1"{
                self.setLoginViewForGuest()
            } else {
                mgrpost.reportPost()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        
        if mgrpost.PostismyPost == "1" {
            alert.addAction(Delete)
        } else {
            alert.addAction(report)
        }
        alert.addAction(share)
        alert.addAction(cancelAction)
        
        // Present the actionsheet
        
        let button = sender
        if (IS_IPAD) {
            
            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
            
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func btnMorePostClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1"
        {
            setLoginViewForGuest()
        } else {
            let mgrItm = PostManager.postManager
            print((self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "userphoto") as? String)
            
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
            VC1.delegate = self
            VC1.delegatePostMedia = self
            VC1.Posttype = 2
            if sender.tag == 102 {
                VC1.isViewComment = 0
            } else {
                VC1.isViewComment = 1
            }
            
            VC1.item_id = item_id
            VC1.boost_type = 2
            
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
     @IBAction func btnFireClicked(_ sender: AnyObject) {
        
        if mainInstance.connected() {
            
            objAppDelegate.internetPopupDisplayed = false
            tblDashboard.isHidden = true;
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            let mgrPost = PostManager.postManager
            self.searchDashboard.resignFirstResponder()
            let parameterss = NSMutableDictionary()
            parameterss.setValue(1, forKey: "offset")
            parameterss.setValue(limit, forKey: "limit")
            parameterss.setValue(usr.userId, forKey: "uid")
            parameterss.setValue(usr.userId, forKey: "myid")
            parameterss.setValue(strFilterType, forKey: "mediatype")
            parameterss.setValue(catID, forKey: "categoryid")
            parameterss.setValue(strPrivacyType, forKey: "userfiltertype")
            parameterss.setValue(strKeyword, forKey: "searchstring")
            parameterss.setValue("0", forKey: "trending_mode")
            parameterss.setValue("1", forKey: "firing_mode")
            
            print(parameterss)
            
            SVProgressHUD.show(withStatus: "Fetching Activity", maskType: SVProgressHUDMaskType.clear)
            mgr.dashBoardAcitivity(parameterss, successClosure: { (dictMy, result) -> Void in
                SVProgressHUD.dismiss()
                print(dictMy!)
                self.tblDashboard.isHidden=false;
                if result == APIResult.apiSuccess {
                    if let countMedia :  Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "mediapostcount") as? Int {
                        self.totalMediaCount = countMedia
                    }
                    if let countShop :  Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "itemcount") as? Int {
                        self.totalShopCount = countShop
                    }
                    if let countStream :  Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "streampostcount") as? Int {
                        self.totalStreamPost = countStream
                    }
                    
                    self.arrayShopItems = NSMutableArray(array: (dictMy!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemdetails") as! NSArray)
                    
                    self.arrayStream = NSMutableArray(array: (dictMy!.value(forKey: "result")! as! NSDictionary).value(forKey: "streampost") as! NSArray)
                    
                    self.arrayMediaItems = NSMutableArray(array: (dictMy!.value(forKey: "result")! as! NSDictionary).value(forKey: "mediapost") as! NSArray)
                    
                    self.tblDashboard.reloadData()
                    if self.arrayMediaItems.count > 0 {
                        self.icarouselView.scrollToItem(at: 0, animated: true)
                    }
                    var emptyDic:[String : AnyObject] = [:]
                    
                    emptyDic["shop"] = self.arrayShopItems
                    emptyDic["media"] = self.arrayMediaItems
                    emptyDic["stream"] = self.arrayStream
                    if (!IS_IPAD) {
                        let manger = APIManager.apiManager
                        if manger.sessionToken != nil {
                            objAppDelegate.sendData(emptyDic)
                        }
                    }
                    SVProgressHUD.dismiss()
                } else if result == APIResult.apiError {
                    
                    print(dictMy!)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    
                    mainInstance.showSomethingWentWrong()
                }
            })
        } else {
            
            if objAppDelegate.internetPopupDisplayed == false {
                
                mainInstance.showNoInternetAlert()
                objAppDelegate.internetPopupDisplayed = true
            }
        }

    }
    
    @IBAction func btnMenucClicked(_ sender: AnyObject) {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    func btnMediaHeaderOptionsClicked(_ sender: UIButton) {
        constant.onMediaHeaderOptions = !constant.onMediaHeaderOptions
        tblDashboard.reloadData()
    }
    
    func btnShopHeaderOptionsClicked(_ sender: UIButton) {
        constant.onShopHeaderOptions = !constant.onShopHeaderOptions
        tblDashboard.reloadData()
    }
    
    
    func btnStreamHeaderOptionsClicked(_ sender: UIButton) {
        constant.onStreamHeaderOptions = !constant.onStreamHeaderOptions
        tblDashboard.reloadData()
    }
    
    func btnexpandBuffetClicked(_ sender: UIButton?) {
        
        var paths:[IndexPath]!
        tblDashboard.beginUpdates()
        
        if ExpandType == Expand.exPfull.rawValue {
            isBuffetExpand = false
            buffetSession = ExpandType
            paths = [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)]
            ExpandType = 0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
            
        } else if ExpandType == Expand.exPhalf.rawValue {
            isBuffetExpand = false
            buffetSession = ExpandType
            paths = [IndexPath(row: 0, section: 0)]
            ExpandType = 0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
            
        } else {
            ExpandType = buffetSession
            
            if buffetSession == Expand.exPfull.rawValue {
                paths = [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)]
            }
            else {
                paths = [IndexPath(row: 0, section: 0)]
            }
            isBuffetExpand = true
            
            tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
            
        }
        if (isBuffetExpand) {
            sender?.setImage(UIImage(named: "upic"), for: UIControlState())
        } else {
            sender?.setImage(UIImage(named: "dpic"), for: UIControlState())
        }
        
    }
    
    func btnexpandshopClicked(_ sender: UIButton?) {
        
        var paths:[IndexPath]!
        tblDashboard.beginUpdates()
        if Expandshop == Expand.exPfull.rawValue {
            
            isShopExpand = false
            shopSession = Expandshop
            paths = [IndexPath(row: 0, section: 1), IndexPath(row: 1, section: 1)]
            Expandshop = 0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        } else if Expandshop == Expand.exPhalf.rawValue {
            isShopExpand = false
            shopSession = Expandshop
            paths = [IndexPath(row: 0, section: 1)]
            Expandshop = 0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        } else {
            Expandshop = shopSession
            
            if shopSession == Expand.exPfull.rawValue {
                paths = [IndexPath(row: 0, section: 1), IndexPath(row: 1, section: 1)]
            } else {
                paths = [IndexPath(row: 0, section: 1)]
            }
            isShopExpand = true
            
            tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        }
        
        if (isShopExpand) {
            sender?.setImage(UIImage(named: "upic"), for: UIControlState())
        } else {
            sender?.setImage(UIImage(named: "dpic"), for: UIControlState())
        }
    }
    
    func btnexpandstreamClicked(_ sender: UIButton?) {
        
        if (arrayStream.count>0) {
            var paths:[IndexPath]!
            tblDashboard.beginUpdates()
            
            if Expandstream==Expand.exPhalf.rawValue {
                isStreamExpand = false
                
                if(self.arrayStream.count>0) {
                    paths = getAllIndexes(2)
                    pathsStore = paths
                    Expandstream=0
                    tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                    tblDashboard.endUpdates()
                }
            } else {
                Expandstream=1;
                
                isStreamExpand = true
                
                tblDashboard.insertRows(at: pathsStore, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
            }
            
            if (isStreamExpand) {
                sender?.setImage(UIImage(named: "upic"), for: UIControlState())
            } else {
                sender?.setImage(UIImage(named: "dpic"), for: UIControlState())
            }
        }
        
    }
    
    func btnAddMediaPost(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePost_Media")) as! CreatePost_Media
            VC1.delegate = self
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnAddItem(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN")) as! SellItemVC
            VC1.delegate = self
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnAddTextPost(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePostVC")) as! CreatePostVC
            VC1.delegate = self
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnWatchClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        }else {
            let mgrItm = ItemManager.itemManager
            if sender.accessibilityIdentifier == "ico_unwatch" {
                mgrItm.addWatchedItem(1,successClosure:{ (dic, result) -> Void in
                    
                    if result == APIResultItm.apiSuccess {
                        sender.setImage(UIImage(named: "ico_watch"), for: UIControlState())
                        sender.accessibilityIdentifier = "ico_watch"
                        let objShopItm = NSMutableDictionary(dictionary: self.arrayShopItems.object(at: mgrItm.itmTag) as! NSDictionary)
                        objShopItm.setValue("1", forKey: "iswatched")
                        self.arrayShopItems.replaceObject(at: mgrItm.itmTag, with: objShopItm)
                    }
                })
            } else {
                mgrItm.addWatchedItem(0,successClosure:{ (dic, result) -> Void in
                    
                    if result == APIResultItm.apiSuccess {
                        sender.setImage(UIImage(named: "ico_unwatch"), for: UIControlState())
                        sender.accessibilityIdentifier = "ico_unwatch"
                        let objShopItm = NSMutableDictionary(dictionary: self.arrayShopItems.object(at: mgrItm.itmTag) as! NSDictionary)
                        objShopItm.setValue("0", forKey: "iswatched")
                        self.arrayShopItems.replaceObject(at: mgrItm.itmTag, with: objShopItm)
                    }
                })
            }
        }
    }
    
    func btnItmNameClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        }else {
            let mgrItm = ItemManager.itemManager
            
            if let itmID: Int  = Int(mgrItm.ItemId), let itmTag = mgrItm.itmTag {
                mgrItm.clearManager()
                mgrItm.ItemId = "\(itmID)"
                mgrItm.itmTag = itmTag
            }
            VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as? ItemDetails
            VC1?.delegateAddItem = self
            VC1!.delegate = self
            VC1?.delegateHomeWatch = self
            VC1?.item_id = item_id
            VC1?.boost_type = 1
            self.navigationController?.pushViewController(VC1!, animated: true)
        }
    }
    
    
    
    
    func btnBoostClickedMedia(_ sender: UIButton) {
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            
            let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
            print(item_id)
            boostViewController.item_id =  item_id
            boostViewController.boost_type =  boost_type
            if isPlayVideo {
                playerFullscreen.stop()
            }
            
            self.navigationController?.pushViewController(boostViewController, animated: true)
        }
        
    }
    
    
    func btnBoostClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
            print(item_id)
            if isPlayVideo {
                playerFullscreen.stop()
            }
            boostViewController.item_id =  item_id
            boostViewController.boost_type =  boost_type
            self.navigationController?.pushViewController(boostViewController, animated: true)
        }
    }
    
    func btnShareClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let mgrItm = PostManager.postManager
            print((self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "media_url") as? String)
            let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
            objfriends.ispushtype=1;
            objfriends.shareFlag = true
            objfriends.shareUrl = ((self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "media_url") as? String)!
            self.navigationController!.pushViewController(objfriends, animated: true)
        }
    }
    
    
    func btnBuyClicked(_ sender: UIButton) {
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            
            let mgrItm = ItemManager.itemManager
            
            if mgrItm.ispaymentKind == "0" {
                
                mainInstance.ShowAlertWithError("Error!", msg: "you can not purchase this item!! seller has not configured payment gateway")
            } else {
                
                let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "ConfigureBuyPaymentVC")) as! ConfigureBuyPaymentVC
                 VC1.isShopFlag = true
                self.navigationController?.pushViewController(VC1, animated: true)
                
                
//                let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "PaymentDetailsVC")) as! PaymentDetailsVC
//                self.navigationController?.pushViewController(VC1, animated: true)
            }
        }
    }
    
    func btnFilterClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            if (popoverController != nil) {
                popoverController.dismissPopover(animated: true)
            }
             catID = 0
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "FilterHome")) as! FilterHome
            VC1.mediaType = strFilterType
            VC1.delegate=self
            VC1.isTable = "media"
            popoverController = WYPopoverController(contentViewController: VC1)
            popoverController.delegate = self;
            popoverController.popoverContentSize = CGSize(width: 150, height: 200)
            popoverController.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        }
    }
    
    func btnShopFilterClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let mgrPost = PostManager.postManager
            mgrPost.mediaType = ""
            mgrPost.privacyType = ""
            strFilterType = ""
            if (popoverController != nil) {
                self.popoverController.dismissPopover(animated: true)
            }
            let VC1 = objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "DropDownVC") as! DropDownVC
            VC1.selectedCategory = String(catID)
            VC1.delegate = self
            popoverController = WYPopoverController(contentViewController: VC1)
            popoverController.delegate = self
            popoverController.popoverContentSize = CGSize(width: 150, height: 200)
            popoverController.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        }
    }
    
    func btnPrivacySettingClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            catID = 0
            let mgrPost = PostManager.postManager
            mgrPost.mediaType = ""
            
            if (popoverController != nil) {
                popoverController.dismissPopover(animated: true)
            }
            
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "FilterHome")) as! FilterHome
            
            VC1.privacyType = strPrivacyType
            VC1.delegate = self
            VC1.isTable = "stream"
            popoverController = WYPopoverController(contentViewController: VC1)
            popoverController.delegate = self;
            popoverController.popoverContentSize = CGSize(width: 150, height: 120)
            popoverController.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        }
    }
    
    func btnUserProfileClicked() {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let user = UserManager.userManager
            let mgrfriend = FriendsManager.friendsManager
            let mgrItm = PostManager.postManager
            
            if let fName = (self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "fname") as? String {
                if let lName = (self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "lname") as? String {
                    mgrfriend.FriendName = fName + lName
                } else {
                    mgrfriend.FriendName = fName
                }
            }
            if let fUserName = (self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "username") as? String {
                mgrfriend.FUsername = fUserName
            }
            
            if let fPhoto = (self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "userphoto") as? String {
                mgrfriend.FriendPhoto = fPhoto
            }
            
            if let fID = (self.arrayMediaItems.object(at: mgrItm.postTag) as! NSDictionary).value(forKey: "userid") as? Int {
                mgrfriend.FriendID = String(fID)
            }
            
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
    
    // MARK: GSM Method
    
    func btnGSMClicked(_ btnIndex: Int) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            
            switch btnIndex {
                
                
            case 0:
                
                let VC1 = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "PostVC") as? PostVC
                navigationController?.pushViewController(VC1!, animated: true)
                
            case 6:
                if isBuffetExpand || isShopExpand || isStreamExpand {
                    if (isBuffetExpand) {
                        btnexpandBuffetClicked(nil)
                    }
                    
                    if (isShopExpand) {
                        btnexpandshopClicked(nil)
                    }
                    
                    if (isStreamExpand) {
                        btnexpandstreamClicked(nil)
                    }
                } else {
                    btnexpandBuffetClicked(nil)
                    btnexpandshopClicked(nil)
                    btnexpandstreamClicked(nil)
                }
                tblDashboard.reloadData()
                
            case 7:
                constant.onSearchDash = !constant.onSearchDash
                if constant.onSearchDash {
                    self.fireBtn.isHidden = false
                    self.searchDashboard.isHidden = false
                    self.searchDashboard.becomeFirstResponder()
                    self.searchDashboard.delegate = self
                    self.constTblDashTop.constant = 44
                } else {
                    self.fireBtn.isHidden = true
                    self.searchDashboard.isHidden = true
                    self.constTblDashTop.constant = 0
                     self.searchDashboard.resignFirstResponder()
                    self.searchDashboard.resignFirstResponder()
                    self.searchDashboard.showsCancelButton = false
                }
                
            default:
                break
            }
        }
    }
    
    func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
    }
    //MARK: - opencamera method
    
    func openCameraSwipe() {
        if UserManager.userManager.userId == "1"{
        }else {
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePost_Media")) as! CreatePost_Media
            VC1.delegate=self
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 47
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        
        if indexPath.section==0
        {
            if indexPath.row==0
            {
                
                if (UI_USER_INTERFACE_IDIOM() == .pad)
                {
                    return 200;
                }
                
                return 106;
            }
            if (UI_USER_INTERFACE_IDIOM() == .pad)
            {
                
                return 299;
                
                
            }
            return 250;
        }
        else  if indexPath.section==1
        {
            if indexPath.row==0
            {
                
                if (UI_USER_INTERFACE_IDIOM() == .pad)
                {
                    return 200;
                }
                
                
                return 106;
            }
            if (UI_USER_INTERFACE_IDIOM() == .pad)
            {
                
                return 299;
                
                
            }
            return 250;
        }
        //        {
        //
        //            if (UI_USER_INTERFACE_IDIOM() == .Pad)
        //            {
        //
        //                return 200;
        //            }
        //            return 106;
        //        }
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if section==0 {
            if ExpandType == Expand.exPfull.rawValue {
                return 2
            } else if ExpandType == Expand.exPhalf.rawValue {
                return 1
            }
            return 0
        } else if section==1 {
            if Expandshop == Expand.exPfull.rawValue {
                return 2
            } else if Expandshop == Expand.exPhalf.rawValue {
                return 1
            }
            return 0
        } else if section == 2 {
            if Expandstream == Expand.expDelete.rawValue {
                return 0
            }
            
            if arrayStream.count == 0 {
                return 1
            } else {
                return arrayStream.count
            }
        }
        
        return 0
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let CELL_ID = "headerCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as UITableViewCell!
        let lblName : UILabel = cell!.contentView.viewWithTag(101) as! UILabel
        let btnExpand: UIButton = cell!.contentView.viewWithTag(102) as! UIButton
        let btnAdd: UIButton = cell!.contentView.viewWithTag(103) as! UIButton
        let btnfilter: UIButton = cell!.contentView.viewWithTag(104) as! UIButton
        let btnmenu: UIButton = cell!.contentView.viewWithTag(100) as! UIButton
        let stackView: UIStackView = cell!.contentView.viewWithTag(105) as! UIStackView
        let btnShowHeaderOptions: UIButton = cell!.contentView.viewWithTag(106) as! UIButton
        
        btnExpand.setImage(UIImage(named: "upic"), for: UIControlState())
        
        if section == 0 {
            lblName.text = "MEDIA"
            
            btnShowHeaderOptions.addTarget(self, action: #selector(self.btnMediaHeaderOptionsClicked(_:)), for: .touchUpInside)
            btnExpand.addTarget(self, action: #selector(self.btnexpandBuffetClicked(_:)), for: .touchUpInside)
            btnAdd.addTarget(self, action: #selector(self.btnAddMediaPost(_:)), for: .touchUpInside)
            btnfilter.addTarget(self, action: #selector(self.btnFilterClicked(_:)), for: .touchUpInside)
            btnmenu.addTarget(self, action: #selector(self.btnMenucClicked(_:)), for: .touchUpInside)
            
            btnmenu.isHidden = false
            
            if constant.onMediaHeaderOptions == true {
                lblName.isHidden = true
                stackView.isHidden = false
            } else {
                lblName.isHidden = false
                stackView.isHidden = true
            }
            
            if (isFilter) {
                if strFilterType != "" {
                    btnfilter.layer.borderWidth = 0.5
                    btnfilter.layer.borderColor = UIColor.lightGray.cgColor
                }
            }
            
            if (isBuffetExpand) {
                btnExpand.setImage(UIImage(named: "upic"), for: UIControlState())
            } else {
                btnExpand.setImage(UIImage(named: "dpic"), for: UIControlState())
            }
        } else if section == 1 {
            btnmenu.isHidden=true;
            lblName.text = "SHOP"
            
            btnShowHeaderOptions.addTarget(self, action: #selector(self.btnShopHeaderOptionsClicked(_:)), for: .touchUpInside)
            btnExpand.addTarget(self, action: #selector(self.btnexpandshopClicked(_:)), for: .touchUpInside)
            btnAdd.addTarget(self, action: #selector(self.btnAddItem(_:)), for: .touchUpInside)
            btnfilter.addTarget(self, action: #selector(self.btnShopFilterClicked(_:)), for: .touchUpInside)
            
            if constant.onShopHeaderOptions == true {
                lblName.isHidden = true
                stackView.isHidden = false
            } else {
                lblName.isHidden = false
                stackView.isHidden = true
            }
            
            if (isShopFilter) {
                
                btnfilter.layer.borderWidth=0.5
                btnfilter.layer.borderColor=UIColor.lightGray.cgColor
            } else {
                
                btnfilter.layer.borderWidth=0.0
                btnfilter.layer.borderColor=UIColor.clear.cgColor
            }
            if (isShopExpand) {
                btnExpand.setImage(UIImage(named: "upic"), for: UIControlState())
            } else {
                btnExpand.setImage(UIImage(named: "dpic"), for: UIControlState())
            }
        } else {
            btnmenu.isHidden = true;
            lblName.text = "STREAM"
            
            btnShowHeaderOptions.addTarget(self, action: #selector(self.btnStreamHeaderOptionsClicked(_:)), for: .touchUpInside)
            btnExpand.addTarget(self, action: #selector(self.btnexpandstreamClicked(_:)), for: .touchUpInside)
            btnAdd.addTarget(self, action: #selector(self.btnAddTextPost(_:)), for: .touchUpInside)
            btnfilter.setImage(UIImage(named: "ico-setting"), for: UIControlState())
            btnfilter.addTarget(self, action: #selector(self.btnPrivacySettingClicked(_:)), for: .touchUpInside)
            
            if constant.onStreamHeaderOptions == true {
                lblName.isHidden = true
                stackView.isHidden = false
            } else {
                lblName.isHidden = false
                stackView.isHidden = true
            }
            
            if (isPrivacyFilter) {
                
                btnfilter.layer.borderWidth=0.5
                btnfilter.layer.borderColor=UIColor.lightGray.cgColor
            } else {
                
                btnfilter.layer.borderWidth=0.0
                btnfilter.layer.borderColor=UIColor.clear.cgColor
            }
            
            if (isStreamExpand) {
                btnExpand.setImage(UIImage(named: "upic"), for: UIControlState())
            } else {
                btnExpand.setImage(UIImage(named: "dpic"), for: UIControlState())
            }
        }
        btnmenu.isHidden = true
        return cell!.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                
                let CELL_ID = "BuffetCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! buffetCell!
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                
                if (isreloadbuffet == false ) {
                    
                    isreloadbuffet=false
                    cell?.caroselBufeet.type = iCarouselType.linear
                    cell?.caroselBufeet.bounces = false
                    cell?.caroselBufeet.isPagingEnabled = false
                    cell?.caroselBufeet.delegate = self
                    cell?.caroselBufeet.strIdentifier="buffet"
                    cell?.caroselBufeet.dataSource = self
                    if arrayMediaItems.count>0 {
                        
                        cell?.lblnofounddata.isHidden = true
                    } else {
                        
                        cell?.lblnofounddata.isHidden = false
                    }
                    
                    tblDashboard.emptyDataSetDelegate = self
                    tblDashboard.emptyDataSetSource = self
                    icarouselView=cell?.caroselBufeet
                    
                    if DeviceType.IS_IPHONE_6 {
                        cell?.caroselBufeet.viewpointOffset=CGSize(width: 140, height: 0)
                        
                    }
                    else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                        cell?.caroselBufeet.viewpointOffset=CGSize(width: 119, height: 0)
                        
                    }
                    else if DeviceType.IS_IPHONE_6P {
                        cell?.caroselBufeet.viewpointOffset=CGSize(width: 155, height: 0)
                        
                    }
                    else if UI_USER_INTERFACE_IDIOM() == .pad{
                        
                        cell?.caroselBufeet.viewpointOffset=CGSize(width: 285, height: 0)
                    }
                    cell?.caroselBufeet.reloadData()
                    
                }
                return cell!
            } else {
                
                let CELL_ID = "MediaCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as UITableViewCell!
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                let btnComment: UIButton = cell!.contentView.viewWithTag(102) as! UIButton
                let imgbg: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
                let btnlike: UIButton = cell!.contentView.viewWithTag(104) as! UIButton
                let userImgBtn: UIButton = cell!.contentView.viewWithTag(133) as! UIButton
                let userImg: UIImageView = cell!.contentView.viewWithTag(135) as! UIImageView
                let btnlikecount: UIButton = cell!.contentView.viewWithTag(105) as! UIButton
                let btnUserName: UIButton = cell!.contentView.viewWithTag(106) as! UIButton
                btnUserName.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 16.0)
                let mgrPost = PostManager.postManager
                let strisLike:Int?=(self.arrayMediaItems.object(at: mgrPost.postTag) as AnyObject).value(forKey: "islike") as? Int
                let strlikeCount:Int=((self.arrayMediaItems.object(at: mgrPost.postTag) as AnyObject).value(forKey: "likecount")! as? Int)!
                let strUserName: String = (self.arrayMediaItems.object(at: mgrPost.postTag) as AnyObject).value(forKey: "username") as! String
                let isMyPost: Int = (self.arrayMediaItems.object(at: mgrPost.postTag) as AnyObject).value(forKey: "mypost") as! Int
                
                userImg.layer.cornerRadius = userImg.layer.frame.width / 2.0
                userImg.layer.masksToBounds = true
                
                let itmImgString = (self.arrayMediaItems.object(at: mgrPost.postTag) as AnyObject).value(forKey: "userphoto") as! String
                
                var imgurl: URL!
                if let imageURL = URL(string: itmImgString) {
                    imgurl = imageURL
                    userImg.sd_setImageWithPreviousCachedImage(with: imgurl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: { (img, error, type, url) -> Void in
                    })
                } else {
                    
                }
                
                btnlikecount.setTitle("\(strlikeCount)", for: UIControlState())
                
                if (strisLike == 0) {
                    btnlike.setImage(UIImage(named: "unlike"), for: UIControlState())
                } else {
                    btnlike.setImage(UIImage(named: "like"), for: UIControlState())
                }
                
                btnlike.addTarget(self, action: #selector(self.btnLikeClickedmedia(_:)), for: .touchUpInside)
                btnlikecount.addTarget(self, action: #selector(self.btntotalLikeClcikedmedia(_:)), for: .touchUpInside)
                if (shouldRefreshMedia) {
                    shouldRefreshMedia = false
                    if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a"||MediaType == "audio/mp3" || MediaType == "video/mp4") {
                        
                        let bundle = Bundle.main
                        let config = MobilePlayerConfig(fileURL: bundle.url(
                            forResource: "Skin",
                            withExtension: "json")!)
                        playerFullscreen = MobilePlayerViewController(
                            contentURL: videoUrl,
                            config: config)
                        print(videoUrl)
                        playerFullscreen.activityItems = [videoUrl]
                        
                        playerFullscreen.view.frame = (cell?.contentView.frame)!
                        playerFullscreen.view.frame.size.height = (cell?.contentView.frame.size.height)! - 43
                        playerFullscreen.fitVideo()
                        playerFullscreen.view.tag=1001
                        playerFullscreen.shouldAutoplay = true
                        
                        if let strtitle:String = mgrPost.PostText {
                            playerFullscreen.title = strtitle
                        }
                        if IsAddedPlayer == false {
                            cell?.contentView.addSubview(playerFullscreen.view)
                            IsAddedPlayer=true
                            playerFInal=playerFullscreen;
                        } else {
                            playerFullscreen.view.removeFromSuperview()
                            cell?.contentView.addSubview(playerFullscreen.view)
                            playerFInal=playerFullscreen;
                        }
                        playerFullscreen.play()
                        NotificationCenter.default.addObserver(self, selector: #selector(self.movieFinishedCallback(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object:nil)
                        
                    } else {
                        let player: UIView? = (cell?.contentView.viewWithTag(1001))
                        
                        if (player != nil) {
                            IsAddedPlayer = false
                            player!.removeFromSuperview()
                        }
                        
                        if((playerFullscreen) != nil) {
                            
                            if((playerFullscreen.view? .isDescendant(of: (cell?.contentView)!)) != nil) {
                                playerFullscreen.view.removeFromSuperview()
                            }
                        }
                        imgbg.sd_setImageWithPreviousCachedImage(with: videoUrl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: { (img, error, type, url) -> Void in
                        })
                        
                        cell?.contentView.bringSubview(toFront: imgbg)
                    }
                }
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openImage(_:)))
                imgbg.addGestureRecognizer(tapGesture)
                
                tapGesture.numberOfTapsRequired=1;
                
                let doubletapGesturedoubleTap = UITapGestureRecognizer(target: self, action: #selector(self.btnLikeClickedmedia(_:)))
                doubletapGesturedoubleTap.numberOfTapsRequired=2
                imgbg.addGestureRecognizer(doubletapGesturedoubleTap)
                
                tapGesture.require(toFail: doubletapGesturedoubleTap)
                
                if isMyPost == 1 {
                    btnComment.removeTarget(self, action: #selector(self.btnShareClicked(_:)), for: .touchUpInside)
                    btnComment.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnComment.setTitle("BOOST", for: UIControlState())
                    btnComment.setTitleColor(.white, for: .normal)
                    btnComment.addTarget(self, action: #selector(self.btnBoostClickedMedia(_:)), for: .touchUpInside)
                    
                    btnUserName.backgroundColor = .clear
                    btnUserName.setTitle(strUserName, for: UIControlState())
                    btnUserName.setTitleColor(colors.kLightgrey155, for: .normal)
                    
                    btnUserName.addTarget(self, action: #selector(self.btnMorePostClicked(_:)), for: .touchUpInside)
              
                } else {
                    btnComment.removeTarget(self, action: #selector(self.btnBoostClickedMedia(_:)), for: .touchUpInside)
                    btnComment.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnComment.setTitle("Share", for: UIControlState())
                    btnComment.setTitleColor(.white, for: .normal)
                    btnComment.addTarget(self, action: #selector(self.btnShareClicked(_:)), for: .touchUpInside)
                    
                    btnUserName.backgroundColor = .clear
                    btnUserName.setTitle(strUserName, for: UIControlState())
                    btnUserName.setTitleColor(colors.kLightgrey155, for: .normal)
                    
                    btnUserName.addTarget(self, action: #selector(self.btnMorePostClicked(_:)), for: .touchUpInside)
                    
                    //btnUserName.addTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                    
                    // btnUserName.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                }
                //btnComment.addTarget(self, action: #selector(self.btnMorePostClicked(_:)), for: .touchUpInside)
                return cell!
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                let CELL_ID = "shopCell"
                
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! shopCell!
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                
                if (isreloaditem == false ) {
                    isreloaditem=false
                    cell?.caroselShop.type = iCarouselType.linear
                    cell?.caroselShop.bounces = false
                    cell?.caroselShop.isPagingEnabled = false
                    cell?.caroselShop.delegate = self
                    cell?.caroselShop.strIdentifier="shop"
                    cell?.caroselShop.centerItemWhenSelected = true
                    icarouselItem=cell?.caroselShop;
                    
                    if DeviceType.IS_IPHONE_6 {
                        cell?.caroselShop.viewpointOffset=CGSize(width: 140, height: 0)
                    }
                    else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                        cell?.caroselShop.viewpointOffset=CGSize(width: 119, height: 0)
                    }
                    else if DeviceType.IS_IPHONE_6P {
                        cell?.caroselShop.viewpointOffset=CGSize(width: 155, height: 0)
                        
                    }
                    else if UI_USER_INTERFACE_IDIOM() == .pad{
                        cell?.caroselShop.viewpointOffset=CGSize(width: 285, height: 0)
                    }
                    if arrayShopItems.count>0 {
                        cell?.lblnofounddata.isHidden = true
                    } else {
                        cell?.lblnofounddata.isHidden = false
                    }
                    cell?.caroselShop.reloadData()
                }
                if scrollShopCarousel {
                    
                    cell?.caroselShop.scrollToItem(at: 0, animated: false)
                    scrollShopCarousel = false
                }
                return cell!
            } else {
                let CELL_ID = "shopPreviewCell"
                let mgrItm = ItemManager.itemManager
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as UITableViewCell!
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                let btnWatch: UIButton = cell!.contentView.viewWithTag(201) as! UIButton
                let btnItmName: UIButton = cell!.contentView.viewWithTag(202) as! UIButton
                let usrImgBtn: UIButton = cell!.contentView.viewWithTag(134) as! UIButton
                let userImg: UIImageView = cell!.contentView.viewWithTag(136) as! UIImageView
                let btnBuy: UIButton = cell!.contentView.viewWithTag(203) as! UIButton
                //btnWatch.titleLabel?.font = UIFont(name: "ProximaNova-Bold", size: 16.0)
                btnItmName.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 16.0)
                btnBuy.titleLabel?.font = UIFont(name: "ProximaNova-Regular", size: 16.0)
                let imgItm: UIImageView = cell!.contentView.viewWithTag(204) as! UIImageView
                
                userImg.layer.cornerRadius = userImg.layer.frame.width / 2.0
                userImg.layer.masksToBounds = true
                print(arrayShopItems)
                let itmImgString: String? = (self.arrayShopItems.object(at: mgrItm.itmTag) as AnyObject).value(forKey: "userphoto") as? String
                var imgurl: URL!
                if let urlExist = itmImgString as? String {
                    if let imageURL = URL(string: itmImgString!)  {
                        imgurl = imageURL
                        userImg.sd_setImageWithPreviousCachedImage(with: imgurl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: { (img, error, type, url) -> Void in
                        })
                    }
                }
                
                var imgURL: URL!
                if let imageURL = URL(string: mgrItm.ItemImg) {
                    imgURL = imageURL
                    imgItm.sd_setImageWithPreviousCachedImage(with: imgURL, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: { (img, error, type, url) -> Void in
                    })
                }
                imgItm.contentMode = .scaleAspectFill
                
                let imgSoldOut: UIImageView = cell!.contentView.viewWithTag(205) as! UIImageView
                let lblItmPrice: UILabel = cell!.contentView.viewWithTag(206) as! UILabel
                
                var newstr = String()
                newstr = String(describing: mgrItm.ItemPrice )
                let largeNumber = Float(newstr)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
                let FinalAmount = String(describing: formattedNumber!)
                
                lblItmPrice.backgroundColor = UIColor.black
                lblItmPrice.font = UIFont(name: "ProximaNova-Semibold", size: 10.0)
                lblItmPrice.textColor = UIColor.white
                
                lblItmPrice.text = "$ \(FinalAmount)"
                
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openImage(_:)))
                imgItm.addGestureRecognizer(tapGesture)
                
                tapGesture.numberOfTapsRequired=1;
                
                let doubletapGesturedoubleTap = UITapGestureRecognizer(target: self, action: #selector(self.btnLikeClickedmedia(_:)))
                doubletapGesturedoubleTap.numberOfTapsRequired=2
                imgItm.addGestureRecognizer(doubletapGesturedoubleTap)
                
                tapGesture.require(toFail: doubletapGesturedoubleTap)
                
                
                imgSoldOut.image = UIImage(named: "sold_out")
                imgSoldOut.contentMode = .scaleAspectFill
                if Int(mgrItm.isItemPurchase)! == 1 || Int(mgrItm.Itemmy)! == 1 {
                    btnWatch.isHidden = true
                    if Int(mgrItm.isItemPurchase)! == 1 {
                        imgSoldOut.isHidden = false
                    } else {
                        imgSoldOut.isHidden = true
                    }
                    if Int(mgrItm.Itemmy)! == 1 {
                         btnBuy.isHidden = false
                        btnBuy.setTitle("BOOST", for: .normal)
                        btnBuy.removeTarget(self, action: #selector(self.btnBuyClicked(_:)), for: .touchUpInside)
                        btnBuy.addTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                        btnBuy.isHidden = false
                    } else {
                        btnBuy.isHidden = true
                    }
                } else {
                    btnWatch.isHidden = false
                    if mgrItm.isWatch {
                        btnWatch.setImage(UIImage(named: "ico_watch"), for: UIControlState())
                        btnWatch.accessibilityIdentifier = "ico_watch"
                    } else {
                        btnWatch.setImage(UIImage(named: "ico_unwatch"), for: UIControlState())
                        btnWatch.accessibilityIdentifier = "ico_unwatch"
                        
                    }
                    btnBuy.isHidden = false
                    imgSoldOut.isHidden = true
                    btnBuy.setTitle("BUY", for: .normal)
                    
                    btnBuy.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    btnBuy.addTarget(self, action: #selector(self.btnBuyClicked(_:)), for: .touchUpInside)
                }
                btnWatch.addTarget(self, action: #selector(self.btnWatchClicked(_:)), for: .touchUpInside)
                btnItmName.setTitle(mgrItm.ItemName, for: UIControlState())
                btnItmName.addTarget(self, action: #selector(self.btnItmNameClicked(_:)), for: .touchUpInside)
                
                return cell!
            }
            
        }
        
        let CELL_ID = "streamCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! streamCell!
        
        if arrayStream.count > 0
        {
            cell?.lblnofounddata.isHidden = true
            
        } else {
            
            cell?.lblnofounddata.isHidden = false
            return cell!
        }
        
        cell?.selectionStyle = .none
        cell?.userNameBtn.addTarget(self, action: #selector(self.goToUserProfile(_:)), for: .touchUpInside)
        cell?.btnlikecount.addTarget(self, action: #selector(self.btntotalLikeCOuntClicked(_:)), for: .touchUpInside)
        cell?.btnLike.addTarget(self, action: #selector(self.btnLikeClicked(_:)), for: .touchUpInside)
        cell?.btnComment.addTarget(self, action: #selector(self.btnCommentClicked(_:)), for: .touchUpInside)
        cell?.btntalcomments.addTarget(self, action: #selector(self.btnTotalCOmmentClciked(_:)), for: .touchUpInside)
        cell?.btnMore.addTarget(self, action: #selector(self.btnMoreoptionClicked(_:)), for: .touchUpInside)
        cell?.btnMore.tag=indexPath.row
        
        cell?.userNameBtn.tag = indexPath.row
        cell?.btnLike.tag=indexPath.row
        cell?.btnLike.restorationIdentifier=String(indexPath.section)
        
        cell?.btnComment.tag=indexPath.row
        cell?.btnlikecount.tag=indexPath.row
        cell?.btntalcomments.tag=indexPath.row
        
        //        cell?.imguser.layer.borderWidth = 2
        //        cell?.imguser.layer.borderColor = UIColor.white.cgColor
        
        let strisLike:Int? = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "islike")! as? Int
        var strDescription:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "post_title")! as? String
        let strusername:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "username")! as? String
        let strimgname:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "userphotothumb")! as? String
        
        let strlikeCount:Int=((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "likecount")! as? Int)!
        
        let strcommentCOunt:Int=((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "commentcount")! as? Int)!
        var strtime:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "updated_date")! as? String
        
        strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo:strtime)
        
        if (strisLike == 0)
        {
            cell?.btnLike.setImage(UIImage(named: "unlike"), for: UIControlState())
        }
        else
        {
            cell?.btnLike.setImage(UIImage(named: "like"), for: UIControlState())
        }
        cell?.imguser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
        }, completed: { (img, error, type, url) -> Void in
        })
        cell?.layoutIfNeeded()
        cell?.imguser.contentMode=UIViewContentMode.scaleAspectFill
        
        cell?.lblName.text=strusername
        
        if (strusername == "" || strusername == nil)
        {
            cell?.lblName.text="\((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String) "  +  "\((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openImage(_:)))
        cell?.imguser.addGestureRecognizer(tapGesture)
        cell?.lbltime.text=strtime
        cell?.btntalcomments.setTitle("\(strcommentCOunt)", for: UIControlState())
        cell?.btnlikecount.setTitle("\(strlikeCount)", for: UIControlState())
        
        if (strDescription == nil)
        {
            strDescription = ""
        }
        
        cell?.lbldescription.urlLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
            self.attemptOpenURL(URL(string: string)!)
        }
        cell?.lbldescription.userHandleLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
            self.attemptOpenURL(URL(string: string)!)
        }
        cell?.lbldescription.hashtagLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
            self.attemptOpenURL(URL(string: string)!)
        }
        

        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                  NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
        
        let strDescAttribString = NSAttributedString(string: strDescription!, attributes: multipleAttributes)
        var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
        
        for emojiName in customEmojis.emojiItemsArray {
            objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
        }
        cell?.lbldescription.tag = indexPath.row
        
        // MARK: Not to tag functionality when user does not exist
        
        let post_oldtitle = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "post_oldtitle")! as? String
        let mystr = post_oldtitle
        let searchExcludeString = "@"
        let searchIncludeString = "@:@:"
        var rangesExcludeString: [NSRange]
        let rangesIncludeString: [NSRange]
        
        
        do {
            // Create the regular expression.
            var regex = try NSRegularExpression(pattern: searchExcludeString, options: [])
            
            
            // Use the regular expression to get an array of NSTextCheckingResult.
            // Use map to extract the range from each result.
            rangesExcludeString = regex.matches(in: mystr!, options: [], range: NSMakeRange(0, mystr!.characters.count)).map {$0.range}
            
            regex = try NSRegularExpression(pattern: searchIncludeString, options: [])
            rangesIncludeString = regex.matches(in: mystr!, options: [], range: NSMakeRange(0, mystr!.characters.count)).map {$0.range}
        }
        catch {
            // There was a problem creating the regular expression
            rangesExcludeString = []
            rangesIncludeString = []
        }
        let finalString = rangesExcludeString.filter {
            var returnValue = true
            for (_, range) in rangesIncludeString.enumerated() {
                if $0.location == range.location {
                    returnValue = false
                    break
                }
            }
            return returnValue
        }
        print(rangesExcludeString)
        print(rangesIncludeString)
        print(finalString)
        
        cell?.lbldescription.ignoredKeywords = ["@chetandodiya", "@vanrajmori"]
        //cell?.lbldescription.alignment = .center
        cell?.lbldescription.selectedLinkBackgroundColor = UIColor(hexString: "FD676C")
        cell?.lbldescription.userHandleLinkTapHandler = { label, handle, range in
            
            let strWithId = ((self.arrayStream.object(at: label.tag) as AnyObject) as AnyObject).value(forKey: "post_oldtitle")! as? String
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
            if ((self.arrayStream.object(at: label.tag) as AnyObject) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary == nil {
                var dictTags = NSDictionary()
                if let arrTags = (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSArray {
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
                                        let struser:String=(self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "username")! as! String
                                        let strimg:String=(self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "userphotothumb")! as! String
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
                    return
                }
                return
            }
            if (((self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary)?.count)! <= 0 {
                return
            }
            if ranges.count > 0 {
                if (label.text! as NSString).range(of: handle).location >= 0 {
                    if let ids = ((self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary)!.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                        let arrStr = ids.components(separatedBy: ",")
                        if arrStr.count > 0 {
                            let otherId = arrStr[arrStr.count-1]
                            let struser:String = (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "username")! as! String
                            let strimg:String = (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "userphotothumb")! as! String
                            let user = UserManager.userManager
                            let mgrfriend = FriendsManager.friendsManager
                            
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
        
        cell?.lbldescription.attributedText = mutableStrDesc
        //cell?.lbldescription.alignment = .center
        return cell!
    }
    
    func movieFinishedCallback(_ notif:Notification) {
        var userInfo:Dictionary<String,Int?>  = notif.userInfo as! Dictionary<String,Int?>
        let finishReason : Int = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]!!
        if ( finishReason == MPMovieFinishReason.playbackEnded.rawValue) {
            let moviePlayer:MPMoviePlayerController = notif.object as! MPMoviePlayerController
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: nil)
            self.PlayNext()
        }
    }
    
    func PlayNext() {
         var checkFlag = false
            for var i in (0..<arrayMediaItems.count) {
                if (self.arrayMediaItems.object(at: i) as AnyObject).value(forKey: "media_type")! as! String == MediaType {
                    let urlstring:String = ((self.arrayMediaItems.object(at: i) as AnyObject).value(forKey: "media_url"))! as! String
                    
                    if checkFlag {
                        let mgrItm = PostManager.postManager
                        shouldRefreshMedia = true
                        mgrItm.clearManager()
                        var  index = i
                        mgrItm.PostId="\(((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "id"))!)"
                        mgrItm.PostType = MediaType
                        mgrItm.PostImg = urlstring
                        mgrItm.postTag = index
                        if ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) is NSNull {
                            mgrItm.PostText = ""
                        } else {
                            if  let text = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                                let unfilteredString: String = text
                                let notAllowedChars = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
                                let resultString = (unfilteredString.components(separatedBy: notAllowedChars) as NSArray).componentsJoined(by: "")
                                if resultString == "" {
                                    
                                    if let post = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                                        print(post)
                                        if post != "" {
                                            let arr = post.components(separatedBy: "@@:-:@@")
                                            if arr.count>0 {
                                                mgrItm.PostText = arr[0]
                                            }
                                            if arr.count>1 {
                                                if let title = arr[1] as? String {
                                                    mgrItm.PostText = title
                                                }
                                            }
                                        }
                                        else {
                                            
                                        }
                                        
                                    }
                                } else {
                                    mgrItm.PostText = resultString
                                }
                            }
                        }
                        let strimg:String = (self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                        UserDefaults.standard.set(strimg, forKey: "mediaimg")
                        isPlayVideo = true
                        videoUrl = URL(string: urlstring)
                        selecteditemIndex = i
                        mgrItm.postTag   = i
                        
//                        let currentDevice: UIDevice = UIDevice.current
//                        let orientation: UIDeviceOrientation = currentDevice.orientation
//                        if orientation.isLandscape {
//                           // playVideoinlandscapemode()
//                        }
                        
                        tblDashboard.reloadData()
                        self.icarouselView.reloadData()
                        break
                    }
                    if selecteditemIndex ==  i {
                        print("i: \(i)")
                        videoUrl = URL(string: tempArrForNextPlay[0] as! String)
                        checkFlag = true
                    } else {
                    }
                } else {
                    
                }

        }
      
        
    //        self.tblDashboard.reloadData()
//        self.icarouselView.reloadData()
        
//
//        let bundle = Bundle.main
//        let config = MobilePlayerConfig(fileURL: bundle.url(
//            forResource: "Skin",
//            withExtension: "json")!)
//        playerFullscreen = MobilePlayerViewController(
//            contentURL: videoUrl,
//            config: config)
//        //        playerFullscreen.activityItems = [videoUrl]
//        playerFullscreen.shouldAutoplay = true
        playerFullscreen.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.movieFinishedCallback(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object:nil)
    }
    
    func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.current.orientation.isLandscape {
        } else {
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        print(indexPath.row)
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            if (indexPath.section==2) {
                
                if arrayStream.count == 0 {
                    
                } else {
                    let mgrfriend = FriendsManager.friendsManager
                    mgrfriend.clearManager()
                    
                    dictMy = self.arrayStream.object(at: indexPath.row) as? Dictionary<String, AnyObject>
                    
                    let mgrItm = PostManager.postManager
                    mgrItm.clearManager()
                    mgrItm.PostId="\(((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "id"))!)"
                    mgrItm.PostType = "0"
                    mgrItm.postTag = (indexPath.row)
                    let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
                    VC1.Posttype=0;
                    VC1.isViewComment=0;
                    VC1.delegate=self
                    
                    self.navigationController?.pushViewController(VC1, animated: true)
                }
                
            }
        }
    }
    
    //MARK: - scrollview delegates -
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (tblDashboard.contentOffset.y >= (tblDashboard.contentSize.height-tblDashboard.bounds.size.height) && !isBusyFetching) {
            print(arrayStream.count)
            print(totalStreamPost)
            if arrayStream.count < totalStreamPost {
                offsetSt += 1
                self.getStreamPost()
            }
        }
        guard let visibleIndexPaths = tblDashboard.indexPathsForVisibleRows else { return }
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
    
    
    
    
    
    // MARK: - sharemedia
    
    func sharemedia() {
        let textToShare = ""
        
        let mgrItm = PostManager.postManager
        
        let objectsToShare = [textToShare, mgrItm.PostImg]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - video play methods for landscape
    
    func playVideoinlandscape() {
        
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        if orientation.isPortrait {
            print(orientation.isPortrait)
            let ip = IndexPath.init(row:1, section: 0)
            let cell = tblDashboard.cellForRow(at: ip)
            
            playerFullscreen.view.backgroundColor = UIColor.red
            if(playerFullscreen.view.frame.height == self.view.frame.height) {
                UIApplication.shared.isStatusBarHidden = false
                if (cell != nil) {
                    let _: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
                    UIView.animate(withDuration: 0.50, animations:{
                        self.playerFullscreen.view.transform = CGAffineTransform.identity
                        self.playerFullscreen.view.center = cell!.contentView.center
                        self.playerFullscreen.view.frame=cell!.contentView.frame
                        self.playerFullscreen.view.frame.size.height = cell!.contentView.frame.size.height - 42
                        self.playerFullscreen.loadViewIfNeeded()
                        cell!.contentView.addSubview(self.playerFullscreen.view)
                    })
                }
            }
            self.orientationValue = false
        } else if orientation.isLandscape {
            
            UIApplication.shared.isStatusBarHidden = true
            UIView.animate(withDuration: 0.50, animations:{
                if orientation.rawValue == 4 {
                    if orientation.isLandscape == self.orientationValue {
                        self.playerFullscreen.view.frame.size.width=self.view.frame.size.width
                        self.playerFullscreen.view.frame.size.height=self.view.frame.size.height
                        
                    } else {
                        self.playerFullscreen.view.frame.size.width=self.view.frame.size.height
                        self.playerFullscreen.view.frame.size.height=self.view.frame.size.width
                    }
                    self.playerFullscreen.view.transform = CGAffineTransform(rotationAngle: -.pi/2)
                    self.playerFullscreen.view.center = self.view.center
                    self.playerFullscreen.fitVideo()
                    self.playerFullscreen.loadViewIfNeeded()
                    self.view.addSubview(self.playerFullscreen.view)
                    
                } else if orientation.rawValue == 3 {
                    if orientation.isLandscape == self.orientationValue {
                        self.playerFullscreen.view.frame.size.width=self.view.frame.size.width
                        self.playerFullscreen.view.frame.size.height=self.view.frame.size.height
                        
                    } else {
                        self.playerFullscreen.view.frame.size.width=self.view.frame.size.height
                        self.playerFullscreen.view.frame.size.height=self.view.frame.size.width
                    }
                    self.playerFullscreen.view.transform = CGAffineTransform(rotationAngle: .pi/2)
                    self.playerFullscreen.view.center = self.view.center
                    self.playerFullscreen.fitVideo()
                    self.playerFullscreen.loadViewIfNeeded()
                    // playerFullscreen.play()
                    self.view.addSubview(self.playerFullscreen.view)
                } else {
                }
            })
            self.orientationValue = true
        }
    }
    
    func playVideoinlandscapemode() {
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        UIApplication.shared.isStatusBarHidden = true
        UIView.animate(withDuration: 0.50, animations:{
            if orientation.rawValue == 4 {
                if  ( self.MediaType == "video/quicktime" || self.MediaType == "audio/m4a"||self.MediaType == "audio/mp3" || self.MediaType == "video/mp4") {
                    
                    let bundle = Bundle.main
                    let config = MobilePlayerConfig(fileURL: bundle.url(
                        forResource: "Skin",
                        withExtension: "json")!)
                    self.playerFullscreen = MobilePlayerViewController(
                        contentURL: self.videoUrl,
                        config: config)
                    print(self.videoUrl)
                    self.playerFullscreen.activityItems = [self.videoUrl]
                    self.playerFullscreen.shouldAutoplay = true
                    
                    if let strtitle:String = self.mgrPost.PostText {
                        self.playerFullscreen.title = strtitle
                    }
                    self.playerFInal=self.playerFullscreen;
                    self.playerFullscreen.play()
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.movieFinishedCallback(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object:nil)
                    
                }
                
                
                
            } else if orientation.rawValue == 3 {
                if  ( self.MediaType == "video/quicktime" || self.MediaType == "audio/m4a"||self.MediaType == "audio/mp3" || self.MediaType == "video/mp4") {
                    
                    let bundle = Bundle.main
                    let config = MobilePlayerConfig(fileURL: bundle.url(
                        forResource: "Skin",
                        withExtension: "json")!)
                    self.playerFullscreen = MobilePlayerViewController(
                        contentURL: self.videoUrl,
                        config: config)
                    print(self.videoUrl)
                    self.playerFullscreen.activityItems = [self.videoUrl]
                    self.playerFullscreen.shouldAutoplay = true
                    
                    if let strtitle:String = self.mgrPost.PostText {
                        self.playerFullscreen.title = strtitle
                    }
                    self.playerFInal=self.playerFullscreen;
                    self.playerFullscreen.play()
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(self.movieFinishedCallback(_:)), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object:nil)
                    
                }
            } else {
            }
        })
        //self.orientationValue = true
    }
    
    func stopVideo() {
        
        let ip = IndexPath.init(row:1, section: 0)
        let cell = tblDashboard.cellForRow(at: ip)
        if cell != nil
        {
            let _: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
            playerFullscreen.view.frame=cell!.contentView.frame
            cell!.contentView.addSubview(playerFullscreen.view)
            tblDashboard.reloadData()
        }
    }
    
    func PlayNextFile() {
        if tempArrForNextPlay.count > 0 {
        tempArrForNextPlay.removeAllObjects()
        }
        for var i in (0..<arrayMediaItems.count) {
            if (self.arrayMediaItems.object(at: i) as AnyObject).value(forKey: "media_type")! as! String == MediaType {
                let urlstring:String = ((self.arrayMediaItems.object(at: i) as AnyObject).value(forKey: "media_url"))! as! String
                if tempArrForNextPlay.contains(urlstring) {
                    
                } else {
                    tempArrForNextPlay.add(urlstring)
                }
            } else {
                
            }
        }
    }
    
    // MARK: --WebService Method
    
    func getDasboardActivity() {
         DispatchQueue.main.async {
            self.showDataUpdating()
        }
        
        if mainInstance.connected() {
            
            objAppDelegate.internetPopupDisplayed = false
            tblDashboard.isHidden = false;
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            let mgrPost = PostManager.postManager
            print(mgrPost.mediaType)
            print(mgrPost.privacyType)
            
            if mgrPost.mediaType == "5" {
                trendingType = "1"
            } else if mgrPost.privacyType == "3" {
                trendingType = "3"
            }  else if mgrItm.ItemCategoryID == "20" {
                strPrivacyType = "2"
                trendingType = "2"
            } else {
                trendingType = ""
            }
            let parameterss = NSMutableDictionary()
            parameterss.setValue(1, forKey: "offset")
            parameterss.setValue(limit, forKey: "limit")
            parameterss.setValue(usr.userId, forKey: "uid")
            parameterss.setValue(usr.userId, forKey: "myid")
            parameterss.setValue(strFilterType, forKey: "mediatype")
            parameterss.setValue(catID, forKey: "categoryid")
            parameterss.setValue(strPrivacyType, forKey: "userfiltertype")
            parameterss.setValue(strKeyword, forKey: "searchstring")
            parameterss.setValue(trendingType, forKey: "trending_mode")
            print(parameterss)
            SVProgressHUD.show(withStatus: "Fetching Activity", maskType: SVProgressHUDMaskType.clear)
            mgr.dashBoardAcitivity(parameterss, successClosure: { (dictMy, result) -> Void in
                SVProgressHUD.dismiss()
                
                
                print(dictMy!)
                self.tblDashboard.isHidden=false;
                
                if result == APIResult.apiSuccess {
                    
                    DispatchQueue.main.async {
                        self.showDataUpdated()
                    }
                    
                    let itemMgr = ItemManager.itemManager
                    itemMgr.loadEarlier = true
                    if let countMedia :  Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "mediapostcount") as? Int {
                        self.totalMediaCount = countMedia
                    }
                    if let countShop :  Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "itemcount") as? Int {
                        self.totalShopCount = countShop
                    }
                    if let countStream :  Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "streampostcount") as? Int {
                        self.totalStreamPost = countStream
                    }
                    
                    self.arrayShopItems = NSMutableArray(array: (dictMy!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemdetails") as! NSArray)
                    itemMgr.arrayShopItems = self.arrayShopItems
                    
                    
                    self.arrayStream = NSMutableArray(array: (dictMy!.value(forKey: "result")! as! NSDictionary).value(forKey: "streampost") as! NSArray)
                    itemMgr.arrayStream = self.arrayStream
                    
                    
                    self.arrayMediaItems = NSMutableArray(array: (dictMy!.value(forKey: "result")! as! NSDictionary).value(forKey: "mediapost") as! NSArray)
                    itemMgr.arrayMediaItems = self.arrayMediaItems
                    
                    
                    self.tblDashboard.reloadData()
                    if self.arrayMediaItems.count > 0 {
                        self.icarouselView.scrollToItem(at: 0, animated: true)
                    }
                    var emptyDic:[String : AnyObject] = [:]
                    
                    emptyDic["shop"] = self.arrayShopItems
                    emptyDic["media"] = self.arrayMediaItems
                    emptyDic["stream"] = self.arrayStream
                    if (!IS_IPAD) {
                        let manger = APIManager.apiManager
                        if manger.sessionToken != nil {
                            objAppDelegate.sendData(emptyDic)
                        }
                    }
                    SVProgressHUD.dismiss()
                } else if result == APIResult.apiError {
                    
                    print(dictMy!)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    
                    mainInstance.showSomethingWentWrong()
                }
            })
        } else {
            
            if objAppDelegate.internetPopupDisplayed == false {
                
                mainInstance.showNoInternetAlert()
                objAppDelegate.internetPopupDisplayed = true
            }
        }
    }
    
    func getShopItem() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offsetsh, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(usr.userId, forKey: "myid")
        parameterss.setValue(catID, forKey: "categoryid")
        parameterss.setValue(strPrivacyType, forKey: "userfiltertype")
        parameterss.setValue(trendingType, forKey: "trending_mode")
        print(parameterss)
        SVProgressHUD.show()
        mgr.dashBoardItems(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic!)
            
            if result == APIResult.apiSuccess {
                
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int {
                    self.totalShopCount = countShop
                }
                
                if self.offsetsh == 1 {
                    self.arrayShopItems.removeAllObjects()
                    
                    self.arrayShopItems = (NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "items") as! NSArray))
                } else {
                    
                    let array:NSArray! = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "items") as! NSArray
                    if (array.count>0)
                    {
                        let mutArray = NSMutableArray(array: (dic!.value(forKey: "result")! as AnyObject).value(forKey: "items")! as! [AnyObject])
                        
                        self.arrayShopItems.addObjects(from: mutArray.mutableCopy() as! [AnyObject])
                    }
                }
                self.tblDashboard.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                if mainInstance.connected() == false {
                    mainInstance.showNoInternetAlert()
                    
                } else {
                    
                    
                    (dic!)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                }
            } else {
                
                SVProgressHUD.dismiss()
                if self.internetConnected == false {
                    
                } else if mainInstance.connected() == false && self.internetConnected == true {
                    mainInstance.showNoInternetAlert()
                    self.internetConnected = false
                } else {
                    mainInstance.showSomethingWentWrong()
                }
            }
        })
    }
    
    func getMediaItem() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        
        parameterss.setValue(self.offsetMe, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(usr.userId, forKey: "myid")
        parameterss.setValue("1", forKey: "posttype")
        parameterss.setValue(strFilterType, forKey: "mediatype")
        parameterss.setValue(strPrivacyType, forKey: "userfiltertype")
        parameterss.setValue(strKeyword, forKey: "searchstring")
        parameterss.setValue(trendingType, forKey: "trending_mode")
        print(parameterss)
        SVProgressHUD.show()
        mgr.dashBoardMedia(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            //UIApplication.shared.endIgnoringInteractionEvents()
            
            if result == APIResult.apiSuccess {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalmedia") as? Int {
                    self.totalMediaCount = countShop
                }
                if self.offsetMe == 1 {
                    self.arrayMediaItems.removeAllObjects()
                    self.PlayNextFile()
                    self.arrayMediaItems = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts")) as! NSArray).mutableCopy() as! NSMutableArray
                    
                } else {
                    self.arrayMediaItems.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as? NSArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblDashboard.reloadData()
                self.icarouselView.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                
            } else {
                SVProgressHUD.dismiss()
                if self.internetConnected == false {
                    
                } else if mainInstance.connected() == false && self.internetConnected == true {
                    mainInstance.showNoInternetAlert()
                    self.internetConnected = false
                } else {
                    mainInstance.showSomethingWentWrong()
                }
            }
        })
    }
    
    func getStreamPost() {
        isBusyFetching = true
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offsetSt, forKey: "offset")
        parameterss.setValue(10, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue("0", forKey: "posttype")
        parameterss.setValue(usr.userId, forKey: "myid")
        parameterss.setValue(strPrivacyType, forKey: "userfiltertype")
        parameterss.setValue(strKeyword, forKey: "searchstring")
        parameterss.setValue(trendingType, forKey: "trending_mode")
        SVProgressHUD.show()
        print(parameterss)
        mgr.dashBoardStream(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            self.isBusyFetching=false
            if result == APIResult.apiSuccess {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int {
                    self.totalStreamPost = countShop
                }
                if self.offsetSt == 1 {
                    self.arrayStream.removeAllObjects()
                    self.arrayStream = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray))
                } else {
                    if (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray).count>0) {
                        self.arrayStream.addObjects(from: NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray)) as! [Any])
                    }
                }
                self.tblDashboard.reloadData()
                SVProgressHUD.dismiss()
            }
            else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                if self.internetConnected == false {
                    
                } else if mainInstance.connected() == false && self.internetConnected == true {
                    mainInstance.showNoInternetAlert()
                    self.internetConnected = false
                } else {
                    mainInstance.showSomethingWentWrong()
                }
            }
        })
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
            if result == APIResult.apiSuccess {
                
            } else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    
    //MARK: - play video  -
    
    
    func playVideo() {
        
        let urlS  = Bundle.main.path(forResource: "shutterstock_v530524 (Converted)", ofType: "mp4")
        let url =  URL.init(fileURLWithPath:urlS!, isDirectory: false)
        player = AVPlayer.init(playerItem: AVPlayerItem.init(url:url))
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = self.view!.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view!.layer  .addSublayer(playerLayer)
        player.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:player.currentItem)
        player.play()
    }
    
    func playerItemDidReachEnd(_ notification:Notification)  {
        
        player.pause()
        playerLayer.removeFromSuperlayer()
        
    }
    
    
    func attemptOpenURL(_ url: URL) {
        let webView: UIWebView! = UIWebView()
        webView.loadRequest(URLRequest(url: url))
        let mywebViewController = UIViewController()
        mywebViewController.view = webView
        let navController = UINavigationController(rootViewController: mywebViewController)
        mywebViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: "dismiss")
        self.navigationController!.present(navController, animated: true, completion: nil)

    }
    
    //MARK: - Open Image VIewer  -
    
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
    
    //MARK: - get all  -
    func getImgArray(_ imgName: String, totalImages: Int) -> [UIImage] {
        
        var imgArray: [UIImage] = []
        var number = 1
        while number <= totalImages {
            imgArray.append(UIImage(named: "\(imgName)-\(number)")!)
            number += 1
        }
        return imgArray
    }
    func getAllIndexes(_ section : Int) -> [IndexPath] {
        
        var indexes = [IndexPath]()
        // assuming that tableView is your self.tableView defined somewhere
        
        for j in 0...tblDashboard.numberOfRows(inSection: section)-1
        {
            
            let index = IndexPath(row: j, section: section)
            indexes.append(index)
            
        }
        return indexes
    }
    
    
    func navigatetoRelvantPushScreen() {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
            if let info = objAppDelegate.dicUserInfopush!["aps"] as? Dictionary<String, AnyObject> {
                let strType = ("\(info["ntype"]! as! NSNumber)")
                let detailID = ("\(info["detailid"]! as! NSNumber)")
                
                let usr = UserManager.userManager
                if usr.userId != nil {
                    //navig
                    if (Int(strType) == notifiType.pLike.rawValue || Int(strType) == notifiType.pComment.rawValue)
                    {//other_user_id
                        
                        let strsubType =  ("\(info["posttype"]! as! NSNumber)")
                        
                        let mgrItm = PostManager.postManager
                        mgrItm.clearManager()
                        
                        
                        let objpost: PostDetailsVC = objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsVC
                        
                        mgrItm.PostId = detailID
                        if strsubType == "0" {
                            
                            objpost.Posttype=0;
                        } else {
                            
                            objpost.Posttype=2;
                        }
                        self.navigationController!.pushViewController(objpost, animated: true)
                    }
                    else if Int(strType) == notifiType.cntrequest.rawValue {
                        
                        let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=1;
                        self.navigationController!.pushViewController(objfriends, animated: true)
                    } else if Int(strType) == notifiType.cntaccept.rawValue {
                        
                        let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=2;
                        self.navigationController!.pushViewController(objfriends, animated: true)
                    } else if Int(strType) == notifiType.pItem.rawValue {
                        
                        let mgrItm = ItemManager.itemManager
                        mgrItm.clearManager()
                        mgrItm.ItemId = detailID
                        
                        let objitm: ItemDetails = objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails") as! ItemDetails
                        self.navigationController!.pushViewController(objitm, animated: true)
                    }
                    objAppDelegate.dicUserInfopush=nil
                }
            }
        }
    }
    
    func getadminData() {
        
        let mgradmin = AdminManager.adminManager
        
        mgradmin.getAdminDetails { (dic:NSDictionary?, result:APIResultAdm) -> Void in
            
            if (result == APIResultAdm.apiSuccess) {
                
                mgradmin.bitcoincID=dic?.value(forKeyPath: "result.bitcoin_api") as! String
                mgradmin.bitcoincSecret=dic?.value(forKeyPath: "result.bitcoin_secret") as! String
                mgradmin.bitcoinemail=dic?.value(forKeyPath: "result.bitcoin_acc") as! String
                mgradmin.paypalcID=dic?.value(forKeyPath: "result.paypal_api") as! String
                mgradmin.paypalcSecret=dic?.value(forKeyPath: "result.paypal_secret") as! String
                mgradmin.cutpercentage=dic?.value(forKeyPath: "result.percentage") as! String
                
                PayPalMobile .initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "YOUR_CLIENT_ID_FOR_PRODUCTION",
                                                                        PayPalEnvironmentSandbox: "AYuIo-X4PK27s5RernB7kkIKAhsqjI3IsnX3B-Zp9utG3LH3IaIY4Swqz5si23ErYjRXGe2OC_zukrrd"])
            }
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UISearchBar delegate methods

extension HomeScreen: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        if (searchBar.text?.characters.count)! > 0 {
            strKeyword = searchBar.text!
            getDasboardActivity()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let player = playerFInal {
            player.stop()
        }
        
        searchBar.showsCancelButton = true
        
        var strMsg = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
         var lengthStr = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if strMsg.characters.last == "\n" {
            strMsg = String(strMsg.characters.dropLast())
        }
        strKeyword = strMsg
        
        if strMsg.characters.count == 0 {
            strKeyword = ""
        }
        
        if lengthStr.characters.count >= 3 {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getDasboardActivity), object: nil)
        perform(#selector(getDasboardActivity), with: nil, afterDelay: 0.5)
        }
        
        if ExpandType == Expand.exPfull.rawValue {
            if selecteditemIndex != -1 {
                objAppDelegate.fullScreenVideoIsPlaying=false
                tblDashboard.beginUpdates()
                ExpandType=1;
                let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
                selecteditemIndex = -1
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            strKeyword = ""
            getDasboardActivity()
        }
        
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}



// MARK: iCarousel delegate & datasource methods

extension HomeScreen: iCarouselDelegate, iCarouselDataSource {
    func numberOfItems (in carousel : iCarousel) -> NSInteger {
        if carousel.tag == 1001 {
            if self.arrayMediaItems.count > 0
            {
                return self.arrayMediaItems.count
            }
        } else {
            if self.arrayShopItems.count > 0
            {
                return self.arrayShopItems.count
            }
        }
        return 0
    }
    
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var view = view
        
        var imgPic : UIImageView
        var imgicon : UIImageView
        var imgSoldOut: UIImageView
        var lblItmPrice: UILabel
        
        if view == nil {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4.3, height: carousel.frame.size.width/4.3)
            
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            imgPic.contentMode=UIViewContentMode.scaleAspectFill
            
            imgSoldOut = UIImageView()
            imgSoldOut.frame =  CGRect(x: 0, y: 0, width: view!.frame.width - 10, height: view!.frame.height)
            imgSoldOut.clipsToBounds = true
            imgSoldOut.contentMode=UIViewContentMode.scaleToFill
            imgSoldOut.layer.masksToBounds = true
            
            imgicon = UIImageView(frame: CGRect(x: (view?.frame.size.width)! / 2 - 16, y: (view?.frame.size.height)! / 2 - 16, width: 32, height: 32))
            imgicon.contentMode = .scaleAspectFill
            lblItmPrice = UILabel()
            
            lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 20, width: (view?.frame.width)! + 10 , height: 15.0)
            
            if  UIDevice.current.userInterfaceIdiom == .pad {
                lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 40, width: (view?.frame.width)! + 10 , height: 20.0)
            }
            
            
            lblItmPrice.backgroundColor = UIColor(hexString: "000000", alpha: 0.5)
            lblItmPrice.font = UIFont(name: "ProximaNova-Semibold", size: 10.0)
            lblItmPrice.textColor = UIColor.white
            lblItmPrice.textAlignment = .center
            
            imgicon.tag = 101
            imgPic.tag = 105
            imgSoldOut.tag = 109
            lblItmPrice.tag = 110
            
            view?.addSubview(imgPic)
            view?.addSubview(imgicon)
            view?.addSubview(imgSoldOut)
            view?.addSubview(lblItmPrice)
        } else {
            imgicon = view?.viewWithTag(101) as! UIImageView
            imgPic = view?.viewWithTag(105) as! UIImageView
            imgSoldOut = view?.viewWithTag(109) as! UIImageView
            lblItmPrice = view?.viewWithTag(110) as! UILabel
        }
        
        imgicon.image=UIImage(named: "vdic")
        imgSoldOut.image = UIImage(named: "sold_out")
        imgSoldOut.isHidden = true
        if carousel.tag==1001 {
            lblItmPrice.isHidden = false
            
            let strmediatype:Int=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "posttype")! as! Int
            if strmediatype == 3 || strmediatype == 4  {
                imgicon.isHidden=false;
                
                if (strmediatype == 3)  {
                    print(self.arrayMediaItems.object(at: index))
                    imgicon.image=UIImage(named: "ico_microphone")
                }   else  {
                    print(self.arrayMediaItems.object(at: index))
                    imgicon.image=UIImage(named: "auic")
                }
                
                let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
                })
                
            } else if strmediatype == 1 {
                imgicon.isHidden=false;
                
                imgicon.image=UIImage(named: "vdic")
                let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
                })
            } else  {
                imgicon.isHidden=true
                
                let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: {
                    (a, b , url) -> Void in
                }, completed: {
                    (img, error, type, url) -> Void in
                    if img != nil {
                        
                    } else {
                        print(strimg)
                        
                    }
                    
                })
                
            }
            lblItmPrice.text = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String
            
            
            if  let text = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                let unfilteredString: String = text
                let notAllowedChars = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
                let resultString = (unfilteredString.components(separatedBy: notAllowedChars) as NSArray).componentsJoined(by: "")
                if resultString == "" {
                    
                    if let post = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                        print(post)
                        if post != "" {
                            let arr = post.components(separatedBy: "@@:-:@@")
                            if arr.count>1 {
                                if let title = arr[1] as? String {
                                    lblItmPrice.text = title
                                }
                            }
                        }
                        else {
                            lblItmPrice.isHidden = true
                        }
                        
                    }
                } else {
                    lblItmPrice.text = resultString
                }
                
            } else {
                lblItmPrice.isHidden = true
            }
                     if index==selecteditemIndex {
                view?.layer.borderWidth = 2.0
                view?.layer.borderColor = colors.klightgreyfont.cgColor
            }
            imgPic.layer.masksToBounds = true
            imgicon.contentMode = .scaleAspectFill
        } else {
            lblItmPrice.isHidden = false
            
            var newstr = String()
            newstr = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_price")!)
            let largeNumber = Float(newstr)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
            let FinalAmount = String(describing: formattedNumber!)
            
            lblItmPrice.text = "$ \(FinalAmount)"
            let strimg:String=(self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
            })
            
            if (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "ispurchased") as? Int == 1 {
                imgSoldOut.isHidden = false
            }
            view?.layer.borderColor = colors.klightgreyfont.cgColor
            view?.layer.borderWidth = 1.0
            view?.layer.masksToBounds = true
            
            imgicon.isHidden=true
        }
        
        view!.backgroundColor = UIColor.clear
        
        view?.layer.masksToBounds = true
        imgPic.layer.masksToBounds = true
        imgSoldOut.layer.masksToBounds = true
        
        if index==selecteditemIndex && carousel.strIdentifier=="buffet" {
            view?.layer.borderWidth = 2.0
            view?.layer.borderColor = colors.klightgreyfont.cgColor
        } else {
            view?.layer.borderColor = UIColor.white.cgColor
            view?.layer.borderWidth = 0.0
        }
        return view
    }
    
    
    
    func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
        return icarouselView.frame.size.width/4.3
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.07
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
        
        isPlayVideo = false
        objAppDelegate.fullScreenVideoIsPlaying = false
        
        if carousel.tag == 1001 {
            
            item_id = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "id"))! as? Int
            boost_type = 2
            shouldRefreshMedia = true
            let urlstring:String = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_url"))! as! String
            MediaType = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_type"))! as! String
            
            let mgrItm = PostManager.postManager
            mgrItm.clearManager()
            mgrItm.PostId="\(((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "id"))!)"
            mgrItm.PostType = MediaType
            mgrItm.PostImg = urlstring
            mgrItm.postTag = index
            if ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) is NSNull {
                mgrItm.PostText = ""
            } else {
                if  let text = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                    let unfilteredString: String = text
                    let notAllowedChars = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
                    let resultString = (unfilteredString.components(separatedBy: notAllowedChars) as NSArray).componentsJoined(by: "")
                    if resultString == "" {
                        
                        if let post = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                            print(post)
                            if post != "" {
                                let arr = post.components(separatedBy: "@@:-:@@")
                                if arr.count>0 {
                                    mgrItm.PostText = arr[0]
                                }
                                if arr.count>1 {
                                    if let title = arr[1] as? String {
                                        mgrItm.PostText = title
                                    }
                                }
                            }
                            else {
                                
                            }
                            
                        }
                    } else {
                        mgrItm.PostText = resultString
                    }
                    
                }
             
            
            }
            
            if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a" || MediaType == "audio/mp3" || MediaType == "video/mp4") {
                if (MediaType == "audio/m4a" || MediaType == "audio/mp3") {
                    UserDefaults.standard.set("y", forKey: "isoverlay")
                } else {
                    UserDefaults.standard.set("n", forKey: "isoverlay")
                }
                let strimg:String = (self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                UserDefaults.standard.set(strimg, forKey: "mediaimg")
                isPlayVideo = true
                objAppDelegate.fullScreenVideoIsPlaying = true
            }
            
            videoUrl = URL(string: urlstring)
            
            PlayNextFile()
            if ExpandType == Expand.exPfull.rawValue {
                if (selecteditemIndex == index) {
                    objAppDelegate.fullScreenVideoIsPlaying = false
                    tblDashboard.beginUpdates()
                    ExpandType = 1
                    let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                    tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                    tblDashboard.endUpdates()
                    selecteditemIndex = -1
                } else {
                    selecteditemIndex = index
                    tblDashboard.reloadData()
                }
            } else {
                ExpandType = 2
                tblDashboard.beginUpdates()
                let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
                selecteditemIndex = index
            }
            icarouselView.reloadData()
        } else {
            
            item_id = ((self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_id"))! as? Int
            boost_type = 1
            let mgrItm = ItemManager.itemManager
            let mgrFriend = FriendsManager.friendsManager
            
            
            
            mgrItm.clearManager()
            
            mgrFriend.FriendID = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_created_by")!)
            mgrFriend.FUsername = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "ispurchased")!)
            
            mgrItm.itmTag = index
            mgrItm.ItemId = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_id")!)
            mgrItm.Itembitcoinmail = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "bitcoinmail")!)
            mgrItm.isItemPurchase = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "ispurchased")!)
            mgrItm.ItemactualPrice = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_actualprice")!)
            let stringLength = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_name")!)
            
            if stringLength.characters.count > 24 {
                let index = stringLength.index(stringLength.startIndex, offsetBy: 20)
                mgrItm.ItemName = stringLength.substring(to: index)
            } else {
                mgrItm.ItemName = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_name")!)
            }
            
            let myString: NSString = stringLength as NSString
            let size: CGSize = myString.size(attributes: [NSFontAttributeName: UIFont(name: "ProximaNova-Regular", size: 16.0)])
            
            
            mgrItm.ItemPrice = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_price")!)
            mgrItm.itm_qty = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_qty")!)
            mgrItm.itm_qty_remain = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_qty_remained")!)
            mgrItm.ItemShipingCost = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_shipping_cost")!)
            mgrItm.ItemImg = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "media_url")!)
            mgrItm.Itemtype = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "media_type")!)
            mgrItm.Itemmy = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "myitem")!)
            let watched = (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "iswatched") as? String
            if watched == "1" {
                mgrItm.isWatch = true
            } else {
                mgrItm.isWatch = false
            }
            
            let isbitcoin:String = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "isbitcoin")!)
            let ispaypal:String = String(describing: (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "ispaypal")!)
            
            if (isbitcoin == "1" && ispaypal == "1" ) {
                
                mgrItm.ispaymentKind="3"
            } else if (isbitcoin == "1") {
                
                mgrItm.ispaymentKind="2"
            } else if (ispaypal == "1") {
                
                mgrItm.ispaymentKind="1"
            } else {
                
                mgrItm.ispaymentKind="0"
            }
            
            if self.Expandshop == Expand.exPfull.rawValue {
                if self.selectedShopItmIndex == index {
                    self.Expandshop = 1
                    self.tblDashboard.beginUpdates()
                    let paths: [IndexPath] = [IndexPath(row: 1, section: 1)]
                    self.tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                    self.tblDashboard.endUpdates()
                    self.selectedShopItmIndex = -1
                } else {
                    self.selectedShopItmIndex = index
                    self.tblDashboard.reloadData()
                }
                
            } else {
                self.Expandshop=2;
                self.tblDashboard.beginUpdates()
                let paths: [IndexPath] = [IndexPath(row: 1, section: 1)]
                self.tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
                self.tblDashboard.endUpdates()
                self.selectedShopItmIndex = index
            }
            self.icarouselView.reloadData()
        }
    }
    
    
    
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel!) {
        
        print(carousel.currentItemIndex)
        if( carousel.currentItemIndex == self.arrayShopItems.count-2 && self.arrayShopItems.count>0  && carousel.tag==1002 && self.totalShopCount > self.arrayShopItems.count) {
            offsetsh += 1
            self.getShopItem()
        } else if( carousel.currentItemIndex == self.arrayMediaItems.count-2 && self.arrayMediaItems.count>0  && carousel.tag==1001 && self.totalMediaCount > self.arrayMediaItems.count) {
            //UIApplication.shared.beginIgnoringInteractionEvents()
            offsetMe += 1
            print("offset :",offsetMe)
            self.getMediaItem()
        }
    }
}

// MARK: PostMediaActionDelegate

extension HomeScreen: PostmediaActionDelegate {
    func postmediaData() {
        if self.arrayMediaItems.count > 0 {
            self.icarouselView.scrollToItem(at: 0, animated: true)
        }
        offsetMe = 1
        getMediaItem()
    }
}

// MARK: PostMediaViaPostDetailDelegate

extension HomeScreen: PostMediaViaPostDetailDelegate {
    func actionOnPostMediaViaPostDetail() {
        if self.arrayMediaItems.count > 0 {
            self.icarouselView.scrollToItem(at: 0, animated: true)
        }
        offsetMe = 1
        getMediaItem()
    }
}

// MARK: PostplainActionDelegate

extension HomeScreen: PostplainActionDelegate {
    func postData() {
        offsetSt=1
        getStreamPost()
    }
}

// MARK: Edit item delegate

extension HomeScreen: ItemeditActionDelegate {
    func actionOnDataItem() {
        offsetsh=1
        getShopItem()
    }
}

// MARK: Add item delegate

extension HomeScreen: AddItemDelgate {
    func actionOnaddItemData()  {
        offsetsh=1
        getShopItem()
    }
}

// MARK: Comment action delegate

extension HomeScreen: commentActionDelegate {
    
    func actionOnData() {
        offsetSt=1
        getStreamPost()
    }
    
    func actionOnpostData() {
        offsetMe=1;
        getDasboardActivity()
    }
    
    func btnLikeClickedmedia(_ sender: UIButton) {
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        }else {
            let mgrpost = PostManager.postManager
            
            var dic :NSMutableDictionary?
            
            let mutDict = NSMutableDictionary(dictionary: self.arrayMediaItems.object(at: mgrpost.postTag) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;
            
            var likeCount:Int=((self.arrayMediaItems.object(at: mgrpost.postTag) as AnyObject).value(forKey: "likecount")! as? Int)!
            
            if ((dic?.value(forKey: "islike"))! as! Int == 0) {
                dic?.setValue(1, forKey: "islike");
                likeaction = 0
                likeCount += 1
                dic?.setValue(likeCount, forKey: "likecount");
                self.arrayMediaItems.replaceObject(at: mgrpost.postTag!, with: dic!)
                tblDashboard.reloadData()
                postlikeMethod()
            } else {
                
                likeaction = 1
                likeCount -= 1
                dic?.setValue(likeCount, forKey: "likecount");
                dic?.setValue(0, forKey: "islike");
                self.arrayMediaItems.replaceObject(at: mgrpost.postTag!, with: dic!)
                tblDashboard.reloadData()
                postlikeMethod()
            }
        }
    }
}

// MARK: HomescreenFilterDelegate

extension HomeScreen: Homescreenfilter {
    func actionFIlterData(_ filterType: String) {
        
        if filterType == "media" {
            popoverController.dismissPopover(animated: true)
            isFilter = true
            offsetMe = 1
            strFilterType = mgrPost.mediaType
            getDasboardActivity()
            if ExpandType == Expand.exPfull.rawValue {
                
                if selecteditemIndex != -1 {
                    
                    objAppDelegate.fullScreenVideoIsPlaying = false
                    tblDashboard.beginUpdates()
                    ExpandType = 1
                    let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                    tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                    tblDashboard.endUpdates()
                    selecteditemIndex = -1
                }
            }
        } else if filterType == "stream" {
            popoverController.dismissPopover(animated: true)
            offsetSt = 1
            strPrivacyType = mgrPost.privacyType
            if strPrivacyType == "2" {
                isPrivacyFilter = false
            } else {
                isPrivacyFilter = true
            }
            getDasboardActivity()
        }
    }
}

// MARK: ItemWatchDelegate

extension HomeScreen: ItemWatchDelegate {
    func actionOnWatch(isWatch: Bool, index: Int) {
        
        let objShopItm = NSMutableDictionary(dictionary: self.arrayShopItems.object(at: index) as! NSDictionary)
        
        if isWatch {
            objShopItm.setValue("1", forKey: "iswatched")
            self.arrayShopItems.replaceObject(at: mgrItm.itmTag, with: objShopItm)
        } else {
            objShopItm.setValue("0", forKey: "iswatched")
            self.arrayShopItems.replaceObject(at: mgrItm.itmTag, with: objShopItm)
        }
    }
}

// MARK: CategorySelectDelegate

extension HomeScreen: CategorySelectDelegate {
    func actionOnFilterCategory(_ reloadData: Bool) {
        let mgrItm = ItemManager.itemManager
        popoverController.dismissPopover(animated: true)
        
        scrollShopCarousel = true
        
        if mgrItm.ItemCategoryID.characters.count > 0  {
            catID = Int(mgrItm.ItemCategoryID)!
        }
        if mgrItm.ItemCategoryID == ""  {
            catID = 0
        }
        if catID != 0 {
            isShopFilter = true
        } else {
            isShopFilter = false
        }
        
        offsetsh = 1
        getDasboardActivity()
        
        if Expandshop == Expand.exPfull.rawValue {
            
            if selecteditemIndex != -1 {
                
                tblDashboard.beginUpdates()
                Expandshop = 1
                let paths: [IndexPath] = [IndexPath(row: 1, section: 1)]
                tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
                selectedShopItmIndex = -1
            }
        }
    }
}

extension String {
    
    func NSRangeFromRange(_ range : Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = String.UTF16View.Index(range.lowerBound, within: utf16view)
        let to = String.UTF16View.Index(range.upperBound, within: utf16view)
        return NSMakeRange(utf16view.startIndex.distance(to: from), from!.distance(to: to))
    }
}

extension HomeScreen: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let  tblLocaion :CGPoint = self.view.convert(location, to: self.tblDashboard)
        guard let indexPath = self.tblDashboard.indexPathForRow(at: tblLocaion) else { return nil }
        
        if (indexPath.section == 0 /*&& indexPath.row == 1*/){
            guard let cell =  self.tblDashboard.cellForRow(at: indexPath) as? buffetCell else { return nil }
            let cellPoint = self.tblDashboard.convert(tblLocaion, to: cell)
            
            let p = cell.convert(cellPoint, to:cell.caroselBufeet)
            
            guard let cview = cell.caroselBufeet.itemView(at: p) else{
                return nil
            }
            let index = cell.caroselBufeet.index(ofItemView: cview)
            
            let mgrItm = PostManager.postManager
            mgrItm.clearManager()
            mgrItm.PostId="\(((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "id"))!)"
            mgrItm.PostType = MediaType
            mgrItm.PostImg = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_url"))! as! String
            mgrItm.postTag = index
            MediaType = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_type"))! as! String
            if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a" || MediaType == "audio/mp3" || MediaType == "video/mp4") {
                
                if (MediaType == "audio/m4a" || MediaType == "audio/mp3") {
                    UserDefaults.standard.set("y", forKey: "isoverlay")
                } else {
                    UserDefaults.standard.set("n", forKey: "isoverlay")
                }
                let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                
                UserDefaults.standard.set(strimg, forKey: "mediaimg")
            }
            
            if ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) is NSNull {
                
                mgrItm.PostText = ""
            } else {
                if let post = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                    let arr = post.components(separatedBy: "@@:-:@@")
                    if arr.count>0 {
                        mgrItm.PostText = arr[0]
                    }
                }
            }
            
            guard let VC1 = (objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as? PostDetailsVC else {
                return nil
            }
            VC1.delegate=self
            VC1.Posttype=2;
            VC1.isViewComment=1;
            VC1.preferredContentSize = CGSize(width: 0.0, height: 0.0)
            return VC1
            
        }
        else if(indexPath.section == 1) {
            guard let cell =  self.tblDashboard.cellForRow(at: indexPath) as? shopCell else {
                return nil
            }
            let cellPoint = self.tblDashboard.convert(tblLocaion, to: cell)
            let p = cell.convert(cellPoint, to:cell.caroselShop)
            
            guard let cview = cell.caroselShop.itemView(at: p) else{
                return nil
            }
            let index = cell.caroselShop.index(ofItemView: cview)
            
            
            let mgrItm = ItemManager.itemManager
            mgrItm.clearManager()
            
            if let itmID: Int  = (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
            VC1.delegate=self
            VC1.preferredContentSize = CGSize(width: 0.0, height: 0.0)
            return VC1
        } else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController){
        show(viewControllerToCommit, sender: self)
    }
    
    
}


