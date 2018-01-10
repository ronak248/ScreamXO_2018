//
//  ChangePwd.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 08/02/16.
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
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
    }
    
    // MARK: - custom Button methods

    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    @IBAction func btnUpdateClicked(_ sender: AnyObject) {
        
        if txtOldPassword.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter old password")
        } else if txtNewPassword.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter new password")
        } else if txtConfirmPassword.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Please enter confirm password")
        } else if !(txtConfirmPassword.text==txtNewPassword.text!) {
            mainInstance.ShowAlertWithError("Error", msg: "Password miss-match")
        } else {
            if mainInstance.connected() {
                let usr = UserManager.userManager
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                let mgr = APIManager.apiManager
                let parameterss = NSMutableDictionary()
                parameterss.setValue(usr.username, forKey: "username")
                parameterss.setValue(txtOldPassword.text, forKey: "oldpassword")
                parameterss.setValue(usr.userId, forKey: "uid")
                parameterss.setValue(txtNewPassword.text, forKey: "newpassword")
                
                mgr.changePassword(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess
                    {
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                        self.navigationController?.popViewController(animated: true)
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
            } else {
                mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
            }
        }
    }
}
