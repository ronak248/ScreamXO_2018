//
//  ItemManager.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 25/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation

enum APIResultcmt : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}

open class CommentManager {
    
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResultcmt)  -> Void

    
    var CommentID : Int!
    var CommentUname : String!
    var COmmentUphoto : String!
    var COmmentMessage : String!
    var COmmentMessageOld : String!
    var COmmentTagIds : NSDictionary!
    var CommentTime : String!
 
    struct Static {
        static let instance = CommentManager()
    }
    
    // this is the Swift way to do singletons
    class var commentManager: CommentManager
    {
        return Static.instance
    }
   
    func deletecomment(_ deleteParams: NSDictionary, successClosure: @escaping ServiceComplitionBlock)
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let mgrpost = PostManager.postManager

        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrpost.PostId, forKey: "postid")
        parameterss.setValue(self.CommentID, forKey: "commentid")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.deleteComment(deleteParams.mutableCopy() as! NSMutableDictionary, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
                successClosure(dic , APIResultcmt.apiSuccess)
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: (dic?.value(forKey: "msg"))! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultcmt.apiError)
            } else {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultcmt.apiFail)
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
}
