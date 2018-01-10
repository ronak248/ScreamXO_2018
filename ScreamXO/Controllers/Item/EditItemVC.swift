//
//  EditItemVC.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 04/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AFNetworking

class EditItemVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WYPopoverControllerDelegate,iCarouselDataSource,iCarouselDelegate , addItemConditionDelegate {
    
    // MARK: Properites
    var popoverController: WYPopoverController!
    let mgrItm = ItemManager.itemManager
    var passArray = NSMutableArray()
    
    var arrayImages: NSMutableArray = []
    var arrayCategories: NSMutableArray! = NSMutableArray()

    var categoryArr: NSMutableArray!
    var subCategoryArr: NSMutableArray!
    var selectedIndex: Int!
    
    var indexPic:Int = 0
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_. "
    var charactesAllowedforPrice = "1234567890. "
    
    var strId: String = ""
    var delegate : ItemActionDelegate!
    var delegateAddItem : AddItemDelgate!
    var lastCategoryPickerIndex: Int?
    var lastConditionPickerIndex: Int?
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var isImage :Bool!
    
    
//    var arrayCategories: NSArray = [
//        ["name": "Original Artwork and Crafts", "img": "dash"]
//        ,   ["name": "Music and Entertainment", "img": "friend"]
//        ,["name": "Electronics", "img": "notification"]
//        , ["name": "Fashion (Clothing, Shoes & Jewelry)", "img": "shop"]
//        , ["name": "Classifieds (Home, Health, Beauty etc.)", "img": "shop"]
//        , ["name": "Specialty Services", "img": "shop"]
//        , ["name": "Misc", "img": "shop"]
//    ]
    var tmpMediaArray = NSMutableArray()
    
    // MARK: IBOutlets

    @IBOutlet weak var txtActualPrice: UITextField!
    @IBOutlet weak var imgSell: UIImageView!
    @IBOutlet weak var txtDescription: SAMTextView!
    @IBOutlet weak var txtItemname: UITextField!
    @IBOutlet weak var txtcategory: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var txtTags: UITextField!
    @IBOutlet var txtItmQty: UITextField!
    @IBOutlet var txtItmCondition: UITextField!
    @IBOutlet weak var caroselItm: iCarousel!
    
    // MARK: View life cycle methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.isImage = false

//        let mgrItm = ItemManager.itemManager
//        
//        if (mgrItm.arrayCategories == nil ) {
//            objAppDelegate.getCategoriesList()
//        }
        txtDescription.placeholder="Item Description"
        Fetchdata()
        tmpMediaArray = self.mgrItm.arrayMedia.mutableCopy() as! NSMutableArray

        callCategoryAPI()
    }

    func callCategoryAPI() {
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        print(parameterss)
        mgr.getCategoryWithSubCat(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            
            if result == APIResult.apiSuccess {
                
                self.arrayCategories = NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "categories") as! NSArray)
                self.categoryArr = NSMutableArray(array: (dic!.value(forKey: "result")! as! NSDictionary).value(forKey: "categories") as! NSArray)
                
            }else if result == APIResult.apiError {
                print(dic)
                
                SVProgressHUD.dismiss()
            }
            else {
                self.view.endEditing(true)
                mainInstance.showSomethingWentWrong()
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mgrItm.arrayMedia = tmpMediaArray.mutableCopy() as! NSMutableArray
    }
    
    // MARK: - custom button methods
    
    @IBAction func btnConditionClicked(_ sender: UIButton) {
        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "itemConditionVC")) as! itemConditionVC
        VC1.itemConditionDelegate = self
        self.navigationController?.pushViewController(VC1, animated: true)
        
//        let conditionArray = ["New", "Old"]
//        
//        ActionSheetStringPicker.show(withTitle: "Select Category", rows: conditionArray, initialSelection: lastConditionPickerIndex != nil ? lastConditionPickerIndex! : 0, doneBlock: {
//            picker, value, index in
//            
//            self.lastConditionPickerIndex = value
//            self.txtItmCondition.text = conditionArray[value]
//            return
//        }, cancel: {
//            ActionStringCancelBlock in
//            
//            return
//        }, origin: sender)
    }
    
    
    func addItemConditionDelegate(conditionTxt : String ) {
        self.txtItmCondition.text = conditionTxt
    }
    
    
    @IBAction func btnCategoryClicked(_ sender: AnyObject) {
        
        
        self.view.endEditing(true)
        let categoryArray = NSMutableArray()
        
        
        arrayCategories.removeObject(at: 0)
        arrayCategories.removeObject(at: 0)
        let allCategoryObj = arrayCategories[0]
        let allCategoryObj1 = arrayCategories[0]
        for i in 0 ..< arrayCategories.count
        {
            
            categoryArray.add((arrayCategories.object(at: i) as AnyObject).value(forKey: "category_name")!)
            
        }
        
        print(categoryArray)
        ActionSheetStringPicker.show(withTitle: "Select Category", rows: categoryArray as [AnyObject], initialSelection: lastCategoryPickerIndex != nil ? lastCategoryPickerIndex! : 0, doneBlock: {
            picker, value, index in
            
            
            self.lastCategoryPickerIndex = value
            self.txtcategory.text = "\((self.arrayCategories.object(at: value) as AnyObject).value(forKey: "category_name")!)"
            
            self.strId = "\((self.arrayCategories.object(at: value) as AnyObject).value(forKey: "id")!)"
            self.selectedIndex = value
            self.arrayCategories.insert(allCategoryObj, at: 0)
            self.arrayCategories.insert(allCategoryObj1, at: 0)
            self.selectSubCategory(sender as! UIButton)
            return
        }, cancel: { ActionStringCancelBlock in
            
            self.arrayCategories.insert(allCategoryObj, at: 0)
            self.arrayCategories.insert(allCategoryObj1, at: 0)
            return
        }, origin: sender)
    }
    
    
    
    
    
    
    func selectSubCategory(_ sender: UIButton) {
        
        
        print(categoryArr)
        let conditionArray: NSMutableArray! =  NSMutableArray()
        let subCategoryArr = (((categoryArr.object(at: selectedIndex + 2) as AnyObject).value(forKey: "sub_category") as! NSArray))
        print(subCategoryArr)
        for (index, element) in subCategoryArr.enumerated() {
            var subCatStr: String! = String()
            subCatStr = ((element as AnyObject).value(forKey: "category_name") as? String)
            conditionArray.insert(subCatStr, at: index)
        }
        
        ActionSheetStringPicker.show(withTitle: "Select Subcategory", rows: conditionArray as! [Any]!, initialSelection: lastConditionPickerIndex != nil ? lastConditionPickerIndex! : 0, doneBlock: {
            picker, value, index in
            
            self.lastConditionPickerIndex = value
            self.txtcategory.text = conditionArray.object(at: value) as? String
            return
        }, cancel: {
            ActionStringCancelBlock in
            
            return
        }, origin: sender)
    }

    @IBAction func btnAddItemClicked(_ sender: AnyObject) {

        self.view.endEditing(true)
        let predicate = NSPredicate(format: "(isimage == '1')")
        
        _ = arrayImages.filtered(using: predicate)

        self.view.endEditing(true)
        if mgrItm.arrayMedia.count <= 0
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please select item image")
        }
        else if mgrItm.arrayMedia.count > 0 {
            var isOneImage = false
            for media in mgrItm.arrayMedia {
                let dict = media as! NSDictionary
                if dict.value(forKey: "id") as! Int != 0 {
                    isOneImage = true
                }
            }
            if !isOneImage {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please select item image")
                
            } else if mainInstance.isTextfieldBlank(txtItemname) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter item name")
                
            } else if mainInstance.isTextviewBlank(txtDescription) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter description")
                
            } else if mainInstance.isTextfieldBlank(txtcategory) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please select category")
                
            } else if mainInstance.isTextfieldBlank(txtcategory) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter Email address")
                
            } else if mainInstance.isTextfieldBlank(txtPrice) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter price")
                
            } else if mainInstance.isTextfieldBlank(txtCost) {

                mainInstance.ShowAlertWithError("Error!", msg: "Please enter shipping cost")
                
            } else if mainInstance.isTextfieldBlank(txtTags) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter tags")
                
            } else if mainInstance.isTextfieldBlank(txtItmQty) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter item quantity")
                
            } else if mainInstance.isTextfieldBlank(txtItmCondition) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter item condition")
                
            } else {
                if mainInstance.connected() {
                    let usr = UserManager.userManager
                    let itm = ItemManager.itemManager
                    
                    SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                    let mgr = APIManager.apiManager
                    let parameterss = NSMutableDictionary()
                    parameterss.setValue(txtItemname.text, forKey: "itemname")
                    parameterss.setValue(txtDescription.text, forKey: "itemdesc")
                    parameterss.setValue(usr.userId, forKey: "itemcreatedby")
                    parameterss.setValue(txtPrice.text, forKey: "itemprice")
                    parameterss.setValue(txtCost.text, forKey: "itemshipcost")
                    parameterss.setValue(strId, forKey: "category")
                    parameterss.setValue(txtTags.text, forKey: "itemtags")
                    parameterss.setValue(itm.ItemId, forKey: "itemid")
                    parameterss.setValue(txtActualPrice.text, forKey: "itemactualprice")
                    parameterss.setValue(txtItmQty.text, forKey: "itemquantity")
                    parameterss.setValue(txtItmCondition.text, forKey: "item_condition")
                    
                    print(parameterss)
                    
                    mgr.manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/html"]) as? Set<String>
                    
                    if ( !(itm.ItemmedID == "")) {
                        do {
                            
                            let jsonData = try JSONSerialization.data(withJSONObject: passArray, options: JSONSerialization.WritingOptions.prettyPrinted)
                            let theJSONText:NSString = NSString(data: jsonData,
                                                                encoding: String.Encoding.ascii.rawValue)!
                            parameterss.setValue(theJSONText , forKey: "removemedia")
                        }
                        catch {
                            print(error)
                        }
                    }
                    
                    if  (isImage == true) {
                        
                        if let sessionStr:String = mgr.sessionToken {
                            mgr.manager.requestSerializer.setValue(sessionStr, forHTTPHeaderField: "usertoken")
                            
                            mgr.manager.requestSerializer.timeoutInterval = TimeInterval(300)
                            
                            mgr.manager.requestSerializer.setValue(UserManager.userManager.userId, forHTTPHeaderField: "uid")
                            if ( mgr.deviceID != nil)
                            {
                                mgr.manager.requestSerializer.setValue(mgr.deviceID, forHTTPHeaderField: "userdevice")
                            }
                            else
                            {
                                mgr.manager.requestSerializer.setValue(UIDevice.current.identifierForVendor!.uuidString, forHTTPHeaderField: "userdevice")
                                mgr.deviceID=UIDevice.current.identifierForVendor!.uuidString
                            }
                            
                        }
                        
                        mgr.manager.post(APIManager.APIConstants.ScreamXOBaseUrl + APIManager.APIConstants.Item_editEndPoint,
                                         parameters: parameterss, constructingBodyWith: {(formData: AFMultipartFormData!) -> Void in
                                            if(self.isImage == true) {
                                                
                                                var incJ:Int=0
                                                
                                                for i in 0 ..< self.mgrItm.arrayMedia.count
                                                {
                                                    let Dicdata: NSMutableDictionary = NSMutableDictionary(dictionary: self.mgrItm.arrayMedia.object(at: i) as! [AnyHashable: Any])
                                                    if (Dicdata.value(forKey: "id") as! Int == 0001)
                                                    {
                                                        var stringValue = "\(incJ)"
                                                        stringValue = "media[" + stringValue + "]"
                                                        let imgname:String = stringValue + ".png"
                                                        incJ += 1;
                                                        formData.appendPart(withFileData: UIImageJPEGRepresentation( objAppDelegate.ResizeImage((self.mgrItm.arrayMedia.object(at: i) as AnyObject).value(forKey: "img") as? UIImage, targetSize: CGSize(width: 500, height: 500))!, 0.8)!, name: stringValue, fileName: imgname, mimeType: "image/png")
                                                    }
                                                }
                                            }
                            },success: { operation ,responseObject in
                                print((responseObject! as AnyObject).description)
                                SVProgressHUD.dismiss()
                                let info = responseObject as! NSDictionary
                                print(info)
                                if(info.object(forKey: "status") as! String == "0"){
                                    
                                    mainInstance.ShowAlertWithError("Error!", msg: info.object(forKey: "msg") as! String as NSString)
                                    
                                }else{
                                    SVProgressHUD.dismiss()
                                    print(info)
                                    mainInstance.ShowAlertWithSucess("ScreamXO", msg: info.object(forKey: "msg") as! NSString)
                                    SVProgressHUD.dismiss()
                                    if self.delegate != nil
                                    {
                                        self.delegate.actionOnData()
                                    }
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }
                            },
                              failure: { operation,error in
                                print(error.localizedDescription)
                                SVProgressHUD.dismiss()
                                mainInstance.ShowAlertWithError("Error!", msg: constant.ktimeout as NSString)
                                
                        })
                        
                    }
                    else
                    {
                        
                        mgr.editItem(parameterss, successClosure: { (dic, result) -> Void in
                            SVProgressHUD.dismiss()
                            if result == APIResult.apiSuccess
                            {
                                print(dic)
                                self.tmpMediaArray = self.mgrItm.arrayMedia.mutableCopy() as! NSMutableArray
                                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                                SVProgressHUD.dismiss()
                                if self.delegate == nil
                                {
                                }
                                else
                                {
                                    self.delegate.actionOnData()
                                }
                                self.navigationController?.popViewController(animated: true)
                            }
                            else if result == APIResult.apiError
                            {
                                
                                print(dic)
                                mainInstance.ShowAlertWithError("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                                SVProgressHUD.dismiss()
                            }
                            else
                            {
                                mainInstance.showSomethingWentWrong()
                            }
                        })
                    }
                }
                else
                {
                    mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
                }
            }
        }
    }
    
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnPicClicked(_ sender: AnyObject) {
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
                {
                    self.picker!.sourceType = UIImagePickerControllerSourceType.camera
                    self.picker!.cameraDevice = .front
                    self.picker?.delegate = self
                    self.picker!.allowsEditing = true
                    self.present(self.picker!, animated: true, completion: nil)
                }
        }
        let gallaryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default)
            {
                UIAlertAction in
                if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary))
                {
                    self.picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    self.picker?.delegate = self
                    self.picker!.allowsEditing = true
                    self.present(self.picker!, animated: true, completion: nil)
                }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        
        let button = sender as! UIButton
        if (IS_IPAD)
        {
            
            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
            
        }
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func btnBackClicked(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)

        for index in 0..<mgrItm.arrayMedia.count {
            let dict = (mgrItm.arrayMedia[index] as! NSDictionary).mutableCopy()
            if (dict as AnyObject).value(forKey: "id") as! Int == 0001 {
                (dict as AnyObject).setValue(0, forKey: "id")
                (dict as AnyObject).setValue((UIImage(named: "sell_item")!), forKey: "img")
                mgrItm.arrayMedia.replaceObject(at: index, with: dict)
            }
        }
        
    }
    
    @IBAction func btnpopupClicked(_ sender: AnyObject) {
        
        if ((popoverController) != nil)
        {
            
            popoverController.dismissPopover(animated: true)
            
            
        }
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "InfoVCItem")) as! InfoVCItem
        
        popoverController = WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self;
        popoverController.popoverContentSize = CGSize(width: 200, height: 80)
        popoverController.presentPopover(from: sender.bounds, in: sender as! UIButton, permittedArrowDirections: WYPopoverArrowDirection.down, animated: true)
    }
    
    @IBAction func txtValuechanged(_ sender: AnyObject) {
        
        if ((txtPrice.text?.characters.count)!>0 && txtPrice.text != ".")
        {
            
            let mgradmin = AdminManager.adminManager
            var price:CGFloat = CGFloat(Float(txtPrice.text!)!)
            price = CGFloat(price) - CGFloat(price) * CGFloat(0.01) * CGFloat(Int(mgradmin.cutpercentage!)!)
            
            
            txtActualPrice.text = String(format: "%.2f", price)
        }
        else
        {
            
            txtActualPrice.text="";
            
        }
        
        
    }
    @IBAction func btnDeleteClicked(_ sender: AnyObject) {
        
        let alert:UIAlertController = UIAlertController(title: "Are you sure you want to delete?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let logoutAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.destructive)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                self.deleteItm()
        }
        
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.cancel)
            {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        
        if (IS_IPAD)
        {
            let button = sender as! UIButton

            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
        }
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        var Dicdata = (mgrItm.arrayMedia.object(at: indexPic)) as! NSDictionary
        Dicdata = Dicdata.mutableCopy() as! NSMutableDictionary
        Dicdata.setValue((info[UIImagePickerControllerEditedImage] as? UIImage)!, forKey: "img")
        
        
        let parameter = NSMutableDictionary()
        parameter.setValue(Dicdata.value(forKey: "id"), forKey: "img_id")
        self.passArray.add(parameter)
        Dicdata.setValue(0001, forKey: "id")
        print(mgrItm.arrayMedia)
        mgrItm.arrayMedia.replaceObject(at: indexPic, with:Dicdata)
        picker.dismiss(animated: true, completion: nil)
        isImage = true
        caroselItm.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker .dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    
    // MARK: - ClearField
    
    func clearData()
    {
    
    
        txtcategory.text = ""
        txtCost.text = ""
        txtDescription.text = ""
        txtPrice.text = ""
        txtItemname.text = ""
        txtTags.text = ""
        txtItmCondition.text = ""
        self.isImage = false;
        imgSell.image = UIImage(named: "sell_item")
        
    }
    
    func Fetchdata()
    {

        txtcategory.text=mgrItm.ItemCategory;
        txtCost.text=mgrItm.ItemShipingCost;
        txtDescription.text=mgrItm.ItemDescription;
        txtPrice.text=mgrItm.ItemPrice;
        txtItemname.text=mgrItm.ItemName;
        txtTags.text=mgrItm.ItemTags;
        txtItmQty.text = mgrItm.itm_qty_remain
        self.strId=mgrItm.ItemCategoryID
        self.isImage=false;
        
        if (mgrItm.ItemImg == nil)
        {
            mgrItm.arrayMedia.removeAllObjects()

            let parameterss = NSMutableDictionary()
            parameterss.setValue(0, forKey: "id")
            parameterss.setValue((UIImage(named: "sell_item")!), forKey: "img")
            
            let parameterss1 = NSMutableDictionary()
            parameterss1.setValue(0, forKey: "id")
            parameterss1.setValue((UIImage(named: "sell_item")!), forKey: "img")
            
            let parameterss2 = NSMutableDictionary()
            parameterss2.setValue(0, forKey: "id")
            parameterss2.setValue((UIImage(named: "sell_item")!), forKey: "img")
            
            let parameterss3 = NSMutableDictionary()
            parameterss3.setValue(0, forKey: "id")
            parameterss3.setValue((UIImage(named: "sell_item")!), forKey: "img")
            mgrItm.arrayMedia.add(parameterss)
            mgrItm.arrayMedia.add(parameterss1)
            mgrItm.arrayMedia.add(parameterss2)
            mgrItm.arrayMedia.add(parameterss3)
            
            caroselItm.reloadData()
        }
        
        else
        {
            
            if (mgrItm.arrayMedia.count==1)
            {
            
            
                let parameterss1 = NSMutableDictionary()
                parameterss1.setValue(0, forKey: "id")
                parameterss1.setValue((UIImage(named: "sell_item")!), forKey: "img")
                
                let parameterss2 = NSMutableDictionary()
                parameterss2.setValue(0, forKey: "id")
                parameterss2.setValue((UIImage(named: "sell_item")!), forKey: "img")
                
                let parameterss3 = NSMutableDictionary()
                parameterss3.setValue(0, forKey: "id")
                parameterss3.setValue((UIImage(named: "sell_item")!), forKey: "img")
                mgrItm.arrayMedia.add(parameterss1)
                mgrItm.arrayMedia.add(parameterss2)
                mgrItm.arrayMedia.add(parameterss3)

            
            }
            else if (mgrItm.arrayMedia.count==2)
            {
                
                let parameterss2 = NSMutableDictionary()
                parameterss2.setValue(0, forKey: "id")
                parameterss2.setValue((UIImage(named: "sell_item")!), forKey: "img")
                
                let parameterss3 = NSMutableDictionary()
                parameterss3.setValue(0, forKey: "id")
                parameterss3.setValue((UIImage(named: "sell_item")!), forKey: "img")
                mgrItm.arrayMedia.add(parameterss2)
                mgrItm.arrayMedia.add(parameterss3)
            } else if (mgrItm.arrayMedia.count==3) {
                
                let parameterss1 = NSMutableDictionary()
                parameterss1.setValue(0, forKey: "id")
                parameterss1.setValue((UIImage(named: "sell_item")!), forKey: "img")
                mgrItm.arrayMedia.add(parameterss1)
            }
            caroselItm.reloadData()
        }
        caroselItm.reloadData()

        let mgradmin = AdminManager.adminManager
        var price:CGFloat = CGFloat(Float(txtPrice.text!)!)
        price = CGFloat(price) - CGFloat(price) * CGFloat(0.01) * CGFloat(Int(mgradmin.cutpercentage!)!)
        txtActualPrice.text = String(format: "%.2f", price)
    }
    func deleteItm()
    {
        SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
        
        let mgrItm = ItemManager.itemManager
        let usr = UserManager.userManager
        let mgr = APIManager.apiManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(mgrItm.ItemId, forKey: "itemid")
        parameterss.setValue(usr.userId, forKey: "itemcreatedby")
        print(parameterss)
        
        mgr.deletetItem(parameterss, successClosure: { (dic, result) -> Void in
            print(dic)
            if result == APIResult.apiSuccess
            {
                mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                SVProgressHUD.dismiss()
                
                if self.delegate != nil {
                    
                    self.delegate.actiondeleteOnData()
                }
                self.navigationController?.popToRootViewController(animated: true)
            }
                
            else if result == APIResult.apiError
            {
                print(dic)
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
    
    // MARK: - Textfeild Delgate method
    
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        if ((textField == txtPrice || textField == txtCost || textField == txtItmQty))
        {
            
            
            
            // Get the attempted new string by replacing the new characters in the
            // appropriate range
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            if newString.characters.count > 0 {
                
                
                let newLength = textField.text!.characters.count + string.characters.count - range.length
                
                // Find out whether the new string is numeric by using an NSScanner.
                // The scanDecimal method is invoked with NULL as value to simply scan
                // past a decimal integer representation.
                let scanner: Scanner = Scanner(string:newString)
                let isNumeric = scanner.scanDecimal(nil) && scanner.isAtEnd
                
                
                if (string == "e" || newLength >= 10 || string == "E"||string == "-" || string == " ")
                {
                    return false
                }
                
                return isNumeric
                
            } else {
                
                // To allow for an empty text field
                return true
            }
            
            
        }
        
        let cs: CharacterSet = CharacterSet(charactersIn: charactesAllowed).inverted
        let filtered: String = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
        
        
        
    }

    //MARK: - iCarousel methods -
    
    func numberOfItems (in carousel : iCarousel) -> NSInteger
    {
        if (mgrItm.arrayMedia.count>0) {
            return (mgrItm.arrayMedia.count)
        }
        return 0
        
    }
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var view = view
        
        var imgPic : UIImageView
        
        if view == nil
        {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4, height: carousel.frame.size.width/4.3)
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            imgPic.contentMode = UIViewContentMode.scaleAspectFit
            imgPic.tag = 105
            view?.addSubview(imgPic)
        }
        else
        {
            imgPic = view?.viewWithTag(105) as! UIImageView
            
        }
        if ((((mgrItm.arrayMedia.object(at: index) as AnyObject).value(forKey: "id") as AnyObject).int32Value) == 0 || (((mgrItm.arrayMedia.object(at: index) as AnyObject).value(forKey: "id") as AnyObject).int32Value) == 0001)  {
            imgPic.image = (mgrItm.arrayMedia.object(at: index) as AnyObject).value(forKey: "img") as? UIImage
        }
        else
        {
            let strimg:String=(mgrItm.arrayMedia.object(at: index) as AnyObject).value(forKey: "media_thumb")! as! String
            imgPic.sd_setImageWithPreviousCachedImage(with: URL(string: strimg), placeholderImage: UIImage(named: "placeh"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
                }, completed: { (img, error, type, url) -> Void in
            })
        }
        imgPic.contentMode = UIViewContentMode.scaleAspectFit
        view!.backgroundColor = UIColor.white
        view?.layer.borderColor = colors.klightgreyfont.cgColor
        view?.layer.borderWidth = 1.0
        view?.layer.masksToBounds = true
        return view
    }
    func carouselItemWidth(_ carousel: iCarousel!) -> CGFloat {
        return caroselItm.frame.size.width/4.3
    }
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .spacing)
        {
            return value * 1.2
        }
        
        return value
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
        
        
        indexPic = index
        
        var Dicdata : NSMutableDictionary = NSMutableDictionary(dictionary: mgrItm.arrayMedia.object(at: indexPic) as! [AnyHashable: Any])
        
        Dicdata = Dicdata.mutableCopy() as! NSMutableDictionary
        
        
        
        let alert:UIAlertController = UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
            {
                self.picker!.sourceType = UIImagePickerControllerSourceType.camera
                self.picker!.cameraDevice = .front
                self.picker?.delegate = self
                self.picker!.allowsEditing = true
                self.present(self.picker!, animated: true, completion: nil)
            }
        }
        let gallaryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary))
            {
                self.picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
                self.picker?.delegate = self
                self.picker!.allowsEditing = true
                self.present(self.picker!, animated: true, completion: nil)
            }
        }
        let removeaction = UIAlertAction(title: "Remove Photo", style: UIAlertActionStyle.default)
        {
            UIAlertAction in
            
            if (((Dicdata.value(forKey: "id") as AnyObject).int32Value) == 0 || ((Dicdata.value(forKey: "id") as AnyObject).int32Value) == 0001)
            {
                Dicdata.setValue(0, forKey: "id")
                Dicdata.setValue((UIImage(named: "sell_item")!), forKey: "img")
            }
            else
            {
                Dicdata.setValue((UIImage(named: "sell_item")!), forKey: "img")
            
                let parameter = NSMutableDictionary()
                 parameter.setValue(Dicdata.value(forKey: "id"), forKey: "img_id")
                self.passArray.add(parameter)
                
                Dicdata.setValue(0, forKey: "id")
            }
        
            self.mgrItm.arrayMedia.replaceObject(at: index, with: Dicdata)
            self.caroselItm.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel)
        {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        
        if (Dicdata.value(forKey: "id") as! Int != 0)
        {
            alert.addAction(removeaction)
        }
        
        alert.addAction(cancelAction)
        
        if (IS_IPAD)
        {
            alert.popoverPresentationController!.sourceRect = caroselItm.bounds
            alert.popoverPresentationController!.sourceView = caroselItm
        }
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
    }
}
