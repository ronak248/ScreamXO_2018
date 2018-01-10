//
//  BoostViewController.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 26/05/17.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit
class BoostViewController: UIViewController {

    // MARK: Properties
    
    var pickerDayTitles = [""] //
    var pickerAmountTitles = ["More" , "9000" ,"8000" , "7000", "6000" , "5000" , "4000" , "3000" , "2000", "1000","950", "900","850", "800","750", "700","650", "600","550", "500", "450", "400", "350", "300", "250","200","150","100", "95", "90", "85", "80","75", "70", "65", "60", "55","50", "45", "40", "35", "30","25", "20", "15", "10", "5"]
    var selDayIndex: Int?
    var selAmountIndex: Int?
    var item_id : Int!
    var boost_type : Int!
    var selectedDay: String!
    var selectedAmount: String!
    var totalRechedPeople: String!
    @IBOutlet var txtPromoCode: UITextField!
    
    // MARK: IBActions
    
    @IBOutlet var viewDays: UIView!
    @IBOutlet var viewAmount: UIView!
    @IBOutlet var pickerDays: PickerView!
    @IBOutlet var pickerAmount: PickerView!
    @IBOutlet var btnDaysPicker: UIButton!
    @IBOutlet var btnAmountPicker: UIButton!
    @IBOutlet var lblTotalAmount: UILabel!
    
    // MARK: Constraint outlets
    
    @IBOutlet var constViewReachTop: NSLayoutConstraint!
    var btnDaysFlag: Bool!
    var btnAmountFlag: Bool!
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnDaysFlag = false
        btnAmountFlag = false
        selectedDay = "5"
        selectedAmount = "20"
        totalRechedPeople = "1200"
        
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }
       var data = 31
        for i in 0 ... 29 {
            data = data - 1
            let str = String(data) 
            pickerDayTitles.insert(str, at: i)
        }
        
//        var dataMoney = 10000
//        for i in 0 ... 9998 {
//            dataMoney = dataMoney - 5
//            let str = String(dataMoney)
//            pickerAmountTitles.insert(str, at: i)
//        }
//
        print(pickerDayTitles)
        pickerDays.delegate = self
        pickerDays.dataSource = self
        pickerAmount.delegate = self
        pickerAmount.dataSource = self
    }
    
    // MARK: IBActions
    
    @IBAction func btnDaysPickerClicked(_ sender: UIButton) {
        viewDays.isHidden = false
        btnDaysPicker.layer.borderUIColor = UIColor(red: 254/255, green: 104/255, blue: 108/255, alpha: 1.0)
        btnDaysPicker.isUserInteractionEnabled = false
        btnDaysPicker.setTitle("", for: .normal)
        
        if (selDayIndex != nil) {
            pickerDays.selectRow(selDayIndex!, animated: true)
        }
        moveViewReachDown()
    }
    
    @IBAction func btnAmountPickerClicked(_ sender: UIButton) {
        viewAmount.isHidden = false
        btnAmountPicker.layer.borderUIColor = UIColor(red: 254/255, green: 104/255, blue: 108/255, alpha: 1.0)
        btnAmountPicker.isUserInteractionEnabled = false
        btnAmountPicker.setTitle("", for: .normal)
        
        if (selAmountIndex != nil) {
            pickerAmount.selectRow(selAmountIndex!, animated: true)
        }
        moveViewReachDown()
    }
    
    @IBAction func btnBoostClicked(_ sender: UIButton) {
        
            let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "NewConfigurePaymentVC")) as! NewConfigurePaymentVC
            VC1.isBoostFlag = true
            VC1.item_id = item_id
            VC1.days = selectedDay
            VC1.amount = selectedAmount
            VC1.rechedPeople = totalRechedPeople
            VC1.boost_type = boost_type
            print(item_id)
            print(totalRechedPeople)
            print(selectedAmount)
            print(selectedDay)
        
            self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    
    // MARK: Methods
    
    func moveViewReachDown() {
        UIView.animate(withDuration: 0.3, animations: {
            self.constViewReachTop.constant = 50
        })
    }
    
    func moveViewReachUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.constViewReachTop.constant = 20
        })
    }
}

// MARK: Extensions

extension BoostViewController: PickerViewDelegate, PickerViewDataSource {
    
    func pickerViewNumberOfRows(_ pickerView: PickerView) -> Int {
        if pickerView == pickerDays {
            return pickerDayTitles.count
        } else {
            return pickerAmountTitles.count
        }
    }
    
    func pickerViewHeightForRows(_ pickerView: PickerView) -> CGFloat {
        return 50.0
    }
    
    func pickerView(_ pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        if pickerView == pickerDays {
            return pickerDayTitles[index]
        } else {
            return pickerAmountTitles[index]
        }
    }
    
    func pickerView(_ pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.textAlignment = .center
        if highlighted {
            label.font = fonts.kfontproxiBold
            label.textColor = .white
        } else {
            label.font = fonts.kfontproxiBold
            label.textColor = UIColor.white
        }
    }
    
    func pickerView(_ pickerView: PickerView, didTapRow row: Int, index: Int) {
        
        if pickerView == pickerDays {
            btnDaysFlag = true
            btnDaysPicker.setTitleColor(UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0), for: .normal)
            viewDays.isHidden = true
            btnDaysPicker.isUserInteractionEnabled = true
            btnDaysPicker.layer.borderUIColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
            selDayIndex = row
            selectedDay = pickerDayTitles[selDayIndex!]
            btnDaysPicker.setTitle(pickerDayTitles[selDayIndex!] + " Days", for: .normal)
        } else {
            
            if row == 0 {
                let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SupportVC")) as! SupportVC
                VC1.moreBoostFlag = true
                self.navigationController?.pushViewController(VC1, animated: true)
            } else {
            btnAmountFlag = true
            btnAmountPicker.setTitleColor(UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0), for: .normal)
            viewAmount.isHidden = true
            btnAmountPicker.layer.borderUIColor = UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)
            btnAmountPicker.isUserInteractionEnabled = true
            selAmountIndex = row
            selectedAmount = pickerAmountTitles[selAmountIndex!]
            btnAmountPicker.setTitle("$" + pickerAmountTitles[selAmountIndex!], for: .normal)
            let str: String = "" + pickerAmountTitles[selAmountIndex!]
            lblTotalAmount.text = String(Int(str)! * 60 )
            totalRechedPeople = lblTotalAmount.text
        }
        if viewDays.isHidden && viewAmount.isHidden {
            moveViewReachUp()
        }
        
        if btnAmountFlag == true && btnDaysFlag == true {
            txtPromoCode.layer.borderWidth = 1.5
            txtPromoCode.layer.borderColor = UIColor(red: 192/255, green: 192/255, blue: 192/255, alpha: 1.0).cgColor
            txtPromoCode.attributedPlaceholder = NSAttributedString(string: "Enter Code",
                                                                   attributes: [NSForegroundColorAttributeName: UIColor(red: 63/255, green: 63/255, blue: 63/255, alpha: 1.0)])
            //txtPromoCode.placeholder = "Enter Code"
        } else {
            txtPromoCode.layer.borderWidth = 0.0
        }
        }
    }
}
