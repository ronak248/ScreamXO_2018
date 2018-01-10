
//
//  PaymentVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 17/03/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AFNetworking
import coinbase_official
import Stripe

class PaymentVC: UIViewController,PayPalPaymentDelegate,PayPalFuturePaymentDelegate,PayPalProfileSharingDelegate, STPPaymentCardTextFieldDelegate,STPAddCardViewControllerDelegate {
    
    // MARK: Properties
    
    var environment:String = PayPalEnvironmentProduction {
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
    
    var resultText = "" // empty
    var payPalConfig = PayPalConfiguration() // default
    var isSucePmt:Bool = false
    var strtransactionID:String = ""
    var coinbase = Coinbase(apiKey: AdminManager.adminManager.bitcoincID, secret: AdminManager.adminManager.bitcoincSecret)
    var accountfinal: CoinbaseAccount!
    
    var coinbasetransfer:Coinbase!
    let mgrItm = ItemManager.itemManager
    
    // MARK: IBOutlets
    
    @IBOutlet weak var lblacceptBit: UILabel!
    @IBOutlet weak var lblacceptPaypal: UILabel!
    @IBOutlet var viewWeb: UIControl!
    @IBOutlet var wbpayment: UIWebView!
    var token1 : String!
    // MARK: View life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentProduction)
        paypalCOnfiguration()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: constant.forbitcoinprocess), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if (mgrItm.ispaymentKind=="3")
        {
            lblacceptBit.isHidden=true
            lblacceptPaypal.isHidden=true
        }
        else if (mgrItm.ispaymentKind=="1")
        {
            lblacceptBit.isHidden=true
            lblacceptPaypal.isHidden=false
        }
        else if (mgrItm.ispaymentKind=="2")
        {
            lblacceptBit.isHidden=false
            lblacceptPaypal.isHidden=true
        }
        else
        {
            lblacceptBit.isHidden=false
            lblacceptPaypal.isHidden=true
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(PaymentVC.gettoken(_:)), name: NSNotification.Name(rawValue: constant.forbitcoinprocess), object: nil)
        
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    // MARK: IBActions
    
    @IBAction func btnbackwebClicked(_ sender: AnyObject) {
        
        viewWeb.removeFromSuperview()
        
    }
    @IBAction func backButtonCLicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPaypalClicked(_ sender: AnyObject) {
        
        
        if (mgrItm.ispaymentKind=="3" || mgrItm.ispaymentKind=="1")
        {
            
            isSucePmt=false
            
            let mgrItm = ItemManager.itemManager
            
            mgrItm.purchaseItem(1,successClosure:{ (dic, result) -> Void in
                
                if result == APIResultItm.apiSuccess
                {
                    let strpykey:String! = dic?.value(forKeyPath: "result.PayKey") as! String
                    let strurl:String! = dic?.value(forKeyPath: "result.RedirectURL") as! String
                    
                    mgrItm.Itempaykey=strpykey
                    let url = URL (string: strurl);
                    let requestObj = URLRequest(url: url!);
                    self.wbpayment.loadRequest(requestObj);
                    //self.wbpayment.scalesPageToFit=true
                    self.viewWeb.frame = self.view.frame
                    self.view.addSubview(self.viewWeb)
                }
            })
        }
        else
        {
            mainInstance.ShowAlertWithError("Error!", msg: "This seller only accepts Bitcoin")
        }
    }
    
    @IBAction func btnBitcoinCLicked(_ sender: AnyObject)
    {
    buyButtonTapped()
        
        
//        if (mgrItm.ispaymentKind=="3" || mgrItm.ispaymentKind=="2")
//        {
//            let accestok:String?=nil
//            if (accestok == nil)
//            {
//                let parameterss = NSMutableDictionary()
//                parameterss.setValue("1", forKey: "send_limit_amount")
//                parameterss.setValue("USD", forKey: "send_limit_currency")
//                parameterss.setValue("day", forKey: "send_limit_period")
//                let mgradmin = AdminManager.adminManager
//                CoinbaseOAuth.startAuthentication(withClientId: mgradmin.bitcoincID, scope: "balance transactions user,send", redirectUri:"com.simform.screamxo.coinbase-oauth://coinbase-oauth", meta: parameterss as NSMutableDictionary as! [AnyHashable: Any])
//            }
//            else
//            {
//                coinbasetransfer = Coinbase(oAuthAccessToken:accestok)
//                self.transferbitcoin()
//            }
//        }
//        else
//        {
//            mainInstance.ShowAlertWithError("Error!", msg: "This seller only accepts Paypal")
//        }
//        
    }
    
    // MARK: Paypal configuration
    
    func paypalCOnfiguration()
    {
        
        payPalConfig.acceptCreditCards = acceptCreditCards;
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        
        // Setting the payPalShippingAddressOption property is optional.
        //
        // See PayPalConfiguration.h for details.
        
        payPalConfig.payPalShippingAddressOption = .payPal;
        
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
        
        
    }
    // MARK: PayPalPaymentDelegate
    
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
            print(dic)
            self.strtransactionID = dic?.value(forKeyPath: "response.id") as! String
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
    
    func payPalFuturePaymentViewController(_ futurePaymentViewController: PayPalFuturePaymentViewController, didAuthorizeFuturePayment futurePaymentAuthorization: [AnyHashable: Any]) {
        print("PayPal Future Payment Authorization Success!")
        futurePaymentViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = futurePaymentAuthorization.description
        })
    }
    
    // MARK: Profile Sharing
    
    @IBAction func authorizeProfileSharingAction(_ sender: AnyObject) {
        let scopes = [kPayPalOAuth2ScopeOpenId, kPayPalOAuth2ScopeEmail, kPayPalOAuth2ScopeAddress, kPayPalOAuth2ScopePhone]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
        present(profileSharingViewController!, animated: true, completion: nil)
    }
    
    // PayPalProfileSharingDelegate
    
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        print("PayPal Profile Sharing Authorization Canceled")
        profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable: Any]) {
        print("PayPal Profile Sharing Authorization Success!")
        
        // send authorization to your server
        
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = profileSharingAuthorization.description
        })
        
    }
    
    
    func verifyCompletedPayment(_ completedPayment: PayPalPayment) {
        // Send the entire confirmation dictionary
        
        do {
            
            
            var confirmation: Data = try JSONSerialization.data(withJSONObject: completedPayment.confirmation, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch {
            print(error)
            
        }
        
        // Send confirmation to your server; your server should verify the proof of payment
        // and give the user their goods or services. If the server is not reachable, save
        // the confirmation and try again later.
    }
    
    // MARK: paypal webview load data
    
    func webView(_ webView: UIWebView, shouldStartLoadWithRequest request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool
        
    {
        
        
        if (request.url!.absoluteString.contains("execution=e2s2")&&isSucePmt==false) {
            isSucePmt=true
            viewWeb.removeFromSuperview()
            mgrItm.finalpayment(1,successClosure:{ (dic, result) -> Void in
                if result == APIResultItm.apiSuccess
                {
                    SVProgressHUD.dismiss()
                    
                    mainInstance.ShowAlertWithSucess("ScreamXO", msg: "Item purchased successfully")
                    self.navigationController?.popToRootViewController(animated: true)
                    
                    
                }
                
            })
            
            //self.validatePayment()
            return true
        }
        if (request.url!.absoluteString.contains("execution=e1s2")) {
            
            
            SVProgressHUD.dismiss()
            
            //self.validatePayment()
            return true
        }
        else if (request.url!.absoluteString.contains("closewindow")) {
            
            viewWeb.removeFromSuperview()
            SVProgressHUD.dismiss()
            
            
            //self.validatePayment()
            return true
        }
        return true
        
        
        
    }
    // MARK: bitcoin transcation data
    
    func gettoken(_ notification: Notification) {
        
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        
        //deal with notification.userInfo
        print(notification.userInfo)
        
        
        let dicdata : NSDictionary! = notification.object as! NSDictionary
        token1 = dicdata.value(forKey: "access_token") as! String
        let reftoken : String! = dicdata.value(forKey: "refresh_token") as! String
        
        UserDefaults.standard.set(token1, forKey: "access_token_pm")
        UserDefaults.standard.set(reftoken, forKey: "refresh_token_pm")
        
        coinbasetransfer = Coinbase(oAuthAccessToken:token1)
        
        coinbasetransfer.getExchangeRates { (dictianry:[AnyHashable: Any]!,error: Error!) -> Void in
            
            self.mgrItm.dicExchangerate = dictianry as NSDictionary
            
            let price:CGFloat = CGFloat(Float(self.mgrItm.ItemPrice)! + Float(self.mgrItm.ItemShipingCost!)!)
            let exchangerate:CGFloat = CGFloat(Double(self.mgrItm.dicExchangerate.value(forKey: "usd_to_btc") as! String)!)
            let totalcoin:CGFloat = CGFloat(price * exchangerate)
            
            SVProgressHUD.dismiss()
            let message:String!="It will deduct \(totalcoin) coin from your coinbase account.are you sure you want to continue?"
            
            let refreshAlert = UIAlertController(title: "Warning!", message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Yes, I agree!", style: .default, handler: { (action: UIAlertAction!) in
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                
                self.transferbitcoin()
            }))
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            }))
            self.present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func transferbitcoin()
    {
        coinbasetransfer.getCurrentUser { (user: CoinbaseUser!,error: Error!) -> Void in
            if ((error) != nil)
            {
                print(error.localizedDescription)
            }
            else
            {
                print(user.email)
            }
        }
        coinbasetransfer.getCurrentUser { (user: CoinbaseUser!,error: Error!) -> Void in
            if ((error) != nil)
            {
                print(error.localizedDescription)
            }
            else
            {
                print(user.email)
                let mgrItm = ItemManager.itemManager
                let mgrAdmin = AdminManager.adminManager
                
                if (user.email != mgrAdmin.bitcoinemail && user.email != mgrItm.Itembitcoinmail)
                {
                    
                    SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                    
                    self.coinbasetransfer.getAccountsList { ( Array: [Any]!, helper:CoinbasePagingHelper!, error: Error!) -> Void in
                        if (Array != nil)
                        {
                            self.accountfinal = Array[0] as! CoinbaseAccount
                            print(self.accountfinal.balance.amount)
                            
                            let balance:CGFloat = CGFloat(Double(self.accountfinal.balance.amount!)!)
                            let price:CGFloat = CGFloat(Double(self.mgrItm.ItemPrice)! + Double((self.mgrItm.ItemShipingCost))!)
                            var actualprice:CGFloat = CGFloat(Double(mgrItm.ItemactualPrice!)!)
                            let exchangerate:CGFloat = CGFloat(Double(self.mgrItm.dicExchangerate.value(forKey: "usd_to_btc") as! String)!)
                            let totalcoin:CGFloat = CGFloat(price * exchangerate)
                            var cutamount:CGFloat = CGFloat(Double(self.mgrItm.ItemPrice)!) - actualprice
                            actualprice = actualprice*exchangerate
                            cutamount = cutamount*exchangerate
                            if balance >= totalcoin
                            {
                                self.accountfinal.client=self.coinbasetransfer
                                print(self.accountfinal.name)
                                self.accountfinal.sendAmount(String(describing: cutamount), to: mgrAdmin.bitcoinemail, completion: {(transaction: CoinbaseTransaction!, error: Error!) -> Void in
                                    if ((error) != nil)
                                    {
                                        let dicerror:Dictionary<String,AnyObject> = error._userInfo as! Dictionary<String,AnyObject>
                                        
                                        mainInstance.ShowAlertWithError("Error!", msg: ((dicerror["errors"] as! [AnyObject])[0] as! NSString) )
                                        SVProgressHUD.dismiss()
                                    }
                                    else
                                    {
                                        self.accountfinal.sendAmount(String(describing: actualprice), to: mgrItm.Itembitcoinmail, completion: {(transaction: CoinbaseTransaction!, error: Error!) -> Void in
                                            if ((error) != nil)
                                            {
                                                let dicerror:Dictionary<String,AnyObject> = error._userInfo as! Dictionary<String,AnyObject>
                                                
                                                mainInstance.ShowAlertWithError("Error!", msg: ((dicerror["errors"] as! [AnyObject])[0] as! NSString) )
                                                SVProgressHUD.dismiss()
                                            }
                                            else
                                            {
                                                let mgrItm = ItemManager.itemManager
                                                mgrItm.purchasebitcoinItem(transaction.transactionID,successClosure:{ (dic, result) -> Void in
                                                    if result == APIResultItm.apiSuccess
                                                    {
                                                        SVProgressHUD.dismiss()
                                                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: "Item purchased successfully")
                                                        self.navigationController?.popToRootViewController(animated: true)
                                                    }
                                                })
                                            }
                                        })
                                    }
                                })
                            }
                            else
                            {
                                mainInstance.ShowAlertWithError("Error!", msg: "You do not have sufficient bitcoin to purchase this item")
                                SVProgressHUD.dismiss()
                            }
                        }
                        else
                        {
                            mainInstance.ShowAlertWithError("Error!", msg: "Account not configured properly")
                            SVProgressHUD.dismiss()
                        }
                    }
                    
                }
                else
                {
                    mainInstance.ShowAlertWithError("Error!", msg: "you can not transfer coin to your account itself")
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    
    func buyButtonTapped() {
        
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
                                           "itemid":  mgrItm.ItemId as AnyObject
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
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        self.dismiss(animated: true)
                        self.navigationController?.popViewController(animated: true)
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
}



