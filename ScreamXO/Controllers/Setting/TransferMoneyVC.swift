//
//  TransferMoneyVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-04.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class TransferMoneyVC: UIViewController, SelectUserForTransferMoneyDelegate, UITextFieldDelegate {
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var toCustomerName: UITextField!
    @IBOutlet weak var transferAmountTxtFiled: UITextField!
    var toUserId: String!
    var toFriendName: String!
    var profileSendMoneyFlag = false
    let tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendBtn.layer.cornerRadius = 5
        sendBtn.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TransferMoneyVC.removeKeyword(_:)))
        self.view.addGestureRecognizer(tapGesture)
        transferAmountTxtFiled.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if profileSendMoneyFlag {
            toCustomerName.text = toFriendName
            print(toUserId)
        }
    }
    @IBAction func selectUserName(_ sender: Any) {
        let friendsVC = (objAppDelegate.strFriends.instantiateViewController(withIdentifier: "FriendsVC")) as! FriendsVC
        friendsVC.isForTransferMoney = true
        friendsVC.delegate = self
        self.navigationController?.pushViewController(friendsVC, animated: true)
    }
    
    
    func SelectUserForTransferMoneyDelegate(userId: String , userName: String) {
        toUserId = userId
        toCustomerName.text = userName
    }
    
    func removeKeyword(_ sender: AnyObject) {
        transferAmountTxtFiled.resignFirstResponder()
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: String = (transferAmountTxtFiled.text! as NSString).replacingCharacters(in: range, with: string)
        let length: Int = (currentString.characters.count )
        if length > 4 {
            return false
        }
        return true
    }
    
    @IBAction func transferMoneyClicked(_ sender: Any) {
        transferAmountTxtFiled.resignFirstResponder()
        if transferAmountTxtFiled.text == nil || transferAmountTxtFiled.text == "" || transferAmountTxtFiled.text == "0" {
            transferAmountTxtFiled.resignFirstResponder()
            mainInstance.ShowAlertWithError("ScreamXO", msg: "Please enter amount for transfer")
        } else if toCustomerName.text == nil || toCustomerName.text == "" {
            transferAmountTxtFiled.resignFirstResponder()
            mainInstance.ShowAlertWithError("ScreamXO", msg: "Please select your friend")
        }else  {
        if  UserManager.userManager.walletMoney  != nil  {
            let walletMoneyStr: String? = UserManager.userManager.walletMoney
            let fullNameArr = walletMoneyStr?.characters.split{$0 == "."}.map(String.init)
            let myWalletmoney = Int((fullNameArr?[0])!)
            let transferMoney = Int(transferAmountTxtFiled.text!)
            
            if myWalletmoney! >= transferMoney! {
                let mgr = APIManager.apiManager
                let usrMgr = UserManager.userManager
                let params: [String: AnyObject] =
                    ["amount": transferAmountTxtFiled.text as AnyObject,
                     "user_id": usrMgr.userId as AnyObject,
                     "to_user_id":  toUserId as AnyObject
                ]
                SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
                mgr.transferMoneyProcess(params as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess {
                        print(dic!)
                        print(result)
                        let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"amount") as! Int)
                        UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                        UserManager.userManager.userDefaults.synchronize()
                        
                        if self.profileSendMoneyFlag {
                            let stripePaymentViewController = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "Wallet") as! WalletViewController
                            self.navigationController?.pushViewController(stripePaymentViewController, animated: true)
                        } else {
                        self.navigationController?.popViewController(animated: true)
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
            } else {
                let alertController = UIAlertController(
                    title: "ScreamXO",
                    message: "Please add wallet money",
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                    style: UIAlertActionStyle.destructive) { (action) in
                        
                }
                
                let confirmAction = UIAlertAction(
                title: "Add", style: UIAlertActionStyle.default) { (action) in
                    let stripePaymentViewController = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "addAmount") as! StripePaymentViewController
                    self.navigationController?.pushViewController(stripePaymentViewController, animated: true)
                }
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                present(alertController, animated: true, completion: nil)
                
            }
        } else {
            let alertController = UIAlertController(
                title: "ScreamXO",
                message: "Your wallet money is Zero Please add wallet money",
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.destructive) { (action) in
            }
            
            let confirmAction = UIAlertAction(
            title: "Add", style: UIAlertActionStyle.default) { (action) in
                
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
