	//
//  BuyerSellerMsgVC.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 19/09/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
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
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class BuyerSellerMsgVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, DZNEmptyDataSetSource,DZNEmptyDataSetDelegate, MsgSentDelegate {

    // MARK: Properties
    
    var parentCnt: UIViewController!
    var limit:Int = 10
    var totalMsgCount: Int = 0
    var offset: Int = 1
    var arrayBuySellMsg = NSMutableArray()
    var dictMy : Dictionary<String, AnyObject>?
    var arrayUserID = [Int]()
    var didViewLoaded: Bool = false
    var hadSent = false
    var indexPatH = 0
    // MARK: IBOutlets
    
    @IBOutlet var tblBuySellMsg: UITableView!
    
    
    // MARK: UIViewControllerOverridenMethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshChatHead(_:)), name: NSNotification.Name(rawValue: "refreshChatHead"), object: nil)

        tblBuySellMsg.delegate = self
        tblBuySellMsg.dataSource = self
        tblBuySellMsg.emptyDataSetSource = self
        tblBuySellMsg.emptyDataSetDelegate = self
        tblBuySellMsg.tableFooterView = UIView()
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        lpgr.minimumPressDuration = 1.5
        lpgr.delegate = self
        self.tblBuySellMsg.addGestureRecognizer(lpgr)
        self.getBuySellMsg(true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.didViewLoaded == true {
            offset = 1
            self.getBuySellMsg(false)
        } else {
            didViewLoaded = true
        }
    }
    
    func refreshChatHead(_ sender:AnyObject)  {
        self.offset = 1
        //self.getBuySellMsg(false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        

    }
    // MARK: Delegates
    
    func msgSent(_ hadSent: Bool) {
        self.hadSent = hadSent
    }
    
    // MARK: UITableViewDelegateMethods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayBuySellMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CellBuySellMsg"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CellMsg
        
        cell.layoutMargins = UIEdgeInsets.init(top: 0, left: 100, bottom: 0, right: 0)
        
        cell.lblProductName.text = (self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "itemname") as? String
        cell.lblUserName.text = (self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "username") as? String
        if !(cell.lblUserName.text?.characters.count > 0) {
            cell.lblUserName.text = "\(((self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as? String)!) \(((self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as? String)!)"
        }
        
        let mediaType = (self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "mediatype") as? String
        if mediaType!.contains("image") {
            cell.lblLastMsg.text = "Image"
        } else if mediaType!.contains("video") {
            cell.lblLastMsg.text = "Video"
        } else {
            cell.lblLastMsg.text = (self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "messagetext") as? String
            
            // StringToEmoji
            
            let strDescription = cell.lblLastMsg.text
            
            if let strDesc = strDescription
            {
                let style = NSMutableParagraphStyle()
                style.lineSpacing = 5
                let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                          NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
                
                let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
                var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
                
                for emojiName in customEmojis.emojiItemsArray {
                    objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
                }
                
                cell.lblLastMsg.attributedText = mutableStrDesc
            }
        }
        
        var strtime = (self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "messagedate") as? String
        strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
        cell.lblTime.text = strtime
        let strimgname = (self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "itemmedia") as? String

        
        if strimgname == nil || strimgname == "" {
            cell.imgViewBuySell.image = UIImage(named: "2kxologo")
            cell.imgViewBuySell.layer.cornerRadius = cell.imgViewFriends.frame.size.height / 2
            cell.imgViewBuySell.layer.masksToBounds = true
        } else {
        cell.imgViewBuySell!.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
                cell.imgViewBuySell.layer.cornerRadius = cell.imgViewBuySell.frame.size.height / 2
                cell.imgViewBuySell.layer.masksToBounds = true

        })
        }
        
        indexPatH = indexPath.row
//        if self.totalMsgCount > self.arrayBuySellMsg.count && indexPath.row == (self.arrayBuySellMsg.count - 1) {
//            offset += 1
//            getBuySellMsg(false)
//        }
        
        return cell
    }
    
    // MARK: - ScrollViewDelegate Method
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if  self.totalMsgCount > self.arrayBuySellMsg.count && indexPatH == (self.arrayBuySellMsg.count - 1) {
            if arrayBuySellMsg.count < totalMsgCount {
                offset += 1
                getBuySellMsg(false)
            }
        }
        guard let visibleIndexPaths = tblBuySellMsg.indexPathsForVisibleRows else { return }
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
                print(constant.btnObj1.frame.origin.x)
                print(constant.btnObj1.frame.origin.y)
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
            setLoginViewForGuest()
        }else {
            guard tblBuySellMsg.numberOfRows(inSection: 0) > 0 else { return }
            tblBuySellMsg.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
            
            
        }else {

        
        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        if let otherID = (self.arrayBuySellMsg.object(at: indexPath.row) as! NSDictionary).value(forKey: "userid") as? String {
            chatVC.otherID = Int(otherID)
        }
        
        if let userName = (self.arrayBuySellMsg.object(at: indexPath.row) as! NSDictionary).value(forKey: "username") as? String {
            chatVC.userName = userName
        }
        
        if (chatVC.userName?.characters.count)! <= 0 {
            if let firstName = (self.arrayBuySellMsg.object(at: indexPath.row) as! NSDictionary).value(forKey: "fname") as? String,
                let lastName = (self.arrayBuySellMsg.object(at: indexPath.row) as! NSDictionary).value(forKey: "lname") as? String {
                chatVC.userName = firstName + lastName
            }
        }
        
        chatVC.item_id = ((self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "itemid") as AnyObject).intValue
        chatVC.delegate = self
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    }
    
    func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
    }
    
    

    
    
    
    // MARK: Methods
    
    func newMsgCome(_ sender:AnyObject)  {
        self.getBuySellMsg(false)
    }
    
    func getBuySellMsg(_ reloadFlag: Bool) {
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        
        print(parameterss)
        
        if reloadFlag == true {
            SVProgressHUD.show(withStatus: "Fetching Activity", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.getBuyerSenderMsg(parameterss, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            print(dictMy ?? "nil value")
            
            if result == APIResult.apiSuccess {
                
                if let countMsg: Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                {
                    self.totalMsgCount = countMsg
                }
                
                if self.offset == 1 {
                    
                    self.arrayBuySellMsg.removeAllObjects()
                    self.arrayBuySellMsg = NSMutableArray(array: ((dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "messages") as? NSArray)!)
                } else {
                    for buySellObj in (NSMutableArray(array: ((dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "messages") as? NSArray)!)) {
                        self.arrayBuySellMsg.add(buySellObj)
                    }
                }
                if self.hadSent {
                    let indexPath = IndexPath.init(row: 0, section: 0)
                    self.tblBuySellMsg.reloadData()
                    self.tblBuySellMsg.scrollToRow(at: indexPath, at: .top, animated: false)
                    self.hadSent = false
                } else {
                    self.tblBuySellMsg.reloadData()
                }
                
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                print(dictMy ?? "nil value")
                mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func deleteChat(_ otherID: Int, itemID: Int) {
        let mgr = APIManager.apiManager
        let parameters = NSMutableDictionary()
        parameters.setValue(otherID, forKey: "otherid")
        parameters.setValue(itemID, forKey: "itemid")
        
        print(parameters)
        
        SVProgressHUD.show(withStatus: "Fetching Activity", maskType: SVProgressHUDMaskType.clear)
        
        mgr.deleteChat(parameters, successClosure: {(dictMy, result) -> Void in
            
            print(dictMy ?? "nil value")
            if result == APIResult.apiSuccess {
                SVProgressHUD.dismiss()
                self.offset = 1
                self.getBuySellMsg(true)
            } else if result == APIResult.apiError {
                mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: UIGestureRecognizerDelegateMethods
    
    func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.tblBuySellMsg)
        let indexPath = self.tblBuySellMsg.indexPathForRow(at: p)!
        if gestureRecognizer.state == .began {
            let alert:UIAlertController = UIAlertController(title: "Are you sure you want to delete this chat?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let yesAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                self.deleteChat((((self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "userid") as AnyObject).intValue)!, itemID: (((self.arrayBuySellMsg.object(at: indexPath.row) as AnyObject).value(forKey: "itemid") as AnyObject).intValue)!)
            }
            let noAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(yesAction)
            alert.addAction(noAction)
            
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                alert.modalPresentationStyle = .popover
                alert.popoverPresentationController!.sourceView = gestureRecognizer.view
                let cellRect = self.tblBuySellMsg.rectForRow(at: indexPath)
                alert.popoverPresentationController!.sourceRect = cellRect
                alert.popoverPresentationController?.canOverlapSourceViewRect = true
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            self.present(alert, animated: true, completion: nil)
        }
        else {
            print("gestureRecognizer.state = \(gestureRecognizer.state)")
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let textAttrib = [NSForegroundColorAttributeName : colors.kLightgrey155,
                          NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 24)!]
        let finalString = NSMutableAttributedString(string: "No records found", attributes: textAttrib)
        return finalString
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo")
    }
}
