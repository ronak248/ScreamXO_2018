//
//  Message.swift
//  WhereIts
//
//  Created by Jatin Kathrotiya on 14/07/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit


import Foundation
import WatchKit

class Message: NSObject {

    // MARK: ScreamXO
    
    var messageid:Int = 0
    var sender_id: Int = 0
    var messagedate:String = ""
    var messagetext:String?
    var media_original_name: String = ""
    var media_thumb: String = ""
    var media: String = ""
    var media_type:String = ""

    func Populate(_ dictionary:[String:AnyObject]) {
        
        messageid = Int((dictionary["messageid"])! as! String)!
        messagedate =  dictionary["messagedate"] as! String
        sender_id = Int((dictionary["senderid"])! as! String)!
        messagetext = dictionary["messagetext"] as? String
        media_type =  dictionary["mediatype"] as! String
        media_original_name = dictionary["mediaoriginalname"] as! String
        media_thumb = dictionary["mediathumb"] as! String
        media  = dictionary["media"] as! String
    }
    
    class func DateFromString(_ dateString:String) -> Date
    {
        
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation:"UTC")
        let date = dateFormatter.date(from: dateString)!
        
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let timestamp = dateFormatter.string(from: date)
        

        return dateFormatter.date(from: timestamp)!
    }
    
    
    class func Populate(_ dictionary:[String:AnyObject]) -> Message
    {
        
        let result = Message()
        result.Populate(dictionary)
        return result
    }
    
    class func PopulateArray(_ array:[AnyObject]) -> [Message]
    {
        let arr:[Message] = array.map {
            let newItem = Message()
            newItem.Populate($0 as! [String:AnyObject])
            return newItem
        }
        return arr
        
    }
    
    
}
