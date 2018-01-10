//
//  UserManager.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 17/09/15.
//  Copyright (c) 2015 Twizz Ltd All rights reserved.
//


import Foundation
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotificaiton = "userDidLogoutNotification"
let refreshUserDataNotification = "refreshUserDataNotification"

private struct UserConstants {
    
    // NSUserDefaults persistence keys
    static let UsernameKey            = "UsernameKey"
    static let FirstnameKey           = "FirstnameKey"
    static let LastnameKey            = "LastnameKey"
    static let fullnameKey            = "fullnameKey"
    static let username               = "usernameKey"
    static let EmailKey               = "EmailKey"
    static let walletMoneyKey        = "walletMoney"
    static let ProfileImageKey        = "ProfileImage"
    static let phonenoKey             = "phonenoKey"
    static let jobkey                 = "jobKey"
    static let schoolKey              = "schoolKey"
    static let facebookIdKey          = "facebookIdKey"
    static let receiveEmailsKey       = "receiveEmailsKey"
    static let userIdKey              = "userIdKey"
    static let twitterIdKey           = "twitterIdKey"
    static let cityKey                = "cityKey"
    static let zipKey                 = "zipKey"
    static let GenderKey              = "GenderKey"
    static let sexpref              = "sexpref"

    static let hobbyKey         = "hobbyKey"
    static let issocialKey         = "issocialKey"
    static let ispaypalConfigured         = "ispaypalConfigured"
    static let paymentPrefrence         = "paymentPrefrence"

    static let nationalityKey         = "nationalityKey"
    static let relationshipstKey      = "relationshipstKey"
    static let stripeCustomerId      = "stripeCustomerId"
    
    
}

class UserManager {
    
    // static properties get lazy evaluation and dispatch_once_t for free
    struct Static {
        static let instance = UserManager()
    }
    
    // this is the Swift way to do singletons
    class var userManager: UserManager
    {
        return Static.instance
    }
    
    // user authentication always begins with a UUID
    let userDefaults = UserDefaults.standard

    
    // username etc. are backed by NSUserDefaults, no need for further local storage
    var username: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.UsernameKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.UsernameKey)
            userDefaults.synchronize()
        }
        
    }
    
    var emailAddress: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.EmailKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.EmailKey)
            userDefaults.synchronize()
        }
        
    }
    
    
    var ispaypalconfi: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.ispaypalConfigured) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.ispaypalConfigured)
            userDefaults.synchronize()
        }
        
    }
    var paymentPrefrence: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.paymentPrefrence) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.paymentPrefrence)
            userDefaults.synchronize()
        }
        
    }
    
    var firstname: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.FirstnameKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.FirstnameKey)
            userDefaults.synchronize()
        }
        
    }
    //fullnameKey
    var fullName: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.fullnameKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.fullnameKey)
            userDefaults.synchronize()
        }
        
    }
    var lastname: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.LastnameKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.LastnameKey)
            userDefaults.synchronize()
        }
        
    }
    
    var profileImage: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.ProfileImageKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.ProfileImageKey)
            userDefaults.synchronize()
        }
        
    }
    
    var walletMoney: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.walletMoneyKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.walletMoneyKey)
            userDefaults.synchronize()
        }
        
    }
    
    
    var stripeCustomerId: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.stripeCustomerId) as? String ?? nil
        }
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.stripeCustomerId)
            userDefaults.synchronize()
        }
        
    }
    
    var job: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.jobkey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.jobkey)
            userDefaults.synchronize()
        }
        
    }
    
    var school : String?
    {
        get {
            return userDefaults.object(forKey: UserConstants.schoolKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.schoolKey)
            userDefaults.synchronize()
        }
    }
        var facebookId: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.facebookIdKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.facebookIdKey)
            userDefaults.synchronize()
        }
        
    }
    var receiveEmails: String? {
        
        get {
            return userDefaults.object(forKey: UserConstants.receiveEmailsKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.receiveEmailsKey)
            userDefaults.synchronize()
        }
        
    }
        var userId: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.userIdKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.userIdKey)
            userDefaults.synchronize()
        }
        
    }
    
       var setTwitter: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.twitterIdKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.twitterIdKey)
            userDefaults.synchronize()
        }
        
    }
    var setjobkey: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.jobkey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.jobkey)
            userDefaults.synchronize()
        }
        
    }
    var setcityKey: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.cityKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.cityKey)
            userDefaults.synchronize()
        }
        
    }
    var setzipKey: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.zipKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.zipKey)
            userDefaults.synchronize()
        }
        
    }
    var setGenderKey: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.GenderKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.GenderKey)
            userDefaults.synchronize()
        }
        
    }
    var setsexpref: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.sexpref) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.sexpref)
            userDefaults.synchronize()
        }
        
    }
    var setnationalityKey: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.nationalityKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.nationalityKey)
            userDefaults.synchronize()
        }
        
    }
    var setHobby: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.hobbyKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.hobbyKey)
            userDefaults.synchronize()
        }
        
    }
    var setSOcial: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.issocialKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.issocialKey)
            userDefaults.synchronize()
        }
    }
    var setjob: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.jobkey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.jobkey)
            userDefaults.synchronize()
        }
        
    }
    var setrelationshipstKey: String?
        {
        
        get {
            return userDefaults.object(forKey: UserConstants.relationshipstKey) as? String ?? nil
        }
        
        set (newValue) {
            userDefaults.set(newValue, forKey: UserConstants.relationshipstKey)
            userDefaults.synchronize()
        }
        
    }
    func clearUUID()
    {
        //NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotificaiton, object: nil)
        self.username       = nil
        self.firstname      = nil
        self.lastname       = nil
        self.emailAddress   = nil
        self.profileImage   = nil
        self.facebookId        = nil
        self.setTwitter = nil
        self.setjob  = nil
        self.setrelationshipstKey = nil
        self.setcityKey  = nil
        self.job    = nil
        self.school            = nil
        self.facebookId     = nil
        self.setzipKey       = nil
        self.receiveEmails  = nil
        self.setnationalityKey  = nil
        self.setHobby  = nil
        self.setGenderKey  = nil
        self.setsexpref  = nil

        self.userId         = nil
        self.fullName       = nil
        self.ispaypalconfi       = nil
        self.paymentPrefrence       = nil
        self.job       = nil
        self.school       = nil
        self.facebookId       = nil
        self.receiveEmails       = nil
        self.setTwitter       = nil
        self.setjobkey       = nil


        //mgr.clearSession()
        // this works because the TJUserManager will recreate a UUID on next access, & Validate() etc. will do the rest
        userDefaults.removeObject(forKey: UserConstants.FirstnameKey)
        userDefaults.removeObject(forKey: UserConstants.LastnameKey)
        userDefaults.removeObject(forKey: UserConstants.EmailKey)
        userDefaults.removeObject(forKey: UserConstants.ProfileImageKey)
        userDefaults.removeObject(forKey: UserConstants.jobkey)
        userDefaults.removeObject(forKey: UserConstants.facebookIdKey)
        userDefaults.removeObject(forKey: UserConstants.twitterIdKey)
        userDefaults.removeObject(forKey: UserConstants.schoolKey)
        userDefaults.removeObject(forKey: UserConstants.facebookIdKey)
        userDefaults.removeObject(forKey: UserConstants.receiveEmailsKey)
        userDefaults.removeObject(forKey: UserConstants.userIdKey)
        userDefaults.removeObject(forKey: UserConstants.fullnameKey)
        userDefaults.removeObject(forKey: UserConstants.username)
        userDefaults.removeObject(forKey: UserConstants.cityKey)
        userDefaults.removeObject(forKey: UserConstants.GenderKey)
        userDefaults.removeObject(forKey: UserConstants.sexpref)

        userDefaults.removeObject(forKey: UserConstants.stripeCustomerId)
        userDefaults.removeObject(forKey: UserConstants.nationalityKey)
        userDefaults.removeObject(forKey: UserConstants.relationshipstKey)
        userDefaults.removeObject(forKey: UserConstants.phonenoKey)
        userDefaults.removeObject(forKey: UserConstants.zipKey)
        userDefaults.removeObject(forKey: UserConstants.ispaypalConfigured)
        userDefaults.removeObject(forKey: UserConstants.issocialKey)
        userDefaults.removeObject(forKey: UserConstants.GenderKey)
        userDefaults.removeObject(forKey: UserConstants.paymentPrefrence)
        userDefaults.removeObject(forKey: UserConstants.relationshipstKey)



        userDefaults.synchronize()
    }
}
