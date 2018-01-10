//
//  CommentList_watch.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity



class commentListtbl: NSObject {
    
    @IBOutlet var lblusername: WKInterfaceLabel!
    
    @IBOutlet var lbldescription: WKInterfaceLabel!
    
    @IBOutlet var imgLikeicon: WKInterfaceImage!
    @IBOutlet var lbltime: WKInterfaceLabel!
    
    @IBOutlet var lbllikecount: WKInterfaceLabel!
}

class CommentList_watch: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet var imgLoader: WKInterfaceImage!
    
    var arrayComment = NSMutableArray()
    
    let objects: [RowData] = []
    var totalcommentPost:Int = 0
    var offsetSt:Int = 1
    var session : WCSession!
    var strpostID:String = ""



    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let userDefaults = UserDefaults.standard
        
        strpostID = (String(describing: context!))

        
        if (userDefaults.value(forKey: "wuid") as? String) != nil
        {
            
            getCommentPost()
            
        }
        else
        {
  
            self.presentAlert(withTitle: "Warning!", message: "Please login in application in your mobile first", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                
                self.pop()
                // Write click code here.
                
            })])
            
        }

        // Configure interface objects here.
    }
    
    override func willActivate() {
      
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // MARK: ----------------------
    // MARK: - webservice methods
    // MARK: ----------------------


    func getCommentPost()
    {
        
        
        
        self.showLoader()

        let userDefaults = UserDefaults.standard


        print(userDefaults.value(forKey: "wuid") ?? "nil wuid")
         let parameters = ["offset":"0", "limit":"10","uid":(userDefaults.object(forKey: "wuid") as! String),"myid":(userDefaults.object(forKey: "wuid") as! String),"postid":strpostID] as Dictionary<String, String>
    
    let request = NSMutableURLRequest(url: URL(string: "https://api.screamxo.com/mobileservice/Posts/getpostscomment")!)
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
            print("Body: \(String(describing: strData))")
            let json = try!JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
            
            if json["status"] as! String == "1"
            {
                
                if let countShop :  Int = (json.value(forKey: "result")! as AnyObject).value(forKey: "commentcount") as? Int
                {
                    self.totalcommentPost = countShop
                }
                
                if self.offsetSt == 1
                {
                    self.arrayComment.removeAllObjects()
                    
                    self.arrayComment = (((json.value(forKey: "result")! as AnyObject).value(forKey: "comments") as! NSArray).mutableCopy() as? NSMutableArray)!
                }
                else
                {
                    self.arrayComment.addObjects(from: ((json.value(forKey: "result")! as AnyObject).value(forKey: "comments")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                
                let rows = Array(repeating: "Comment", count: self.arrayComment.count)
                
                self.table.setRowTypes(rows)
                
                if (self.arrayComment.count>0)
                {
                
                for i in 0 ..< self.arrayComment.count {
                    if let row = self.table.rowController(at: i) as? commentListtbl {
                        
                        
                        let strusername:String?=(self.arrayComment.object(at: i) as AnyObject).value(forKey: "username")! as? String
                        
                        if (strusername == "" || strusername == nil)
                        {
                            
                            
                            
                            row.lblusername.setText("\((self.arrayComment.object(at: i) as AnyObject).value(forKey: "fname") as! String) "  +  "\((self.arrayComment.object(at: i) as AnyObject).value(forKey: "lname") as! String)")

                            
                            
                        }
                        else
                        {

                        
                        row.lblusername.setText(strusername)
                        }
                        
                        row.lbldescription.setText((self.arrayComment.object(at: i) as AnyObject).value(forKey: "commentdesc")! as? String)
                        
                        
                        var strtime:String?=(self.arrayComment.object(at: i) as AnyObject).value(forKey: "commenttime")! as? String
                        strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
                        
                        row.lbltime.setText(strtime)
                    }
                }
                }
                else
                {
                    
                    
                    self.presentAlert(withTitle: nil, message: "No comments", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                        
                        self.pop()
                        // Write click code here.
                        
                    })])
                    
                    
                }

                
            }
            else
            {
            }
            
            print("account data")
            
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(error != nil) {
                print(error!.localizedDescription)
                let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print("Error could not parse JSON: '\(String(describing: jsonStr))'")
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
    
    
    // MARK:---------------
    // MARK: Loader Methods
    // MARK:---------------
    
    func showLoader(){
        
        self.imgLoader.setHidden(false)
        self.imgLoader.setImageNamed("tmp-")
        self.imgLoader.startAnimatingWithImages(in: NSRange(location: 0,length: 11), duration: 1, repeatCount: -1)
    }
    
    func hideLoader(){
        
        self.imgLoader.stopAnimating()
        self.imgLoader.setHidden(true)
        
    }



}
extension NSMutableURLRequest {
    func setBodyContent(_ contentMap: Dictionary<String, String>) {
        var firstOneAdded = false
        var contentBodyAsString = String()
        let contentKeys:Array<String> = Array(contentMap.keys)
        for contentKey in contentKeys {
            if(!firstOneAdded) {
                
                contentBodyAsString = contentBodyAsString + contentKey + "=" + contentMap[contentKey]!
                firstOneAdded = true
            }
            else {
                contentBodyAsString = contentBodyAsString + "&" + contentKey + "=" + contentMap[contentKey]!
            }
        }
        
        contentBodyAsString = contentBodyAsString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        self.httpBody = contentBodyAsString.data(using: String.Encoding.utf8)
    }
}


