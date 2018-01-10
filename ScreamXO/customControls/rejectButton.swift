//
//  rejectButton.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 17/11/15.
//  Copyright © 2015 Twizz Ltd. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
@IBDesignable
class rejectButton: UIButton
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
        self.setTitle("Reject", for: UIControlState())
        self.setTitle("Reject", for: .highlighted)
        self.setBackgroundImage(UIImage(named: "rejectbtn"), for: UIControlState())
        self.setBackgroundImage(UIImage(named: "rejectbtn-selected"), for: .highlighted)
        self.titleLabel?.font = UIFont(name: fontsName.KfontNameSTDRoman, size: 13)
        self.backgroundColor = UIColor.clear
        self.setTitleColor(colors.kPlaceholderTextColor, for: UIControlState())
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
