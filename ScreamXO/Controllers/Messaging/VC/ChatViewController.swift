//
//  ChatViewController.swift
//  WhereIts
//
//  Created by Jatin Kathrotiya on 13/06/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import SafariServices
import TTTAttributedLabel
import AVKit
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


class MsgCell: UITableViewCell {
    @IBOutlet var imgViewProfilePic : UIImageView!
    @IBOutlet var chatBubble : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblMsg: KILabel! //TTTAttributedLabel!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet weak var btnTapVIew: UIButton!
    @IBOutlet weak var msgRecBtn: UIButton!
    
    @IBOutlet weak var msgSenBtn: UIButton!
    
}

class ImgCell: UITableViewCell {
    @IBOutlet var imgViewProfilePic : UIImageView!
    @IBOutlet var chatBubble : UIImageView!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var imgMsgPic : UIImageView!
    @IBOutlet var btnPic : UIButton!
    @IBOutlet var lblTime : UILabel!
    @IBOutlet var WidthC : NSLayoutConstraint!
    @IBOutlet var HeightC : NSLayoutConstraint!
    @IBOutlet var btnPlayVideo: UIButton!
    @IBOutlet weak var imgRecBtn: UIButton!
    @IBOutlet weak var imgSenBtn: UIButton!
    
    override func layoutSubviews() {
        
        imgViewProfilePic.layer.cornerRadius = imgViewProfilePic.bounds.width/2
        imgViewProfilePic.layer.masksToBounds = true
    }
}


protocol MsgSentDelegate {
    func msgSent(_ hadSent: Bool)
}

class ChatViewController: UIViewController , UITableViewDataSource ,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource , UIDocumentInteractionControllerDelegate {
    
    // MARK: Properties
    var chatArray:[Message] = []
    var tempChatArray: [Message] = []
    var _keyboardAnimationDuration : Double = 0
    var _keyboardAnimationCurve : NSInteger = 7
    var userId:Int!
    var userName:String?
    var shareURL: String!
    var ShareFlag = false
    var timerGetMsg:Timer!
    var picker:UIImagePickerController? = UIImagePickerController()
    var totalMsg:Int = 0
    var offset:Int = 1
    var isGroup:Bool = false
    var otherID: Int?
    var limit:Int = 20
    var user_name: String = ""
    var user_photo: String = ""
    var item_id:  Int?
    var directMsgType: String?
    var counter = 0
    var isPickerVisible : Bool = true
    var selectedDict = ["title" : "None", "value" : 0] as [String : Any]
    var selectedDate:Int?
    var timerArray = [["title": "30 min", "value": 30], ["title": "1 Hour", "value": 60],["title": "4 Hours", "value": 240],["title": "12 Hours", "value": 720], ["title": "24 Hours", "value": 1440]]
    var isTimerVisible = true
    var myItm: String = ""
    var imagePicked : UIImage?
    var dataVideofnl : Data?
    var videoUrl: URL? = nil
    var timerSelectedIndexPath: IndexPath?
    var delegate: MsgSentDelegate?
    var dictChatUserInfo = [String: AnyObject]()
    // MARK: IBOutlets
    
    @IBOutlet weak var userImgProfilePic: UIImageView!
    @IBOutlet var viewPreview: UIView!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var imgPreview: UIImageView!
    @IBOutlet var viewHeaderNav: UIView!
    @IBOutlet var tblChat: UITableView!
    @IBOutlet var txtView: SAMTextView!
    @IBOutlet var iaccessoryView: UIView!
    @IBOutlet var bottomC :NSLayoutConstraint!
    @IBOutlet var headerView: UIView!
    @IBOutlet var lblUserName: HeaderLable!
    @IBOutlet var btnDatePicker: UIButton!
    @IBOutlet var addEmojiButton: UIButton!
    @IBOutlet var emojiViewCollection: emojiSetView!
    @IBOutlet var tblTimer: UITableView!
    @IBOutlet var constHeightTblTimer: NSLayoutConstraint!
    @IBOutlet var itemView: UIView!
    @IBOutlet var imgItm: RoundImage!
    @IBOutlet var lblItmName: UILabel!
    @IBOutlet var lblItmPrice: UILabel!
    @IBOutlet var imgSoldOut: UIImageView!
    @IBOutlet var btnPaySeller: RoundRectbtn!
    
    // MARK: IBOutlets for contraints
    
    @IBOutlet var constTblUserNameHeight: NSLayoutConstraint!
     var documentController : UIDocumentInteractionController!
    
    // MARK: UIViewControllerOverridenMethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigController = self.navigationController {
            navigController.interactivePopGestureRecognizer?.delegate = nil
        }

        self.imgSoldOut.isHidden = true
        self.automaticallyAdjustsScrollViewInsets = false
        txtView.delegate = self
        self.tblChat.rowHeight = UITableViewAutomaticDimension
        self.tblChat.estimatedRowHeight = 65
        self.tblChat.tableFooterView = UIView()
        if ShareFlag {
//             self.txtView.text = shareURL
//            self.txtView.becomeFirstResponder()
        } else {
        self.txtView.placeholder = "Type Something..."
        if directMsgType != nil {
            self.txtView.text = "\(directMsgType!) :"
        }
        }
        
        
        txtView.enablesReturnKeyAutomatically = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapOnChatTbl(_:)))
        tap.numberOfTapsRequired = 1
      
        tblChat.addGestureRecognizer(tap)
        getMessages(true, isLoadMore: false)
        
        if userName != nil {
            lblUserName.text = userName
        } else {
            lblUserName.text = user_name
        }
        
        //title = userName
        
        emojiViewCollection.emojiCollectionView.delegate = self
        emojiViewCollection.emojiCollectionView.dataSource = self
        
        tblTimer.delegate = self
        tblTimer.dataSource = self
        hideTimer()
        if item_id != nil {
            
            getItemDetails()
        }
        let hv = headerView
        hv?.frame = CGRect(x: (hv?.frame.origin.x)!, y: (hv?.frame.origin.y)!, width: UIScreen.main.bounds.size.width,height: 0)
        self.tblChat.tableHeaderView = hv
        self.headerView.isHidden = true

    }

    override func viewWillAppear(_ animated: Bool) {

        let notificationName = Notification.Name("setFlagForChat")
        NotificationCenter.default.post(name: notificationName, object: nil)
        
        if ShareFlag {
//            self.txtView.text = shareURL
//            self.txtView.becomeFirstResponder()
        }
        
        userImgProfilePic.layer.masksToBounds = true
        userImgProfilePic.layer.cornerRadius = userImgProfilePic.frame.size.height / 2
        userImgProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
        }, completed: {(img, error, type, url) -> Void in
            
        })
        self.tabBarController?.tabBar.isHidden = true
        let defaulCenter = NotificationCenter.default
        defaulCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         defaulCenter.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         defaulCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.newMsgCome(_:)), name: NSNotification.Name(rawValue: "newMsgCome"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyBoardNew(_:)), name: NSNotification.Name(rawValue: "hideKeyBoardNew"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         view.endEditing(true)
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "newMsgCome"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "setFlagForChat"), object: nil)
        if( self.timerGetMsg != nil){
             self.timerGetMsg.invalidate()
        }
    }
    
    
    func hideKeyBoardNew(_ sender:AnyObject)  {
        self.view.endEditing(true)
    }
    
    // MARK: KeyboardHandleEvents
    func keyboardWillHide(_ notification:Notification?)  {
        bottomC.constant = 0
        UIView.animate(withDuration: 0.3,
                                   animations: { () -> Void in
                                    self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
        })
    }
    
    func keyboardWillShow(_ notification:Notification?)  {
        
         _keyboardAnimationDuration = ((notification?.userInfo![UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue)!
        
        
        _keyboardAnimationCurve = ((notification?.userInfo![UIKeyboardAnimationCurveUserInfoKey] as AnyObject).intValue)!
        
    }
    
    func keyboardWillChangeFrame(_ notification:Notification?)  {
        let rect = (notification?.userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let converted = self.view.convert(rect!, from: nil)
        let keyboardHeight = converted.size.height;
        bottomC.constant = keyboardHeight
        UIView.animate(withDuration: _keyboardAnimationDuration, delay:0.0, options:UIViewAnimationOptions.showHideTransitionViews, animations: {
            self.view.layoutIfNeeded()
            if self.tblChat.isLastRowVisible() {
                self.tblChat.reloadDataBottom(false)
            }
        }) { (finished:Bool) in
            
        }
    }
    
    // MARK: Webservice call for item detail
    
    func getItemDetails()
    {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrItm = ItemManager.itemManager
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.item_id!, forKey: "itemid")
        parameterss.setValue(usr.userId, forKey: "myid")
        
        print(parameterss)
        
        SVProgressHUD.show(withStatus: "Fetching Details", maskType: SVProgressHUDMaskType.clear)
        mgr.getShopItemDetails(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess
            {
                
                mgrItm.ItemName = (dic?.value(forKey: "result") as AnyObject).value(forKey: "item_name") as! NSString as String
                
                mgrItm.ItemDescription=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_description") as! NSString as String
                
                mgrItm.Itemmy =  "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "myitem") as! Int)"
                self.myItm = mgrItm.Itemmy
                mgrItm.isItemPurchase =  (dic?.value(forKey: "result") as AnyObject).value(forKey: "ispurchased") as! String
                mgrItm.itm_qty = String(describing: ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_qty"))!)
                mgrItm.itm_qty_remain = String(describing: ((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_qty_remained"))!)
                let itm_qty_remain: Int = Int(mgrItm.itm_qty_remain)!
                
                if itm_qty_remain == 0 {
                    self.imgSoldOut.isHidden = false
                    self.btnPaySeller.isHidden = true
                } else {
                    self.imgSoldOut.isHidden = true
                }
                
                let isbitcoinmail:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "bitcoinmail") as! String)"
                
                let actualprice:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "item_actualprice") as! String)"
                
                mgrItm.ItemactualPrice =  actualprice
                mgrItm.Itembitcoinmail = isbitcoinmail
                
                let isbitcoin:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "isbitcoin") as! Int as Int)"
                let ispaypal:String = "\((dic?.value(forKey: "result") as AnyObject).value(forKey: "ispaypal") as! Int as Int)"
                
                if (isbitcoin == "1" && ispaypal == "1" ) {
                    
                    mgrItm.ispaymentKind="3"
                } else if (isbitcoin == "1") {
                    
                    mgrItm.ispaymentKind="2"
                } else if (ispaypal == "1") {
                    
                    mgrItm.ispaymentKind="1"
                } else {
                    
                    mgrItm.ispaymentKind="0"
                }
                
                
                mgrItm.ItemPrice=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_price") as! NSString as String
                
                let keyExists = ((dic?.value(forKey: "result") as AnyObject).value(forKey: "media") as AnyObject).count
                if keyExists > 0
                {
                    
                    mgrItm.ItemmedID =  "\((((dic?.value(forKey: "result") as! NSDictionary).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "id") as! Int)"
                    
                    let itmphoto:String = (((dic?.value(forKey: "result") as AnyObject).value(forKey: "media")! as! NSArray)[0] as AnyObject).value(forKey: "media_url") as! String
                    
                    mgrItm.ItemImg=itmphoto
                    
                    
                    
                    mgrItm.arrayMedia.addObjects(from: (((dic?.value(forKey: "result") as AnyObject).value(forKey: "media") as! NSArray).mutableCopy() as! NSMutableArray) as [AnyObject])
                    
                }
                
                mgrItm.ItemShipingCost=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_shipping_cost") as! NSString as String
                mgrItm.ItemTags=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_tags") as! NSString as String
                mgrItm.ItemCategory=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_category_name") as! NSString as String
                mgrItm.ItemCategoryID=(dic?.value(forKey: "result") as AnyObject).value(forKey: "item_category_id") as! NSString as String
                
                
                self.tblChat.reloadData()
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic ?? "nil value")
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
    
    
    // MARK: MessageWebServiceCall
    
    func newMsgCome(_ sender:Notification)  {
        self.offset = 1
        self.getMessages(true , isLoadMore: false)
    }
    
    func getMessages(_ scrollFlag: Bool, isLoadMore: Bool)  {
        if ShareFlag {
            self.txtView.text = shareURL
            self.txtView.becomeFirstResponder()
        }
        let mgr = APIManager.apiManager
        let parameters = NSMutableDictionary()
        parameters.setValue(self.offset, forKey: "offset")
        parameters.setValue(limit, forKey: "limit")
        parameters.setValue(self.otherID!, forKey: "otherid")
        
        if self.item_id != nil {
            parameters.setValue(self.item_id!, forKey: "itemid")
        }
        
        print(parameters)
        
        if scrollFlag == true {
            SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.getChatMsg(parameters, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            print(dictMy ?? "nil value")
            
            if result == APIResult.apiSuccess
            {
                if self.item_id != nil {
                    if let itmImgString = ((dictMy?.value(forKey: "result") as AnyObject).value(forKey: "item") as AnyObject).value(forKey: "media_url") as? String
                    {
                        
                        self.imgItm.sd_setImageWithPreviousCachedImage(with: URL(string: itmImgString), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                        }, completed: {(img, error, type, url) -> Void in
                            
                        })
                        //self.imgItm.sd_setImage(with: URL(string: itmImgString), placeholderImage: UIImage())
                    }
                    
                    self.lblItmName.text = (((dictMy?.value(forKey: "result") as AnyObject).value(forKey: "item") as AnyObject).value(forKey: "name") as? String)?.replacingOccurrences(of: "\"", with: "")
                    self.lblItmPrice.text = "$\(((dictMy?.value(forKey: "result") as AnyObject).value(forKey: "item") as AnyObject).value(forKey: "itemprice") as! String)"
                }
                
                
                if let countMsg: Int = (dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int {
                    
                    self.totalMsg = countMsg
                }
                
                let msgDict = (((dictMy!.value(forKey: "result")! as AnyObject).value(forKey: "messages") as! NSArray).mutableCopy() as? [AnyObject])!
                
                if msgDict.count > 0 {
                    
                    if isLoadMore == false && scrollFlag == true {
                        
                        self.chatArray = Message.PopulateArray(msgDict)
                    } else if isLoadMore == false  {
                        
                        if self.offset != 1 {
                            
                            if self.totalMsg % ((self.offset - 1) * 10) > self.chatArray.count {
                                
                                self.tempChatArray = Message.PopulateArray(msgDict)
                                var startIndex = (self.chatArray.count % ((self.offset - 1) * 10))
                                
                                while startIndex < 10 {
                                    
                                    self.chatArray.append(self.tempChatArray[startIndex])
                                    startIndex += 1
                                }
                            }
                        } else if self.offset == 1 {
                            
                            if self.totalMsg > self.chatArray.count {
                                
                                self.tempChatArray = Message.PopulateArray(msgDict)
                                var startIndex = (self.chatArray.count % (self.offset * 10))
                                
                                while startIndex < 10 {
                                    
                                    self.chatArray.append(self.tempChatArray[startIndex])
                                    startIndex += 1
                                }
                            }
                        } else {
                            
                            if msgDict.count > self.chatArray.count {
                                
                                self.tempChatArray = Message.PopulateArray(msgDict)
                                var startIndex = (self.chatArray.count % ((self.offset - 1) * 10))
                                
                                while startIndex < 10 {
                                    
                                    self.chatArray.append(self.tempChatArray[startIndex])
                                    startIndex += 1
                                }
                            }
                        }
                    } else if isLoadMore == true && scrollFlag == true {
                        
                        self.tempChatArray = Message.PopulateArray(msgDict)
                        self.tempChatArray = self.tempChatArray.reversed()
                        self.chatArray = self.chatArray.reversed()
                        self.chatArray.append(contentsOf: self.tempChatArray)
                        self.chatArray = self.chatArray.reversed()
                    }
                    
                    if self.totalMsg == self.chatArray.count {
                        let hv = self.tblChat.tableHeaderView
                        hv?.frame = CGRect(x: (hv?.frame.origin.x)!, y: (hv?.frame.origin.y)!, width: UIScreen.main.bounds.size.width,height: 0)
                        self.tblChat.tableHeaderView = hv
                        self.headerView.isHidden = true
                    } else {
                        let hv = self.tblChat.tableHeaderView
                        hv?.frame = CGRect(x: (hv?.frame.origin.x)!, y: (hv?.frame.origin.y)!, width: UIScreen.main.bounds.size.width,height: 30)
                        self.tblChat.tableHeaderView = hv
                        self.headerView.isHidden = false
                    }
                    self.tblChat.reloadData()
                    
                    if scrollFlag == true {
                        if isLoadMore == true {
                            self.tblChat.setContentOffset(CGPoint.zero, animated:true)
                        } else {
                            if(self.chatArray.count > 0){
                                let numberOfSections = self.tblChat.numberOfSections
                                let numberOfRows = self.tblChat.numberOfRows(inSection: numberOfSections - 1)
                                let indexPath = IndexPath.init(row: numberOfRows - 1 , section: numberOfSections - 1)
                                self.tblChat.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
                            }
                        }
                    } else {
                        
                        self.chatArray = []
                    }
                    
                    if let otherUsrDict = (dictMy?.value(forKey: "result") as! NSDictionary).value(forKey: "otheruser") as? [String: AnyObject] {
                        self.dictChatUserInfo = otherUsrDict
                        self.user_name = (otherUsrDict["username"] as? String)!
                        self.user_photo = (otherUsrDict["userphoto"] as? String)!
                    }
                    
                    SVProgressHUD.dismiss()
                }
            } else if result == APIResult.apiError {
                    
                    self.tblChat.isHidden =  false
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    self.tblChat.isHidden =  false
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
                }
            
        })
    }

    
    func deleteMessage(_ messageID : Int, index : Int, fromid: Int)  {
        
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(1, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(fromid, forKey: "otherid")
        parameterss.setValue(messageID, forKey: "messageid")
        if self.item_id != nil {
            parameterss.setValue(self.item_id!, forKey: "itemid")
        }
        
        print(parameterss)
        
        mgr.deleteMsg(parameterss, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                self.tblChat.isHidden =  false
                self.chatArray.remove(at: index)
                self.totalMsg = self.totalMsg - 1
                self.tblChat.reloadData()
            } else if result == APIResult.apiError {
                self.tblChat.isHidden =  false
                mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
              
            } else {
                self.tblChat.isHidden =  false
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func sendMessages()  {
        
        if ShareFlag {
            var videoPath: URL?
            var movieData: Data?
            var type = ""
            let url = NSURL(string: shareURL)
            type = "image"
            let urlType = shareURL.components(separatedBy: ".")
            let dataType = urlType.last
            if dataType == "mp3" {
                videoPath = (url as URL?)!
                type = "video"
                do {
                    movieData = try Data(contentsOf: URL(fileURLWithPath: (videoPath!.relativePath)), options: NSData.ReadingOptions.alwaysMapped)
                } catch _ {
                    movieData = nil
                    return
                }
                type = "audio"
            } else if  dataType == "mp4" {
                videoPath = (url as URL?)!
                type = "video"
                do {
                    movieData = try Data(contentsOf: URL(fileURLWithPath: (videoPath!.relativePath)), options: NSData.ReadingOptions.alwaysMapped)
                } catch _ {
                    movieData = nil
                    return
                }
                 type = "video"
            } else if dataType == "png" {
                movieData = try? Data(contentsOf: url! as URL)
                let image: UIImage = UIImage(data: movieData!)!
                movieData = UIImageJPEGRepresentation(image, 0.8)
            }  else if dataType == "jpg" {
                movieData = try? Data(contentsOf: url! as URL)
                let image: UIImage = UIImage(data: movieData!)!
                movieData = UIImageJPEGRepresentation(image, 0.8)
            } else if dataType == "jpeg" {
                movieData = try? Data(contentsOf: url! as URL)
                let image: UIImage = UIImage(data: movieData!)!
                movieData = UIImageJPEGRepresentation(image, 0.8)
            }
            
            txtView.text = ""
            let usr = UserManager.userManager
            let parameterss = NSMutableDictionary()
            parameterss.setValue(usr.userId, forKey: "fromid")
            parameterss.setValue(self.otherID, forKey: "toid")
            parameterss.setValue(1, forKey: "messagetype")
            parameterss.setValue(txtView.text, forKey: "messagedetail")
            if selectedDate != nil && selectedDate > 0 {
                parameterss.setValue(selectedDate!, forKey: "messagetiming")
            }
            if item_id != nil {
                parameterss.setValue(self.item_id!, forKey: "itemid")
            }
            
            print(parameterss)
            
            
            SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
            APIManager.apiManager.sendChatMedia(parameterss,type: type, imgData: movieData) {
                responseObject,result in
                if result == APIResult.apiSuccess {
                    
                    if (self.delegate != nil) {
                        self.delegate?.msgSent(true)
                    }
                    let dictMy = responseObject
                    let msgDict = (dictMy!.value(forKey: "result") as! NSDictionary).mutableCopy() as! [String: AnyObject]
                    let msg = Message.Populate(msgDict)
                    self.chatArray.append(msg)
                    SVProgressHUD.dismiss()
                    self.tblChat.reloadData()
                    self.txtView.text = ""
                    
                    if(self.chatArray.count > 1){
                        let indexPath = IndexPath.init(row:self.chatArray.count - 1 , section: 0)
                        self.tblChat.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
                    }
                    
                } else if result == APIResult.apiError {
                    SVProgressHUD.dismiss()
                    mainInstance.ShowAlertWithError("ScreamXO", msg: responseObject!.value(forKey: "msg")! as! NSString)
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
                }
            
        }
        }else {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(self.otherID, forKey: "toid")
        parameterss.setValue(1, forKey: "messagetype")
        
        // EmojiToString
        let txtPostAttribString = self.txtView.attributedText
        self.txtView.text = ""
        let txtMutableAttribString = NSMutableAttributedString(attributedString: txtPostAttribString!)
        
        txtMutableAttribString.enumerateAttribute(NSAttachmentAttributeName, in: NSMakeRange(0, txtMutableAttribString.length), options: [], using: {(value: Any?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if (value is NSTextAttachment) {
                let attachment = (value as! NSTextAttachment)
                var image: UIImage!
                if attachment.image != nil  {
                    
                    image = attachment.image
                    
                    if let emojiName = objAppDelegate.getEmojiName(image) {
                        txtMutableAttribString.replaceCharacters(in: range, with: NSAttributedString(string: emojiName))
                    }
                }
            }
        })
        print(txtMutableAttribString.string)
        
        let strMsg =  txtMutableAttribString.string
        
        
        
        parameterss.setValue(strMsg, forKey: "messagedetail")
        if selectedDate != nil && selectedDate > 0
        {
            parameterss.setValue(selectedDate!, forKey: "messagetiming")
        }
        if item_id != nil
        {
            parameterss.setValue(self.item_id!, forKey: "itemid")
        }
        
        print(parameterss)
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
        
        mgr.sendChatMsg(parameterss, successClosure: {(dictMy, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                if (self.delegate != nil) {
                    self.delegate?.msgSent(true)
                }
                let msgDict = (dictMy!.value(forKey: "result") as! NSDictionary).mutableCopy() as! [String: AnyObject]
                let msg = Message.Populate(msgDict)
                self.chatArray.append(msg)
                SVProgressHUD.dismiss()
                self.tblChat.reloadData()
                if(self.chatArray.count > 1){
                    let indexPath = IndexPath.init(row:self.chatArray.count - 1 , section: 0)
                    self.tblChat.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
                }
            } else if result == APIResult.apiError {
                self.view.endEditing(true)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dictMy!.value(forKey: "msg")! as! NSString)
                self.tblChat.isHidden =  false
                SVProgressHUD.dismiss()
            } else {
                self.view.endEditing(true)
                self.tblChat.isHidden =  false
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
        }
    }
    
    // MARK: IBActions
    
    
    @IBAction func btnOnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnLoadMoreClicked(_ sender:AnyObject?) {
        
        if totalMsg > chatArray.count
        {
            if totalMsg > 20 {
                offset = offset + 1
            }
            
            self.getMessages(true, isLoadMore: true)
        }
    }
    
    @IBAction func btnBackClicked() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTimerClicked(_ sender: UIButton) {
        self.txtView.endEditing(true)
                if isTimerVisible {
            
            self.showTimer()
        } else {
            
            self.hideTimer()
            
        }
    }
    
    @IBAction func btnCameraClicked()
    {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        self.present(fusuma, animated: true, completion: nil)
        
    }
    
    @IBAction func addEmoji(_ sender: UIButton)
    {
        if addEmojiButton.tag == 0 {
            txtView.resignFirstResponder()
            txtView.inputView = self.emojiViewCollection.emojiCollectionView
            txtView.becomeFirstResponder()
            addEmojiButton.setImage(UIImage(named: "ico-keyboard"), for: UIControlState())
            addEmojiButton.tag = 1
            txtView.reloadInputViews()
        } else if addEmojiButton.tag == 1{
            txtView.resignFirstResponder()
            txtView.inputView = nil
            txtView.becomeFirstResponder()
            addEmojiButton.setImage(UIImage(named: "like"), for: UIControlState())
            addEmojiButton.tag = 0
            txtView.reloadInputViews()
        }
    }
    
    
    @IBAction func btnPayClicked(_ sender: UIButton) {
        
        let mgrItm = ItemManager.itemManager
        
        if mgrItm.ispaymentKind == "0" {
            
            mainInstance.ShowAlertWithError("Error!", msg: "you can not purchase this item!! seller has not configured payment gateway")
        } else {
        
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "PaymentDetailsVC")) as! PaymentDetailsVC
            self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    // MARK: Methods
    
    func attemptOpenURL(_ url: URL) {

        let webView: UIWebView! = UIWebView()
        webView.loadRequest(URLRequest(url: url))
        let mywebViewController = UIViewController()
        mywebViewController.view = webView
        let navController = UINavigationController(rootViewController: mywebViewController)
        mywebViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: "dismiss")
        self.navigationController!.present(navController, animated: true, completion: nil)
        
        //if  UIApplication.shared.canOpenURL(url) {
       //          UIApplication.shared.openURL(url)
       // }
       // else {
        //    let alert = UIAlertController(title: "Problem", message: "The selected link cannot be opened.", preferredStyle: .alert)
       //     let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //    alert.addAction(defaultAction)
         //   present(alert, animated: true, completion: nil)
       // }
    }
    
    func tapOnChatTbl(_ sender: AnyObject?){
      self.txtView.resignFirstResponder()
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func saveSuccess(_ image: UIImage, error: NSError?, contextInfo:UnsafeRawPointer){
        mainInstance.ShowAlert("ScreamXO", msg: "Image saved successfully!")
    }
    
    func openOptions(_ sender:UILongPressGestureRecognizer)  {
        
        let btnSender = sender.view as! UIButton
        
        let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if btnSender.accessibilityIdentifier! == "image" {
            let gallaryAction = UIAlertAction(title: "Save to gallery", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                let indexPath = IndexPath.init(row: btnSender.tag, section: 0)
                let cell :ImgCell = (self.tblChat.cellForRow(at: indexPath) as? ImgCell)!
                UIImageWriteToSavedPhotosAlbum(cell.imgMsgPic.image!, self,#selector(self.saveSuccess(_:error:contextInfo:)), nil)
            }
            alert.addAction(gallaryAction)
        }
        
        if btnSender.accessibilityIdentifier == "text" {
            let copyAction = UIAlertAction(title: "Copy Post", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let msg = self.chatArray[btnSender.tag]
                UIPasteboard.general.string = msg.messagetext
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(copyAction)
        }
        
        let deleteAction = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.destructive) {
            UIAlertAction in
            let msg = self.chatArray[btnSender.tag]
            
            let indext:Int = btnSender.tag
            
            self.deleteMessage(msg.messageid, index: indext, fromid: msg.sender_id)
            
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(deleteAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
            
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.modalPresentationStyle = .popover
            alert.popoverPresentationController!.sourceView = btnSender
            alert.popoverPresentationController!.sourceRect = sender.view!.bounds
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func playVideo(_ sender : AnyObject) {
        
        let btn = sender as! UIButton
        let msg = chatArray[btn.tag]
        self.present(SFSafariViewController(url: URL.init(string: msg.media)!), animated: true, completion: nil)
    }
    
    func openFullImage(_ sender: UIButton) {
        
        let msg = self.chatArray[sender.tag]
        let strybrdImageViewr = UIStoryboard(name: "ImageViewer", bundle: nil)
        let x = strybrdImageViewr.instantiateViewController(withIdentifier: "ImageViewerViewController") as! ImageViewerViewController
        x.arrayImages=[["media_url" : msg.media]]
        self.present(x, animated:true, completion: nil)
    }
    
    func cancelTimerTapped() {
        
        self.hideTimer()
        self.txtView.becomeFirstResponder()
    }

    func showTimer() {
        isTimerVisible = false
        constHeightTblTimer.constant = 270
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        
        tblTimer.reloadData()
        tblTimer.selectRow(at: timerSelectedIndexPath, animated: false, scrollPosition: .none)
    }
    
    func hideTimer() {
        isTimerVisible = true
        
        constHeightTblTimer.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        })
        tblTimer.reloadData()
    }
    
    
    // MARK: DelegateMethods
    
    
    // MARK: Image Picker Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        var videoPath: URL?
        var movieData: Data?
        var type = ""
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        // choose Video
        if mediaType.isEqual(to: kUTTypeMovie as String) {
            videoPath = (info[UIImagePickerControllerMediaURL] as? URL)!
            type = "video"
            // Check the file path in here
            do {
                movieData = try Data(contentsOf: URL(fileURLWithPath: (videoPath!.relativePath)), options: NSData.ReadingOptions.alwaysMapped)
            } catch _ {
                movieData = nil
                return
            }
        } else if mediaType.isEqual(to: kUTTypeImage as String) {
            type = "image"
            var image = info[UIImagePickerControllerOriginalImage] as? UIImage
            image = image?.resizeChatImage()
            movieData = UIImageJPEGRepresentation(image!, 0.8)
        }
        
        let usr = UserManager.userManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(self.otherID, forKey: "toid")
        parameterss.setValue(1, forKey: "messagetype")
        parameterss.setValue(txtView.text, forKey: "messagedetail")
        if selectedDate != nil && selectedDate > 0 {
            parameterss.setValue(selectedDate!, forKey: "messagetiming")
        }
        if item_id != nil {
            parameterss.setValue(self.item_id!, forKey: "itemid")
        }
        
        print(parameterss)
        
           
        SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
            APIManager.apiManager.sendChatMedia(parameterss,type: type, imgData: movieData) {
                responseObject,result in
                if result == APIResult.apiSuccess {
                    
                    if (self.delegate != nil) {
                        self.delegate?.msgSent(true)
                    }
                    let dictMy = responseObject
                    let msgDict = (dictMy!.value(forKey: "result") as! NSDictionary).mutableCopy() as! [String: AnyObject]
                    let msg = Message.Populate(msgDict)
                    self.chatArray.append(msg)
                    SVProgressHUD.dismiss()
                    self.tblChat.reloadData()
                    self.txtView.text = ""
                    
                    if(self.chatArray.count > 1){
                        let indexPath = IndexPath.init(row:self.chatArray.count - 1 , section: 0)
                        self.tblChat.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
                    }
                    
                } else if result == APIResult.apiError {
                    SVProgressHUD.dismiss()
                    mainInstance.ShowAlertWithError("ScreamXO", msg: responseObject!.value(forKey: "msg")! as! NSString)
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
                }
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker .dismiss(animated: true, completion: nil)
        // print("picker cancel.")
    }
    
    // MARK: UICollectionViewDelegateMethods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == emojiViewCollection.emojiCollectionView {
            return 1
        } else {
            return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return customEmojis.emojiItemsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "EmojiCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! EmojiCollectionViewCell
        cell.emojiImage?.image =  customEmojis.emojiItems[customEmojis.emojiItemsArray[indexPath.row]]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let textAttachment = MyTextAttachment()
        let emoji =  customEmojis.emojiItemsArray[indexPath.row]
        textAttachment.image = customEmojis.emojiItems[emoji]
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        let mutAttrString = NSMutableAttributedString()
        mutAttrString.append(txtView.attributedText)
        mutAttrString.append(attrStringWithImage)
        let txtViewFontSize = txtView.font?.pointSize
        let textAttrib = [NSForegroundColorAttributeName : colors.kTextViewColor,
                          NSFontAttributeName : UIFont(name: (txtView.font?.fontName)!, size: txtViewFontSize!)!]
        mutAttrString.addAttributes(textAttrib, range: NSRange(location: 0,length: mutAttrString.length))
        txtView.attributedText = mutAttrString
    }
    
    // MARK: UITableViewDelegateMethods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount: Int?
        if tableView == tblChat {
            rowCount = chatArray.count
        } else if tableView == tblTimer {
            rowCount = timerArray.count
        }
        return rowCount!
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == tblTimer {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = UIColor.init(red: 243.0/255.0, green: 243.0/255.0, blue: 243.0/255.0, alpha: 1.0)
            let lblHeader = UILabel(frame: CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height))
            lblHeader.font = UIFont(name: fontsName.KfontproxisemiBold, size: 22)
            lblHeader.text = "Time"
            
            lblHeader.textAlignment = NSTextAlignment.center
            headerView.addSubview(lblHeader)
            
            return headerView
        }
        else if item_id != nil && myItm == "0" {
            return itemView
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if tableView == tblTimer {
            
            let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            footerView.backgroundColor = UIColor.init(red: 163.0/255.0, green: 182.0/255.0, blue: 217.0/255.0, alpha: 1.0)
            let btnFooter = UIButton(frame: CGRect(x: 0, y: 0, width: footerView.frame.width, height: footerView.frame.height))
            btnFooter.titleLabel?.font = UIFont(name: fontsName.KfontproxiRegular, size: 14)!
            btnFooter.addTarget(self, action: #selector(self.cancelTimerTapped), for: .touchUpInside)
            btnFooter.setTitle("Cancel", for: UIControlState())
            btnFooter.titleLabel?.textAlignment = NSTextAlignment.center
            btnFooter.setTitleColor(UIColor.black, for: UIControlState())
            footerView.addSubview(btnFooter)
            
            return footerView
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if tableView == tblTimer {
            return 50.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == tblTimer {
            return 50.0
        } else if item_id != nil && myItm == "0" {
            return self.itemView.frame.height
        } else {
            return 0.0
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblChat {
            let msg = chatArray[indexPath.row]
            
            if(msg.sender_id == self.otherID) {
                if msg.media_type.contains("image") {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ImgRevicerCell") as! ImgCell
                    cell.btnPic.accessibilityIdentifier = "image"
                    cell.btnPlayVideo.isHidden = true
                    cell.imgViewProfilePic.image = UIImage(named: "img")
                    cell.imgViewProfilePic.layer.cornerRadius =  cell.imgViewProfilePic.frame.size.height / 2
                    cell.imgViewProfilePic.clipsToBounds = true
                    cell.imgViewProfilePic.layer.masksToBounds = true
                    cell.lblName.text = self.user_name
                    cell.imgMsgPic.sd_setImage(with: URL(string: msg.media_thumb), placeholderImage: UIImage())
                    cell.imgRecBtn.tag = indexPath.row
                    cell.imgRecBtn.addTarget(self, action: #selector(ChatViewController.imgRecBtnAction(_:)), for: UIControlEvents.touchUpInside)

                    cell.imgViewProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: self.user_photo), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                        cell.imgViewProfilePic.layer.cornerRadius = cell.imgViewProfilePic.frame.size.height / 2
                        cell.imgViewProfilePic.layer.masksToBounds = true
                    })
                    
                    
                    let at = ChatDateTime.sharedInstance.attributedStringForDisplayOfDate(Message.DateFromString(msg.messagedate))
                    at.addAttribute(NSForegroundColorAttributeName, value:cell.lblTime.textColor, range: NSMakeRange(0, at.length))
                    at.addAttribute(NSFontAttributeName, value: cell.lblTime.font, range: NSMakeRange(0, at.length))
                    cell.lblTime.attributedText = at
                    cell.chatBubble.image = UIImage(named: "left")?.leftBubble()
                    
                    cell.btnPic.tag = indexPath.row
                    
                    cell.btnPic.addTarget(self, action: #selector(self.openFullImage(_:)), for: UIControlEvents.touchUpInside)
                    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.openOptions(_:)))
                    lpgr.minimumPressDuration = 1.0
                    lpgr.delegate = self
                    cell.btnPic.addGestureRecognizer(lpgr)
                    
                    cell.setNeedsUpdateConstraints()
                    cell.updateConstraintsIfNeeded()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                    
                } else if msg.media_type.contains("video") {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ImgRevicerCell") as! ImgCell
                    cell.btnPlayVideo.accessibilityIdentifier = "video"
                    cell.btnPic.isHidden = true
                    cell.btnPlayVideo.isHidden = false
                    cell.imgRecBtn.tag = indexPath.row
                    cell.imgRecBtn.addTarget(self, action: #selector(ChatViewController.imgRecBtnAction(_:)), for: UIControlEvents.touchUpInside)
                    cell.btnPlayVideo.tag = indexPath.row
                    cell.btnPlayVideo.addTarget(self, action: #selector(self.playVideo(_:)), for: .touchUpInside)
                    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.openOptions(_:)))
                    lpgr.minimumPressDuration = 1.0
                    lpgr.delegate = self
                    cell.btnPlayVideo.addGestureRecognizer(lpgr)
                    
                    cell.imgViewProfilePic.image = UIImage(named: "img")
                    cell.imgViewProfilePic.layer.cornerRadius =  cell.imgViewProfilePic.frame.size.height / 2
                    cell.imgViewProfilePic.clipsToBounds = true
                    cell.imgViewProfilePic.layer.masksToBounds = true
                    cell.lblName.text = self.user_name
                    
                    cell.imgMsgPic.sd_setImage(with: URL(string: msg.media_thumb), placeholderImage:UIImage())
                    
                    cell.imgViewProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: self.user_photo), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                        cell.imgViewProfilePic.layer.cornerRadius = cell.imgViewProfilePic.frame.size.height / 2
                        cell.imgViewProfilePic.layer.masksToBounds = true
                    })
                    
                    
                    //cell.imgViewProfilePic.sd_setImage(with: URL(string: self.user_photo), placeholderImage: UIImage(named: "placeholder"))
                    
                    let at = ChatDateTime.sharedInstance.attributedStringForDisplayOfDate(Message.DateFromString(msg.messagedate))
                    at.addAttribute(NSForegroundColorAttributeName, value:cell.lblTime.textColor, range: NSMakeRange(0, at.length))
                    at.addAttribute(NSFontAttributeName, value: cell.lblTime.font, range: NSMakeRange(0, at.length))
                    cell.lblTime.attributedText = at
                    cell.chatBubble.image = UIImage(named: "left")?.leftBubble()
                    cell.setNeedsUpdateConstraints()
                    cell.updateConstraintsIfNeeded()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }else {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MsgReciverCell") as! MsgCell
                    
                    cell.chatBubble.image = UIImage(named: "left")?.leftBubble()
                    
                    cell.imgViewProfilePic.image = UIImage(named: "img")
                    cell.imgViewProfilePic.layer.cornerRadius =  cell.imgViewProfilePic.frame.size.height / 2
                    cell.imgViewProfilePic.clipsToBounds = true
                    cell.msgRecBtn.tag = indexPath.row
                    cell.msgRecBtn.addTarget(self, action: #selector(ChatViewController.msgRecBtnAction(_:)), for: UIControlEvents.touchUpInside)
                    
                    cell.lblMsg.urlLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
                        // Open URLs
                        self.attemptOpenURL(URL(string: string)!)
                    }
                    cell.lblMsg.userHandleLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
                        // Open URLs
                        self.attemptOpenURL(URL(string: string)!)
                    }
                    cell.lblMsg.hashtagLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
                        // Open URLs
                        self.attemptOpenURL(URL(string: string)!)
                    }
                    
                    
                    cell.lblMsg.text = msg.messagetext
                    
                    // StringToEmoji
                    
                    let strDescription = cell.lblMsg.text
                    
                    if let strDesc:String = strDescription {
                        
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 5
                        let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                                  NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
                        
                        let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
                        var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
                        
                        for emojiName in customEmojis.emojiItemsArray {
                            objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
                        }
                        
                        cell.lblMsg.attributedText = mutableStrDesc
                    }
                    
                    
                    cell.lblName.text = self.user_name
                    
                    cell.imgViewProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: self.user_photo), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                        cell.imgViewProfilePic.layer.cornerRadius = cell.imgViewProfilePic.frame.size.height / 2
                        cell.imgViewProfilePic.layer.masksToBounds = true
                    })
                    
                    
                    //cell.imgViewProfilePic.sd_setImage(with: URL(string: user_photo), placeholderImage: UIImage(named: "placeholder"))
                    
                    cell.btnTapVIew.tag = indexPath.row
                    
                    cell.btnTapVIew.accessibilityIdentifier = "text"
                    
                    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.openOptions(_:)))
                    
                    lpgr.minimumPressDuration = 1.0
                    lpgr.delegate = self
                    
                    cell.btnTapVIew.addGestureRecognizer(lpgr)
                    
                    let at = ChatDateTime.sharedInstance.attributedStringForDisplayOfDate(Message.DateFromString(msg.messagedate))
                    at.addAttribute(NSForegroundColorAttributeName, value:cell.lblTime.textColor, range: NSMakeRange(0, at.length))
                    at.addAttribute(NSFontAttributeName, value: cell.lblTime.font, range: NSMakeRange(0, at.length))
                    cell.lblTime.attributedText = at
                    cell.setNeedsUpdateConstraints()
                    cell.updateConstraintsIfNeeded()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
            }else{
                
                if msg.media_type.contains("image") {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ImgSenderCell") as! ImgCell
                    cell.btnPlayVideo.isHidden = true
                    cell.imgViewProfilePic.image = UIImage(named: "img")
                    cell.imgViewProfilePic.layer.cornerRadius =  cell.imgViewProfilePic.frame.size.height / 2
                    cell.imgViewProfilePic.clipsToBounds = true
                    cell.imgViewProfilePic.layer.masksToBounds = true
                    cell.lblName.text = ""
                    cell.imgSenBtn.tag = indexPath.row
                    cell.imgSenBtn.addTarget(self, action: #selector(ChatViewController.imgSenBtnAction(_:)), for: UIControlEvents.touchUpInside)
                    cell.imgMsgPic.sd_setImage(with: URL(string: msg.media), placeholderImage:UIImage())
                    cell.imgViewProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                        cell.imgViewProfilePic.layer.cornerRadius = cell.imgViewProfilePic.frame.size.height / 2
                        cell.imgViewProfilePic.layer.masksToBounds = true
                    })
                    
                    cell.chatBubble.image = UIImage(named: "right")?.rightBubble()
                    
                    cell.btnPic.tag = indexPath.row
                    
                    cell.btnPic.accessibilityIdentifier = "image"
                    cell.btnPic.addTarget(self, action: #selector(self.openFullImage(_:)), for: UIControlEvents.touchUpInside)
                    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.openOptions(_:)))
                    lpgr.minimumPressDuration = 1.0
                    lpgr.delegate = self
                    cell.btnPic.addGestureRecognizer(lpgr)
                    
                    let at = ChatDateTime.sharedInstance.attributedStringForDisplayOfDate(Message.DateFromString(msg.messagedate))
                    at.addAttribute(NSForegroundColorAttributeName, value:cell.lblTime.textColor, range: NSMakeRange(0, at.length))
                    at.addAttribute(NSFontAttributeName, value: cell.lblTime.font, range: NSMakeRange(0, at.length))
                    cell.lblTime.attributedText = at
                    cell.setNeedsUpdateConstraints()
                    cell.updateConstraintsIfNeeded()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    
                    return cell
                }else if msg.media_type.contains("video") {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ImgSenderCell") as! ImgCell
                    cell.btnPlayVideo.accessibilityIdentifier = "video"
                    cell.btnPic.isHidden = true
                    cell.btnPlayVideo.isHidden = false
                    cell.btnPlayVideo.tag = indexPath.row
                    cell.btnPlayVideo.addTarget(self, action: #selector(self.playVideo(_:)), for: .touchUpInside)
                    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.openOptions(_:)))
                    lpgr.minimumPressDuration = 1.0
                    lpgr.delegate = self
                    cell.btnPlayVideo.addGestureRecognizer(lpgr)
                    cell.imgViewProfilePic.image = UIImage(named: "img")
                    cell.imgViewProfilePic.layer.cornerRadius =  cell.imgViewProfilePic.frame.size.height / 2
                    cell.imgViewProfilePic.clipsToBounds = true
                    cell.imgViewProfilePic.layer.masksToBounds = true
                    cell.lblName.text = ""
                    
                    
                    cell.imgMsgPic.sd_setImage(with: URL(string: msg.media_thumb), placeholderImage:UIImage())
                    cell.imgSenBtn.tag = indexPath.row
                    cell.imgSenBtn.addTarget(self, action: #selector(ChatViewController.imgSenBtnAction(_:)), for: UIControlEvents.touchUpInside)
                    
                    cell.imgViewProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                        cell.imgViewProfilePic.layer.cornerRadius = cell.imgViewProfilePic.frame.size.height / 2
                        cell.imgViewProfilePic.layer.masksToBounds = true
                    })
                    
                    
                    
                    let at = ChatDateTime.sharedInstance.attributedStringForDisplayOfDate(Message.DateFromString(msg.messagedate))
                    at.addAttribute(NSForegroundColorAttributeName, value:cell.lblTime.textColor, range: NSMakeRange(0, at.length))
                    at.addAttribute(NSFontAttributeName, value: cell.lblTime.font, range: NSMakeRange(0, at.length))
                    cell.lblTime.attributedText = at
                    cell.chatBubble.image = UIImage(named: "right")?.rightBubble()
                    cell.setNeedsUpdateConstraints()
                    cell.updateConstraintsIfNeeded()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MsgSenderCell") as! MsgCell
                    
                    cell.chatBubble.image = UIImage(named: "right")?.rightBubble()
                    cell.imgViewProfilePic.image = UIImage(named: "img")
                    cell.imgViewProfilePic.layer.cornerRadius =  cell.imgViewProfilePic.frame.size.height / 2
                    cell.imgViewProfilePic.clipsToBounds = true
                    
                    cell.msgSenBtn.tag = indexPath.row
                    cell.msgSenBtn.addTarget(self, action: #selector(ChatViewController.msgSenBtnAction(_:)), for: UIControlEvents.touchUpInside)
                    
                    cell.lblMsg.urlLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
                        self.attemptOpenURL(URL(string: string)!)
                    }
                    cell.lblMsg.userHandleLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
                        self.attemptOpenURL(URL(string: string)!)
                    }
                    
                    cell.lblMsg.hashtagLinkTapHandler =  {(label: KILabel, string: String, range: NSRange) -> Void in
                        self.attemptOpenURL(URL(string: string)!)
                    }
                    
                    // StringToEmoji
                    
                    let strDescription = msg.messagetext
                    
                    if let strDesc:String = strDescription {
                        
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 5
                        let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                                  NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
                        
                        let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
                        var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
                        
                        for emojiName in customEmojis.emojiItemsArray {
                            objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
                        }
                        
                        cell.lblMsg.attributedText = mutableStrDesc
                        
                    }
                    
                    
                    cell.imgViewProfilePic.sd_setImageWithPreviousCachedImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeholder"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                    }, completed: {(img, error, type, url) -> Void in
                        cell.imgViewProfilePic.layer.cornerRadius = cell.imgViewProfilePic.frame.size.height / 2
                        cell.imgViewProfilePic.layer.masksToBounds = true
                    })
                    
                    
                    //cell.imgViewProfilePic.sd_setImage(with: URL(string: UserManager.userManager.profileImage!), placeholderImage: UIImage(named: "placeholder"))
                    
                    cell.btnTapVIew.tag = indexPath.row
                    
                    cell.btnTapVIew.accessibilityIdentifier = "text"
                    
                    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.openOptions(_:)))
                    
                    lpgr.minimumPressDuration = 1.0
                    lpgr.delegate = self
                    
                    cell.btnTapVIew.addGestureRecognizer(lpgr)
                    
                    let at = ChatDateTime.sharedInstance.attributedStringForDisplayOfDate(Message.DateFromString(msg.messagedate))
                    at.addAttribute(NSForegroundColorAttributeName, value:cell.lblTime.textColor, range: NSMakeRange(0, at.length))
                    at.addAttribute(NSFontAttributeName, value: cell.lblTime.font, range: NSMakeRange(0, at.length))
                    cell.lblTime.attributedText = at
                    cell.setNeedsUpdateConstraints()
                    cell.updateConstraintsIfNeeded()
                    cell.selectionStyle = UITableViewCellSelectionStyle.none
                    return cell
                }
            }
        } else {
            let cellIdentifier = "tblTimerCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! tblTimerCell
            cell.contentView.backgroundColor = UIColor.init(red: 10/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0)
            cell.lblTime.text = timerArray[indexPath.row]["title"] as? String
            
            return cell
        }
    }
    
    
    
    
    func imgSenBtnAction(_ sender: AnyObject) {
         goToProfile(uID: UserManager.userManager.userId!)
        }
   
    func imgRecBtnAction(_ sender: AnyObject) {
        let uID: String  = String(describing: dictChatUserInfo["userid"]!)
        goToProfile(uID: uID)
    }
    
    func msgSenBtnAction(_ sender: AnyObject) {
        goToProfile(uID: UserManager.userManager.userId!)
        
    }
    
    func msgRecBtnAction(_ sender: AnyObject) {
        let uID: String  = String(describing: dictChatUserInfo["userid"]!)
        goToProfile(uID: uID)
    }
    
    func goToProfile(uID: String) {
        let mgrfriend = FriendsManager.friendsManager
        mgrfriend.clearManager()
        let user = UserManager.userManager
        if (uID == user.userId) {
            if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                leftVC.selectedrow = leftVC.profileRow
                leftVC.tblView.reloadData()
            }
            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
            self.navigationController?.pushViewController(VC1, animated: true)
            
        } else {
            
            mgrfriend.FriendID = "\(uID)"
            mgrfriend.FriendName = "\(dictChatUserInfo["fname"] as! String)"  +  "  \(dictChatUserInfo["lname"] as! String)"
            mgrfriend.FriendPhoto = "\(dictChatUserInfo["userphoto"] as! String)"
            mgrfriend.FUsername = "\(dictChatUserInfo["username"] as! String)"
            if let fID = dictChatUserInfo["isfriend"] as? Int {
                mgrfriend.isFriend = "\(fID)"
                print(fID)
                if fID == 1 {
                    if let fconnectionID = dictChatUserInfo["friendshipid"]! as? Int {
                        print(fconnectionID)
                        mgrfriend.friendConnectionID = "\(fconnectionID)"
                        
                    }
                }
            }
            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
            self.navigationController?.pushViewController(VC1, animated: true)
        }
        

    }
    


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == tblTimer {
            
            tableView.deselectRow(at: indexPath, animated: true)
            timerSelectedIndexPath = indexPath
            self.selectedDate = self.timerArray[indexPath.row]["value"] as? Int
            print(timerArray[indexPath.row]["value"] as! Int)
            self.hideTimer()
            self.txtView.becomeFirstResponder()
        }
    }
    
    func getGifAspectRatio(_ width:Int,  height:Int,  maxWidth:Int,  maxHeight:Int) -> CGSize {
        var  width1 = width > maxWidth ? maxWidth : width;
        var height1 = height > maxHeight ? maxHeight : height;
    
        let ratioW = Float(width1) / Float(width);
        let ratioH = Float(height1) / Float(height);
    
        if (ratioW <= ratioH) {
            height1 = Int((Float(height) * ratioW));
            //width1 = (int)((float)width * ratioW);
        } else {
            width1 = Int((Float(width) * ratioH));
            //height1 = (int)((float)height * ratioH);
        }
        return CGSize(width: CGFloat(width1), height: CGFloat(height1));
    }
   
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    // MARK: UITextViewDelegateMethods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidChange(_ textView: UITextView) {
    
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if(textView.text.characters.count > 0) {
                self.sendMessages()
                return false
            }
        } else if text == "@" {
        }
        return true
    }
}

extension UITableView {
    func reloadDataBottom(_ animated: Bool)
    {
        self.reloadData()
        let iPath = IndexPath(row: self.numberOfRows(inSection: 0) - 1, section: self.numberOfSections - 1)
        self.scrollToRow(at: iPath, at: .bottom, animated: false)
    }
    func isLastRowVisible() -> Bool {
        let lastSectionIndex = self.numberOfSections - 1
        let lastRowIndex = self.numberOfRows(inSection: lastSectionIndex) - 1
        let pathToLastRow = IndexPath(row: lastRowIndex, section: lastSectionIndex)
        let visibleRows = self.indexPathsForVisibleRows
        for row in visibleRows! {
            if row == pathToLastRow {
                return true
            }
        }
        return false
    }
}

extension UIImage{
    
    func leftBubble() ->  UIImage{
        return self.resizableImage(withCapInsets: UIEdgeInsetsMake(28, 11,11, 4), resizingMode: UIImageResizingMode.stretch)
    }
    func rightBubble() ->  UIImage{
        return self.resizableImage(withCapInsets: UIEdgeInsetsMake(28, 4, 11, 11), resizingMode: UIImageResizingMode.stretch)
    }
    func resizeChatImage() -> UIImage {
        var newWidth:CGFloat = self.size.width
        var newHeight:CGFloat = self.size.height
        if (self.size.width > self.size.height) {
            if self.size.width > 700 {
                newWidth = 700
                let scale = newWidth / self.size.width
                newHeight = self.size.height * scale
            }
        }else{
            if self.size.height  > 700 {
                newHeight = 700
                let scale = newHeight / self.size.height
                newWidth = self.size.width * scale
                
            }
        }
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func resizeArtWorkImage() -> UIImage {
        var newWidth:CGFloat = 100
        var newHeight:CGFloat = 100
        if (self.size.width > self.size.height) {
            if self.size.width > 700 {
                newWidth = 700
                let scale = newWidth / self.size.width
                newHeight = self.size.height * scale
            }
        }else{
            if self.size.height  > 700 {
                newHeight = 700
                let scale = newHeight / self.size.height
                newWidth = self.size.width * scale
                
            }
        }
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
extension ChatViewController: FusumaDelegate {
    func fusumaClosed() {
        
        print("Called when the close button is pressed")
    }
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    func fusumaImageSelected(_ image: UIImage) {
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            
            self.view.addSubview(self.viewPreview)
        
            }, completion: nil)
        btnPlay.isHidden = true
        videoUrl = nil
        print("Image selected")
        imgPreview.image = image
        imagePicked = image
        
    }
    func intialSetupForPreview() {
        
    }
    func fusumaVideoCompletedwithData(withFileURL dataass: Data, fileURLL: URL) {
        
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            
            self.view.addSubview(self.viewPreview)
           
            }, completion: nil)
        btnPlay.isHidden = false
        thumbnail(fileURLL)
        videoUrl = fileURLL
        dataVideofnl = dataass
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        viewPreview.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            
            self.view.addSubview(self.viewPreview)
          
            }, completion: nil)
        btnPlay.isHidden = false
        thumbnail(fileURL)
        videoUrl = fileURL
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("Called just after dismissed FusumaViewController")
    }
    func thumbnail(_ sourceURL:URL) -> Void {
        
        let asset = AVURLAsset(url: sourceURL, options: nil)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(0.1, 1)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)], completionHandler: {
            (requestedTime: CMTime, thumbnail: CGImage?, actualTime: CMTime, result: AVAssetImageGeneratorResult, error: Error?) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.imgPreview.image = UIImage(cgImage: thumbnail!)
            })
        })
        
       
    }
    @IBAction func btnPlayPressed(_ sender: AnyObject) {
        if let url = videoUrl {
            let player = AVPlayer(url: url)
            let controller=AVPlayerViewController()
            controller.player=player
            self.present(controller, animated: false, completion: nil)
            player.play()
        }
    }
    
    
    @IBAction func btnDonePressed(_ sender: AnyObject) {

        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            self.viewPreview.removeFromSuperview()
            }, completion: {
                result in
                var movieData: Data?
                var type = ""
                if let url = self.videoUrl {
                    //video
                    type = "video"
                    if let dataVideo = try? Data(contentsOf: url) {
                        movieData = dataVideo
                    } else {
                        movieData = self.dataVideofnl
                    }
                    
                } else {
                    //image
                    type = "image"
                    let image = self.imagePicked
                    movieData = UIImageJPEGRepresentation(image!, 0.8)
                    
                }
                
                let usr = UserManager.userManager
                let parameterss = NSMutableDictionary()
                parameterss.setValue(usr.userId, forKey: "fromid")
                parameterss.setValue(self.otherID, forKey: "toid")
                parameterss.setValue(1, forKey: "messagetype")
                parameterss.setValue(self.txtView.text, forKey: "messagedetail")
                if self.selectedDate != nil && self.selectedDate > 0 {
                    parameterss.setValue(self.selectedDate!, forKey: "messagetiming")
                }
                if self.item_id != nil {
                    parameterss.setValue(self.item_id!, forKey: "itemid")
                }
                
                print(parameterss)
                
                
                SVProgressHUD.show(withStatus: "", maskType: SVProgressHUDMaskType.clear)
                APIManager.apiManager.sendChatMedia(parameterss,type: type, imgData: movieData) {
                    responseObject,result in
                    if result == APIResult.apiSuccess {
                        
                        if (self.delegate != nil) {
                            self.delegate?.msgSent(true)
                        }
                        let dictMy = responseObject
                        let msgDict = (dictMy!.value(forKey: "result") as! NSDictionary).mutableCopy() as! [String: AnyObject]
                        let msg = Message.Populate(msgDict)
                        self.chatArray.append(msg)
                        SVProgressHUD.dismiss()
                        self.tblChat.reloadData()
                        self.txtView.text = ""
                        
                        if(self.chatArray.count > 1){
                            let indexPath = IndexPath.init(row:self.chatArray.count - 1 , section: 0)
                            self.tblChat.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: false)
                        }
                        
                    } else if result == APIResult.apiError {
                        SVProgressHUD.dismiss()
                        mainInstance.ShowAlertWithError("ScreamXO", msg: responseObject!.value(forKey: "msg")! as! NSString)
                    } else {
                        SVProgressHUD.dismiss()
                        mainInstance.showSomethingWentWrong()
                    }
                }
                
        })
        
    }
    @IBAction func btnClosePressed(_ sender: AnyObject) {
        UIView.transition(with: view, duration: 0.5, options: UIViewAnimationOptions(), animations: {
            self.viewPreview.removeFromSuperview()

            }, completion: nil)
    }
}

extension ChatViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

