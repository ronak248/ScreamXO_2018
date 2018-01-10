//
//  EditProfile.swift
//  ScreamXO
//
//  Created by Parth ProblemStucks on 04/02/16.
//  Copyright © 2016 Ronak Barot. All rights reserved.
//

import UIKit
import AFNetworking

class EditProfile: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var imgPic: RoundImage!
    @IBOutlet weak var btnpic: RoundRectbtncir!
    @IBOutlet weak var txtcity: UITextField!
    @IBOutlet weak var txtjob: UITextField!
    @IBOutlet weak var txtschool: UITextField!
    @IBOutlet weak var txtlname: UITextField!
    @IBOutlet weak var txtfname: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet var txtUserName: UITextField!
    @IBOutlet weak var btnmaleRadio: UIButton!
    @IBOutlet weak var btnfemale: UIButton!
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."

    @IBOutlet weak var btnsame: UIButton!
    @IBOutlet weak var btnopposite: UIButton!
    @IBOutlet weak var btnunaviable: UIButton!
    @IBOutlet weak var btnaviable: UIButton!
    @IBOutlet weak var btnother: UIButton!
    @IBOutlet weak var txtHobby: UITextField!
    var statusList: [String] = ["Single", "Married","Complicate"]
    
    var picker:UIImagePickerController? = UIImagePickerController()
    var isImage :Bool!
    var strGender :String!
    var strstatus :String!
    var strpref :String!

    var strIsFirstTime :String!


    override func viewDidLoad() {
        
        self.isImage = false

        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        txtcity.delegate = self
        txtUserName.delegate = self
        txtfname.delegate = self
        txtlname.delegate = self
        email.delegate = self
        txtschool.delegate = self
        txtjob.delegate = self
        txtHobby.delegate = self
        if isImage == false
        {

        loadUserdata()
        }
        
        if strIsFirstTime == "1"
        {
        
        self.isImage = true
            btnBack.isHidden=true
        }
        else
        {
        btnBack.isHidden=false
        }

        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - custom button methods
    @IBAction func hideKeyboardClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func btnunavaibleClicked(_ sender: AnyObject) {
        
        strstatus="u"
        btnaviable.setImage(UIImage(named: "radiod"), for: UIControlState())
        btnunaviable.setImage(UIImage(named: "radioa"), for: UIControlState())
    }
    @IBAction func btnavaibleClicked(_ sender: AnyObject) {
        
        strstatus="a"
        btnaviable.setImage(UIImage(named: "radioa"), for: UIControlState())
        btnunaviable.setImage(UIImage(named: "radiod"), for: UIControlState())
        
    }
    
    @IBAction func btnsameCliked(_ sender: AnyObject) {
        
        strpref="s"
        btnsame.setImage(UIImage(named: "radioa"), for: UIControlState())
        btnopposite.setImage(UIImage(named: "radiod"), for: UIControlState())
        
    }
    @IBAction func btnoppositeClicked(_ sender: AnyObject) {
        
        strpref="o"
        btnsame.setImage(UIImage(named: "radiod"), for: UIControlState())
        btnopposite.setImage(UIImage(named: "radioa"), for: UIControlState())
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
        // Present the actionsheet
        let button = sender as! UIButton
        if (IS_IPAD)
        {
            
            alert.popoverPresentationController!.sourceRect = button.bounds;
            alert.popoverPresentationController!.sourceView = button;
            
        }
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func btnMaleClicked(_ sender: AnyObject) {
        
        
       
        strGender="m"
            btnmaleRadio.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnfemale.setImage(UIImage(named: "radiod"), for: UIControlState())
        btnother.setImage(UIImage(named: "radiod"), for: UIControlState())

        
        
    }

    @IBAction func btnFemaleClicked(_ sender: AnyObject) {
        
        strGender="f"

        
        btnother.setImage(UIImage(named: "radiod"), for: UIControlState())
            btnfemale.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnmaleRadio.setImage(UIImage(named: "radiod"), for: UIControlState())
        
        
        
        
    }
    @IBAction func btnotherClicked(_ sender: AnyObject) {
        
        
        strGender="o"
        btnother.setImage(UIImage(named: "radioa"), for: UIControlState())
        btnfemale.setImage(UIImage(named: "radiod"), for: UIControlState())
        btnmaleRadio.setImage(UIImage(named: "radiod"), for: UIControlState())
        
        
    }
       @IBAction func btnBackClicked(_ sender: AnyObject) {
        
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnupdateClicked(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if mainInstance.isTextfieldBlank(txtfname) {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter first name")
        } else if mainInstance.isTextfieldBlank(txtlname) {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter first name")
        } else if mainInstance.isTextfieldBlank(txtUserName) {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter username")
        } else if mainInstance.isTextfieldBlank(email) {
            mainInstance.ShowAlertWithError("Error!", msg: "Please enter email")
        } else if isValidEmail(testStr: email.text!) ==  false{
             mainInstance.ShowAlertWithError("Error!", msg: "Please enter valid email")
        }else if imgPic.image == nil {
             mainInstance.ShowAlertWithError("Error!", msg: "Please upload profile picture")
        }else {
            if mainInstance.connected() {
                
                let usr = UserManager.userManager
                SVProgressHUD.show(with: SVProgressHUDMaskType.clear)
                let mgr = APIManager.apiManager
                let parameterss = NSMutableDictionary()
                parameterss.setValue(txtfname.text, forKey: "fname")
                parameterss.setValue(txtlname.text, forKey: "lname")
                parameterss.setValue(txtUserName.text, forKey: "username")
                parameterss.setValue(email.text, forKey: "email")
                parameterss.setValue(usr.userId, forKey: "uid")
                parameterss.setValue(txtschool.text, forKey: "school")
                parameterss.setValue(txtcity.text, forKey: "city")
                parameterss.setValue(txtjob.text, forKey: "job")
                parameterss.setValue(txtHobby.text, forKey: "hobbies")
                parameterss.setValue(strGender, forKey: "gender")
                parameterss.setValue(strpref, forKey: "sexpreference")
                parameterss.setValue(strstatus, forKey: "realtionstatus")
                
                print(parameterss)
                
                
                mgr.manager.responseSerializer.acceptableContentTypes=NSSet(array: ["text/html"]) as? Set<String>
                
                
                if  ( isImage == true )
                {
                    
                    if let sessionStr:String = mgr.sessionToken
                    {
                        mgr.manager.requestSerializer.setValue(sessionStr, forHTTPHeaderField: "usertoken")
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
                    mgr.manager.post(APIManager.APIConstants.ScreamXOBaseUrl + APIManager.APIConstants.editProfileEndpoint,
                                     parameters: parameterss, constructingBodyWith: {(formData: AFMultipartFormData!) -> Void in
                                        if(self.isImage == true){
                                            formData.appendPart(withFileData: UIImageJPEGRepresentation( objAppDelegate.ResizeImage(self.imgPic.image!, targetSize: CGSize(width: 500, height: 500))!, 0.8)!, name: "photo", fileName: "profilePictureFile.png", mimeType: "image/png")
                                        }
                        },success: { (operation: URLSessionDataTask,responseObject: Any?) -> Void in
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
                                usr.firstname = self.txtfname.text
                                usr.lastname = self.txtlname.text
                                usr.emailAddress = self.email.text
                                usr.profileImage = ((info.value(forKey: "result")! as AnyObject).value(forKey: "photo") as? String)!
                                usr.setHobby = self.txtHobby.text
                                usr.school = self.txtschool.text
                                usr.job = self.txtjob.text
                                usr.setcityKey = self.txtcity.text
                                usr.setGenderKey=self.strGender
                                usr.setrelationshipstKey=self.strstatus
                                usr.setsexpref=self.strpref
                                
                                
                                
                                usr.firstname!.replaceSubrange(usr.firstname!.startIndex...usr.firstname!.startIndex, with: String(usr.firstname![usr.firstname!.startIndex]).capitalized)
                                
                                usr.lastname!.replaceSubrange(usr.lastname!.startIndex...usr.lastname!.startIndex, with: String(usr.lastname![usr.lastname!.startIndex]).capitalized)
                                
                                usr.fullName = usr.firstname! + " " + usr.lastname!
                                
                                self.createCustomer()
                                
                                if self.strIsFirstTime == "1"
                                {
                                    
                                    objAppDelegate.setViewAfterLogin()
                                    let mgrItm = ItemManager.itemManager
                                    if mgrItm.arrayCategories == nil {
                                        objAppDelegate.getCategoriesList()
                                    }
                                }
                                else
                                {
                                    
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                                
                                
                            }
                        },
                          failure: { (operation: URLSessionDataTask?,error: Error!) in
                            print(error.localizedDescription)
                            SVProgressHUD.dismiss()
                            mainInstance.ShowAlertWithError("Error!", msg: constant.ktimeout as NSString)
                            
                    })
                    
                }
                else
                {
                    
                    mgr.EditProfile(parameterss, successClosure: { (dic, result) -> Void in
                        SVProgressHUD.dismiss()
                        if result == APIResult.apiSuccess
                        {
                            
                            
                            print(dic)
                            usr.firstname = self.txtfname.text
                            usr.lastname = self.txtlname.text
                            usr.emailAddress = self.email.text
                            usr.setHobby = self.txtHobby.text
                            usr.school = self.txtschool.text
                            usr.job = self.txtjob.text
                            usr.setHobby = self.txtHobby.text
                            usr.setcityKey = self.txtcity.text
                            usr.setGenderKey=self.strGender
                            usr.setGenderKey=self.strGender
                            usr.setrelationshipstKey=self.strstatus
                            usr.setsexpref=self.strpref
                            usr.firstname!.replaceSubrange(usr.firstname!.startIndex...usr.firstname!.startIndex, with: String(usr.firstname![usr.firstname!.startIndex]).capitalized)
                            
                            usr.lastname!.replaceSubrange(usr.lastname!.startIndex...usr.lastname!.startIndex, with: String(usr.lastname![usr.lastname!.startIndex]).capitalized)
                            usr.username = self.txtUserName.text
                            
                            
                            usr.fullName = usr.firstname! + " " + usr.lastname!
                            mainInstance.ShowAlertWithSucess("ScreamXO", msg: dic!.value(forKey: "msg")! as! NSString)
                            SVProgressHUD.dismiss()
                            
                            if self.strIsFirstTime == "1"
                            {
                                
                                objAppDelegate.setViewAfterLogin()
                                let mgrItm = ItemManager.itemManager
                                if mgrItm.arrayCategories == nil {
                                    objAppDelegate.getCategoriesList()
                                }
                            }
                            else
                            {
                                
                                self.navigationController?.popViewController(animated: true)
                            }
                            
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
  
     // MARK: - Create Customer for Paymnet Getways
    
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
                print((dic?.value(forKey: "stripe_customer_id") as AnyObject))
                userManger.stripeCustomerId = (dic?.value(forKey: "stripe_customer_id") as AnyObject).value(forKey:"") as? String
                
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
        imgPic.image=info[UIImagePickerControllerEditedImage] as? UIImage
        imgPic.contentMode=UIViewContentMode.scaleAspectFill
        imgPic.layer.cornerRadius = imgPic.frame.size.height / 2
        imgPic.layer.masksToBounds = true
        isImage = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        picker .dismiss(animated: true, completion: nil)
        print("picker cancel.")
    }
    // MARK: - load userdata
    
    func loadUserdata()
    {
        let usr = UserManager.userManager
        txtfname.text=usr.firstname
        txtUserName.text = usr.username
        txtlname.text=usr.lastname
        email.text = usr.emailAddress
        txtHobby.text=usr.setHobby
        txtschool.text=usr.school
        txtjob.text=usr.job
        txtcity.text=usr.setcityKey

        if usr.setGenderKey == "m"||usr.setGenderKey == "M"
        {
            strGender="m"

            
            btnmaleRadio.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnfemale.setImage(UIImage(named: "radiod"), for: UIControlState())
            btnother.setImage(UIImage(named: "radiod"), for: UIControlState())



        }
        else if usr.setGenderKey == "f"||usr.setGenderKey == "F"
        {
        
            strGender="f"
            btnother.setImage(UIImage(named: "radiod"), for: UIControlState())
            btnfemale.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnmaleRadio.setImage(UIImage(named: "radiod"), for: UIControlState())
        
        }
        else
        {
        
        
            strGender="o"
            btnother.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnfemale.setImage(UIImage(named: "radiod"), for: UIControlState())
            btnmaleRadio.setImage(UIImage(named: "radiod"), for: UIControlState())
            
        
        }
        
        if usr.setrelationshipstKey == "a"||usr.setrelationshipstKey == "A"
        {
            strstatus="a"
            
            
            btnaviable.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnunaviable.setImage(UIImage(named: "radiod"), for: UIControlState())
            
            
            
        }
       
        else
        {
            
            
            strstatus="u"
            
            
            btnunaviable.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnaviable.setImage(UIImage(named: "radiod"), for: UIControlState())
            
            
        }
        
        if usr.setsexpref == "o"||usr.setsexpref == "O"
        {
            strpref="o"
            
            
            btnopposite.setImage(UIImage(named: "radioa"), for: UIControlState())
            btnsame.setImage(UIImage(named: "radiod"), for: UIControlState())
            
            
            
        }
            
        else
        {
            
            
            strpref="s"
            
            
            btnopposite.setImage(UIImage(named: "radiod"), for: UIControlState())
            btnsame.setImage(UIImage(named: "radioa"), for: UIControlState())
        }
        
        
       
        imgPic!.sd_setImageWithPreviousCachedImage(with: URL(string: usr.profileImage!), placeholderImage: UIImage(named: "profile"), options: SDWebImageOptions.refreshCached, progress: { (a, b , url) -> Void in
            }, completed: { (img, error, type, url) -> Void in
        })
        
        imgPic.contentMode=UIViewContentMode.scaleAspectFill
        imgPic.layer.cornerRadius = imgPic.frame.size.height / 2
        imgPic.layer.masksToBounds = true

        
    
    }

    // MARK: - Textfeild Delgate method
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        
        if (textField == txtcity || textField == txtHobby || textField == email)
        {
            
            return true
        
        
        }
        
        let cs: CharacterSet = CharacterSet(charactersIn: charactesAllowed).inverted
        
        
        let filtered: String = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
        
        
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtfname {
            textField.resignFirstResponder()
            txtlname.becomeFirstResponder()
        } else if textField == txtlname {
            txtlname.resignFirstResponder()
            txtUserName.becomeFirstResponder()
          
        }  else if textField == txtUserName {
            txtUserName.resignFirstResponder()
            email.becomeFirstResponder()
            
        } else if textField == email {
            email.resignFirstResponder()
            txtschool.becomeFirstResponder()
            
        }else if textField == txtschool {
            txtschool.resignFirstResponder()
            txtjob.becomeFirstResponder()
            
        } else if textField == txtjob {
            txtjob.resignFirstResponder()
            txtcity.becomeFirstResponder()
            
        } else if textField == txtcity {
            txtcity.resignFirstResponder()
            txtHobby.becomeFirstResponder()
            
        } else if textField == txtHobby {
            txtHobby.resignFirstResponder()
            textField.resignFirstResponder()
        }
        
        
        return true
    }
    
    
}
