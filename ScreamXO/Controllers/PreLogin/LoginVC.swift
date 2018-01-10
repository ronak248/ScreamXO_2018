//
//  LoginVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 20/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import TwitterKit
import Crashlytics
import WatchConnectivity

class LoginVC: UIViewController ,GIDSignInUIDelegate,GIDSignInDelegate,WCSessionDelegate, UITextFieldDelegate {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    @IBOutlet weak var viewBg: UIView!
    
    // player
    var dictFb : Dictionary<String, AnyObject>?
    var player : AVPlayer!
    var playerLayer : AVPlayerLayer!
    
    @IBOutlet var loginView: UIView!
    @IBOutlet var signUpView: UIView!
    var session : WCSession!
    var isLoginFlag = false
    // MARK: - Lifecycle Methods
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginView.isHidden = true
        signUpView.isHidden = true
        
        let attributes = [
            NSForegroundColorAttributeName:UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1.00),
            NSFontAttributeName : UIFont(name: "ProximaNova-Bold" , size: 19)!
        ]
        
        txtEmail.attributedPlaceholder = NSAttributedString(string: "         Email Or Username", attributes:attributes)

        txtpassword.attributedPlaceholder = NSAttributedString(string: "                Password", attributes:attributes)
        
        
        self.view.isHidden = true
        if (objAppDelegate.isLoadVideo) {
            playVideo()
            objAppDelegate.isLoadVideo=false
            viewBg.isHidden=false
            self.view.isHidden = false
        } else {
            self.view.isHidden = false
            viewBg.isHidden=true
        }
        txtEmail.delegate = self
        txtpassword.delegate = self
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
    }
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    func sessionDidBecomeInactive(_: WCSession) {
        
    }
    func sessionDidDeactivate(_: WCSession) {
        
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
        }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    }
    
    
     // MARK: - TextField Delegate Method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail {
            txtEmail.resignFirstResponder()
            txtpassword.becomeFirstResponder()
        } else if textField == txtpassword {
            txtpassword.resignFirstResponder()
        }
        return true
    }
    
    
    // MARK: - social  button Metho

    @IBAction func btnFbClicked(_ sender: AnyObject) {
        
       if mainInstance.connected() {
           
           
           let login: FBSDKLoginManager = FBSDKLoginManager()

           login.logOut();
           login.logIn(withReadPermissions: ["email","basic_info","user_friends"] , from: self) { (result, error) -> Void in
               SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
               if (error != nil)
               {
                   mainInstance.ShowAlertWithError("ScreamXO", msg: constant.kloginFailed as NSString)
                   SVProgressHUD.dismiss()
                   // Process error
               } else if (result?.isCancelled)! {
                   mainInstance.ShowAlertWithError("ScreamXO", msg: constant.kloginFailed as NSString)
                   SVProgressHUD.dismiss()
                   // Handle cancellations
               } else {
                   if(result?.grantedPermissions.contains("email"))!{
                       let fbRequest = FBSDKGraphRequest(graphPath: "me?fields=email,first_name,id,last_name,gender,bio,picture,hometown,location", parameters: nil)
                       let graphConnection = FBSDKGraphRequestConnection()
                       graphConnection.add(fbRequest, completionHandler: { (connection:FBSDKGraphRequestConnection?, result:Any?, error:Error?) -> Void in
                           if(error != nil){
                               mainInstance.ShowAlertWithError("ScreamXO", msg: constant.kloginFailed as NSString)
                               SVProgressHUD.dismiss()
                           }
                           else
                           {
                               self.dictFb = result as? Dictionary
                               print(self.dictFb ?? "")
                               if let fbId = self.dictFb?["id"] as? String
                               {
                                   SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                                
                                let parameterss = NSMutableDictionary()
                                var dTok = String()
                                if (mainInstance.dTokenString) != nil {
                                     dTok = mainInstance.dTokenString
                                } else {
                                    dTok = "NO TOKEN"
                                }
                                
                                
                                parameterss.setValue(fbId, forKey: "fbid")
                                 parameterss.setValue("iPhone", forKey: "devicetype")
                                parameterss.setValue(self.dictFb?["first_name"] as? String, forKey: "fname")
                                parameterss.setValue(dTok, forKey: "devicetoken")
                                parameterss.setValue(self.dictFb?["last_name"] as? String, forKey: "lname")
                                
                                let apiMgr   = APIManager.apiManager//184675888535838

                                if ( apiMgr.deviceID != nil)
                                {
                                    parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                                }
                                else
                                {
                                    apiMgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                                    parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                                }

                                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

                                apiMgr.registerNewDevice(parameterss, successClosure: { (dic, result) -> Void in
                                    SVProgressHUD.dismiss()
                                    if result == APIResult.apiSuccess
                                    {
                                        print(dic ?? "")
                                        
                                        let usr = UserManager.userManager
                                        if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int
                                        {
                                            usr.userId = "\(uID)"
                                        }
                                     
                                            
                                            
                                            usr.fullName = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String
                                        
                                        usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)
                                        
                                      
                                            
                                            let fullName: String = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String)!
                                            
                                            var fullNameArr = fullName.components(separatedBy: " ")
                                            let firstName: String = fullNameArr[0]
                                        
                                            usr.firstname = firstName
                                        
                                        let social_id = self.dictFb?["id"] as! String

                                        
                                           let profilePic = "https://graph.facebook.com/" + social_id + "/picture?type=large"
                                            
                                            
                                            usr.username = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "uname") as? String)!
                                            usr.emailAddress = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "email") as? String)!
                                        let mgr   = APIManager.apiManager

                                            if let apiKey : String = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "usertoken") as? String
                                            {
                                                mgr.sessionToken = apiKey
                                            }
                                        
                                        
                                        let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")

                                        userDefaults!.set(usr.userId, forKey: "wuid")
                                        userDefaults!.set(mgr.sessionToken, forKey: "wtoken")

                                        userDefaults?.synchronize()
                                
                                        let emptyDic:[String : AnyObject] = [:]
                                        
                                        if (!IS_IPAD)
                                        {
                                            objAppDelegate.sendData(emptyDic)
                                            
                                        }
                                            usr.lastname = fullNameArr[1]
                                            
                                            usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "nationality") as? String
                                            usr.school = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "school") as? String
                                        usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "hobbies") as? String
                                        
                                        if (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String == "" {
                                       self.createCustomer()
                                        } else {
                                            usr.stripeCustomerId = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String
                                        }
                                        
                                        
                                        usr.setSOcial="1"


                                            usr.setrelationshipstKey =  (dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                                            usr.job = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "job") as? String
                                            usr.setcityKey = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "city") as? String
                                            usr.setGenderKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "gender") as? String
                                        
                                        
                                        usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                                        
                                        usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                                        
                                        
                                        if (usr.setrelationshipstKey == "")
                                        {
                                            
                                            usr.setrelationshipstKey = "a"
                                            
                                            
                                        }
                                        if (usr.setsexpref == "")
                                        {
                                            
                                            usr.setsexpref = "o"
                                            
                                            
                                        }
                                        
                                        usr.profileImage = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!

                                        if let reg: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "isregistered") as? Int
                                        {
                                            
                                            
                                            
                                            if reg == 0 || (dic!.value(forKey: "result")! as AnyObject).value(forKey: "email") as? String == ""  {
                                                
                                                if self.dictFb?["gender"] as? String == "male"||usr.setGenderKey == "Male"
                                                {
                                                
                                                    usr.setGenderKey="m"
                                                    
                                                }
                                                else
                                                {
                                                    usr.setGenderKey="f"
                                                }


                                                usr.profileImage = profilePic
                                                usr.emailAddress=self.dictFb?["email"] as? String
                                                
                                                
                                                usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                                                
                                                usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                                                
                                                
                                                if (usr.setrelationshipstKey == "")
                                                {
                                                    
                                                    usr.setrelationshipstKey = "a"
                                                    
                                                    
                                                }
                                                if (usr.setsexpref == "")
                                                {
                                                    
                                                    usr.setsexpref = "o"
                                                    
                                                    
                                                }
                                                


                                                //self.sendData()


                                                
                                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "EditProfile")) as! EditProfile
                                                VC1.strIsFirstTime="1"
                                                self.navigationController?.pushViewController(VC1, animated: true)
                                                
                                                
                                            } else {
                                           // self.sendData()
                                                let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"wallet_amount") as! String)
                                                UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                                                UserManager.userManager.userDefaults.synchronize()
                                                objAppDelegate.setViewAfterLogin()
                                                objAppDelegate.getCategoriesList()
                                            }
                                            
                                        }
                            
                                        UserDefaults.standard.set(true, forKey: "IsLogedIn")
                                        
                                    }
                                    else if result == APIResult.apiError
                                    {
                                        print(dic ?? "")
                                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                                        SVProgressHUD.dismiss()
                                        
                                        
                                    }
                                    else
                                    {
                                        mainInstance.showSomethingWentWrong()
                                    }
                                })

                                   
                               }
                           }
                       })
                       graphConnection.start()
                   }
               }
           }
           
      
       
   }
   
   
    
       else
       {
           mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
           
       }



    }

    @IBAction func btnTwitterClicked(_ sender: AnyObject) {
       
        CLSLogv("Login with Twitter started", getVaList(["0"]))
        //SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)

        Twitter.sharedInstance().logIn { session, error in
            if (session != nil) {
                print(session!.userID);
                SVProgressHUD.dismiss()

                let client = TWTRAPIClient()
                client.loadUser(withID: session!.userID) { (user, error) -> Void in
                    // handle the response or error
                    let usr = UserManager.userManager
                    let parameterss = NSMutableDictionary()

                    usr.username=session!.userName
                    print(user!.userID)
                    let social_id = user!.userID
                    let firstName = (user!.name.components(separatedBy: " "))[0] as String
                    if ((user!.name.components(separatedBy: " ")).count>1)
                    {
                    let lastName = (user!.name.components(separatedBy: " "))[1] as String
                        parameterss.setValue(lastName, forKey: "lname")
                    }
                    else
                    {
                        parameterss.setValue(usr.username, forKey: "lname")
                    }
                    let profilePic = user!.profileImageLargeURL
                    var dTok: String!  //mainInstance.dTokenString as String
                    
                    if let token = mainInstance.dTokenString as? String {
                         dTok = mainInstance.dTokenString as String
                    } else {
                        dTok = "NO TOKEN"
                    }
                    
                     parameterss.setValue("iPhone", forKey: "devicetype")
                    parameterss.setValue(social_id, forKey: "twitterid")
                    parameterss.setValue(firstName , forKey: "fname")
                    parameterss.setValue(dTok, forKey: "devicetoken")
                    let apiMgr   = APIManager.apiManager//184675888535838

                    if ( apiMgr.deviceID != nil)
                    {
                        
                        parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                    }
                    else
                    {
                        
                        apiMgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                        parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                    }
                    SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

                    apiMgr.registerNewDevice(parameterss, successClosure: { (dic, result) -> Void in
                        SVProgressHUD.dismiss()
                        if result == APIResult.apiSuccess
                        {
                            print(dic ?? "")
                            
                            if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int
                            {
                                usr.userId = "\(uID)"
                            }
                            
                            usr.fullName = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String
                            
                            usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)
                            
                         
                            
                            let fullName: String = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String)!
                            
                            usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)
                            
                       
                            var fullNameArr = fullName.components(separatedBy: " ")
                            let firstName: String = fullNameArr[0]
                            
                            usr.firstname = firstName
                            usr.emailAddress = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "email") as? String)!
                            let mgr   = APIManager.apiManager

                            if let apiKey : String = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "usertoken") as? String
                            {
                                mgr.sessionToken = apiKey
                            }
                            let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
                            
                            userDefaults!.set(usr.userId, forKey: "wuid")
                            userDefaults!.set(mgr.sessionToken, forKey: "wtoken")
                            
                            userDefaults?.synchronize()
                            
                            usr.lastname = fullNameArr[1]
                            usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "nationality") as? String
                            usr.school = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "school") as? String
                            usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "hobbies") as? String

                            usr.setrelationshipstKey =  (dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                            usr.job = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "job") as? String
                            usr.setcityKey = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "city") as? String
                            usr.setGenderKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "gender") as? String
                            usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                            
                            usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                            
                            if (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String == "" {
                                self.createCustomer()
                            } else {
                                usr.stripeCustomerId = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String
                            }

                            
                            if (usr.setrelationshipstKey == "")
                            {
                                
                                usr.setrelationshipstKey = "a"
                                
                                
                            }
                            if (usr.setsexpref == "")
                            {
                                
                                usr.setsexpref = "o"
                                
                                
                            }
                            
                            usr.setSOcial="1"

                            
                            usr.profileImage = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!
                            
                            if let reg: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "isregistered") as? Int {
                                if reg == 0 || usr.emailAddress == "" {
                                   usr.profileImage = profilePic
                                    
                                    let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "EditProfile")) as! EditProfile
                                    VC1.strIsFirstTime="1"
                                    self.navigationController?.pushViewController(VC1, animated: true)
                                } else {
                                    
                                    let walletMoney: String = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"wallet_amount") as! String)
                                    UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                                    UserManager.userManager.userDefaults.synchronize()
                                    
                                    objAppDelegate.setViewAfterLogin()
                                    let mgrItm = ItemManager.itemManager
                                    if mgrItm.arrayCategories == nil {
                                        objAppDelegate.getCategoriesList()
                                    }
                                }
                            }
                            UserDefaults.standard.set(true, forKey: "IsLogedIn")
                        }
                        else if result == APIResult.apiError
                        {
                            print(dic ?? "")
                            mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                            SVProgressHUD.dismiss()
                            
                            
                        }
                        else
                        {
                            mainInstance.showSomethingWentWrong()
                        }
                    })
                    
                    
                }
                
                
                CLSLogv("Login with Twitter Successful", getVaList([session!.userID]))
            } else {
                print(error!.localizedDescription);
                CLSLogv("Login with Twitter Error", getVaList([error!.localizedDescription]))
            }
        }
    }
    @IBAction func btnGoogleClicked(_ sender: AnyObject) {
      
        
        let VC1=(objAppDelegate.storyboard.instantiateViewController(withIdentifier: "InstagramVC")) as! InstagramVC
        if (UserDefaults.standard.object(forKey: APIManager.APIConstants.kACCESSTOKEN) as? String) != nil {
            VC1.getuserDetail({ (dict:NSDictionary?, ststus:APIResult) in
                
                
                if (ststus == APIResult.apiSuccess)
                {
                self.instagramSignin(dict!)
                    UserDefaults.standard.set(true, forKey: "IsLogedIn")
                }
             })
        }else{
            self.navigationController?.present(VC1, animated: true, completion: nil)
            VC1.getuserDetail({ (dict:NSDictionary?, ststus:APIResult) in
                if (ststus == APIResult.apiSuccess)
                {
                    self.instagramSignin(dict!)
                }
            })
        }
        

    
    }
    
    func instagramSignin(_ dict:NSDictionary) {
        
        let social_id = dict.value(forKeyPath: "data.id") as! String
        
        let fullname = dict.value(forKeyPath: "data.full_name") as! String
        
        let firstName: String?
        let lastName: String?
        if fullname.components(separatedBy: " ").count > 1 {
            
            firstName = (fullname.components(separatedBy: " "))[0]
            lastName = (fullname.components(separatedBy: " "))[1]
        } else {
            
            firstName = (fullname.components(separatedBy: " "))[0]
            lastName = ""
        }
        
        let urlImg = dict.value(forKeyPath: "data.profile_picture") as! String
        
        
        let usr = UserManager.userManager
        
        
        
        let parameterss = NSMutableDictionary()
        let dTok: String = mainInstance.dTokenString as String
        
        parameterss.setValue(social_id, forKey: "googleid")
        parameterss.setValue(firstName!, forKey: "fname")
        parameterss.setValue(dTok, forKey: "devicetoken")
        parameterss.setValue(lastName!, forKey: "lname")
         parameterss.setValue("iPhone", forKey: "devicetype")
        
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let apiMgr   = APIManager.apiManager//184675888535838
        
        if ( apiMgr.deviceID != nil)
        {
            
            parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
            
        }
        else
        {
            
            apiMgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
            parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
            
            
            
        }
        apiMgr.registerNewDevice(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                print(dic ?? "")
                
                if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int
                {
                    usr.userId = "\(uID)"
                }
                
                
                usr.fullName = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String
                usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)
                
                let fullName: String = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String)!
                
                var fullNameArr = fullName.components(separatedBy: " ")
                let firstName: String = fullNameArr[0]
                
                usr.firstname = firstName
                let mgr   = APIManager.apiManager
                
                if let apiKey : String = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "usertoken") as? String
                {
                    mgr.sessionToken = apiKey
                }
                
                let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
                
                userDefaults!.set(usr.userId, forKey: "wuid")
                userDefaults!.set(mgr.sessionToken, forKey: "wtoken")
                
                userDefaults?.synchronize()
                usr.lastname = fullNameArr[1]
                
                usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "nationality") as? String
                usr.school = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "school") as? String
                usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "hobbies") as? String
                
                usr.setrelationshipstKey =  (dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                usr.job = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "job") as? String
                usr.setcityKey = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "city") as? String
                usr.setGenderKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "gender") as? String
                usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                
                usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                
                
                if (usr.setrelationshipstKey == "")
                {
                    
                    usr.setrelationshipstKey = "a"
                    
                    
                }
                if (usr.setsexpref == "")
                {
                    
                    usr.setsexpref = "o"
                    
                    
                }
                
                usr.profileImage = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!
                
                usr.setSOcial="1"
                
                if (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String == "" {
                    self.createCustomer()
                } else {
                    usr.stripeCustomerId = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String
                }

                if let reg: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "isregistered") as? Int
                {
                    
                    let EmailAdd: String! = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "email") as? String
                    
                    if reg == 0 || EmailAdd == "" {
                        
                        
                        
                        usr.profileImage = urlImg
                        
                        
                        
                        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "EditProfile")) as! EditProfile
                        VC1.strIsFirstTime="1"
                        self.navigationController?.pushViewController(VC1, animated: true)
                        
                        
                    }
                    else {
                        let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"wallet_amount") as! String)
                        UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                        UserManager.userManager.userDefaults.synchronize()
                        objAppDelegate.setViewAfterLogin()
                        let mgrItm = ItemManager.itemManager
                        if mgrItm.arrayCategories == nil {
                            objAppDelegate.getCategoriesList()
                        }
                        
                    }
                    
                }
                
                UserDefaults.standard.set(true, forKey: "IsLogedIn")
                
            }
            else if result == APIResult.apiError
            {
                print(dic ?? "")
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                
            }
            else
            {
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    //MARK : G+ delegate

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
        withError error: Error!) {
            if (error == nil) {
                
                print(user.userID)
                
                let social_id = user.userID
                
                let firstName = (user.profile.name.components(separatedBy: " "))[0]
                
                let lastName = (user.profile.name.components(separatedBy: " "))[1]
                
                _ = user.profile.email
                
                var profilePic = ""
                if(user.profile.hasImage){
                    let urlImg = user.profile .imageURL(withDimension: 300)
                    profilePic = (urlImg?.absoluteString)!
                }
                
                
                let usr = UserManager.userManager
                
             
                
                let parameterss = NSMutableDictionary()
                let dTok: String = mainInstance.dTokenString as String
                
                parameterss.setValue(social_id, forKey: "googleid")
                parameterss.setValue(firstName, forKey: "fname")
                parameterss.setValue(dTok, forKey: "devicetoken")
                parameterss.setValue(lastName, forKey: "lname")
                 parameterss.setValue("iPhone", forKey: "devicetype")
                
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

                let apiMgr   = APIManager.apiManager//184675888535838
                if ( apiMgr.deviceID != nil)
                {
                    
                    parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                    
                }
                else
                {
                    apiMgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                    parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                }
                apiMgr.registerNewDevice(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess
                    {
                        print(dic ?? "")
                        
                        if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int
                        {
                            usr.userId = "\(uID)"
                        }
                        
                        
                        
                        usr.fullName = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String
                        usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)

                        let fullName: String = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String)!
                        
                        var fullNameArr = fullName.components(separatedBy: " ")
                        let firstName: String = fullNameArr[0]
                        
                        usr.firstname = firstName
                        let mgr   = APIManager.apiManager

                        if let apiKey : String = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "usertoken") as? String
                        {
                            mgr.sessionToken = apiKey
                        }
                        
                        let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
                        
                        userDefaults!.set(usr.userId, forKey: "wuid")
                        userDefaults!.set(mgr.sessionToken, forKey: "wtoken")
                        
                        userDefaults?.synchronize()
                        usr.lastname = fullNameArr[1]
                        
                        usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "nationality") as? String
                        usr.school = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "school") as? String
                        usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "hobbies") as? String

                        usr.setrelationshipstKey =  (dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                        usr.job = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "job") as? String
                        usr.setcityKey = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "city") as? String
                        usr.setGenderKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "gender") as? String
                        usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                        
                        usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                        
                        
                        if (usr.setrelationshipstKey == "")
                        {
                            
                            usr.setrelationshipstKey = "a"
                            
                            
                        }
                        if (usr.setsexpref == "")
                        {
                            
                            usr.setsexpref = "o"
                            
                            
                        }
                        
                        usr.profileImage = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!
                        
                        usr.setSOcial="1"

                        
                        if let reg: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "isregistered") as? Int
                        {
                            
                            
                            
                            if reg == 0
                            {
                                
                                
                                
                                usr.profileImage = profilePic
                                
                                
                                
                                
                                
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "EditProfile")) as! EditProfile
                                VC1.strIsFirstTime="1"
                                self.navigationController?.pushViewController(VC1, animated: true)
                                
                                
                            }
                            else
                            {
                                let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"wallet_amount") as! String)
                                UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                                UserManager.userManager.userDefaults.synchronize()
                                objAppDelegate.setViewAfterLogin()
                                let mgrItm = ItemManager.itemManager
                                if mgrItm.arrayCategories == nil {
                                    objAppDelegate.getCategoriesList()
                                }
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    else if result == APIResult.apiError
                    {
                        print(dic ?? "")
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                        
                        
                    }
                    else
                    {
                        mainInstance.showSomethingWentWrong()
                    }
                })
            } else {
                print("\(error.localizedDescription)")
            }
    }

    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
        withError error: Error!) {
            
    }

    // MARK: - custom button Metho

    @IBAction func btnLoginClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)

        if txtEmail.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Email or Username is required")
        } else if txtpassword.text?.characters.count == 0 {
            mainInstance.ShowAlertWithError("Error", msg: "Password is required")
        } else {
            if mainInstance.connected() {
                let parameterss = NSMutableDictionary()
                let tokenId = mainInstance.dTokenString
                let dTok: String!
                if tokenId == nil {
                    dTok = "NoToken"
                } else {
                    dTok = tokenId
                }

                parameterss.setValue(self.txtEmail.text, forKey: "uname")
                parameterss.setValue(self.txtpassword.text, forKey: "password")
                parameterss.setValue(dTok, forKey: "devicetoken")
                parameterss.setValue("iPhone", forKey: "devicetype")
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                let apiMgr   = APIManager.apiManager//184675888535838
                let mgr = APIManager.apiManager
                if ( apiMgr.deviceID != nil) {
                    parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                } else {
                    
                    apiMgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                    parameterss.setValue(apiMgr.deviceID, forKey: "uniquestring")
                }
                mgr.loginUser(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess {
                        print(dic ?? "")
                        
                        let usr = UserManager.userManager
                        if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int {
                            usr.userId = "\(uID)"
                        }
                        if let ustatus : NSString = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "userstatus") as? NSString {
                            if ustatus == "0" {
                                
                                let VC1=(objAppDelegate.storyboard.instantiateViewController(withIdentifier: "VerficationVC")) as UIViewController
                                self.navigationController?.pushViewController(VC1, animated: true)
                                
                            }
                        } else {
                            
                            usr.fullName = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String
                            
                            usr.fullName!.replaceSubrange(usr.fullName!.startIndex...usr.fullName!.startIndex, with: String(usr.fullName![usr.fullName!.startIndex]).capitalized)

                            
                            let fullName: String = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "name") as? String)!
                            
                            var fullNameArr = fullName.components(separatedBy: " ")
                            let firstName: String = fullNameArr[0]
                            
                            usr.firstname = firstName
                            usr.profileImage = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!
                            let walletMoney: String! = String(describing: (dic?.value(forKey: "result")! as! NSDictionary).value(forKey:"wallet_amount") as! String)
                            UserManager.userManager.userDefaults.set(walletMoney, forKey: "walletMoney")
                            UserManager.userManager.userDefaults.synchronize()
                            usr.username = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "uname") as? String)!
                            usr.emailAddress = ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "email") as? String)!
                            let mgr   = APIManager.apiManager

                            if let apiKey : String = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "usertoken") as? String {
                                mgr.sessionToken = apiKey
                            }
                            usr.lastname = fullNameArr[1]
                            
                            usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "nationality") as? String
                            usr.school = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "school") as? String
                            usr.setHobby = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "hobbies") as? String

                            usr.setrelationshipstKey =  (dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String
                            usr.job = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "job") as? String
                            usr.setcityKey = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "city") as? String
                            usr.setGenderKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "gender") as? String
                            usr.setsexpref=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "sexpreference") as? String
                            
                            usr.setrelationshipstKey=(dic!.value(forKey: "result")! as AnyObject).value(forKey: "realtionstatus") as? String

                            if (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String == "" {
                                self.createCustomer()
                            } else {
                                usr.stripeCustomerId = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "stripe_customer_id") as? String
                            }

                            if (usr.setrelationshipstKey == "") {
                            
                                usr.setrelationshipstKey = "a"
                            }
                            if (usr.setsexpref == "") {
                                usr.setsexpref = "o"
                            }
                            usr.setSOcial="0"
                            objAppDelegate.setViewAfterLogin()
                            let mgrItm = ItemManager.itemManager
                            if mgrItm.arrayCategories == nil {
                                objAppDelegate.getCategoriesList()
                            }
                        }
                        UserDefaults.standard.set(true, forKey: "IsLogedIn")
                    }
                    else if result == APIResult.apiError
                    {
                        print(dic ?? "")
                        mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                        
                        
                    }
                    else
                    {
                        mainInstance.showSomethingWentWrong()
                    }
                })
                
            }
            else
            {
                mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)

            
            }

        
        }
        
    }
    
    
    @IBAction func GuestLogin(_ sender: Any) {
                
    }

    @IBAction func cancelSignUpView(_ sender: Any) {
       loginView.isHidden = true
        signUpView.isHidden = true
    }
    
    @IBAction func loginViewBtnTapped(_ sender: Any) {
        loginView.isHidden = true
        signUpView.isHidden = false
        isLoginFlag = true
    }
    
    @IBAction func loginBackBtnTapped(_ sender: Any) {
        loginView.isHidden = true
        signUpView.isHidden = true
    }
    
    @IBAction func signUpBackBtnTapped(_ sender: Any) {
        loginView.isHidden = true
        signUpView.isHidden = true
    }
    
    
    
    @IBAction func signUpView(_ sender: Any) {
        isLoginFlag = false
        loginView.isHidden = true
        signUpView.isHidden = false
    }
    
    @IBAction func btnSignupClicked(_ sender: AnyObject) {
        
        if isLoginFlag {
            loginView.isHidden = false
            signUpView.isHidden = true
        } else {
            
        let VC1=(objAppDelegate.storyboard.instantiateViewController(withIdentifier: "SignUpVC")) as UIViewController
        
        self.navigationController?.pushViewController(VC1, animated: true)
        }
        
    }
    
    @IBAction func btnForgotClicked(_ sender: AnyObject) {
        let VC1=(objAppDelegate.storyboard.instantiateViewController(withIdentifier: "ForgotVC")) as UIViewController
      self.navigationController?.pushViewController(VC1, animated: true)
    }

    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
    
   func createCustomer() {
    
    let when = DispatchTime.now() + 2
    DispatchQueue.main.asyncAfter(deadline: when) {
    
    let usr = UserManager.userManager
    let parameterss = NSMutableDictionary()
    parameterss.setValue(usr.userId, forKey: "uid")
    parameterss.setValue(usr.emailAddress, forKey: "email")
    parameterss.setValue(usr.username, forKey: "description")
    
    let apiMgr   = APIManager.apiManager//
    apiMgr.create_stripe_customerId(parameterss, successClosure: { (dic, result) -> Void in
    SVProgressHUD.dismiss()
    if result == APIResult.apiSuccess
    {
    print(dic ?? "")
        print((dic?.value(forKey: "stripe_customer_id") as AnyObject))
        usr.stripeCustomerId = (dic?.value(forKey: "stripe_customer_id") as AnyObject).value(forKey:"") as? String
    
    }  else if result == APIResult.apiError
    {
    print(dic ?? "")
    
    
    }
    else
    {
    }
    })
    }
    }
    
    // MARK:---------------
    // MARK: Watch Connectivity Methods
    // MARK:---------------
    
    @IBAction func btnSend_Click(_ sender: AnyObject) {
        
        let emptyDic:[String : AnyObject] = [:]
        
        if (!IS_IPAD)
        {
            objAppDelegate.sendData(emptyDic)
            
        }    }
    
    //MARK: - play video  -
    
    
    func playVideo()
    {
        let urlS  = Bundle.main.path(forResource: "shutterstock_v530524 (Converted)", ofType: "mp4")
        let url =  URL.init(fileURLWithPath:urlS!, isDirectory: false)
        player = AVPlayer.init(playerItem: AVPlayerItem.init(url:url))
        let imgoverlay = UIImageView()
        imgoverlay.image = UIImage(named: "logologinnew")
        imgoverlay.frame=CGRect(x: 0, y: 50, width: imgoverlay.image!.size.width, height: imgoverlay.image!.size.height)
        imgoverlay.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = self.view!.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.addSublayer(imgoverlay.layer)
        self.view!.layer.addSublayer(playerLayer)
        //self.view.userInteractionEnabled=false
        player.actionAtItemEnd = .none
        
        
        let pinchy = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handletapGesture(_:)))
        pinchy.numberOfTapsRequired=1
        viewBg.addGestureRecognizer(pinchy)

        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:player.currentItem)
        player.play()
    }
    func handletapGesture(_ sender: AnyObject) {
        
        self.view.isUserInteractionEnabled = true
        player.pause()
        playerLayer.removeFromSuperlayer()
        objAppDelegate.setRootViewController()
        
        // MARK: Introduction View Controller
//        let objLoginViewController = objAppDelegate.storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//        var screamNavig : XXNavigationController?
//        screamNavig = XXNavigationController(rootViewController: objLoginViewController)
//        screamNavig!.setNavigationBarHidden(true, animated: false)
//        objAppDelegate.window?.rootViewController = screamNavig
    }
    func playerItemDidReachEnd( _ notification:Notification)
    {
        self.view.isUserInteractionEnabled=true
        player.pause()
        playerLayer.removeFromSuperlayer()
        objAppDelegate.setRootViewController()
        
        // MARK: Introduction View Controller
        
//        let objLoginViewController = storyboard!.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
//        var screamNavig : XXNavigationController?
//        screamNavig = XXNavigationController(rootViewController: objLoginViewController)
//        screamNavig!.setNavigationBarHidden(true, animated: false)
//        objAppDelegate.window?.rootViewController = screamNavig
        
    }

    


}
