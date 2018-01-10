//
//  World.swift
//  ScreamXO
//
//  Created by Ronak Barot on 27/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
//import MobilePlayer

class World: UIViewController ,iCarouselDataSource,iCarouselDelegate ,commentActionDelegate,ItemeditActionDelegate,PostplainActionDelegate,PostmediaActionDelegate,AddItemDelgate,WYPopoverControllerDelegate,Homescreenfilter {
    
    enum Expand : NSInteger {
        case expDelete = 0,exPhalf,exPfull
    }
    var icarouselView: iCarousel!
    var icarouselItem: iCarousel!
    
    @IBOutlet weak var searchMusic: UISearchBar!
    var selecteditemIndex:NSInteger?
    var ExpandType :Int!
    var BuffetSession :Int!
    var Expandshop :Int!
    var Expandstream :Int!
    var isreloadbuffet :Bool!
    var isreloaditem :Bool!
    
    var isBusyFetching : Bool = false
    
    // for expand collapse check
    
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
    var strKeyword:String! = ""
    
    var playerFInal:MobilePlayerViewController!
    var playerFullscreen:MobilePlayerViewController!
    let mgrPost = PostManager.postManager
    var orientationValue = false
    var videoUrl:URL!
    
    @IBOutlet weak var tblDashboard: UITableView!
    @IBOutlet var btnFilter: UIButton!
    
    var popoverController: WYPopoverController!
    
    // MARK: - life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        searchMusic.barTintColor = UIColor.clear
        searchMusic.backgroundColor = UIColor.white
        searchMusic.backgroundImage = UIImage()
        searchMusic.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        if constant.onWorldFilter == false {
            btnFilter.isHidden = true
        } else {
            btnFilter.isHidden = false
        }
        searchMusic.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        searchMusic.returnKeyType = .done
        getadminData()
        ExpandType=1;
        Expandshop=1;
        Expandstream=1;
        isreloaditem=false
        isreloadbuffet=false
        tblDashboard.estimatedRowHeight = 145
        tblDashboard.rowHeight = UITableViewAutomaticDimension
        tblDashboard.reloadData()
        let mgr = PostManager.postManager
        mgr.clearManager()
        getWorldActivity()
        if( traitCollection.forceTouchCapability == .available){
            
            registerForPreviewing(with: self, sourceView:self.view)
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        if (!(objAppDelegate.dicUserInfopush == nil))
        {
            navigatetoRelvantPushScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let emptyDic:[String : AnyObject] = [:]
        if (!IS_IPAD) {
            objAppDelegate.sendData(emptyDic)
            
        }
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.playVideoinlandscapemode), name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(self.playVideoinlandscape), name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.stopVideo), name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.btnLikeClickedmedia(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)
        
        self.tblDashboard.reloadData()
        
        // gsm ops
        
        if constant.btnObj1.buttonsIsShown() {
            constant.btnObj1.onTap()
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
        
        if ExpandType == Expand.exPfull.rawValue
        {
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
        
        // gsm ops
        
        if constant.btnObj1.buttonsIsShown() {
            constant.btnObj1.onTap()
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

    
    
    // MARK: - custom button methods
    
    
    @IBAction func btnFiltersortClicked(_ sender: AnyObject) {
        
        if ((popoverController) != nil)
        {
            
            popoverController.dismissPopover(animated: true)
            
            
        }
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "FilterHome")) as! FilterHome
        VC1.mediaType = strFilterType
        VC1.isTable = "media"
        VC1.delegate=self
        popoverController = WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self;
        popoverController.popoverContentSize=CGSize(width: 150, height: 200)
        popoverController.presentPopover(from: sender.bounds, in: sender as! UIView, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        
    }
    
    func btntotalLikeCOuntClicked(_ sender: UIButton) {
        
        
        let mgrpost = PostManager.postManager
        mgrpost.clearManager()
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    func btnLikeClickedmedia(_ sender: UIButton) {
        
        
        let mgrpost = PostManager.postManager
        
        var dic :NSMutableDictionary?
        
        let mutDict = NSMutableDictionary(dictionary: self.arrayMediaItems.object(at: mgrpost.postTag) as! [AnyHashable: Any])
        dic = mutDict.mutableCopy() as? NSMutableDictionary;
        
        
        
        var likeCount:Int=((self.arrayMediaItems.object(at: mgrpost.postTag) as AnyObject).value(forKey: "likecount")! as? Int)!
        
        if ((dic?.value(forKey: "islike"))! as! Int == 0)
        {
            dic?.setValue(1, forKey: "islike");
            likeaction = 0
            likeCount += 1
            dic?.setValue(likeCount, forKey: "likecount");
            self.arrayMediaItems.replaceObject(at: mgrpost.postTag!, with: dic!)
            tblDashboard.reloadData()
            postlikeMethod()
            
            
        }
        else
        {
            likeaction = 1
            likeCount -= 1
            dic?.setValue(likeCount, forKey: "likecount");
            dic?.setValue(0, forKey: "islike");
            self.arrayMediaItems.replaceObject(at: mgrpost.postTag!, with: dic!)
            tblDashboard.reloadData()
            postlikeMethod()
            
        }
        
    }
    
    func btntotalLikeClcikedmedia(_ sender: UIButton) {
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    func btnLikeClicked(_ sender: UIButton) {
        
        var likeCount:Int=((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "likecount")! as? Int)!
        
        let mgrpost = PostManager.postManager
        mgrpost.clearManager()
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        var dic :NSMutableDictionary?
        let index = Int(sender.restorationIdentifier!)
        
        let mutDict = NSMutableDictionary(dictionary: self.arrayStream.object(at: sender.tag) as! [AnyHashable: Any])
        dic = mutDict.mutableCopy() as? NSMutableDictionary;
        
        
        if ((dic?.value(forKey: "islike"))! as! Int == 0) {
            dic?.setValue(1, forKey: "islike");
            likeaction = 0
            likeCount += 1
            dic?.setValue(likeCount, forKey: "likecount");
            self.arrayStream.replaceObject(at: sender.tag, with: dic!)
            tblDashboard.reloadData()
            postlikeMethod()
            
            
        }
        else
        {
            likeaction = 1
            likeCount -= 1
            dic?.setValue(likeCount, forKey: "likecount");
            dic?.setValue(0, forKey: "islike");
            self.arrayStream.replaceObject(at: sender.tag, with: dic!)
            tblDashboard.reloadData()
            postlikeMethod()
        }
    }
    
    func btnCommentClicked(_ sender: UIButton) {
        
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
    func btnTotalCOmmentClciked(_ sender: UIButton) {
        
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
    
    func btnMoreoptionClicked(_ sender: UIButton) {
        let mgrpost = PostManager.postManager
        
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        
        
        if let mypost :  Int = (self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "mypost") as? Int
        {
            
            mgrpost.PostismyPost = "\(mypost)"
            
            
        }
        
        
        let strshare : String
        strshare = (self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "post_title") as! String
        
        
        
        let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let Delete = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            
            mgrpost.PostTypecheck="0"
            
            mgrpost.deletepost({ (dic, result) -> Void in
                if result == APIResultpost.apiSuccess
                {
                    
                    print("tag:: %d",(sender.tag))
                    if self.arrayStream.count > sender.tag {
                        self.arrayStream.removeObject(at: sender.tag)
                    }
                    self.tblDashboard.reloadData()
                    
                }
                
            })
            
            
            
            
        }
        
        
        let share = UIAlertAction(title: "Share", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            let textToShare = ""
            
            
            let objectsToShare = [textToShare, strshare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            let button = sender
            if (IS_IPAD)
            {
                
                activityVC.popoverPresentationController!.sourceRect = button.bounds;
                activityVC.popoverPresentationController!.sourceView = button;
                
            }
            
            self.present(activityVC, animated: true, completion: nil)
            
            
            
        }
        let report = UIAlertAction(title: "Report Post", style: UIAlertActionStyle.default)
        {
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
        }
        else {
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
        
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
        VC1.delegate=self
        VC1.Posttype=2;
        if sender.tag == 102 {
            VC1.isViewComment = 0
        } else {
            VC1.isViewComment = 1
        }
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    @IBAction func btnMenucClicked(_ sender: AnyObject) {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    func btnexpandBuffetClicked(_ sender: UIButton) {
        
        var paths:[IndexPath]!
        tblDashboard.beginUpdates()
        
        if ExpandType==Expand.exPfull.rawValue {
            
            isBuffetExpand = false
            BuffetSession=ExpandType;
            paths = [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)]
            ExpandType=0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        } else if ExpandType==Expand.exPhalf.rawValue {
            isBuffetExpand = false
            
            BuffetSession=ExpandType;
            paths = [IndexPath(row: 0, section: 0)]
            ExpandType=0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        } else {
            ExpandType = BuffetSession
            
            if BuffetSession==Expand.exPfull.rawValue {
                
                paths = [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)]
                
            } else {
                paths = [IndexPath(row: 0, section: 0)]
                
            }
            isBuffetExpand = true
            
            tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        }
        
        if (isBuffetExpand) {
            sender.setImage(UIImage(named: "dpic"), for: UIControlState())
        } else {
            sender.setImage(UIImage(named: "upic"), for: UIControlState())
        }
    }
    
    func btnexpandshopClicked(_ sender: UIButton) {
        
        var paths:[IndexPath]!
        tblDashboard.beginUpdates()
        if Expandshop==Expand.exPhalf.rawValue {
            isShopExpand = false
            
            paths = [IndexPath(row: 0, section: 1)]
            Expandshop=0
            tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        } else {
            
            Expandshop=1;
            isShopExpand = true
            paths = [IndexPath(row: 0, section: 1)]
            tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
            tblDashboard.endUpdates()
        }
        
        if (isShopExpand) {
            sender.setImage(UIImage(named: "dpic"), for: UIControlState())
        } else {
            sender.setImage(UIImage(named: "upic"), for: UIControlState())
        }
    }
    func btnexpandstreamClicked(_ sender: UIButton) {
        
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
                Expandstream = 1
                isStreamExpand = true
                
                tblDashboard.insertRows(at: pathsStore, with: UITableViewRowAnimation.fade)
                tblDashboard.endUpdates()
            }
            
            if (isStreamExpand) {
                sender.setImage(UIImage(named: "dpic"), for: UIControlState())
            } else {
                sender.setImage(UIImage(named: "upic"), for: UIControlState())
            }
        }
        
    }
    
    func btnMediaCollapseClicked(_ sender: UIButton) {
        
        var paths:[IndexPath]!
        tblDashboard.beginUpdates()
        paths = [IndexPath(row: 1, section: 0)]
        ExpandType=1
        tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
        tblDashboard.endUpdates()
    }
    func btnAddMediaPost(_ sender: UIButton) {
        
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePost_Media")) as! CreatePost_Media
        VC1.delegate=self
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    func btnAddItem(_ sender: UIButton) {
        
        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN")) as! SellItemVC
        
        VC1.delegate=self
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    func btnAddTextPost(_ sender: UIButton) {
        
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePostVC")) as! CreatePostVC
        
        VC1.delegate=self
        
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    
    func btnUserProfileClicked() {
        
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
    
    func btnBoostClicked(_ sender: UIButton) {
        let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
        
        self.navigationController?.pushViewController(boostViewController, animated: true)
    }
    
    // MARK: --action delgate Method
    
    
    func actionFIlterData(_ filterType: String) {
        if self.ExpandType == Expand.exPfull.rawValue {
            if self.selecteditemIndex != -1 {
                objAppDelegate.fullScreenVideoIsPlaying=false
                self.tblDashboard.beginUpdates()
                self.ExpandType=1;
                let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                self.tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                self.tblDashboard.endUpdates()
                self.selecteditemIndex = -1
            }
        }
        popoverController.dismissPopover(animated: true)
        offsetMe = 1
        strFilterType = mgrPost.mediaType
        
        if strFilterType != "" {
            btnFilter.layer.borderWidth=0.5
            btnFilter.layer.borderColor=UIColor.lightGray.cgColor
        } else {
            btnFilter.layer.borderWidth=0.0
            btnFilter.layer.borderColor=UIColor.clear.cgColor
        }
        getWorldActivity()
    }
    
    func actionOnData() {
        offsetSt=1
        getStreamPost()
    }
    func actionOnpostData() {
        offsetMe=1;
        getWorldActivity()
    }
    func actionOnaddItemData() {
        offsetsh=1
        //getShopItem()
    }
    
    func actionOnDataItem() {
        offsetsh=1
    }
    func postData() {
        offsetSt=1
        getStreamPost()
    }
    
    func postmediaData() {
        offsetMe=1
        getMediaItem()
    }
    
    // MARK: GSM Method
    
    func btnGSMClicked(_ btnIndex: Int) {
    
        switch btnIndex {
        case 7:
            constant.onWorldFilter = !constant.onWorldFilter
            if constant.onWorldFilter {
                btnFilter.isHidden = false
            } else {
                btnFilter.isHidden = true
            }
        default:
            break
        }
    }
    
    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 2
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
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if section==0
        {
            if ExpandType == Expand.exPfull.rawValue
            {
                return 2
                
                
            }
            else if ExpandType == Expand.exPhalf.rawValue
            {
                return 1
            }
            return 0
        }
            
        else if section==1
        {
            
            if Expandstream == Expand.expDelete.rawValue
            {
                return 0
            }
            if arrayStream.count == 0 {
                return 1
            }
            else
            {
                return arrayStream.count
            }
        }
        
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section==0 {
            if indexPath.row==0 {
                let CELL_ID = "BuffetCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! buffetCell
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.clear
                
                if (isreloadbuffet == false) {
                    isreloadbuffet=false
                    cell.caroselBufeet.type = iCarouselType.linear
                    cell.caroselBufeet.bounces = false
                    cell.caroselBufeet.isPagingEnabled = false
                    cell.caroselBufeet.delegate = self
                    cell.caroselBufeet.strIdentifier="buffet"
                    cell.caroselBufeet.dataSource = self
                    if arrayMediaItems.count>0 {
                        
                        cell.lblnofounddata.isHidden = true
                        
                    } else {
                        
                        cell.lblnofounddata.isHidden = false
                    }
                    icarouselView=cell.caroselBufeet
                    
                    if DeviceType.IS_IPHONE_6 {
                        cell.caroselBufeet.viewpointOffset=CGSize(width: 140, height: 0)
                        
                    }
                    else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                        cell.caroselBufeet.viewpointOffset=CGSize(width: 119, height: 0)
                        
                    }
                    else if DeviceType.IS_IPHONE_6P {
                        cell.caroselBufeet.viewpointOffset=CGSize(width: 155, height: 0)
                        
                    }
                    else if UI_USER_INTERFACE_IDIOM() == .pad{
                        
                        cell.caroselBufeet.viewpointOffset=CGSize(width: 285, height: 0)
                    }
                    
                    cell.caroselBufeet.reloadData()
                    
                }
                
                return cell
            } else {
                let CELL_ID = "MediaCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
                cell.selectionStyle = .none
                cell.backgroundColor = UIColor.clear
                let btnMore: UIButton = cell.contentView.viewWithTag(102) as! UIButton
                let imgbg: UIImageView = cell.contentView.viewWithTag(101) as! UIImageView
                let btnlike: UIButton = cell.contentView.viewWithTag(104) as! UIButton
                let btnlikecount: UIButton = cell.contentView.viewWithTag(105) as! UIButton
                let btnUserName: UIButton = cell.contentView.viewWithTag(106) as! UIButton
                
                let mgrItm = PostManager.postManager
                let strisLike:Int?=(self.arrayMediaItems.object(at: mgrItm.postTag) as AnyObject).value(forKey: "islike") as? Int
                let strlikeCount:Int=((self.arrayMediaItems.object(at: mgrItm.postTag) as AnyObject).value(forKey: "likecount")! as? Int)!
                let strUserName: String = (self.arrayMediaItems.object(at: mgrItm.postTag) as AnyObject).value(forKey: "username") as! String
                let isMyPost: Int = (self.arrayMediaItems.object(at: mgrPost.postTag) as AnyObject).value(forKey: "mypost") as! Int

                
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
                        playerFullscreen = MobilePlayerViewController(contentURL: videoUrl, config: config)
                        playerFullscreen.activityItems = [videoUrl]
                        
                        playerFullscreen.view.frame=cell.contentView.frame
                        playerFullscreen.view.frame.size.height = cell.contentView.frame.size.height - 35
                        
                        playerFullscreen.fitVideo()
                        playerFullscreen.view.tag=1001
                        playerFullscreen.shouldAutoplay=true
                        
                        if let strtitle:String = mgrItm.PostText {
                        playerFullscreen.title = strtitle
                        }
                        
                        if IsAddedPlayer == false {
                            cell.contentView.addSubview(playerFullscreen.view)
                            IsAddedPlayer=true
                            playerFInal=playerFullscreen;
                        } else {
                            playerFullscreen.view.removeFromSuperview()
                            cell.contentView.addSubview(playerFullscreen.view)
                            playerFInal=playerFullscreen;
                        }
                        playerFullscreen.play()
                    } else {
                        
                        let player: UIView? = (cell.contentView.viewWithTag(1001))
                        
                        if (player != nil) {
                            IsAddedPlayer = false
                            player!.removeFromSuperview()
                        }
                        
                        if((playerFullscreen) != nil) {
                            if((playerFullscreen.view? .isDescendant(of: cell.contentView)) != nil) {
                                playerFullscreen.view.removeFromSuperview()
                            }
                        }
                        imgbg.sd_setImageWithPreviousCachedImage(with: videoUrl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a,b,url) -> Void in
                        }, completed: {(img, error, type, url) -> Void in
                        })
                        cell.contentView.bringSubview(toFront: imgbg)
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
                    btnUserName.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnUserName.setTitle("BOOST", for: UIControlState())
                    btnUserName.sizeToFit()
                    btnUserName.setTitleColor(.white, for: .normal)
                    btnUserName.removeTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                    btnUserName.addTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                } else {
                    btnUserName.backgroundColor = .clear
                    btnUserName.setTitle(strUserName, for: UIControlState())
                    btnUserName.setTitleColor(colors.kLightgrey155, for: .normal)
                    btnUserName.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    btnUserName.addTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                }
                
                btnMore.addTarget(self, action: #selector(self.btnMorePostClicked(_:)), for: .touchUpInside)
                return cell
            }
        }
        let CELL_ID = "streamCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! streamCell
        
        if arrayStream.count > 0 {
            cell.lblnofounddata.isHidden = true
        } else {
            cell.lblnofounddata.isHidden = false
            return cell
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.btnlikecount.addTarget(self, action: #selector(self.btntotalLikeCOuntClicked(_:)), for: .touchUpInside)
        cell.btnLike.addTarget(self, action: #selector(self.btnLikeClicked(_:)), for: .touchUpInside)
        cell.btnComment.addTarget(self, action: #selector(self.btnCommentClicked(_:)), for: .touchUpInside)
        cell.btntalcomments.addTarget(self, action: #selector(self.btnTotalCOmmentClciked(_:)), for: .touchUpInside)
        cell.btnMore.addTarget(self, action: #selector(self.btnMoreoptionClicked(_:)), for: .touchUpInside)
        cell.btnMore.tag=indexPath.row
        
        cell.btnLike.tag=indexPath.row
        cell.btnLike.restorationIdentifier=String(indexPath.section)
        
        cell.btnComment.tag=indexPath.row
        cell.btnlikecount.tag=indexPath.row
        cell.btntalcomments.tag=indexPath.row
        
        let strisLike:Int?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "islike")! as? Int
        var strDescription:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "post_title")! as? String
        let strusername:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "username")! as? String
        let strimgname:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "userphotothumb")! as? String
        
        let strlikeCount:Int=((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "likecount")! as? Int)!
        
        let strcommentCOunt:Int=((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "commentcount")! as? Int)!
        var strtime:String?=(self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "updated_date")! as? String
        
        
        strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
        
        
        if (strisLike == 0) {
            cell.btnLike.setImage(UIImage(named: "unlike"), for: UIControlState())
        } else {
            cell.btnLike.setImage(UIImage(named: "like"), for: UIControlState())
        }
        cell.imguser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a,b,url) -> Void in
        }, completed: {(img, error, type, url) -> Void in
        })
        
        cell.imguser.contentMode=UIViewContentMode.scaleAspectFill
        cell.imguser.layer.cornerRadius = cell.imguser.frame.size.height / 2
        cell.imguser.layer.masksToBounds = true
        cell.lblName.text=strusername
        
        if (strusername == "" || strusername == nil) {
            cell.lblName.text="\((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String) "  +  "\((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.openImage(_:)))
        cell.imguser.addGestureRecognizer(tapGesture)
        cell.lbltime.text=strtime
        cell.btntalcomments.setTitle("\(strcommentCOunt)", for: UIControlState())
        cell.btnlikecount.setTitle("\(strlikeCount)", for: UIControlState())
        
        if (strDescription==nil) {
            
            strDescription = ""
        }
        
        if let strDesc:String = strDescription {
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                      NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
            
            let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
            var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
            
            for emojiName in customEmojis.emojiItemsArray {
                objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
            }
            
            print(strDescription ?? "nil")
            cell.lbldescription.tag = indexPath.row
            cell.lbldescription.userHandleLinkTapHandler = { label, handle, range in
                let strWithId = (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_oldtitle")! as? String
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
                if (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary == nil {
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
            cell.lbldescription.attributedText = mutableStrDesc
        }
        return cell
    }
        func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
        {
            
            if (indexPath.section == 1)
            {
                
                let mgrfriend = FriendsManager.friendsManager
                mgrfriend.clearManager()
                
                var dictMy: Dictionary<String, AnyObject>?
                
                dictMy = self.arrayStream.object(at: indexPath.row) as? Dictionary<String, AnyObject>
                
                if let uID: Int  = (dictMy!["userid"]! as? Int)!
                {
                    print(uID)
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
        
        
        //MARK: - scrollview delegates -
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            
            if (tblDashboard.contentOffset.y >= (tblDashboard.contentSize.height-tblDashboard.bounds.size.height) && !isBusyFetching) {
                if arrayStream.count < totalStreamPost {
                    offsetSt += 1
                    self.getStreamPost()
                }
            }
        }
        // MARK: - sharemedia
        
        
        func sharemedia()
        {      let textToShare = ""
            
            let mgrItm = PostManager.postManager
            
            let objectsToShare = [textToShare, mgrItm.PostImg]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            if (IS_IPAD)
            {
                
            }
            
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
                        self.playerFullscreen.view.frame.size.height = cell!.contentView.frame.size.height - 35
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
                    // playerFullscreen.play()
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
        playerFullscreen.view.backgroundColor = UIColor.red
        if(playerFullscreen.view.frame.height == self.view.frame.height) {
            UIApplication.shared.isStatusBarHidden = false
            let ip = IndexPath.init(row:1, section: 0)
            let cell = tblDashboard.cellForRow(at: ip)
            
            if (cell != nil) {
                let _: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
                UIView.animate(withDuration: 0.25, animations:{
                    self.playerFullscreen.view.transform = CGAffineTransform.identity
                    self.playerFullscreen.view.center = cell!.contentView.center
                    self.playerFullscreen.view.frame=cell!.contentView.frame
                    self.playerFullscreen.view.frame.size.height = cell!.contentView.frame.size.height - 35
                    cell!.contentView.addSubview(self.playerFullscreen.view)
                })
            }
            
        } else {
            UIApplication.shared.isStatusBarHidden = true
            UIView.animate(withDuration: 0.25, animations:{
                self.playerFullscreen.view.frame.size.width=self.view.frame.size.height
                self.playerFullscreen.view.frame.size.height=self.view.frame.size.width
                self.playerFullscreen.view.transform = CGAffineTransform(rotationAngle: .pi/2)
                self.playerFullscreen.view.center = self.view.center
                self.playerFullscreen.fitVideo()
                self.playerFullscreen.loadViewIfNeeded()
                // playerFullscreen.play()
                self.view.addSubview(self.playerFullscreen.view)
            })
        }
    }

    
    
        func stopVideo()
        {
            
            if (isPlayVideo == true)
            {
                //playerFullscreen.view.removeFromSuperview()
                
            }
            
            
            let ip = IndexPath.init(row:1, section: 0)
            let cell = tblDashboard.cellForRow(at: ip)
            
            if (cell == nil)
            {
                
            }
            else
            {
                
                
                let imgbg: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
                
                playerFullscreen.view.frame = imgbg.frame
                cell!.contentView.addSubview(playerFullscreen.view)
                
                
                //let indexPath = NSIndexPath(forRow: 1, inSection: 0)
                // tblDashboard.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Top)
                tblDashboard.reloadData()
                
            }
            
            
            
        }
        
        //MARK: - iCarousel methods -
        func numberOfItems (in carousel : iCarousel) -> NSInteger
        {
            if carousel.tag == 1001
            {
                if self.arrayMediaItems.count > 0
                {
                    return self.arrayMediaItems.count
                }
            }
            else
            {
                
                if self.arrayShopItems.count > 0
                {
                    return self.arrayShopItems.count
                    
                }
            }
            
            return 0
        }
        func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
            var view = view
            
            //    let contentView : UIView?
            var imgPic : UIImageView
            var imgicon : UIImageView
            
            if view == nil
            {
                view = UIView()
                view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4.3, height: carousel.frame.size.width/4.3)
                
                imgPic = UIImageView()
                imgPic.frame = view!.frame
                imgPic.clipsToBounds = true
                imgPic.contentMode=UIViewContentMode.scaleAspectFill
                imgicon = UIImageView(frame: CGRect(x: (view?.frame.size.width)! / 2 - 16, y: (view?.frame.size.height)! / 2 - 16, width: 32, height: 32))
                imgicon.contentMode = .scaleAspectFill
                imgicon.tag = 101
                imgPic.tag = 105
                
                view?.addSubview(imgPic)
                view?.addSubview(imgicon)
                
                
            }
            else
            {
                //get a reference to the label in the recycled view
                //imgConnection = view.viewWithTag(105) as! UIImageView
                imgicon = view?.viewWithTag(101) as! UIImageView
                imgPic = view?.viewWithTag(105) as! UIImageView
                
            }
            // print(view.subviews)
            
            
            
            imgicon.image=UIImage(named: "vdic")
            
            
            if carousel.tag==1001
            {
                
                let strmediatype:Int=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "posttype")! as! Int
                
                if strmediatype == 3 || strmediatype == 4
                {
                    imgicon.isHidden=false;
                    
                    var Strnameimg : String!
                    if (strmediatype == 3)
                    {
                        Strnameimg = "micro_S"
                        imgicon.image=UIImage(named: "ico_microphone")
                        
                    }
                    else
                    {
                        Strnameimg = "audsc"
                        imgicon.image=UIImage(named: "auic")
                        
                        
                    }
                    
                    let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                    imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a,b,url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                    })
                    
                    
                }
                else if   strmediatype == 1
                {
                    imgicon.isHidden=false;
                    
                    imgicon.image = UIImage(named: "vdic")
                    let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                    imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a,b,url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                    })
                }
                else
                {
                    imgicon.isHidden=true
                    let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                    imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a,b,url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                    })
                }
                
                view!.backgroundColor = UIColor.white
                
                if index==selecteditemIndex
                {
                    
                    view?.layer.borderWidth = 2.0
                    view?.layer.borderColor = colors.klightgreyfont.cgColor
                    
                    
                }
                imgPic.layer.masksToBounds = true
                imgicon.contentMode = .scaleAspectFit
                
                
            }
            else
            {
                
                let strimg:String=(self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a,b,url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
                })
                
                view!.backgroundColor = UIColor.white
                view?.layer.borderColor = colors.klightgreyfont.cgColor
                view?.layer.borderWidth = 1.0
                view?.layer.masksToBounds = true
                imgicon.isHidden=true;
            }
            imgPic.contentMode=UIViewContentMode.scaleAspectFill
            
            view!.backgroundColor = UIColor.clear
            
            view?.layer.masksToBounds = true
            imgPic.layer.masksToBounds = true
            
            if index==selecteditemIndex && carousel.strIdentifier=="buffet"
            {
                view?.layer.borderWidth = 2.0
                view?.layer.borderColor = colors.klightgreyfont.cgColor
            }
            else
            {
                view?.layer.borderColor = UIColor.white.cgColor
                view?.layer.borderWidth = 0.0
                
            }
            return view
        }
        func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
            return icarouselView.frame.size.width/4.3
        }
        func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
        {
            if (option == .spacing)
            {
                return value * 1.07
            }
            
            
            return value
        }
        
        func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
            
            isPlayVideo=false
            objAppDelegate.fullScreenVideoIsPlaying=false
            
            if carousel.tag==1001 {
                
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
                    if let post = ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
                        let arr = post.components(separatedBy: "@@:-:@@")
                        if arr.count>0 {
                            mgrItm.PostText = arr[0]
                        }
                    }
                }
                
                let _:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_type")! as! String
                
                if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a" || MediaType == "audio/mp3" || MediaType == "video/mp4") {
                    
                    if (MediaType == "audio/m4a" || MediaType == "audio/mp3") {
                        UserDefaults.standard.set("y", forKey: "isoverlay")
                        
                    } else {
                        UserDefaults.standard.set("n", forKey: "isoverlay")
                    }
                    let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                    
                    UserDefaults.standard.set(strimg, forKey: "mediaimg")
                    isPlayVideo = true
                    objAppDelegate.fullScreenVideoIsPlaying=true
                    
                    
                } else {
                    if let player = playerFInal {
                        player.stop()
                    }
                }
                
                videoUrl = URL(string: urlstring)
                
                if ExpandType == Expand.exPfull.rawValue {
                    
                    if (selecteditemIndex==index) {
                        objAppDelegate.fullScreenVideoIsPlaying=false
                        
                        tblDashboard.beginUpdates()
                        ExpandType=1;
                        let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                        tblDashboard.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                        tblDashboard.endUpdates()
                        selecteditemIndex = -1
                    } else {
                        selecteditemIndex = index
                        tblDashboard.reloadData()
                    }
                    
                } else {
                    
                    ExpandType=2;
                    tblDashboard.beginUpdates()
                    let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                    tblDashboard.insertRows(at: paths, with: UITableViewRowAnimation.fade)
                    tblDashboard.endUpdates()
                    selecteditemIndex = index
                }
                icarouselView.reloadData()
            }
            else {
                
                let mgrItm = ItemManager.itemManager
                mgrItm.clearManager()
                
                if let itmID: Int  = (self.arrayShopItems.object(at: index) as AnyObject).value(forKey: "item_id") as? Int {
                    mgrItm.ItemId = "\(itmID)"
                }
                let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
                VC1.delegate=self
                self.navigationController?.pushViewController(VC1, animated: true)
            }
        }
        
        func carouselCurrentItemIndexDidChange(_ carousel: iCarousel!) {
            
            if( carousel.currentItemIndex == self.arrayMediaItems.count-2 && self.arrayMediaItems.count>0  && carousel.tag==1001 && self.totalMediaCount > self.arrayMediaItems.count) {
                
                UIApplication.shared.beginIgnoringInteractionEvents()
                offsetMe += 1
                print("offset :",offsetMe)
                self.getMediaItem()
            }
        }
        
        // MARK: --WebService Method
        
        func getWorldActivity() {
            
            tblDashboard.isHidden=true;
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            let parameterss = NSMutableDictionary()
            parameterss.setValue(1, forKey: "offset")
            parameterss.setValue(limit, forKey: "limit")
            parameterss.setValue(usr.userId, forKey: "uid")
            parameterss.setValue(usr.userId, forKey: "myid")
            parameterss.setValue(strKeyword, forKey: "searchstring")
            parameterss.setValue(strFilterType, forKey: "mediatype")
            
            print(parameterss)
            
            SVProgressHUD.show(withStatus: "Fetching Activity", maskType: SVProgressHUDMaskType.clear)
            
            mgr.worldAcitivity(parameterss, successClosure: { (dic, result) -> Void in
                print(parameterss)
                SVProgressHUD.dismiss()
                self.tblDashboard.isHidden=false;
                
                if result == APIResult.apiSuccess {
                    
                    if let countMedia :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "mediapostcount") as? Int {
                        self.totalMediaCount = countMedia
                    }
                    
                    if let countStream :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "streampostcount") as? Int {
                        self.totalStreamPost = countStream
                    }
                    
                    self.offsetMe = 1
                    self.offsetSt = 1
                    
                    self.arrayStream.removeAllObjects()
                    
                    self.arrayStream = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "streampost") as? NSArray)!)
                
                    self.arrayMediaItems.removeAllObjects()
                    
                    self.arrayMediaItems = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "mediapost") as? NSArray)!)
                
                    
                    self.tblDashboard.reloadData()
                    self.tblDashboard.scrollsToTop = true
                    
                    var emptyDic:[String : AnyObject] = [:]
                    
                    emptyDic["shop"] = self.arrayShopItems
                    emptyDic["media"] = self.arrayMediaItems
                    emptyDic["stream"] = self.arrayStream
                    if (!IS_IPAD) {
                        objAppDelegate.sendData(emptyDic)
                    }
                    SVProgressHUD.dismiss()
                } else if result == APIResult.apiError {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
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
            parameterss.setValue(strKeyword, forKey: "searchstring")
            parameterss.setValue("1", forKey: "posttype")
            parameterss.setValue(strFilterType, forKey: "mediatype")
            
            print(parameterss)
            
            mgr.worldmedia(parameterss, successClosure: { (dic, result) -> Void in
                SVProgressHUD.dismiss()
                
               // UIApplication.shared.endIgnoringInteractionEvents()
                
                if result == APIResult.apiSuccess {
                    if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "mediapostcount") as? Int {
                        self.totalMediaCount = countShop
                    }
                    
                    if self.offsetMe == 1 {
                        self.arrayMediaItems.removeAllObjects()
                        
                        self.arrayMediaItems = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "mediapost") as? NSArray)!)
                    } else {
                        self.arrayMediaItems.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "mediapost")! as? NSArray)!.mutableCopy() as! [AnyObject])
                        
                    }
                    self.tblDashboard.reloadData()
                    SVProgressHUD.dismiss()
                } else if result == APIResult.apiError {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
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
            parameterss.setValue(strKeyword, forKey: "searchstring")
            SVProgressHUD.show()
            
            
            mgr.worldstream(parameterss, successClosure: { (dic, result) -> Void in
                SVProgressHUD.dismiss()
                print(dic)
                self.isBusyFetching=false
                if result == APIResult.apiSuccess {
                    if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "streampostcount") as? Int {
                        self.totalStreamPost = countShop
                    }
                    
                    if self.offsetSt == 1 {
                        self.arrayStream.removeAllObjects()
                        
                        self.arrayStream = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "streampost") as? NSArray)!)
                    } else {
                        if ((((dic!.value(forKey: "result")! as AnyObject).value(forKey: "streampost")! as? NSArray)?.count)!>0) {
                            self.arrayStream.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "streampost")! as? NSArray)!.mutableCopy() as! [AnyObject])
                        }
                    }
                    self.tblDashboard.reloadData()
                    SVProgressHUD.dismiss()
                } else if result == APIResult.apiError {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
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
                if result == APIResult.apiSuccess
                {
                }
                    
                else if result == APIResult.apiError
                {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                    
                    
                }
                else
                {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
                }
            })
        }
        //MARK: - Open Image VIewer  -
        
        func openImage(_ sender: AnyObject)
        {
            let tapguesture = sender as! UITapGestureRecognizer
            let imageInfo = JTSImageInfo()
            let imgVIew = tapguesture.view as! UIImageView
            imageInfo.image = imgVIew.image
            imageInfo.referenceView = imgVIew
            imageInfo.referenceRect = imgVIew.frame
            let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
            imageViewer?.show(from: self, transition: JTSImageViewControllerTransition.fromOriginalPosition)
        }
        
        
        //MARK: - SearchVIew delgate datasource methods -
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = true
            
            if (searchBar.text?.characters.count)! > 0 {
                strKeyword = searchBar.text!
                getWorldActivity()
            }

        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if let player = playerFInal {
                player.stop()
            }
            searchBar.showsCancelButton = true
            
            var strMsg = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            
            if strMsg.characters.last == "\n" {
                strMsg = String(strMsg.characters.dropLast())
            }
            strKeyword = strMsg
            
            if strMsg.characters.count == 0 {
                strKeyword = ""
            }
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getWorldActivity), object: nil)
            perform(#selector(getWorldActivity), with: nil, afterDelay: 0.5)

            
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
                getWorldActivity()
            }
            
            searchBar.showsCancelButton=false
            searchBar.resignFirstResponder()
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
        
        //MARK: - get all
        
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
        
        
        func navigatetoRelvantPushScreen()
        {
            if let info = objAppDelegate.dicUserInfopush!["aps"] as? Dictionary<String, AnyObject>
            {
                let strType = ("\(info["ntype"]! as! NSNumber)")
                let detailID = ("\(info["detailid"]! as! NSNumber)")
                
                let usr = UserManager.userManager
                if usr.userId != nil
                {
                    //navig
                    if (Int(strType) == notifiType.pLike.rawValue || Int(strType) == notifiType.pComment.rawValue)
                    {//other_user_id
                        
                        let strsubType =  ("\(info["posttype"]! as! NSNumber)")
                        
                        let mgrItm = PostManager.postManager
                        mgrItm.clearManager()
                        
                        
                        let objpost: PostDetailsVC = objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsVC
                        
                        mgrItm.PostId = detailID
                        if strsubType == "0"
                        {
                            
                            objpost.Posttype=0;
                            
                            
                        }
                        else
                        {
                            objpost.Posttype=2;
                            
                            
                            
                        }
                        self.navigationController!.pushViewController(objpost, animated: true)
                    }
                    else if Int(strType) == notifiType.cntrequest.rawValue
                    {
                        
                        let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=1;
                        self.navigationController!.pushViewController(objfriends, animated: true)
                    }
                    else if Int(strType) == notifiType.cntaccept.rawValue
                    {
                        
                        let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=2;
                        self.navigationController!.pushViewController(objfriends, animated: true)
                    }
                    else if Int(strType) == notifiType.pItem.rawValue
                    {
                        
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
        
        func getadminData()
        {
            
            
            let mgradmin = AdminManager.adminManager
            
            mgradmin.getAdminDetails { (dic:NSDictionary?, result:APIResultAdm) -> Void in
                
                
                if (result == APIResultAdm.apiSuccess)
                {
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
    }

extension World: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let  tblLocaion :CGPoint = self.view.convert(location, to: self.tblDashboard)
        guard let indexPath = self.tblDashboard.indexPathForRow(at: tblLocaion)
            else {
                return nil
        }
        
        if (indexPath.section == 0){
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
            if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a" || MediaType == "audio/mp3" || MediaType == "video/mp4")
            {
                
                if (MediaType == "audio/m4a" || MediaType == "audio/mp3")
                {
                    UserDefaults.standard.set("y", forKey: "isoverlay")
                    
                    
                }
                else
                {
                    UserDefaults.standard.set("n", forKey: "isoverlay")
                }
                let strimg:String=(self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                
                UserDefaults.standard.set(strimg, forKey: "mediaimg")
            }
            
            if ((self.arrayMediaItems.object(at: index) as AnyObject).value(forKey: "post_title")) is NSNull {
                
                mgrItm.PostText = ""
            }
            else
            {
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
        } else if(indexPath.section == 1){
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

