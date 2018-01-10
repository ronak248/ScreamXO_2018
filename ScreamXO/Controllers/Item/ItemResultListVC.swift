//
//  ItemResultListVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 10/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class ItemListCell: UITableViewCell
{


    @IBOutlet weak var imgItm: UIImageView!
    @IBOutlet weak var lblItmname: UILabel!
    @IBOutlet weak var lblItmPrice: UILabel!
    @IBOutlet var imgSoldOut: UIImageView!
}

class ItemResultListVC: UIViewController ,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate,watchDelgate{
    
    // MARK: IBOutlets
    
    @IBOutlet weak var titlelbl: HeaderLable!
    @IBOutlet weak var tblItemList: UITableView!
    
    
    // MARK: Properties
    
    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0
    var strttitle:String = ""
    var delegateWatch : watchDelgate?
    var arrayItemList = NSMutableArray ()
    var indexPatH = 0

    // MARK: View lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblItemList.emptyDataSetDelegate = self
        tblItemList.emptyDataSetSource = self
        tblItemList.isHidden = true

        ItemList()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        
        titlelbl.text = strttitle
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : - custom button methods
    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
        
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
        return 123
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
        return arrayItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        indexPatH = indexPath.row
        let CELL_ID = "ItemListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! ItemListCell
        cell.selectionStyle = .none
        
        cell.backgroundColor = UIColor.clear
        
        let stritmname:String?=(self.arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "item_name")! as? String
        let strimgname:String?=(self.arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "media_url")! as? String
        
        if ((self.arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "ispurchased")! as AnyObject).intValue == 1 {
            cell.imgSoldOut.isHidden = false
        } else {
            cell.imgSoldOut.isHidden = true
        }
        
        cell.imgItm.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
        })
        
        cell.lblItmname.text = stritmname
        var newstr = String()
        newstr = String(describing: (self.arrayItemList.object(at: indexPath.row) as! NSDictionary).value(forKey: "item_price")!)
        let largeNumber = Float(newstr)
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
        cell.lblItmPrice.text="$ \(String(describing: formattedNumber!))"
        if( indexPath.row == self.arrayItemList.count-1 && self.arrayItemList.count>9 && self.totalList > self.arrayItemList.count)
        {
            offset = offset + 1
            ItemList()
        }
        return cell        
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if( indexPatH == self.arrayItemList.count-1 && self.arrayItemList.count>9 && self.totalList > self.arrayItemList.count) {
            if arrayItemList.count < totalList {
                offset = offset + 1
            }
        }
        
        guard let visibleIndexPaths = tblItemList.indexPathsForVisibleRows else { return }
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
            guard tblItemList.numberOfRows(inSection: 0) > 0 else { return }
            tblItemList.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    
    {
    let mgrItm = ItemManager.itemManager
    
  
    if let itmID: Int  = (arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "item_id") as? Int
    {
    mgrItm.ItemId = "\(itmID)"
    }

    
    let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
    VC1.delegatewatch = self
    self.navigationController?.pushViewController(VC1, animated: true)
    
}

    func actionOnwatchItm()
    {
        if let delegate = delegateWatch {
            delegate.actionOnwatchItm()
        }
        self.arrayItemList.removeAllObjects()
        
        ItemList()
        
        
        
    }
    // MARK: --ItemList webservice Method
    
    func ItemList()
    {
        
        let usr = UserManager.userManager
        let Itmmgr = ItemManager.itemManager

        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
         parameterss.setValue("2", forKey: "trending")
        parameterss.setValue(usr.userId, forKey: "uid")
        if let cateId = Int(Itmmgr.ItemCategoryID) {
            parameterss.setValue(cateId, forKey: "categoryid")
        } else {
            parameterss.setValue(0, forKey: "categoryid")
        }
        
        parameterss.setValue(Itmmgr.Itemtype, forKey: "type")
        parameterss.setValue(Itmmgr.Itemsearchkey, forKey: "searchstring")

        if arrayItemList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.getShopList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            self.tblItemList.isHidden=false;

            if result == APIResult.apiSuccess
            {
                if (Itmmgr.Itemtype == "2")
                {
                
                    if let countShop :  Int = dic!.value(forKeyPath: "result.recommend.itemcount") as? Int
                    {
                        self.totalList = countShop
                    }
                    
                    if self.offset == 1 && self.totalList > 0
                    {
                        self.arrayItemList.removeAllObjects()
                        self.arrayItemList = NSMutableArray(array: (dic!.value(forKeyPath: "result.recommend.itemdetails") as! NSArray))
                        
                    }
                    else if ( self.totalList > 0 )
                    {
                        self.arrayItemList.addObjects(from: (NSMutableArray(array: (dic!.value(forKeyPath: "result.recommend.itemdetails") as! NSArray)) as! [Any]))
                    }
                } else if (Itmmgr.Itemtype == "1") {
                    
                    if let countShop :  Int = dic!.value(forKeyPath: "result.watched.itemcount") as? Int {
                        self.totalList = countShop
                    }
                    
                    if self.offset == 1 && self.totalList > 0 {
                        self.arrayItemList.removeAllObjects()
                        self.arrayItemList = NSMutableArray(array: (dic!.value(forKeyPath: "result.watched.itemdetails") as! NSArray))
                    } else if ( self.totalList > 0 ) {
                        self.arrayItemList.addObjects(from: (NSMutableArray(array: (dic!.value(forKeyPath: "result.watched.itemdetails") as! NSArray)) as! [Any]))
                    }
                    
                } else if (Itmmgr.Itemtype == "3") {
                    
                    if let countShop :  Int = dic!.value(forKeyPath: "result.recentitems.itemcount") as? Int {
                        self.totalList = countShop
                    }
                    
                    if self.offset == 1 && self.totalList > 0 {
                        self.arrayItemList.removeAllObjects()
                        self.arrayItemList = NSMutableArray(array: (dic!.value(forKeyPath: "result.recentitems.itemdetails") as! NSArray))
                    } else if ( self.totalList > 0 ) {
                        self.arrayItemList.addObjects(from: (NSMutableArray(array: (dic!.value(forKeyPath: "result.recentitems.itemdetails") as! NSArray)) as! [Any]))
                        
                    }
                } else if (Itmmgr.Itemtype == "4") {
                    
                    if let countShop :  Int = dic!.value(forKeyPath: "result.globaltrend.itemcount") as? Int {
                        self.totalList = countShop
                    }
                    
                    if self.offset == 1 && self.totalList > 0 {
                        self.arrayItemList.removeAllObjects()
                        self.arrayItemList = NSMutableArray(array: (dic!.value(forKeyPath: "result.globaltrend.itemdetails") as! NSArray))
                        
                    } else if ( self.totalList > 0 ) {
                        self.arrayItemList.addObjects(from: (NSMutableArray(array: (dic!.value(forKeyPath: "result.globaltrend.itemdetails") as! NSArray)) as! [Any]))
                        
                    }
                }
                self.tblItemList.reloadData()
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
}
