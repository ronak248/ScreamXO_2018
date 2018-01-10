//
//  CustomCamera.swift
//  ScreamXO
//
//  Created by Jasmin Patel on 17/11/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
class CustomCamera: UIViewController {

    @IBOutlet var btnDone: UIButton!
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var imgPreview: UIImageView!
    var videoUrl: URL? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        btnPlay.isHidden = true
        let fusuma = FusumaViewController()
        
        //        fusumaCropImage = false
        
        fusuma.delegate = self
        self.present(fusuma, animated: true, completion: nil)
    }
    func thumbnail(_ sourceURL:URL) -> Void {
        
        let asset = AVURLAsset(url: sourceURL, options: nil)
        let generator = AVAssetImageGenerator(asset: asset)
        
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(0.1, 1)
        
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
            (requestedTime: CMTime, thumbnail: CGImage?, actualTime: CMTime, result: AVAssetImageGeneratorResult, error: Error?) in
            DispatchQueue.main.async(execute: { () -> Void in
                self.imgPreview.image = UIImage(cgImage: thumbnail!)
            })
        }
    }
    @IBAction func btnPlayPressed(_ sender: AnyObject) {
        if let url = videoUrl {
            let player = AVPlayer(url: url)
            let controller=AVPlayerViewController()
            controller.player=player
            self.present(controller, animated: true, completion: nil)
            player.play()
        }
    }
    @IBAction func btnDonePressed(_ sender: AnyObject) {
        
    }
    @IBAction func btnClosePressed(_ sender: AnyObject) {
        
    }
}
extension CustomCamera: FusumaDelegate {
    func fusumaClosed() {
        
        print("Called when the close button is pressed")
    }
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
        
        let alert = UIAlertController(title: "Access Requested", message: "Saving image needs to access your photo album", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        UIApplication.shared.keyWindow?.rootViewController!.present(alert, animated: true, completion: nil)
    }
    func fusumaImageSelected(_ image: UIImage) {
        videoUrl = nil
        print("Image selected")
        imgPreview.image = image
    }
    func fusumaVideoCompletedwithData(withFileURL dataass: Data, fileURLL: URL) {
        
        
        btnPlay.isHidden = false
        thumbnail(fileURLL)
        videoUrl = fileURLL
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        btnPlay.isHidden = false
        thumbnail(fileURL)
        videoUrl = fileURL
    }
    
    func fusumaDismissedWithImage(_ image: UIImage) {
        
        print("Called just after dismissed FusumaViewController")
    }
}
