//
//  PrivacySettingProfile.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class privacyCell :UITableViewCell
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblsubTitle: UILabel!
}

class PrivacySettingProfile: UIViewController {
    
    enum enumSection : NSInteger
    {
        case xoNoti = 0,coNoti,conNoti
    }
    let notifiMgr = NotificationManager.notificationManager
    var selectedrow :NSInteger!
    var selectedsection :NSInteger!
    var lastPickerIndex:Int = 1
    var arrayPrivacy: NSMutableArray = [
        ["name": "Public", "id": "2"]
        ,["name": "Friends", "id": "1"],
         ["name": "Private", "id": "0"]
    ]
    
    var arraySetting: NSMutableArray = [
        ["name": "Media", "id": "2"]
        ,["name": "Stream", "id": "2"],
         ["name": "Shop", "id": "2"]
    ]
    @IBOutlet weak var tblSetting: UITableView!
    var indexBuffet = 0
    var indexSream = 0
    var indexShop = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedrow=1011
        selectedsection=1011
        getpushSettings()
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        notifiMgr.setPrivacySettings()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK : - custom button methods -
    
    
    @IBAction func btncheckMarkClicked(_ sender: AnyObject)
    {
        
        let btncheck:UIButton = sender as! UIButton
        
        if notifiMgr.users_info == 0
        {
            
            notifiMgr.users_info = 1
            
            btncheck.setImage(UIImage(named: "checked"), for: UIControlState())
            btncheck.restorationIdentifier="222";
            
        }
        else
        {
            
            notifiMgr.users_info = 0
            
            btncheck.setImage(UIImage(named: "unchecked"), for: UIControlState())
            btncheck.restorationIdentifier="111";
            
        }
        
        tblSetting.reloadData()
        
    }
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - getSettings
    func setSelectedRows(_ index: Int,type: Int) {
        var selectedIndex = index
        if index == 2 {
            selectedIndex = 0
        }
        if index == 1 {
            selectedIndex = index
        }
        if index == 0 {
            selectedIndex = 2
        }
        if type == 2 {
            indexSream = selectedIndex
        }
        if type == 1 {
            indexShop = selectedIndex
        }
        if type == 0 {
            indexBuffet = selectedIndex
        }
    }
    func getpushSettings()
    {
        SVProgressHUD.show()
        notifiMgr.getNotification({ (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResultnoti.apiSuccess
            {
                self.notifiMgr.users_media = Int((dic!.value(forKey: "result")! as AnyObject).value(forKey: "users_media") as! String)!
                self.notifiMgr.users_buffet = Int((dic!.value(forKey: "result")! as AnyObject).value(forKey: "users_buffet") as! String)!
                self.notifiMgr.users_shop = Int((dic!.value(forKey: "result")! as AnyObject).value(forKey: "users_shop") as! String)!
                self.notifiMgr.users_info = Int((dic!.value(forKey: "result")! as AnyObject).value(forKey: "users_info") as! String)!
                self.indexSream = self.notifiMgr.users_buffet
                self.indexBuffet = self.notifiMgr.users_media
                self.indexShop = self.notifiMgr.users_shop
                self.setSelectedRows(self.indexSream, type: 2)
                self.setSelectedRows(self.indexShop, type: 1)
                self.setSelectedRows(self.indexBuffet, type: 0)
                
                let paramere : Dictionary =        ["name": "Media", "id": String(self.notifiMgr.users_media)]
                self.arraySetting.replaceObject(at: 0, with: paramere)
                
                let paramere1 : Dictionary =        ["name": "Stream", "id": String(self.notifiMgr.users_buffet)]
                self.arraySetting.replaceObject(at: 1, with: paramere1)
                
                let paramere2 : Dictionary =        ["name": "Shop", "id": String(self.notifiMgr.users_shop)]
                self.arraySetting.replaceObject(at: 2, with: paramere2)
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
        return arraySetting.count;
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let CELL_ID = "HEADERCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        let btncheck : UIButton = cell.contentView.viewWithTag(103) as! UIButton
        
        if (self.notifiMgr.users_info == 1) {
            btncheck.setImage(UIImage(named: "checked"), for: UIControlState())
        } else {
            btncheck.setImage(UIImage(named: "unchecked"), for: UIControlState())
        }
        btncheck.addTarget(self, action: #selector(PrivacySettingProfile.btncheckMarkClicked(_:)), for: .touchUpInside)
        btncheck.restorationIdentifier="111"
        if section==0 {
            //proPic.image=UIImage(named: "icxo")
            lblName.text = "Set entire account private"
        }
        
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let CELL_ID = "privacyCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! privacyCell
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.lblTitle?.text = (arraySetting.object(at: indexPath.row) as AnyObject).value(forKey: "name") as? String
        let type : String = ((arraySetting.object(at: indexPath.row) as AnyObject).value(forKey: "id") as? String)!
        
        if (type == "2")
        {
            
            cell.lblsubTitle?.text = "Public"
            
        }
        else if (type == "1")
        {
            
            cell.lblsubTitle?.text = "Friends"
            
        }
        else if (type == "0")
        {
            
            cell.lblsubTitle?.text = "Private"
            
        }
        
        return cell
    }
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if (notifiMgr.users_info == 0) {
            let temp = NSMutableArray()
            
            for i in 0 ..< arrayPrivacy.count {
                temp.add((arrayPrivacy[i] as AnyObject).value(forKey: "name")!)
            }
            var dict  = self.arraySetting.object(at: indexPath.row) as? [String:AnyObject]
            var indexSelected = 0
            if (dict!["name"] as! String == "Media") {
                indexSelected = indexBuffet
            } else if (dict!["name"] as! String == "Shop") {
                indexSelected = indexShop
            } else if (dict!["name"] as! String == "Stream") {
                indexSelected = indexSream
            }
            
            ActionSheetStringPicker.show(withTitle: "Select Privacy", rows: temp as [AnyObject], initialSelection: indexSelected, doneBlock: {
                picker, value, index in
                
                let strtype :String = (self.arrayPrivacy.object(at: value) as AnyObject).value(forKey: "id") as! String
                
                var dic  = self.arraySetting.object(at: indexPath.row) as? [String:AnyObject]
                dic!["id"]=strtype as AnyObject
                
                self.arraySetting.replaceObject(at: indexPath.row, with: dic!)
                self.lastPickerIndex = value
                
                if (dic!["name"] as! String == "Media") {
                    
                    self.notifiMgr.users_media = Int((self.arraySetting.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String)!
                    self.indexBuffet = value
                } else if (dic!["name"] as! String == "Shop") {
                    self.notifiMgr.users_shop = Int((self.arraySetting.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String)!
                    self.indexShop = value
                    
                } else if (dic!["name"] as! String == "Stream") {
                    
                    self.notifiMgr.users_buffet = Int((self.arraySetting.object(at: indexPath.row) as AnyObject).value(forKey: "id") as! String)!
                    self.indexSream = value
                    
                }
                self.tblSetting.reloadData()
                return
                
                }, cancel: { ActionStringCancelBlock in return }, origin: tblSetting)
        }
        
    }
}
