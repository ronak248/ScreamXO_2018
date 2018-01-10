//
//  PurchasedHistory.swift
//  ScreamXO
//
//  Created by Ronak Barot on 10/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
class purchaseCell :UITableViewCell {
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgItm: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet var btnAddReview: UIButton!
    
    @IBOutlet weak var btnAddTrack: UIButton!
}
class PurchasedHistory: UIViewController ,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate{
    
    // MARK: Properties
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var textLbl: UILabel!
    
    @IBOutlet weak var constTblDashTop: NSLayoutConstraint!
    @IBOutlet weak var searchBar: UISearchBar!
    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0
    var arrayPurchaseList = NSMutableArray ()
    let scrReviewName = "scrReview"
    var item_id: Int?
    var strKeyword = ""
    // MARK: IBOutlets
    var indexPatH = 0

    @IBOutlet weak var tblPurchaseList: UITableView!
    @IBOutlet var txtViewReview: UITextView!
    @IBOutlet var scrReview: TPKeyboardAvoidingScrollView!
    
    @IBOutlet weak var carrierLbl: UILabel!
    @IBOutlet weak var shippingLbl: UILabel!
    @IBOutlet weak var TrackDetailView: UIView!

    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrReview.isHidden = true
        searchBar.delegate = self
        tblPurchaseList.emptyDataSetDelegate = self
        tblPurchaseList.emptyDataSetSource = self
        tblPurchaseList.isHidden=true;

        PurchaseList()
        
        
        searchBar.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        searchBar.backgroundColor = UIColor.white
        searchBar.barTintColor = UIColor.clear
        
        
        if constant.onRecieptOptions {
            self.searchBar.isHidden = false
            self.constTblDashTop.constant = 44
        } else {
            self.searchBar.isHidden = true
            self.constTblDashTop.constant = 0
        }
        self.searchBar.barTintColor = UIColor.clear
        self.searchBar.backgroundColor = UIColor.white
        searchBar.backgroundImage = UIImage()

        
        
    }
    
    // MARK: IBActions
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func btnAddReviewClicked(_ sender: UIButton) {
        let purchaseItem = self.arrayPurchaseList.object(at: sender.tag) as? [String: AnyObject]
        item_id = purchaseItem!["item_id"] as? Int
        self.showView(scrReviewName)
    }
    
    
    @IBAction func doneViewTracking(_ sender: Any) {
        TrackDetailView.isHidden = true
        KGModal.sharedInstance().hide()
        KGModal.sharedInstance().hide(animated: true)
        TrackDetailView.isHidden = true
    }
    
    
    func btnViewTrackClicked(_ sender: UIButton) {
        
        let dictEntry = self.arrayPurchaseList[sender.tag] as? [String: AnyObject]
        let trackDetail = dictEntry!["trackingdetail"] as? [String: AnyObject]
        TrackDetailView.isHidden = false
        carrierLbl.text = trackDetail?["comapnyname"] as? String
        shippingLbl.text = trackDetail?["trackingid"] as? String
        KGModal.sharedInstance().show(withContentView: TrackDetailView)
        
        
        
//        let mgrItm = ItemManager.itemManager
//        mgrItm.clearManager()
//        if let tmpItmID: Int  = (self.arrayPurchaseList.object(at: sender.tag) as AnyObject).value(forKey: "item_id") as? Int
//        {
//            mgrItm.ItemId = "\(tmpItmID)"
//        }
//        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
//        VC1.isAddTrack = true
//        VC1.orderID = (self.arrayPurchaseList.object(at: sender.tag) as AnyObject).value(forKey: "order_id") as? Int
//        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    func btnRequestTrackClicked(_ sender: UIButton) {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let orderID = (self.arrayPurchaseList.object(at: sender.tag) as AnyObject).value(forKey: "order_id") as? String
        let purchaseItem = self.arrayPurchaseList.object(at: sender.tag) as? [String: AnyObject]
        item_id = purchaseItem!["item_id"] as? Int
        let parameters = NSMutableDictionary()
        parameters.setValue(item_id, forKey: "itemid")
        parameters.setValue(usr.userId, forKey: "uid")
        parameters.setValue(orderID, forKey: "orderid")
        print(parameters)
        SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        mgr.requestTracking(parameters, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic)
            if result == APIResult.apiSuccess {
                print(dic)
                mainInstance.ShowAlert("ScreamXO", msg: dic?.value(forKey: "msg")! as! NSString)
                self.tblPurchaseList.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
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
    
    @IBAction func btnReviewDoneClicked(_ sender: UIButton) {
        view.endEditing(true)
        if txtViewReview.text.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter review")
        } else {
            hideView(scrReviewName)
            addReview()
        }
    }
    
    @IBAction func btnReviewCancelClicked(_ sender    : UIButton) {
        view.endEditing(true)
        item_id = nil
        txtViewReview.text = ""
        hideView(scrReviewName)
    }

    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayPurchaseList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let CELL_ID = "RecieptCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! purchaseCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        let strfinalmessage:String!
        let strItmnm = (arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "item_name")! as! String
        let strUserName = String(describing: (arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "username")!)
        var strItprice = String(describing: (arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "item_purchased_price")!)
        
        var newstr = String()
        newstr = strItprice
        let largeNumber = Float(newstr)
        var numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
        let FinalAmount = String(describing: formattedNumber!)
        strItprice = "\(FinalAmount)"
        
        
        
        let strItmPurchaseQty = String(describing: (arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "item_purchased_qty")!)
        
        
        let dictEntry = self.arrayPurchaseList[indexPath.row] as? [String: AnyObject]
        let trackDetail = dictEntry!["trackingdetail"] as? [String: AnyObject]
        
        if (arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "hastrackingdetail") as? Int == 1 {
            cell.btnAddTrack.removeTarget(self, action: #selector(btnRequestTrackClicked), for: .touchUpInside)
            cell.btnAddTrack.setTitle("View Tracking", for: .normal)
            cell.btnAddTrack.addTarget(self, action: #selector(btnViewTrackClicked), for: .touchUpInside)
            cell.btnAddTrack.tag = indexPath.row
            let str1 = "Purchased \(strItmPurchaseQty) \(strItmnm) in "
            let str2 = "$ \(strItprice) from \(strUserName)"
            let str3 = " Tracking Id: $ \(trackDetail!["trackingid"]! as! String)"
            strfinalmessage = str1 + str2 + str3
          //  strfinalmessage = "Purchased \(strItmPurchaseQty) \(strItmnm) in " + "$ \(strItprice) from \(strUserName)" + " Tracking Id: $ \(trackDetail!["trackingid"]! as! String)"
        } else {
            cell.btnAddTrack.removeTarget(self, action: #selector(btnViewTrackClicked), for: .touchUpInside)
            
            strfinalmessage = "Purchased \(strItmPurchaseQty) \(strItmnm) in " + "$ \(strItprice) from \(strUserName)"
            cell.btnAddTrack.setTitle("Request Tracking", for: .normal)
            cell.btnAddTrack.addTarget(self, action: #selector(btnRequestTrackClicked), for: .touchUpInside)
            cell.btnAddTrack.tag = indexPath.row
            cell.btnAddTrack.isHidden = false
        }
        
        
        
//        strfinalmessage = "Purchased \(strItmPurchaseQty) \(strItmnm) in " + "$ \(strItprice) from \(strUserName)" + "$ \(strItprice) Tracking Id : \(trackingId)"
        
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(
            string: strfinalmessage!,
            attributes: [NSFontAttributeName:UIFont( name: fontsName.KfontproxiRegular, size: 14.0)!])
        
        myMutableString.addAttribute(NSFontAttributeName,
            value: UIFont( name: fontsName.KfontproxisemiBold, size: 14.0)!,
            range: NSRange( location: 11 + strItmPurchaseQty.characters.count + 1 + strItmnm.characters.count + 2,
                length: (strItprice.characters.count)+3))
        
        myMutableString.addAttribute(NSForegroundColorAttributeName,
            value: colors.kLightblack,
            range: NSRange(
                location: 11 + strItmPurchaseQty.characters.count + 1 + strItmnm.characters.count + 2,
                length: (strItprice.characters.count)+3))
        

        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: fontsName.KfontproxisemiBold, size: 14.0)!, range: NSRange(location: 10, length: strItmPurchaseQty.characters.count))
        
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: colors.kLightblack, range: NSRange(location: 10, length: strItmPurchaseQty.characters.count))
        
        cell.lblMessage.attributedText = myMutableString

        let strimgname:String?=(self.arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "media_url")! as? String
        
        cell.imgItm.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        cell.imgItm.contentMode=UIViewContentMode.scaleAspectFill
       // cell.imgItm.layer.cornerRadius = cell.imgItm.frame.size.height / 2
        cell.imgItm.layer.masksToBounds = true
        cell.imgItm.contentMode=UIViewContentMode.scaleAspectFill
        
        if let strtime = (self.arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "purchasedate") as? String {
            let time = NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
            cell.lblTime.text = time
        }
        
        let isReview = (self.arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "isreview") as? NSNumber
        let tmpItm_id = (self.arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "item_id") as? Int
        

        if isReview! == 0 {
            if tmpItm_id != item_id {
                cell.btnAddReview.addTarget(self, action: #selector(btnAddReviewClicked), for: .touchUpInside)
                cell.btnAddReview.tag = indexPath.row
                cell.btnAddReview.isHidden = false
            } else {
                cell.btnAddReview.isHidden = true
            }
        } else {
            
            cell.btnAddReview.isHidden = true
        }

        if( indexPath.row == self.arrayPurchaseList.count-1 && self.arrayPurchaseList.count>9 && self.totalList > self.arrayPurchaseList.count)
        {
            
            offset = offset + 1
            PurchaseList()
        }
        
        indexPatH = indexPath.row
        
        return cell
    }
    
    
    
    // MARK: - ScrollViewDelegate Method
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  self.totalList > self.arrayPurchaseList.count && indexPatH == (self.arrayPurchaseList.count - 1) {
            if arrayPurchaseList.count < totalList {
                offset += 1
            }
        }
        guard let visibleIndexPaths = tblPurchaseList.indexPathsForVisibleRows else { return }
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
                
                constant.btnObj1.frame.origin.x = (self.view.window?.frame.maxX)! - constant.btnObj1.frame.width
                constant.btnObj1.frame.origin.y = (self.view.window?.frame.maxY)! - constant.btnObj1.frame.height
                print(constant.btnObj1.frame.origin.x)
                print(constant.btnObj1.frame.origin.y)
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
            guard tblPurchaseList.numberOfRows(inSection: 0) > 0 else { return }
            tblPurchaseList.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        
        let mgrItm = ItemManager.itemManager
        mgrItm.clearManager()
        
        if let tmpItmID: Int  = (self.arrayPurchaseList.object(at: indexPath.row) as AnyObject).value(forKey: "item_id") as? Int
        {
            mgrItm.ItemId = "\(tmpItmID)"
        }
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    
    // MARK: methods
    
    func showView(_ viewName: String) {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrReview.isHidden = false
            self.view.layoutIfNeeded()
        })
    }
    
    func hideView(_ viewName: String) {
        UIView.animate(withDuration: 0.3, animations: {
            self.scrReview.isHidden = true
            self.view.layoutIfNeeded()
        })
    }

   
    // MARK: Webservice Method
   
    func addReview() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameters = NSMutableDictionary()
        parameters.setValue(item_id, forKey: "itemid")
        parameters.setValue(txtViewReview.text, forKey: "description")
        parameters.setValue(usr.userId, forKey: "uid")
        txtViewReview.text = ""
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)

        mgr.addReview(parameters, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            print(dic)
            
            if result == APIResult.apiSuccess {
                
                print(dic)
                mainInstance.ShowAlert("ScreamXO", msg: dic?.value(forKey: "msg")! as! NSString)
                self.tblPurchaseList.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
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
    
    func PurchaseList() {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameters = NSMutableDictionary()
        parameters.setValue(self.offset, forKey: "offset")
        parameters.setValue(limit, forKey: "limit")
        parameters.setValue(usr.userId, forKey: "uid")
        parameters.setValue(strKeyword, forKey: "srch_text")
        
        print(parameters)

        if arrayPurchaseList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getPurchaseList(parameters, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic)
            
            self.tblPurchaseList.isHidden=false;

            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "itemcount") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offset == 1 && self.totalList > 0
                {
                    self.arrayPurchaseList.removeAllObjects()
                    self.arrayPurchaseList = NSMutableArray(array: ((dic?.value(forKey: "result") as AnyObject).value(forKey: "itemdetails") as? [AnyObject])!)
                }
                else if ( self.totalList > 0 )
                {
                    let itemDetailsArray = NSMutableArray(array: ((dic?.value(forKey: "result") as AnyObject).value(forKey: "itemdetails") as? [AnyObject])!)
                    self.arrayPurchaseList.addObjects(from: itemDetailsArray as [AnyObject])
                }
                self.tblPurchaseList.reloadData()
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
    
    //MARK: - DZNEmptyDataSetSource Methods -
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let textAttrib = [NSForegroundColorAttributeName : colors.kLightgrey155,
            NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 24)!]
        let finalString = NSMutableAttributedString(string: "No records found", attributes: textAttrib)
        return finalString
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo")
    }
    // MARK: GSM Method
    
    func btnGSMClicked(_ btnIndex: Int) {
        if UserManager.userManager.userId == "1" {
        } else {
            
            switch btnIndex {
            case 7:
                constant.onRecieptOptions = !constant.onRecieptOptions
                if constant.onRecieptOptions {
                    self.searchBar.isHidden = false
                    self.searchBar.becomeFirstResponder()
                    self.searchBar.delegate = self
                    self.constTblDashTop.constant = 0
                    self.backBtn.isHidden = true
                    self.textLbl.isHidden = true
                } else {
                    self.searchBar.isHidden = true
                    self.constTblDashTop.constant = 0
                    self.searchBar.resignFirstResponder()
                    self.searchBar.resignFirstResponder()
                    self.searchBar.showsCancelButton = false
                    self.backBtn.isHidden = false
                    self.textLbl.isHidden = false
                }
                
            default:
                break
            }
        }
    }
    
    
    
}

// MARK: UISearchBar delegate methods

extension PurchasedHistory: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        if (searchBar.text?.characters.count)! > 0 {
            strKeyword = searchBar.text!
            self.PurchaseList()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(PurchaseList), object: nil)
        perform(#selector(PurchaseList), with: nil, afterDelay: 0.5)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            strKeyword = ""
            self.PurchaseList()
        }
        strKeyword = ""
        self.PurchaseList()
        
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.PurchaseList()
        searchBar.resignFirstResponder()
    }
}



