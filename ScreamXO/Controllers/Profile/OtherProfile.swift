//
//  OtherProfile.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 03/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet var lblMsg: UILabel!
}

class OtherProfile: UIViewController,CAPSPageMenuDelegate,WYPopoverControllerDelegate,commentActionDelegate, UITableViewDelegate, UITableViewDataSource,ItemeditActionDelegate {
    
    // MARK: Properties
    
    enum friendShipType : NSInteger
    {
        case addFriend = 0,friend,reqfriend,recfriend,isblocked,isblockedbyhim
    }
    
    var pageMenu : CAPSPageMenu?
    var popoverController: WYPopoverController!
    var delegate : FriendActionDelegate!
    var friendType: Int = 0
    var offset:Int = 1
    var isAction:Bool = false
    var limit:Int = 4
    var totalShopCount:Int = 0
    var totalMediaCount:Int = 0
    var totalStreamPost:Int = 0
    
    @IBOutlet weak var friendsView: UIView!
    @IBOutlet weak var itemView: UIView!
    var controller1 : MediaBuffetVC!
    let controller2 : ShopBuffetVC = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "ShopBuffetVC") as! ShopBuffetVC;
    //let controller2 = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "ShopVc") as! ShopVc;
    let controller3 = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "StreamVC") as! StreamVC;
    
    var arrayShopItems = NSMutableArray()
    var arrayMediaItems = NSMutableArray()
    var arrayStream = NSMutableArray ()
    
    var arrayMsg: [String] = ["Direct", "Good Morning", "Good Evening", "Good Night", "Just Saying Hello", "What are you doing?", "SOS", "Thank You", "Sending my love", "On my way", "What's your favorite song?", "What's your favorite movie?", "What's your favorite meal?", "Call me"]
    
    var msgShown = false
    
    // MARK: IBOutlets
    
    @IBOutlet weak var lblfriends: UILabel!
    @IBOutlet weak var lblfriendsCount: UILabel!
    @IBOutlet weak var lblItems: UILabel!
    @IBOutlet weak var lblitemCount: UILabel!
    
    @IBOutlet weak var btnmoreInfo: UIButton!
    @IBOutlet weak var scrProfile: UIScrollView!
    
    @IBOutlet weak var lblFullname: UILabel!
    @IBOutlet weak var imgProfile: RoundImage!
    
    @IBOutlet weak var lblUniversity: UIButton!
    @IBOutlet weak var lblUsername: UILabel!
    
    @IBOutlet var btnMsg: UIButton!
    @IBOutlet var tblMsg: UITableView!
    
    // MARK: UIViewControllerOverridenMethods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }
        
        
        tblMsg.delegate = self
        tblMsg.dataSource = self
        tblMsg.isHidden = true
        btnMsg.isHidden = true
        controller1    = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "MediaBuffetVC") as! MediaBuffetVC;
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(OtherProfile.openImage(_:)))
        imgProfile.addGestureRecognizer(tapGesture)
        self.automaticallyAdjustsScrollViewInsets = false
        self.setupMenuClass()
        if( traitCollection.forceTouchCapability == .available){
            registerForPreviewing(with: self, sourceView:self.view)
        }
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
         NotificationCenter.default.addObserver(self, selector: #selector(handleUpdatedData), name: NSNotification.Name(rawValue: "closeImage"), object: nil)
        
        
        //imgProfile.layer.borderWidth = 2
//        imgProfile.layer.borderColor = UIColor.white.cgColor

        friendsView.layer.borderWidth = 10
        friendsView.layer.borderColor = (UIColor.white).cgColor
        
        itemView.layer.borderWidth = 10
        itemView.layer.borderColor = (UIColor.white).cgColor
        
        
//        imgProfile.contentMode=UIViewContentMode.scaleAspectFill
//        imgProfile.layer.cornerRadius = imgProfile.frame.size.height / 2
//        imgProfile.layer.masksToBounds = true//
        
        
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

        
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
        NotificationCenter.default.addObserver(self, selector: #selector(Profile.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         objAppDelegate.repositiongsm()
        if isAction == true
        {
            isAction = false
            if self.delegate == nil
            {
            }
            else
            {
                self.delegate.actionOnData()
            }
        }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "sharemedia"), object: nil)
    }
    
    
    
    func handleUpdatedData(notification: NSNotification) {
        
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
        
        
        
        
//        imgProfile.layer.borderWidth = 10
//        imgProfile.layer.borderColor = UIColor.white.cgColor
//        
//        imgProfile.contentMode=UIViewContentMode.scaleAspectFill
//        imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height / 2
//        imgProfile.layer.masksToBounds = true
//       // imgProfile.layer.shadowPath = UIBezierPath(roundedRect: imgProfile.bounds, cornerRadius: 10).cgPath

        
    }
    
    
    // MARK: IBActions
    
    func actionOnDataItem() {
        offset=1
        getShopItem()
    }
    
    @IBAction func btnMoreInfoClicked(_ sender: AnyObject) {
        
        
        if (FriendsManager.friendsManager.users_info==1) {
            mainInstance.ShowAlertWithError("", msg: "This user is private")
        } else {
            if ((popoverController) != nil) {
                popoverController.dismissPopover(animated: true)
            }
            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "MoreInfoVC")) as UIViewController
            
            popoverController=WYPopoverController(contentViewController: VC1)
            popoverController.delegate = self;
            popoverController.popoverContentSize=CGSize(width: 247, height: 210)
            
            popoverController.presentPopover(from: btnmoreInfo.bounds, in: btnmoreInfo, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        }
        
    }
    
    @IBAction func btnSendMsgClicked(_ sender: AnyObject) {
        let mgrfriend = FriendsManager.friendsManager
        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.otherID = Int(mgrfriend.FriendID)!
        chatVC.userName = mgrfriend.FriendName
        
        self.navigationController?.pushViewController(chatVC, animated: true)
        
    }
    
    @IBAction func btnsendMoneyClicked(_ sender: AnyObject) {
         let mgrfriend = FriendsManager.friendsManager
        let sendMoneyVC = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "TransferMoneyVC") as! TransferMoneyVC
        sendMoneyVC.toUserId = mgrfriend.FriendID
        sendMoneyVC.toFriendName = mgrfriend.FriendName
        sendMoneyVC.profileSendMoneyFlag = true
        self.navigationController?.pushViewController(sendMoneyVC, animated: true)
        
    }
    
    @IBAction func btnMoreOptionCLicked(_ sender: AnyObject) {
        
        let mgrfriend = FriendsManager.friendsManager
        
        if friendType == friendShipType.addFriend.rawValue {
            
            
            let alert:UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let cameraAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.BlockFriend()
                self.friendType=4
                
                self.isAction = true
            }
            let gallaryAction = UIAlertAction(title: "Add Friend", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.Addfriend()
                self.friendType=2
                self.isAction = true
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            
            let button = sender as! UIButton
            if (IS_IPAD) {
                
                alert.popoverPresentationController!.sourceRect = button.bounds;
                alert.popoverPresentationController!.sourceView = button;
                
            }
            // Present the actionsheet
            self.present(alert, animated: true, completion: nil)
            
        }
            
        else if friendType == friendShipType.friend.rawValue {
            
            let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let cameraAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.BlockFriend()
                self.friendType=4
                
                //self.delegate.actionOnData();
                self.isAction = true
            }
            let gallaryAction = UIAlertAction(title: "Un Friend", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.Unfriend()
                self.friendType=0
                self.lblfriendsCount.text = "\(Int(self.lblfriendsCount.text!)! - 1)"
                self.isAction = true
            }
            
            let messageAction = UIAlertAction(title: "Share", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                let mgrfriend = FriendsManager.friendsManager
                let chatVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                chatVC.shareFlag = true
                print(mgrfriend.FriendPhoto)
                chatVC.shareUrl = mgrfriend.FriendPhoto
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
            
            let sendMoneyAction = UIAlertAction(title: "Send Money", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let sendMoneyVC = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "TransferMoneyVC") as! TransferMoneyVC
//                chatVC.otherID = Int(mgrfriend.FriendID)!
//                chatVC.userName = mgrfriend.FriendName
                sendMoneyVC.toUserId = mgrfriend.FriendID
                sendMoneyVC.toFriendName = mgrfriend.FriendName
                sendMoneyVC.profileSendMoneyFlag = true
                self.navigationController?.pushViewController(sendMoneyVC, animated: true)
            }
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(messageAction)
            alert.addAction(sendMoneyAction)
            alert.addAction(cancelAction)
            
            let button = sender as! UIButton
            if (IS_IPAD) {
                
                alert.popoverPresentationController!.sourceRect = button.bounds;
                alert.popoverPresentationController!.sourceView = button;
                
            }
            // Present the actionsheet
            self.present(alert, animated: true, completion: nil)
            
        }
        else if friendType == friendShipType.reqfriend.rawValue
        {
            let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let cameraAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.BlockFriend()
                self.friendType=4
                
                //self.delegate.actionOnData();
                self.isAction = true
                
                
                
            }
            let gallaryAction = UIAlertAction(title: "Cancel Request", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                self.isAction = true
                self.friendType=0
                
                
                mgrfriend.cancelfriend()
                //self.delegate.actionOnData();
                
                
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alert.addAction(cameraAction)
            alert.addAction(gallaryAction)
            alert.addAction(cancelAction)
            
            let button = sender as! UIButton
            if (IS_IPAD)
            {
                
                alert.popoverPresentationController!.sourceRect = button.bounds;
                alert.popoverPresentationController!.sourceView = button;
                
            }
            // Present the actionsheet
            self.present(alert, animated: true, completion: nil)
            
        }
        else if friendType == friendShipType.recfriend.rawValue
            
        {
            
            let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let blockAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.BlockFriend()
                self.friendType=4
                
                // self.delegate.actionOnData();
                self.isAction = true
                
                
                
            }
            let acceptAction = UIAlertAction(title: "Accept Request", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.AcceptRequest()
                self.lblfriendsCount.text = "\(Int(self.lblfriendsCount.text!)! + 1)"
                self.isAction = true
                self.friendType=1
            }
            let rejectAction = UIAlertAction(title: "Reject Request", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                
                mgrfriend.rejectRequest()
                //self.delegate.actionOnData();
                self.friendType=0
                
                self.isAction = true
                
                
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alert.addAction(acceptAction)
            alert.addAction(rejectAction)
            alert.addAction(blockAction)
            alert.addAction(cancelAction)
            
            let button = sender as! UIButton
            if (IS_IPAD)
            {
                
                alert.popoverPresentationController!.sourceRect = button.bounds;
                alert.popoverPresentationController!.sourceView = button;
                
            }
            // Present the actionsheet
            self.present(alert, animated: true, completion: nil)
            
        }
        else if friendType == friendShipType.isblocked.rawValue
            
        {
            
            
            let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let blockAction = UIAlertAction(title: "UnBlock", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                mgrfriend.UnBlockFriend()
                self.friendType=0
                
                //self.delegate.actionOnData();
                self.isAction = true
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alert.addAction(blockAction)
            alert.addAction(cancelAction)
            
            let button = sender as! UIButton
            if (IS_IPAD)
            {
                
                alert.popoverPresentationController!.sourceRect = button.bounds;
                alert.popoverPresentationController!.sourceView = button;
                
            }
            // Present the actionsheet
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }

    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func btnMsgClicked(_ sender: UIButton) {
        
        let mgrfriend = FriendsManager.friendsManager
        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.otherID = Int(mgrfriend.FriendID)!
        chatVC.userName = mgrfriend.FriendName
        
        self.navigationController?.pushViewController(chatVC, animated: true)
        
//        if tblMsg.isHidden == true {
//            tblMsg.isHidden = false
//        } else {
//            tblMsg.isHidden = true
//        }
    }
    
    
    // MARK: Methods
    
    // MARK: --action delgate Method
    
    func actionOnData() {
        offset=1
        getStreamPost()
        getMediaItem()
    }
    
    //MARK: - Open Image VIewer  -
    
    func openImage(_ sender: AnyObject) {
        let imageInfo = JTSImageInfo()
        imageInfo.image = imgProfile.image
        imageInfo.referenceView = imgProfile
        imageInfo.referenceRect = imgProfile.bounds
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
        imageViewer?.show(from: self, transition: JTSImageViewControllerTransition.fromOriginalPosition)
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
        controller1.PaginationCallback = getDataForType

        controllerArray.append(controller1)
        controller2.title = "Shop"
        controller2.parentCnt=self
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
         pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: self.imgProfile.frame.origin.y + self.imgProfile.frame.height , width: self.scrProfile.frame.width, height: self.scrProfile.frame.size.height + 50 - (self.imgProfile.frame.origin.y + self.imgProfile.frame.height )), pageMenuOptions: parameters)
        pageMenu?.delegate = self
        self.addChildViewController(pageMenu!)
        pageMenu!.view.layoutIfNeeded()
        scrProfile.insertSubview((pageMenu?.view)!, belowSubview: btnMsg)
        self.getMediaItem()
        self.userInfo()
    }
    // MARK: --WebService Method
    
    func getShopItem()
    {
        let usr = UserManager.userManager

        let mgrfriend = FriendsManager.friendsManager
        //let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(mgrfriend.FriendID, forKey: "uid")
        parameterss.setValue(usr.userId, forKey: "myid")

        if arrayShopItems.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Items", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getShopItems(parameterss, successClosure: { (dic, result) -> Void in
            
            print(dic)
            SVProgressHUD.dismiss()
           // UIApplication.shared.endIgnoringInteractionEvents()

            if result == APIResult.apiSuccess
            {
                    if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                    {
                        self.totalShopCount = countShop
                    }
                    
                    if self.offset == 1
                    {
                        self.arrayShopItems.removeAllObjects()
                        self.arrayShopItems = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "items") as! NSArray).mutableCopy() as? NSMutableArray)!
                    }
                    else
                    {
                        if (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "items")! as! NSArray).count > 0) {
                            self.arrayShopItems.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "items")! as? [AnyObject])!)
                        }
                    }
                self.controller2.arrayMedia=self.arrayShopItems
                self.controller2.totalCount=self.totalShopCount
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
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
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

    
    
    func getMediaItem()
    {
        
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager

       // let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(mgrfriend.FriendID, forKey: "uid")
        parameterss.setValue("1", forKey: "posttype")
        parameterss.setValue(usr.userId, forKey: "myid")
        print(parameterss)

        if arrayShopItems.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Media", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getPostPlain(parameterss, successClosure: { (dic, result) -> Void in
            
            SVProgressHUD.dismiss()
            print(dic)
           // UIApplication.shared.endIgnoringInteractionEvents()
            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                {
                    self.totalMediaCount = countShop
                }
             
                
                if self.offset == 1
                {
                    
                    if let ftype :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friendshipstate") as? Int
                    {
                        if let ffid :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friendshipid") as? Int
                        {
                           
                            mgrfriend.friendConnectionID =  "\(ffid)"
                        }
                        self.friendType = ftype
                    }
                    
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
                    self.arrayMediaItems = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray).mutableCopy() as? NSMutableArray)!
                    
                }
                else
                {
                    let tmpArray = NSMutableArray(array: (dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as! [AnyObject])
                    self.arrayMediaItems.addObjects(from: tmpArray as [AnyObject])
                }
                self.controller1.arrayMedia=self.arrayMediaItems
                self.controller1.totalCount=self.totalMediaCount
                self.controller1.tableView.layoutIfNeeded()
                self.controller1.tableView.reloadData()
                
                if self.friendType == friendShipType.friend.rawValue {
                    //self.btnMsg.isHidden = true
                } else {
                    self.btnMsg.isHidden = true
                }
                
                SVProgressHUD.dismiss()
           }
                
            else if result == APIResult.apiError
            {
                print(dic)
                
                self.friendType = (dic?.value(forKey: "result")! as AnyObject).value(forKey: "friendshipstate") as! Int
                
                SVProgressHUD.dismiss()
                if self.msgShown == false {
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    self.msgShown = true
                }
            }
            else
             {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    func getStreamPost()
    {
        
        limit=10
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrfriend = FriendsManager.friendsManager

        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(mgrfriend.FriendID, forKey: "uid")
        parameterss.setValue(usr.userId, forKey: "myid")

        parameterss.setValue("0", forKey: "posttype")

        if arrayStream.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Stream", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getPostPlain(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
          //  UIApplication.shared.endIgnoringInteractionEvents()

            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                {
                    self.totalStreamPost = countShop
                }
                
                if self.offset == 1
                {
                    self.arrayStream.removeAllObjects()
                    self.arrayStream = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray).mutableCopy() as? NSMutableArray)!
                    
                }
                else
                {
                    self.arrayStream.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as? NSArray)!.mutableCopy() as! [AnyObject])
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
                mainInstance.showSomethingWentWrong()
            }
        })
    }

    
    
    // MARK: - delegate methods

    
    func willMoveToPage(_ controller: UIViewController, index: Int)
    {
        offset=1;
        
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
    
    func userInfo() {
        
        let mgrfriend = FriendsManager.friendsManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrfriend.FriendID, forKey: "userid")
        
        mgr.getUserInfo(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                SVProgressHUD.dismiss()
                mgrfriend.FriendName = "\(dic!.value(forKeyPath: "result.userdetail.firstname") as! String) "  +  " \(dic!.value(forKeyPath: "result.userdetail.lastname") as! String)"
                mgrfriend.friendCity = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "city") as? String
                mgrfriend.FUsername = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "username") as? String
                mgrfriend.FriendPhoto = (dic!.value(forKeyPath: "result.userdetail.photo") as! String)
                mgrfriend.friendSchool = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "school") as? String
                mgrfriend.friendJob = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "job") as? String
                mgrfriend.friendHobby = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "hobbies") as? String
                mgrfriend.friendGender = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "gender") as? String
                mgrfriend.friendsexpref = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "sexpreference") as? String
                mgrfriend.friendrelstatus = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "userdetail")! as AnyObject).value(forKey: "realtionstatus") as? String)!
                mgrfriend.users_media = Int(dic?.value(forKeyPath: "result.userdetail.users_media") as! String)!
                mgrfriend.users_shop = Int(dic?.value(forKeyPath: "result.userdetail.users_shop") as! String)!
                mgrfriend.users_buffet = Int(dic?.value(forKeyPath: "result.userdetail.users_buffet") as! String)!
                mgrfriend.users_info = Int(dic?.value(forKeyPath: "result.userdetail.users_info") as! String)!
                
                self.lblFullname.text = mgrfriend.FriendName
                
                if mgrfriend.FriendPhoto != nil {
                    self.imgProfile.sd_setImageWithPreviousCachedImage(with: URL(string: mgrfriend.FriendPhoto!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                    })
                    self.imgProfile.contentMode=UIViewContentMode.scaleAspectFill
                    self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.height / 2
//                    self.imgProfile.layer.masksToBounds = true
                }
                
                if ((mgrfriend.FUsername != nil && !( mgrfriend.FUsername == ""))) {
                    self.lblUsername.text =  "@\(mgrfriend.FUsername!)"
                    self.pageMenu?.view.frame = CGRect(x: 0.0, y: self.imgProfile.frame.origin.y + self.imgProfile.frame.height, width: self.scrProfile.frame.width, height: self.scrProfile.frame.size.height - (self.imgProfile.frame.origin.y + self.imgProfile.frame.height ))
                } else {
                    self.lblUsername.text =  "@Social"
                    self.pageMenu?.view.frame = CGRect(x: 0.0, y: self.imgProfile.frame.origin.y + self.imgProfile.frame.height, width: self.scrProfile.frame.width, height: self.scrProfile.frame.size.height - (self.imgProfile.frame.origin.y + self.imgProfile.frame.height ))
                }
            } else if result == APIResult.apiError {
                SVProgressHUD.dismiss()
                if self.msgShown == false {
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    self.msgShown = true
                }
                
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: - share media
    
    func sharemedia() {
        let textToShare = ""
        
        let mgrItm = PostManager.postManager
        
        let objectsToShare = [textToShare, mgrItm.PostImg]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: UITableViewDelegateMethods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCell
        
        cell.lblMsg.text = arrayMsg[indexPath.row]
        if arrayMsg[indexPath.row] == "SOS" {
            cell.lblMsg.textColor = UIColor.red
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if arrayMsg[indexPath.row] == "Direct" {
            let mgrfriend = FriendsManager.friendsManager
            let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
            chatVC.otherID = Int(mgrfriend.FriendID)!
            chatVC.userName = mgrfriend.FriendName
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        } else {
            self.sendMessages(arrayMsg[indexPath.row])
        }
    }
    
    // MARK: ChatServices
    
    func sendMessages(_ message: String)  {
        
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(Int(usr.userId!)!, forKey: "fromid")
        parameterss.setValue(Int(mgrfriend.FriendID)!, forKey: "toid")
        parameterss.setValue(1, forKey: "messagetype")
        parameterss.setValue(message, forKey: "messagedetail")
        
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        
        mgr.sendChatMsg(parameterss, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                mainInstance.ShowAlert("ScreamXO", msg: dictMy?.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                let mgrfriend = FriendsManager.friendsManager
                let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                chatVC.otherID = Int(mgrfriend.FriendID)!
                chatVC.userName = mgrfriend.FriendName
                
                self.navigationController?.pushViewController(chatVC, animated: true)
                
            } else if result == APIResult.apiError {
                mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
}
extension OtherProfile: UIViewControllerPreviewingDelegate {
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
            
            tblLocaion.y = tblLocaion.y - (btnMsg.frame.origin.y)+50
            
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
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}
