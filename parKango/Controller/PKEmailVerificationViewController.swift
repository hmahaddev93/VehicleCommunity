//
//  PKEmailVerificationViewController.swift

//
//  Created by Khatib H. on 4/26/19.
//  //

import UIKit
import Firebase
import JHSpinner

class PKEmailVerificationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tfEmail: TextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lblMsg: UILabel!
    
    @IBOutlet weak var viPwdInput: UIView!
    @IBOutlet weak var tfPwd: TextField!
    @IBOutlet weak var btnPwdOk: UIButton!
    @IBOutlet weak var btnPwdCancel: UIButton!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var isEmailEditable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "VERIFY YOUR EMAIL"
        
        self.btnSend.layer.masksToBounds = true
        self.btnSend.layer.cornerRadius = self.btnSend.frame.size.height / 2.0
        
        self.tfEmail.layer.masksToBounds = true
        self.tfEmail.layer.cornerRadius = self.tfEmail.frame.size.height / 2.0
        self.tfEmail.layer.borderColor = ColorPalette.pkLightGray.cgColor
        self.tfEmail.layer.borderWidth = 1.0
        
        self.viPwdInput.layer.masksToBounds = true
        self.viPwdInput.layer.cornerRadius = 6.0
        self.viPwdInput.layer.borderColor = UIColor.lightGray.cgColor
        self.viPwdInput.layer.borderWidth = 1.0
        
        self.btnPwdOk.layer.masksToBounds = true
        self.btnPwdOk.layer.cornerRadius = self.btnPwdOk.frame.size.height / 2.0
        
        self.btnPwdCancel.layer.masksToBounds = true
        self.btnPwdCancel.layer.cornerRadius = self.btnPwdCancel.frame.size.height / 2.0
        self.btnPwdCancel.layer.borderWidth = 1.0
        self.btnPwdCancel.layer.borderColor = ColorPalette.pkGreen.cgColor
        
        self.tfPwd.layer.masksToBounds = true
        self.tfPwd.layer.cornerRadius = self.tfPwd.frame.size.height / 2.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkEmailVerificationState(sender:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.lblMsg.text = "SENDING... TO"
        self.tfPwd.text = ""
        
        self.isEmailEditable = false
        tfEmail.text = Auth.auth().currentUser?.email
        tfEmail.textColor = UIColor.lightGray
        tfEmail.isEnabled = false
        tfEmail.resignFirstResponder()
        
        self.sendEmailVerificationEmail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tfEmail.resignFirstResponder()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @objc func checkEmailVerificationState(sender:Any) {
        Auth.auth().currentUser?.reload(completion: { (error) in
            if error != nil{
                
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                if !Auth.auth().currentUser!.isEmailVerified {
                    return
                }
                self.performSegue(withIdentifier: "showMainTabsFromEmailVerify", sender: self.btnSend)
            }
        })
    }
    
    // MARK: - Own Methods
    func showPwdInputView() {
        self.tfEmail.resignFirstResponder()
        
        self.viPwdInput.alpha = 0
        self.viPwdInput.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.viPwdInput.alpha = 1.0
        }) { (complete) in
            self.tfPwd.becomeFirstResponder()
        }
    }
    
    func hidePwdInputView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.viPwdInput.alpha = 0.0
            
        }) { (complete) in
            self.viPwdInput.isHidden = true
            self.tfPwd.resignFirstResponder()
            
            self.btnChange.setTitle("CHANGE", for: .normal)
            self.btnChange.setTitleColor(ColorPalette.pkRed, for: .normal)
            self.tfEmail.textColor = UIColor.lightGray
            self.tfEmail.isEnabled = false
            self.tfEmail.resignFirstResponder()
            
            self.isEmailEditable = false
            self.btnSend.isHidden = false
        }
    }
    
    func reAuthAndUpdateEmail() {
        self.tfPwd.resignFirstResponder()
        
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        let credential = EmailAuthProvider.credential(withEmail: (Auth.auth().currentUser?.email)!, password: self.tfPwd.text!)
        
        Auth.auth().currentUser!.reauthenticateAndRetrieveData(with: credential, completion: { (dataResult, error) in
            if let error = error {
                // An error happened.
                spinner.dismiss()
                self.hidePwdInputView()
                self.present(self.sharedManager.getErrorAlert(withError: error), animated: true, completion: nil)
                
            } else {
                // User re-authenticated.
                
                Auth.auth().currentUser?.updateEmail(to: self.tfEmail.text!, completion: { (error) in
                    if error != nil{
                        spinner.dismiss()
                        self.hidePwdInputView()
                        self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                    }
                    else {
                        spinner.dismiss()
                        
                        let dbRef = Database.database().reference()
                    dbRef.child("user_data").child(Auth.auth().currentUser!.uid).child("email").setValue(self.tfEmail.text)
                        self.sharedManager.myUser.email = self.tfEmail.text
                        
                        self.hidePwdInputView()
                        self.sendEmailVerificationEmail()
                    }
                })
                
            }
        })
    }
    
    func sendEmailVerificationEmail() {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
            }
            else {
                self.lblMsg.text = "✓ VERIFICATION EMAIL SENT TO "
                spinner.dismiss()
                
            }
        })
    }

    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfEmail {
            self.showPwdInputView()
        }
        else if textField == self.tfPwd {
            self.reAuthAndUpdateEmail()
        }
        return true
    }
    
    // MARK: - Event Handlers
    @IBAction func onPwdOk(_ sender: Any) {
        self.reAuthAndUpdateEmail()
    }
    
    @IBAction func onPwdCancel(_ sender: Any) {
        self.hidePwdInputView()
    }
    
    @IBAction func onResend(_ sender: Any) {
        self.sendEmailVerificationEmail()
    }
    
    @IBAction func onChange(_ sender: Any) {
        
        if !self.isEmailEditable {
            self.btnChange.setTitle("✓ DONE", for: .normal)
            self.btnChange.setTitleColor(ColorPalette.pkGreen, for: .normal)
            tfEmail.textColor = UIColor.black
            tfEmail.isEnabled = true
            tfEmail.becomeFirstResponder()
            
            self.isEmailEditable = true
            self.btnSend.isHidden = true
        }
        else {
            self.showPwdInputView()
        }
    }
    

}
