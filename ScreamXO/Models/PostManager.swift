//
//  PostManager.swift
//  ScreamXO
//
//  Created by Ronak Barot on 25/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation


enum APIResultpost : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}
open  class PostManager {
    
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResultpost)  -> Void

    
    var PostId : String = ""
    var PostText : String!
    var PostTextOld : String!
    var PostTagIds : NSDictionary!
    var PostTagIdArr : NSArray!
    var PostTime : String!
    var PostImg : String!
    var PostOwner : String!
    var PostOwnerimg : String?
    var PostOwnerfname : String = ""
    var PostOwnerlname : String = ""
    var PostismyPost : String!
    var PostOwID : String!
    var PostOwAdd : String?
    var PostLikes : Int=0
    var PostComments : Int = 0
    var isPostLike : Int!
    var isPostComment : Int!
    var PostType : String!
    var PostTypecheck : String!
    var postTag : Int!
    var mediaType : String = ""
    var PostTitle : String!
    var privacyType = ""




    struct Static {
        static let instance = PostManager()
    }
    
    // this is the Swift way to do singletons
    class var postManager: PostManager
    {
        return Static.instance
    }
    
    func clearManager() {
        self.PostId = ""
        self.PostText = nil
        self.PostTime = nil
        self.PostImg = nil
        self.PostOwner = nil
        self.PostOwnerimg = nil
        self.PostOwAdd = nil
        self.PostLikes = 0
        self.PostComments = 0
        self.isPostLike = nil
        self.isPostComment = nil
        self.PostOwnerfname = ""
        self.PostismyPost = nil
        self.PostOwnerlname = ""
        self.mediaType = ""
        self.PostType = nil
        self.PostTitle = nil
        self.privacyType = ""
    }
    func postlikeMethod(_ likeaction:Int)
    {
        
        let mgrpost = PostManager.postManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(likeaction, forKey: "action")
        parameterss.setValue(mgrpost.PostId, forKey: "postid")
        
        
        mgr.likePost(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
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
    func deletepost(_ successClosure: @escaping ServiceComplitionBlock)
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let mgrPost = PostManager.postManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrPost.PostId, forKey: "postid")
        parameterss.setValue(mgrPost.PostTypecheck, forKey: "posttype")
        parameterss.setValue(usr.userId, forKey: "uid")
        mgr.deletePost(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess  {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultpost.apiSuccess)
            }
            else if result == APIResult.apiError  {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultpost.apiError)
            }
            else  {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultpost.apiFail)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func reportPost()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let mgrPost = PostManager.postManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrPost.PostId, forKey: "postid")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.reportPost(parameterss, successClosure: { (dic, result) -> Void in
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
