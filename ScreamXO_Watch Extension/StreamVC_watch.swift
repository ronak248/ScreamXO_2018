//
//  StreamVC_watch.swift
//  ScreamXO
//
//  Created by Ronak Barot on 05/04/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

struct RowDataStream {
    let name: String
    let imageName: String
}
struct customEmojis {
    static let angryface = "[:angryface:]"
    static let bigsmile = "[:bigsmile:]"
    static let dizzy = "[:dizzy:]"
    static let tongue = "[:tongue:]"
    static let wink = "[:wink:]"
    static let rosychicks = "[:rosy-chicks:]"
    static let cry = "[:cry:]"
    
    static let emojiItemsArray = [angryface, bigsmile, dizzy, tongue, wink, rosychicks, cry]
    
    static let emojiItems: [String: UIImage] = [angryface : UIImage(named: angryface)!, bigsmile : UIImage(named: bigsmile)!, dizzy : UIImage(named: dizzy)!, tongue : UIImage(named: tongue)!, wink : UIImage(named: wink)!, rosychicks : UIImage(named: rosychicks)!, cry : UIImage(named: cry)!]
}

struct fontsName
{
    static let KfontproxiRegular = "ProximaNova-Regular"
    static let KfontproxisemiBold = "ProximaNova-Semibold"
    static let KfontNameRoman = "HelveticaNeueLTPro-Roman"
    static let KfontNameSTDRoman = "HelveticaNeueLTStd-Roman" //HelveticaNeueLTStd-Lt
    static let KfontNameSTDLite = "HelveticaNeueLTStd-Lt"
    static let kfontNameMedium = "HelveticaNeueLTPro-Md"
    static let kfontNameRobotoMedium = "Roboto-Medium"
    static let kfontNameBold = "HelveticaNeueLTPro-Bd"
}

class streamtbl: NSObject {
    
    @IBOutlet var lblusername: WKInterfaceLabel!
    
    @IBOutlet var lbldescription: WKInterfaceLabel!
    
    @IBOutlet var imgLikeicon: WKInterfaceImage!
    @IBOutlet var lbltime: WKInterfaceLabel!
    
    @IBOutlet var lbllikecount: WKInterfaceLabel!
}

class StreamVC_watch: WKInterfaceController {
    @IBOutlet weak var table: WKInterfaceTable!
    @IBOutlet var imgLoader: WKInterfaceImage!
    
    var arrayStream = NSMutableArray()
    
    let objects: [RowData] = []
    var totalStreamPost:Int = 0
    var offsetSt:Int = 1
    var session : WCSession!


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let userDefaults = UserDefaults.standard
        
        
        if let strwuid = userDefaults.value(forKey: "wuid") as? String
        {
            
            getStreamPost()
            
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
    
    
    // MARK:---------------
    // MARK: Segue Operations
    // MARK:---------------
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        
        if(segueIdentifier == "commentlistdt")
        {
            
            
            
            
            return (arrayStream.object(at: rowIndex) as AnyObject).value(forKey: "id")
        }
        
        return nil
        
    }
    
    // MARK: ----------------------
    // MARK: - webservice methods
    // MARK: ----------------------


    func getStreamPost()
    {
        
        if let arraystream = UserDefaults.standard.value(forKey: "stream") as? NSMutableArray
        {
            
            self.arrayStream  = arraystream
            self.renederdata()

            
        }
        else
        {
        
        
        self.showLoader()

        let userDefaults = UserDefaults.standard


        print(userDefaults.value(forKey: "wuid"))
         let parameters = ["offset":"0", "limit":"10","uid":(userDefaults.object(forKey: "wuid") as! String),"myid":(userDefaults.object(forKey: "wuid") as! String),"posttype":"0"] as Dictionary<String, String>
    
    let request = NSMutableURLRequest(url: URL(string: "https://api.screamxo.com/mobileservice/Posts/getdashboardstream")!)
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
                    
                    if let countShop :  Int = (json.value(forKey: "result")! as AnyObject).value(forKey: "count") as? Int
                    {
                        self.totalStreamPost = countShop
                    }
                    
                    if self.offsetSt == 1
                    {
                        self.arrayStream.removeAllObjects()
                        
                        self.arrayStream = (((json.value(forKey: "result")! as AnyObject).value(forKey: "posts") as! NSArray).mutableCopy() as? NSMutableArray)!
                    }
                    else
                    {
                        self.arrayStream.addObjects(from: ((json.value(forKey: "result")! as AnyObject).value(forKey: "posts")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
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
    
    // MARK:---------------
    // MARK: data UI
    // MARK:---------------
    
    func renederdata()
    {
    
        let rows = Array(repeating: "Stream", count: self.arrayStream.count)
        
        self.table.setRowTypes(rows)
        
        if (self.arrayStream.count>0)
        {
            
            for i in 0 ..< self.arrayStream.count {
                if let row = self.table.rowController(at: i) as? streamtbl {
                    
                    
                    let strusername:String?=(self.arrayStream.object(at: i) as AnyObject).value(forKey: "username")! as? String
                    
                    if (strusername == "" || strusername == nil)
                    {
                        row.lblusername.setText("\((self.arrayStream.object(at: i) as AnyObject).value(forKey: "fname") as! String)"  +  " \((self.arrayStream.object(at: i) as AnyObject).value(forKey: "lname") as! String)")
                    }
                    else
                    {
                        row.lblusername.setText(strusername)
                    }
                    
                    /*let strDescription = self.arrayStream.objectAtIndex(i).valueForKey("post_title")! as? String
                    if let strDesc:String = (strDescription)! as String
                    {
                        let style = NSMutableParagraphStyle()
                        style.lineSpacing = 5
                        let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                                  NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
                        
                        let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
                        let mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
                        
                        for _ in customEmojis.emojiItemsArray {
                            self.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
                        }
                        
                        row.lbldescription.setAttributedText(mutableStrDesc)
                        row.lbldescription.textInsets = UIEdgeInsetsMake(5, 5, 5, 5)
                        row.lbldescription.allowLineBreakInsideLinks = false
                        row.lbldescription.linkTextAttributes = nil
                        row.lbldescription.activeLinkTextAttributes = nil
                    }*/
                    
                    row.lbldescription.setText((self.arrayStream.object(at: i) as AnyObject).value(forKey: "post_title")! as? String)
                    
                    let strlikeCount:Int=((self.arrayStream.object(at: i) as AnyObject).value(forKey: "likecount")! as? Int)!
                    
                    row.lbllikecount.setText("\(strlikeCount)")
                    var strtime:String?=(self.arrayStream.object(at: i) as AnyObject).value(forKey: "updated_date")! as? String
                    strtime=NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
                    
                    row.lbltime.setText(strtime)
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
    
    // MARK: Loader Methods
    
    func showLoader(){
        
        self.imgLoader.setHidden(false)
        self.imgLoader.setImageNamed("tmp-")
        self.imgLoader.startAnimatingWithImages(in: NSRange(location: 0,length: 11), duration: 1, repeatCount: -1)
        
        
    }
    
    func hideLoader(){
        
        self.imgLoader.stopAnimating()
        self.imgLoader.setHidden(true)
        
    }

//    func replaceEmoji(emojiName: String, inout mutableStrDesc: NSMutableAttributedString) {
//        let textAttachment = MyTextAttachment()
//        textAttachment.image = UIImage(named: emojiName)
//        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
//
//        let mutAttrString = NSMutableAttributedString()
//        mutAttrString.appendAttributedString(attrStringWithImage)
//        
//        while mutableStrDesc.mutableString.containsString(emojiName)
//        {
//            let range = mutableStrDesc.mutableString.rangeOfString(emojiName)
//            mutableStrDesc.replaceCharactersInRange(range, withAttributedString: mutAttrString)
//            
//        }
//    }


}


