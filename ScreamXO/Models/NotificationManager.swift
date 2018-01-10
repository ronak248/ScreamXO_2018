//
//  NotificationManager.swift
//  ScreamXO
//
//  Created by Ronak Barot on 25/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation


enum APIResultnoti : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}
open  class NotificationManager {
    
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResultnoti)  -> Void

    
    var NotiLike : Int = 0
    var NotiComment : Int = 0
    var NotiContact : Int = 0
    
    
    var users_buffet : Int = 2
    var users_shop : Int = 2
    var users_media : Int = 2
    var users_info : Int = 0



    struct Static {
        static let instance = NotificationManager()
    }
    
    // this is the Swift way to do singletons
    class var notificationManager: NotificationManager
    {
        return Static.instance
    }
    
    func clearManager()
    {
        //NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotificaiton, object: nil)
        self.NotiLike       = 0
        self.NotiComment      = 0
        self.NotiContact       = 0
        
        self.users_buffet       = 2
        self.users_shop      = 2
        self.users_media       = 2
        self.users_info       = 0


        
    }
    func setNotification()
    {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(String(NotiLike), forKey: "notificationlike")
        parameterss.setValue(String(NotiContact), forKey: "notificationnewcontact")
        parameterss.setValue(String(NotiComment), forKey: "notificationcomment")
        parameterss.setValue(usr.userId, forKey: "uid")
        mgr.setnotiSetting(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
               // mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic!)
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
    func resetbadgeNotification()
    {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue("true", forKey: "reset")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.updatebadge(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                UIApplication.shared.applicationIconBadgeNumber = 0

                // mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
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
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    func decrebadgeNotification()
    {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.updatebadge(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                // mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
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
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    func getNotification(_ successClosure: @escaping ServiceComplitionBlock)
    {
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.getnotiSetting(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                SVProgressHUD.dismiss()
                
                
                self.users_media = Int(dic?.value(forKeyPath: "result.users_media") as! String)!
                self.users_shop = Int(dic?.value(forKeyPath: "result.users_shop") as! String)!
                self.users_buffet = Int(dic?.value(forKeyPath: "result.users_buffet") as! String)!
                self.users_info = Int(dic?.value(forKeyPath: "result.users_info") as! String)!

                
                let likecount:Int!
                let commentcount:Int!
                let contactcount:Int!

                if let like: Int  = dic?.value(forKeyPath: "result.user_notification_like") as? Int
                {
                    likecount = like
                }
                else
                {
            
                 likecount = (dic?.value(forKeyPath: "result.user_notification_like") as! NSString).integerValue
                
                }
                self.NotiLike = likecount
                
                if let comment: Int  = dic?.value(forKeyPath: "result.user_notification_comment") as? Int
                {
                    commentcount = comment
                }
                else
                {
                    
                    commentcount = (dic?.value(forKeyPath: "result.user_notification_comment") as! NSString).integerValue
                    
                }
                
                self.NotiComment = commentcount
                
                if let contact: Int  = dic?.value(forKeyPath: "result.user_notification_newcontact") as? Int
                {
                    contactcount = contact
                }
                else
                {
                    
                    contactcount = (dic?.value(forKeyPath: "result.user_notification_newcontact") as! NSString).integerValue
                    
                }
                
                self.NotiContact = contactcount
                


                successClosure(dic , APIResultnoti.apiSuccess)

            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultnoti.apiError)

                
                
            }
            else
            {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultnoti.apiFail)

                mainInstance.showSomethingWentWrong()
            }
        })
    }
    func getPrivacySettings(_ successClosure: @escaping ServiceComplitionBlock)
    {
        // SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
       
        
        mgr.setprivacySettings(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                //mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultnoti.apiSuccess)
                
            } else if result == APIResult.apiError {
                print(dic)
                //mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultnoti.apiError)
            } else {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultnoti.apiFail)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func setPrivacySettings() {
        // SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(users_buffet, forKey: "users_buffet")
        parameterss.setValue(users_shop, forKey: "users_shop")
        parameterss.setValue(users_media, forKey: "users_media")
        parameterss.setValue(users_info, forKey: "users_info")
        
        mgr.setprivacySettings(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                //mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                //mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
            else
            {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
}
