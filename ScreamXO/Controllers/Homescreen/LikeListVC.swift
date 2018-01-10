//
//  LikeListVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 10/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class LikeListVC: UIViewController ,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate{
    
    
    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0

    var arrayLikeList = NSMutableArray ()
    @IBOutlet weak var tblLikeList: UITableView!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblLikeList.emptyDataSetDelegate = self
        tblLikeList.emptyDataSetSource = self
        tblLikeList.isHidden=true;

        LikeList()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK : - custom button methods
    
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
        
    }

    //MARK: - tableview delgate datasource methods -
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 0.00
    }
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    {
        return 0.01
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayLikeList.count;
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let CELL_ID = "rejectCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! BlockListCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        
        let strusername:String?=(self.arrayLikeList.object(at: indexPath.row) as AnyObject).value(forKey: "username")! as? String
        let strimgname:String?=(self.arrayLikeList.object(at: indexPath.row) as AnyObject).value(forKey: "userphoto")! as? String
        
        
        
        cell.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
        })
        
        cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        cell.imgUser.layer.cornerRadius = cell.imgUser.frame.size.height / 2
        cell.imgUser.layer.masksToBounds = true
        cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        if (strusername == "" || strusername == nil)
        {
            
            
            cell.lblname.text="\((self.arrayLikeList.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  +  " \((self.arrayLikeList.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            
            
        }
        else
        {
        
        
            cell.lblname.text = strusername
        
        }
            
        
        if( indexPath.row == self.arrayLikeList.count-1 && self.arrayLikeList.count>9 && self.totalList > self.arrayLikeList.count)
        {
            
            //            if PaginationCallback != nil
            //            {
            //                PaginationCallback!(type : (self.title?.lowercaseString)!)
            //            }
            
            offset = offset + 1
            LikeList()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        var dic :NSMutableDictionary?
        
        let mgrfriend = FriendsManager.friendsManager
        mgrfriend.clearManager()
        
        
        let mutDict = NSMutableDictionary(dictionary: self.arrayLikeList.object(at: indexPath.row) as! [AnyHashable: Any])
        dic = mutDict.mutableCopy() as? NSMutableDictionary
        
        if let uID: String  = dic!.value(forKey: "userid")! as? String {
            
            let user = UserManager.userManager
            
            if (uID == user.userId) {
                
                if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                    leftVC.selectedrow = leftVC.profileRow
                    leftVC.tblView.reloadData()
                }
                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                
                self.navigationController?.pushViewController(VC1, animated: true)
                
            } else {
                
                mgrfriend.FriendID = "\(uID)"
                mgrfriend.FriendName = "\(dic!.value(forKey: "fname") as! String)"  +  " \(dic!.value(forKey: "lname") as! String)"
                mgrfriend.FriendPhoto = "\(dic!.value(forKey: "userphoto") as! String)"
                mgrfriend.FUsername = "\(dic!.value(forKey: "username") as! String)"
                
                
                if let fID = dic!.value(forKey: "isfriend")! as? Int {
                    mgrfriend.isFriend = "\(fID)"
                    
                    if fID == 1 {
                        if let fconnectionID = dic!.value(forKey: "friendshipid")! as? Int {
                            mgrfriend.friendConnectionID = "\(fconnectionID)"
                            
                        }
                    }
                }
                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                self.navigationController?.pushViewController(VC1, animated: true)
            }
        }
    }
    
    
    // MARK: --LikeList webservice Method
    
    func LikeList()
    {
        
        let usr = UserManager.userManager
        let postmgr = PostManager.postManager

        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(postmgr.PostId, forKey: "postid")

        if arrayLikeList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.likeList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            self.tblLikeList.isHidden=false;

            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "likecount") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offset == 1 && self.totalList > 0
                {
                    self.arrayLikeList.removeAllObjects()
                    self.arrayLikeList = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "likes") as! NSArray).mutableCopy() as? NSMutableArray)!
                    
                }
                else if ( self.totalList > 0 )
                {
                    self.arrayLikeList.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "likes")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblLikeList.reloadData()
                SVProgressHUD.dismiss()
                
                
                
            }
                
            else if result == APIResult.apiError
            {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                
            }
            else
             {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    //MARK: - DZNEmptyDataSetSource Methods -
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let textAttrib = [NSForegroundColorAttributeName : colors.kLightgrey155,
            NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 24)!]
        let finalString = NSMutableAttributedString(string: "No records found", attributes: textAttrib)
        return finalString
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
