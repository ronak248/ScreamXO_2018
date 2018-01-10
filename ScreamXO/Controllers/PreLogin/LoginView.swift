//
//  LoginView.swift
//  BeersMe
//
//  Created by Jatin Kathrotiya on 31/03/16.
//  Copyright © 2016 Ajay Ghodadra. All rights reserved.
//

import UIKit

class LoginView: UIView {
 
    @IBOutlet var imgviewTop: UIImageView!
    @IBOutlet var btnFaceBook: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    override func awakeFromNib() {
        self.layoutIfNeeded()
    }
    class func initNib()->LoginView{
        var loginView : LoginView!
        let nibArray = Bundle.main.loadNibNamed("LoginView", owner:self, options:nil)
        
        for v in nibArray! {
            if (v as AnyObject).isKind(of: LoginView.self){
                loginView = v as! LoginView
            }
        }
        
        return loginView
    }
}
