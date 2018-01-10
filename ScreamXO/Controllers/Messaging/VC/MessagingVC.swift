//
//  MessagingVC.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 12/09/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import TwitterKit

class MessagingVC: UIViewController, CAPSPageMenuDelegate, UISearchBarDelegate {
    
    // MARK: Properties
    //    @IBOutlet var btnBackTop: NSLayoutConstraint!
    @IBOutlet var searchBarTop: NSLayoutConstraint!
    
    var pageMenu: CAPSPageMenu?
    let controller1 = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "FriendsMsgVC") as! FriendsMsgVC
    let controller2 = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "BuyerSellerMsgVC") as! BuyerSellerMsgVC
    let controller3 = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "NotificationsVC") as! NotificationsVC
    
    var gestures = [UIGestureRecognizer]()
    var isSwipeVC = false
    var isSetup = false
    var isTrackNotify = false
    var friends = [SearchResult]()
    var searchOffset = 1
    var searchLimit = 10
    var searchTotalUser = 0
    var search_text = ""
    var btnFwd: UIButton!
    
    // MARK: IBOutlets
    @IBOutlet var tblSearchFriend: UITableView!
    @IBOutlet var btnBack: UIButton!
    @IBOutlet var searchBarChat: UISearchBar!
    @IBOutlet var btnSearchFilterOutlet: UIButton!
    
    // MARK: IBOutlets & Properties FriendsVC finder & inviter implemetation
    
    var arraySearchResult = NSMutableArray ()
    var totalSRCount:Int = 0
    var offsetsr:Int = 1
    var offsetfriendreque:Int = 1
    var limit:Int = 10
    
    
    enum TypeListFriend : NSInteger
    {
        case typeFriend = 0,typerequest,typesuggestion,typesearch,typeFB,typeTW
    }
    enum TypeSocial : NSInteger
    {
        case typeFb = 0,typeTw
    }
    
    @IBOutlet var stackViewControlHeight: NSLayoutConstraint!
    
    var typeSocial :Int!
    var typeFriend :Int!
    var typeFriendPrevios :Int!
    var dataSource = [AnyObject]()
    
    @IBOutlet var viewControl: UIView!
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
    
    var theJSONTextFb :NSString = ""
    var theJSONTextTW :NSString = ""
    var theJSONTextIg :NSString = ""
    var theJSONTextcn :NSString = ""
    
    // MARK: UIViewControllerOverridenMethods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBarChat.backgroundColor = UIColor.white
        searchBarChat.barTintColor = UIColor.clear
        searchBarChat.backgroundImage = UIImage()
        searchBarChat.setImage(UIImage(named: "SearchIcon"), for: .search, state: .normal)
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
        initUI()
        typeFriend = 0
        
        searchBarChat.delegate = self
        
        if isSwipeVC {
            btnFwd = UIButton()
            btnBack.isHidden = true
            btnFwd.frame = btnBack.frame
            btnFwd.setImage(UIImage(named: "fwdi"), for: UIControlState())
            btnFwd.addTarget(self, action: #selector(self.btnFwdClicked), for: .touchUpInside)
            self.view.addSubview(btnFwd)
            searchBarTop.constant = 20.0
        }
        isSetup = true
        tblSearchFriend.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
           NotificationCenter.default.addObserver(self, selector: #selector(self.hideKeyBoardNew(_:)), name: NSNotification.Name(rawValue: "hideKeyBoardNew"), object: nil)
        if isSetup == true {
            isSetup = false
            self.setupMenu()
            self.view.bringSubview(toFront: tblSearchFriend)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if isSwipeVC {
            
            searchBarChat.frame = CGRect(x: self.view.frame.origin.x + 10.0 + btnSearchFilterOutlet.frame.width + 8.0, y: searchBarTop.constant, width: self.view.frame.width - btnFwd.frame.width - self.btnSearchFilterOutlet.frame.width - 28.0, height: searchBarChat.frame.height)
            
            btnSearchFilterOutlet.frame.origin.x = self.view.frame.origin.x + 10.0
            btnSearchFilterOutlet.frame.origin.y = self.btnFwd.frame.origin.y
            
            btnFwd.frame = CGRect(x: self.view.frame.width - btnBack.frame.height - 8.0, y: self.btnFwd.frame.origin.y, width: btnBack.frame.height, height: btnBack.frame.height)
            
        }
    }

    
    
    
    func hideKeyBoardNew(_ sender:AnyObject)  {
        self.view.endEditing(true)
    }
    
    // MARK: IBActions & Methods for FriendsVC finder & inviter implemetation
    
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        dismissAllKeyboard()
    }
    
    func searchBarTextDidEndEditing(aSearchBar: UISearchBar) {
        searchBarChat.resignFirstResponder()
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
            
        }else{
            _currentPopUP = nil
            self.viewShareOption.isHidden = true
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
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
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
    }
    
    @IBAction func btnFacebbokCLicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
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
                    _ = fbRequest?.start(completionHandler: { (connection : FBSDKGraphRequestConnection!, result : Any!, error : Error!) -> Void in
                        
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
                                self.typeFriend = 3;
                                self.arraySearchResult.removeAllObjects()
                                self.tblSearchFriend.reloadData()
                            }
                            
                        } else {
                            
                            print("Error Getting Friends \(error)");
                            
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func btnContactClicked(_ sender:UIButton){
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
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
    }
    
    @IBAction func btnInstagramClicked(_ sender: UIButton)  {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
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
    
    
    func  setLoginViewForGuest() {
        let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
        objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
        objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
    }
    
    @IBAction func btnTwitterClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
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
                                    print("Error: \(String(describing: connectionError))")
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
    }
    
    
    @IBAction func btnFbRadioClicked(_ sender: AnyObject){
        
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
            _currentInvite = InviteType.fbInvite
            self.radioSelection()
        }
    }
    @IBAction func btnTwRadioClicked(_ sender: AnyObject){
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
            _currentInvite = InviteType.twInvite
            self.radioSelection()
        }
    }
    @IBAction func btnCnRadioClicked(_ sender: AnyObject){
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
            _currentInvite = InviteType.cnInvite
            self.radioSelection()
        }
    }
    
    @IBAction func btnSearchBottomClicked(_ sender: AnyObject){
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
            tblSearchFriend.isHidden = false
            
            if btnSearchFilterOutlet.tag == 1 {
                
                hideMachineView()
                tblSearchFriend.isHidden = false
            }
            
            if(_currentPopUP == PopupType.invite) {
                self.viewShareOption.isHidden = true
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
    }
    
    func invateFromContacts(_ jsonText:NSString)  {
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
                print(dic!)
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
    
    // MARK: - get Social Friends Webservice_ FriendsVC finder & inviter implemetation
    
    
    func btnMachineMessageClicked(_ sender: UIButton) {
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            
        }
        dismissAllKeyboard()
        
        let friendMgr = FriendsManager.friendsManager
        friendMgr.clearManager()
        var dict: NSMutableDictionary?
        
        if typeFriend == TypeListFriend.typesearch.rawValue {
            
            let mutDict = NSMutableDictionary(dictionary: self.arraySearchResult.object(at: sender.tag) as! [AnyHashable: Any])
            dict = mutDict.mutableCopy() as? NSMutableDictionary;
        }
        print(dict!)
        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatVC.otherID = (dict!.value(forKey: "userid") as AnyObject).intValue
        chatVC.userName = dict!.value(forKey: "username") as? String
        
        if !((chatVC.userName?.characters.count)! > 0) {
            chatVC.userName = "\((dict!.value(forKey: "fname") as? String)!) \((dict!.value(forKey: "lname") as? String)!)"
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    func btnAddFriendClicked(_ sender: UIButton) {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
        let friendmgr = FriendsManager.friendsManager
        friendmgr.clearManager()
        var dic :NSMutableDictionary?
        
        if typeFriend==TypeListFriend.typesearch.rawValue
        {
            let mutDict = NSMutableDictionary(dictionary: self.arraySearchResult.object(at: sender.tag) as! [AnyHashable: Any])
            dic = mutDict.mutableCopy() as? NSMutableDictionary;
        }
        
        dic?.setValue(1, forKey: "isfriend");
        
        if let uID  = dic?.value(forKey: "userid") as? Int
        {
            friendmgr.FriendID = "\(uID)"
        }
        
        if typeFriend==TypeListFriend.typesearch.rawValue
        {
            self.arraySearchResult.replaceObject(at: sender.tag, with: dic!)
        }
        
        tblSearchFriend.reloadData()
        dismissAllKeyboard()
        
        friendmgr.Addfriend()
        }
    }
    
    func btnfbInvitationClicked() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)
        {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            fbShare.setInitialText("")
            
            self.present(fbShare, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a facebook account to invite.", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
                self.tblSearchFriend.reloadData()
                SVProgressHUD.dismiss()
            }
            else if result == APIResult.apiError
            {
                self.arraySearchResult.removeAllObjects()
                self.tblSearchFriend.reloadData()
                
                print(dic!)
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
                }
                
                if self.offsetsr == 1
                {
                    self.arraySearchResult.removeAllObjects()
                    self.arraySearchResult = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends")) as? NSMutableArray)!
                    
                }
                else
                {
                    self.arraySearchResult.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends")) as! [AnyObject])
                }
                self.tblSearchFriend.reloadData()
                SVProgressHUD.dismiss()
            }
            else if result == APIResult.apiError
            {
                self.arraySearchResult.removeAllObjects()
                self.tblSearchFriend.reloadData()
                print(dic!)
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
    func GetFbFriendList()
    {
        
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
                }
                
                if self.offsetsr == 1
                {
                    self.arraySearchResult.removeAllObjects()
                    self.arraySearchResult = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends")) as? NSMutableArray)!
                }
                else
                {
                    self.arraySearchResult.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblSearchFriend.reloadData()
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic!)
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
    
    func dismissAllKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: IBActions
    @IBAction func btnBack(_ sender: UIButton) {
        self.sideMenuViewController.presentLeftMenuViewController()
    }
    
    func btnFwdClicked()
    {
        if UserManager.userManager.userId == "1"{
            setLoginViewForGuest()
        } else {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "goToPageMiddle"), object: nil)
        }
    }
    
    
    // MARK: UserDefinedFunctions
    
    func setupMenu() {
        var controllerArray : [UIViewController] = []
        
        
        controller1.title = "Pleasure"
        controller1.parentCnt = self
        controllerArray.append(controller1)
        
        controller2.title = "Business"
        controller2.parentCnt = self
        controllerArray.append(controller2)
        
        controller3.title = "Network"
        controller3.parentCnt = self
        controllerArray.append(controller3)
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.clear),
            .viewBackgroundColor(UIColor.clear),
            .selectionIndicatorColor(colors.kLightgrey155),
            .addBottomMenuHairline(false),
            .menuItemFont(UIFont(name: fontsName.KfontproxisemiBold, size: 14.0)!),
            .menuItemSeparatorRoundEdges(true),
            .menuItemSeparatorColor(UIColor.red),
            .menuHeight(50.0),
            .selectionIndicatorHeight(2.0),
            .menuItemWidthBasedOnTitleTextWidth(false),
            .selectedMenuItemLabelColor(UIColor.black),
            .menuItemWidth(self.view.bounds.width / 3)
        ]
        let height = searchBarChat.frame.origin.y + searchBarChat.frame.size.height
        if isSwipeVC {
            
            pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 64, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-64), pageMenuOptions: parameters)
        }
        else
        {
            pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: height, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height-(height)), pageMenuOptions: parameters)
        }
        
        pageMenu?.delegate=self
        self.addChildViewController(pageMenu!)
        self.view.addSubview((pageMenu?.view)!)
        if isTrackNotify == true {
            pageMenu?.moveToPage(2)
        }
    }
    
    @IBAction func btnSearchFilter(_ sender: UIButton)
    {
        self.viewShareOption.isHidden = true
        
        //        mainInstance.ShowAlert("Alert", msg: "Once ScreamXO is released to the public, you can use this to invite friends")
        
        if tblSearchFriend.isHidden == true {
            if btnSearchFilterOutlet.tag == 0  {
                showMachineView()
            } else if btnSearchFilterOutlet.tag == 1 {
                hideMachineView()
            }
        } else {
            hideMachineView()
        }
        
        
    }
    
    
    // MARK: SearchBarDelegate Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)     {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        self.viewShareOption.isHidden = true
        
        if btnSearchFilterOutlet.tag == 1 {
            hideMachineView()
        }
        
        if (searchBar.text?.characters.count)! > 0 {
            tblSearchFriend.isHidden = false
            search_text = searchBar.text!
            searchFriends()
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        if btnSearchFilterOutlet.tag == 1 {
            hideMachineView()
        }
        
        search_text = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if search_text.characters.count != 0 {
            
            tblSearchFriend.isHidden = false
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchFriends), object: nil)
            perform(#selector(searchFriends), with: nil, afterDelay: 0.5)
            
        } else {
            tblSearchFriend.isHidden = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        if searchBar.text != "" {
            
            search_text = ""
            
            if search_text.characters.count != 0  {
                tblSearchFriend.isHidden = false
                searchFriends()
            } else {
                tblSearchFriend.isHidden = true
            }
        }
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchFriends() {
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(searchOffset, forKey: "offset")
        parameterss.setValue(searchLimit, forKey: "limit")
        parameterss.setValue(search_text, forKey: "string")
        parameterss.setValue(usr.userId, forKey: "uid")
        SVProgressHUD.show(withStatus: "Fetching Friends", maskType: SVProgressHUDMaskType.clear)
        mgr.SearchFriendTagging(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                print(dic!)
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int {
                    self.searchTotalUser = countShop
                }
                if self.searchOffset == 1 {
                    self.friends.removeAll()
                    for searchObject in (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray {
                        let json = SearchResult.Populate(searchObject as! NSDictionary)
                        self.friends.append(json)
                    }
                } else {
                    for searchObject in (dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray {
                        let json = SearchResult.Populate(searchObject as! NSDictionary)
                        self.friends.append(json)
                    }
                }
                
                self.tblSearchFriend.reloadData()
                SVProgressHUD.dismiss()
                
            } else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                self.view.endEditing(true)
                
            } else {
                SVProgressHUD.dismiss()
                self.view.endEditing(true)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func showMachineView() {
        
        searchBarChat.text = ""
        searchBarChat.showsCancelButton = false
        searchBarChat.resignFirstResponder()
        
        view.bringSubview(toFront: viewControl)
        view.bringSubview(toFront: viewShareOption)
        viewAutoFinder.isHidden = false
        viewInviteFinder.isHidden = false
        stackViewControlHeight.constant = 51
        btnSearchFilterOutlet.tag = 1
        tblSearchFriend.isHidden = true
    }
    
    func hideMachineView() {
        
        view.sendSubview(toBack: viewControl)
        view.sendSubview(toBack: viewShareOption)
        tblSearchFriend.isHidden = true
        viewAutoFinder.isHidden = true
        viewInviteFinder.isHidden = true
        stackViewControlHeight.constant = 41
        btnSearchFilterOutlet.tag = 0
        
        btnInvite.setTitleColor(UIColor.white, for: UIControlState())
        btnInvite.tag = 0
        
        btnFinder.setTitleColor(UIColor.white, for: UIControlState())
        btnFinder.tag = 0
    }
    
    // MARK: CAPSPageMenuDelegateImpl.
    
    func willMoveToPage(_ controller: UIViewController, index: Int) {
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
    }
    
    func btnMsgClicked(_ sender: AnyObject) {
        if UserManager.userManager.userId == "1"{
        } else {
            setLoginViewForGuest()
        
        let tag = (sender as! UIButton).tag
        let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        chatVC.otherID = friends[tag].userid
        chatVC.userName = friends[tag].username
        if !((chatVC.userName?.characters.count)! > 0) {
            chatVC.userName = "\(friends[tag].fname) \(friends[tag].lname)"
        }
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    }
}
extension MessagingVC: UITableViewDataSource,UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // MARK: number of rows in section for friendVC finder & inviter implementation
        if typeFriend == TypeListFriend.typesearch.rawValue
        {
            return arraySearchResult.count
        }
        return friends.count
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        // MARK: cellForRowAtIndexpath for friendVC finder & inviter implemetation
        
        if typeFriend==TypeListFriend.typesearch.rawValue
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
            
            cell?.btnAdd.addTarget(self, action: #selector(self.btnAddFriendClicked(_:)), for: .touchUpInside)
            cell?.btnAdd.tag = indexPath.row;
            cell?.btnMsg.addTarget(self, action: #selector(self.btnMachineMessageClicked(_:)), for: .touchUpInside)
            cell?.btnMsg.tag = indexPath.row;
            
            cell?.btnMsg.isHidden = false
            
            if let isFrind: Int  = (self.arraySearchResult.object(at: indexPath.row) as AnyObject).value(forKey: "isfriend")! as? Int
            {
                
                if let isSent: Int  = Int(String(describing: (self.arraySearchResult.object(at: indexPath.row) as AnyObject).value(forKey: "issent")!))
                {
                    if isFrind == 0 && isSent == 0
                    {
                        cell?.btnAdd.isHidden = false;
                        cell?.btnMsg.isHidden = true
                    }
                    else if isFrind == 1 && isSent == 0
                    {
                        cell?.btnAdd.isHidden=true;
                        cell?.btnMsg.isHidden = false
                    }
                    else
                    {
                        cell?.btnAdd.isHidden=true;
                        cell?.btnMsg.isHidden = true
                    }
                }
            }
            return cell!
        }
        
        let CELL_ID = "suggestedCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! suggestedCell!
        cell?.selectionStyle = .none
        cell?.btnAdd.isHidden = true
        cell?.lblname.text = friends[indexPath.row].username
        cell?.imgUser.sd_setImage(with: URL(string: friends[indexPath.row].photo), placeholderImage: UIImage(named: "profile"))
        cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        cell?.imgUser.layer.cornerRadius = (cell?.imgUser.frame.size.height)! / 2
        cell?.imgUser.layer.masksToBounds = true
        cell?.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        cell?.btnMsg.addTarget(self, action: #selector(btnMsgClicked(_:)), for: .touchUpInside)
        cell?.btnMsg.tag=indexPath.row;
        if indexPath.row == friends.count-1 && searchTotalUser > friends.count {
            searchOffset = searchOffset + 1
            searchFriends()
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if UserManager.userManager.userId == "1" {
            setLoginViewForGuest()
        } else {
            // MARK: didSelectRowAtIndexPath for FriendVC finder & inviter implemetation
            
            if typeFriend == TypeListFriend.typesearch.rawValue
            {
                var dic :NSMutableDictionary?
                let mgrfriend = FriendsManager.friendsManager
                mgrfriend.clearManager()
                
                let mutDict = NSMutableDictionary(dictionary: self.arraySearchResult.object(at: indexPath.row) as! [AnyHashable: Any])
                dic = mutDict.mutableCopy() as? NSMutableDictionary
                
                if let uID: Int  = dic!.value(forKey: "userid") as? Int
                {
                    
                    mgrfriend.FriendID = "\(uID)"
                    mgrfriend.FriendName = "\(dic!.value(forKey: "fname") as! String) "  +  " \(dic!.value(forKey: "lname") as! String)"
                    mgrfriend.FriendPhoto = "\(dic!.value(forKey: "photo") as! String)"
                    mgrfriend.FUsername = "\(dic!.value(forKey: "username") as! String)"
                    
                    if let fID: Int  = dic!.value(forKey: "isfriend")! as? Int {
                        mgrfriend.isFriend = "\(fID)"
                        
                        if fID == 1 {
                            
                            if let fconnectionID  = dic?.value(forKey: "friendshipid") as? Int {
                                mgrfriend.friendConnectionID = "\(fconnectionID)"
                            }
                        }
                    }
                }
                
                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                //            VC1.delegate = self
                
                self.navigationController?.pushViewController(VC1, animated: true)
                
            } else {
                
                let chatVC = objAppDelegate.stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                
                chatVC.otherID = friends[indexPath.row].userid
                chatVC.userName = friends[indexPath.row].username
                if !((chatVC.userName?.characters.count)! > 0) {
                    chatVC.userName = "\(friends[indexPath.row].fname) \(friends[indexPath.row].lname)"
                }
                self.navigationController?.pushViewController(chatVC, animated: true)
            }
        }
    }
}
