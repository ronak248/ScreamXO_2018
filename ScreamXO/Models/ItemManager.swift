//
//  ItemManager.swift
//  ScreamXO
//
//  Created by Ronak Barot on 25/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation

enum APIResultItm : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}

open class ItemManager {
    
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResultItm)  -> Void

    var ItemId : String!
    var Itemmy : String!

    var ItemName : String!
    var ItemDescription : String!
    var ItemPrice : String = ""
    var ItemactualPrice : String!

    var ItemTags : String!
    var ItemCategory : String!
    var ItemCategoryID : String = "0"
    var ItemShipingCost : String!
    var ItemShipingaddress : String!
    var Itemkeyword : String!
    var Itempaykey : String!
    var Itembitcoinmail : String!
    var isItemPurchase : String!
    var ispaymentKind : String!
    var Itemtype : String!
    var Itemsearchkey : String = ""

    var ItemImg : String!
    var ItemOwner : String!
    var PostOwAdd : String!
    var ItmOwimg : String!
    var ItemOwID : String!
    var ItemmedID : String = ""
    var arrayMedia = NSMutableArray()
    var arrayCategories : NSMutableArray!
    var dicExchangerate : NSDictionary!
    
    
    var arrayMediaItems = NSMutableArray()
    var arrayShopItems = NSMutableArray()
    var arrayStream = NSMutableArray()
    
    
    var loadEarlier = false
    var itm_qty: String!
    var itm_qty_remain: String!
    var product_qty: String!
    var itmTag: Int!
    var isWatch: Bool!
    var itemCondition: String!

    struct Static {
        static let instance = ItemManager()
    }
    
    // this is the Swift way to do singletons
    class var itemManager: ItemManager
    {
        return Static.instance
    }
    
   
        
    func clearManager()
    {
        //NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotificaiton, object: nil)
        self.ItemId       = nil
        self.arrayMedia.removeAllObjects()
        self.Itemtype       = nil
        
        self.isItemPurchase       = nil
        self.ispaymentKind       = nil
        self.Itembitcoinmail = nil
        self.ItemName      = nil
        self.ItemDescription       = nil
        self.ItemPrice   = ""
        self.ItemactualPrice   = nil
        self.ItemImg   = nil
        self.ItemCategory       = nil
        self.ItemCategoryID       = "0"
        self.Itemsearchkey      = ""
        
        self.ItemShipingCost       = nil
        self.ItemTags       = nil
        self.ItemOwner        = nil
        self.PostOwAdd = nil
        self.Itempaykey=nil
        self.ItemShipingaddress = nil
        self.ItmOwimg  = nil
        self.Itemmy  = nil
        self.ItemmedID  = ""
        self.ItemOwID = nil
        
        self.itm_qty = nil
        self.itm_qty_remain = nil
        self.product_qty = nil
    }
    
    
    func addWatchedItem(_ action:Int , successClosure: @escaping ServiceComplitionBlock) {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.ItemId, forKey: "itemid")
        parameterss.setValue(action, forKey: "action")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.actionwatchItems(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiSuccess)
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiError)
                
                
                
            }
            else
            {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiFail)
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func purchaseItem(_ action:Int , successClosure: @escaping ServiceComplitionBlock)
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.ItemId, forKey: "itemid")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(self.product_qty, forKey: "productqty")
        
        print(parameterss)
        
        mgr.adptivepayment(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                successClosure(dic , APIResultItm.apiSuccess)
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: "Failed transcation")
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiError)
            }
            else
            {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiFail)
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    
    func purchasebitcoinItem(_ orderID:String , successClosure: @escaping ServiceComplitionBlock)
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.ItemId, forKey: "itemid")
        parameterss.setValue(orderID, forKey: "orderid")
        parameterss.setValue(self.ItemShipingaddress, forKey: "shipping")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(self.product_qty, forKey: "productqty")
        
        mgr.bitcoinPurchase(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                SVProgressHUD.dismiss()

                successClosure(dic , APIResultItm.apiSuccess)
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKeyPath: "msg.Errors.Message")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiError)                
            }
            else
            {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiFail)
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }


    func finalpayment(_ action:Int , successClosure: @escaping ServiceComplitionBlock)
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.ItemShipingaddress, forKey: "shipping")
        parameterss.setValue(self.Itempaykey, forKey: "paymentkey")
        parameterss.setValue(self.product_qty, forKey: "productqty")

        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.finalpayment(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess
            {
                successClosure(dic , APIResultItm.apiSuccess)
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiError)
                
                
                
            }
            else
            {
                SVProgressHUD.dismiss()
                successClosure(dic , APIResultItm.apiFail)
                
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    func reportItemPost()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let mgrPost = ItemManager.itemManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrPost.ItemId, forKey: "item_id")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        
        mgr.reportItemPost(parameterss, successClosure: { (dic, result) -> Void in
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
