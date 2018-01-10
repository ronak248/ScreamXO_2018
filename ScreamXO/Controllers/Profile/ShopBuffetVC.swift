//
//  ShopBuffetVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 03/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
//import MobilePlayer

class ShopBuffetVC: UITableViewController ,iCarouselDataSource,iCarouselDelegate {
    
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
    var itemName:String!
    var playerFInal:MobilePlayerViewController!
    var IsAddedPlayer:Bool = false
    var shouldRefreshMedia :Bool = true
    var isPlayVideo :Bool = false
    var totalCount: Int!
    var playerFullscreen:MobilePlayerViewController!
    var orientationValue = false
    var ShareURL: String!
    var item_id : Int!
     var boost_type : Int!
    var selectedIndex : Int!
    // MARK: View Life Cycle Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets=false
        ExpandType=1;
        selecteditemIndex=10111;
        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.btnLikeClickedmedia(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)

    }
    override func viewDidAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(HomeScreen.btnLikeClickedmedia(_:)), name: NSNotification.Name(rawValue: constant.forVideoMediaLike), object: nil)


    }
    override func viewWillAppear(_ animated: Bool)
    {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
       // NotificationCenter.default.addObserver(self, selector: #selector(self.deviceDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
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
     
            let mgrItm = ItemManager.itemManager
            if sender.accessibilityIdentifier == "ico_unwatch" {
                mgrItm.addWatchedItem(1,successClosure:{ (dic, result) -> Void in
                    
                    if result == APIResultItm.apiSuccess {
                        sender.setImage(UIImage(named: "ico_watch"), for: UIControlState())
                        sender.accessibilityIdentifier = "ico_watch"
                        let objShopItm = NSMutableDictionary(dictionary: self.arrayMedia.object(at: self.selectedIndex) as! NSDictionary)
                        objShopItm.setValue("1", forKey: "iswatched")
                        self.arrayMedia.replaceObject(at: self.selectedIndex, with: objShopItm)
                    }
                })
            } else {
                mgrItm.addWatchedItem(0,successClosure:{ (dic, result) -> Void in
                    
                    if result == APIResultItm.apiSuccess {
                        sender.setImage(UIImage(named: "ico_unwatch"), for: UIControlState())
                        sender.accessibilityIdentifier = "ico_unwatch"
                        let objShopItm = NSMutableDictionary(dictionary: self.arrayMedia.object(at: self.selectedIndex) as! NSDictionary)
                        objShopItm.setValue("0", forKey: "iswatched")
                        self.arrayMedia.replaceObject(at: self.selectedIndex, with: objShopItm)
                    }
                })
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
                            lblnodata.text = "No any Media Uploaded."
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
                let itmMgr = ItemManager.itemManager
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
                let btnWatch: UIButton = cell!.contentView.viewWithTag(104) as! UIButton
                let btnlikecount: UIButton = cell!.contentView.viewWithTag(105) as! UIButton
                let lblItmPrice: UILabel = cell!.contentView.viewWithTag(206) as! UILabel
                
                let mgrItm = PostManager.postManager
                userImg.layer.cornerRadius = userImg.frame.width / 2
                userImg.layer.masksToBounds = true
                boost_type = 2
                
                
                var newstr = String()
                newstr = String(describing: itmMgr.ItemPrice )
                let largeNumber = Float(newstr)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
                let FinalAmount = String(describing: formattedNumber!)
                
                lblItmPrice.backgroundColor = UIColor.black
                lblItmPrice.font = UIFont(name: "ProximaNova-Semibold", size: 10.0)
                lblItmPrice.textColor = UIColor.white
                
                lblItmPrice.text = "$ \(FinalAmount)"
                
                
                 let isMyPost: Int = (self.arrayMedia.object(at: indexPath.row) as AnyObject).value(forKey: "myitem") as! Int
               
                if isMyPost == 1 {
                    btnExpand.removeTarget(self, action: #selector(self.btnShareClicked(_:)), for: .touchUpInside)
                    btnExpand.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnExpand.setTitle("BOOST", for: UIControlState())
                    btnExpand.setTitleColor(.white, for: .normal)
                    btnExpand.addTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    btnComment.backgroundColor = .clear
                    btnComment.setTitle(itemName, for: UIControlState())
                    btnComment.setTitleColor(colors.kLightgrey155, for: .normal)
                    btnComment.contentHorizontalAlignment = .center
                    btnComment.addTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                    
                    //btnUserName.removeTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                } else {
                    btnExpand.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    btnExpand.backgroundColor = UIColor(red: 253/255, green: 76/255, blue: 80/255, alpha: 1.0)
                    btnExpand.setTitle("BUY", for: UIControlState())
                    btnExpand.setTitleColor(.white, for: .normal)
                    btnExpand.addTarget(self, action: #selector(self.btnShareClicked(_:)), for: .touchUpInside)
                    btnComment.backgroundColor = .clear
                    btnComment.setTitle(itemName, for: UIControlState())
                    btnComment.setTitleColor(colors.kLightgrey155, for: .normal)
                    btnComment.addTarget(self, action: #selector(self.btnUserProfileClicked), for: .touchUpInside)
                    btnComment.contentHorizontalAlignment = .center
                    // btnUserName.removeTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                }
                
               
                    
                btnWatch.addTarget(self, action: #selector(ShopBuffetVC.btnLikeClickedmedia(_:)), for: .touchUpInside)
                btnlikecount.addTarget(self, action: #selector(ShopBuffetVC.btntotalLikeClcikedmedia(_:)), for: .touchUpInside)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ShopBuffetVC.openImage(_:)))
                imgbg.addGestureRecognizer(tapGesture)
                tapGesture.numberOfTapsRequired=1;
                let doubletapGesturedoubleTap = UITapGestureRecognizer(target: self, action: #selector(HomeScreen.btnLikeClickedmedia(_:)))
                doubletapGesturedoubleTap.numberOfTapsRequired=2
                imgbg.addGestureRecognizer(doubletapGesturedoubleTap)
                tapGesture.require(toFail: doubletapGesturedoubleTap)
                
                userImg.sd_setImageWithPreviousCachedImage(with: videoUrl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
                })
                
               
                if Int(itmMgr.isItemPurchase)! == 1  {
                    btnExpand.isHidden = true
                    imgbg.image = UIImage(named: "sold_out")
                    btnExpand.isHidden = true
                } else {
                    
                    imgbg.sd_setImageWithPreviousCachedImage(with: videoUrl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: { (img, error, type, url) -> Void in
                    })

                    
                    btnExpand.isHidden = false
                    if itmMgr.isWatch {
                        btnWatch.setImage(UIImage(named: "ico_watch"), for: UIControlState())
                        btnWatch.accessibilityIdentifier = "ico_watch"
                    } else {
                        btnWatch.setImage(UIImage(named: "ico_unwatch"), for: UIControlState())
                        btnWatch.accessibilityIdentifier = "ico_unwatch"
                        
                    }
                    
                }
                
                return cell!
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
            if indexPath.row==0
            {
                
                if (UI_USER_INTERFACE_IDIOM() == .pad) {
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
        var imgSoldOut: UIImageView
         var lblItmPrice: UILabel
        if view == nil
        {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4.3, height: carousel.frame.size.width/4.3)
            
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            
            lblItmPrice = UILabel()
            
            lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 20, width: (view?.frame.width)!  , height: 15.0)
            
            if  UIDevice.current.userInterfaceIdiom == .pad {
                lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 40, width: (view?.frame.width)!  , height: 20.0)
            }
            
            
            lblItmPrice.backgroundColor = UIColor(hexString: "000000", alpha: 0.5)
            lblItmPrice.font = UIFont(name: "ProximaNova-Semibold", size: 10.0)
            lblItmPrice.textColor = UIColor.white
            lblItmPrice.textAlignment = .center
            

            imgSoldOut = UIImageView()
            imgSoldOut.frame =  CGRect(x: 0, y: 0, width: view!.frame.width - 10, height: view!.frame.height)
            imgSoldOut.clipsToBounds = true
            imgSoldOut.contentMode=UIViewContentMode.scaleToFill
            imgSoldOut.tag = 107
            imgSoldOut.layer.masksToBounds = true
            
            imgicon = UIImageView(frame: CGRect(x: (view?.frame.size.width)! / 2 - 16, y: (view?.frame.size.width)! / 2 - 16, width: 32, height: 32))
            imgicon.contentMode = .scaleAspectFill
            imgicon.tag = 101
            imgPic.tag = 105
            lblItmPrice.tag = 110
            
            view?.addSubview(imgPic)
            view?.addSubview(imgicon)
            view?.addSubview(lblItmPrice)
            view?.addSubview(imgSoldOut)
            
            
        }
        else
        {
            imgicon = view?.viewWithTag(101) as! UIImageView
            imgPic = view?.viewWithTag(105) as! UIImageView
            lblItmPrice = view?.viewWithTag(110) as! UILabel
            imgSoldOut = view?.viewWithTag(107) as! UIImageView
        }
       
            imgicon.isHidden=true
            let strimg:String=(self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
        
        lblItmPrice.isHidden = false
        
        var newstr = String()
        newstr = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_price")!)
        let largeNumber = Float(newstr)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
        let FinalAmount = String(describing: formattedNumber!)
        
        lblItmPrice.text = "$ \(FinalAmount)"
        
        
        if ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "ispurchased")! as AnyObject).intValue == 1 {
            imgSoldOut.image = UIImage(named: "sold_out")
            imgSoldOut.isHidden = false
        } else {
            imgSoldOut.isHidden = true
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
        let mgrItm = ItemManager.itemManager
            let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
            boostViewController.item_id =  Int(mgrItm.ItemId)
            boostViewController.boost_type =  1
            self.navigationController?.pushViewController(boostViewController, animated: true)
        
    }
    
    func btnShareClicked(_ sender: UIButton) {
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
                let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "ConfigureBuyPaymentVC")) as! ConfigureBuyPaymentVC
                VC1.isShopFlag = true
                self.navigationController?.pushViewController(VC1, animated: true)
                      }
    }
    
    func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
    }
    
    func btnUserProfileClicked() {

        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
            
        }
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
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

        selectedIndex = index
        boost_type = 1
        
        let mgrItm = ItemManager.itemManager
        let mgrFriend = FriendsManager.friendsManager
        
        mgrItm.clearManager()
        
        if let itmID: Int  = (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_id") as? Int
        {
            mgrItm.ItemId = "\(itmID)"
        }
        
        
        mgrFriend.FriendID = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_created_by")!)
        mgrFriend.FUsername = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "ispurchased")!)
        
        mgrItm.itmTag = index
        mgrItm.ItemId = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_id")!)

        mgrItm.isItemPurchase = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "ispurchased")!)
        mgrItm.ItemactualPrice = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_actualprice")!)
        let stringLength = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_name")!)
        
        if stringLength.characters.count > 24 {
            let index = stringLength.index(stringLength.startIndex, offsetBy: 20)
            mgrItm.ItemName = stringLength.substring(to: index)
        } else {
            mgrItm.ItemName = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_name")!)
        }
        
        
        mgrItm.ItemPrice = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_price")!)
        mgrItm.itm_qty = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_qty")!)
        mgrItm.itm_qty_remain = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_qty_remained")!)
        mgrItm.ItemShipingCost = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_shipping_cost")!)
        mgrItm.ItemImg = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_url")!)
        mgrItm.Itemtype = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_type")!)
        mgrItm.Itemmy = String(describing: (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "myitem")!)
        let watched = (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "iswatched") as? String
        if watched == "1" {
            mgrItm.isWatch = true
        } else {
            mgrItm.isWatch = false
        }
        

        let urlstring:String = ((self.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_url"))! as! String
         videoUrl = URL(string: urlstring)
        let strUserName: String = (self.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_name") as! String
        itemName = strUserName
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
    

}
