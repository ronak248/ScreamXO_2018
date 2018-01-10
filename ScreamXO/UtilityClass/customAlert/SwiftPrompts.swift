//
//  SwiftPrompts.swift
//  ProjectName
//
//  Created by Gabriel Alvarado on 3/22/15.
//  Copyright (c) 2015 CompanyName. All rights reserved.
//
//  Generated by PaintCode (www.paintcodeapp.com)
//



import UIKit

open class SwiftPrompts : NSObject {

    //// Drawing Methods

    open class func drawSwiftPrompt(frame: CGRect, backgroundColor: UIColor, headerBarColor: UIColor, bottomBarColor: UIColor, headerTxtColor: UIColor, contentTxtColor: UIColor, outlineColor: UIColor, topLineColor: UIColor, bottomLineColor: UIColor, dismissIconButton: UIColor, promptText: String, textSize: CGFloat, topBarVisibility: Bool, bottomBarVisibility: Bool, headerText: String, headerSize: CGFloat, topLineVisibility: Bool, bottomLineVisibility: Bool, outlineVisibility: Bool, dismissIconVisibility: Bool) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Rectangle Drawing
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x: frame.minX + floor(frame.width * 0.01778 + 0.5), y: frame.minY + 9, width: floor(frame.width * 0.98667 + 0.5) - floor(frame.width * 0.01778 + 0.5), height: frame.height - 19), cornerRadius: 12)
        backgroundColor.setFill()
        rectanglePath.fill()


        if (outlineVisibility) {
            //// Rectangle 6 Drawing
            let rectangle6Path = UIBezierPath(roundedRect: CGRect(x: frame.minX + floor(frame.width * 0.01778 + 0.5), y: frame.minY + 9, width: floor(frame.width * 0.98667 + 0.5) - floor(frame.width * 0.01778 + 0.5), height: frame.height - 19), cornerRadius: 12)
            outlineColor.setStroke()
            rectangle6Path.lineWidth = 3.5
            rectangle6Path.stroke()
        }


        if (bottomBarVisibility) {
            //// Rectangle 2 Drawing
            let rectangle2Path = UIBezierPath(roundedRect: CGRect(x: frame.minX + floor(frame.width * 0.01778 + 0.5), y: frame.minY + frame.height - 51, width: floor(frame.width * 0.98667 + 0.5) - floor(frame.width * 0.01778 + 0.5), height: 41), byRoundingCorners: [UIRectCorner.bottomLeft, UIRectCorner.bottomRight], cornerRadii: CGSize(width: 12, height: 12))
            rectangle2Path.close()
            bottomBarColor.setFill()
            rectangle2Path.fill()
        }


        //// Text Drawing
        let textRect = CGRect(x: frame.minX + 13, y: frame.minY + 56, width: frame.width - 26, height: frame.height - 109)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        textStyle.alignment = NSTextAlignment.center

        let textFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: textSize)!, NSForegroundColorAttributeName: contentTxtColor, NSParagraphStyleAttributeName: textStyle]

        let textTextHeight: CGFloat = NSString(string: promptText).boundingRect(with: CGSize(width: textRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: textFontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: textRect);
        NSString(string: promptText).draw(in: CGRect(x: textRect.minX, y: textRect.minY + (textRect.height - textTextHeight) / 2, width: textRect.width, height: textTextHeight), withAttributes: textFontAttributes)
        context!.restoreGState()


        if (topBarVisibility) {
            //// Rectangle 3 Drawing
            let rectangle3Path = UIBezierPath(roundedRect: CGRect(x: frame.minX + floor(frame.width * 0.01778 + 0.5), y: frame.minY + 9, width: floor(frame.width * 0.98667 + 0.5) - floor(frame.width * 0.01778 + 0.5), height: 44), byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: 12, height: 12))
            rectangle3Path.close()
            headerBarColor.setFill()
            rectangle3Path.fill()
        }


        //// Text 2 Drawing
        let text2Rect = CGRect(x: frame.minX + floor(frame.width * 0.05333 + 0.5), y: frame.minY + 17, width: floor(frame.width * 0.93778 + 0.5) - floor(frame.width * 0.05333 + 0.5), height: 34)
        let text2Style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        text2Style.alignment = NSTextAlignment.center

        let text2FontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: headerSize)!, NSForegroundColorAttributeName: headerTxtColor, NSParagraphStyleAttributeName: text2Style]

        let text2TextHeight: CGFloat = NSString(string: headerText).boundingRect(with: CGSize(width: text2Rect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: text2FontAttributes, context: nil).size.height
        context!.saveGState()
        context!.clip(to: text2Rect);
        NSString(string: headerText).draw(in: CGRect(x: text2Rect.minX, y: text2Rect.minY + (text2Rect.height - text2TextHeight) / 2, width: text2Rect.width, height: text2TextHeight), withAttributes: text2FontAttributes)
        context!.restoreGState()


        if (topLineVisibility) {
            //// Rectangle 4 Drawing
            let rectangle4Path = UIBezierPath(rect: CGRect(x: frame.minX + 12, y: frame.minY + 53, width: frame.width - 23, height: 1))
            topLineColor.setFill()
            rectangle4Path.fill()
        }


        if (bottomLineVisibility) {
            //// Rectangle 5 Drawing
            let rectangle5Path = UIBezierPath(rect: CGRect(x: frame.minX + 12, y: frame.minY + frame.height - 52, width: frame.width - 23, height: 1))
            bottomLineColor.setFill()
            rectangle5Path.fill()
        }


        //// Page-
        //// First
        //// Group 4
        if (dismissIconVisibility) {
            //// Shape 2 Drawing
            let shape2Path = UIBezierPath()
            shape2Path.move(to: CGPoint(x: frame.minX + 29.83, y: frame.minY + 27.57))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 28.13, y: frame.minY + 25.88))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 21.33, y: frame.minY + 32.68))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 14.53, y: frame.minY + 25.88))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 12.83, y: frame.minY + 27.57))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 19.63, y: frame.minY + 34.38))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 12.83, y: frame.minY + 41.18))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 14.53, y: frame.minY + 42.88))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 21.33, y: frame.minY + 36.07))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 28.13, y: frame.minY + 42.88))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 29.83, y: frame.minY + 41.18))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 23.03, y: frame.minY + 34.38))
            shape2Path.addLine(to: CGPoint(x: frame.minX + 29.83, y: frame.minY + 27.57))
            shape2Path.close()
            shape2Path.miterLimit = 4;

            shape2Path.usesEvenOddFillRule = true;

            dismissIconButton.setFill()
            shape2Path.fill()
        }
    }

}

@objc protocol StyleKitSettableImage {
    func setImage(_ image: UIImage!)
}

@objc protocol StyleKitSettableSelectedImage {
    func setSelectedImage(_ image: UIImage!)
}
