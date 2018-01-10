//
//  ItemListing_Watch.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit

struct itemList {
    let itmname: String
    let itmdescription: String
    let itmimage: String

}

class ItemListing_Watch: WKInterfaceController {
    

    
    @IBOutlet var imgLoader: WKInterfaceImage!
    var strCatID : String!
    
    var arrayItemList = NSMutableArray()
    
    let objects: [RowData] = []
    var totalList:Int = 0
    var offsetSt:Int = 1
    
    @IBOutlet weak var table: WKInterfaceTable!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        

        
        strCatID = (String(describing: context!))
        getItmResultList()

        // Configure interface objects here.
    }
    
    
    override func willActivate() {
        
        
        
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
//        let rows = Array(count: objects.count, repeatedValue: "ListItem")
//        table.setRowTypes(rows)
//        
//        for i in 0 ..< objects.count {
//            let object = objects[i];
//            if let row = table.rowControllerAtIndex(i) as? ItmCellWatch {
//                row.lblitmname.setText(object.itmname)
//                row.imgItem.setImageNamed(object.itmimage)
//                row.lbldescription.setText(object.itmdescription)
//
//            }
//        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    
    // MARK:---------------
    // MARK: Segue Operations
    // MARK:---------------
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if(segueIdentifier == "detailsfullitm") {
            return arrayItemList.object(at: rowIndex)
        }
        return nil
    }

    
    // MARK: - webservice methods
    
    
    func getItmResultList()
    {
        self.showLoader()
        let userDefaults = UserDefaults.standard
        
        if (strCatID == "nil")
        {
            strCatID = ""
        }
        print(userDefaults.value(forKey: "wuid") ?? "nil wuid")
        let parameters = ["offset":"0", "limit":"10","iswatch":"true","uid":(userDefaults.object(forKey: "wuid") as! String),"catid":strCatID!,"string":""] as Dictionary<String, String>
        let request = NSMutableURLRequest(url: URL(string: "https://api.screamxo.com/mobileservice/Categories/getitembycat/")!)
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
            //let stippedData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let json = try! JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
            
            if json["status"] as! String == "1"
            {
                
                if let countShop :  Int = (json.value(forKey: "result")! as AnyObject).value(forKey: "itemcount") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offsetSt == 1
                {
                    self.arrayItemList.removeAllObjects()
                    if (self.strCatID == "")
                    {
                        self.arrayItemList = ((json.value(forKey: "result")! as! NSArray).mutableCopy() as? NSMutableArray)!
                    }
                    else
                    {
                        self.arrayItemList = (((json.value(forKey: "result")! as AnyObject).value(forKey: "items") as! NSArray).mutableCopy() as? NSMutableArray)!
                    }
                }
                else
                {
                    self.arrayItemList.addObjects(from: ((json.value(forKey: "result")! as AnyObject).value(forKey: "items")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                
                let rows = Array(repeating: "ListItem", count: self.arrayItemList.count)
                
                self.table.setRowTypes(rows)
                
                
                if (self.arrayItemList.count>0)
                {
                    
                    for i in 0 ..< self.arrayItemList.count {
                        if let row = self.table.rowController(at: i) as? ItmCellWatch {
                            
                            
                            let stritmname:String?=(self.arrayItemList.object(at: i) as AnyObject).value(forKey: "item_name")! as? String
                            let strimgname:String?=(self.arrayItemList.object(at: i) as AnyObject).value(forKey: "media_url")! as? String
                            if (self.strCatID == "")
                            {
                                row.lbldescription.setText("")
                            }
                                
                            else
                            {
                                let strdescription:String?=(self.arrayItemList.object(at: i) as AnyObject).value(forKey: "item_description")! as? String
                                
                                row.lbldescription.setText(strdescription)
                            }
                            
                            if (strimgname != nil)
                            {
                                _ = row.imgItem.setImageWithUrl((strimgname)!)
                            }
                            
                            row.lblitmname.setText(stritmname)
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
public extension WKInterfaceImage {
    
    public func setImageWithUrl(_ url:String, scale: CGFloat = 1.0) -> WKInterfaceImage? {
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            if (data != nil && error == nil) {
                let image = UIImage(data: data!, scale: scale)
                DispatchQueue.main.async {
                    self.setImage(image)
                }
            }
            }) .resume()
        
        return self
    }
}

public extension WKInterfaceButton {
    
    public func setbackgroundImageWithUrl(_ url:String, scale: CGFloat = 1.0) -> WKInterfaceButton? {
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            if (data != nil && error == nil) {
                let image = UIImage(data: data!, scale: scale)
                
                DispatchQueue.main.async {
                    self.setBackgroundImage(image)
                }
            }
            }) .resume()
        
        return self
    }
}

