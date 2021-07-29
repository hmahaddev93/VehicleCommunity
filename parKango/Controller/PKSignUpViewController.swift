//
//  PKSignUpViewController.swift

//
//  Created by Khatib H. on 3/8/19.
//  //

import UIKit
import Firebase
import JHSpinner
import ActionSheetPicker_3_0

class PKSignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrlViContainer: UIScrollView!
    @IBOutlet weak var viPage1: UIView!
    @IBOutlet weak var viPage2: UIView!
    @IBOutlet weak var viPage3: UIView!
    
    // Page 1
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnAlien: UIButton!

    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblAlien: UILabel!
    
    @IBOutlet weak var btnTypeCar: UIButton!
    @IBOutlet weak var btnTypeTruck: UIButton!
    @IBOutlet weak var btnTypeCycle: UIButton!
    @IBOutlet weak var btnTypeSpectator: UIButton!
    
    @IBOutlet weak var lblTypeCar: UILabel!
    @IBOutlet weak var lblTypeTruck: UILabel!
    @IBOutlet weak var lblTypeCycle: UILabel!
    @IBOutlet weak var lblTypeSpectator: UILabel!
    
    @IBOutlet weak var btnPage1Next: UIButton!
    
    // Page 2
    @IBOutlet weak var tfMake: TextField!
    @IBOutlet weak var tfModel: TextField!
    @IBOutlet weak var tfZipcode: TextField!
    @IBOutlet weak var tfLastfour: TextField!
    @IBOutlet weak var tfHashtag: TextField!
    @IBOutlet weak var btnPage2Next: UIButton!
    @IBOutlet weak var viMakeTF: UIView!
    @IBOutlet weak var viModelTF: UIView!
    @IBOutlet weak var viZipCodeTF: UIView!
    @IBOutlet weak var viLFLPTF: UIView!
    @IBOutlet weak var viHashtagTF: UIView!
    
    // Page 3
    @IBOutlet weak var btnUserPhoto: UIButton!
    @IBOutlet weak var imgViUserPhoto: UIImageView!
    @IBOutlet weak var btnAddPhotoTitle: UIButton!
    
    @IBOutlet weak var tfUsername: TextField!
    @IBOutlet weak var tfEmail: TextField!
    @IBOutlet weak var tfPassword: TextField!
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnAddSocial: UIButton!
    
    var tfFocusedInPage2 = UITextField()
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var isPhotoTaken:Bool = false
    var initMakeIdx = 0
    var isSignupWithInstagram = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        btnMale.layer.masksToBounds = true
        btnMale.layer.cornerRadius = btnMale.frame.size.width / 2.0
        btnMale.layer.borderColor = UIColor.black.cgColor
        btnMale.layer.borderWidth = 2.0
        
        btnFemale.layer.masksToBounds = true
        btnFemale.layer.cornerRadius = btnFemale.frame.size.width / 2.0
        btnFemale.layer.borderColor = UIColor.black.cgColor
        btnFemale.layer.borderWidth = 2.0
        
        btnAlien.layer.masksToBounds = true
        btnAlien.layer.cornerRadius = btnAlien.frame.size.width / 2.0
        btnAlien.layer.borderColor = UIColor.black.cgColor
        btnAlien.layer.borderWidth = 2.0
        
        btnTypeCar.layer.masksToBounds = true
        btnTypeCar.layer.cornerRadius = btnTypeCar.frame.size.width / 2.0
        btnTypeCar.layer.borderColor = UIColor.black.cgColor
        btnTypeCar.layer.borderWidth = 2.0
        
        btnTypeTruck.layer.masksToBounds = true
        btnTypeTruck.layer.cornerRadius = btnTypeTruck.frame.size.width / 2.0
        btnTypeTruck.layer.borderColor = UIColor.black.cgColor
        btnTypeTruck.layer.borderWidth = 2.0
        
        btnTypeCycle.layer.masksToBounds = true
        btnTypeCycle.layer.cornerRadius = btnTypeCycle.frame.size.width / 2.0
        btnTypeCycle.layer.borderColor = UIColor.black.cgColor
        btnTypeCycle.layer.borderWidth = 2.0
        
        btnTypeSpectator.layer.masksToBounds = true
        btnTypeSpectator.layer.cornerRadius = btnTypeSpectator.frame.size.width / 2.0
        btnTypeSpectator.layer.borderColor = UIColor.black.cgColor
        btnTypeSpectator.layer.borderWidth = 2.0
        
        btnPage1Next.layer.masksToBounds = true
        btnPage1Next.layer.cornerRadius = btnPage1Next.frame.size.height / 2.0
        
        tfMake.layer.masksToBounds = true
        tfMake.layer.cornerRadius = tfMake.frame.size.height / 2.0
        
        tfModel.layer.masksToBounds = true
        tfModel.layer.cornerRadius = tfModel.frame.size.height / 2.0
        
        tfZipcode.layer.masksToBounds = true
        tfZipcode.layer.cornerRadius = tfZipcode.frame.size.height / 2.0
        
        tfLastfour.layer.masksToBounds = true
        tfLastfour.layer.cornerRadius = tfLastfour.frame.size.height / 2.0
        
        tfHashtag.layer.masksToBounds = true
        tfHashtag.layer.cornerRadius = tfHashtag.frame.size.height / 2.0
        
        btnPage2Next.layer.masksToBounds = true
        btnPage2Next.layer.cornerRadius = btnPage2Next.frame.size.height / 2.0
        
        imgViUserPhoto.layer.masksToBounds = true
        imgViUserPhoto.layer.cornerRadius = imgViUserPhoto.frame.size.height / 2.0
        imgViUserPhoto.layer.borderWidth = 1.0
        imgViUserPhoto.layer.borderColor = UIColor.black.cgColor
        
        tfUsername.layer.masksToBounds = true
        tfUsername.layer.cornerRadius = tfUsername.frame.size.height / 2.0
        
        tfEmail.layer.masksToBounds = true
        tfEmail.layer.cornerRadius = tfEmail.frame.size.height / 2.0
        
        tfPassword.layer.masksToBounds = true
        tfPassword.layer.cornerRadius = tfPassword.frame.size.height / 2.0
        
        btnRegister.layer.masksToBounds = true
        btnRegister.layer.cornerRadius = btnRegister.frame.size.height / 2.0
        
        btnAddSocial.layer.masksToBounds = true
        btnAddSocial.layer.cornerRadius = btnAddSocial.frame.size.height / 2.0
        btnAddSocial.layer.borderWidth = 1.0
        btnAddSocial.layer.borderColor = UIColor.black.cgColor
        
        let tapBg2 = UITapGestureRecognizer(target: self, action:#selector(onTapBg2(sender:)))
        self.viPage2.addGestureRecognizer(tapBg2)
        
        let tapBg3 = UITapGestureRecognizer(target: self, action:#selector(onTapBg3(sender:)))
        self.viPage3.addGestureRecognizer(tapBg3)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.title = "SIGN UP"
        scrlViContainer.frame = CGRect(x: 0, y: 64, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64)
        scrlViContainer.contentSize = CGSize(width: SCREEN_WIDTH * 3 , height: scrlViContainer.frame.size.height)
        viPage1.frame = CGRect(x: 0, y: 20, width: SCREEN_WIDTH, height: scrlViContainer.frame.size.height-20)
        viPage2.frame = CGRect(x: SCREEN_WIDTH, y: 20, width: SCREEN_WIDTH, height: scrlViContainer.frame.size.height - 20)
        viPage3.frame = CGRect(x: SCREEN_WIDTH * 2, y: 20, width: SCREEN_WIDTH, height: scrlViContainer.frame.size.height - 20)
        
        if self.isSignupWithInstagram {
            self.tfUsername.isEnabled = false
            self.tfUsername.backgroundColor = UIColor.lightGray
            
            self.tfEmail.isEnabled = false
            self.tfEmail.backgroundColor = UIColor.lightGray

            self.tfPassword.isEnabled = false
            self.tfPassword.backgroundColor = UIColor.lightGray

            self.sharedManager.dicRegisterValues["is_instagram_login"] = true
            self.sharedManager.dicRegisterValues["username"] = self.sharedManager.instaUserInfo["username"] as! String
            self.sharedManager.dicRegisterValues["email"] = String(format: "%@_%@@karkango.com", self.sharedManager.instaUserInfo["username"] as! String, self.sharedManager.instaUserInfo["id"] as! String)
            
            self.tfUsername.text = (self.sharedManager.instaUserInfo["username"] as! String)
            self.tfEmail.placeholder = "Can't get email from Instagram"
            self.tfEmail.text = ""
            self.tfPassword.text = self.sharedManager.instaUserInfo["id"] as! String + "karKango"
            self.imgViUserPhoto.sd_setImage(with: URL(string: self.sharedManager.instaUserInfo["profile_picture"] as! String), placeholderImage:UIImage(named: "icon_car_h"),  completed: nil)


        }
        else {
            self.tfUsername.isEnabled = true
            self.tfUsername.backgroundColor = ColorPalette.pkLightGray
            
            self.tfEmail.isEnabled = true
            self.tfEmail.backgroundColor = ColorPalette.pkLightGray
            
            self.tfPassword.isEnabled = true
            self.tfPassword.backgroundColor = ColorPalette.pkLightGray
    
            self.sharedManager.dicRegisterValues["is_instagram_login"] = false
        }
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.tfFocusedInPage2 = textField
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfMake {
            self.tfModel.becomeFirstResponder()
        }
        else if textField == self.tfModel {
            self.tfZipcode.becomeFirstResponder()
        }
        else if textField == self.tfHashtag {
            self.validateZipCode()
        }
        else if textField == self.tfUsername {
            self.tfEmail.becomeFirstResponder()
        }
        else if textField == self.tfEmail {
            self.tfPassword.becomeFirstResponder()
        }
        else if textField == self.tfPassword {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: - Own Methods
    
    func hidePage2Keyboards()
    {
        self.tfMake.resignFirstResponder()
        self.tfModel.resignFirstResponder()
        self.tfZipcode.resignFirstResponder()
        self.tfLastfour.resignFirstResponder()
        self.tfHashtag.resignFirstResponder()
    }
    
    func hidePage3Keyboards()
    {
        self.tfUsername.resignFirstResponder()
        self.tfEmail.resignFirstResponder()
        self.tfPassword.resignFirstResponder()
    }
    
    func validateAndNextForPage2()
    {
        if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.spectator {
            
            self.hidePage2Keyboards()
            self.sharedManager.dicRegisterValues["zipcode"] = self.tfZipcode.text
            
            self.scrlViContainer.scrollRectToVisible(CGRect(x: SCREEN_WIDTH * 2, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), animated: true)
            
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            
            return
        }
        
        if self.tfMake.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please enter your Make."), animated: true) {
                self.hidePage2Keyboards()
            }
            return
        }
        
        if self.tfModel.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please enter your Model."), animated: true) {
                self.hidePage2Keyboards()
                self.tfModel.becomeFirstResponder()
                
            }
            return
        }
        
        if self.tfLastfour.text!.count > 4 {
            self.present(self.sharedManager.getAppAlert(withMsg: "4 characters max for LFLP!"), animated: true) {
                self.hidePage2Keyboards()
                self.tfLastfour.becomeFirstResponder()
            }
            return
        }
        
        if self.tfHashtag.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please enter your Hashtag."), animated: true) {
                self.hidePage2Keyboards()
                self.tfHashtag.becomeFirstResponder()
            }
            return
        }
        else if self.tfHashtag.text!.count > 15 {
            self.present(self.sharedManager.getAppAlert(withMsg: "15 characters max for #hashtag!"), animated: true) {
                self.hidePage2Keyboards()
                self.tfHashtag.becomeFirstResponder()
            }
            return
        }
        
        self.hidePage2Keyboards()
        self.sharedManager.dicRegisterValues["v_make"] = self.tfMake.text
        self.sharedManager.dicRegisterValues["v_model"] = self.tfModel.text
        self.sharedManager.dicRegisterValues["zipcode"] = self.tfZipcode.text
        self.sharedManager.dicRegisterValues["LFLP"] = self.tfLastfour.text
        self.sharedManager.dicRegisterValues["hashtag"] = self.tfHashtag.text
        self.sharedManager.dicRegisterValues["social_links"] = [String]()
        
        self.scrlViContainer.scrollRectToVisible(CGRect(x: SCREEN_WIDTH * 2, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), animated: true)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func validateAndSaveValue()
    {
        if !self.isPhotoTaken {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please take your best photo."), animated: true) {
                self.hidePage3Keyboards()
            }
            return
        }
        
        if self.tfUsername.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Username is required. Please enter your unique username."), animated: true) {
                self.hidePage3Keyboards()
                self.tfUsername.becomeFirstResponder()
            }
            return
        }
        else if self.tfUsername.text!.count > 15 {
            self.present(self.sharedManager.getAppAlert(withMsg: "15 characters max for @username!"), animated: true) {
                self.hidePage3Keyboards()
                self.tfUsername.becomeFirstResponder()
            }
            return
        }
        else if self.tfEmail.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Email is required. Please enter your email."), animated: true) {
                self.hidePage3Keyboards()
                self.tfEmail.becomeFirstResponder()
            }
            return
        }
        else if !self.sharedManager.isValidEmail(testStr: self.tfEmail.text!)
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Invalid email address. Please enter a correct email."), animated: true) {
                self.hidePage3Keyboards()
                self.tfEmail.becomeFirstResponder()
            }
            return
        }
        else if self.tfPassword.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Password is required. Please enter your password."), animated: true) {
                self.hidePage3Keyboards()
                self.tfPassword.becomeFirstResponder()
            }
            return
        }
        
        self.hidePage3Keyboards()
        self.sharedManager.dicRegisterValues["username"] = self.tfUsername.text
        self.sharedManager.dicRegisterValues["email"] = self.tfEmail.text
        
        self.registerUser()
    }
    
    func validateZipCode()
    {
        
        if self.tfZipcode.text?.trimmingCharacters(in: .whitespaces) == ""
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please enter your Zip Code."), animated: true) {
                self.hidePage2Keyboards()
                self.tfZipcode.becomeFirstResponder()
            }
            return
        }
        
        if !self.sharedManager.isValidUSZipCode(postalCode: self.tfZipcode.text!)
        {
            self.present(self.sharedManager.getAppAlert(withMsg: "Invalid zipcode. Please enter your correct zipcode."), animated: true) {
                self.hidePage2Keyboards()
                self.tfZipcode.becomeFirstResponder()
            }
            return
        }
        
        let zipCodeInfoUrl = URL(string: String(format: ZipCodeAPI.getLocationInfoURLFormat, ZipCodeAPI.apiKey, tfZipcode.text!))!
        
        let task = URLSession.shared.dataTask(with: zipCodeInfoUrl) {(data, response, error) in
            if(error != nil){
                print("Error \(String(describing: error))")
            }
            else {
                
                do {
                    
                    let fetchedDataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    
                    if let errorMessage = fetchedDataDictionary?.object(forKey: "error_msg")
                    {
                        self.present(self.sharedManager.getAppAlert(withMsg: errorMessage as! String), animated: true, completion: {
                            self.hidePage2Keyboards()
                            self.tfZipcode.becomeFirstResponder()
                        })
                        return
                    }
                    else {
                        self.sharedManager.dicRegisterValues["city"] = fetchedDataDictionary?.object(forKey: "city") as! String
                        self.sharedManager.dicRegisterValues["state"] = fetchedDataDictionary?.object(forKey: "state") as! String
                        self.sharedManager.dicRegisterValues["latitude"] = fetchedDataDictionary?.object(forKey: "lat")
                        self.sharedManager.dicRegisterValues["longitude"] = fetchedDataDictionary?.object(forKey: "lng")

                        DispatchQueue.main.async {
                            self.validateAndNextForPage2()
                        }
                        
                    }
                    
                }
                catch let error as NSError {
                    print(error.debugDescription)
                }
            }
        }
        task.resume()
    }
    
    func uploadPhoto(image:UIImage)
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:"PHOTO")
        self.view.addSubview(spinner)
        
        let storageRef = Storage.storage().reference()
        let imageData = image.jpegData(compressionQuality: 0.8)
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("user_images/\(uuid).jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                
            } else {
                spinner.dismiss()
                imageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    var arrPhotos  = [String]()
                    arrPhotos.append(downloadURL.absoluteString)
                    self.sharedManager.dicRegisterValues["photos"] = arrPhotos
                    self.updateUserData()
                }
                
            }
        }
    }
    
    func updateUserData()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:"DATA")
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        self.sharedManager.dicRegisterValues["uid"] = Auth.auth().currentUser?.uid
        if self.sharedManager.fcmToken != "" {
            self.sharedManager.dicRegisterValues["fcm_token"] = self.sharedManager.fcmToken
        }
        
        dbRef.child("user_data").child(self.sharedManager.dicRegisterValues["uid"] as! String).updateChildValues(self.sharedManager.dicRegisterValues, withCompletionBlock: { (error, dataRef) in
            
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.sharedManager.myUser.setUser(withUserDataDic: self.sharedManager.dicRegisterValues)
                
                if self.isSignupWithInstagram {
                    self.performSegue(withIdentifier: "showMainTabs", sender: self.btnRegister)
                }
                else {
                    self.verifyEmail()
                }
            }
            
        })
    }
    
    func verifyEmail()
    {
        if Auth.auth().currentUser!.isEmailVerified {
            self.performSegue(withIdentifier: "showMainTabs", sender: self.btnRegister)
        }
        else {
            self.performSegue(withIdentifier: "showSignUpEmailVerification", sender: self.btnRegister)
        }
    }
    
    /*func registerMakeIfNew()
    {
        var arrMakes = [String]()
        let spinner = JHSpinnerView.showOnView(self.view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("vehicle_makes").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    arrMakes.append(snap.value as! String)
                }
            }
            
            var isNewMake = true
            for make in arrMakes
            {
                if make.lowercased() == self.sharedManager.myUser.vehicleMake?.lowercased() {
                    isNewMake = false
                    break
                }
            }
            
            if isNewMake {
                dbRef.child("vehicle_makes").childByAutoId().setValue(self.sharedManager.myUser.vehicleMake, withCompletionBlock: { (error, dbRef) in
                    spinner.dismiss()
                    
                    self.performSegue(withIdentifier: "showMainTabs", sender: self.btnRegister)
                })
            }
            else {
                spinner.dismiss()
                self.performSegue(withIdentifier: "showMainTabs", sender: self.btnRegister)
            }
            
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
    }*/
    
    func registerUser() {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:"UPDATING")
        self.view.addSubview(spinner)
        
        let email = self.sharedManager.dicRegisterValues["email"] as! String
        let password = self.tfPassword.text
        Auth.auth().createUser(withEmail: email, password: password!) { (authResult, error) in
            
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                spinner.dismiss()
                self.uploadPhoto(image: self.imgViUserPhoto.image!)
                
            }
        }
    }
    
    func continueWithInstagram() {
        self.uploadPhoto(image: self.imgViUserPhoto.image!)
    }
    
    // MARK: - Event Handlers
    
    @objc func onTapBg2(sender: Any) {
        self.hidePage2Keyboards()
    }
    
    @objc func onTapBg3(sender: Any) {
        self.hidePage3Keyboards()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if self.tfFocusedInPage2 == self.tfHashtag {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBAction func onGenderMaleSelect(_ sender: Any) {
        btnMale.layer.borderColor = ColorPalette.pkRed.cgColor
        lblMale.textColor = ColorPalette.pkRed
        
        btnFemale.layer.borderColor = UIColor.black.cgColor
        lblFemale.textColor = .black
        
        btnAlien.layer.borderColor = UIColor.black.cgColor
        lblAlien.textColor = .black
        
        self.sharedManager.dicRegisterValues["gender"] = PKGender.male

    }
    
    @IBAction func onGenderFemaleSelect(_ sender: Any) {
        btnFemale.layer.borderColor = ColorPalette.pkRed.cgColor
        lblFemale.textColor = ColorPalette.pkRed
        
        btnMale.layer.borderColor = UIColor.black.cgColor
        lblMale.textColor = .black
        
        btnAlien.layer.borderColor = UIColor.black.cgColor
        lblAlien.textColor = .black
        
        self.sharedManager.dicRegisterValues["gender"] = PKGender.female

    }
    
    @IBAction func onGenderAlienSelect(_ sender: Any) {
        btnAlien.layer.borderColor = ColorPalette.pkRed.cgColor
        lblAlien.textColor = ColorPalette.pkRed
        
        btnFemale.layer.borderColor = UIColor.black.cgColor
        lblFemale.textColor = .black
        
        btnMale.layer.borderColor = UIColor.black.cgColor
        lblMale.textColor = .black
        
        self.sharedManager.dicRegisterValues["gender"] = PKGender.neutral
    }
    
    @IBAction func onTypeCarSelect(_ sender: Any) {
        
        btnTypeCar.backgroundColor = ColorPalette.pkGreen
        lblTypeCar.textColor = ColorPalette.pkGreen
        
        btnTypeTruck.backgroundColor = .clear
        lblTypeTruck.textColor = .black
        
        btnTypeCycle.backgroundColor = .clear
        lblTypeCycle.textColor = .black
        
        btnTypeSpectator.backgroundColor = .clear
        lblTypeSpectator.textColor = .black
        
        self.sharedManager.dicRegisterValues["v_type"] = PKVehicleType.car
    }
    
    @IBAction func onTypeTruckSelect(_ sender: Any) {
        
        btnTypeCar.backgroundColor = .clear
        lblTypeCar.textColor = .black
        
        btnTypeTruck.backgroundColor = ColorPalette.pkGreen
        lblTypeTruck.textColor = ColorPalette.pkGreen
        
        btnTypeCycle.backgroundColor = .clear
        lblTypeCycle.textColor = .black
        
        btnTypeSpectator.backgroundColor = .clear
        lblTypeSpectator.textColor = .black
        
        self.sharedManager.dicRegisterValues["v_type"] = PKVehicleType.truck

    }
    
    @IBAction func onTypeCycleSelect(_ sender: Any) {
        
        btnTypeCar.backgroundColor = .clear
        lblTypeCar.textColor = .black
        
        btnTypeTruck.backgroundColor = .clear
        lblTypeTruck.textColor = .black
        
        btnTypeCycle.backgroundColor = ColorPalette.pkGreen
        lblTypeCycle.textColor = ColorPalette.pkGreen
        
        btnTypeSpectator.backgroundColor = .clear
        lblTypeSpectator.textColor = .black
        
        self.sharedManager.dicRegisterValues["v_type"] = PKVehicleType.motorcycle
    }
    
    @IBAction func onTypeSpectatorSelect(_ sender: Any) {
        
        btnTypeCar.backgroundColor = .clear
        lblTypeCar.textColor = .black
        
        btnTypeTruck.backgroundColor = .clear
        lblTypeTruck.textColor = .black
        
        btnTypeCycle.backgroundColor = .clear
        lblTypeCycle.textColor = .black
        
        btnTypeSpectator.backgroundColor = ColorPalette.pkGreen
        lblTypeSpectator.textColor = ColorPalette.pkGreen
        
        self.sharedManager.dicRegisterValues["v_type"] = PKVehicleType.spectator
    }
    
    @IBAction func onSelectMake(_ sender: Any) {
        var arrMakes = [String]()
        if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.motorcycle {
            arrMakes = self.sharedManager.arrCycleMakes
        }
        else {
            arrMakes = self.sharedManager.arrVehicleMakes
        }
        
        ActionSheetStringPicker.show(withTitle: "Select a Make", rows: arrMakes, initialSelection: self.initMakeIdx, doneBlock: { (picker, selectedIdx, selectedValue) in
            self.initMakeIdx = selectedIdx
            self.tfMake.text = (selectedValue as! String)
            
        }, cancel: { (picker) in
            
        }, origin: sender)
    }
    
    @IBAction func onPage1Next(_ sender: Any) {
        
        if self.sharedManager.dicRegisterValues["gender"] as! Int == PKGender.none {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please select your gender."), animated: true)
            return
        }
        
        if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.none {
            self.present(self.sharedManager.getAppAlert(withMsg: "Please select what you drive."), animated: true)
            return
        }
        
        if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.spectator {
            
            self.imgViUserPhoto.image = UIImage(named: "icon_spectator_h")
            self.btnAddPhotoTitle.setTitle("ADD YOUR PHOTO", for: .normal)
            
            self.viMakeTF.isHidden = true
            self.viModelTF.isHidden = true
            self.viLFLPTF.isHidden = true
            self.viHashtagTF.isHidden = true
            self.viZipCodeTF.frame = CGRect(x: self.viZipCodeTF.frame.origin.x, y: 20, width: self.viZipCodeTF.frame.size.width, height: self.viZipCodeTF.frame.size.height)
        }
        else {
            
            self.viMakeTF.isHidden = false
            self.viModelTF.isHidden = false
            self.viLFLPTF.isHidden = false
            self.viHashtagTF.isHidden = false
            self.viZipCodeTF.frame = CGRect(x: self.viZipCodeTF.frame.origin.x, y: 200, width: self.viZipCodeTF.frame.size.width, height: self.viZipCodeTF.frame.size.height)

            if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.car {
                
                self.imgViUserPhoto.image = UIImage(named: "icon_car_h")
                self.btnAddPhotoTitle.setTitle("ADD BEST PHOTO OF YOUR CAR", for: .normal)
            }
            else if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.truck {
                
                self.imgViUserPhoto.image = UIImage(named: "icon_truck_h2")
                self.btnAddPhotoTitle.setTitle("ADD BEST PHOTO OF YOUR TRUCK", for: .normal)
            }
            else if self.sharedManager.dicRegisterValues["v_type"] as! Int == PKVehicleType.motorcycle {
                
                self.imgViUserPhoto.image = UIImage(named: "icon_motorcycle_h")
                self.btnAddPhotoTitle.setTitle("ADD BEST MOTORC®YCLE PHOTO", for: .normal)
            }
            
        }
        
        self.scrlViContainer.scrollRectToVisible(CGRect(x: SCREEN_WIDTH, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT - 64), animated: true)

        
    }
    
    @IBAction func onPage2Next(_ sender: Any) {
        self.validateZipCode()
    }
    
    @IBAction func onRegister(_ sender: Any) {
        if self.isSignupWithInstagram {
            self.continueWithInstagram()
        }
        else {
            self.validateAndSaveValue()
        }
        
    }
    
    @IBAction func onTakePhoto(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let actionSheet = UIAlertController(title: "Pick a photo from", message: nil, preferredStyle: .actionSheet)
        let actionCameraRoll = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        
        let actionCamera = UIAlertAction(title: "Camera", style: .default) { (_) in
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: {
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(actionCameraRoll)
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func onAddSocial(_ sender: Any) {
        let viCtrlAddSocial = UIStoryboard(name: "Additional", bundle: nil).instantiateViewController(withIdentifier: "PKAddSocialViewController") as! PKAddSocialViewController
        viCtrlAddSocial.nAddSocialMode = PKAddSocialLinkMode.fromSignUp
        
        self.present(viCtrlAddSocial, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) != nil
        {
            self.imgViUserPhoto.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
            self.isPhotoTaken = true
            
        }
    }
}
