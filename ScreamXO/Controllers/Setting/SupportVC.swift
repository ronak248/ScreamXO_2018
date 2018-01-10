//
//  SupportVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-10.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class SupportVC: UIViewController, WYPopoverControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var dropDownBtn: UIButton!
    @IBOutlet weak var queryTextView: UITextView!
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var sendQuery: UIButton!
    var delegate : Homescreenfilter!
    var popoverController: WYPopoverController!
    var strFilterType:String = ""
    var queryQuestion = String()
    var countCharacter = -1
    var moreBoostFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryTextView.delegate = self
        chooseBtn.layer.cornerRadius = 5
        chooseBtn.clipsToBounds = true
        queryTextView.layer.cornerRadius = 5
        queryTextView.clipsToBounds = true
        sendQuery.layer.cornerRadius = 5
        if moreBoostFlag {
            queryQuestion = "Custom Boost"
            chooseBtn.setTitle("Custom Boost", for: .normal)
        }
        sendQuery.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SupportVC.removeKeyword(_:)))
        self.view.addGestureRecognizer(tapGesture)
        queryTextView.text = "   Please enter your query here..."
        queryTextView.textColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if queryTextView.textColor == UIColor.white {
            queryTextView.text = nil
            queryTextView.textColor = UIColor.black
        }
    }
    
    @IBAction func dropDownBtn(_ sender: UIButton) {
        
        if moreBoostFlag {
            
        } else {
        if (popoverController != nil) {
            popoverController.dismissPopover(animated: true)
        }
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "FilterHome")) as! FilterHome
        VC1.mediaType = strFilterType
        VC1.delegate = self
        VC1.isTable = "query"
        popoverController = WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self
        popoverController.popoverContentSize = CGSize(width: 150, height: 200)
        popoverController.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)
        }
    }
    
    
    
    
    
    @IBAction func sendQueryBtnTapped(_ sender: Any) {
        if countCharacter <= 0 {
            queryTextView.resignFirstResponder()
        } else {
            let usr = UserManager.userManager
            let mgr = APIManager.apiManager
            queryTextView.resignFirstResponder()
            let parameterss = NSMutableDictionary()
            parameterss.setValue(Int(usr.userId!)!, forKey: "uid")
            parameterss.setValue(queryTextView.text, forKey: "message")
            parameterss.setValue(queryQuestion, forKey: "issue")
            
            SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
            
            mgr.sendMessageTosupportAdmin(parameterss, successClosure: {(dictMy, result) -> Void in
                SVProgressHUD.dismiss()
                
                if result == APIResult.apiSuccess {
                     mainInstance.ShowAlert("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                    self.queryTextView.text = nil
                    self.chooseBtn.setTitle("Choose Issue", for: .normal)
                    self.queryTextView.text = "   Please enter your query here..."
                    SVProgressHUD.dismiss()
                   
                } else if result == APIResult.apiError {
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
                }
            })
        }
    }
    
    func removeKeyword(_ sender: AnyObject) {
        queryTextView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text == "\n" {
            queryTextView.resignFirstResponder()
            return false
        }
      countCharacter = countCharacter +  textView.text.characters.count
        return true
    }

}
extension SupportVC: Homescreenfilter {
    func actionFIlterData(_ filterType: String ) {
        if filterType == "Payment options" {
            queryQuestion = filterType
            popoverController.dismissPopover(animated: true)
            chooseBtn.setTitle(queryQuestion,for: .normal)
        } else if  filterType == "Shipping timeframes" {
            queryQuestion = filterType
            chooseBtn.setTitle(queryQuestion,for: .normal)
             popoverController.dismissPopover(animated: true)
        } else if filterType == "Returns policy" {
            queryQuestion = filterType
            chooseBtn.setTitle(queryQuestion,for: .normal)
            popoverController.dismissPopover(animated: true)
        } else if filterType == "How do I place my order?" {
            queryQuestion = filterType
            chooseBtn.setTitle(queryQuestion,for: .normal)
            popoverController.dismissPopover(animated: true)
        } else {
            queryQuestion = filterType
            chooseBtn.setTitle(queryQuestion,for: .normal)
            popoverController.dismissPopover(animated: true)
        }
    }
}
