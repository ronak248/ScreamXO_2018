//
//  GuestShareVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-07-19.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class GuestShareVC: UIViewController {
    
    @IBOutlet weak var viewBg: UIView!
    var theJSONTextcn :NSString = ""
    var arraySearchResult = NSMutableArray()
    var player : AVPlayer!
    var playerLayer : AVPlayerLayer!
    //var session : WCSession!
    
    @IBOutlet weak var shareButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isHidden = true
        if (objAppDelegate.isLoadVideo) {
            playVideo()
            objAppDelegate.isLoadVideo=false
            viewBg.isHidden=false
            self.view.isHidden = false
        } else {
            self.view.isHidden = false
            viewBg.isHidden=true
        }
       shareButton.layer.cornerRadius = 6
    }
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func ShareScremXOAction(_ sender: Any) {
        CNContactStore().requestAccess(for: .contacts) {granted, error in
            if granted {
                DispatchQueue.main.async {
                    JContactStore.sharedContact().fetchContactEmailswithblock({ (dict:[AnyHashable: Any]!) in
                        let passArray = NSMutableArray()
                        if let temp : NSMutableArray = (dict as NSDictionary).value(forKey: "contactEmail") as? NSMutableArray
                        {
                            
//                            for i in 0 ..< temp.count
//                            {
//                                let parameterss = NSMutableDictionary()
//                                parameterss.setValue(temp.object(at: i), forKey: "email_id")
//                                passArray.add(parameterss)
//                            }
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                                let jsonTextContact = NSString(data: jsonData,
                                                               encoding: String.Encoding.ascii.rawValue)!
                                print("JSON string = \(self.theJSONTextcn)")
                                self.invateFromContacts(jsonTextContact)
                            } catch {
                                print(error)
                                mainInstance.ShowAlert("Alert", msg: error as! String as NSString )
                                
                                
                            }
                        }
                    })
                }
            } else {
                let alertHide = UIAlertController(title: "Contacts Access Denied", message:"You must allow contacts access in Settings", preferredStyle: .alert)
                let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                })
                let Setting = UIAlertAction(title: "Settings", style: .default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                    if let url = settingsUrl {
                        UIApplication.shared.openURL(url)
                    }
                    
                })
                alertHide.addAction(Cancel)
                alertHide.addAction(Setting)
                self.present(alertHide, animated: true, completion: nil)
            }
        }
        
    }
    
    func invateFromContacts(_ jsonText:NSString) {
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        
        parameterss.setValue(jsonText, forKey: "contactfriends")
        parameterss.setValue(1, forKey: "uid")
        if arraySearchResult.count == 0
        {
            SVProgressHUD.show(withStatus: "Inviting  Friends", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.InviteByContactForGuest(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: (dic?.object(forKey: "msg")) as! NSString)
                SVProgressHUD.dismiss()
                UserDefaults.standard.set(true, forKey: "GuestUser")
                UserDefaults.standard.set(true, forKey: "Shared")
                objAppDelegate.setViewAfterLogin()
                 objAppDelegate.getCategoriesList()
                UserManager.userManager.userDefaults.set("1", forKey: "userIdKey")
                UserManager.userManager.userDefaults.synchronize()
            }
            else if result == APIResult.apiError
            {
                print(dic)
                SVProgressHUD.dismiss()
            }
            else
            {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }

    func playVideo()
    {
        let urlS  = Bundle.main.path(forResource: "shutterstock_v530524 (Converted)", ofType: "mp4")
        let url =  URL.init(fileURLWithPath:urlS!, isDirectory: false)
        player = AVPlayer.init(playerItem: AVPlayerItem.init(url:url))
        let imgoverlay = UIImageView()
        imgoverlay.image = UIImage(named: "logologinnew")
        imgoverlay.frame=CGRect(x: 0, y: 50, width: imgoverlay.image!.size.width, height: imgoverlay.image!.size.height)
        imgoverlay.center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: UIScreen.main.bounds.size.height/2)
        playerLayer = AVPlayerLayer.init(player: player)
        playerLayer.frame = self.view!.bounds;
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.addSublayer(imgoverlay.layer)
        self.view!.layer  .addSublayer(playerLayer)
        //self.view.userInteractionEnabled=false
        player.actionAtItemEnd = .none
        
        
        let pinchy = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handletapGesture(_:)))
        pinchy.numberOfTapsRequired=1
        viewBg.addGestureRecognizer(pinchy)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerItemDidReachEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:player.currentItem)
        player.play()
    }
    
    func handletapGesture(_ sender: AnyObject) {
        
        self.view.isUserInteractionEnabled = true
        player.pause()
        playerLayer.removeFromSuperlayer()
        objAppDelegate.setRootViewController()
       
    }
    func playerItemDidReachEnd( _ notification:Notification)
    {
        self.view.isUserInteractionEnabled=true
        player.pause()
        playerLayer.removeFromSuperlayer()
        objAppDelegate.setRootViewController()
 
    }

    
}
