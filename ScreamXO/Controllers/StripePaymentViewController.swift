//
//  StripePaymentViewController.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 01/06/17.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit
import Stripe


class StripePaymentViewController: UIViewController, STPAddCardViewControllerDelegate, UITextFieldDelegate ,selectCardOrPaymentMethodDelegate {
    
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var paymentContext: STPPaymentContext!
    var isInType = false
    var pendingPurchase = false
    var addMinimumMoneyForPendingPurchase: String!
    var card_id : String!
     var cardDelegate: selectCardOrPaymentMethodDelegate!
//   init() {
////       // Here, MyAPIAdapter is your class that implements STPBackendAPIAdapter (see above)
////       self.paymentContext = STPPaymentContext(apiAdapter: MyAPIClient.sharedClient)
////       super.init(nibName: n, bundle: <#T##Bundle?#>)
////       self.paymentContext.delegate = self
////       self.paymentContext.hostViewController = self
////       self.paymentContext.paymentAmount = 5000 // This is in cents, i.e. $50 USD
//   }
   
   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
   }
    
    
    
    // MARK: View life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        amountTxt.delegate = self
        amountTxt.becomeFirstResponder()
        addBtn.layer.cornerRadius = 5
        addBtn.clipsToBounds = true
        if pendingPurchase {
           amountTxt.text =  addMinimumMoneyForPendingPurchase
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StripePaymentViewController.removeKeyword(_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func btnPayAction(_ sender: UIButton) {
        //self.paymentContext.pushPaymentMethodsViewController()
        
        let SelectPaymentVC = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SelectPaymentVC") as! SelectPaymentVC
        SelectPaymentVC.delegate = self
        SelectPaymentVC.isAddMoneyInWalletFlag = true
        self.navigationController?.pushViewController(SelectPaymentVC, animated: true)

        
        
        

    }
    
    func selectCardOrPaymentMethod(emailId: String) {
        card_id = emailId
        buyButtonTapped()
    }
    
    func selectCardOrPaymentMethodType(methodType: String , cardNumber: String) {
        
    }
    func buyButtonTapped() {
        if amountTxt.text == nil || amountTxt.text == "" {
            amountTxt.resignFirstResponder()
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter Amount")
        } else {
            addMoneyInWallet(cardID: card_id)
        }
        
        
    }
    
    func removeKeyword(_ sender: AnyObject) {
        amountTxt.resignFirstResponder()
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
        addNewCard()
        //self.postStripeToken(token: token)
    }
    
    
    
    func addNewCard() {
        let usr = UserManager.userManager
        let expMonth:String! = UserDefaults.standard.value(forKey:"expMonth") as! String
        let expYear:String! = UserDefaults.standard.value(forKey:"expYear") as! String
        let cardNumber:String! = UserDefaults.standard.value(forKey:"cardNumber") as! String
        let cardCvc:String! = UserDefaults.standard.value(forKey:"cardCvc") as! String
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(usr.stripeCustomerId, forKey: "customer_id")
        parameterss.setValue(cardNumber, forKey: "number")
        parameterss.setValue(expMonth, forKey: "exp_month")
        parameterss.setValue(expYear, forKey: "exp_year")
        parameterss.setValue(cardCvc, forKey: "cvc")
        
        let mgr = APIManager.apiManager
        mgr.addCard(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
           
            if dic != nil {
                self.dismiss(animated: true, completion: nil)
            }
            
            if result == APIResult.apiSuccess
            {
                 print(dic)
                //self.addMoneyInWallet(dic: dic!)
            }
            else if result == APIResult.apiError
            {
                
            }
            else
            {
            }
        })
        
    }

    
    
    func handleError(error: NSError) {
        print(error)
        UIAlertView(title: "Please Try Again",
                    message: error.localizedDescription,
                    delegate: nil,
                    cancelButtonTitle: "OK").show()
    }
    
    
    func addMoneyInWallet(cardID: String) {
        let mgrItm = ItemManager.itemManager
        let mgr = APIManager.apiManager
        let usrMgr = UserManager.userManager
        var params: [String: AnyObject] = [:]
        if isInType {
            params   = ["card_id": cardID as AnyObject ,
                        "customer_id": UserManager.userManager.stripeCustomerId as AnyObject,
                        "uid": usrMgr.userId as AnyObject,
                        "amount":amountTxt.text as AnyObject,
                        "type":"IN" as AnyObject
            ]

        } else {
            params   = ["access_token":cardID as AnyObject,
                        "uid": usrMgr.userId as AnyObject,
                        "shipping": mgrItm.ItemShipingaddress as AnyObject,
                        "productqty":  mgrItm.product_qty as AnyObject,
                        "itemid":  mgrItm.ItemId as AnyObject,
                         "type":"OUT" as AnyObject
            ]
        }
            
            SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
            mgr.stripePaymentProcess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
                
                if result == APIResult.apiSuccess {
                    print(dic!)
                    print(result)
                    if self.isInType {
                        params =   ["stripe_id": (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "stripe_payment_id") as! NSString,
                                    "uid": usrMgr.userId as AnyObject,
                                     "amount":self.amountTxt.text as AnyObject,
                                     "type":"IN" as AnyObject
                        ]
                        print(params)
                        mgr.addMoneyInWalletFinalProcess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
                            SVProgressHUD.dismiss()
                            if result == APIResult.apiSuccess {
                                print(dic!)
                                print(result)
                                let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"amount") as! Int)
                                print(walletMoney)
                                UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                                UserManager.userManager.userDefaults.synchronize()

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
                    } else {
                        params =   ["strip_response_id": (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "stripe_payment_id") as! NSString,
                                    "uid": usrMgr.userId as AnyObject,
                                    "shipping": mgrItm.ItemShipingaddress as AnyObject,
                                    "productqty": mgrItm.product_qty as AnyObject,
                                    "itemid": mgrItm.ItemId as AnyObject,
                                    "type": "OUT" as AnyObject
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
                    }
               
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

// MARK: Extensions

// STPPaymentContextDelegate

extension StripePaymentViewController: STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult,
                        completion: @escaping STPErrorBlock) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFinishWith status: STPPaymentStatus,
                        error: Error?) {
        
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext,
                        didFailToLoadWithError error: Error) {
        self.navigationController?.popViewController(animated: true)
        // Show the error to your user, etc.
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
    }
}
    



