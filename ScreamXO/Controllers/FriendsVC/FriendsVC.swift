 //
//  FriendsVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 29/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import TwitterKit
import Crashlytics
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


 protocol SelectUserForTransferMoneyDelegate: class {
    func SelectUserForTransferMoneyDelegate(userId: String , userName: String)
 }
 
protocol FriendActionDelegate  {
    func actionOnData()
}
class suggestedCell : UITableViewCell,UISearchBarDelegate
{
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var imgUser: RoundImage!
    @IBOutlet weak var lblRequest: UILabel!
    @IBOutlet var btnMsg: UIButton!
}

class RequestCell : UITableViewCell
{
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var btnreject: UIButton!
    @IBOutlet weak var btnaccept: UIButton!
    @IBOutlet weak var imgUser: RoundImage!
}

enum PopupType : Int {
    case finder = 0
    case invite = 1
}

enum InviteType : Int{
    case fbInvite = 0
    case twInvite = 1
    case cnInvite = 2
}

 class FriendsVC: UIViewController ,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate,FriendActionDelegate,UIGestureRecognizerDelegate, FBSDKAppInviteDialogDelegate   {
    
    enum TypeListFriend : NSInteger
    {
        case typeFriend = 0,typerequest,typesuggestion,typesearch,typeFB,typeTW
    }
    enum TypeSocial : NSInteger
    {
        case typeFb = 0,typeTw
    }
    
     weak var delegate: SelectUserForTransferMoneyDelegate?
    
    @IBOutlet var viewAutoFinderTopConstraint: NSLayoutConstraint!
    @IBOutlet var stackViewControlHeight: NSLayoutConstraint!
    @IBOutlet var btnSearchFilterOutlet: UIButton!
//    @IBOutlet weak var conHeightSearch: NSLayoutConstraint!
    @IBOutlet weak var tblFriends: UITableView!
    var typeSocial :Int!
    var typeFriend :Int!
    var typeFriendPrevios :Int!
    var dataSource = [AnyObject]()
    @IBOutlet weak var searchBarFriends: UISearchBar!
    
    @IBOutlet weak var btnFriend: UIButton!
    @IBOutlet weak var btnSuggestion: UIButton!
    @IBOutlet weak var btnRequest: UIButton!
    @IBOutlet var viewAutoFinder: UIView!
    @IBOutlet var viewInviteFinder :UIView!
    @IBOutlet var viewShareOption :UIView!
    @IBOutlet var viewInstaOp :UIView!
    
    @IBOutlet var btnAutoFibder:UIButton!
    @IBOutlet var btnFinder:UIButton!
    @IBOutlet var btnInvite:UIButton!
    var  _currentPopUP:PopupType?
    
    @IBOutlet var btnCheckFb:UIButton!
    @IBOutlet var btnCheckTw:UIButton!
    @IBOutlet var btnCheckIg:UIButton!
    @IBOutlet var btnCheckCn:UIButton!
    
    @IBOutlet var btnRadioFb:UIButton!
    @IBOutlet var btnRadioTw:UIButton!
    @IBOutlet var btnRadioCn:UIButton!
    
    @IBOutlet var instaHeight:NSLayoutConstraint!
    
    var autoFiderCheckArray = NSMutableArray()
    
    var _currentInvite : InviteType?
    
    
    var offsetsr:Int = 1
    var offsetsugge:Int = 1
    var offsetfriendreque:Int = 1
    var offsetFlist:Int = 1
    
    var ispushtype:Int = 0
    
    var slectedTAB:Int = 0
    var indexPatH = 0
    var totalList:Int = 0
    
    var limit:Int = 10
    
    var arraySearchResult = NSMutableArray ()
    var arraySuggestion = NSMutableArray ()
    var arrayRequest = NSMutableArray ()
    var arrayFriendList = NSMutableArray ()
    var arrayTemp = NSMutableArray()
    var totalSRCount:Int = 0
    var totalfriends:Int = 0
    
    var totalSuggesCount:Int = 0
    var totalrequeCount:Int = 0
    var theJSONTextFb :NSString = ""
    var theJSONTextTW :NSString = ""
    var theJSONTextIg :NSString = ""
    var theJSONTextcn :NSString = ""
    
    var strKeyword :String!
    var isFromNotify = false
    var isForTransferMoney = false
    var shareFlag = false
    
    var  shareUrl: String = ""
    var labelFriend: UILabel?
    var labelRequest: UILabel?
    var labelSuggestion: UILabel?
    // MARK: View life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        labelFriend = self.view.viewWithTag(121) as? UILabel
        labelRequest = self.view.viewWithTag(122) as? UILabel
        labelSuggestion = self.view.viewWithTag(123) as? UILabel
        
        searchBarFriends.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
        searchBarFriends.backgroundColor = UIColor.white
        searchBarFriends.barTintColor = UIColor.clear
        searchBarFriends.backgroundImage = UIImage()
        btnInvite.setTitleColor(UIColor.white, for: UIControlState())
        btnFinder.setTitleColor(UIColor.white, for: UIControlState())
        btnInvite.layer.masksToBounds = true
        btnFinder.layer.masksToBounds = true
        btnInvite.layer.cornerRadius = 4.0
        btnFinder.layer.cornerRadius = 4.0
        self.viewAutoFinder.isHidden = true
        self.viewInviteFinder.isHidden = true
        
        if self.viewAutoFinder.isHidden && self.viewInviteFinder.isHidden {
            self.stackViewControlHeight.constant = 41
        } else {
            self.stackViewControlHeight.constant = 121
        }
        typeFriend=0
        tblFriends.estimatedRowHeight = 80
        tblFriends.rowHeight = UITableViewAutomaticDimension
        tblFriends.reloadData()
        
        self.tblFriends.emptyDataSetDelegate = self
        self.tblFriends.emptyDataSetSource = self
        initUI()
        if isFromNotify {
            
            btnRequestClicked(UIButton())
        } else {
         
            FriendList()
        }
        
        // Do any additional setup after loading the view.
    }

    
    
    override func viewWillAppear(_ animated: Bool) {
        
        labelFriend?.isHidden = false
        labelRequest?.isHidden = true
        labelSuggestion?.isHidden = true
        
        if (self.ispushtype == 1) {
            typeFriend=1;
            self.arrayRequest.removeAllObjects()
            offsetfriendreque=1
            RequestList()
            self.ispushtype=0
        }
        else if (self.ispushtype == 2) {
            typeFriend=0;
            self.arrayFriendList.removeAllObjects()
            offsetFlist=1
            FriendList()
            self.ispushtype=0
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        objAppDelegate.repositiongsm()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        objAppDelegate.positiongsmAtBottom(viewController: self, position: PositionMenu.bottomRight.rawValue)
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
    

    // MARK: - init methods
    
    func dismissAllKeyboard() {
        self.view.endEditing(true)
    }
    
    func initUI() {
        
        self.checkSelectedButom()
        self.radioSelection()
    }
    
    func radioSelection(){
        if _currentInvite != nil {
            
            if(_currentInvite == InviteType.fbInvite){
                btnRadioFb.setImage(UIImage(named:"radioa"), for: UIControlState())
                btnRadioTw.setImage(UIImage(named:""), for: UIControlState())
                btnRadioCn.setImage(UIImage(named:""), for: UIControlState())
            }else if(_currentInvite == InviteType.twInvite){
                btnRadioFb.setImage(UIImage(named:""), for: UIControlState())
                btnRadioTw.setImage(UIImage(named:"radioa"), for: UIControlState())
                btnRadioCn.setImage(UIImage(named:""), for: UIControlState())
            }else if(_currentInvite == InviteType.cnInvite){
                btnRadioFb.setImage(UIImage(named:""), for: UIControlState())
                btnRadioTw.setImage(UIImage(named:""), for: UIControlState())
                btnRadioCn.setImage(UIImage(named:"radioa"), for: UIControlState())
            }
            
        }else{
            btnRadioFb.setImage(UIImage(named:""), for: UIControlState())
            btnRadioTw.setImage(UIImage(named:""), for: UIControlState())
            btnRadioCn.setImage(UIImage(named:""), for: UIControlState())
            
        }
    }
    
    func checkSelectedButom(){
        if(autoFiderCheckArray.contains("Fb")){
            self.btnCheckFb.setImage(UIImage(named: "checkbox"), for: UIControlState())
            
        }else{
            self.btnCheckFb.setImage(UIImage(named: ""), for: UIControlState())
        }
        
        if(autoFiderCheckArray.contains("Tw")){
            self.btnCheckTw.setImage(UIImage(named: "checkbox"), for: UIControlState())
            
        }else{
            self.btnCheckTw.setImage(UIImage(named: ""), for: UIControlState())
        }
        
        if(autoFiderCheckArray.contains("Ig")){
            self.btnCheckIg.setImage(UIImage(named: "checkbox"), for: UIControlState())
            
        }else{
            self.btnCheckIg.setImage(UIImage(named: ""), for: UIControlState())
        }
        if(autoFiderCheckArray.contains("Cn")){
            self.btnCheckCn.setImage(UIImage(named: "checkbox"), for: UIControlState())
            
        }
        else
        {
            self.btnCheckCn.setImage(UIImage(named: ""), for: UIControlState())
        }
    }
    
    // MARK: - custom button methods
    
    @IBAction func btnSearchFilter(_ sender: UIButton)
    {
        self.viewShareOption.isHidden = true
        
//        mainInstance.ShowAlert("Alert", msg: "Once ScreamXO is released to the public, you can use this to invite friends")
        
        if btnSearchFilterOutlet.tag == 0
        {
            viewAutoFinder.isHidden = false
            viewInviteFinder.isHidden = false
            stackViewControlHeight.constant = 51
            viewAutoFinderTopConstraint.constant = -45
            btnSearchFilterOutlet.tag = 1
        }
        else if btnSearchFilterOutlet.tag == 1
        {
            self.viewAutoFinder.isHidden = true
            self.viewInviteFinder.isHidden = true
            self.stackViewControlHeight.constant = 41
            viewAutoFinderTopConstraint.constant = 0
            btnSearchFilterOutlet.tag = 0
            
            btnInvite.setTitleColor(UIColor.white, for: UIControlState())
            btnInvite.tag = 0
            
            btnFinder.setTitleColor(UIColor.white, for: UIControlState())
            btnFinder.tag = 0
        }
    }
    
    @IBAction func btnMenuClicked(_ sender: AnyObject) {
        
        if (self.sideMenuViewController == nil)
        {
            
            self.navigationController?.popViewController(animated: true)
            
        }
        else
        {
        dismissAllKeyboard()
        self.sideMenuViewController.presentLeftMenuViewController()
        }
        
    }
    
    @IBAction func btnAutoFiderClicked(_ sender:AnyObject) {
        
        btnInvite.setTitleColor(UIColor.white, for: UIControlState())
        btnInvite.tag = 0
        
        btnFinder.setTitleColor(UIColor.white, for: UIControlState())
        btnFinder.tag = 0
        
        
        if(self.viewInviteFinder.isHidden){
            self.viewInviteFinder.isHidden = false
            
        }else{
            self.viewInviteFinder.isHidden = true
            self.viewShareOption.isHidden = true
        }
        
    }
    @IBAction func btnFinderClicked(_ sender:AnyObject){
        
        if btnFinder.tag == 0 {
            btnFinder.setTitleColor(colors.kLightgrey110, for: UIControlState())
            btnFinder.tag = 1
        } else if btnFinder.tag == 1 {
            btnFinder.setTitleColor(UIColor.white, for: UIControlState())
            btnFinder.tag = 0
        }
        
        btnInvite.setTitleColor(UIColor.white, for: UIControlState())
        btnInvite.tag = 0
        
        if(self.viewShareOption.isHidden || _currentPopUP == PopupType.invite ){
            _currentPopUP = PopupType.finder
            self.viewShareOption.isHidden = false
            //             btnFinder.setTitleColor(UIColor.whiteColor(),
            //                                     forState:UIControlState.Normal)
            //            btnInvite.setTitleColor(colors.kLightgrey110, forState:UIControlState.Normal)
        }else{
            _currentPopUP = nil
            self.viewShareOption.isHidden = true
            //            btnFinder.setTitleColor(colors.kLightgrey110, forState:UIControlState.Normal)
        }
        self.changePopUp()
    }
    
   
    
    
    func changePopUp() {
        if (_currentPopUP == PopupType.invite){
            
            
            
            func findView(_ v:UIView){
                
                for  c in v.subviews {
                    if c.isKind(of: RoundCornerView.self) {
                        c.isHidden  = true
                    }
                    else if(c.isKind(of: RoundView.self)){
                        c.isHidden  = false
                    }
                    if(c.isKind(of: UIView.self)){
                        findView(c)
                    }
                }
            }
            
            findView(self.viewShareOption)
            instaHeight.constant = 0.0
            viewInstaOp.isHidden = true
            
            
        }else {
            
            
            func findView(_ v:UIView){
                
                for  c in v.subviews {
                    if c.isKind(of: RoundView.self) {
                        c.isHidden  = true
                    }else if(c.isKind(of: RoundCornerView.self)){
                        c.isHidden  = false
                    }
                    if(c.isKind(of: UIView.self)){
                        findView(c)
                    }
                }
                
            }
            
            findView(self.viewShareOption)
            
            
            
            instaHeight.constant = 35.0
            viewInstaOp.isHidden = false
        }
    }
    
    
    @IBAction func btnInviteClicked(_ sender:AnyObject){
        
        if btnInvite.tag == 0 {
            btnInvite.setTitleColor(colors.kLightgrey110, for: UIControlState())
            btnInvite.tag = 1
        } else if btnInvite.tag == 1 {
            btnInvite.setTitleColor(UIColor.white, for: UIControlState())
            btnInvite.tag = 0
        }
        btnFinder.setTitleColor(UIColor.white, for: UIControlState())
        btnFinder.tag = 0
        
        if(self.viewShareOption.isHidden ||  _currentPopUP == PopupType.finder){
            
            _currentPopUP = PopupType.invite
            self.viewShareOption.isHidden = false
        }else{
            
            _currentPopUP = nil
            self.viewShareOption.isHidden = true
        }
        self.changePopUp()
    }
    
    @IBAction func btnFacebbokCLicked(_ sender: UIButton) {
        
        if(!autoFiderCheckArray.contains("Fb")){
            autoFiderCheckArray.add("Fb");
            self.btnCheckFb.setImage(UIImage(named: "checkbox"), for: UIControlState())
        }else{
            autoFiderCheckArray.remove("Fb");
            self.theJSONTextFb = ""
            self.btnCheckFb.setImage(UIImage(named: ""), for: UIControlState())
            return;
        }
        
        let login: FBSDKLoginManager = FBSDKLoginManager()
        login.logOut();
        
        login.logIn(withReadPermissions: ["email","public_profile","user_friends"] , from: self) { (result, error) -> Void in
            SVProgressHUD.show(withStatus: "Fetching Facebook Friends", maskType: SVProgressHUDMaskType.clear)
            if (error == nil)
            {
                let parameterss = NSMutableDictionary()
                
                parameterss.setValue("id", forKey: "fields")
                
                
                let fbRequest = FBSDKGraphRequest(graphPath: "/me/friends", parameters: parameterss as! [AnyHashable: Any], httpMethod: "GET")
                _ = fbRequest?.start(completionHandler:  { (connection : FBSDKGraphRequestConnection?, result : Any?, error : Error?) -> Void in
                    
                    SVProgressHUD.dismiss()
                    if error == nil {
                        
                        var temp = NSMutableArray()
                        let passArray = NSMutableArray()
                        
                        if let arraayTemp = (result as AnyObject).value(forKey: "data") as? NSArray
                        {
                            
                            temp = arraayTemp.mutableCopy() as! NSMutableArray
                            for i in 0 ..< temp.count
                            {
                                let parameterss = NSMutableDictionary()
                                parameterss.setValue((temp.object(at: i) as AnyObject).value(forKey: "id"), forKey: "fb_id")
                                passArray.add(parameterss)
                            }
                            
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                                self.theJSONTextFb = NSString(data: jsonData,
                                    encoding: String.Encoding.ascii.rawValue)!
                                print("JSON string = \(self.theJSONTextFb)")
                                
                                
                            } catch {
                                print(error)
                                
                            }
                        }
                        else
                        {
                            self.typeFriend=3;
                            self.arraySearchResult.removeAllObjects()
                            self.tblFriends.reloadData()
                            
                            
                            
                        }
                        
                    } else {
                        
                        print("Error Getting Friends \(error)");
                    }
                })
            }
            
        }
        
        
        
        
        // Handle the result
        
        
        
    }
    
    @IBAction func btnContactClicked(_ sender:UIButton){
        if(!autoFiderCheckArray.contains("Cn")){
            autoFiderCheckArray.add("Cn");
            self.btnCheckCn.setImage(UIImage(named: "checkbox"), for: UIControlState())
        }else{
            autoFiderCheckArray.remove("Cn");
            self.theJSONTextIg = ""
            self.btnCheckCn.setImage(UIImage(named: ""), for: UIControlState())
            return;
        }
        CNContactStore().requestAccess(for: .contacts) {granted, error in
            if granted {
                DispatchQueue.main.async {
                    JContactStore.sharedContact().fetchContactEmailswithblock ({ (dict:[AnyHashable: Any]!) in
                        
                        
                        let passArray = NSMutableArray()
                        if let temp : NSMutableArray = (dict as NSDictionary).value(forKey: "contactEmail") as? NSMutableArray
                        {
                            
                            for i in 0 ..< temp.count
                            {
                                let parameterss = NSMutableDictionary()
                                parameterss.setValue(temp.object(at: i), forKey: "email_id")
                                passArray.add(parameterss)
                                
                                
                                
                            }
                            
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                                self.theJSONTextcn = NSString(data: jsonData,
                                    encoding: String.Encoding.ascii.rawValue)!
                                print("JSON string = \(self.theJSONTextcn)")
                                
                                
                            } catch {
                                print(error)
                                
                            }
                        }
                    })
                }
            } else {
                let alertHide = UIAlertController(title: "Contacts Access Denied", message:"You must allow contacts access in Settings", preferredStyle: .alert)
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                })
                let Setting = UIAlertAction(title: "Settings", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.shared.openURL(url)
                    }
                    
                })
                alertHide.addAction(Cancel)
                alertHide.addAction(Setting)
                self.present(alertHide, animated: true, completion: nil)
            }
        }
        
        
    }
    
    @IBAction func btnInstagramClicked(_ sender: UIButton)  {
        if(!autoFiderCheckArray.contains("Ig")){
            autoFiderCheckArray.add("Ig");
            self.btnCheckIg.setImage(UIImage(named: "checkbox"), for: UIControlState())
        }else{
            autoFiderCheckArray.remove("Ig");
            self.theJSONTextIg = ""
            self.btnCheckIg.setImage(UIImage(named: ""), for: UIControlState())
            return;
        }
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let VC1=(sb.instantiateViewController(withIdentifier: "InstagramVC")) as! InstagramVC
        if (UserDefaults.standard.object(forKey: APIManager.APIConstants.kACCESSTOKEN) as? String) != nil {
            VC1.getUserFollows({ (Dict:NSDictionary?, status :APIResult) in
                
                
                self.instagramFolowerParss(Dict!)
                
                
                
            })
        }else{
            self.navigationController?.present(VC1, animated: true, completion: nil)
            VC1.getUserFollows({ (Dict:NSDictionary?, status :APIResult) in
                
                self.instagramFolowerParss(Dict!)
            })
        }
        
        
    }
    
    func instagramFolowerParss(_ dict:NSDictionary) {
        
        
        let passArray = NSMutableArray()
        
        if let temp = dict.value(forKey: "data") as? NSArray
        {
            
            for i in 0 ..< temp.count
            {
                let parameterss = NSMutableDictionary()
                parameterss.setValue((temp.object(at: i) as AnyObject).value(forKey: "id"), forKey: "Insta_id")
                passArray.add(parameterss)
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                self.theJSONTextIg = NSString(data: jsonData,
                                              encoding: String.Encoding.ascii.rawValue)!
                print("JSON string = \(self.theJSONTextIg)")
                
                
            } catch {
                print(error)
                
            }
        }
    }
    
    
    
    @IBAction func btnTwitterClicked(_ sender: UIButton) {

        if(!autoFiderCheckArray.contains("Tw")) {
            autoFiderCheckArray.add("Tw");
            self.btnCheckTw.setImage(UIImage(named: "checkbox"), for: UIControlState())
        }else{
            autoFiderCheckArray.remove("Tw");
            self.theJSONTextTW = ""
            self.btnCheckTw.setImage(UIImage(named: ""), for: UIControlState())
            return
        }
      
        Twitter.sharedInstance().logIn { session, error in
            if (session != nil) {
                print(session!.userID);
                SVProgressHUD.dismiss()
                
                let client = TWTRAPIClient()
                SVProgressHUD.show(withStatus: "Fetching Twitter Friends", maskType: SVProgressHUDMaskType.clear)
                
                
                client.loadUser(withID: session!.userID) { (user, error) -> Void in
                    do {
                        
                        SVProgressHUD.dismiss()
                        
                        //let client = TWTRAPIClient()
                        let statusesShowEndpoint = "https://api.twitter.com/1.1/friends/ids.json"
                        let params = ["id": user!.userID]
                        var clientError : NSError?
                        
                        let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
                        
                        
                        client.sendTwitterRequest(request, completion: { (response, data, connectionError) -> Void in
                            if (connectionError == nil) {
                                
                                do {
                                    let json : AnyObject? = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                                    
                                    print("JSON string = \(json!)")
                                    
                                    var temp = NSMutableArray()
                                    let passArray = NSMutableArray()
                                  
                                    let tempArray = json!.value(forKey: "ids") as! [AnyObject]
                                    temp = NSMutableArray(array: tempArray)
                                    for i in 0 ..< temp.count
                                    {
                                        let parameterss = NSMutableDictionary()
                                        parameterss.setValue(temp.object(at: i), forKey: "twitter_id")
                                        passArray.add(parameterss)
                                        
                                        
                                        
                                    }
                                    
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                                        self.theJSONTextTW = NSString(data: jsonData,
                                            encoding: String.Encoding.ascii.rawValue)!
                                        print("JSON string = \(self.theJSONTextTW)")
                                        // self.GetTWFriendList()
                                        
                                        
                                    } catch {
                                        print(error)
                                        
                                    }
                                    
                                    
                                    
                                }
                                catch {
                                    //print(jsonError)
                                    
                                }
                            }
                            else {
                                print("Error: \(connectionError)")
                            }
                        })
                    }
                    catch {
                        print(error)
                        
                    }
                    
                }
            }
            
        }
    }
    
    
    @IBAction func btnFbRadioClicked(_ sender: AnyObject){
        _currentInvite = InviteType.fbInvite
        self.radioSelection()
    }
    @IBAction func btnTwRadioClicked(_ sender: AnyObject){
        _currentInvite = InviteType.twInvite
        self.radioSelection()
    }
    @IBAction func btnCnRadioClicked(_ sender: AnyObject){
        
        _currentInvite = InviteType.cnInvite
        self.radioSelection()
    }
    
    
    @IBAction func btnFriendClicked(_ sender: AnyObject) {
        
        dismissAllKeyboard()
        
        if searchBarFriends.text?.characters.count > 0 {
            
            searchBarFriends.text = ""
        }
        
        labelFriend?.isHidden = false
        labelRequest?.isHidden = true
        labelSuggestion?.isHidden = true
        
//        let btnSuggestionTitle = NSMutableAttributedString(string: btnSuggestion.currentTitle!)
//        btnSuggestion.setAttributedTitle(btnSuggestionTitle, for: UIControlState())
//        let btnRequestTitle = NSMutableAttributedString(string: btnRequest.currentTitle!)
//        btnRequest.setAttributedTitle(btnRequestTitle, for: UIControlState())
//        let attrs = [NSUnderlineStyleAttributeName : 0]
//        let buttonTitleStr = NSMutableAttributedString(string: btnFriend.currentTitle!, attributes:attrs)
//        btnFriend.setAttributedTitle(buttonTitleStr, for: UIControlState())
        
        btnFriend.setTitleColor(UIColor.black , for: .normal )
        btnSuggestion.setTitleColor(UIColor.lightGray , for: .normal)
        btnRequest.setTitleColor(UIColor.lightGray , for: .normal)
        btnRequest.tintColor = UIColor.lightGray
        btnSuggestion.tintColor = UIColor.lightGray
        btnFriend.tintColor = UIColor.black
        typeFriend=0
        slectedTAB=0
        self.arrayFriendList.removeAllObjects()
        offsetFlist=1
        FriendList()
    }
    
    @IBAction func btnRequestClicked(_ sender: AnyObject) {
        
        dismissAllKeyboard()
        if searchBarFriends.text?.characters.count > 0 {
            searchBarFriends.text = ""
        }
        labelFriend?.isHidden = true
        labelRequest?.isHidden = false
        labelSuggestion?.isHidden = true
        
//        let btnFriendTitle = NSMutableAttributedString(string: btnFriend.currentTitle!)
//        btnFriend.setAttributedTitle(btnFriendTitle, for: UIControlState())
//        let btnSuggestionTitle = NSMutableAttributedString(string: btnSuggestion.currentTitle!)
//        btnSuggestion.setAttributedTitle(btnSuggestionTitle, for: UIControlState())
//        let attrs = [NSUnderlineStyleAttributeName : 0]
//        let buttonTitleStr = NSMutableAttributedString(string: btnRequest.currentTitle!, attributes:attrs)
//        btnRequest.setAttributedTitle(buttonTitleStr, for: UIControlState())
        
        btnFriend.setTitleColor(UIColor.lightGray , for: .normal )
        btnSuggestion.setTitleColor(UIColor.lightGray , for: .normal)
        btnRequest.setTitleColor(UIColor.black , for: .normal)
        
        btnRequest.tintColor = UIColor.black
        btnSuggestion.tintColor = UIColor.lightGray
        btnFriend.tintColor = UIColor.lightGray
        
       
        
        typeFriend=1;
        slectedTAB=1
        self.arrayRequest.removeAllObjects()
        offsetfriendreque=1
        RequestList()
        
    }
    
    
    @IBAction func btnSuggestionClicked(_ sender: AnyObject) {
        
        dismissAllKeyboard()
        
        if searchBarFriends.text?.characters.count > 0 {
            searchBarFriends.text = ""
        }
        labelFriend?.isHidden = true
        labelRequest?.isHidden = true
        labelSuggestion?.isHidden = false
        
        btnFriend.setTitleColor(UIColor.lightGray , for: .normal )
        btnSuggestion.setTitleColor(UIColor.black , for: .normal)
        btnRequest.setTitleColor(UIColor.lightGray , for: .normal)
        
        btnRequest.tintColor = UIColor.lightGray
        btnSuggestion.tintColor = UIColor.black
        btnFriend.tintColor = UIColor.lightGray
        
//        let btnFriendTitle = NSMutableAttributedString(string: btnFriend.currentTitle!)
//        btnFriend.setAttributedTitle(btnFriendTitle, for: UIControlState())
//        let btnRequestTitle = NSMutableAttributedString(string: btnRequest.currentTitle!)
//        btnRequest.setAttributedTitle(btnRequestTitle, for: UIControlState())
//        let attrs = [NSUnderlineStyleAttributeName : 0]
//        let buttonTitleStr = NSMutableAttributedString(string:btnSuggestion.currentTitle!, attributes:attrs)
//        btnSuggestion.setAttributedTitle(buttonTitleStr, for: UIControlState())
//        

        self.arraySearchResult.removeAllObjects()
        offsetsr=1
        typeFriend=2;
        slectedTAB=2
        
        SuggestedList()
    }
    
    @IBAction func btnSearchBottomClicked(_ sender: AnyObject){
        if(_currentPopUP == PopupType.invite){
            
            viewShareOption.isHidden = true
            if btnInvite.tag == 0
            {
                btnInvite.setTitleColor(colors.kLightgrey110, for: UIControlState())
                btnInvite.tag = 1
            } else if btnInvite.tag == 1
            {
                btnInvite.setTitleColor(UIColor.white, for: UIControlState())
                btnInvite.tag = 0
            }
            if(_currentInvite == InviteType.fbInvite)
            {
                self.btnfbInvitationClicked()
            }
            else if(_currentInvite == InviteType.twInvite)
            {
                self.btnTwInvitationClicked()
            }
            else if(_currentInvite == InviteType.cnInvite)
            {
                CNContactStore().requestAccess(for: .contacts) {granted, error in
                    if granted {
                        DispatchQueue.main.async {
                            JContactStore.sharedContact().fetchContactEmailswithblock({ (dict:[AnyHashable: Any]!) in
                                let passArray = NSMutableArray()
                                if let temp : NSMutableArray = (dict as NSDictionary).value(forKey: "contactEmail") as? NSMutableArray
                                {
                                    
                                    for i in 0 ..< temp.count
                                    {
                                        let parameterss = NSMutableDictionary()
                                        parameterss.setValue(temp.object(at: i), forKey: "email_id")
                                        passArray.add(parameterss)
                                    }
                                    
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                                        let jsonTextContact = NSString(data: jsonData,
                                            encoding: String.Encoding.ascii.rawValue)!
                                        print("JSON string = \(self.theJSONTextcn)")
                                        self.invateFromContacts(jsonTextContact)
                                        
                                    } catch {
                                        print(error)
                                        mainInstance.ShowAlert("Alert", msg: error as! String as NSString )
                                        
                                        
                                    }
                                }
                            })
                        }
                    } else {
                        let alertHide = UIAlertController(title: "Contacts Access Denied", message:"You must allow contacts access in Settings", preferredStyle: .alert)
                        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                            (alert: UIAlertAction!) -> Void in
                            
                        })
                        let Setting = UIAlertAction(title: "Settings", style: .default, handler: {
                            (alert: UIAlertAction!) -> Void in
                            let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                            if let url = settingsUrl {
                                UIApplication.shared.openURL(url)
                            }
                            
                        })
                        alertHide.addAction(Cancel)
                        alertHide.addAction(Setting)
                        self.present(alertHide, animated: true, completion: nil)
                    }
                }
                
            } else {
                
                self.dismissAllKeyboard()
                mainInstance.ShowAlert("Alert", msg: "Please select any one of the option!")
            }
        }else{
            if btnFinder.tag == 0 {
                btnFinder.setTitleColor(colors.kLightgrey110, for: UIControlState())
                btnFinder.tag = 1
            } else if btnFinder.tag == 1 {
                btnFinder.setTitleColor(UIColor.white, for: UIControlState())
                btnFinder.tag = 0
            }
            self.viewShareOption.isHidden = true
            if(autoFiderCheckArray.contains("Fb")) || (autoFiderCheckArray.contains("Tw")) || (autoFiderCheckArray.contains("Ig")) || (autoFiderCheckArray.contains("Cn")) {
                
                arraySearchResult = NSMutableArray()
                self.syncWithServer()
            }
        }
    }
    
    func invateFromContacts(_ jsonText:NSString) {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        
        parameterss.setValue(jsonText, forKey: "contactfriends")
        parameterss.setValue(usr.userId, forKey: "uid")
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Inviting  Friends", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.InviteByContact(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: (dic?.object(forKey: "msg")) as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                // mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    @IBAction func hidekeyboardClicked(_ sender: AnyObject) {
        dismissAllKeyboard()
    }
    
    // MARK: FBSDKAppInviteDialogDelegate methods
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("did failed with error : \(error)")
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        print("result")
    }
    
    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if typeFriend == TypeListFriend.typeFriend.rawValue
        {
            return arrayFriendList.count
        }
        else if typeFriend == TypeListFriend.typerequest.rawValue
        {
            return arrayRequest.count
        }
        else if typeFriend == TypeListFriend.typesearch.rawValue
        {
            return arraySearchResult.count
        }
        else if typeFriend == TypeListFriend.typesuggestion.rawValue
        {
            return arraySuggestion.count
        }
        
        return 0;
        
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        
        
        indexPatH = indexPath.row
        
        if typeFriend==TypeListFriend.typeFriend.rawValue {
            

            
            let CELL_ID = "suggestedCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! suggestedCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            
            let strimgname:String?=(self.arrayFriendList.object(at: indexPath.row) as AnyObject).value(forKey: "photo")! as? String
            cell.lblname.text = "\((arrayFriendList.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  + " \((arrayFriendList.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            cell.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
            })
            //cell.imgUser.sd_setImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"))
            cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height / 2
            cell.imgUser.layer.masksToBounds = true
            cell.imgUser.layer.masksToBounds = true
            cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            cell.btnAdd.addTarget(self, action: #selector(FriendsVC.btnAddFriendClicked(_:)), for: .touchUpInside)
            cell.btnAdd.tag=indexPath.row;
            cell.btnMsg.addTarget(self, action: #selector(FriendsVC.btnMsgClicked(_:)), for: .touchUpInside)
            cell.btnMsg.tag=indexPath.row;

            
            cell.lblRequest.isHidden=true;
            
            cell.btnAdd.isHidden = true
            cell.btnMsg.isHidden = false
            //proPic.layer.cornerRadius = proPic.frame.size.height / 2
            //proPic.layer.masksToBounds = true
            return cell
        }
        else if typeFriend==TypeListFriend.typesuggestion.rawValue
        {
            
            
            
            let CELL_ID = "suggestedCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! suggestedCell!
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            
            let strimgname:String?=(self.arraySuggestion.object(at: indexPath.row) as AnyObject).value(forKey: "photo")! as? String
            
            cell?.lblname.text = "\((arraySuggestion.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  + " \((arraySuggestion.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            
            cell?.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            
            cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            cell?.imgUser.layer.cornerRadius = (cell?.imgUser.frame.size.height)! / 2
            cell?.imgUser.layer.masksToBounds = true
            cell?.imgUser.layer.masksToBounds = true
            cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            
            cell?.btnAdd.addTarget(self, action: #selector(FriendsVC.btnAddFriendClicked(_:)), for: .touchUpInside)
            cell?.btnAdd.tag=indexPath.row;
            cell?.btnMsg.addTarget(self, action: #selector(FriendsVC.btnMsgClicked(_:)), for: .touchUpInside)
            cell?.btnMsg.tag=indexPath.row;
            cell?.lblRequest.isHidden=true;
            cell?.btnAdd.isHidden=false;
            cell?.btnMsg.isHidden = true
            
            return cell!
        }
        else if typeFriend==TypeListFriend.typesearch.rawValue
        {
            
            let CELL_ID = "suggestedCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! suggestedCell!
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            if self.arraySearchResult.count == 0 {
                return cell!
            }
            let strimgname:String?=(self.arraySearchResult.object(at: indexPath.row) as AnyObject).value(forKey: "photo")! as? String
            
            cell?.lblname.text = "\((arraySearchResult.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  + " \((arraySearchResult.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            
            
            cell?.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            cell?.imgUser.layer.cornerRadius = (cell?.imgUser.frame.size.height)! / 2
            cell?.imgUser.layer.masksToBounds = true
            cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            
            cell?.btnAdd.addTarget(self, action: #selector(FriendsVC.btnAddFriendClicked(_:)), for: .touchUpInside)
            cell?.btnAdd.tag=indexPath.row;
            cell?.btnMsg.addTarget(self, action: #selector(FriendsVC.btnMsgClicked(_:)), for: .touchUpInside)
            cell?.btnMsg.tag=indexPath.row;
            
            cell?.btnMsg.isHidden = false
            
            if let isFrind: Int  = ((self.arraySearchResult.object(at: indexPath.row) as AnyObject).value(forKey: "isfriend")! as? Int)! {
                
                if let isSent: Int  = Int(String(describing: ((self.arraySearchResult.object(at: indexPath.row)) as AnyObject).value(forKey: "issent")!))!
                {
                    if isFrind == 0 && isSent == 0
                    {
                        cell?.btnAdd.isHidden = false;
                        cell?.lblRequest.isHidden = true;
                        cell?.btnMsg.isHidden = true
                    }
                    else if isFrind == 1 && isSent == 0
                    {
                        cell?.btnAdd.isHidden=true;
                        cell?.lblRequest.isHidden=true;
                        cell?.btnMsg.isHidden = false
                    }
                    else
                    {
                        cell?.btnAdd.isHidden = true;
                        cell?.lblRequest.isHidden = true;
                        cell?.btnMsg.isHidden = true
                    }
                }
            }
            return cell!
        }
            
        else
        {
            
            let CELL_ID = "RequestCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! RequestCell!
            cell?.selectionStyle = .none
            cell?.backgroundColor = UIColor.clear
            let strimgname:String?=(self.arrayRequest.object(at: indexPath.row) as AnyObject).value(forKey: "photo")! as? String
            
            cell?.lblname.text = "\((arrayRequest.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  + " \((arrayRequest.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            
            
            cell?.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            
            cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            cell?.imgUser.layer.cornerRadius = (cell?.imgUser.frame.size.height)! / 2
            cell?.imgUser.layer.masksToBounds = true
            
            cell?.imgUser.layer.masksToBounds = true
            cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
            cell?.btnaccept.addTarget(self, action: #selector(FriendsVC.btnAcceptClicked(_:)), for: .touchUpInside)
            cell?.btnaccept.tag=indexPath.row
            
            cell?.btnreject.addTarget(self, action: #selector(FriendsVC.btnRejectClicked(_:)), for: .touchUpInside)
            cell?.btnreject.tag=indexPath.row
            
            return cell!
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        dismissAllKeyboard()
        
        
        if( indexPatH == self.arrayTemp.count-1 && self.arrayTemp.count>9 && self.totalList > self.arrayTemp.count) {
            if arrayTemp.count < totalList {
                offsetsr = offsetsr + 1
                
            }
        }
        
        
        guard let visibleIndexPaths = tblFriends.indexPathsForVisibleRows else { return }
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
            setLoginViewForGuest()
        }else {
            guard tblFriends.numberOfRows(inSection: 0) > 0 else { return }
            tblFriends.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    {
        
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
            
            
        }else if shareFlag {
            
        } else {
        
        var dic :NSMutableDictionary?
        
        let mgrfriend = FriendsManager.friendsManager
        mgrfriend.clearManager()
        
        if typeFriend==TypeListFriend.typesuggestion.rawValue
        {
            let mutDict = NSMutableDictionary(dictionary: self.arraySuggestion.object(at: indexPath.row) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary
        }
        else if typeFriend==TypeListFriend.typeFriend.rawValue
        {
            let mutDict = NSMutableDictionary(dictionary: self.arrayFriendList.object(at: indexPath.row) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary
        }
            
        else if typeFriend==TypeListFriend.typesearch.rawValue
        {
            let mutDict = NSMutableDictionary(dictionary: self.arraySearchResult.object(at: indexPath.row) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary
        }
        else
        {
            let mutDict = NSMutableDictionary(dictionary: self.arrayRequest.object(at: indexPath.row) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary
        }
        
        if isForTransferMoney {
//            let VC1 = (objAppDelegate.stWallet.instantiateViewController(withIdentifier: "TransferMoneyVC")) as! TransferMoneyVC
//            VC1.toUserId = String(dic!.value(forKey: "userid") as! Int)
//            VC1.toCustName = dic!.value(forKey: "username") as! String
            self.delegate?.SelectUserForTransferMoneyDelegate(userId: String(dic!.value(forKey: "userid") as! Int), userName: dic!.value(forKey: "username") as! String)
            self.navigationController?.popViewController(animated: true)
        } else {
        
        if let uID: Int  = dic!.value(forKey: "userid") as? Int
        {
            
            mgrfriend.FriendID = "\(uID)"
            mgrfriend.FriendName = "\(dic!.value(forKey: "fname") as! String) "  +  " \(dic!.value(forKey: "lname") as! String)"
            mgrfriend.FriendPhoto = "\(dic!.value(forKey: "photo") as! String)"
            mgrfriend.FUsername = "\(dic!.value(forKey: "username") as! String)"
            
            if let fID: Int  = (dic!.value(forKey: "isfriend")! as? Int)! {
                mgrfriend.isFriend = "\(fID)"
                
                if fID == 1 {
                    
                    if let fconnectionID  = dic?.value(forKey: "friendshipid") as? Int {
                        mgrfriend.friendConnectionID = "\(fconnectionID)"
                    }
                }
            }
        }
        let VC1 = (objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
        VC1.delegate = self
        self.navigationController?.pushViewController(VC1, animated: true)
        }
    }
    }
    
    
    
    func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
    }
    
    
    
    //MARK: - tableview delgate datasource methods -
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        
        dismissAllKeyboard()
    }
   
    
    
    //MARK: - CustomButton Methods
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        dismissAllKeyboard()
    }
    func hideKeyboard()
    {
        
        dismissAllKeyboard()
    }
    
    func btnMsgClicked(_ sender: UIButton) {
        
        dismissAllKeyboard()
        
        let friendMgr = FriendsManager.friendsManager
        friendMgr.clearManager()
        var dict: NSMutableDictionary?
        
        if typeFriend == TypeListFriend.typeFriend.rawValue {
            
            let mutDict = NSMutableDictionary(dictionary: self.arrayFriendList.object(at: sender.tag) as! [AnyHashable: Any])
            dict = mutDict.mutableCopy() as? NSMutableDictionary;
        } else {
            
            let mutDict = NSMutableDictionary(dictionary: self.arraySearchResult.object(at: sender.tag) as! [AnyHashable: Any])
            dict = mutDict.mutableCopy() as? NSMutableDictionary;
        }
        print(dict!)
        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.otherID = (dict!.value(forKey: "userid") as AnyObject).intValue
        chatVC.userName = dict!.value(forKey: "username") as? String
        
        if !(chatVC.userName?.characters.count > 0) {
            chatVC.userName = "\((dict!.value(forKey: "fname") as? String)!) \((dict!.value(forKey: "lname") as? String)!)"
        }
        if shareFlag {
            shareFlag = false
            chatVC.shareURL = shareUrl
            chatVC.ShareFlag = true
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    func btnAddFriendClicked(_ sender: UIButton) {
        
        let friendmgr = FriendsManager.friendsManager
        friendmgr.clearManager()
        var dic :NSMutableDictionary?
        
        if typeFriend==TypeListFriend.typesuggestion.rawValue
        {
            let mutDict = NSMutableDictionary(dictionary: self.arraySuggestion.object(at: sender.tag) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;
        }
        else
        {
            let mutDict = NSMutableDictionary(dictionary: self.arraySearchResult.object(at: sender.tag) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;
        }
        
        dic?.setValue(1, forKey: "issent");
        
        if let uID  = dic?.value(forKey: "userid") as? Int
        {
            friendmgr.FriendID = "\(uID)"
        }
        
        if typeFriend == TypeListFriend.typesuggestion.rawValue
        {
            self.arraySuggestion.removeObject(at: sender.tag)
        }
        else
        {
            
            self.arraySearchResult.replaceObject(at: sender.tag, with: dic!)
            
            
        }
        
        tblFriends.reloadData()
        dismissAllKeyboard()

        friendmgr.Addfriend()
        
        
    }
    func btnAcceptClicked(_ sender: UIButton) {
        
        dismissAllKeyboard()
        
        let friendmgr = FriendsManager.friendsManager
        friendmgr.clearManager()
        if let uID: Int  = (self.arrayRequest.object(at: sender.tag) as AnyObject).value(forKey: "userid") as? Int
        {
            friendmgr.FriendID = "\(uID)"
        }
        if let fID: Int  = (self.arrayRequest.object(at: sender.tag) as AnyObject).value(forKey: "friendshipid") as? Int
        {
            friendmgr.friendConnectionID = "\(fID)"
        }
        friendmgr.tagID=(sender.tag)
        AcceptRequest()
        
        
    }
    func btnRejectClicked(_ sender: UIButton) {
        
        dismissAllKeyboard()
        
        let friendmgr = FriendsManager.friendsManager
        friendmgr.clearManager()
        if let uID: Int  = (self.arrayRequest.object(at: sender.tag) as AnyObject).value(forKey: "userid")! as? Int
        {
            friendmgr.FriendID = "\(uID)"
        }
        if let fID: Int  = (self.arrayRequest.object(at: sender.tag) as AnyObject).value(forKey: "friendshipid") as? Int
        {
            friendmgr.friendConnectionID = "\(fID)"
        }
        friendmgr.tagID=(sender.tag)
        rejectRequest()
    }
    
    //MARK: - SearchVIew delgate datasource methods -
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) // called when keyboard search button pressed
    {
        
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        
        strKeyword = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        var strMsg = strKeyword.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if strMsg.characters.last == "\n"
        {
            strMsg = String(strMsg.characters.dropLast())
        }
        strKeyword = strMsg
        
        if strMsg.characters.count == 0
        {
            btnSearchFilterOutlet.isHidden = false
            typeFriend=slectedTAB
            if typeFriend == 0 {
                let attrs = [NSUnderlineStyleAttributeName : 0]
                let buttonTitleStr = NSMutableAttributedString(string:btnFriend.currentTitle!, attributes:attrs)
                btnFriend.setAttributedTitle(buttonTitleStr, for: UIControlState())
            } else if typeFriend == 1 {
                let attrs = [NSUnderlineStyleAttributeName : 0]
                let buttonTitleStr = NSMutableAttributedString(string:btnRequest.currentTitle!, attributes:attrs)
                btnRequest.setAttributedTitle(buttonTitleStr, for: UIControlState())
            } else if typeFriend == 2 {
                let attrs = [NSUnderlineStyleAttributeName : 0]
                let buttonTitleStr = NSMutableAttributedString(string:btnSuggestion.currentTitle!, attributes:attrs)
                btnSuggestion.setAttributedTitle(buttonTitleStr, for: UIControlState())
            }
            tblFriends.reloadData()
        }
        else
        {
            btnSearchFilterOutlet.isHidden = true
            arraySearchResult.removeAllObjects()
            SearchFriend()
        }
    }
    
    
    
    // MARK: --WebService Method
    
    func SearchFriend()
    {
        typeFriend=3;
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offsetsr, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(strKeyword, forKey: "string")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        print(parameterss)
        
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Users", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.SearchFriendList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            print(dic ?? "")
            if result == APIResult.apiSuccess
            {
                let btnSuggestionTitle = NSMutableAttributedString(string: self.btnSuggestion.currentTitle!)
                self.btnSuggestion.setAttributedTitle(btnSuggestionTitle, for: UIControlState())
                let btnFriendTitle = NSMutableAttributedString(string: self.btnFriend.currentTitle!)
                self.btnFriend.setAttributedTitle(btnFriendTitle, for: UIControlState())
                let btnRequestTitle = NSMutableAttributedString(string: self.btnRequest.currentTitle!)
                self.btnRequest.setAttributedTitle(btnRequestTitle, for: UIControlState())
                
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalSRCount = countShop
                    self.totalList = countShop
                }
                
                print(dic ?? "")
                self.arraySearchResult.removeAllObjects()
                self.arraySearchResult = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray).mutableCopy() as! NSMutableArray
              
                self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic ?? "")
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.tblFriends.reloadData()
                self.dismissAllKeyboard()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: --action delgate Method
    
    func actionOnData()
    {
        
        if typeFriend==TypeListFriend.typesuggestion.rawValue
        {
            
            self.SuggestedList()
            
        }
        else if typeFriend==TypeListFriend.typeFriend.rawValue
        {
            self.FriendList()
            
        }
            
        else if typeFriend==TypeListFriend.typesearch.rawValue {
            self.SearchFriend()
        }
        else {
            
            self.RequestList()
        }
    }
    // MARK: --suggested webservice Method
    
    
    func SuggestedList()
    {
        
        typeFriend=2;
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offsetsugge, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(objAppDelegate.strLat, forKey: "lat")
        parameterss.setValue(objAppDelegate.strLon, forKey: "lon")
        parameterss.setValue(usr.userId, forKey: "uid")
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Suggested Friends", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.suggestedFriendList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            self.tblFriends.emptyDataSetDelegate = self
            self.tblFriends.emptyDataSetSource = self
            if result == APIResult.apiSuccess  {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int  {
                    self.totalSuggesCount = countShop
                    self.totalList = countShop
                }
                
                if self.offsetsugge == 1 {
                    self.arraySuggestion.removeAllObjects()
                    self.arrayTemp.removeAllObjects()
                    self.arraySuggestion = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as? NSArray)!)
                    self.arrayTemp = self.arraySuggestion
                    
                    
                } else {
                    self.arraySuggestion.addObjects(from: NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as? NSArray)!) as! [Any])
                    self.arrayTemp = self.arraySuggestion
                }
                self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
                
                
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                
                
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: --FriendList webservice Method
    
    func FriendList()
    {
        typeFriend=0;
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offsetFlist, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        print(parameterss)
        
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Friends", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.FriendList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            print(dic)
            
            if result == APIResult.apiSuccess
            {
                
//                let attrs = [NSUnderlineStyleAttributeName : 0]
//                let buttonTitleStr = NSMutableAttributedString(string: self.btnFriend.currentTitle!, attributes:attrs)
//                self.btnFriend.setAttributedTitle(buttonTitleStr, for: UIControlState())
                
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalfriends = countShop
                    self.totalList = countShop
                }
                
                if self.offsetFlist == 1
                {
                    self.arrayFriendList.removeAllObjects()
                    self.arrayTemp.removeAllObjects()
                    self.arrayFriendList = NSMutableArray(array: (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray)
                    self.arrayTemp = self.arrayFriendList
                }
                else
                {
                    self.arrayFriendList.addObjects(from: NSMutableArray(array: (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray) as! [Any])
                    self.arrayTemp = self.arrayFriendList
                }
                    self.typeFriend = 0
                    self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
            } else {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    
    
    func RequestList() {
        
        typeFriend=1;
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offsetfriendreque, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        if arrayRequest.count == 0 {
            SVProgressHUD.show(withStatus: "Fetching Requests", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.FRequestList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            self.tblFriends.emptyDataSetDelegate = self
            self.tblFriends.emptyDataSetSource = self
            if result == APIResult.apiSuccess {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalrequests") as? Int {
                    self.totalrequeCount = countShop
                    self.totalList = countShop
                }
                
                if self.offsetfriendreque == 1 && self.totalrequeCount > 0 {
                    self.arrayRequest.removeAllObjects()
                    self.arrayTemp.removeAllObjects()
                    self.arrayRequest = NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as? NSArray)!)
                    self.arrayTemp = self.arrayRequest
                } else {
                    self.arrayRequest.addObjects(from: NSMutableArray(array: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as? NSArray)!) as! [Any])
                    self.arrayTemp = self.arrayRequest
                }
                self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError  {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
            } else {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: - get Social Friends Webservice
    
    func btnfbInvitationClicked() {
        
        let fbSDKAppInviteDialog = FBSDKAppInviteDialog()
        fbSDKAppInviteDialog.delegate = self
        
        // Facebook Invite Integration
        if fbSDKAppInviteDialog.canShow() {
            
            let content = FBSDKAppInviteContent()
            content.appLinkURL = URL(string: "https://fb.me/1404595076281105")!
            
            //optionally set previewImageURL
            
//            content.appInvitePreviewImageURL = NSURL(string: "")!
            
            
            FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
        }
        
        // Facebook Post Integration
//        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)
//        {
//            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
//            fbShare.setInitialText("")
//            
//            self.presentViewController(fbShare, animated: true, completion: nil)
//            
//        } else {
//            let alert = UIAlertController(title: "Accounts", message: "Please login to a facebook account to invite.", preferredStyle: UIAlertControllerStyle.Alert)
//            
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
    }
    
    func btnTwInvitationClicked(){
        
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let twitter:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitter.setInitialText("")
            self.present(twitter, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func syncWithServer()  {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        typeFriend=3
        parameterss.setValue(self.theJSONTextIg, forKey: "googlefriends")
        parameterss.setValue(self.theJSONTextFb, forKey: "fbfriends")
        parameterss.setValue(self.theJSONTextTW, forKey: "twitterfriends")
        parameterss.setValue(self.theJSONTextcn, forKey: "contactfriends")
        parameterss.setValue(usr.userId, forKey: "uid")
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Friends", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getFinderFriendList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalSRCount = countShop
                    self.totalList = countShop
                }
                
                if self.offsetsr == 1
                {
                    self.arraySearchResult.removeAllObjects()
                    
                    let fbfriends = NSMutableArray(array:((dic!.value(forKey: "result")! as AnyObject).value(forKey: "fbfriends")!) as! [AnyObject] )
                    let emailfriends = NSMutableArray(array:((dic!.value(forKey: "result")! as AnyObject).value(forKey: "emailfriends")!) as! [AnyObject] )
                    let googlefriends = NSMutableArray(array:((dic!.value(forKey: "result")! as AnyObject).value(forKey: "googlefriends")!) as! [AnyObject] )
                    let twitterfriends = NSMutableArray(array:((dic!.value(forKey: "result")! as AnyObject).value(forKey: "twitterfriends")!) as! [AnyObject] )
                    self.arraySearchResult .addObjects(from: fbfriends as [AnyObject])
                    self.arraySearchResult .addObjects(from: emailfriends as [AnyObject])
                    self.arraySearchResult .addObjects(from: googlefriends as [AnyObject])
                    self.arraySearchResult .addObjects(from: twitterfriends as [AnyObject])
                    
                    self.viewShareOption.isHidden = true
                }
                else
                {
                    //                    self.arraySearchResult.addObjectsFromArray((dic!.valueForKey("result")!.valueForKey("friends")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
            }
            else if result == APIResult.apiError
            {
                self.arraySearchResult.removeAllObjects()
                self.tblFriends.reloadData()
                
                print(dic)
                // mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func GetTWFriendList()
    {
        typeFriend=3;
        offsetsr=1
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        
        parameterss.setValue(self.offsetfriendreque, forKey: "offset")
        parameterss.setValue(self.theJSONTextTW, forKey: "twitterfriends")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching  Friends", maskType: SVProgressHUDMaskType.clear)
        }
        
        mgr.getTwFriendList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalSRCount = countShop
                    self.totalList = countShop
                }
                
                if self.offsetsr == 1
                {
                    self.arraySearchResult.removeAllObjects()
                    self.arrayTemp.removeAllObjects()
                    self.arraySearchResult = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as? NSMutableArray)!
                    self.arrayTemp = self.arraySearchResult
                    
                }
                else
                {
                    self.arraySearchResult.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                    self.arrayTemp = self.arraySearchResult
                }
                self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
            }
            else if result == APIResult.apiError
            {
                self.arraySearchResult.removeAllObjects()
                self.tblFriends.reloadData()
                print(dic)
                // mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    func GetFbFriendList() {
        
        typeFriend=3;
        offsetsr=1
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        
        parameterss.setValue(self.offsetfriendreque, forKey: "offset")
        parameterss.setValue(self.theJSONTextFb, forKey: "fbfriends")
        
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching Facebook Friends", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.getFbFriendList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalSRCount = countShop
                    self.totalList = countShop
                }
                
                if self.offsetsr == 1
                {
                    self.arraySearchResult.removeAllObjects()
                    self.arraySearchResult = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as? NSMutableArray)!
                }
                else
                {
                    self.arraySearchResult.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblFriends.reloadData()
                SVProgressHUD.dismiss()
            } else if result == APIResult.apiError {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
            } else {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    // MARK: - Add Friend Webservice
    func AcceptRequest()
    {
        
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        parameterss.setValue(mgrfriend.friendConnectionID, forKey: "friendshipid")
        
        SVProgressHUD.show()
        
        mgr.acceptFriendRe(parameterss, successClosure: { (dic, result) -> Void in
            
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.arrayRequest.removeObject(at: mgrfriend.tagID)
                self.tblFriends.reloadData()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func rejectRequest()
    {
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        parameterss.setValue(mgrfriend.friendConnectionID, forKey: "friendshipid")
        
        mgr.rejectFriendRe(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.arrayRequest.removeObject(at: mgrfriend.tagID)
                self.tblFriends.reloadData()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
            }
            else
            {
                SVProgressHUD.dismiss()
                self.dismissAllKeyboard()
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    //MARK: - DZNEmptyDataSetSource Methods -
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


