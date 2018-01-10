//
//  APIManager.swift
//  ScreamXO
//
//  Created by Tejas Ardeshna on 17/09/15.
//  Copyright (c) 2015 ScreamXO Ltd All rights reserved.
//

import Foundation
import AFNetworking

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


// we need a custom serializer for AFNetworking to be able to get at response data after an error (particularly for registration errors)
class TJJSONResponseSerializer: AFJSONResponseSerializer {
    
//    override func responseObjectForResponse(response: NSURLResponse!, data: NSData!) throws -> AnyObject
//    {
//        var json: AnyObject? = try super.responseObjectForResponse(response, data: data)
//        do {
//            try self.validateResponse(response as! NSHTTPURLResponse, data: data)
//        } catch let error as NSError {
//            
//            if error.memory != nil {
//                var errorValue    = error.memory!
//                var userInfo      = errorValue.userInfo
//                userInfo["data"] = json
//                error.memory      = NSError(domain: errorValue.domain, code: errorValue.code, userInfo: userInfo)
//            }
//        }
//        return json!
//        
//    }
    
}

enum APIResult : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}

open class APIManager {
    
   
    
    //service complition block
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResult)  -> Void
    
    // static properties get lazy evaluation and dispatch_once_t for free
    struct Static {
        static let instance = APIManager()
    }
    
    // this is the Swift way to do singletons
    class var apiManager: APIManager {
        return Static.instance
    }
    
    // NB: include trailing slashes in Jottr endpoint strings!
    open class APIConstants {
        
        // URL construction
        
         //local http://192.168.1.82/screamXo/mobileservice
        static let ScreamXOBaseUrl           = "https://api.screamxo.com/mobileservice/"
        static let ScreamXOAPIVersion        = "v1"
        
        
        static let KAUTHURL  =  "https://api.instagram.com/oauth/authorize"
        static let kAPIURl = "https://api.instagram.com/v1/users/"
        static let KCLIENTID = "d737eff40c4b426c899d13b305fc6baa"
        static let KCLIENTSERCRET = "aadf64c1cfc54087afef5f24a0f33248"
        static let kREDIRECTURI = "igd737eff40c4b426c899d13b305fc6baa://authorize"
        static let kUSER = "self/"
        static let kACCESSTOKEN = "kaccesstoken"
        
        
        // NSUserDefaults persistence keys
        static let ScreamXOTokenKey                     = "ScreamXOTokenKey"
        static let ScreamXOTokendeviceKey                     = "ScreamXOTokendeviceKey"
        static let ScreamXOLastSyncDate                 = "ScreamXOLastSyncDate"
        static let ScreamXOChallengeUpdateSyncDate      = "ScreamXOChallengeUpdateSyncDate"
        static let ScreamXOIndividualChallengeUpdateSyncDate      = "ScreamXOIndividualChallengeUpdateSyncDate"
        static let ScreamXOActivitySyncDate             = "ScreamXOActivitySyncDate"
        
        static let createUserEndpoint           = "Auth/signup"
        static let loginEndpoint           = "Auth/signin"
        static let forgotEndpoint           = "Auth/forgotpassword"
        static let verifyagainEndpoint           = "Auth/verificationmail"
        static let verifyuserEndpoint           = "Auth/verifyuser"
        static let editProfileEndpoint           = "Users/updateprofile"
        static let updatepaymentAccount           = "Users/updateaccount"
        static let processForBoost           = "Stripepaymentnew/process_boost"
        static let purchaseListEndPoint           = "Users/getpurchasedlist"
        static let addReview           = "Items/addreview"
        static let requesttracking           = "Items/notifyItemOwnerForTrackingUpdate"
        static let getpaymentAccount           = "Users/getaccount"
        static let logOutEndpoint               = "Auth/logout"
        static let getpagesEndPoint               = "Auth/getpages"
        static let updateBadgeEndpoint               = "Users/updatepbadge"
        static let createPostEndPoint            = "Posts/createpost"
        static let categoriesListEndPoint        = "Categories/listAllCategories/"
        static let Item_ListShopEndPoint                = "Users/getshopdashboard/"
        static let Item_ListcategoryEndPoint                = "Categories/getitembycat/"
        static let Item_ListSearchEndPoint                = "Categories/searchitembystring/"
        static let Item_creationEndPoint                = "Items/createitem"
        static let Item_editEndPoint                = "Items/edititem"
        static let Item_deleteEndPoint                = "Items/deleteitem"
        static let Item_purchaseEndPoint                = "Items/purchaseitem"
        static let Item_purchaseStripepayment              = "Stripepaymentnew/process"
        static let StripeProcessBitcoin = "Stripebitcoinpayment/process_bitcoin"
        static let StripeBitcoinPaymentFinalprocess = "Stripebitcoinpayment/finalprocess"
        
        
        //--------------------------
         static let Stripebitcoinpayment = "Stripebitcoinpayment/process_boost"
         static let StripebitcoinpaymentfinalBoostprocess = "Stripebitcoinpayment/finalBoostprocess"
        
        
        static let Stripealipaypayment = "Stripealipaypayment/process_boost"
        static let StripealipaypaymentfinalBoostprocess = "Stripealipaypayment/finalBoostprocess"
        
        //--------------------------
        
        
        static let StripealipaypaymentProcessalipay = "Stripealipaypayment/process_alipay"
        static let Stripealipaypaymentfinalprocess = "Stripealipaypayment/finalprocess"
        
        static let Item_transferMoney              = "Users_wallet/sendMoney"
        static let userWalletListNew = "Users_wallet/userWalletListNew"
        static let genrateTransactionReceipt = "Walletorderpayment/generateReceipt/"
        static let Item_purchaseStripeFinalpayment              = "Stripepaymentnew/finalprocess"
        static let Item_purchaseWalletFinalpayment              = "Walletorderpayment/finalprocess"
        static let finalBoostprocess              = "Stripepaymentnew/finalBoostprocess"
        static let WalletorderpaymentForBoost              = "Walletorderpayment/finalboostprocess"
        static let add_moneyInWallet              = "Stripepayment/addAmountToWallet"
        static let watchedItemListEndPoint    = "Items/listwatcheditem"
        static let ActiononWatchItem    = "Items/addwatcheditem"
        static let Item_search_shop                = "Items/purchaseitem"
        static let Shop_get_userEndPoint     = "Items/getitembyuid"
        static let Media_get_userEndPoint     = "Posts/getpostmediabyuid"
        static let Shopdetails_get_userEndPoint       = "Items/getitem"
        static let AddTrackingDetail = "Items/updatetrackingdetail"
        static let Post_get_userEndPoint       = "Posts/getpostbyuid"
        static let likePostEndPoint   = "Posts/likepost"
        static let getPostDetails          = "Posts/getpost"
        static let deletePostEndPoint          = "Posts/deletepost"
        static let getCOmmentEndPoint      = "Posts/getpostscomment"
        static let sendMessageEndPoint      = "Posts/createcomment"
        static let searchFriendEndPoint       = "Friends/searchFriends"
        static let searchFriendTagEndPoint       = "Friends/getfriendsearch"
        static let ViewFRequestListEndPoint           = "Friends/Friendrequestlist"
        static let suggestedFriendEndPoint            = "Friends/suggestedFriends"
        static let FriendListEndPoint            = "Friends/Friendlist"
        static let FBFriendListEndPoint            = "Friends/getfbFriends"
        static let TWFriendListEndPoint            = "Friends/gettwitterFriends"
        static let FinderFriendListEndPoint            = "Friends/fetchfriends"
        static let InviteByContactListEndPoint            = "Friends/invitefriends"
        
        static let isRegisteredEndpoint         = "registered"
        static let addFriendEndPoint       =    "Friends/Addfriend"
        static let acceptFriendEndPoint       = "Friends/Acceptfriend"
        static let rejectFriendEndPoint       = "Friends/Rejectfriend"
        static let  UserInfoEndPoint               = "Users/getuserbyid"
        static let DashBoardEndPoint          = "Users/Dashboradevents"
        
        static let worldendpoint          = "Users/getworldata"
        static let worldstreamendpoint          = "Users/getworldstream"
        static let worldmediaendpoint          = "Users/getworldmedia"

        
        static let DashBoardItemsEndPoint          = "Items/getdashboarditembyuid"
        static let DashBoardStreamsEndPoint = "Posts/getdashboardstream"
        static let DashBoardMediasEndPoint  = "Posts/getdashboardmedia"
        static let LikeListEndPoint  =          "Posts/getpostslike"
        static let UnBlockEndPoint  =          "Friends/Unblockfriend"

        static let BlockEndPoint  =          "Friends/Blockfriend"
        static let UnfriendEndPoint  =          "Friends/Unfriend"
        static let cancelFriendreEndPoint  =          "Friends/Cancelfriend"
        static let ReportAbuseEndPoint  =          "Posts/Reportpost"
        static let ReportItemAbuseEndPoint  =          "Items/Reportitem"
        
        static let deletecommentEndPoint   =  "Posts/deletecomment"

        static let BlockListEndPoint            = "Friends/Blockedlist"
        static let changePWDEndPoint            = "Users/updatepassword"
        static let getAllnotificationEndPoint   = "Notifications/getAllNotification"

        static let setnotiSettingEndPoint   = "Settings/Savesettings"
         static let getCardList   = "Stripepaymentnew/getCardList"
        static let createCustomer   = "Stripepaymentnew/createCustomer"
        static let addCard   = "Stripepaymentnew/addCard"
        

        static let getnotiSettingEndPoint   = "Settings/Getsettings"
        static let getadmindtEndPoint   = "Settings/getadmindetail"

        static let adptivepaymentEndPoint   = "Paypalpayment/chainpay"
        static let finalpaymentEndPoint   = "Paypalpayment/finalpaydetails"
        static let paypalform   = "Paypalpayment/pay_form"
        static let bitcoinpurchaseEndPoint   = "Paypalpayment/purchaseitem"
        static let sellerhistory   = "Users/getsolditemlist"
        static let privacySettings   = "Settings/Saveusersettings"
        
        static let getBuyerSenderMsgPosts = "Userchats/buyersellermessagelist"
        static let getFriendsMsgPosts = "Userchats/friendmessagelist"
        static let sendChatMsg = "Userchats/Sendmessage"
        static let getChatList = "Userchats/getchat"
        static let deleteMsg = "Userchats/deletemessage"
        static let deleteChat = "Userchats/deletechat"
        static let updateShippingAddress = "Users/updateshippingadress"
        static let getShippingAddress = "Users/getshippingaddress"
        static let getCountry = "Users/AddressLatLong"
        static let getCatWithSubCat = "Categories/listAllCategoriesNew"
       

        static let send_enquiry = "Settings/send_enquiry"
        

    }
    
    // needed for all AFNetworking requests
    let manager            =  AFHTTPSessionManager()
    
    
    
    // needed for session token persistence
    let userDefaults       = UserDefaults.standard
    
    // we get a session token on login from Jottr
    var sessionToken: String? {
        
        get {
            return userDefaults.object(forKey: APIConstants.ScreamXOTokenKey) as? String ?? nil
        }
        
        set (newValue) {
            if newValue != nil {
                
                userDefaults.set(newValue, forKey: APIConstants.ScreamXOTokenKey)
                userDefaults.synchronize()
            }
        }
        
    }
    var deviceID: String? {
        
        get {
            return userDefaults.object(forKey: APIConstants.ScreamXOTokendeviceKey) as? String ?? nil
        }
        
        set (newValue) {
            if newValue != nil {
                
                userDefaults.set(newValue, forKey: APIConstants.ScreamXOTokendeviceKey)
                userDefaults.synchronize()
            }
        }
        
    }
    var lastSyncDate: String? {
        
        get {
            return userDefaults.object(forKey: APIConstants.ScreamXOLastSyncDate) as? String ?? nil
        }
        
        set (newValue) {
            if newValue != nil {
                userDefaults.set(newValue, forKey: APIConstants.ScreamXOLastSyncDate)
                userDefaults.synchronize()
            }
        }
        
    }
    var lastChallengeUpdateSyncDate: String? {
        
        get {
            return userDefaults.object(forKey: APIConstants.ScreamXOChallengeUpdateSyncDate) as? String ?? nil
        }
        
        set (newValue) {
            if newValue != nil {
                userDefaults.set(newValue, forKey: APIConstants.ScreamXOChallengeUpdateSyncDate)
                userDefaults.synchronize()
            }
        }
        
    }
    var lastIndividualChallengeUpdateSyncDate: String? {
        
        get {
            return userDefaults.object(forKey: APIConstants.ScreamXOIndividualChallengeUpdateSyncDate) as? String ?? nil
        }
        
        set (newValue) {
            if newValue != nil {
                userDefaults.set(newValue, forKey: APIConstants.ScreamXOIndividualChallengeUpdateSyncDate)
                userDefaults.synchronize()
            }
        }
        
    }
    var lastActivityUpdateSyncDate: String? {
        
        get {
            return userDefaults.object(forKey: APIConstants.ScreamXOActivitySyncDate) as? String ?? nil
        }
        
        set (newValue) {
            if newValue != nil {
                userDefaults.set(newValue, forKey: APIConstants.ScreamXOActivitySyncDate)
                userDefaults.synchronize()
            }
        }
        
    }
    init()
    {
        
    }
    func clearSession()
    {
        // this is tantamount to a 'logout' from the user's perspective
        self.sessionToken = nil
        self.lastSyncDate = nil
        self.deviceID = nil

        self.lastChallengeUpdateSyncDate = nil
        self.lastIndividualChallengeUpdateSyncDate = nil
        
        userDefaults.removeObject(forKey: APIConstants.ScreamXOTokenKey)
        userDefaults.removeObject(forKey: APIConstants.ScreamXOLastSyncDate)
        userDefaults.removeObject(forKey: APIConstants.ScreamXOChallengeUpdateSyncDate)
        userDefaults.removeObject(forKey: APIConstants.ScreamXOActivitySyncDate)
        userDefaults.removeObject(forKey: APIConstants.ScreamXOIndividualChallengeUpdateSyncDate)
        //
        
    }
    

    // MARK: - Helper functions
    func loginUser(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.loginEndpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func loginUserAsGuest(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.loginEndpoint
        self.postDatadicFromUrlForGuestLogin(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func registerNewDevice(_ dic :NSDictionary ,successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.createUserEndpoint
        //let myDic1 = [String : AnyObject]()
        self.postDatadicFromUrl(url as String, dic: dic as NSDictionary) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func forgotPwd(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.forgotEndpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func verifcation(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.verifyuserEndpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func verifyagain(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.verifyagainEndpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func EditProfile(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.editProfileEndpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func createPost(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.createPostEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func getCategoriesList(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.categoriesListEndPoint
        self.getDatadicFromUrl(url as String , dic: dic as NSDictionary) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getShopItems(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Shop_get_userEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getShopList(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_ListShopEndPoint
        print("url api: \(url)")
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getPagesList(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getpagesEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getItembycategoryList(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_ListcategoryEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getItemItems(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Media_get_userEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getShopItemDetails(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Shopdetails_get_userEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func addTrackingDetail(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.AddTrackingDetail
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func watchedListItems(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.watchedItemListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func actionwatchItems(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.ActiononWatchItem
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getPostDetails(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getPostDetails
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func getCategoryWithSubCat(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getCatWithSubCat
        self.getDatadicFromUrl(url as String , dic: dic as NSDictionary) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func deletePost(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.deletePostEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getCommentList(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getCOmmentEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getUserInfo(_ dic :NSDictionary,successClosure : @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.UserInfoEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func postItem(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_creationEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func purchaseItem(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_purchaseEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func adptivepayment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.adptivepaymentEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func finalpayment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.finalpaymentEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func purchaseItemList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_purchaseEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func stripePaymentProcess(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_purchaseStripepayment
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func stripePaymentProcessBitcoin(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.StripeProcessBitcoin
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func StripeBitcoinPaymentFinalprocess(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.StripeBitcoinPaymentFinalprocess
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func Stripealipaypaymentfinalprocess(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Stripealipaypaymentfinalprocess
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    //-------------------------------------------------------------------------------------------------
    func Stripebitcoinpayment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Stripebitcoinpayment
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func StripebitcoinpaymentfinalBoostprocess(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.StripebitcoinpaymentfinalBoostprocess
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func Stripealipaypayment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Stripealipaypayment
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func StripealipaypaymentfinalBoostprocess(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.StripealipaypaymentfinalBoostprocess
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    //----------------------------------------------------------------------------------------------//

    func StripealipaypaymentPprocessalipay(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.StripealipaypaymentProcessalipay
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }

    func transferMoneyProcess(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_transferMoney
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func walletHistory(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.userWalletListNew
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func GentareReceipt(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.genrateTransactionReceipt
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
   

    func stripePaymentFinalProcess (_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_purchaseStripeFinalpayment
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func finalBoostprocess (_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.finalBoostprocess
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }

    
    func walletPaymentFinalProcess (_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_purchaseWalletFinalpayment
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func WalletorderpaymentForBoost (_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.WalletorderpaymentForBoost
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    

    
    func addMoneyInWalletFinalProcess (_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.add_moneyInWallet
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func editItem(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_editEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func deletetItem(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_deleteEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getPostPlain(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Post_get_userEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getsellerHistory(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.sellerhistory
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func likePost(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.likePostEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func SendComment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.sendMessageEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func deleteComment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.deletecommentEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func SearchFriendList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.searchFriendEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func SearchFriendTagging(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.searchFriendTagEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func suggestedFriendList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.suggestedFriendEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func FriendList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.FriendListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func FRequestList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.ViewFRequestListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getFbFriendList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.FBFriendListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getTwFriendList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.TWFriendListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func getFinderFriendList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock){
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.FinderFriendListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func InviteByContact(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock){
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.InviteByContactListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func getCountry(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock){
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getCountry
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func InviteByContactForGuest(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock){
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.InviteByContactListEndPoint
        self.postDatadicFromUrlForInviteFriend(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func AddFriend(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.addFriendEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func reportPost(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.ReportAbuseEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func reportItemPost(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.ReportItemAbuseEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }

    
    func unFriend(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.UnfriendEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func blockFriend(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.BlockEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func changePassword(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.changePWDEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func blockList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.BlockListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func unblockFriend(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.UnBlockEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func acceptFriendRe(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.acceptFriendEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func rejectFriendRe(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.rejectFriendEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func dashBoardAcitivity(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.DashBoardEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func worldAcitivity(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.worldendpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func worldstream(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.worldstreamendpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func worldmedia(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.worldmediaendpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func dashBoardStream(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.DashBoardStreamsEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func dashBoardItems(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.DashBoardItemsEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getPurchaseList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.purchaseListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func addReview(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.addReview
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func requestTracking(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.requesttracking
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func dashBoardMedia(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.DashBoardMediasEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func likeList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.LikeListEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func cancelRequest(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.cancelFriendreEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func ItemSearch(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.Item_ListSearchEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getAllnotification(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getAllnotificationEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
   

    
    
    func getCardList(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getCardList
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func create_stripe_customerId(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.createCustomer
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func addCard(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.addCard
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func setnotiSetting(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.setnotiSettingEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    func getAdminDetails(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getadmindtEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func updatebadge(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.updateBadgeEndpoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getnotiSetting(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getnotiSettingEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func updatepayment(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.updatepaymentAccount
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func processForBoost(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.processForBoost
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    

    
    
    func bitcoinPurchase(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.bitcoinpurchaseEndPoint
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func setprivacySettings(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.privacySettings
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func getAccount(_ dic : NSMutableDictionary , successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getpaymentAccount
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    func checkUserIsRegistered(_ id : String,successClosure: @escaping ServiceComplitionBlock)
    {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.loginEndpoint
        let dTok: String = mainInstance.dTokenString
        var myDic1 = [String : Any]()
        myDic1["googleid"] = id
        myDic1["issocial"] = "true"
        myDic1["uniquestring"] = UIDevice.current.identifierForVendor!.uuidString
        myDic1["devicetoken"] = dTok

        manager.get(url, parameters: myDic1, progress: nil, success: { task,responseObject in
            let responseDict = responseObject as! Dictionary<String, AnyObject>
            if responseDict["status"] as! String == "success"
            {
                
                successClosure(responseObject as? NSDictionary, APIResult.apiSuccess)
                
            }
            else
            {
                successClosure(responseObject as? NSDictionary, APIResult.apiError)
                
            }
        }, failure: { task,error in
            let errorDict = ["error": error]
            successClosure(errorDict as NSDictionary, APIResult.apiFail)
        })
        
    }

    func makeScreamXOURL(_ endpoint: String) -> String
    {
        // NB: include trailing slashes in Jottr URL strings!
        let url = "\(APIConstants.ScreamXOBaseUrl)/\(APIConstants.ScreamXOAPIVersion)/\(endpoint)/"
        return url
    }

 

    func logOut(_ successClosure: @escaping ServiceComplitionBlock)
    {
        let tokenId = mainInstance.dTokenString
        let dTok: String!
        if tokenId == nil {
             dTok = "NoToken"
        } else {
             dTok = tokenId
        }
        
        let dic = NSMutableDictionary()
        dic.setObject(dTok, forKey: "registration_id" as NSCopying)
       
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.logOutEndpoint
        self.postDatadicFromUrl(url as String, dic: dic as NSDictionary, block: { (data, result) -> Void in
            successClosure(data, result)
        })
    }
    func changePushNotificationStatus(_ isOn :Bool, successClosure: @escaping ServiceComplitionBlock)
    {
        let dTok: String = mainInstance.dTokenString
        let dic = NSMutableDictionary()
        dic.setObject(isOn ? "True" : "False", forKey: "enable" as NSCopying)
        dic.setObject(UIDevice.current.identifierForVendor!.uuidString, forKey: "device_id" as NSCopying)
        dic.setObject(dTok, forKey: "registration_id" as NSCopying)
        dic.setObject("ios", forKey: "device_type" as NSCopying)
        if dTok == "NoToken"
        {
            return
        }
        let url = makeScreamXOURL(APIConstants.logOutEndpoint)
        self.postDatadicFromUrl(url as String, dic: dic as NSDictionary, block: { (data, result) -> Void in
            successClosure(data, result)
        })
    }
 
    func getBuyerSenderMsg(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getBuyerSenderMsgPosts
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func getFriendsMsg(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getFriendsMsgPosts
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func sendChatMedia(_ dic: NSDictionary , type : String ,imgData : Data?, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.sendChatMsg
        self.postDatadicFromUrlAndMultipartImage(url,type: type, dic: dic, imgData: imgData){ (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func updateShippingAddress(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.updateShippingAddress
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func getShippingAddress(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getShippingAddress
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    
    func sendChatMsg(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.sendChatMsg
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func getChatMsg(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.getChatList
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func deleteMsg(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.deleteMsg
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func deleteChat(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.deleteChat
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    func sendMessageTosupportAdmin(_ dic: NSDictionary, successClosure: @escaping ServiceComplitionBlock) {
        let url = APIConstants.ScreamXOBaseUrl + APIConstants.send_enquiry
        self.postDatadicFromUrl(url, dic: dic) { (data, result) -> Void in
            successClosure(data, result)
        }
    }
    
    
    
    //MARK: - Patch methods -
    func patchDataDicFromurl(_ url: String, dic : NSMutableDictionary , block: @escaping ServiceComplitionBlock)
    {
        let requestSerializer = AFJSONRequestSerializer()
//        let responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
        

        //let usr = UserManager.userManager
        //let url = makeScreamXOURL(APIConstants.userProfileEndpoint) + usr.userId! + "/"
        let baseURL = URL(string: url)
        let httpRequestOperationManager = AFHTTPSessionManager(baseURL: baseURL)
        requestSerializer.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if sessionToken?.characters.count > 1 {
            let tokenString = sessionToken!
            requestSerializer.setValue(tokenString, forHTTPHeaderField: "usertoken")
            requestSerializer.setValue(UserManager.userManager.userId, forHTTPHeaderField: "uid")
            if ( self.deviceID != nil) {
                
                requestSerializer.setValue(self.deviceID, forHTTPHeaderField: "userdevice")
            } else {
                requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
                self.deviceID=UIDevice.current.identifierForVendor!.uuidString
                
            }
            
        }
        requestSerializer.timeoutInterval = TimeInterval(300)
        
        httpRequestOperationManager.requestSerializer = requestSerializer
        httpRequestOperationManager.responseSerializer = AFHTTPResponseSerializer()
        
        httpRequestOperationManager.patch(url, parameters: dic, success: { operation,responseObject in
            let responseObject = responseObject as! [String: AnyObject]
            if responseObject["status"] as! String == "success" {
                block(responseObject as NSDictionary , APIResult.apiSuccess)
            } else {
                block(responseObject as NSDictionary , APIResult.apiError)
            }
        }, failure: { operation,error in
            let errorDict = ["error": error]
            block(errorDict as NSDictionary , APIResult.apiFail)
        })
        
        
    }
    //MARK: - POST methods -
    func postDatadicFromUrl(_ url : String, dic :NSDictionary , block: @escaping ServiceComplitionBlock) {
        print("url api :%@",url)
        let manger = APIManager.apiManager

        if ( manger.sessionToken != nil) {
                let tokenString = sessionToken!
                manager.requestSerializer.setValue(tokenString, forHTTPHeaderField: "usertoken")
                manager.requestSerializer.setValue(UserManager.userManager.userId, forHTTPHeaderField: "uid")
            if ( manger.deviceID != nil) {
                manager.requestSerializer.setValue(manger.deviceID, forHTTPHeaderField: "userdevice")
            } else {
                manager.requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
                manger.deviceID=UIDevice.current.identifierForVendor!.uuidString
            }
            let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
            
            userDefaults!.setValue("data", forKey: "wdata")
            userDefaults!.synchronize()
        }
        print("token::%@ ",sessionToken)
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/html"]) as? Set<String>
        print("userdevice : %@",manger.deviceID)
        manager.post(url, parameters: dic, progress: nil, success: { operation, responseObject in
            let responseDict = responseObject as! Dictionary<String, AnyObject>
            if responseDict["status"] as! String == "1" {
                block(responseObject as? NSDictionary , APIResult.apiSuccess)
                print(APIResult.apiSuccess)
                //print(responseDict)
            } else {
                block(responseObject as? NSDictionary , APIResult.apiError)
            }
            }, failure: {
                operation, error in
                let errorDict = ["error": error]
                block(errorDict as NSDictionary , APIResult.apiFail)
        })
     }
    
    func postDatadicFromUrlForGuestLogin(_ url : String, dic :NSDictionary , block: @escaping ServiceComplitionBlock) {
        print("url api :%@",url)
        let manger = APIManager.apiManager
        UserManager.userManager.userDefaults.set("1", forKey: "userId")
        let tokenString = "m6dYTparmi"
        manager.requestSerializer.setValue(tokenString, forHTTPHeaderField: "usertoken")
        manager.requestSerializer.setValue("1", forHTTPHeaderField: "uid")
        if ( manger.deviceID != nil) {
            manager.requestSerializer.setValue("6CB9F594-07B7-4F4C-9078-2D78CA615B71", forHTTPHeaderField: "userdevice")
        } else {
            manager.requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
            manger.deviceID=UIDevice.current.identifierForVendor!.uuidString
        }
        let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
        userDefaults!.setValue("data", forKey: "wdata")
        userDefaults!.synchronize()
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/html"]) as? Set<String>
        print("userdevice : %@",manger.deviceID!)
        manager.post(url, parameters: dic, progress: nil, success: { operation, responseObject in
            let responseDict = responseObject as! Dictionary<String, AnyObject>
            if responseDict["status"] as! String == "1" {
                block(responseObject as? NSDictionary , APIResult.apiSuccess)
                print(APIResult.apiSuccess)
                
            } else {
                block(responseObject as? NSDictionary , APIResult.apiError)
            }
            
        }, failure: {
            operation, error in
            let errorDict = ["error": error]
            
            block(errorDict as NSDictionary , APIResult.apiFail)
        })
    }

    
    
    func postDatadicFromUrlForInviteFriend(_ url : String, dic :NSDictionary , block: @escaping ServiceComplitionBlock) {
        print("url api :%@",url)
        let manger = APIManager.apiManager
            UserManager.userManager.userDefaults.set("1", forKey: "userId")
        UserManager.userManager.userDefaults.synchronize()
            let tokenString = "m6dYTparmi"
            manager.requestSerializer.setValue(tokenString, forHTTPHeaderField: "usertoken")
            manager.requestSerializer.setValue("1", forHTTPHeaderField: "uid")
            if ( manger.deviceID != nil) {
                manager.requestSerializer.setValue("6CB9F594-07B7-4F4C-9078-2D78CA615B71", forHTTPHeaderField: "userdevice")
            } else {
                manager.requestSerializer.setValue("6CB9F594-07B7-4F4C-9078-2D78CA615B71", forHTTPHeaderField: "userdevice")
                manger.deviceID=UIDevice.current.identifierForVendor!.uuidString
            }
            let userDefaults = UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")
            userDefaults!.setValue("data", forKey: "wdata")
            userDefaults!.synchronize()
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/html"]) as? Set<String>
        print("userdevice : %@",manger.deviceID!)
        manager.post(url, parameters: dic, progress: nil, success: { operation, responseObject in
            let responseDict = responseObject as! Dictionary<String, AnyObject>
            if responseDict["status"] as! String == "1" {
                block(responseObject as? NSDictionary , APIResult.apiSuccess)
                UserManager.userManager.userDefaults.set("1", forKey: "userId")
                UserManager.userManager.userDefaults.synchronize()
                print(APIResult.apiSuccess)
                
            } else {
                block(responseObject as? NSDictionary , APIResult.apiError)
            }
            
        }, failure: {
            operation, error in
            let errorDict = ["error": error]
            
            block(errorDict as NSDictionary , APIResult.apiFail)
        })
    }

    
    //MARK: - get methods -
    func getDatadicFromUrl(_ url : String, dic :NSDictionary , block: @escaping ServiceComplitionBlock)
    {
        let manger = APIManager.apiManager

        if ( manger.sessionToken != nil)
        {
           
            let tokenString = sessionToken!
            manager.requestSerializer.setValue(tokenString, forHTTPHeaderField: "usertoken")
            manager.requestSerializer.setValue(UserManager.userManager.userId, forHTTPHeaderField: "uid")
            if ( manger.deviceID != nil)
            {
                manager.requestSerializer.setValue(manger.deviceID, forHTTPHeaderField: "userdevice")
            }
            else
            {
                manager.requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
                manger.deviceID=UIDevice.current.identifierForVendor!.uuidString
            }
            
        }
        print(dic)

        manager.responseSerializer.acceptableContentTypes=NSSet(array: ["text/html"]) as? Set<String>

        // no parameters, no returns - could check 200 status? TBD
           manager.get(url, parameters: dic, progress: nil, success: {
               operation, responseObject in
               let responseDict = responseObject as! Dictionary<String, AnyObject>
               if responseDict["status"] as! String == "1"
               {
                   block(responseObject as? NSDictionary , APIResult.apiSuccess)
               }
               else
               {
                   block(responseObject as? NSDictionary , APIResult.apiError)
               }
        
               }, failure: {
                   operation, error in
                   let errorDict = ["error": error]
                   block(errorDict as NSDictionary , APIResult.apiFail)
           })
    }
    
    fileprivate func postDatadicFromUrlAndMultipartImage(_ url : String ,type : String, dic :NSDictionary, imgData : Data? , block: @escaping ServiceComplitionBlock)
    {
        let manger = APIManager.apiManager
        if ( manger.sessionToken != nil)
        {
            
            
            let tokenString = sessionToken!
            manager.requestSerializer.setValue(tokenString, forHTTPHeaderField: "usertoken")
            manager.requestSerializer.setValue(UserManager.userManager.userId, forHTTPHeaderField: "uid")
            if ( manger.deviceID != nil)
            {
                manager.requestSerializer.setValue(manger.deviceID, forHTTPHeaderField: "userdevice")
            }
            else
            {
                manager.requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
                
                manger.deviceID=UIDevice.current.identifierForVendor!.uuidString
                
            }
            
        }
        
        // no parameters, no returns - could check 200 status? TBD
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        manager.post(url, parameters: dic, constructingBodyWith: { (data: AFMultipartFormData!) -> Void in
            if type == "image"{
                if imgData != nil {
//                    data.appendPart(withFileData: imgData!, name: "media", fileName: self.createImageName()! , mimeType: "image/png")
                    data.appendPart(withFileData: imgData!, name: "media", fileName: self.createImageName()! , mimeType: "image/jpeg")
                }
            } else {
                if imgData != nil {
                    data.appendPart(withFileData: imgData!, name: "media", fileName: self.createVideoName()! , mimeType: "video/quicktime")
                }
            }
            }, progress: {
                progress in
                
            }, success: {
                task,responseObject in
                SVProgressHUD.dismiss()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let responseDict = responseObject as! Dictionary<String, AnyObject>
                if responseDict["status"] as! String == "1"
                {
                    block(responseObject as? NSDictionary , APIResult.apiSuccess)
                }
                else
                {
                    block(responseObject as? NSDictionary , APIResult.apiError)
                }
            }, failure: {
                task,error in
                SVProgressHUD.dismiss()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let errorDict = ["error": error]
                block(errorDict as NSDictionary , APIResult.apiFail)
        })
    }
    
    
    func createImageName() -> String?
    {
        //        2015-10-08T20:00:00Z
        let date = Date().timeIntervalSince1970
        let time = Double(date)
        return "profile_" + String(time) + ".jpeg"
    }
    func createVideoName() -> String?
    {
        //        2015-10-08T20:00:00Z
        let date = Date().timeIntervalSince1970
        let time = Double(date)
        return "profile_" + String(time) + ".mov"
    }
}
