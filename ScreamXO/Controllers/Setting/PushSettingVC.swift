//
//  PushSettingVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class PushSettingVC: UIViewController {
    
    enum enumSection : NSInteger
    {
        case xoNoti = 0,coNoti,conNoti
    }
    let notifiMgr = NotificationManager.notificationManager

    var selectedrow :NSInteger!
    var selectedsection :NSInteger!

    @IBOutlet weak var tblSetting: UITableView!

    override func viewDidLoad() {
        
        
    
        
        super.viewDidLoad()
        selectedrow=1011
        selectedsection=1011
        
//        notifiMgr.NotiLike=0
//        notifiMgr.NotiComment=2
//        notifiMgr.NotiContact=1
        //tblSetting.reloadData()
        
        getpushSettings()


        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        notifiMgr.setNotification()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK : - custom button methods -

    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - getSettings
    
    func getpushSettings() {
    
        notifiMgr.getNotification({ (dic, result) -> Void in
            if result == APIResultnoti.apiSuccess {
                self.tblSetting.reloadData()
            }
        })
    }

    
    //MARK: - tableview delgate datasource methods -

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ( section==0 || section==1) {
            return 2;
        }
        return 1;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let CELL_ID = "HEADERCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
        let proPic:UIImageView = cell.contentView.viewWithTag(101) as! UIImageView
        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        
        
        if section==0
        {
            proPic.image=UIImage(named: "icxo")
            lblName.text = "Notification"
        }
        else if section==1
        {
            //checked
            //unchecked
            proPic.image=UIImage(named: "ico_commentic")
            
            lblName.text = "Comment Notification"
            
            
        }
        else
        {
        
            proPic.image=UIImage(named: "email_ic")
            
            lblName.text = "Contact Notification"
            
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        let CELL_ID = "settingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
        let menuPic:UIImageView = cell.contentView.viewWithTag(102) as! UIImageView
        let lblName : UILabel = cell.contentView.viewWithTag(101) as! UILabel
        lblName.textColor = UIColor.black
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        if indexPath.section==0
        {
            
            if selectedsection==enumSection.xoNoti.rawValue
            {
                if selectedrow==0 {
                    
                    if indexPath.row==1 {
                        menuPic.image=UIImage(named: "unchecked")
                    } else {
                        let image1=UIImage(named: "checked")! as UIImage
                        let image2=menuPic.image! as UIImage
                        
                        if image1==image2 {
                            menuPic.image=UIImage(named: "unchecked")
                            notifiMgr.NotiLike=0
                            print(notifiMgr.NotiLike)
                        } else {
                            notifiMgr.NotiLike=indexPath.row+1
                            print(notifiMgr.NotiLike)
                            menuPic.image=UIImage(named: "checked")
                        }
                        
                    }
                    
                    
                } else if selectedrow==1 {
                    if indexPath.row==0 {
                        menuPic.image=UIImage(named: "unchecked")
                    } else {
                        let image1=UIImage(named: "checked")! as UIImage
                        let image2=menuPic.image! as UIImage

                        if image1==image2
                        {
                            notifiMgr.NotiLike=0
                            print(notifiMgr.NotiLike)

                            menuPic.image=UIImage(named: "unchecked")
                            
                        } else {
                            notifiMgr.NotiLike=indexPath.row+1
                            print(notifiMgr.NotiLike)
                            menuPic.image=UIImage(named: "checked")
                        }
                    }
                }
            } else if(selectedsection==1011) {
                
                if indexPath.row==0 {
                    lblName.text = "From My Friends"
                    
                    if (notifiMgr.NotiLike == 1) {
                        menuPic.image=UIImage(named: "checked")
                    } else {
                        menuPic.image=UIImage(named: "unchecked")
                    }
                }
                if indexPath.row==1 {
                    if (notifiMgr.NotiLike == 2) {
                        menuPic.image=UIImage(named: "checked")
                    } else {
                        menuPic.image=UIImage(named: "unchecked")
                        
                    }
                    lblName.text = "From Everyone"

                }
            } else {
                if indexPath.row==0 {
                    lblName.text = "From My Friends"
                }
                if indexPath.row==1 {
                    lblName.text = "From Everyone"
                }
            }
        } else if indexPath.section==1 {
            
            if selectedsection==enumSection.coNoti.rawValue
            {
                if selectedrow==0
                {
                    
                    if indexPath.row==1
                    {
                        menuPic.image=UIImage(named: "unchecked")
                    }
                    else
                    {
                        let image1=UIImage(named: "checked")! as UIImage
                        let image2=menuPic.image! as UIImage
                        
                        if image1==image2
                        {
                            notifiMgr.NotiComment=0
                            print("comment:\(notifiMgr.NotiComment)")

                            menuPic.image=UIImage(named: "unchecked")
                            
                        }
                        else
                        {
                            notifiMgr.NotiComment=indexPath.row+1
                            print("comment:\(notifiMgr.NotiComment)")
                            menuPic.image=UIImage(named: "checked")
                        }
                        
                    }
                    
                    
                }
                else if selectedrow==1
                {
                    
                    if indexPath.row==0
                    {
                        menuPic.image=UIImage(named: "unchecked")
                    }
                    else
                    {
                        let image1=UIImage(named: "checked")! as UIImage
                        let image2=menuPic.image! as UIImage
                        
                        if image1==image2
                        {
                            menuPic.image=UIImage(named: "unchecked")
                            notifiMgr.NotiComment=0

                            
                        }
                        else
                        {  notifiMgr.NotiComment=indexPath.row+1
                            print("comment:\(notifiMgr.NotiComment)")
                            menuPic.image=UIImage(named: "checked")
                        }
                        
                    }
                    
                    
                }
                
            }
            else if(selectedsection==1011)
            {
                
                
                
                
                if indexPath.row==0
                {
                    lblName.text = "From My Friends"
                    if (notifiMgr.NotiComment == 1)
                    {
                        
                        
                        menuPic.image=UIImage(named: "checked")
                        
                        
                    }
                    else
                    {
                        
                        
                        menuPic.image=UIImage(named: "unchecked")
                        
                        
                    }
                    
                }
                if indexPath.row==1
                {
                    lblName.text = "From Everyone"
                    if (notifiMgr.NotiComment == 2)
                    {
                        
                        
                        menuPic.image=UIImage(named: "checked")
                        
                        
                    }
                    else
                    {
                        
                        
                        menuPic.image=UIImage(named: "unchecked")
                        
                        
                    }
                }
                
                
                
            }

            else
            {
                
                
                
                
                if indexPath.row==0
                {
                    lblName.text = "From My Friends"
                }
                if indexPath.row==1
                {
                    lblName.text = "From Everyone"
                }
                
                
                
            }
            
            
            
            
            
        }
        else
        {
            
            if selectedsection==enumSection.conNoti.rawValue
            {
                
                
                let image1=UIImage(named: "checked")! as UIImage
                let image2=menuPic.image! as UIImage
                
                if image1==image2
                {
                    notifiMgr.NotiContact=0
                    print("contact:\(notifiMgr.NotiContact)")
                    menuPic.image=UIImage(named: "unchecked")
                    
                }
                else
                {
                    notifiMgr.NotiContact=indexPath.row+1
                    print("contact:\(notifiMgr.NotiContact)")
                    menuPic.image=UIImage(named: "checked")
                }
                
            }
            else
            {
            
            if indexPath.row==0
            {
                if (notifiMgr.NotiContact == 1)
                {
                    
                    
                    menuPic.image=UIImage(named: "checked")
                    
                    
                }
                else
                {
                    
                    
                    menuPic.image=UIImage(named: "unchecked")
                    
                    
                }
                lblName.text = "All New Contacts"
            }
            }
        }
        return cell
    }
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        selectedrow = indexPath.row
        selectedsection = indexPath.section
        tblSetting.reloadData()
    }
}
