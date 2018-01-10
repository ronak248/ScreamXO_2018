//
//  RoundImage.swift
//  ScreamXO
//
//  Created by Ronak Barot on 28/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

@IBDesignable
class RoundImage: UIImageView {
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        self.layoutSubviews()
        
    }
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = self.frame.size.height / 2
        layer.masksToBounds = true

    }
}

