//
//  MiddleScrollViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 12/14/15.
//  Copyright © 2015 Jake Spracher. All rights reserved.
//

import UIKit

class VerticalScrollViewController: UIViewController, SnapContainerViewControllerDelegate {
    var topVc: UIViewController!
    var middleVc: UIViewController!
    var bottomVc: UIViewController!
    var scrollView: UIScrollView!
    
    class func verticalScrollVcWith(_ middleVc: UIViewController,
                                    topVc: UIViewController?=nil,
                                    bottomVc: UIViewController?=nil) -> VerticalScrollViewController {
        let middleScrollVc = VerticalScrollViewController()
        
        middleScrollVc.topVc = topVc
        middleScrollVc.middleVc = middleVc
        middleScrollVc.bottomVc = bottomVc
        
        return middleScrollVc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view:
        setupScrollView()
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )
        
        scrollView.frame = CGRect(x: view.x, y: view.y, width: view.width, height: view.height)
        self.view.addSubview(scrollView)
        
        
        if topVc != nil && bottomVc != nil {
            topVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            middleVc.view.frame = CGRect(x: 0, y: view.height, width: view.width, height: view.height)
            bottomVc.view.frame = CGRect(x: 0, y: 2 * view.height, width: view.width, height: view.height)
            
            addChildViewController(topVc)
            addChildViewController(middleVc)
            addChildViewController(bottomVc)
            
            scrollView.addSubview(topVc.view)
            scrollView.addSubview(middleVc.view)
            scrollView.addSubview(bottomVc.view)
            
            topVc.didMove(toParentViewController: self)
            middleVc.didMove(toParentViewController: self)
            bottomVc.didMove(toParentViewController: self)
            
            scrollView.contentOffset.y = middleVc.view.frame.origin.y
            
        } else if topVc == nil {
            middleVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            //bottomVc.view.frame = CGRect(x: 0, y: view.height, width: view.width, height: view.height)
            
            addChildViewController(middleVc)
           // addChildViewController(bottomVc)
            
            scrollView.addSubview(middleVc.view)
           // scrollView.addSubview(bottomVc.view)
            
            middleVc.didMove(toParentViewController: self)
            //bottomVc.didMoveToParentViewController(self)
            
            scrollView.contentOffset.y = 0

        } else if bottomVc == nil {
            topVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            middleVc.view.frame = CGRect(x: 0, y: view.height, width: view.width, height: view.height)
            
            addChildViewController(topVc)
            addChildViewController(middleVc)
            
            scrollView.addSubview(topVc.view)
            scrollView.addSubview(middleVc.view)
            
            topVc.didMove(toParentViewController: self)
            middleVc.didMove(toParentViewController: self)
            
            scrollView.contentOffset.y = middleVc.view.frame.origin.y

        } else {
            middleVc.view.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
            addChildViewController(middleVc)
            scrollView.addSubview(middleVc.view)
            middleVc.didMove(toParentViewController: self)
        }
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }

    // MARK: - SnapContainerViewControllerDelegate Methods
    
    func outerScrollViewShouldScroll() -> Bool {
        if scrollView.contentOffset.y < middleVc.view.frame.origin.y || scrollView.contentOffset.y > 2*middleVc.view.frame.origin.y {
            return false
        } else {
            return true
        }
    }
    
}
