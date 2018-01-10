//
//  CongratsShopVC.swift
//  ScreamXO
//
//  Created by Parangat on 2017-08-29.
//  Copyright © 2017 Ronak Barot. All rights reserved.
//


    
    import UIKit
    
    class CongratsShopVC: UIViewController {
        
        @IBOutlet weak var boostItemView: UIImageView!
        @IBOutlet weak var itemDesLbl: UIButton!
        @IBOutlet weak var keepShoppingBtn: UIButton!
        @IBOutlet weak var shareItemBtn: UIButton!
        
        var  itemimage: String!
        var itemName: String!
        var boost_type = Int()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            var strimg:String!
            itemDesLbl.setTitle(itemName ,for: .normal)
            boostItemView.sd_setImageWithPreviousCachedImage(with: URL(string: itemimage), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
            })
            NotificationCenter.default.addObserver(self, selector: #selector(self.sharemedia), name:NSNotification.Name(rawValue: "sharemedia"), object: nil)
        }
        
        override func viewWillAppear(_ animated: Bool) {
           keepShoppingBtn.layer.borderWidth = 3.0
            shareItemBtn.layer.borderWidth = 3.0
            keepShoppingBtn.layer.cornerRadius = 5.0
            shareItemBtn.layer.cornerRadius = 5.0
            
            keepShoppingBtn.layer.borderUIColor = UIColor(red: 254/255, green: 104/255, blue: 108/255, alpha: 1.0)
            shareItemBtn.layer.borderUIColor = UIColor(red: 254/255, green: 104/255, blue: 108/255, alpha: 1.0)

        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        func sharemedia() {
            let textToShare = "I have purchased This One From SCREAMXO!"
            let mgrItm = PostManager.postManager
            let objectsToShare = [textToShare, itemimage]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
        
        
        @IBAction func shopAnotherBtn(_ sender: Any) {
            let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ShopSearchVC")) as! ShopSearchVC
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
