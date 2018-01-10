//
//  FusumaViewController.swift
//  Fusuma
//
//  Created by Yuta Akizuki on 2015/11/14.
//  Copyright © 2015年 ytakzk. All rights reserved.
//

import UIKit
import Photos
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc public protocol FusumaDelegate: class {
    
    func fusumaImageSelected(_ image: UIImage)
    @objc optional func fusumaDismissedWithImage(_ image: UIImage)
    func fusumaVideoCompleted(withFileURL fileURL: URL)
    func fusumaVideoCompletedwithData(withFileURL dataass: Data,fileURLL:URL)
    func fusumaCameraRollUnauthorized()
    
    @objc optional func fusumaClosed()
}

public var fusumaBaseTintColor   = UIColor.hex("#FFFFFF", alpha: 1.0)
public var fusumaTintColor       = UIColor.hex("#009688", alpha: 1.0)
public var fusumaBackgroundColor = UIColor.clear

public var fusumaAlbumImage : UIImage? = nil
public var fusumaCameraImage : UIImage? = nil
public var fusumaVideoImage : UIImage? = nil
public var fusumaCheckImage : UIImage? = nil
public var fusumaCloseImage : UIImage? = nil
public var fusumaFlashOnImage : UIImage? = nil
public var fusumaFlashOffImage : UIImage? = nil
public var fusumaFlashAutoImage : UIImage? = nil

public var fusumaFlipImage : UIImage? = nil
public var fusumaShotImage : UIImage? = nil

public var fusumaVideoStartImage : UIImage? = nil
public var fusumaVideoStopImage : UIImage? = nil

public var fusumaCropImage: Bool = false

public var fusumaCameraRollTitle = "CAMERA ROLL"
public var fusumaCameraTitle = "PHOTO"
public var fusumaVideoTitle = "VIDEO"

public var fusumaTintIcons : Bool = true

public enum FusumaModeOrder {
    case cameraFirst
    case libraryFirst
}

//@objc public class FusumaViewController: UIViewController, FSCameraViewDelegate, FSAlbumViewDelegate {
public final class FusumaViewController: UIViewController {
    
    enum Mode {
        case camera
        case library
        case video
    }

    public var hasVideo = false

    var mode: Mode = Mode.library
    public var modeOrder: FusumaModeOrder = .cameraFirst
    var willFilter = true

    @IBOutlet weak var photoLibraryViewerContainer: UIView!
    @IBOutlet weak var cameraShotContainer: UIView!
    @IBOutlet weak var videoShotContainer: UIView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
//    @IBOutlet weak var doneButton: UIButton!

    @IBOutlet var libraryFirstConstraints: [NSLayoutConstraint]!
    @IBOutlet var cameraFirstConstraints: [NSLayoutConstraint]!
    
    lazy var albumView  = FSAlbumView.instance()
    lazy var cameraView = FSCameraView.instance()
    lazy var videoView = FSVideoCameraView.instance()

    fileprivate var hasGalleryPermission: Bool {
        return PHPhotoLibrary.authorizationStatus() == .authorized
    }
    
    public weak var delegate: FusumaDelegate? = nil
    
    override public func loadView() {
        
        if let view = UINib(nibName: "FusumaViewController", bundle: Bundle(for: self.classForCoder)).instantiate(withOwner: self, options: nil).first as? UIView {
            
            self.view = view
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    
        self.view.backgroundColor = fusumaBackgroundColor
        
        cameraView.delegate = self
        
        albumView.delegate  = self
        videoView.delegate = self

        menuView.backgroundColor = fusumaBackgroundColor
        menuView.addBottomBorder(UIColor.clear, width: 1.0)
        
        let bundle = Bundle(for: self.classForCoder)
        
        // Get the custom button images if they're set
        let albumImage = fusumaAlbumImage != nil ? fusumaAlbumImage : UIImage(named: "", in: bundle, compatibleWith: nil)
        let cameraImage = fusumaCameraImage != nil ? fusumaCameraImage : UIImage(named: "", in: bundle, compatibleWith: nil)
        
        let videoImage = fusumaVideoImage != nil ? fusumaVideoImage : UIImage(named: "", in: bundle, compatibleWith: nil)

        
        let checkImage = fusumaCheckImage != nil ? fusumaCheckImage : UIImage(named: "ic_check", in: bundle, compatibleWith: nil)
        let closeImage = fusumaCloseImage != nil ? fusumaCloseImage : UIImage(named: "ic_close", in: bundle, compatibleWith: nil)
        
        if fusumaTintIcons {
            
            libraryButton.setImage(albumImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            libraryButton.setImage(albumImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            libraryButton.setImage(albumImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            libraryButton.tintColor = UIColor.clear
            libraryButton.adjustsImageWhenHighlighted = false

            cameraButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            cameraButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            cameraButton.setImage(cameraImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            cameraButton.tintColor  = UIColor.clear
            cameraButton.adjustsImageWhenHighlighted  = false
            
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: UIControlState())
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .highlighted)
            closeButton.setImage(closeImage?.withRenderingMode(.alwaysTemplate), for: .selected)
            closeButton.tintColor = fusumaBaseTintColor
            
            videoButton.setImage(videoImage, for: UIControlState())
            videoButton.setImage(videoImage, for: .highlighted)
            videoButton.setImage(videoImage, for: .selected)
            videoButton.tintColor  = UIColor.clear
            videoButton.adjustsImageWhenHighlighted = false
            
//            doneButton.setImage(checkImage?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
//            doneButton.tintColor = fusumaBaseTintColor
            
        } else {
            
            libraryButton.setImage(albumImage, for: UIControlState())
            libraryButton.setImage(albumImage, for: .highlighted)
            libraryButton.setImage(albumImage, for: .selected)
            libraryButton.tintColor = nil
            
            cameraButton.setImage(cameraImage, for: UIControlState())
            cameraButton.setImage(cameraImage, for: .highlighted)
            cameraButton.setImage(cameraImage, for: .selected)
            cameraButton.tintColor = nil

            videoButton.setImage(videoImage, for: UIControlState())
            videoButton.setImage(videoImage, for: .highlighted)
            videoButton.setImage(videoImage, for: .selected)
            videoButton.tintColor = nil
            
            closeButton.setImage(closeImage, for: UIControlState())
//            doneButton.setImage(checkImage, forState: .Normal)
        }
        
        cameraButton.clipsToBounds  = true
        libraryButton.clipsToBounds = true
        videoButton.clipsToBounds = true

        changeMode(Mode.camera)
        
        photoLibraryViewerContainer.addSubview(albumView)
        
        videoShotContainer.addSubview(videoView)
        
		//titleLabel.textColor = fusumaBaseTintColor
		
        if modeOrder != .libraryFirst {
//            libraryFirstConstraints.forEach { $0.priority = 250 }
//            cameraFirstConstraints.forEach { $0.priority = 1000 }
        }
        
        if !hasVideo {
            
            videoButton.removeFromSuperview()
            
            self.view.addConstraint(NSLayoutConstraint(
                item:       self.view,
                attribute:  .trailing,
                relatedBy:  .equal,
                toItem:     cameraButton,
                attribute:  .trailing,
                multiplier: 1.0,
                constant:   0
                )
            )
            
            self.view.layoutIfNeeded()
        }
        
        if fusumaCropImage {
//            cameraView.fullAspectRatioConstraint.active = false
//            cameraView.croppedAspectRatioConstraint.active = true
        } else {
//            cameraView.fullAspectRatioConstraint.active = true
//            cameraView.croppedAspectRatioConstraint.active = false
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        changeMode(Mode.camera)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        albumView.frame  = CGRect(origin: CGPoint.zero, size: photoLibraryViewerContainer.frame.size)
        albumView.layoutIfNeeded()
        cameraView.frame = CGRect(origin: CGPoint.zero, size: cameraShotContainer.frame.size)
        cameraView.layoutIfNeeded()
        
        albumView.initialize()
        cameraView.initialize()
        
        cameraShotContainer.addSubview(cameraView)
        
        if hasVideo {

            videoView.frame = CGRect(origin: CGPoint.zero, size: videoShotContainer.frame.size)
            videoView.layoutIfNeeded()
            videoView.initialize()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAll()
    }

    override public var prefersStatusBarHidden : Bool {
        
        return true
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            
            self.delegate?.fusumaClosed?()
        })
    }
    
    @IBAction func libraryButtonPressed(_ sender: UIButton) {
        
        changeMode(Mode.library)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
    
        changeMode(Mode.camera)
    }
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        
        changeMode(Mode.video)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        let view = albumView.imageCropView

        if fusumaCropImage {
            let normalizedX = (view?.contentOffset.x)! / (view?.contentSize.width)!
            let normalizedY = (view?.contentOffset.y)! / (view?.contentSize.height)!
            
            let normalizedWidth = (view?.frame.width)! / (view?.contentSize.width)!
            let normalizedHeight = (view?.frame.height)! / (view?.contentSize.height)!
            
            let cropRect = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                options.normalizedCropRect = cropRect
                options.resizeMode = .exact
                
                let targetWidth = floor(CGFloat(self.albumView.phAsset.pixelWidth) * cropRect.width)
                let targetHeight = floor(CGFloat(self.albumView.phAsset.pixelHeight) * cropRect.height)
                let dimension = max(min(targetHeight, targetWidth), 1024 * UIScreen.main.scale)
                
                let targetSize = CGSize(width: dimension, height: dimension)
                
                PHImageManager.default().requestImage(for: self.albumView.phAsset, targetSize: targetSize,
                contentMode: .aspectFill, options: options) {
                    result, info in
                    
                    DispatchQueue.main.async(execute: {
                        self.delegate?.fusumaImageSelected(result!)
                        
                        self.dismiss(animated: true, completion: {
                            self.delegate?.fusumaDismissedWithImage?(result!)
                        })
                    })
                }
            })
        } else {
            print("no image crop ")
            delegate?.fusumaImageSelected((view?.image)!)
            
            self.dismiss(animated: true, completion: {
                self.delegate?.fusumaDismissedWithImage?((view?.image)!)
            })
        }
    }
    
}

extension FusumaViewController: FSAlbumViewDelegate, FSCameraViewDelegate, FSVideoCameraViewDelegate {
    
    // MARK: FSCameraViewDelegate
    func cameraShotFinished(_ image: UIImage) {
        
        delegate?.fusumaImageSelected(image)
        self.dismiss(animated: false, completion: {
            
            self.delegate?.fusumaDismissedWithImage?(image)
        })
    }
    func videoFinishedFinal(withFileURL dataasset: Data,fileUrl:URL) {
        self.dismiss(animated: false, completion: nil)
        delegate?.fusumaVideoCompletedwithData(withFileURL: dataasset, fileURLL: fileUrl)
    }
    // MARK: FSAlbumViewDelegate
    public func albumViewCameraRollUnauthorized() {
        
    }
    func cameraUnauthorized() {
        
    }
    func microphoneUnauthorized() {
        
    }
    func videoFinished(withFileURL fileURL: URL) {
        delegate?.fusumaVideoCompleted(withFileURL: fileURL)
        self.dismiss(animated: false, completion: nil)
    }
    
}
func alertCamera(_ vc: UIViewController) {
    let alert = UIAlertController(title: "Access Requested", message: "Create post with media needs access of camera,microphone and photos permission", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
        
        if let url = URL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
        
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        
    }))
    
    vc.present(alert, animated: true, completion: nil)
}
func alertMicrophone(_ vc: UIViewController) {
    let alert = UIAlertController(title: "Access Requested", message: "Create post with video needs microphone permission", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
        
        if let url = URL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
        
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        
    }))
    
    vc.present(alert, animated: true, completion: nil)
}
func alertCameraRoll(_ vc: UIViewController) {
    let alert = UIAlertController(title: "Access Requested", message: "Create post with media needs access of camera,microphone and photos permission", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
        
        if let url = URL(string:UIApplicationOpenSettingsURLString) {
            UIApplication.shared.openURL(url)
        }
        
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        
    }))
    
    vc.present(alert, animated: true, completion: nil)
}
private extension FusumaViewController {
    
    func stopAll() {
        
        if hasVideo {

            self.videoView.stopCamera()
        }
        
        self.cameraView.stopCamera()
    }
    
    func changeMode(_ mode: Mode) {

        if self.mode == mode {
            return
        }
        
        //operate this switch before changing mode to stop cameras
        switch self.mode {
        case .library:
            break
        case .camera:
            self.cameraView.stopCamera()
        case .video:
            self.videoView.stopCamera()
        }
        
        self.mode = mode
        
        dishighlightButtons()
        
        switch mode {
        case .library:
            //titleLabel.text = NSLocalizedString(fusumaCameraRollTitle, comment: fusumaCameraRollTitle)
//            doneButton.hidden = false
            
            highlightButton(libraryButton)
            self.view.bringSubview(toFront: photoLibraryViewerContainer)
        case .camera:
           // titleLabel.text = NSLocalizedString(fusumaCameraTitle, comment: fusumaCameraTitle)
//            doneButton.hidden = true
            
            highlightButton(cameraButton)
            self.view.bringSubview(toFront: cameraShotContainer)
            cameraView.startCamera()
        case .video:
            //titleLabel.text = fusumaVideoTitle
//            doneButton.hidden = true
            
            highlightButton(videoButton)
            self.view.bringSubview(toFront: videoShotContainer)
            videoView.startCamera()
        }
//        doneButton.hidden = !hasGalleryPermission
        self.view.bringSubview(toFront: menuView)
    }
    
    
    func dishighlightButtons() {
        cameraButton.tintColor  = fusumaBaseTintColor
        libraryButton.tintColor = fusumaBaseTintColor
        
        if cameraButton.layer.sublayers?.count > 1 {
            
            for layer in cameraButton.layer.sublayers! {
                
                if let borderColor = layer.borderColor, UIColor(cgColor: borderColor) == UIColor.clear {
                    
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        if libraryButton.layer.sublayers?.count > 1 {
            
            for layer in libraryButton.layer.sublayers! {
                
                if let borderColor = layer.borderColor, UIColor(cgColor: borderColor) == UIColor.clear {
                    
                    layer.removeFromSuperlayer()
                }
                
            }
        }
        
        if let videoButton = videoButton {
            
            videoButton.tintColor = fusumaBaseTintColor
            
            if videoButton.layer.sublayers?.count > 1 {
                
                for layer in videoButton.layer.sublayers! {
                    
                    if let borderColor = layer.borderColor, UIColor(cgColor: borderColor) == UIColor.clear {
                        
                        layer.removeFromSuperlayer()
                    }
                    
                }
            }
        }
        
    }
    
    func highlightButton(_ button: UIButton) {
        
        button.tintColor = UIColor.clear
        
        button.addBottomBorder(UIColor.clear, width: 3)
    }
}
