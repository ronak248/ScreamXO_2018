//
//  NotificationsVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 30/01/16.
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



class NotificationCell :UITableViewCell
{
    @IBOutlet var imgVd: UIImageView!
    @IBOutlet weak var imgUser: RoundImage!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet var lbltitlemargin: NSLayoutConstraint!
}

class NotificationsVC: UIViewController,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate {
    
    @IBOutlet weak var tblNotification: UITableView!
    
    var parentCnt: UIViewController!
    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0
     var indexPatH = 0
    var arrayNotificationList = NSMutableArray ()
    
    // MARK: - life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        tblNotification.estimatedRowHeight = 90
        tblNotification.rowHeight = UITableViewAutomaticDimension
        tblNotification.emptyDataSetDelegate=self
        tblNotification.emptyDataSetSource=self
        tblNotification.isHidden=true
        self.notificationList()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotificationList), name: NSNotification.Name(rawValue: "refreshNetworkVC"), object: nil)
    }
    func refreshNotificationList() {
        self.offset = 1
        //notificationList()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - custom button methods

    @IBAction func btnMenuClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    
    //MARK: - tableview delgate datasource methods -
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayNotificationList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {

        let CELL_ID = "NotificationCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! NotificationCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        var strusername:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "userdata.username")! as? String
        
        
        if (strusername == "" || strusername == nil)
        {
            
            strusername="\((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "userdata.fname") as! String)"  +  " \((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "userdata.lname") as! String)"
            
        }
        
        var strtime:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "notificationstime")! as? String
        strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
        
        cell.lblTime.text=strtime;
        
        let strimgname:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "userdata.userphoto")! as? String
        
        
        var strmessage:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "notificationsdetail")! as? String
        
        
        strmessage = strmessage!.replacingOccurrences(of: "__username__", with: strusername!, options: NSString.CompareOptions.literal, range: nil)
        
        
        var myMutableString = NSMutableAttributedString()
        
        
        myMutableString = NSMutableAttributedString(
            string: strmessage!,
            attributes: [NSFontAttributeName:UIFont(
                name: fontsName.KfontproxiRegular,
                size: 14.0)!])
        
        myMutableString.addAttribute(NSFontAttributeName, value: UIFont(name: fontsName.KfontproxisemiBold, size: 14.0)!, range: NSRange(
                                        location: 0,
                                        length: (strusername?.characters.count)!))
        
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: colors.kLightblack, range: NSRange(location:0,
                                        length:(strusername?.characters.count)!))
        
        cell.lblMessage.attributedText = myMutableString
        
        
        
        
        let strnotiType1:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "notificationstype")! as? String
        
        
        
        
        if (Int(strnotiType1!)! == notifiType.pLike.rawValue || Int(strnotiType1!)! == notifiType.pComment.rawValue)
            
        {
            
            let strposttype:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "itemdata.post_type")! as? String
            
            
            
            if (strposttype != "0")
            {
                
                //cell.lbltitlemargin.constant=66.0;
                cell.imgItem.isHidden=false;
                cell.imgVd.isHidden=false;
                
                
                let keyExists = (((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media") as AnyObject).count
                
                if keyExists > 0
                {
                    
                    let strmediatype:String=((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_type") as! String
                    let strmediathumb:String=((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_thumb") as! String
                    
                    
                    if strmediatype == "audio/m4a" || strmediatype == "audio/mp3"
                    {
                        cell.imgVd.isHidden=false;
                        
                        cell.imgVd.image=UIImage(named: "auic")
                        cell.imgItem.sd_setImageWithPreviousCachedImage(with: URL(string: strmediathumb), placeholderImage: UIImage(named: "audsc"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                            }, completed: {(img, error, type, url) -> Void in
                        })
                    }
                    else if   strmediatype == "video/quicktime"
                    {
                        cell.imgVd.isHidden=false;
                        
                        cell.imgVd.image=UIImage(named: "vdic")
                        cell.imgItem.sd_setImageWithPreviousCachedImage(with: URL(string: strmediathumb), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                            }, completed: {(img, error, type, url) -> Void in
                        })
                    }
                    else
                    {
                        cell.imgVd.isHidden=true
                        let itmphoto:String = ((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_thumb") as! String
                        cell.imgItem.sd_setImageWithPreviousCachedImage(with: URL(string: itmphoto), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                            }, completed: {(img, error, type, url) -> Void in
                        })
                    }
                    
                }
            }
            else
            {
                
                //cell.lbltitlemargin.constant=10.0;
                
                cell.imgItem.isHidden=true;
                cell.imgVd.isHidden=true;
            }
            
        }
        else if (Int(strnotiType1!)! == notifiType.pItem.rawValue || Int(strnotiType1!)! == notifiType.itmTrack.rawValue || Int(strnotiType1!)! == notifiType.itmTrackAdded.rawValue)
        {
            
            cell.imgVd.isHidden=true
            cell.imgItem.isHidden=false
            let itmphoto:String = ((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_thumb") as! String
            cell.imgItem.sd_setImageWithPreviousCachedImage(with: URL(string: itmphoto), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: {(img, error, type, url) -> Void in
            })
        } else if (Int(strnotiType1!)! == notifiType.cntrequest.rawValue)  {
            
            cell.imgItem.isHidden=false;
            cell.imgVd.isHidden=true;
            cell.imgItem.image = UIImage(named: "crrequest")
            }
        else
        {
            
            
            cell.imgItem.isHidden=false;
            cell.imgVd.isHidden=true;
            cell.imgItem.image = UIImage(named: "newcomment")
        }
        
        cell.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        cell.imgItem.contentMode=UIViewContentMode.scaleAspectFill
        cell.imgItem.layer.masksToBounds = true
        cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height / 2
        cell.imgUser.layer.masksToBounds = true
        cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        indexPatH = indexPath.row
        
//        if( indexPath.row == self.arrayNotificationList.count-1 && self.arrayNotificationList.count>9 && self.totalList > self.arrayNotificationList.count)
//        {
//            offset = offset + 1
//            notificationList()
//        }
        return cell
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if( indexPatH == self.arrayNotificationList.count-1 && self.arrayNotificationList.count>9 && self.totalList > self.arrayNotificationList.count) {
            if arrayNotificationList.count < totalList {
                offset = offset + 1
                notificationList()

            }
        }
        guard let visibleIndexPaths = tblNotification.indexPathsForVisibleRows else { return }
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
            setLoginViewForGuest()
        }else {
            guard tblNotification.numberOfRows(inSection: 0) > 0 else { return }
            tblNotification.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
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
        
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
            
            
        }else {

        
        let strnotiType1:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "notificationstype")! as? String
        
        if (Int(strnotiType1!)! == notificationType.notiLike.rawValue || Int(strnotiType1!)! == notificationType.notiComment.rawValue) || Int(strnotiType1!)! == notificationType.notiTagPost.rawValue || Int(strnotiType1!)! == notificationType.notiTagComment.rawValue {
            
            let strposttype:String?=(self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "itemdata.post_type")! as? String
            
            let strpostid = (self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "itemdata.post_id")! as! Int
            let mgrpost = PostManager.postManager
            mgrpost.clearManager()
            if (strposttype != "0" && strposttype != nil)
            {
                
                let urlstring:String = ((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media") as! NSArray)[0] as AnyObject).value(forKey: "media_url") as! String
                
                let MediaType:String = ((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_type") as! String
                
                mgrpost.PostType = MediaType
                mgrpost.PostImg = urlstring
                
                mgrpost.PostId="\(String(describing: strpostid))"
                let strimg:String = ((((self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKey: "itemdata") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_thumb") as! String
                UserDefaults.standard.set(strimg, forKey: "mediaimg")
                
                
                let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
                
                VC1.Posttype=2;
                VC1.isViewComment=1;
                self.navigationController?.pushViewController(VC1, animated: true)
            }
            else
            {
                mgrpost.PostId="\(strpostid)"
                
                let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
                mgrpost.PostType = "0"
                
                VC1.Posttype=0;
                
                VC1.isViewComment=1;
                self.navigationController?.pushViewController(VC1, animated: true)
                
            }
        }
        else if (Int(strnotiType1!)! == notificationType.notiPurchase.rawValue || Int(strnotiType1!)! == notificationType.notiTrackingDetail.rawValue)
            
        {
            
            let mgrItm = ItemManager.itemManager
            mgrItm.clearManager()
            
            if let itmID: Int  = (self.arrayNotificationList.object(at: indexPath.row) as AnyObject).value(forKeyPath: "itemdata.item_id") as? Int
            {
                mgrItm.ItemId = "\(itmID)"
            }
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
            
            self.navigationController?.pushViewController(VC1, animated: true)
            
        }
        else if (Int(strnotiType1!)! == notificationType.notiAccept.rawValue)
        {
            let mgrfriend = FriendsManager.friendsManager
            mgrfriend.clearManager()
            var dic :NSMutableDictionary?

            let mutDict = NSMutableDictionary(dictionary: self.arrayNotificationList.object(at: indexPath.row) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;

            
            if let uID: Int  = (dic!.value(forKeyPath: "userdata.userid")! as? Int)!
            {
                
                let user = UserManager.userManager
                
                if (("\(uID)") == user.userId)
                {
                    if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                        leftVC.selectedrow = leftVC.profileRow
                        leftVC.tblView.reloadData()
                    }
                    let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                    
                    self.navigationController?.pushViewController(VC1, animated: true)
                }
                else
                {
                    
                    mgrfriend.FriendID = "\(uID)"
                    mgrfriend.FriendPhoto = "\(dic!.value(forKeyPath: "userdata.userphoto") as! String)"
                    mgrfriend.FUsername = "\(dic!.value(forKeyPath: "userdata.username") as! String)"
                    
                    mgrfriend.FriendName = "\(dic!.value(forKeyPath: "userdata.fname") as! String)"  +  " \(dic!.value(forKeyPath: "userdata.lname") as! String)"
         
                    let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                    
                    self.navigationController?.pushViewController(VC1, animated: true)
                }
            }
        } else if Int(strnotiType1!)! == notificationType.notiRequest.rawValue {
            
            let friendsVC = (objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC")) as! FriendsVC
            friendsVC.isFromNotify = true
            
            if let sidemenu = self.sideMenuViewController,let leftVC = sidemenu.leftMenuViewController as? sideMenuLeftVC {
                leftVC.selectedrow = leftVC.peopleRow
                leftVC.tblView.reloadData()
            }
            
            self.navigationController?.pushViewController(friendsVC, animated: true)
        } else if Int(strnotiType1!)! == notifiType.itmTrackAdded.rawValue {
            
        }
    }
    }

    
    func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
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
    
    func notificationList()
    {
        
        let usr = UserManager.userManager
        
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        print(parameterss)
        
        if arrayNotificationList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getAllnotification(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic ?? "nil value")
            
            self.tblNotification.isHidden=false;
            
            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offset == 1 && self.totalList > 0
                {
                    self.arrayNotificationList.removeAllObjects()
                    self.arrayNotificationList = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "notifications")  as AnyObject) as? NSArray)!.mutableCopy() as! NSMutableArray
                    
                    let notifiMgr = NotificationManager.notificationManager

                    notifiMgr.resetbadgeNotification()
                    
                }
                else if ( self.totalList > 0 )
                {
                    let myArray = (dic?.value(forKey: "result") as AnyObject).value(forKey: "notifications") as! NSArray
                    let mutableArray = NSMutableArray.init(array: myArray)
                    self.arrayNotificationList.addObjects(from: mutableArray.mutableCopy() as! [AnyObject])
                }
                self.tblNotification.reloadData()
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
}
