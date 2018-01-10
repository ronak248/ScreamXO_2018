//
//  ShopVc.swift
//  ScreamXO
//
//  Created by Ronak Barot on 03/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class ShopVc: UITableViewController,iCarouselDataSource,iCarouselDelegate {

    var arrayShop = NSMutableArray ()
    var icarouselView: iCarousel!
    var parentCnt: UIViewController!
    var totalCount: Int!
    var morevisible: Bool = true

    @IBOutlet var btnWatched: RoundRectbtn!
    @IBOutlet var btnSellnow: RoundRectbtn!
    @IBOutlet var btnReciept: RoundRectbtn!
    
    var updateCallback : ((_ index : Int)-> Void)?
    var PaginationCallback : ((_ type : String)-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets=false
    }
    override func viewWillAppear(_ animated: Bool) {
        
        morevisible=true
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - button methhods
    
    @IBAction func btnMenucClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
             self.sideMenuViewController.presentLeftMenuViewController()

    }
    
    @IBAction func btnWatchedListClicked(_ sender: AnyObject) {
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "WatchedList")) as! WatchedList
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
    }
    func btnReciptClicked(_ sender: UIButton) {
        
        let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "PurchasedHistory")) as! PurchasedHistory
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
        
    }
    func btnHistoryClicked(_ sender: UIButton) {
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "SellerHistoryVC")) as! SellerHistoryVC
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
    }

    
    func btnAddButtonClicked(_ sender: UIButton) {
        
        
        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "SellItemVCN")) as! SellItemVC
        
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
        }
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
        
        
    }
    func btnmoreoptionClicked(_ sender: UIButton) {
      
        if (morevisible)
        {
            morevisible=false
        }
        else
        {
            morevisible=true
        }
        self.tableView.reloadData()
    }

    //MARK: - tableview delgate datasource methods -
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        if (UI_USER_INTERFACE_IDIOM() == .pad)
        {
            return UITableViewAutomaticDimension;
        }
        return UITableViewAutomaticDimension
        
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CELL_ID = "BuffetCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID)!
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        
        let btnRecipt: UIButton = cell.contentView.viewWithTag(111) as! UIButton
        let btnAddItem: UIButton = cell.contentView.viewWithTag(112) as! UIButton
        let btnwatch: UIButton = cell.contentView.viewWithTag(113) as! UIButton
        let btnHistory: UIButton = cell.contentView.viewWithTag(114) as! UIButton
        let btnmore: UIButton = cell.contentView.viewWithTag(117) as! UIButton
        
        if parentCnt.isKind(of: Profile.self)
        {
            btnRecipt.isHidden=true
            btnAddItem.isHidden=true
            btnwatch.isHidden=true
            btnHistory.isHidden=true
            btnmore.isHidden=true
        }
        else
        {
            
            btnRecipt.isHidden=true
            btnAddItem.isHidden=true
            btnwatch.isHidden=true
            btnHistory.isHidden=true
            btnmore.isHidden=true
        }
        
        
        if (morevisible)
        {
            btnmore.isHidden=true
            btnmore.titleLabel?.textColor=colors.kLightgrey155
            btnmore.setTitleColor(colors.kLightgrey155, for: UIControlState())
            btnRecipt.isHidden=true
            btnHistory.isHidden=true
        }
        else
        {
            btnmore.titleLabel?.textColor=colors.kLightgrey155
            
            btnmore.setTitleColor(colors.kLightgrey155, for: UIControlState())
            
            btnmore.isHidden=true
            btnRecipt.isHidden=true
            btnHistory.isHidden=true
        }
        
        if parentCnt.isKind(of: Profile.self)
        {
            
        }
        else
        {
            btnRecipt.isHidden=true
            btnAddItem.isHidden=true
            btnwatch.isHidden=true
            btnHistory.isHidden=true
            btnmore.isHidden=true
        }
        btnRecipt.addTarget(self, action: #selector(ShopVc.btnReciptClicked(_:)), for: .touchUpInside)
        btnAddItem.addTarget(self, action: #selector(ShopVc.btnAddButtonClicked(_:)), for: .touchUpInside)
        btnHistory.addTarget(self, action: #selector(ShopVc.btnHistoryClicked(_:)), for: .touchUpInside)
        btnmore.addTarget(self, action: #selector(ShopVc.btnmoreoptionClicked(_:)), for: .touchUpInside)
        
        icarouselView = cell.contentView.viewWithTag(110) as! iCarousel
        let lblnodata = cell.contentView.viewWithTag(1111) as! UILabel
        
        icarouselView.type = iCarouselType.linear
        icarouselView.bounces = false
        icarouselView.isPagingEnabled = false
        icarouselView.delegate = self
        icarouselView.dataSource = self
        
        if arrayShop.count > 0
        {
            lblnodata.isHidden = true
        }
        else
        {
            lblnodata.isHidden = false
            
            if (FriendsManager.friendsManager.users_info == 1 || FriendsManager.friendsManager.users_shop == 0)
            {
                
                lblnodata.text = "No any Items Uploaded."
                
                if parentCnt.isKind(of: Profile.self) {
                    
                } else {
                    
                    lblnodata.text = "This user is private"
                }
            }
        }
        
        if DeviceType.IS_IPHONE_6 {
            
            icarouselView.viewpointOffset = CGSize(width: 140, height: 0)
        }
        else if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_4_OR_LESS {
            
            icarouselView.viewpointOffset = CGSize(width: 119, height: 0)
        }
        else if DeviceType.IS_IPHONE_6P {
            
            icarouselView.viewpointOffset = CGSize(width: 155, height: 0)
        }
        else if UI_USER_INTERFACE_IDIOM() == .pad{
            
            icarouselView.viewpointOffset = CGSize(width: 285, height: 0)
        }
        icarouselView.reloadData()
        
        return cell
    }
    
    //MARK: - iCarousel methods -
    

    func numberOfItems (in carousel : iCarousel) -> NSInteger
    {
        if self.arrayShop.count > 0
        {
            return self.arrayShop.count
        }
        return 0
    }
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var view = view
        
        //    let contentView : UIView?
        var imgPic : UIImageView
        var imgicon : UIImageView
        var imgSoldOut: UIImageView
        
        if view == nil {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4.3, height: carousel.frame.size.width/4.3)
            
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            imgPic.contentMode=UIViewContentMode.scaleAspectFill
            
            imgSoldOut = UIImageView()
            imgSoldOut.frame = view!.frame
            imgSoldOut.clipsToBounds = true
            imgSoldOut.contentMode=UIViewContentMode.scaleAspectFill
            imgSoldOut.contentMode=UIViewContentMode.scaleAspectFit
            imgSoldOut.layer.masksToBounds = true
            
            imgicon = UIImageView(frame: CGRect(x: (view?.frame.size.width)! / 2 - 16, y: (view?.frame.size.width)! / 2 - 16, width: 32, height: 32))
            imgicon.contentMode = .scaleAspectFill
            
            imgicon.tag = 101
            imgPic.tag = 105
            imgSoldOut.tag = 109
            
            view?.addSubview(imgPic)
            view?.addSubview(imgSoldOut)
            
        } else {
            imgPic = view?.viewWithTag(105) as! UIImageView
            imgSoldOut = view?.viewWithTag(109) as! UIImageView
        }
        
        let strimg:String=(self.arrayShop.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
        imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        if (self.arrayShop.object(at: index) as AnyObject).value(forKey: "ispurchased") as? Int == 1 {
            imgSoldOut.image = UIImage(named: "sold_out")
            imgSoldOut.isHidden = false
        } else {
            imgSoldOut.isHidden = true
        }
        
        view!.backgroundColor = UIColor.white
        
        return view
    }
    func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
        return icarouselView.frame.size.width/4.3
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .spacing)
        {
            return value * 1.07
        }
     
        return value
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
            
        let mgrItm = ItemManager.itemManager
        mgrItm.clearManager()

        if let itmID: Int  = (self.arrayShop.object(at: index) as AnyObject).value(forKey: "item_id") as? Int
        {
            mgrItm.ItemId = "\(itmID)"
        }

        
        
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "ItemDetails")) as! ItemDetails
        
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
            
        }
        parentCnt.navigationController?.pushViewController(VC1, animated: true)    }
    
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel!) {
        
        
        if( carousel.currentItemIndex == self.arrayShop.count-2 && self.arrayShop.count>0 && self.totalCount > self.arrayShop.count)
        {
        
            if PaginationCallback != nil
            {
                PaginationCallback!((self.title?.lowercased())!)
            }
        }
    }
    
    //MARK: - Open Image VIewer  -
    
    func openImage(_ sender: AnyObject)
    {
        let tapguesture = sender as! UITapGestureRecognizer
        let imageInfo = JTSImageInfo()
        let imgVIew = tapguesture.view as! UIImageView
        imageInfo.image = imgVIew.image
        imageInfo.referenceView = imgVIew
        imageInfo.referenceRect = imgVIew.frame
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
        imageViewer?.show(from: self, transition: JTSImageViewControllerTransition.fromOriginalPosition)
        
    }
}


