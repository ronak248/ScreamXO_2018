//
//  Profile.swift
//  ScreamXO
//
//  Created by Ronak Barot on 03/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Profile: UIViewController,CAPSPageMenuDelegate,commentActionDelegate,ItemeditActionDelegate,AddItemDelgate,WYPopoverControllerDelegate {
    
    // MARK: Properties
    
    var pageMenu : CAPSPageMenu?
    var offset:Int = 1
    var limit:Int = 4
    var totalShopCount:Int = 0
    var totalMediaCount:Int = 0
    var totalStreamPost:Int = 0
    var popoverController: WYPopoverController!
    let controller1 : MediaBuffetVC = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "MediaBuffetVC") as! MediaBuffetVC;
    //let controller2 : ShopVc = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "ShopVc") as! ShopVc;
    let controller2 : ShopBuffetVC = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "ShopBuffetVC") as! ShopBuffetVC;
    let controller3 : StreamVC = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "StreamVC") as! StreamVC;
    
    var arrayShopItems = NSMutableArray ()
    var arrayMediaItems = NSMutableArray ()
    var arrayStream = NSMutableArray ()
    var internetConnected = true

    // MARK: IBOutlets
    
    @IBOutlet weak var lblfriends: UILabel!
    @IBOutlet weak var lblfriendsCount: UILabel!
    @IBOutlet weak var lblItems: UILabel!
    @IBOutlet weak var lblitemCount: UILabel!
    @IBOutlet weak var btnWentFrom: UIButton!
    @IBOutlet weak var scrProfile: UIScrollView!
    
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var imgProfile: RoundImage!
    
    @IBOutlet weak var lblUniversity: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet weak var itemsView: UIView!
    @IBOutlet weak var friendsView: UIView!
    
    // MARK: UIViewControllerSuperClassMethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsView.layer.borderWidth = 10
        friendsView.layer.borderColor = (UIColor.white).cgColor
        
        itemsView.layer.borderWidth = 10
        itemsView.layer.borderColor = (UIColor.white).cgColor
        
        //imgProfile.layer.borderWidth = 10
        //imgProfile.layer.borderColor = UIColor.white.cgColor
        
        let margin: CGFloat = 10.0
        var _: CGRect = imgProfile.bounds.insetBy(dx: margin, dy: margin)
        let path = UIBezierPath(arcCenter: CGPoint(x: imgProfile.bounds.size.width / 2, y: imgProfile.bounds.size.height / 2), radius: imgProfile.bounds.size.width / 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        imgProfile.layer.mask = mask
        
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = mask.path // Reuse the Bezier path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.white.cgColor
        borderLayer.lineWidth = 20
        borderLayer.frame = imgProfile.bounds
        imgProfile.layer.addSublayer(borderLayer)

        
        
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }
        self.setupMenuClass()
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView:self.view)
        }
        self.automaticallyAdjustsScrollViewInsets=false
    }

    override func viewWillDisappear(_ animated: Bool) {
        objAppDelegate.repositiongsm()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sharemedia"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(Profile.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)

        let usr = UserManager.userManager
        usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)

        lblFullname.text = usr.fullName
        
        if usr.profileImage != nil {
            imgProfile.sd_setImageWithPreviousCachedImage(with: URL(string: usr.profileImage!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
        }
        
//        imgProfile.contentMode=UIViewContentMode.scaleAspectFill
//        imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2
//        imgProfile.layer.masksToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OtherProfile.openImage(_:)))
        imgProfile.addGestureRecognizer(tapGesture)
        
        if ((usr.school != nil && !( usr.school == "")) && (usr.username != nil && !( usr.username == ""))) {
            btnWentFrom.setTitle("More Info", for: UIControlState())
            lblUsername.text =  "@\(usr.username!)"
            btnWentFrom.isHidden=true
            pageMenu?.view.frame = CGRect(x: 0.0, y: imgProfile.frame.origin.y + imgProfile.frame.height , width: scrProfile.frame.width, height: scrProfile.frame.size.height - (imgProfile.frame.origin.y + imgProfile.frame.height))
        } else if ((usr.school == nil || ( usr.school == "")) && (usr.username != nil && !( usr.username == ""))) {
            
            lblUsername.text =  "@\(usr.username!)"
            
            btnWentFrom.isHidden=true
            pageMenu?.view.frame = CGRect(x: 0.0, y: imgProfile.frame.origin.y + imgProfile.frame.height , width: scrProfile.frame.width, height: scrProfile.frame.size.height - (imgProfile.frame.origin.y + imgProfile.frame.height))
        } else if ( (usr.school != nil && !( usr.school == "")) && (usr.username == nil || ( usr.username == ""))) {
            
            btnWentFrom.setTitle("More Info", for: UIControlState())
            lblUsername.isHidden=true
            pageMenu?.view.frame = CGRect(x: 0.0, y: imgProfile.frame.origin.y + imgProfile.frame.height , width: scrProfile.frame.width, height: scrProfile.frame.size.height - (imgProfile.frame.origin.y + imgProfile.frame.height))
        } else {
            btnWentFrom.isHidden=true
            lblUsername.isHidden=true

            pageMenu?.view.frame = CGRect(x: 0.0, y: imgProfile.frame.origin.y + imgProfile.frame.height , width: scrProfile.frame.width, height: scrProfile.frame.size.height - (imgProfile.frame.origin.y + imgProfile.frame.height))
        }
        userInfo()
    }
    
    
     // MARK: GSM
    func btnGSMClicked(_ btnIndex: Int) {
        switch btnIndex {
            
        case 0:
            let objwallet: CreatePost_Media =  objAppDelegate.stMsg.instantiateViewController(withIdentifier: "CreatePost_Media") as! CreatePost_Media
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
            
        case 7:
            let objwallet: MessagingVC =  objAppDelegate.stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
        default:
            break
        }
    }
    
    
    // MARK: IBActions
    
    

    @IBAction func btnEditProfileClicked(_ sender: AnyObject) {
        
        
        let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let watchingAction = UIAlertAction(title: "Watching", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
         self.btnWatchedListClicked()
        }
        let boughtAction = UIAlertAction(title: "Bought", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
           self.btnReciptClicked()
        }
        
        let soldAction = UIAlertAction(title: "Sold", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.btnHistoryClicked()
        }
        let editAction = UIAlertAction(title: "Edit Profile", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.editProfileTapped()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        // Add the actions
        alert.addAction(watchingAction)
        alert.addAction(boughtAction)
        alert.addAction(soldAction)
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        
         let button = sender as! UIButton
        if (IS_IPAD) {
            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnWatchedListClicked() {
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "WatchedList")) as! WatchedList
        
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    func btnReciptClicked() {
        
        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "PurchasedHistory")) as! PurchasedHistory
        
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    func btnHistoryClicked() {
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "SellerHistoryVC")) as! SellerHistoryVC
        
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    func editProfileTapped() {
    let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "EditProfile")) as! EditProfile
    VC1.strIsFirstTime="0"
    self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    @IBAction func btnMenucClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    @IBAction func btnFriendsCLicked(_ sender: AnyObject) {
        if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
            leftVC.selectedrow = leftVC.peopleRow
            leftVC.tblView.reloadData()
        }
        
        let VC1=(objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC")) as! FriendsVC
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    @IBAction func btnMoreClicked(_ sender: Any) {
        if ((popoverController) != nil)
        {
            popoverController.dismissPopover(animated: true)
        }
        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "MoreInfoVC")) as UIViewController
        
        popoverController=WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self;
        popoverController.popoverContentSize=CGSize(width: 247, height: 210)
        
        popoverController.presentPopover(from: btnWentFrom.bounds, in: btnWentFrom, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
    }
    
    @IBAction func sendMsgClicked(_ sender: Any) {
        let friendsVC = (objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC")) as! FriendsVC
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
    
    @IBAction func sendMoneyClicked(_ sender: Any) {
        let transferVC = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "TransferMoneyVC")) as! TransferMoneyVC
        self.navigationController?.pushViewController(transferVC, animated: true)
    }
    
    @IBAction func btnMoreInfoClicked(_ sender: AnyObject) {
        
        if ((popoverController) != nil)
        {
            popoverController.dismissPopover(animated: true)
        }
        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "MoreInfoVC")) as UIViewController
        
        popoverController=WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self;
        popoverController.popoverContentSize=CGSize(width: 247, height: 210)
        
        popoverController.presentPopover(from: btnWentFrom.bounds, in: btnWentFrom, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        
    }
    
    // MARK: - setUp menubar
    func getDataForType(_ type : String)
    {
        //ACTIVITIES "FRIEND REQUESTS"
        if type == "shop"
        {
            if (self.totalShopCount > self.arrayShopItems.count)
            {
                offset += 1
                self.getShopItem()
            }
        }
        else if type == "media"
        {
            if (self.totalMediaCount > self.arrayMediaItems.count)
            {
                offset += 1
                self.getMediaItem()
            }
        }
        else
        {
            if (self.totalStreamPost > self.arrayStream.count)
            {
                offset += 1
                self.getStreamPost()
            }
        }
    }
    func setupMenuClass()
    {
    
        var controllerArray : [UIViewController] = []
        
        controller1.parentCnt=self
        controller1.title = "Media"
        controller1.totalCount=self.totalMediaCount
        controller1.PaginationCallback = getDataForType
        controllerArray.append(controller1)
        
        controller2.title = "Shop"
        controller2.parentCnt=self
        controller2.totalCount=self.totalShopCount
        controller2.PaginationCallback = getDataForType
        controllerArray.append(controller2)
        
        controller3.title = "Stream"
        controller3.parentCnt=self
        controller3.PaginationCallback = getDataForType

        controllerArray.append(controller3)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.clear),
            .viewBackgroundColor(UIColor.white),
            .selectionIndicatorColor(colors.kLightgrey155),
            .addBottomMenuHairline(false),
            .menuItemFont(UIFont(name: fontsName.KfontproxisemiBold, size: 14.0)!),
            .menuItemSeparatorRoundEdges(true),
            .menuItemSeparatorColor(UIColor.red),
            .menuHeight(50.0),
            .selectionIndicatorHeight(2.0),
            .menuItemWidthBasedOnTitleTextWidth(false),
            .selectedMenuItemLabelColor(UIColor.black)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: imgProfile.frame.origin.y + imgProfile.frame.height , width: scrProfile.frame.width, height: scrProfile.frame.size.height - (imgProfile.frame.origin.y + imgProfile.frame.height)), pageMenuOptions: parameters)
        pageMenu?.delegate=self
        self.addChildViewController(pageMenu!)
        scrProfile.addSubview(pageMenu!.view)
        self.getMediaItem()
        self.userInfo()
    }
    // MARK: --WebService Method
    
    func getShopItem()
    {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(usr.userId, forKey: "myid")

        if arrayShopItems.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Items", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getShopItems(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            //UIApplication.shared.endIgnoringInteractionEvents()

            if result == APIResult.apiSuccess
            {
                    if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                    {
                        self.totalShopCount = countShop
                        self.lblitemCount.text = String(countShop)
                    }
                    if self.offset == 1 {
                        self.arrayShopItems.removeAllObjects()
                        self.arrayShopItems = (NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "items") as! NSArray))
                    } else {
                        
                        if (((dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "items") as! NSArray).count > 0) {
                            self.arrayShopItems.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "items")! as? [AnyObject])!)
                        }
                    }
                
                              
                self.controller2.arrayMedia = self.arrayShopItems
                self.controller2.totalCount = self.totalShopCount

                self.controller2.tableView.reloadData()
                SVProgressHUD.dismiss()
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
    func getMediaItem()
    {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue("1", forKey: "posttype")
        parameterss.setValue(usr.userId, forKey: "myid")
        
        print(parameterss)
        
        if arrayShopItems.count == 0 {
            SVProgressHUD.show(withStatus: "Fetching Media", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getPostPlain(parameterss, successClosure: { (dic, result) -> Void in
            print(dic)
            SVProgressHUD.dismiss()
            //UIApplication.shared.endIgnoringInteractionEvents()

            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                {
                    self.totalMediaCount = countShop
                }
                
                if self.offset == 1
                {
                        
                    if let totalFriends :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friendscount") as? Int
                    {
                        if totalFriends == 0
                        {
                            self.lblfriends.text = "Friends"
                            self.lblfriendsCount.text = "\(totalFriends)"
                        }
                        else if  totalFriends == 1
                        {
                            self.lblfriends.text = "Friend"
                            self.lblfriendsCount.text = "\(totalFriends)"
                            
                        }
                        else if totalFriends > 1
                        {
                            self.lblfriends.text = "Friends"
                            self.lblfriendsCount.text = "\(totalFriends)"
                        }
                    }
                    if let totalItems :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "itemcount") as? Int
                    {
                        if totalItems == 0 || totalItems == 1
                        {
                            self.lblItems.text = "Item"
                            self.lblitemCount.text = "\(totalItems)"
                        }
                        else if totalItems > 1
                        {
                            self.lblItems.text = "Items"
                            self.lblitemCount.text = "\(totalItems)"
                        }
                        
                    }
                    
                    
                    let usgMgr = UserManager.userManager
                    usgMgr.profileImage = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "userProfile") as? String
                    self.imgProfile.sd_setImageWithPreviousCachedImage(with: URL(string: usgMgr.profileImage!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                    })
                    
                    self.arrayMediaItems.removeAllObjects()
                    self.arrayMediaItems = (NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "posts") as! NSArray))
                    
                }
                else
                {
                    
                    if (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as? NSArray)?.count>0)
                    {
                        self.arrayMediaItems.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as? NSArray)!.mutableCopy() as! [AnyObject])
                    }
                }
                self.controller1.arrayMedia=self.arrayMediaItems
                self.controller1.totalCount=self.totalMediaCount
                self.controller1.tableView.reloadData()
                SVProgressHUD.dismiss()
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
    func getStreamPost()
    {
        
        limit=10
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue("0", forKey: "posttype")
        parameterss.setValue(usr.userId, forKey: "myid")

        if arrayStream.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Stream", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getPostPlain(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
           // UIApplication.shared.endIgnoringInteractionEvents()

            if result == APIResult.apiSuccess
            {
                self.internetConnected = true
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                {
                    self.totalStreamPost = countShop
                }
                
                if self.offset == 1
                {
                    self.arrayStream.removeAllObjects()
                    self.arrayStream = NSMutableArray(array: (dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray)
                } else {
                    self.arrayStream.addObjects(from: (dic?.value(forKey: "result") as AnyObject).value(forKey: "posts") as! [AnyObject])

                }
                self.controller3.arrayStream=self.arrayStream
                self.controller3.totalCount=self.totalStreamPost
                
                self.controller3.tableView.reloadData()
                SVProgressHUD.dismiss()
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


    // MARK: - delegate methods
    
    func willMoveToPage(_ controller: UIViewController, index: Int)
    {
        offset = 1
        
        if index == 0
        {
            self.getMediaItem()
        }
        else if index == 1
        {
           self.getShopItem()
        }
        else if index == 2
        {
            self.getStreamPost()
        }
    }
    
    // MARK: --action delgate Method
    
    func actionOnData() {
        offset=1
        getStreamPost()
        getMediaItem()
    }
    
    func actionOnpostData() {
        let mgrItm = PostManager.postManager
        self.arrayMediaItems.removeObject(at: mgrItm.postTag)
        var paths:[IndexPath]!
        self.controller1.tableView.beginUpdates()
        paths = [IndexPath(row: 1, section: 0)]
        self.controller1.ExpandType=1
        self.controller1.tableView.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
        self.controller1.tableView.endUpdates()
        self.controller1.icarouselView.reloadData()
    }
    
    func actionOnDataItem() {
        offset=1
        getShopItem()
    }
    func actionOnaddItemData() {
        
        offset=1
        getShopItem()
        
    }

    func userInfo()
    {
        let usr = UserManager.userManager
        
        let mgrfriend = FriendsManager.friendsManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "userid")
        
        
        mgr.getUserInfo(parameterss, successClosure: { (dic, result) -> Void in
            
            print(dic)
            
            if result == APIResult.apiSuccess
            {
                SVProgressHUD.dismiss()
                
                mgrfriend.friendCity = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "city") as? String
                mgrfriend.friendSchool = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "school") as? String
                mgrfriend.friendJob = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "job") as? String
                mgrfriend.friendHobby = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "hobbies") as? String
                
                mgrfriend.friendGender = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "gender") as? String
                
                mgrfriend.friendsexpref = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "sexpreference") as? String
                
                mgrfriend.friendrelstatus = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "realtionstatus") as? String)!
            }
                
            else if result == APIResult.apiError
            {
                
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()            }
            else
            {
                
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
    // MARK: - share media
    
    
    func sharemedia()
    {      let textToShare = ""
        
        let mgrItm = PostManager.postManager
        
        let objectsToShare = [textToShare, mgrItm.PostImg]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        if (IS_IPAD) {
            
        }
        
        self.present(activityVC, animated: true, completion: nil)
        
    }
}

extension Profile: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if self.pageMenu?.currentPageIndex == 0 {
            let  tblLocaion :CGPoint = self.view.convert(location, to: controller1.tableView)
            guard let indexPath = controller1.tableView.indexPathForRow(at: tblLocaion) else { return nil }
            
            guard let cell =  controller1.tableView.cellForRow(at: indexPath) else {
                return nil
            }
            let cellPoint = controller1.tableView.convert(tblLocaion, to: cell)
            
            
            controller1.icarouselView = cell.contentView.viewWithTag(110) as! iCarousel
            let p = cell.convert(cellPoint, to:controller1.icarouselView )
            
            
            guard let cview = controller1.icarouselView.itemView(at: p) else{
                return nil
            }
            let index = controller1.icarouselView.index(ofItemView: cview)
            
            let urlstring:String = ((controller1.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_url"))! as! String
            controller1.MediaType = ((controller1.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_type"))! as! String
            let mgrItm = PostManager.postManager
            mgrItm.clearManager()
            mgrItm.PostId="\(((controller1.arrayMedia.object(at: index) as AnyObject).value(forKey: "id"))!)"
            mgrItm.PostType = controller1.MediaType
            mgrItm.PostImg = urlstring
            mgrItm.postTag = index
            
            
            if ((controller1.arrayMedia.object(at: index) as AnyObject).value(forKey: "post_title")) is NSNull {
                
                mgrItm.PostText = ""
            }
            else {
                let post = ((controller1.arrayMedia.object(at: index) as AnyObject).value(forKey: "post_title")) as! String
                if post.contains("@@:-:@@") {
                    let arr = post.components(separatedBy: "@@:-:@@")
                    
                    if arr.count>0 {
                        mgrItm.PostText = arr[1]
                    }
                } else {
                    mgrItm.PostText = post
                }
            }
            
            controller1.videoUrl = URL(string: urlstring)
            
            if  ( controller1.MediaType == "video/quicktime" || controller1.MediaType == "audio/m4a" || controller1.MediaType == "audio/mp3" ||  controller1.MediaType == "video/mp4") {
                
                if (controller1.MediaType == "audio/m4a" || controller1.MediaType == "audio/mp3")
                {
                    UserDefaults.standard.set("y", forKey: "isoverlay")
                }
                else
                {
                    UserDefaults.standard.set("n", forKey: "isoverlay")
                }
                let strimg:String=(controller1.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
                
                UserDefaults.standard.set(strimg, forKey: "mediaimg")
                
            }
            
            let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
            VC1.Posttype=2;
            VC1.isViewComment=1;
            VC1.delegate = self
            VC1.preferredContentSize = CGSize(width: 0.0, height: 0.0)
            return VC1
        }
        if self.pageMenu?.currentPageIndex == 1 {
            var  tblLocaion :CGPoint = controller2.view.convert(location, to: controller2.tableView)
            
            tblLocaion.y = tblLocaion.y - imgProfile.frame.origin.y + 50
            
            guard let indexPath = controller2.tableView.indexPathForRow(at: tblLocaion) else {
                return nil
            }
            let cell =  controller2.tableView.cellForRow(at: indexPath)
            let cellPoint = controller2.tableView.convert(tblLocaion, to: cell)
            
            
            var p = cell!.convert(cellPoint, to:controller2.icarouselView)
            
            p.y = cellPoint.y - p.y
            
            
            let mgrItm = ItemManager.itemManager
            mgrItm.clearManager()
            guard let cview = controller2.icarouselView.itemView(at: p) else{
                return nil
            }
            let index = controller2.icarouselView.index(ofItemView: cview)
            
            
            if let itmID: Int  = (controller2.arrayMedia.object(at: index) as AnyObject).value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
            
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
            VC1.delegate = self
            VC1.preferredContentSize = CGSize(width: 0.0, height: 0.0)
            //previewingContext.sourceRect = cell!.frame
            return VC1
        }
        return nil
            
        //        guard let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("forceViewController")  else { return nil }
        //
        //        viewController.preferredContentSize = CGSize(width: 0, height: 0)
        
    }
    
    func openImage(_ sender: AnyObject) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = imgProfile.image
        imageInfo.referenceView = imgProfile
        imageInfo.referenceRect = imgProfile.bounds
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
        imageViewer?.show(from: self, transition: JTSImageViewControllerTransition.fromOriginalPosition)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

