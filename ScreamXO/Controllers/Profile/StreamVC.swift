//
//  StreamVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 03/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
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
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
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


class StreamVC: UITableViewController,DZNEmptyDataSetSource ,DZNEmptyDataSetDelegate {
    
    var parentCnt: UIViewController!
    var arrayStream = NSMutableArray ()
    var PaginationCallback : ((_ : String)-> Void)?
    var likeaction: Int?
    var totalCount:  Int?

    // MARK: View life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notificationName = Notification.Name("myhomescreen")
        NotificationCenter.default.post(name: notificationName, object: nil)
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-icon_menu")
        constant.btnObj1.tag = 0
        constant.btnObj1.removeTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
    }
    
    // MARK: - custom button methods
    
    func btntotalLikeCOuntClicked(_ sender: UIButton) {
        
        let mgrpost = PostManager.postManager
        mgrpost.clearManager()
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        
        let VC1=(objAppDelegate.stSideMenu.instantiateViewController(withIdentifier: "LikeListVC")) as UIViewController
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
    }
    func btnLikeClicked(_ sender: UIButton) {
        
        var likeCount:Int=((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "likecount")! as? Int)!

        let mgrpost = PostManager.postManager
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        var dic :NSMutableDictionary?
        
        let mutDict = NSMutableDictionary(dictionary: self.arrayStream.object(at: sender.tag) as! [AnyHashable: Any])
        dic = mutDict.mutableCopy() as? NSMutableDictionary;

        
        if ((dic?.value(forKey: "islike"))! as! Int == 0)
        {
            dic?.setValue(1, forKey: "islike");
         
            likeaction = 0
            likeCount += 1
            
            dic?.setValue(likeCount, forKey: "likecount");

            
            var paths:[IndexPath]!
            paths = [IndexPath(row: sender.tag, section: 0)]
            self.arrayStream.replaceObject(at: sender.tag, with: dic!)
            self.tableView.reloadRows(at: paths, with: UITableViewRowAnimation.none)
            postlikeMethod()
            
            
        }
        else
        {
            likeaction = 1
            likeCount -= 1
            dic?.setValue(likeCount, forKey: "likecount");
            dic?.setValue(0, forKey: "islike");
            var paths:[IndexPath]!
            paths = [IndexPath(row: sender.tag, section: 0)]
            self.arrayStream.replaceObject(at: sender.tag, with: dic!)
            self.tableView.reloadRows(at: paths, with: UITableViewRowAnimation.none)
            postlikeMethod()
        }
    }
    func btnMoreoptionClicked(_ sender: UIButton) {
        let mgrpost = PostManager.postManager
        
        mgrpost.PostId="\((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id") as! Int)"
        
        
        if let mypost :  Int = (self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "mypost") as? Int
        {
            mgrpost.PostismyPost = "\(mypost)"
        }
        
        let strshare : String
        strshare = (self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "post_title") as! String
        
        let alert:UIAlertController = UIAlertController(title: "Choose Action", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let Delete = UIAlertAction(title: "Delete Post", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                
                
                mgrpost.PostTypecheck="0"
                
                mgrpost.deletepost({ (dic, result) -> Void in
                    if result == APIResultpost.apiSuccess
                    {
                        self.arrayStream.removeObject(at: sender.tag)
                        var paths:[IndexPath]!
                        self.tableView.beginUpdates()
                        
                        
                        paths = [IndexPath(row: (sender.tag), section: 0)]
                        self.tableView.deleteRows(at: paths, with: UITableViewRowAnimation.fade)
                        self.tableView.endUpdates()
                    }
                })
        }
        
        
        let share = UIAlertAction(title: "Share", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                
                let textToShare = ""
                
                
                let objectsToShare = [textToShare, strshare]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                
                let button = sender
                if (IS_IPAD)
                {
                    activityVC.popoverPresentationController!.sourceRect = button.bounds;
                    activityVC.popoverPresentationController!.sourceView = button;
                }
                
                self.present(activityVC, animated: true, completion: nil)
                
                
                
        }
        let report = UIAlertAction(title: "Report Post", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                
                mgrpost.reportPost()
                
                
                
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        
        if mgrpost.PostismyPost == "1"
        {
            
            alert.addAction(Delete)
            
            
        }
        else
        {
            alert.addAction(report)
            
            
        }
        alert.addAction(share)
        alert.addAction(cancelAction)
        
        // Present the actionsheet
        
        let button = sender
        if (IS_IPAD)
        {
            
            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
            
        }
        self.present(alert, animated: true, completion: nil)
        
    }

    
    func btnCommentClicked(_ sender: UIButton) {
        
        
        let mgrItm = PostManager.postManager
        mgrItm.clearManager()
        mgrItm.PostId="\(((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id"))!)"
        mgrItm.PostType = "0"
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
            
        }
        else
        {
        
            VC1.delegate=parentCnt as! OtherProfile

        
        }
        VC1.Posttype=0;
        VC1.isViewComment=0;
        
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
        
        
    }
    func btnTotalCOmmentClciked(_ sender: UIButton) {
        
        let mgrItm = PostManager.postManager
        mgrItm.clearManager()
        mgrItm.PostId="\(((self.arrayStream.object(at: sender.tag) as AnyObject).value(forKey: "id"))!)"
        mgrItm.PostType = "0"
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
        if parentCnt.isKind(of: Profile.self) {
            
            VC1.delegate=parentCnt as! Profile
        }
        else {
            VC1.delegate=parentCnt as! OtherProfile
        }

        VC1.Posttype=0;
        VC1.isViewComment=1;
        
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
    }
    
    func btnGoToTopClicked(_ sender: Any) {
        guard self.tableView.numberOfRows(inSection: 0) > 0 else { return }
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    // MARK: ScrollView delegates
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let visibleIndexPaths = self.tableView.indexPathsForVisibleRows else { return }
        let zeroIndex = IndexPath(row: 0, section: 0)
        
        if visibleIndexPaths.contains(zeroIndex) {
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.transitionFlipFromTop, animations: {
                constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-icon_menu")
                constant.btnObj1.tag = 0
                constant.btnObj1.removeTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.1, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: {
                if constant.btnObj1.buttonsIsShown() {
                    constant.btnObj1.onTap()
                    if let firstTimeMenuLoaded = Defaults.firstTimeMenuLoaded.value as? String {
                        if firstTimeMenuLoaded != "1" {
                            constant.btnObj2.onTap()
                        }
                    }
                }
                var view: UIView?
                if let superView = self.parentCnt as? Profile{
                    view = superView.view
                } else if let superView = self.parentCnt as? OtherProfile {
                    view = superView.view
                }
                
                constant.btnObj1.frame.origin.x = (view?.frame.maxX)! - constant.btnObj1.frame.width
                constant.btnObj1.frame.origin.y = (view?.frame.maxY)! - constant.btnObj1.frame.height
                constant.btnObj2.frame.origin = constant.btnObj1.frame.origin
                objAppDelegate.circleMenuOrigin = constant.btnObj1.frame.origin
                constant.btnObj1.customNormalIconView.image = UIImage(named: "menu-uparrow")
                constant.btnObj1.tag = 1
                constant.btnObj1.addTarget(self, action: #selector(self.btnGoToTopClicked(_:)), for: .touchUpInside)
            }, completion: nil)
        }
        
    }
    
    // MARK: - tableview delgate datasource methods -
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableViewAutomaticDimension;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrayStream.count
    }
  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let CELL_ID = "streamCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ID) as! streamCell
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        cell.btnlikecount.addTarget(self, action: #selector(self.btntotalLikeCOuntClicked(_:)), for: .touchUpInside)
        cell.btnLike.addTarget(self, action: #selector(self.btnLikeClicked(_:)), for: .touchUpInside)
        cell.btnComment.addTarget(self, action: #selector(self.btnCommentClicked(_:)), for: .touchUpInside)
        cell.btntalcomments.addTarget(self, action: #selector(self.btnTotalCOmmentClciked(_:)), for: .touchUpInside)
        cell.btnMore.addTarget(self, action: #selector(self.btnMoreoptionClicked(_:)), for: .touchUpInside)
        cell.btnMore.tag=indexPath.row
        
        cell.btnLike.tag = indexPath.row
        cell.btnComment.tag = indexPath.row
        cell.btnlikecount.tag = indexPath.row
        cell.btntalcomments.tag = indexPath.row
        let strisLike:Int? = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "islike")! as? Int

       
        let strDescription:String? = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "post_title")! as? String
        let strusername:String? = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "username")! as? String
        let strimgname:String? = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "userphotothumb")! as? String

        let strlikeCount:Int = ((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "likecount")! as? Int)!

        let strcommentCOunt:Int = ((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "commentcount")! as? Int)!
        var strtime:String? = (self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "updated_date")! as? String
        strtime = NSDate.mysqlDatetimeFormatted(asTimeAgo: strtime)
        
        if (strisLike == 0) {
            cell.btnLike.setImage(UIImage(named: "unlike"), for: UIControlState())
        } else {
            cell.btnLike.setImage(UIImage(named: "like"), for: UIControlState())
        }

        cell.imguser.sd_setImageWithPreviousCachedImage(with: URL(string: strimgname!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b,url) -> Void in
            }, completed: {(img, error, type, url) -> Void in
        })
        
        cell.imguser.contentMode=UIViewContentMode.scaleAspectFill
        cell.imguser.layer.cornerRadius = cell.imguser.frame.size.height / 2
        cell.imguser.layer.masksToBounds = true
        cell.imguser.layer.borderWidth = 1.5
        cell.imguser.layer.borderColor = UIColor.white.cgColor
        cell.imguser.contentMode=UIViewContentMode.scaleAspectFill
        cell.lblName.text=strusername
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(StreamVC.openImage(_:)))
        cell.imguser.addGestureRecognizer(tapGesture)

        if (strusername == "" || strusername == nil)
        {
            
            
            cell.lblName.text="\((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "fname") as! String)"  +  " \((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "lname") as! String)"
            
            
        }
            cell.lbltime.text=strtime
            cell.btntalcomments.setTitle("\(strcommentCOunt)", for: UIControlState())
            cell.btnlikecount.setTitle("\(strlikeCount)", for: UIControlState())
        
        
        if let strDesc:String = (strDescription)! as String
        {
            let textAttachment = MyTextAttachment()
            textAttachment.image = UIImage(named: "like")
            
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 5
            let multipleAttributes = [NSParagraphStyleAttributeName: style,
                                      NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 14)!]
            
            let strDescAttribString = NSAttributedString(string: strDesc, attributes: multipleAttributes)
            var mutableStrDesc = NSMutableAttributedString(attributedString: strDescAttribString)
            
            for emojiName in customEmojis.emojiItemsArray {
                objAppDelegate.replaceEmoji(emojiName, mutableStrDesc: &mutableStrDesc)
            }
            cell.lbldescription.attributedText = mutableStrDesc
        }
        
        
        
        cell.lbldescription.tag = indexPath.row
        cell.lbldescription.userHandleLinkTapHandler = { label, handle, range in
            let strWithId = (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_oldtitle")! as? String
            let mystr = strWithId
            let searchstr = "@:@:"
            let ranges: [NSRange]
            
            do {
                // Create the regular expression.
                let regex = try NSRegularExpression(pattern: searchstr, options: [])
                
                // Use the regular expression to get an array of NSTextCheckingResult.
                // Use map to extract the range from each result.
                ranges = regex.matches(in: mystr!, options: [], range: NSMakeRange(0, mystr!.characters.count)).map {$0.range}
            }
            catch {
                // There was a problem creating the regular expression
                ranges = []
            }
            
            print(ranges)
            if (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary == nil {
                var dictTags = NSDictionary()
                if let arrTags = (self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSArray {
                    if arrTags.count == 1 {
                        let dict = ["0":arrTags.object(at: 0)]
                        dictTags = dict as NSDictionary
                        if dictTags.count <= 0 {
                            return
                        }
                        if ranges.count > 0 {
                            if (label.text! as NSString).range(of: handle).location >= 0 {
                                if let ids = dictTags.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                                    let arrStr = ids.components(separatedBy: ",")
                                    if arrStr.count > 0 {
                                        let otherId = arrStr[arrStr.count-1]
                                        let struser:String=(self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "username")! as! String
                                        let strimg:String=(self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "userphotothumb")! as! String
                                        let user = UserManager.userManager
                                        let mgrfriend = FriendsManager.friendsManager
                                        
                                        //mgrfriend.clearManager()
                                        
                                        mgrfriend.FriendName = struser + struser
                                        mgrfriend.FriendPhoto = strimg
                                        mgrfriend.FUsername = struser
                                        mgrfriend.FriendID = otherId
                                        
                                        if (mgrfriend.FriendID == user.userId)
                                        {
                                            if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                                                leftVC.selectedrow = leftVC.profileRow
                                                leftVC.tblView.reloadData()
                                            }
                                            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                                            self.navigationController?.pushViewController(VC1, animated: true)
                                        }
                                        else
                                        {
                                            let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                                            self.navigationController?.pushViewController(VC1, animated: true)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    return
                }
                return
            }
            if ((self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary)?.count <= 0 {
                return
            }
            if ranges.count > 0 {
                if (label.text! as NSString).range(of: handle).location >= 0 {
                    if let ids = ((self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "post_tagids")! as? NSDictionary)!.value(forKey: "\((label.text! as NSString).range(of: handle).location)") as? String {
                        let arrStr = ids.components(separatedBy: ",")
                        if arrStr.count > 0 {
                            let otherId = arrStr[arrStr.count-1]
                            let struser:String=(self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "username")! as! String
                            let strimg:String=(self.arrayStream.object(at: label.tag) as AnyObject).value(forKey: "userphotothumb")! as! String
                            let user = UserManager.userManager
                            let mgrfriend = FriendsManager.friendsManager
                            
                            //mgrfriend.clearManager()
                            
                            mgrfriend.FriendName = struser + struser
                            mgrfriend.FriendPhoto = strimg
                            mgrfriend.FUsername = struser
                            mgrfriend.FriendID = otherId
                            
                            if (mgrfriend.FriendID == user.userId)
                            {
                                if let leftVC = self.sideMenuViewController.leftMenuViewController as? sideMenuLeftVC {
                                    leftVC.selectedrow = leftVC.profileRow
                                    leftVC.tblView.reloadData()
                                }
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "Profile")) as! Profile
                                self.navigationController?.pushViewController(VC1, animated: true)
                            }
                            else
                            {
                                let VC1=(objAppDelegate.stProfile.instantiateViewController(withIdentifier: "OtherProfile")) as! OtherProfile
                                self.navigationController?.pushViewController(VC1, animated: true)
                                
                            }
                        }
                    }
                }
            }
        }
        
        if( indexPath.row == self.arrayStream.count-1 && self.arrayStream.count>9 && self.totalCount > self.arrayStream.count)
        {
            if PaginationCallback != nil
            {
                PaginationCallback!((self.title?.lowercased())!)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mgrItm = PostManager.postManager
        mgrItm.clearManager()
        mgrItm.PostId="\(((self.arrayStream.object(at: indexPath.row) as AnyObject).value(forKey: "id"))!)"
        mgrItm.PostType = "0"
        let VC1=(objAppDelegate.stPOST.instantiateViewController(withIdentifier: "PostDetailsVC")) as! PostDetailsVC
        if parentCnt.isKind(of: Profile.self)
        {
            VC1.delegate=parentCnt as! Profile
        }
        else
        {
            VC1.delegate=parentCnt as! OtherProfile
        }
        VC1.Posttype=0;
        VC1.isViewComment=0;
        
        
        parentCnt.navigationController?.pushViewController(VC1, animated: true)
    }
    
        
    // MARK: - Like WebServiceCalled
    
    func postlikeMethod() {
        
        let mgrpost = PostManager.postManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(usr.userId, forKey: "uid")
        parameterss.setValue(likeaction, forKey: "action")
        parameterss.setValue(mgrpost.PostId, forKey: "postid")

    
        mgr.likePost(parameterss, successClosure: { (dic, result) -> Void in
            if result == APIResult.apiSuccess {
            } else if result == APIResult.apiError {
                print(dic!)
                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
            } else {
                SVProgressHUD.dismiss()
                mainInstance.showSomethingWentWrong()
            }
        })
    }

    
    //MARK: - DZNEmptyDataSetSource Methods -
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {

        let textAttrib = [NSForegroundColorAttributeName : colors.kLightgrey155,
            NSFontAttributeName : UIFont(name: fontsName.KfontproxiRegular, size: 24)!]
        
        if (FriendsManager.friendsManager.users_info == 1 || FriendsManager.friendsManager.users_buffet == 0)
        {
        
            let finalString = NSMutableAttributedString(string: "This User is Private", attributes: textAttrib)
            return finalString
        
        }
        let finalString = NSMutableAttributedString(string: "No any post uploaded", attributes: textAttrib)
        return finalString

        
       
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "logo")
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
        imageViewer?.show(from: parentCnt, transition: JTSImageViewControllerTransition.fromOriginalPosition)
        
    }
}
