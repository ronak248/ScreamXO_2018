//
//  RoundRectbtn.swift
//  TravelApp
//
//  Created by Tejas Ardeshna on 16/12/15.
//  Copyright © 2015 Tejas Ardeshna. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

@IBDesignable
class RoundButton: UIButton {
    override  func draw(_ rect: CGRect) {
        self.backgroundColor = UIColor.blue
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true
    }
}

@IBDesignable
class RoundRectbtn: UIButton
{
    //MARK: Initializers
    override var backgroundColor: UIColor?  {
       
        didSet {
            super.backgroundColor = colors.kPinkColour
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        self.titleLabel?.font = UIFont(name: fontsName.KfontproxiRegular, size: 18)
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.backgroundColor = UIColor.blue
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
    }
}
class RoundRectbtnIpad: RoundRectbtn
{
    //MARK: Initializers
    
    override func draw(_ rect: CGRect) {
        self.titleLabel?.font = UIFont(name: fontsName.KfontproxiRegular, size: 29)
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.backgroundColor = UIColor.blue
        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
    
        
    }
}
class RoundRectbtncir: RoundRectbtn
{
    //MARK: Initializers
    
    
    override  func draw(_ rect: CGRect) {
        //self.titleLabel?.font = UIFont(name: fontsName.KfontproxisemiBold, size: 14)
        //self.setTitleColor(UIColor.white, for: .normal)
        self.backgroundColor = UIColor.blue
        self.layer.cornerRadius = 15;
        self.layer.masksToBounds = true
    }
    
    func setBackgroundcolorbtn() {
        self.backgroundColor = UIColor.blue
        

    }
}
