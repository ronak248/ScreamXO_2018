//
//  AppDelegate.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 07/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import CoreLocation;
import TwitterKit
import coinbase_official
import AVFoundation
import WatchConnectivity
import UserNotifications
import ImageIO
import Instabug
import Stripe
import Google
import GoogleSignIn
import MSAL




//1=like post,2=comment post,3=purchase your item,4=contact request,5=accepted friendship,6=send new mnessage,7=trackingdetail added,8= added review for product,9= Tagged you in post,10=tagged you in comment

enum notificationType: Int {
    case notiLike = 1,notiComment,notiPurchase,notiRequest,notiAccept,notiNewMsg,notiTrackingDetail,addTrackNo, notiReviewProduct,notiTagPost,notiTagComment
}

enum notifiType : NSInteger
{
    case pLike = 1,pComment,pItem,cntrequest,cntaccept,itmTrack, itmTrackAdded , addTrackNo
}


///fgfjglfkg

let objAppDelegate = UIApplication.shared.delegate as! AppDelegate
let IS_IPAD = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,CLLocationManagerDelegate,WCSessionDelegate {
    
 
    // for watch connectivity
    var session : WCSession!
    // for watch connectivity

    var landScape: String = ""
    var storyboard = UIStoryboard(name: "Main", bundle: nil)
    var stSideMenu = UIStoryboard(name: "SideMenu", bundle: nil)
    var strFriends = UIStoryboard(name: "Friends", bundle: nil)
    var stPOST = UIStoryboard(name: "CreatePost", bundle: nil)
    var stProfile = UIStoryboard(name: "Profile", bundle: nil)
    var stShopItem = UIStoryboard(name: "ShopItem", bundle: nil)
    var stMsg = UIStoryboard(name: "Messaging", bundle: nil)
    var stWallet = UIStoryboard(name: "Wallet", bundle: nil)
    var dicUserInfopush : NSDictionary?
    var window: UIWindow?
    var lat: Double = 0.0
    var lon: Double = 0.0
    var strLat :String = "23.0300"
    var strLon :String = "72.5800"
    var locationManager: CLLocationManager!
    var seenError : Bool = false
    var isconfiguredpayment : Bool = false
    var fullScreenVideoIsPlaying : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus : NSString = "Not Started"
    var isLoadVideo : Bool = true
    var screamNavig : UINavigationController?
    var internetPopupDisplayed = false
    var noPopAlert = 0
    var circleMenuLoaded = false
    var circleMenuOrigin: CGPoint!
    var isCircleMenuLabelShown = false
    var shareFlag = false
    //MARK: - watch delegates -
    @available(iOS 9.3, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
    
    }
    func sessionDidBecomeInactive(_: WCSession)
        
    {
        
    }
    func sessionDidDeactivate(_: WCSession)
    {
        
    }
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
            
        }
    }
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    }
    
    // MARK: - Application Life Cycle Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        // Stripe statements
        
        
        Fabric.with([STPAPIClient.self, Twitter.self, Crashlytics.self])

        
        
        let appKey = "c7eh9v0sk0ertg2"      // Set your own app key value here.
        let appSecret = "4bwwnvd44mxlt3e"   // Set your own app secret value here.
        
        let dropboxSession = DBSession(appKey: appKey, appSecret: appSecret, root: kDBRootAppFolder)
        DBSession.setShared(dropboxSession)
        
        
        
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "Ads5vhR2_6PBBDjy2MAMNpGp9SLoukSdfaW77zP_EjdWR1VkKTuV0cy0dbjkixohCRf3ueru_KLa3MsS", PayPalEnvironmentSandbox: "AVXWGvfvgZZSEDKzMy3ZCGClZYtkJwwSi2DeMuSOxYIRQGl6zvuo4-cfrQYN9Q96ms7-dkYkfZUQVPjM"])

        STPPaymentConfiguration.shared().publishableKey = "pk_test_52XRGhakXWpAPlAMKegKSlkX"  //"pk_test_OTagBMSd80AEIQv20biYqTae" myKey
        
        mainInstance.changePopUpStyle()
        // for crashaltics
        Fabric.with([Crashlytics.self,Twitter.self])
        initLocationManager()
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotationType), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(String(describing: configureError))")
    

        let manger = APIManager.apiManager
        if manger.sessionToken != nil {
            setViewAfterLogin()
            getCategoriesList()
        } else {
//            setViewAfterLogin()
            setRootViewController()
        }
        // instabug
        
        Instabug.start(withToken: "67e05c3b0c872f334b1c375d0bffcb90", invocationEvent: .shake)
        
        let item = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem]
        if item != nil {
            print("We've launched from a shortcut item: ", (item as AnyObject).localizedTitle)
            if (item as AnyObject).type == constant.kshortcutmediapost
            {
                launchMediaPost()
            }
            else if (item as AnyObject).type == constant.kshortcutstreampost
            {
                launchstreamPost()
            }
            else if (item as AnyObject).type == constant.kshortcutsellnow
            {
                launchsellnow()
            }
        } else
        {
            print("We've launched properly.")
            
        }
        
        // launch specific vew controllers
        
        
        
        // get static pages
        
        let mgradmin = AdminManager.adminManager
        mgradmin.getpages { (dic:NSDictionary?, result:APIResultAdm) -> Void in
            
        };
        
        /// end shortcut menu
        
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            
            var categories  = Set<UIUserNotificationCategory>()
            let inviteCategory = UIMutableUserNotificationCategory()
            inviteCategory.setActions([],
                                      for: UIUserNotificationActionContext.default)
            inviteCategory.identifier = "myCategory"
            
            categories.insert(inviteCategory)
            
            // Configure other actions and categories and add them to the set...
            
            if #available(iOS 10.0, *){
                let center = UNUserNotificationCenter.current()
                center.delegate = self
                center.requestAuthorization(options: [.alert,.badge,.sound]) {
                    granted,error in
                    if (error == nil) {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            } else {
                
                let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: categories)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
            }
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        
        // mainInstance.printFonts()
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
        // Override point for customization after application launch.
        
        Twitter.sharedInstance().start(withConsumerKey: constant.kTwiiterConsumerKey, consumerSecret: constant.kTwiiterConsumersecret)
        Fabric.with([Twitter.sharedInstance()])
        FBSDKApplicationDelegate.sharedInstance().application(
            application, didFinishLaunchingWithOptions: launchOptions)
        
//        GIDSignIn.sharedInstance().clientID = "932248994868-gtj7625tel5ll1lre0s6s9jmi9gpgqf7.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().clientID = "638589596844-tfr5bjos3og2gn8fuavaej7iicd24hfu.apps.googleusercontent.com"

        #if DEBUG
            Rollout.setup(withKey: "571e1a6e369ae6b7733fd340", developmentDevice: true)
        #else
            Rollout.setup(withKey: "571e1a6e369ae6b7733fd340", developmentDevice: false)
        #endif
        
        // for push handle
        
        
        if(!(launchOptions == nil)){
            let userInfo  = (launchOptions![UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary)
            
            if(!(userInfo == nil)){
                dicUserInfopush=userInfo
            }else{
            }
            
        }else{
        }
        
        
        // for watch connectivity
        
        self.initSession()
        
        
        // for logout
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.logoutInbetween), name: NSNotification.Name(rawValue: userDidLogoutNotificaiton), object: nil)
        
        try!  AVAudioSession.sharedInstance().setActive(true)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
        return true
        
    }
    
    

    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        FBSDKAppEvents.activateApp()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // react to shortcut item selections
        print("A shortcut item was pressed. It was ", shortcutItem.localizedTitle)
        
        // have we launched Deep Link 1?
        if shortcutItem.type == constant.kshortcutmediapost {
            launchMediaPost()
        } else if shortcutItem.type == constant.kshortcutstreampost {
            launchstreamPost()
        } else if shortcutItem.type == constant.kshortcutsellnow {
            launchsellnow()
        }
    }
    
    // MARK: - Navigation methods

    func setRootViewController() {
        if !UserDefaults.standard.bool(forKey: "GuestUser") {
                let storyboard : UIStoryboard = UIStoryboard(name: "Profile", bundle:nil)
                let objLogin = storyboard.instantiateViewController(withIdentifier: "GuestShare") as! GuestShareVC
                screamNavig = UINavigationController(rootViewController: objLogin)
                screamNavig!.setNavigationBarHidden(true, animated: false)
                window?.rootViewController = screamNavig
        } else if UserDefaults.standard.bool(forKey: "IsLogedIn"){
            let objLogin = stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            screamNavig = UINavigationController(rootViewController: objLogin)
            screamNavig!.setNavigationBarHidden(true, animated: false)
            window?.rootViewController = screamNavig
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
                parameterss.setValue("Ronak1", forKey: "uname")
                parameterss.setValue("123456", forKey: "password")
                parameterss.setValue(dTok, forKey: "devicetoken")
                parameterss.setValue("iPhone", forKey: "devicetype")
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                let mgr = APIManager.apiManager
                    parameterss.setValue("E951A44A-B6E5-4C1C-BC25-378368EFE6B2", forKey: "uniquestring")
                mgr.loginUserAsGuest(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess {
                        print(dic ?? "")
                        
                        let usr = UserManager.userManager
                        if let uID: Int  = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int {
                            usr.userId = "\(uID)"
                        }
                        UserManager.userManager.userDefaults.set("1", forKey: "userId")
                        objAppDelegate.setViewAfterLogin()
                        objAppDelegate.getCategoriesList()
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
    func setViewAfterLogin() {
        
        let objHome = stSideMenu.instantiateViewController(withIdentifier: "HomeScreen") as! HomeScreen
        screamNavig = UINavigationController(rootViewController: objHome)
        screamNavig!.setNavigationBarHidden(true, animated: false)
        
        let objside = stSideMenu.instantiateViewController(withIdentifier: "menuController") as! sideMenuLeftVC

        let objmain = RESideMenu(contentViewController: screamNavig, leftMenuViewController: objside, rightMenuViewController: nil)
        objmain?.panGestureEnabled = false
        objmain?.contentViewShadowEnabled = true
        
        
        let objMessaging = stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
        objMessaging.isSwipeVC = true
        let navMessage = UINavigationController(rootViewController: objMessaging)
        navMessage.setNavigationBarHidden(true, animated: false)
        let fusuma = stSideMenu.instantiateViewController(withIdentifier: "CameraVC") as! CameraVC
        fusuma.delegatePost = objHome
        
        //let snapContainer = SnapContainerViewController.containerViewWith(navMessage, middleVC:objmain!, rightVC: fusuma, topVC:nil,bottomVC:nil)
         let snapContainer = SnapContainerViewController.containerViewWith(navMessage, middleVC:objmain!, rightVC: fusuma, topVC:nil,bottomVC:nil)
        self.window?.rootViewController = snapContainer
        setupCircleMenu()
        
        self.window?.makeKeyAndVisible()
    }
    
    func logoutInbetween() {
        UserDefaults.standard.removeObject(forKey: APIManager.APIConstants.kACCESSTOKEN)
        let mgr = APIManager.apiManager
        mgr.clearSession()
        mgr.logOut { (data, result) -> Void in
            if result == APIResult.apiSuccess {
                print("token cleared")
            } else {
                print("token won't cleared")
            }
        }
        let usr = UserManager.userManager
        usr.clearUUID()
        setRootViewController()
    }
    
    func launchMediaPost() {
        let manger = APIManager.apiManager
        if ( manger.sessionToken != nil) {
            let objmediapost: CreatePost_Media = stPOST.instantiateViewController(withIdentifier: "CreatePost_Media") as! CreatePost_Media
            objmediapost.delegate = nil
            screamNavig!.pushViewController(objmediapost, animated: true)
        }
    }
    func launchstreamPost() {
        
        let manger = APIManager.apiManager
        if ( manger.sessionToken != nil) {
            let objmediapost: CreatePostVC = stPOST.instantiateViewController(withIdentifier: "CreatePostVC") as! CreatePostVC
            objmediapost.delegate = nil
            screamNavig!.pushViewController(objmediapost, animated: true)
        }
    }
    func launchsellnow() {
        
        let manger = APIManager.apiManager
        if ( manger.sessionToken != nil) {
            let objsell: SellItemVC = stShopItem.instantiateViewController(withIdentifier: "SellItemVC") as! SellItemVC
            objsell.delegate = nil
            screamNavig!.pushViewController(objsell, animated: true)
        }
    }
    
    // MARK: Get Image Array
    
    func getImgArray(_ imgName: String, totalImages: Int) -> [UIImage]{
        
        var imgArray: [UIImage] = []
        var number = 1
        while number <= totalImages {
            imgArray.append(UIImage(named: "\(imgName)-\(number)")!)
            number += 1
        }
        return imgArray
    }

    // MARK: - fetch Categories  Methods

    func getCategoriesList() {
        
        if mainInstance.connected() {
            
            internetPopupDisplayed = false
            
            let mgrItm = ItemManager.itemManager
            let mgr = APIManager.apiManager
            let parameterss = NSMutableDictionary()
            mgr.getCategoriesList(parameterss, successClosure: { (dic, result) -> Void in
                SVProgressHUD.dismiss()
                if result == APIResult.apiSuccess {
                    SVProgressHUD.dismiss()
                    mgrItm.arrayCategories = NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "categories") as! NSArray)
                    var emptyDic:[String : AnyObject] = [:]
                    
                    emptyDic["category"] = NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "categories") as! NSArray)
                    
                    if (!IS_IPAD) {
                        self.sendData(emptyDic)
                        
                    }
                }
                else if result == APIResult.apiError {
                    print(dic)
                    mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                    SVProgressHUD.dismiss()
                } else {
                    SVProgressHUD.dismiss()
                    mainInstance.showSomethingWentWrong()
                }
            })
        } else {
            if internetPopupDisplayed == false {
                
                mainInstance.showNoInternetAlert()
                internetPopupDisplayed = true
            }
        }
    }
    
    @objc(application:didRegisterForRemoteNotificationsWithDeviceToken:) func application(_ application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let characterSet = CharacterSet(charactersIn: "<>")
        let deviceTokenString = deviceToken.description.trimmingCharacters(in: characterSet).replacingOccurrences(of: " ", with: "");
        print(deviceTokenString)
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("MyDeviceToken \(token)")
        mainInstance.dTokenString = token
       // UserDefaults.standard.set(false, forKey: "GuestUser")
        //UserDefaults.standard.set(false, forKey: "Shared")
         //UserDefaults.standard.set(false, forKey: "IsLogedIn")
    }
    //Called if unable to register for APNS.
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        // print(error)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        
        print("Recived: \(userInfo)")
        //Parsing userinfo:
        //var temp : NSDictionary = userInfo
        
        let state: UIApplicationState = UIApplication.shared.applicationState
        if state == .background || state == .inactive
        {
            if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
            {
                let strType = ("\(info["ntype"]! as! NSNumber)")
                let detailID = ("\(info["detailid"]! as! NSNumber)")

                let usr = UserManager.userManager
                if usr.userId != nil {
                    
                    let notifiMgr = NotificationManager.notificationManager
                    notifiMgr.decrebadgeNotification()
                    
                    let badgetotal:Int = UIApplication.shared.applicationIconBadgeNumber
                    
                    UIApplication.shared.applicationIconBadgeNumber = (badgetotal-1)
                    
                    //navig
                    if (Int(strType) == notifiType.pLike.rawValue || Int(strType) == notifiType.pComment.rawValue)
                    {
                        let strsubType =  ("\(info["posttype"]! as! NSNumber)")
                        let mgrItm = PostManager.postManager
                        mgrItm.clearManager()
                        let objpost: PostDetailsVC = stPOST.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsVC
                        mgrItm.PostId = detailID
                        if strsubType == "0" {
                            objpost.Posttype=0
                        } else {
                            objpost.Posttype=2;
                        }
                        screamNavig!.pushViewController(objpost, animated: true)
                    } else if Int(strType) == notifiType.cntrequest.rawValue {
                        let objfriends: FriendsVC = strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=1;
                        screamNavig!.pushViewController(objfriends, animated: true)
                    } else if Int(strType) == notifiType.cntaccept.rawValue {
                        let objfriends: FriendsVC = strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=2
                        screamNavig!.pushViewController(objfriends, animated: true)
                    }else if Int(strType) == notifiType.pItem.rawValue {
                        let mgrItm = ItemManager.itemManager
                        mgrItm.clearManager()
                        mgrItm.ItemId = detailID
                        let objitm: Profile = stShopItem.instantiateViewController(withIdentifier: "Profile") as! Profile
                        screamNavig!.pushViewController(objitm, animated: true)
                    }else if Int(strType) == notifiType.pItem.rawValue {
                        let mgrItm = ItemManager.itemManager
                        mgrItm.clearManager()
                        mgrItm.ItemId = detailID
                        let objitm: OtherProfile = stShopItem.instantiateViewController(withIdentifier: "OtherProfile") as! OtherProfile
                        screamNavig!.pushViewController(objitm, animated: true)
                    } else if Int(strType) == notifiType.pItem.rawValue {
                        let mgrItm = ItemManager.itemManager
                        mgrItm.clearManager()
                        mgrItm.ItemId = detailID
                        let objitm: ItemDetails = stShopItem.instantiateViewController(withIdentifier: "ItemDetails") as! ItemDetails
                        screamNavig!.pushViewController(objitm, animated: true)
                    } else if Int(strType) == notifiType.addTrackNo.rawValue {
                        let mgrItm = ItemManager.itemManager
                        mgrItm.clearManager()
                        mgrItm.ItemId = detailID
                        let orderId = Int(("\(info["orderid"]! as! NSNumber)"))
                        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
                        VC1.isAddTrack = true
                        VC1.orderID = orderId
                        screamNavig!.pushViewController(VC1, animated: true)
                    }
                }
            }
        }
        else
        {
            if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
            {
                
                let strType =  ("\(info["ntype"]! as! NSNumber)")
                let strmsg = info["alert"]! as! String
                print("Type: \(strType)")
                print("msg: \(strmsg)")
                var strTitle = "Congratulations"
                switch (strType)
                {
                case "\(notifiType.cntrequest.rawValue)":
                    strTitle = "New Friend Request"
                    break
                case "\(notifiType.pItem.rawValue)":
                    strTitle = "Congrtulation"
                    break
                case "\(notifiType.pLike.rawValue)":
                    strTitle = "Post Like Notification"
                    break
                case "\(notifiType.pComment.rawValue)":
                    strTitle = "Post Comment Notification"
                    break
                case "\(notifiType.itmTrack.rawValue)":
                    strTitle = "You received new text message"

                    break
                    
                case "\(notifiType.addTrackNo.rawValue)":
                    strTitle = "You received new text message"
                    
                    break
                    
                default:
                    break
                }
    
                    let notificaion = MPGNotification(title: strTitle, subtitle: strmsg, backgroundColor: UIColor.black, iconImage: nil)
                    notificaion?.duration = 5.0;
                    notificaion?.swipeToDismissEnabled = false;
                    notificaion?.animationType = .snap
                    notificaion?.fullWidthMessages = true
                    notificaion?.hostViewController = window?.rootViewController
                    notificaion?.show()
            }
        }
    }
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            
            let mgradmin = AdminManager.adminManager
    
            if(url.scheme == "com.googleusercontent.apps.638589596844-tfr5bjos3og2gn8fuavaej7iicd24hfu"){
                return GIDSignIn.sharedInstance().handle(url,
                    sourceApplication: sourceApplication,
                    annotation: annotation)
            }
                
            if url.scheme == "com.simform.screamxo.coinbase-oauth" {
                CoinbaseOAuth.finishAuthentication(for: url, clientId: mgradmin.bitcoincID, clientSecret: mgradmin.bitcoincSecret, completion: { (result : Any?, error: Error?) -> Void in
                    if error != nil {
                        // Could not authenticate.
                    } else {
                        // Tokens successfully obtained!
                        // Do something with them (store them, etc.)
                        if let result = result as? [String : AnyObject] {
                            if (result["access_token"] as? String) != nil {
                                NotificationCenter.default.post(name: Notification.Name(rawValue: constant.forbitcoinprocess), object: result)


                            }
                        }
                        // Note that you should also store 'expire_in' and refresh the token using CoinbaseOAuth.getOAuthTokensForRefreshToken() when it expires
                    }
                })
                return true
                
            } else if (url.scheme == "msal5494c57c-8e9a-47cb-82da-adcd4be5a304") {
                MSALPublicClientApplication.handleMSALResponse(url)
                
            } else if DBSession.shared().handleOpen(url) {
                
                    if DBSession.shared().isLinked() {
                        return true
                    }
                
                
            }else {
//                return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
                
                
                let handled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
                if handled {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didLinkToDropboxAccountNotification"), object: nil)
                    return handled
                }
                // If the SDK did not handle the incoming URL, check it for app link data
//                var parsedUrl = BFURL(inboundURL: url, sourceApplication: sourceApplication)
//                if parsedUrl.appLinkData() {
//                    var targetUrl = parsedUrl.targetURL()
//                    // ...process app link data...
//                    return true
//                }
                
                // ...add any other custom processing...
                
                return true
            }
     return true
    }
    
    func application(_ application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation)
    {
    
    }
    
    // MARK: - Location Methods
    
    func initLocationManager() {
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //locationManager.locationServicesEnabled
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        if (error != nil)  {
            if (seenError == false) {
                seenError = true
                print(error, terminator: "")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locationFixAchieved == false) {
            locationFixAchieved = true
            let locationArray = locations as NSArray
            let locationObj = locationArray.lastObject as! CLLocation
            let coord = locationObj.coordinate
            
            lat = coord.latitude
            lon = coord.longitude
            strLat = String(format: "%.5f", coord.latitude)
            strLon = String(format: "%.5f", coord.longitude)
            print(strLat)
            print(strLon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
            var shouldIAllow = false
            
            switch status {
            case CLAuthorizationStatus.restricted:
                locationStatus = "Restricted Access to location"
                
            case CLAuthorizationStatus.denied:
                locationStatus = "User denied access to location"
                
            case CLAuthorizationStatus.notDetermined:
                locationStatus = "Status not determined"
            default:
                locationStatus = "Allowed to location Access"
                shouldIAllow = true
                
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "LabelHasbeenUpdated"), object: nil)
            if (shouldIAllow == true) {
                NSLog("Location to Allowed")
                // Start location services
                locationManager.startUpdatingLocation()
            } else {
                NSLog("Denied access: \(locationStatus)")
            }
    }
    // MARK: - orientation Methods
    
    
    func rotationType() {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            landScape = "landscape"
            print("Landscape")
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("Portrait")
            landScape = "landscape"
        }
        
    }
    
    
    func rotated()
    {
        if(UIDeviceOrientationIsLandscape(UIDevice.current.orientation))
        {
//            
//            if (self.fullScreenVideoIsPlaying==true) {
//                
//                let value = UIInterfaceOrientation.landscapeLeft.rawValue
//                UIDevice.current.setValue(value, forKey: "orientation")
//                UIInterfaceOrientationMask.all
//            }
//            else
//            {
//                
//                let value = UIInterfaceOrientation.portrait.rawValue
//                UIDevice.current.setValue(value, forKey: "orientation")
//                UIInterfaceOrientationMask.portraitUpsideDown
//            }
//            landScape = ""
//            print("landscape")
//        }
//        
//        if(UIDeviceOrientationIsPortrait(UIDevice.current.orientation))
//        {
//            if (self.fullScreenVideoIsPlaying==true) {
//                
//                let value = UIInterfaceOrientation.portrait.rawValue
//                UIDevice.current.setValue(value, forKey: "orientation")
//                UIInterfaceOrientationMask.portraitUpsideDown
//            }
//            print("Portrait")
        }
        
    }
    
    func ResizeImage(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        
        if let image = image {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return newImage
        } else {
            return nil
        }
    }
    
    // MARK:---------------
    // MARK: Watch Connectivity Methods
    // MARK:---------------
    func sendData(_ Dicdata: [String : AnyObject]) {
        
        if(self.session.isReachable)
        {
            
            let usr = UserManager.userManager
            let apiusr = APIManager.apiManager
            
            var emptyDic:[String : AnyObject] = [:]
            
            if let id = usr.userId {
                emptyDic["id"] = id as AnyObject
            }
            
            if let session = apiusr.sessionToken {
                emptyDic["session"] = session as AnyObject
            }
            
            if let udevice = apiusr.deviceID {
                emptyDic["udevice"] = udevice as AnyObject
            }
            
            emptyDic["home"] = Dicdata as AnyObject
            
            self.session.sendMessage(["value" : emptyDic], replyHandler: nil, errorHandler: { (err : NSError) in
                
                print("-------Erorr-----\(err.localizedDescription)")
                
            } as? (Error) -> Void)
            
            // self.tfInput.text = ""
        }
        else
        {
            
            let usr = UserManager.userManager
            let apiusr = APIManager.apiManager
            
            var emptyDic:[String : AnyObject] = [:]
            if let id = usr.userId {
                emptyDic["id"] = id as AnyObject
            }             
            if let session = apiusr.sessionToken {
                emptyDic["session"] = session as AnyObject
            }
            
            if let udevice = apiusr.deviceID {
                emptyDic["udevice"] = udevice as AnyObject
            }
            do {
                self.session.transferUserInfo(emptyDic)
                try self.session.updateApplicationContext(emptyDic)
            }
            catch {
                print("error")
            }
        }
    }
    
    func initSession(){
        
        if(WCSession.isSupported())
        {
            self.session = WCSession.default()
            self.session.delegate = self
            self.session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]){
        
        DispatchQueue.main.async(execute: {
        })
    }
    
    
    func getEmojiName(_ image: UIImage) -> String?
    {
        for (emojiName, emojiItem) in customEmojis.emojiItems {
            if image.isEqual(emojiItem) {
                return emojiName
            }
        }
        return nil
    }
    
    func replaceEmoji(_ emojiName: String, mutableStrDesc: inout NSMutableAttributedString) {
        let textAttachment = MyTextAttachment()
        textAttachment.image = UIImage(named: emojiName)
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        let mutAttrString = NSMutableAttributedString()
        mutAttrString.append(attrStringWithImage)
        
        while mutableStrDesc.mutableString.contains(emojiName)
        {
            let range = mutableStrDesc.mutableString.range(of: emojiName)
            mutableStrDesc.replaceCharacters(in: range, with: mutAttrString)
        }
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(notification.request.content.userInfo)
        if let info = notification.request.content.userInfo["aps"] as? Dictionary<String, AnyObject>
        {
            let strType =  ("\(info["ntype"]! as! NSNumber)")
            let strmsg = info["alert"]! as! String
            print("Type: \(strType)")
            print("msg: \(strmsg)")
            let strTitle = "ScreamXO"
            let notificaion = MPGNotification(title: strTitle, subtitle: strmsg, backgroundColor: UIColor.black, iconImage: nil)
            notificaion?.duration = 5.0;
            notificaion?.swipeToDismissEnabled = false;
            notificaion?.animationType = .snap
            notificaion?.fullWidthMessages = true
            notificaion?.hostViewController = window?.rootViewController
            notificaion?.show()
            if Int(strType) == notificationType.notiNewMsg.rawValue
            {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "newMsgCome"), object: nil, userInfo: info)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshChatHead"), object: nil, userInfo: info)
            }
        }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
        
        var  userInfo = response.notification.request.content.userInfo as! Dictionary<String, AnyObject>
        print("Recived: \(userInfo)")
        //Parsing userinfo:
        //var temp : NSDictionary = userInfo
        
        let state: UIApplicationState = UIApplication.shared.applicationState
        if state == .background || state == .inactive
        {
            if let info = userInfo["aps"] as? Dictionary<String, AnyObject>
            {
                let strType = ("\(info["ntype"]! as! NSNumber)")
                let usr = UserManager.userManager
                if usr.userId != nil {
                    let notifiMgr = NotificationManager.notificationManager
                    notifiMgr.decrebadgeNotification()
                    let badgetotal:Int = UIApplication.shared.applicationIconBadgeNumber
                    UIApplication.shared.applicationIconBadgeNumber = (badgetotal-1)
                    //navig
                    if (Int(strType) == notificationType.notiLike.rawValue || Int(strType) == notificationType.notiComment.rawValue) || Int(strType) == notificationType.notiTagPost.rawValue || Int(strType) == notificationType.notiTagComment.rawValue
                    {//other_user_id
                        
                        
                        
                        let detailID = ("\(info["detailid"]! as! NSNumber)")
                        let strsubType =  ("\(info["posttype"]! as! NSNumber)")
                        let mgrItm = PostManager.postManager
                        mgrItm.clearManager()
                        let objpost: PostDetailsVC = stPOST.instantiateViewController(withIdentifier: "PostDetailsVC") as! PostDetailsVC
                        mgrItm.PostId = detailID
                        if strsubType == "0"
                        {
                            objpost.Posttype=0;
                        }
                        else
                        {
                            objpost.Posttype=2;
                            
                        }
                        screamNavig!.pushViewController(objpost, animated: true)
                    }
                    else if Int(strType) == notificationType.notiRequest.rawValue
                        
                    {
                        let objfriends: FriendsVC = strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=1;
                        objfriends.isFromNotify = true
                        screamNavig!.pushViewController(objfriends, animated: true)
                    } else if Int(strType) == notificationType.notiAccept.rawValue {
                        
                        let objfriends: FriendsVC = strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                        objfriends.ispushtype=2
                        screamNavig!.pushViewController(objfriends, animated: true)
                    }  else if Int(strType) == notificationType.notiPurchase.rawValue || Int(strType) == notificationType.notiReviewProduct.rawValue {
                        
                        let detailID = ("\(info["detailid"]! as! NSNumber)")
                        
                        let mgrItm = ItemManager.itemManager
                        mgrItm.clearManager()
                        mgrItm.ItemId = detailID
                        let objitm: ItemDetails = stShopItem.instantiateViewController(withIdentifier: "ItemDetails") as! ItemDetails
                        screamNavig!.pushViewController(objitm, animated: true)
                    } else if Int(strType) == notificationType.notiPurchase.rawValue || Int(strType) == notificationType.notiReviewProduct.rawValue {
                        let objitm: Profile = stShopItem.instantiateViewController(withIdentifier: "Profile") as! Profile
                        screamNavig!.pushViewController(objitm, animated: true)
                    } else if Int(strType) == notificationType.notiPurchase.rawValue || Int(strType) == notificationType.notiReviewProduct.rawValue {
                        let detailID = ("\(info["detailid"]! as! NSNumber)")
                        let objitm: OtherProfile = stShopItem.instantiateViewController(withIdentifier: "OtherProfile") as! OtherProfile
                        screamNavig!.pushViewController(objitm, animated: true)
                    } else if Int(strType) == notificationType.addTrackNo.rawValue {
                            let mgrItm = ItemManager.itemManager
                            mgrItm.clearManager()
                        
                            let itemID = Int("\(info["itemid"]! as! NSNumber)")
                            let detailID = ("\(info["detailid"]! as! NSNumber)")
                            mgrItm.ItemId = detailID
                            let orderId = Int(("\(info["orderid"]! as! NSNumber)"))
                            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
                            VC1.isAddTrack = true
                            VC1.orderID = orderId
                            VC1.item_id = itemID
                            screamNavig!.pushViewController(VC1, animated: true)
                        
                    }else if Int(strType) == notificationType.notiNewMsg.rawValue {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "newMsgCome"), object: nil, userInfo: info)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshChatHead"), object: nil, userInfo: info)
                        if let sideVC = (UIApplication.shared.delegate?.window??.rootViewController as! SnapContainerViewController).middleVc as? RESideMenu {
                            
                            if (sideVC.contentViewController as? UINavigationController) != nil {
                                let chatVC = stMsg.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                                if info["itemid"] as! Int != 0 {
                                    chatVC.item_id = info["itemid"] as? Int
                                }
                                chatVC.otherID = info["senderid"] as? Int
                                chatVC.userName = info["username"] as? String
                                screamNavig?.pushViewController(chatVC, animated: true)
                            }
                        }
                    } else if Int(strType) == notificationType.notiTrackingDetail.rawValue {
                        
                        
                        if let sideVC = (UIApplication.shared.delegate?.window??.rootViewController as! SnapContainerViewController).middleVc as? RESideMenu {
                            
                            if let navController = sideVC.contentViewController as? UINavigationController {
                                
                                if navController.viewControllers.count == 1 {
                                    
                                    if let messageVC = navController.viewControllers[0] as? MessagingVC {
                                        
                                        if messageVC.pageMenu?.currentPageIndex == 2 {
                                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshNetworkVC"), object: nil, userInfo: [:])
                                        } else {
                                            messageVC.pageMenu?.moveToPage(2)
                                        }
                                        return
                                    }
                                    
                                    let objMessaging = stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
                                    screamNavig = XXNavigationController(rootViewController: objMessaging)
                                    screamNavig!.setNavigationBarHidden(true, animated: false)
                                    sideVC.setContentViewController(screamNavig, animated: true)
                                    sideVC.hideViewController()
                                    objMessaging.isTrackNotify = true
                                    
                                } else {
                                    
                                    navController.popToViewController(navController.viewControllers[0], animated: false)
                                    
                                    if let messageVC = navController.viewControllers[0] as? MessagingVC {
                                        
                                        if messageVC.pageMenu?.currentPageIndex == 2 {
                                            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshNetworkVC"), object: nil, userInfo: [:])
                                        } else {
                                            messageVC.pageMenu?.moveToPage(2)
                                        }
                                        
                                        return
                                    }
                                    
                                    let objMessaging = stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
                                    screamNavig = XXNavigationController(rootViewController: objMessaging)
                                    screamNavig!.setNavigationBarHidden(true, animated: false)
                                    sideVC.setContentViewController(screamNavig, animated: true)
                                    sideVC.hideViewController()
                                    objMessaging.isTrackNotify = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: <Setup circle menu>

extension AppDelegate: CircleMenuDelegate {
    
    func setupCircleMenu() {
        
        let myPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(myPanAction))
        myPanGestureRecognizer.minimumNumberOfTouches = 1
        myPanGestureRecognizer.maximumNumberOfTouches = 1
        
        // btnObj1
        let view = self.window?.rootViewController?.view
        let roundButtonWidth: CGFloat = 40.0
        let roundButtonHeight: CGFloat = 40.0
        
        if circleMenuLoaded {
            constant.btnObj1 = CircleMenu(frame: CGRect(x: circleMenuOrigin.x, y: circleMenuOrigin.y, width: roundButtonWidth, height: roundButtonHeight), normalIcon: "menu-icon_menu", selectedIcon: "menu-icon_close", buttonsCount: constant.itemsGSM.count, duration: 0.5, distance: 100)
        } else {
            constant.btnObj1 = CircleMenu(frame: CGRect(x: (view!.frame.maxX - roundButtonWidth), y: (view!.frame.maxY - roundButtonHeight), width: roundButtonWidth, height: roundButtonHeight ), normalIcon: "menu-icon_menu", selectedIcon: "menu-icon_close", buttonsCount: constant.itemsGSM.count, duration: 0.5, distance: 100)
            circleMenuOrigin = constant.btnObj1.frame.origin
        }
        
        constant.btnObj1.layer.cornerRadius = constant.btnObj1.frame.size.width / 2
        constant.btnObj1.backgroundColor = colors.kPinkColour
        constant.btnObj1.delegate = self
        constant.btnObj1.accessibilityIdentifier = "btnObj1"
        constant.btnObj1.addTarget(self, action: #selector(menuBtnTapped), for: UIControlEvents.touchUpInside)
        self.window?.rootViewController?.view.addSubview(constant.btnObj1)
        constant.btnObj1.addGestureRecognizer(myPanGestureRecognizer)
        
        // btnObj2
        constant.btnObj2 = CircleMenu(frame: CGRect(x: constant.btnObj1.frame.origin.x, y: constant.btnObj1.frame.origin.y, width: roundButtonWidth, height: roundButtonHeight), normalIcon: "", selectedIcon: "", buttonsCount: constant.itemsGSM.count, duration: 0.5, distance: 210)
        constant.btnObj2.backgroundColor = UIColor(red: 0.73, green: 0.73, blue: 0.73, alpha: 1.0)
        constant.btnObj2.layer.cornerRadius = constant.btnObj2.frame.size.width / 2
        constant.btnObj2.delegate = self
        constant.btnObj2.isHidden = true
        constant.btnObj2.accessibilityIdentifier = "btnObj2"
        
        self.window?.rootViewController?.view.insertSubview(constant.btnObj2, belowSubview: constant.btnObj1)
        circleMenuLoaded = true
    }
    
    func menuBtnTapped() {
        if constant.btnObj1.tag == 0 {
            constant.btnObj1.onTap()
            if let firstTimeMenuLoaded = Defaults.firstTimeMenuLoaded.value as? String {
                if firstTimeMenuLoaded != "1" || constant.btnObj2.buttonsIsShown() {
                    constant.btnObj2.onTap()
                }
            } else {
                constant.btnObj2.onTap()
            }
            
        }
    }
    
    func myPanAction(_ recognizer: UIPanGestureRecognizer) {
        
        let point: CGPoint = recognizer.location(in: recognizer.view?.superview)
        
        let boundsRect = CGRect(x: CGFloat(0), y: CGFloat(30), width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 30.0)
        
        if ((recognizer.state != UIGestureRecognizerState.ended) && (recognizer.state != UIGestureRecognizerState.failed)) {
            
            if boundsRect.contains(point) {
                recognizer.view?.center = recognizer.location(in: recognizer.view?.superview)
            } else{
                print("out of border => \(String(describing: recognizer.view?.center))")
                
            }
        }
        constant.btnObj2.frame.origin = constant.btnObj1.frame.origin
        circleMenuOrigin = constant.btnObj1.frame.origin
    }
    
    // MARK: Position circle menu
    
    func positiongsmAtBottom(viewController: UIViewController, position: String) {
        //        constant.btnObj1.gestureRecognizers?[0].isEnabled = false
        if constant.btnObj1.buttonsIsShown() {
            constant.btnObj1.onTap()
        }
        if position == PositionMenu.bottomRight.rawValue {
            UIView.animate(withDuration: 0.1, animations: {
                constant.btnObj1.frame.origin.x = viewController.view.frame.maxX - constant.btnObj1.frame.width
                constant.btnObj1.frame.origin.y = viewController.view.frame.maxY - constant.btnObj1.frame.height
            })
        } else if position == PositionMenu.topLeft.rawValue {
            UIView.animate(withDuration: 0.1, animations: {
                constant.btnObj1.frame.origin.x = viewController.view.frame.minX
                constant.btnObj1.frame.origin.y = viewController.view.frame.minY + 16.0
            })
        } else if position == PositionMenu.topRight.rawValue {
            UIView.animate(withDuration: 0.1, animations: {
                constant.btnObj1.frame.origin.x = viewController.view.frame.maxX - constant.btnObj1.frame.width
                constant.btnObj1.frame.origin.y = viewController.view.frame.minY + 16.0
            })
        }
        constant.btnObj2.frame.origin = constant.btnObj1.frame.origin
        circleMenuOrigin = constant.btnObj1.frame.origin
    }
    
    func repositiongsm() {
        constant.btnObj1.gestureRecognizers?[0].isEnabled = true
        if constant.btnObj1.buttonsIsShown() {
            constant.btnObj1.onTap()
        }
    }
    
    
    // MARK: <CircleMenuDelegate>
    
    func circleMenu(_ circleMenu: CircleMenu, willDisplay button: UIButton, atIndex: Int) {
        var itemsGSM: [Int : String] = constant.itemsGSM
        
        if let snapContainer = self.window?.rootViewController as? SnapContainerViewController {
            
            if let navigationController = snapContainer.middleVc.childViewControllers[1] as? UINavigationController {
                
                if let topVC = navigationController.topViewController {
                    switch topVC {
                        
                    case is HomeScreen:
                        itemsGSM[6] = "menu-ico-lock"
                        
                    case is ShopSearchVC:
                        itemsGSM[0] = "menu-ico-post"
                        itemsGSM[7] = "menu-ico-filter"
                        
                    case is ItemDetails:
                        itemsGSM[0] = "menu-ico-post"
                        itemsGSM[7] = "menu-ico-dot"
                        
                    case is Profile:
                        itemsGSM[7] = "menu-ico-chat"
                        
                    case is SettingVC:
                        itemsGSM[7] = "menu-ico-chat"
                        
                    case is WalletViewController:
                        itemsGSM[7] = "menu-ico-chat"
                        
                    case is FriendsVC:
                        itemsGSM[7] = "menu-ico-chat"
                        
                        
                    case is OtherProfile:
                        itemsGSM[7] = "menu-ico-chat"
                        
                    case is PostDetailsVC:
                        itemsGSM[0] = "menu-ico-post"
                        itemsGSM[7] = "menu-ico-dot"
                        
                    case is World:
                        itemsGSM[7] = "menu-ico-filter"
                        
                    case is PostVC:
                        itemsGSM[7] = "menu-ico-chat"
                        
                    default:
                        break
                    }
                }
            }
        }
        
        if circleMenu == constant.btnObj1 {
            button.backgroundColor = constant.roundButtonsBgColor
            button.setImage(UIImage(imageLiteralResourceName: (itemsGSM[atIndex])!), for: UIControlState())
            // set highlited image
            let highlightedImage  = UIImage(imageLiteralResourceName: (itemsGSM[atIndex])!).withRenderingMode(.alwaysTemplate)
            button.setImage(highlightedImage, for: .highlighted)
            button.tintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.3)
        } else {
            button.frame.size.width = 50.0
            button.frame.size.height = 25.0
            button.backgroundColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha: 1.0)
            button.titleLabel?.font = UIFont(name: fontsName.KfontproxiBold, size: 10.0)
            button.layer.cornerRadius = 5.0
            
            if atIndex < 4 {
                button.frame.origin.x = 0
                button.frame.origin.y = 7.5
            } else {
                button.frame.origin.x = 55
                button.frame.origin.y = 7.5
                
            }
            button.setTitle(constant.gsmButton2Titles[atIndex], for: UIControlState())
            button.isUserInteractionEnabled = true
        }
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonWillSelected button: UIButton, atIndex: Int) {
        if circleMenu == constant.btnObj1 {
            menuBtnTapped()
            navigateMenuAction(atIndex)
        }
    }
    
    func circleMenu(_ circleMenu: CircleMenu, buttonDidSelected button: UIButton, atIndex: Int) {
        print("button did selected: \(atIndex)")
    }
    
    
    
    func navigateMenuAction(_ index: Int) {
        if UserManager.userManager.userId == "1" {
            let objLogin = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            objAppDelegate.screamNavig = UINavigationController(rootViewController: objLogin)
            objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
            objAppDelegate.window?.rootViewController = objAppDelegate.screamNavig
        } else {
        if let snapContainer = self.window?.rootViewController as? SnapContainerViewController {
            
            if let navController = snapContainer.middleVc.childViewControllers[1] as? UINavigationController {
                if let topVC = navController.topViewController {
                    switch index {
                        
                    case 0:
                        switch topVC {
                        case is ItemDetails:
                            let objItmDetails = topVC as? ItemDetails
                            objItmDetails?.btnGSMClicked(index)
                            
//                        case is Profile:
//                            let objItmDetails = topVC as? Profile
//                            objItmDetails?.btnGSMClicked(index)
//                            
//                        case is OtherProfile:
//                            let objItmDetails = topVC as? OtherProfile
//                            objItmDetails?.btnGSMClicked(index)
                            
                        case is PostDetailsVC:
                            let objItmDetails = topVC as? PostDetailsVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is ShopSearchVC:
                            let objShopSearchVC = topVC as? ShopSearchVC
                            objShopSearchVC?.btnGSMClicked(index)
                            
                        default:
                            
                            let objMessaging: PostVC = stWallet.instantiateViewController(withIdentifier: "PostVC") as! PostVC
                            
                        
                            
                            //let objMessaging = stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
                            screamNavig = XXNavigationController(rootViewController: objMessaging)
                            screamNavig!.setNavigationBarHidden(true, animated: false)
                            navController.sideMenuViewController.setContentViewController(screamNavig, animated: true)
                            navController.sideMenuViewController.hideViewController()
                            
                            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                                sideMenuLeftVC.selectedrow = 3
                            }
                            
                            
                        }
                        
                    case 1:
                        switch topVC {
                        case is FriendsVC:
                            break
                            
                        default:
                            let objfriends : FriendsVC = strFriends.instantiateViewController(withIdentifier: "FriendsVC") as! FriendsVC
                            screamNavig = XXNavigationController(rootViewController: objfriends)
                            screamNavig!.setNavigationBarHidden(true, animated: false)
                            navController.sideMenuViewController.setContentViewController(screamNavig!, animated: true)
                            navController.sideMenuViewController.hideViewController()
                            
                            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                                sideMenuLeftVC.selectedrow = 4
                            }
                        }
                    case 2:
                        switch topVC {
                            
                        case is ShopSearchVC:
                            break
                            
                        default:
                            let objshopsearch : ShopSearchVC = stShopItem.instantiateViewController(withIdentifier: "ShopSearchVC") as! ShopSearchVC
                            screamNavig = XXNavigationController(rootViewController: objshopsearch)
                            screamNavig!.setNavigationBarHidden(true, animated: false)
                            navController.sideMenuViewController.setContentViewController(screamNavig!, animated: true)
                            navController.sideMenuViewController.hideViewController()
                            
                            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                                sideMenuLeftVC.selectedrow = 2
                            }
                        }
                        
                    case 3:
                        switch topVC {
                            
                        case is World:
                            break
                            
                        default:
                            //let objworld: World =  stWallet.instantiateViewController(withIdentifier: "World") as! World
                            
                             let objworld: WalletViewController =  stWallet.instantiateViewController(withIdentifier: "Wallet") as! WalletViewController
                             
                            screamNavig = XXNavigationController(rootViewController: objworld)
                            screamNavig!.setNavigationBarHidden(true, animated: false)
                            navController.sideMenuViewController.setContentViewController(screamNavig!, animated: true)
                            navController.sideMenuViewController.hideViewController()
                            
                            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                                sideMenuLeftVC.selectedrow = 1
                            }
                        }
                        
                    case 4:
                        switch topVC {
                        
                        case is MessagingVC:
                            break
                        default:
                          setSettingVC()
                        }
                        
                    case 5:
                        switch topVC {
                        case is Profile:
                            break
                        default:
                            let objprofile : Profile = stProfile.instantiateViewController(withIdentifier: "Profile") as! Profile
                            screamNavig = XXNavigationController(rootViewController: objprofile)
                            screamNavig!.setNavigationBarHidden(true, animated: false)
                            navController.sideMenuViewController.setContentViewController(screamNavig!, animated: true)
                            navController.sideMenuViewController.hideViewController()
                            
                            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                                sideMenuLeftVC.selectedrow = 5
                            }
                        }
                        
                    case 6:
                        switch topVC {
                            
                        case is ShopSearchVC:
                            let objShopSearchVC = topVC as? ShopSearchVC
                            objShopSearchVC?.btnGSMClicked(index)
                            
                        case is ItemDetails:
                            let objItmDetails = topVC as? ItemDetails
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is PostDetailsVC:
                            let objItmDetails = topVC as? PostDetailsVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is HomeScreen:
                            let objHomeScreen = topVC as! HomeScreen
                            objHomeScreen.btnGSMClicked(index)
                            
                        default:
                            setHomeScreenVC()
                        }
                        
                    case 7:
                        switch topVC {
                            
                        case is SellerHistoryVC:
                            let objItmDetails = topVC as? SellerHistoryVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is PurchasedHistory:
                            let objItmDetails = topVC as? PurchasedHistory
                            objItmDetails?.btnGSMClicked(index)
                            
                            
                        case is ItemDetails:
                            let objItmDetails = topVC as? ItemDetails
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is ShopSearchVC:
                            let objShopSearchVC = topVC as? ShopSearchVC
                            objShopSearchVC?.btnGSMClicked(index)
                            
                        case is Profile:
                            let objItmDetails = topVC as? Profile
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is SettingVC:
                            let objItmDetails = topVC as? SettingVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is WalletViewController:
                            let objItmDetails = topVC as? WalletViewController
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is FriendsVC:
                            let objItmDetails = topVC as? FriendsVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is OtherProfile:
                            let objItmDetails = topVC as? OtherProfile
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is PostDetailsVC:
                            let objItmDetails = topVC as? PostDetailsVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is PostVC:
                            let objItmDetails = topVC as? PostVC
                            objItmDetails?.btnGSMClicked(index)
                            
                        case is World:
                            let objWorld = topVC as? World
                            objWorld?.btnGSMClicked(index)
                            
                        case is HomeScreen:
                            let objHomeScreen = topVC as? HomeScreen
                            objHomeScreen?.btnGSMClicked(index)
                            
                            
                        default:
                            break
                        }
                        
                    default:
                        break
                    }
                }
            }
        }
        }
    }
    
    func setSettingVC() {
        if let snapContainer = self.window?.rootViewController as? SnapContainerViewController {
            
            if let navController = snapContainer.middleVc.childViewControllers[1] as? UINavigationController {
                let objSetting : SettingVC = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
                objAppDelegate.screamNavig = XXNavigationController(rootViewController: objSetting)
                objAppDelegate.screamNavig!.setNavigationBarHidden(true, animated: false)
                navController.sideMenuViewController.setContentViewController(screamNavig!, animated: true)
                navController.sideMenuViewController.hideViewController()
                
                if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                    sideMenuLeftVC.selectedrow = 6
                }
            }
        }
    }
    
    func setHomeScreenVC() {
        if let snapContainer = self.window?.rootViewController as? SnapContainerViewController {
            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                sideMenuLeftVC.sideMenuViewController.hideViewController()
                setViewAfterLogin()
            }
            if let sideMenuLeftVC = snapContainer.middleVc.childViewControllers[0] as? sideMenuLeftVC {
                sideMenuLeftVC.selectedrow = 0
            }
        }
    }
}
