//
//  PaymentDetailsVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 23/03/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
class PaymentDetailsVC: UIViewController {
    
    
    // MARK: Properties
    
    let mgrItm = ItemManager.itemManager
    var selectedItmValue: Int?
    var selecedCountryValue: Int?
    var shippingInfo = [String: String]()
    // MARK: IBOutlets
    
    @IBOutlet var txtStreet: UITextField!
    @IBOutlet var txtcity: UITextField!
    @IBOutlet var txtZip: UITextField!
    @IBOutlet var txtstate: UITextField!
    @IBOutlet var txtcountry: UITextField!
    
    @IBOutlet var lblitemCost: UILabel!
    @IBOutlet var lblshippingCost: UILabel!
    @IBOutlet var lbltotalCost: UILabel!

    @IBOutlet var lblItmQty: UILabel!
    @IBOutlet var btnUpdateShippingAddress: UIButton!
    @IBOutlet var btnContrySelection: UIButton!
    
    // MARK: UIViewController Life Cyle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }
        btnUpdateShippingAddress.layer.cornerRadius = 3.0
        btnUpdateShippingAddress.layer.masksToBounds = true
        getShippingAddress()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.lblItmQty.text = "1"
        lblitemCost.text = mgrItm.ItemPrice
        lblshippingCost.text = mgrItm.ItemShipingCost
        var a:Float? = Float(lblitemCost.text!) // firstText is UITextField
        var b:Float? = Float(lblshippingCost.text!) // secondText is UITextField
        var c: Float?
        if self.lblItmQty.text != "Select Qty" {
            c = Float(lblItmQty.text!)
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
            
            lbltotalCost.text = String(format:"%.2f",((a!*c!)+b!))
        } else {
            
            lbltotalCost.text = String(format:"%.2f",(a!+b!))
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func getLocalCountry() {
        let parameterss = NSMutableDictionary()
        parameterss.setValue(objAppDelegate.strLat, forKey: "lat")
        parameterss.setValue(objAppDelegate.strLon, forKey: "long")
            let mgr = APIManager.apiManager
            mgr.getCountry(parameterss, successClosure: { (dic, result) -> Void in
                SVProgressHUD.dismiss()
                print(dic)
                if dic != nil {
                    self.txtcountry.text = (dic?.value(forKey: "result") as AnyObject ).value(forKey:"country") as? String
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
    
    
   
    // MARK: - custom Button methods
    
    @IBAction func btnUpdateShippingAddressClicked(_ sender: UIButton)
    {
        if btnUpdateShippingAddress.tag == 0
        {
            if checkEmptyTextFields() {
                updateShippingAddress(true)
            }
        }
        else if btnUpdateShippingAddress.tag == 1
        {
            self.txtcity.isUserInteractionEnabled = true
            self.txtcountry.isUserInteractionEnabled = true
            self.txtstate.isUserInteractionEnabled = true
            self.txtStreet.isUserInteractionEnabled = true
            self.txtZip.isUserInteractionEnabled = true
            self.btnContrySelection.isUserInteractionEnabled = true
            btnUpdateShippingAddress.setTitle("ADD SHIPPING ADDRESS", for: UIControlState())
            btnUpdateShippingAddress.tag = 0
        }
    }
    

    @IBAction func btnContinueClicked(_ sender: AnyObject) {
        if checkEmptyTextFields() {
            self.view.endEditing(true)
            if lblItmQty.text == "Select Qty" {
                mainInstance.ShowAlertWithError("Error!", msg: "Please select item quantity")
            } else {
                updateShippingAddress(true)
                mgrItm.product_qty = lblItmQty.text!
                mgrItm.ItemShipingaddress = "\(txtStreet.text!), \(txtcity.text!) - \(txtZip.text!), \(txtstate.text!), \(txtcountry.text!)"
//                let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "PaymentVC")) as! PaymentVC
//                self.navigationController?.pushViewController(VC1, animated: true)
                
                self.navigationController?.popViewController(animated: true)
                
//                let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "ConfigureBuyPaymentVC")) as! ConfigureBuyPaymentVC
//                VC1.isShopFlag = true
//                self.navigationController?.pushViewController(VC1, animated: true)
                
            }
        }
    }
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnCountrySelectionClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)

        var temp = NSArray()
        temp = self.counrtyNames()
        if txtcountry.text != ""
        {
            selecedCountryValue = temp.index(of: txtcountry.text!)
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Country", rows: temp as [AnyObject], initialSelection: selecedCountryValue != nil ? selecedCountryValue! : 0, doneBlock: {
            picker, value, index in
            
            self.selecedCountryValue = value
            self.txtcountry.text = "\(temp.object(at: value))"
            
            return
            }, cancel: { ActionStringCancelBlock in return }, origin: sender)
    }
    
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
                
                self.lbltotalCost.text = String(format:"%.2f",((a!*c!)+b!))
            } else {
                
                self.lbltotalCost.text = String(format:"%.2f",(a!+b!))
            }
            
            return
            }, cancel: {
                ActionStringCancelBlock in
                return
            }, origin: sender)

    }
    
    // MARK: Methods
    
    func checkEmptyTextFields() -> Bool {
        self.view.endEditing(true)
        if mainInstance.isTextfieldBlank(txtStreet)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter street")
        }
        else if mainInstance.isTextfieldBlank(txtcity)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter city")
        } else if mainInstance.isTextfieldBlank(txtZip) {
            
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter zipcode")
        }
        else if mainInstance.isTextfieldBlank(txtstate)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter state")
        }
        else if mainInstance.isTextfieldBlank(txtcountry)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter country")
        } else {
            return true
        }
        return false
    }
    
    func didTxtFieldChanged() -> Bool
    {
        if self.txtcity.text == self.shippingInfo["City"]
        {
            if self.txtcountry.text == self.shippingInfo["Country"]
            {
                if self.txtstate.text == self.shippingInfo["State"]
                {
                    if self.txtStreet.text == self.shippingInfo["Street"]
                    {
                        if self.txtZip.text == self.shippingInfo["Zipcode"]
                        {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    // MARK: Webservice Implementation
    
    func updateShippingAddress(_ reloadFlag: Bool)
    {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(txtStreet.text, forKey: "Street")
        parameterss.setValue(txtcity.text, forKey: "City")
        parameterss.setValue(txtZip.text, forKey: "Zipcode")
        parameterss.setValue(txtstate.text, forKey: "State")
        parameterss.setValue(txtcountry.text, forKey: "Country")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        print(parameterss)
        if reloadFlag
        {
            SVProgressHUD.show(withStatus: "Fetching Details", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.updateShippingAddress(parameterss, successClosure: { (dic, result) -> Void in
            
            SVProgressHUD.dismiss()
            print(dic)
            
            if result == APIResult.apiSuccess
            {
                if reloadFlag
                {
//                    mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                }
            }
            else if result == APIResult.apiError
            {
                if reloadFlag
                {
//                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                }
            }
            else
            {
                if reloadFlag
                {
//                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                }
            }
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
            self.getLocalCountry()
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
                    
                    self.txtcity.text = self.shippingInfo["City"]
                    self.txtcountry.text = self.shippingInfo["Country"]
                    self.txtstate.text = self.shippingInfo["State"]
                    self.txtStreet.text = self.shippingInfo["Street"]
                    self.txtZip.text = self.shippingInfo["Zipcode"]

                    
                    self.btnUpdateShippingAddress.setTitle("UPDATE SHIPPING ADDRESS", for: UIControlState())
                    self.btnUpdateShippingAddress.tag = 1
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
    
    // MARK: - countrynames

    func counrtyNames() -> NSArray{
        
        let countryCodes = Locale.isoRegionCodes
        let countries:NSMutableArray = NSMutableArray()
        
        for countryCode  in countryCodes{
            
            let locale = Locale.current
            //get country name
            let country = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value : countryCode)//replace "NSLocaleIdentifier"  with "NSLocaleCountryCode" to get language name
            
            if country != nil {//check the country name is  not nil
                
                countries.add(country!)
                
            }
        }
        return countries
    }
}
