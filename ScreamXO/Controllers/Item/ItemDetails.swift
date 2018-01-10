//
//  ItemDetails.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 05/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class ShippingCell: UITableViewCell {
    @IBOutlet var imguserpur: RoundImage!
    @IBOutlet var lblname: UILabel!
    @IBOutlet var lblshipping: UILabel!
    @IBOutlet var btnAddTrackDetail: UIButton!
    @IBOutlet var constBtnAddTrackHeight: NSLayoutConstraint!
    @IBOutlet var viewMain: UIView!
    
    
    override func awakeFromNib() {
        self.layoutIfNeeded()
//        viewMain.layer.borderWidth = 1.0
//        viewMain.layer.borderColor = UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0).cgColor
    }
}

protocol ItemActionDelegate  {
    func actionOnData()
    func actiondeleteOnData()
}

protocol ItemeditActionDelegate  {
    func actionOnDataItem()
}

protocol ItemWatchDelegate {
    func actionOnWatch(isWatch: Bool, index: Int)
}

class ItemDetails: UIViewController, ItemActionDelegate, UITableViewDelegate, UITableViewDataSource , UIScrollViewDelegate {

    // MARK: IBOutlets
    
    @IBOutlet weak var scrDataLoad: UIScrollView!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var lblItemPrice: UILabel!
    @IBOutlet weak var imgItemPhoto: UIImageView!
    @IBOutlet weak var imgUserPhoto: UIImageView!
    @IBOutlet weak var lbllocation: UILabel!
    @IBOutlet weak var lblUname: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet var viewShipping: UIView!

    @IBOutlet weak var userCircleImg: UIImageView!
    @IBOutlet weak var imguserpur: RoundImage!
    @IBOutlet var btnBuy: UIButton!
    @IBOutlet var btnWatched: UIButton!
    @IBOutlet weak var btnUserpurchase: UIButton!
    @IBOutlet weak var caroselITM: iCarousel!
    @IBOutlet var btnDirect: UIButton!
    @IBOutlet var btnQuick: UIButton!
    @IBOutlet var viewDirect: UIView!
    @IBOutlet var viewQuick: UIView!
    
    @IBOutlet var btnpayment: UIButton!
    @IBOutlet var btncondition: UIButton!
    
    @IBOutlet var tblShipping: UITableView!
    @IBOutlet var btnReview: UIButton!
    
    @IBOutlet var addTrackingView: UIView!
    @IBOutlet var txtCourierName: UITextField!
    @IBOutlet var txtTrackNo: UITextField!
    @IBOutlet var superAddTrackView: UIView!
    @IBOutlet var viewAllOptions: UIView!
    @IBOutlet var viewDetail: UIView!
    @IBOutlet var viewMsgSubHead: UIView!
    @IBOutlet var lblItmName: UILabel!
    @IBOutlet weak var lblItmCondition: UITextField!
    @IBOutlet weak var lblItmShipping: UITextField!
    @IBOutlet weak var lblItemLocation: UITextField!
    
    
    // MARK: ConstraintOutlets

    @IBOutlet weak var constItmDetailHeight: NSLayoutConstraint!
    
    // MARK: New ConstraintOutlets
    
    @IBOutlet var constViewDetailHeight: NSLayoutConstraint!
    
    // MARK: Properties
    
    var dicDataItem: NSDictionary!
    var delegate : ItemeditActionDelegate!
    var delegateAddItem : AddItemDelgate!
    var delegateHomeWatch: ItemWatchDelegate?
    var delegatewatch : watchDelgate?
    var arrayImages: NSMutableArray = []
    var arrayImagesTemp: NSMutableArray = []
    var iswatched : Bool = false
    let viewDirectName = "viewDirect"
    let viewQuickName = "viewQuick"
    let viewAddTrack = "viewAddTrack"
    var purchaserArray: NSArray?
    var noRowsPurchaseData: Int?
    var orderID: Int?
    var reviewArray: NSArray?
    var noRowsReviewData: Int?
    
    let tblReview = "tblReview"
    let tblPurchase = "tblPurchase"
    var tblName: String = ""
    var isUpdate: Bool?
    var itemRemainStatus = 0
    var isAddTrack = false
    var btnBgColor = UIColor()
    
    var item_id: Int!
    var  boost_type: Int!
    
    // MARK: Viewcontroller life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        constViewDetailHeight.constant = 0
        viewMsgSubHead.isHidden = true
        viewShipping.isHidden = true
        viewAllOptions.isHidden = true
        tblName = tblPurchase
        tblShipping.emptyDataSetSource = self
        tblShipping.emptyDataSetDelegate = self
        tblShipping.bounces = false
        viewDirect.isHidden = true
        viewQuick.isHidden = true
        tblShipping.delegate = self
        tblShipping.dataSource = self
        tblShipping.contentInset.top = 8.0
        tblShipping.estimatedRowHeight = 500
        tblShipping.rowHeight = UITableViewAutomaticDimension
        
        tblShipping.separatorColor = UIColor.clear
        tblShipping.isScrollEnabled = true
        
        scrDataLoad.delaysContentTouches = true
        self.automaticallyAdjustsScrollViewInsets=false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ItemDetails.openImage(_:)))
        imgItemPhoto.addGestureRecognizer(tapGesture)
        
        let tapGesturea = UITapGestureRecognizer(target: self, action: #selector(ItemDetails.openImage(_:)))
        imgUserPhoto.addGestureRecognizer(tapGesturea)
        scrDataLoad.isHidden=true;
        getItemDetails()
        btnBgColor = btnReview.backgroundColor!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        userCircleImg.layer.cornerRadius = userCircleImg.frame.width / 2
        userCircleImg.layer.masksToBounds = true

        if isAddTrack {
            superAddTrackView.isHidden = false
        } else {
            superAddTrackView.isHidden = true
        }
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 120.0
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
        
        // Hide status bar
        
        UIApplication.shared.isStatusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
        
        // GSM operations
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        
        // Show status bar
        
        UIApplication.shared.isStatusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
        
        // MARK: gsm op
        
        objAppDelegate.repositiongsm()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    @IBAction func btnCloseTableClicked(_ sender: UIButton) {
        viewShipping.isHidden = true
    }
    
    @IBAction func btnViewDetailClicked(_ sender: UIButton) {
        viewMsgSubHead.isHidden = true
        viewItmButtonClicked(UIButton())
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: {
            if self.viewDetail.tag == 0 {
                self.constViewDetailHeight.constant = 160
                self.viewDetail.tag = 1
            } else {
                self.constViewDetailHeight.constant = 0
                self.viewDetail.tag = 0
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @IBAction func btnWatchedClicked(_ sender: AnyObject) {
        viewItmButtonClicked(btnWatched)
        let mgrItm = ItemManager.itemManager

        if btnWatched.tag == 0 {
            mgrItm.addWatchedItem(1,successClosure:{ (dic, result) -> Void in
            
            if result == APIResultItm.apiSuccess {
                self.btnWatched.setImage(UIImage(named: "ico_watch"), for: UIControlState())
                self.btnWatched.tag = 1
                if (self.delegatewatch != nil) {
                    self.delegatewatch?.actionOnwatchItm()
                }
                
                if self.delegateHomeWatch != nil {
                    self.delegateHomeWatch?.actionOnWatch(isWatch: true, index: mgrItm.itmTag)
                }
            }
            })
        } else {
            mgrItm.addWatchedItem(0,successClosure:{ (dic, result) -> Void in
                
                if result == APIResultItm.apiSuccess {
                    self.btnWatched.tag = 0
                    self.btnWatched.setImage(UIImage(named: "ico_unwatch"), for: UIControlState())
                    if (self.delegatewatch != nil) {
                        self.delegatewatch?.actionOnwatchItm()
                    }
                    
                    if self.delegateHomeWatch != nil {
                        self.delegateHomeWatch?.actionOnWatch(isWatch: false, index: mgrItm.itmTag)
                    }
                }
            })
        }
        
        if (delegatewatch != nil) {
            self.delegatewatch?.actionOnwatchItm()
        }
    }
    
    func btnBuyClicked(_ sender: AnyObject) {
        
        let mgrItm = ItemManager.itemManager
        
        if mgrItm.ispaymentKind=="0" {
            
            mainInstance.ShowAlertWithError("Error!", msg: "you can not purchase this item!! seller has not configured payment gateway")
        } else {
            
            let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "ConfigureBuyPaymentVC")) as! ConfigureBuyPaymentVC
             VC1.isShopFlag = true
            self.navigationController?.pushViewController(VC1, animated: true)
            
            
//            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "PaymentDetailsVC")) as! PaymentDetailsVC
//            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func btnBoostClicked(_ sender: UIButton) {
        let boostViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BoostViewController") as! BoostViewController
        let mgrItm = ItemManager.itemManager
        boostViewController.item_id =  Int(mgrItm.ItemId)!
        boostViewController.boost_type =  1
        self.navigationController?.pushViewController(boostViewController, animated: true)
    }
    
    @IBAction func btnUserProfileClickedpurchase(_ sender: AnyObject) {
        
        
        let mgrfriend = FriendsManager.friendsManager
        let usrMger = UserManager.userManager

        //mgrfriend.clearManager()
        
        mgrfriend.FriendName = "\((self.dicDataItem?.value(forKey: "result") as AnyObject).value(forKey: "purchasefname") as! String)"  +  " \((self.dicDataItem?.value(forKey: "result") as AnyObject).value(forKey: "purchaselname") as! String)"
        mgrfriend.FriendPhoto = "\((self.dicDataItem?.value(forKey: "result") as AnyObject).value(forKey: "purchaseuserphoto") as! String)"
        mgrfriend.FUsername = "\((self.dicDataItem?.value(forKey: "result") as AnyObject).value(forKey: "purchaseusername") as! String)"
        
        mgrfriend.FriendID = "\((self.dicDataItem?.value(forKey: "result") as AnyObject).value(forKey: "purchaseuserid") as! Int as Int)"
        
        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
        
        if (usrMger.userId != mgrfriend.FriendID) {
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func viewItmButtonClicked(_ buttonType: UIButton) {
        
         if btnReview.tag == 1 && btnReview != buttonType {
            btnReview.tag = 0
            btnReview.titleLabel?.font = fonts.KfontproxisemiBold
            btnReview.backgroundColor = btnBgColor
            btnReview.setBackgroundImage(UIImage(), for: UIControlState())
            self.viewShipping.isHidden = true
        }
        if(viewQuick.tag == 1 || viewDirect.tag == 1) {
            
            if viewDirect.tag == 1 || viewQuick.tag == 1 {
                self.hideView(viewDirectName)
                self.hideView(viewQuickName)
            }
        }
    }
    
    @IBAction func btnReviewClicked(_ sender: UIButton) {
        
        if btnReview.tag == 0 {
            viewItmButtonClicked(sender)
            btnReview.tag = 1
            btnReview.backgroundColor = UIColor.clear
            btnReview.titleLabel?.font = fonts.kfontproxiBold2
            
            viewShipping.isHidden = false
            
            tblName = tblReview
            self.tblShipping.isHidden = true
            self.tblShipping.reloadData()
            self.tblShipping.isHidden = false
            
            if self.viewDetail.tag == 1 {
                UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: {
                    self.constViewDetailHeight.constant = 0
                    self.viewDetail.tag = 0
                    self.view.layoutIfNeeded()
                }, completion: nil)
            }
            
        } else if btnReview.tag == 1 {
            
            btnReview.tag = 0
            btnReview.setBackgroundImage(UIImage(), for: UIControlState())
            btnReview.titleLabel?.font = fonts.KfontproxisemiBold
            btnReview.backgroundColor = btnBgColor
            viewShipping.isHidden = true

        }
    }
    
    @IBAction func btnDirectClicked(_ sender: UIButton) {
        
        if viewQuick.tag == 1 {
            self.hideView(viewQuickName)
        }
        if viewDirect.tag == 0 {
            self.showView(viewDirectName)
        } else if viewDirect.tag == 1 {
            self.hideView(viewDirectName)
        }
    }
    
    @IBAction func btnQuickClicked(_ sender: UIButton) {
        if viewDirect.tag == 1 {
            self.hideView(viewDirectName)
        }
        if viewQuick.tag == 0 {
            self.showView(viewQuickName)
        } else if viewQuick.tag == 1 {
            self.hideView(viewQuickName)
        }
    }
    
    @IBAction func btnSendDirectMsg(_ sender: UIButton) {
        print(sender.currentTitle!)
        let mgrfriend = FriendsManager.friendsManager
        let mgrItm = ItemManager.itemManager

        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.otherID = Int(mgrfriend.FriendID)
        chatVC.user_name = mgrfriend.FUsername
        chatVC.directMsgType = sender.currentTitle!
        chatVC.item_id = Int(mgrItm.ItemId)!
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @IBAction func btnSendQuickMsg(_ sender: UIButton) {
        self.sendMessages(sender.currentTitle!)
    }
    
    func btnAddTrackDetailClicked(_ sender: UIButton) {
        let dictEntry = self.purchaserArray![sender.tag] as? [String: AnyObject]
        self.orderID = dictEntry!["order_id"] as? Int
        print(dictEntry)
        self.showView(viewAddTrack)
    }
    
    func btnCopyTrackDetail(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let copyAction = UIAlertAction(title: "Copy", style: .default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            let dictEntry = self.purchaserArray![sender.tag] as? [String: AnyObject]
            let trackDetail = dictEntry!["trackingdetail"] as? [String: AnyObject]
            UIPasteboard.general.string = String(describing: trackDetail!["trackingid"]!)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(copyAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnTrackDoneClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        txtCourierName.text = txtCourierName.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        txtTrackNo.text = txtTrackNo.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if txtCourierName.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter courier company name")
        } else if txtTrackNo.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter track no.")
        } else {
            self.hideView(viewAddTrack)
            self.addTrackingDetail()
        }
    }
    
    @IBAction func btnTrackCancelClicked(_ sender: UIButton) {
        self.view.endEditing(true)
        txtCourierName.text = ""
        txtTrackNo.text = ""
        self.hideView("viewAddTrack")
    }

    // MARK: Tableview Delegates
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tblName == tblPurchase {
            if noRowsPurchaseData == nil {
                return 0
            } else {
                return noRowsPurchaseData!
            }
        } else if tblName == tblReview {
            if noRowsReviewData == nil {
                return 0
            } else {
                return noRowsReviewData!
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShippingCell") as! ShippingCell
        let usr = UserManager.userManager
        
        if tblName == tblPurchase {
            
            cell.btnAddTrackDetail.isHidden = false
            cell.constBtnAddTrackHeight.isActive = false

            let dictEntry = self.purchaserArray![indexPath.row] as? [String: AnyObject]
            let stefullname: String = (dictEntry!["purchasefname"] as? String)!
            
            if (usr.fullName == stefullname) {
                
                cell.lblname.text =  "Purchased by Me"
            } else {
                
                cell.lblname.text =  "Purchased by \(dictEntry!["purchasefname"] as! String)"  +  " \(dictEntry!["purchaselname"] as! String)"
            }
            let itmphotopur:String = dictEntry!["purchaseuserphoto"] as! String
            
            cell.imguserpur.sd_setImageWithPreviousCachedImage(with: URL(string: itmphotopur), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            cell.lblshipping.text =  "Shipping Address: \(dictEntry!["shippingaddress"] as! String)"
            
            let addedTrackDetail = dictEntry!["hastrackingdetail"] as! Bool
            
            if !addedTrackDetail {
                cell.btnAddTrackDetail.setTitle("Add Tracking Detail", for: UIControlState())
                cell.btnAddTrackDetail.tag = indexPath.row
                cell.btnAddTrackDetail.addTarget(self, action: #selector(btnAddTrackDetailClicked), for: .touchUpInside)
                cell.btnAddTrackDetail.isEnabled = true
            } else {
                
                let trackDetail = dictEntry!["trackingdetail"] as? [String: AnyObject]
                cell.btnAddTrackDetail.titleLabel?.numberOfLines = 1
                cell.btnAddTrackDetail.titleLabel?.adjustsFontSizeToFitWidth = true
                cell.btnAddTrackDetail.titleLabel?.minimumScaleFactor = 0.01
                cell.btnAddTrackDetail.setTitle("Tracking No. : \(trackDetail!["trackingid"]!) ", for: UIControlState())
                cell.btnAddTrackDetail.removeTarget(self, action: #selector(btnAddTrackDetailClicked), for: .touchUpInside)
                cell.btnAddTrackDetail.addTarget(self, action: #selector(btnCopyTrackDetail), for: .touchUpInside)
                
                cell.btnAddTrackDetail.isEnabled = true
                cell.btnAddTrackDetail.tag = indexPath.row
            }
            
        } else if tblName == tblReview {
            
            let dictEntry = self.reviewArray![indexPath.row] as? [String: AnyObject]
            
            cell.lblname.text =  "\(dictEntry!["reviewfname"] as! String)"  +  " \(dictEntry!["reviewlname"] as! String)"
            let itmphotopur:String = dictEntry!["reviewuserphoto"] as! String
            
            cell.imguserpur.sd_setImageWithPreviousCachedImage(with: URL(string: itmphotopur), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            cell.lblshipping.text =  dictEntry!["description"] as? String
            cell.constBtnAddTrackHeight.isActive = true
            cell.constBtnAddTrackHeight.constant = 0
            cell.btnAddTrackDetail.isHidden = true
            cell.selectionStyle = .none
        }
        return cell
    }
    
    
    
    
    
    
    // MARK: Swipe from bottom
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
//            switch swipeGesture.direction {
//                
//            case UISwipeGestureRecognizerDirection.up:
//                self.navigationController?.popViewController(animated: true)
//            default:
//                break
//            }
//        }
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

    // MARK: - refesh item Details delgate
    
    func actionOnData() {
        getItemDetails()
        if self.delegate == nil
        {
        }
        else
        {
        self.delegate.actionOnDataItem()
        }

        
    }
    func actiondeleteOnData()
    {

        if self.delegate == nil
        {
        }
        else
        {
        self.delegate.actionOnDataItem()
        }
        
        
    }
    
    // MARK: iCarousel methods
    
    
    func numberOfItemsInCarousel (_ carousel : iCarousel) -> NSInteger
    {
        
        return arrayImages.count
    }
    func carousel(_ carousel: iCarousel!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        var view = view
        
        //    let contentView : UIView?
        var imgPic : UIImageView
        
        if view == nil
        {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width, height: carousel.frame.size.height)
            
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            imgPic.contentMode=UIViewContentMode.scaleAspectFill
            
            
            imgPic.tag = 105
            view?.addSubview(imgPic)
            
        }
        else
        {
            imgPic = view?.viewWithTag(105) as! UIImageView
            
        }
        
        let strimg:String=(self.arrayImages.object(at: index) as AnyObject).value(forKey: "media_url")! as! String

        
        imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
        })
        return view
    }
   
    func carousel(_ carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .spacing)
        {
            return value * 1.2
        }
        
        return value
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAtIndex index: Int) {
        
        let vc = UIStoryboard(name:"ImageViewer",bundle: nil).instantiateViewController(withIdentifier: "ImageViewerViewController") as! ImageViewerViewController
        vc.arrayImages = self.arrayImages
        vc.Index = index
        self.present(vc, animated:true, completion:nil)
    }
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let likeAction = UIPreviewAction(title: "Close", style: .default) { (action, viewController) -> Void in
            print("Close")
        }
        return [likeAction]
    }
    
    // MARK: GSM Method
    
    func btnGSMClicked(_ btnIndex: Int) {
        switch btnIndex {
        case 0:
            let VC1 = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN") as? SellItemVC
            navigationController?.pushViewController(VC1!, animated: true)
            
        case 6:
            if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
                
                if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                    sideMenuLeftVC.sideMenuViewController.hideViewController()
                    objAppDelegate.setViewAfterLogin()
                }
                if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                    sideMenuLeftVC.selectedrow = 0
                }
            }
            
        case 7:
            let alertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
            
            let reportsAction = UIAlertAction(title: "Report", style: .destructive , handler: {
                
                UIAlertAction in
                alertController.dismiss(animated: true, completion: nil)
                let mgrpost = ItemManager.itemManager
                mgrpost.reportItemPost()
                
//                self.isUpdate = true
//                let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "EditItemVC")) as! EditItemVC
//                VC1.delegate=self
//                self.navigationController?.pushViewController(VC1, animated: true)
            })

            
            let editAction = UIAlertAction(title: "Edit Item", style: .default, handler: {
                
                UIAlertAction in
                alertController.dismiss(animated: true, completion: nil)
                
                self.isUpdate = true
               // let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN")) as! SellItemVC
                //VC1.editItemFlag = true
                let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "EditItemVC")) as! EditItemVC
                VC1.delegate=self
                self.navigationController?.pushViewController(VC1, animated: true)
            })
            
            let shareAction = UIAlertAction(title: "Share Item", style: .default, handler: {
                
                UIAlertAction in
                alertController.dismiss(animated: true, completion: nil)
                
                let mgrItm = ItemManager.itemManager
                
                var textToShare = ""
                var url = mgrItm.ItemImg
                
                if ((url) != nil) {
                    textToShare = "\(mgrItm.ItemName)\n\n\(mgrItm.ItemDescription)"
                    
                } else {
                    
                    url = ""
                    
                    textToShare = mgrItm.ItemDescription
                }
                
                if let myWebsite = URL(string: url!) {
                    let objectsToShare = [textToShare, myWebsite] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    
                    if (IS_IPAD) {
                        activityVC.popoverPresentationController!.sourceRect = self.view.bounds
                        activityVC.popoverPresentationController!.sourceView = self.view
                    }
                    self.present(activityVC, animated: true, completion: nil)
                }
            })
            
            let messageAction = UIAlertAction(title: "Send Message", style: .default, handler: {
                UIAlertAction in
                alertController.dismiss(animated: true, completion: nil)
                
                if self.viewDetail.tag == 1 {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: {
                        self.constViewDetailHeight.constant = 0
                        self.viewDetail.tag = 0
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
                
                self.viewItmButtonClicked(UIButton())
                
                if self.viewMsgSubHead.tag == 0 {
                    self.viewMsgSubHead.isHidden = !self.viewMsgSubHead.isHidden
                }
            })
            
            let purchaseHistoryAction = UIAlertAction(title: "Purchase History", style: .default, handler: {
                UIAlertAction in
                alertController.dismiss(animated: true, completion: nil)
                
                self.viewMsgSubHead.isHidden = true
                if self.viewDetail.tag == 1 {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .transitionFlipFromBottom, animations: {
                        self.constViewDetailHeight.constant = 0
                        self.viewDetail.tag = 0
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
                
                self.viewItmButtonClicked(UIButton())
                self.viewShipping.isHidden = false
                self.tblName = self.tblPurchase
                self.tblShipping.reloadData()
                self.tblShipping.isHidden = false
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                UIAlertAction in
                alertController.dismiss(animated: true, completion: nil)
            })
            
            let mgrItm = ItemManager.itemManager
            if mgrItm.isItemPurchase != "1" {
                if mgrItm.Itemmy == "1"{
                    alertController.addAction(editAction)
                } else {
                    alertController.addAction(reportsAction)
                    alertController.addAction(shareAction)
                    
                }
            }
            
            if mgrItm.Itemmy == "1" {
                if noRowsPurchaseData! > 0 {
                    alertController.addAction(purchaseHistoryAction)
                }
            } else {
                alertController.addAction(messageAction)
            }
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
            
        default:
            break
        }
    }
    
    // MARK: Methods
    
    func showView(_ viewName: String) {
        if viewName == viewDirectName {

            btnDirect.titleLabel?.font = fonts.kfontproxiBold2
            self.viewDirect.isHidden = false
            viewDirect.tag = 1
            
        } else if viewName == viewQuickName {
            
            self.viewQuick.isHidden = false
            viewQuick.tag = 1
            btnQuick.titleLabel?.font = fonts.kfontproxiBold2

        } else if viewName == viewAddTrack {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.superAddTrackView.isHidden = false
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    func hideView(_ viewName: String) {
        
        if viewName == viewDirectName {
            
            viewDirect.tag = 0
            viewDirect.isHidden = true
            btnDirect.titleLabel?.font = fonts.KfontproxisemiBold
            
        } else if viewName == viewQuickName {
            
            viewQuick.tag = 0
            viewQuick.isHidden = true
            btnQuick.titleLabel?.font = fonts.KfontproxisemiBold
            
        } else if viewName == viewAddTrack {
            UIView.animate(withDuration: 0.3, animations: {
                self.superAddTrackView.isHidden = true
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: CallWebService
    
    func addReview() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = ItemManager.itemManager
        let parameters = NSMutableDictionary()
        parameters.setValue(mgrItm.ItemId, forKey: "itemid")
        parameters.setValue(usr.userId, forKey: "uid")
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        
        
        mgr.addReview(parameters, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            print(dic!)
            
            if result == APIResult.apiSuccess {
                print(dic!)
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic?.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                print(dic!)
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

    func addTrackingDetail() {
        
        let mgr = APIManager.apiManager
        let mgrItm = ItemManager.itemManager
        let parameters = NSMutableDictionary()
        parameters.setValue(self.orderID!, forKey: "orderid")
        parameters.setValue(mgrItm.ItemId, forKey: "itemid")
        parameters.setValue(self.txtCourierName.text!, forKey: "companyname")
        parameters.setValue(self.txtTrackNo.text!, forKey: "trackingid")
        self.txtTrackNo.text = ""
        self.txtCourierName.text = ""
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "Fetching Details", maskType: SVProgressHUDMaskType.clear)
        
        mgr.addTrackingDetail(parameters, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                print(dictMy!)
                self.getPurchaseArray()
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
    }
    
    func sendMessages(_ message: String)  {
        
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = ItemManager.itemManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(Int(usr.userId!)!, forKey: "fromid")
        parameterss.setValue(Int(mgrfriend.FriendID)!, forKey: "toid")
        parameterss.setValue(1, forKey: "messagetype")
        parameterss.setValue(message, forKey: "messagedetail")
        
        parameterss.setValue(Int(mgrItm.ItemId)!, forKey: "itemid")
        
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        
        mgr.sendChatMsg(parameterss, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                
                SVProgressHUD.dismiss()
                let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                chatVC.otherID = Int(mgrfriend.FriendID)
                chatVC.user_name = mgrfriend.FUsername
                chatVC.item_id = Int(mgrItm.ItemId)!
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
    
    func getPurchaseArray() {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = ItemManager.itemManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrItm.ItemId, forKey: "itemid")
        parameterss.setValue(usr.userId, forKey: "myid")
        print(parameterss)
        mgr.getShopItemDetails(parameterss, successClosure: {(dic, result) -> Void in
            print(dic as Any)
            if result == APIResult.apiSuccess {
                self.purchaserArray = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "purchasedata") as? NSArray)!
                self.noRowsPurchaseData = self.purchaserArray!.count
                self.tblShipping.isHidden = true
                self.tblShipping.reloadData()
                self.tblShipping.isHidden = false
                 print(dic)
            } else if result == APIResult.apiError {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
            } else {
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func getItemDetails() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = ItemManager.itemManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrItm.ItemId, forKey: "itemid")
        parameterss.setValue(usr.userId, forKey: "myid")
        
        print(parameterss)
        
        if isUpdate != true {
            SVProgressHUD.show(withStatus: "Fetching Details", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.getShopItemDetails(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            print(dic!)
            
            if result == APIResult.apiSuccess {
                
                self.scrDataLoad.isHidden = false
                mgrItm.ItemName = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_name") as? String)!
                mgrItm.itemCondition = (dic?.value(forKey: "result") as AnyObject).value(forKey: "item_condition") as? String
                self.lblItmCondition.text = mgrItm.itemCondition
                self.lblItmName.text = mgrItm.ItemName
                
                // Shipping detail
                mgrItm.ItemShipingCost=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_shipping_cost") as! NSString as String
                self.lblItmShipping.text = mgrItm.ItemShipingCost
                self.lblItemLocation.text = usr.setcityKey
                //self.lblItmCondition.text = "New"
                
                        let itmImgString = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "userphoto")as! String
                        var imgurl: URL!
//                        if let imageURL = URL(string: itmImgString as! String) {
//                            imgurl = imageURL
//                            self.userCircleImg.sd_setImageWithPreviousCachedImage(with: imgurl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
//                            }, completed: { (img, error, type, url) -> Void in
//                            })
//                        } else {
//                            
//                        }
//
                
                self.txtDescription.text = (dic?.value(forKey: "result") as AnyObject).value(forKey: "item_description") as! NSString as String
                
                let contentSize = self.txtDescription.sizeThatFits(self.txtDescription.bounds.size)
                if contentSize.height > 200 {
                     self.scrDataLoad.contentSize = CGSize(width: self.view.frame.size.width, height: contentSize.height + 400 )
                }

                self.constItmDetailHeight.constant = contentSize.height
                
                mgrItm.ItemDescription=self.txtDescription.text
                let mgrfriend = FriendsManager.friendsManager
                
                self.dicDataItem = dic
                mgrfriend.FriendName = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "fname") as! String) "  +  " \((dic?.value(forKey: "result") as AnyObject).value(forKey: "lname") as! String)"
                mgrfriend.FriendPhoto = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "userphoto") as! String)"
                mgrfriend.FUsername = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "username") as! String)"
                mgrfriend.FriendID = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_created_by") as! String as String)"
                
                if (mgrfriend.FriendID == usr.userId) {
                    self.viewMsgSubHead.tag = 1
                }
                
                mgrItm.Itemmy =  "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "myitem") as! Int)"
                mgrItm.isItemPurchase =  (dic?.value(forKey: "result") as AnyObject).value(forKey: "ispurchased") as! String
                mgrItm.itm_qty = String(describing: ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_qty"))!)
                mgrItm.itm_qty_remain = String(describing: ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_qty_remained"))!)
                self.itemRemainStatus = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_qty_remained"))! as! Int
                let isbitcoinmail:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "bitcoinmail") as! String as String)"
                
                let actualprice:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_actualprice") as! String as String)"
                
                mgrItm.ItemactualPrice =  actualprice
                mgrItm.Itembitcoinmail = isbitcoinmail
                
                let isbitcoin:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "isbitcoin") as! Int as Int)"
                let ispaypal:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "ispaypal") as! Int as Int)"
                
                if (isbitcoin == "1" && ispaypal == "1" ) {
                    
                    mgrItm.ispaymentKind="3"
                } else if (isbitcoin == "1") {
                    
                    mgrItm.ispaymentKind="2"
                } else if (ispaypal == "1") {
                    
                    mgrItm.ispaymentKind="1"
                } else {
                    
                    mgrItm.ispaymentKind="0"
                }
                
                self.reviewArray = (dic?.value(forKey: "result") as AnyObject).value(forKey: "reviewdata") as? NSArray
                self.noRowsReviewData = self.reviewArray?.count
                
                if mgrItm.Itemmy == "1" {
                    self.purchaserArray = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "purchasedata") as? NSArray)!
                    self.noRowsPurchaseData = self.purchaserArray!.count
                    
                    self.btnBuy.setTitle("BOOST", for: .normal)
                    self.btnBuy.addTarget(self, action: #selector(self.btnBoostClicked(_:)), for: .touchUpInside)
                    self.btnWatched.isHidden = true
                } else {
                    if mgrItm.isItemPurchase == "1"{
                        self.btnBuy.isHidden = true
                        self.btnWatched.isHidden = true
                    } else {
                        self.btnBuy.setTitle("BUY", for: .normal)
                        self.btnBuy.addTarget(self, action: #selector(self.btnBuyClicked(_:)), for: .touchUpInside)
                        self.btnWatched.isHidden = false
                    }
                }
                
                
                var newstr = String()
                newstr = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_price") as! NSString as String)
                let largeNumber = Float(newstr)
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
                
                
                self.lblItemPrice.text =  "$ \(String(describing: formattedNumber!))"
                mgrItm.ItemPrice=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_price") as! NSString as String
                
                self.lblUname.text=(dic?.value(forKey: "result") as AnyObject).value(forKey: "username") as! NSString as String
                
                if (self.lblUname.text == "" || self.lblUname.text == nil) {
                    self.lblUname.text="\((dic?.value(forKey: "result") as AnyObject).value(forKey: "fname") as! String) "  +  "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "lname") as! String)"
                }
                let userphoto:String = (dic?.value(forKey: "result") as AnyObject).value(forKey: "userphoto") as! String
                let keyExists = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "media") as AnyObject).count
                if keyExists! > 0 {
                    
                    mgrItm.ItemmedID =  "\((((dic?.value(forKey: "result") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "id") as! Int)"
                    
                    let watched:String! =  "\(dic?.value(forKeyPath: "result.iswatched") as! Int)"
                    
                    
                    if (watched == "1") {
                        mgrItm.isWatch = true
                        self.btnWatched.tag = 1
                        self.btnWatched.setImage(UIImage(named: "ico_watch"), for: UIControlState())
                    } else {
                        mgrItm.isWatch = false
                        self.btnWatched.tag = 0
                        self.btnWatched.setImage(UIImage(named: "ico_unwatch"), for: UIControlState())
                    }
                    let itmphoto:String = (((dic?.value(forKey: "result") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_url") as! String
                    mgrItm.ItemImg=itmphoto
                    
                    var imgurl: URL!
                    if let imageURL = URL(string: itmphoto as! String) {
                        imgurl = imageURL
                        self.userCircleImg.sd_setImageWithPreviousCachedImage(with: imgurl, placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: { (img, error, type, url) -> Void in
                        })
                    } else {
                        
                    }
                    
                    self.arrayImages = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "media") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrayImagesTemp = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "media") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    
                    mgrItm.arrayMedia = self.arrayImages
                    
                    if DeviceType.IS_IPHONE_6 {
                        self.caroselITM.viewpointOffset=CGSize(width: 55, height: 0)
                        
                    } else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                        self.caroselITM.viewpointOffset=CGSize(width: 0, height: 0)
                        
                    } else if DeviceType.IS_IPHONE_6P {
                        self.caroselITM.viewpointOffset=CGSize(width: 94, height: 0)
                    } else if UI_USER_INTERFACE_IDIOM() == .pad{
                        self.caroselITM.viewpointOffset=CGSize(width: 450, height: 0)
                    }
                    self.caroselITM.reloadData()
                    self.caroselITM.isPagingEnabled=true
                    self.imgItemPhoto.sd_setImageWithPreviousCachedImage(with: URL(string: itmphoto), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: { (img, error, type, url) -> Void in
                            
                            if self.itemRemainStatus == 0 {
                                self.imgItemPhoto.image = UIImage(named: "sold_out")
                                self.imgItemPhoto.isHidden = false
                            } else {
                                self.imgItemPhoto.isHidden = true
                            }
                    })
                    
                    let itm_qty_remain: Int = Int(mgrItm.itm_qty_remain)!
                    if itm_qty_remain == 0 {
                        self.imgItemPhoto.image = UIImage(named: "sold_out")
                        self.imgItemPhoto.isHidden = false
                    } else {
                        self.imgItemPhoto.isHidden = true
                    }
                }
                else {
                    
                    self.imgItemPhoto.isHidden=false
                    self.imgItemPhoto.image=UIImage(named: "placeh")
                }
                
                let strdate:String=NSDate.mysqlDatetimeFormatted(asTimeAgo: (dic?.value(forKey: "result") as AnyObject).value(forKey: "created_date")as! String)
                
                mgrItm.ItemTags=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_tags") as! NSString as String
                mgrItm.ItemCategory=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_category_name") as! NSString as String
                
                mgrItm.ItemCategoryID=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_category_id") as! NSString as String
                
                
                self.lbllocation.text=(dic?.value(forKey: "result") as AnyObject).value(forKey: "usercity") as! NSString as String
                
                self.lblTime.text=strdate
                
                self.imgUserPhoto.sd_setImageWithPreviousCachedImage(with: URL(string: userphoto), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: { (img, error, type, url) -> Void in
                })
                
                self.imgUserPhoto.contentMode=UIViewContentMode.scaleAspectFill
                self.imgUserPhoto.layer.cornerRadius = self.imgUserPhoto.frame.size.height / 2
                self.imgUserPhoto.layer.masksToBounds = true
                
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                print(dic!)
                _ = SweetAlert().showAlert("ScreamXO", subTitle: dic!.value(forKey: "msg")! as! NSString as String, style: AlertStyle.error, buttonTitle: "OK", action: {
                    result in
                    if result {
                        if let delegate = self.delegateAddItem {
                            delegate.actionOnaddItemData()
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                })
                
                SVProgressHUD.dismiss()                
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func sendMsgToFriend() {
        
        let mgr = APIManager.apiManager
        let parameters = NSMutableDictionary()
        parameters.setValue(7, forKey: "fromid")
        parameters.setValue(10, forKey: "toid")
        parameters.setValue(1, forKey: "messagetype")
        parameters.setValue(1, forKey: "messagedetail")
        parameters.setValue(1, forKey: "itemid")
        parameters.setValue(7, forKey: "myuid")
        
        SVProgressHUD.show(withStatus: "Fetching Activity", maskType: SVProgressHUDMaskType.clear)
        
        mgr.getFriendsMsg(parameters, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                if let messgeId: Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "messageid") as? Int {
                    print(messgeId)
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
        
    }
    
}
extension ItemDetails: DZNEmptyDataSetSource,DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "No review yet..")
    }
}
