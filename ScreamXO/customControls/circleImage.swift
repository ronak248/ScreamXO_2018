//
//  roundImage.swift
//  PharmacyApp
//
//  Created by Tejas Ardeshna on 09/12/15.
//  Copyright © 2015 Tejas Ardeshna. All rights reserved.
//

import Foundation
class circleImage:UIImageView {
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.applyCornerRadius()
        
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setNeedsDisplay()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        self.applyCornerRadius()
    }
    func applyCornerRadius()
    {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = true
    }
    
}
