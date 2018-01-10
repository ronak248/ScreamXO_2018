//
//  SellerHistoryVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 30/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//
import UIKit


class sellerCell :UITableViewCell
{


    @IBOutlet var imgVd: UIImageView!
    @IBOutlet weak var imgUser: RoundImage!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblTime: UILabel!

    @IBOutlet weak var btnAddTrack: UIButton!
    @IBOutlet var lbltitlemargin: NSLayoutConstraint!
}

class SellerHistoryVC: UIViewController,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate {
    
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var textLbl: UILabel!

    @IBOutlet weak var tblSeller: UITableView!
    var indexPatH = 0

    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0
    var strKeyword = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    var arraysellerhiList = NSMutableArray ()
    
    @IBOutlet weak var constTblDashTop: NSLayoutConstraint!
    // MARK: - life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

         searchBar.delegate = self
        tblSeller.estimatedRowHeight = 90
        tblSeller.rowHeight = UITableViewAutomaticDimension
        tblSeller.emptyDataSetDelegate=self
        tblSeller.emptyDataSetSource=self
        self.SellerHistory()
        
        searchBar.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        searchBar.backgroundColor = UIColor.white
        searchBar.barTintColor = UIColor.clear
        
        
        if constant.onSellerHistoryOptions {
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
    // MARK: - custom button methods

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnMenuClicked(_ sender: AnyObject) {
        self.view.endEditing(true)

        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - tableview delgate datasource methods -

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
       
        
        return arraysellerhiList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        let CELL_ID = "sellerCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! sellerCell!
        cell?.selectionStyle = .none
        cell?.backgroundColor = UIColor.clear
        
        var strusername = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "purchaseusername")! as? String
        
         let itemqty = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "item_qty")! as? String
        
        var itemprice = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "item_price")! as? String
        
        var newstr = String()
        newstr = itemprice!
        let largeNumber = Float(newstr)
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
        let FinalAmount = String(describing: formattedNumber!)
        itemprice = "\(FinalAmount)"
        
        if (strusername == "" || strusername == nil)
        {
            strusername="\((self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "purchasefname") as! String)"  +  " \((self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "purchaselname") as! String)"
        }
        
        var strtime:String?=(self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "purchasedate")! as? String
        strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
        
        cell?.lblTime.text=strtime;
        
        let strimgname = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "purchaseuserphoto")! as? String
        
        let stritmname = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "item_name")! as! String
        
        var strmessage = constant.kmessagePurchase
        
        let dictEntry = self.arraysellerhiList[indexPath.row] as? [String: AnyObject]
        let trackDetail = dictEntry!["trackingdetail"] as? [String: AnyObject]
        
        if (arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "hastrackingdetail") as? Int == 1 {
            cell?.btnAddTrack.isHidden = true
            strmessage = "\(strmessage) \(stritmname)" + " Tracking Id : $ \(trackDetail!["trackingid"]! as! String) "
        } else {
          strmessage = "\(strmessage) \(stritmname)"
            cell?.btnAddTrack.isHidden = false
        }
        
        strmessage = strmessage.replacingOccurrences(of: "__username__", with: strusername!, options: NSString.CompareOptions.literal, range: nil)

        strmessage = strmessage.replacingOccurrences(of: "__quentity__", with: itemqty!, options: NSString.CompareOptions.literal, range: nil)
        
        strmessage = strmessage.replacingOccurrences(of: "__price__", with: itemprice!, options: NSString.CompareOptions.literal, range: nil)
        
         print(strmessage)
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(
            string: strmessage,
            attributes: [NSFontAttributeName:UIFont(
                name: fontsName.KfontproxiRegular,
                size: 13.0)!])
        
        myMutableString.addAttribute(NSFontAttributeName,
                                     value: UIFont(
                                        name: fontsName.KfontproxisemiBold,
                                        size: 13.0)!,
                                     range: NSRange(
                                        location: 0,
                                        length: (strusername?.characters.count)!))
        
        
        myMutableString.addAttribute(NSForegroundColorAttributeName,
                                     value: colors.kLightblack,
                                     range: NSRange(
                                        location:0,
                                        length:(strusername?.characters.count)!))
        
    
        
        var startPos: Int! = Int()
        var endPos: Int! = Int()
        if let range = strmessage.range(of: "purchased") {
             endPos = strmessage.distance(from: strmessage.startIndex, to: range.upperBound)
            print(startPos, endPos)
        }
        
        myMutableString.addAttribute(NSFontAttributeName,
                                     value: UIFont(
                                        name: fontsName.KfontproxisemiBold,
                                        size: 13.0)!,
                                     range: NSRange(
                                        location:endPos + 1 ,
                                        length: (itemqty?.characters.count)!))
        
        var startPos1: Int! = Int()
        var endPos1: Int! = Int()
        if let range = strmessage.range(of: "for") {
            endPos1 = strmessage.distance(from: strmessage.startIndex, to: range.upperBound)
            print(startPos1, endPos1)
        }

        myMutableString.addAttribute(NSFontAttributeName,
                                     value: UIFont(
                                        name: fontsName.KfontproxisemiBold,
                                        size: 13.0)!,
                                     range: NSRange(
                                        location: endPos1 + 1,
                                        length: (itemprice?.characters.count)! + 1))

     
        
        
        cell?.lblMessage.attributedText = myMutableString
        cell?.imgVd.isHidden=true
        cell?.imgItem.isHidden=false
        
        let itmphoto:String = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "media_thumb") as! String
        cell?.imgItem.sd_setImageWithPreviousCachedImage(with: URL(string: itmphoto), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            
        }) { (img, error, type, url) -> Void in
            
        }
        
        cell?.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        cell?.imgItem.contentMode=UIViewContentMode.scaleAspectFill
        cell?.imgItem.layer.masksToBounds = true
        cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        cell?.imgUser.layer.cornerRadius = (cell?.imgUser.frame.size.height)! / 2
        cell?.imgUser.layer.masksToBounds = true
        cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        cell?.btnAddTrack.addTarget(self, action: #selector(self.btnAddTrackTapped), for: .touchUpInside)
        
        if( indexPath.row == self.arraysellerhiList.count-1 && self.arraysellerhiList.count>9 && self.totalList > self.arraysellerhiList.count)
        {
            
            //            if PaginationCallback != nil
            //            {
            //                PaginationCallback!(type : (self.title?.lowercaseString)!)
            //            }
            
            offset = offset + 1
            SellerHistory()
        }
        indexPatH = indexPath.row
        return cell!
    }
    
   
    
    // MARK: - ScrollViewDelegate Method
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  self.totalList > self.arraysellerhiList.count && indexPatH == (self.arraysellerhiList.count - 1) {
            if arraysellerhiList.count < totalList {
                offset += 1
            }
        }
        guard let visibleIndexPaths = tblSeller.indexPathsForVisibleRows else { return }
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
            guard tblSeller.numberOfRows(inSection: 0) > 0 else { return }
            tblSeller.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    

    
    
    func btnAddTrackTapped(_ sender: UIButton) {
        let mgrItm = ItemManager.itemManager
        mgrItm.clearManager()
        if let tmpItmID: Int  = (self.arraysellerhiList.object(at: sender.tag) as AnyObject).value(forKey: "item_id") as? Int
        {
            mgrItm.ItemId = "\(tmpItmID)"
        }
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        VC1.isAddTrack = true
        VC1.orderID = (self.arraysellerhiList.object(at: sender.tag) as AnyObject).value(forKey: "orderid") as? Int
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
            let mgrItm = ItemManager.itemManager
            mgrItm.clearManager()
            
            if let itmID: Int  = (self.arraysellerhiList.object(at: indexPath.row) as AnyObject).value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
        
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        
            self.navigationController?.pushViewController(VC1, animated: true)
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

    
    
    // MARK: --ItemList webservice Method
    
    func SellerHistory()
    {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(strKeyword, forKey: "srch_text")
        
        print(parameterss)
        
        if arraysellerhiList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getsellerHistory(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic ?? "")
            self.tblSeller.isHidden=false
            
            if result == APIResult.apiSuccess {
                
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "itemcount") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offset == 1 && self.totalList > 0 {
                    
                    self.arraysellerhiList.removeAllObjects()
                    self.arraysellerhiList = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "itemdetails")) as? NSArray)!.mutableCopy() as! NSMutableArray
                } else if ( self.totalList > 0 ) {
                    let tempArray = NSMutableArray(array: (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "itemdetails")) as? [AnyObject])!)
                    self.arraysellerhiList.addObjects(from: tempArray as [AnyObject])
                }
                self.tblSeller.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                
                print(dic ?? "")
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
    
    
    // MARK: GSM Method
    
    func btnGSMClicked(_ btnIndex: Int) {
        if UserManager.userManager.userId == "1" {
        } else {
            
            switch btnIndex {
            case 7:
                constant.onSellerHistoryOptions = !constant.onSellerHistoryOptions
                if constant.onSellerHistoryOptions {
                    self.searchBar.isHidden = false
                    self.searchBar.becomeFirstResponder()
                    self.searchBar.delegate = self
                    self.constTblDashTop.constant = 44
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

extension SellerHistoryVC: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        if (searchBar.text?.characters.count)! > 0 {
            strKeyword = searchBar.text!
            self.SellerHistory()
            
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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(SellerHistory), object: nil)
        perform(#selector(SellerHistory), with: nil, afterDelay: 0.5)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            strKeyword = ""
            SellerHistory()
            
        }
        strKeyword = ""
        SellerHistory()
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.SellerHistory()
        searchBar.resignFirstResponder()
    }
}
