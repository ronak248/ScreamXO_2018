//
//  ViewController.swift
//  CameraApp
//
//  Created by Jatin Kathrotiya on 25/10/16.
//  Copyright © 2016 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary
typealias ComplitionBlock = (Bool) -> Void
var  AVCamFocusModeObserverContext : UnsafeRawPointer?
enum CaptureMode: Int {
    case photo = 0
    case movie = 1
}


class CameraViewController: UIViewController {
    var captureManager : CaptureManager?
    @IBOutlet var videoPreviewView : UIView!
    
    var captureVideoPreviewLayer : AVCaptureVideoPreviewLayer!
    @IBOutlet var focusModeLabel : UILabel!
    @IBOutlet var recordBtn : UIImageView!
    @IBOutlet var progressView : UIView!
    @IBOutlet var progressBar : UIProgressView!
    @IBOutlet var activityView : UIActivityIndicatorView!
    
    
    @IBOutlet var durationProgressBar : UIProgressView!
    var duration : Float = 0
    var durationTimer : Timer!
    var stillImageOutput : AVCaptureStillImageOutput!
    @IBOutlet var camerasSwitchBtn : UIButton?
    @IBOutlet var deleteLastBtn :  UIButton!
    
    var maxDuration : Float = 20
    var showCameraSwitch : Bool!
    
    var newFocusModeLabel : UILabel!
    var captureImage : UIImage!
    
    @IBOutlet var  progressLabel : UILabel!
    var currentMode : CaptureMode!
    
    
    fileprivate let sessionQueue = DispatchQueue(label: "session queue", attributes: [])
    // private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    // Picker Mehtods
    
    @IBOutlet var collectionView: UICollectionView!
    
    var assetsLibrary :ALAssetsLibrary!
    var groups : [ALAssetsGroup] = []
    var assertsArray:[ALAsset] = []
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialLoadData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func initialLoadData() -> Void {
        if self.captureManager == nil {
            self.captureManager = CaptureManager()
            self.captureManager?.delegate = self
            
            self.loadGallaryPhotos()
            
            if (self.captureManager?.setupSession())! {
                
                let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureManager?.session)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                
                let viewLayer : CALayer = self.videoPreviewView.layer
                viewLayer.masksToBounds = true
                viewLayer.insertSublayer(videoPreviewLayer!, below:viewLayer.sublayers?[0])
                self.captureVideoPreviewLayer = videoPreviewLayer
                
                currentMode = CaptureMode.movie
                let qos = DispatchQoS.QoSClass.background
                let backgroundQueue = DispatchQueue.global(qos: qos)
                backgroundQueue.async(execute: {
                    self.captureManager?.session.startRunning()
                })
                
                 self.addObserver(self, forKeyPath:"captureManager.videoInput.device.focusMode", options: NSKeyValueObservingOptions.new, context: &AVCamFocusModeObserverContext)
                
                let singleTap :UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapToAutoFocus(_:)))
                singleTap.delegate = self
                singleTap.numberOfTapsRequired = 1
                self.videoPreviewView.addGestureRecognizer(singleTap)
                
                let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapToContinouslyAutoFocus(_:)))
                doubleTap.delegate = self
                doubleTap.numberOfTapsRequired = 2
                
                singleTap.require(toFail: doubleTap)
                
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                
                
                
                let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.startRecording(_:)))
                longPress.delegate = self
                self.recordBtn.addGestureRecognizer(longPress)
                
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.takePhoto(_:)))
                tap.delegate = self
                tap.require(toFail: longPress)
                self.recordBtn.addGestureRecognizer(tap)
                
                
            }
        }
    }
    func takePhoto(_ recognizer:UITapGestureRecognizer){
        if (captureManager?.session!.canAddOutput(stillImageOutput))! {
            self.captureManager?.session!.sessionPreset = AVCaptureSessionPresetMedium
            captureManager?.session!.addOutput(stillImageOutput)
            currentMode = CaptureMode.photo
            let qos = DispatchQoS.QoSClass.background
            let backgroundQueue = DispatchQueue.global(qos: qos)
            backgroundQueue.async(execute: {
                self.captureManager?.session.startRunning()
                self.captureManager?.isImage = true
            })
        }
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, NSError) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        self.captureImage = cameraImage
                        self.captureManager = nil
                        self.performSegue(withIdentifier: "PreviewSegue", sender: nil)
                        
                    }
                }
            })
        }
    }
    
    @IBAction func startRecording(_ recognizer:UILongPressGestureRecognizer){
        switch (recognizer.state)
        {
            
        case .began:
            print("START")
            
          
            
            initialLoadData()
                
            
            
            if (self.captureManager?.recorder.isRecording == false){
                
                if (self.duration < self.maxDuration)
                {
                    self.captureManager?.startRecording();
                }
            }
        case .ended:
            if (self.captureManager!.recorder.isRecording) {
                self.durationTimer .invalidate()
                self.captureManager?.stopRecording()
               
                self.videoPreviewView.layer.borderColor = UIColor.clear.cgColor
            }
            break;
            
        default:
            break;
        }
    }
    
    
    func stringForFocusMode(_ focusMode:AVCaptureFocusMode) -> String {
        var focusString = ""
        switch focusMode {
        case .locked:
            focusString = "locked";
        case .autoFocus:
            focusString = "auto";
        case .continuousAutoFocus:
            focusString = "continuous";
        }
        return focusString
        
    }
    
    func tapToAutoFocus(_ gestureRecognizer: UIGestureRecognizer) {
        
        if (self.captureManager?.videoInput.device.isFocusPointOfInterestSupported)! {
            let tapPoint =  gestureRecognizer.location( in: self.videoPreviewView)
            let convertedFocusPoint = self.convertToPointOfInterestFromViewCoordinates(tapPoint)
            self.captureManager?.autoFocus(at: convertedFocusPoint)
        }
        
        
    }
    
    
    func tapToContinouslyAutoFocus(_ gestureRecognizer: UIGestureRecognizer) {
        
        if (self.captureManager?.videoInput.device.isFocusPointOfInterestSupported)! {
            self.captureManager?.continuousFocus(at: CGPoint(x: 0.5, y: 0.5))
        }
        
        
    }
    func convertToPointOfInterestFromViewCoordinates(_ viewCoordinates:CGPoint) -> CGPoint {
        
        var viewCoordinates = viewCoordinates
        var pointOfInterest =  CGPoint(x: 0.5, y: 0.5)
        let frameSize:CGSize = self.videoPreviewView.frame.size;
        
        if (self.captureVideoPreviewLayer.connection.isVideoMirrored) {
            viewCoordinates.x = frameSize.width - viewCoordinates.x;
        }
        if ( self.captureVideoPreviewLayer.videoGravity == AVLayerVideoGravityResize) {
            // Scale, switch x and y, and reverse x
            pointOfInterest = CGPoint(x:viewCoordinates.y / frameSize.height, y:1.0 - (viewCoordinates.x / frameSize.width));
        }else {
            
            var  cleanAperture : CGRect?
            
            for port  in (self.captureManager?.videoInput.ports as! [AVCaptureInputPort]) {
                if port.mediaType == AVMediaTypeVideo {
                    cleanAperture = CMVideoFormatDescriptionGetCleanAperture(port.formatDescription, true)
                    let apertureSize = cleanAperture?.size
                    let point = viewCoordinates
                    let apertureRatio =  (apertureSize?.height)! / (apertureSize?.width)!
                    let viewRatio = frameSize.width / frameSize.height
                    var xc:CGFloat = 0.5
                    var yc:CGFloat = 0.5
                    
                    if self.captureVideoPreviewLayer.videoGravity == AVLayerVideoGravityResizeAspect {
                        if viewRatio > apertureRatio {
                            let y2  = frameSize.height
                            let x2 = frameSize.height * apertureRatio
                            let x1 = frameSize.width
                            let blackBar = (x1 - x2) / 2
                            
                            if point.x >= blackBar && point.x <= blackBar + x2 {
                                xc = point.y / y2
                                yc = 1.0 - ((point.x - blackBar) / x2)
                            }
                        }
                        else {
                            let y2:CGFloat = frameSize.width / apertureRatio;
                            let y1:CGFloat = frameSize.height;
                            let x2:CGFloat = frameSize.width;
                            let blackBar: CGFloat = (y1 - y2) / 2;
                            // If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                            if (point.y >= blackBar && point.y <= blackBar + y2) {
                                // Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                                xc = ((point.y - blackBar) / y2);
                                yc = 1.0 - (point.x / x2);
                            }
                        }
                    }else if (self.captureVideoPreviewLayer.videoGravity == AVLayerVideoGravityResizeAspectFill){
                        if (viewRatio > apertureRatio) {
                            let  y2 : CGFloat = apertureSize!.width * (frameSize.width / apertureSize!.height);
                            xc = (point.y + ((y2 - frameSize.height) / 2.0)) / y2; // Account for cropped height
                            yc = (frameSize.width - point.x) / frameSize.width;
                        } else {
                            let x2 : CGFloat = apertureSize!.height * (frameSize.height / apertureSize!.width);
                            yc = 1.0 - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                            xc = point.y / frameSize.height;
                        }
                    }
                    pointOfInterest = CGPoint(x:xc, y:yc)
                }
            }
        }
        
        return pointOfInterest;
        
    }
    
    
    @IBAction func  switchCameraDevice() {
        self.switchCamera()
        //        if showCameraSwitch {
        //            if (!(self.camerasSwitchBtn != nil)){
        //                let btnImg = UIImage(named: "switchCamera")
        //                self.camerasSwitchBtn = UIButton(type: .custom)
        //                self.camerasSwitchBtn?.setImage(btnImg, for: .normal)
        //                self.camerasSwitchBtn?.bounds = CGRect(x:0.0, y:0.0, width:(btnImg?.size.width)!, height:(btnImg?.size.height)!);
        //                self.camerasSwitchBtn?.addTarget(self, action:#selector(self.switchCamera), for: .touchUpInside)
        //                self.view.addSubview(self.camerasSwitchBtn!)
        //
        //            }
        //
        //        }else{
        //            if ((self.camerasSwitchBtn) != nil)
        //            {
        //                self.camerasSwitchBtn?.removeFromSuperview()
        //                self.camerasSwitchBtn = nil;
        //            }
        //
        //        }
    }
    
    func switchCamera()
    {
        self.captureManager?.switchCamera()
        
    }
    
    func updateDuration()
    {
        
        if (self.captureManager?.recorder.isRecording)! {
            self.duration = self.duration + 0.1;
            self.durationProgressBar.progress = self.duration/self.maxDuration;
            NSLog("self.duration %f, self.progressBar %f", self.duration, self.durationProgressBar.progress);
            if (self.durationProgressBar.progress > 0.99) {
                self.durationTimer.invalidate()
                
                self.durationTimer = nil;
                self.captureManager?.stopRecording()
                
            }
        }else{
            self.durationTimer.invalidate()
            
            self.durationTimer = nil;
            
        }
        
        
    }
    
    func removeTime(fromDuration removeTime:Float)
    {
        self.duration = self.duration - removeTime;
        self.durationProgressBar.progress = self.duration/self.maxDuration;
    }
    
    func refresh()
    {
        self.duration = 0.0
        self.durationProgressBar.progress = 0.0;
        self.durationTimer.invalidate()
        self.durationTimer = nil;
    }
    
    
    func saveVideoWithCompletionBlock(_ completion: @escaping ComplitionBlock){
        self.captureManager?.saveVideo(completionBlock: { (success) in
            if (success) {
                print("save ")
            }else{
            }
            completion(success)
        })
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //        if (context ==  AVCamFocusModeObserverContext) {
        // Update the focus UI overlay string when the focus mode changes
        // self.focusModeLabel.text = "focus " + self.stringForFocusMode(focusMode: (AVCaptureFocusMode )change[NSKeyValueChangeNewKey] as Int )
        
        //        } else {
        //            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        //        }
    }
    
    
    
    @IBAction func toggleTorch() {
        guard let device = self.captureManager?.videoInput .device
            else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if device.torchMode == .on {
                    device.torchMode = .off
                } else {
                    device.torchMode = .on
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
    
    @IBAction func saveBtnClicked(){
        
        if captureManager?.isImage == true{
            
        }
        print(self.captureManager?.getVideoUrl()! ?? "Not found")
        print(self.captureImage)
        self.dismiss(animated: true) {
            
        }
    }
    @IBAction func doneBtnClicked(){
        self.dismiss(animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PreviewSegue"
        {
            let finalCameraView = segue.destination as! FinalCameraViewController
            if currentMode == CaptureMode.photo{
                finalCameraView.previewImage = self.captureImage
            }
            else{
                finalCameraView.captureVideoUrl = self.captureManager?.getVideoUrl()
            }
            finalCameraView.currentMode = currentMode
            
            /* let finalCameraViewController = segue.destination as! FinalCameraViewController
             */
            
            
            
        }
    }
    
    
}

extension CameraViewController : CaptureManagerDelegate , UIGestureRecognizerDelegate{
    
    func updateProgress()
    {
        
        
        //        self.progressView.isHidden = false;
        //        self.progressBar.isHidden = false;
        //        self.activityView.isHidden = true;
        //        self.progressLabel.text = "Creating the video";
        //        self.progressBar.progress = (self.captureManager?.exportSession.progress)!;
        //        if (self.progressBar.progress > 0.99) {
        //            self.captureManager?.exportProgressBarTimer.invalidate()
        //            self.captureManager?.exportProgressBarTimer = nil;
        //        }
        
    }
    
    func removeProgress()
    {
        //        self.progressBar.isHidden = true;
        //        self.activityView.startAnimating()
        //        self.progressLabel.text = "Saving to Camera Roll"
    }
    
    func captureManager(_ captureManager: CaptureManager!, didFailWithError error: NSError!) {
        //       CFRunLoopPerformBlock(CFRunLoopGetMain(), CFRunLoopMode.commonModes as CFTypeRef!) {
        //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
        //                message:[error localizedFailureReason]
        //                delegate:nil
        //                cancelButtonTitle:NSLocalizedString(@"OK", @"OK button title")
        //                otherButtonTitles:nil];
        //            [alertView show];
        //     }
        
    }
    
    func captureManagerRecordingBegan(_ captureManager: CaptureManager!) {
        self.videoPreviewView.layer.borderColor = UIColor.white.cgColor;
        self.videoPreviewView.layer.borderWidth = 2.0;
        self.durationTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateDuration), userInfo: nil, repeats: true)
    }
    func captureManagerRecordingFinished(_ captureManager: CaptureManager!) {
        print(self.captureManager?.getVideoUrl()! ?? "Not found")
        currentMode = CaptureMode.movie
        self.captureManager?.isImage = false
        self.captureManager?.stopRecording()
        
        self.performSegue(withIdentifier: "PreviewSegue", sender:nil)
        refresh()
    }
    
    
    func captureManagerDeviceConfigurationChanged(_ captureManager: CaptureManager!) {
        
    }
    
    
    ///////
    
    func loadGallaryPhotos(){
        
        if (self.assetsLibrary == nil) {
            self.assetsLibrary = ALAssetsLibrary()
        }
        
        let  groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
        
        self.assetsLibrary.enumerateGroupsWithTypes(groupTypes, usingBlock: { (group:ALAssetsGroup?, stop :UnsafeMutablePointer<ObjCBool>?) in
            
            let onlyPhotosFilter = ALAssetsFilter.allAssets()
            group?.setAssetsFilter(onlyPhotosFilter)
            if group != nil {
                if ((group?.numberOfAssets())! > 0 )
                {
                    group?.enumerateAssets({ assert, index, stop in
                        if assert != nil {
                            self.assertsArray.append(assert!)
                        }else{
                            self.collectionView.reloadData()
                        }
                    })
                    group?.enumerateAssets({ assert, index, stop in
                        if assert != nil {
                            self.assertsArray.append(assert!)
                        }else{
                            self.collectionView.reloadData()
                        }
                    })
                }
                else
                {
                }
                
            }
            
        }) { error in
            print("error")
        }
    }
    
    
    
}

extension CameraViewController :UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.assertsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell
        
        
        let  asset : ALAsset = self.assertsArray[indexPath.row]
        print(asset.value(forProperty: ALAssetPropertyType))
        if asset.value(forProperty: ALAssetPropertyType) as! String == ALAssetTypeVideo{
            cell?.btnVideo.isHidden = false
        }
        else{
            cell?.btnVideo.isHidden = true
            
        }
        let thum = asset.thumbnail().takeUnretainedValue()
        let thumbnail: UIImage? =  UIImage(cgImage: thum)
        cell?.imgView.image = thumbnail
        cell?.imgView.backgroundColor = UIColor.red
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}


///

class PhotoCell: UICollectionViewCell {
    @IBOutlet var imgView: UIImageView!
    @IBOutlet var btnVideo: UIButton!
}

