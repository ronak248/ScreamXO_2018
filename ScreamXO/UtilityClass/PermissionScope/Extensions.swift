//
//  Extensions.swift
//  PermissionScope
//
//  Created by Nick O'Neill on 8/21/15.
//  Copyright © 2015 That Thing in Swift. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    /// Returns the inverse color
    var inverseColor: UIColor{
        var r:CGFloat = 0.0; var g:CGFloat = 0.0; var b:CGFloat = 0.0; var a:CGFloat = 0.0;
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return UIColor(red: 1.0-r, green: 1.0 - g, blue: 1.0 - b, alpha: a)
        }
        return self
    }
}

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}

extension String {
    /// NSLocalizedString shorthand
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension CGRect {
    public mutating func offsetInPlace(dx: CGFloat, dy: CGFloat) {
        self = offsetBy(dx: dx, dy: dy)
    }
}

extension Optional {
    /// True if the Optional is .None. Useful to avoid if-let.
    var isNil: Bool {
        if case .none = self {
            return true
        }
        return false
    }
}

extension UIViewController {
    func showAlert(alertMessage : String) ->  Void {
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style:.default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithAction(alertMessage : String , completionHandler:@escaping (Bool)->()) {
        let alert = UIAlertController(title: "", message: alertMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style:.default) {
            action in
            completionHandler(true)
        }
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIButton {
    
//    @IBInspectable var cornerRadiuss: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            self.layer.cornerRadius = newValue
//            self.layer.masksToBounds = newValue > 0
//        }
//    }
//    
//    @IBInspectable var borderColorr: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            self.layer.borderColor = borderColorr?.cgColor
//        }
//    }
//    
//    @IBInspectable var borderWidthh: Float? {
//        get {
//            return Float(layer.borderWidth)
//        }
//        set {
//            self.layer.borderWidth = CGFloat(borderWidthh!)
//        }
//    }
}
