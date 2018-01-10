//
//  ShopSearchVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/02/16.
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


class ShopSearchVC: UIViewController,iCarouselDataSource,iCarouselDelegate,WYPopoverControllerDelegate,CategorySelectDelegate,watchDelgate {
    
    // MARK: Properties
    
    var icarouselView: iCarousel!
    var popoverController: WYPopoverController!
    var arrayShopItems = NSMutableArray ()
    var arrayGlobal = NSMutableArray ()
    var arrayRecent = NSMutableArray ()
    var arrayRecommnded = NSMutableArray ()
    var arrayWatching = NSMutableArray ()
    let mgrItm = ItemManager.itemManager
    var arrayFilters = NSMutableArray ()
    var isFilter = false
    var offset:Int = 1
    var limit:Int = 10
    var catID:Int = 0
    var trending: String!
    var totalList:Int = 0
    var arrayHeaders = ["WATCHING","RECOMMENDED","RECENTLY VIEWED","WORLD TRENDING"]
    var strKeyword :String!
    var mutDict =  NSMutableDictionary()
    var isEmpty = false
    var ExpandType :Int!
    var selecteditemIndex:NSInteger?
    var isFirstLoad = false
    
    enum Expand : NSInteger
    {
        case expDelete = 0,exPhalf,exPfull
    }
    
    // MARK: IBOutlets
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var objsrcBar: UISearchBar!
    @IBOutlet weak var tblShop: UITableView!
    
    
    // MARK: UIViewControllerOverridenMethods
    
    override func viewDidLoad() {
        trending = "2"
        super.viewDidLoad()
        objsrcBar.barTintColor = UIColor.clear
        objsrcBar.backgroundColor = UIColor.white
        objsrcBar.backgroundImage = UIImage()
        objsrcBar.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        if constant.onShopFilter == false {
            btnFilter.isHidden = true
        } else {
            btnFilter.isHidden = false
        }
        
        let mgrItm = ItemManager.itemManager
        ExpandType = 1
        mgrItm.clearManager()
        getShopListItem()
        isFirstLoad = true
        
        if( traitCollection.forceTouchCapability == .available) {
            registerForPreviewing(with: self, sourceView:self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        if isFirstLoad == false {
            let mgrItm = ItemManager.itemManager
            mgrItm.clearManager()
        } else {
            isFirstLoad = false
        }
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        objAppDelegate.repositiongsm()
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
            constant.onShopFilter = !constant.onShopFilter
            if constant.onShopFilter {
                btnFilter.isHidden = false
            } else {
                btnFilter.isHidden = true
            }
        default: break
            
        }
    }
    
    // MARK: - delegateMethod
    
    func actionOnFilterCategory(_ reloadData: Bool) {
        let mgrItm = ItemManager.itemManager
        popoverController.dismissPopover(animated: true)
        
        if mgrItm.ItemCategoryID.characters.count > 0  {
            catID = Int(mgrItm.ItemCategoryID)!
        }
        if mgrItm.ItemCategoryID == ""  {
            catID = 0
        }
        if catID != 0 {
            btnFilter.layer.borderWidth=0.5
            btnFilter.layer.borderColor=UIColor.lightGray.cgColor
        } else {
            btnFilter.layer.borderWidth=0.0
            btnFilter.layer.borderColor=UIColor.clear.cgColor
        }
        getShopListItem()
    }
    
    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        if isFilter == true {
            
            if (self.arrayFilters.count == 0) {
                return 1
            }
            return self.arrayFilters.count
            
        } else {
            return self.arrayHeaders.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ( self.arrayFilters.count == 0 && isFilter) {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            return 250;
        }
        let modelName = UIDevice.current.modelName
        if modelName == "iPhone 6" || modelName == "iPhone 6s" || modelName == "iPhone 7" {
            return 140
        }
        return 155
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
            let CELL_ID = "ShopCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! shopCell!
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            let lblName : UILabel = cell!.contentView.viewWithTag(111) as! UILabel
            let btnViewall : UIButton = cell!.contentView.viewWithTag(112) as! UIButton
            btnViewall.addTarget(self, action: #selector(ShopSearchVC.btnViewallClicked(_:)), for: .touchUpInside)
            
            btnViewall.restorationIdentifier=String(indexPath.section)
            if isFilter == true
            {
                lblName.text = (self.arrayFilters.object(at: indexPath.section) as AnyObject).value(forKey: "categoryname") as? String
            }
            else
            {
                lblName.text = self.arrayHeaders[indexPath.section]
            }
            print("section:  \(indexPath.section)")
            
            icarouselView = cell?.contentView.viewWithTag(110) as! iCarousel
            icarouselView.type = iCarouselType.linear
            icarouselView.typeTag = indexPath.section
            icarouselView.bounces = true
            icarouselView.isPagingEnabled = false
            icarouselView.delegate = self
            icarouselView.dataSource = self
            icarouselView.centerItemWhenSelected = false
            
            if DeviceType.IS_IPHONE_6 {
                icarouselView.viewpointOffset=CGSize(width: 140, height: 0)
            }
            else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
                icarouselView.viewpointOffset=CGSize(width: 119, height: 0)
            }
            else if DeviceType.IS_IPHONE_6P {
                icarouselView.viewpointOffset=CGSize(width: 155, height: 0)
            }
            else if UI_USER_INTERFACE_IDIOM() == .pad{
                icarouselView.viewpointOffset=CGSize(width: 285, height: 0)
            }
            icarouselView.reloadData()
            
            return cell!
    }
    
    //MARK: - SearchVIew delgate datasource methods -
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        if searchBar.text?.characters.count > 0 {
            mgrItm.Itemsearchkey = searchBar.text!
            getShopListItem()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text?.characters.count > 0 {
            let mgrItm = ItemManager.itemManager
            mgrItm.Itemsearchkey = ""
            getShopListItem()
        }
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        if searchText.characters.count == 0 {
            mgrItm.Itemsearchkey = ""
        } else {
            mgrItm.Itemsearchkey = searchBar.text!
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getShopListItem), object: nil)
        perform(#selector(getShopListItem), with: nil, afterDelay: 0.5)
    }
    
    // MARK: - custom button methods
    
    func btnViewallClicked(_ sender: UIButton) {
        
        let index = Int(sender.restorationIdentifier!)
        let mgrItm = ItemManager.itemManager
        
        mgrItm.Itemtype = "\(index!+1)"

        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemResultListVC")) as! ItemResultListVC
        VC1.delegateWatch = self
        VC1.strttitle = self.arrayHeaders[index!]
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    @IBAction func btnFilterClicked(_ sender: AnyObject) {
        
        if ((popoverController) != nil) {
            popoverController.dismissPopover(animated: true)
        }
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "DropDownVC")) as! DropDownVC
        VC1.selectedCategory = mgrItm.ItemCategoryID
        VC1.delegate=self
        popoverController=WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self;
        popoverController.popoverContentSize=CGSize(width: 150, height: 200)
        popoverController.presentPopover(from: btnFilter.bounds, in: btnFilter, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
    }
    
    @IBAction func btnPlusClicked(_ sender: AnyObject) {
        
        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN")) as! SellItemVC
        
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    @IBAction func btnMenucClicked(_ sender: AnyObject) {
        
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    func showNoDataFound(_ carousel: iCarousel, itmArray: NSMutableArray, type: Int) {
        if let superview = carousel.superview {
            if let cell = superview.superview as? shopCell {
                let lblNoData : UILabel = cell.contentView.viewWithTag(113) as! UILabel
                
                if type == 1 {
                    if (((itmArray.object(at: carousel.typeTag) as AnyObject).value(forKey: "items") as AnyObject).count)! == 0 {
                        lblNoData.isHidden = false
                    } else {
                        lblNoData.isHidden = true
                    }
                } else if type == 2{
                    if itmArray.count == 0 {
                        lblNoData.isHidden = false
                    } else {
                        lblNoData.isHidden = true
                    }
                }
            }
        }
    }
    
    //MARK: - iCarousel methods -
    func numberOfItems (in carousel : iCarousel) -> NSInteger {
        if isFilter == true {
            showNoDataFound(carousel, itmArray: arrayFilters, type: 1)
            return (((self.arrayFilters.object(at: carousel.typeTag) as AnyObject).value(forKey: "items") as AnyObject).count)!
        }
        
        if (carousel.typeTag == 0) {
            showNoDataFound(carousel, itmArray: arrayWatching, type: 2)
            return arrayWatching.count;
        } else if (carousel.typeTag == 1) {
            showNoDataFound(carousel, itmArray: arrayRecommnded, type: 2)
            return arrayRecommnded.count;
        } else if (carousel.typeTag == 2) {
            showNoDataFound(carousel, itmArray: arrayRecent, type: 2)
            return arrayRecent.count;
        } else if (carousel.typeTag == 3) {
            showNoDataFound(carousel, itmArray: arrayGlobal, type: 2)
            return arrayGlobal.count;
        }
        showNoDataFound(carousel, itmArray: arrayShopItems, type: 1)
        return (((self.arrayShopItems.object(at: carousel.typeTag) as AnyObject).value(forKey: "items") as AnyObject).count)!
    }
    
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var view = view
        
        var imgPic : UIImageView
        var imgSoldOut: UIImageView
        var lblItmPrice: UILabel
        
        if view == nil {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4, height: carousel.frame.size.width/4)
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            imgPic.contentMode = .scaleAspectFill
            imgPic.tag = 105
            
            imgSoldOut = UIImageView()
            imgSoldOut.frame = view!.frame
            imgSoldOut.clipsToBounds = true
            imgSoldOut.contentMode = .scaleAspectFit
            imgSoldOut.tag = 107
            imgSoldOut.layer.masksToBounds = true
            
            lblItmPrice = UILabel()
            
            lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 20, width: (view?.frame.width)! + 10 , height: 15.0)
            
            if  UIDevice.current.userInterfaceIdiom == .pad {
                lblItmPrice.frame = CGRect( x: (view?.frame.origin.x)!, y: ((view?.frame.origin.y)! +  (view?.frame.height)!) - 40, width: (view?.frame.width)! + 10 , height: 20.0)
            }
            
            //lblItmPrice.frame = CGRect( x: (view?.frame.maxX)! - 50, y: (view?.frame.maxY)! - 20, width: 50.0 , height: 15.0)
            lblItmPrice.backgroundColor = UIColor(hexString :"000000", alpha:0.5)
            lblItmPrice.font = UIFont(name: "ProximaNova-Semibold", size: 10.0)
            lblItmPrice.textColor = UIColor.white
            lblItmPrice.textAlignment = .center
            lblItmPrice.tag = 110
            
            view?.addSubview(imgPic)
            view?.addSubview(imgSoldOut)
            view?.addSubview(lblItmPrice)
        } else {
            imgPic = view?.viewWithTag(105) as! UIImageView
            imgSoldOut = view?.viewWithTag(107) as! UIImageView
            lblItmPrice = view?.viewWithTag(110) as! UILabel
        }
        
        if isFilter == true {
            imgSoldOut.isHidden = true
            
            let strimgurl:String?=(((self.arrayFilters.object(at: carousel.typeTag) as AnyObject).value(forKey: "items") as AnyObject).object(at: index) as AnyObject).value(forKey: "media_url") as? String
            
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimgurl!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
            })
            
        } else {
            
            var DicData = NSMutableDictionary()
            
            if (carousel.typeTag == 0) {
                let dict = arrayWatching.object(at: index) as! NSDictionary
                let mutDict = NSMutableDictionary.init(dictionary: dict)
                DicData = mutDict
            } else if (carousel.typeTag == 1) {
                let dict = arrayRecommnded.object(at: index) as! NSDictionary
                let mutDict = NSMutableDictionary.init(dictionary: dict)
                DicData = mutDict
            } else if (carousel.typeTag == 2) {
                let dict = arrayRecent.object(at: index) as! NSDictionary
                let mutDict = NSMutableDictionary.init(dictionary: dict)
                DicData = mutDict
            } else if (carousel.typeTag == 3) {
                let dict = arrayGlobal.object(at: index) as! NSDictionary
                let mutDict = NSMutableDictionary.init(dictionary: dict)
                DicData = mutDict
            }
            
            var newstr = String()
            newstr = String(describing: DicData.value(forKey: "item_price")!)
            let largeNumber = Float(newstr)
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))

            let FinalAmount = String(describing: formattedNumber!)
            let strimgurl:String? = String(describing: DicData.value(forKey: "media_thumb")!)
            lblItmPrice.text = "$ \(FinalAmount)"
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimgurl!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
            })
            if (DicData.value(forKey: "ispurchased")! as AnyObject).intValue == 1 {
                imgSoldOut.image = UIImage(named: "sold_out")
                imgSoldOut.isHidden = false
            } else {
                imgSoldOut.isHidden = true
            }
        }
        view!.backgroundColor = UIColor.white
        view?.layer.borderColor = colors.klightgreyfont.cgColor
        view?.layer.borderWidth = 1.0
        view?.layer.masksToBounds = true
        return view
    }
    func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
        return icarouselView.frame.size.width/4.3
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing)
        {
            return value * 1.07
        }
        
        
        return value
    }
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel!) {
        
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
        
        
        let mgrItm = ItemManager.itemManager
        mgrItm.clearManager()
        
        if isFilter == true
        {
            if let itmID: Int  = (((self.arrayFilters.object(at: index) as AnyObject).value(forKey: "items") as AnyObject).object(at: index) as AnyObject).value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
        }
        else
        {
            var DicData = NSMutableDictionary()
            
            if (carousel.typeTag == 0)
            {
                mutDict = NSMutableDictionary(dictionary: arrayWatching.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            else if (carousel.typeTag == 1)
            {
                mutDict = NSMutableDictionary(dictionary: arrayRecommnded.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            else if (carousel.typeTag == 2)
            {
                mutDict = NSMutableDictionary(dictionary: arrayRecent.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            else if (carousel.typeTag == 3)
            {
                mutDict = NSMutableDictionary(dictionary: arrayGlobal.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }            
            
            if let itmID: Int  = DicData.value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
        }
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        VC1.delegatewatch = self
        self.navigationController?.pushViewController(VC1, animated: true)
        
        icarouselView.reloadData()
    }
    func actionOnwatchItm() {
        getShopListItem()
    }
    //MARK: - shop list methods -
    
    
    func getShopListItem() {
        
        if mainInstance.connected() {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
            
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            
            let parameterss = NSMutableDictionary()
            parameterss.setValue(self.offset, forKey: "offset")
            parameterss.setValue(limit, forKey: "limit")
            parameterss.setValue(usr.userId, forKey: "uid")
            parameterss.setValue(0, forKey: "type")
            if catID == 20 {
                catID = 0
                trending = "1"
            }
            parameterss.setValue(trending, forKey: "trending")
            if mgrItm.ItemCategoryID.characters.count > 0  {
                parameterss.setValue(catID, forKey: "categoryid")
            } else {
                parameterss.setValue(0, forKey: "categoryid")
            }
            
            parameterss.setValue(mgrItm.Itemsearchkey, forKey: "searchstring")
            print(parameterss)
            
            mgr.getShopList(parameterss, successClosure: { (dic, result) -> Void in
                print(dic)
                SVProgressHUD.dismiss()
                if result == APIResult.apiSuccess {
                    
                    self.arrayGlobal.removeAllObjects()
                    self.arrayGlobal = NSMutableArray(array: dic?.value(forKeyPath: "result.globaltrend.itemdetails") as! NSArray)
                    
                    self.arrayRecent.removeAllObjects()
                    self.arrayRecent = NSMutableArray(array: dic?.value(forKeyPath: "result.recentitems.itemdetails") as! NSArray)
                    
                    
                    self.arrayRecommnded.removeAllObjects()
                    self.arrayRecommnded = NSMutableArray(array: dic?.value(forKeyPath: "result.recommend.itemdetails") as! NSArray)
                    self.arrayWatching.removeAllObjects()
                    self.arrayWatching = NSMutableArray(array: dic?.value(forKeyPath: "result.watched.itemdetails") as! NSArray)
                    
                    self.tblShop.reloadData()
                    self.icarouselView.reloadData()
                    SVProgressHUD.dismiss()
                    
                    let mgrItm = ItemManager.itemManager
                    mgrItm.Itemkeyword=""
                    if (mgrItm.arrayCategories == nil ) {
                        objAppDelegate.getCategoriesList()
                    }
                }
                    
                else if result == APIResult.apiError
                {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                    self.view.endEditing(true)
                }
                else
                {
                    SVProgressHUD.dismiss()
                    self.view.endEditing(true)
                    mainInstance.showSomethingWentWrong()
                }
            })
        }
        else
        {
            mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
            self.view.endEditing(true)
        }
    }
    
    // MARK: - Search Shop Items
    
    func SearchItem()
    {
        
        let mgrItm = ItemManager.itemManager
        mgrItm.Itemkeyword=strKeyword
        if mainInstance.connected()
        {
            
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            let parameterss = NSMutableDictionary()
            parameterss.setValue(self.offset, forKey: "offset")
            parameterss.setValue(limit, forKey: "limit")
            parameterss.setValue(usr.userId, forKey: "uid")
            parameterss.setValue(strKeyword, forKey: "string")
            
            
            mgr.ItemSearch(parameterss, successClosure: { (dic, result) -> Void in
                SVProgressHUD.dismiss()
                if result == APIResult.apiSuccess
                {
                    self.arrayShopItems.removeAllObjects()
                    self.arrayShopItems = ((dic!.value(forKey: "result")) as? NSMutableArray)!
                    self.tblShop.reloadData()
                    SVProgressHUD.dismiss()
                }
                    
                else if result == APIResult.apiError
                {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                    self.view.endEditing(true)
                }
                else
                {
                    SVProgressHUD.dismiss()
                    self.view.endEditing(true)
                    mainInstance.showSomethingWentWrong()
                }
            })
        }
        else
        {
            mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
            self.view.endEditing(true)
        }
    }
    
}
extension ShopSearchVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let  tblLocaion :CGPoint = self.view.convert(location, to: self.tblShop)
        guard let indexPath = self.tblShop.indexPathForRow(at: tblLocaion) else { return nil }
        
        guard let cell =  self.tblShop.cellForRow(at: indexPath) as? shopCell else {
            return nil
        }
        let cellPoint = self.tblShop.convert(tblLocaion, to: cell)
        
        
        icarouselView = cell.contentView.viewWithTag(110) as! iCarousel
        let p = cell.convert(cellPoint, to:icarouselView )
        
        
        guard let cview = icarouselView.itemView(at: p) else{
            return nil
        }
        let index = icarouselView.index(ofItemView: cview)
        
        
        let mgrItm = ItemManager.itemManager
        mgrItm.clearManager()
        
        if isFilter == true
        {
            if let itmID: Int  = (((self.arrayFilters.object(at: index) as AnyObject).value(forKey: "items") as AnyObject).object(at: index) as AnyObject).value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
        }
        else
        {
            
            
            var DicData = NSMutableDictionary()
            
            if (icarouselView.typeTag == 0)
            {
                mutDict = NSMutableDictionary(dictionary: arrayWatching.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            else if (icarouselView.typeTag == 1)
            {
                mutDict = NSMutableDictionary(dictionary: arrayRecommnded.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            else if (icarouselView.typeTag == 2)
            {
                mutDict = NSMutableDictionary(dictionary: arrayRecent.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            else if (icarouselView.typeTag == 3)
            {
                mutDict = NSMutableDictionary(dictionary: arrayGlobal.object(at: index) as! [AnyHashable: Any])
                DicData = mutDict
            }
            
            
            if let itmID: Int  = DicData.value(forKey: "item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
            
        }
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        VC1.delegatewatch = self
        VC1.preferredContentSize = CGSize(width: 0.0, height: 0.0)
        return VC1
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}

