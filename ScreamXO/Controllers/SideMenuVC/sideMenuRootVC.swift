//
//  sideMenuRootVC.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 30/09/15.
//  Copyright © 2015 Twizz Ltd. All rights reserved.
//

import Foundation
class sideMenuRootVC: REFrostedViewController {


    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "HomeScreen")
        
        
        self.menuViewController = objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "menuController")
        
    }
    
}
