//
//  ContainerViewController.swift
//  SnapchatSwipeView
//
//  Created by Jake Spracher on 8/9/15.
//  Copyright (c) 2015 Jake Spracher. All rights reserved.
//

import UIKit

protocol SnapContainerViewControllerDelegate {
    func outerScrollViewShouldScroll() -> Bool
}

class SnapContainerViewController: UIViewController, UIScrollViewDelegate {
    
    var topVc: UIViewController?
    var leftVc: UIViewController!
    var middleVc: UIViewController!
    var rightVc: UIViewController!
    var bottomVc: UIViewController?
    
    var directionLockDisabled: Bool!
    
    var horizontalViews = [UIViewController]()
    var veritcalViews = [UIViewController]()
    
    var initialContentOffset = CGPoint() // scrollView initial offset
    var middleVertScrollVc: VerticalScrollViewController!
    var scrollView: UIScrollView!
    var delegate: SnapContainerViewControllerDelegate?
    
    class func containerViewWith(_ leftVC: UIViewController,
                                 middleVC: UIViewController,
                                 rightVC: UIViewController,
                                 topVC: UIViewController?=nil,
                                 bottomVC: UIViewController?=nil,
                                 directionLockDisabled: Bool?=false) -> SnapContainerViewController {
        let container = SnapContainerViewController()
        
        container.directionLockDisabled = directionLockDisabled
        
        container.topVc = topVC
        container.leftVc = leftVC
        container.middleVc = middleVC
        container.rightVc = rightVC
        container.bottomVc = bottomVC
        return container
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        setupVerticalScrollView()
        setupHorizontalScrollView()
        NotificationCenter.default.addObserver(self, selector: #selector(openMiddlePage), name: NSNotification.Name(rawValue: "goToPageMiddle"), object: nil)
    }
    func openMiddlePage() {
        var frame = scrollView.frame
        frame.origin.x = frame.size.width
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: true)
    }
    func setupVerticalScrollView() {
        middleVertScrollVc = VerticalScrollViewController.verticalScrollVcWith(middleVc,
                                                                               topVc: topVc,
                                                                               bottomVc: bottomVc)
        delegate = middleVertScrollVc
    }
    
    func setupHorizontalScrollView() {
        scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
        
        let view = (
            x: self.view.bounds.origin.x,
            y: self.view.bounds.origin.y,
            width: self.view.bounds.width,
            height: self.view.bounds.height
        )

        scrollView.frame = CGRect(x: view.x,
                                  y: view.y,
                                  width: view.width,
                                  height: view.height
        )
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(scrollView)
        
        let scrollWidth  = 3 * view.width
        let scrollHeight  = view.height
        scrollView.contentSize = CGSize(width: scrollWidth, height: scrollHeight)
        
        leftVc.view.frame = CGRect(x: 0,
                                   y: 0,
                                   width: view.width,
                                   height: view.height
        )
        
        middleVertScrollVc.view.frame = CGRect(x: view.width,
                                               y: 0,
                                               width: view.width,
                                               height: view.height
        )
        
        rightVc.view.frame = CGRect(x: 2 * view.width,
                                    y: 0,
                                    width: view.width,
                                    height: view.height
        )
        
        addChildViewController(leftVc)
        addChildViewController(middleVertScrollVc)
        addChildViewController(rightVc)
        scrollView.addSubview(leftVc.view)
        scrollView.addSubview(middleVertScrollVc.view)
        scrollView.addSubview(rightVc.view)
        leftVc.didMove(toParentViewController: self)
        middleVertScrollVc.didMove(toParentViewController: self)
        rightVc.didMove(toParentViewController: self)
        scrollView.contentOffset.x = middleVertScrollVc.view.frame.origin.x
        scrollView.delegate = self
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.initialContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if SVProgressHUD.isVisible() {
            return
        }
        let width = scrollView.frame.size.width
        let page = (scrollView.contentOffset.x + (0.5 * width)) / width
        
        if page == 0.5 {
            print("left")

            for controller in ((middleVc.childViewControllers[1] as? UINavigationController)?.viewControllers)! {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "hideKeyBoardNew"), object: nil)
                controller.view.endEditing(true)
            }

            if let camVC = rightVc as? CameraVC {
                camVC.dismissCamera()
            }
        }
        
        if page == 1.5 {
            print("middle")
            
            scrollView.keyboardDismissMode = .interactive
            
            for controller in ((middleVc.childViewControllers[1] as? UINavigationController)?.viewControllers)! {
                if controller is CreatePostVC {
                    
                        controller.view.endEditing(true)
                        (controller as? CreatePostVC)?.txtPost.becomeFirstResponder()
                    
                } else if controller is HomeScreen {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                       controller.view.endEditing(true)
                         NotificationCenter.default.post(name: Notification.Name(rawValue: "hideKeyBoardNew"), object: nil)
                        
                        
                    }
                    
                    
                }
            }
            
            if let cameraVC = rightVc as? CameraVC {
                cameraVC.dismissCamera()
            }


        }
        
        if page == 2.5 {
            print("right")
            
            for controller in ((middleVc.childViewControllers[1] as? UINavigationController)?.viewControllers)! {
                controller.view.endEditing(true)
            }
            
            if let cameraVC = rightVc as? CameraVC {
                cameraVC.openCamera()
                cameraVC.view.endEditing(true)
            }
        }
        
        if delegate != nil && !delegate!.outerScrollViewShouldScroll() && !directionLockDisabled {
            let newOffset = CGPoint(x: self.initialContentOffset.x, y: self.initialContentOffset.y)
        
            // Setting the new offset to the scrollView makes it behave like a proper
            // directional lock, that allows you to scroll in only one direction at any given time
            
            self.scrollView!.setContentOffset(newOffset, animated:  false)
        }
    }
    
}


