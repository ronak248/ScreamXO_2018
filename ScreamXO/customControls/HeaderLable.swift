//
//  HeaderLable.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 25/09/15.
//  Copyright (c) 2015 Twizz Ltd All rights reserved.
//

import Foundation
@IBDesignable
class HeaderLable: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        if DeviceType.IS_IPHONE_6P {
            self.font = UIFont(name: fontsName.KfontproxiRegular, size: 18)
        } else if DeviceType.IS_IPHONE_6 {
            self.font = UIFont(name: fontsName.KfontproxiRegular, size: 17)
        } else {
            self.font = UIFont(name: fontsName.KfontproxiRegular, size: 16)
        }
        self.textColor = colors.kLightgrey155
        if let strText = self.text {
            self.text = strText.uppercased()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont(name: fontsName.KfontproxiRegular, size: 16)
        self.textColor = colors.kLightgrey155
    
        if let strText = self.text
        {
            self.text = strText.uppercased()
        }
    }
}
