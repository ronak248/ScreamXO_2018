//
//  WalletViewController.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-01.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource , WYPopoverControllerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var walletMoney: UILabel!
    @IBOutlet weak var topupBtn: UIButton!
    @IBOutlet weak var monthCollectionView: UICollectionView!
    @IBOutlet weak var trasnTblView: UITableView!

    
    var month: String!
    var delegate : Homescreenfilter!
    var popoverController: WYPopoverController!
    var indexpath = -1
    let reuseIdentifier = "cell"
    var strFilterType:String = ""
    var walletHistoryArr : NSMutableArray!
    var items = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    var totalList:Int = 0
    var indexPatH = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topupBtn.layer.masksToBounds = true
        topupBtn.layer.cornerRadius = 30.0
        monthCollectionView.delegate = self
        monthCollectionView.dataSource = self
        monthCollectionView.reloadData()
        let date = Date()
        let calendar = Calendar.current
        indexpath = calendar.component(.month, from: date) - 1
        month = String(calendar.component(.month, from: date)) as! String
        let nib = UINib(nibName: "TransactionHistoryCell", bundle: nil)
        trasnTblView.register(nib, forCellReuseIdentifier: "TransactionHistoryCell")
        
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
            walletMoney.text = "$" + FinalAmount
        } else {
            walletMoney.text = "$" + "0"
        }
        
        setMonthInCenter(index: indexpath)
        callWalletHistory()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        objAppDelegate.repositiongsm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: GSM
    func btnGSMClicked(_ btnIndex: Int) {
        switch btnIndex {
            
        case 0:
            let objwallet: CreatePost_Media =  objAppDelegate.stMsg.instantiateViewController(withIdentifier: "CreatePost_Media") as! CreatePost_Media
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
            
        case 7:
            let objwallet: MessagingVC =  objAppDelegate.stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
        default:
            break
        }
    }

    
    
   func  callWalletHistory() {
    let usr = UserManager.userManager
    let mgr = APIManager.apiManager
    let parameterss = NSMutableDictionary()
    parameterss.setValue(usr.userId, forKey: "user_id")
    parameterss.setValue(month, forKey: "month")
    SVProgressHUD.show()
    mgr.walletHistory(parameterss, successClosure: { (dic, result) -> Void in
        if result == APIResult.apiSuccess {
            SVProgressHUD.dismiss()
            let dataArray  = dic!.value(forKey: "result")! as! NSArray
            self.walletHistoryArr =  dataArray.mutableCopy() as! NSMutableArray
            self.trasnTblView.delegate = self
            self.trasnTblView.dataSource = self
            self.trasnTblView.reloadData()

            let delimiter = "."
            let newstr = dic!.value(forKey: "page_flag")! as! String
            var decimal = newstr.components(separatedBy: delimiter)
            let decimalAmount: String!
            if decimal.count > 1 {
                decimalAmount = decimal[1]
            } else {
                decimalAmount = "00"
            }
            var amount:Float! = Float()
            amount = Float(decimal[0])
            let largeNumber = amount
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
            let FinalAmount = String(describing: formattedNumber!) + ".\(decimalAmount!)"
            
            self.walletMoney.text = "$" + FinalAmount

            UserManager.userManager.userDefaults.set(dic!.value(forKey: "page_flag")! as! String, forKey: "walletMoney")
            UserManager.userManager.userDefaults.synchronize()
        } else if result == APIResult.apiError {
//            self.walletHistoryArr.removeAllObjects()
//            self.trasnTblView.delegate = self
//            self.trasnTblView.dataSource = self
//            self.trasnTblView.reloadData()
            mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
            SVProgressHUD.dismiss()
        } else {
            SVProgressHUD.dismiss()
            mainInstance.showSomethingWentWrong()
        }
    })
    }
    
    
   
    
    @IBAction func moreButtonClicked(_ sender: UIButton) {
        
        if (popoverController != nil) {
            popoverController.dismissPopover(animated: true)
        }
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "FilterHome")) as! FilterHome
        VC1.mediaType = strFilterType
        VC1.delegate = self
        VC1.isTable = "wallet"
        popoverController = WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self
        popoverController.popoverContentSize = CGSize(width: 150, height: 100)
        popoverController.presentPopover(from: sender.bounds, in: sender, permittedArrowDirections: WYPopoverArrowDirection.up, animated: true)

    }
    
    @IBAction func topUpAction(_ sender: Any) {
        let stripePaymentViewController = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "addAmount") as! StripePaymentViewController
        stripePaymentViewController.isInType = true
        self.navigationController?.pushViewController(stripePaymentViewController, animated: true)
    }


    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return 12
    }
    
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as? monthCell
         cell?.monthLbl.text = self.items[indexPath.item]
        if (indexpath == indexPath.row) {
            cell?.colorLabel.backgroundColor = UIColor(red: 38/256, green: 174/256, blue: 234/256, alpha: 1)
            cell?.monthLbl.textColor = UIColor(red: 38/256, green: 174/256, blue: 234/256, alpha: 1)
        } else {
            cell?.monthLbl.textColor = UIColor(red: 187/256, green: 193/256, blue: 203/256, alpha: 1)
            cell?.colorLabel.backgroundColor = UIColor.white
        }

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        indexpath = indexPath.row
        month = String(indexPath.row + 1)
        setMonthInCenter(index: indexpath)
        callWalletHistory()
        monthCollectionView.reloadData()
    }
    
    
  
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walletHistoryArr.count
    }
    
   
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryCell", for: indexPath) as? TransactionHistoryCell
        print(walletHistoryArr)
        
        let delimiter = "."
        let newstr = (walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "amount")! as! String
        var decimal = newstr.components(separatedBy: delimiter)
        
        let decimalAmount: String!
        if decimal.count > 1 {
            decimalAmount = decimal[1]
        } else {
            decimalAmount = "00"
        }
        var amountData:Float! = Float()
        amountData = Float(decimal[0])
        let largeNumber = amountData
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        let formattedNumber = numberFormatter.string(from: NSNumber(value:largeNumber!))
        let FinalAmount = String(describing: formattedNumber!) + ".\(decimalAmount!)"
        
        let amount = FinalAmount //(walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "amount")! as! String
        cell?.transactionAmountLbl.text = "$\(String(describing: amount))"
        
        
        if (walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "type")! as! String == "5"{
            let post = ((walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "walletMessage")) as? String
            let characterSet = CharacterSet(charactersIn: "/@:-")
            let arrayOfComponents: [Any] = post!.components(separatedBy: characterSet)
            let finalStr : String = (arrayOfComponents as NSArray).componentsJoined(by: "")
            cell?.transactionDetailLbl.text = finalStr
        } else {
              cell?.transactionDetailLbl.text = (walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "walletMessage")! as? String
        }
        
        if (walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "payment_mode")! as? String == "in" {
            cell?.transactionAmountLbl.textColor = UIColor(red: 38/256, green: 174/256, blue: 234/256, alpha: 1)
            let image : UIImage = UIImage(named: "blueCir")!
            cell?.transactionTypeImg.image = image
        } else {
            cell?.transactionAmountLbl.textColor = UIColor(red: 254 / 255.0, green: 104 / 255.0, blue: 106 / 255.0, alpha: 1.0)
            let image : UIImage = UIImage(named: "redCir")!
            cell?.transactionTypeImg.image = image
        }
        let localeStr = (walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "added_on_1")! as? String
        
        cell?.dateLbl.text = localetimeZone(timeStr: localeStr!)    //(walletHistoryArr[indexPath.row] as AnyObject).value(forKey: "added_on")! as? String
        return cell!
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if( indexPatH == self.walletHistoryArr.count-1 && self.walletHistoryArr.count>9 && self.totalList > self.walletHistoryArr.count) {
//            if walletHistoryArr.count < totalList {
//                //offset = offset + 1
//                
//            }
//        }
        guard let visibleIndexPaths = trasnTblView.indexPathsForVisibleRows else { return }
        let zeroIndex = IndexPath(row: 0, section: 0)
        
        if visibleIndexPaths.contains(zeroIndex) {
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.transitionFlipFromTop, animations: {
                constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-icon_menu")
                constant.btnObj1.tag = 0
                constant.btnObj1.removeTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: {
                if constant.btnObj1.buttonsIsShown() {
                    constant.btnObj1.onTap()
                    if let firstTimeMenuLoaded = Defaults.firstTimeMenuLoaded.value as? String {
                        if firstTimeMenuLoaded != "1" {
                            constant.btnObj2.onTap()
                        }
                    }
                }
                
                constant.btnObj1.frame.origin.x = (self.view.window?.frame.maxX)! - constant.btnObj1.frame.width
                constant.btnObj1.frame.origin.y = (self.view.window?.frame.maxY)! - constant.btnObj1.frame.height
                constant.btnObj2.frame.origin = constant.btnObj1.frame.origin
                objAppDelegate.circleMenuOrigin = constant.btnObj1.frame.origin
                constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-uparrow")
                constant.btnObj1.tag = 1
                constant.btnObj1.addTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
            }, completion: nil)
        }
    }
    
    
    // MARK: - custom button methods
    
    func btnGoToTopClicked(_ sender: Any) {
        if UserManager.userManager.userId == "1" {

        }else {
            guard trasnTblView.numberOfRows(inSection: 0) > 0 else { return }
            trasnTblView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    
    
    func localetimeZone(timeStr: String) -> String {
        let dateToPassStr: String = "\(timeStr)"
        let gmtDateString: String = dateToPassStr
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone!
        let date: Date? = df.date(from: gmtDateString)
        df.timeZone = NSTimeZone(forSecondsFromGMT: NSTimeZone.local.secondsFromGMT() ) as TimeZone!
        var localDateString: String = df.string(from: date!)
        print("Local date is = \(localDateString)")
        
        var dateStr = String()
        if let idx = localDateString.characters.index(of: " ") {
           dateStr = localDateString.substring(to: idx)
            print(dateStr)
        }
        if let idx = dateStr.characters.index(of: "-") {
            let monthDate = dateStr.substring(from: dateStr.index(after: idx))
            if let idx = monthDate.characters.index(of: "-")  {
                let month = monthDate.substring(to: idx)
                print(month)
                var Month = items[Int(month)! - 1]
                let date = monthDate.substring(from: dateStr.index(after: idx))
                print(date)
                localDateString = Month + " \(date)"
            }
            
        }
        
        return localDateString
    }
    
    public  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let recieptVC = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "TransactionReceiptVC")) as! TransactionReceiptVC
        recieptVC.userId =  UserManager.userManager.userId! as! String
        recieptVC.walletId = (walletHistoryArr![indexPath.row] as AnyObject).value(forKey: "id") as! String
        self.navigationController?.pushViewController(recieptVC , animated: true)
       
    }
    
    

    func setMonthInCenter(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        monthCollectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
        
    }
    
}

extension WalletViewController: Homescreenfilter {
    func actionFIlterData(_ filterType: String) {
      if filterType == "wallet" {
        let transferVC = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "TransferMoneyVC")) as! TransferMoneyVC
        self.navigationController?.pushViewController(transferVC, animated: true)
        popoverController.dismissPopover(animated: true)
      } else if filterType == "walletsupport" {
        let transferVC = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SupportVC")) as! SupportVC
        self.navigationController?.pushViewController(transferVC, animated: true)
         popoverController.dismissPopover(animated: true)        
        }
    }
}
