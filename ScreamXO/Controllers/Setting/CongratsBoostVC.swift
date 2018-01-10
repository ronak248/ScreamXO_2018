//
//  CongratsBoostVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-19.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//

import UIKit

class CongratsBoostVC: UIViewController {
    
    @IBOutlet weak var boostItemView: UIImageView!
    @IBOutlet weak var itemDesLbl: UIButton!
    @IBOutlet weak var boostAnotherBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!

    var boost_type = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var strimg:String!
        if boost_type == 1 {
        let mgrItm = ItemManager.itemManager
            strimg = mgrItm.ItemImg
            itemDesLbl.setTitle(mgrItm.ItemName ,for: .normal)
        } else {
            let mgrItm = PostManager.postManager
            strimg = mgrItm.PostImg
            var myStringArr = strimg.components(separatedBy: ".")
            print(myStringArr[1])
            if myStringArr[3] as? String == "mp3" || myStringArr[3] as? String == "mp4" || myStringArr[3] as? String == "m4a"{
                strimg = UserDefaults.standard.value(forKey: "mediaimg") as! String
            }
        itemDesLbl.setTitle(mgrItm.PostText ,for: .normal)
        print(strimg)
        }
        boostItemView.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
        }, completed: { (img, error, type, url) -> Void in
        })
         NotificationCenter.default.addObserver(self, selector: #selector(self.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        boostAnotherBtn.layer.borderWidth = 3.0
        shareBtn.layer.borderWidth = 3.0
        boostAnotherBtn.layer.cornerRadius = 5.0
        shareBtn.layer.cornerRadius = 5.0
        
        boostAnotherBtn.layer.borderUIColor = UIColor(red: 254/255, green: 104/255, blue: 108/255, alpha: 1.0)
        shareBtn.layer.borderUIColor = UIColor(red: 254/255, green: 104/255, blue: 108/255, alpha: 1.0)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sharemedia() {
        let textToShare = ""
        let mgrItm = PostManager.postManager
        let objectsToShare = [textToShare, mgrItm.PostImg]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }
    

    @IBAction func BoostAnotherBtn(_ sender: Any) {
        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    @IBAction func ShareBtnTapped(_ sender: Any) {
         sharemedia()
    }

    @IBAction func DoneBtnTapped(_ sender: Any) {
        
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "HomeScreen")) as! HomeScreen
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
}
