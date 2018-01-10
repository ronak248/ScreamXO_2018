//
//  ForgotVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 25/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class ForgotVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
    
    // MARK: - custom button Methods

    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)

    }
    @IBAction func btnEmailClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        if txtEmail.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error", msg: "Email ID  required")
        }
        else if !mainInstance.isValidEmail(txtEmail.text!)
        {
            mainInstance.ShowAlertWithError("Error", msg: "Oops! Please provide a correct e-mail address. ")
        }
        else
        {
            
            if mainInstance.connected()
            {
                let parameterss = NSMutableDictionary()
                parameterss.setValue(self.txtEmail.text, forKey: "email")
                let mgr = APIManager.apiManager
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                
                
                mgr.forgotPwd(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess
                    {
                        
                        print(dic)
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
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
            }
            else {
                mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
            }
        }
    }
}
