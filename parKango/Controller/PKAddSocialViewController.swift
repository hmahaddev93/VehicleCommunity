//
//  PKAddSocialViewController.swift

//
//  Created by Khatib H. on 3/24/19.
//  //

import UIKit
import Firebase
import JHSpinner
import WebKit

class PKAddSocialViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var tfInstaLink1: UITextField!
    @IBOutlet weak var tfInstaLink2: UITextField!
    @IBOutlet weak var tfInstaLink3: UITextField!
    
    @IBOutlet weak var viInsta1: UIView!
    @IBOutlet weak var viInsta2: UIView!
    @IBOutlet weak var viInsta3: UIView!
    
    @IBOutlet weak var btnAdd1: UIButton!
    @IBOutlet weak var btnAdd2: UIButton!
    @IBOutlet weak var btnAdd3: UIButton!
    
    let sharedManager:Singleton = Singleton.sharedInstance
    
    var arrLinks = [String]()
    var nAddSocialMode = PKAddSocialLinkMode.fromEditProfile
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.viInsta1.layer.masksToBounds = true
        self.viInsta1.layer.cornerRadius = self.viInsta1.frame.size.height / 2.0
        self.viInsta2.layer.masksToBounds = true
        self.viInsta2.layer.cornerRadius = self.viInsta2.frame.size.height / 2.0
        self.viInsta3.layer.masksToBounds = true
        self.viInsta3.layer.cornerRadius = self.viInsta3.frame.size.height / 2.0

        self.btnAdd1.layer.masksToBounds = true
        self.btnAdd1.layer.cornerRadius = self.btnAdd1.frame.size.height / 2.0
        
        self.btnAdd2.layer.masksToBounds = true
        self.btnAdd2.layer.cornerRadius = self.btnAdd2.frame.size.height / 2.0
        
        self.btnAdd3.layer.masksToBounds = true
        self.btnAdd3.layer.cornerRadius = self.btnAdd3.frame.size.height / 2.0
        
        self.btnDone.layer.masksToBounds = true
        self.btnDone.layer.cornerRadius = self.btnDone.frame.size.height / 2.0
        self.btnDone.layer.borderColor = ColorPalette.pkGreen.cgColor
        self.btnDone.layer.borderWidth = 1.0
        
        self.btnCancel.layer.masksToBounds = true
        self.btnCancel.layer.cornerRadius = self.btnCancel.frame.size.height / 2.0
        self.btnCancel.layer.borderColor = ColorPalette.pkRed.cgColor
        self.btnCancel.layer.borderWidth = 1.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onInstagramVerify1(notification:)), name: NSNotification.Name(rawValue: "instaVerifySuccess1"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onInstagramVerify2(notification:)), name: NSNotification.Name(rawValue: "instaVerifySuccess2"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onInstagramVerify3(notification:)), name: NSNotification.Name(rawValue: "instaVerifySuccess3"), object: nil)
        
        let tapBg = UITapGestureRecognizer(target: self, action:#selector(onTapBg(sender:)))
        self.view.addGestureRecognizer(tapBg)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.nAddSocialMode == PKAddSocialLinkMode.fromEditProfile {
            var i = 0
            for strLink in self.sharedManager.myUser.arrSocialLinks
            {
                if strLink.contains("instagram.com")
                {
                    if i == 0 {
                        self.tfInstaLink1.text = strLink
                    }
                    else if i == 1 {
                        self.tfInstaLink2.text = strLink
                    }
                    else if i == 2 {
                        self.tfInstaLink3.text = strLink
                    }
                    i = i + 1
                }
            }
        }
        else if self.nAddSocialMode == PKAddSocialLinkMode.fromSignUp {
            var i = 0
            for strLink in (self.sharedManager.dicRegisterValues["social_links"] as! [String])
            {
                if strLink.contains("instagram.com")
                {
                    if i == 0 {
                        self.tfInstaLink1.text = strLink
                    }
                    else if i == 1 {
                        self.tfInstaLink2.text = strLink
                    }
                    else if i == 2 {
                        self.tfInstaLink3.text = strLink
                    }
                    i = i + 1
                }
            }
        }
        
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
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    final class WebCacheCleaner {
        
        class func clear() {
            URLCache.shared.removeAllCachedResponses()
            
            HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            print("[WebCacheCleaner] All cookies deleted")
            
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                    print("[WebCacheCleaner] Record \(record) deleted")
                }
            }
            
            UserDefaults.standard.synchronize()
        }
        
    }
    
    // MARK: - Own Methods
    func getUpdatedInstaLinkWith(linkIdx: Int) {
        let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
        self.view.addSubview(spinner)
        
        // Get Instagram User Info with Access Token
        let instaUserInfoUrl = URL(string: String(format: InstagramAPI.INSTAGRAM_USER_INFO_URL_FORMAT, self.sharedManager.instaAccessToken))!
        
        let task = URLSession.shared.dataTask(with: instaUserInfoUrl) {(data, response, error) in
            
            DispatchQueue.main.async {
                spinner.dismiss()
            }
            
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
                            if linkIdx == 1 {
                                self.tfInstaLink1.text = String(format: "https://www.instagram.com/%@", self.sharedManager.instaUserInfo["username"] as! String)
                            }
                            else if linkIdx == 2 {
                                self.tfInstaLink2.text = String(format: "https://www.instagram.com/%@", self.sharedManager.instaUserInfo["username"] as! String)
                                
                            }
                            else if linkIdx == 3 {
                                self.tfInstaLink3.text = String(format: "https://www.instagram.com/%@", self.sharedManager.instaUserInfo["username"] as! String)
                                
                            }
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
    
    // MARK: - Event Handlers
    
    @objc func onInstagramVerify1(notification:Notification) {
        self.getUpdatedInstaLinkWith(linkIdx: 1)
    }
    
    @objc func onInstagramVerify2(notification:Notification) {
        self.getUpdatedInstaLinkWith(linkIdx: 2)
    }
    
    @objc func onInstagramVerify3(notification:Notification) {
        self.getUpdatedInstaLinkWith(linkIdx: 3)
    }
    
    @IBAction func onAdd1(_ sender: Any) {
        WebCacheCleaner.clear()
        
        let viCtrlInstaAuth = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PKInstagramAuthViewController") as! PKInstagramAuthViewController
        viCtrlInstaAuth.nInstaAuthMode = PKInstagramAuthMode.verifyProfile1
        self.present(viCtrlInstaAuth, animated: true, completion: nil)
    }
    
    @IBAction func onAdd2(_ sender: Any) {
        WebCacheCleaner.clear()

        let viCtrlInstaAuth = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PKInstagramAuthViewController") as! PKInstagramAuthViewController
        viCtrlInstaAuth.nInstaAuthMode = PKInstagramAuthMode.verifyProfile2
        self.present(viCtrlInstaAuth, animated: true, completion: nil)
    }
    
    @IBAction func onAdd3(_ sender: Any) {
        WebCacheCleaner.clear()

        let viCtrlInstaAuth = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PKInstagramAuthViewController") as! PKInstagramAuthViewController
        viCtrlInstaAuth.nInstaAuthMode = PKInstagramAuthMode.verifyProfile3
        self.present(viCtrlInstaAuth, animated: true, completion: nil)
    }
    
    @objc func onTapBg(sender: Any) {
        
    }
    
    @IBAction func onDone(_ sender: Any) {
        self.arrLinks.removeAll()
        
        if self.tfInstaLink1.text!.contains("instagram.com") {
            self.arrLinks.append(self.tfInstaLink1.text!)
        }
        
        if self.tfInstaLink2.text!.contains("instagram.com") {
            self.arrLinks.append(self.tfInstaLink2.text!)
        }
        
        //if self.lblInstaLink3.text?.trimmingCharacters(in: .whitespaces) != "" {
        //    self.arrLinks.append(self.lblInstaLink3.text!)
        //}
        
        if self.nAddSocialMode == PKAddSocialLinkMode.fromEditProfile {
            let spinner = JHSpinnerView.showOnView(view, spinnerColor:ColorPalette.pkRed, overlay:.roundedSquare, overlayColor:ColorPalette.pkLightGreen.withAlphaComponent(0.8), text:nil)
            self.view.addSubview(spinner)
            
            let dbRef = Database.database().reference()
            dbRef.child("user_data").child(self.sharedManager.myUser.uid!).child("social_links").setValue(arrLinks) { (error, dataRef) in
                if error != nil{
                    spinner.dismiss()
                    self.present(self.sharedManager.getErrorAlert(withError: error!), animated: true, completion: nil)
                }
                else {
                    spinner.dismiss()
                    self.sharedManager.myUser.arrSocialLinks = self.arrLinks
                    
                    self.dismiss(animated: true) {
                        
                    }
                }
            }
        }
        else if self.nAddSocialMode == PKAddSocialLinkMode.fromSignUp {
            self.sharedManager.dicRegisterValues["social_links"] = self.arrLinks
            self.dismiss(animated: true) {
                
            }
        }
        
        
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    
}
