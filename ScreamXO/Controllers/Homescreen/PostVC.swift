//
//  CreatePost_Media.swift
//  ScreamXO
//
//  Created by Ronak Barot on 29/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking


class PostVC: UIViewController,UINavigationControllerDelegate ,UITableViewDataSource ,UITableViewDelegate, UIScrollViewDelegate{
  
    
    // MARK: Properties
    
    
    var isTimerVisible = true
    var delegate : PostmediaActionDelegate!
    var meterTimer:Timer!
    var dataGdrive:Data!
    var isImage :Bool!
    var strsongname :String = ""
    var strartistname :String = ""
    
    var timerArray = [["title": "30 min", "value": 30], ["title": "1 Hour", "value": 60],["title": "4 Hours", "value": 240],["title": "12 Hours", "value": 720], ["title": "24 Hours", "value": 1440]]
    
    
    @IBOutlet weak var controlBtn: UIButton!
    var selectedDate: Int?
    
    var videoUrl: URL? = nil
    var timerSelectedIndexPath: IndexPath?
    var searchOffset = 1
    var searchLimit = 10
    var isRecord = false
    
    
    // MARK: IBOutlets
    
    
    @IBOutlet var viewArtistView: UIControl!
    @IBOutlet weak var btnMedia: UIButton!
    @IBOutlet weak var btnShop: UIButton!
    @IBOutlet weak var btnStream: UIButton!
    @IBOutlet weak var lblTime: UILabel!
    
    @IBOutlet var tblTimer: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let navController = self.navigationController {
            navController.interactivePopGestureRecognizer?.delegate = nil
        }
        
        tblTimer.delegate = self
        tblTimer.dataSource = self
        tblTimer.isScrollEnabled = false
        tblTimer.isHidden = true
        self.isImage = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tblTimer.isHidden = true
        btnMedia.layer.cornerRadius = btnMedia.frame.size.width/2
        btnMedia.layer.masksToBounds = true
        btnShop.layer.cornerRadius = btnShop.frame.size.width/2
        btnShop.layer.masksToBounds = true
        btnStream.layer.cornerRadius = btnStream.frame.size.width/2
        IQKeyboardManager.sharedManager().enable = true
        btnStream.layer.masksToBounds = true
        IQKeyboardManager.sharedManager().enableAutoToolbar=true
        if let snapContainer = objAppDelegate.window?.rootViewController as? SnapContainerViewController {
            snapContainer.scrollView.isScrollEnabled = true
        }
        
        
    }
    

    
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
 
    }
    
    // MARK: - customButton Methods
    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    

    @IBAction func btnMediaClicked(_ sender: AnyObject) {
        let objwallet: CreatePost_Media =  objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePost_Media") as! CreatePost_Media
       // objwallet.delegate = self
        objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
        
    }
    
    @IBAction func btnShopClicked(_ sender: AnyObject) {
        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN")) as! SellItemVC
        self.navigationController?.pushViewController(VC1, animated: true)
        
    }
    
    @IBAction func btnStreamClicked(_ sender: AnyObject) {
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "CreatePostVC")) as! CreatePostVC
        self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    
    func btnTimerClicked(_ sender: UIButton) {
        
        if isTimerVisible {
            self.showTimer()
        } else {
            self.hideTimer()
        }
    }
    
    func showTimer() {
        isTimerVisible = false
        tblTimer.isScrollEnabled = true
        tblTimer.backgroundColor = UIColor(hexString: "27B9B8")
        UIView.animate(withDuration: 0.4, animations: {
            self.controlBtn.isHidden = true
            self.view.layoutIfNeeded()
        })
        tblTimer.reloadData()
        tblTimer.selectRow(at: timerSelectedIndexPath, animated: false, scrollPosition: .none)
    }
    
    @IBAction func timerActionBtn(_ sender: Any) {
        showTimer()
        tblTimer.isHidden = true
    }
    
    func hideTimer() {
        isTimerVisible = true
        tblTimer.isScrollEnabled = false
        tblTimer.backgroundColor = .clear
        UIView.animate(withDuration: 0.4, animations: {
            self.tblTimer.isHidden = true
            self.controlBtn.isHidden = false
            self.view.layoutIfNeeded()
        })
        tblTimer.reloadData()
    }

    func cancelTimerTapped() {
        self.hideTimer()
    }

    
    
    func btnGSMClicked(_ btnIndex: Int) {
        switch btnIndex {
            
        case 0:
            let objwallet: CreatePost_Media =  objAppDelegate.stMsg.instantiateViewController(withIdentifier: "CreatePost_Media") as! CreatePost_Media
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
            
        case 7:
            let objwallet: MessagingVC =  objAppDelegate.stMsg.instantiateViewController(withIdentifier: "MessagingVC") as! MessagingVC
            objAppDelegate.screamNavig?.pushViewController(objwallet, animated: true)
        default:
            break
        }
    }
    

    
    

 //MARK: UITableViewDelegate

func numberOfSections(in tableView: UITableView) -> Int {
    return 1
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return timerArray.count
}

func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
    let btnTime = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: headerView.frame.height))
//    btnTime.addTarget(self, action: #selector(self.btnTimerClicked), for: .touchUpInside)
//    btnTime.titleLabel?.font = UIFont(name: fontsName.KfontproxiBold, size: 28)
//    btnTime.setImage(UIImage(named: "ico_mediapost_timer"), for: UIControlState())
    
    if tableView == tblTimer {
        //btnTime.setTitle("Control", for: UIControlState())
    }
    btnTime.isHidden = true
    btnTime.setTitleColor(.white, for: .normal)
    btnTime.titleEdgeInsets.left = 20
    
    if isTimerVisible {
        headerView.frame =  CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0)
        btnTime.titleEdgeInsets.top = -10
        btnTime.imageEdgeInsets.top = -10
    } else {
        btnTime.titleEdgeInsets.top = 0
        btnTime.imageEdgeInsets.top = 0
    }
    
    btnTime.titleLabel?.textAlignment = NSTextAlignment.center
    headerView.addSubview(btnTime)
    return headerView
}

func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
   
    let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
    footerView.backgroundColor = UIColor.init(red: 163.0/255.0, green: 182.0/255.0, blue: 217.0/255.0, alpha: 1.0)
    let btnFooter = UIButton(frame: CGRect(x: 0, y: 0, width: footerView.frame.width, height: footerView.frame.height))
    btnFooter.titleLabel?.font = UIFont(name: fontsName.KfontproxiRegular, size: 14)!
    btnFooter.addTarget(self, action: #selector(self.cancelTimerTapped), for: .touchUpInside)
    btnFooter.setTitle("Cancel", for: UIControlState())
    btnFooter.titleLabel?.textAlignment = NSTextAlignment.center
    btnFooter.setTitleColor(UIColor.black, for: UIControlState())
    footerView.addSubview(btnFooter)
    
    return footerView
}

func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    
    return 50.0
}

func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    
    return 50.0
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "tblTimerCell"
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! tblTimerCell
    cell.contentView.backgroundColor = UIColor.init(red: 10/255.0, green: 187/255.0, blue: 181/255.0, alpha: 1.0)
    cell.lblTime.text = timerArray[indexPath.row]["title"] as? String
    return cell
    
    
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedDate = self.timerArray[indexPath.row]["value"] as? Int
    print(timerArray[indexPath.row]["value"] as! Int)
    timerSelectedIndexPath = indexPath
    self.hideTimer()
}

}


