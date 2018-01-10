//
//  AddCardVC.swift
//  ScreamXO
//
//  Created by Parangat on 09/11/17.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit
import Stripe

class AddCardVC: UIViewController ,STPPaymentCardTextFieldDelegate {

    let paymentCardTextField = STPPaymentCardTextField()
    @IBOutlet weak var btnDone: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDone.isEnabled = false
        paymentCardTextField.delegate = self
        self.view.addSubview(paymentCardTextField)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        btnDone.isEnabled = textField.isValid
        print(textField)
    }

    @IBAction func btnBackClicked() {
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is SelectPaymentVC  {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            } else if vc is SelectPaymentVC  {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    @IBAction func btnDoneClicked() {
    
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
