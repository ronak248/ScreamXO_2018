//
//  MediaBuffetVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 03/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
//import MobilePlayer

class MediaBuffetVC: UITableViewController ,iCarouselDataSource,iCarouselDelegate {
    
    enum Expand : NSInteger
    {
        case expDelete = 0,exPhalf,exPfull
    }
    var icarouselView: iCarousel!
    var selecteditemIndex:Int?
    var ExpandType :Int!
    var parentCnt: UIViewController!
    var arrayMedia = NSMutableArray ()
    var PaginationCallback : (( _ type : String)-> Void)?
    var videoUrl:URL!
    var videoTitle:String!
    var MediaType:String!
    var playerFInal:MobilePlayerViewController!
    var IsAddedPlayer:Bool = false
    var shouldRefreshMedia :Bool = true
    var isPlayVideo :Bool = false
    var totalCount: Int!
    var playerFullscreen:MobilePlayerViewController!
    var orientationValue = false
    var ShareURL: String!
    var boost_type : Int!
    var item_id : Int!
    // MARK: View Life Cycle Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets=false
        ExpandType=1;
        selecteditemIndex=10111;
        NotificationCenter.default.addObserver(self, selector: #selector(MediaBuffetVC.stopVideo), name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.btnLikeClickedmedia(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)

    }
    override func viewDidAppear(_ animated: Bool) {
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(MediaBuffetVC.stopVideo), name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.btnLikeClickedmedia(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)


    }
    override func viewWillAppear(_ animated: Bool)
    {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
       // NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        objAppDelegate.fullScreenVideoIsPlaying=false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideoPlayinglanscape), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideostopPlayinglanscape), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)
        if ExpandType == Expand.exPfull.rawValue {
                objAppDelegate.fullScreenVideoIsPlaying=false
                self.tableView.beginUpdates()
                ExpandType=1;
                let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                self.tableView.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                self.tableView.endUpdates()
                selecteditemIndex = -1
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - custom button methods

    
    func btnMediaCollapseClicked(_ sender: UIButton) {
        var paths:[IndexPath]!
        self.tableView.beginUpdates()
        paths = [IndexPath(row: 1, section: 0)]
        ExpandType=1
        self.tableView.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
        self.tableView.endUpdates()
        
    }
    
    func btnMorePostClicked(_ sender: UIButton) {
        
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
        
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
        }
        else
        {
            VC1.delegate=parentCnt as! OtherProfile
        }
    
        VC1.Posttype=2;
        VC1.isViewComment=1;
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
        
    }
    
    func btnLikeClickedmedia(_ sender: UIButton) {
        
        
        let mgrpost = PostManager.postManager
        
        var dic :NSMutableDictionary?
        
        
        let mutDict = NSMutableDictionary(dictionary: self.arrayMedia.object(at: mgrpost.postTag) as! [AnyHashable: Any])
        dic = mutDict.mutableCopy() as? NSMutableDictionary 

        var likeCount:Int=((self.arrayMedia.object(at: mgrpost.postTag) as AnyObject).value(forKey: "likecount")! as? Int)!
        
        if ((dic?.value(forKey: "islike"))! as! Int == 0)
        {
            dic?.setValue(1, forKey: "islike");
            likeCount += 1
            dic?.setValue(likeCount, forKey: "likecount");
            self.arrayMedia.replaceObject(at: mgrpost.postTag!, with: dic!)
            self.tableView.reloadData()
            mgrpost.postlikeMethod(0)
            
            
        }
        else
        {
            likeCount -= 1
            dic?.setValue(likeCount, forKey: "likecount");
            dic?.setValue(0, forKey: "islike");
            self.arrayMedia.replaceObject(at: mgrpost.postTag!, with: dic!)
            self.tableView.reloadData()
            mgrpost.postlikeMethod(1)
            
        }
        
    }
    
    func btntotalLikeClcikedmedia(_ sender: UIButton) {
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
            if indexPath.row==0
            {
                let CELL_ID = "BuffetCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as UITableViewCell!
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                icarouselView = cell?.contentView.viewWithTag(110) as! iCarousel
                let lblnodata = cell?.contentView.viewWithTag(111) as! UILabel
                icarouselView.type = iCarouselType.linear
                icarouselView.bounces = false
                icarouselView.isPagingEnabled = false
                icarouselView.delegate = self
                icarouselView.strIdentifier="buffet"
                icarouselView.dataSource = self
                if arrayMedia.count>0
                {
                    lblnodata.isHidden = true
                }
                else
                {
                    lblnodata.isHidden = false

                    if (FriendsManager.friendsManager.users_info==1 || FriendsManager.friendsManager.users_media==0)
                    {
                        if parentCnt.isKind(of: Profile.self)
                        {
                            lblnodata.text = " No any Media Uploaded."
                        }
                        else
                        {
                            lblnodata.text = "This user is private"
                        }
                    
                    }
                    
                }
                
                if DeviceType.IS_IPHONE_6 {
                    icarouselView.viewpointOffset = CGSize(width: 140, height: 0)
                    
                }
                else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                    icarouselView.viewpointOffset = CGSize(width: 119, height: 0)
                    
                }
                else if DeviceType.IS_IPHONE_6P {
                    icarouselView.viewpointOffset = CGSize(width: 155, height: 0)
                    
                }
                else if UI_USER_INTERFACE_IDIOM() == .pad{
                    
                    icarouselView.viewpointOffset=CGSize(width: 285, height: 0)
                    
                    
                }
                icarouselView.reloadData()
                
                return cell!
            } else {
                let CELL_ID = "MediaCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as UITableViewCell!
                cell?.selectionStyle = .none
                cell?.backgroundColor = UIColor.clear
                let btnExpand: UIButton = cell!.contentView.viewWithTag(103) as! UIButton
                let btnMore: UIButton = cell!.contentView.viewWithTag(102) as! UIButton
                let btnComment: UIButton = cell!.contentView.viewWithTag(106) as! UIButton
                let labelTotalComment: UIButton = cell!.contentView.viewWithTag(107) as! UIButton
                let imgbg: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
                 let userImg: UIImageView = cell!.contentView.viewWithTag(201) as! UIImageView
                let btnlike: UIButton = cell!.contentView.viewWithTag(104) as! UIButton
                let btnlikecount: UIButton = cell!.contentView.viewWithTag(105) as! UIButton
                let mgrItm = PostManager.postManager
                let strisLike:Int?=(self.arrayMedia.object(at: mgrItm.postTag) as AnyObject).value(forKey: "islike") as? Int
                let totalComment:Int = ((self.arrayMedia.object(at: mgrItm.postTag) as AnyObject).value(forKey: "commentcount") as? Int)!
                userImg.layer.cornerRadius = userImg.frame.width / 2
                userImg.layer.masksToBounds = true
                
                item_id = ((self.arrayMedia.object(at: mgrItm.postTag) as AnyObject).value(forKey: "id") as? Int)!
                boost_type = 2
                labelTotalComment.setTitle("\(totalComment)", for: UIControlState())
                let strlikeCount:Int=((self.arrayMedia.object(at: mgrItm.postTag) as AnyObject).value(forKey: "likecount")! as? Int)!
                btnlikecount.setTitle("\(strlikeCount)", for: UIControlState())
                 let isMyPost: Int = (self.arrayMedia.object(at: mgrItm.postTag) as AnyObject).value(forKey: "mypost") as! Int
                let strUserName: String = (self.arrayMedia.object(at: mgrItm.postTag) as AnyObject).value(forKey: "username") as! String
                
                if isMyPost == 1 {
                    let imgURL = UserManager.userManager.profileImage
                    let newURL = URL(string: imgURL!)
                    userImg.sd_setImageWithPreviousCachedImage(with: newURL, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: { (img, error, type, url) -> Void in
                    })
                    
                    
                    btnExpand.removeTarget(self, action: #selector(self.btnShareClicked(_:)), for: .touchUpInside)
                    btnExpand.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnExpand.setTitle("BOOST", for: UIControlState())
                    btnExpand.setTitleColor(.white, for: .normal)
                    btnExpand.addTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    btnComment.backgroundColor = .clear
                    btnComment.setTitle(strUserName, for: UIControlState())
                    btnComment.setTitleColor(colors.kLightgrey155, for: .normal)
                    btnComment.contentHorizontalAlignment = .center
                    btnComment.addTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                    
                    //btnUserName.removeTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                } else {
                    let imgURL = FriendsManager.friendsManager.FriendPhoto
                    let newURL = URL(string: imgURL!)
                    userImg.sd_setImageWithPreviousCachedImage(with: newURL, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: { (img, error, type, url) -> Void in
                    })
                    
                    
                    btnExpand.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    btnExpand.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnExpand.setTitle("Share", for: UIControlState())
                    btnExpand.setTitleColor(.white, for: .normal)
                    btnExpand.addTarget(self, action: #selector(self.btnShareClicked(_:)), for: .touchUpInside)
                    btnComment.backgroundColor = .clear
                    btnComment.setTitle(strUserName, for: UIControlState())
                    btnComment.setTitleColor(colors.kLightgrey155, for: .normal)
                    btnComment.addTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                    btnComment.contentHorizontalAlignment = .center
                    // btnUserName.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                }
                
                
                if (strisLike == 0)
                {
                    btnlike.setImage(UIImage(named: "unlike"), for: UIControlState())
                    
                }
                else
                {
                    btnlike.setImage(UIImage(named: "like"), for: UIControlState())
                }
                
                
                
                btnlike.addTarget(self, action: #selector(MediaBuffetVC.btnLikeClickedmedia(_:)), for: .touchUpInside)
                btnlikecount.addTarget(self, action: #selector(MediaBuffetVC.btntotalLikeClcikedmedia(_:)), for: .touchUpInside)
                
                if (shouldRefreshMedia)
                {
                    shouldRefreshMedia = false

                if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a" || MediaType == "audio/mp3" || MediaType == "video/mp4")
                {
                    
                    let bundle = Bundle.main
                    let config = MobilePlayerConfig(fileURL: bundle.url(
                        forResource: "Skin",
                        withExtension: "json")!)
                    playerFullscreen = MobilePlayerViewController(
                        contentURL: videoUrl,
                        config: config)
                    playerFullscreen.activityItems = [videoUrl]
                    playerFullscreen.view.frame=(cell?.contentView.frame)!
                    playerFullscreen.view.frame.size.height = (cell?.contentView.frame.size.height)! - 42
                    playerFullscreen.moviePlayer.shouldAutoplay=true
                    playerFullscreen.fitVideo()
                    playerFullscreen.view.tag=1001
                    playerFullscreen.shouldAutoplay=true
                    
                    if let strtitle:String =    mgrItm.PostText
                    {
                        playerFullscreen.title = strtitle
                    }
                    if IsAddedPlayer == false
                    {
                        cell?.contentView.addSubview(playerFullscreen.view)
                        IsAddedPlayer=true
                        playerFInal=playerFullscreen;
                    }
                    else
                    {
                        
                        
                        playerFullscreen.view.removeFromSuperview()
                        cell?.contentView.addSubview(playerFullscreen.view)
                        playerFInal=playerFullscreen;
                    }
                    
                    playerFullscreen.play()
                }
                else
                {
                    
                    let player: UIView? = (cell?.contentView.viewWithTag(1001))
                    
                    if (player != nil)
                    {
                        IsAddedPlayer = false
                        player!.removeFromSuperview()
                    }
                    if((playerFullscreen) != nil)
                    {
                        
                        if((playerFullscreen.view? .isDescendant(of: (cell?.contentView)!)) != nil)
                        {
                            playerFullscreen.view.removeFromSuperview()
                        }
                    }
                    
                    imgbg.sd_setImageWithPreviousCachedImage(with: videoUrl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: { (img, error, type, url) -> Void in
                    })
                }
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MediaBuffetVC.openImage(_:)))
                imgbg.addGestureRecognizer(tapGesture)
                
                tapGesture.numberOfTapsRequired=1;
                
                let doubletapGesturedoubleTap = UITapGestureRecognizer(target: self, action: #selector(HomeScreen.btnLikeClickedmedia(_:)))
                doubletapGesturedoubleTap.numberOfTapsRequired=2
                imgbg.addGestureRecognizer(doubletapGesturedoubleTap)
                tapGesture.require(toFail: doubletapGesturedoubleTap)
                    
                }
                //btnExpand.addTarget(self, action: #selector(MediaBuffetVC.btnMediaCollapseClicked(_:)), for: .touchUpInside)
                //btnMore.addTarget(self, action: #selector(MediaBuffetVC.btnMorePostClicked(_:)), for: .touchUpInside)
                //btnComment.addTarget(self, action: #selector(MediaBuffetVC.btnMorePostClicked(_:)), for: .touchUpInside)
                return cell!
        }
            
         
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            if indexPath.row==0
            {
                
                if (UI_USER_INTERFACE_IDIOM() == .pad)
                {
                    return 210;

                }
                
                return 110;
                
            }
        if (UI_USER_INTERFACE_IDIOM() == .pad)
        {
            return 301;

        }
            return 250;
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    //MARK: - iCarousel methods -
    func numberOfItems (in carousel : iCarousel) -> NSInteger
    {
        if self.arrayMedia.count > 0
        {
            return self.arrayMedia.count
            
        }
        return 0
    }
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var view = view
        
        //    let contentView : UIView?
        var imgPic : UIImageView
        var imgicon : UIImageView
         var lblItmPrice: UILabel
        if view == nil
        {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4.3, height: carousel.frame.size.width/4.3)
            
            lblItmPrice = UILabel()
            
            lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 20, width: (view?.frame.width)!  , height: 15.0)
            
            if  UIDevice.current.userInterfaceIdiom == .pad {
                lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 40, width: (view?.frame.width)!  , height: 20.0)
            }
            
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            
            lblItmPrice.backgroundColor = UIColor(hexString: "000000", alpha: 0.5)
            lblItmPrice.font = UIFont(name: "ProximaNova-Semibold", size: 10.0)
            lblItmPrice.textColor = UIColor.white
            lblItmPrice.textAlignment = .center
            
            imgicon = UIImageView(frame: CGRect(x: (view?.frame.size.width)! / 2 - 16, y: (view?.frame.size.width)! / 2 - 16, width: 32, height: 32))
            imgicon.contentMode = .scaleAspectFill
            imgicon.tag = 101
            imgPic.tag = 105
             lblItmPrice.tag = 110
            view?.addSubview(imgPic)
            view?.addSubview(imgicon)
            view?.addSubview(lblItmPrice)
            
        }
        else
        {
            imgicon = view?.viewWithTag(101) as! UIImageView
            imgPic = view?.viewWithTag(105) as! UIImageView
            lblItmPrice = view?.viewWithTag(110) as! UILabel
        }
        let strmediatype:Int=(self.arrayMedia.object(at: index) as AnyObject).value(forKey: "posttype")! as! Int
        
        
        
        
        
        if  let text = ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
            let unfilteredString: String = text
            let notAllowedChars = CharacterSet(charactersIn: " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
            let resultString = (unfilteredString.components(separatedBy: notAllowedChars) as NSArray).componentsJoined(by: "")
            if resultString == "" {
                
                if let post = ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "post_title")) as? String {
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
        
        
        
        if strmediatype == 3 || strmediatype == 4
        {
            imgicon.isHidden = false
            if (strmediatype == 3)
            {
                imgicon.image=UIImage(named: "ico_microphone")
            }
            else
            {
                imgicon.image=UIImage(named: "auic")
            }
            let strimg:String=(self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
        }
        else if   strmediatype == 1
        {
            imgicon.isHidden = false
            imgicon.image=UIImage(named: "vdic")
            let strimg:String=(self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
        
        }
        else
        {
            imgicon.isHidden=true
            let strimg:String=(self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
        }
//        imgicon.hidden=false;
        
        view!.backgroundColor = UIColor.white
        
        if index==selecteditemIndex {
            view?.layer.borderWidth = 2.0
            view?.layer.borderColor = colors.klightgreyfont.cgColor
        } else {
        
            view?.layer.borderColor = UIColor.white.cgColor
            view?.layer.borderWidth = 0.0
        }
        imgPic.layer.masksToBounds = true
        imgicon.contentMode = .scaleAspectFit
        //        view!.contentMode = .ScaleAspectFit
        return view
    }
    
    func btnBoostClicked(_ sender: UIButton) {
            let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
            boostViewController.item_id =  item_id
            boostViewController.boost_type =  boost_type
            self.navigationController?.pushViewController(boostViewController, animated: true)
        
    }
    
    func btnShareClicked(_ sender: UIButton) {
      
            let objfriends: FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
           objfriends.ispushtype=1;
        objfriends.shareFlag = true
        objfriends.shareUrl = ShareURL
            self.navigationController!.pushViewController(objfriends, animated: true)
        
    }
    
    func btnUserProfileClicked() {
        
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
        
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
            
        }
        VC1.Posttype = 2
        VC1.item_id = item_id
        VC1.boost_type = 2
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
        
        
//        let mgrfriend = FriendsManager.friendsManager
//        var uID = mgrfriend.FriendID
//        mgrfriend.clearManager()
//        let user = UserManager.userManager
//        if (uID == user.userId) {
//            if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
//                leftVC.selectedrow = leftVC.profileRow
//                leftVC.tblView.reloadData()
//            }
//            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
//            self.navigationController?.pushViewController(VC1, animated: true)
//        } else {
//            mgrfriend.FriendID = uID
//            mgrfriend.FriendName = ((dictChatUserInfo as AnyObject).value(forKey: "fname") as! String) + ((dictChatUserInfo as AnyObject).value(forKey: "lname") as! String)
//            mgrfriend.FriendPhoto = ((dictChatUserInfo as AnyObject).value(forKey: "userphoto") as! String)
//            mgrfriend.FUsername = ((dictChatUserInfo as AnyObject).value(forKey: "username") as! String)
//            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
//            self.navigationController?.pushViewController(VC1, animated: true)
        //}
        
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
        if (option == .wrap)
        {
            return value
        }
        return value
    }
  
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
        
        isPlayVideo=false
        shouldRefreshMedia = true
        
        objAppDelegate.fullScreenVideoIsPlaying=false
        let urlstring:String = ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_url"))! as! String
        ShareURL = urlstring
        MediaType = ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_type"))! as! String
        
        let mgrItm = PostManager.postManager
        mgrItm.clearManager()
        mgrItm.PostId="\(((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "id"))!)"
        mgrItm.PostType = MediaType
        mgrItm.PostImg = urlstring
        mgrItm.postTag = index
        
        
        if ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "post_title")) is NSNull {
            
            mgrItm.PostText = ""
        }
        else {
            let post = ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "post_title")) as! String
            if post.contains("@@:-:@@") {
                let arr = post.components(separatedBy: "@@:-:@@")
                
                if arr.count>0 {
                    mgrItm.PostText = arr[1]
                }
            } else {
                mgrItm.PostText = post
            }
        }
        
        videoUrl = URL(string: urlstring)
        
        if  ( MediaType == "video/quicktime" || MediaType == "audio/m4a" || MediaType == "audio/mp3" ||  MediaType == "video/mp4") {
            
            if (MediaType == "audio/m4a" || MediaType == "audio/mp3")
            {
                UserDefaults.standard.set("y", forKey: "isoverlay")
            }
            else
            {
                UserDefaults.standard.set("n", forKey: "isoverlay")
            }
            let strimg:String=(self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            
            UserDefaults.standard.set(strimg, forKey: "mediaimg")
            
            isPlayVideo = true
            objAppDelegate.fullScreenVideoIsPlaying=true
        }
        if ExpandType == Expand.exPfull.rawValue {
            
            if (selecteditemIndex==index) {
                objAppDelegate.fullScreenVideoIsPlaying=false
                self.tableView.beginUpdates()
                ExpandType=1;
                let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
                self.tableView.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                self.tableView.endUpdates()
                selecteditemIndex = -1
            } else {
                selecteditemIndex = index
                self.tableView.reloadData()
            }
        } else {
            ExpandType=2;
            self.tableView.beginUpdates()
            let paths: [IndexPath] = [IndexPath(row: 1, section: 0)]
            self.tableView.insertRows(at: paths, with: UITableViewRowAnimation.fade)
            self.tableView.endUpdates()
            selecteditemIndex = index
        }
        icarouselView.reloadData()
    }

    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel!) {
        
        if( carousel.currentItemIndex == self.arrayMedia.count-2 && self.arrayMedia.count>0 && self.totalCount > self.arrayMedia.count) {
            
            if PaginationCallback != nil
            {
                UIApplication.shared.beginIgnoringInteractionEvents()

                PaginationCallback!((self.title?.lowercased())!)
            }
        }
    }
    
    func openImage(_ sender: AnyObject) {
        let tapguesture = sender as! UITapGestureRecognizer
        let imageInfo = JTSImageInfo()
        let imgVIew = tapguesture.view as! UIImageView
        imageInfo.image = imgVIew.image
        imageInfo.referenceView = imgVIew
        imageInfo.referenceRect = imgVIew.frame
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
        imageViewer?.show(from: parentCnt, transition: JTSImageViewControllerTransition.fromOriginalPosition)
    }
    
    // MARK: - video play methods for landscape
    
    func playVideoinlandscape() {
        playerFullscreen.view.backgroundColor = UIColor.red
        if(playerFullscreen.view.frame.height == self.view.frame.height) {
            UIApplication.shared.isStatusBarHidden = false
            let ip = IndexPath.init(row:1, section: 0)
            let cell = tableView.cellForRow(at: ip)
            
            if (cell != nil) {
                let _: UIImageView = cell!.contentView.viewWithTag(101) as! UIImageView
                UIView.animate(withDuration: 0.25, animations:{
                    self.playerFullscreen.view.transform = CGAffineTransform.identity
                    self.playerFullscreen.view.center = cell!.contentView.center
                    self.playerFullscreen.view.frame=cell!.contentView.frame
                    self.playerFullscreen.view.frame.size.height = cell!.contentView.frame.size.height - 40
                    cell!.contentView.addSubview(self.playerFullscreen.view)
                })
            }
            
        } else {
//            UIApplication.shared.isStatusBarHidden = true
//            UIView.animate(withDuration: 0.25, animations:{
//                self.playerFullscreen.view.frame.size.width=self.view.frame.size.height
//                self.playerFullscreen.view.frame.size.height=self.view.frame.size.width
//                self.playerFullscreen.view.transform = CGAffineTransform(rotationAngle: .pi/2)
//                self.playerFullscreen.view.center = self.view.center
//                self.playerFullscreen.fitVideo()
//                self.playerFullscreen.loadViewIfNeeded()
//                // playerFullscreen.play()
//                self.view.addSubview(self.playerFullscreen.view)
//            })
        }
    }
    
    
    func playVideoinlandscapemode() {
        playerFullscreen.view.backgroundColor = UIColor.red
        if(playerFullscreen.view.frame.height == self.view.frame.height) {
            UIApplication.shared.isStatusBarHidden = false
            let ip = IndexPath.init(row:1, section: 0)
            let cell = tableView.cellForRow(at: ip)
            
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

    
    
    func stopVideo() {
        
        let ip = IndexPath.init(row:1, section: 0)
        let cell = self.tableView.cellForRow(at: ip)
        
        if (cell != nil) {
            playerFullscreen.view.frame=cell!.contentView.frame
            cell!.contentView.addSubview(playerFullscreen.view)
            self.tableView.reloadData()
        }
    }
}
