//
//  SettingVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 02/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class SettingVC: UIViewController {
    
    // MARK: Properties
    
    enum menuType : NSInteger
    {
        case pushm = 0,rejectm,privacym,payment,helpm,changePwm,aboutus,logoutm
    }
    
    var arrayLabels: NSArray = [
        ["name": "Push Notification Settings", "img": "icnotification"],
        ["name": "Reject List", "img": "icreject"],
        ["name": "Privacy Settings", "img": "icprivacy"],
        ["name": "Payment", "img": "payment"],
        ["name": "Help and Contact", "img": "icterms"],
        ["name": "Change Password", "img": "ic_password"],
        ["name": "About Us", "img": "ichelp"],
        ["name": "Logout", "img": "iclogout"]
    ]
    
    var arrayLabelsocial: NSArray = [
        ["name": "Push Notification Settings", "img": "icnotification"],
        ["name": "Reject List", "img": "icreject"],
        ["name": "Privacy Settings", "img": "icprivacy"],
        ["name": "Payment", "img": "payment"],
        ["name": "Help and Contact", "img": "icterms"],
        ["name": "About Us", "img": "ichelp"],
        ["name": "Logout", "img": "iclogout"]
    ]
    
    let mgradmin = AdminManager.adminManager
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tblSetting: UITableView!
    
    // MARK: UIViewControllerOverridenMethods

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        objAppDelegate.repositiongsm()
    }

    override func viewDidAppear(_ animated: Bool) {
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
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
    
    
    //MARK : - custom button methods -
    
    @IBAction func btnMenuClicked(_ sender: AnyObject) {
             self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    //MARK: - tableview delgate datasource methods -

    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let usr = UserManager.userManager
        
        if usr.setSOcial == "1"
        {
            return arrayLabelsocial.count

        }

        return arrayLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        let CELL_ID = "settingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! UITableViewCell
        let menuPic:UIImageView = cell.contentView.viewWithTag(101) as! UIImageView
        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        lblName.textColor = UIColor.black
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.accessoryType=UITableViewCellAccessoryType.disclosureIndicator
        let usr = UserManager.userManager
        if usr.setSOcial == "1"
        {
            let strimg:String = ((arrayLabelsocial[indexPath.row] as AnyObject).value(forKey: "img") as? String)!
            let strname:String = ((arrayLabelsocial[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            
            menuPic.image=UIImage(named: strimg)
            
            lblName.text = strname
            
        }
        else
        {
            
            let strimg:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "img") as? String)!
            let strname:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
            
            menuPic.image=UIImage(named: strimg)
            
            lblName.text = strname
            
            
        }
        
        lblName.textColor=colors.kLightblack;
        
        return cell
    }
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        
        if indexPath.row==menuType.pushm.rawValue
        {
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "PushSettingVC")) as UIViewController
            
            self.navigationController?.pushViewController(VC1, animated: true)
        }
        else if indexPath.row==menuType.rejectm.rawValue
        {
            
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "BlockListVC")) as UIViewController
            self.navigationController?.pushViewController(VC1, animated: true)
        }
        else if indexPath.row==menuType.privacym.rawValue
        {
            
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "PrivacySettingProfile")) as UIViewController
            
            self.navigationController?.pushViewController(VC1, animated: true)
        }
        else if indexPath.row==menuType.aboutus.rawValue
        {
            let usr = UserManager.userManager

            if usr.setSOcial == "1"
            {
                let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
                
                let logoutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive)
                {
                    UIAlertAction in
                    alert.dismiss(animated: true, completion: nil)
                    objAppDelegate.logoutInbetween()
                    
                    
                    
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
                {
                    UIAlertAction in
                    alert.dismiss(animated: true, completion: nil)
                }
                // Add the actions
                alert.addAction(logoutAction)
                alert.addAction(cancelAction)
                
                
                if (IS_IPAD)
                {
                    
                    
                    let aFrame: CGRect = tblSetting.rectForRow(at: IndexPath(row: indexPath.row, section: indexPath.section))
                    
                    
                    alert.popoverPresentationController!.sourceRect = aFrame;
                    alert.popoverPresentationController!.sourceView = tblSetting;
                    
                }
                // Present the actionsheet
                self.present(alert, animated: true, completion: nil)
                
            }
            else
            {
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "AboutUSVC")) as UIViewController
            
            self.navigationController?.pushViewController(VC1, animated: true)
            }
        }
        else if indexPath.row==menuType.payment.rawValue
        {
            
            
            let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "NewConfigurePaymentVC")) as! NewConfigurePaymentVC
            VC1.settingFlag = true
            self.navigationController?.pushViewController(VC1, animated: true)
        }
        else if indexPath.row==menuType.changePwm.rawValue
        {
            
            let usr = UserManager.userManager
            
            if usr.setSOcial == "1"
            {
                let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "AboutUSVC")) as UIViewController
                
                self.navigationController?.pushViewController(VC1, animated: true)

            }
            else
            {
       
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "ChangePwd")) as UIViewController
            self.navigationController?.pushViewController(VC1, animated: true)
                
            }
        }
            
        else if indexPath.row==menuType.helpm.rawValue
        {
                UIApplication.shared.openURL(URL(string: mgradmin.helpUrl)!)
        }
        
        else if indexPath.row==menuType.logoutm.rawValue
        {
            
            
            
            let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            
            let logoutAction = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive)
                {
                    UIAlertAction in
                    alert.dismiss(animated: true, completion: nil)
                    objAppDelegate.logoutInbetween()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
                {
                    UIAlertAction in
                    alert.dismiss(animated: true, completion: nil)
            }
            // Add the actions
            alert.addAction(logoutAction)
            alert.addAction(cancelAction)
            
          
            if (IS_IPAD)
            {
                
                
                let aFrame: CGRect = tblSetting.rectForRow(at: IndexPath(row: indexPath.row, section: indexPath.section))
                
                
                alert.popoverPresentationController!.sourceRect = aFrame;
                alert.popoverPresentationController!.sourceView = tblSetting;
                
            }
            // Present the actionsheet
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
}
