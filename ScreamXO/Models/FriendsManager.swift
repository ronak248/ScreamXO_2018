//
//  FirnedsManager.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 25/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation
open class FriendsManager {
    
    var FriendID : String!
    var FriendName : String!
    var FUsername : String!
    var FriendPhoto : String!
    var isFriend : String!
    var friendConnectionID : String!
    var friendSchool : String!
    var friendJob : String!
    var friendCity : String!
    var friendHobby : String!
    var friendGender : String!
    var friendrelstatus : String = "a"
    var friendsexpref : String!
    
    var users_buffet : Int = 2
    var users_shop : Int = 2
    var users_media : Int = 2
    var users_info : Int = 0


    var tagID : Int!

    struct Static {
        static let instance = FriendsManager()
    }
    
    // this is the Swift way to do singletons
    class var friendsManager: FriendsManager
    {
        return Static.instance
    }
    
    
    
    func clearManager()
    {
        //NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotificaiton, object: nil)
        self.FriendID       = nil
        self.friendrelstatus       = "a"
        self.friendsexpref       = nil

        self.FriendName      = nil
        self.FUsername = nil;
        self.FriendPhoto       = nil
        self.isFriend   = nil
        self.friendConnectionID   = nil
        self.friendSchool   = nil
        self.friendJob   = nil
        self.friendHobby   = nil
        self.friendGender   = nil
        
        self.users_buffet       = 2
        self.users_shop      = 2
        self.users_media       = 2
        self.users_info       = 0

    }
    
    func BlockFriend()
    {
        
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

        mgr.blockFriend(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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
    func UnBlockFriend()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        
        
        mgr.unblockFriend(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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
    
    func Addfriend()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        print(parameterss)
        
        
        mgr.AddFriend(parameterss, successClosure: { (dic, result) -> Void in
            print(dic)
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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
    func Unfriend()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)

        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        parameterss.setValue(mgrfriend.friendConnectionID, forKey: "friendshipid")

        
        mgr.unFriend(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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

    func cancelfriend()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        parameterss.setValue(mgrfriend.friendConnectionID, forKey: "friendshipid")
        
        
        mgr.cancelRequest(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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

    func AcceptRequest()
    {
        let mgrfriend = FriendsManager.friendsManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "fromid")
        parameterss.setValue(mgrfriend.FriendID, forKey: "toid")
        parameterss.setValue(mgrfriend.friendConnectionID, forKey: "friendshipid")
        
        
        mgr.acceptFriendRe(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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
}
