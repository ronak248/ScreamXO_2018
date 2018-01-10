//
//  sideMenuNavigationVC.swift
//  Twizz
//
//  Created by Tejas Ardeshna on 30/09/15.
//  Copyright © 2015 Twizz Ltd. All rights reserved.
//

import Foundation
class sideMenuNavigationVC: UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sideMenuNavigationVC.panGestureRecognized(_:)))
        self.view.addGestureRecognizer(panGesture)
        self.frostedViewController.menuViewSize = CGSize(width: 230, height: UIScreen.main.bounds.height)
        self.frostedViewController.limitMenuViewSize = true
    }
    func panGestureRecognized (_ sender : UIPanGestureRecognizer)
    {
        self.view.endEditing(true)
        self.frostedViewController.view.endEditing(true)
        self.frostedViewController.panGestureRecognized(sender)
    }
}
