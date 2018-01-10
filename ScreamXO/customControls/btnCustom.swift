//
//  btnCustom.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 25/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
@IBDesignable
class btnCustom: UIButton
{
    //MARK: Initializers

    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        
        self.backgroundColor = UIColor(red: 138/255, green: 138/255, blue: 138/255, alpha: 1.0)
        self.setTitle("Menu", for: UIControlState())
        self.setTitleColor(UIColor.white, for: UIControlState())
        self.titleLabel?.font = UIFont(name: fontsName.KfontproxisemiBold, size: 18.0)
        self.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = 5.0
        self.clipsToBounds = true
//        self.frameWidth = 75.0
//        self.frameHeight = 25.0
    }
}
