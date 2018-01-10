//
//  FSCameraView.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

public enum CameraSelection {
    case rear
    case front
    
}

@objc protocol FSCameraViewDelegate: class {
    func cameraShotFinished(_ image: UIImage)
    func albumViewCameraRollUnauthorized()
    @objc optional func cameraUnauthorized()
    @objc optional func microphoneUnauthorized()
    func videoFinished(withFileURL fileURL: URL)
    func videoFinishedFinal(withFileURL dataasset: Data, fileUrl:URL)

}

final class FSCameraView: UIView,UICollectionViewDataSource, UICollectionViewDelegate,PHPhotoLibraryChangeObserver {
    struct GestureConstants {
        static let maximumHeight: CGFloat = 200
        static let minimumHeight: CGFloat = 80
        static let velocity: CGFloat = 100
    }
    @IBOutlet weak var viewTimer: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var previewViewContainer: UIView!
    @IBOutlet weak var shotButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    var flashView: UIView?
    @IBOutlet weak var croppedAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var fullAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: FSCameraViewDelegate? = nil
    weak var maindelegate: FusumaDelegate? = nil
    fileprivate var isRecording = false
    var videoOutput: AVCaptureMovieFileOutput?
    var videoStartImage: UIImage?
    var session: AVCaptureSession?
    var device: AVCaptureDevice?
    var videoInput: AVCaptureDeviceInput?
    var imageOutput: AVCaptureStillImageOutput?
    var focusView: UIView?
    var images: PHFetchResult<PHAsset>!
    var flashOffImage: UIImage?
    var flashOnImage: UIImage?
    var flashAutoImage: UIImage?
    var timeMin = 0
    var timeSec = 0
    var timer = Timer()
    var imageManager: PHCachingImageManager?
    var previousPreheatRect: CGRect = CGRect.zero
    let cellSize = CGSize(width: 100, height: 100)
    let imageSize = CGSize(width: 500, height: 500)
    var phAsset: PHAsset!
    var beginZoomScale: CGFloat = 1.0
    var zoomScale: CGFloat = 1.0
    var scaleOfZoom = 1
    var longPressVideo = UILongPressGestureRecognizer()
    var currentCamera = CameraSelection.rear
    @IBOutlet var collectionHeight: NSLayoutConstraint!
    @IBOutlet var viewPanGallery: UIView!
    
    @IBOutlet weak var btnSlideGallery: UIButton!
    var initialFrame: CGRect?
    var initialContentOffset: CGPoint?
    var numberOfCells: Int?
    var imageLimit = 0
    var initialPoint = CGPoint()
    var pointLong = CGPoint()
    
    var isCameraTorchOn = false
    var isCameraTorchOff = false
    var isCameraTorchAuto = false
    var flashEnabledOn = false
    var flashEnabledOFF = false
    var flashEnabledAuto = true
    var lowLightBoost = true
    var videoDeviceInput : AVCaptureDeviceInput!
    let sessionQueue = DispatchQueue(label: "session queue", attributes: DispatchQueue.Attributes.concurrent)
    enum VideoQuality {
        
        /// AVCaptureSessionPresetHigh
        case high
        
        /// AVCaptureSessionPresetMedium
        case medium
        
        /// AVCaptureSessionPresetLow
        case low
        
        /// AVCaptureSessionPreset352x288
        case resolution352x288
        
        /// AVCaptureSessionPreset640x480
        case resolution640x480
        
        /// AVCaptureSessionPreset1280x720
        case resolution1280x720
        
        /// AVCaptureSessionPreset1920x1080
        case resolution1920x1080
        
        /// AVCaptureSessionPreset3840x2160
        case resolution3840x2160
        
        /// AVCaptureSessionPresetiFrame960x540
        case iframe960x540
        
        /// AVCaptureSessionPresetiFrame1280x720
        case iframe1280x720
    }
    var videoQuality : VideoQuality = .high
    enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    var setupResult = SessionSetupResult.success
    
    
    
    static func instance() -> FSCameraView {
        return UINib(nibName: "FSCameraView", bundle: Bundle(for: self.classForCoder())).instantiate(withOwner: self, options: nil)[0] as! FSCameraView
    }
    
    func changeImage(_ asset: PHAsset) {
        
        
        self.phAsset = asset
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
            
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            
            self.imageManager?.requestImage(for: asset,
                targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                contentMode: .aspectFill,
            options: options) {
                result, info in
                
                DispatchQueue.main.async(execute: {
            
                    
                    
                })
            }
        })
    }
    func checkPhotoAuth() {
        
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch status {
            case .authorized:
                self.imageManager = PHCachingImageManager()
                if self.images != nil && self.images.count > 0 {
                    
                    self.changeImage(self.images[0])
                }
            case .restricted, .denied:
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.delegate?.albumViewCameraRollUnauthorized()
                    
                })
            default:
                break
            }
        }
    }
    func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
        {
            // Already Authorized
       
        }
        else
        {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if granted == true
                {
                    // User granted
                }
                else
                {
                    self.delegate?.albumViewCameraRollUnauthorized()
                }
            });
        }
    }
    func checkMicrophonePermission() {
        let microPhoneStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        
        switch microPhoneStatus {
        case .restricted, .denied:
            self.delegate?.albumViewCameraRollUnauthorized()
        // Microphone disabled in settings
        default:
            break
        }
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FSAlbumViewCell", for: indexPath) as! FSAlbumViewCell
        
        let currentTag = cell.tag + 1
        cell.tag = currentTag
        
        let asset = self.images[indexPath.item] 
        print(asset.mediaType)
        self.imageManager?.requestImage(for: asset,
                                                targetSize: cellSize,
                                                contentMode: .aspectFill,
                                                options: nil) {
                                                    result, info in
                                                    if cell.tag == currentTag {
                                                        if asset.mediaType == .video {
                                                            cell.imgPlay.isHidden = false
                                                        } else {
                                                            cell.imgPlay.isHidden = true
                                                        }
                                                        cell.image = result
                                                    }
                                                    
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return images == nil ? 0 : images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let width = (collectionView.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        changeImage(images[indexPath.row] )
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.layoutIfNeeded()
            
            }, completion: nil)
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        let asset = images[indexPath.row] 
        self.phAsset = asset
        if asset.mediaType == .video {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                options.version = .original
                let videoManager = PHImageManager.default()
                videoManager.requestPlayerItem(forVideo: asset, options: options, resultHandler: {
                    item,response in
                    print((item?.asset as! AVURLAsset).url)
                    DispatchQueue.main.async(execute: {
                        
                        PHCachingImageManager().requestAVAsset(forVideo: asset, options: nil, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable: Any]?) in
                            DispatchQueue.main.async(execute: {
                                
                                let asset = asset as? AVURLAsset
                                let data: Data!
                                do {
                                    data = try NSData(contentsOf: asset!.url, options: .mappedIfSafe) as Data!
                                } catch {
                                    print(error)
                                    return
                                }
                                
                                //let data = try? Data(contentsOf: asset!.url)
                                self.delegate?.videoFinishedFinal(withFileURL: data!, fileUrl: ((item?.asset as! AVURLAsset).url))

                                
                            })
                        })
                        
                    })
                })
            })
        } else {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                
                let options = PHImageRequestOptions()
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true
                options.isSynchronous = true
                self.imageManager?.requestImage(for: asset,
                    targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                    contentMode: .aspectFill,
                options: options) {
                    result, info in
                    
                    DispatchQueue.main.async(execute: {
                        
                        if let res = result {
                            if let dele = self.delegate {
                                dele.cameraShotFinished(res)
                            }
                        }
                        
                    })
                }
            })
        }
        
    }
    
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let imgs = self.images else { return }
        
        DispatchQueue.main.async {
            
            let collectionChanges = changeInstance.changeDetails(for: imgs)
            if collectionChanges != nil {
                
                self.images = collectionChanges!.fetchResultAfterChanges
                
                let collectionView = self.collectionView!
                
                if !collectionChanges!.hasIncrementalChanges || collectionChanges!.hasMoves {
                    
                    collectionView.reloadData()
                    
                } else {
                    
                    collectionView.performBatchUpdates({
                        let removedIndexes = collectionChanges!.removedIndexes
                        if (removedIndexes?.count ?? 0) != 0 {
                            collectionView.deleteItems(at: removedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let insertedIndexes = collectionChanges!.insertedIndexes
                        if (insertedIndexes?.count ?? 0) != 0 {
                            collectionView.insertItems(at: insertedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        let changedIndexes = collectionChanges!.changedIndexes
                        if (changedIndexes?.count ?? 0) != 0 {
                            collectionView.reloadItems(at: changedIndexes!.aapl_indexPathsFromIndexesWithSection(0))
                        }
                        }, completion: nil)
                }
                
                self.resetCachedAssets()
            }
        }
    }
    func resetCachedAssets() {
        
        imageManager?.stopCachingImagesForAllAssets()
        previousPreheatRect = CGRect.zero
    }
    fileprivate func toggleRecording() {
        guard let videoOutput = videoOutput else {
            return
        }
        if !(videoOutput.connection(withMediaType: AVMediaTypeVideo).isActive) {
            self.session?.sessionPreset = AVCaptureSessionPresetHigh
            
        }
        self.isRecording = !self.isRecording
        
        let shotImage: UIImage?
        if self.isRecording {
            shotImage = videoStartImage
        } else {
            shotImage = videoStartImage
        }
        self.shotButton.setImage(shotImage, for: UIControlState())
        
        if self.isRecording {
            let outputPath = "\(NSTemporaryDirectory())output.mov"
            let outputURL = URL(fileURLWithPath: outputPath)
            
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: outputPath) {
                do {
                    try fileManager.removeItem(atPath: outputPath)
                } catch {
                    print("error removing item at path: \(outputPath)")
                    self.isRecording = false
                    return
                }
            }
            self.galleryButton.isEnabled = false
            self.flipButton.isEnabled = false
            self.flashButton.isEnabled = false
            self.timeMin = 0
            self.timeSec = 0
            
            let timeNow = String(format: "%02d:%02d", self.timeMin, self.timeSec)
            self.lblTime.text = timeNow
            viewTimer.isHidden = false
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timeTrick(_:)), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer, forMode: RunLoopMode.defaultRunLoopMode)
            if videoOutput.connection(withMediaType: AVMediaTypeVideo).isActive {
                videoOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
                if flashButton.imageView?.image == flashOnImage && currentCamera == .front {
                    flashView = UIView(frame: self.frame)
                    flashView?.backgroundColor = UIColor.white
                    flashView?.alpha = 0.0
                    previewViewContainer.addSubview(flashView!)
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                        self.flashView?.alpha = 0.85
                        }, completion: nil)
                }
               
            }
        } else {
            self.timer.invalidate()
            
            videoOutput.stopRecording()
            if flashButton.imageView?.image == flashOnImage && currentCamera == .front {
                UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.flashView?.alpha = 0.0
                    }, completion: { (_) in
                    self.flashView?.removeFromSuperview()
                })
            }
            self.session     = nil
            self.device      = nil
            self.imageOutput = nil
            self.images = nil
            viewTimer.isHidden = true
            self.lblTime.text = "00:00"
            self.galleryButton.isEnabled = true
            self.flipButton.isEnabled = true
            self.flashButton.isEnabled = true
        }
        return
    }
    func timeTrick(_ time: Timer) {
        print(time)
        self.timeSec += 1
        if self.timeSec == 60
        {
            self.timeSec = 0
            self.timeMin += 1
        }
        
        let timeNow = String(format: "%02d:%02d", self.timeMin, self.timeSec)
        self.lblTime.text = timeNow
    }
    
    func recordVideo(_ longGes: UILongPressGestureRecognizer) {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            switch longGes.state {
            case .began:
                toggleRecording()
                initialPoint = longGes.location(in: self)
                pointLong = longGes.location(in: self)
                
            case .changed:
                pointLong = longGes.location(in: self)
                let totalSize = (collectionView.frame.origin.y + collectionView.frame.size.height)/10
                print("up:\(abs((pointLong.y-initialPoint.y)/totalSize))\n")
                let scale = abs((pointLong.y-initialPoint.y)/totalSize)
                do {
                    let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
                    try captureDevice?.lockForConfiguration()
                    
                    zoomScale = max(1.0, min(beginZoomScale * scale,  captureDevice!.activeFormat.videoMaxZoomFactor))
                    
                    captureDevice?.videoZoomFactor = zoomScale
                    
                    
                    captureDevice?.unlockForConfiguration()
                    
                } catch {
                    print("[SwiftyCam]: Error locking configuration")
                }
                
            case .ended:
                print("Touch ended")
                toggleRecording()
            default:
                break
            }
        }
    }
    
    func initialize() {
        if images != nil {
            return
        }
        if session != nil {
            
            return
        }
        
        let frontCamera = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
        var captureDevice:AVCaptureDevice
        
        for element in frontCamera!{
            let element = element as! AVCaptureDevice
            if element.position == AVCaptureDevicePosition.front {
                captureDevice = element
            }
        }
        
        
        viewTimer.isHidden = true
        collectionView.register(UINib(nibName: "FSAlbumViewCell", bundle: Bundle(for: self.classForCoder)), forCellWithReuseIdentifier: "FSAlbumViewCell")
        checkPhotoAuth()
        
        // Sorting condition
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        
        images = PHAsset.fetchAssets(with: options) 
        
        if images.count > 0 {
            changeImage(images[0])
            collectionView.reloadData()
            collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
        
        PHPhotoLibrary.shared().register(self)
        
        
        longPressVideo.addTarget(self, action: #selector(recordVideo(_:)))
        shotButton.addGestureRecognizer(longPressVideo)
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(shotButtonPressed(_:)))
        shotButton.addGestureRecognizer(tapGes)
        longPressVideo.require(toFail: tapGes)
        
        self.backgroundColor = fusumaBackgroundColor
        
        let bundle = Bundle(for: self.classForCoder)
        videoStartImage = fusumaVideoStartImage != nil ? fusumaVideoStartImage : UIImage(named: "video_button", in: bundle, compatibleWith: nil)
        flashOnImage = fusumaFlashOnImage != nil ? fusumaFlashOnImage : UIImage(named: "ic_flash_on", in: bundle, compatibleWith: nil)
        flashOffImage = fusumaFlashOffImage != nil ? fusumaFlashOffImage : UIImage(named: "ic_flash_off", in: bundle, compatibleWith: nil)
        flashAutoImage = fusumaFlashAutoImage != nil ? fusumaFlashAutoImage : UIImage(named: "ic_flash_auto", in: bundle, compatibleWith: nil)
        let flipImage = fusumaFlipImage != nil ? fusumaFlipImage : UIImage(named: "ic_loop", in: bundle, compatibleWith: nil)
        let shotImage = fusumaShotImage != nil ? fusumaShotImage : UIImage(named: "ic_radio_button_checked", in: bundle, compatibleWith: nil)
        
        if(fusumaTintIcons) {
            
            flashButton.tintColor = fusumaBaseTintColor
            flipButton.tintColor  = fusumaBaseTintColor
            shotButton.tintColor  = fusumaBaseTintColor
            
            flashButton.setImage(flashAutoImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            flipButton.setImage(flipImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            shotButton.setImage(shotImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            
        } else {
            
            flashButton.setImage(flashAutoImage, for: UIControlState())
            flipButton.setImage(flipImage, for: UIControlState())
            shotButton.setImage(shotImage, for: UIControlState())
            
        }

        
        self.isHidden = false
        
        // AVCapture
        session = AVCaptureSession()
        
        for device in AVCaptureDevice.devices() {
            
            if let device = device as? AVCaptureDevice, device.position == AVCaptureDevicePosition.front {
                
                self.device = device
                
                if !device.hasFlash {
                    
                    flashButton.isHidden = false
                }
            }
        }
        
        do {

            if let session = session {
                
                videoInput = try AVCaptureDeviceInput(device: device)

                session.addInput(videoInput)
                
                imageOutput = AVCaptureStillImageOutput()
                
                session.addOutput(imageOutput)
                videoOutput = AVCaptureMovieFileOutput()
                let totalSeconds = 60.0 //Total Seconds of capture time
                let timeScale: Int32 = 30 //FPS
                
                let maxDuration = CMTimeMakeWithSeconds(totalSeconds, timeScale)
                
                videoOutput?.maxRecordedDuration = maxDuration
                videoOutput?.minFreeDiskSpaceLimit = 1024 * 1024 //SET MIN FREE SPACE IN BYTES FOR RECORDING TO CONTINUE ON A VOLUME
                
                if session.canAddOutput(videoOutput) {
                    session.addOutput(videoOutput)
                }
                
                for de in AVCaptureDevice.devices(withMediaType: AVMediaTypeAudio) {
                    videoInput = try AVCaptureDeviceInput(device: de as! AVCaptureDevice)
                    session.addInput(videoInput)
                }
                
               
                let videoLayer = AVCaptureVideoPreviewLayer(session: session)
                videoLayer?.frame = self.previewViewContainer.bounds
                videoLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                
                self.previewViewContainer.layer.addSublayer(videoLayer!)
                
                session.sessionPreset = AVCaptureSessionPresetHigh

                session.startRunning()
                
            }
            // Focus View
            self.focusView         = UIView(frame: CGRect(x: 0, y: 0, width: 90, height: 90))
            let tapRecognizer      = UITapGestureRecognizer(target: self, action:#selector(FSCameraView.focus(_:)))
            tapRecognizer.delegate = self
            self.previewViewContainer.addGestureRecognizer(tapRecognizer)
           
            
        } catch {
            
        }
        
        flashConfiguration()
        currentCamera = CameraSelection.front
        
        self.startCamera()
        let panGes = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDownGallery(_:)))
        panGes.direction = .down
        let panGes1 = UISwipeGestureRecognizer(target: self, action: #selector(swipeUpDownGallery(_:)))
        panGes1.direction = .up
        viewPanGallery.addGestureRecognizer(panGes1)
        viewPanGallery.addGestureRecognizer(panGes)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(zoomGesture(_:)))
        pinchGesture.delegate = self
        self.addGestureRecognizer(pinchGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FSCameraView.willEnterForegroundNotification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
//        setFlashCameraSettings()
    }
    
    func zoomGesture(_ pinch: UIPinchGestureRecognizer) {
//        guard pinchToZoom == true && self.currentCamera == .rear else {
//            //ignore pinch if pinchToZoom is set to false
//            return
//        }
        do {
            let captureDevice = AVCaptureDevice.devices().first as? AVCaptureDevice
            try captureDevice?.lockForConfiguration()
            
            zoomScale = max(1.0, min(beginZoomScale * pinch.scale,  captureDevice!.activeFormat.videoMaxZoomFactor))
            
            captureDevice?.videoZoomFactor = zoomScale
            
            // Call Delegate function with current zoom scale
            
            captureDevice?.unlockForConfiguration()
            
        } catch {
            print("[SwiftyCam]: Error locking configuration")
        }
    }
    func swipeUpDownGallery(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.down && self.collectionHeight.constant == 80 {
                switch gesture.state {
                case .began:
                    print("start")
                case .changed:
                    print("change")
                case .ended:
                    print("end")
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                            self.collectionHeight.constant = 40
                        }, completion: { result in
                            self.collectionHeight.constant = 0
                    })
                default: break
            }
        }
        if gesture.direction == UISwipeGestureRecognizerDirection.up && self.collectionHeight.constant == 0 {
            switch gesture.state {
                case .began:
                    print("start")
                case .changed:
                    print("change")
                case .ended:
                    print("end")
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
                        self.collectionHeight.constant = 40
                    }, completion: { result in
                        self.collectionHeight.constant = 80
                    })
                default: break
            }
        }
    }
    @IBAction func swipeToZoom(_ gestureRecognizer: UIPanGestureRecognizer)
    {
        if !isRecording { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let velocity = gestureRecognizer.velocity(in: previewViewContainer)
            let point = gestureRecognizer.translation(in: self)
            if velocity.y > 0 {
                print("down:\(point)")
                print(shotButton.bounds)
            } else {
                print("up:\(point)")
                print(shotButton.bounds)
            }
        }  
    }
    
    func willEnterForegroundNotification(_ notification: Notification) {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {
            
            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            
            session?.stopRunning()
            alertCamera()
        }
    }
    
    func alertCamera() {
        let alert = UIAlertController(title: "Access Requested", message: "Create post with media needs access of camera,microphone and photos permission", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            
            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            
        }))
        
        self.vcc!.present(alert, animated: true, completion: nil)
    }
    func startCamera() {
        
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if status == AVAuthorizationStatus.authorized {

            session?.startRunning()
            
        } else if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {

            session?.stopRunning()
           
        }
    }
    
    func stopCamera() {
        session?.stopRunning()
    }
    
    @IBAction func shotButtonPressed(_ sender: AnyObject) {
        
        guard let device = device else {
            return
        }
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized {
            if device.hasFlash == true && flashEnabledOn == true /* TODO: Add Support for Retina Flash and add front flash */ {
                changeFlashSettings(device, mode: .on)
                capturePhotoAsyncronously({ (_) in })
                
            } else if device.hasFlash == true && flashEnabledAuto == true {
                changeFlashSettings(device, mode: .auto)
                capturePhotoAsyncronously({ (_) in })
                
            } else if device.hasFlash == true && flashEnabledOFF == true {
                changeFlashSettings(device, mode: .off)
                capturePhotoAsyncronously({ (_) in })
                
            } else if device.hasFlash == false && flashEnabledOn == true && currentCamera == .front {
                
                flashView = UIView(frame: self.frame)
                flashView?.alpha = 0.0
                flashView?.backgroundColor = UIColor.white
                previewViewContainer.addSubview(flashView!)
                
                UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                    self.flashView?.alpha = 1.0
                    
                    }, completion: { (_) in
                        self.capturePhotoAsyncronously({ (success) in
                            UIView.animate(withDuration: 0.1, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                                self.flashView?.alpha = 0.0
                                }, completion: { (_) in
                                    self.flashView?.removeFromSuperview()
                            })
                        })
                })
            } else {
                if device.isFlashActive == true {
                    changeFlashSettings(device, mode: .off)
                }
                capturePhotoAsyncronously({ (_) in })
            }
        }
    }
    
    @IBAction func flipButtonPressed(_ sender: UIButton) {

        if !cameraIsAvailable() {

            return
        }
        
        switch currentCamera {
        case .front:
            currentCamera = .rear
            UserDefaults.standard.set(false, forKey: "isFrontCamera")
        case .rear:
            currentCamera = .front
            UserDefaults.standard.set(true, forKey: "isFrontCamera")
        }
        
        session?.stopRunning()
        sessionQueue.async(execute: { [unowned self] in
            // remove and re-add inputs and outputs
            
            for input in self.session!.inputs {
                self.session!.removeInput(input as! AVCaptureInput)
            }
            self.addInputs()
            self.session!.startRunning()
        })
        
        
        // If flash is enabled, disable it as the torch is needed for front facing camera
        disableFlash()
    }

    
    func enableFlash() {
        if self.isCameraTorchOn == false {
            toggleFlash()
        }
    }
    
    func disableFlash() {
        if self.isCameraTorchOn == true {
            toggleFlash()
        }
    }
    
    func toggleFlash() {
        guard self.currentCamera == .rear else {
            // Flash is not supported for front facing camera
            return
        }
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // Check if device has a flash
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (device?.torchMode == AVCaptureTorchMode.on) {
                    device?.torchMode = AVCaptureTorchMode.off
                    self.isCameraTorchOn = false
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                        self.isCameraTorchOn = true
                    } catch {
                        print("[SwiftyCam]: \(error)")
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: \(error)")
            }
        }
    }
    
    func changeFlashSettings(_ device: AVCaptureDevice, mode: AVCaptureFlashMode) {
        do {
            try device.lockForConfiguration()
            device.flashMode = mode
            device.unlockForConfiguration()
        } catch {
            print("[SwiftyCam]: \(error)")
        }
    }
    
    func capturePhotoAsyncronously(_ completionHandler: @escaping (Bool) -> ()) {
        if let videoConnection = imageOutput?.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            imageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let image = self.processPhoto(imageData!)
                    
                    // Call delegate and return new image
                    DispatchQueue.main.async(execute: { () -> Void in
                        if fusumaCropImage {
                            self.delegate!.cameraShotFinished(image)
                        } else {
                            self.delegate!.cameraShotFinished(image)
                        }
                        
                        self.session     = nil
                        self.device      = nil
                        self.imageOutput = nil
                        self.images = nil
                    })
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            })
        } else {
            completionHandler(false)
        }
    }
    
    func processPhoto(_ imageData: Data) -> UIImage {
        let dataProvider = CGDataProvider(data: imageData as CFData)
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
        
        var image: UIImage!
        
        // Set proper orientation for photo
        // If camera is currently set to front camera, flip image
        
        switch self.currentCamera {
        case .front:
            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .leftMirrored)
        case .rear:
            image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: .right)
        }
        return image
    }
    
    func addInputs() {
        session!.beginConfiguration()
        configureVideoPreset()
        addVideoInput()
        addAudioInput()
        session!.commitConfiguration()
    }
    
    func configureVideoPreset() {
        
        if currentCamera == .front {
            session!.sessionPreset = videoInputPresetFromVideoQuality(.high)
        } else {
            if session!.canSetSessionPreset(videoInputPresetFromVideoQuality(videoQuality)) {
                session!.sessionPreset = videoInputPresetFromVideoQuality(videoQuality)
            } else {
                session!.sessionPreset = videoInputPresetFromVideoQuality(.high)
            }
        }
    }
    
    func videoInputPresetFromVideoQuality(_ quality: VideoQuality) -> String {
        switch quality {
        case .high: return AVCaptureSessionPresetHigh
        case .medium: return AVCaptureSessionPresetMedium
        case .low: return AVCaptureSessionPresetLow
        case .resolution352x288: return AVCaptureSessionPreset352x288
        case .resolution640x480: return AVCaptureSessionPreset640x480
        case .resolution1280x720: return AVCaptureSessionPreset1280x720
        case .resolution1920x1080: return AVCaptureSessionPreset1920x1080
        case .iframe960x540: return AVCaptureSessionPresetiFrame960x540
        case .iframe1280x720: return AVCaptureSessionPresetiFrame1280x720
        case .resolution3840x2160:
            if #available(iOS 9.0, *) {
                return AVCaptureSessionPreset3840x2160
            }
            else {
                print("[SwiftyCam]: Resolution 3840x2160 not supported")
                return AVCaptureSessionPresetHigh
            }
        }
    }
    
    func addVideoInput() {
        switch currentCamera {
        case .front:
            device = deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .front)
        case .rear:
            device = deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .back)
        }
        
        if let device = device {
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                    if device.isSmoothAutoFocusSupported {
                        device.isSmoothAutoFocusEnabled = true
                    }
                }
                
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                
                if device.isWhiteBalanceModeSupported(.continuousAutoWhiteBalance) {
                    device.whiteBalanceMode = .continuousAutoWhiteBalance
                }
                
                if device.isLowLightBoostSupported && lowLightBoost == true {
                    device.automaticallyEnablesLowLightBoostWhenAvailable = true
                }
                
                device.unlockForConfiguration()
            } catch {
                print("[SwiftyCam]: Error locking configuration")
            }
        }
        
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: device)
            
            if session!.canAddInput(videoDeviceInput) {
                session!.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                print("[SwiftyCam]: Could not add video device input to the session")
                print(session!.canSetSessionPreset(videoInputPresetFromVideoQuality(videoQuality)))
                setupResult = .configurationFailed
                session!.commitConfiguration()
                return
            }
        } catch {
            print("[SwiftyCam]: Could not create video device input: \(error)")
            setupResult = .configurationFailed
            return
        }
    }
    
    func addAudioInput() {
        do {
            let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            
            if session!.canAddInput(audioDeviceInput) {
                session!.addInput(audioDeviceInput)
            }
            else {
                print("[SwiftyCam]: Could not add audio device input to the session")
            }
        }
        catch {
            print("[SwiftyCam]: Could not create audio device input: \(error)")
        }
    }
    
    func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        if let devices = AVCaptureDevice.devices(withMediaType: mediaType) as? [AVCaptureDevice] {
            return devices.filter({ $0.position == position }).first
        }
        return nil
    }
    
    
    @IBAction func galleryButtonPressed(_ sender: UIButton) {
        let picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String,kUTTypeImage as String]
        picker.videoMaximumDuration = 3600
        picker.videoQuality=UIImagePickerControllerQualityType.typeHigh
        self.parentViewController?.present(picker, animated: true, completion: nil)
//        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(picker, animated: true, completion: nil)
    }
    func setFlashCameraSettings() {
        
        if !cameraIsAvailable() {
            
            return
        }
        
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                if UserDefaults.standard.bool(forKey: "isFlashOn") {
                    
                    device.flashMode = AVCaptureFlashMode.on
                    flashButton.setImage(flashOnImage, for: UIControlState())
                    
                } else {
                    
                    device.flashMode = AVCaptureFlashMode.off
                    flashButton.setImage(flashAutoImage, for: UIControlState())
                }
                
                device.unlockForConfiguration()
            }
            
        } catch _ {
            
            flashButton.setImage(flashAutoImage, for: UIControlState())
            return
        }
        
        session?.stopRunning()
        
        
        if UserDefaults.standard.bool(forKey: "isFrontCamera") {
            currentCamera = .front
        } else {
            currentCamera = .rear
        }
        
        sessionQueue.async(execute: { [unowned self] in
            // remove and re-add inputs and outputs
            
            for input in self.session!.inputs {
                self.session!.removeInput(input as! AVCaptureInput)
            }
            self.addInputs()
            self.session!.startRunning()
            })
        
        
        // If flash is enabled, disable it as the torch is needed for front facing camera
        disableFlash()
        session?.startRunning()
    }
    
    @IBAction func flashButtonPressed(_ sender: UIButton) {

        if !cameraIsAvailable() {

            return
        }

        do {

            if let device = device {
                
//                guard device.hasFlash else { return }
            
                try device.lockForConfiguration()
                
                _ = device.flashMode
                
                if flashEnabledOFF == true {
                    flashEnabledOFF = false
                    flashEnabledOn = true
                    flashEnabledAuto = false
                    if device.hasFlash {
                        device.flashMode = AVCaptureFlashMode.off
                    }
                    
                    flashButton.setImage(flashOnImage, for: UIControlState())
                    UserDefaults.standard.set(false, forKey: "isFlashOn")
                    
                } else if flashEnabledOn == true {
                    flashEnabledOn = false
                    flashEnabledAuto = true
                    flashEnabledOFF = false
                    if device.hasFlash {
                        device.flashMode = AVCaptureFlashMode.on
                    }
                    
                    flashButton.setImage(flashAutoImage, for: UIControlState())
                    UserDefaults.standard.set(true, forKey: "isFlashOn")
                } else if flashEnabledAuto == true {
                    flashEnabledAuto = false
                    flashEnabledOn = false
                    flashEnabledOFF = true
                    if device.hasFlash {
                        device.flashMode = AVCaptureFlashMode.auto
                    }
                    
                    flashButton.setImage(flashOffImage, for: UIControlState())
                    UserDefaults.standard.set(true, forKey: "isFlashOn")
                }
                
                device.unlockForConfiguration()
            }

        } catch _ {

            flashButton.setImage(flashAutoImage, for: UIControlState())
            flashEnabledOFF = true
            return
        }
    }
}

extension FSCameraView {
    
    @objc func focus(_ recognizer: UITapGestureRecognizer) {
        if isRecording { return }
        let point = recognizer.location(in: self)
        let viewsize = self.bounds.size
        let newPoint = CGPoint(x: point.y/viewsize.height, y: 1.0-point.x/viewsize.width)
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        do {
            
            try device?.lockForConfiguration()
            
        } catch _ {
            
            return
        }
        
        if device?.isFocusModeSupported(AVCaptureFocusMode.autoFocus) == true {

            device?.focusMode = AVCaptureFocusMode.autoFocus
            device?.focusPointOfInterest = newPoint
        }

        if device?.isExposureModeSupported(AVCaptureExposureMode.continuousAutoExposure) == true {
            
            device?.exposureMode = AVCaptureExposureMode.continuousAutoExposure
            device?.exposurePointOfInterest = newPoint
        }
        
        device?.unlockForConfiguration()
        
        self.focusView?.alpha = 0.0
        self.focusView?.center = point
        self.focusView?.backgroundColor = UIColor.clear
        self.focusView?.layer.borderColor = fusumaBaseTintColor.cgColor
        self.focusView?.layer.borderWidth = 1.0
        self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.addSubview(self.focusView!)
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.8,
            initialSpringVelocity: 3.0, options: UIViewAnimationOptions.curveEaseIn, // UIViewAnimationOptions.BeginFromCurrentState
            animations: {
                self.focusView!.alpha = 1.0
                self.focusView!.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            }, completion: {(finished) in
                self.focusView!.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                self.focusView!.removeFromSuperview()
        })
    }
    
    func flashConfiguration() {
    
        do {
            
            if let device = device {
                
                guard device.hasFlash else { return }
                
                try device.lockForConfiguration()
                
                device.flashMode = AVCaptureFlashMode.off
                flashButton.setImage(flashOffImage, for: UIControlState())
                
                device.unlockForConfiguration()
                
            }
            
        } catch _ {
            
            return
        }
    }

    func cameraIsAvailable() -> Bool {

        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)

        if status == AVAuthorizationStatus.authorized {

            return true
        }

        return false
    }
}
extension FSCameraView: AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print("started recording to: \(fileURL)")
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        print("finished recording to: \(outputFileURL)")
        self.delegate?.videoFinished(withFileURL: outputFileURL)
    }
    
}
extension FSCameraView: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        var videoPath: URL?
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        // choose Video
        if mediaType.isEqual(to: kUTTypeMovie as String) {
            videoPath = (info[UIImagePickerControllerMediaURL] as? URL)!
            // Check the file path in here
            self.delegate?.videoFinished(withFileURL: videoPath!)
        } else if mediaType.isEqual(to: kUTTypeImage as String) {
            
            self.delegate?.cameraShotFinished(info[UIImagePickerControllerEditedImage] as! UIImage)
            
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
extension UIView {
    
    var vcc: UIViewController? {
        
        var responder: UIResponder? = self
        
        while responder != nil {
            
            if let responder = responder as? UIViewController {
                return responder
            }
            responder = responder?.next
        }
        return nil
    }
}
func firstAvailableUIViewController(fromResponder responder: UIResponder) -> UIViewController? {
    func traverseResponderChainForUIViewController(_ responder: UIResponder) -> UIViewController? {
        if let nextResponder = responder.next {
            if let nextResp = nextResponder as? UIViewController {
                return nextResp
            } else {
                return traverseResponderChainForUIViewController(nextResponder)
            }
        }
        return nil
    }
    return traverseResponderChainForUIViewController(responder)
}
extension FSCameraView : UIGestureRecognizerDelegate {
    
    /// Set beginZoomScale when pinch begins
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
            beginZoomScale = zoomScale
        }
        if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
            beginZoomScale = zoomScale
        }
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
//    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
//            beginZoomScale = zoomScale;
//        }
//        return true
//    }
}
