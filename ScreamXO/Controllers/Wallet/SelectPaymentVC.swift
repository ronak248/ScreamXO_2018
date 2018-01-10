//
//  SelectPaymentVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-10-23.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit
import Stripe

public class cardCell: UITableViewCell {
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var cardInfoLbl: UILabel!
    @IBOutlet weak var cardUserAdd: UILabel!
}

public class StripePaymentCell: UITableViewCell {
    @IBOutlet weak var paymentGetwayImg: UIImageView!
    @IBOutlet weak var methodTypelbl: UILabel!
    @IBOutlet weak var userEmail: UILabel!
}

protocol selectCardOrPaymentMethodDelegate: class {
    func selectCardOrPaymentMethod(emailId: String)
    func selectCardOrPaymentMethodType(methodType: String , cardNumber: String)
}

class SelectPaymentVC: UIViewController, STPAddCardViewControllerDelegate ,STPPaymentMethodsViewControllerDelegate, UITableViewDelegate, UITableViewDataSource ,STPPaymentCardTextFieldDelegate  {

    @IBOutlet weak var paymentTblView: UITableView!
    var delegate: selectCardOrPaymentMethodDelegate!
    var listCardArr: NSMutableArray! = NSMutableArray()
    let paymentCardTextField = STPPaymentCardTextField()
    var isAddMoneyInWalletFlag = false
    var delayFlag = false
    override func viewDidLoad() {
        super.viewDidLoad()
        paymentCardTextField.delegate = self
        view.addSubview(paymentCardTextField)
        
    }
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        //buyButton.enabled = textField.isValid
    }

    override func viewWillAppear(_ animated: Bool) {
         getAccountDetails()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackClicked() {
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is NewConfigurePaymentVC  {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            } else if vc is ConfigureBuyPaymentVC  {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return listCardArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    let checkCard = (listCardArr[indexPath.row] as AnyObject).value(forKey:"isCard") as! String
        if checkCard == "yes" {
            let cellIdentifier = "cardCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! cardCell
            var str1: String! = String()
            str1 = (listCardArr[indexPath.row] as AnyObject).value(forKey:"last4") as! String
            var str2: String! = String()
            str2 = String(describing: ((listCardArr[indexPath.row]  as AnyObject).value(forKey:"exp_month") as! Int))
            var str3: String! = String()
            str3 = String(describing:((listCardArr[indexPath.row] as AnyObject).value(forKey:"exp_year") as! Int))
            
            let endIndex = str3.index(str3.startIndex, offsetBy: 2)
            let truncated = str3.substring(to: endIndex)
            
            
            let finalStr = "****" + String(str1) + " " + String(str2!) + "/" + String(truncated)
             cell.cardInfoLbl.text = finalStr
            
            var str4: String! = String()
            str4 = (listCardArr[indexPath.row] as AnyObject).value(forKey:"brand") as! String
            var str5: String! = String()
            str5 = (listCardArr[indexPath.row] as AnyObject).value(forKey:"country") as! String
            let finalStr1 = "       " + String(str5) + "  " + String(str4)
            cell.cardUserAdd.text = finalStr1
            let image : UIImage = UIImage(named: "stp_card_visa")!
            print(image)
            cell.cardImg.image = image
             return cell
        } else {
        let cellIdentifier = "StripePaymentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! StripePaymentCell
        cell.methodTypelbl.text = (listCardArr[indexPath.row] as AnyObject).value(forKey:"type") as? String
        cell.userEmail.text = (listCardArr[indexPath.row] as AnyObject).value(forKey:"email") as? String
        if (listCardArr[indexPath.row] as AnyObject).value(forKey:"type") as? String == "bitcoin" {
            cell.paymentGetwayImg.image = UIImage(named: "bitcoin")
        } else if (listCardArr[indexPath.row] as AnyObject).value(forKey:"type") as? String == "alipay" {
            cell.paymentGetwayImg.image = UIImage(named: "alipay")
        } else if (listCardArr[indexPath.row] as AnyObject).value(forKey:"type") as? String == "wechat" {
            cell.paymentGetwayImg.image = UIImage(named: "wechat")
        } else {
            cell.paymentGetwayImg.image = UIImage(named: "paypal")
        }
        return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let checkFlag = (listCardArr[indexPath.row] as AnyObject).value(forKey:"isCard") as! String
     
        if checkFlag == "yes" {
            
            
            if  isAddMoneyInWalletFlag {
                delegate.selectCardOrPaymentMethod(emailId: ((listCardArr[indexPath.row] as AnyObject).value(forKey:"id") as? String)! )
                self.navigationController?.popViewController(animated: true)
            } else {
                
                
            var str1: String! = String()
            str1 = (listCardArr[indexPath.row] as AnyObject).value(forKey:"last4") as! String
            var str2: String! = String()
            str2 = String(describing: ((listCardArr[indexPath.row]  as AnyObject).value(forKey:"exp_month") as! Int))
            var str3: String! = String()
            str3 = String(describing:((listCardArr[indexPath.row] as AnyObject).value(forKey:"exp_year") as! Int))
            
            let endIndex = str3.index(str3.startIndex, offsetBy: 2)
            let truncated = str3.substring(to: endIndex)
            
            
            let showCardInfo = "****" + String(str1) + " " + String(str2!) + "/" + String(truncated)
            
             delegate.selectCardOrPaymentMethod(emailId: ((listCardArr[indexPath.row] as AnyObject).value(forKey:"id") as? String)! )
            delegate.selectCardOrPaymentMethodType(methodType: "CardType", cardNumber: showCardInfo)
            }
        } else {
            
            if  isAddMoneyInWalletFlag {
                 mainInstance.ShowAlertWithError("ScreamXO", msg: "you can't add money by these payments")
                
            } else {
            delegate.selectCardOrPaymentMethod(emailId: ((listCardArr[indexPath.row] as AnyObject).value(forKey:"email") as? String)! )
            delegate.selectCardOrPaymentMethodType(methodType: ((listCardArr[indexPath.row] as AnyObject).value(forKey:"type") as? String)!, cardNumber: "")
        
       
            }
        }
        
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is NewConfigurePaymentVC   {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            } else if vc is ConfigureBuyPaymentVC  {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
    }
    
    @IBAction func btnAddNewCardClicked(_ sender: Any) {
//        let VC1:AddCardVC! = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "AddCardVC")) as! AddCardVC
//        self.navigationController?.pushViewController(VC1, animated: true)
        
        buttonStripeClicked()
    }

    @IBAction func btnAddNewProcessorClicked(_ sender: Any) {
        let VC1:SelectProcessorVC! = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SelectProcessorVC")) as! SelectProcessorVC
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    func getAccountDetails() {
        let mgr = APIManager.apiManager
        let usrid = UserManager.userManager.userId
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usrid, forKey: "uid")
         parameterss.setValue(UserManager.userManager.stripeCustomerId  , forKey: "customer_id")
        
        print(parameterss)
        SVProgressHUD.show()
        mgr.getCardList(parameterss, successClosure: { (dic, result) -> Void in
            print(dic!)
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess {
                let DicData = (dic?.value(forKey: "result") as? NSDictionary)
                self.listCardArr  = (DicData?.value(forKey: "card_list") as! NSArray).mutableCopy() as? NSMutableArray
                if self.listCardArr != nil {
                    self.delayFlag = true
                    self.paymentTblView.isHidden = false
                    self.paymentTblView.delegate = self
                    self.paymentTblView.dataSource = self
                    self.paymentTblView.reloadData()
                }
                
//                let strlbl:String? = dic?.value(forKeyPath: "result.paypal") as? String
//                let strlblbit:String? = dic?.value(forKeyPath: "result.bitcoin") as? String
//                
//                if (strlbl?.characters.count)! <= 0
//                {
//                    self.lblpaypal.text = "PayPal" //Not Configured
//                }
//                else
//                {
//                    self.lblpaypal.text = strlbl
//                    self.usr.ispaypalconfi = "1"
//                }
//                if (strlblbit?.characters.count)! <= 0
//                {
//                    // self.lblAlipay.text = "Not Configured"
//                }
//                else
//                {
//                    self.usr.ispaypalconfi = "1"
//                }
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
            
    
    }
    
    
    
    func submitTokenToBackendForBoostItem(token: STPToken, completion: (_ error:Error)->()){
        print(token)
        addNewCard()
        //self.postStripeTokenForBoostItem(token: token)
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
            print(dic)
            if dic != nil {
                self.dismiss(animated: true, completion: nil)
            }
            
            if result == APIResult.apiSuccess
            {
                
            }
            else if result == APIResult.apiError
            {
                
            }
            else
            {
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



