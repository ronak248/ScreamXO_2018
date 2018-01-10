//
//  ImageViewerViewController.swift
//  ScreamXO
//
//  Created by Jatin Kathrotiya on 24/06/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class ImageViewerViewController: UIViewController,iCarouselDelegate,iCarouselDataSource {
    
    @IBOutlet weak var carosel: iCarousel!
     var  arrayImages : NSMutableArray!
    var Index : Int = 0
     var isPresented = true
    
    
    var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(ImageViewerViewController.deviceDidRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        // Initial device orientation
        self.currentDeviceOrientation = UIDevice.current.orientation
        // Do what you want here
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        if UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    }
    
    func deviceDidRotate(_ notification: Notification) {
        self.currentDeviceOrientation = UIDevice.current.orientation
        self.carosel.reloadInputViews()
        self.carosel.reloadData()
        

        // Do what you want here
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.carosel.delegate = self
        self.carosel.dataSource = self
        self.carosel.isPagingEnabled = true
        self.carosel.bounces = false
        
        self.carosel.scrollToItem(at: self.Index, animated:false)
        self.carosel.reloadData()
        self.carosel.reloadInputViews()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func numberOfItems (in carousel : iCarousel) -> NSInteger
    {
        
        return self.arrayImages.count
        
    }
 
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        
        let view1 : ImageViewerView?
        
        if view == nil
        {
            view1 = ImageViewerView().initWithNib()
            
            let strimg:String=(self.arrayImages.object(at: index) as AnyObject).value(forKey: "media_url")! as! String
            view1!.imageView.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            view1?.frame = CGRect(x: 0, y: 0, width: self.carosel.frame.size.width,  height: self.carosel.frame.size.height)
            view1?.setNeedsLayout()
            view1?.layoutIfNeeded()

        }
        else
        {
            view1 = view as? ImageViewerView
            
            let strimg:String=(self.arrayImages.object(at: index) as AnyObject).value(forKey: "media_url")! as! String
            view1!.imageView.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
            
            view1?.frame = CGRect(x: 0, y: 0, width: self.carosel.frame.size.width,  height: self.carosel.frame.size.height)
            view1?.setNeedsLayout()
            view1?.layoutIfNeeded()
        }
        
        return view1
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
       
        
        return value
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
   
        
    }
    func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
        return self.carosel.frame.size.width
    }
    @IBAction func doneBtnClicked(){
        isPresented = false
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        UIInterfaceOrientationMask.portraitUpsideDown
        self.dismiss(animated: true, completion: nil)
    }
    
    
  
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
