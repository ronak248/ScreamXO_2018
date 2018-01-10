//
//  CustomeView.swift
//  WhereIts
//
//  Created by Jatin Kathrotiya on 09/06/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit

@IBDesignable
class BorderView: UIView {
    var ratio : CGFloat = 1
    
   
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
           //
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var shadowColor:UIColor?{
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity:Float = 0{
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset:CGSize = CGSize.zero{
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var masksToBounds:Bool = false{
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    override func layoutSubviews() {
        
        if(ratio == 1){
            ratio = UIScreen.main.bounds.size.width/375.0
        }
        layer.cornerRadius = cornerRadius * ratio
    }
}
@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var shadowColor:UIColor?{
        didSet {
            layer.shadowColor = shadowColor?.cgColor
        }
    }
    
    @IBInspectable var shadowOpacity:Float = 0{
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    @IBInspectable var shadowOffset:CGSize = CGSize.zero{
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    @IBInspectable var masksToBounds:Bool = false{
        didSet {
            layer.masksToBounds = masksToBounds
        }
    }
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.size.height/2.0
    }
}


class PLabel: UILabel{
    var fontSize : CGFloat = -1
    override func draw(_ rect: CGRect){
        let ratio = UIScreen.main.bounds.size.width/375.0
        if(self.fontSize == -1){
            self.fontSize = (self.font.pointSize)
        }
        self.font = UIFont(name:self.font.fontName , size:(self.fontSize * ratio))
        super.draw(rect)
    }
    
}

@IBDesignable
class PButton: UIButton {
    var indexPath:IndexPath!
    var isSelBtn :Bool!
    var fontSize : CGFloat = -1
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var isRounded:Bool = false {
        didSet {
            if isRounded == true{
                layer.cornerRadius = self.frame.size.height / 2.0
            }
            
        }
    }
    
    override func draw(_ rect: CGRect){
        if(self.fontSize == -1){
            self.fontSize = (self.titleLabel?.font.pointSize)!
        }
        let ratio = UIScreen.main.bounds.size.width/375.0
        self.titleLabel?.font = UIFont(name: (self.titleLabel?.font.fontName)! , size:(self.fontSize * ratio))
        super.draw(rect)
    }
    
    
    
    
    @IBInspectable var imageTintColor: UIColor? {
        didSet {
            self.imageView?.contentMode = UIViewContentMode.scaleAspectFit
            let origImage = self.imageView?.image;
            let tintedImage = origImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            self.setImage(tintedImage, for: UIControlState())
            self.tintColor = imageTintColor
        }
    }
    
    @IBInspectable var underLinedText: String? {
        didSet {
            let titleString : NSMutableAttributedString = NSMutableAttributedString(string: underLinedText!)
            titleString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, underLinedText!.characters.count))
            self.setAttributedTitle(titleString, for: UIControlState())
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if(isRounded){
            layer.cornerRadius = self.frame.size.height / 2.0
        }
    }
    
    
    
    
}

class CheckButton: PButton {
    var isCheck:Bool = false {
        didSet{
            if (isCheck == true){
                self.setImage(UIImage(named: "on"), for: UIControlState())
                self.borderColor = UIColor.clear
                self.borderWidth = 0.0
                self.clipsToBounds = true
            }else{
                self.setImage(UIImage(named: ""), for: UIControlState())
                self.isRounded = true
//                self.borderColor = grayLineColor
                self.borderWidth = 1.0
                self.clipsToBounds = true
                
            }
        }
    }
    
}
