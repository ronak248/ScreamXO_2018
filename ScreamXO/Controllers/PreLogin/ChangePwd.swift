//
//  ChangePwd.swift
//  ScreamXO
//
//  Created by Ronak Barot on 08/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class ChangePwd: UIViewController {

    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtOldPassword: UITextField!
    
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
    }
    override func viewWillDisappear(animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - custom Button methods

    @IBAction func btnBackClicked(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)

        
        
    }
    @IBAction func hideKeyboardClicked(sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
    @IBAction func btnUpdateClicked(sender: AnyObject)
    {
        
        if txtOldPassword.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter old password")
        }
        else if txtNewPassword.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter new password")
        }
        else if txtConfirmPassword.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter confirm password")
        }
        else if !(txtConfirmPassword.text==txtNewPassword.text!)
        {
            mainInstance.ShowAlertWithError("Error", msg: "Password miss-match")
        }
        else
        {
            if mainInstance.connected()
            {
               
                let usr = UserManager.userManager
                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
                let mgr = APIManager.apiManager
                let parameterss = NSMutableDictionary()
                parameterss.setValue(usr.username, forKey: "username")
                parameterss.setValue(txtOldPassword.text, forKey: "oldpassword")
                parameterss.setValue(usr.userId, forKey: "uid")
                parameterss.setValue(txtNewPassword.text, forKey: "newpassword")
                
                mgr.changePassword(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.APISuccess
                    {
                        
               
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                        SVProgressHUD.dismiss()
                        
                      
                            
                        self.navigationController?.popViewControllerAnimated(true)
                        
                    }
                    else if result == APIResult.APIError
                    {
                        print(dic)
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
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
                mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage)
            }
            
        
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
