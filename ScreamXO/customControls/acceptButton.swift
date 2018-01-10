//
//  acceptButton.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 17/11/15.
//  Copyright © 2015 Twizz Ltd. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
@IBDesignable
class acceptButton: UIButton
{
    //MARK: Initializers
    override init(frame : CGRect) {
        super.init(frame : frame)
        setup()
        configure()
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
        setup()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        configure()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        configure()
    }
    func setup() {
//        self.layer.borderColor = colors.KOrangeTextColor.CGColor
 //       self.layer.borderWidth = 2.0
   //     self.layer.cornerRadius = self.frame.size.height / 2
        self.setTitle("Accept", for: UIControlState())
        self.setTitle("Accept", for: .highlighted)
        self.setBackgroundImage(UIImage(named: "acceptbtn"), for: UIControlState())
        self.setBackgroundImage(UIImage(named: "acceptbtn-selected"), for: .highlighted)
       // self.titleLabel?.font = UIFont(name: fontsName.KfontNameSTDRoman, size: 13)
        self.backgroundColor = UIColor.clear
        //self.setTitleColor(colors.KOrangeTextColor, forState: .Normal)
        self.setTitleColor(UIColor.white, for: .highlighted)
    }
    
    func configure() {
       // layer.borderColor = borderColor.CGColor
//layer.borderWidth = borderWidth
        //layer.cornerRadius = cornurRadius
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
