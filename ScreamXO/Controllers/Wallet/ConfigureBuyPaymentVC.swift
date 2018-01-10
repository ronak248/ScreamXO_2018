//
//  ConfigureBuyPaymentVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-10-25.
//  Copyright © 2017 Ronak Barot. All rights reserved.
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
    
    
    
    class ConfigureBuyPaymentVC: UIViewController , selectCardOrPaymentMethodDelegate
    {
        
        @IBOutlet weak var btnPay: RoundRectbtn!
        
        @IBOutlet weak var itemImgView: UIImageView!
         @IBOutlet var itemName: UILabel!
         @IBOutlet var itemCost: UILabel!
        
        
        @IBOutlet var lblitemCost: UILabel!
        @IBOutlet var lblshippingCost: UILabel!
        @IBOutlet var lbltotalCost: UILabel!
        @IBOutlet var lblItmQty: UILabel!
        
        var cardDelegate: selectCardOrPaymentMethodDelegate!
        var selectedItmValue: Int?
        
        let mgrItm = ItemManager.itemManager
        var selecedCountryValue: Int?
        var shippingInfo = [String: String]()
        var payByCard: Bool = false
        var payByStripeMethod:Bool = false
        var paymentType: String! = String()
        var cardType: String! = String()
        var card_Id: String! = String()
        var lbltotalCostStr: String!

        // MARK: IBOutlets
        
        @IBOutlet weak var btnSell: RoundRectbtn!
        @IBOutlet weak var walletMoney: UILabel!
        @IBOutlet weak var cardBillLbl: UILabel!
        @IBOutlet weak var addressLbl: UILabel!
        @IBOutlet weak var userNameLbl: UILabel!
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
        
        @IBOutlet weak var payBtn: RoundRectbtn!
        @IBOutlet weak var itemPriceQtyView: UIView!
        var delegate : ItemAddedSucess!
        var resultText = "" // empty
        let usr = UserManager.userManager
        
        // MARK: View lifecycle methods
        
        override func viewDidLoad()
        {
            super.viewDidLoad()
            
        }
        
        override func viewWillAppear(_ animated: Bool) {
            
            
            let usrMgr =  UserManager.userManager
            if usrMgr.walletMoney != nil {
                let delimiter = "."
                let newstr = usrMgr.walletMoney!
                var decimal = newstr.components(separatedBy: delimiter)
                let decimalAmount: String!
                var amount:Float! = Float()
                if decimal.count > 1 {
                    decimalAmount = decimal[1]
                } else {
                    decimalAmount = "00"
                }
                
                amount = Float(decimal[0])
                let largeNumber = amount
                let numberFormatter = NumberFormatter()
                numberFormatter.numberStyle = NumberFormatter.Style.decimal
                let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
                let FinalAmount = String(describing: formattedNumber!) + ".\(decimalAmount!)"
                walletMoney.text = "$ " + FinalAmount
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
            
             getShippingAddress()
            if isShopFlag {
                itemPriceQtyView.isHidden = false
                userNameLbl.text = UserManager.userManager.username
            } else {
                itemPriceQtyView.isHidden = true
            }
            
            
            lblitemCost.text = mgrItm.ItemPrice
            lblshippingCost.text = mgrItm.ItemShipingCost
            lblItmQty.text = "1"
            mgrItm.product_qty = "1"
            var a:Float? = Float(lblitemCost.text!) // firstText is UITextField
            var b:Float? = Float(lblshippingCost.text!) // secondText is UITextField
            var c: Float?
            if self.lblItmQty.text != "Select Qty" {
                c = Float("1")
                lblItmQty.text = "1"
            } else {
                c = 0
            }
            
            if (b == nil)
            {
                b = 0
            }
            if (a == nil)
            {
                a = 0
            }
            if c != 0 {
                lbltotalCostStr = String(format:"%.2f",((a!*c!)+b!))
                lbltotalCost.text = String(format:"%.2f",((a!*c!)+b!))
                lbltotalCost.text = "$ " + lbltotalCostStr
            } else {
                 lbltotalCostStr = String(format:"%.2f",(a!+b!))
                lbltotalCost.text = String(format:"%.2f",(a!+b!))
                lbltotalCost.text = "$ " + lbltotalCostStr
            }
            self.itemName.text = ItemManager.itemManager.ItemName
            
            
            
            let delimiter = "."
            let newstr = ItemManager.itemManager.ItemPrice as! String
            var decimal = newstr.components(separatedBy: delimiter)
            
            let decimalAmount: String!
            if decimal.count > 1 {
                decimalAmount = decimal[1]
            } else {
                decimalAmount = ""
            }
            var amountData:Float! = Float()
            amountData = Float(decimal[0])
            let largeNumber = amountData
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
            let FinalAmount = String(describing: formattedNumber!) + "\(decimalAmount!)"

            self.itemCost.text = "$" + FinalAmount
            addressLbl.text = ItemManager.itemManager.ItemShipingaddress
            self.itemImgView.sd_setImageWithPreviousCachedImage(with: URL(string: ItemManager.itemManager.ItemImg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
              
            })
        }
        
        
        
        
        func getShippingAddress()
        {
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            
            let parameterss = NSMutableDictionary()
            parameterss.setValue(usr.userId, forKey: "uid")
            
            print(parameterss)
            
            SVProgressHUD.show(withStatus: "Fetching Details", maskType: SVProgressHUDMaskType.clear)
            
            mgr.getShippingAddress(parameterss, successClosure: { (dic, result) -> Void in
                
                SVProgressHUD.dismiss()
                print(dic)
                
                if result == APIResult.apiSuccess
                {
                    if String(describing: (dic!.object(forKey: "result")! as AnyObject).object(forKey: "shipping_address")!) != ""
                    {
                        self.shippingInfo["City"] = String(describing: (dic!.object(forKey: "result")! as AnyObject).object(forKey: "shipping_address")!.value(forKey: "City")!)
                        self.shippingInfo["Country"] = String(describing: (dic!.object(forKey: "result")! as AnyObject).object(forKey: "shipping_address")!.value(forKey: "Country")!)
                        self.shippingInfo["State"] = String(describing: (dic!.object(forKey: "result")! as AnyObject).object(forKey: "shipping_address")!.value(forKey: "State")!)
                        self.shippingInfo["Street"] = String(describing: (dic!.object(forKey: "result")! as AnyObject).object(forKey: "shipping_address")!.value(forKey: "Street")!)
                        self.shippingInfo["Zipcode"] = String(describing: (dic!.object(forKey: "result")! as AnyObject).object(forKey: "shipping_address")!.value(forKey: "Zipcode")!)
                        
                        let txtcity:String! = self.shippingInfo["City"]
                        let txtcountry:String! = self.shippingInfo["Country"]
                        let txtstate:String! = self.shippingInfo["State"]
                        let txtStreet:String! = self.shippingInfo["Street"]
                        let txtZip:String! = self.shippingInfo["Zipcode"]
                        ItemManager.itemManager.ItemShipingaddress = "\(txtStreet!), \(txtcity!) - \(txtZip!), \(txtstate!), \(txtcountry!)"
                        self.addressLbl.text = ItemManager.itemManager.ItemShipingaddress
                        
                    }
                }
                else if result == APIResult.apiError
                {
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                }
                else
                {
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                }
            })
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
                let objwallet: WalletViewController =  objAppDelegate.stWallet.instantiateViewController(withIdentifier: "Wallet") as! WalletViewController
                objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
            } else if isBoostFlag {
                let objwallet: WalletViewController =  objAppDelegate.stWallet.instantiateViewController(withIdentifier: "Wallet") as! WalletViewController
                objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
            }else if (delegate != nil) {
                
            }else if settingFlag {
                
            }else {
                let objwallet: WalletViewController =  objAppDelegate.stWallet.instantiateViewController(withIdentifier: "Wallet") as! WalletViewController
                objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
            }
        }
        
        @IBAction func btnCardAndBillingClicked(_ sender: Any) {
            let objwallet: SelectPaymentVC =  objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SelectPaymentVC") as! SelectPaymentVC
            objwallet.delegate = self
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
        }
        
        @IBAction func btnShipToClicked(_ sender: Any) {
            
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "PaymentDetailsVC")) as! PaymentDetailsVC
            self.navigationController?.pushViewController(VC1, animated: true)
            
        }
        
        func  selectCardOrPaymentMethod(emailId: String) {
            
            cardBillLbl.text = emailId
            cardType = emailId
        }
        
        func  selectCardOrPaymentMethodType(methodType: String, cardNumber: String) {
            paymentType = methodType
            
            if paymentType == "CardType" {
                cardBillLbl.text = cardNumber
            }
        }
        
        
        @IBAction func newPayBtnClicked(_ sender: Any) {
            
            if paymentType == "PayPal" {
                
            } else if paymentType == "bitcoin" {
                if addressLbl.text == "" || addressLbl.text == nil{
                    mainInstance.ShowAlertWithError("ScreamXO", msg: "Please select your Shipping Address")
                } else {
                    if isBoostFlag {
                        
                    } else {
                    callApiForPaymentByStripeBitcoin()
                    }
                }
            } else if paymentType == "alipay" {
                if addressLbl.text == "" || addressLbl.text == nil{
                    mainInstance.ShowAlertWithError("ScreamXO", msg: "Please select your Shipping Address")
                } else {
                    if isBoostFlag {
                        
                    } else {
                    callApiForPaymentByStripeAlipay()
                    }
                }
                
            }else if paymentType == "CardType" {
                paymentByCard(cardId: cardBillLbl.text!)
            }else if isShopFlag {
                if addressLbl.text == "" || addressLbl.text == nil{
                    mainInstance.ShowAlertWithError("ScreamXO", msg: "Please select your Shipping Address")
                } else {
                    paymentByWallet()
                }
            } else if isBoostFlag {
                if addressLbl.text == "" || addressLbl.text == nil{
                    mainInstance.ShowAlertWithError("ScreamXO", msg: "Please select your Shipping Address")
                } else {
                    payForBoostByWallet()
                }
                
            }

        }
        
        func  callApiForPaymentByStripeAlipay() {
            let mgr = APIManager.apiManager
            let usrMgr = UserManager.userManager
            var params: [String: AnyObject] = ["email_id": cardType as AnyObject,
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
            var params: [String: AnyObject] = ["email_id": cardType as AnyObject,
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
                isAliPay = true
            }
        }
        
        @IBAction func btnSellItemClicked(_ sender: AnyObject) {
            
            if delegate != nil {
                self.usr.ispaypalconfi = "1"
            }
            if self.usr.ispaypalconfi == "1"
            {
                let message:String!="Confirm you accept these forms of payment."
                
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
        
    
        func handleError(error: NSError) {
            print(error)
            UIAlertView(title: "Please Try Again",
                        message: error.localizedDescription,
                        delegate: nil,
                        cancelButtonTitle: "OK").show()
        }
        
        
        func paymentByCard(cardId: String) {
            print(cardId)
            let mgr = APIManager.apiManager
            let usrMgr = UserManager.userManager
            var params: [String: AnyObject] = ["card_id": cardType as AnyObject,
                                               "customer_id": UserManager.userManager.stripeCustomerId as AnyObject,
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
        

        
        
        
        
        @IBAction func btnsaveSettingClicked(_ sender: AnyObject) {
            
        }
        
        
        
        //MARK: TextFieldDelegate
        
        @IBAction func btnItmSelectionClicked(_ sender: UIButton) {
            self.view.endEditing(true)
            let itm_remain: Int = Int(self.mgrItm.itm_qty_remain!)!
            var itmArray: [Int] = []
            
            var number = 1
            while number <= itm_remain {
                itmArray.append(number)
                number += 1
            }
            let itmStringArray = itmArray.map {
                (number: Int) -> String in
                return String(number)
            }
            
            ActionSheetStringPicker.show(withTitle: "Select Quantity", rows: itmStringArray, initialSelection: selectedItmValue != nil ? selectedItmValue! : 0, doneBlock: {
                picker, value, index  in
                
                self.selectedItmValue = value
                self.lblItmQty.text = "\(itmStringArray[value])"
                self.mgrItm.product_qty = self.lblItmQty.text
                var a:Float? = Float(self.lblitemCost.text!) // firstText is UITextField
                var b:Float? = Float(self.lblshippingCost.text!) // secondText is UITextField
                var c: Float?
                if self.lblItmQty.text != "Select Qty" {
                    c = Float(self.lblItmQty.text!)
                } else {
                    
                    c = 0
                }
                
                if (b == nil)
                {
                    
                    b = 0
                }
                if (a == nil)
                {
                    
                    a = 0
                }
                if c != 0 {
                    self.lbltotalCostStr = String(format:"%.2f",((a!*c!)+b!))
                    self.lbltotalCost.text = String(format:"%.2f",((a!*c!)+b!))
                    self.lbltotalCost.text = "$ " + self.lbltotalCostStr

                } else {
                    self.lbltotalCostStr = String(format:"%.2f",(a!+b!))
                    self.lbltotalCost.text = String(format:"%.2f",(a!+b!))
                    self.lbltotalCost.text = "$ " + self.lbltotalCostStr
                }
                
                return
            }, cancel: {
                ActionStringCancelBlock in
                return
            }, origin: sender)
            
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
        
        
        
        
        
}

