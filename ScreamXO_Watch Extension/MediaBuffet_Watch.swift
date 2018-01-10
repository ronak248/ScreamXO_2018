//
//  MediaBuffet_Watch.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit

class mediaBuffetcell: NSObject {
    
  
    @IBOutlet var imgBuffet: WKInterfaceImage!
}
class MediaBuffet_Watch: WKInterfaceController {
    
    @IBOutlet var imgLoader: WKInterfaceImage!
    @IBOutlet var itmDescription: WKInterfaceLabel!
    @IBOutlet var itmPrice: WKInterfaceLabel!
    @IBOutlet var lblitmname: WKInterfaceLabel!
    var arrayMdiaBuffet = NSMutableArray()
    var totalPost:Int = 0
    var offsetSt:Int = 1
  
    @IBOutlet weak var table: WKInterfaceTable!




    @IBOutlet var imgItmimage: WKInterfaceImage!
    var DictinaryData = NSDictionary()
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        
        let userDefaults = UserDefaults.standard
        
        
        if (userDefaults.value(forKey: "wuid") as? String) != nil
        {
        
            getmediaPost()
            
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
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        
        
        let strmediaType:String?=(self.arrayMdiaBuffet.object(at: rowIndex) as AnyObject).value(forKey: "media_type")! as? String
        
        
        if strmediaType == "audio/m4a" || strmediaType == "audio/mp3" || strmediaType == "video/quicktime" || strmediaType == "video/mp4"
        {
        
            pushController(withName: "Movieplayer_watch", context: arrayMdiaBuffet.object(at: rowIndex))
            
            
        }
        else
        {
        
            pushController(withName: "ImageVIewer", context: (arrayMdiaBuffet.object(at: rowIndex) as AnyObject).value(forKey: "media_url")!)
            
        }

        
        
    }
    
    // MARK:---------------
    // MARK: Segue Operations
    // MARK:---------------
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if(segueIdentifier == "playmovie")
        {
            
            
            return arrayMdiaBuffet.object(at: rowIndex)
            
        }
        
        return nil
        
    }

    
    // MARK: ----------------------
    // MARK: - webservice methods
    // MARK: ----------------------
    
    
    func getmediaPost()
    {
        
        
        if let arraymed = UserDefaults.standard.value(forKey: "media") as? NSMutableArray
        {
            
            self.arrayMdiaBuffet  = arraymed
            self.renederdata()
            
            
        }
        else
        {
        self.showLoader()

        
        let userDefaults = UserDefaults.standard
        
        
        print(userDefaults.value(forKey: "wuid") ?? "nil wuid")
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
            
            

        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error -> Void in
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

                _ = Array(repeating: "medialist", count: self.arrayMdiaBuffet.count)
                
//                self.table.setRowTypes(rows)
                
                var TotalPages:[String]=[]
                for _ in 0..<self.arrayMdiaBuffet.count {
                    TotalPages.append("page2")
                }
                
                
                if (self.arrayMdiaBuffet.count>0)
                {
                     self.presentController(withNames: TotalPages, contexts: self.arrayMdiaBuffet as [AnyObject])
                    
             /*
                for i in 0 ..< self.arrayMdiaBuffet.count {
                    if let row = self.table.rowControllerAtIndex(i) as? mediaBuffetcell {
                        
                        
                        let strmediaType:String?=self.arrayMdiaBuffet.objectAtIndex(i).valueForKey("media_type")! as? String
                        
                        
                        if strmediaType == "audio/m4a" || strmediaType == "audio/mp3"
                        {
                            row.imgBuffet.setImageNamed("audio_w")
                        }
                        else
                        {
                        
                            let strimg:String=self.arrayMdiaBuffet.objectAtIndex(i).valueForKey("media_thumb")! as! String

                            row.imgBuffet.setImageWithUrl(strimg)

                            
                        
                        
                        }
                        
                                            }
                    
                    }
               */
                }
                else
                {
                    
                    
                    self.presentAlert(withTitle: nil, message: "NO data Found", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                        
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
        
        
    }
    // MARK:---------------
    // MARK: data UI
    // MARK:---------------
    
    func renederdata()
    {
        let rows = Array(repeating: "medialist", count: self.arrayMdiaBuffet.count)
        
        self.table.setRowTypes(rows)
        
        if (self.arrayMdiaBuffet.count>0)
        {
            
            for i in 0 ..< self.arrayMdiaBuffet.count {
                if let row = self.table.rowController(at: i) as? mediaBuffetcell {
                    
                    
                    let strmediaType:String?=(self.arrayMdiaBuffet.object(at: i) as AnyObject).value(forKey: "media_type")! as? String
                    
                    
                    if strmediaType == "audio/m4a" || strmediaType == "audio/mp3"
                    {
                        row.imgBuffet.setImageNamed("audio_w")
                    }
                    else
                    {
                        
                        let strimg:String=(self.arrayMdiaBuffet.object(at: i) as AnyObject).value(forKey: "media_thumb")! as! String
                        
                        _ = row.imgBuffet.setImageWithUrl(strimg)
                        
                        
                        
                        
                    }
                    
                }
                
            }
            
        }
        else
        {
            
            
            self.presentAlert(withTitle: nil, message: "NO data Found", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                
                self.pop()
                // Write click code here.
                
            })])
            
            
        }
        
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
