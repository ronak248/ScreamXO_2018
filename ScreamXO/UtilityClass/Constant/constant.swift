//
//  constant.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 10/09/15.
//  Copyright (c) 2015 Twizz Ltd All rights reserved.
//

import Foundation
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


class Main {
    var name:String
    var notificationCount = 0
  
    var dTokenData = Data()
    var dTokenString :String! 
    typealias completionHandlerBlock = (NSDictionary? , Bool)  -> ()
    
    func changePopUpStyle() {
        let appearance = WYPopoverBackgroundView.appearance()
        appearance.fillTopColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0)
        appearance.outerCornerRadius = 25
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        
        //println("validate emilId: \(testStr)")
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        let result = emailTest.evaluate(with: testStr)
        
        return result
        
    }
    func isTextfieldBlank (_ textField : UITextField) -> Bool
    {
        if textField.text?.characters.count > 0
        {
            let trimmedString = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            if trimmedString.characters.count > 0
            {
                return false
            }
            return true
        }
        return true
    }
    
    func isTextviewBlank (_ textField : SAMTextView) -> Bool {
        if textField.text?.characters.count > 0
        {
            let trimmedString = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
            if trimmedString.characters.count > 0
            {
                return false
            }
            return true
        }
        return true
    }
    func ShowAlert(_ title : NSString , msg :NSString ) {
        _ = SweetAlert().showAlert(constant.kAppName, subTitle: msg as String, style: AlertStyle.none)
    }
    func ShowAlertWithError(_ title : NSString , msg :NSString ) {
        _ = SweetAlert().showAlert(constant.kAppName, subTitle: msg as String, style: AlertStyle.error)
    }
    func showSomethingWentWrong() {
        _ = SweetAlert().showAlert("Error!", subTitle: "Something went wrong, please try again later", style: AlertStyle.error)
    }
    func showNoInternetAlert() {
        _ = SweetAlert().showAlert("Error!", subTitle: "No internet connection, Please connect internet", style: AlertStyle.error)
    }
    func ShowAlertWithSucess(_ title : NSString , msg :NSString ) {
        _ = SweetAlert().showAlert(constant.kAppName, subTitle: msg as String, style: AlertStyle.success)
    }
    func shoAlertWithBlock(_ title : NSString, msg : NSString, buttonOkTitle : NSString, completionHandler:@escaping (Bool )->()) {
        _ = SweetAlert().showAlert(title as String, subTitle: msg as String, style: .none, buttonTitle: buttonOkTitle as String) { (isOtherButton) -> Void in
            completionHandler(true)
        }
    }
    func showAlertWithConfirm(_ title : NSString , msg : NSString , buttonOkTitle: NSString , buttonOtherTitle: NSString,  completionHandler:@escaping (Bool )->()) {
        SweetAlert().showAlert(title as String, subTitle: msg as String, style: AlertStyle.warning, buttonTitle:buttonOtherTitle as String, buttonColor:UIColor(hexString: "008040")! , otherButtonTitle:  buttonOkTitle as String, otherButtonColor: colors.kRedColor) { (isOtherButton) -> Void in
            if isOtherButton == true
            {
                completionHandler(true)
            }
            else
            {
                completionHandler(false)
            }
        }
    }
    func ResizeImage(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        if let image = image {
            let size = image.size
            
            let widthRatio  = targetSize.width  / image.size.width
            let heightRatio = targetSize.height / image.size.height
            
            // Figure out what our orientation is, and use that to form the rectangle
            var newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
            }
            
            // This is the rect that we've calculated out and this is what is actually used below
            let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
            
            // Actually do the resizing to the rect using the ImageContext stuff
            UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
            image.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage
        } else {
            return nil
        }
    }
    func connected() -> Bool {
        let reachability = Reachability.forInternetConnection()
        let networkStatus: Int = reachability!.currentReachabilityStatus().rawValue
        return networkStatus != 0
    }
    func getDateStringForDisplay(_ strDate : String) -> String? {
//        2015-10-08T20:00:00Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
        if let date = formatter.date(from: strDate) {
            let s = dateFormatter.string(from: date)
            return s
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSz"
            if let  date = formatter.date(from: strDate) {
                
                let s = dateFormatter.string(from: date)
                return s
            }
        }
        return nil
    }
    func createProfileImageName() -> String? {
        //        2015-10-08T20:00:00Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date = Date()
        let s = dateFormatter.string(from: date)
        
        return "profile_" + s + ".png"
    }
    func createChatImageName() -> String?
    {
        //        2015-10-08T20:00:00Z
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        let date = Date()
        let s = dateFormatter.string(from: date)
        
        return "chat_" + s + ".png"
    }
    func convertFbDateToDate(_ strDate : String) -> String?
    {//"01/06/1986"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        if let date = formatter.date(from: strDate) {
            let s = dateFormatter.string(from: date)
            return s
        } else {
            formatter.dateFormat = "MM/dd/yyyy"
            if let  date = formatter.date(from: strDate) {
                
                let s = dateFormatter.string(from: date)
                return s
            }
        }
        return nil
    }
    func getProperDateString(_ strDate : String) -> String?
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: strDate) {
            let s = dateFormatter.string(from: date)
            return s
        } else {
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            if let  date = formatter.date(from: strDate) {
                
                let s = dateFormatter.string(from: date)
               return s
            }
        }
        return nil
    }
    func calculateAge (_ birthday: Date) -> NSInteger {
        
        //var userAge : NSInteger = 0
        let calendar : Calendar = Calendar.current
        let unitFlags : NSCalendar.Unit = [ .year , .month, .day]
        let dateComponentNow : DateComponents = (calendar as NSCalendar).components(unitFlags, from: Date())
        let dateComponentBirth : DateComponents = (calendar as NSCalendar).components(unitFlags, from: birthday)
        
        if ((dateComponentNow.month < dateComponentBirth.month) || ((dateComponentNow.month == dateComponentBirth.month) && (dateComponentNow.day < dateComponentBirth.day))) {
            return dateComponentNow.year! - dateComponentBirth.year! - 1
        }
        else {
            return dateComponentNow.year! - dateComponentBirth.year!
        }
    }
    
   // func ResizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {

    func imageisequal(_ image1: UIImage?, image2: UIImage) -> Bool? {
        
        var data1=Data()
        var data2=Data()
        data1 = UIImagePNGRepresentation(image1!)!
        data2 = UIImagePNGRepresentation(image2)!
        
        return (data1 == data2);
    }
    func getCurrentGMTDateString() -> String? {
        let date = Date();
        let formatter = DateFormatter();
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss";
        //let defaultTimeZoneStr = formatter.stringFromDate(date);
        // "2015-04-01 08:52:00 -0400" <-- same date, local, but with seconds
        formatter.timeZone = TimeZone(abbreviation: "UTC");
        let utcTimeZoneStr = formatter.string(from: date);
        // "2015-04-01 12:52:00 +0000" <-- same date, now in UTC
        return utcTimeZoneStr
    }
    func utcToCurrentTimeAndMakeReadable(_ time: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        var date = dateFormatter.date(from: time)
        if date == nil
        {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZ"
            date = dateFormatter.date(from: time)
        }
        // change to a readable time format and change to local time zone
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "HH:mm dd MMM yyyy"
        dateFormatter2.timeZone = TimeZone.current
        let timeStamp = dateFormatter2.string(from: date!)
        return timeStamp
    }
    init(name:String) {
        self.name = name
    }
    
     func printFonts() {
        for fontFamilyName in UIFont.familyNames {
            print("-- \(fontFamilyName) --", terminator: "")
            
            for fontName in UIFont.fontNames(forFamilyName: fontFamilyName ) {
                print(fontName)
            }
            
            print(" ", terminator: "")
        }
    }
    
    func counrtyNames() -> NSArray{
        
        let countryCodes = Locale.isoRegionCodes
        let countries:NSMutableArray = NSMutableArray()
        
        for countryCode  in countryCodes{
            
            let locale = Locale.current
            //get country name
            let country = (locale as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value : countryCode)//replace "NSLocaleIdentifier"  with "NSLocaleCountryCode" to get language name
            
            if country != nil {//check the country name is  not nil
                countries.add(country!)
            }
        }
        NSLog("\(countries)")
        return countries
    }
}
var mainInstance = Main(name:"My Global Class")

struct constant {
    static let kAppName                 = "ScreamXO"
    static let kAwsPoolId               = "eu-west-1:c805e781-b69b-4e38-8acb-67892a0ef6d9"
    static let kBucketName              = "twizzstaging"
    static let kProfileFolderName       = "profile_pictures"
    static let kConnectionFolderName    = "connection_photos"
    static let kMessageFolderName       = "messaging_photos"
    
    static let ksandboxcoinbaseapi       = "https://api.coinbase.com/"
    static let kPaypalAPI = "https://api.sandbox.paypal.com/"

    static let kTwiiterConsumerKey       = "jMb0r0Fw70JpBKjJgkOIbmYdR"
    static let kTwiiterConsumersecret       = "6SsIalMCL1AO0fFT3WV45geI84R7GZjzNojiV8tzcJcFVHGrLR"
    
    static let kshortcutmediapost       = "com.screamxo.postmedia"
    static let kshortcutsellnow       = "com.screamxo.sellnow"
    static let kshortcutstreampost       = "com.screamxo.poststream"

    static let kmessagePurchase       = "__username__ purchased __quentity__ Item for $__price__ Price"

    static let biglaugh       = "e8912"

    
    static let imgProfilePicPlaceholder:UIImage     = UIImage(named: "profile_pic_placeholder")!
    static let linkVerifyNotification               = "linkVerifyNotification"
    static let updateLinksNotification              = "updateLinkArray"
    static let updateFriendsRequestsNotification    = "updateFriendRequests"
    static let updateActivitiesNotification         = "updateActivitiesNotification"
    static let stopActivityFooterSpinerNotification = "stopActivityFooterSpiner"
    static let updateRecentChatNotification         = "updateRecentChatArray"
    static let internetWorkingNotification          = "internetWorkingNotification"
    static let internetNotWorkingNotification       = "internetNotWorkingNotification"
    static let newMessageReceivedNotification       = "newMessageReceivedNotification"
    static let updateChallangeStatusNotification    = "updateChallangeStatusNotification"
    static let updateOtherUserScreenNotification    = "updateOtherUserScreenNotification"
    static let refreshSideMenuNotification          = "refreshSideMenuNotification"
    static let setHomeVCNotification                = "setHomeVCNotification"
    
    static let forVideoPlayinglanscape                = "forVideoPlayinglanscape"
    static let forVideostopPlayinglanscape                = "forVideostopPlayinglanscape"
    static let forVideoMediaLike                = "forVideoMediaLike"
    static let PlayNext                = "PlayNext"

    static let forbitcoinprocess                = "forbitcoinprocess"

    static let ktimeout                 = "Request timeout. Please try again later."
    static let kinternetMessage                 = "Make sure your device is connected to the internet."
    static let kloginFailed                 = "Login Failed. Please try again."
    
    static let kInfoAvailable = "kInfoAvailable"
    static let kStreet = "kStreet"
    static let kCity = "kCity"
    static let kZip  = "kZip"
    static let kState = "kState"
    static let kCountry = "kCountry"
    
    // MARK: <CircleMenu properties>
    
    static let post = "POST"
    static let people = "PEOPLE"
    static let profile = "PROFILE"
    static let world = "WALLET"
    static let shop = "SHOP"
    static let chat = "SETTING"
    static let screen = "SCREEN"
    static let filter = "FILTER"
    
    static let roundButtonsBgColor = UIColor(red:0.73, green:0.73, blue:0.73, alpha: 1.0)
    static let gsmButton2Titles = [post, people, shop, world, chat, profile, screen, filter]
    
    static let itemsGSM: [Int : String] = [
        0   :   "menu-ico-post",
        1   :   "menu-ico-people",
        2   :   "menu-ico-shop",
        3   :   "menu-ico-world",
        4   :   "menu_ico_settings", //menu-ico-chat
        5   :   "menu-ico-profile",
        6   :   "menu_ico_dash",
        7   :   "menu_ico_search"
    ]
    
    static var btnObj1: CircleMenu!
    static var btnObj2: CircleMenu!
    
    static var onFiltering = false
    static var onPosting = false
    
    static var onShopFilter = false
    static var onWorldFilter = false
    
    static var isDashboardExpanded = true
    
    static var onMediaHeaderOptions = false
    static var onShopHeaderOptions = false
    static var onStreamHeaderOptions = false
    
    static var onSellerHistoryOptions = false
    static var onRecieptOptions = false
    
    static var onSearchDash = false
}

struct RandomColor {
    static let KRandomRed = UIColor (red: 0.9859, green: 0.0, blue: 0.027, alpha: 1.0)
    static let KRandomBlue = UIColor (red: 0.0, green: 0.0, blue: 0.9982, alpha: 1.0)
    static let KRandomGreen = UIColor (red: 0.1353, green: 1.0, blue: 0.0249, alpha: 1.0)
    static let KRandomYellow = UIColor (red: 0.9952, green: 0.7644, blue: 0.0368, alpha: 1.0)
    static let KRandomPurple = UIColor (red: 0.2596, green: 0.0038, blue: 0.4706, alpha: 1.0)
    static let KRandomBrown = UIColor (red: 0.3225, green: 0.1484, blue: 0.0044, alpha: 1.0)
    static let KRandomPink = UIColor (red: 0.9876, green: 0.2982, blue: 0.6471, alpha: 1.0)
    static let KRandomBlack = UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    static let KRandomWhite = UIColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let KRandomAqua = UIColor (red: 0.0605, green: 0.4479, blue: 0.4343, alpha: 1.0)
    static let KRandomLime = UIColor (red: 0.1844, green: 0.7817, blue: 0.1498, alpha: 1.0)
    static let KRandomOrange = UIColor (red: 0.9917, green: 0.5813, blue: 0.034, alpha: 1.0)
    static let KRandomGrey = UIColor.gray
    //
}
struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}
struct DeviceType {
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}
struct fontsName {
    static let KfontproxiRegular = "ProximaNova-Regular"
    static let KfontproxisemiBold = "ProximaNova-Semibold"
    static let KfontproxiBold = "ProximaNova-Bold"
    static let kfontproxiExtraBold = "ProximaNova-Extrabld"
    static let KfontNameRoman = "HelveticaNeueLTPro-Roman"
    static let KfontNameSTDRoman = "HelveticaNeueLTStd-Roman" //HelveticaNeueLTStd-Lt 
    static let KfontNameSTDLite = "HelveticaNeueLTStd-Lt"
    static let kfontNameMedium = "HelveticaNeueLTPro-Md"
    static let kfontNameRobotoMedium = "Roboto-Medium"
    static let kfontNameBold = "HelveticaNeueLTPro-Bd"
}

struct fonts {
    static let KfontproxiRegularfont = UIFont(name: "ProximaNova-Regular", size: 17)
    static let KfontRoman = UIFont(name: "HelveticaNeueLTPro-Roman", size: 17)
    static let kfontMedium = UIFont(name: "HelveticaNeueLTPro-Md", size: 17)
    static let kfontRobotoMedium = UIFont(name: "Roboto-Medium", size: 22)
    static let KfontproxisemiBold = UIFont(name: fontsName.KfontproxisemiBold, size: 17.0)
    static let kfontproxiBold = UIFont(name: "ProximaNova-Bold", size: 17.0)
    static let kfontproxiBold2 = UIFont(name: "ProximaNova-Bold", size: 18.0)
}

struct colors {
    static let KOrangeTextColor = UIColor (red: 0.922, green: 0.322, blue: 0.0, alpha: 1.0) //(red: 0.8909, green: 0.2324, blue: 0.0245, alpha: 1.0)
    static let KBalckTextColor = UIColor (red: 0.0561, green: 0.0561, blue: 0.0561, alpha: 1.0)
    static let KLightTextColor = UIColor (red: 178/255, green: 178/255, blue: 176/255, alpha: 1.0)
    
    static let kbgprofile = UIColor (red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)

    
    static let kTextViewColor = UIColor (red: 51/255, green: 51/255, blue: 4/255, alpha: 1.0)

    
    static let kLightgrey155 = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
    static let kLightgrey196 = UIColor (red: 196/255, green: 196/255, blue: 196/255, alpha: 1.0)
    static let kLightgrey110 = UIColor (red: 110/255, green: 110/255, blue: 110/255, alpha: 1.0)
    static let kLightblack = UIColor (red: 13/255, green: 8/255, blue: 4/255, alpha: 1.0)

    static let KbtnLightborderTextColor = UIColor (red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0)
    
    static let kPinkColour = UIColor(red: 254/255, green: 104/255, blue: 106/255, alpha: 1.0)


    static let kTabBarUnselectedColor = UIColor (red: 0.8951, green: 0.5602, blue: 0.4043, alpha: 1.0)
    static let kYellowColor = UIColor (red: 0.9911, green: 0.5449, blue: 0.0576, alpha: 1.0)
    static let kRedColor = UIColor (red: 0.673, green: 0.0, blue: 0.106, alpha: 1.0)
    static let kChallengeDescColor = UIColor (red: 0.2567, green: 0.2567, blue: 0.2567, alpha: 1.0)
    
    static let klightgreyfont = UIColor (red: 178/255, green: 178/255, blue: 176/255, alpha: 1.0) //(red: 0.8909, green: 0.2324, blue: 0.0245, alpha: 1.0)
    
    static let kPlaceholderTextColor = UIColor (red: 178/255, green: 178/255, blue: 176/255, alpha: 1.0) //(red: 0.8909, green: 0.2324, blue: 0.0245, alpha: 1.0)

}

public func setAttributedPlaceholder(_ txtField : UITextField) {
    txtField.attributedPlaceholder = NSAttributedString(string:txtField.placeholder!,
        attributes:[NSForegroundColorAttributeName:colors.kPlaceholderTextColor])
}

struct Urls {
    static let baseURL = "http://staging.twizz.com/api/v1/"
}

struct keys {
    static let parseAppId = "2dDYmib6RSM2PO3Hg86M7wNvRrMOWSJYgkjbwec9"
    static let parseClientId = "sTp8mkrfMnzphllWldlyzNrxxKXCTAslgxnyu0sF"
    static let stripeKey = "pk_test_pN6YbjnbmNlQktWQBu4LlsJB"
    static let stripeSecreatKey = "sk_test_Szb9cIKCpyBF5O5mS4TgO6TE"
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

enum PositionMenu: String {
    case bottomRight = "BottomRight"
    case topLeft = "TopLeft"
    case topRight = "TopRight"
    case bottomLeft = "BottomLeft"
}

