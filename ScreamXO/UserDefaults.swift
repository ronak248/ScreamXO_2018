//
//  UserDefaults.swift
//  ScreamXO
//
//  Created by Chetan Dodiya on 01/05/17.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import Foundation


enum Defaults: String {
    
    case firstTimeMenuLoaded
    case userData
}


extension Defaults {
    
    var keyName: String {
        
        return rawValue
        
    }
    
    func set(_ value: Any) {
        
        UserDefaults.standard.set(value, forKey: keyName)
        
        UserDefaults.standard.synchronize()
    }
    
    var value: Any? {
        
        return UserDefaults.standard.value(forKey: keyName)
    }
}
