//
//  ChatDateTime.swift
//  WhereIts
//
//  Created by Jatin Kathrotiya on 19/07/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit

enum ATLMDateProximity : Int {
    case today
    case yesterday
    case week
    case year
    case other
}
class ChatDateTime: NSObject {
 
    struct Static {
        static var onceToken: Int = 0
        static var instance: ChatDateTime? = nil
    }
    
    private static var __once: () = {
            Static.instance = ChatDateTime()
        }()
 
    class var sharedInstance: ChatDateTime {
        _ = ChatDateTime.__once
        return Static.instance!
    }
    
    func attributedStringForDisplayOfDate(_ date: Date) -> NSMutableAttributedString {
        var dateFormatter: DateFormatter
        let dateProximity: ATLMDateProximity = ATLMProximityToDate(date)
        switch dateProximity {
        case .today, .yesterday:
            dateFormatter = ATLMRelativeDateFormatter()
        case .week:
            dateFormatter = ATLMDayOfWeekDateFormatter()
        case .year:
            dateFormatter = ATLMThisYearDateFormatter()
        case .other:
            dateFormatter = ATLMDefaultDateFormatter()
        }
        
        let dateString: String = dateFormatter.string(from: date)
        let timeString: String = ATLMShortTimeFormatter().string(from: date)
        let dateAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: dateString + " " + timeString)
      
        
        return dateAttributedString
        
    }
    func  ATLMProximityToDate(_ date:Date) ->ATLMDateProximity{
        let calendar: Calendar = Calendar.current
        let now: Date = Date()
        let calendarUnits : NSCalendar.Unit = [.era, .year, .weekOfMonth , .month , .day]
        
        
        let dateComponents: DateComponents = (calendar as NSCalendar).components(calendarUnits, from: date)
        let todayComponents: DateComponents = (calendar as NSCalendar).components(calendarUnits, from: now)
        if dateComponents.day == todayComponents.day && dateComponents.month == todayComponents.month && dateComponents.year == todayComponents.year && dateComponents.era == todayComponents.era {
            return .today
        }
        
        var componentsToYesterday: DateComponents = DateComponents()
        componentsToYesterday.day = -1
        let yesterday: Date = (calendar as NSCalendar).date(byAdding: componentsToYesterday, to: now, options: .wrapComponents)!
        let yesterdayComponents: DateComponents = (calendar as NSCalendar).components(calendarUnits, from: yesterday)
        if dateComponents.day == yesterdayComponents.day && dateComponents.month == yesterdayComponents.month && dateComponents.year == yesterdayComponents.year && dateComponents.era == yesterdayComponents.era {
            return .yesterday
        }
        if dateComponents.weekOfMonth == todayComponents.weekOfMonth && dateComponents.month == todayComponents.month && dateComponents.year == todayComponents.year && dateComponents.era == todayComponents.era {
            return .week
        }
        if dateComponents.year == todayComponents.year && dateComponents.era == todayComponents.era {
            return .year
        }
        return .other;

    }
    
    func ATLMRelativeDateFormatter() ->  DateFormatter {
        var dateFormatter: DateFormatter?
        if (dateFormatter == nil) {
            dateFormatter = DateFormatter()
            dateFormatter!.dateStyle = .medium
            dateFormatter!.doesRelativeDateFormatting = true
        }
        return dateFormatter!
    }
    func ATLMDayOfWeekDateFormatter()->DateFormatter{
        var dateFormatter: DateFormatter?
         if (dateFormatter == nil) {
            dateFormatter = DateFormatter()
            dateFormatter!.dateFormat = "EEEE"
            // Tuesday
        }
        return dateFormatter!

    }
    func ATLMThisYearDateFormatter()->DateFormatter{
        var dateFormatter: DateFormatter?
        if (dateFormatter == nil) {

            dateFormatter = DateFormatter()
            dateFormatter!.dateFormat = "E, MMM dd "
            // Sat, Nov 29,
        }
        return dateFormatter!
        

    }
    
    func ATLMDefaultDateFormatter()->DateFormatter{
        var dateFormatter: DateFormatter?
        if (dateFormatter == nil) {
            dateFormatter = DateFormatter()
            dateFormatter!.dateFormat = "MMM dd, yyyy "
            // Nov 29, 2013,
        }
        return dateFormatter!
    }
    
    func ATLMShortTimeFormatter()->DateFormatter{
        var dateFormatter: DateFormatter?
        if (dateFormatter == nil) {
            
            dateFormatter = DateFormatter()
            dateFormatter!.timeStyle = .short
        }
        return dateFormatter!
    }
}
