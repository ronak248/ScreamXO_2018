//
//  ShopCategory_watch.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit
import Foundation
struct RowData {
    let name: String
    let imageName: String
}


class ShopCategory_watch: WKInterfaceController {
    
    let objects: [RowData] = [
        RowData(name: "Men Fashion", imageName: "cat1"),
        RowData(name: "Camera", imageName: "cat2"),
        RowData(name: "Bay & Kids", imageName: "cat3"),
        RowData(name: "Women Fashions", imageName: "cat4")]
    @IBOutlet weak var table: WKInterfaceTable!

    @IBOutlet var imgLoader: WKInterfaceImage!
    var arrayCategory = NSMutableArray()

    override func awake(withContext context: Any?) {
        
        let userDefaults = UserDefaults.standard
        
        
        if let strwuid = userDefaults.value(forKey: "wuid") as? String
        {
            
            getcategoryList()
            
        }
        else
        {
            
            self.presentAlert(withTitle: "Warning!", message: "Please login in application in your mobile first", preferredStyle: WKAlertControllerStyle.alert, actions: [WKAlertAction(title: "Okay", style: WKAlertActionStyle.cancel, handler: {
                
                self.pop()
                // Write click code here.
                
            })])
            
        }
        
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        
        //getcategoryList()
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
//        let rows = Array(count: objects.count, repeatedValue: "category")
//        table.setRowTypes(rows)
//        
//        for i in 0 ..< objects.count {
//            let object = objects[i];
//            if let row = table.rowControllerAtIndex(i) as? shopcatCell {
//                row.lblcatname.setText(object.name)
//                row.imgLikeicon.setImageNamed(object.imageName)
//            }
//        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        
        
        
        
        
        
        
    }
    
    // MARK:---------------
    // MARK: Segue Operations
    // MARK:---------------
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if(segueIdentifier == "detailItm")
        {
            
            
            if let uID: Int  = (arrayCategory.object(at: rowIndex) as AnyObject).value(forKey: "id") as? Int
            {
                return uID

            }
            return ""
        }
        
        return nil
        
    }

    
    // MARK: ----------------------
    // MARK: - webservice methods
    // MARK: ----------------------
    
    
    func getcategoryList()
    {
        
        if let arraycate = UserDefaults.standard.value(forKey: "category") as? NSMutableArray
        {
            
            self.arrayCategory  = arraycate
            self.renederdata()
            
            
        }
        else
        {
        self.showLoader()

        let userDefaults = UserDefaults.standard
        
        
        print(userDefaults.value(forKey: "wuid"))
        let parameters = ["offset":"0", "limit":"10","uid":(userDefaults.object(forKey: "wuid") as! String),"myid":(userDefaults.object(forKey: "wuid") as! String),"posttype":"0"] as Dictionary<String, String>
        
        let request = NSMutableURLRequest(url: URL(string: "https://api.screamxo.com/mobileservice/Categories/listAllCategories/")!)
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
                
                self.arrayCategory = NSMutableArray(array: ((json.value(forKey: "result") as AnyObject).value(forKey: "categories"))! as! [AnyObject])
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
    // MARK:---------------
    // MARK: data UI
    // MARK:---------------
    
    func renederdata()
    {
        let rows = Array(repeating: "category", count: self.arrayCategory.count)
        
        self.table.setRowTypes(rows)
        
        if (self.arrayCategory.count>0)
        {
            
            for i in 0 ..< self.arrayCategory.count {
                if let row = self.table.rowController(at: i) as? shopcatCell {
                    
                    
                    row.lblcatname.setText((self.arrayCategory.object(at: i) as AnyObject).value(forKey: "category_name")! as? String)
                    
                    
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


