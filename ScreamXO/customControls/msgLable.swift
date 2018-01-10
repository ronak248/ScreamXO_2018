//
//  msgLable.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 01/12/15.
//  Copyright © 2015 Twizz Ltd. All rights reserved.
//

import Foundation
class msgLable: UILabel {
    
    var topInset:       CGFloat = 3
    var rightInset:     CGFloat = 0
    var bottomInset:    CGFloat = 3
    var leftInset:      CGFloat = 0
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: self.topInset, left: self.leftInset, bottom: self.bottomInset, right: self.rightInset)
        self.setNeedsLayout()
        let newrect = CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height + 12)
        print(newrect)
        return super.drawText(in: UIEdgeInsetsInsetRect(newrect, insets))
    }

}
