//
//  sideMenuLeftVC.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 30/09/15.
//  Copyright © 2015 Twizz Ltd. All rights reserved.
//

import Foundation
class sideMenuLeftVC: UIViewController
{
    
    @IBOutlet var tblView: UITableView!
    var selectedrow :NSInteger!
    var arrayLabels: NSArray = [
        ["name": "Dashboard", "img": "dash"],
        ["name": "Wallet", "img": "ico-world"],
        ["name": "Shop", "img": "shop"],
        ["name" : "Social", "img" : "Social"],
        ["name": "People", "img": "friend"],
        ["name": "Profile", "img": "scream"],
        ["name": "Settings", "img": "setting"]
    ]
    let profileRow = 5
    let peopleRow = 4
    //sideMenuCell
    //sideMenuHeaderCell
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedrow=0
        tblView.backgroundColor = UIColor.clear
        //sidemenu_bg
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(sideMenuLeftVC.refreshTableView), name: NSNotification.Name(rawValue: refreshUserDataNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sideMenuLeftVC.refreshTableView), name: NSNotification.Name(rawValue: constant.refreshSideMenuNotification), object: nil)
        //refreshSideMenuNotification
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tblView.reloadData()
        
    }
    
    // MARK: - tables Methods
    
    func refreshTableView()
    {
        self.tblView.reloadData()
    }
    //MARK : - uitableview delegates -
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
//        return 150
        return 100
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
   {
        if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            
            return 62
        }
        else if DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P {
            
            return 75
        }
        return 62
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayLabels.count
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let CELL_ID = "sideMenuHeaderCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
//        let proPic:RoundImage = cell.contentView.viewWithTag(101) as! RoundImage
//        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        let _: UIImageView = cell.contentView.viewWithTag(103) as! UIImageView
        
        
//        let usr = UserManager.userManager
//        lblName.text = usr.fullName
//        
//        if usr.profileImage != nil
//        {
//            proPic.sd_setImageWithPreviousCachedImageWithURL(NSURL(string: usr.profileImage!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.RefreshCached, progress: { (a, b) -> Void in
//                }, completed: {(img, error, type, url) -> Void in
//            })
//        }
//        proPic.layer.cornerRadius = proPic.frame.size.height / 2
//        proPic.layer.masksToBounds = true
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let CELL_ID = "sideMenuCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
        let menuPic:UIImageView = cell.contentView.viewWithTag(101) as! UIImageView
        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        lblName.textColor = UIColor.black
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        if selectedrow == indexPath.row {
            
            var strimg:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "img") as? String)!
            strimg = strimg + "_e"
            let strname:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            menuPic.image=UIImage(named: strimg)
            lblName.text = strname
            lblName.textColor=UIColor.black
            lblName.font = fonts.kfontproxiBold
            
        } else {
            let strimg:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "img") as? String)!
            let strname:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            menuPic.image=UIImage(named: strimg)
            lblName.text = strname
            lblName.textColor = colors.klightgreyfont;
            lblName.font = fonts.KfontproxiRegularfont
        }
        
        return cell
    }
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        selectedrow = indexPath.row
        tblView.reloadData()
        if indexPath.row == 0 {
            self.sideMenuViewController.hideViewController()
            objAppDelegate.setViewAfterLogin()
            
        } else if indexPath.row == 1 {
            
            let objworld: World =  objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "World") as! World
            objAppDelegate.screamNavig = XXNavigationController(rootViewController: objworld)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            self.sideMenuViewController.setContentViewController(objAppDelegate.screamNavig!, animated: true)
            self.sideMenuViewController.hideViewController()
            
        } else if indexPath.row == 2 {
            
            let objshopsearch : ShopSearchVC = objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ShopSearchVC") as! ShopSearchVC
            objAppDelegate.screamNavig = XXNavigationController(rootViewController: objshopsearch)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            self.sideMenuViewController.setContentViewController(objAppDelegate.screamNavig!, animated: true)
            self.sideMenuViewController.hideViewController()
            
        }  else if indexPath.row == 3 {
            
            let objMessaging = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
            objAppDelegate.screamNavig = XXNavigationController(rootViewController: objMessaging)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            self.sideMenuViewController.setContentViewController(objAppDelegate.screamNavig, animated: true)
            self.sideMenuViewController.hideViewController()
            
        } else if indexPath.row == 4 {
            
            let objfriends : FriendsVC = objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
            objAppDelegate.screamNavig = XXNavigationController(rootViewController: objfriends)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            self.sideMenuViewController.setContentViewController(objAppDelegate.screamNavig!, animated: true)
            self.sideMenuViewController.hideViewController()
            
        } else if indexPath.row == 5 {
            let objprofile : Profile = objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile") as! Profile
            objAppDelegate.screamNavig = XXNavigationController(rootViewController: objprofile)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            self.sideMenuViewController.setContentViewController(objAppDelegate.screamNavig!, animated: true)
            self.sideMenuViewController.hideViewController()
            
        } else if indexPath.row == 6 {

            let objSetting : SettingVC = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
            objAppDelegate.screamNavig = XXNavigationController(rootViewController: objSetting)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            self.sideMenuViewController.setContentViewController(objAppDelegate.screamNavig!, animated: true)
            self.sideMenuViewController.hideViewController()
        }
    }
}
