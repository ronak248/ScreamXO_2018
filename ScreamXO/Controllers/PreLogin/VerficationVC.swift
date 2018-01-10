//
//  VerficationVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 22/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class VerficationVC: UIViewController {

    
    @IBOutlet weak var lblTimerCode: UILabel!
    var countTotla: Int!
    @IBOutlet weak var btnResend: RoundRectbtn!
    var meterTimer:Timer!
    @IBOutlet weak var txtCode: UITextField!
    override func viewDidLoad() {
        
        
        btnResend.isUserInteractionEnabled=false;
        countTotla=60;
       self.meterTimer = Timer.scheduledTimer(timeInterval: 1,
           target:self,
           selector:#selector(VerficationVC.updateTimer(_:)),
           userInfo:nil,
           repeats:true)
        
        lblTimerCode.text =  "Verification code will be deliver in \(countTotla) Seconds"

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - custom button Methods
    
    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
        
    }
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
    @IBAction func btnResendClicked(_ sender: AnyObject) {
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(UserManager.userManager.userId, forKey: "uid")
        if mainInstance.connected()
        {
            SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
            let mgr = APIManager.apiManager
            mgr.verifyagain(parameterss, successClosure: { (dic, result) -> Void in
                SVProgressHUD.dismiss()
                if result == APIResult.apiSuccess
                {
                    
                    print(dic)
                    mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    
                    self.countTotla=60;
                    self.meterTimer = Timer.scheduledTimer(timeInterval: 1,
                        target:self,
                        selector:#selector(VerficationVC.updateTimer(_:)),
                        userInfo:nil,
                        repeats:true)
                    
                    self.lblTimerCode.text =  "Verification code will be deliver in \(self.countTotla!) Seconds"
                    self.lblTimerCode.isHidden=false
                    SVProgressHUD.dismiss()
                    self.btnResend.isUserInteractionEnabled=false
                    
                }
                else if result == APIResult.apiError
                {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                }
                else
                {
                    mainInstance.showSomethingWentWrong()
                }
            })
            
        }
        else
        {
            mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
        }
    }
    @IBAction func btnVerificationClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        if txtCode.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter code")
        }
      
        else
        {
            
            
            if mainInstance.connected()
            {
                let usr = UserManager.userManager
                let parameterss = NSMutableDictionary()
                parameterss.setValue(self.txtCode.text, forKey: "vtoken")
                parameterss.setValue(usr.userId, forKey: "uid")
                let mgr = APIManager.apiManager

                if ( mgr.deviceID != nil)
                {
                    
                    
                    parameterss.setValue(mgr.deviceID, forKey: "uniquestring")
                    
                    
                }
                else
                {
                    parameterss.setValue(UIDevice.current.identifierForVendor!.uuidString, forKey: "uniquestring")
                    mgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                    
                }

                
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
               

                mgr.verifcation(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess
                    {
                        SVProgressHUD.dismiss()

                            let usr = UserManager.userManager
                            if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int
                            {
                                usr.userId = "\(uID)"
                            }
                            usr.fullName = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String
                        
                        usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)

                        
                         usr.profileImage=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String
                            
                            let fullName: String = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String)!
                            
                            var fullNameArr = fullName.components(separatedBy: " ")
                            let firstName: String = fullNameArr[0]
                        
                        usr.username = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "uname") as? String)!
                        usr.emailAddress = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "email") as? String)!
                            usr.firstname = firstName
                            usr.setSOcial="0"
                        
                        
                        
                        usr.setrelationshipstKey =  (dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                        usr.job = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "job") as? String
                        usr.setcityKey = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "city") as? String
                        usr.setGenderKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "gender") as? String
                        
                        
                        usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                        
                        usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                        
                        
                        if (usr.setrelationshipstKey == "")
                        {
                            
                            usr.setrelationshipstKey = "a"
                            
                            
                        }
                        if (usr.setsexpref == "")
                        {
                            
                            usr.setsexpref = "o"
                            
                            
                        }
                        
                        
                        usr.profileImage = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!
                        
                        
                        let mgr   = APIManager.apiManager

                            if let apiKey : String = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "usertoken") as? String
                            {
                                mgr.sessionToken = apiKey
                            }
                        
                        let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
                        
                        userDefaults!.set(usr.userId, forKey: "wuid")
                        userDefaults!.set(mgr.sessionToken, forKey: "wtoken")
                        
                        userDefaults?.synchronize()
                            usr.lastname = fullNameArr[1]
                        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "EditProfile")) as! EditProfile
                        VC1.strIsFirstTime="1"
                        
                        self.navigationController?.pushViewController(VC1, animated: true)
                        
                    }
                    else if result == APIResult.apiError
                    {
                        print(dic)
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                        
                    }
                    else
                    {
                        mainInstance.showSomethingWentWrong()
                    }
                })
                
            }
            else
            {
                mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
            }
        }
    }
    
    // MARK: - timer
    
    func updateTimer(_ timer:Timer) {
        
        if countTotla > 1
        {
            
            countTotla=countTotla-1
            lblTimerCode.text =  "Verification code will be deliver in \(countTotla) Seconds"
        }
        else
        {
            lblTimerCode.isHidden=true;
            btnResend.isUserInteractionEnabled=true
            meterTimer.invalidate()
            
        }
    }
}
