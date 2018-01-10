//
//  SellItemVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 04/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AFNetworking

protocol AddItemDelgate  {
    func actionOnaddItemData()
}




enum APIResultITM : NSInteger
{
    case apiSuccess = 0,apiFail,apiError
}
class SellItemVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,WYPopoverControllerDelegate,ItemAddedSucess,iCarouselDataSource,iCarouselDelegate , addItemConditionDelegate, UITextFieldDelegate {
    
    // MARK: Properties
    
    typealias ServiceComplitionBlock = (NSDictionary? ,APIResultItm)  -> Void
    
    var delegate : AddItemDelgate!
    
     let mgrItm = ItemManager.itemManager
    
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_. "
    
    var charactesAllowedforPrice = "1234567890."
    
    var popoverController: WYPopoverController!
    
    var strId: String = ""
    
    var lastCategoryPickerIndex: Int?
    var lastConditionPickerIndex: Int?
    
    var editItemFlag = false
    var categoryArr: NSMutableArray!
    var subCategoryArr: NSMutableArray!
    var selectedIndex: Int!
    var indexPic:Int = 0
    var cameraIndex: Int = -1
    var picker:UIImagePickerController? = UIImagePickerController()
    var isImage :Bool!
    var arrayImages: NSMutableArray = []
    var arrayCategories: NSMutableArray! = NSMutableArray()
//    var arrayCategories: NSArray = [
//        ["name": "Original Artwork and Crafts", "img": "dash"]
//        ,   ["name": "Music and Entertainment", "img": "friend"]
//        ,["name": "Electronics", "img": "notification"]
//        , ["name": "Fashion (Clothing, Shoes & Jewelry)", "img": "shop"]
//        , ["name": "Classifieds (Home, Health, Beauty etc.)", "img": "shop"]
//        , ["name": "Specialty Services", "img": "shop"]
//        , ["name": "Misc", "img": "shop"]
//    ]
    
    // MARK: IBOutlets
    
    @IBOutlet weak var caroselItm: iCarousel!
    @IBOutlet weak var txtDescription: SAMTextView!
    @IBOutlet weak var txtItemname: UITextField!
    @IBOutlet weak var btnPic: UIButton!
    @IBOutlet weak var txtcategory: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtCost: UITextField!
    @IBOutlet weak var txtTags: UITextField!
    @IBOutlet weak var txtActualprice: UITextField!
    @IBOutlet var txtItmQty: UITextField!
    @IBOutlet var txtItmCondition: UITextField!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblCategoryDes: UILabel!
    @IBOutlet var viewPhoto: UIView!
    @IBOutlet var viewDetail: UIView!
    @IBOutlet var viewPrice: UIView!
    @IBOutlet weak var photoImgView: UIImageView!
    @IBOutlet weak var detailImgView: UIImageView!
    @IBOutlet weak var priceImgView: UIImageView!
    @IBOutlet weak var finishImgView: UIImageView!
    @IBOutlet weak var lblPhoto: UILabel!
    @IBOutlet weak var lblDetails: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblFinish: UILabel!
    @IBOutlet weak var cateBtnLbl: UILabel!
    @IBOutlet weak var cetegotryBtn: RoundRectbtn!
    
    
    var cetegotryTitleArr = ["Product Photos", "Product Details", "Product Pricing"]
    var cetegotryTitleDesArr = ["A picture is worth ten thousand words",
                                "Beware of the man who won't be bothered with details.",
                                "A price they will pay. A value you will give."
    ]
    var cetegotryBtnTitleArr = ["Add Details", "Add Price", "Post"]
    
    var photoFlag = true
    var detailsFlag = false
    var priceFlag = false
    // MARK: UIViewControllerOverridenMethods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        txtItemname.delegate = self
        txtcategory.delegate = self
        txtPrice.delegate = self
        txtCost.delegate = self
        txtTags.delegate = self
        txtActualprice.delegate = self
        txtItmQty.delegate = self
        txtItmCondition.delegate = self
        
        
        objAppDelegate.isconfiguredpayment=false
        
        self.isImage = false

        if editItemFlag {
         Fetchdata()
        } else {
        clearData()
        }
        txtDescription.placeholder="Item Description"
        callCategoryAPI()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        cetegotryBtn.layer.masksToBounds = true
        cetegotryBtn.layer.cornerRadius = 6.0
        lblCategory.text = cetegotryTitleArr[0]
        lblCategoryDes.text = "\"\(cetegotryTitleDesArr[0])\""
        cateBtnLbl.text = cetegotryBtnTitleArr[0]
        lblPhoto.tintColor = UIColor.darkGray
        viewPhoto.isHidden = false
        if self.isImage==false
        {
            //clearData()
        }
        
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
             arrayImages = mgrItm.arrayMedia
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
                 arrayImages = mgrItm.arrayMedia
                
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
                 arrayImages = mgrItm.arrayMedia
            } else if (mgrItm.arrayMedia.count==3) {
                
                let parameterss1 = NSMutableDictionary()
                parameterss1.setValue(0, forKey: "id")
                parameterss1.setValue((UIImage(named: "sell_item")!), forKey: "img")
                mgrItm.arrayMedia.add(parameterss1)
                arrayImages = mgrItm.arrayMedia
            }
            caroselItm.reloadData()
        }
        arrayImages = mgrItm.arrayMedia
        caroselItm.reloadData()
        
        let mgradmin = AdminManager.adminManager
        var price:CGFloat = CGFloat(Float(txtPrice.text!)!)
        price = CGFloat(price) - CGFloat(price) * CGFloat(0.01) * CGFloat(Int(mgradmin.cutpercentage!)!)
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
    
    @IBAction func hintBtnTapped(_ sender: Any) {
                let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "itemConditionVC")) as! itemConditionVC
                VC1.itemConditionDelegate = self
                self.navigationController?.pushViewController(VC1, animated: true)
    }
    
    func addItemConditionDelegate(conditionTxt : String ) {
        self.txtItmCondition.text = conditionTxt
    }
    
    // MARK: IBActions
    
    @IBAction func btnpoupClickhelp(_ sender: AnyObject) {
        
        
        if ((popoverController) != nil) {
            
            popoverController.dismissPopover(animated: true)
        }
        let VC1=(objAppDelegate.stShopItem.instantiateViewController(withIdentifier: "InfoVCItem")) as! InfoVCItem
        
        popoverController=WYPopoverController(contentViewController: VC1)
        popoverController.delegate = self;
        popoverController.popoverContentSize=CGSize(width: 200, height: 80)
        popoverController.presentPopover(from: sender.bounds, in: sender as! UIButton, permittedArrowDirections: WYPopoverArrowDirection.down, animated: true)
    }
    
    @IBAction func btnConditionClicked(_ sender: UIButton) {
        
//        
//        let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "itemConditionVC")) as! itemConditionVC
//        VC1.itemConditionDelegate = self
//        self.navigationController?.pushViewController(VC1, animated: true)
        
        let conditionArray =  ["New", "Like New", "Refurbished", "Fair", "Poor"]
        
        ActionSheetStringPicker.show(withTitle: "Select Condition", rows: conditionArray, initialSelection: lastConditionPickerIndex != nil ? lastConditionPickerIndex! : 0, doneBlock: {
            picker, value, index in
            
            self.lastConditionPickerIndex = value
            self.txtItmCondition.text = conditionArray[value]
            return
        }, cancel: {
            ActionStringCancelBlock in
            
            return
        }, origin: sender)
    }
    
    
    @IBAction func btnCategoryClicked(_ sender: AnyObject) {
        
        
        self.view.endEditing(true)
        let categoryArray = NSMutableArray()
        arrayCategories.removeObject(at: 0)
        arrayCategories.removeObject(at: 0)
        let allCategoryObj = arrayCategories[0]
        let allCategoryObj1 = arrayCategories[0]
        for i in 0 ..< arrayCategories.count {
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
    
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        self.view.endEditing(true)
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
    

    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtItemname {
            txtItemname.resignFirstResponder()
            txtItmQty.becomeFirstResponder()
        } else if textField == txtItmQty {
            txtItmQty.resignFirstResponder()
            txtDescription.becomeFirstResponder()
        }
        if textField == txtPrice {
            txtPrice.resignFirstResponder()
            txtCost.becomeFirstResponder()
        } else if textField == txtCost {
            txtCost.resignFirstResponder()
            txtTags.becomeFirstResponder()
        }  else if textField == txtTags {
            txtTags.resignFirstResponder()
        }
        
        self.view.endEditing(true)
        return false
    }
    
    
    @IBAction func btnAddItemClicked(_ sender: AnyObject) {
        
        
        if photoFlag {
            
            let predicate = NSPredicate(format: "(isimage == '1')")
            
            let newIsimagearray = arrayImages.filtered(using: predicate)
            
            self.view.endEditing(true)
            
            if newIsimagearray.count <= 3 {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please select atleast 4 item image")
                
            } else {
                
                 self.view.endEditing(true)
                photoFlag = false
                detailsFlag = true
                
                lblCategory.text = cetegotryTitleArr[1]
                lblCategoryDes.text = "\"\(cetegotryTitleDesArr[1])\""
                cateBtnLbl.text = cetegotryBtnTitleArr[1]
            
                photoImgView.image = UIImage(named: "tickLig")!
                detailImgView.image = UIImage(named: "twoDar")!
                viewPhoto.isHidden = true
                
                lblDetails.textColor = UIColor.darkGray
                lblPhoto.textColor = UIColor.lightGray
                viewPrice.isHidden = false
            }
            
            
        } else if detailsFlag {
            
            if mainInstance.isTextfieldBlank(txtItemname) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter item name")
                
            } else if mainInstance.isTextviewBlank(txtDescription) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter description")
                
            } else if mainInstance.isTextfieldBlank(txtcategory) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please select category")
                
            }  else if mainInstance.isTextfieldBlank(txtItmQty) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter item quantity")
                
            } else if mainInstance.isTextfieldBlank(txtItmCondition) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter item condition")
                
            } else {
                 self.view.endEditing(true)
                priceFlag = true
                detailsFlag = false
                
                lblCategory.text = cetegotryTitleArr[2]
                lblCategoryDes.text = "\"\(cetegotryTitleDesArr[2])\""
                //lblCategoryDes.textAlignment = .center
                cateBtnLbl.text = cetegotryBtnTitleArr[2]
                
                viewDetail.isHidden = false
                viewPrice.isHidden = true
                
                
                lblDetails.textColor = UIColor.lightGray
                lblPrice.textColor = UIColor.darkGray
                
                photoImgView.image = UIImage(named: "tickLig")!
                detailImgView.image = UIImage(named: "tickLig")!
                priceImgView.image = UIImage(named: "ThreeDar")!
                
            }
            
           
        } else if priceFlag {
           
            if mainInstance.isTextfieldBlank(txtPrice) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter price")
                
            } else if mainInstance.isTextfieldBlank(txtCost) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter shipping cost")
                
            } else if mainInstance.isTextfieldBlank(txtTags) {
                
                mainInstance.ShowAlertWithError("Error!", msg: "Please enter tags")
                
            } else {
                
                
                
                self.view.endEditing(true)
                viewDetail.isHidden = true
                priceFlag = false
                
                lblFinish.textColor = UIColor.darkGray
                lblPrice.textColor = UIColor.lightGray
                
                
                photoImgView.image = UIImage(named: "tickLig")!
                detailImgView.image = UIImage(named: "tickLig")!
               priceImgView.image = UIImage(named: "tickLig")!
                finishImgView.image = UIImage(named: "FourDar")!
                
                mainInstance.ShowAlert("Confirm!", msg: "Please confirm payment recieve mode")
                let configPaymentVC = objAppDelegate.stWallet.instantiateViewController(withIdentifier: "NewConfigurePaymentVC") as! NewConfigurePaymentVC
                configPaymentVC.delegate = self
                configPaymentVC.sellFlag = true
                self.navigationController?.pushViewController(configPaymentVC, animated: true)

            }
            
        }
            
            

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
        
        if photoFlag {
            
        self.navigationController?.popViewController(animated: true)
            
        } else if detailsFlag {
            
            self.view.endEditing(true)
            photoFlag = true
            detailsFlag = false
            
            lblCategory.text = cetegotryTitleArr[0]
            lblCategoryDes.text = "\"\(cetegotryTitleDesArr[0])\""
            cateBtnLbl.text = cetegotryBtnTitleArr[0]
            
            photoImgView.image = UIImage(named: "oneDar")!
            detailImgView.image = UIImage(named: "TwoLig")!
            viewPhoto.isHidden = false
            
            lblDetails.textColor = UIColor.lightGray
            lblPhoto.textColor = UIColor.darkGray
            viewDetail.isHidden = true
            viewPrice.isHidden = true
            
        } else if priceFlag {
            
            self.view.endEditing(true)
            detailsFlag = true
            priceFlag = false
            
            lblCategory.text = cetegotryTitleArr[1]
            lblCategoryDes.text = "\"\(cetegotryTitleDesArr[1])\""
            cateBtnLbl.text = cetegotryBtnTitleArr[1]
            
            detailImgView.image = UIImage(named: "twoDar")!
            priceImgView.image = UIImage(named: "ThreeLig")!
            lblDetails.textColor = UIColor.darkGray
            lblPrice.textColor = UIColor.lightGray
            viewDetail.isHidden = true
            viewPrice.isHidden = false
            viewPhoto.isHidden = true
            
        } else {
            self.view.endEditing(true)
            priceFlag = true
            lblCategory.text = cetegotryTitleArr[2]
            lblCategoryDes.text = "\"\(cetegotryTitleDesArr[2])\""
            cateBtnLbl.text = cetegotryBtnTitleArr[2]
            
            finishImgView.image = UIImage(named: "FourLig")!
            priceImgView.image = UIImage(named: "ThreeDar")!
            lblFinish.textColor = UIColor.lightGray
            lblPrice.textColor = UIColor.darkGray
            viewPrice.isHidden = true
            viewDetail.isHidden = false
            viewPhoto.isHidden = true
        }
        
       
    }
    
    
    @IBAction func txtValuechanged(_ sender: AnyObject) {
        
        if ((txtPrice.text?.characters.count)!>0 && txtPrice.text != ".") {
            let mgradmin = AdminManager.adminManager
            var price:CGFloat = CGFloat(Float(txtPrice.text!)!)
            price = CGFloat(price) - CGFloat(price) * CGFloat(0.01) * CGFloat(Int(mgradmin.cutpercentage!)!)
            txtActualprice.text = String(format: "%.2f", price)
        } else {
            txtActualprice.text="";
        }
    }
    
    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let Dicdata : NSMutableDictionary = arrayImages.object(at: indexPic) as! NSMutableDictionary
        
        Dicdata.setValue((info[UIImagePickerControllerEditedImage] as? UIImage)!, forKey: "img")
        Dicdata.setValue("1", forKey: "isimage")
        
        arrayImages.replaceObject(at: indexPic, with:Dicdata)
        picker.dismiss(animated: true, completion: nil)
        isImage = true
        caroselItm.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker.dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    
    // MARK: - ClearField
    
    func clearData()
    {
        txtcategory.text="";
        txtCost.text="";
        txtDescription.text="";
        txtPrice.text="";
        txtItemname.text="";
        txtActualprice.text="";
        txtItmQty.text = "";
        txtItmCondition.text = ""
        
        txtTags.text="";
        self.isImage=false;
        
        let parameterss = NSMutableDictionary()
        parameterss.setValue("0", forKey: "isimage")
        parameterss.setValue((UIImage(named: "sell_item")!), forKey: "img")
        
        let parameterss1 = NSMutableDictionary()
        parameterss1.setValue("0", forKey: "isimage")
        parameterss1.setValue((UIImage(named: "sell_item")!), forKey: "img")
        
        let parameterss2 = NSMutableDictionary()
        parameterss2.setValue("0", forKey: "isimage")
        parameterss2.setValue((UIImage(named: "sell_item")!), forKey: "img")
        
        let parameterss3 = NSMutableDictionary()
        parameterss3.setValue("0", forKey: "isimage")
        parameterss3.setValue((UIImage(named: "sell_item")!), forKey: "img")
        
        arrayImages.add(parameterss)
        arrayImages.add(parameterss1)
        arrayImages.add(parameterss2)
        arrayImages.add(parameterss3)
        caroselItm.reloadData()
    }
    
    // MARK: - Textfeild Delgate method
    
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
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
    
    // MARK: - sell Item Methods
    
 
    
    func actiononpayment() {
        
        let usr = UserManager.userManager
        
        if mainInstance.connected() {
            
            SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
            let mgr = APIManager.apiManager
            let parameterss = NSMutableDictionary()
            parameterss.setValue(txtItemname.text, forKey: "itemname")
            parameterss.setValue(txtDescription.text, forKey: "itemdesc")
            parameterss.setValue(usr.userId, forKey: "itemcreatedby")
            parameterss.setValue(txtPrice.text, forKey: "itemprice")
            parameterss.setValue(txtCost.text, forKey: "itemshipcost")
            parameterss.setValue(self.strId, forKey: "category")
            parameterss.setValue(txtTags.text, forKey: "itemtags")
            parameterss.setValue(txtActualprice.text, forKey: "itemactualprice")
            parameterss.setValue(txtItmQty.text, forKey: "itemquantity")
            parameterss.setValue(txtItmCondition.text, forKey: "item_condition")
            
            print(parameterss)
        
            mgr.manager.responseSerializer.acceptableContentTypes=NSSet(array: ["text/html"]) as? Set<String>
            if  ( isImage == true ) {
                
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
                
                
                mgr.manager.post(APIManager.APIConstants.ScreamXOBaseUrl + APIManager.APIConstants.Item_creationEndPoint,
                                 parameters: parameterss, constructingBodyWith: {(formData: AFMultipartFormData!) -> Void in
                                    if(self.isImage == true){
                                        
                                        var incJ:Int=0
                                        
                                        for i in 0 ..< self.arrayImages.count
                                        {
                                            let Dicdata : NSMutableDictionary = self.arrayImages.object(at: i) as! NSMutableDictionary
                                            if (Dicdata.value(forKey: "isimage") as! String == "1")
                                            {
                                                
                                                var stringValue = "\(incJ)"
                                                stringValue = "media[" + stringValue + "]"
                                                let imgname:String = stringValue + ".png"
                                                incJ += 1;
                                                formData.appendPart(withFileData: UIImageJPEGRepresentation( objAppDelegate.ResizeImage(                            (self.arrayImages.object(at: i) as AnyObject).value(forKey: "img") as? UIImage, targetSize: CGSize(width: 500, height: 500))!, 0.8)!, name: stringValue, fileName: imgname, mimeType: "image/png")
                                            }
                                            
                                            
                                        }
                                    }
                    },success: { operation,responseObject in
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
                            self.clearData()
                            if (self.delegate != nil)
                            {
                                self.delegate.actionOnaddItemData()
                            }
                            
                            let VC1=(objAppDelegate.stWallet.instantiateViewController(withIdentifier: "CongratsPostVC")) as! CongratsPostVC
                            VC1.itemimage = ((responseObject! as AnyObject).value(forKey: "result")! as! NSDictionary).value(forKey: "item_image") as! String
                            VC1.itemName = ((responseObject! as AnyObject).value(forKey: "result")! as! NSDictionary).value(forKey: "item_name") as! String
                            self.navigationController?.pushViewController(VC1, animated: true)
                            
                        }
                    }, failure: { operation,error in
                        print(error.localizedDescription)
                        SVProgressHUD.dismiss()
                        mainInstance.ShowAlertWithError("Error!", msg: constant.ktimeout as NSString)
                        
                })
                
            }
            else
            {
                
                mgr.postItem(parameterss, successClosure: { (dic, result) -> Void in
                    SVProgressHUD.dismiss()
                    if result == APIResult.apiSuccess
                    {
                        
                        self.clearData()
                        print(dic)
                        
                        if (self.delegate != nil)
                        {
                            self.delegate.actionOnaddItemData()
                        }
                        
                        self.navigationController?.popToRootViewController(animated: true)
                        
                        mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                        SVProgressHUD.dismiss()
                        
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
    
    // MARK: ----------------------
    
    //MARK: - iCarousel methods -
    
    // MARK: ----------------------
    
    func numberOfItems (in carousel : iCarousel) -> NSInteger
    {
        
        return arrayImages.count
        
    }
    func carousel(_ carousel: iCarousel!, viewForItemAt index: Int, reusing view: UIView!) -> UIView! {
        var view = view
        
        //    let contentView : UIView?
        var imgPic : UIImageView
        
        if view == nil
        {
            view = UIView()
            view!.frame = CGRect(x: 0, y: 0, width: carousel.frame.size.width/4, height: carousel.frame.size.width/4)
            
            imgPic = UIImageView()
            imgPic.frame = view!.frame
            imgPic.clipsToBounds = true
            imgPic.contentMode=UIViewContentMode.scaleAspectFit
            
            
            imgPic.tag = 105
            view?.addSubview(imgPic)
            
        }
        else
        {
            imgPic = view?.viewWithTag(105) as! UIImageView
            
        }
        
        imgPic.image = (arrayImages.object(at: index) as AnyObject).value(forKey: "img") as? UIImage
        
        
        
        
        view!.backgroundColor = UIColor.white
        view?.layer.borderColor = colors.klightgreyfont.cgColor
        view?.layer.borderWidth = 1.0
        view?.layer.masksToBounds = true
        //        view!.contentMode = .ScaleAspectFit
        
        
        
        
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
    
    @IBAction func takePhotoBtn(_ sender: Any) {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
        self.picker!.sourceType = UIImagePickerControllerSourceType.camera
        self.picker?.delegate = self
        self.picker!.allowsEditing = true
        self.present(self.picker!, animated: true, completion: nil)
            if cameraIndex == 3 {
                cameraIndex = 0
            } else {
               cameraIndex = cameraIndex + 1
            }
            
        }
        indexPic = cameraIndex
    }
    
    func carousel(_ carousel: iCarousel!, didSelectItemAt index: Int) {
        
        
        indexPic = index
        
        let Dicdata : NSMutableDictionary = arrayImages.object(at: indexPic) as! NSMutableDictionary
        
        
        
        
        
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
            Dicdata.setValue("0", forKey: "isimage")
            Dicdata.setValue((UIImage(named: "sell_item")!), forKey: "img")
            
            self.arrayImages.replaceObject(at: index, with: Dicdata)
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
        
        if (Dicdata.value(forKey: "isimage") as! String == "1")
        {
            
            alert.addAction(removeaction)
            
            
            
        }
        
        
        alert.addAction(cancelAction)
        
        if (IS_IPAD)
        {
            
            alert.popoverPresentationController!.sourceRect = caroselItm.bounds;
            alert.popoverPresentationController!.sourceView = caroselItm;
            
        }
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
}
