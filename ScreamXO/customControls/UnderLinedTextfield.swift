//
//  UnderLinedTextfield.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 10/09/15.
//  Copyright (c) 2015 Twizz Ltd All rights reserved.
//

import UIKit

@IBDesignable class UnderLinedTextfield: UITextField {
    
    @IBInspectable var errorEntry: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineColor: UIColor = UIColor ( red: 0.049, green: 0.049, blue: 0.049, alpha: 1.0 ) {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var errorColor: UIColor = UIColor.red {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var imageRect: CGRect = CGRect.zero {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var errorMessage: String?
    
    override func draw(_ rect: CGRect)
    {
        let height = self.bounds.height
        
        if let strPlaceHolder: String = self.placeholder
        {
            self.attributedPlaceholder = NSAttributedString(string:strPlaceHolder,
            attributes:[NSForegroundColorAttributeName:colors.kPlaceholderTextColor])
        }
        self.textColor = colors.KBalckTextColor
        
        self.font = UIFont(name: fontsName.KfontproxiRegular, size: 16)

        // get the current drawing context
        let context = UIGraphicsGetCurrentContext()
        
        // set the line color and width
        if errorEntry {
            context!.setStrokeColor(errorColor.cgColor)
            context!.setLineWidth(0.5)
        } else {
            context!.setStrokeColor(lineColor.cgColor)
            context!.setLineWidth(1)
        }
        
        // start a new Path
        context!.beginPath()
        
        context!.move(to: CGPoint(x: self.bounds.origin.x, y: height - 0.5))
        context!.addLine(to: CGPoint(x: self.bounds.size.width, y: height - 0.5))
        
        // close and stroke (draw) it
        context!.closePath()
        context!.strokePath()
        
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect
    {
        return imageRect
    }
    
}
