//
//  PrivacySettingProfile.swift
//  ScreamXO
//
//  Created by Ronak Barot on 02/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class PrivacySetting: UIViewController {
    
    
    @IBOutlet weak var tblSetting: UITableView!
    enum menuType : NSInteger
    {
        case pushm = 0,rejectm,privacym,termsm,changePwm,helpm,logoutm
    }
    
    
    var arrayLabels: NSArray = [
        ["name": "Configure Payment", "img": "icnotification"]
        ,   ["name": "Privacy Settings", "img": "icreject"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : - custom button methods -
    
    

    @IBAction func btnMenuClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
        
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
      

        return arrayLabels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let CELL_ID = "settingCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! UITableViewCell
        let lblName : UILabel = cell.contentView.viewWithTag(102) as! UILabel
        lblName.textColor = UIColor.black
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.accessoryType=UITableViewCellAccessoryType.disclosureIndicator
        let strname:String = ((arrayLabels[indexPath.row] as AnyObject).value(forKey: "name") as? String)!
        lblName.text = strname
        lblName.textColor=colors.kLightblack;
        return cell
    }
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        if (indexPath.row==0) {
            let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "NewConfigurePaymentVC")) as UIViewController
            
            self.navigationController?.pushViewController(VC1, animated: true)
        } else {
        
            let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "PrivacySettingProfile")) as UIViewController
            self.navigationController?.pushViewController(VC1, animated: true)
        }
        
    }
}
