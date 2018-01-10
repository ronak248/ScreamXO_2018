//
//  WatchedList.swift
//  ScreamXO
//
//  Created by Ronak Barot on 10/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class WatchListCell: UITableViewCell
{


    @IBOutlet weak var imgItm: UIImageView!
    @IBOutlet weak var lblItmname: UILabel!
    @IBOutlet weak var lblItmPrice: UILabel!
    @IBOutlet var btnWatch: UIButton!
}

protocol watchDelgate  {
    func actionOnwatchItm()
}
class WatchedList: UIViewController ,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate,watchDelgate{
    
    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0

    var indexPatH = 0
    var arrayItemList = NSMutableArray ()
    @IBOutlet weak var tblItemList: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblItemList.emptyDataSetDelegate = self
        tblItemList.emptyDataSetSource = self
        tblItemList.isHidden=true;
        ItemList()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        tblItemList.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : - custom button methods
    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    func btnWatchClicked(_ sender: UIButton) {
        
        
        
        let alert:UIAlertController = UIAlertController(title: "Are you sure you want to remove item from watch list?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let mgrItm = ItemManager.itemManager
                
                mgrItm.clearManager()
                
                
                if let itmID: Int  = (self.arrayItemList.object(at: sender.tag) as AnyObject).value(forKey: "item_id") as? Int
                {
                    mgrItm.ItemId = "\(itmID)"
                }
                
                mgrItm.addWatchedItem(0,successClosure:{ (dic, result) -> Void in
                    
                    if result == APIResultItm.apiSuccess {
                        self.arrayItemList.removeObject(at: sender.tag)
                        self.tblItemList.reloadData()
                    }
                })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
        let button = sender
        if (IS_IPAD) {
            
            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.00
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 85
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayItemList.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        
        let CELL_ID = "WatchListCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! WatchListCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        
        let stritmname:String?=(self.arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "item_name")! as? String
        let strimgname:String?=(self.arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "media_url")! as? String
        
        
        
        cell.imgItm.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        cell.lblItmname.text = stritmname
        cell.lblItmPrice.text="$ \((self.arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "item_price") as! String)"
        
        cell.btnWatch.addTarget(self, action: #selector(WatchedList.btnWatchClicked(_:)), for: .touchUpInside)
        cell.btnWatch.tag=indexPath.row;
        
        if( indexPath.row == self.arrayItemList.count-1 && self.arrayItemList.count>9 && self.totalList > self.arrayItemList.count) {
            offset = offset + 1
            ItemList()
        }
        indexPatH = indexPath.row
        return cell
        
    }
    
    
    // MARK: - ScrollViewDelegate Method
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  self.totalList > self.arrayItemList.count && indexPatH == (self.arrayItemList.count - 1) {
            if arrayItemList.count < totalList {
                offset += 1
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
            guard tblItemList.numberOfRows(inSection: 0) > 0 else { return }
            tblItemList.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let mgrItm = ItemManager.itemManager
        
        if let itmID: Int  = (arrayItemList.object(at: indexPath.row) as AnyObject).value(forKey: "item_id") as? Int {
            mgrItm.ItemId = "\(itmID)"
        }
        
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        
        VC1.delegatewatch=self
        
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }

    
    // MARK: --ItemList webservice Method
    
    func ItemList() {
        
        let usr = UserManager.userManager

        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        print(parameterss)

        if arrayItemList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.watchedListItems(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic as Any)
            self.tblItemList.isHidden=false;

            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offset == 1 && self.totalList > 0
                {
                    self.arrayItemList.removeAllObjects()
                    self.arrayItemList = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "items") as! NSArray).mutableCopy() as? NSMutableArray)!
                    
                }
                else if ( self.totalList > 0 )
                {
                    self.arrayItemList.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "items")! as? NSArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblItemList.reloadData()
                SVProgressHUD.dismiss()
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic as Any)
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
    
    func actionOnwatchItm() {
        self.arrayItemList.removeAllObjects()
        ItemList()
    }
}
