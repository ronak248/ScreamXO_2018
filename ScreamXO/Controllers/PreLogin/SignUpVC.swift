//
//  SignUpVC.swift
//  ScreamXO
//
//  Created by Ronak Barot on 20/01/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//



import UIKit
import AFNetworking
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


class SignUpVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CountryPhoneCodePickerDelegate, UITextFieldDelegate {
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtfname: UITextField!
    
    //@IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var txtcode: UITextField!
    @IBOutlet weak var txtphonenum: UITextField!
    @IBOutlet weak var txtpassword: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtlname: UITextField!
    
    @IBOutlet weak var btnProfilePic: UIButton!
    @IBOutlet weak var btnCheckMark: UIButton!
    
    @IBOutlet weak var imgProfile: UIImageView!
    var picker:UIImagePickerController? = UIImagePickerController()
    var isImage :Bool!
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
    
    
    // for country code
    @IBOutlet weak var countryPhoneCodePicker: CountryPicker!

    @IBOutlet var viewcountry: UIView!
    
    override func viewDidLoad() {
        
        let attributes = [
            NSForegroundColorAttributeName:UIColor(red: 48/255, green: 48/255, blue: 48/255, alpha: 1.00),
            NSFontAttributeName : UIFont(name: "ProximaNova-Bold" , size: 19)!
        ]
        
        txtUsername.attributedPlaceholder = NSAttributedString(string: "Username", attributes:attributes)
        
        txtfname.attributedPlaceholder = NSAttributedString(string: "First Name", attributes:attributes)
        
        txtcode.attributedPlaceholder = NSAttributedString(string: "+1", attributes:attributes)
        
        txtphonenum.attributedPlaceholder = NSAttributedString(string: "Phone", attributes:attributes)
        

        txtEmail.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes:attributes)
        
        txtlname.attributedPlaceholder = NSAttributedString(string: "Last Name", attributes:attributes)
        
        txtpassword.attributedPlaceholder = NSAttributedString(string: "Password", attributes:attributes)
        

        
        txtUsername.delegate = self
        txtfname.delegate = self
        txtlname.delegate = self
        txtEmail.delegate = self
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String
        
        countryPhoneCodePicker.countryPhoneCodeDelegate = self
        countryPhoneCodePicker.setCountry(code)

        
//        self.automaticallyAdjustsScrollViewInsets = false
//        scrollView.contentInset = UIEdgeInsetsMake(0,0,0,0)
        
        
        self.isImage = false
        btnCheckMark.tag=1
        btnCheckMark.setImage(UIImage(named: ""), for: UIControlState())
        btnCheckMark.tag=1;
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar=false
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - custom button Methods


    
    
    
    // MARK: - customButton Methods

    @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
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
        
        if (UI_USER_INTERFACE_IDIOM() == .pad)
        {
            
            alert.popoverPresentationController!.sourceRect = btnProfilePic.bounds;
            alert.popoverPresentationController!.sourceView = btnProfilePic;
            
        }
        // Present the actionsheet
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func btnCheckMarkClicked(_ sender: AnyObject) {
        
        if btnCheckMark.tag==0
        {
            
            btnCheckMark.setImage(UIImage(named: ""), for: UIControlState())
            btnCheckMark.tag=1;
        
        }
        else
        {
        
        
            btnCheckMark.setImage(UIImage(named: "checkbox"), for: UIControlState())
            btnCheckMark.tag=0;
        
        }
        
        
    }
    
    @IBAction func btntermsClicked(_ sender: AnyObject) {
        
        let mgradmin = AdminManager.adminManager

        
        UIApplication.shared.openURL(URL(string: mgradmin.termsUrl)!)


        
    }
    
    
    @IBAction func btnDonepickerClicked(_ sender: AnyObject) {
        
        viewcountry.isHidden=true

        
        
    }
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func btncanceltoolClicked(_ sender: AnyObject) {
        
        viewcountry.isHidden=true
        txtcode.text = ""
        
    }
    
    
    @IBAction func btncountrycodeClicked(_ sender: AnyObject) {
        
        
        viewcountry.isHidden=false
        self.view.endEditing(true)

        self.view.addSubview(viewcountry)
        
        
    }
    
    @IBAction func btnCreateAccountClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)

        if mainInstance.isTextfieldBlank(txtUsername)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter username")
        }
        else if mainInstance.isTextfieldBlank(txtfname)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter first name")
        }
        else if mainInstance.isTextfieldBlank(txtlname)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter last name")
        }
        else if txtEmail.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter Email address")
        }
        else if !mainInstance.isValidEmail(txtEmail.text!)
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter valid Email address")
        }
//        else if !isImage {
//             mainInstance.ShowAlertWithError("Error!", msg: "Please upload profile picture")
//        }
            
        else if txtpassword.text?.characters.count == 0
        {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter password")
        }
        else if(txtpassword.text?.characters.count<6){
            
            mainInstance.ShowAlertWithError("Error!", msg: "Password should not be less than 6 Characters")

            
        }
//        else if btnCheckMark.tag == 1
//        {
//            mainInstance.ShowAlertWithError("Error!", msg: "Please accept terms and conditions")
//        }
        else
        {
        
            if mainInstance.connected()
            {
                
                
                let usr = UserManager.userManager
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                let mgr = APIManager.apiManager
                let tokenId = mainInstance.dTokenString
                let dTok: String!
                if tokenId == nil {
                    dTok = "NoToken"
                } else {
                    dTok = tokenId
                }

                
                
                let phone = txtcode.text! + txtphonenum.text!
                
                let parameterss = NSMutableDictionary()
                parameterss.setValue(txtfname.text, forKey: "fname")
                parameterss.setValue(txtlname.text, forKey: "lname")
                parameterss.setValue(dTok, forKey: "devicetoken")
                parameterss.setValue(txtUsername.text, forKey: "uname")
                parameterss.setValue(txtEmail.text, forKey: "email")
                parameterss.setValue(phone, forKey: "phone")
                parameterss.setValue(txtpassword.text, forKey: "password")
                parameterss.setValue(objAppDelegate.strLat, forKey: "lat")
                parameterss.setValue(objAppDelegate.strLon, forKey: "lon")
                parameterss.setValue("iPhone", forKey: "devicetype")
                mgr.manager.responseSerializer.acceptableContentTypes=NSSet(array: ["text/html"]) as? Set<String>

                mgr.manager.post(APIManager.APIConstants.ScreamXOBaseUrl + APIManager.APIConstants.createUserEndpoint,
                    parameters: parameterss, constructingBodyWith: {(formData: AFMultipartFormData!) -> Void in
                        if(self.isImage == true){
                            formData.appendPart(withFileData: UIImageJPEGRepresentation( objAppDelegate.ResizeImage(self.imgProfile.image!, targetSize: CGSize(width: 500, height: 500))!, 0.8)!, name: "photo", fileName: "profilePictureFile.png", mimeType: "image/png")
                        }
                    },success: { operation ,responseObject in
                        print((responseObject! as AnyObject).description)
                        SVProgressHUD.dismiss()
                        let info = responseObject as! NSDictionary
                        print(info)
                        if(info.object(forKey: "status") as! String == "0"){
                            mainInstance.ShowAlertWithSucess("2KXO", msg: info.object(forKey: "msg") as! String as NSString)
                            //ShowAlertWithError("Error!", msg: info.object(forKey: "msg") as! String as NSString)
                        }else{
                            SVProgressHUD.dismiss()
                            self.createCustomer()
                            let usr = UserManager.userManager
                            if let uID: Int  = (info.value(forKey: "result")! as AnyObject).value(forKey: "uid") as? Int
                            {
                                usr.userId = "\(uID)"
                            }
                            let VC1=(self.storyboard?.instantiateViewController(withIdentifier: "VerficationVC"))! as UIViewController
                            self.navigationController?.pushViewController(VC1, animated: true)
                        }
                        UserDefaults.standard.set(true, forKey: "IsLogedIn")
                    }, failure: { operation,error in
                        print(error.localizedDescription)
                        SVProgressHUD.dismiss()
                        mainInstance.ShowAlertWithError("Error!", msg: constant.ktimeout as NSString)
                })
            }
            else
            {
                 mainInstance.ShowAlertWithError("No internet connection", msg: constant.kinternetMessage as NSString)
            }
        }
    }
    
    // MARK: - Create Customer ID
    
    func createCustomer() {
        let userManger = UserManager.userManager
        let parameterss = NSMutableDictionary()
        parameterss.setValue(userManger.userId, forKey: "uid")
        parameterss.setValue(userManger.emailAddress, forKey: "email")
        parameterss.setValue(userManger.username, forKey: "description")
        
        let apiMgr   = APIManager.apiManager//
        apiMgr.create_stripe_customerId(parameterss, successClosure: { (dic, result) -> Void in
            SVProgressHUD.dismiss()
            if result == APIResult.apiSuccess
            {
                print(dic ?? "")
                
            }  else if result == APIResult.apiError
            {
                print(dic ?? "")
                
                
            }
            else
            {
            }
        })
    }
    
    // MARK: - ImagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        imgProfile.image=info[UIImagePickerControllerEditedImage] as? UIImage
        imgProfile.layer.cornerRadius=5.0;
        imgProfile.layer.masksToBounds=true
        isImage = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker .dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    
    // MARK: - Textfeild Delgate method

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
  
        let cs: CharacterSet = CharacterSet(charactersIn: charactesAllowed).inverted
        
        let filtered: String = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
   
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtUsername {
            textField.resignFirstResponder()
            txtfname.becomeFirstResponder()
        } else if textField == txtfname {
            txtfname.resignFirstResponder()
            txtlname.becomeFirstResponder()
        }  else if textField == txtlname {
            txtlname.resignFirstResponder()
            txtEmail.becomeFirstResponder()
        }else if textField == txtEmail {
            txtEmail.resignFirstResponder()
            txtphonenum.becomeFirstResponder()
        }  else if textField == txtphonenum {
            txtphonenum.resignFirstResponder()
            txtpassword.becomeFirstResponder()
        }
        return true
    }

    // MARK: - CountryPhoneCodePicker Delegate
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String) {
        let newcode: String!
        newcode = phoneCode
        txtcode.text = newcode
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
