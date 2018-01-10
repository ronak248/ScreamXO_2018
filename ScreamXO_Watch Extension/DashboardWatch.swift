//
//  DashboardWatch.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import UIKit
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



class DashboardWatch: WKInterfaceController,WCSessionDelegate {
     @IBOutlet var imgLoader: WKInterfaceImage!
    
    var session : WCSession!
    var arrayMdiaBuffet = NSMutableArray()
    var totalPost:Int = 0
    var offsetSt:Int = 1
    var moviePlayer: WKInterfaceMovie!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let foo =  UserDefaults.init(suiteName: "group.com.screamxo.sharegroup")?.object(forKey: "bar"){
            print(foo)
        }
        
        
        self.initSession()

        // Configure interface objects here.
    }
    
    @available(watchOSApplicationExtension 2.2, *)
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?)
    {
    
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
         
        }
    }
func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
    }
    override func willActivate() {
        
        
        


        

        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    

    
    // MARK:-----------------------
    
    // MARK: - mice Clicked
    

    // MARK:-----------------------
    @IBAction func btnMiceClicked() {
        

        
            let h0 = { print("ok")}
        
        let h1 = {          self.presentTextInputController(withSuggestions: nil,
                                                                           allowedInputMode: WKTextInputMode.plain,
                                                                           completion: { (answers) -> Void in
                                                                            
                                                                            
                                                                            
                                                                            if (answers != nil)
                                                                            {
                                                                            
                                                                            if answers?.count > 0
                                                                            {
                                                                                
                                                                                
                                                                                self.createPostService(String(describing: answers!))
                                                                                
                                                                            }
                                                                            }
                                                                            
        })}

        
        let action1 = WKAlertAction(title: "No", style: .default, handler:h0)
        let action2 = WKAlertAction(title: "Yes", style: .cancel, handler:h1)

        
        self.presentAlert(withTitle: "", message: "Do you want to post stream?", preferredStyle: WKAlertControllerStyle.alert, actions: [action1,action2])
        
        
        
   
        }
    
    // MARK: ----------------------
    // MARK: - WCSession methods
    // MARK: ----------------------
    
    func initSession()
    {
        
        if(WCSession.isSupported())
        {
            self.session = WCSession.default()
            self.session.delegate = self
            self.session.activate()
            let X =   self.session.outstandingUserInfoTransfers
            print(X)
            let foo =  self.session.applicationContext
            print(foo)
        }
        
    }
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        
        
        UserDefaults.standard.setValue(userInfo["id"], forKey: "wuid")
        UserDefaults.standard.setValue(userInfo["session"], forKey: "wtoken")
        UserDefaults.standard.setValue(userInfo["udevice"], forKey: "wuserdevice")
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]){
        
        
        // dispatch_async(dispatch_get_main_queue(),{
        
        let dicData : NSDictionary = message["value"] as! NSDictionary
        let dicDatafordata : NSDictionary = dicData["home"] as! NSDictionary
        
        if let arraymedia = dicDatafordata["media"] as? NSMutableArray
        {
        
            UserDefaults.standard.setValue(arraymedia, forKey: "media")
        
        }
        if let arrayshop = dicDatafordata["shop"] as? NSMutableArray
        {
            
            UserDefaults.standard.setValue(arrayshop, forKey: "shop")
            
        }
        if let arraystream = dicDatafordata["stream"] as? NSMutableArray
        {
            
            UserDefaults.standard.setValue(arraystream, forKey: "stream")
            
        }
        if let arraycate = dicDatafordata["category"] as? NSMutableArray
        {
            
            UserDefaults.standard.setValue(arraycate, forKey: "category")
            
        }
        

        
        UserDefaults.standard.setValue(dicData["id"], forKey: "wuid")
        UserDefaults.standard.setValue(dicData["session"], forKey: "wtoken")
        UserDefaults.standard.setValue(dicData["udevice"], forKey: "wuserdevice")
        
        UserDefaults.standard.setValue(dicData["udevice"], forKey: "wuserdevice")

        
        print("call ewfwefegefwegrew")
        
        print( UserDefaults.standard.value(forKey: "wuid"))
        //self.lblTitle.setText(message["value"] as? String)
        
        //})
        
    }
    


    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        print(userInfoTransfer.userInfo)
    }
   


    // MARK: ----------------------
    // MARK: - webservice methods
    // MARK: ----------------------
    
    
    func createPostService(_ strContent:String)
    {
        
        let userDefaults = UserDefaults.standard
        
        
        print(userDefaults.value(forKey: "wuid"))
        let parameters = ["postedby":(userDefaults.object(forKey: "wuid") as! String),"posttitle":strContent,"posttype":"0"] as Dictionary<String, String>
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.screamxo.com/mobileservice/Posts/createpost")!)
        let session = URLSession.shared
        request.httpMethod = "POST" //set http method as POST
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue((userDefaults.object(forKey: "wtoken") as! String), forHTTPHeaderField: "usertoken")
        request.setValue((userDefaults.object(forKey: "wuid") as! String), forHTTPHeaderField: "uid")
        request.setValue((userDefaults.object(forKey: "wuserdevice") as! String), forHTTPHeaderField: "userdevice")
        
        
        request.setBodyContent(parameters)
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            // println("Response: \(response)")
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("Body: \(strData)")
            let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
            
            if json["status"] as! String == "1"
            {
                
                self.presentAlert(withTitle: "Success!", message: "Post Created Successfully", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                    
                    // Write click code here.
                    
                })])
                
            }
            else
            {
            }
            
            print("account data")
            
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(error != nil) {
                print(error!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json as NSDictionary! {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    _ = parseJSON["success"] as? Int
                    //println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    // println("Error could not parse JSON: \(jsonStr)")
                }
            }
            
        })
        
        task.resume()
        
        
        
    }

    
    
    
   @IBAction func getmediaPost()
    {
        let userDefaults = UserDefaults.standard

        if let strwuid = userDefaults.value(forKey: "wuid") as? String
        {
        
        if let arraymed = UserDefaults.standard.value(forKey: "media") as? NSMutableArray
        {
            
            self.arrayMdiaBuffet  = arraymed
            self.renederdata()
            
            
        }
        else
        
        {
       self.showLoader()
        
        
        
            
        
        print(userDefaults.value(forKey: "wuid"))
        let parameters = ["offset":"0", "limit":"10","uid":(userDefaults.object(forKey: "wuid") as! String),"myid":(userDefaults.object(forKey: "wuid") as! String),"posttype":"1"] as Dictionary<String, String>
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.screamxo.com/mobileservice/Posts/getdashboardmedia")!)
        let session = URLSession.shared
        request.httpMethod = "POST" //set http method as POST
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue((userDefaults.object(forKey: "wtoken") as! String), forHTTPHeaderField: "usertoken")
        request.setValue((userDefaults.object(forKey: "wuid") as! String), forHTTPHeaderField: "uid")
        request.setValue((userDefaults.object(forKey: "wuserdevice") as! String), forHTTPHeaderField: "userdevice")
        
        
        request.setBodyContent(parameters)
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            self.hideLoader()
            
            if ((error) != nil)
            {
                
                
                self.presentAlert(withTitle: "Warning!", message: error?.localizedDescription, preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                    
                    self.pop()
                    // Write click code here.
                    
                })])
                
            }
            else
            {
                // println("Response: \(response)")
                let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Body: \(strData)")
                let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                
                if json["status"] as! String == "1"
                {
                    
                    if let countShop :  Int = (json.value(forKey: "result")! as AnyObject).value(forKey: "totalmedia") as? Int
                    {
                        self.totalPost = countShop
                    }
                    
                    if self.offsetSt == 1
                    {
                        self.arrayMdiaBuffet.removeAllObjects()
                        
                        self.arrayMdiaBuffet = (((json.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray).mutableCopy() as? NSMutableArray)!
                    }
                    else
                    {
                        self.arrayMdiaBuffet.addObjects(from: ((json.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                    }
                    
               
                    self.renederdata()
                    
                }
                else
                {
                }
                
                print("account data")
                
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error != nil) {
                    print(error!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json as NSDictionary! {
                        // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                        _ = parseJSON["success"] as? Int
                        //println("Succes: \(success)")
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        _ = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        // println("Error could not parse JSON: \(jsonStr)")
                    }
                }
            }
            
            
        })
        
        task.resume()
        }
            
        }
        else
        {
            
            
            
            
            self.presentAlert(withTitle: "Warning!", message: "Please login in application in your mobile first", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                
                self.pop()
                // Write click code here.
                
            })])
            
        }
        
        
    }
    
    // MARK:---------------
    // MARK: data UI
    // MARK:---------------
    
    func renederdata()
    {
        
        
        let rows = Array(repeating: "medialist", count: self.arrayMdiaBuffet.count)
        
        //                self.table.setRowTypes(rows)
        
        var TotalPages:[String]=[]
        for _ in 0..<self.arrayMdiaBuffet.count {
            TotalPages.append("page2")
        }
        
        
        if (self.arrayMdiaBuffet.count>0)
        {
            self.presentController(withNames: TotalPages, contexts: self.arrayMdiaBuffet as [AnyObject])
            
            
        }
        else
        {
            
            
            self.presentAlert(withTitle: nil, message: "NO data Found", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                
                self.pop()
                // Write click code here.
                
            })])
            
            
        }
        
    }
    func showLoader(){
        
        self.imgLoader.setHidden(false)
        self.imgLoader.setImageNamed("load-")
        self.imgLoader.startAnimatingWithImages(in: NSRange(location: 0,length: 11), duration: 1, repeatCount: -1)
        
        
    }
    
    func hideLoader(){
        
        self.imgLoader.stopAnimating()
        self.imgLoader.setHidden(true)
        
    }
    

}
