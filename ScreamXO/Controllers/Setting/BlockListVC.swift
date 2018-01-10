//
//  BlockListVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 08/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit

class BlockListCell :UITableViewCell
{
    
    
    @IBOutlet weak var btnLock: UIButton!
    @IBOutlet weak var lblname: UILabel!
    @IBOutlet weak var imgUser: RoundImage!
    
}


class BlockListVC: UIViewController,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate {
    
    var offset:Int = 1
    var limit:Int = 10
    var totalList:Int = 0
    
    var arrayBlockList = NSMutableArray ()

    @IBOutlet weak var tblBlockList: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tblBlockList.emptyDataSetDelegate = self
        tblBlockList.emptyDataSetSource = self
        tblBlockList.isHidden=true
        BlockList()

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
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
        
        
        
        return arrayBlockList.count;
        
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let CELL_ID = "rejectCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! BlockListCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        let strusername:String?=(self.arrayBlockList.object(at: indexPath.row) as AnyObject).value(forKey: "username")! as? String
        let strimgname:String?=(self.arrayBlockList.object(at: indexPath.row) as AnyObject).value(forKey: "photo")! as? String
        
        cell.imgUser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        cell.imgUser.layer.masksToBounds = true
        cell.imgUser.contentMode=UIViewContentMode.scaleAspectFill
        
        if (strusername == "" || strusername == nil)
        {
            
            
            cell.lblname.text="\((self.arrayBlockList.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String) "  +  " \((self.arrayBlockList.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            
            
        }
        else
        {
            
            
            cell.lblname.text = strusername
            
        }
        
        
        if( indexPath.row == self.arrayBlockList.count-1 && self.arrayBlockList.count>9 && self.totalList > self.arrayBlockList.count)
        {
            
            //            if PaginationCallback != nil
            //            {
            //                PaginationCallback!(type : (self.title?.lowercaseString)!)
            //            }
            
            offset = offset + 1
            BlockList()
        }

        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        var dic :NSMutableDictionary?

        let mgrfriend = FriendsManager.friendsManager
        mgrfriend.clearManager()
        
        let mutDict = NSMutableDictionary(dictionary: self.arrayBlockList.object(at: indexPath.row) as! [AnyHashable: Any])
        dic = mutDict.mutableCopy() as? NSMutableDictionary;

        
        let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let logoutAction = UIAlertAction(title: "UnBlock", style: UIAlertActionStyle.destructive) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                if let uID: Int  = dic!.value(forKey: "userid")! as? Int
                {
                    mgrfriend.FriendID = "\(uID)"
                    mgrfriend.FriendName = "\(dic!.value(forKey: "fname") as! String)"  +  " \(dic!.value(forKey: "lname") as! String)"
                    mgrfriend.FriendPhoto = "\(dic!.value(forKey: "photo") as! String)"
                    mgrfriend.FUsername = "\(dic!.value(forKey: "username") as! String)"
                    
                    self.arrayBlockList.removeObject(at: indexPath.row)
                    self.tblBlockList.reloadData()
                    mgrfriend.UnBlockFriend()
                    
                }
                
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        
        if (IS_IPAD)
        {
            
            
            let aFrame: CGRect = tblBlockList.rectForRow(at: IndexPath(row: indexPath.row, section: indexPath.section))
            
            
            alert.popoverPresentationController!.sourceRect = aFrame;
            alert.popoverPresentationController!.sourceView = tblBlockList;
            
        }
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: --BlockList webservice Method
    
    func BlockList()
    {
        
        let usr = UserManager.userManager
        
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(self.offset, forKey: "offset")
        parameterss.setValue(limit, forKey: "limit")
        parameterss.setValue(usr.userId, forKey: "uid")
        
        if arrayBlockList.count == 0
        {
            SVProgressHUD.show(withStatus: "Fetching List", maskType: SVProgressHUDMaskType.clear)
        }
        mgr.blockList(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            self.tblBlockList.isHidden=false;
            if result == APIResult.apiSuccess
            {
                if let countShop :  Int = (dic!.value(forKey: "result")! as AnyObject).value(forKey: "totalcount") as? Int
                {
                    self.totalList = countShop
                }
                
                if self.offset == 1 && self.totalList > 0
                {
                    self.arrayBlockList.removeAllObjects()
                    self.arrayBlockList = (((dic!.value(forKey: "result")! as AnyObject).value(forKey: "friends") as! NSArray).mutableCopy() as? NSMutableArray)!
                    
                }
                else if ( self.totalList > 0 )
                {
                    self.arrayBlockList.addObjects(from: ((dic!.value(forKey: "result")! as AnyObject).value(forKey: "likes")! as? NSMutableArray)!.mutableCopy() as! [AnyObject])
                }
                self.tblBlockList.reloadData()
                SVProgressHUD.dismiss()
            }
            else if result == APIResult.apiError
            {
                print(dic ?? "nil value")
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

}
