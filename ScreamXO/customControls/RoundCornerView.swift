//
//  RoundCornerView.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 25/09/15.
//  Copyright (c) 2015 Tejas Ardeshna. All rights reserved.
//

import Foundation
@IBDesignable
class RoundCornerView : UIView
{
    override func draw(_ rect: CGRect) {

        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = colors.KbtnLightborderTextColor.cgColor
        self.layer.masksToBounds = true
    
    }
}

@IBDesignable
class RoundView : UIView
{
    override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = self.frame.size.height/2
        self.layer.borderWidth = 1.0
        self.layer.borderColor = colors.KbtnLightborderTextColor.cgColor
        self.layer.masksToBounds = true
        
    }
}
@IBDesignable
class BottomRoundCornerView: UIView {
    
    let rectShape = CAShapeLayer()
    
    override func draw(_ rect: CGRect) {
        
        
        rectShape.bounds = self.frame
        rectShape.position = self.center
        
        rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 10, height: 10)).cgPath
        
        self.layer.mask = rectShape
    }
}


@IBDesignable
class ViewRoundCorner : UIView {
    
    override func draw(_ rect: CGRect) {
        
        self.layer.cornerRadius = 14.0
        self.layer.masksToBounds = true
    }
}
