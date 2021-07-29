//
//  PKForgotPasswordViewController.swift

//
//  Created by Khatib H. on 4/17/19.
//  //

import UIKit
import Firebase
import JHSpinner

class PKForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tfEmail: TextField!
    @IBOutlet weak var btnSend: UIButton!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "FORGOT PASSWORD"
        
        let doneButtonItem = UIBarButtonItem(title: "DONE", style: .done, target: self, action: #selector(self.onDone(sender:)))
        self.navigationItem.rightBarButtonItem = doneButtonItem
        
        // Do any additional setup after loading the view.
        tfEmail.layer.masksToBounds = true
        tfEmail.layer.cornerRadius = tfEmail.frame.size.height / 2.0
        
        btnSend.layer.masksToBounds = true
        btnSend.layer.cornerRadius = btnSend.frame.size.height / 2.0
        btnSend.layer.borderColor = ColorPalette.pkGreen.cgColor
        btnSend.layer.borderWidth = 1.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        tfEmail.text = self.email
        lblTitle.text = "FORGOT YOUR PASSWORD?"
        
        if tfEmail.text?.replacingOccurrences(of: " ", with: "") != "" {
            self.sendPasswordResetEmail()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Own Methods
    func sendPasswordResetEmail()
    {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        Auth.auth().sendPasswordReset(withEmail: (tfEmail.text?.lowercased())!) { (error) in
            if error != nil{
                spinner.dismiss()
                self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                self.tfEmail.becomeFirstResponder()
            }
            else {
                spinner.dismiss()
                self.lblTitle.text = "✓ EMAIL SENT.\n CHECK YOUR EMAIL."
                self.btnSend.setTitle("↻ RESEND", for: .normal)
                self.tfEmail.resignFirstResponder()
            }
        }
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.tfEmail {
            self.sendPasswordResetEmail()
        }
        return true
    }
    
    // MARK: - Event Handlers
    @objc func onDone(sender: Any) {
        self.tfEmail.resignFirstResponder()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onSend(_ sender: Any) {
        self.sendPasswordResetEmail()
    }
    
}
