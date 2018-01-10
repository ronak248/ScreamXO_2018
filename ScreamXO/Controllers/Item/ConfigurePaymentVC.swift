//
//  ConfigurePaymentVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 17/03/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AFNetworking
import coinbase_official
import Stripe
// FIXME: comparison operators with optionals were removed from the Swift Standard Libvar.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}

protocol ItemAddedSucess  {
    func actiononpayment()
    
}
class ConfigurePaymentVC: UIViewController,PayPalPaymentDelegate,PayPalFuturePaymentDelegate,PayPalProfileSharingDelegate, STPAddCardViewControllerDelegate ,STPPaymentMethodsViewControllerDelegate , UITextFieldDelegate
{
    
    // MARK: IBOutlets
    
    @IBOutlet weak var btnSell: RoundRectbtn!
    @IBOutlet var lblbitcoin: UILabel!
    @IBOutlet var lblpaypal: UILabel!
    @IBOutlet weak var walletMoney: UILabel!
    @IBOutlet var lblAlipay: UILabel!
    var settingFlag = false
    var isShopFlag = false
    var isAliPay = false
    var paymentTypeWallet = false
    var isBoostFlag = false
    var item_id: Int!
    var boost_type: Int!
    var days: String!
    var amount: String!
    var rechedPeople: String!
    // MARK: Properties
    
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
    var delegate : ItemAddedSucess!
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default
    var strtransactionID:String = ""
    var strrefreshtoken:String = ""
    var strfinaltoken:String = ""
    var stremail:String = ""
    let usr = UserManager.userManager
    var accestok:String!
    var client:Coinbase!
    
    @IBOutlet  var paymentConfigureView: UIView!
    @IBOutlet weak var emailTxt: UITextField!
    let mgrItm = ItemManager.itemManager
    // MARK: View lifecycle methods
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        getAccountDetails()
        paypalCOnfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTxt.delegate = self
        paymentConfigureView.layer.cornerRadius = 5.0
        paymentConfigureView.clipsToBounds = true
        let usrMgr =  UserManager.userManager
        if usrMgr.walletMoney != nil {
            walletMoney.text = usrMgr.walletMoney
        } else {
            walletMoney.text = "0"
        }
        
        if self.delegate==nil
        {
            btnSell.isHidden=true
        }
        else
        {
            btnSell.isHidden=false
        }
        
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
        
        
        //PayPalMobile.preconnect(withEnvironment: environment)

        NotificationCenter.default.addObserver(self, selector: #selector(ConfigurePaymentVC.gettoken(_:)), name: NSNotification.Name(rawValue: constant.forbitcoinprocess), object: nil)

    }

    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forbitcoinprocess), object: nil)

        
        if self.usr.ispaypalconfi == "1"
        {
            objAppDelegate.isconfiguredpayment = true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBActions
    
    @IBAction func btnWalletClicked(_ sender: AnyObject) {
        if isShopFlag {
            paymentByWallet()
        } else if isBoostFlag {
            payForBoostByWallet()
        }else if (delegate != nil) {
            
        }else if settingFlag {
            
        }else {
            let objwallet: WalletViewController =  objAppDelegate.stWallet.instantiateViewController(withIdentifier: "Wallet") as! WalletViewController
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
        }
    }
    
    
    @IBAction func btnAddPaymentMethodClicked(_ sender: AnyObject) {

        
        if isBoostFlag {
            buttonStripeClicked()
        } else if settingFlag {
            
        }else if (self.delegate != nil) {
            
        } else {
             buttonStripeClicked()
        }
    }
    
    @IBAction func submitPaymentConfigure(_ sender: Any) {
        paymentConfigureView.isHidden = true
        KGModal.sharedInstance().hide()
        if mainInstance.isTextfieldBlank(emailTxt) {
            mainInstance.ShowAlertWithError("ScreamXO", msg: "Please enter bitcoin email id")
        } else {
            if isAliPay {
                callApiForPaymentByStripeAlipay()
            } else {
                callApiForPaymentByStripeBitcoin()
            }
            
        }
        
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        if scoreText == emailTxt {
            self.view.endEditing(true)
        self.paymentConfigureView.endEditing(true)
        }
        return true
    }
    
    
    func  callApiForPaymentByStripeAlipay() {
        
        let mgr = APIManager.apiManager
        let usrMgr = UserManager.userManager
        var params: [String: AnyObject] = ["email_id": emailTxt.text as AnyObject,
                                           "uid": usrMgr.userId as AnyObject,
                                           "shipping": mgrItm.ItemShipingaddress as AnyObject,
                                           "productqty":  mgrItm.product_qty as AnyObject,
                                           "itemid":  mgrItm.ItemId as AnyObject
        ]
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        mgr.StripealipaypaymentPprocessalipay(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
            
            if result == APIResult.apiSuccess {
                print(dic!)
                print(result)
                
                
                
                params =   ["stripe_source_id": (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "stripe_source_id") as AnyObject
                ]
                print(params)
                
                SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
                    mgr.Stripealipaypaymentfinalprocess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
                        SVProgressHUD.dismiss()
                        if result == APIResult.apiSuccess {
                            print(dic!)
                            print(result)
                            mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                            self.dismiss(animated: true)
                            let VC1:CongratsShopVC! = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsShopVC")) as! CongratsShopVC
                            VC1.itemimage = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemimage") as! String
                            VC1.itemName = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemname") as! String
                            self.navigationController?.pushViewController(VC1, animated: true)
                        } else if result == APIResult.apiError {
                            mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                            SVProgressHUD.dismiss()
                        }  else {
                            SVProgressHUD.dismiss()
                            mainInstance.showSomethingWentWrong()
                        }
                    })
                })
                
                
            } else if result == APIResult.apiError {
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
            
        })
        
    }
    
    
    func callApiForPaymentByStripeBitcoin() {
    
        let mgr = APIManager.apiManager
        let usrMgr = UserManager.userManager
        var params: [String: AnyObject] = ["email_id": emailTxt.text as AnyObject,
                                           "uid": usrMgr.userId as AnyObject,
                                           "shipping": mgrItm.ItemShipingaddress as AnyObject,
                                           "productqty":  mgrItm.product_qty as AnyObject,
                                           "itemid":  mgrItm.ItemId as AnyObject
                                           ]
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        mgr.stripePaymentProcessBitcoin(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
            
            if result == APIResult.apiSuccess {
                print(dic!)
                print(result)
                
                
                
                params =   ["stripe_source_id": (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "stripe_source_id") as AnyObject
                ]
                print(params)
                
                SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: {
                mgr.StripeBitcoinPaymentFinalprocess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess {
                        print(dic!)
                        print(result)
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        self.dismiss(animated: true)
                        let VC1:CongratsShopVC! = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsShopVC")) as! CongratsShopVC
                        VC1.itemimage = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemimage") as! String
                        VC1.itemName = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemname") as! String
                        self.navigationController?.pushViewController(VC1, animated: true)
                    } else if result == APIResult.apiError {
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                    }  else {
                        SVProgressHUD.dismiss()
                        mainInstance.showSomethingWentWrong()
                    }
                })
                })
                
                
            } else if result == APIResult.apiError {
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
            
        })
        
    }
    
    @IBAction func alipayPaymentBtn(_ sender: Any) {
        if isShopFlag {
            
            emailTxt.placeholder = "Please enter your Alipya Email Id"
            isAliPay = true
            paymentConfigureView.isHidden = false
            KGModal.sharedInstance().show(withContentView: paymentConfigureView)
        }
    }
    
    @IBAction func btnSellItemClicked(_ sender: AnyObject) {
        
        if delegate != nil {
            self.usr.ispaypalconfi = "1"
        }
        if self.usr.ispaypalconfi == "1"
        {
            let message:String!="Are you sure you want to continue with above account?"
            
            let refreshAlert = UIAlertController(title: "Confirm!", message: message, preferredStyle: UIAlertControllerStyle.alert)
            refreshAlert.addAction(UIAlertAction(title: "Yes, I agree!", style: .default, handler: { (action: UIAlertAction!) in
                self.delegate.actiononpayment()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
        else
        {
               mainInstance.ShowAlertWithError("ScreamXO", msg:"Please configure atleast one account before proceed!")
        }
    }
    
    
    @IBAction func backButtonCLicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func payForBoostByWallet() {
        let mgr = APIManager.apiManager
        let usr = UserManager.userManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(amount, forKey: "amount")
        parameterss.setValue(days, forKey: "no_days")
        parameterss.setValue(rechedPeople, forKey: "no_users")
        parameterss.setValue(UserManager.userManager.walletMoney , forKey: "wallet_amount")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(item_id, forKey: "itemid")
        parameterss.setValue(boost_type, forKey: "boost_type")
        SVProgressHUD.show()
        mgr.WalletorderpaymentForBoost(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsBoostVC")) as! CongratsBoostVC
                VC1.boost_type = self.boost_type
                self.navigationController?.pushViewController(VC1, animated: true)
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
    
    
    
    @IBAction func btnsaveSettingClicked(_ sender: AnyObject) {
        
    }
    
    @IBAction func btnPaypalClicked(_ sender: AnyObject) {
        //buttonStripeClicked()
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
    }

    //MARK: TextFieldDelegate 
    
    
    
    
    
    @IBAction func btnBitcoinCLicked(_ sender: AnyObject) {
        //buttonStripeClicked()
        
        if isShopFlag {
            paymentConfigureView.isHidden = false
            KGModal.sharedInstance().show(withContentView: paymentConfigureView)
        }
        
        
//        if (lblbitcoin.text == "Not Configured")
//        {
//        
//        let mgradmin = AdminManager.adminManager
//
//            CoinbaseOAuth.startAuthentication(withClientId: mgradmin.bitcoincID, scope: "balance transactions user", redirectUri:"com.simform.screamxo.coinbase-oauth://coinbase-oauth", meta: nil)
//            
//        }
//        else
//        {
//            
//            let message:String!="Are you sure you want to change account?"
//            
//            let refreshAlert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.alert)
//            
//            refreshAlert.addAction(UIAlertAction(title: "Yes, I agree!", style: .default, handler: { (action: UIAlertAction!) in
//                let mgradmin = AdminManager.adminManager
//                
//                CoinbaseOAuth.startAuthentication(withClientId: mgradmin.bitcoincID, scope: "balance transactions user", redirectUri:"com.simform.screamxo.coinbase-oauth://coinbase-oauth", meta: nil)
//            }))
//            
//            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
//            }))
//            
//            self.present(refreshAlert, animated: true, completion: nil)
//        }
    }
    
    // MARK: PayPalPaymentDelegate & Configuration
    
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
        
        
//        payPalConfig.acceptCreditCards = acceptCreditCards;
//        payPalConfig.merchantName = "Awesome Shirts, Inc."
//        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
//        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        

        
        
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
    
    // MARK: Future Payments
    
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
    
    // PayPalProfileSharingDelegate
    
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
                if (type == "bitcoin") {
                    self.lblbitcoin.text="\(email)"
                    self.usr.ispaypalconfi="1"
                } else {
                    self.lblpaypal.text="\(email)"
                    self.usr.ispaypalconfi="1"
                    
                }
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
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

                if strlbl?.characters.count <= 0
                {
                    self.lblpaypal.text = "Not Configured"
                }
                else
                {
                    self.lblpaypal.text = strlbl
                    self.usr.ispaypalconfi = "1"
                }
                if strlblbit?.characters.count <= 0
                {
                    self.lblAlipay.text = "Not Configured"
                    self.lblbitcoin.text = "Not Configured"
                }
                else
                {
                    self.lblbitcoin.text = strlblbit
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

    // MARK: get Userdetails
    
    func getUserdetails()
    {
        client.getCurrentUser { user,error -> Void in
            
            if ((error) != nil)
            {
                print(error?.localizedDescription)
            }
            else
            {
                print(user?.email!)
                self.lblbitcoin.text=user!.email
                self.callwebserver(user!.email! as NSString,type: "bitcoin")
            }
        }
    }
    
    func gettoken(_ notification: Notification)
    {
        //deal with notification.userInfo
        print(notification.userInfo!)
        
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

        let dicdata : NSDictionary! = notification.object as! NSDictionary
        let token : String! = dicdata.value(forKey: "access_token") as! String
        let reftoken : String! = dicdata.value(forKey: "refresh_token") as! String
        UserDefaults.standard.set(token, forKey: "access_token")
        UserDefaults.standard.set(reftoken, forKey: "refresh_token")
        client = Coinbase(oAuthAccessToken:token)
        getUserdetails()
    }
    
    
    
    func buttonStripeClicked() {
            let addCardViewController = STPAddCardViewController()
            addCardViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: addCardViewController)
            self.present(navigationController, animated: true, completion: nil)
    }
    
    func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        print(token)
        
        if isBoostFlag {
            self.submitTokenToBackendForBoostItem(token: token, completion: { (error: Error?) in
                print(token)
                if let error = error {
                    completion(error)
                } else {
                    self.dismiss(animated: true, completion: {
                        completion(nil)
                    })
                }
            })

        } else {
        self.submitTokenToBackend(token: token, completion: { (error: Error?) in
            print(token)
            if let error = error {
                completion(error)
            } else {
                self.dismiss(animated: true, completion: {
                    completion(nil)
                })
            }
        })
        }
    }
    
    
    
    func submitTokenToBackendForBoostItem(token: STPToken, completion: (_ error:Error)->()){
        print(token)
        self.postStripeTokenForBoostItem(token: token)
    }
    
    
    
    func postStripeTokenForBoostItem(token: STPToken) {
        
        
        let mgr = APIManager.apiManager
        let usr = UserManager.userManager
        var parameterss = NSMutableDictionary()
        parameterss.setValue(amount, forKey: "amount")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(item_id, forKey: "itemid")
        parameterss.setValue("", forKey: "shipping")
        parameterss.setValue(boost_type, forKey: "boost_type")
        parameterss.setValue(token, forKey: "access_token")
        parameterss.setValue("out", forKey: "type")
         SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        mgr.processForBoost(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                SVProgressHUD.dismiss()
                print(dic!)
                print(result)
                parameterss =   ["strip_response_id": (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "stripe_payment_id") as! NSString,
                            "uid": usr.userId as AnyObject,
                            "shipping": "",
                            "boost_type":  self.boost_type,
                            "itemid":  self.item_id,
                            "amount": self.amount,
                            "no_days":  self.days,
                             "no_users":  self.rechedPeople,
                              "wallet_amount":  UserManager.userManager.walletMoney,
                ]
                print(parameterss)
                SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
                mgr.finalBoostprocess(parameterss , successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess {
                        print(dic!)
                        print(result)
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        self.dismiss(animated: true)
                        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsBoostVC")) as! CongratsBoostVC
                        VC1.boost_type = self.boost_type
                        self.navigationController?.pushViewController(VC1, animated: true)
                    } else if result == APIResult.apiError {
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                    }  else {
                        SVProgressHUD.dismiss()
                        mainInstance.showSomethingWentWrong()
                    }
                })
                
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

    
    
    func submitTokenToBackend(token: STPToken, completion: (_ error:Error)->()){
        print(token)
             self.postStripeToken(token: token)
    }
    
    func handleError(error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
    }
    
    
    func postStripeToken(token: STPToken) {
        print(token)
        let mgr = APIManager.apiManager
        let usrMgr = UserManager.userManager
        var params: [String: AnyObject] = ["access_token": token.tokenId as AnyObject,
                                           "uid": usrMgr.userId as AnyObject,
                                           "shipping": mgrItm.ItemShipingaddress as AnyObject,
                                           "productqty":  mgrItm.product_qty as AnyObject,
                                           "itemid":  mgrItm.ItemId as AnyObject,
                                            "type": "OUT" as AnyObject,
        ]
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        mgr.stripePaymentProcess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
            
            if result == APIResult.apiSuccess {
                print(dic!)
                print(result)
                params =   ["strip_response_id": (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "stripe_payment_id") as! NSString,
                            "uid": usrMgr.userId as AnyObject,
                            "shipping": self.mgrItm.ItemShipingaddress as AnyObject,
                            "productqty":  self.mgrItm.product_qty as AnyObject,
                            "itemid":  self.mgrItm.ItemId as AnyObject
                ]
                print(params)
                mgr.stripePaymentFinalProcess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess {
                        print(dic!)
                        print(result)
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        self.dismiss(animated: true)
                        
                        let VC1:CongratsShopVC! = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsShopVC")) as! CongratsShopVC
                        VC1.itemimage = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemimage") as! String
                        VC1.itemName = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemname") as! String
                        self.navigationController?.pushViewController(VC1, animated: true)
                        
                        
                    } else if result == APIResult.apiError {
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                    }  else {
                        SVProgressHUD.dismiss()
                        mainInstance.showSomethingWentWrong()
                    }
                })
            } else if result == APIResult.apiError {
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
            
        })
    }
    
    
 func paymentByWallet()   {
    let mgr = APIManager.apiManager
    let usrMgr = UserManager.userManager
   let  params =   [
    "uid": usrMgr.userId as AnyObject,
    "wallet_amount": usrMgr.walletMoney as AnyObject,
    "shipping": self.mgrItm.ItemShipingaddress as AnyObject,
    "productqty":  self.mgrItm.product_qty as AnyObject,
    "itemid":  self.mgrItm.ItemId as AnyObject
    ]
    print(params)
     SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
    mgr.walletPaymentFinalProcess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
    SVProgressHUD.dismiss()
    if result == APIResult.apiSuccess {
    print(dic!)
    print(result)
        let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"amount") as! Int)
        UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
        UserManager.userManager.userDefaults.synchronize()
    mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
    self.dismiss(animated: true)
        
        let VC1:CongratsShopVC! = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsShopVC")) as! CongratsShopVC
        
        VC1.itemimage = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemimage") as! String
        VC1.itemName = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "itemname") as! String
        self.navigationController?.pushViewController(VC1, animated: true)
        
    } else if result == APIResult.apiError {
        
        let alertController = UIAlertController(title: "ScreamXO", message: dic!.value(forKey: "msg")! as! NSString as String, preferredStyle: UIAlertControllerStyle.alert)
        
        let DestructiveAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in

        }
        

        let okAction = UIAlertAction(title: "Add Money", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            
            let stripePaymentViewController = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "addAmount") as! StripePaymentViewController
            stripePaymentViewController.isInType = true
            stripePaymentViewController.pendingPurchase = true
            var amount: AnyObject!
            amount = (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "need_amount") as AnyObject
            print(amount)
            
            print(String(describing: amount))
            let amountStr: String!  = String(describing: amount) 
            print(amountStr)
           stripePaymentViewController.addMinimumMoneyForPendingPurchase = String(describing: amount)
            self.navigationController?.pushViewController(stripePaymentViewController, animated: true)
        }
        
        alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
//        
//    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
//    SVProgressHUD.dismiss()
    }  else {
    SVProgressHUD.dismiss()
    mainInstance.showSomethingWentWrong()
    }
    })
    }
    
    
    
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didFailToLoadWithError error: Error) {
        dismiss(animated: true)
        
    }
    
    func paymentMethodsViewControllerDidCancel(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        dismiss(animated: true)
    }
    
    func paymentMethodsViewControllerDidFinish(_ paymentMethodsViewController: STPPaymentMethodsViewController) {
        dismiss(animated: true)
    }
    
    func paymentMethodsViewController(_ paymentMethodsViewController: STPPaymentMethodsViewController, didSelect paymentMethod: STPPaymentMethod) {
        var selectedPaymentMethod: STPPaymentMethod!
        selectedPaymentMethod = paymentMethod
        print(selectedPaymentMethod)
    }
   
    
}
