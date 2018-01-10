//
//  AdminManager.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 25/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation

enum APIResultAdm : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}

open class AdminManager {
    
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResultAdm)  -> Void

    
    var paypalcID : String!
    var paypalcSecret : String!
    
    var bitcoincID : String!
    var bitcoincSecret : String!
    var cutpercentage : String!
    var bitcoinemail : String!
    var paypalemail : String!
    var termsUrl : String!
    var helpUrl : String!
    var Privacy  : String!



    struct Static {
        static let instance = AdminManager()
    }
    
    // this is the Swift way to do singletons
    class var adminManager: AdminManager
    {
        return Static.instance
    }
    
   
        
    func clearManager()
    {
        //NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotificaiton, object: nil)
        self.paypalcID       = nil
        self.paypalcSecret       = nil
        self.bitcoincID       = nil
        self.bitcoincSecret      = nil
        self.bitcoinemail      = nil
        self.paypalemail      = nil
        self.cutpercentage       = nil


    }
    
    
    func getAdminDetails(_ successClosure: @escaping ServiceComplitionBlock)
    {
       // SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.getAdminDetails(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                //mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultAdm.apiSuccess)
                
            } else if result == APIResult.apiError {
                print(dic)
                //mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultAdm.apiError)
                
                
                
            } else {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultAdm.apiFail)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    
    func getpages(_ successClosure: @escaping ServiceComplitionBlock)
    {
        // SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.getPagesList(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                
                
                let array : NSArray = dic?.value(forKey: "result") as! NSArray
                self.termsUrl = (array.object(at: 0) as AnyObject).value(forKey: "value") as! String
                self.helpUrl = (array.object(at: 1) as AnyObject).value(forKey: "value") as! String
                self.Privacy = (array.object(at: 2) as AnyObject).value(forKey: "value") as! String


                
                //mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultAdm.apiSuccess)
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                //mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.valueForKey("msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultAdm.apiError)
                
                
                
            }
            else
            {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultAdm.apiFail)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    

    //MARK: - Patch methods -
  
    
    
}
