//
//  ViewController.swift

//
//  Created by Khatib H. on 3/6/19.
//  //

import UIKit
import Firebase
import JHSpinner

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var viEmail: UIView!
    @IBOutlet weak var viPassword: UIView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnFacebookLogin: UIButton!
    @IBOutlet weak var btnInstagramLogin: UIButton!
    
    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    
    @IBOutlet weak var blackCover: UILabel!
    @IBOutlet weak var viTermsAgreement: UIView!
    @IBOutlet weak var viTermsAgreementInner: UIView!
    @IBOutlet weak var markDone: UILabel!
    @IBOutlet weak var lblTerms: UnderlinedLabel!
    @IBOutlet weak var lblPolicy: UnderlinedLabel!
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var isInstagramSignup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        viEmail.layer.masksToBounds = true
        viEmail.layer.cornerRadius = viEmail.frame.size.height/2
        viPassword.layer.masksToBounds = true
        viPassword.layer.cornerRadius = viPassword.frame.size.height/2
        
        btnLogin.layer.masksToBounds = true
        btnLogin.layer.cornerRadius = btnLogin.frame.size.height/2
        btnLogin.layer.borderColor = UIColor.white.cgColor
        btnLogin.layer.borderWidth = 1
        
        btnFacebookLogin.layer.masksToBounds = true
        btnFacebookLogin.layer.cornerRadius = btnFacebookLogin.frame.size.height/2
        btnFacebookLogin.layer.borderColor = ColorPalette.pkFacebook.cgColor
        btnFacebookLogin.layer.borderWidth = 1
        
        btnInstagramLogin.layer.masksToBounds = true
        btnInstagramLogin.layer.cornerRadius = btnInstagramLogin.frame.size.height/2
        btnInstagramLogin.layer.borderColor = ColorPalette.pkInstaPink.cgColor
        btnInstagramLogin.layer.borderWidth = 1
        
        btnSignUp.layer.masksToBounds = true
        btnSignUp.layer.cornerRadius = btnSignUp.frame.size.height/2
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onInstagramLoginSuccess(notification:)), name: NSNotification.Name(rawValue: "instaLoginSuccess"), object: nil)
        
        let tapBg = UITapGestureRecognizer(target: self, action:#selector(onTapBg(sender:)))
        self.view.addGestureRecognizer(tapBg)
        
        // Terms View Configuration
        self.viTermsAgreementInner.layer.masksToBounds = true
        self.viTermsAgreementInner.layer.cornerRadius = 8.0
        self.markDone.layer.masksToBounds = true
        self.markDone.layer.cornerRadius = self.markDone.frame.size.width / 2.0
        self.markDone.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.markDone.layer.borderWidth = 1.0
        self.btnAgree.layer.masksToBounds = true
        self.btnAgree.layer.cornerRadius = self.btnAgree.frame.size.height / 2.0
        self.btnAgree.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.btnAgree.layer.borderWidth = 1.0
        self.btnCancel.layer.masksToBounds = true
        self.btnCancel.layer.cornerRadius = self.btnCancel.frame.size.height / 2.0
        self.btnCancel.layer.borderColor = UIColor.lightGray.cgColor
        self.btnCancel.layer.borderWidth = 1.0
        
        self.lblTerms.text = "karKango Terms of Service"
        self.lblPolicy.text = "Privacy Policy"
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showForgotPassword" {
            let viCtrlForgotPassword = segue.destination as! PKForgotPasswordViewController
            viCtrlForgotPassword.email = self.tfEmail.text!
        }
        else if segue.identifier == "showSignUp" {
            let viCtrlSignUp = segue.destination as! PKSignUpViewController
            viCtrlSignUp.isSignupWithInstagram = self.isInstagramSignup
        }
        else if segue.identifier == "showInstagramAuth" {
            let viCtrlInstaAuth = segue.destination as! PKInstagramAuthViewController
            viCtrlInstaAuth.nInstaAuthMode = PKInstagramAuthMode.login
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.blackCover.isHidden = true
        self.getMakes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tfEmail.text = ""
        self.tfPassword.text = ""
        self.view.endEditing(true)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Own Methods
    
    func verifyEmail()
    {
        self.performSegue(withIdentifier: "showEmailVerification", sender: self.btnLogin)
    }
    
    func checkRememberLogin()
    {
        if ((Auth.auth().currentUser?.uid) != nil)
        {
            print(Auth.auth().currentUser?.uid)
            self.blackCover.isHidden = false
            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                spinner.dismiss()
                print(dataSnapshot)
                
                if dataSnapshot.children.allObjects.count > 1
                {
                    self.sharedManager.myUser.setUser(withDataSnapshot: dataSnapshot)
                    
                    if self.sharedManager.myUser.isInstagramLogin {
                        self.performSegue(withIdentifier: "showMainTabsFromLogin", sender: self.btnLogin)
                    }
                    else if Auth.auth().currentUser!.isEmailVerified {
                        self.performSegue(withIdentifier: "showMainTabsFromLogin", sender: self.btnLogin)
                    }
                    else {
                        try! Auth.auth().signOut()
                        self.blackCover.isHidden = true
                    }
                }
                else {
                    self.present(self.sharedManager.getAppAlert(withMsg: "This karKango account is not created properly, please use another one!"), animated: true, completion: nil)

                    try! Auth.auth().signOut()
                    self.blackCover.isHidden = true
                }
                
            }, withCancel: { (error) in
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
            })
        }
    }
    
    func getMakes()
    {
        self.sharedManager.arrVehicleMakes.removeAll()
        let spinner = JHSpinnerView.showOnView(self.view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("vehicle_makes").observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    self.sharedManager.arrVehicleMakes.append(snap.value as! String)
                }
            }
            
            self.sharedManager.arrCycleMakes.removeAll()
            dbRef.child("motorcycle_makes").observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshots {
                        self.sharedManager.arrCycleMakes.append(snap.value as! String)
                    }
                }
                
                self.sharedManager.arrAllMakes = self.sharedManager.arrVehicleMakes + self.sharedManager.arrCycleMakes
                spinner.dismiss()
                self.checkRememberLogin()
                
            }, withCancel: { (getUserInfoError) in
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
            })
            
        }, withCancel: { (getUserInfoError) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: getUserInfoError), animated: true, completion: nil)
        })
    }
    
    func performLogin()
    {
        if self.tfEmail.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.present(self.sharedManager.getAppAlert(withMsg: "Email is required."), animated: true, completion:nil)
            self.tfEmail.becomeFirstResponder()
            return
        }
        
        if self.tfPassword.text?.replacingOccurrences(of: " ", with: "") == "" {
            self.present(self.sharedManager.getAppAlert(withMsg: "Password is required."), animated: true, completion:nil)
            self.tfPassword.becomeFirstResponder()
            return
        }
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        Auth.auth().signIn(withEmail: self.tfEmail.text!, password: self.tfPassword.text!) { (authResult, error) in
            if error != nil{
                print(error)
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                let dbRef = Database.database().reference()
                
                if self.sharedManager.fcmToken != "" {
                    dbRef.child("user_data").child(Auth.auth().currentUser!.uid).child("fcm_token").setValue(self.sharedManager.fcmToken, withCompletionBlock: { (error, dataRef) in
                        spinner.dismiss()
                        self.updateLogInUserInfo()
                    })
                }
                else {
                    spinner.dismiss()
                    self.updateLogInUserInfo()
                }
                
            }
        }
    }
    
    func updateLogInUserInfo() {
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let dbRef = Database.database().reference()
        dbRef.child("user_data").child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (dataSnapshot) in
            
            spinner.dismiss()
            self.sharedManager.myUser.setUser(withDataSnapshot: dataSnapshot)
            
            if self.sharedManager.myUser.isInstagramLogin {
                self.present(self.sharedManager.getAppAlert(withMsg: "Invalid username/email or password!"), animated: true)
                return
            }
            else {
                if Auth.auth().currentUser!.isEmailVerified {
                    self.performSegue(withIdentifier: "showMainTabsFromLogin", sender: self.btnLogin)
                }
                else {
                    self.verifyEmail()
                }
            }
            
        }, withCancel: { (error) in
            spinner.dismiss()
            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
        })
    }
    
    func onPerformInstagramLogin() {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let email = String(format: "%@_%@@karkango.com", self.sharedManager.instaUserInfo["username"] as! String, self.sharedManager.instaUserInfo["id"] as! String)
        let password = self.sharedManager.instaUserInfo["id"] as! String + "karKango"
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            
            if error != nil{
                
                Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                    if error != nil{
                        print(error)
                        spinner.dismiss()
                        self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                    }
                    else {
                        let dbRef = Database.database().reference()
                        dbRef.child("user_data").child((authResult?.user.uid)!).observeSingleEvent(of: .value, with: { (dataSnapshot) in
                            
                            spinner.dismiss()
                            self.sharedManager.myUser.setUser(withDataSnapshot: dataSnapshot)
                            self.performSegue(withIdentifier: "showMainTabsFromLogin", sender: self.btnLogin)
                            
                            
                        }, withCancel: { (error) in
                            spinner.dismiss()
                            self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                        })
                        
                    }
                }
            }
            else {
                spinner.dismiss()
                self.isInstagramSignup = true
                self.performSegue(withIdentifier: "showSignUp", sender: self.btnInstagramLogin)
            }
        }
    }
    
    func showTermsView() {
        self.viTermsAgreement.alpha = 0
        self.viTermsAgreement.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viTermsAgreement.alpha = 1.0
        }) { (complete) in
        }
    }
    
    func hideTermsView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.viTermsAgreement.alpha = 0.0
            
        }) { (complete) in
            self.viTermsAgreement.isHidden = true
            
        }
    }
    
    // MARK: - Event Handlers
    @IBAction func onTermsAgree(_ sender: Any) {
        self.hideTermsView()
        self.performSegue(withIdentifier: "showSignUp", sender: self)

    }
    
    @IBAction func onTermsCancel(_ sender: Any) {
        self.hideTermsView()
    }
    
    @IBAction func onTerms(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Additional", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
        controller.browseURL = PKURL.termsOfService
        controller.pageTitle = "TERMS OF SERVICE"
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func onPolicy(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Additional", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PKWebViewController") as! PKWebViewController
        controller.browseURL = PKURL.privacyPolicy
        controller.pageTitle = "PRIVACY POLICY"
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func onInstagramLoginSuccess(notification:Notification) {
        //print(notification.userInfo)
        
        // Get Instagram User Info with Access Token
        let instaUserInfoUrl = URL(string: String(format: InstagramAPI.INSTAGRAM_USER_INFO_URL_FORMAT, self.sharedManager.instaAccessToken))!
        
        let task = URLSession.shared.dataTask(with: instaUserInfoUrl) {(data, response, error) in
            if(error != nil){
                print("Error \(String(describing: error))")
            }
            else {
                
                do {
                    
                    let fetchedDataDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
                    print(fetchedDataDictionary)
                    
                    let metaData = fetchedDataDictionary["meta"] as! [String: Any]
                    
                    if metaData["code"] as! Int != 200 //Error
                    {
                        print(metaData)
                    }
                    else { //Success
                        self.sharedManager.instaUserInfo = fetchedDataDictionary["data"] as! [String:Any]
                        
                        DispatchQueue.main.async {
                            self.onPerformInstagramLogin()
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
    
    @objc func onTapBg(sender: Any) {
        self.tfEmail.resignFirstResponder()
        self.tfPassword.resignFirstResponder()
    }
    
    @IBAction func onLogin(_ sender: Any) {
        self.performLogin()
    }
    @IBAction func onSignUp(_ sender: Any) {
        self.isInstagramSignup = false
        self.showTermsView()
        
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfEmail {
            self.tfPassword.becomeFirstResponder()
        }
        else if textField == self.tfPassword {
            textField.resignFirstResponder()
            self.performLogin()
        }
        return true
    }

}

