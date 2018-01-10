//
//  FinalCameraViewController.swift
//  CameraApp
//
//  Created by Chirag Lakhani on 11/11/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import MediaPlayer
import AVKit
class FinalCameraViewController: UIViewController {
    @IBOutlet var imgCapturePreview : UIImageView?
    @IBOutlet var btnPlay : UIButton?
    var previewImage : UIImage!
    var currentMode : CaptureMode!
    var captureVideoUrl : URL!
    var player: MPMoviePlayerController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentMode == CaptureMode.photo
        {
            btnPlay?.isHidden = true
            imgCapturePreview!.image = previewImage
        }
        else{
             btnPlay?.isHidden = false
            self.thumbnail(captureVideoUrl as URL)
        }
        // Do any additional setup after loading the view.
    }
    func thumbnail(_ sourceURL:URL) -> Void
    {
            let asset = AVURLAsset(url: sourceURL, options: nil)
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            let generator = AVAssetImageGenerator(asset: asset)
            
            generator.appliesPreferredTrackTransform = true
            
            let time = CMTimeMakeWithSeconds(0.1, 1)
            
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) {
                (requestedTime: CMTime, thumbnail: CGImage?, actualTime: CMTime, result: AVAssetImageGeneratorResult, error: Error?) in
                     DispatchQueue.main.async(execute: { () -> Void in
                        self.imgCapturePreview!.image = UIImage(cgImage: thumbnail!)
                    })
            }
    }
    @IBAction func cancelTapped(_ withSender:AnyObject)
    {
        
        self.dismiss(animated: true, completion:nil)
    }
    @IBAction func sendTapped(_ withSender:AnyObject)
    {
        self.dismiss(animated: true, completion:nil)
    }
    @IBAction func playTapped(_ withSender:AnyObject){
        
            let player = AVPlayer(url: captureVideoUrl)
            let controller=AVPlayerViewController()
            controller.player=player
            self.present(controller, animated: true, completion: nil)
            player.play()
    }
    func removeOldFileIfExist() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        if paths.count > 0 {
            let filePath = NSString(format:"output.mov") as String
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                    print("old image has been removed")
                } catch {
                    print("an error during a removing")
                }
            }
        }
    }
}
