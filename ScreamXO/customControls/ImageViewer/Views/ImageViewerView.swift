//
//  ImageViewerView.swift
//  ScreamXO
//
//  Created by Jatin Kathrotiya on 24/06/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AVFoundation

class ImageViewerView: UIView ,UIScrollViewDelegate{

    
    @IBOutlet var scrollView : MyScrollView!
    @IBOutlet var imageView : UIImageView!
    var image: UIImage!
    var iview : ImageViewerView?
    var imgUrl : String!
    @IBOutlet var imgH : NSLayoutConstraint!
    @IBOutlet var imgW : NSLayoutConstraint!
    @IBOutlet var imgCY : NSLayoutConstraint!
    func initWithNib()->ImageViewerView {
        let array = Bundle.main.loadNibNamed("ImageViewerView", owner:nil, options: nil)
        for  v in array!{
            if (v as AnyObject).isKind(of: ImageViewerView.self) {
                iview = v as? ImageViewerView
            }
        }
//        if !(self.superview == nil){
//        iview?.frame = CGRectMake(0, 0,(self.superview?.frame.size.width)!,(self.superview?.frame.size.height)!)
//        }
        iview!.setLayOuts()
        iview!.setNeedsUpdateConstraints()
        iview!.updateConstraintsIfNeeded()
        return iview!
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if imageView.image != nil {

          var rect = AVMakeRect(aspectRatio: self.imageView.image!.size, insideRect: self.bounds);
            rect = self.convert(rect, to: self.scrollView)
            imgH.constant = rect.size.height
            imgW.constant = rect.size.width
            self.setNeedsUpdateConstraints()
            self.updateConstraintsIfNeeded()

         
        }
    }
    
    func setLayOuts()  {
        
        self.scrollView.minimumZoomScale = 1.0
         self.scrollView.maximumZoomScale = 3.0
        let tap = UITapGestureRecognizer(target: self ,action:#selector(self.handleSingleTap(_:)))
        tap.numberOfTapsRequired = 2
        self.scrollView.addGestureRecognizer(tap)
        
        
    }
    
    func handleSingleTap(_ sender:AnyClass)  {
        if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale){
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        }
        else{
             self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
           
        }
        
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
       return self.imageView;
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.scrollView.zoomScale == self.scrollView.minimumZoomScale {
           self.scrollView.setZoomScale(1.0, animated: true)
        }
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView){
      
//        let x = (((self.scrollView.frame.size.height) * self.scrollView.zoomScale) - (self.scrollView.frame.size.height))
//         print(x)
//        imgCY.constant =  -CGFloat(x) / 4.0
//        self.imageView.layoutIfNeeded()
//        self.imageView.setNeedsUpdateConstraints()
//        self.imageView.updateConstraintsIfNeeded()
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}

class MyScrollView: UIScrollView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let v = self.delegate?.viewForZooming!(in: self)
         let svw = self.bounds.size.width;
         let svh = self.bounds.size.height;
        let vw = v!.frame.size.width;
        let vh = v!.frame.size.height;
        var f = v!.frame;
        if (vw < svw){
           f.origin.x = (svw - vw) / 2.0;
        }else{
            f.origin.x = 0;
        }
        if (vh < svh){
             f.origin.y = (svh - vh) / 2.0;
        }
        else{
             f.origin.y = 0;
        }
       
        v!.frame = f;
        
    }
}


