//
//  SelectProcessorVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-10-23.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class SelectProcessorVC: UIViewController , UITextFieldDelegate ,PayPalPaymentDelegate,PayPalFuturePaymentDelegate,PayPalProfileSharingDelegate {

    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default
    var strtransactionID:String = ""
    var strrefreshtoken:String = ""
    var strfinaltoken:String = ""
    
    @IBOutlet  var pickerView: UIView!
    @IBOutlet  var textFiled: UITextField!
    var paymentType: String!
    var type: String!
    var stremail:String = ""
    @IBOutlet var lblpaypal: UILabel!
    let usr = UserManager.userManager
    
    var environment:String = PayPalEnvironmentSandbox {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentProduction)
            }
        }
    }
    
    #if HAS_CARDIO
    // You should use the PayPal-iOS-SDK+card-Sample-App target to enable this setting.
    // For your apps, you will need to link to the libCardIO and dependent libraries. Please read the README.md
    // for more details.
    
    var acceptCreditCards: Bool = true {
    didSet {
    payPalConfig.acceptCreditCards = acceptCreditCards
    }
    }
    #else
    var acceptCreditCards: Bool = false {
        didSet {
            payPalConfig.acceptCreditCards = acceptCreditCards
        }
    }
    #endif
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAccountDetails()
        paypalCOnfiguration()
        textFiled.delegate = self
        
        var environment:String = PayPalEnvironmentNoNetwork {
            willSet(newEnvironment) {
                if (newEnvironment != environment) {
                    PayPalMobile.preconnect(withEnvironment: newEnvironment)
                }
            }
        }
        
        var environmentForSendbox:String = PayPalEnvironmentSandbox
        {
            willSet(newEnvironment) {
                if (newEnvironment != environmentForSendbox)
                {
                    PayPalMobile.preconnect(withEnvironment: newEnvironment)
                }
            }
        }

        
        
    }

    override func viewWillDisappear(_ animated: Bool) {

        if self.usr.ispaypalconfi == "1"
        {
            objAppDelegate.isconfiguredpayment = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackClicked() {
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is SelectPaymentVC {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
    }
    
    
    
    // MARK: getAccountDetails
    
    func getAccountDetails() {
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        
        print(parameterss)
        SVProgressHUD.show()
        mgr.getAccount(parameterss, successClosure: { (dic, result) -> Void in
            print(dic!)
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess {
                
                
                
                let strlbl:String? = dic?.value(forKeyPath: "result.paypal") as? String
                let strlblbit:String? = dic?.value(forKeyPath: "result.bitcoin") as? String
                
                if (strlbl?.characters.count)! <= 0
                {
                    self.lblpaypal.text = "PayPal" //Not Configured
                }
                else
                {
                    self.lblpaypal.text = strlbl
                    self.usr.ispaypalconfi = "1"
                }
                if (strlblbit?.characters.count)! <= 0
                {
                   // self.lblAlipay.text = "Not Configured"
                }
                else
                {
                    self.usr.ispaypalconfi = "1"
                }
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
    
    
    
    @IBAction func btnPaypalClicked(_ sender: Any) {
        
        type = "paypal"
        if (lblpaypal.text == "Not Configured")
        {
            let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
            let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
            present(profileSharingViewController!, animated: true, completion: nil)
        }
        else
        {
            let message:String!="Are you sure you want to change account?"
            
            let refreshAlert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes, I agree!", style: .default, handler: { (action: UIAlertAction!) in
                
                let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
                let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: self.payPalConfig, delegate: self)
                self.present(profileSharingViewController!, animated: true, completion: nil)
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
//
//        paymentType = "PayPal"
//        textFiled.placeholder = "Please enter your Paypal Email Id"
//        pickerView.isHidden = false
//        KGModal.sharedInstance().show(withContentView: pickerView)
    }

    @IBAction func btnBitcoinClicked(_ sender: Any) {
        paymentType = "Bitcoin"
        type = "bitcoin"
        textFiled.placeholder = "Please enter your Bitcoin Email Id"
        pickerView.isHidden = false
        KGModal.sharedInstance().show(withContentView: pickerView)
    }
    
    @IBAction func btnAliPayClicked(_ sender: Any) {
        paymentType = "Alipay"
        type = "alipay"
        textFiled.placeholder = "Please enter your Alipay Email Id"
        pickerView.isHidden = false
        KGModal.sharedInstance().show(withContentView: pickerView)
    }
    
    @IBAction func btnWeChatClicked(_ sender: Any) {
        paymentType = "WeChat"
        type = "wechat"
        textFiled.placeholder = "Please enter your WeChat Email Id"
        pickerView.isHidden = false
        KGModal.sharedInstance().show(withContentView: pickerView)
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        if scoreText == textFiled {
            self.view.endEditing(true)
            self.pickerView.endEditing(true)
        }
        return true
    }
    
    
    func paypalCOnfiguration()
    {
        
        
        payPalConfig = PayPalConfiguration()
        payPalConfig.acceptCreditCards = true
        payPalConfig.languageOrLocale = "en"
        payPalConfig.merchantName = "Merchant nmae"
        payPalConfig.merchantPrivacyPolicyURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")! as URL
        payPalConfig.merchantUserAgreementURL = NSURL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")! as URL
        payPalConfig.languageOrLocale = NSLocale.preferredLanguages[0]
        environment = PayPalEnvironmentSandbox
        payPalConfig.acceptCreditCards = false
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
    }
    
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("PayPal Payment Cancelled")
        resultText = ""
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            let dic : NSDictionary? = completedPayment.confirmation as NSDictionary
            print(dic!)
            self.strtransactionID = dic?.value(forKeyPath: "response.id") as! String
            self.accestoken()
            
            self.verifyCompletedPayment(completedPayment)
            //self.resultText = completedPayment.intent
        })
    }
    
    @IBAction func authorizeFuturePaymentsAction(_ sender: AnyObject) {
        let futurePaymentViewController = PayPalFuturePaymentViewController(configuration: payPalConfig, delegate: self)
        present(futurePaymentViewController!, animated: true, completion: nil)
    }
    
    func payPalFuturePaymentDidCancel(_ futurePaymentViewController: PayPalFuturePaymentViewController) {
        print("PayPal Future Payment Authorization Canceled")
        futurePaymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any])
    {
        
        let metadata :String? = PayPalMobile.clientMetadataID()
        
        print("PayPal Future Payment Authorization Success!")
        
        let dic : NSDictionary? = futurePaymentAuthorization as NSDictionary
        print(dic)
        self.strtransactionID = dic?.value(forKeyPath: "response.id") as! String
        
        // send authorization to your server to get refresh token.
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = futurePaymentAuthorization.description
        })
    }

    
    // MARK: Profile Sharing
    
    @IBAction func authorizeProfileSharingAction(_ sender: AnyObject) {
        let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
        
        let metadata :String? = PayPalMobile.clientMetadataID()
        
        present(profileSharingViewController!, animated: true, completion: nil)
    }
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController)
    {
        print("PayPal Profile Sharing Authorization Canceled")
        let metadata :String? = PayPalMobile.clientMetadataID()
        
        profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any])
    {
        print("PayPal Profile Sharing Authorization Success!")
        
        // send authorization to your server
        let dic : NSDictionary? = profileSharingAuthorization as NSDictionary
        print(dic)
        self.strtransactionID = dic?.value(forKeyPath: "response.code") as! String
        self.accestoken()
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = profileSharingAuthorization.description
        })
    }
    
    func verifyCompletedPayment(_ completedPayment: PayPalPayment) {
        // Send the entire confirmation dictionary
        
        do {
            
            
            var _: Data = try JSONSerialization.data(withJSONObject: completedPayment.confirmation, options: JSONSerialization.WritingOptions.prettyPrinted)
        }
        catch
        {
            print(error)
        }
    }
    
    func accestoken()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let mgradmin = AdminManager.adminManager
        
        let clientID: String = mgradmin.paypalcID
        let secret: String = mgradmin.paypalcSecret
        let _ = "\(clientID):\(secret)"
        
        let auth = String(format: "%@:%@", clientID, secret).data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let header = auth.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Accept": "application/json", "Accept-Language": "en", "Content-Type": "application/x-www-form-urlencoded"]
        
        let session = URLSession(configuration: configuration)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "\(constant.kPaypalAPI)v1/identity/openidconnect/tokenservicen")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(header)", forHTTPHeaderField: "Authorization")
        
        let bodyData : String = "grant_type=authorization_code&code=\(self.strtransactionID)"
        
        let theData: Data = bodyData.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        let task: URLSessionUploadTask = session.uploadTask(with: request as URLRequest, from: theData, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if ((error == nil)) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    print("JSON string = \(json)")
                    if let refreshToken = ((json as AnyObject).object(forKey: "refresh_token")) {
                        self.strrefreshtoken = String(describing: refreshToken)
                        self.refreshaccestoken()
                    }
                }
                catch
                {
                    print(error)
                }
            }
        })
        task.resume()
    }
    
    func refreshaccestoken()
    {
        let mgradmin = AdminManager.adminManager
        
        let clientID: String = mgradmin.paypalcID
        let secret: String = mgradmin.paypalcSecret
        let _: String = "\(clientID):\(secret)"
        
        let auth = String(format: "%@:%@", clientID, secret).data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let header = auth.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Accept": "application/json", "Accept-Language": "en_US", "Content-Type": "application/x-www-form-urlencoded"]
        
        let session = URLSession(configuration: configuration)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "\(constant.kPaypalAPI)v1/identity/openidconnect/tokenservice")!)
        request.httpMethod = "POST"
        request.setValue("Basic \(header)", forHTTPHeaderField: "Authorization")
        
        let bodyData : String = "grant_type=refresh_token&refresh_token=\(self.strrefreshtoken)"
        
        let theData: Data = bodyData.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        let task: URLSessionUploadTask = session.uploadTask(with: request as URLRequest, from: theData, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if ((error == nil)) {
                
                
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    print("JSON string = \(json)")
                    
                    self.strfinaltoken = ((json as AnyObject).object(forKey: "access_token"))! as! String
                    self.getUserInfo()
                }
                catch
                {
                    print(error)
                }
            }
        })
        task.resume()
    }
    func getUserInfo() {
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Accept": "application/json", "Accept-Language": "en_US", "Content-Type": "application/x-www-form-urlencoded"]
        
        let session = URLSession(configuration: configuration)
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: "\(constant.kPaypalAPI)v1/identity/openidconnect/userinfo/?schema=openid")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.strfinaltoken)", forHTTPHeaderField: "Authorization")
        
        let bodyData : String = "grant_type=refresh_token&refresh_token=\(self.strrefreshtoken)"
        
        let theData: Data = bodyData.data(using: String.Encoding.ascii, allowLossyConversion: true)!
        
        let task: URLSessionUploadTask = session.uploadTask(with: request as URLRequest, from: theData, completionHandler: {(data: Data?, response: URLResponse?, error: Error?) -> Void in
            if ((error == nil)) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    print("JSON string = \(json)")
                    self.stremail = ((json as AnyObject).object(forKey: "email"))! as! String
                    self.callwebserver(self.stremail as NSString,type: "paypal")
                } catch {
                    print(error)
                }
            }
        })
        task.resume()
    }

    func callwebserver(_ email:NSString ,type:NSString) {
        let mgr = APIManager.apiManager
        let usr = UserManager.userManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(email, forKey: type as String)
        parameterss.setValue(usr.userId, forKey: "uid")
        
        SVProgressHUD.show()
        mgr.updatepayment(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                
                self.lblpaypal.text="\(email)"
                self.usr.ispaypalconfi="1"
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.pickerView.isHidden = true
                KGModal.sharedInstance().hide()
                self.view.endEditing(true)
                for vc in (self.navigationController?.viewControllers ?? []) {
                                    if vc is SelectPaymentVC {
                                        _ = self.navigationController?.popToViewController(vc, animated: true)
                                        break
                                    }
                                }
            } else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    
    @IBAction func submitEmail(_ sender: Any) {
        self.callwebserver(textFiled.text!as NSString, type : type! as NSString)
        
//        var emailData: NSMutableArray! = NSMutableArray()
//        let userDefaults = UserDefaults.standard
//        emailData   = (userDefaults.object(forKey: "paymentGetway") as? NSArray)?.mutableCopy() as! NSMutableArray
//        if emailData == nil {
//            let emailData: NSMutableArray! = NSMutableArray()
//            let emailDic: NSMutableDictionary! =  NSMutableDictionary()
//            emailDic.setObject(textFiled.text!, forKey: "email" as NSCopying)
//            emailDic.setObject(paymentType, forKey: "type" as NSCopying)
//            emailData.add(emailDic) //add(emailDic)
//            userDefaults.set(emailData, forKey: "paymentGetway")
//            userDefaults.synchronize()
//            pickerView.isHidden = true
//            KGModal.sharedInstance().hide()
//            for vc in (self.navigationController?.viewControllers ?? []) {
//                if vc is SelectPaymentVC {
//                    _ = self.navigationController?.popToViewController(vc, animated: true)
//                    break
//                }
//            }
//        } else {
//            let emailArrresults: NSMutableArray! = NSMutableArray()
//            for var data in emailData as NSMutableArray {
//                emailArrresults.add((data as AnyObject).value(forKey:"email") as? String)
//            }
//            let flag: Bool = (emailArrresults?.contains(textFiled.text))!
//            if (flag == false) {
//                let emailDic: NSMutableDictionary! = NSMutableDictionary()
//                emailDic.setObject(textFiled.text!, forKey: "email" as NSCopying)
//                emailDic.setObject(paymentType, forKey: "type" as NSCopying)
//                emailData.add(emailDic)
//                userDefaults.set(emailData, forKey: "paymentGetway")
//                userDefaults.synchronize()
//                pickerView.isHidden = true
//                KGModal.sharedInstance().hide()
//            for vc in (self.navigationController?.viewControllers ?? []) {
//                if vc is SelectPaymentVC {
//                    _ = self.navigationController?.popToViewController(vc, animated: true)
//                    break
//                }
//            }
//            
//        }
//        
//    }
}
}
